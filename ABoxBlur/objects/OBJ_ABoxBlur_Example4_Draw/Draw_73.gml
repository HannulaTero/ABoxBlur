/// @desc DRAW THE RESULTS.

// Verify surfaces exist.
self.VerifySurfaces();


// Preparations.
var _w = room_width;
var _h = room_height;


// Draw the result.
draw_surface(self.surface.dst, 0, 0);


// Draw the brush.
draw_circle(mouse_x, mouse_y, self.brushRadius, true);