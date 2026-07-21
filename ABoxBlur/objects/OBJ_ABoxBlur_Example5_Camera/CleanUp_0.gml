/// @desc RETURN BACK PREV VIEW.

view_camera[0] = self.prevCam;
camera_destroy(self.camera);
gpu_set_ztestenable(false);

window_mouse_set_locked(false);

gpu_set_alphatestenable(false);
gpu_set_alphatestref(128);
gpu_set_fog(false, c_white, 64, self.zfar);