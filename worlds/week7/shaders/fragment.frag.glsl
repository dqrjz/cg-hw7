#version 300 es        // NEWER VERSION OF GLSL
precision highp float; // HIGH PRECISION FLOATS

uniform vec3  uColor;
uniform vec3  uCursor; // CURSOR: xy=pos, z=mouse up/down
uniform float uTime;   // TIME, IN SECONDS

in vec2 vXY;           // POSITION ON SCREEN IMAGE
in vec3 vPos;          // POSITION IN SPACE
in vec3 vNor;          // SURFACE NORMAL
in vec2 vUV;           // U,V PARAMETRIC COORDINATES

////////////////////////////////////////////////////////////
////    Eye of Cthulhu (Second Form) from Terraria     /////
////  (https://terraria.gamepedia.com/Eye_of_Cthulhu)  /////
////////////////////////////////////////////////////////////


uniform int uTexIndex;

uniform sampler2D uTex0;
uniform sampler2D uTex1;
uniform sampler2D uTex2;

out vec4 fragColor;    // RESULT WILL GO HERE

const int NL = 2;
const int NS = 1;

struct Light {
    vec3 src;
    vec3 col;
};

struct Ray {
    vec3 src;
    vec3 dir;
};

struct Material {
  vec3  ambient;
  vec3  diffuse;
  vec3  specular;
  float power;
};

uniform vec3 camera;
uniform Light uLights[NL];
uniform Material uMaterials[NS];


Ray computeRay(vec3 src, vec3 dest) {
    Ray r;
    r.src = src;
    r.dir = normalize(dest - src);
    return r;
}

vec3 computeSurfaceNormal(vec3 P) {
    return normalize(vNor);
}

Ray reflectRay(Ray R, vec3 N) {
    Ray r;
    r.src = R.src;
    r.dir = normalize(2. * dot(N, R.dir) * N - R.dir);
    return r;
}

// PHONG SHADING
vec3 phongShading(vec3 P, int iS) {
    Material M = uMaterials[iS];
    vec3 N = computeSurfaceNormal(P);
    vec3 color = M.ambient;
    for(int i = 0;i < NL; i++) {
        Ray L = computeRay(P, uLights[i].src);
        Ray E = computeRay(P, camera); // E = -W
        Ray R = reflectRay(L, N);
        color += uLights[i].col * (M.diffuse * max(0., dot(N, L.dir)));
    float ER = dot(E.dir, R.dir);
    float spec;
        if(ER > 0.) {
            spec = max(0., exp(M.power * log(ER)));
        } else {
            spec = 0.;
        }
        color += uLights[i].col * M.specular * spec;
    }
    return color;
}

void main() {
    vec4 texture0 = texture(uTex0, vUV);
    vec4 texture1 = texture(uTex1, vUV);
    vec4 texture2 = texture(uTex2, vUV);

    // I hardwired in Phong shading parameters and lights here
    // because I threw together this example quickly.
    // You should probably continue to define lights on the CPU
    // as you have been doing in previous weeks.
/*
    vec3 ambient = .1 * uColor;
    vec3 diffuse = .5 * uColor;
    vec3 specular = vec3(.6,.6,.6);
    float p = 30.;

    Ldir[0] = normalize(vec3(-2.,1.,3.));
    Ldir[1] = normalize(vec3( 1.,0.,2.));
    Lrgb[0] = vec3(.5,.4,.4);
    Lrgb[1] = vec3(.4,.4,.4);

    vec3 normal = normalize(vNor);

    vec3 color = ambient;
    for (int i = 0 ; i < 2 ; i++) {
       float d = dot(Ldir[i], normal);
       if (d > 0.)
          color += diffuse * d * Lrgb[i];
       vec3 R = 2. * normal * dot(Ldir[i], normal) - Ldir[i];
       float s = dot(R, normal);
       if (s > 0.)
          color += specular * pow(s, p) * Lrgb[i];
    }
*/
    vec3 color = phongShading(vPos, 0);
    
    if (uCursor.z > 0. && min(abs(uCursor.x - vXY.x), abs(uCursor.y - vXY.y)) < .005)
          color *= 2.;

    fragColor = vec4(sqrt(color), 1.0);

    // This isn't the only thing you can do with textures. For example,
    // you can use them to modify the values in the Phong shading algorithm,
    // including things like the value of the surface normal vector.
    // Feel free to experiment. WebGL allows you up to 8 textures at once.

    if (uTexIndex == 0) fragColor *= texture0;
    if (uTexIndex == 1) fragColor *= texture1;
    if (uTexIndex == 2) fragColor *= texture2;
}


