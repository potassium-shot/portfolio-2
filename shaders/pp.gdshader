shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture, filter_linear_mipmap;

uniform float bloom_radius = 1.0;
uniform float bloom_intensity = 1.0;

uniform float crt_scroll_speed = 1.0;
uniform float crt_blink_speed = 1.0;
uniform float crt_blink_min_brightness = 0.8;

void fragment() {
	ivec2 size = textureSize(screen, 0);

    float uv_x = SCREEN_UV.x * float(size.x);
    float uv_y = SCREEN_UV.y * float(size.y);

    COLOR = texture(screen, SCREEN_UV);
    vec4 bloom = textureLod(screen, SCREEN_UV, bloom_radius);

    COLOR.rgb += bloom.rgb * bloom_intensity;

    float crt_intensity = pow((1.0 + sin(uv_y + TIME * crt_scroll_speed)) * 0.5, 0.5);
    crt_intensity *= mix(crt_blink_min_brightness, 1.0, (sin(TIME * crt_blink_speed) + 1.0) * 0.5);

    COLOR *= crt_intensity * 0.5 + 0.5;
}
