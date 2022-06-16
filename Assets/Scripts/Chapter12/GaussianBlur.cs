using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMaterial = null;

    public Material material {
        get {
            gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
            return gaussianBlurMaterial;
        }
    }

    //Blur Iterator. The bigger, the more blur
    [Range(0, 4)]
    public int iterations = 3;

    //Blur spread for each iterator. 
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1,8)]
    public int downSample = 2;

    // //单纯应用模糊
    // void OnRenderImage(RenderTexture src, RenderTexture dest) {
    //     if (material != null) {
    //         int rtW = src.width;
    //         int rtH = src.height;

    //         RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
    //         Graphics.Blit(src, buffer, material, 0);
    //         Graphics.Blit(buffer, dest, material, 1);

    //         RenderTexture.ReleaseTemporary(buffer);
    //     }
    //     Graphics.Blit(src, dest);
    // }

    // //降采样模糊
    // void OnRenderImage(RenderTexture src, RenderTexture dest) {
    //     if (material != null) {
    //         int rtW = src.width/downSample;
    //         int rtH = src.height/downSample;

    //         RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
    //         buffer.filterMode = FilterMode.Bilinear;

    //         Graphics.Blit(src, buffer, material, 0);
    //         Graphics.Blit(buffer, dest, material, 1);

    //         RenderTexture.ReleaseTemporary(buffer);
    //     }
    //     else {
    //         Graphics.Blit(src, dest);
    //     }
    // }

    //同时考虑迭代次数
    void OnRenderImage (RenderTexture src, RenderTexture dest) {
        if (material != null){
            int rtW = src.width / downSample;
            int rtH = src.width / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);

            Graphics.Blit(src, buffer0);

            for (int i = 0; i < iterations ; ++i) {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW ,rtH, 0);

                //竖直方向
                Graphics.Blit(buffer0, buffer1, material, 0);
                //重置
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //水平方向
                Graphics.Blit(buffer0, buffer1, material, 1);

                //重置，本层结果存到buffer0, 下一层迭代开始, 如果结束, 也是存到buffer0
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            
            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else {
            Graphics.Blit(src, dest);
        }
    }

}
