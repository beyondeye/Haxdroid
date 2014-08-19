package com.eyebeyond.haxdroid;
import haxe.xml.Parser.parse;
import Xml;
import com.eyebeyond.haxdroid.XMLConverterHelperMethods.*;
/**
 * ...
 * @author dario
 */
class AndroidXMLNodeConverter extends AndroidXMLConverterModule
{

	private var _attrconverter:AndroidXMLAttributesConverter;
	public function new(resloader:AndroidResourceLoader,logger:IConverterLogger=null) 
	{
		if (logger == null) logger = new DefaultConverterLogger();
		super(resloader, logger);
		_attrconverter = new AndroidXMLAttributesConverter(resloader, logger);
	}
	public function process(node:Xml):Xml
	{
	    var res:Xml = null;
//		node.remove("xmlns:android"); //remove android namespace, it will only complicate parsing
		var nodeName:String = node.nodeName; //note:  Android XML Layout is case sensitive!
		res =
			switch(nodeName)
			{
				case "LinearLayout":
					processAndroidLinearLayout(node);
				case "Button":
					processAndroidButton(node);
				case "TextView":
					processAndroidTextView(node);
				case "EditText":
					processAndroidEditText(node);
				case "CheckBox":
					processAndroidCheckBox(node);	
				case "ImageView":
					processAndroidImageView(node);						
				default:
					_logger.warning("unsupported android widget: " + node.nodeName);
					null;			
			}
		if (res != null) _attrconverter.processCommonWidgetAttributes();
		return res;
	}
	

	

	private function processAndroidEditText( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("textinput");
		_attrconverter.setSourceAndDest(node, res);
		
		_attrconverter.processCommonTextAttributes();
		_attrconverter.processAndroidHintAttribute();
		return res;		
	}	
	
	
	private function processAndroidTextView( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("text");
		_attrconverter.setSourceAndDest(node, res);

		_attrconverter.processCommonTextAttributes();
		_attrconverter.processAndroidHintAttributeForText();
		return res;		
	}	


	
	private function processAndroidCheckBox( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("checkbox");
		_attrconverter.setSourceAndDest(node, res);

		_attrconverter.processCommonTextAttributes();

		_attrconverter.processAndroidHintAttributeForText();
		
		_attrconverter.processAndroidCheckedAttribute();
		
		_attrconverter.processAndroidButtonAttribute();
		return res;
	}	
	
	private function processAndroidImageView( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("image");
		_attrconverter.setSourceAndDest(node,res);
		
		_attrconverter.processAndroidSrcAttribute();
		_attrconverter.processAndroidScaleTypeAttribute();
		return res;
	}		
	
	private function processAndroidButton( node:Xml ):Xml 
	{		
		var res:Xml = Xml.createElement("button");
		_attrconverter.setSourceAndDest(node,res);
		
		_attrconverter.processTextAttribute();
		return res;		
	}

	
	private function processAndroidLinearLayout( node:Xml ):Xml 
	{
		var or = popAttribute(node,"android:orientation");
		var res:Xml = 
			switch( or)
			{
				case "vertical":
					Xml.createElement("vbox");
				case "horizontal":
					Xml.createElement("hbox");
				default:
					_logger.warning("LinearLayout: unknown android:orientation=" + or);
					null;
			}	
			
		_attrconverter.setSourceAndDest(node, res); 
		// TODO: add here conversion of additional attributes for LinearLayout
	
		return res;
	}
}