vec3 projectile(vec3 force, float mass, vec3 pos0, vec3 vel0, float t) {
  vec3 position = pos0;
  position += vel0 * t;
  position += 0.5 * force/mass * t * t;
  return position;
}

vec3 projectileWithDrag(float drag, vec3 force, float mass, vec3 pos0, vec3 vel0, float t) {
  vec3 position = pos0;
	position += force * drag * t;
	position += (-drag * vel0 + force) * mass * (exp(-drag/mass * t) - 1.0);
	return position;
}

float circle(vec2 center, float radius, vec2 st) {
	vec2 d = center - st;
	float distanceSq = dot(d, d);
	if (distanceSq < radius * radius) {
		return 1.0;
	}
	return 0.0;
}

void main() {
	vec2 uv = gl_FragCoord.xy;

	float loopTime = 10.0;

	float drag = 1.0;
	vec3 gravity = vec3(0.0, -2000.0, 0.0);
	float mass = 10.0;
	vec3 pos0 = vec3(0.0);
	vec3 vel0 = vec3(200.0, 600.0, 0.0);

	float t = mod(iGlobalTime, loopTime);

	vec3 color = vec3(0.0);
	vec3 red = vec3(1.0, 0.0, 0.0);
	vec3 blue = vec3(0.0, 0.0, 1.0);

	vec3 position = projectile(gravity, mass, pos0, vel0, t);
	color += red * circle(position.xy, 20.0, uv);

	position = projectileWithDrag(drag, gravity, mass, pos0, vel0, t);
	color += blue * circle(position.xy, 20.0, uv);

	gl_FragColor = vec4(color, 1.0);
}
