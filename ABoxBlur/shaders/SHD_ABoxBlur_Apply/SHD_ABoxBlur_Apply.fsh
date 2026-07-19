//=============================================================
//
#region INFORMATION.
/*
  Applies the boxblur using previously generated sum-table.
  
  It works by calculating avaerage of the area.
  https://en.wikipedia.org/wiki/Summed-area_table
  
  Requires floating-point textures for blur and sum-table!
*/
#endregion
// 
//=============================================================
//
#region UNIFORMS etc.


// Ensure there will not be problems with precision.
precision highp float;
precision highp sampler2D;


// Varyings.
varying vec2 vCoord;


// Uniforms.
#define FSH_TexSums gm_BaseTexture
uniform sampler2D FSH_TexSrc;
uniform sampler2D FSH_TexBlur;

uniform vec2 FSH_Layout;
uniform vec2 FSH_Multiply;


#endregion
// 
//=============================================================
//
#region MAIN FUNCTION.


void main()
{  
  // Sample the blur strength.
  vec2 blur = texture2D(FSH_TexBlur, vCoord).rg;
  vec2 dist = (blur * FSH_Multiply);
  
  
  // Calculate the corners of box-blur as pixels.
  // Used to sample summed-table, clamp properly.
  // Also in pixels, so averaging is easier.
  vec2 origin = floor(gl_FragCoord.xy);
  vec2 lower  = max(origin - dist, vec2(0.0));
  vec2 upper  = min(origin + dist, FSH_Layout - 1.0);
  vec4 corner = vec4(lower, upper);
  vec2 sides  = abs(upper - lower);
  
  
  // Get the area sum with given corners.  
  vec4 coords = (corner + 0.5) / FSH_Layout.xyxy;
  vec4 summation = (
    + texture2D(FSH_TexSums, coords.xy) // top-left
    + texture2D(FSH_TexSums, coords.zw) // bottom-right
    - texture2D(FSH_TexSums, coords.xw) // bottom-left
    - texture2D(FSH_TexSums, coords.zy) // top-right
  );
  
  
  // Get area coverage, used to average the sum.
  float areaSize = (sides.x * sides.y);
  vec4 average = (summation / max(1.0, areaSize));
  
  
  // Blend between source-color and blur.
  // -> This is done to mitigate problems with blurs <= 1.0
  vec4 source = texture2D(FSH_TexSrc, vCoord);
  float ratio = clamp(areaSize - 1.0, 0.0, 1.0);
  
  gl_FragData[0] = mix(source, average, vec4(ratio));
}


#endregion
// 
//=============================================================
