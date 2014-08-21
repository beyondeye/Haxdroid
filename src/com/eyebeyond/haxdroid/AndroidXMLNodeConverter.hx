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
	private var _srcNode:Xml;
	private var _dstParentNode:Xml;
	public function new(resloader:AndroidResourceLoader,logger:IConverterLogger=null) 
	{
		if (logger == null) logger = new DefaultConverterLogger();
		super(resloader, logger);
		_attrconverter = new AndroidXMLAttributesConverter(resloader, logger);
	}
	public function process(srcNode:Xml,dstParentNode:Xml):Xml
	{
	    var dstNode:Xml = null;
		_dstParentNode=dstParentNode;
		_srcNode = srcNode;
//		node.remove("xmlns:android"); //remove android namespace, it will only complicate parsing
		var srcNodeName:String = srcNode.nodeName; //note:  Android XML Layout is case sensitive!
		dstNode =
			switch(srcNodeName)
			{
				case "LinearLayout":
					processAndroidLinearLayout();
				case "Button":
					processAndroidButton();
				case "TextView":
					processAndroidTextView();
				case "EditText":
					processAndroidEditText();
				case "CheckBox":
					processAndroidCheckBox();	
				case "ImageView":
					processAndroidImageView();	
				case "ScrollView":
					processAndroidScrollView();		
				default:
					_logger.warning("unsupported android widget: " + _srcNode.nodeName);
					null;			
			}
		if (dstNode != null) _attrconverter.processCommonWidgetAttributes();
		return dstNode;
	}
	
	private function setAttrConverterParams(dstNode:Xml)
	{
		_attrconverter.setParams(_srcNode, dstNode,_dstParentNode);
	}
	

	private function processAndroidEditText():Xml 
	{
		var res:Xml = Xml.createElement("textinput");
		setAttrConverterParams(res);
		
		_attrconverter.processCommonTextAttributes();
		_attrconverter.processAndroidHintAttribute();
		return res;		
	}	
	
	

	private function processAndroidTextView():Xml 
	{
		var res:Xml = Xml.createElement("text");
		setAttrConverterParams(res);

		_attrconverter.processCommonTextAttributes();
		_attrconverter.processAndroidHintAttributeForText();
		return res;		
	}	


	
	private function processAndroidCheckBox( ):Xml 
	{
		var res:Xml = Xml.createElement("checkbox");
		setAttrConverterParams(res);

		_attrconverter.processCommonTextAttributes();

		_attrconverter.processAndroidHintAttributeForText();
		
		_attrconverter.processAndroidCheckedAttribute();
		
		_attrconverter.processAndroidButtonAttribute();
		return res;
	}	
	
	private function processAndroidImageView( ):Xml 
	{
		var res:Xml = Xml.createElement("image");
		setAttrConverterParams(res);
		
		_attrconverter.processAndroidSrcAttribute();
		_attrconverter.processAndroidScaleTypeAttribute();
		return res;
	}		
	private function processAndroidScrollView( ):Xml 
	{
		var res:Xml = Xml.createElement("scrollview");
		setAttrConverterParams(res);
		
		return res;
	}		
	
	private function processAndroidButton( ):Xml 
	{		
		var res:Xml = Xml.createElement("button");
		setAttrConverterParams(res);
		
		_attrconverter.processTextAttribute();
		return res;		
	}

	
	private function processAndroidLinearLayout( ):Xml 
	{
		var or = popAttribute(_srcNode,"android:orientation");
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
			
		setAttrConverterParams(res);
		// TODO: add here conversion of additional attributes for LinearLayout
	
		return res;
	}
}