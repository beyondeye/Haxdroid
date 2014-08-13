package com.eyebeyond.haxdroid;

/**
 * see http://developer.android.com/reference/android/util/DisplayMetrics.html
 * @author dario
 */
class AndroidDisplayMetrics
{
	public static inline var DENSITY_LOW = 120; //DPI for low density screens
	public static inline var DENSITY_MEDIUM = 160;
	public static inline var DENSITY_DEFAULT = 160;
	public static inline var DENSITY_HIGH = 240;
	public static inline var DENSITY_TV = 213; //720p TV scren
	public static inline var DENSITY_XHIGH = 320; //1080p TV screen
	public static inline var DENSITY_400 = 400;
	public static inline var DENSITY_XXHIGH = 480;
	public static inline var DENSITY_XXXHIGH = 640; // 4K television screens -- 3840x2160, which is 2x a traditional HD 1920x1080 screen
		
	/**
	 * The logical density of the display. This is a scaling factor for 
	 * the Density Independent Pixel unit,  where one DIP is one pixel on
	 * an approximately 160 dpi screen (for example a 240x320, 1.5"x2" screen), 
	 * providing the baseline of the system's display. Thus on a 160dpi screen
	 * this density value will be 1; on a 120 dpi screen it would be .75; etc.
	 * 
	 * 	This value does not exactly follow the real screen size (as given by xdpi
	 * and ydpi, but rather is used to scale the size of the overall UI in steps 
	 * based on gross changes in the display dpi. For example, a 240x320 screen 
	 * will have a density of 1 even if its width is 1.8", 1.3", etc. However, 
	 * if the screen resolution is increased to 320x480 but the screen size 
	 * remained 1.5"x2" then the density would be increased (probably to 1.5).
	 */	
	public var density(default, null):Float; 
	
	/**
	 * The screen density expressed as dots-per-inch. May be either
	 * DENSITY_LOW, DENSITY_MEDIUM, or DENSITY_HIGH.
	 */
	public var densityDpi(default, null):Int;


	/**
	 * A scaling factor for fonts displayed on the display. This is the same
	 * as density, except that it may be adjusted in smaller increments 
	 * at runtime based on a user preference for the font size.
	 */
	public var scaledDensity(default, null):Float;

	/**
	 * The absolute height of the display in pixels.
	 */
	public var heightPixels(default, null):Int;

	/**
	 *  The absolute width of the display in pixels.
	 */
	public var widthPixels(default, null):Int;

	/**
	 * The exact physical pixels per inch of the screen in the X dimension.
	 */
	public var xdpi(default, null):Float;

	/**
	 * The exact physical pixels per inch of the screen in the Y dimension.
	 */
	public var ydpi(default, null):Float;

	//---------------------------------------------------------------------------------------

	private var _deviceConfiguration:AndroidDeviceConfiguration; //the android device configuration used to intialize display metrics

	public function new(config:AndroidDeviceConfiguration) 
	{
		_deviceConfiguration = config;
		reset();
	}
	/**
	 * initialize density according to current status of linked AndroidDeviceConfiguration
	 */
	public function reset():Void
	{
		var pxdstr = _deviceConfiguration.getConfigurationScreenPixelDensity();
		if (pxdstr == null|| pxdstr.length==0) pxdstr = "mdpi";
		switch(pxdstr)
		{
			case "ldpi":
				densityDpi = DENSITY_LOW;
			case "mdpi":
				densityDpi = DENSITY_MEDIUM;
			case "tvdpi":
				densityDpi = DENSITY_TV;
			case "hdpi":
				densityDpi = DENSITY_HIGH;
			case "xhdpi":
				densityDpi = DENSITY_XHIGH;
			case "xxhdpi":
				densityDpi = DENSITY_XXHIGH;
			case "xxxhdpi":
				densityDpi = DENSITY_XXXHIGH;
			default:
				trace('unrecognized display density $pxdstr');
				densityDpi = DENSITY_MEDIUM;				
		}
		density = cast(densityDpi,Float) / cast(DENSITY_DEFAULT,Float);
		scaledDensity = density; // for fonts
		
		heightPixels = 0; // TODO:: assign this:  The absolute height of the display in pixels.
		widthPixels = 0; // TODO:: assign this: The absolute width of the display in pixels.
		xdpi = 0; // TODO:: assign this:  The exact physical pixels per inch of the screen in the X dimension.
		ydpi = 0; // TODO:: assign this: The exact physical pixels per inch of the screen in the Y dimension.		
	}

	
	public function getDimension(d:AndroidDimension):Float
	{
		return switch(d.units)
		{
			case "dp":
				d.size * density;
			case "sp":
				d.size * scaledDensity;
			case "pt":
				d.size * densityDpi / 72;
			case "px":
				d.size;
			case "mm":
				d.size * densityDpi / 25.4;
			case "in":
				d.size * densityDpi;
			default:
				trace('unknown units $d.units');
				return d.size;
		}
	}
	/**
	 * see http://developer.android.com/reference/android/content/res/Resources.html#getDimensionPixelOffset%28int%29
	 */
	public function getDimensionPixelOffset(d:AndroidDimension):Int
	{
			return Math.floor(getDimension(d));
	}
	/**
	 * see http://developer.android.com/reference/android/content/res/Resources.html#getDimensionPixelSize%28int%29
	 */
	public function getDimensionPixelSize(d:AndroidDimension):Int
	{
		var dpx:Int = Math.round(getDimension(d));
		if (dpx == 0 && d.size > 0) dpx = 1; //enforce non zero size in case of rounding errors
		return dpx;
	}
	
	
}