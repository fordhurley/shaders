#pragma glslify: smoothUnion = require(./lib/iq/smoothUnion)

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;

  vec2 thickness = vec2(100.0 / iResolution);
  float cornerSmoothness = 0.75;

  vec2 distanceToEdge = min(abs(uv), abs(1.0 - uv));

  // smoothUnion gives some roundness to the corners:
  float alpha = smoothUnion(
    smoothstep(0.0, thickness.x, distanceToEdge.x),
    smoothstep(0.0, thickness.y, distanceToEdge.y),
    cornerSmoothness
  );
  alpha = 1.0 - alpha;

  // FIXME: alpha isn't 0 in the center

  gl_FragColor = vec4(vec3(alpha), 1.0);
}
