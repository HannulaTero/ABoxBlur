/// @desc GET BLUR STRENGTH.

// Give dead zone to the edges.
var _w = room_width * 0.5;
var _h = room_height * 0.5;
var _x = abs(mouse_x - _w);
var _y = abs(mouse_y - _h);
var _xratio = (_x / _w);
var _yratio = (_y / _h);
_xratio = lerp(-0.01, 1.2, _xratio);
_yratio = lerp(-0.01, 1.2, _yratio);
_xratio = clamp(_xratio, 0.0, 1.0);
_yratio = clamp(_yratio, 0.0, 1.0);

// Blur strength can be arbitrary.
self.blurStrength[0] = lerp(0.0, 64.0, _xratio);
self.blurStrength[1] = lerp(0.0, 64.0, _yratio);
