Shader "PointCloud/SquareTransparent" {
	Properties{
		_Size("Point Size", float) = 0.01
		_AlphaMultiplier("Alpha Multiplier", Range(0,1)) = 1
	}
		SubShader{
		LOD 200
		//Tags{ "RenderType" = "Opaque" }
		//if you want transparency
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma geometry geom
#pragma target 4.0                  // Use shader model 3.0 target, to get nicer looking lighting
#include "UnityCG.cginc"
		struct vertexIn {
		float4 pos : POSITION;
		float4 color : COLOR;
	};
	struct vertexOut {
		float4 pos : SV_POSITION;
		float4 color : COLOR0;
	};
	struct geomOut {
		float4 pos : POSITION;
		float4 color : COLOR0;
	};


	//Vertex shader: computes normal wrt camera
	vertexOut vert(vertexIn i) {
		vertexOut o;
		o.pos = UnityObjectToClipPos(i.pos);
		o.color = i.color;

		return o;
	}

	float _Size;
	float _AlphaMultiplier;

	[maxvertexcount(6)]
	void geom(point vertexOut IN[1], inout TriangleStream<geomOut> OutputStream)
	{


		geomOut OUT;
		OUT.color = IN[0].color;
		//OUT.color.a *= _AlphaMultiplier;

		float2 p[3];
		float xyscale = _ScreenParams.y / _ScreenParams.x;

		float xr = _Size * xyscale;
		p[0] = float2(-xr, -_Size);
		p[2] = float2(xr, -_Size);
		p[1] = float2(-xr, _Size);

		OUT.pos = IN[0].pos + float4(p[0], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[2], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[1], 0, 0);
		OutputStream.Append(OUT);

		p[0] = float2(xr, -_Size);
		p[1] = float2(xr, _Size);
		p[2] = float2(-xr, _Size);

		OUT.pos = IN[0].pos + float4(p[0], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[2], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[1], 0, 0);
		OutputStream.Append(OUT);


	}
	float4 frag(geomOut i) : COLOR
	{
		float4 col = i.color;
		col.a *= _AlphaMultiplier;
		return col;
	}
		ENDCG
	}
	}
		FallBack "Diffuse"
}




















