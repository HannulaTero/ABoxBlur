/// @desc CAMERA CONTROLS.


// Move the camera around in XY-plane.
{
  var _dx = real(keyboard_check(ord("W"))) - real(keyboard_check(ord("S")));
  var _dy = real(keyboard_check(ord("D"))) - real(keyboard_check(ord("A")));
  var _dir = point_direction(0, 0, _dx, _dy);
  var _len = point_distance(0, 0, _dx, _dy);
  var _spd = (keyboard_check(vk_shift) == false) ? 6.0 : 16.0;
  
  if (_len > 0.0)
  {
    self.xat += lengthdir_x(_spd, _dir + self.dir);
    self.yat += lengthdir_y(_spd, _dir + self.dir);
  }
}


// Move the camera around in Z-axis.
if (keyboard_check(ord("Q")) == true)
{
  self.zat += 4.0;
}

if (keyboard_check(ord("E")) == true)
{
  self.zat -= 4.0;
}


// Rotate the camera.
if (device_mouse_check_button(0, mb_left) == true)
{
  var _dx = window_mouse_get_delta_x() * 0.15;
  var _dy = window_mouse_get_delta_y() * 0.15;
  window_mouse_set_locked(true);
  
  self.dir -= _dx;
  self.rot -= _dy;
  self.rot = clamp(self.rot, -80, +80);
}
else
{
  window_mouse_set_locked(false);
}


// Change the focus.
if (mouse_wheel_down() == true)
{
  self.focus += 0.025;
}
if (mouse_wheel_up() == true)
{
  self.focus -= 0.025;
}
self.focus = clamp(self.focus, -1.5, +0.5);


// Update target position and lookat.
var _xrot = lengthdir_x(1.0, self.rot);
self.xto = self.xat + lengthdir_x(self.len, self.dir) * _xrot;
self.yto = self.yat + lengthdir_y(self.len, self.dir) * _xrot;
self.zto = self.zat + lengthdir_y(self.len, self.rot);


