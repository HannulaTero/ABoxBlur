/// @desc APPLY THE ABOXBLUR.

// Verify surfaces exist.
self.VerifySurfaces();


// Apply the boxblur.
// After calling destination should have results.
ABoxBlur(
  self.surface.dst,
  self.surface.src,
  self.surface.blur, 
  self.blurStrength,
  ABOXBLUR_FALLBACK
);