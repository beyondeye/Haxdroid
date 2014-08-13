package com.eyebeyond;

/**
 * @author dario
 */

 
/**
 * for deocumentation of Android device configuration qualifiers as used in the Android App Resource management system, look at
 *  http://developer.android.com/guide/topics/resources/providing-resources.html#AlternativeResources
 */

 
//There is one exception to this rule: If your application's minSdkVersion is 4 or greater, you do not need default drawable resources
//when you provide alternative drawable resources with the screen density qualifier. Even without default drawable resources, Android
//can find the best match among the alternative screen densities and scale the bitmaps as necessary. However, for the best experience 
//on all types of devices, you should provide alternative drawables for all three types of density. 


typedef AndroidDeviceConfigQualifier=
{
	var name:String;
	var regex:String; 
}

/**
 * TODO need to document this configuration qualifiers labels, somewhere, not only list them in code
 */
 
class AndroidDeviceConfiguration
{
	private var _signalConfigurationChanged:Void->Void=null;
	private var _requestedConfigQualifierValues:Array<String> ;
	private  static  var _qualifiers:Array<AndroidDeviceConfigQualifier> = [
		{name:"MCCandMNC", regex: "^mcc[0-9]+(mnc[0-9]+)?-" }, 					//Examples:  mcc310 mcc310-mnc004 mcc208-mnc00
		{name:"LanguageAndRegion", regex: "^[a-z][a-z](-r[A-Z][A-Z])?-" }, 		//Examples:en fr en-rUS fr-rFR fr-rCA
		{name:"LayoutDirection", regex: "^(ldrtl)|(ldltr)-" },
		{name:"SmallestWidth", regex: "^sw[0-9]+dp-" },							//Examples sw320dp sw600dp sw720dp
		{name:"AvailableWidth", regex: "^w[0-9]+dp-" },							//Examples w720dp w1024dp
		{name:"AvailableHeight", regex: "^h[0-9]+dp-" },							//Examples h720dp h1024dp
		{name:"ScreenSize", regex: "^(small)|(normal)|(large)|(xlarge)-" },
		{name:"ScreenAspect", regex: "^(long)|(notlong)-" },
		{name:"ScreenOrientation", regex: "^(port)|(land)-" },
		{name:"UIMode", regex: "^(car)|(desk)|(television)|(appliance)|(watch)-" },
		{name:"NightMode", regex: "^(night)|(notnight)-" },
		{name:"ScreenPixelDensity", regex: "^(ldpi)|(mdpi)|(tvdpi)|(hdpi)|(xhdpi)|(xxhdpi)|(xxxhdpi)|(nodpi)-" },
		{name:"TouchScreenType", regex: "^(notouch)|(finger)-" },
		{name:"KeyboardAvailability", regex: "^(keysexposed)|(keyshidden)|(keyssoft)-" },
		{name:"PrimaryTextInputMethod", regex: "^(nokeys)|(qwerty)|(12key)-" },
		{name:"NavigationKeyAvailability", regex: "^(navexposed)|(navhidden)-" },
		{name:"PrimaryNonTouchNavigationMethod", regex: "^(nonav)|(dpad)|(trackball)|(wheel)-" },
		{name:"APILevel", regex: "^v[0-9]+-" } //Examples: v3 v4 v9	
		];	
		
	// ordered values ScreenPixelDensity, for lowest to highest.
	// IMPORTANT: The algorithm used to match requested pixel density is based on the
	// assumption that that values in this array are ordered this way
	private static var screenPixelDensityStr = [ "nodpi", "ldpi", "mdpi", "tvdpi", "hdpi", "xhdpi" ,"xxhdpi","xxxhdpi"];
	
	/**
	 * Set Android device configuration to something similar to a desktop pc
	 */
	public function setConfigurationForDesktopPC()
	{
		_requestedConfigQualifierValues = [for (i in 0..._qualifiers.length) ""]; //fill with empty string: no configuration selected
		setConfiguration("LanguageAndRegion", "en");
		setConfiguration("LayoutDirection", "ldltr");
		setConfiguration("ScreenSize", "xlarge");
		setConfiguration("ScreenAspect", "long");
		setConfiguration("ScreenOrientation", "land");
		setConfiguration("ScreenPixelDensity", "xhdpi");
		setConfiguration("TouchScreenType", "notouch");
		setConfiguration("KeyboardAvailability", "keysexposed");
		setConfiguration("PrimaryTextInputMethod", "qwerty");
		setConfiguration("NavigationKeyAvailability", "navhidden");
		setConfiguration("PrimaryNonTouchNavigationMethod", "trackball");
	}
	
	public function new() 
	{
		reset();
	}

	public function reset():Void
	{
		_requestedConfigQualifierValues = [for (i in 0..._qualifiers.length) ""]; //fill with empty string: no configuration selected
		dispatchSignalConfigurationChanged();
	}
	
	@:allow(com.eyebeyond.AndroidResourceLoader.new)
	private function registerHandlerSignalConfigurationChanged(handler:Void->Void)
	{
		_signalConfigurationChanged = handler;
	}	
	private function dispatchSignalConfigurationChanged():Void
	{
		if (_signalConfigurationChanged != null) _signalConfigurationChanged();
	}
		

	/**
	 * 
	 * @param	qualifierName
	 * @param	qualifierValue
	 * @return True if Configuration successfully changed
	 */
	public function setConfiguration(qualifierName:String, qualifierValue_:String):Bool
	{
		var qidx = findConfigQualifierIndex(qualifierName);
		if (qidx < 0) 
		{
			trace ('Error:android configuration qualifier name ${qualifierName} unknown');
			return false;
		}
		var regexString = _qualifiers[qidx].regex;
		var regex = new EReg(regexString, null);
		var qualifierValue = qualifierValue_.toLowerCase() +"-"; //"-" is always added at the end of qualifiers, for allowing regex to work
		if (!regex.match(qualifierValue ))
		{
			trace('android configuration ${qualifierValue} for ${qualifierName}  does not match required pattern ${regexString}');
			return false;
		}
		_requestedConfigQualifierValues[qidx] = qualifierValue;
		dispatchSignalConfigurationChanged();
		return true;
	}

	public function getConfiguration(qualifierName:String):String
	{
		var qidx = findConfigQualifierIndex(qualifierName);
		if (qidx < 0) 
		{
			trace ('Error:android configuration qualifier name ${qualifierName} unknown');
			return null;
		}
		var qstr = _requestedConfigQualifierValues[qidx];
		return trimLast(qstr); //remove last character ("-")
	}

	public function getConfigurationScreenPixelDensity():String
	{
		return getConfiguration("ScreenPixelDensity");
	}

	/**
	 * Check if the specified resourceName is compatible for current selected device Configuration
	 * see http://developer.android.com/guide/topics/resources/providing-resources.html for details
	 * @param	resourceType
	 * Name of the resource (for example: "layout", "drawable", etc.)
	 * @param	resourceNameWithConfigQualifiers
	 * Full name of the resource, including resource qualifiers, (for example" "drawable-ldpi", "drawable-xhdpi", etc.)
	 * @return
	 */
	@:allow(com.eyebeyond.AndroidResourceLoader.getAllCompatibleResources)	
	private function isCompatibleResource(resourceType:String, resourceNameWithConfigQualifiers_:String):Bool
	{
		var resourceNameWithConfigQualifiers = resourceNameWithConfigQualifiers_.toLowerCase();
		var qualifiersStartIdx = resourceNameWithConfigQualifiers.indexOf(resourceType)+resourceType.length;
		if (qualifiersStartIdx < 0) 
			return false;
		var qualifiersEndIdx = resourceNameWithConfigQualifiers.indexOf('/', qualifiersStartIdx);
		if (qualifiersEndIdx < 0) 
			return false;
		var resourceQualifiers:String = resourceNameWithConfigQualifiers.substring(qualifiersStartIdx,qualifiersEndIdx);
		var curQualifierIdx = 0;
		var curQualifierStringStartIdx = 1; //skip the initial '-'
		// TODO: I can simplify a lot this code by using only regex.match and rgx.matchedRight, instead of index counters and substring!
		while (curQualifierStringStartIdx<resourceQualifiers.length)
		{
			var curQualifierStringEndIdx = resourceQualifiers.indexOf('-', curQualifierStringStartIdx); 
			if (curQualifierStringEndIdx < 0)
			{
				curQualifierStringEndIdx = resourceQualifiers.length;
			}
			//notes: //s.substring(start,end) returns s[start:end) (end excluded
			//notes: add a '-' at the end of qualifiers, for allowing regex to work
			var curQualifierString = resourceQualifiers.substring(curQualifierStringStartIdx, curQualifierStringEndIdx)+'-'; 
			//update for next qualifier match attemtpt (skip the '-' between qualifiers)
			curQualifierStringStartIdx = curQualifierStringEndIdx+1;
			var matchedQualIdx:Int = -1;
			for (cur in curQualifierIdx..._qualifiers.length)
			{
				var rgx = new EReg(_qualifiers[cur].regex, 'i'); //case insensitive match for resource paths
				if (rgx.match(curQualifierString))
				{
					matchedQualIdx = cur;
					break;
				}				
			} 
			if (matchedQualIdx < 0)
				return false; //invalid qualifier syntax
			curQualifierIdx = matchedQualIdx + 1; //the syntax requires that the qualifiers should be defined according the predefined order
			if ( _qualifiers[matchedQualIdx].name!='ScreenPixelDensity') //ScreenPixelDensity never defines an incompatible resource: see Android documentation
			{				
				var  requestQualValue = _requestedConfigQualifierValues[matchedQualIdx];
				if ((requestQualValue.length > 0) && (requestQualValue != curQualifierString))
					return false; //incompatible with current configuration
			}
		}
		return true; //resource with no qualifiers, always compatible
		
		
		
	}
	
	/**
	 * Remove last character from string
	 */
	private static inline function trimLast(s:String):String
	{
		return  s.substr(0, s.length - 1); //remove '-' at end
	}
	
	private function findConfigQualifierIndex(qualifierName:String): Int
	{
		if (qualifierName == null) return -1;
		for (i in 0..._qualifiers.length)
		{
			if (_qualifiers[i].name == qualifierName) return i;
		}
		return -1;
	}
	/**
	 * Return distance>0 if density higher that densityBase
	 **/
	private function calcPixelDensityDistance(density:String, densityBase:String):Int
	{
		var base_d = screenPixelDensityStr.indexOf(densityBase);
		var d = screenPixelDensityStr.indexOf(density);
		return d - base_d;
	}
	
	/**
	 * Extract resource config qualifiers from full resource path+resource name
	 * TODO use regex instead of string functions here?
	 */
	function extractResourceConfigQualifiers(resourcePaths:Array<String>,resourceType:String):Array<String> 
	{
		var configQualifiers = new Array<String>();
		var rtlenp1 = resourceType.length+1;		
		for (res in resourcePaths)
		{
			var lastidx = res.indexOf('/');
			var resq = 
			{
				if (rtlenp1 >= lastidx) 
					""
				else
					res.substring(rtlenp1, lastidx) +'-';
			}
			configQualifiers.push(resq);
		}
		return configQualifiers;
		
	}

	/**
	 * The following function implement the algorithm used by android to select 
	 * the best matching resource between all resources that satisfy
	 * the current device configuration.
	 * The algorithm is described in http://developer.android.com/guide/topics/resources/providing-resources.html#BestMatch
	 * 1.  Pick the (next) highest-precedence configuration qualifier in the list. (Start with MCC, then move down.)
	 * 2.Do any of the resource directories include this qualifier?
	 *		-If No, return to step 1 and look at the next qualifier.
     *		-If Yes, continue to step 3. 
	 * 3.Eliminate resource directories that do not include this qualifier. 
	 *        EXCEPTION:  If the qualifier in question is screen pixel density, Android selects the option that most 
	 *                    closely matches the device screen density. 
	 *                    In general, Android prefers scaling down a larger original image to scaling up a smaller original image
	 * 4.Go back and repeat steps 1, 2, and 3 until only one directory remains.  
	 */
	@:allow(com.eyebeyond.AndroidResourceLoader.resolveResource)
	@:allow(com.eyebeyond.AndroidResourceLoader.resolveAllResourcesOfType)
	private function findBestMatchingResource(compatibleResources:Array<String>, resourceType:String):String
	{
		var compatibleResourcesConfigQualifiers = extractResourceConfigQualifiers(compatibleResources,resourceType);

		var remainingIdxs = [for (i in 0...compatibleResources.length) i]; 
		
		// 1.  Pick the (next) highest-precedence configuration qualifier in the list. (Start with MCC, then move down.)	
		for (curq in 0..._qualifiers.length)
		{
			var rgx = new EReg(_qualifiers[curq].regex, 'i'); //case insensitive match for resource paths
			var newRemainingIdxs = new Array<Int>();
			var newCompatibleResourceQualifiers = new Array<String>();
			var requestedQValue = _requestedConfigQualifierValues[curq];

			//in the case of pixel density, even if no exact match found, android chooses between all available configs,
			//the one that best matches the requested config	
			if (_qualifiers[curq].name == "ScreenPixelDensity" && requestedQValue.length > 0)
			{
				var  requestedPixelDensity = trimLast(requestedQValue); //remove '-' at end
				var  distanceFromRequestedDensity = new Array<Int>();

				for (i in 0...remainingIdxs.length)
				{
					var curqstr = compatibleResourcesConfigQualifiers[i];
					if (rgx.match(curqstr)) //we have a PixelDensity qualifier defined for this resource
					{
						distanceFromRequestedDensity.push(calcPixelDensityDistance(rgx.matched(0), requestedPixelDensity));
						newRemainingIdxs.push(remainingIdxs[i]);
						newCompatibleResourceQualifiers.push(rgx.matchedRight());
					} 
				}	
				if (newRemainingIdxs.length > 0)
				{
					var bestd = getBestDistanceFromRequestedDensity(distanceFromRequestedDensity);
					var res=SelectBestDistanceConfigurations(bestd,distanceFromRequestedDensity, newRemainingIdxs, newCompatibleResourceQualifiers);
					newRemainingIdxs = res.idxs;
					newCompatibleResourceQualifiers = res.values;
				}
			}
			else
			{  //_qualifiers[curq].name != "ScreenPixelDensity" 

				// * 2.Do any of the resource directories include this qualifier?
				// *		-If No, return to step 1 and look at the next qualifier.
				// *		-If Yes, continue to step 3. 
				for (i in 0...remainingIdxs.length)
				{ 
					var curqstr = compatibleResourcesConfigQualifiers[i];
					if (rgx.match(curqstr))
					{
						newRemainingIdxs.push(remainingIdxs[i]);
						newCompatibleResourceQualifiers.push(rgx.matchedRight());
					} 
				}
			}
			// * 3.Eliminate resource directories that do not include this qualifier.
			if (newRemainingIdxs.length > 0) //some match found
			{ 
				remainingIdxs = newRemainingIdxs;
				compatibleResourcesConfigQualifiers = newCompatibleResourceQualifiers;
			} 
		 	
			if (remainingIdxs.length == 1) break;
		}
		if (remainingIdxs.length != 1)
			trace("findBestMatchingResource() failed to identify a single matching resource");
		return compatibleResources[remainingIdxs[0]];
	}
	
	/**
	 * select best matching resolution: closest to required, prefering higher density to lower density
	 * 
	 */
	function getBestDistanceFromRequestedDensity(distanceFromRequestedDensity:Array<Int>):Int 
	{
		var bestd = 1000; //artificially big number
		for (i in 0...distanceFromRequestedDensity.length)
		{
			var curd = distanceFromRequestedDensity[i];
			if (Math.abs(curd) < Math.abs(bestd))
			{
				bestd = curd;
			} else 
			if (Math.abs(curd) == bestd && curd > bestd) //same distance, but positive instead of negative (i.e. higher pixel density)
			{
				bestd = curd;
			}
		}
		return bestd;
	}
	/**
	 *  select only configurations equal or better to bestd
	 */
	function SelectBestDistanceConfigurations(
									bestd:Int, distanceFromRequestedDensity:Array<Int>,
									idxs:Array<Int>, values:Array<String>)
									: {idxs:Array<Int>,values:Array<String>}
	{
		var res_idxs = new Array<Int>();
		var res_values = new Array<String>();
		for (i in 0...idxs.length)
		{
			var curd = distanceFromRequestedDensity[i];
			if (curd == bestd)
			{
				res_idxs.push(idxs[i]);
				res_values.push(values[i]);
			}						
		}
		return { idxs:res_idxs, values:res_values };
	}	

	
}

