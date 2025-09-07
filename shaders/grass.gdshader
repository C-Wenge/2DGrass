shader_type canvas_item;

global uniform sampler2D direction_noise;
global uniform float wind_time;
global uniform sampler2D mask_texture;

uniform vec2 sway_amplitude;
uniform vec2 bend_amplitude;
uniform vec2 points_offsets[4];

void vertex(){

	//草根世界坐标
	vec2 root_world_pos = (MODEL_MATRIX * vec4(VERTEX+points_offsets[VERTEX_ID],0.0,1.0)).xy;

	vec4 canvas = CANVAS_MATRIX * vec4(root_world_pos,0.0,1.0);
	vec4 screen = SCREEN_MATRIX * canvas;

	//遮罩UV坐标
	vec2 mask_uv = (screen.xy + 1.0) / 2.0;

	vec4 mask_color = texture(mask_texture,mask_uv);

	float scale = mask_color.b;
	//缩放方向
	vec2 scale_direction = normalize(VERTEX+points_offsets[VERTEX_ID] - VERTEX);
	//缩放距离
	float scale_distance = distance(VERTEX+points_offsets[VERTEX_ID],VERTEX);

	VERTEX += scale_direction * scale_distance * scale;

	//弯曲方向
	vec2 bend_direction = vec2((mask_color.r - 0.5) * 2.0,(mask_color.g - 0.5) * 2.0);
	//弯曲权重
	float bend_weight = clamp((mask_color.a - 0.5) * 2.0,0.0,1.0);

	VERTEX += bend_direction * bend_amplitude * bend_weight * (1.0 - UV.y) * (1.0 - scale);

	//方向噪声纹理大小
	vec2 direction_noise_size = vec2(textureSize(direction_noise,0));

	//方向噪声纹理UV坐标
	vec2 direction_noise_uv = mod(root_world_pos+wind_time,direction_noise_size) / direction_noise_size;

	//方向（弧度）
	float direction_angle = texture(direction_noise,direction_noise_uv).r * TAU;

	//方向
	vec2 direction = vec2(cos(direction_angle),sin(direction_angle));

	VERTEX += direction * sway_amplitude * (1.0 - UV.y) * (1.0-scale);
}
