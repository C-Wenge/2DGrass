shader_type canvas_item;

uniform float radius :hint_range(0.0, 1.0, 0.001) = 1.0;
uniform sampler2D bend;
uniform sampler2D scale;
uniform float weight:hint_range(0.0, 1.0, 0.001) = 1.0;

void fragment(){
	float dis = distance(vec2(0.5,0.5),UV);
	vec2 dir = normalize(UV - vec2(0.5,0.5));
	float offset = dis / (0.5 * radius);
	
	vec4 color = vec4(
		(dir.x + 1.0) / 2.0,
		(dir.y + 1.0) / 2.0,
		texture(scale,vec2(offset,0.0)).r * weight,
		0.5 + (texture(bend,vec2(offset,0.0)).r / 2.0 * weight)
	);
	
	COLOR = color;
	COLOR.a *= step(dis,radius*0.5);
}
