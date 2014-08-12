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
class TestColorResources extends TestCase
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
		var white256 = resloader.getColor("@color/white256");			
		assertEquals(white256, "0xffffff");
		var red256 = resloader.getColor("@color/red256");			
		assertEquals(red256, "0xff0000");
		var green256 = resloader.getColor("@color/green256");			
		assertEquals(green256, "0x00ff00");
		var blue256 = resloader.getColor("@color/blue256");			
		assertEquals(blue256, "0x0000ff");
		//---------
		//get color that actually has no alpha channel definition
		var blue_withalpha = resloader.getColorWithAlpha("@color/blue256");			
		assertEquals(blue_withalpha, "0xff0000ff");
		//-------------
		var translucent_red256 = resloader.getColorWithAlpha("@color/translucent_red256");			
		assertEquals(translucent_red256, "0x88ff0000");
		var translucent_red256_noalpha = resloader.getColor("@color/translucent_red256");			
		assertEquals(translucent_red256_noalpha, "0xff0000");
		//---------
		var red = resloader.getColor("@color/red");			
		assertEquals(red, "0xff0000");
		//get color that actually has no alpha channel definition
		var red_with_alpha = resloader.getColorWithAlpha("@color/red");			
		assertEquals(red_with_alpha, "0xffff0000");		
		//---------
		var translucent_red = resloader.getColor("@color/translucent_red");			
		assertEquals(translucent_red, "0xff0000");
		var translucent_red_with_alpha = resloader.getColorWithAlpha("@color/translucent_red");			
		assertEquals(translucent_red_with_alpha, "0x80ff0000");	
	}
	
}


