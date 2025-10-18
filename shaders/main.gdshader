shader_type canvas_item;

// Ambient light uniforms
uniform vec3 ambient_color = vec3(1.0, 0.7, 0.3);
uniform float ambient_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float flicker_speed : hint_range(0.1, 5.0) = 2.0;
uniform float flicker_amount : hint_range(0.0, 1.0) = 0.3;

// Noise function for organic flicker
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
    // Get original pixel color
    vec4 pixelColor = texture(TEXTURE, UV);
    
    // Create flickering ambient light
    float flicker = noise(TIME * flicker_speed) * flicker_amount;
    float final_intensity = ambient_intensity + flicker;
    
    // Apply ambient light color overlay (multiplicative blend)
    vec3 ambient_light = ambient_color * final_intensity;
    vec3 lit_color = pixelColor.rgb * (vec3(1.0) + ambient_light * 0.5);
    
    // Output with original alpha
    COLOR = vec4(lit_color, pixelColor.a);
}
