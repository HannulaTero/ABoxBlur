//=============================================================
//
#region INFORMATION.
/*
  This does prefix-sum pass in given direction.
  
  This uses exact pixel positions to ensure correct summation.
  When using normalized coordinates there could be problems.
  
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
uniform vec2 FSH_Layout;
uniform vec2 FSH_Jump;


#endregion
// 
//=============================================================
//
#region FUNCTIONS.


vec4 Get(vec2 pos)
{
  return texture2D(gm_BaseTexture, (pos + 0.5) / FSH_Layout);
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
  if (any(lessThan(origin - FSH_Jump, vec2(-0.5))))
  {
    gl_FragColor = rhs;
    return;
  }
  
  
  // Read the left operand.
  vec4 lhs = Get(origin - FSH_Jump);
  
  
  // As it is prefix sum, add them together.
  gl_FragColor = (lhs + rhs);
}


#endregion
// 
//=============================================================