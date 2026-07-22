//=============================================================
//
#region INFORMATION.
/*
  This does prefix-sum pass in given direction.
  
  This uses exact pixel positions to ensure correct summation.
  When using normalized coordinates there could be problems.
  
  Uses regular rgba8unorm textures.
  Single pixel stores 32bit integer, encoded as :
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
  highp vec4 rhs = Get(origin);
  
  
  // Check whether goes outside the boundary.
  if (any(lessThan(origin - FSH_Jump, vec2(-0.5))))
  {
    gl_FragColor = rhs;
    return;
  }
  
  
  // Read the left operand.
  highp vec4 lhs = Get(origin - FSH_Jump);
  
  
  // As it is prefix sum, add them together.
  // Dealing with whole numbers is safer than normalized values.
  lhs = floor(lhs * 255.0 + 0.5);
  rhs = floor(rhs * 255.0 + 0.5);
  highp vec4 result = (lhs + rhs);
  
  
  // Resolve carries over bytes.
  for(int i = 0; i < 3; i++)
  {
    if (result[i] >= 255.5)
    {
      result[i + 0] -= 256.0;
      result[i + 1] += 1.0;
    }
  }
  
  
  // Normalize the result back to 0 to 1 range.
  gl_FragColor = (result / 255.0);
}


#endregion
// 
//=============================================================