package;
import js.Browser;
import htmlHelper.webgl.WebGLSetup;
import js.html.Event;
import js.html.KeyboardEvent;
import js.html.MouseEvent;
import htmlHelper.tools.AnimateTimer; 
import trilateral.tri.Triangle;
import TrilateralTest;
import shaders.Shaders;
import geom.Matrix4x3;
using htmlHelper.webgl.WebGLSetup;
class Main extends WebGLSetup {
    var webgl:          WebGLSetup;
    var trilateralTest: TrilateralTest;
    var scale:          Float;
    var modelViewProjection: Matrix4x3;
    var omegaX          = 0.;
    var omegaY          = Math.PI/2;
    public static function main(){ new Main(); }
    public inline static var stageRadius: Int = 600;
    public function new(){
        super( stageRadius, stageRadius );
        DEPTH_TEST = false;
        BACK = false;
        scale = 1/(stageRadius);
        darkBackground();
        modelViewProjection = Matrix4x3.unit();
        setupProgram( Shaders.vertex, Shaders.fragment );
        trilateralTest =  new TrilateralTest( stageRadius );
        trilateralTest.setup();
        setTriangles( trilateralTest.triangles, cast trilateralTest.appColors );
        setAnimate();
    }
    public inline
    function setAnimate(){
        AnimateTimer.create();
        AnimateTimer.onFrame = render_;
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
        var modelViewProjection = spin();
        modelViewProjection.toFloat32Array( matrix32Array );
        render();

    }
    override public 
    function render(){
        super.render();
    }
    inline function spin(): Matrix4x3 {
        omegaX += Math.PI/100;
        var rz = Matrix4x3.radianZ( omegaX - Math.PI/2 );
        var ry = Matrix4x3.radianY( omegaX - Math.PI/2 );
        var rx = Matrix4x3.radianX( omegaX - Math.PI/2 );
        return rx * ry * rz;
    }
}