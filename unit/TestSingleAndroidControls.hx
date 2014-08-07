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
class TestSingleAndroidControls extends TestCase
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
	public function testSingleButton()
	{
		var resloader = new AndroidResourceLoader();
		resloader.androidDeviceConfiguration.setConfiguration("LanguageAndRegion", "it"); //config change automatically trigger rebuild of string resource buffer
		var androidxml = resloader.getLayout("onebutton.xml");		
		var converter = new AndroidXMLConverter(resloader);
		var convertedxml = converter.processXml(androidxml);
		assertTrue(converter.logger.warningCount == 0 && converter.logger.errorCount == 0);
		assertTrue(CompareTools.match_ignoreblanks(convertedxml.toString(),
		"<vbox percentWidth=\"100\" percentHeight=\"100\"><button text=\"Ciao Mondo!\" percentWidth=\"100\" autoSize=\"true\" id=\"myButton\"/></vbox>"));		
	}
	
}



