Shader "UnityShaderLearning/Chapter 6/Blinn-Phong Built In Function"
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
                fixed3 worldNormal : TEXCOORD0;
                fixed3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                //Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                //Transform the normal from object space to world space
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                //Transform the vertex from object space to world space
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //Transform the normal fram object space to world space
                fixed3 worldNormal = normalize(i.worldNormal);
                //Get the light direction in world space
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                //Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                //Get the view direction in world space
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                //Get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);

                //Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfDir)), _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}