//=============================================================
//
#region INFORMATION.
/*
  This does prefix-sum pass in given direction.
  
  Requires floating-point textures!
*/
#endregion
// 
//=============================================================
//
#region UNIFORMS etc.


// Ensure there will not be problems with precision.
precision highp float;
precision highp sampler2D;


// Uniforms.
uniform vec2 FSH_Texels;
uniform vec2 FSH_Jump;


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
  
  
  // Read the right operand.
  vec4 rhs = Get(origin);
  
  
  // Check whether goes outside the boundary.
  if (any(lessThan(origin - FSH_Jump, vec2(0.0))))
  {
    gl_FragData[0] = rhs;
    return;
  }
  
  
  // Read the left operand.
  vec4 lhs = Get(origin + FSH_Jump);
  
  
  // As it is prefix sum, add them together.
  gl_FragData[0] = (lhs + rhs);
}


#endregion
// 
//=============================================================