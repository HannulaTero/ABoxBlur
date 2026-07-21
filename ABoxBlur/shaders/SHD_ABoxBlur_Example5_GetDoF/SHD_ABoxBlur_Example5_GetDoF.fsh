//=============================================================
//
#region INFORMATION.
/*
  Used to get the depth information for the blur.
*/
#endregion
// 
//=============================================================
//
#region UNIFORMS etc.


// Varyings.
varying vec2 vCoord;


// Uniforms.
uniform float FSH_ZParam;
uniform float FSH_Lower;
uniform float FSH_Upper;


#endregion
// 
//=============================================================
//
#region FUNCTIONS.


/// @param depth Non-linear depth.
/// @param zparam Equals (zfar / znear).
/// @return Linearized depth, in range 0..1.
/// @url https://manual.gamemaker.io/beta/en/GameMaker_Language/GML_Reference/Drawing/Surfaces/surface_get_texture_depth.htm
float LinearizeDepth(float depth, float zparam)
{
  #if !defined(_YY_HLSL11_)
    depth = depth * 2.0 - 1.0;
  #endif
  return 1.0 / ((1.0 - zparam) * depth + zparam);
}


#endregion
// 
//=============================================================
//
#region MAIN FUNCTION.


void main()
{
  // Get the depth.
  float depth = texture2D(gm_BaseTexture, vCoord).r;
  depth = LinearizeDepth(depth, FSH_ZParam);
  
  // Calculate desired blur information from depth.
  float blur = mix(FSH_Lower, FSH_Upper, depth);
  blur = abs(blur);
  
  // Store the results.
  gl_FragData[0] = vec4(vec3(blur), 1.0);
}

#endregion
// 
//=============================================================
