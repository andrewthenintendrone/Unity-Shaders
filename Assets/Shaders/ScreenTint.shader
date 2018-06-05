Shader "ScreenTint"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DisplaceTex("Displace Texture", 2D) = "White" {}
		_Magnitude("Magnitude", Float) = 0.0
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
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DisplaceTex;
			float4 _DisplaceTex_ST;
			float _Magnitude;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv2, _DisplaceTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 disp = tex2D(_DisplaceTex, i.uv2).xy;
				disp = ((disp * 2) - 1) * _Magnitude;

				fixed4 col = tex2D(_MainTex, i.uv + disp);
				return col;
			}
			ENDCG
		}
	}
}
