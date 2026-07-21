/// @desc 


// Information for the manager.
self.Info = function()
{
  return [
    $"EXAMPLE [2] Blur Axis : RG-colors of blurmask apply horizontal/vertical blur.",
    $"[MOUSE MOVE] Change blur strength.",
    $"[MOUSE LEFT] Hide/unhide blur-mask.",
    $"Horizontal strength : {self.blurStrength[0]}",
    $"Vertical strength   : {self.blurStrength[1]}"
  ];
};


// How strongly blur is applied.
self.blurStrength = [ 0.0, 0.0 ];


// Inputs and target for ABoxBlur.
self.surface = {
  blur : undefined,
  src : undefined,
  dst : undefined,
};


// To verify surfaces exists.
self.VerifySurfaces = function()
{
  struct_foreach(self.surface, function(_key, _surface)
  {
    if (surface_exists(_surface) == false)
    {
      self.surface[$ _key] = surface_create(room_width, room_height);
    }
  });
};