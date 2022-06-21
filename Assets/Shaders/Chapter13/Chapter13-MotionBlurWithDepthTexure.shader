Shader "UnityShaderLearning/Chapter 13/Motion Blur With Depth Texure"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMatrix;
        half _BlurSize;

        struct v2f {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
        };

        v2f vert (appdata_img v) {
            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);

            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1 - o.uv_depth.y;
            #endif

            return o;
        }

        fixed4 frag (v2f i) : SV_TARGET {
            //获取深度值
            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);

            //NDC坐标
            float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth * 2 - 1, 1);

            //获取世界坐标
            float4 worldPos = mul(_CurrentViewProjectionInverseMatrix, H);
            worldPos /= worldPos.w;

            //现在的视点坐标
            float4 currentPos = H;
            
            //用前一帧的变换矩阵变换世界坐标
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            previousPos /= previousPos.w;

            //像素的移动速度
            float2 velocity = (currentPos.xy - previousPos.xy)/2.0f;

            float2 uv = i.uv;
            float4 color = tex2D(_MainTex, uv);

            uv += velocity * _BlurSize;
            for (int iter = 1; iter <3; iter++, uv += velocity * _BlurSize) {
                float4 currentColor = tex2D(_MainTex, uv);
                color += currentColor;
            }
            color /= 3;

            return fixed4(color.rgb, 1.0);
        }

        ENDCG

        Pass {
            ZTest Always
            Cull Off
            ZWrite Off 
                
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag 

            ENDCG
        }
    }
    FallBack Off 
}