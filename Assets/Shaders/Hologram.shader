Shader "Unlit/Hologram"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TintColor("Tint Color", Color) = (1, 1, 1, 1)
		_Transparency("Transparency", Range(0, 1)) = 0.25
		_CutoutThresh("Cutout Threshold", Range(0, 1)) = 0.2
		_Distance("Distance", Float) = 1
		_Amplitude("Amplitude", Float) = 1
		_Speed("Speed", Float) = 1
		_Amount("Amount", Float) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			//ZWrite Off
			//Blend SrcAlpha OneMinusSrcAlpha

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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _TintColor;
			float _Transparency;
			float _CutoutThresh;
			float _Distance;
			float _Amplitude;
			float _Speed;
			float _Amount;
			
			v2f vert (appdata v)
			{
				v2f o;
				//v.vertex.y += sin(_Time.y * _Speed + v.vertex.x * _Amplitude) * _Distance * _Amount;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				float b = pow(i.normal.r, 2) + pow(i.normal.g, 2);
				b = 0.5;
				fixed4 col = fixed4(i.normal.r, i.normal.g, b, 1);

				return col;
			}
			ENDCG
		}
	}
}
