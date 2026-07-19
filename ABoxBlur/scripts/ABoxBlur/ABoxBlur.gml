

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
* @param {Id.Surface} _dst  Where blurred image is stored.
* @param {Id.Surface} _src  The source image.
* @param {Id.Surface} _blur How large the box-blur should be. If not floating-point, then blur is multiplied by 64.0
*/ 
function ABoxBlur(_dst, _src, _blur)
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
  static tmp = {
    dst   : undefined,
    src   : undefined,
    timer : undefined,
    Swap  : function()
    {
      var _tmp = dst;
      dst = src;
      src = _tmp;
    }
  };
  
  
  // The helper surface dimensions.
  static layout = [ 1, 1 ]; // What is actual surface size for temporals.
  static texels = [ 1, 1 ]; // What are the texels.
  static active = [ 1, 1 ]; // What is active target area (active <= layout)
  

#endregion
//
//=============================================================
//
#region SANITY CHECKS.
  
  
  // Sanity check.
  if (surface_format_is_supported(surface_rgba32float) == false)
  {
    throw("[ABoxBlur] Surface format RGBA32FLOAT is not supported!");
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
  
  
#endregion
//
//=============================================================
//
#region PREPARE THE HELPER SURFACES.
  
  
  // Restart the cache deletion timer.
  if (ABoxBlur.tmp.timer != undefined)
  {
    call_cancel(ABoxBlur.tmp.timer);
  }
  call_later(1, time_source_units_seconds, function()
  {
    ABoxBlur.tmp.timer = undefined;
    if (surface_exists(ABoxBlur.tmp.dst) == true)
    {
      surface_free(ABoxBlur.tmp.dst);
    }
    if (surface_exists(ABoxBlur.tmp.src) == true)
    {
      surface_free(ABoxBlur.tmp.src);
    }
  });
  
  
  // Ensure cached surfaces have appropriate size.
  if (surface_exists(ABoxBlur.tmp.dst) == true)
  {
    var _w = surface_get_width(_src);
    var _h = surface_get_height(_src);
    if (ABoxBlur.layout[0] < _w)
    || (ABoxBlur.layout[1] < _h)
    {
      // Have to enlarge the surface.
      surface_free(ABoxBlur.tmp.dst);
      ABoxBlur.layout[0] = _w;
      ABoxBlur.layout[1] = _h;
      ABoxBlur.texels[0] = (1.0 / _w);
      ABoxBlur.texels[1] = (1.0 / _h);
    }
  }
  
  if (surface_exists(ABoxBlur.tmp.dst) == false)
  {
    ABoxBlur.tmp.dst = surface_create(
      ABoxBlur.layout[0],
      ABoxBlur.layout[1],
      surface_rgba32float
    );
  }
  
  if (surface_exists(ABoxBlur.tmp.src) == true)
  {
    var _w = surface_get_width(ABoxBlur.tmp.src);
    var _h = surface_get_height(ABoxBlur.tmp.src);
    if (ABoxBlur.layout[0] < _w)
    || (ABoxBlur.layout[1] < _h)
    {
      // Have to enlarge the surface.
      surface_free(ABoxBlur.tmp.src);
    }
  }
  
  if (surface_exists(ABoxBlur.tmp.src) == false)
  {
    ABoxBlur.tmp.src = surface_create(
      ABoxBlur.layout[0],
      ABoxBlur.layout[1],
      surface_rgba32float
    );
  }
  
  
#endregion
//
//=============================================================
//
#region OTHER PREPARATIONS.
  
  
  var _previosShader = shader_current();
  
  // Set the active area. 
  ABoxBlur.active[0] = surface_get_width(_src);
  ABoxBlur.active[1] = surface_get_height(_src);
  
  
#endregion
//
//=============================================================
//
#region USE SOURCE AS THE SEED.
  
  
  gpu_push_state();
  shader_set(SHD_ABoxBlur_PrefixSum_Seed);
  {
    surface_set_target(ABoxBlur.tmp.dst);
    draw_surface(_src, 0, 0);
    surface_reset_target();
    ABoxBlur.tmp.Swap();
  }
  shader_reset();
  gpu_pop_state();
  
  
#endregion
//
//=============================================================
//
#region APPLY THE PREFIX SUM BOTH AXIS.
  
  
  gpu_push_state();
  shader_set(SHD_ABoxBlur_PrefixSum_Pass);
  {
    // Preparations.
    var _FSH_Jump   = shader_get_uniform(SHD_ABoxBlur_PrefixSum_Pass, "FSH_Jump");
    var _FSH_Texels = shader_get_uniform(SHD_ABoxBlur_PrefixSum_Pass, "FSH_Texels");
    var _w = ABoxBlur.active[0];
    var _h = ABoxBlur.active[1];
    
    // Set uniforms, which don't change with loop.
    shader_set_uniform_f_array(_FSH_Jump, ABoxBlur.texels);
    
    // Do the horizontal passes
    for(var i = 1; i < _w; i *= 2)
    {
      shader_set_uniform_f(_FSH_Jump, i, 0);
      surface_set_target(ABoxBlur.tmp.dst);
      draw_surface_stretched(ABoxBlur.tmp.src, 0, 0, _w, _h);
      surface_reset_target();
      ABoxBlur.tmp.Swap();
    }
    
    // Do the vertical passes.
    for(var i = 1; i < _h; i *= 2)
    {
      shader_set_uniform_f(_FSH_Jump, i, 0);
      surface_set_target(ABoxBlur.tmp.dst);
      draw_surface_stretched(ABoxBlur.tmp.src, 0, 0, _w, _h);
      surface_reset_target();
      ABoxBlur.tmp.Swap();
    }
  }
  shader_reset();
  gpu_pop_state();
  
  
#endregion
//
//=============================================================
//
#region APPLY THE BOX BLUR
  
  
  gpu_push_state();
  shader_set(SHD_ABoxBlur_Apply);
  {
    // Preparations.
    var _FSH_Blur     = shader_get_sampler_index(SHD_ABoxBlur_Apply, "FSH_Blur");
    var _FSH_Multiply = shader_get_uniform(SHD_ABoxBlur_Apply, "FSH_Multiply");
    var _FSH_Texels   = shader_get_uniform(SHD_ABoxBlur_Apply, "FSH_Texels");
    
    var _w = surface_get_width(_dst);
    var _h = surface_get_height(_dst);
    
    var _blurMultiplier = 1.0;
    var _format = surface_get_format(_blur);
    if (_format != surface_rgba16float)
    && (_format != surface_rgba32float)
    && (_format != surface_r16float)
    && (_format != surface_r32float)
    {
      _blurMultiplier = 64.0;
    }
    
    
    // Apply the uniforms.
    // As temp-surfaces may be different size, it needs to be rescaled.
    texture_set_stage(_FSH_Blur,    surface_get_texture(_blur));
    shader_set_uniform_f(_FSH_Multiply, _blurMultiplier, _blurMultiplier);
    shader_set_uniform_f(_FSH_Texels, 
      ABoxBlur.texels[0] * (ABoxBlur.layout[0] / _w),
      ABoxBlur.texels[1] * (ABoxBlur.layout[1] / _h)
    );
    
    // Render to the destination.
    surface_set_target(_dst);
    draw_surface_stretched(ABoxBlur.tmp.src, 0, 0, _w, _h);
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






