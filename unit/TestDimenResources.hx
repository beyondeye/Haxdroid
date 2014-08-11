package ;
import haxe.unit.*;
import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;

import com.eyebeyond.AndroidResourceLoader;
import com.eyebeyond.AndroidXMLConverter;
import com.eyebeyond.AndroidDeviceConfiguration;

/**
 * ...
 * @author dario
 */
//force access to private methods of AndroidResourceLoader from this class, for allowing work with mockatoo
@:access(com.eyebeyond.AndroidResourceLoader)
class TestDimenResources  extends TestCase
{
	public override function setup():Void 
	{
		super.setup();
		//TODO add here initialization to do before starting tests
	}
	public override function tearDown():Void
	{
		super.tearDown();
		//TODO add here code to run when test finished (deallocations, etc.)
	}
	
	public function testGetColorsMultipleFormats()
	{
		var resloader = new AndroidResourceLoader();
		var d = resloader.getDimension("button_ysize");			
		assertEquals(d.toString(), "25dp");
		d = resloader.getDimension("font_size");			
		assertEquals(d.toString(), "16sp");		
		d = resloader.getDimension("box_ysize");			
		assertEquals(d.toString(), "30px");		
		d = resloader.getDimension("ruler_size");			
		assertEquals(d.toString(), "25mm");		
		d = resloader.getDimension("ruler_inch_size");			
		assertEquals(d.toString(), "1in");		
	}	
	
}
