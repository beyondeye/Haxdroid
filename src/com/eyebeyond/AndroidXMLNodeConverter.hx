package com.eyebeyond;
import haxe.xml.Parser.parse;
import Xml;

/**
 * ...
 * @author dario
 */
class AndroidXMLNodeConverter
{
	private var _resloader:AndroidResourceLoader;
	private var _logger:IConverterLogger = null;
	public function new(resloader:AndroidResourceLoader,logger:IConverterLogger=null) 
	{
		_resloader = resloader;
		_logger = logger;
		if (_logger == null) _logger = new DefaultConverterLogger();
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
				default:
					_logger.warning("unsupported android widget: " + node.nodeName);
					null;			
			}
		if (res != null) processCommonWidgetAttributes(node, res);
		return res;
	}
	
	private function processCommonWidgetAttributes(srcWidget:Xml, dstWidget:Xml ):Void
	{
		if (dstWidget == null) return;
		var attrVal:String;
		var converted_attrs:Map<String,String> = null;
		//----
		attrVal = popAttribute(srcWidget, "android:layout_width");
		converted_attrs = convertWidth(attrVal);
		addAttributes(dstWidget, converted_attrs);				
		//----
		attrVal = popAttribute(srcWidget, "android:layout_height");
		converted_attrs = convertHeight(attrVal);
		addAttributes(dstWidget, converted_attrs);	
		//----
		attrVal = popAttribute(srcWidget, "android:id");
		converted_attrs = convertId(attrVal);
		addAttributes(dstWidget, converted_attrs);	

			
		// TODO: this way of looping on attributes, is not so good, I should get attrname and attrval at the same time!
		for (attrname in srcWidget.attributes())
		{
			if (StringTools.startsWith(attrname, "xmlns:")) 	continue;
			_logger.warning('Do not know how to process attribute of widget ${srcWidget.nodeName}: ${attrname}');
		}
	}

	private function processAndroidButton( node:Xml ):Xml 
	{
		
		var res:Xml = Xml.createElement("button");

		var astr = popAttribute(node, "android:text");
		var text = _resloader.getString(astr);
		res.set("text", text);
		var  converted_attrs:Map<String,String> = null;
		for (attrname in node.attributes())
		{

				
		}

			
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
			var  converted_attrs:Map<String,String> = null;
			for (attrname in node.attributes())
			{

					
			}
//    android:paddingLeft="16dp"
//    android:paddingRight="16dp"
			
			
		return res;
	}
	
	private function convertWidth(value:String):Map<String,String>
	{
		if (value == null) return null;
		var res = new Map<String,String>();
		switch(value)
		{
			case "match_parent", "fill_parent":
				res["percentWidth"] = "100";
			case "wrap_content":
				res["autoSize"] = "true";
			default:
				res["Width"]= Std.string(_resloader.getDimensionPixelSize(value));
		}	
		return res;
	}

	private function convertHeight(value:String):Map<String,String>
	{
		if (value == null) return null;
		var res = new Map<String,String>();
		switch(value)
		{
			case "match_parent", "fill_parent":
				res["percentHeight"] = "100";
			case "wrap_content":
				res["autoSize"] = "true";
			default:
				res["Height"]= Std.string(_resloader.getDimensionPixelSize(value));
		}	
		return res;
	}
	private function convertId(value:String):Map<String,String>
	{
		if (value == null) return null;
		var res = new Map<String,String>();
		// TODO: perhaps I should use direct string operations instead of REGEX  for better performance
		var rgx = ~/^@\+id\//; //new id definition syntax: "@+id/myid"
		if (!rgx.match(value))
		{
			_logger.error('unrecognized android:id format ${value}');
			rgx = ~/^@id\//; //"@id/"
			if (rgx.match(value))
				_logger.info('perhaps you meant @+id/${rgx.matchedRight()}?');
		}
		else
		{
			res["id"] = rgx.matchedRight();
		}	
		return res;
	}

	
	// TODO: implement this using Haxe mixin feature (syntax extension for Xml object)
	private static function addAttributes(node:Xml, attrs:Map<String,String>):Void
	{
		if (attrs == null) return;
		// TODO: the following way of accessing the list of converted_attrs seems to me extremely inefficient
		for (attrname in attrs.keys())
		{
			node.set(attrname, attrs.get(attrname));
		}		
	}

	// TODO: implement this using Haxe mixin feature (syntax extension for Xml object)
	private static function popAttribute(node:Xml, attrname:String):String
	{
		var res:String = node.get(attrname);
		if (res != null) node.remove(attrname);
		return res;			
	}
		
	


	
}