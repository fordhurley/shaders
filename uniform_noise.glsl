// Used in valueNoise
vec2 hash(vec2 st) {
  st = vec2(dot(st, vec2(0.040, -0.250)), dot(st, vec2(269.5, 183.3)));
  return fract(sin(st) * 43758.633);
}

// From ScribbleChat
float getRandomFloat(vec2 seed) {
  return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453);
}

// From http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float rand2(vec2 co) {
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

// From THREE.js:
// expects values in the range of [0,1]x[0,1], returns values in the [0,1] range.
// do not collapse into a single function per: http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float rand3( const in vec2 uv ) {
  #define PI 3.14159265359
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract(sin(sn) * c);
}

void main() {
  vec2 uv = gl_FragCoord.xy / u_resolution;

  float hash = hash(uv).x;
  float randomFloat = getRandomFloat(uv);
  float rand2 = rand2(uv);
  float rand3 = rand3(uv);

  // Hover your mouse over a quadrant to switch between the functions:

  float value = 0.0;
  vec2 quadrant = floor(u_mouse * 2.0);
  value += (quadrant == vec2(0.0, 1.0)) ? hash : 0.0; // top left
  value += (quadrant == vec2(1.0, 1.0)) ? randomFloat : 0.0; // top right
  value += (quadrant == vec2(0.0, 0.0)) ? rand2 : 0.0; // bottom left
  value += (quadrant == vec2(1.0, 0.0)) ? rand3 : 0.0; // bottom right

  gl_FragColor = vec4(vec3(value), 1.0);
}
