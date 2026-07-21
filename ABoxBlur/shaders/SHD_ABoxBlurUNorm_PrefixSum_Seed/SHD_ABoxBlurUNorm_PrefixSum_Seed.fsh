//=============================================================
//
#region INFORMATION.
/*
  Generates seed-value for prefix sum-passes.
  This selects correct color channel using hot-encoded mask.
*/
#endregion
// 
//=============================================================
//
#region UNIFORMS etc.


// Varyings.
varying vec2 vCoord;


// Uniforms.
uniform vec4 FSH_ChannelMask;


#endregion
// 
//=============================================================
//
#region MAIN FUNCTION.


void main()
{
  vec4 sample = texture2D(gm_BaseTexture, vCoord);
  float channel = dot(sample, FSH_ChannelMask);
  gl_FragData[0] = vec4(channel, 0.0, 0.0, 0.0);
}


#endregion
// 
//=============================================================

