/// @desc GET BLUR STRENGTH.

// Give dead zone to the edges.
var _x = abs(mouse_x - room_width * 0.5);
var _ratio = (_x / room_width);
_ratio = lerp(0.0, 1.2, _ratio);
_ratio = clamp(_ratio, 0.0, 1.0);

// Blur strength can be arbitrary.
self.blurStrength = lerp(0.0, 256.0, _ratio);
