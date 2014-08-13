package com.eyebeyond.haxdroid;

/**
 * ...
 * @author dario
 */
class AndroidResourceParsers
{

	public function new() 
	{
		
	}
	 // resource id syntax: @resourcetype/id 
	public static function parseAndroidId(resourceStr,resourceType:String):String
	{
		var rgx = new EReg("@" + resourceType+"/", null);
		if (rgx.match(resourceStr)) return rgx.matchedRight();
		return null;
	}	
	public static function parseAndroidDimension(dstr:String):AndroidDimension 
	{
		var dstr = StringTools.trim(dstr);
		var regexsize = ~/^[0-9]+/;
		if (!regexsize.match(dstr))
		{
			return null;
		}
		var size = Std.parseInt(regexsize.matched(0));
		var unitstr = regexsize.matchedRight();
		var regexunit = ~/^(dp)|(sp)|(pt)|(px)|(mm)|(in)/;
		if (!regexunit.match(unitstr))
		{
			return null;
		}
		var units = regexunit.matched(0); // TODO:: useless call to matched, use directly unitstr
		return new AndroidDimension(dstr,size,units);
	}
	public static function parseAndroidColor(cstr:String):AndroidColor
	{
		var cstr = StringTools.trim(cstr).toLowerCase();

		var alphastr = "ff";
		var colorstr = "000000";
	
		var colorFormat = ~/#[a-f0-9]+/;
		if (!colorFormat.match(cstr))
			return null;
		else
		{
			switch(cstr.length)
			{
				case 4: //#RGB
					colorstr = interp64(cstr.charAt(1)) + interp64(cstr.charAt(2)) + interp64(cstr.charAt(3));
				case 5: //#ARGB
					alphastr = interp64(cstr.charAt(1));
					colorstr = interp64(cstr.charAt(2)) + interp64(cstr.charAt(3)) + interp64(cstr.charAt(4));
				case 7: // #RRGGBB
					colorstr = cstr.substr(1);
				case 9: // #AARRGGBB
					alphastr = cstr.substr(1, 2);
					colorstr = cstr.substr(3);
				default:
					return null;
			}
		}
		return new AndroidColor(cstr, colorstr, alphastr);
	}	
	/**
	 * take a single character hex value (0-15) and interpolate it to a two character (0-255) hex value 
	 * NOTE: no check is done of nstr being actually a single digit hex number
	 */
	private static function interp64(nstr:String):String
	{
		var n:Float = Std.parseInt("0x" + nstr); //parseInt support hex numbers
		var n255:Int = Math.round(255 * n / 15);
		return StringTools.hex(n255,2).toLowerCase();	//convert back to hex
	}	
}