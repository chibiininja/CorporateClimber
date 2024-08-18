shader_type sky;

//sky 
uniform vec3 skyColor : source_color;
uniform vec3 horizonColor : source_color;

//clouds
uniform sampler2D clouds_texture: filter_linear_mipmap;
uniform sampler2D clouds_distort_texture: filter_linear_mipmap;
uniform sampler2D clouds_noise_texture: filter_linear_mipmap;
uniform vec3 clouds_main_color: source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 clouds_edge_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float clouds_speed: hint_range(0.0, 0.1, 0.01);
uniform float clouds_scale: hint_range(0.0, 1.0, 0.01);
uniform float clouds_cutoff: hint_range(0.0, 1.0, 0.01);
uniform float clouds_fuzziness: hint_range(0.0, 1.0, 0.01);

void sky() {
	vec2 sky_uv = EYEDIR.xz / EYEDIR.y;
	float col = clamp(EYEDIR.y/0.2,0.0,1.0);
	vec3 gradient = mix(horizonColor,skyColor,col);
	
	float clouds_movement = TIME * clouds_speed * 0.5;
	float clouds_base_noise = texture(clouds_texture, (sky_uv + clouds_movement ) * clouds_scale).r;
	float noise1 = texture(clouds_distort_texture, (sky_uv + clouds_base_noise + (clouds_movement * 0.75)) * clouds_scale).r;
	float noise2 = texture(clouds_noise_texture, (sky_uv + noise1 + (clouds_movement * 0.25)) * clouds_scale).r;
	
	float clouds_noise_value = clamp(noise1 * noise2, 0.0, 1.0) * clamp(EYEDIR.y, 0.0, 1.0);
	
	float clouds_value = clamp(smoothstep(clouds_cutoff, clouds_cutoff + clouds_fuzziness, clouds_noise_value), 0.0, 1.0);
	
	
	vec3 clouds = mix(clouds_edge_color,  clouds_main_color , clouds_value) * clouds_value;
	
	float clouds_negative = 1.0 - clouds_value;
	
	gradient = clamp(gradient * clouds_negative, 0.0, 1.0);

	COLOR = gradient+clouds;
}
