shader_type canvas_item;

uniform sampler2D runes: repeat_enable, filter_linear_mipmap;
uniform float lod = 0.0;
uniform float scale = 1.0;
uniform vec2 movement;

uniform float min_radius_start = 0.0;
uniform float min_radius_end = 0.2;
uniform float max_radius_start = 0.8;
uniform float max_radius_end = 1.0;

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float mag = length(centered_uv) * 2.0;

    float intensity = smoothstep(min_radius_start, min_radius_end, mag) * smoothstep(max_radius_end, max_radius_start, mag);

    float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    vec2 uv = SCREEN_UV * vec2(1.0, ratio) * scale;
    COLOR *= textureLod(runes, uv + movement * TIME, lod) * intensity;
}
