Shader "DepthBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			// box blur
			fixed4 blur(v2f i)
			{
				// kernel
				float2 samplePositions[9] =
				{
					float2(-1, -1),
					float2(0, -1),
					float2(1, -1),
					float2(-1, 0),
					float2(0, 0),
					float2(1, 0),
					float2(-1, 1),
					float2(0, 1),
					float2(1, 1)
				};

				float3 color = float3(0, 0, 0);

				for(int k = 0; k < 9; k++)
				{
					color += tex2D(_MainTex, i.uv + samplePositions[k] * _MainTex_TexelSize).rgb;
				}

				return fixed4(color / 9, 1);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the main texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 blurCol = blur(i);

				// sample the depth texture
				float depth = 1 - Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));

				return lerp(blurCol, col, fixed4(depth, depth, depth, depth));
			}
			ENDCG
		}
	}
}
