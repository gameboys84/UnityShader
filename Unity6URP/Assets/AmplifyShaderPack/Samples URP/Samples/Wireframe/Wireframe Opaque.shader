// Made with Amplify Shader Editor v1.9.9.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AmplifyShaderPack/Wireframe Opaque"
{
	Properties
	{
		_WireframeSmoothing ( "Wireframe Smoothing", Range( 0, 10 ) ) = 1
		_WireframeThickness ( "Wireframe Thickness", Range( 0, 10 ) ) = 1

		[HDR] _WireColor( "Wire Color", Color ) = ( 1, 0, 0 )
		[HDR] _BaseColor( "Base Color", Color ) = ( 0, 1, 0 )
		[Enum(Front,2,Back,1,Both,0)] _Cull( "Render Face", Int ) = 2

	}

	SubShader
	{
		

		Tags { "RenderType"="Opaque" }

	LOD 0

		

		Blend Off
		AlphaToMask Off
		Cull [_Cull]
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		

		CGINCLUDE
			#pragma target 3.5

			float4 ComputeClipSpacePosition( float2 screenPosNorm, float deviceDepth )
			{
				float4 positionCS = float4( screenPosNorm * 2.0 - 1.0, deviceDepth, 1.0 );
			#if UNITY_UV_STARTS_AT_TOP
				positionCS.y = -positionCS.y;
			#endif
				return positionCS;
			}
		ENDCG

		
		Pass
		{
			
			Name "Unlit"

			Blend One Zero

			CGPROGRAM
				#define ASE_VERSION 19904

				#pragma require geometry

				#pragma vertex vert_setup
				#pragma geometry geom
				#pragma fragment frag

				#pragma multi_compile_instancing
				#include "UnityCG.cginc"

				

				struct appdata
				{
					float4 vertex : POSITION;
					
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 baryCoords : TEXCOORD0;
					
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				uniform int _Cull;
				uniform float3 _WireColor;
				uniform float3 _BaseColor;


				
				appdata vert_setup( appdata v )
				{
					return v;
				}

				v2f vert_apply( appdata v, float3 baryCoords  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID( v );
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
					UNITY_TRANSFER_INSTANCE_ID( v, o );

					

					float3 vertexValue = float3( 0, 0, 0 );
					#if ASE_ABSOLUTE_VERTEX_POS
						vertexValue = v.vertex.xyz;
					#endif

					vertexValue = vertexValue;

					#if ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif

					o.pos = UnityObjectToClipPos( v.vertex );
					o.baryCoords = baryCoords;
					return o;
				}

				[maxvertexcount(15)]
				void geom( triangle appdata input[3], uint pid : SV_PrimitiveID, inout TriangleStream<v2f> outStream )
				{
					outStream.Append( vert_apply( input[ 0 ], float3( 1, 0, 0 ) ) );
					outStream.Append( vert_apply( input[ 1 ], float3( 0, 1, 0 ) ) );
					outStream.Append( vert_apply( input[ 2 ], float3( 0, 0, 1 ) ) );
				}

				float _WireframeSmoothing;
				float _WireframeThickness;

				half ComputeWireframe( float3 baryCoords )
				{
					float3 deltas = fwidth( baryCoords );
					float3 smoothing = deltas * _WireframeSmoothing;
					float3 thickness = deltas * _WireframeThickness;
					baryCoords = smoothstep( thickness, thickness + smoothing, baryCoords );
					float minBary = min( baryCoords.x, min( baryCoords.y, baryCoords.z ) );
					return 1 - minBary;
				}

				half4 frag( v2f IN  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( IN );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

					float4 ScreenPosNorm = float4( IN.pos.xy * ( _ScreenParams.zw - 1.0 ), IN.pos.zw );
					float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, IN.pos.z ) * IN.pos.w;
					float4 ScreenPos = ComputeScreenPos( ClipPos );

					

					half3 wireColor = _WireColor;
					half3 surfaceColor = _BaseColor;

					half wire = ComputeWireframe( IN.baryCoords );

					half4 finalColor;
				#if defined( ASE_WIREFRAME_ALPHA )
					finalColor.rgb = wireColor;
					finalColor.a = wire;
				#else
					finalColor.rgb = lerp( surfaceColor.rgb, wireColor.rgb, wire );
					finalColor.a = 1;
				#endif
					return finalColor;
				}
			ENDCG
		}
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19904
Node;AmplifyShaderEditor.IntNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;3;0,-224;Inherit;False;Property;_Cull;Render Face;2;1;[Enum];Create;False;1;;0;1;Front,2,Back,1,Both,0;True;0;False;2;2;False;0;1;INT;0
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;1;-320,-144;Inherit;False;Property;_WireColor;Wire Color;0;1;[HDR];Create;True;0;0;0;False;0;False;1,0,0,0;0.8867924,0.4764209,0,0;True;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;2;-320,0;Inherit;False;Property;_BaseColor;Base Color;1;1;[HDR];Create;True;0;0;0;False;0;False;0,1,0,0;0.25,0.25,0.25,0.7254902;True;False;0;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;9;0,-144;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;18;AmplifyShaderPack/Wireframe Opaque;45bf09b07249a46489d5200e9ba4d9f1;True;Unlit;0;0;Unlit;3;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_Cull;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;3;False;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;2;Vertex Position,InvertActionOnDeselection;1;0;Wireframe Mode;0;0;0;1;True;False;;False;0
WireConnection;9;0;1;0
WireConnection;9;1;2;0
ASEEND*/
//CHKSM=D8FD6DE19AB6AF1DBED680CCE9CD1C977634A8F9