float map(float value, float inMin, float inMax, float outMin, float outMax) {
	return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
}

void main() {
	vec2 uv = gl_FragCoord.xy / iResolution;

	float aspect = iResolution.x / iResolution.y;

	vec3 color = vec3(uv.x, 0.0, uv.y);
	uv.x *= aspect;

	vec2 mouse = iMouse;
	mouse.x *= aspect;

	float radius = map(sin(iGlobalTime), -1.0, 1.0, 0.25, 0.3);

	if (distance(uv, mouse) < radius){
		color.r = 1.0 - color.r;
		color.b = 1.0 - color.b;
	}

	gl_FragColor = vec4(color, 1.0);
}
