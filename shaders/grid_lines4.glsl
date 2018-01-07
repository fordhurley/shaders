#pragma glslify: cubicPulse = require(../lib/iq/cubicPulse)
#pragma glslify: map = require(../lib/map)

#define PI 3.14159

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  vec2 center = vec2(0.65, 0.5);
  vec2 st = (uv - center) * 16.0;

  float amplitude = 0.5;
  st.y += amplitude * abs(center.y - st.x);

  vec2 cellUV = fract(st);

  float lineWidth = 0.15;

  float alpha = cubicPulse(0.5, lineWidth, cellUV.x);
  alpha = max(alpha, cubicPulse(0.5, lineWidth, cellUV.y));

  alpha -= 0.05 * abs(center.y - st.x);
  alpha *= map(uv.y, 0.0, 1.0, 1.0, 0.75);

  vec3 color = vec3(0.0);
  color = mix(color, vec3(1.0), alpha);

  gl_FragColor = vec4(color, 1.0);
}
