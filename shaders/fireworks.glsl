#pragma glslify: hsv2rgb = require(glsl-hsv2rgb)

#pragma glslify: hash = require(../lib/hash)
#pragma glslify: map = require(../lib/map)

vec2 polarCoords(vec2 st) {
  float radius = length(st);
  float theta = atan(st.y, st.x);
  theta += PI;
  return vec2(radius, theta);
}

// "Fold" up a space, like folding up paper for a snowflake.
float fold(float x, float times) {
  x = fract(x * times);
  // Symmetry:
  x = 2.0 * abs(x - 0.5);
  return x;
}

float radialLines(float theta, float width, float num) {
  float edge = width/2.0;
  float fuzz = 0.1;
  return 1.0 - smoothstep(edge-fuzz, edge, fold(theta, num));
}

vec4 randomBurst(vec2 st, float t, float burstIndex) {
  vec4 seed = vec4(hash(vec2(burstIndex)));
  seed.y = hash(seed.xy + 12.329);
  seed.z = hash(seed.yz * PI);
  seed.w = hash(seed.xw * 417.109 - PI*0.1);

  vec2 center = vec2(
    mix(-0.6, 0.6, seed.x),
    mix(-0.2, 0.3, seed.y)
  );
  float scale = mix(0.8, 2.3, seed.z);
  float thetaOffset = hash(seed.xx);
  vec3 color = hsv2rgb(vec3(hash(seed.xy), hash(seed.yz) * 0.3 + 0.1, 1.0));
  float points = floor(mix(10.0, 16.5, hash(seed.zw)));
  float length = mix(0.4, 0.6, hash(seed.wx));
  float speed = mix(1.0, 1.3, hash(seed.yx));
  float delay = hash(seed.zy) * 0.15;

  vec2 polar = polarCoords(st - center);
  float radius = polar.r;
  radius /= scale;
  float theta = polar.y / (2.0 * PI); // 0 to 1
  theta += thetaOffset;

  float rOuter = t * speed - delay;
  float rInner = rOuter - length;
  float width = sqrt(rOuter - radius) - sqrt(radius);
  float fuzz = 0.1;
  width *= smoothstep(rInner-fuzz, rInner+fuzz, radius);
  width *= 1.0 - smoothstep(rOuter-fuzz, rOuter+fuzz, radius);
  width = clamp(width, 0.0, 1.0);
  return vec4(color, radialLines(theta, width, points));
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  // Background gradient:
  vec3 color = vec3(0.1, 0.05, 0.2);
  color = mix(color, vec3(0.06, 0.01, 0.1), uv.y);

  float loopTime = 1.6;
  float t = fract(u_time / loopTime);
  float burstIndex = floor(u_time / loopTime);

  vec2 st = uv * 2.0 - 1.0;

  vec4 burst = randomBurst(st, t, burstIndex);
  color = mix(color, burst.rgb, burst.a);

  gl_FragColor = vec4(color, 1.0);
}
