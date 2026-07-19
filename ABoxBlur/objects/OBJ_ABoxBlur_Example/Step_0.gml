/// @desc 

if (device_mouse_check_button(0, mb_left) == true)
{
  direction += 1;
}

if (device_mouse_check_button(0, mb_right) == true)
{
  direction -= 1;
}