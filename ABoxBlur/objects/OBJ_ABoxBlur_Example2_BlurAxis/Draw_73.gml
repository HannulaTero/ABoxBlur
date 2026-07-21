/// @desc DRAW THE RESULTS.

// Verify surfaces exist.
self.VerifySurfaces();


// Preparations.
var _w = room_width;
var _h = room_height;


// Draw the result.
draw_surface(self.surface.dst, 0, 0);


// Draw how blur mask is being applied
gpu_push_state();
{
  gpu_set_blendmode(bm_add);
  if (device_mouse_check_button(0, mb_left) == false)
  {
    draw_sprite_stretched_ext(SPR_ABoxBlur_Example2_Blur, 0, 0, 0, _w, _h, c_white, 0.2);
  }

  draw_set_color(c_white);
  draw_line(_w * 0.5, _h * 0.5, mouse_x, mouse_y);
  draw_set_color(c_red);
  draw_line(_w * 0.5, _h * 0.5, mouse_x, _h * 0.5);
  draw_set_color(c_green);
  draw_line(_w * 0.5, _h * 0.5, _w * 0.5, mouse_y);
  draw_set_color(c_white);
}
gpu_pop_state();


