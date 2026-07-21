

/**
* Hey! Don't use this directly!
* 
* Read information from ABoxBlur -function.
* 
* @ignore
*/ 
function __ABoxBlurFloat(_dst, _src, _blur, _hstrength, _vstrength)
{
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
#region ENSURE HELPER SURFACES EXIST.
  
  
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
  shader_set(SHD_ABoxBlurFloat_PrefixSum_Seed);
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
#region APPLY THE PREFIX SUM BOTH AXIS - GENERATE SUMMED AREA TABLE.
  
  
  gpu_push_state();
  gpu_set_state(ABoxBlur.gpuState);
  shader_set(SHD_ABoxBlurFloat_PrefixSum_Pass);
  {
    // Get uniforms.
    var _FSH_Jump   = shader_get_uniform(SHD_ABoxBlurFloat_PrefixSum_Pass, "FSH_Jump");
    var _FSH_Texels = shader_get_uniform(SHD_ABoxBlurFloat_PrefixSum_Pass, "FSH_Texels");
    
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
  
  
  gpu_push_state();
  gpu_set_state(ABoxBlur.gpuState);
  shader_set(SHD_ABoxBlurFloat_Apply);
  {
    // Get shader uniforms.
    var _FSH_TexBlur  = shader_get_sampler_index(SHD_ABoxBlurFloat_Apply, "FSH_TexBlur");
    var _FSH_Layout   = shader_get_uniform(SHD_ABoxBlurFloat_Apply, "FSH_Layout");
    var _FSH_Multiply = shader_get_uniform(SHD_ABoxBlurFloat_Apply, "FSH_Multiply");
    
    // Apply the uniforms.
    texture_set_stage(_FSH_TexBlur, surface_get_texture(_blur));
    shader_set_uniform_f(_FSH_Layout,   _layoutW, _layoutH);
    shader_set_uniform_f(_FSH_Multiply, _hstrength, _vstrength);
    
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






