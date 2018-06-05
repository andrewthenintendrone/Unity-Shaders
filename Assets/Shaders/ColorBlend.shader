Shader "Unlit/ColorBlend"
{
	Properties
	{
		_Color1("Color", Color) = (1, 1, 1, 1)
		_Color2("Color", Color) = (0, 0, 0, 1)
		_Factor("float", range(0, 1)) = 0
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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			float4 _Color1;
			float4 _Color2;
			float _Factor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// blend colors based on factor
				return lerp(_Color1, _Color2, sin(_Time) * 0.5 + 0.5);
			}
			ENDCG
		}
	}
}
