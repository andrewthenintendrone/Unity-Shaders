Shader "Unlit/Water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ColorWater("Color Water", Color) = (0, 0, 0, 1)
		_ColorFoam("Color Foam", Color) = (1, 1, 1, 1)
		_WaveOffset("Wave offset", Vector) = (0, 0, 0, 0)
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
			float4 _ColorWater;
			float4 _ColorFoam;
			float4 _WaveOffset;
			
			float getWaveHeight(appdata v)
			{
				float height = 0;
				float x = v.vertex.x;
				float z = v.vertex.z;


				height += (sin(x * 1.0 / 10.0 + _Time.y * 1.0) + sin(x * 2.3 / 10.0 + _Time.y * 1.5) + sin(x * 3.3 / 10.0f + _Time.y * 0.4)) / 3.0;
				height += (sin(z * 0.2 / 10.0 + _Time.y * 1.8) + sin(z * 1.8 / 10.0 + _Time.y * 1.8) + sin(z * 2.8 / 10.0f + _Time.y * 0.8)) / 3.0;
				return height;
			}

			v2f vert (appdata v)
			{
				v2f o;

				v.vertex.y = getWaveHeight(v);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float foamFactor = tex2D(_MainTex, i.uv).a;
				fixed4 col = lerp(_ColorWater, _ColorFoam, foamFactor);
				
				return col;
			}
			ENDCG
		}
	}
}
