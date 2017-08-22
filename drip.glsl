void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  float t = fract(iGlobalTime / 4.0);

  vec2 v_uv = uv;
  const float dripRadius = 0.25;
  const float dripStart = 1.0 + dripRadius;
  const float dripEnd = dripRadius;

  vec2 drip = vec2(0.5, mix(dripStart, dripEnd, t));

  vec2 relativeToDrip = v_uv - drip;
  relativeToDrip /= dripRadius;
  float radiusSq = dot(relativeToDrip, relativeToDrip);

  float alpha = 0.0;
  alpha += step(drip.x - dripRadius, v_uv.x); // left edge
  alpha -= step(drip.x + dripRadius, v_uv.x); // right edge
  alpha -= 1.0 - step(drip.y, v_uv.y); // bottom edge
  alpha += 1.0 - step(1.0, radiusSq); // circle centered on the drip

  vec3 color = vec3(0.0, 0.0, alpha);
  gl_FragColor = vec4(color, 1.0);
}
