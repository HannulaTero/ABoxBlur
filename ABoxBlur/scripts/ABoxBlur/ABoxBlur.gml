

/**
* Applies variable/arbitrary sized Box-blur.
* 
* For this, summed-area table is generated using parallel prefix scan.
* -> Read more : https://en.wikipedia.org/wiki/Summed-area_table
* 
* Prefix scan is Hillis-Steele -style naive scan (not work-efficient)
* -> This is just easier to implement with fragment shaders.
* -> Alternative would be Blelloch, which is harder (but possible).
* 
* This should be called in Draw-event.
* 
* This requires float32-textures, as summation can get large.
* -> Reason: If surface of 1024x1024 has in average values 0.5, then total sum is over 500k
* -> This well exceeds float16-texture, which is why it can't be used.
* Alternatively rgba8unorm pixel could represent single color channel summation 
* -> This is more cumbersome, but allows higher compatibility.
* 
* @param {Id.Surface} _dst        Where blurred image is stored.
* @param {Id.Surface} _src        The source image. Can be same as destination.
* @param {Id.Surface} _blur       How box-blur is applied in source image.
* @param {Real}       _strength   Multiplier for blur - for normalized blur-texture really important.
*/ 
function ABoxBlur(_dst, _src, _blur, _strength=64.0)
{
//=============================================================
//
#region STATIC VARIABLES.

  
  static gpuState = method_call(function() 
  {
    // Create a new GPU state.
    gpu_push_state();
    gpu_set_colorwriteenable(true, true, true, true);
    gpu_set_alphatestenable(false);
    gpu_set_blendenable(false);
    gpu_set_blendmode_ext(bm_one, bm_zero);
    gpu_set_zwriteenable(false);
    gpu_set_ztestenable(false);
    gpu_set_stencil_enable(false);
    gpu_set_tex_filter(false);
    gpu_set_tex_repeat(true);
    gpu_set_tex_mip_enable(false);
    gpu_set_fog(false, c_white, 1, 2);
    gpu_set_cullmode(cull_noculling);
    
    // Return the state.
    var _state = gpu_get_state();
    gpu_pop_state();
    return _state;
  });
  
  
  // Helper surfaces.
  // -> Keep them cached/alive for short period, if function is called again.
  static tempDst  = undefined;
  static tempSrc  = undefined;
  static timer    = undefined;
  static Swap     = function()
  {
    var _tmp = ABoxBlur.tempDst;
    ABoxBlur.tempDst = ABoxBlur.tempSrc;
    ABoxBlur.tempSrc = _tmp;
  };
  
  
#endregion
//
//=============================================================
//
#region PREPARATIONS.
  
  
  var _layoutW = surface_get_width(_src);
  var _layoutH = surface_get_height(_src);
  var _texelsW = (1.0 / _layoutW);
  var _texelsH = (1.0 / _layoutH);
  var _previosShader = shader_current();
  

#endregion
//
//=============================================================
//
#region SANITY CHECKS.
  
  
  // Sanity check.
  if (surface_format_is_supported(surface_rgba32float) == false)
  {
    throw("[ABoxBlur] Required RGBA32FLOAT is not supported!");
    return;
  }
  
  if (os_type == os_gxgames) 
  || (os_browser != browser_not_a_browser)
  {
    // From own tests HTML5 doesn't work, and GX has too many artefacts.
    // Therefore unusable.
    throw("[ABoxBlur] Not supported on browsers!");
    return;
  }
  
  
  if (surface_exists(_dst) == false)
  {
    throw("[ABoxBlur] Destination surface doesn't exist!");
    return;
  }
  
  if (surface_exists(_src) == false)
  {
    throw("[ABoxBlur] Source surface doesn't exist!");
    return;
  }
  
  if (surface_exists(_blur) == false)
  {
    throw("[ABoxBlur] Blur-size surface doesn't exist!");
    return;
  }
  
  if (_layoutW != surface_get_width(_dst))  
  || (_layoutW != surface_get_width(_blur)) 
  || (_layoutH != surface_get_height(_dst))
  || (_layoutH != surface_get_height(_blur))
  {
    throw("[ABoxBlur] Surfaces size must match!");
    return;
  }
  
  
#endregion
//
//=============================================================
//
#region HANDLE CACHE REMOVAL.
  
  
  // Restart the cache deletion timer.
  if (ABoxBlur.timer != undefined)
  {
    call_cancel(ABoxBlur.timer);
  }
  
  call_later(1, time_source_units_seconds, function()
  {
    ABoxBlur.timer = undefined;
    if (surface_exists(ABoxBlur.tempDst) == true)
    {
      surface_free(ABoxBlur.tempDst);
    }
    if (surface_exists(ABoxBlur.tempSrc) == true)
    {
      surface_free(ABoxBlur.tempSrc);
    }
  });
  
  
  // Ensure cached surfaces have appropriate size.
  if (surface_exists(ABoxBlur.tempDst) == true)
  {
    if (_layoutW != surface_get_width(ABoxBlur.tempDst))
    || (_layoutH != surface_get_height(ABoxBlur.tempDst))
    {
      surface_free(ABoxBlur.tempDst);
    }
  }
  
  if (surface_exists(ABoxBlur.tempSrc) == true)
  {
    if (_layoutW != surface_get_width(ABoxBlur.tempSrc))
    || (_layoutH != surface_get_height(ABoxBlur.tempSrc))
    {
      surface_free(ABoxBlur.tempSrc);
    }
  }
  

#endregion
//
//=============================================================
//
#region ENSURE HELPER SURFACES EXIST.
  
  
  // Ensure helper surfaces exist.
  if (surface_exists(ABoxBlur.tempDst) == false)
  {
    ABoxBlur.tempDst = surface_create(_layoutW, _layoutH, surface_rgba32float);
  }
  
  if (surface_exists(ABoxBlur.tempSrc) == false)
  {
    ABoxBlur.tempSrc = surface_create(_layoutW, _layoutH, surface_rgba32float);
  }
  
  
#endregion
//
//=============================================================
//
#region USE SOURCE AS THE SEED.
  
  
  gpu_push_state();
  gpu_set_state(ABoxBlur.gpuState);
  shader_set(SHD_ABoxBlur_PrefixSum_Seed);
  {
    surface_set_target(ABoxBlur.tempDst);
    draw_surface(_src, 0, 0);
    surface_reset_target();
    ABoxBlur.Swap();
  }
  shader_reset();
  gpu_pop_state();
  
  
#endregion
//
//=============================================================
//
#region APPLY THE PREFIX SUM BOTH AXIS.
  
  
  gpu_push_state();
  gpu_set_state(ABoxBlur.gpuState);
  shader_set(SHD_ABoxBlur_PrefixSum_Pass);
  {
    // Get uniforms.
    var _FSH_Jump   = shader_get_uniform(SHD_ABoxBlur_PrefixSum_Pass, "FSH_Jump");
    var _FSH_Texels = shader_get_uniform(SHD_ABoxBlur_PrefixSum_Pass, "FSH_Texels");
    
    // Set uniforms, which don't change with loop.
    shader_set_uniform_f(_FSH_Texels, _texelsW, _texelsH);
    
    // Do the horizontal passes.
    // Offset are used to avoid unnecessary fragments.
    // -> But must allow previous results to be copied over.
    var _woffset = 0;
    for(var i = 1; i < _layoutW; i *= 2)
    {
      shader_set_uniform_f(_FSH_Jump, i, 0);
      surface_set_target(ABoxBlur.tempDst);
      draw_surface_stretched(ABoxBlur.tempSrc, 
        _woffset, 0, _layoutW - _woffset, _layoutH
      );
      surface_reset_target();
      ABoxBlur.Swap();
      _woffset = i;
    }
    
    // Do the vertical passes.
    var _hoffset = 0;
    for(var i = 1; i < _layoutH; i *= 2)
    {
      shader_set_uniform_f(_FSH_Jump, 0, i);
      surface_set_target(ABoxBlur.tempDst);
      draw_surface_stretched(ABoxBlur.tempSrc, 
        0, _hoffset, _layoutW, _layoutH - _hoffset
      );
      surface_reset_target();
      ABoxBlur.Swap();
      _hoffset = i;
    }
  }
  shader_reset();
  gpu_pop_state();
  
  
#endregion
//
//=============================================================
//
#region APPLY THE BOX BLUR
  
    
    
  // Check if source is same as destination,
  // as this can't be done. If yes, use temporary target instead.
  var _original = _src;
  if (_dst == _src)
  {
    _original = ABoxBlur.tempDst;
    gpu_push_state();
    surface_set_target(_original);
    draw_surface(_src, 0, 0);
    surface_reset_target();
    gpu_pop_state();
  }
  
  gpu_push_state();
  gpu_set_state(ABoxBlur.gpuState);
  shader_set(SHD_ABoxBlur_Apply);
  {
    // Get shader uniforms.
    var _FSH_TexSrc   = shader_get_sampler_index(SHD_ABoxBlur_Apply, "FSH_TexSrc");
    var _FSH_TexBlur  = shader_get_sampler_index(SHD_ABoxBlur_Apply, "FSH_TexBlur");
    var _FSH_Layout   = shader_get_uniform(SHD_ABoxBlur_Apply, "FSH_Layout");
    var _FSH_Multiply = shader_get_uniform(SHD_ABoxBlur_Apply, "FSH_Multiply");
    
    // Apply the uniforms.
    texture_set_stage(_FSH_TexSrc,  surface_get_texture(_original));
    texture_set_stage(_FSH_TexBlur, surface_get_texture(_blur));
    shader_set_uniform_f(_FSH_Layout,   _layoutW, _layoutH);
    shader_set_uniform_f(_FSH_Multiply, _strength, _strength);
    
    // Render to the destination.
    surface_set_target(_dst);
    draw_surface_stretched(ABoxBlur.tempSrc, 0, 0, 
      surface_get_width(_dst), surface_get_height(_dst)
    );
    surface_reset_target();
  }
  shader_reset();
  gpu_pop_state();
  
  
#endregion
//
//=============================================================
//
#region FINALIZATION.
  
  
  // Return previous shader.
  if (_previosShader != -1)
  {
    shader_set(_previosShader);
  }
  
  
#endregion
//
//=============================================================
}






