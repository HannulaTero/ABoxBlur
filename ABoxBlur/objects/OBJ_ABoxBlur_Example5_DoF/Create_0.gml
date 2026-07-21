/// @desc 


// Information for the manager.
self.Info = function()
{
  var _focus = 0.5;
  with(OBJ_ABoxBlur_Example5_Camera)
  {
    _focus = self.focus; 
  }
  
  return [
    $"EXAMPLE [5] Depth of Field : Uses depth to apply the blur",
    $"[WASD] Move around. [MOUSE LEFT] Look around. [SCROLL] Change focus.",
    $"Blur strength : {self.blurStrength}. Focus : {_focus}"
  ];
};


// How strongly blur is applied.
self.blurStrength = 32.0;


// Inputs and target for ABoxBlur.
self.surface = {
  blur : undefined,
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


// Create instances to move around etc.
instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example5_Camera);
instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example5_Floor);
instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example5_Ceil);
instance_create_depth(0, 0, 0, OBJ_ABoxBlur_Example5_Sky);
repeat(64)
{
  var _random = sqrt(random(1.0)); // Biased as circular.
  var _length = lerp(128, 512, _random);
  var _angle  = random(360);
  var _x = lengthdir_x(_length, _angle);
  var _y = lengthdir_y(_length, _angle); 
  instance_create_depth(_x, _y, 0, OBJ_ABoxBlur_Example5_Block);
}







