vec3 projectile(vec3 force, float mass, vec3 pos0, vec3 vel0, float t) {
  vec3 position = pos0;
  position += vel0 * t;
  position += 0.5 * force/mass * t * t;
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

	float t = mod(iGlobalTime, 8.0);

	vec3 position = projectile(
		vec3(0.0, -1000.0, 0.0),
		10.0,
		vec3(0.0),
		vec3(200.0, 400.0, 0.0),
		t
	);

	float value = circle(position.xy, 20.0, uv);

	gl_FragColor = vec4(value, value, value, 1.0);
}
