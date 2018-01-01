#define PI 3.14159

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

vec2 polarCoords(vec2 st) {
  float radius = length(st);
  float theta = atan(st.y, st.x);
  theta += PI;
  return vec2(radius, theta);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;

  float speed = 0.25;
  float t = fract(u_time * speed);

  vec3 color = vec3(0.06, 0.03, 0.12);
  color = mix(color, vec3(0.05, 0.0, 0.1), uv.y);

  uv = uv * 2.0 - 1.0;

  vec2 polar = polarCoords(uv + vec2(0.2, 0.2));
  float radius = polar.r * 0.75;
  float theta = polar.y / (2.0 * PI);

  float rOuter = t * 3.5;
  float rInner = rOuter - 0.5;
  float width = sqrt(rOuter - radius) - sqrt(radius);
  width *= smoothstep(rInner-0.1, rInner+0.1, radius) - smoothstep(rOuter-0.1, rOuter+0.1, radius);
  width = clamp(width, 0.0, 1.0);
  vec4 burst = vec4(0.8, 0.1, 0.2, radialLines(theta, width, 12.0));
  color = mix(color, burst.rgb, burst.a);

  polar = polarCoords(uv + vec2(-0.2, -0.1));
  radius = polar.r * 0.5;
  theta = polar.y / (2.0 * PI);

  rOuter = t * 3.0 - 1.2;
  rInner = rOuter - 0.5;
  width = sqrt(rOuter - radius) - sqrt(radius);
  width *= smoothstep(rInner-0.1, rInner+0.1, radius) - smoothstep(rOuter-0.1, rOuter+0.1, radius);
  width = clamp(width, 0.0, 1.0);
  burst = vec4(0.8, 0.8, 0.6, radialLines(theta, width, 16.0));
  color = mix(color, burst.rgb, burst.a);

  polar = polarCoords(uv + vec2(0.0, -0.25));
  radius = polar.r * 0.6;
  theta = polar.y / (2.0 * PI);

  rOuter = t * 4.0 - 3.0;
  rInner = rOuter - 0.5;
  width = sqrt(rOuter - radius) - sqrt(radius);
  width *= smoothstep(rInner-0.1, rInner+0.1, radius) - smoothstep(rOuter-0.1, rOuter+0.1, radius);
  width = clamp(width, 0.0, 1.0);
  burst = vec4(0.8, 0.1, 0.6, radialLines(theta + 1.0/24.0, width, 12.0));
  color = mix(color, burst.rgb, burst.a);

  gl_FragColor = vec4(color, 1.0);
}
