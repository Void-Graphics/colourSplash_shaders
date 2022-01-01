#version 120

#define goalHue 40.0 // the desired hue to display [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 220 230 240 250 260 270 280 290 300 310 320 330 340 350]
#define wiggle 20 // wiggle room [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 220 230 240 250 260 270 280 290 300 310 320 330 340 350]
//#define BLACKEN // Whether or not to blackent the background

uniform sampler2D gcolor;

varying vec2 texcoord;

// All components are in the range [0…1], including hue.
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
	float mask;
	vec3 ogRGB = texture2D(gcolor, texcoord).rgb;
	vec3 black = vec3(0, 0, 0);
	vec3 ogHSV = rgb2hsv(ogRGB).xyz;
	float hue = 360*ogHSV.x;
	if(goalHue < wiggle || goalHue > (360 - wiggle)) {
		mask = (hue < mod(goalHue + wiggle, 360) || hue > mod(goalHue - wiggle, 360)) ? 1 : 0;
	} else {
		mask = (hue < mod(goalHue + wiggle, 360) && hue > mod(goalHue - wiggle, 360)) ? 1 : 0;
	}
	#ifdef BLACKEN
		vec3 test = vec3(hue/360, ogHSV.y * mask, ogHSV.z*mask*ogHSV.y);
	#else
		vec3 test = vec3(hue/360, ogHSV.y * mask, ogHSV.z);
	#endif
	// if(effect == 1) {
	// 	vec3 test = vec3(hue/360, ogHSV.y * mask, ogHSV.z*mask*ogHSV.y);
	// } else {
	// 	vec3 test = vec3(hue/360, ogHSV.y * mask, ogHSV.z);
	// }
	vec3 exitHSV = hsv2rgb(test).rgb;

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(vec3(exitHSV), 1.0); //gcolor
}

