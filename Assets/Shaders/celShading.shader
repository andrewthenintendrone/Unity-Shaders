Shader "CelShading"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Ambient ("Ambient", float) = 0.1
		_Color ("Color", color) = (1, 1, 1, 1)
		_Cuts ("Number of cuts", Range(2, 10)) = 3
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Ambient;
			float4 _Color;
			float _Cuts;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample texture
				float4 textureColor = tex2D(_MainTex, i.uv);

				// discard if texture alpha is lower than 0.5
				if (textureColor.a < 0.5)
				{
					discard;
				}

				// get normal
				float3 N = normalize(i.normal).xyz;

				// get light direction
				float3 L = normalize(i.vertex.xyz - _WorldSpaceLightPos0.xyz);

				// calculate lambert term (N dot L)
				float lambertTerm = dot(N, L);

				// clamp lambert term for cel shading
				lambertTerm = floor(lambertTerm * _Cuts) / (_Cuts + 1) + _Ambient;

				// return final fragment color
				return lambertTerm * _Color * textureColor;
			}
			ENDCG
		}
	}
}
