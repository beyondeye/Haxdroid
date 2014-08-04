package com.eyebeyond;

/**
 * ...
 * @author dario
 * This class is used to buffer parsed resources for current selected Android Device Configuration
 */
class AndroidResourceLoaderBuffer
{
	private var _resLoader:AndroidResourceLoader;
	private var _strings:Map<String,String>;
	private var _matchedResources:Map<String,String>;
	
	public function new(resLoader:AndroidResourceLoader) 
	{
		_resLoader = resLoader;
		reset();
	}

	public function getString(id:String):String
	{
		if (_strings == null) initStringsBuffer();
		return _strings[id];
	}	
	public function getBufferedMatchedResourceName(resourceType:String, resourceName:String):String
	{
		return _matchedResources.get(resourceType+ '/' + resourceName);
	}
	public function setBufferedMatchedResourceName(resourceType:String, resourceName:String,matchedResourcePath:String):Void
	{
		_matchedResources.set(resourceType+ '/' + resourceName,matchedResourcePath);
	}
	public function reset():Void
	{
		_strings = null;
		_matchedResources = new Map<String,String>();
	}

	private function initStringsBuffer()
	{
		var stringsPath = _resLoader.getResourcePath("values", "strings.xml");
		if (stringsPath == null) 
		{
			trace("Error: strings.xml resource not found!");
			return;
		}
		//parse them
		var fileXml = _resLoader.getXML(stringsPath);
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
	
}