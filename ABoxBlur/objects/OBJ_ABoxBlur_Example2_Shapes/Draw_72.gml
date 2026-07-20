/// @desc UPDATE SURFACE CONTENTS.

// Verify surfaces exist.
self.VerifySurfaces();


// Preparations.
var _w = room_width;
var _h = room_height;


// Update the source surface.
// -> This can be anything.
surface_set_target(self.surface.src);
{
  draw_sprite_stretched(SPR_ABoxBlur_Example2_Scene, 0, 0, 0, _w, _h);
}
surface_reset_target();


// Update the contents of the blur.
// -> Surface and blur strength determines pixel-bases blur strength.
surface_set_target(self.surface.blur);
{
  draw_clear_alpha(c_black, 1.0);
  draw_sprite_ext(SPR_ABoxBlur_Example2_Blur, 0, mouse_x, mouse_y, 2, 2, self.rotation, c_white, 1.0);
}
surface_reset_target();

