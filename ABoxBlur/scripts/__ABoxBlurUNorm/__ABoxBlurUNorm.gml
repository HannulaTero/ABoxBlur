

/**
* Hey! Don't use this directly!
* 
* Read information from ABoxBlur -function.
* Does the same as __ABoxBlurFloat, but without floating point textures.
* 
* Because the summation is encoded, it can't be interpolated.
* -> This means final blur-strength can only be whole number.
* -> Technically is possible to deal with it, but would have to manually interpolate.
* 
* To lessen the required iterations, alpha is always set to 1.
* -> Technically could do extra blur dimension there, but eh.
* 
* @ignore
*/ 
function __ABoxBlurUNorm(_dst, _src, _blur, _hstrength, _vstrength)
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
  
  
  // Ensure helper surfaces exist.
  if (surface_exists(ABoxBlur.tempDst) == false)
  {
    ABoxBlur.tempDst = surface_create(_layoutW, _layoutH);
  }
  
  if (surface_exists(ABoxBlur.tempSrc) == false)
  {
    ABoxBlur.tempSrc = surface_create(_layoutW, _layoutH);
  }
  
  
#endregion
//
//=============================================================
//
#region SET DESTINATION ALPHA TO 1.

  
  gpu_push_state();
  gpu_set_colourwriteenable(0,0,0,1);
  surface_set_target(_dst);
  draw_clear_alpha(c_black, 1.0);
  surface_reset_target();
  gpu_pop_state();

  
#endregion
//
//=============================================================
//
#region LOOP OVER THE COLOR CHANNELS - SKIP ALPHA.
  
  
  // Could iterate _channel < 4 to include alpha.
  for(var _channel = 0; _channel < 3; _channel++)
  {
  //=============================================================
  //
  #region UPDATE CHANNEL MASK.
  
  
    // For masking out correct color channel.
    ABoxBlur.channelMask[0] = (_channel == 0);
    ABoxBlur.channelMask[1] = (_channel == 1);
    ABoxBlur.channelMask[2] = (_channel == 2);
    ABoxBlur.channelMask[3] = (_channel == 3);
    
    
  #endregion
  //
  //=============================================================
  //
  #region USE SOURCE AS THE SEED.
  
  
    gpu_push_state();
    gpu_set_state(ABoxBlur.gpuState);
    shader_set(SHD_ABoxBlurUNorm_PrefixSum_Seed);
    {
      // Preparations.
      var _FSH_ChannelMask = shader_get_uniform(SHD_ABoxBlurUNorm_PrefixSum_Seed, "FSH_ChannelMask");
      
      // Apply the uniforms.
      shader_set_uniform_f_array(_FSH_ChannelMask, ABoxBlur.channelMask);
      
      // Get the seed value.
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
    shader_set(SHD_ABoxBlurUNorm_PrefixSum_Pass);
    {
      // Get uniforms.
      var _FSH_Jump   = shader_get_uniform(SHD_ABoxBlurUNorm_PrefixSum_Pass, "FSH_Jump");
      var _FSH_Texels = shader_get_uniform(SHD_ABoxBlurUNorm_PrefixSum_Pass, "FSH_Texels");
    
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
  #region APPLY THE BOX BLUR TO SELECTED COLOR CHANNEL.
  
    
    gpu_push_state();
    gpu_set_state(ABoxBlur.gpuState);
    gpu_set_colourwriteenable(ABoxBlur.channelMask);
    shader_set(SHD_ABoxBlurUNorm_Apply);
    {
      // Get shader uniforms.
      var _FSH_TexBlur  = shader_get_sampler_index(SHD_ABoxBlurUNorm_Apply, "FSH_TexBlur");
      var _FSH_Layout   = shader_get_uniform(SHD_ABoxBlurUNorm_Apply, "FSH_Layout");
      var _FSH_Multiply = shader_get_uniform(SHD_ABoxBlurUNorm_Apply, "FSH_Multiply");
    
      // Apply the uniforms.
      texture_set_stage(_FSH_TexBlur, surface_get_texture(_blur));
      shader_set_uniform_f(_FSH_Layout,   _layoutW, _layoutH);
      shader_set_uniform_f(_FSH_Multiply, _hstrength, _vstrength);
    
      // Render to the destination.
      surface_set_target(_dst);
      draw_surface_stretched(ABoxBlur.tempSrc, 0, 0, _layoutW, _layoutH);
      surface_reset_target();
    }
    shader_reset();
    gpu_pop_state();
  
  
  #endregion
  //
  //=============================================================
  } // End of the color channel for-loop.
  
    
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






