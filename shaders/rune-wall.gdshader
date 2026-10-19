shader_type canvas_item;

uniform sampler2D runes: repeat_enable, filter_linear_mipmap;
uniform bool screen_space = true;
uniform vec2 size;
uniform vec4 runes_color: source_color;
uniform vec4 background_color: source_color;
uniform float scale = 1.0;
uniform vec2 movement = vec2(0.0, 0.0);
uniform float lod = 0.0;

void fragment() {
    vec2 uv;

    if (screen_space) {
        float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
        uv = SCREEN_UV * vec2(1.0, ratio) * scale;
    } else {
        uv = UV * size * scale;
    }

	vec4 runes_final = textureLod(runes, uv + movement * TIME, lod) * runes_color;

	runes_final = mix(background_color, runes_final, runes_final.a);

	runes_final.a *= COLOR.r;
	COLOR = runes_final;
}
