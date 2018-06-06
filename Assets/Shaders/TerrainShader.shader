Shader "TerrainShader"
{
	// shader uniforms
	Properties
	{
		_SandTex("Sand Diffuse Texture", 2D) = "white" {}
		_GrassTex("Grass Diffuse Texture", 2D) = "white" {}
		_DirtTex("Dirt Diffuse Texture", 2D) = "white" {}
		_SnowTex("Snow Diffuse Texture", 2D) = "white" {}
		_SampleScale("Texture sample scale", float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma glsl
			#pragma target 3.0
			// vertex shader is called vert
			#pragma vertex vert
			// fragment shader is called frag
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			// sent from unity to the vertex shader
			struct appdata
			{
				// position
				float4 position : POSITION;
				
				// normal
				float4 normal : NORMAL;

				// uvs
				float2 uvs : TEXCOORD0;
			};

			// sent from the vertex shader to the fragment shader
			struct v2f
			{
				float4 screenPos : POSITION; // postion on screen
				float4 worldPos : TEXCOORD11; // position in world

				float4 normal : NORMAL; // normal

				// uvs
				float2 uvs : TEXCOORD0;
			};

			// internal uniforms (_ST are the uvs)
			sampler2D _SandTex;
			float4 _SandTex_ST;
			sampler2D _GrassTex;
			sampler2D _DirtTex;
			sampler2D _SnowTex;
			float _SampleScale;

			float4 _TerrainScale;
			
			// vertex shader
			v2f vert (appdata v)
			{
				v2f o;
				
				o.screenPos = UnityObjectToClipPos(v.position);
				o.worldPos = v.position;

				o.normal = v.normal;

				o.uvs = TRANSFORM_TEX(v.uvs, _SandTex);

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float y = i.worldPos.y;

				// triplanar stuff

				float3 blending = abs(i.normal);
				blending = normalize(max(blending, 0.00001)); // force weights to sum to 1
				float b = (blending.x + blending.y + blending.z);
				blending /= b;
				
				float4 xaxis;
				float4 yaxis;
				float4 zaxis;

				if (y < _TerrainScale.y * 0.25)
				{
					float2 samplePos = 1.0 / _TerrainScale * _SampleScale;

					xaxis = tex2D(_SandTex, i.worldPos.yz * samplePos);
					yaxis = tex2D(_SandTex, i.worldPos.xz * samplePos);
					zaxis = tex2D(_SandTex, i.worldPos.xy * samplePos);
				}
				else if (y < _TerrainScale.y * 0.5)
				{
					float2 samplePos = 1.0 / _TerrainScale * _SampleScale;

					xaxis = tex2D(_GrassTex, i.worldPos.yz * samplePos);
					yaxis = tex2D(_GrassTex, i.worldPos.xz * samplePos);
					zaxis = tex2D(_GrassTex, i.worldPos.xy * samplePos);
				}
				else if (y < _TerrainScale.y * 0.75)
				{
					float2 samplePos = 1.0 / _TerrainScale * _SampleScale;

					xaxis = tex2D(_DirtTex, i.worldPos.yz * samplePos);
					yaxis = tex2D(_DirtTex, i.worldPos.xz * samplePos);
					zaxis = tex2D(_DirtTex, i.worldPos.xy * samplePos);
				}
				else
				{
					float2 samplePos = 1.0 / _TerrainScale * _SampleScale;

					xaxis = tex2D(_SnowTex, i.worldPos.yz * samplePos);
					yaxis = tex2D(_SnowTex, i.worldPos.xz * samplePos);
					zaxis = tex2D(_SnowTex, i.worldPos.xy * samplePos);
				}

				float4 tex = xaxis * blending.x + yaxis * blending.y + zaxis * blending.z;

				return tex;
			}
			ENDCG
		}
	}
}
