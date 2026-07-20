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
  var _x = 0.5 * room_width;
  var _y = 0.5 * room_height;
  var _angle = dsin(current_time / 60) * 30;
  draw_clear_alpha(c_black, 0.0);
  draw_sprite_stretched(SPR_ABoxBlur_Example2_Scene, 0, 0, 0, _w, _h);
  draw_sprite_ext(SPR_ABoxBlur_Example1, 0, _x, _y, 3, 3, _angle, c_white, 1.0);
}
surface_reset_target();


// Update the contents of the blur.
// -> Surface and blur strength determines pixel-bases blur strength.
surface_set_target(self.surface.blur);
{
  draw_sprite_stretched(SPR_ABoxBlur_Example1_Blur, 0, 0, 0, _w, _h);
}
surface_reset_target();

