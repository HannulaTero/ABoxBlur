

/**
* Applies variable/arbitrary sized Box-blur.
* 
* For this, summed-area table is generated using parallel prefix scan.
* -> Read more : https://en.wikipedia.org/wiki/Summed-area_table
* 
* Parallel Prefix scan is Hillis-Steele -style naive scan (not work-efficient)
* -> This is just easier to implement with fragment shaders.
* -> Alternative would be Blelloch, which is harder (but possible).
* -> Read more : https://en.wikipedia.org/wiki/Prefix_sum
* 
* This should be called in Draw-event.
* 
* Direct version requires float32-textures, as summation can get large.
* -> Reason: If surface of 1024x1024 has in average values 0.5, then total sum is over 500k
* -> This well exceeds float16-texture, which is why it can't be used.
* 
* If float-textures are not supported, ABoxBlur provides fallback version.
* -> This only uses rgba8unorm surfaces, where pixel represents single color channel summation 
* -> This is more cumbersome, requires more passes, but allows higher compatibility.
* -> You may enforce this use anyways.
* 
* @param {Id.Surface}       _dst          Where blurred image is stored.
* @param {Id.Surface}       _src          The source image. Can be same as destination.
* @param {Id.Surface}       _blur         How box-blur is applied in source image.
* @param {Real|Array<Real>} _strength     Multiplier for blur - for normalized blur-texture really important.
* @param {Bool}             _useFallback  Whether force the use of compatibility version (only rgba8unorm).
*/ 
function ABoxBlur(_dst, _src, _blur, _strength=16.0, _useFallback=false)
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
    gpu_set_tex_repeat(false);
    gpu_set_tex_mip_enable(false);
    gpu_set_fog(false, c_white, 1, 2);
    gpu_set_cullmode(cull_noculling);
    
    // Return the state.
    var _state = gpu_get_state();
    gpu_pop_state();
    return _state;
  });
  
  
  // Whether has warned RGBA32FLOAT not being supported.
  static hasWarned = false;
  
  
  // To mask out which color channel is used (UNorm-version).
  static channelMask = array_create(4, false);
  
  
  // Helper surfaces.
  // -> Keep them cached/alive for short period, if function is called again.
  static tempDst  = undefined;
  static tempSrc  = undefined;
  static Swap     = function()
  {
    var _tmp = ABoxBlur.tempDst;
    ABoxBlur.tempDst = ABoxBlur.tempSrc;
    ABoxBlur.tempSrc = _tmp;
  };
  
  
  // Timer to remove helper surfaces after inactivity.
  static timer = method_call(function()
  {
    var _timer = time_source_create(
      time_source_game, 
      1, time_source_units_seconds, 
      function()
      {
        show_debug_message("[ABoxBlur] Freed the cached surfaces.");
        if (surface_exists(ABoxBlur.tempDst) == true)
        {
          surface_free(ABoxBlur.tempDst);
        }
        if (surface_exists(ABoxBlur.tempSrc) == true)
        {
          surface_free(ABoxBlur.tempSrc);
        }
      },
      [ ], -1
    );
    time_source_start(_timer);
    return _timer;
  });
  
  
  
#endregion
//
//=============================================================
//
#region PREPARATIONS.
  
  
  // Get source size.
  var _layoutW = surface_get_width(_src);
  var _layoutH = surface_get_height(_src);
  
  // Get blur strength - horizontal and vertical.
  var _hstrength = 1.0;
  var _vstrength = 1.0;
  if (is_numeric(_strength) == true)
  {
    _hstrength = _strength;
    _vstrength = _strength;
  }
  else if (is_array(_strength) == true)
  {
    _hstrength = _strength[0];
    _vstrength = _strength[1];
  }
  
  
#endregion
//
//=============================================================
//
#region SANITY CHECKS.
  
  
  // Sanity check.
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
  time_source_reset(ABoxBlur.timer);
  time_source_start(ABoxBlur.timer);
  
  
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
#region CHOOSE WHICH VERSION IS BEING USED.
  
  
  // Use compatibility anyways.
  if (_useFallback == true)
  {
    return __ABoxBlurUNorm(_dst, _src, _blur, _hstrength, _vstrength);
  }
  
  
  // Check whether is not supported.
  // From own tests HTML5 doesn't work, and GX has too many artefacts with float-textures.
  if (surface_format_is_supported(surface_rgba32float) == false)
  || (os_type == os_gxgames) || (os_browser != browser_not_a_browser)
  {
    // Give single warning to not spam it.
    if (ABoxBlur.hasWarned == false)
    {
      show_debug_message("[ABoxBlur] Required 'rgba32float' is not supported!");
      show_debug_message("[ABoxBlur] -> Using fallback 'rgba8unorm' version!");
      ABoxBlur.hasWarned = true;
    }
    
    return __ABoxBlurUNorm(_dst, _src, _blur, _hstrength, _vstrength);
  }
  
  
  // Using float version.
  return __ABoxBlurFloat(_dst, _src, _blur, _hstrength, _vstrength);
  
  
#endregion
//
//=============================================================
}






