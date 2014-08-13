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
class TestAndroidResourceLoader extends TestCase
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
	public function testGetDrawableResource():Void
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("ScreenPixelDensity", "hdpi");

		var img_path = resloader.resolveResource("drawable", "arrow_left");
		assertEquals(img_path, "androidres/drawable-hdpi/arrow_left.png");
	}
	public function testGetDrawableResourceInexactPixelDensityMatch():Void
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("ScreenPixelDensity", "ldpi");

		var img_path = resloader.resolveResource("drawable", "arrow_left");
		assertEquals(img_path, "androidres/drawable-mdpi/arrow_left.png"); //best match is this, since no ldpi version exists
	}	
	public function testGetDrawableResourceBuffered()
	{
		var resloader = spy(AndroidResourceLoader); //Mockatoo.spy
		resloader.androidDeviceConfiguration.setConfiguration("ScreenPixelDensity", "hdpi");
		var img_path = resloader.resolveResource("drawable", "arrow_left");		
		var img_path2 = resloader.resolveResource("drawable", "arrow_left");
		resloader.getAllCompatibleResources("drawable", "arrow_left").verify(times(1)); //called only once, because second time obtained through  _loaderBuffer.getBufferedMatchedResourceName
		assertEquals(img_path, "androidres/drawable-hdpi/arrow_left.png");
		assertEquals(img_path, img_path2);
	}
	public function testGetLocalizedValues()
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("ScreenOrientation", "land");
		resloader.androidDeviceConfiguration.setConfiguration("LanguageAndRegion", "es");
		var values_path = resloader.resolveResource("values", "strings.xml");			
		assertEquals(values_path, "androidres/values-es-land/strings.xml");
	}	
	public function testGetLocalizedString()
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("ScreenOrientation", "land");
		resloader.androidDeviceConfiguration.setConfiguration("LanguageAndRegion", "es");
		var hellostring = resloader.getString("@string/hello");			
		assertEquals(hellostring, "Hola Mundo (es-land)!");
	}	
	public function testGetLocalizedStringAfterConfigChange()
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("ScreenOrientation", "land");
		resloader.androidDeviceConfiguration.setConfiguration("LanguageAndRegion", "es");
		var hellostring = resloader.getString("@string/hello");			
		assertEquals(hellostring, "Hola Mundo (es-land)!");
		resloader.androidDeviceConfiguration.setConfiguration("LanguageAndRegion", "it"); //config change automatically trigger rebuild of string resource buffer
		var hellostring_it = resloader.getString("@string/hello");			
		assertEquals(hellostring_it, "Ciao Mondo!");		
	}		
	
}


