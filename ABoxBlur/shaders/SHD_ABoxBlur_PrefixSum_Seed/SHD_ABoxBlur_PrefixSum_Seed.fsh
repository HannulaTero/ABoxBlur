// Simple passthrough fragment shader
varying vec2 vCoord;

void main()
{
  gl_FragData[0] = texture2D(gm_BaseTexture, vCoord);
}
