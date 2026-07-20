// Simple passthrough fragment shader.
// As own shader just in case if needed.
varying vec2 vCoord;

void main()
{
  gl_FragData[0] = texture2D(gm_BaseTexture, vCoord);
}
