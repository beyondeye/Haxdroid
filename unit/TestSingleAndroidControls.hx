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
class TestSingleAndroidControls extends TestCase
{
	var resloader:AndroidResourceLoader;
	var converter:AndroidXMLConverter;
	public override function setup():Void 
	{
		super.setup();
		// TODO: add here initialization to do before starting tests
		resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("LanguageAndRegion", "it"); //config change automatically trigger rebuild of string resource buffer
		resloader.androidDeviceConfiguration.setConfiguration("ScreenPixelDensity", "xhdpi");
		converter = new AndroidXMLConverter(resloader);
	}
	public override function tearDown():Void
	{
		super.tearDown();
		// TODO: add here code to run when test finished (deallocations, etc.)
	}
	public function testSingleButtonWithInlineDims()
	{
		var androidxml = resloader.getLayout("@layout/onebutton_with_inline_dims.xml");		
		var convertedxml = converter.processXml(androidxml);
		assertTrue(converter.logger.warningCount == 0 && converter.logger.errorCount == 0);
		var res = convertedxml.toString();
		assertTrue(CompareTools.match_ignoreblanks(res,
		"<vbox percentWidth=\"100\" percentHeight=\"100\"><button text=\"Ciao Mondo!\" width=\"200\" height=\"100\" id=\"myButton\"/></vbox>"));		
	}	
	public function testSingleButtonWithDims()
	{
		var androidxml = resloader.getLayout("@layout/onebutton_with_dims.xml");		
		var convertedxml = converter.processXml(androidxml);
		assertTrue(converter.logger.warningCount == 0 && converter.logger.errorCount == 0);
		var res = convertedxml.toString();
		assertTrue(CompareTools.match_ignoreblanks(res,
		"<vbox percentWidth=\"100\" percentHeight=\"100\"><button text=\"Ciao Mondo!\" width=\"200\" height=\"50\" id=\"myButton\"/></vbox>"));		
	}
	public function testSingleButton()
	{
		var androidxml = resloader.getLayout("@layout/onebutton.xml");		
		var convertedxml = converter.processXml(androidxml);
		assertTrue(converter.logger.warningCount == 0 && converter.logger.errorCount == 0);
		var res = convertedxml.toString();
		assertTrue(CompareTools.match_ignoreblanks(res,
		"<vbox percentWidth=\"100\" percentHeight=\"100\"><button text=\"Ciao Mondo!\" percentWidth=\"100\" autoSize=\"true\" id=\"myButton\"/></vbox>"));		
	}	
	
}



