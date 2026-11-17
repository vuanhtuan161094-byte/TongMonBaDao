shader_type canvas_item;
render_mode unshaded, blend_add;
// Pure luminance motion along curved wind streamlines, not UV image wobble.
uniform float activity : hint_range(0.0,1.0) = 0.0;
uniform float clock = 0.0;
void fragment() {
	vec2 p=(UV-vec2(.5,.54))*vec2(1.0,1.35);
	float r=length(p);
	float phi=atan(p.y,p.x)*4.0+log(max(r,.12))*3.9-clock*5.5;
	float narrow=pow(max(cos(phi),0.0),18.0);
	float traveling=pow(max(cos(phi*.31-clock*2.0),0.0),5.0);
	float footprint=smoothstep(.16,.29,r)*(1.0-smoothstep(.54,.76,r));
	float luminous=narrow*traveling*footprint*activity*.36;
	COLOR=vec4(mix(vec3(.14,.96,.78),vec3(.98,1.0,.86),traveling*.72),luminous);
}
