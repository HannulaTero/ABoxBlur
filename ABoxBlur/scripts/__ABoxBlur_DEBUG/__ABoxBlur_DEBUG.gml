

/**
* Helper function to debug encodings etc.
* Floats can't be read from debugger, and sometimes you want read bytes too.
*/ 
function _ABoxBlur_DEBUG(_surface)
{
  var _w = surface_get_width(_surface);
  var _h = surface_get_height(_surface);
  var _temp = surface_create(_w, _h);
  
  surface_set_target(_temp);
  draw_clear_alpha(c_black, 1.0);
  draw_surface(_surface, 0, 0);
  surface_reset_target();
  surface_free(_temp);
  
  var _buff = buffer_create(1, buffer_grow, 1);
  buffer_get_surface(_buff, _surface, 0);
  buffer_delete(_buff);
}