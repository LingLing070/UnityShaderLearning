using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase {

    public Shader motionBlurShader;
    private Material motionBlurMaterial;

    public Material material {
        get {
            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;
        }
    }

    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    private RenderTexture accumulationTexture;

    void OnDisable() {
        DestroyImmediate(accumulationTexture);
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        if (material != null) {
            
            //initialize the accumulationTexture
            if (accumulationTexture == null || 
                accumulationTexture.width != src.width || 
                accumulationTexture.height != src.height) {
                    DestroyImmediate(accumulationTexture);
                    accumulationTexture = new RenderTexture(src.width, src.height, 0);
                    accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                    Graphics.Blit(src, accumulationTexture);
            }

            //恢复操作
            accumulationTexture.MarkRestoreExpected();

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            Graphics.Blit(src, accumulationTexture, material);
            Graphics.Blit(accumulationTexture, dest);
        }
        else {
            Graphics.Blit(src, dest);
        }
    }
}
