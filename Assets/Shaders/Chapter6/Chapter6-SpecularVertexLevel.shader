Shader "UnityShaderLearning/Chapter 6/Specular Vertex-Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass{
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f{
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v v){
                v2f o;
                //Transform the vertex from object space to projection space
                //把顶点从模型空间转换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);

                //Get ambient term
                //获取环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //Transform the normal fram object space to world space
                //把法线从模型空间转换到世界空间
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                //Get the light direction in world space
                //获取光源位置
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //Compute diffuse term
                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir)); 

                //Get the reflect direction in world space
                //获取反射方向
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                //Get the view direction in world space
                //获取世界空间的视口方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - UnityObjectToClipPos(v.vertex));

                //Compute specular term
                //计算高光
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
