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
  draw_sprite_stretched(SPR_ABoxBlur_Example_Puupaa, 0, 0, 0, _w, _h);
  draw_sprite_ext(SPR_ABoxBlur_Example_HelloWorld, 0, _x, _y, 2, 2, _angle, c_white, 1.0);
}
surface_reset_target();


// Update the contents of the blur.
// This has rudamentary drawing thing.
surface_set_target(self.surface.blur);
{
  if (keyboard_check_pressed(vk_delete) == true)
  {
    draw_clear_alpha(c_black, 1.0);
  }
  
  var _color = undefined;
  
  // Use distance to determine whether to draw or not.
  // When clicking ensure it is drawn.
  var _distance = point_distance(mouse_x, mouse_y, self.mousePrevX, self.mousePrevY);
  if (_distance > 0.0)
  || (device_mouse_check_button_pressed(0, mb_left) == true)
  || (device_mouse_check_button_pressed(0, mb_right) == true)
  {
    if (device_mouse_check_button(0, mb_left) == true)
    {
      _color = c_white;
    }
  
    if (device_mouse_check_button(0, mb_right) == true)
    {
      _color = c_black;
    }
  
    if (_color != undefined)
    {
      var _sprite = SPR_ABoxBlur_Example4_Brush;
      var _scale  = self.brushRadius * 2.0 / sprite_get_width(_sprite);
      var _steps  = 16;
      for(var i = 0.5; i < _steps; i++)
      {
        var _ratio = (i / _steps);
        var _x = lerp(self.mousePrevX, mouse_x, _ratio);
        var _y = lerp(self.mousePrevY, mouse_y, _ratio);
        draw_sprite_ext(_sprite, 0, _x, _y, _scale, _scale, 0, _color, 0.1);
      }
    }
  }
  
  self.mousePrevX = mouse_x;
  self.mousePrevY = mouse_y;
}
surface_reset_target();

