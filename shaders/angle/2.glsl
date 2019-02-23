#pragma glslify: map = require('../../lib/map');

uniform vec2 u_resolution;
uniform float u_time;

#define sqrt2 1.4142

const float repeat = 4.0;

float chevron(vec2 uv, float lineWidth) {
   vec2 st = fract(uv);
   // Mirror every other cell horiziontally:
   st.x = abs(mod(floor(uv.x), 2.0) - st.x);
   float line = st.x + st.y;
   line = fract(line);
   return step(lineWidth, line);
}

void main() {
   vec2 uv = gl_FragCoord.xy / u_resolution;
   uv *= repeat;
   uv.y += 0.5;

   float t = u_time;

   vec2 cellNum = floor(uv * sqrt2);

   const float speed = 0.25;
   float direction = sign(mod(cellNum.y, 2.0) - 0.5);
   uv.x += t * speed * direction;

   const float loopTime = 8.0;
   float lineT = mod(t, loopTime) / loopTime;
   lineT = abs(2.0 * lineT - 1.0);
   lineT = smoothstep(0.0, 1.0, lineT);

   float lineWidth = map(lineT, 0.0, 1.0, 0.05, 0.95);
   vec3 color = vec3(1.0) * chevron(uv, lineWidth);

   gl_FragColor = vec4(color, 1.0);
}
