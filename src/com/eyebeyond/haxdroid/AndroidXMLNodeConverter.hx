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
		if (res != null) _attrconverter.processCommonWidgetAttributes(node, res);
		return res;
	}
	

	

	private function processAndroidEditText( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("textinput");

		_attrconverter.processCommonTextAttributes(node , res);

		var hintstr = popAttribute(node, "android:hint");
		if (hintstr != null)
		{
			var text = _resloader.getString(hintstr);
			res.set("placeholderText", text);						
		}
		return res;		
	}	
	
	
	private function processAndroidTextView( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("text");

		_attrconverter.processCommonTextAttributes(node,res);

		_attrconverter.processAndroidHintAttributeForText(node, res);
		return res;		
	}	


	
	private function processAndroidCheckBox( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("checkbox");

		_attrconverter.processCommonTextAttributes(node,res);

		_attrconverter.processAndroidHintAttributeForText(node, res);
		
		_attrconverter.processAndroidCheckedAttribute(node, res);
		
		_attrconverter.processAndroidButtonAttribute(node, res);
		return res;
	}	
	
	private function processAndroidImageView( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("image");
		
		_attrconverter.processAndroidSrcAttribute(node, res);
		_attrconverter.processAndroidScaleTypeAttribute(node, res);
		return res;
	}		
	
	private function processAndroidButton( node:Xml ):Xml 
	{		
		var res:Xml = Xml.createElement("button");
		_attrconverter.processTextAttribute(node , res);
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
		return res;
	}
	

	

	

	

	

	

	

	


	
}