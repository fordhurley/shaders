uniform sampler2D noiseTex; // textures/noise.png

vec3 noise(vec2 uv) {
  return texture2D(noiseTex, fract(uv)).rgb;
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

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  float t = iGlobalTime;
  uv.x += 0.05 * t;
  uv.y += 0.25 * sin(t * 0.1);

  float repeat = 15.0;
  uv *= repeat;

  t *= 0.1;

  float verticalStipes = valueNoise(vec2(uv.x, t));
  verticalStipes = step(verticalStipes, 0.0);

  float horizontalStripes = valueNoise(vec2(t, uv.y));
  horizontalStripes = step(horizontalStripes, 0.0);

  vec3 color = vec3(0.0, 0.28, 0.62);
  color *= verticalStipes + 0.5 * horizontalStripes;
  color += 0.1 * noise(uv).x;

  gl_FragColor = vec4(color, 1.0);
}
