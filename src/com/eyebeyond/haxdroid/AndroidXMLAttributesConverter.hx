package com.eyebeyond.haxdroid;
import haxe.xml.Parser.parse;
import Xml;
import com.eyebeyond.haxdroid.XMLConverterHelperMethods.*;

/**
 * ...
 * @author dario
 */
class AndroidXMLAttributesConverter extends AndroidXMLConverterModule
{
	public function new(resloader:AndroidResourceLoader,logger:IConverterLogger) 
	{
		super(resloader, logger);
	}

	public function processCommonWidgetAttributes(srcWidget:Xml, dstWidget:Xml ):Void
	{
		if (dstWidget == null) return;

		processWidthAttribute(srcWidget, dstWidget);
		
		processHeightAttribute(srcWidget, dstWidget);
		
		processIdAttribute(srcWidget,dstWidget);

		processEnabledAttribute(srcWidget,dstWidget);
		
		processBackgroundAttribute(srcWidget, dstWidget);
		processAlphaAttribute(srcWidget, dstWidget); // TODO: this is a more general attribute, of stylable widgets
			
		// TODO: this way of looping on attributes, is not so good, I should get attrname and attrval at the same time!
		for (attrname in srcWidget.attributes())
		{
			if (StringTools.startsWith(attrname, "xmlns:")) 	continue;
			unknownAttribute(srcWidget, attrname);
		}
	}
	private function processWidthAttribute(srcnode:Xml, res:Xml):Void
	{
		var attrVal = popAttribute(srcnode, "android:layout_width");	
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "match_parent", "fill_parent":
				res.set("percentWidth", "100");
			case "wrap_content":
				res.set("autoSize","true");
			default:
				res.set("width",Std.string(_resloader.getDimensionPixelSize(attrVal)));
		}	
	}

	private function processHeightAttribute(srcnode:Xml, res:Xml):Void
	{
		var attrVal = popAttribute(srcnode, "android:layout_height");	
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "match_parent", "fill_parent":
				res.set("percentHeight", "100");
			case "wrap_content":
				res.set("autoSize", "true");
			default:
				res.set("height",Std.string(_resloader.getDimensionPixelSize(attrVal)));
		}	
	}
	
	private function processEnabledAttribute(srcnode:Xml, res:Xml):Void
	{
		var attrVal = popAttribute(srcnode, "android:enabled");		
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "true":
//				res.set("disabled", "false");
			case "false":
				res.set("disabled","true");
			default:
				_logger.error('unrecognized android:enabled  value ${attrVal}');
		}			
	}	
	private function processIdAttribute(srcnode:Xml, res:Xml):Void
	{
		var attrVal = popAttribute(srcnode, "android:id");
		if (attrVal == null) return ;
		// TODO: perhaps I should use direct string operations instead of REGEX  for better performance
		var rgx = ~/^@\+id\//; //new id definition syntax: "@+id/myid"
		if (!rgx.match(attrVal))
		{
			_logger.error('unrecognized android:id format ${attrVal}');
			rgx = ~/^@id\//; //"@id/"
			if (rgx.match(attrVal))
				_logger.info('perhaps you meant @+id/${rgx.matchedRight()}?');
		}
		else
		{
			res.set("id", rgx.matchedRight());
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
	
}