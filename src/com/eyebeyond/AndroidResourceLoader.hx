package com.eyebeyond ;
import haxe.Resource;
import openfl.Assets;


/**
 * ...
 * @author dario
 */
class AndroidResourceLoader
{
	public var androidResourcesBasePath:String = "androidres/";
	private var _strings:Map<String,String> ;

	public function new() 
	{
		//TODO when device configuration change, need to call again parseStrings: can force this by clearing _strings when configuration change
		parseStringsResource();
	}
	public function getLayout(lname:String):Xml
	{
		var resPath = getResourcePath("layout", lname);
		if (resPath == null) return null;
		return getXML(resPath);
	}
	public function getString(id:String):String
	{
		return _strings[id];
	}

	public  function hasResource(resourceType:String, resourceName:String):Bool
	{
		return getResourcePath(resourceType, resourceName) != null;
	}
	
	public function getResourcePath(resourceType:String, resourceName:String):String
	{
		var res:String = androidResourcesBasePath + resourceType + "/" + resourceName;
		if (hasAsset(res)) return res;
		//TODO add support for multiple layouts directories: layout, layout-land, and so on, depending on configuration
		return null;
	}
	
	private function parseStringsResource()
	{
		var stringsPath = getResourcePath("values", "strings.xml");
		if (stringsPath == null) 
		{
			trace("Error: strings.xml resource not found!");
			return;
		}
		//parse them
		var fileXml = getXML(stringsPath);
		if (fileXml == null)
		{
			trace("Error: reading/parsing strings.xml resource");
		}
		_strings = new Map<String,String>(); 
		//now get strings values
		var resources = fileXml.elementsNamed("resources").next();
		for (stringElement in resources.elements() ) //stringElement=<string name="hello">Hello World!</string>
		{
			var name = stringElement.get("name");
			var txt = stringElement.firstChild().nodeValue;
			_strings[name] = txt;
		}

	}
	private  function getXML(resourceId:String):Xml {
		var text:String = getText(resourceId);
		var xml:Xml = null;
		if (text != null) {
			xml = Xml.parse(text);
		}
		return xml;
	}
	
	private  function getText(resourceId:String):String {
		var str:String = Resource.getString(resourceId);
		if (str == null) {
			str = Assets.getText(resourceId);
		}
		return str;
	}
	
	private  function hasAsset(resouceId:String):Bool
	{
		return Assets.exists(resouceId);
	}	
	
}