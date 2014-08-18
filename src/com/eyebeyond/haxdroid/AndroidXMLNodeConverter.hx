package com.eyebeyond.haxdroid;
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
				case "TextView":
					processAndroidTextView(node);
				case "EditText":
					processAndroidEditText(node);
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
		//----
		attrVal = popAttribute(srcWidget, "android:enabled");
		converted_attrs = convertEnabled(attrVal);
		addAttributes(dstWidget, converted_attrs);
		
		processBackgroundAttribute(srcWidget, dstWidget);
		processAlphaAttribute(srcWidget, dstWidget); // TODO: this is a more general attribute, of stylable widgets
			
		// TODO: this way of looping on attributes, is not so good, I should get attrname and attrval at the same time!
		for (attrname in srcWidget.attributes())
		{
			if (StringTools.startsWith(attrname, "xmlns:")) 	continue;
			unknownAttribute(srcWidget, attrname);
		}
	}

	private function unknownAttribute(widget:Xml, attrname:String, attrval:String=null):Void
	{
		if(attrval!=null)
			_logger.warning('Do not know how to process attribute of widget ${widget.nodeName}: $attrname=$attrval');
		else
			_logger.warning('Do not know how to process attribute of widget ${widget.nodeName}: $attrname');
	}

	
	
	private function processTextAttribute(srcnode:Xml, res:Xml):Void
	{
		var astr = popAttribute(srcnode, "android:text");
		if (astr != null)
		{
			var text = _resloader.getString(astr);
			res.set("text", text);			
		}
	
	}

	private function processTextColorAttribute(srcnode:Xml, res:Xml):Void
	{
		var cstr = popAttribute(srcnode, "android:textColor");
		if (cstr != null)
		{
			var color=_resloader.getColorObject(cstr);
			addHaxeUIStyle(res, "color", color.color());
		}		
	}
	
	private function processAlphaAttribute(srcnode:Xml, res:Xml):Void
	{
		var astr = popAttribute(srcnode, "android:alpha");
		if (astr != null)
		{
			addHaxeUIStyle(res, "alpha", astr);
		}		
	}	
	
	private function processBackgroundAttribute(srcnode:Xml, res:Xml):Void
	{
		var attrname = "android:background";
		var attrval = popAttribute(srcnode, attrname);
		if (attrval != null)
		{
			var color = _resloader.getColorObject(attrval); //is it a color?
			if(color!=null) 
			{
				addHaxeUIStyle(res, "backgroundColor", color.color());
				return;
			}
			var dpath = _resloader.resolveDrawable(attrval); //is it a drawable?
			if (dpath != null)
			{	
				addHaxeUIStyle(res, "backgroundImage", dpath);
				return;
			}
			//other type of android:background, not yet supported
			unknownAttribute(srcnode, attrname, attrval);
		}		
	}		
	
	function processTextAlignmentAttribute(srcnode:Xml,res:Xml):Void 
	{
		var attrname = "android:textAlignment";
		var alignstr = popAttribute(srcnode, attrname);
		if (alignstr != null)
		{
			var dstalignstr:String =
			switch(alignstr)
			{
				case "center":
					"center";
				case "inherit":
					unknownAttribute(srcnode, attrname, alignstr);
					"";
				case "gravity":
					unknownAttribute(srcnode, attrname, alignstr);
					"";
				case "textStart":
					unknownAttribute(srcnode, attrname, alignstr);
					"";
				case "textEnd":
					unknownAttribute(srcnode, attrname, alignstr);
					"";
				case "viewStart":
					unknownAttribute(srcnode, attrname, alignstr);						
					"";
				case "viewEnd":
					unknownAttribute(srcnode, attrname, alignstr);
					"";
				default:
					unknownAttribute(srcnode, attrname, alignstr);						
					"";
			}
			if(dstalignstr.length>0)
				res.set("textAlign", dstalignstr);
		}		
	}

	private function processCommonTextAttributes(srcnode:Xml , res:Xml):Void 
	{
		processTextAttribute(srcnode, res);
		processTextColorAttribute(srcnode, res);
		processTextAlignmentAttribute(srcnode,res);		
	}
	
	private function processAndroidEditText( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("textinput");

		processCommonTextAttributes(node , res);

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

		processCommonTextAttributes(node,res);

		var astr = res.get("text"); //get text if already defined
		var hintstr = popAttribute(node, "android:hint");
		if (hintstr != null && (astr == null || astr.length == 0))
		{ //use hint, if text not defined
			var text = _resloader.getString(hintstr);
			res.set("text", text);						
		}			
		return res;		
	}	
	
	private function processAndroidButton( node:Xml ):Xml 
	{		
		var res:Xml = Xml.createElement("button");
		processTextAttribute(node , res);
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
				res["width"]= Std.string(_resloader.getDimensionPixelSize(value));
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
				res["height"]= Std.string(_resloader.getDimensionPixelSize(value));
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
	
	private function convertEnabled(value:String):Map<String,String>
	{
		if (value == null) return null;
		var res = new Map<String,String>();
		switch(value)
		{
			case "true":
//				res["disabled"] = "false";
			case "false":
				res["disabled"] = "true";
			default:
				_logger.error('unrecognized android:enabled  value ${value}');
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
	

	// TODO: add check that the same style not added twice?
	private static function addHaxeUIStyle(node:Xml, styleName:String, styleValue:String):Void
	{
		var curstyles = node.get("style");
		var newstyle = '$styleName: $styleValue';
		var allstyles=
			if (curstyles != null)
				curstyles + ';' + newstyle;
			else
				newstyle;
		node.set("style", allstyles);
	}
	

	


	
}