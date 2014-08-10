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
	private var _colors:Map<String,String>;	
	private var _colorsWithAlpha:Map<String,String>;	
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
	public function getColor(id:String):String
	{
		if (_colors == null) initColorsBuffer();
		return _colors[id];
	}
	public function getColorWithAlpha(id:String):String
	{
		if (_colorsWithAlpha == null) initColorsBuffer();
		return _colorsWithAlpha[id];
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
		_colors = null;
		_colorsWithAlpha = null;
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
			if (stringElement.nodeName != "string")
			{
				trace("element of invalid type found where <string/> was expected" + stringElement.toString());
				continue;
			}			
			var name = stringElement.get("name");
			var txt = stringElement.firstChild().nodeValue;
			_strings[name] = txt;
		}

	}	
	private function initColorsBuffer()
	{
		var colorsPath = _resLoader.getResourcePath("values", "colors.xml");
		if (colorsPath == null) 
		{
			trace("Error: colors.xml resource not found!");
			return;
		}
		//parse them
		var fileXml = _resLoader.getXML(colorsPath);
		if (fileXml == null)
		{
			trace("Error: reading/parsing colors.xml resource");
		}
		_colors = new Map<String,String>(); 
		_colorsWithAlpha = new Map<String,String>(); 
		//now get strings values
		var resources = fileXml.elementsNamed("resources").next();
		for (colorElement in resources.elements() ) //stringElement=<string name="hello">Hello World!</string>
		{
			if (colorElement.nodeName != "color")
			{
				trace("element of invalid type found where <color/> was expected" + colorElement.toString());
				continue;
			}
			var colorName = colorElement.get("name");
			var txt = StringTools.trim(colorElement.firstChild().nodeValue).toLowerCase();
			var alpha = "ff";
			var color = "000000";

			var colorFormat = ~/#[a-f0-9]+/;
			if (!colorFormat.match(txt))
				trace('Invalid color format $txt for color $colorName');
			else
			{
				switch(txt.length)
				{
					case 4: //#RGB
						color = interp64(txt.charAt(1)) + interp64(txt.charAt(2)) + interp64(txt.charAt(3));
					case 5: //#ARGB
						alpha = interp64(txt.charAt(1));
						color = interp64(txt.charAt(2)) + interp64(txt.charAt(3)) + interp64(txt.charAt(4));
					case 7: // #RRGGBB
						color = txt.substr(1);
					case 9: // #AARRGGBB
						alpha = txt.substr(1, 2);
						color = txt.substr(3);
					default:
						trace('Invalid color format $txt for color $colorName');
				}
			}
			_colors[colorName] = '0x$color';
			_colorsWithAlpha[colorName] = '0x$alpha$color';
		}
	}
	/**
	 * take a single character hex value (0-15) and interpolate it to a two character (0-255) hex value 
	 * NOTE: no check is done of nstr being actually a single digit hex number
	 */
	private function interp64(nstr:String):String
	{
		var n:Float = Std.parseInt("0x" + nstr); //parseInt support hex numbers
		var n255:Int = Math.round(255 * n / 15);
		return StringTools.hex(n255,2).toLowerCase();	//convert back to hex
	}
	
}