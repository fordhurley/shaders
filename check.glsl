uniform sampler2D noiseTex; // textures/noise.png

vec3 grain(vec2 uv) {
  return texture2D(noiseTex, fract(uv)).rgb * 2.0 - 1.0;
}

float fabric(vec2 uv) {
  // Diagonal stripes with a gradient running across it.
  return mod(uv.x - uv.y, 2.0) - 1.0;
}

vec2 vec2Random(vec2 st) {
  st = vec2(dot(st, vec2(0.040,-0.250)),
  dot(st, vec2(269.5,183.3)));
  return -1.0 + 2.0 * fract(sin(st) * 43758.633);
}

float valueNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = smoothstep(0.0, 1.0, f);

    return mix(mix(dot(vec2Random(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)),
                   dot(vec2Random(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
               mix(dot(vec2Random(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)),
                   dot(vec2Random(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
}

float octaveNoise(vec2 st) {
  float freq = 1.0;
  float ampl = 1.0;
  float v = 0.0;
  for (int i = 0; i < 4; i++) {
    v += ampl * valueNoise(st * freq);
    freq *= 2.0;
    ampl /= 2.0;
  }
  return v;
}

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  float t = iGlobalTime;
  uv.x += 0.05 * t;
  uv.y += 0.25 * sin(t * 0.1);

  float repeat = 9.0;
  float speed = 0.1;

  float verticalStipes = octaveNoise(vec2(uv.x * repeat, t * speed));
  verticalStipes = step(verticalStipes, 0.0);

  float horizontalStripes = octaveNoise(vec2(t * speed, uv.y * repeat));
  horizontalStripes = step(horizontalStripes, 0.0);

  float stripes = verticalStipes + 0.5 * horizontalStripes;
  stripes /= 1.5;

  vec3 bg = vec3(0.106, 0.082, 0.047);
  vec3 fg = vec3(0, 0.22, 0.51);

  vec3 color = mix(bg, fg, stripes);
  color += 0.02 * grain(uv).x;

  float fabricRepeat = 240.0;
  color += 0.03 * fabric(uv * fabricRepeat);

  gl_FragColor = vec4(color, 1.0);
}
