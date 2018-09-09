#pragma glslify: hsv2rgb = require(glsl-hsv2rgb)

#pragma glslify: map = require(../lib/map)
#pragma glslify: hash = require(../lib/hash)
#pragma glslify: clamp01 = require(../lib/clamp01)
#pragma glslify: smoothUnion = require(../lib/iq/smoothUnion)

uniform vec2 u_resolution;
uniform float u_time;

#define pi 3.14159
#define sqrt2 1.41421

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;
  uv.x *= u_resolution.x / u_resolution.y;

  const vec2 repeat = vec2(24.0);

  // Gridded cell coordinate:
  vec2 cellNum = floor(uv * repeat);

  // Coordinate within the cell:
  vec2 cellUV = fract(uv * repeat);

  float minDist = 1.0;
  for (int x = -1; x <= 1; x++) {
    for (int y = -1; y <= 1; y++) {
      vec2 neighbor = vec2(x, y);
      vec2 cellCenter = vec2(
        hash(cellNum + neighbor),
        hash(cellNum + neighbor + 32.134)
      );
      cellCenter = sin(u_time + cellCenter * 2.0 * pi);
      cellCenter = map(cellCenter, -1.0, 1.0, 0.25, 0.75);
      cellCenter += neighbor;
      float dist = distance(cellUV, cellCenter);
      minDist = min(minDist, dist);
    }
  }
  gl_FragColor = vec4(minDist);

  float mask = 0.4 - minDist;
  mask /= 0.3;
  mask = clamp01(mask);
  mask = mask * mask * mask * mask;

  vec3 color = vec3(0.0);
  vec3 dotColor = hsv2rgb(vec3(hash(cellNum), 0.9, 0.9));
  color += dotColor * mask;

  gl_FragColor = vec4(color, 1.0);
}
