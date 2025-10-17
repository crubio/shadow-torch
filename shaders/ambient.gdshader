shader_type canvas_item;
blend_type add;  // Add this line for additive blending

// Torch colors
uniform vec3 torch_color : hint_color = vec3(1.0, 0.7, 0.3);
uniform vec3 spell_color : hint_color = vec3(0.3, 0.7, 1.0);

// Flicker controls
uniform float intensity : hint_range(0.0, 1.0) = 0.1;
uniform float flicker_speed : hint_range(0.1, 5.0) = 2.0;
uniform float flicker_amount : hint_range(0.0, 1.0) = 0.4;

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float noise(float x) {
    float i = floor(x);
    float f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(hash(i), hash(i + 1.0), f);
}

void fragment() {
    // Create flickering value based on time
    float flicker = noise(TIME * flicker_speed) * flicker_amount;
    float final_intensity = intensity + flicker;

    // Blend torch and spell colors smoothly
    vec3 light_color = mix(torch_color, spell_color, 0.5);

    // Create very subtle additive color
    vec3 final_color = light_color * final_intensity * 0.15;

    // Output with low alpha for additive blend
    COLOR = vec4(final_color, 1.0);
}