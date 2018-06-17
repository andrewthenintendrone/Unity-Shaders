Shader "Phong"
{
	Properties
	{
		_Ambient ("Ambient", Color) = (0.25, 0.25, 0.25, 1)
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_SpecularPower ("Specular Power", Float) = 32.0

		_AmbientTex ("Ambient Texture", 2D) = "white" {}
		_DiffuseTex ("Diffuse Texture", 2D) = "white" {}
		_SpecularTex ("Specular Texture", 2D) = "white" {}
		_SpecularPowerTex ("Specular Power Texture", 2D) = "white" {}
		_NormalTex ("Normal Texture", 2D) = "bump" {}
		_EmissiveTex ("Emissive Texture", 2D) = "black" {}
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

			struct v2f
			{
				float3 worldPos : TEXCOORD0;
				// these three vectors will hold a 3x3 rotation matrix
				// that transforms from tangent to world space
				half3 tspace0 : TEXCOORD1; // tangent.x, bitangent.x, normal.x
				half3 tspace1 : TEXCOORD2; // tangent.y, bitangent.y, normal.y
				half3 tspace2 : TEXCOORD3; // tangent.z, bitangent.z, normal.z
										   // texture coordinate for the normal map
				float2 uv : TEXCOORD4;
				float4 pos : SV_POSITION;
			};

			// material properties
			float4 _Ambient;
			float4 _Diffuse;
			float4 _Specular;
			float _SpecularPower;

			sampler2D _AmbientTex;
			float4 _AmbientTex_ST;
			sampler2D _DiffuseTex;
			float4 _DiffuseTex_ST;
			sampler2D _SpecularTex;
			float4 _SpecularTex_ST;
			sampler2D _SpecularPowerTex;
			float4 _SpecularPowerTex_ST;
			sampler2D _NormalTex;
			float4 _NormalTex_ST;
			sampler2D _EmissiveTex;
			float4 _EmissiveTex_ST;
			
			v2f vert (appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 wNormal = UnityObjectToWorldNormal(v.normal);
				half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
				// compute bitangent from cross product of normal and tangent
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
				// output the tangent space matrix
				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
				o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
				o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
				o.uv = v.texcoord;
				return o;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the normal map, and decode from the Unity encoding
				half3 tnormal = UnpackNormal(tex2D(_NormalTex, i.uv));
				// transform normal from tangent to world space
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tnormal);
				worldNormal.y = dot(i.tspace1, tnormal);
				worldNormal.z = dot(i.tspace2, tnormal);

				// ambient lighting
				float3 ambient = _Ambient.rgb * tex2D(_AmbientTex, i.uv) * _LightColor0;

				// diffuse lighting (lambert)
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float lambertTerm = max(0, min(1, dot(worldNormal, L)));
				float3 diffuse = _Diffuse * lambertTerm * tex2D(_DiffuseTex, i.uv) * _LightColor0;

				// specular lighting (phong)
				float3 V = normalize(_WorldSpaceCameraPos - i.pos.xyz);
				float3 R = reflect(L, worldNormal);
				float specularTerm = pow(max(0, dot(R, V)), _SpecularPower * tex2D(_SpecularPowerTex, i.uv));
				float3 specular = _Specular * specularTerm * tex2D(_SpecularTex, i.uv) * _LightColor0;

				// emissive lighting
				float3 emissive = tex2D(_EmissiveTex, i.uv) * (sin(_Time.z) * 0.5 + 0.5);

				return fixed4(ambient + diffuse + specular + emissive, 1);
			}
			ENDCG
		}
	}
}
