// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/celShading"
{
	Properties
	{
		_Color ("Color", color) = (0, 0, 0, 1)
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
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
			};

			float4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// light direction
				float4 lightDirection = _WorldSpaceLightPos0;

				// color
				fixed4 col = _Color;

				// diffuse lighting(n dot l)
				float lighting = dot(i.normal, normalize(-lightDirection.xyz));

				// calmp for cel shading
				lighting = floor(lighting * 3) / 3;

				// return
				return col * lighting;
			}
			ENDCG
		}
	}
}
