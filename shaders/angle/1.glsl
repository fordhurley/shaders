uniform vec2 u_resolution;
uniform float u_time;

const float repeat = 4.0;

float lines(vec2 uv, float lineWidth) {
   float line = uv.x + uv.y;
   line = fract(line + lineWidth * 0.5);
   return step(lineWidth, line);
}

void main() {
   vec2 uv = gl_FragCoord.xy / u_resolution;
   uv *= repeat;

   float rowNum = floor(uv.y);

   const float speed = 0.5;
   float direction = sign(mod(rowNum, 2.0) - 0.5);

   uv.x += u_time * speed * direction;

   const float loopTime = 14.0;
   float t = mod(u_time, loopTime) / loopTime;
   t = abs(2.0 * t - 1.0);

   float lineWidth = clamp(0.05, 0.95, t);
   vec3 color = vec3(1.0) * lines(uv, lineWidth);

   gl_FragColor = vec4(color, 1.0);
}
