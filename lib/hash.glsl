// From THREE.js:
// expects values in the range of [0,1]x[0,1], returns values in the [0,1] range.
// do not collapse into a single function per: http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float hash(const in vec2 uv) {
  #define PI 3.14159265359
	const highp float a = 12.9898;
  const highp float b = 78.233;
  const highp float c = 43758.5453;
	highp float dt = dot(uv, vec2(a, b));
  highp float sn = mod(dt, PI);
	return fract(sin(sn) * c);
}

highp float hash(const in float x, const in float y) {
  return hash(vec2(x, y));
}

#pragma glslify: export(hash)
