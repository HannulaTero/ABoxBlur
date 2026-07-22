/// @desc 


event_inherited();
depth = -1000;


// Camera position and target.
self.camera       = camera_create();
self.viewMatrix   = matrix_build_identity();
self.projMatrix   = matrix_build_identity();

self.fov    = 60.0;
self.znear  = 1.0;
self.zfar   = 1024.0;
self.focus  = 0.15;

self.xat = x;
self.yat = y;
self.zat = -150.0;

self.xto = self.xat + 1.0;
self.yto = self.yat;
self.zto = self.zat;

self.xup = 0.0;
self.yup = 0.0;
self.zup = 1.0;

self.len = 512.0;
self.dir = 0.0;
self.rot = 0.0;