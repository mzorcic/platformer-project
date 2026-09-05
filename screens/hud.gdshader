shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float blur_strength : hint_range(0.0, 5.0) = 2.5;
uniform float darken : hint_range(0.0, 1.0) = 0.25;

void fragment() {
    vec3 blurred = textureLod(
        screen_texture,
        SCREEN_UV,
        blur_strength
    ).rgb;

    // Darken the background slightly
    blurred *= 1.0 - darken;

    COLOR = vec4(blurred, 1.0);
}