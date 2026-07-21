/// @desc FREE SURFACES.

struct_foreach(self.surface, function(_key, _surface)
{
  if (surface_exists(_surface) == true)
  {
    surface_free(_surface);
  }
});