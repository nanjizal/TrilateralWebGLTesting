package;
import js.Browser;
import htmlHelper.webgl.WebGLSetup;
import htmlHelper.tools.CharacterInput;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import htmlHelper.tools.AnimateTimer; 
import trilateral.tri.Triangle;
import TrilateralTest;
import shaders.Shaders;
import geom.Matrix4x3;
import geom.Matrix4x4;
import geom.QuatAxis;
import geom.Trinary;
#if (haxe_ver < 4.0 )
import js.html.Float32Array;
#else
import  js.lib.Float32Array;
#end


using htmlHelper.webgl.WebGLSetup;
class Main extends WebGLSetup {
    var webgl:          WebGLSetup;
    var characterInput: CharacterInput;
    var trilateralTest: TrilateralTest;
    var scale:          Float;
    var modelViewProjection: Matrix4x3;
    var quatAxis        = new QuatAxis();
    public static function main(){ new Main(); }
    public inline static var stageRadius: Int = 600;
    public function new(){
        super( stageRadius, stageRadius );
        DEPTH_TEST = false;
        BACK = false;
        scale = 1/(stageRadius);
        darkBackground();
        modelViewProjection =  Matrix4x3.unit();//Matrix4x4.perspective( Math.PI/5, 1, 4, 8 );
        setupProgram( Shaders.vertex, Shaders.fragment );
        trilateralTest =  new TrilateralTest( stageRadius );
        trilateralTest.setup();
        setTriangles( trilateralTest.triangles, cast trilateralTest.appColors );
        setAnimate();
    }
    inline
    function setAnimate(){
        characterInput = new CharacterInput();
        characterInput.commandSignal = commandDown;
        characterInput.navSignal     = navDown;
        characterInput.letterSignal  = letterDown;
        AnimateTimer.create();
        AnimateTimer.onFrame = render_;
    }
    inline
    function commandDown(){
        if( characterInput.cmdDown ){          quatAxis.roll( negative );
        } else if( characterInput.altDown ){   quatAxis.roll( positive );
        } else {                               quatAxis.roll( zero );
        }
        //trace( characterInput.commandDown() );
    }
    inline
    function navDown(){
        //trace( characterInput.navDown() );
        if( characterInput.leftDown ) {        quatAxis.yaw( positive );
        } else if( characterInput.rightDown ){ quatAxis.yaw( negative );
        } else {                               quatAxis.yaw( zero );
        }
        if( characterInput.upDown ) {          quatAxis.pitch( positive );
        } else if( characterInput.downDown ){  quatAxis.pitch( negative );
        } else {                               quatAxis.pitch( zero );
        }
    }
    inline
    function letterDown( letter: String ){
        if( letter == 'q' ){                    quatAxis.alongZ( positive );
        } else if( letter == 'a' ){             quatAxis.alongZ( negative );
        } else {                                quatAxis.alongZ( zero );
        }
        //trace( 'letter pressed ' + letter );
    }
    function darkBackground(){
        var dark = 0x18/256;
        bgRed   = dark;
        bgGreen = dark;
        bgBlue  = dark;
    }
    inline
    function setTriangles( triangles: Array<Triangle>, triangleColors:Array<UInt> ) {
        var rgb: RGB;
        var colorAlpha = 1.;
        var tri: Triangle;
        var count = 0;
        var i: Int = 0;
        var c: Int = 0;
        var j: Int = 0;
        var ox: Float = -1.0;
        var oy: Float = 1.0;
        var no: Int = 0;
        for( tri in triangles ){
            vertices[ i++ ] = tri.ax*scale + ox;
            vertices[ i++ ] = -tri.ay*scale + oy;
            vertices[ i++ ] = tri.depth;
            vertices[ i++ ] = tri.bx*scale + ox;
            vertices[ i++ ] = -tri.by*scale + oy;
            vertices[ i++ ] = tri.depth;
            vertices[ i++ ] = tri.cx*scale + ox;
            vertices[ i++ ] = -tri.cy*scale + oy;
            vertices[ i++ ] = tri.depth;
            if( tri.mark != 0 ){
                rgb = WebGLSetup.toRGB( triangleColors[ tri.mark ] );
            } else {
                rgb = WebGLSetup.toRGB( triangleColors[ tri.colorID ] );
            }
            for( k in 0...3 ){
                colors[ c++ ] = rgb.r;
                colors[ c++ ] = rgb.g;
                colors[ c++ ] = rgb.b;
                colors[ c++ ] = colorAlpha;
                indices[ j++ ] = count++;
            }
            vertices[ i++ ] = tri.ax*scale + ox;
            vertices[ i++ ] = -tri.ay*scale + oy;
            vertices[ i++ ] = tri.depth;
            vertices[ i++ ] = tri.cx*scale + ox;
            vertices[ i++ ] = -tri.cy*scale + oy;
            vertices[ i++ ] = tri.depth;
            vertices[ i++ ] = tri.bx*scale + ox;
            vertices[ i++ ] = -tri.by*scale + oy;
            vertices[ i++ ] = tri.depth;
            if( tri.mark != 0 ){
                rgb = WebGLSetup.toRGB( triangleColors[ tri.mark ] );
            } else {
                rgb = WebGLSetup.toRGB( triangleColors[ tri.colorID ] );
            }
            for( k in 0...3 ){
                colors[ c++ ] = rgb.r;
                colors[ c++ ] = rgb.g;
                colors[ c++ ] = rgb.b;
                colors[ c++ ] = colorAlpha;
                indices[ j++ ] = count++;
            }
        }
        gl.uploadDataToBuffers( program, vertices, colors, indices );
    }
    inline
    function render_( i: Int ):Void{        
        modelViewProjection = quatAxis.updateCalculate( modelViewProjection );
        //matrix32Array = new Float32Array( WebGLSetup.ident() );
        modelViewProjection.toFloat32Array( matrix32Array );
        trace( 'matrix32Array ' + matrix32Array );
        render();

    }
    override public 
    function render(){
        super.render();
    }
}