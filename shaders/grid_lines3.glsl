#pragma glslify: cubicPulse = require(../lib/iq/cubicPulse)
#pragma glslify: map = require(../lib/map)

#define PI 3.14159

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  float t = u_time;
  vec2 center = vec2(sin(t), cos(t));
  center = map(center, -1.0, 1.0, 0.25, 0.75);
  // center = u_mouse;
  float radius = 2.0 * distance(uv, center);

  vec2 st = uv * 25.0;

  const float amplitude = 0.5;
  float distortion = 1.0 - radius;
  distortion *= amplitude;
  distortion = max(distortion, 0.0);

  const float frequency = 0.2;

  st.x += distortion * sin(frequency * PI * st.y);
  st.y += distortion * sin(frequency * PI * st.x);

  // Gridded cell coordinate:
  vec2 cellNum = floor(st);

  // Coordinate within the cell:
  vec2 cellUV = fract(st);

  float lineWidth = 0.2;

  float alpha = cubicPulse(0.5, lineWidth, cellUV.x);
  alpha = max(alpha, cubicPulse(0.5, lineWidth, cellUV.y));

  alpha -= 0.3 * radius;

  vec3 color = vec3(0.0);
  color = mix(color, vec3(1.0), alpha);

  gl_FragColor = vec4(color, 1.0);
}
