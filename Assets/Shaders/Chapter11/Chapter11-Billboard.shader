Shader "UnityShaderLearning/Chapter 11/Billboard"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _VerticalBillboarding ("Vertical Restraints", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Opaque" "Disablebatching"="True" }
        
        ZWrite Off 
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off 

        Pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM

            #pragma vertex vert 
            #pragma fragment frag 

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _VerticalBillboarding;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (a2v v) {
                v2f o;

                float3 center = float3(0, 0, 0);
                float3 objectViewDir = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)).xyz;
                
                float3 normalDir = objectViewDir - center;
                
                //_VerticalBillboarding = 0, 即是将y分量强行置为1,归一化后向上的方向就是(0,1,0)
                normalDir.y *= _VerticalBillboarding;
                normalDir = normalize(normalDir);

                //获取向上的向量基
                float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3 (0, 1, 0);
                float3 rightDir = normalize(cross(upDir, normalDir));
                upDir = normalize(cross(normalDir, rightDir));
                //
                float3 centerOffset = v.vertex.xyz - center;
                float3 localPos = center + centerOffset.x * rightDir +
                                            centerOffset.y * upDir +
                                            centerOffset.z * normalDir;
                
                o.pos = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }
            fixed4 frag (v2f i) : SV_TARGET {
                fixed4 color = tex2D(_MainTex, i.uv);
                color.rgb *= _Color.rgb;

                return color;
            }
            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
