/// @desc CHANGE DIRECTION & BLUR STRENGTH.


// Rotate.
self.rotation += (
  + device_mouse_check_button(0, mb_left)
  - device_mouse_check_button(0, mb_right)
);


// Change blur strength.
if (mouse_wheel_down() == true)
{
  self.blurStrength *= 1.5;
}

if (mouse_wheel_up() == true)
{
  self.blurStrength /= 1.5;
}


self.blurStrength = clamp(self.blurStrength, 1.0, 256.0);


