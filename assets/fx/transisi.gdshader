shader_type canvas_item;
// Transisi lensa detektif: lingkaran pixel bergaris emas yang menutup (progress 0 -> 1) lalu membuka.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(160.0, 90.0);
uniform vec4 fill_color : source_color = vec4(0.094, 0.078, 0.145, 1.0);
uniform vec4 ring_color : source_color = vec4(0.996, 0.682, 0.204, 1.0);
uniform vec4 ring_dark : source_color = vec4(0.969, 0.463, 0.133, 1.0);

void fragment() {
	vec2 p = floor(UV * vec2(320.0, 180.0) / 2.0) * 2.0 + 1.0;
	float r = (1.0 - progress) * 200.0;
	float d = distance(p, center);
	if (d < r - 6.0) {
		COLOR = vec4(0.0);
	} else if (d < r - 4.0) {
		COLOR = vec4(0.094, 0.078, 0.145, 1.0);
	} else if (d < r - 2.0) {
		COLOR = ring_color;
	} else if (d < r) {
		COLOR = ring_dark;
	} else {
		COLOR = fill_color;
	}
}
