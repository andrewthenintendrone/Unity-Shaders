﻿Shader "EdgeDetection"
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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
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
				float2 texel = _MainTex_TexelSize.xy;

				float3 sobelH = float3(0, 0, 0);
				float3 sobelV = float3(0, 0, 0);

				float2 samplePositions[9] =
				{
					float2(i.uv.x - texel.x, i.uv.y - texel.y),
					float2(texel.x, i.uv.y - texel.y),
					float2(i.uv.x + texel.x, i.uv.y - texel.y),
					float2(i.uv.x - texel.x, i.uv.y),
					float2(i.uv.x, i.uv.y),
					float2(i.uv.x + texel.x, i.uv.y),
					float2(i.uv.x - texel.x, i.uv.y + texel.y),
					float2(i.uv.x, i.uv.y + texel.y),
					float2(i.uv.x + texel.x, i.uv.y + texel.y)
				};

				float kernelH[9] =
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

				float kernelV[9] =
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

				for (int i = 0; i < 9; i++)
				{
					//float4 color = tex2D(_MainTex, i.uv);

					sobelH += tex2D(_MainTex, i.uv).rgb;
					sobelV += tex2D(_MainTex, i.uv).rgb;
				}

				sobelH /= 9;
				sobelV /= 9;


				fixed4 col = fixed4(sobelH, 1);
				return col;
			}
			ENDCG
		}
	}
}
