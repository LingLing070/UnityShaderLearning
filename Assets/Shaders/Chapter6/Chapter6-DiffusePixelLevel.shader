// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "UnityShaderLearning/Chapter 6/Diffuse Pixel-Level"
{
    Properties
    {
        //Diffuse Color 漫反射颜色
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass{
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse; //使用Properties里的变量

            //输入和输出结构体
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal: TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                //Transform the vertex from object space to projection space
                //把顶点从模型空间转换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);

                //Transform the normal fram object space to world space
                //把法线从模型空间转换到世界空间
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                //Get ambient term
                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //Get the normal in world space
                //获取世界空间下的法线
                fixed3 worldNormal = normalize(i.worldNormal);
                //Get the light direction in world space
                //获取光源方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                //Compute diffuse term
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
