package com.eyebeyond;

/**
 * @author dario
 */

 
/**
 * for deocumentation of Android device configuration qualifiers as used in the Android App Resource management system, look at
 *  http://developer.android.com/guide/topics/resources/providing-resources.html#AlternativeResources
 */
typedef AndroidDeviceConfigQualifier=
{
	var name:String;
	var regex:String; 
}

class AndroidDeviceConfiguration
{
	private  static  var qualifiers = [
		{name:"MCCandMNC", regex: "mcc[0-9]+(mnc[0-9]+)?" }, 					//Examples:  mcc310 mcc310-mnc004 mcc208-mnc00
		{name:"LanguageAndRegion", regex: "[a-z][a-z](-r[A-Z][A-Z])?" }, 		//Examples:en fr en-rUS fr-rFR fr-rCA
		{name:"LayoutDirection", regex: "(ldrtl)|(ldltr)" },
		{name:"SmallestWidth", regex: "sw[0-9]+dp" },							//Examples sw320dp sw600dp sw720dp
		{name:"AvailableWidth", regex: "w[0-9]+dp" },							//Examples w720dp w1024dp
		{name:"AvailableHeight", regex: "h[0-9]+dp" },							//Examples h720dp h1024dp
		{name:"ScreenSize", regex: "(small)|(normal)|(large)|(xlarge)" },
		{name:"ScreenAspect", regex: "(long)|(notlong)" },
		{name:"ScreenOrientation", regex: "(port)|(land)" },
		{name:"UIMode", regex: "(car)|(desk)|(television)|(appliance)|(watch)" },
		{name:"NightMode", regex: "(night)|(notnight)" },
		{name:"ScreenPixelDensity", regex: "(ldpi)|(mdpi)|(hdpi)|(xhdpi)|(nodpi)|(tvdpi)" },
		{name:"TouchScreenType", regex: "(notouch)|(finger)" },
		{name:"KeyboardAvailability", regex: "(keysexposed)|(keyshidden)|(keyssoft)" },
		{name:"PrimaryTextInputMethod", regex: "(nokeys)|(qwerty)|(12key)" },
		{name:"NavigationKeyAvailability", regex: "(navexposed)|(navhidden)" },
		{name:"PrimaryNonTouchNavigationMethod", regex: "(nonav)|(dpad))|(trackball)|(wheel)" },
		{name:"APILevel", regex: "v[0-9]+" } //Examples: v3 v4 v9	
		];	

	public function new() 
	{
		
		
		
	}
	
	//trace (AndroidDeviceConfiguration.qualifiers[0]);
	//var a:ConfigQualifierAndRegex = AndroidDeviceConfiguration.qualifiers[1];
	//trace(a);
	
}

