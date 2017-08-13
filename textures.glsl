uniform sampler2D mainTex; // ./textures/lena.bmp
uniform sampler2D dustTex; // ./textures/dust.png
uniform sampler2D normalMap; // ./textures/brickwall_normal-map.jpg

// radius at which it reaches full black:
const float vignetteRadius = 1.4;

const float dustOpacity = 0.5;

// where the light is coming from:
const vec3 lightDirection = normalize(vec3(-1.0, 1.0, 1.0));
const float lightIntensity = 0.25;
const float ambientIntensity = 0.75;

void main() {
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float aspect = iResolution.x / iResolution.y;
  uv.x *= aspect;

  vec4 color = texture2D(mainTex, uv);

  float radius = distance(uv, vec2(0.5));
  radius *= 2.0; // 0 to 1 at the edges (sqrt2 at the corners)

  float vignette = vignetteRadius - radius;
  vignette = clamp(vignette, 0.0, 1.0);
  color *= vignette;

  vec3 normal = texture2D(normalMap, uv).xyz;
  normal = 2.0 * normal - 1.0; // map to [-1, 1] range

  float light = dot(normal, lightDirection * lightIntensity);
  light += ambientIntensity;
  color *= light;
  color = clamp(color, 0.0, 1.0);

  vec4 dust = texture2D(dustTex, uv);
  dust.a *= dustOpacity;
  color = mix(color, dust, dust.a);

  gl_FragColor = vec4(color.rgb, 1.0);
}
