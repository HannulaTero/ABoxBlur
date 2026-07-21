/// @desc CHANGE BRUSH.


// Change brush-radius.
if (mouse_wheel_down() == true)
{
  self.brushRadius *= 1.5;
}

if (mouse_wheel_up() == true)
{
  self.brushRadius /= 1.5;
}


self.brushRadius = clamp(self.brushRadius, 1.0, 256.0);
