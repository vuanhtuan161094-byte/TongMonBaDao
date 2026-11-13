shader_type canvas_item;
render_mode blend_add, unshaded;

// VFX16.2 LAB-ONLY sword qi contact: luminous CUT, flash and expanding
// ellipse. Parameters are synchronised to the existing contact_time,
// target list and demo progress; not a gameplay hit or collision shape.
uniform float event_age : hint_range(0.0, 1.0) = 0.0;
uniform float power : hint_range(0.0, 1.0) = 1.0;
uniform float seed = 0.0;
uniform int wave = 0;

void fragment() {
    vec2 p = (UV - vec2(0.5)) * vec2(220.0, 220.0);
    float age = clamp(event_age, 0.0, 1.0);
    float fade = 1.0 - smoothstep(0.42, 1.0, age);
    float quick = exp(-age * 11.0);
    float wide = wave == 2 ? 1.0 : (wave == 1 ? 0.81 : 0.68);
    float theta = -0.40 + seed * 0.36;
    vec2 axis = vec2(cos(theta), sin(theta));
    vec2 normal = vec2(-axis.y, axis.x);
    float along = dot(p, axis);
    float across = dot(p, normal);
    // The first brilliant flash sits in a very short diagonal contact cut.
    float core = exp(-pow(across / (1.9 + age * 3.6), 2.0)) *
                 smoothstep(-34.0, -26.0, along) *
                 (1.0 - smoothstep(33.0, 44.0, along));
    float broad = exp(-pow(across / (5.5 + age * 7.0), 2.0)) *
                  smoothstep(-36.0, -22.0, along) *
                  (1.0 - smoothstep(28.0, 47.0, along));
    // Sweeping sword crescent grows away from the chest, is not a solid ring.
    vec2 elliptical = vec2(p.x, p.y * 1.08);
    float rr = length(elliptical);
    float angle = atan(elliptical.y, elliptical.x);
    float sweep_r = (19.0 + 45.0 * age) * wide;
    float sweep = exp(-pow((rr - sweep_r) / (2.4 + 4.0 * age), 2.0));
    float segment = smoothstep(-2.65, -2.15, angle) *
                    (1.0 - smoothstep(0.68, 1.24, angle));
    float crescent = sweep * segment * (1.0 - smoothstep(0.62, 1.0, age));
    // Expanding elliptical shock is a separate quieter contact cue.
    float shock = exp(-pow(
        (length(vec2(p.x, p.y * 1.90)) - (13.0 + 59.0 * age) * wide) /
        (3.0 + 5.0 * age), 2.0)) * (1.0 - age);
    float flash = exp(-dot(p / vec2(13.0, 10.0),
                           p / vec2(13.0, 10.0)) * 0.9) * quick;
    // Small radial needles, dispersing away from the slash.
    float shards = 0.0;
    for (int i = 0; i < 6; i++) {
        float a = 6.2831853 * float(i) / 6.0 + seed;
        vec2 ray = vec2(cos(a), sin(a));
        vec2 perp = vec2(-ray.y, ray.x);
        float d = dot(p, ray);
        float side = dot(p, perp);
        float span = smoothstep(5.0 + 18.0 * age, 12.0 + 26.0 * age, d) *
                     (1.0 - smoothstep(21.0 + 35.0 * age,
                                      31.0 + 51.0 * age, d));
        shards += exp(-pow(side / (1.0 + age * 1.3), 2.0)) * span;
    }
    vec3 ice = vec3(0.87, 0.98, 1.00);
    vec3 cyan = vec3(0.25, 0.86, 1.00);
    vec3 blue = vec3(0.16, 0.48, 1.00);
    vec3 rgb = ice * (core * (0.77 + quick * 0.24) +
                      crescent * 0.39 + flash * 0.69) +
               cyan * (broad * 0.42 + shock * 0.51 +
                       crescent * 0.65 + shards * 0.37) +
               blue * (broad * 0.21 + shock * 0.34);
    float value = core * 0.77 + broad * 0.36 + flash * 0.91 +
                  crescent * 0.74 + shock * 0.48 + shards * 0.28;
    float edge = smoothstep(0.01, 0.07, UV.x) *
                 (1.0 - smoothstep(0.93, 0.99, UV.x)) *
                 smoothstep(0.01, 0.07, UV.y) *
                 (1.0 - smoothstep(0.93, 0.99, UV.y));
    COLOR = vec4(rgb, clamp(value * power * fade * edge, 0.0, 1.0));
}
