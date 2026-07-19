/// @desc 

var _w = room_width;
var _h = room_height;

// Verify surfaces exist.
if (surface_exists(self.surface.dst) == false)
{
  self.surface.dst = surface_create(_w, _h);
}

if (surface_exists(self.surface.src) == false)
{
  self.surface.src = surface_create(_w, _h);
}

if (surface_exists(self.surface.blur) == false)
{
  self.surface.blur = surface_create(_w, _h);
}


// Update surface contents.
surface_set_target(self.surface.dst);
draw_clear_alpha(c_black, 1.0);
surface_reset_target();

surface_set_target(self.surface.src);
draw_clear_alpha(c_black, 1.0);
draw_sprite_stretched(
  SPR_ABoxBlur_Example_Scene, 0, 0, 0, _w, _h
);
surface_reset_target();

surface_set_target(self.surface.blur);
{
  draw_clear_alpha(c_black, 1.0);
  gpu_push_state();
  {
    var _angle = direction;
    gpu_set_blendmode(bm_add);
    // draw_sprite_ext(
    //   SPR_ABoxBlur_Example_Blur, 0, 0, 0, 2, 2, _angle, c_white, 1.0
    // );
    draw_sprite_ext(
      SPR_ABoxBlur_Example_Blur, 0, mouse_x, mouse_y, 2, 2, _angle, c_white, 1.0
    );
  }
  gpu_pop_state();
}
surface_reset_target();


// Apply the boxblur.
ABoxBlur(
  self.surface.dst,
  self.surface.src,
  self.surface.blur, 128
);


// Draw the result.
draw_surface(self.surface.dst, 0, 0);
