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
import geom.Quaternion;
import geom.DualQuaternion;
import geom.Matrix1x4;
import geom.Axis;
import geom.Trinary;
import geom.Projection;
#if (haxe_ver < 4.0 )
import js.html.Float32Array;
#else
import  js.lib.Float32Array;
#end

using htmlHelper.webgl.WebGLSetup;
class Main extends WebGLSetup {
    var webgl:                  WebGLSetup;
    var characterInput:         CharacterInput;
    var trilateralTest:         TrilateralTest;
    var scale:                  Float;
    var model                   =  DualQuaternion.zero();
    //var origin                  =  DualQuaternion.zero();
    var axisModel               = new Axis();
    //var axisOrigin              = new Axis();
    public static function main(){ new Main(); }
    public inline static var stageRadius: Int = 600;
    public function new(){
        super( stageRadius, stageRadius );
        DEPTH_TEST = false;
        BACK = false;
        scale = 1/(stageRadius);
        darkBackground();
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
        if( characterInput.cmdDown ){            axisModel.roll( negative );
        } else if( characterInput.altDown ){     axisModel.roll( positive );
        } else {                                 axisModel.roll( zero );
        }
        if( characterInput.tabDown ) {           axisModel.alongY( positive );
        } else if( characterInput.shiftDown ){   axisModel.alongY( negative );
        } else {                                 axisModel.alongY( zero );
        }
        if( characterInput.spaceDown ) {         axisModel.alongX( positive );
        } else if( characterInput.controlDown ){ axisModel.alongX( negative );
        } else {                                 axisModel.alongX( zero );
        }
        if( characterInput.deleteDown ) {        axisModel.alongZ( positive );
        } else if( characterInput.enterDown ){   axisModel.alongZ( negative );
        } else {                                 axisModel.alongZ( zero );
        }
        trace( characterInput.commandDown() );
    }
    inline
    function navDown(){
        trace( characterInput.navDown() );
        if( characterInput.leftDown ) {         axisModel.yaw( positive );
        } else if( characterInput.rightDown ){  axisModel.yaw( negative );
        } else {                                axisModel.yaw( zero );
        }
        if( characterInput.upDown ) {           axisModel.pitch( positive );
        } else if( characterInput.downDown ){   axisModel.pitch( negative );
        } else {                                axisModel.pitch( zero );
        }
    }
    inline
    function letterDown( letter: String ){
        /*
        if( letter == 'q' ){                    quatAxis.along( positive );
        } else if( letter == 'a' ){             quatAxis.alongX( negative );
        } else {                                quatAxis.alongX( zero );
        }
        */
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
        var oz: Float = 0.;
        var no: Int = 0;
        for( tri in triangles ){
            vertices[ i++ ] = tri.ax*scale + ox;
            vertices[ i++ ] = -tri.ay*scale + oy;
            vertices[ i++ ] = tri.depth + oz;
            vertices[ i++ ] = tri.bx*scale + ox;
            vertices[ i++ ] = -tri.by*scale + oy;
            vertices[ i++ ] = tri.depth + oz;
            vertices[ i++ ] = tri.cx*scale + ox;
            vertices[ i++ ] = -tri.cy*scale + oy;
            vertices[ i++ ] = tri.depth + oz;
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
            vertices[ i++ ] = tri.depth + oz;
            vertices[ i++ ] = tri.cx*scale + ox;
            vertices[ i++ ] = -tri.cy*scale + oy;
            vertices[ i++ ] = tri.depth + oz;
            vertices[ i++ ] = tri.bx*scale + ox;
            vertices[ i++ ] = -tri.by*scale + oy;
            vertices[ i++ ] = tri.depth + oz;
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
        //origin = axisOrigin.updateCalculate( origin );
        model  = axisModel.updateCalculate( model );
        var trans: Matrix4x3 = ( offset * model ).normalize();
        var proj4 = ( Projection.perspective() * trans ).toFloat32Array( matrix32Array );
        trace( 'matrix32Array ' + matrix32Array );
        render();

    }
    var offset = getOffset();
    inline
    function getOffset(): DualQuaternion {
        var qReal = Quaternion.zeroNormal();
        var qDual = new Matrix1x4( { x: 0., y: 0., z: -10., w: 1. } );
        return DualQuaternion.create( qReal, qDual );
    }
    override public 
    function render(){
        super.render();
    }
}