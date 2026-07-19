// Simple passthrough fragment shader
varying vec2 vCoord;

void main()
{
  gl_FragColor = texture2D(gm_BaseTexture, vCoord);
}
