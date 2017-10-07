uniform sampler2D noiseTex; // textures/noise.png

vec3 grain(vec2 uv) {
  return texture2D(noiseTex, fract(uv)).rgb * 2.0 - 1.0;
}

float fabric(vec2 uv) {
  // Diagonal stripes with a gradient running across it.
  return mod(uv.x - uv.y, 2.0) - 1.0;
}

vec2 hash(vec2 st) {
  st = vec2(dot(st, vec2(0.040, -0.250)), dot(st, vec2(269.5, 183.3)));
  return fract(sin(st) * 43758.633) * 2.0 - 1.0;
}

float valueNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float v00 = dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
    float v10 = dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float v01 = dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float v11 = dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

    vec2 u = smoothstep(0.0, 1.0, f);

    float v0 = mix(v00, v10, u.x);
    float v1 = mix(v01, v11, u.x);

    float v = mix(v0, v1, u.y);

    return v;
}

float octaveNoise(vec2 st) {
  float freq = 1.0;
  float ampl = 1.0;
  float v = 0.0;
  for (int i = 0; i < 2; i++) {
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
  float speed = 0.;

  float edgeNoisiness = 0.05;

  vec3 grainNoise = grain(uv);

  vec2 stripeUV = vec2(uv.x * repeat, t * speed);
  float edgeNoise = grainNoise.r;
  edgeNoise *= edgeNoise;
  stripeUV.x += edgeNoisiness * edgeNoise;
  float verticalStipes = octaveNoise(stripeUV);
  verticalStipes = step(verticalStipes, 0.0);

  stripeUV = vec2(t * speed, uv.y * repeat);
  edgeNoise = grainNoise.g;
  edgeNoise *= edgeNoise;
  stripeUV.y += edgeNoisiness * edgeNoise;
  float horizontalStripes = octaveNoise(stripeUV);
  horizontalStripes = step(horizontalStripes, 0.0);

  float stripes = verticalStipes + 0.5 * horizontalStripes;
  stripes /= 1.5;

  vec3 bg = vec3(0.11, 0.133, 0.235);
  vec3 fg = vec3(0.29, 0.471, 0.573);

  vec3 color = mix(bg, fg, stripes);
  color += 0.04 * grainNoise.b;

  float fabricRepeat = 240.0;
  color += 0.04 * fabric(uv * fabricRepeat);

  gl_FragColor = vec4(color, 1.0);
}
