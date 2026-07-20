/// @desc DRAW HUD.

gpu_push_state();
{
  // GPU Settings.
  draw_set_font(FONT_Courier);
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);
  
  // Preparations.
  var _x = 0;
  var _y = 0;
  var _w = room_width;
  var _h = room_height;
  var _text = "";
  
  // Get information.
  with(PAR_ABoxBlur_Example)
  {
    _text = string_join_ext("\n  ", self.Info());
  }
  
  // Draw the Info-backplate and text.
  var _textH = string_height(_text) + 16;
  draw_sprite_stretched_ext(SPR_ABoxBlur_Example_Backplate, 0, _x, _y, _w, _textH, c_black, 0.75);
  draw_text(8, 8, _text);
  
  
  // Get Manager information.
  _text = "Press NUMBERS to change example.";
  _textH = string_height(_text) + 16;
  _y = (_h - _textH);
  
  // Draw the Manager-backplate and text.
  draw_sprite_stretched_ext(SPR_ABoxBlur_Example_Backplate, 0, 0, _y, _w, _textH, c_black, 0.75);
  draw_text(8, _y + 8, _text);
}
gpu_pop_state();

