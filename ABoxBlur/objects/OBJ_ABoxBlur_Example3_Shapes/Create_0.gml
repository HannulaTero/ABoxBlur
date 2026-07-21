/// @desc 


// Information for the manager.
self.Info = function()
{
  return [
    $"EXAMPLE [2] Shapes : Blurmask can be arbitrary",
    $"Use [MOUSE] to move and rotate shape, change blur strength [MOUSE WHEEL]",
    $"Blur strength : {self.blurStrength}"
  ];
};


// How strongly blur is applied.
self.blurStrength = 32.0;
self.rotation = random(360);

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