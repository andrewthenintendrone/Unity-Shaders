Shader "Chromatic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Intensity ("Intensity", Range(1, 10)) = 1
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
			float _Intensity;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 texel = _MainTex_TexelSize;

				// sample the texture
				float red = tex2D(_MainTex, i.uv + float2(texel.x * _Intensity, 0)).x;
				float green = tex2D(_MainTex, i.uv).y;
				float blue = tex2D(_MainTex, i.uv + float2(-texel.x * _Intensity, 0)).z;

				fixed4 col = fixed4(red, green, blue, 1.0);

				return col;
			}
			ENDCG
		}
	}
}
