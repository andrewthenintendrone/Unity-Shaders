Shader "Custom/TerrainShader"
{
	Properties
	{
		_Texture1("Texture 1", 2D) = "white" {}
		_Texture2("Texture 2", 2D) = "white" {}
		_Texture3("Texture 3", 2D) = "white" {}
		_SnowCutoff("Snow Cutoff", Float) = 0.0
		_SnowFade("Snow Blend", Range(0.0, 1.0)) = 0.0
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader
		{
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_Texture1;
			float2 uv_Texture2;
			float2 uv_Texture3;
		};

		sampler2D _Texture1;
		sampler2D _Texture2;
		sampler2D _Texture3;
		float _SnowCutoff;
		float _SnowFade;
		half _Glossiness;
		half _Metallic;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o)
		{
			float4 rock = tex2D(_Texture1, IN.uv_Texture1);
			float4 grass = tex2D(_Texture2, IN.uv_Texture2);

			float grassBlend = dot(IN.worldNormal, float3(0, 1, 0));
			grassBlend = acos(grassBlend - 0.1);

			o.Albedo = lerp(grass, rock, grassBlend);

			if (IN.worldPos.y >= _SnowCutoff)
			{
				o.Albedo = lerp(o.Albedo, tex2D(_Texture3, IN.uv_Texture3), grassBlend);
			}

			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
