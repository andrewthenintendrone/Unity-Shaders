Shader "EdgeDetection"
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// positions to sample
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

				// horizontal kernel
				float kernelH[9] =
				{
					1,
					2,
					1,
					0,
					0,
					0,
					-1,
					-2,
					-1
				};

				// vertical kernel
				float kernelV[9] =
				{
					1,
					0,
					-1,
					2,
					0,
					-2,
					1,
					0,
					-1
				};

				float3 sobelH = float3(0, 0, 0);
				float3 sobelV = float3(0, 0, 0);

				for (int k = 0; k < 9; k++)
				{
					sobelH += tex2D(_MainTex, i.uv + samplePositions[k] * _MainTex_TexelSize).rgb * kernelH[k];
					sobelV += tex2D(_MainTex, i.uv + samplePositions[k] * _MainTex_TexelSize).rgb * kernelV[k];
				}

				float sobelAverageH = (sobelH.r + sobelH.g + sobelH.b) / 3;
				float sobelAverageV = (sobelV.r + sobelV.g + sobelV.b) / 3;

				float sobelFinal = 1 - pow(pow(sobelAverageH, 2) + pow(sobelAverageV, 2), 0.5);

				float3 lines = float3(sobelFinal, sobelFinal, sobelFinal);

				return float4(lines * tex2D(_MainTex, i.uv).rgb, 1);
			}
			ENDCG
		}
	}
}
