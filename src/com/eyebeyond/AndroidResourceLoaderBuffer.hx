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
	private var _colors:Map<String,AndroidColor>;	
	private var _dimensions:Map<String,AndroidDimension>;	
	private var _matchedResources:Map<String,String>;
	private var _needInit:Bool;
	
	public function new(resLoader:AndroidResourceLoader) 
	{
		_resLoader = resLoader;
		reset();
	}

	public function getString(id:String):String
	{
		if (_needInit) initValuesBuffer();
		return _strings[id];
	}
	public function getColor(id:String):AndroidColor
	{
		if (_needInit) initValuesBuffer();
		return _colors[id];
	}

	public function getDimension(id:String):AndroidDimension
	{
		if (_needInit) initValuesBuffer();
		return _dimensions[id];
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
		_strings = new Map<String,String>();
		_colors = new Map<String,AndroidColor>();
		_dimensions = new Map<String,AndroidDimension>();	
		_matchedResources = new Map<String,String>();
		_needInit = true;
	}
	
	private function initValuesBuffer()
	{
		reset();
		var valuesFiles = _resLoader.resolveAllResourcesOfType("values");
		for (valuesFile in valuesFiles)
		{
			if (!~/(\.xml)$/.match(valuesFile)) continue; //skip files without .xml suffix
			var fileXml = _resLoader.getXML(valuesFile);
			if (fileXml == null)
			{
				trace('Error: reading/parsing $valuesFile resource file');
			}
			var resources = fileXml.elementsNamed("resources").next();
			if (resources == null)
			{
				trace('cannot find resource element in $valuesFile');
				continue;
			}
			for (valuesElement in resources.elements() ) //stringElement=<string name="hello">Hello World!</string>
			{
				switch(valuesElement.nodeName)
				{
					case "string":
						processStringElement(valuesElement);
					case "color":
						processColorElement(valuesElement);
					case "dimen":
						processDimenElement(valuesElement);
					default:
						trace('Unknown values element type: $valuesElement.nodeName');
				}
			}			
		}
		resolveValuesAlias(); //after parsing all xml files, need to resolve aliases!
		_needInit = false;
	}
	private function resolveValuesAlias()
	{
		// TODO:: rewrite this function using unified loop and resolve function for each resource type
		for (key in _strings.keys())
		{
			_strings[key] = resolveString(_strings[key]); // TODO:: use lambda?
		}
		for (key in _dimensions.keys())
		{
			_dimensions[key] = resolveDimension(_dimensions[key]); // TODO:: use lambda?
		}
		for (key in _colors.keys())
		{
			_colors[key] = resolveColor(_colors[key]); // TODO:: use lambda?
		}			
	}

	private function resolveString(inputStr:String):String
	{
		var res:String = inputStr;
		var rgx = ~/^@string\//; //string resource id syntax: "@string/mystringid"
		while (rgx.match(res))
		{ //resource id reference found
			var id = rgx.matchedRight();
			res = _strings[id]; 
		} //loop until the resolved string is a literal string, not a reference to another string resource
		return res;
	}	
	
	/**
	 * if inputStr is a literal dimension definition, parse it and returns it
	 * if it is a reference to a dimension resource (@dimen/dimenid), then resolve it and return it
	 * resolve the dimen resource recursively, in order to support dimen resource aliases
	 */	
	public function resolveDimension(inputDim:AndroidDimension):AndroidDimension
	{
		var res:AndroidDimension = inputDim;
		var rgx = ~/^@dimen\//; //dimension resource id syntax: "@dimen/mydimensionid"
		while (rgx.match(res.str))
		{ //resource id reference found
			var id = rgx.matchedRight();
			res = _dimensions[id]; 
		} 
		return res;
	}
	
	public function resolveColor(inputCol:AndroidColor):AndroidColor
	{
		var res:AndroidColor = inputCol;
		var rgx = ~/^@color\//; //color resource id syntax: "@color/mydimensionid"
		while (rgx.match(res.str))
		{ //resource id reference found
			var id = rgx.matchedRight();
			res = _colors[id]; 
		} 
		return res;
	}			
	
	
	
	
	private function processStringElement(stringElement:Xml):Void 
	{
		var name = stringElement.get("name");
		var txt = stringElement.firstChild().nodeValue;
		_strings[name] = txt;
	}
	
	function processColorElement(colorElement:Xml):Void 
	{
		var colorName = colorElement.get("name");
		var valuestr = colorElement.firstChild().nodeValue;
		//color definition refer to another color resource, delay resolve and parse
		var color:AndroidColor;
		if (valuestr.indexOf("@color/") >= 0) 
			color = new AndroidColor(valuestr);
		else
		{
			color = AndroidResourceParsers.parseAndroidColor(valuestr);
			if (color == null)
				trace('Invalid color format $valuestr for color $colorName');
		}
		 
		_colors[colorName] = color;
	}
	private function processDimenElement(dimenElement:Xml):Void 
	{
		var name = dimenElement.get("name");
		var valuestr = dimenElement.firstChild().nodeValue;
		var dimen:AndroidDimension;
		if (valuestr.indexOf("@dimen/") >= 0) //dimension definition refer to another dimen resource, delay resolve and parse
			dimen = new AndroidDimension(valuestr);
		else
		{
			dimen = AndroidResourceParsers.parseAndroidDimension(valuestr);
			if (dimen == null)
				trace('Invalid format $valuestr for dimensions $name');
		}

		_dimensions[name] = dimen;
	}	
	

	

	

	
}