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
	public function processWidthAttribute(srcnode:Xml, res:Xml):Void
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

	public function processHeightAttribute(srcnode:Xml, res:Xml):Void
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
	
	public function processEnabledAttribute(srcnode:Xml, res:Xml):Void
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
	public function processIdAttribute(srcnode:Xml, res:Xml):Void
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
	
	public function processAlphaAttribute(srcnode:Xml, res:Xml):Void
	{
		var astr = popAttribute(srcnode, "android:alpha");
		if (astr != null)
		{
			addHaxeUIStyle(res, "alpha", astr);
		}		
	}	
	
	public function processBackgroundAttribute(srcnode:Xml, res:Xml):Void
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
	
	public function processTextAttribute(srcnode:Xml, res:Xml):Void
	{
		var astr = popAttribute(srcnode, "android:text");
		if (astr != null)
		{
			var text = _resloader.getString(astr);
			res.set("text", text);			
		}
	
	}


	public function processTextColorAttribute(srcnode:Xml, res:Xml):Void
	{
		var cstr = popAttribute(srcnode, "android:textColor");
		if (cstr != null)
		{
			var color=_resloader.getColorObject(cstr);
			addHaxeUIStyle(res, "color", color.color());
		}		
	}
	
	
	public function processTextAlignmentAttribute(srcnode:Xml,res:Xml):Void 
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

	public function processCommonTextAttributes(srcnode:Xml , res:Xml):Void 
	{
		processTextAttribute(srcnode, res);
		processTextColorAttribute(srcnode, res);
		processTextAlignmentAttribute(srcnode,res);		
	}
	public function processAndroidHintAttributeForText( node:Xml,res:Xml):Void 
	{
		var astr = res.get("text"); //get text if already defined
		var hintstr = popAttribute(node, "android:hint");
		if (hintstr != null && (astr == null || astr.length == 0))
		{ //use hint, if text not defined
			var text = _resloader.getString(hintstr);
			res.set("text", text);						
		}			
	}		
	
	public function processAndroidCheckedAttribute(node:Xml,res:Xml):Void 
	{
		var checkedstr = popAttribute(node, "android:checked");
		if (checkedstr != null)
		{
			switch(checkedstr)
			{
				case "true", "false":
					res.set("selected", checkedstr);
				default:
					unknownAttribute(node, "checked", checkedstr);
			}
		}
	}	
	
	/**
	 * android attribute that defines the icon to be used for the checkbox
	 */
	public function processAndroidButtonAttribute(node:Xml,res:Xml):Void 
	{
		var attrname = "android:button";
		var bstr = popAttribute(node, attrname);
		if (bstr == null) return;
		var iconstr = _resloader.resolveDrawable(bstr);
		if (iconstr == null)
		{ //cannot resolve icon
			errorResolvingResource(node, attrname, bstr);
			return;
		}
		unsupportedHaxeUIFeature(node, attrname);
//		addHaxeUIStyle(res, "icon", iconstr);
	}	
	
	public function processAndroidSrcAttribute(node:Xml,res:Xml):Void 
	{
		var attrname = "android:src";
		var srcstr = popAttribute(node, attrname);
		if (srcstr == null) 
		{
			//todo: add warning?
			return;		
		}
		var imagestr = _resloader.resolveDrawable(srcstr);
		if (imagestr == null)
		{ //cannot resolve image
			errorResolvingResource(node, attrname, imagestr);
			return;
		}		
		res.set("resource", imagestr);
	}
	
	public function processAndroidScaleTypeAttribute(node:Xml,res:Xml):Void 
	{
		var attrname = "android:scaleType";
		var ststr = popAttribute(node, attrname);
		if (ststr == null) return; 
		switch(ststr)
		{
			case "matrix": //Scale using the image matrix when drawing. The image matrix can be set using setImageMatrix(Matrix). From XML, use this syntax: android:scaleType="matrix". 
				unsupportedHaxeUIFeature(node, attrname);
			case "fitXY": //scale the image using FILL:Scale in X and Y independently, so that src matches dst exactly. This may change the aspect ratio of the src
				res.set("stretch", "true");
			case "fitStart": //scale the image using START: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. START aligns the result to the left and top edges of dst. 
				unsupportedHaxeUIFeature(node, attrname);
			case "fitCenter": //scale the image using CENTER: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. The result is centered inside dst. 
				unsupportedHaxeUIFeature(node, attrname);
			case "fitEnd": //scale the image using END: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. END aligns the result to the right and bottom edges of dst. 
				unsupportedHaxeUIFeature(node, attrname);
			case "center": //Center the image in the view, but perform no scaling. 
				unsupportedHaxeUIFeature(node, attrname);
			case "centerCrop": //Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or larger than the corresponding dimension of the view (minus padding). 
				unsupportedHaxeUIFeature(node, attrname);
			case "centerinside":	//Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or less than the corresponding dimension of the view (minus padding). 	
				unsupportedHaxeUIFeature(node, attrname);
			default:
				unknownAttribute(node, attrname, ststr);
		}
	}
		
}