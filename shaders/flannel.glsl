precision highp float;

uniform sampler2D noiseTex; //  ../textures/noise.png

vec3 grain(vec2 uv) {
  return texture2D(noiseTex, fract(uv)).rgb * 2.0 - 1.0;
}

float twill(vec2 uv) {
  // Diagonal stripes with a gradient running across it.
  return mod(uv.x - uv.y, 2.0) - 1.0;
}

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  float t = u_time;
  uv.x += 0.05 * t;
  uv.y += 0.25 * sin(t * 0.1);

  float repeat = 9.0;
  float speed = 0.;

  vec3 grainNoise = grain(uv);

  float fuzziness = 0.003;
  uv += fuzziness * grainNoise.rg;

  vec2 stripeUV = vec2(uv.x * repeat, t * speed);
  float verticalStipes = sin(stripeUV.x);
  verticalStipes = step(verticalStipes, 0.0);

  stripeUV = vec2(t * speed, uv.y * repeat);
  float horizontalStripes = sin(stripeUV.y);
  horizontalStripes = step(horizontalStripes, 0.0);

  float stripes = verticalStipes + 0.5 * horizontalStripes;
  stripes /= 1.5;

  vec3 bg = vec3(0.11, 0.133, 0.235);
  vec3 fg = vec3(0.29, 0.471, 0.573);

  vec3 color = mix(bg, fg, stripes);
  color += 0.04 * grainNoise.b;

  float twillRepeat = 240.0;
  color += 0.04 * twill(uv * twillRepeat);

  gl_FragColor = vec4(color, 1.0);
}
