# Read texture from image

```glsl
uniform sampler2D TEXTURE;

void freagment() {
    vec4 my_texture = texture(TEXTURE, UV);

    ALBEDO = my_texture.rgb;
}
```

## Retain color in a next pass shader

```glsl
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void freagment() {
    vec4 currentColor = textureLod(screen_texture, SCREEN_UV, 0.0);
    ALBEDO = currentColor.rgb;
}

```

## Smoothstep

https://godotshaders.com/snippet/interpolation/
https://thebookofshaders.com/glossary/?search=Smoothstep
