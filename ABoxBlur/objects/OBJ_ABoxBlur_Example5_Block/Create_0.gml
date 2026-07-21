/// @desc INITIALIZATION.

self.image_index = irandom(sprite_get_number(sprite_index));

self.z      = random_range(-20, -250);
self.xrot   = random(360);
self.yrot   = random(360);
self.zrot   = random(360);
self.xscale = random_range(0.5, 2.0);
self.yscale = random_range(0.5, 2.0);
self.zscale = random_range(0.5, 2.0);
self.xspin  = random_range(-0.25, +0.25);
self.yspin  = random_range(-0.25, +0.25);
self.zspin  = random_range(-0.25, +0.25);


self.DrawBlock = function()
{
  // Just caching these.
  static identity   = matrix_build_identity();
  static transform  = matrix_build_identity();
  
  // Move block around.
  matrix_build(
    self.x, self.y, self.z, 
    self.xrot, self.yrot, self.zrot, 
    self.xscale, self.yscale, self.zscale, 
    transform
  );
  
  // Apply world transformations for the block.
  matrix_set(matrix_world, transform);
  draw_sprite(sprite_index, image_index, 0, 0);
  matrix_set(matrix_world, identity);
};

