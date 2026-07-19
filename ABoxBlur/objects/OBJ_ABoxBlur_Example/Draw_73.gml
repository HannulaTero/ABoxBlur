/// @desc 

// Verify surfaces exist.
if (surface_exists(self.surface.dst) == false)
{
  self.surface.dst = surface_create(
    room_width, room_height
  );
}

if (surface_exists(self.surface.src) == false)
{
  self.surface.src = surface_create(
    room_width, room_height
  );
}

if (surface_exists(self.surface.blur) == false)
{
  self.surface.blur = surface_create(
    room_width, room_height
  );
}


// Update surface contents.
surface_set_target(self.surface.dst);
draw_clear_alpha(c_black, 1.0);
surface_reset_target();

surface_set_target(self.surface.src);
draw_clear_alpha(c_black, 1.0);
draw_sprite_stretched(
  SPR_ABoxBlur_Example_Scene, 0, 0, 0, room_width, room_height
);
surface_reset_target();

surface_set_target(self.surface.blur);
draw_clear_alpha(c_black, 1.0);
draw_sprite(
  SPR_ABoxBlur_Example_Blur, 0, mouse_x, mouse_y
);
draw_clear_alpha(c_black, 1.0);


surface_reset_target();


// Apply the boxblur.
ABoxBlur(
  self.surface.dst,
  self.surface.src,
  self.surface.blur
);


// Draw the result.
draw_surface(self.surface.dst, 0, 0);
