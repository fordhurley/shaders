float checker(vec2 st, float size) {
  vec2 i = floor(st/size);
  float v = mod(i.x + i.y, 2.0);
  return step(1.0, v);
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

  vec3 color = vec3(0.0);

  vec2 center = vec2(0.5);
  vec2 st = uv - center; // vector pointing from center
  st *= 2.0;

  float radiusSq = dot(st, st);
  radiusSq += valueNoise(st * 2.129 + 20.123 + iGlobalTime / 2.0);

  if (radiusSq < 1.0) {
    vec3 normal = vec3(st.xy, sqrt(1.0 - radiusSq));
    normal = normalize(normal);
    vec3 view = vec3(0.0, 0.0, -1.0);
    float refractionRatio = 0.5;
    st = refract(view, normal, refractionRatio).xy;
  }
  color += checker(st, 0.1);
  color.r *= st.y;

  gl_FragColor = vec4(color, 1.0);
}
