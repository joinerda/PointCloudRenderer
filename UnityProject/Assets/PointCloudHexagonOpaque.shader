Shader "PointCloud/HexagonOpaque" {
	Properties{
		_Size("Point Size", float) = 0.01
	}
		SubShader{
		LOD 200
		Tags{ "RenderType" = "Opaque" }
		//if you want transparency
		//Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		//Blend SrcAlpha OneMinusSrcAlpha
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
	[maxvertexcount(12)]
	void geom(point vertexOut IN[1], inout TriangleStream<geomOut> OutputStream)
	{


		geomOut OUT;
		OUT.color = IN[0].color;


		float2 p[6];
		float xyscale = _ScreenParams.y / _ScreenParams.x;
		float r = _Size;  // radius of the hexagon

		p[0] = r * float2(-xyscale, 0);   // (-1, 0)
		p[1] = r * float2(-0.5 * xyscale, 0.866);  // (-1/2, √3/2)
		p[2] = r * float2(0.5 * xyscale, 0.866);   // (1/2, √3/2)
		p[3] = r * float2(xyscale, 0);   // (1, 0) 
		p[4] = r * float2(0.5 * xyscale, -0.866);  // (1/2, -√3/2)
		p[5] = r * float2(-0.5 * xyscale, -0.866); // (-1/2, -√3/2)

		
		OUT.pos = IN[0].pos + float4(p[0], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[1], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[2], 0, 0);  // The center of the hexagon.
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[0], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[2], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[3], 0, 0);  // The center of the hexagon.
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[0], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[3], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[4], 0, 0);  // The center of the hexagon.
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[0], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[5], 0, 0);
		OutputStream.Append(OUT);
		OUT.pos = IN[0].pos + float4(p[4], 0, 0);  // The center of the hexagon.
		OutputStream.Append(OUT);


		


	}
	float4 frag(geomOut i) : COLOR
	{
		return i.color;
	}
		ENDCG
	}
	}
		FallBack "Diffuse"
}