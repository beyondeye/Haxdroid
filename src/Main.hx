package  ;

import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.themes.GradientTheme;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.style.StyleManager;
import haxe.ui.toolkit.style.Style;
import haxe.unit.TestResult;

import com.eyebeyond.haxdroid.AndroidResourceLoader;
import com.eyebeyond.haxdroid.AndroidXMLConverter;
import com.eyebeyond.haxdroid.AndroidDeviceConfiguration;
import openfl.Assets;

class Main {
    public static function main() {
		UnitTestsRunner.runTests();
		testConvertButton();
	}

	static private function testConvertButton():Void 
	{		
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		
		//basically, the meaning of this is initialize main activity
        Toolkit.openFullscreen(function(root:Root) {
			var resloader = new AndroidResourceLoader();
			resloader.androidDeviceConfiguration.setConfigurationForDesktopPC();
			var androidxml = resloader.getLayout("@layout/oneimage.xml");
			//..parse each object, 
			//..create an xml element for each converted object
			//serialize to file
//			var thepath = openfl.Assets.getPath("strings.xml");
//			trace(thepath);
			var converter = new AndroidXMLConverter(resloader);
 			var convertedxml = converter.processXml(androidxml);
			trace(convertedxml);
			var view = Toolkit.processXml(convertedxml);
			root.addChild(view);
     });
	}
	//http://haxeui.org/wiki/en/Styling
	static private function testGUI7():Void 
	{ 
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		UnitTestsRunner.runTests();
		//basically, the meaning of this is initialize main activity
        Toolkit.openFullscreen(function(root:Root) {
			var view = Toolkit.processXmlResource("assets/styled-buttons-with-inline-style.xml"); //read button definition from xml file
			root.addChild(view);
     });
	}	


	//http://haxeui.org/wiki/en/Styling
	static private function testGUI6():Void 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		
		//basically, the meaning of this is initialize main activity
        Toolkit.openFullscreen(function(root:Root) {
			var view = Toolkit.processXmlResource("assets/styled-buttons.xml"); //read button definition from xml file
			root.addChild(view);
     });
	}		
	
	//http://haxeui.org/wiki/en/Styling
	static private function testGUI5():Void 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		
		//basically, the meaning of this is initialize main activity
        Toolkit.openFullscreen(function(root:Root) {
            StyleManager.instance.addStyle("Button.myStyle, .myStyle, #myButton, #myButton.myStyle", new Style({
                width: 150,
                height: 100,
                color: 0xFF00FF,
                icon: "assets/fav_32.png",
                iconPosition: "top",
            }));
             
            var hbox:HBox = new HBox();
            hbox.x = 10;
            hbox.y = 10;
             
            var button:Button = new Button();
            button.text = "Normal";
            hbox.addChild(button);
 
            var button:Button = new Button();
            button.text = "#myButton";
            button.id = "myButton";
            hbox.addChild(button);
 
            var button:Button = new Button();
            button.text = ".myStyle";
            button.styleName = "myStyle";
            hbox.addChild(button);
 
            var button:Button = new Button();
            button.text = "myButton.myStyle";
            button.id = "myButton";
            button.styleName = "myStyle";
            hbox.addChild(button);
             
            root.addChild(hbox);
     });
	}	
	
	//http://haxeui.org/wiki/en/Styling	
	static private function testGUI4():Void 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		//basically, the meaning of this is initialize main activity
		Toolkit.openFullscreen(
			function (root:Root)
			{
				var button = new Button();
				button.x = 100;
				button.y = 100;
				button.style.width = 150;
				button.style.height = 100;
				button.style.color = 0xFF00FF;
				button.style.icon = "assets/fav_32.png";
				button.style.iconPosition = "top";
				button.text = "Styled";				
				root.addChild(button);						
			}
		);
	}		
	
	static private function testGUI3():Void 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		//basically, the meaning of this is initialize main activity
		Toolkit.openFullscreen(
			function (root:Root)
			{
				var view = Toolkit.processXmlResource("assets/scroll-view.xml"); //read button definition from xml file
				root.addChild(view);						
			}
		);
	}	
	
	static private function testGUI2():Void 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		//basically, the meaning of this is initialize main activity
		Toolkit.openFullscreen(
			function (root:Root)
			{
				var button:Button = Toolkit.processXmlResource("assets/button.xml"); //read button definition from xml file
				button.addEventListener(UIEvent.CLICK, function(e:UIEvent) {
				   e.component.text = "You clicked me!";
				});
				root.addChild(button);						
			}
		);
	}
	
	static private function testGUI1():Void 
	{
		Toolkit.theme = new GradientTheme();
		Toolkit.init(); //initialize HaxeUI
		
		//basically, the meaning of this is initialize main activity
		Toolkit.openFullscreen(
			function (root:Root)
			{
				var button:Button = new Button();
				button.text = "Click Me!";
				button.x = 100;
				button.y = 100;
				button.addEventListener(UIEvent.CLICK, function(e:UIEvent) {
				   e.component.text = "You clicked me!";
				});
				root.addChild(button);						
			}
		);
	}	
}