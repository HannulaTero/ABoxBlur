/// @desc APPLY THE ABOXLUR ON APPLICATION SURFACE.

// Verify surfaces exist.
self.VerifySurfaces();

if (surface_exists(application_surface) == false)
{
  exit;
}


// Get the blur-mask from distance.
var _texDepth = surface_get_texture_depth(application_surface);
gpu_push_state()
shader_set(SHD_ABoxBlur_Example5_GetDoF);
{
  // Preparations.
  var _FSH_ZParam = shader_get_uniform(SHD_ABoxBlur_Example5_GetDoF, "FSH_ZParam");
  var _FSH_Lower  = shader_get_uniform(SHD_ABoxBlur_Example5_GetDoF, "FSH_Lower");
  var _FSH_Upper  = shader_get_uniform(SHD_ABoxBlur_Example5_GetDoF, "FSH_Upper");
  
  // Match this with the camera.
  var _zparam = 2048.0;
  var _focus  = 0.5;
  with(OBJ_ABoxBlur_Example5_Camera)
  {
    _zparam = (self.zfar / self.znear);
    _focus  = self.focus; 
  }
  
  // Set the uniforms.
  shader_set_uniform_f(_FSH_ZParam, _zparam);
  shader_set_uniform_f(_FSH_Lower, _focus - 0.5);
  shader_set_uniform_f(_FSH_Upper, _focus + 0.5);
  
  // Get the blur.
}
gpu_pop_state();


// Apply the box-blur.
ABoxBlur(
  application_surface,
  application_surface,
  self.surface.blur,
  self.blurStrength,
  ABOXBLUR_FALLBACK
);


// Draw the application surface.
if (device_mouse_check_button(0, mb_left) == false)
{
  var _w = display_get_gui_width();
  var _h = display_get_gui_height();
  draw_surface_stretched(application_surface, 0, 0, _w, _h);
}