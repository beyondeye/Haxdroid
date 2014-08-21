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
class TestContainersAndroidControls extends TestCase
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
	
	public function testScrollView()
	{
		var androidxml = resloader.getLayout("@layout/scrollview.xml");		
		var convertedxml = converter.processXml(androidxml);
		assertTrue(converter.logger.warningCount == 0 && converter.logger.errorCount == 0);
		var res = convertedxml.toString();
		assertTrue(CompareTools.match_ignoreblanks(res,
		"<vbox percentWidth=\"100\" percentHeight=\"100\"><scrollview width=\"120\" height=\"120\" id=\"scrollView1\"><vbox percentWidth=\"100\" percentHeight=\"100\" id=\"linearLayout1\"><button text=\"1\" width=\"80\" autoSize=\"true\"/><button text=\"2\" width=\"80\" autoSize=\"true\"/><button text=\"3\" width=\"80\" autoSize=\"true\"/><button text=\"4\" width=\"80\" autoSize=\"true\"/><button text=\"5\" width=\"80\" autoSize=\"true\"/><button text=\"6\" width=\"80\" autoSize=\"true\"/></vbox></scrollview></vbox>"));		
	}	
	public function testLayoutGravity()
	{
		var androidxml = resloader.getLayout("@layout/gravitytestlayout.xml");		
		var convertedxml = converter.processXml(androidxml);
		assertTrue(converter.logger.warningCount == 2 && converter.logger.errorCount == 0); //warnings because of android:gravity attributes, not yet supported
		var res = convertedxml.toString();
		assertTrue(CompareTools.match_ignoreblanks(res,
		"<vbox percentWidth=\"100\" percentHeight=\"100\" style=\"backgroundColor: 0x666666\"><text text=\"Linear Layout - horizontal, gravity=center\" style=\"color: 0xffffff;paddingTop: 2;paddingBottom: 2;paddingLeft: 2;paddingRight: 2\" percentWidth=\"100\" autoSize=\"true\"/><hbox percentWidth=\"100\" height=\"200\" style=\"backgroundColor: 0xeeeeee\"><button text=\"top\" autoSize=\"true\" verticalAlign=\"top\" id=\"Button01\"/><button text=\"center\" autoSize=\"true\" verticalAlign=\"center\" id=\"Button02\"/><button text=\"bottom\" autoSize=\"true\" verticalAlign=\"bottom\" id=\"Button03\"/></hbox><text text=\"Linear Layout - vertical, gravity=center\" style=\"color: 0xffffff;paddingTop: 2;paddingBottom: 2;paddingLeft: 2;paddingRight: 2\" percentWidth=\"100\" autoSize=\"true\"/><vbox percentWidth=\"100\" height=\"200\" style=\"backgroundColor: 0xdddddd\"><button text=\"left\" autoSize=\"true\" horizontalAlign=\"left\" id=\"Button04\"/><button text=\"center\" autoSize=\"true\" horizontalAlign=\"center\" id=\"Button05\"/><button text=\"right\" autoSize=\"true\" horizontalAlign=\"right\" id=\"Button06\"/></vbox></vbox>"));		
	}		
}