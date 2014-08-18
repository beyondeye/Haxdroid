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
class TestSimpleResourceAliases extends TestCase
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
	public function testGetColorsMultipleFormats()
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("LanguageAndRegion", "it"); //config change automatically trigger rebuild of string resource buffer

		var blue_alias = resloader.getColor("@color/blue256alias");			
		assertEquals(blue_alias, "0x0000ff");
		
		var hi = resloader.getString("@string/hello_alias");
		assertEquals(hi, "Ciao Mondo!");
		
		var butsize = resloader.getDimensionObject("@dimen/button_ysize_alias");
		assertEquals(butsize.toString(), "25dp");		

	}
	
}


