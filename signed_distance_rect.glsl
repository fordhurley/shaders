float rect(vec2 st, vec2 size) {
  float right = st.x - size.x;
  float left = -size.x - st.x;

  float top = st.y - size.y;
  float bottom = -size.y - st.y;

  float horizontal = max(right, left);
  float vertical = max(top, bottom);
  return max(horizontal, vertical);
}

// Comment out to show the shape:
#define SHOW_FIELD

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec2 st = uv * 2.0 - 1.0; // [-1, 1] in xy

  vec3 color = vec3(0.0);

  float d = rect(st, vec2(0.75, 0.5));
  color += 1.0 - step(0.0, d);

  #ifdef SHOW_FIELD
    color = vec3(0.0);
    if (d < 0.0) {
      color.r -= d; // Negative parts are red
    } else {
      color.b += d; // Positive parts are blue
    }
  #endif

  gl_FragColor = vec4(color, 1.0);
}
