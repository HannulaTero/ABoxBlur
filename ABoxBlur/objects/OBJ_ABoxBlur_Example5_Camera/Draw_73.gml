/// @desc DRAW THE SCENE

gpu_push_state();
{
  // Update the matrixes.
  camera_set_view_mat(self.camera, self.viewMatrix);
  camera_set_proj_mat(self.camera, self.projMatrix);
  camera_apply(self.camera);

  // Set the gpu settings.
  var _fogColor = make_color_rgb(160, 150, 200);
  gpu_set_fog(true, _fogColor, 64, self.zfar);
  gpu_set_ztestenable(true);
  gpu_set_sprite_cull(false);
  
  // Render the elements.
  draw_clear_alpha(_fogColor, 1.0);
  with(PAR_ABoxBlur_Example5)
  {
    gpu_set_depth(0);
    self.Draw();
  }
}
gpu_pop_state();