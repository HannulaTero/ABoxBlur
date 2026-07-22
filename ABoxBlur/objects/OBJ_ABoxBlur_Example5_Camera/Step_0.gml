/// @desc UPDATE CAMERA MATRIXES.


// Update where camera is and where pointing at.
matrix_build_lookat(
  self.xat, self.yat, self.zat,
  self.xto, self.yto, self.zto,
  self.xup, self.yup, self.zup,
  self.viewMatrix
);


// Make perspective projection.
var _guiRatio = display_get_gui_width() / display_get_gui_height();
matrix_build_projection_perspective_fov(
  self.fov, _guiRatio,
  self.znear, self.zfar,
  self.projMatrix
);
