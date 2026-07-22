/// @desc 

self.Draw = function()
{
  gpu_set_depth(-350);
  draw_sprite_stretched(SPR_ABoxBlur_Example_Clouds, 0, -2048, -2048, 4096, 4096);
};