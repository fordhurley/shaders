#pragma glslify: smoothUnion = require(../lib/iq/smoothUnion)

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

  // I'm not sure why, but this value isn't 1 unless cornerSmoothness is 0. We
  // can use this to properly invert alpha, so that it reaches 0 at the center
  // of the frame.
  float unionOfOne = smoothUnion(1.0, 1.0, cornerSmoothness);
  alpha = unionOfOne - alpha;

  gl_FragColor = vec4(vec3(alpha), 1.0);
}
