/// @desc 

if (instance_number(object_index) > 1)
{
  instance_destroy();
  exit;
}


display_set_gui_size(room_width, room_height);


self.DrawText = function(_x, _y, _text)
{
  // Quick and dirty. Don't do this.
  draw_set_color(c_black);
  draw_text(_x-1, _y-1, _text);
  draw_text(_x-1, _y+1, _text);
  draw_text(_x+1, _y-1, _text);
  draw_text(_x+1, _y+1, _text);
  draw_set_color(c_white);
  draw_text(_x, _y, _text);
};

