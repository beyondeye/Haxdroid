package ;
import haxe.unit.*;
import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

import com.eyebeyond.haxdroid.AndroidResourceLoader;
import com.eyebeyond.haxdroid.AndroidXMLConverter;
import com.eyebeyond.haxdroid.AndroidDeviceConfiguration;

/**
 * ...
 * @author dario
 */
@:access(com.eyebeyond.haxdroid.AndroidResourceLoader) ////force access to private methods of AndroidResourceLoader from this class, for allowing work with mockatoo
class TestDimenResources  extends TestCase
{
	public override function setup():Void 
	{
		super.setup();
		// TODO: add here initialization to do before starting tests
	}
	public override function tearDown():Void
	{
		super.tearDown();
		// TODO: add here code to run when test finished (deallocations, etc.)
	}
	
	public function testGetDimensionsRaw()
	{
		var resloader = new AndroidResourceLoader();
		
		var d = resloader.getDimensionObject("@dimen/button_ysize");			
		assertEquals(d.toString(), "25dp");
		d = resloader.getDimensionObject("@dimen/font_size");			
		assertEquals(d.toString(), "16sp");		
		d = resloader.getDimensionObject("@dimen/box_ysize");			
		assertEquals(d.toString(), "30px");		
		d = resloader.getDimensionObject("@dimen/ruler_size");			
		assertEquals(d.toString(), "25mm");		
		d = resloader.getDimensionObject("@dimen/ruler_inch_size");			
		assertEquals(d.toString(), "1in");		
		d = resloader.getDimensionObject("@dimen/oldfontsize");			
		assertEquals(d.toString(), "16pt");		
	}	
	public function testGetDimensions()
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("ScreenPixelDensity", "xhdpi"); //will give 2x scale factor for dp/px	
		var d = resloader.getDimension("@dimen/button_ysize");			
		assertEquals(d, 25*2 );
		d = resloader.getDimension("@dimen/font_size");			
		assertEquals(d, 16*2);		
		d = resloader.getDimension("@dimen/box_ysize");			
		assertEquals(d, 30);		
		d = resloader.getDimension("@dimen/ruler_size");
		var expectedt1000 = Math.round((25 * 2 *160 / 25.4)*1000);
		assertEquals(Math.round(d*1000), expectedt1000);		
		d = resloader.getDimension("@dimen/ruler_inch_size");			
		assertEquals(d, 2 * 160);		

		d = resloader.getDimension("@dimen/oldfontsize");	
		expectedt1000 = Math.round((16 * 320 / 72) * 1000);
		assertEquals(Math.round(d*1000), expectedt1000);		
		
	}	
	
}
