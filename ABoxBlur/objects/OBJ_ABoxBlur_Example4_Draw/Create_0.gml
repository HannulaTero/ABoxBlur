/// @desc 


// Information for the manager.
self.Info = function()
{
  return [
    $"EXAMPLE [4] Draw : Blurmask is surface, which can be edited",
    $"[MOUSE LEFT/RIGHT] Draw/Erase blur",
    $"[MOUSE WHEEL]      Change brush radius",
    $"[DELETE]           Clear the blurmask.",
    $"Blur strength : {self.blurStrength}, Draw radius : {self.brushRadius}",
  ];
};


// How large the brush is for drawing.
self.brushRadius = 32;
self.mousePrevX = mouse_x;
self.mousePrevY = mouse_y;


// How strongly blur is applied.
self.blurStrength = [ 32.0, 32.0 ];


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