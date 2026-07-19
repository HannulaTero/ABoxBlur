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
uniform sampler2D FSH_Blur;
uniform vec2 FSH_Multiply;
uniform vec2 FSH_Texels;


#endregion
// 
//=============================================================
//
#region FUNCTIONS.


vec4 Get(vec2 pos)
{
  return texture2D(gm_BaseTexture, (pos + 0.5) * FSH_Texels);
}


#endregion
// 
//=============================================================
//
#region MAIN FUNCTION.


void main()
{
  // Preparations.
  vec2 origin = floor(gl_FragCoord.xy);
  
  // Sample the blur strength.
  vec2 blur = texture2D(FSH_Blur, vCoord).rg;
  blur = max(vec2(0.5), blur * FSH_Multiply);
  
  // Offset divided in half, as sampled in both directions.
  vec4 offset = vec4(-blur, +blur) * 0.5;
  
  // Get area coverage, used to average the sum.
  float areaSize = (blur.x * blur.y);
  
  // Otherwise calculate the average of area.  
  gl_FragData[0] = (
    + Get(origin + offset.xy) // top-left
    + Get(origin + offset.zw) // bottom-right
    - Get(origin + offset.xw) // bottom-left
    - Get(origin + offset.zx) // top-right
  ) / areaSize;
}


#endregion
// 
//=============================================================
