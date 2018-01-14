float smoothStepUpDown(float center, float width, float edgeWidth, float x) {
  float w2 = width/2.0;
  float e2 = edgeWidth/2.0;
  return smoothstep(center - w2 - e2, center - w2 + e2, x) -
         smoothstep(center + w2 - e2, center + w2 + e2, x);
}

#pragma glslify: export(smoothStepUpDown)
