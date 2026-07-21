/// @desc FREE SURFACES & ASSETS.

// Free surfaces.
struct_foreach(self.surface, function(_key, _surface)
{
  if (surface_exists(_surface) == true)
  {
    surface_free(_surface);
  }
});


// Remove all assets from the room.
instance_destroy(PAR_ABoxBlur_Example5);