#pragma glslify: colormap = require('glsl-colormap/portland')

#pragma glslify: map = require(../lib/map)
#pragma glslify: hash = require(../lib/hash)
#pragma glslify: clamp01 = require(../lib/clamp01)

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  const vec2 gridSize = vec2(15.0);

  // Gridded cell coordinate:
  vec2 cellNum = floor(uv * gridSize);

  // Coordinate within the cell:
  vec2 cellUV = fract(uv * gridSize);

  // A random value for each cell:
  float cellSeed = hash(cellNum);

  vec3 color = colormap(cellSeed).rgb;

  const float shadowIntensity = 0.85;
  float shadow = clamp01(map(cellUV.x, 0.5, 0.0, shadowIntensity, 1.0));
  shadow *= clamp01(map(cellUV.y, 0.0, 0.5, shadowIntensity, 1.0));
  color *= shadow;
  color = clamp01(color);

  const float highlightIntensity = 0.02;
  float highlight = clamp01(map(cellUV.x, 1.0, 0.5, 0.0, highlightIntensity));
  highlight += clamp01(map(cellUV.y, 0.5, 1.0, 0.0, highlightIntensity));
  color += highlight;
  color = clamp01(color);

  gl_FragColor = vec4(color, 1.0);
}
