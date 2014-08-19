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

	public function processCommonWidgetAttributes(srcNode:Xml, dstNode:Xml ):Void
	{
		if (dstNode == null) return;

		processWidthAttribute(srcNode, dstNode);
		
		processHeightAttribute(srcNode, dstNode);
		
		processIdAttribute(srcNode,dstNode);

		processEnabledAttribute(srcNode,dstNode);
		
		processBackgroundAttribute(srcNode, dstNode);
		processAlphaAttribute(srcNode, dstNode); // TODO: this is a more general attribute, of stylable widgets
			
		// TODO: this way of looping on attributes, is not so good, I should get attrname and attrval at the same time!
		for (attrname in srcNode.attributes())
		{
			if (StringTools.startsWith(attrname, "xmlns:")) 	continue;
			unknownAttribute(srcNode, attrname);
		}
	}
	public function processWidthAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var attrVal = popAttribute(srcNode, "android:layout_width");	
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "match_parent", "fill_parent":
				dstNode.set("percentWidth", "100");
			case "wrap_content":
				dstNode.set("autoSize","true");
			default:
				dstNode.set("width",Std.string(_resloader.getDimensionPixelSize(attrVal)));
		}	
	}

	public function processHeightAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var attrVal = popAttribute(srcNode, "android:layout_height");	
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "match_parent", "fill_parent":
				dstNode.set("percentHeight", "100");
			case "wrap_content":
				dstNode.set("autoSize", "true");
			default:
				dstNode.set("height",Std.string(_resloader.getDimensionPixelSize(attrVal)));
		}	
	}
	
	public function processEnabledAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var attrVal = popAttribute(srcNode, "android:enabled");		
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "true":
//				res.set("disabled", "false");
			case "false":
				dstNode.set("disabled","true");
			default:
				_logger.error('unrecognized android:enabled  value ${attrVal}');
		}			
	}	
	public function processIdAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var attrVal = popAttribute(srcNode, "android:id");
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
			dstNode.set("id", rgx.matchedRight());
		}	
	}	
	
	public function processAlphaAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var astr = popAttribute(srcNode, "android:alpha");
		if (astr != null)
		{
			addHaxeUIStyle(dstNode, "alpha", astr);
		}		
	}	
	
	public function processBackgroundAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var attrname = "android:background";
		var attrval = popAttribute(srcNode, attrname);
		if (attrval != null)
		{
			var color = _resloader.getColorObject(attrval); //is it a color?
			if(color!=null) 
			{
				addHaxeUIStyle(dstNode, "backgroundColor", color.color());
				return;
			}
			var dpath = _resloader.resolveDrawable(attrval); //is it a drawable?
			if (dpath != null)
			{	
				addHaxeUIStyle(dstNode, "backgroundImage", dpath);
				return;
			}
			//other type of android:background, not yet supported
			unknownAttribute(srcNode, attrname, attrval);
		}		
	}		
	
	public function processTextAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var astr = popAttribute(srcNode, "android:text");
		if (astr != null)
		{
			var text = _resloader.getString(astr);
			dstNode.set("text", text);			
		}
	
	}


	public function processTextColorAttribute(srcNode:Xml, dstNode:Xml):Void
	{
		var cstr = popAttribute(srcNode, "android:textColor");
		if (cstr != null)
		{
			var color=_resloader.getColorObject(cstr);
			addHaxeUIStyle(dstNode, "color", color.color());
		}		
	}
	
	
	public function processTextAlignmentAttribute(srcNode:Xml,dstNode:Xml):Void 
	{
		var attrname = "android:textAlignment";
		var alignstr = popAttribute(srcNode, attrname);
		if (alignstr != null)
		{
			var dstalignstr:String =
			switch(alignstr)
			{
				case "center":
					"center";
				case "inherit":
					unknownAttribute(srcNode, attrname, alignstr);
					"";
				case "gravity":
					unknownAttribute(srcNode, attrname, alignstr);
					"";
				case "textStart":
					unknownAttribute(srcNode, attrname, alignstr);
					"";
				case "textEnd":
					unknownAttribute(srcNode, attrname, alignstr);
					"";
				case "viewStart":
					unknownAttribute(srcNode, attrname, alignstr);						
					"";
				case "viewEnd":
					unknownAttribute(srcNode, attrname, alignstr);
					"";
				default:
					unknownAttribute(srcNode, attrname, alignstr);						
					"";
			}
			if(dstalignstr.length>0)
				dstNode.set("textAlign", dstalignstr);
		}		
	}

	public function processCommonTextAttributes(srcNode:Xml , dstNode:Xml):Void 
	{
		processTextAttribute(srcNode, dstNode);
		processTextColorAttribute(srcNode, dstNode);
		processTextAlignmentAttribute(srcNode,dstNode);		
	}
	
	public function processAndroidHintAttribute( srcNode:Xml,dstNode:Xml):Void 
	{
		var hintstr = popAttribute(srcNode, "android:hint");
		if (hintstr != null)
		{
			var text = _resloader.getString(hintstr);
			dstNode.set("placeholderText", text);						
		}
	}
	
	public function processAndroidHintAttributeForText( srcNode:Xml,dstNode:Xml):Void 
	{
		var astr = dstNode.get("text"); //get text if already defined
		var hintstr = popAttribute(srcNode, "android:hint");
		if (hintstr != null && (astr == null || astr.length == 0))
		{ //use hint, if text not defined
			var text = _resloader.getString(hintstr);
			dstNode.set("text", text);						
		}			
	}		
	
	public function processAndroidCheckedAttribute(srcNode:Xml,dstNode:Xml):Void 
	{
		var checkedstr = popAttribute(srcNode, "android:checked");
		if (checkedstr != null)
		{
			switch(checkedstr)
			{
				case "true", "false":
					dstNode.set("selected", checkedstr);
				default:
					unknownAttribute(srcNode, "checked", checkedstr);
			}
		}
	}	
	
	/**
	 * android attribute that defines the icon to be used for the checkbox
	 */
	public function processAndroidButtonAttribute(srcNode:Xml,dstNode:Xml):Void 
	{
		var attrname = "android:button";
		var bstr = popAttribute(srcNode, attrname);
		if (bstr == null) return;
		var iconstr = _resloader.resolveDrawable(bstr);
		if (iconstr == null)
		{ //cannot resolve icon
			errorResolvingResource(srcNode, attrname, bstr);
			return;
		}
		unsupportedHaxeUIFeature(srcNode, attrname);
//		addHaxeUIStyle(res, "icon", iconstr);
	}	
	
	public function processAndroidSrcAttribute(srcNode:Xml,dstNode:Xml):Void 
	{
		var attrname = "android:src";
		var srcstr = popAttribute(srcNode, attrname);
		if (srcstr == null) 
		{
			//todo: add warning?
			return;		
		}
		var imagestr = _resloader.resolveDrawable(srcstr);
		if (imagestr == null)
		{ //cannot resolve image
			errorResolvingResource(srcNode, attrname, imagestr);
			return;
		}		
		dstNode.set("resource", imagestr);
	}
	
	public function processAndroidScaleTypeAttribute(srcNode:Xml,dstNode:Xml):Void 
	{
		var attrname = "android:scaleType";
		var ststr = popAttribute(srcNode, attrname);
		if (ststr == null) return; 
		switch(ststr)
		{
			case "matrix": //Scale using the image matrix when drawing. The image matrix can be set using setImageMatrix(Matrix). From XML, use this syntax: android:scaleType="matrix". 
				unsupportedHaxeUIFeature(srcNode, attrname);
			case "fitXY": //scale the image using FILL:Scale in X and Y independently, so that src matches dst exactly. This may change the aspect ratio of the src
				dstNode.set("stretch", "true");
			case "fitStart": //scale the image using START: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. START aligns the result to the left and top edges of dst. 
				unsupportedHaxeUIFeature(srcNode, attrname);
			case "fitCenter": //scale the image using CENTER: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. The result is centered inside dst. 
				unsupportedHaxeUIFeature(srcNode, attrname);
			case "fitEnd": //scale the image using END: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. END aligns the result to the right and bottom edges of dst. 
				unsupportedHaxeUIFeature(srcNode, attrname);
			case "center": //Center the image in the view, but perform no scaling. 
				unsupportedHaxeUIFeature(srcNode, attrname);
			case "centerCrop": //Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or larger than the corresponding dimension of the view (minus padding). 
				unsupportedHaxeUIFeature(srcNode, attrname);
			case "centerinside":	//Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or less than the corresponding dimension of the view (minus padding). 	
				unsupportedHaxeUIFeature(srcNode, attrname);
			default:
				unknownAttribute(srcNode, attrname, ststr);
		}
	}
		
}