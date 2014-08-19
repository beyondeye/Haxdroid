package com.eyebeyond.haxdroid;

/**
 * ...
 * @author dario
 */
class XMLConverterHelperMethods
{

	public function new() 
	{
		
	}
	// TODO: implement this using Haxe mixin feature (syntax extension for Xml object)
	public static function addAttributes(node:Xml, attrs:Map<String,String>):Void
	{
		if (attrs == null) return;
		// TODO: the following way of accessing the list of converted_attrs seems to me extremely inefficient
		for (attrname in attrs.keys())
		{
			node.set(attrname, attrs.get(attrname));
		}		
	}

	// TODO: implement this using Haxe mixin feature (syntax extension for Xml object)
	public static function popAttribute(node:Xml, attrname:String):String
	{
		var res:String = node.get(attrname);
		if (res != null) node.remove(attrname);
		return res;			
	}
	

	// TODO: add check that the same style not added twice?
	public static function addHaxeUIStyle(node:Xml, styleName:String, styleValue:String):Void
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