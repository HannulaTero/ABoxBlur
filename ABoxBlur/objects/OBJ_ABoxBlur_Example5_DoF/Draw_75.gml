/// @desc APPLY THE ABOXLUR ON APPLICATION SURFACE.

// Verify surfaces exist.
self.VerifySurfaces();

if (surface_exists(application_surface) == false)
{
  exit;
}


// Get the blur-mask from distance.
gpu_push_state()
gpu_set_state(ABoxBlur.gpuState);
shader_set(SHD_ABoxBlur_Example5_GetDoF);
{
  // Preparations.
  var _FSH_ZParam = shader_get_uniform(SHD_ABoxBlur_Example5_GetDoF, "FSH_ZParam");
  var _FSH_Lower  = shader_get_uniform(SHD_ABoxBlur_Example5_GetDoF, "FSH_Lower");
  var _FSH_Upper  = shader_get_uniform(SHD_ABoxBlur_Example5_GetDoF, "FSH_Upper");
  
  var _w = surface_get_width(application_surface);
  var _h = surface_get_height(application_surface);
  var _texDepth = surface_get_texture_depth(application_surface);
  
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
  surface_set_target(self.surface.blur);
  {
    draw_primitive_begin_texture(pr_trianglestrip, _texDepth);
    draw_vertex_texture(0, 0, 0, 0);
    draw_vertex_texture(_w, 0, 1, 0);
    draw_vertex_texture(0, _h, 0, 1);
    draw_vertex_texture(_w, _h, 1, 1);
    draw_primitive_end();
  }
  surface_reset_target();
}
shader_reset();
gpu_pop_state();


// Apply the box-blur.
ABoxBlur(
  self.surface.dst,
  application_surface,
  self.surface.blur,
  self.blurStrength,
  ABOXBLUR_FALLBACK
);


// Draw the application surface.
gpu_push_state()
{
  var _guiW = display_get_gui_width();
  var _guiH = display_get_gui_height();
  draw_surface_stretched(self.surface.dst, 0, 0, _guiW, _guiH);
}
gpu_pop_state();





