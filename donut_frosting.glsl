// Building a mask to be used on a torus to look like frosting on a donut. The
// torus will have uv arranged so that u is longitudinal (around the outer
// circumference), and v is around the "tube" with 0 and 1 at the bottom. The
// frosting is centered around v=0.5, and the melty edge runs parallel to u.

#pragma glslify: valueNoise = require(./lib/valueNoise)

float frostingMask(vec2 uv, float meltiness, float topEdge, float bottomEdge, float topRepeat, float bottomRepeat) {
  topEdge += meltiness * valueNoise(vec2(uv.x * topRepeat));
  bottomEdge += meltiness * valueNoise(vec2(uv.x * bottomRepeat));
  return step(bottomEdge, uv.y) - step(topEdge, uv.y);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  vec3 color = vec3(0.0);

  const float meltiness = 0.1;
  const float topEdge = 0.75;
  const float bottomEdge = 0.25;
  const float topRepeat = 30.0;
  const float bottomRepeat = 20.0;

  float alpha = frostingMask(uv, meltiness, topEdge, bottomEdge, topRepeat, bottomRepeat);

  color = mix(color, vec3(1.0), alpha);

  gl_FragColor = vec4(color, 1.0);
}
