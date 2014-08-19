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
	function processAndroidHintAttributeForText( node:Xml,res:Xml):Void 
	{
		var astr = res.get("text"); //get text if already defined
		var hintstr = popAttribute(node, "android:hint");
		if (hintstr != null && (astr == null || astr.length == 0))
		{ //use hint, if text not defined
			var text = _resloader.getString(hintstr);
			res.set("text", text);						
		}			
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

		processAndroidHintAttributeForText(node, res);
		return res;		
	}	

	function processAndroidCheckedAttribute(node:Xml,res:Xml):Void 
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
	function processAndroidButtonAttribute(node:Xml,res:Xml):Void 
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
	
	private function processAndroidSrcAttribute(node:Xml,res:Xml):Void 
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
	
	private function processAndroidScaleTypeAttribute(node:Xml,res:Xml):Void 
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
	
	
	private function processAndroidCheckBox( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("checkbox");

		processCommonTextAttributes(node,res);

		processAndroidHintAttributeForText(node, res);
		
		processAndroidCheckedAttribute(node, res);
		
		processAndroidButtonAttribute(node, res);
		return res;
	}	
	
	private function processAndroidImageView( node:Xml ):Xml 
	{
		var res:Xml = Xml.createElement("image");
		
		processAndroidSrcAttribute(node, res);
		processAndroidScaleTypeAttribute(node, res);
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
	

	

	

	

	

	

	

	


	
}