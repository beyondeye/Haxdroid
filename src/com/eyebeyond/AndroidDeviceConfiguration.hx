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
		{name:"ScreenPixelDensity", regex: "^(ldpi)|(mdpi)|(tvdpi)|(hdpi)|(xhdpi)|(nodpi)-" },
		{name:"TouchScreenType", regex: "^(notouch)|(finger)-" },
		{name:"KeyboardAvailability", regex: "^(keysexposed)|(keyshidden)|(keyssoft)-" },
		{name:"PrimaryTextInputMethod", regex: "^(nokeys)|(qwerty)|(12key)-" },
		{name:"NavigationKeyAvailability", regex: "^(navexposed)|(navhidden)-" },
		{name:"PrimaryNonTouchNavigationMethod", regex: "^(nonav)|(dpad))|(trackball)|(wheel)-" },
		{name:"APILevel", regex: "^v[0-9]+-" } //Examples: v3 v4 v9	
		];	
	private static var screenPixelDensityStr = [ "nodpi","ldpi", "mdpi","tvdpi", "hdpi", "xhdpi" ];
	public function new() 
	{
		reset();
	}
	@:allow(AndroidResourceLoader.new)
	public function registerHandlerSignalConfigurationChanged(handler:Void->Void)
	{
		_signalConfigurationChanged = handler;
	}
	public function reset():Void
	{
		_requestedConfigQualifierValues = [for (i in 0..._qualifiers.length) ""]; //fill with empty string: no configuration selected
		dispatchSignalConfigurationChanged();
	}
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
		setConfiguration("ScreenPixelDensity", "hdpi");
		setConfiguration("TouchScreenType", "notouch");
		setConfiguration("KeyboardAvailability", "keysexposed");
		setConfiguration("PrimaryTextInputMethod", "qwerty");
		setConfiguration("NavigationKeyAvailability", "navhidden");
		setConfiguration("PrimaryNonTouchNavigationMethod", "trackball");
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
		var qidx = findQualifierName(qualifierName);
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

	/**
	 * Check if the specified resourceName is compatible for current selected device Configuration
	 * see http://developer.android.com/guide/topics/resources/providing-resources.html for details
	 * @param	resourceType
	 * Name of the resource (for example: "layout", "drawable", etc.)
	 * @param	resourceNameWithConfigQualifiers
	 * Full name of the resource, including resource qualifiers, (for example" "drawable-ldpi", "drawable-xhdpi", etc.)
	 * @return
	 */
	@:allow(AndroidResourceLoader.getAllCompatibleResources)	
	public function isCompatibleResource(resourceType:String, resourceNameWithConfigQualifiers_:String):Bool
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
		//TODO I can simplify a lot this code by using only regex.match and rgx.matchedRight, instead of index counters and substring!
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
				var rgx = new EReg(_qualifiers[cur].regex, 'i');
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
	private function findQualifierName(qualifierName:String): Int
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
	 * @param	density
	 * @param	densityBase
	 * @return
	 */
	private function calcPixelDensityDistance(density:String, densityBase:String):Int
	{
		var base_d = screenPixelDensityStr.indexOf(densityBase);
		var d = screenPixelDensityStr.indexOf(density);
		return d - base_d;
	}
	/**
	 * The following function implement the algorithm used by android to select the best matching resource between all resources that satisfy
	 * the current device configuration. The algorithm is described in http://developer.android.com/guide/topics/resources/providing-resources.html#BestMatch
	 * 1.  Pick the (next) highest-precedence configuration qualifier in the list. (Start with MCC, then move down.)
	 * 2.Do any of the resource directories include this qualifier?
	 *		-If No, return to step 1 and look at the next qualifier.
     *		-If Yes, continue to step 3. 
	 * 3.Eliminate resource directories that do not include this qualifier. EXCEPTION:  If the qualifier in question is screen pixel density, Android selects the option that most closely matches the device screen density. In general, Android prefers scaling down a larger original image to scaling up a smaller original image
	 * 4.Go back and repeat steps 1, 2, and 3 until only one directory remains.  
	 */
	@:allow(AndroidResourceLoader.getResourcePath)
	public function findBestMatchingResource(compatibleResources:Array<String>, resourceType:String, resourceName:String):String
	{
		//first extract config qualifier substring
		var compatibleResourcesQualifiers = new  Array<String>();
		var rtlenp1 = resourceType.length+1;
		
		for (res in compatibleResources)
		{
			var lastidx = res.indexOf('/');
			var resq = 
			{
				if (rtlenp1 >= lastidx) 
					""
				else
					res.substring(rtlenp1, lastidx) +'-';
			}
			compatibleResourcesQualifiers.push(resq);
		}
		var remainingidxs = [for (i in 0...compatibleResources.length) i]; 
		
		for (curq in 0..._qualifiers.length)
		{
			var rgx = new EReg(_qualifiers[curq].regex, 'i');
			var newRemainingIdx = new Array<Int>();
			var newCompatibleResourceQualifiers = new Array<String>();
			var requestedQValue = _requestedConfigQualifierValues[curq];

			//todo this function too complicated, split it into simpler functions
			if (_qualifiers[curq].name == "ScreenPixelDensity" && requestedQValue.length > 0)
			{
				var  requestPixelDensity = requestedQValue.substr(0, requestedQValue.length - 1); //remove '-' at end
				var  distanceFromRequestedDensity = new Array<Int>();

				//in the case of pixel density, even if no exact match found, android chose between all available configs,
				//the one that best matches the required config.In general, Android prefers scaling down a larger original
				// image to scaling up a smaller original image
				for (idx in remainingidxs)
				{
					var curqstr = compatibleResourcesQualifiers[idx];
					if (rgx.match(curqstr))
					{
						distanceFromRequestedDensity.push(calcPixelDensityDistance(rgx.matched(0), requestPixelDensity));
						newRemainingIdx.push(idx);
						newCompatibleResourceQualifiers.push(rgx.matchedRight());
					} 
				}	
				if (newRemainingIdx.length > 0)
				{
					//now select best matching resolution
					var bestMatchDistance = 1000; //artificially big number
					for (i in 0...newRemainingIdx.length)
					{
						var curd = distanceFromRequestedDensity[i];
						if (Math.abs(curd) < Math.abs(bestMatchDistance))
						{
							bestMatchDistance = curd;
						} else 
						if (Math.abs(curd) == bestMatchDistance && curd > bestMatchDistance) //same distance, but positive instead of negative (i.e. higher pixel density)
						{
							bestMatchDistance = curd;
						}
					}
					//finally select only configurations equal or better to bestMatchDistance
					var newRemainingIdx2 = new Array<Int>();
					var newCompatibleResourceQualifiers2 = new Array<String>();
					for (i in 0...newRemainingIdx.length)
					{
						var curd = distanceFromRequestedDensity[i];
						if (curd == bestMatchDistance)
						{
							newRemainingIdx2.push(newRemainingIdx[i]);
							newCompatibleResourceQualifiers2.push(newCompatibleResourceQualifiers[i]);
						}						
					}
					newRemainingIdx = newRemainingIdx2;
					newCompatibleResourceQualifiers = newCompatibleResourceQualifiers2;
				}
			}
			else
			{
				for (idx in remainingidxs)
				{
					var curqstr = compatibleResourcesQualifiers[idx];
					if (rgx.match(curqstr))
					{
						newRemainingIdx.push(idx);
						newCompatibleResourceQualifiers.push(rgx.matchedRight());
					} 
				}
			}
			if (newRemainingIdx.length > 0) //some match found
			{ //some resource speficy
				remainingidxs = newRemainingIdx;
				compatibleResourcesQualifiers = newCompatibleResourceQualifiers;
			} 
		 	
			if (remainingidxs.length == 1) break;
		} 		
		return compatibleResources[remainingidxs[0]];
	}
	
	//trace (AndroidDeviceConfiguration.qualifiers[0]);
	//var a:ConfigQualifierAndRegex = AndroidDeviceConfiguration.qualifiers[1];
	//trace(a);
	
}

