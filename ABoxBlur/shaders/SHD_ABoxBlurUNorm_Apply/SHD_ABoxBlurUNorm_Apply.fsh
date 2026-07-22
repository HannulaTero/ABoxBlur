//=============================================================
//
#region INFORMATION.
/*
  Applies the boxblur using previously generated Summed Area Table.
  
  It works by calculating avaerage of the area.
  https://en.wikipedia.org/wiki/Summed-area_table
  
  Uses regular rgba8unorm textures.
  In the SAT-texture, single pixel stores 32bit integer, encoded as :
    R - 0x00_00_00_FF Least significant byte.
    G - 0x00_00_FF_00 
    B - 0x00_FF_00_00 
    A - 0xFF_00_00_00 Most significant byte.
*/
#endregion
// 
//=============================================================
//
#region UNIFORMS etc.


// Varyings.
varying vec2 vCoord;


// Uniforms.
#define FSH_TexSums gm_BaseTexture
uniform sampler2D FSH_TexBlur;

uniform vec2 FSH_Layout;
uniform vec2 FSH_Multiply;


// Constants.
const vec4 DECODER = vec4(1.0, 256.0, 65536.0, 16777216.0);


#endregion
// 
//=============================================================
//
#region MAIN FUNCTION.


void main()
{  
  // Sample the blur strength.
  // As the SAT is encoded, it needs sample exact pixel positions to ne break it.
  // -> Therefore blur distance is kept as whole numbers.
  vec2 blur = texture2D(FSH_TexBlur, vCoord).rg;
  vec2 dist = (blur * FSH_Multiply);
  dist = max(vec2(1.0), dist);
  dist = floor(dist + 0.5);
  
  
  // Calculate the corners of box-blur as pixels.
  // Used to sample SAT, clamp properly.
  // Also in pixels, so averaging is easier.
  vec2 origin = floor(gl_FragCoord.xy);
  vec2 lower  = max(origin - dist, vec2(0.0));
  vec2 upper  = min(origin + dist, FSH_Layout - 1.0);
  vec4 corner = vec4(lower, upper);
  vec2 sides  = abs(upper - lower);
  
  
  // Get the area sum with given corners.
  // Turn pixel position into relative coordinates.
  vec4 coords = (corner + 0.5) / FSH_Layout.xyxy;
  vec4 summation = (
    + texture2D(FSH_TexSums, coords.xy) // top-left
    + texture2D(FSH_TexSums, coords.zw) // bottom-right
    - texture2D(FSH_TexSums, coords.xw) // bottom-left
    - texture2D(FSH_TexSums, coords.zy) // top-right
  );
  
  
  // Get area coverage.
  float areaSize = max(1.0, sides.x * sides.y);
  
  
  // Calculate the average.
  // -> Decoder is divided, and "should" produce correct result.
  // -> This avoids ever actually trying to store large U32 value.
  float average = dot(summation, (DECODER / areaSize));
  
  
  // Store the results.
  // -> This is applied to all color channels,
  //    but with color_writeenable discards all but one.
  gl_FragData[0] = vec4(average); 
}


#endregion
// 
//=============================================================
