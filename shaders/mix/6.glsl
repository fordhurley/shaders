#pragma glslify: clamp01 = require(../../lib/clamp01)
#pragma glslify: map = require(../../lib/map)

#define sqrt2 1.414213562

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  float t = 1.9;

  float k;
  vec3 color;
  vec2 center;

  float over = 0.1;

  center.x = map(cos(t), -1.0, 1.0, -over, 1.0+over);
  center.y = 1.0 + over;
  k = distance(uv, center);
  k = 1.0 - k;
  k = clamp01(k);
  color = mix(color, vec3(0.278, 0.42, 0.608), k);

  center.x = map(cos(t), -1.0, 1.0, -over, 1.0+over);
  center.y = map(-sin(t), -1.0, 1.0, -over, 1.0+over);
  k = distance(uv, center);
  k = 1.0 - k;
  k = clamp01(k);
  color = mix(color, vec3(0.678, 0.851, 0.957), k);

  center.x = map(sin(t), -1.0, 1.0, -over, 1.0+over);
  center.y = -over;
  k = distance(uv, center);
  k = 1.0 - k;
  k = clamp01(k);
  color = mix(color, vec3(0.271, 0.545, 0.596), k);

  center.x = map(sin(t), -1.0, 1.0, -over, 1.0+over);
  center.y = map(-cos(t), -1.0, 1.0, -over, 1.0+over);
  k = distance(uv, center);
  k = 1.0 - k;
  k = clamp01(k);
  color = mix(color, vec3(0.698, 0.298, 0.384), k);

  gl_FragColor = vec4(color, 1.0);
}
