// Made with Amplify Shader Editor v1.9.9.4
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/DitheringFade"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.74
		_Albedo( "Albedo", 2D ) = "white" {}
		[NoScaleOffset] _Normal( "Normal", 2D ) = "bump" {}
		[NoScaleOffset] _Occlusion( "Occlusion", 2D ) = "white" {}
		_StartDitheringFade( "Start Dithering Fade", Float ) = 0
		_EndDitheringFade( "End Dithering Fade", Float ) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#define ASE_VERSION 19904
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPosition;
		};

		uniform sampler2D _Normal;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Occlusion;
		uniform float _StartDitheringFade;
		uniform float _EndDitheringFade;
		uniform float _Cutoff = 0.74;


		float4 ASEScreenPositionNormalizedToPixel( float4 screenPosNorm, float4 screenParams )
		{
			float4 screenPosPixel = screenPosNorm * float4( screenParams.xy, 1, 1 );
			#if UNITY_UV_STARTS_AT_TOP
				screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x < 0 ) ? screenParams.y - screenPosPixel.y : screenPosPixel.y );
			#else
				screenPosPixel.xy = float2( screenPosPixel.x, ( _ProjectionParams.x > 0 ) ? screenParams.y - screenPosPixel.y : screenPosPixel.y );
			#endif
			return screenPosPixel;
		}


		inline float Dither8x8Bayer( uint x, uint y )
		{
			const float dither[ 64 ] = {
			     1, 49, 13, 61,  4, 52, 16, 64,
			    33, 17, 45, 29, 36, 20, 48, 32,
			     9, 57,  5, 53, 12, 60,  8, 56,
			    41, 25, 37, 21, 44, 28, 40, 24,
			     3, 51, 15, 63,  2, 50, 14, 62,
			    35, 19, 47, 31, 34, 18, 46, 30,
			    11, 59,  7, 55, 10, 58,  6, 54,
			    43, 27, 39, 23, 42, 26, 38, 22};
			uint r = y * 8 + x;
			return dither[ min( r, 63 ) ] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_positionSS = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_positionSS;
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Albedo ) );
			o.Albedo = tex2D( _Albedo, uv_Albedo ).rgb;
			o.Occlusion = tex2D( _Occlusion, uv_Albedo ).r;
			o.Alpha = 1;
			float4 ase_positionSS = i.screenPosition;
			half ase_depthLinearEye = LinearEyeDepth( ase_positionSS.z / ase_positionSS.w );
			half temp_output_65_0 = ( _StartDitheringFade + _ProjectionParams.y );
			half4 ase_positionSSNorm = ase_positionSS / ase_positionSS.w;
			ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
			half4 ase_positionSS_Pixel = ASEScreenPositionNormalizedToPixel( ase_positionSSNorm, _ScreenParams );
			half dither26 = Dither8x8Bayer( fmod( ase_positionSS_Pixel.x, 8 ), fmod( ase_positionSS_Pixel.y, 8 ) );
			clip( ( ( ( ase_depthLinearEye + -temp_output_65_0 ) / ( _EndDitheringFade - temp_output_65_0 ) ) - dither26 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
}
/*ASEBEGIN
Version=19904
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;36;-622.9761,91.39496;Inherit;False;1047.541;403.52;Scale depth from start to end;8;30;65;28;29;34;31;33;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;37;-609.7847,546.5101;Inherit;False;297.1897;243;Correction for near plane clipping;1;19;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ProjectionParams, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;19;-537.0848,595.81;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;30;-584.0002,374.09;Float;False;Property;_StartDitheringFade;Start Dithering Fade;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;65;-298.5083,377.6221;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;31;-117.5356,335.0947;Float;False;Property;_EndDitheringFade;End Dithering Fade;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SurfaceDepthNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;15;-557.4172,189.5072;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;33;-107.1209,253.7414;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;28;101.9639,194.1952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;47;-62.14664,-384.9758;Inherit;False;0;44;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;29;99.26421,348.9946;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;34;285.764,250.6948;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;26;480,336;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;44;384,-688;Inherit;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;45;384,-496;Inherit;True;Property;_Normal;Normal;2;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;48;384,-112;Inherit;True;Property;_Occlusion;Occlusion;4;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;46;384,-304;Inherit;True;Property;_Specular;Specular;3;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;49;847.9045,48.44281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;52;867.2929,-172.9061;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;51;857.5114,-90.67801;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;27;736,256;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;0;999.2003,-69.70003;Half;False;True;-1;2;AmplifyShaderEditor.MaterialInspector;0;0;StandardSpecular;ASESampleShaders/DitheringFade;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;3;False;;False;0;False;;0;False;;False;0;Masked;0.74;True;True;0;False;TransparentCutout;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;65;0;30;0
WireConnection;65;1;19;2
WireConnection;33;0;65;0
WireConnection;28;0;15;0
WireConnection;28;1;33;0
WireConnection;29;0;31;0
WireConnection;29;1;65;0
WireConnection;34;0;28;0
WireConnection;34;1;29;0
WireConnection;44;1;47;0
WireConnection;45;1;47;0
WireConnection;48;1;47;0
WireConnection;46;1;47;0
WireConnection;49;0;48;1
WireConnection;52;0;44;0
WireConnection;51;0;45;0
WireConnection;27;0;34;0
WireConnection;27;1;26;0
WireConnection;0;0;52;0
WireConnection;0;1;51;0
WireConnection;0;5;49;0
WireConnection;0;10;27;0
ASEEND*/
//CHKSM=CACA9F8EFBBACC65560CE1A49C021A0EE37F6807