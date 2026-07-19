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
uniform sampler2D FSH_Source;
uniform sampler2D FSH_Blur;
uniform vec2 FSH_Strength;
uniform vec2 FSH_Layout;
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
  // As blur is directted in both directions, half it.
  vec2 blur = texture2D(FSH_Blur, vCoord).rg;
  blur *= FSH_Strength * 0.5;
  
  // Calculate the corners of box-blur.
  vec2 lower = max(origin - blur, vec2(0.0));
  vec2 upper = min(origin + blur, FSH_Layout - 1.0);
  vec4 corner = vec4(lower, upper);
  
  // Get area coverage, used to average the sum.
  // -> As it might get clamped, then 
  vec2 size = (upper - lower);
  float area = (size.x * size.y);
  area = max(1.0, area);
  
  // Otherwise calculate the average of area.  
  vec4 average = (
    + Get(corner.xy) // top-left
    + Get(corner.zw) // bottom-right
    - Get(corner.xw) // bottom-left
    - Get(corner.zy) // top-right
  ) / area;
  
  // Blend between source-color and blur.
  // -> This is done to mitigate problems with blurs <= 1.0
  vec4 source = texture2D(FSH_Source, vCoord);
  float ratio = clamp(blur.x - 1.0, 0.0, 1.0);
  
  gl_FragColor = mix(source, average, vec4(ratio));
}


#endregion
// 
//=============================================================
