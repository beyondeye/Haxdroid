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
	private var _srcNode:Xml;
	private var _dstNode:Xml;
	
	public function new(resloader:AndroidResourceLoader,logger:IConverterLogger) 
	{
		super(resloader, logger);
	}
	public function setSourceAndDest(srcNode:Xml, dstNode:Xml ):Void
	{
		this._srcNode = srcNode;
		this._dstNode = dstNode;
	}
	
	public function processCommonWidgetAttributes():Void
	{
		if (_dstNode == null) return;

		processWidthAttribute();
		
		processHeightAttribute();
		
		processIdAttribute();

		processEnabledAttribute();
		
		processBackgroundAttribute();
		processAlphaAttribute(); // TODO: this is a more general attribute, of stylable widgets
			
		// TODO: this way of looping on attributes, is not so good, I should get attrname and attrval at the same time!
		for (attrname in _srcNode.attributes())
		{
			if (StringTools.startsWith(attrname, "xmlns:")) 	continue;
			unknownAttribute(_srcNode, attrname);
		}
	}
	public function processWidthAttribute():Void
	{
		var attrVal = popAttribute(_srcNode, "android:layout_width");	
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "match_parent", "fill_parent":
				_dstNode.set("percentWidth", "100");
			case "wrap_content":
				_dstNode.set("autoSize","true");
			default:
				_dstNode.set("width",Std.string(_resloader.getDimensionPixelSize(attrVal)));
		}	
	}

	public function processHeightAttribute():Void
	{
		var attrVal = popAttribute(_srcNode, "android:layout_height");	
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "match_parent", "fill_parent":
				_dstNode.set("percentHeight", "100");
			case "wrap_content":
				_dstNode.set("autoSize", "true");
			default:
				_dstNode.set("height",Std.string(_resloader.getDimensionPixelSize(attrVal)));
		}	
	}
	
	public function processEnabledAttribute():Void
	{
		var attrVal = popAttribute(_srcNode, "android:enabled");		
		if (attrVal == null) return ;
		switch(attrVal)
		{
			case "true":
//				res.set("disabled", "false");
			case "false":
				_dstNode.set("disabled","true");
			default:
				_logger.error('unrecognized android:enabled  value ${attrVal}');
		}			
	}	
	public function processIdAttribute():Void
	{
		var attrVal = popAttribute(_srcNode, "android:id");
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
			_dstNode.set("id", rgx.matchedRight());
		}	
	}	
	
	public function processAlphaAttribute():Void
	{
		var astr = popAttribute(_srcNode, "android:alpha");
		if (astr != null)
		{
			addHaxeUIStyle(_dstNode, "alpha", astr);
		}		
	}	
	
	public function processBackgroundAttribute():Void
	{
		var attrname = "android:background";
		var attrval = popAttribute(_srcNode, attrname);
		if (attrval != null)
		{
			var color = _resloader.getColorObject(attrval); //is it a color?
			if(color!=null) 
			{
				addHaxeUIStyle(_dstNode, "backgroundColor", color.color());
				return;
			}
			var dpath = _resloader.resolveDrawable(attrval); //is it a drawable?
			if (dpath != null)
			{	
				addHaxeUIStyle(_dstNode, "backgroundImage", dpath);
				return;
			}
			//other type of android:background, not yet supported
			unknownAttribute(_srcNode, attrname, attrval);
		}		
	}		
	
	public function processTextAttribute():Void
	{
		var astr = popAttribute(_srcNode, "android:text");
		if (astr != null)
		{
			var text = _resloader.getString(astr);
			_dstNode.set("text", text);			
		}
	
	}


	public function processTextColorAttribute():Void
	{
		var cstr = popAttribute(_srcNode, "android:textColor");
		if (cstr != null)
		{
			var color=_resloader.getColorObject(cstr);
			addHaxeUIStyle(_dstNode, "color", color.color());
		}		
	}
	
	
	public function processTextAlignmentAttribute():Void 
	{
		var attrname = "android:textAlignment";
		var alignstr = popAttribute(_srcNode, attrname);
		if (alignstr != null)
		{
			var dstalignstr:String =
			switch(alignstr)
			{
				case "center":
					"center";
				case "inherit":
					unknownAttribute(_srcNode, attrname, alignstr);
					"";
				case "gravity":
					unknownAttribute(_srcNode, attrname, alignstr);
					"";
				case "textStart":
					unknownAttribute(_srcNode, attrname, alignstr);
					"";
				case "textEnd":
					unknownAttribute(_srcNode, attrname, alignstr);
					"";
				case "viewStart":
					unknownAttribute(_srcNode, attrname, alignstr);						
					"";
				case "viewEnd":
					unknownAttribute(_srcNode, attrname, alignstr);
					"";
				default:
					unknownAttribute(_srcNode, attrname, alignstr);						
					"";
			}
			if(dstalignstr.length>0)
				_dstNode.set("textAlign", dstalignstr);
		}		
	}

	public function processCommonTextAttributes():Void 
	{
		processTextAttribute();
		processTextColorAttribute();
		processTextAlignmentAttribute();		
	}
	
	public function processAndroidHintAttribute():Void 
	{
		var hintstr = popAttribute(_srcNode, "android:hint");
		if (hintstr != null)
		{
			var text = _resloader.getString(hintstr);
			_dstNode.set("placeholderText", text);						
		}
	}
	
	public function processAndroidHintAttributeForText():Void 
	{
		var astr = _dstNode.get("text"); //get text if already defined
		var hintstr = popAttribute(_srcNode, "android:hint");
		if (hintstr != null && (astr == null || astr.length == 0))
		{ //use hint, if text not defined
			var text = _resloader.getString(hintstr);
			_dstNode.set("text", text);						
		}			
	}		
	
	public function processAndroidCheckedAttribute():Void 
	{
		var checkedstr = popAttribute(_srcNode, "android:checked");
		if (checkedstr != null)
		{
			switch(checkedstr)
			{
				case "true", "false":
					_dstNode.set("selected", checkedstr);
				default:
					unknownAttribute(_srcNode, "checked", checkedstr);
			}
		}
	}	
	
	/**
	 * android attribute that defines the icon to be used for the checkbox
	 */
	public function processAndroidButtonAttribute():Void 
	{
		var attrname = "android:button";
		var bstr = popAttribute(_srcNode, attrname);
		if (bstr == null) return;
		var iconstr = _resloader.resolveDrawable(bstr);
		if (iconstr == null)
		{ //cannot resolve icon
			errorResolvingResource(_srcNode, attrname, bstr);
			return;
		}
		unsupportedHaxeUIFeature(_srcNode, attrname);
//		addHaxeUIStyle(res, "icon", iconstr);
	}	
	
	public function processAndroidSrcAttribute():Void 
	{
		var attrname = "android:src";
		var srcstr = popAttribute(_srcNode, attrname);
		if (srcstr == null) 
		{
			//todo: add warning?
			return;		
		}
		var imagestr = _resloader.resolveDrawable(srcstr);
		if (imagestr == null)
		{ //cannot resolve image
			errorResolvingResource(_srcNode, attrname, imagestr);
			return;
		}		
		_dstNode.set("resource", imagestr);
	}
	
	public function processAndroidScaleTypeAttribute():Void 
	{
		var attrname = "android:scaleType";
		var ststr = popAttribute(_srcNode, attrname);
		if (ststr == null) return; 
		switch(ststr)
		{
			case "matrix": //Scale using the image matrix when drawing. The image matrix can be set using setImageMatrix(Matrix). From XML, use this syntax: android:scaleType="matrix". 
				unsupportedHaxeUIFeature(_srcNode, attrname);
			case "fitXY": //scale the image using FILL:Scale in X and Y independently, so that src matches dst exactly. This may change the aspect ratio of the src
				_dstNode.set("stretch", "true");
			case "fitStart": //scale the image using START: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. START aligns the result to the left and top edges of dst. 
				unsupportedHaxeUIFeature(_srcNode, attrname);
			case "fitCenter": //scale the image using CENTER: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. The result is centered inside dst. 
				unsupportedHaxeUIFeature(_srcNode, attrname);
			case "fitEnd": //scale the image using END: Compute a scale that will maintain the original src aspect ratio, but will also ensure that src fits entirely inside dst. At least one axis (X or Y) will fit exactly. END aligns the result to the right and bottom edges of dst. 
				unsupportedHaxeUIFeature(_srcNode, attrname);
			case "center": //Center the image in the view, but perform no scaling. 
				unsupportedHaxeUIFeature(_srcNode, attrname);
			case "centerCrop": //Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or larger than the corresponding dimension of the view (minus padding). 
				unsupportedHaxeUIFeature(_srcNode, attrname);
			case "centerinside":	//Scale the image uniformly (maintain the image's aspect ratio) so that both dimensions (width and height) of the image will be equal to or less than the corresponding dimension of the view (minus padding). 	
				unsupportedHaxeUIFeature(_srcNode, attrname);
			default:
				unknownAttribute(_srcNode, attrname, ststr);
		}
	}
		
}