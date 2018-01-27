#pragma glslify: colorizeSDF = require(../lib/colorizeSDF)

float circle(vec2 st, float radius) {
  return length(st) - radius;
}

float semicircle(vec2 st, float radius) {
  return max(circle(st, radius), -st.y); // chop off below x axis
}

// Comment out to show the shape:
#define SHOW_FIELD

uniform vec2 u_resolution;

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  float aspect = u_resolution.x / u_resolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 color = vec3(0.0);

  float d = semicircle(st, 0.5);
  color += 1.0 - step(0.0, d);

  #ifdef SHOW_FIELD
    color = colorizeSDF(d);
  #endif

  gl_FragColor = vec4(color, 1.0);
}
