Shader "Hidden/science1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _bgTex ("BackgroundTexture", 2D) = "white" {}
        _Density ("Point density", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/Perlin.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _Density;
            sampler2D _bgTex;

            float4 skyTexture(float2 uv, float density) {
                float mask = rand2dTo1d(uv, float2(35.352,2526.23));

                return (mask > density);
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                float4 skyTex = skyTexture(i.uv + _Time.y, _Density);

                float perlinMask = perlinFrom3D(float3(i.uv * 20, _Time.y)) + 0.5 > 0.5;
                float4 mainTex = tex2D(_MainTex, i.uv);
                float4 bgTex = tex2D(_bgTex, i.uv - (_Time.y / 10));

                float whiteMask = mainTex != (1, 1, 1, 1);
                skyTex = lerp(skyTex, mainTex, perlinMask);
                skyTex = lerp(skyTex, bgTex, whiteMask);

                float4 col = skyTex;
                return col;
            }
            ENDCG
        }
    }
}
