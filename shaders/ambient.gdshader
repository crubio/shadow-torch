shader_type canvas_item;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV) # get the color of each pixel
	new_color = vec4(1, 1, 1, pixel_color.a)
	COLOR = new_color
}