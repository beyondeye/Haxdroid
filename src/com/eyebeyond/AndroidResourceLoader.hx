package com.eyebeyond ;
import haxe.Resource;
import openfl.Assets;
import openfl.display.BitmapData;
using Lambda;

/**
 * Class for accessing an application's resources, emulating Android Resource Management system
 * The API of this class is inspired to class android.content.res.Resources in Android API
 * See http://developer.android.com/reference/android/content/res/Resources.htm
 * @author dario
 */
class AndroidResourceLoader
{
	public var androidResourcesBasePath(default,null):String;
	private var _androidResourcesList:Array<String>; //depends only on androidResourcesBasePath, not on _androidConfiguration
	public var androidDeviceConfiguration(default, null) :AndroidDeviceConfiguration; //each time this is changed, need to rebuild _androidResourceBuffer
	private var _loaderBuffer:AndroidResourceLoaderBuffer; //store resolved path to resources in androidresourcebuffer!!!
	private var _displayMetrics:AndroidDisplayMetrics; //class that manage translation of virtual dimensions in real pixel dimensions

	public function new(androidResourceBasePath:String="androidres/") 
	{
		this.androidResourcesBasePath = androidResourceBasePath;
		if (androidResourceBasePath.charAt(androidResourceBasePath.length-1) != '/')
		{
			this.androidResourcesBasePath = this.androidResourcesBasePath + "/";
		}
		InitAndroidResourcesList();
		androidDeviceConfiguration = new AndroidDeviceConfiguration();
		_displayMetrics = new AndroidDisplayMetrics(androidDeviceConfiguration);
		_loaderBuffer = new AndroidResourceLoaderBuffer(this);
		androidDeviceConfiguration.registerHandlerSignalConfigurationChanged(reset);	
	}
	private function reset():Void
	{
		_displayMetrics.reset();
		_loaderBuffer.reset();
	}
	public function getLayout(lname:String):Xml
	{
		var res:Xml = null;
		var id = AndroidResourceParsers.parseAndroidId(lname,"layout");
		if (id!=null)
		{ //resource id reference found
			var resPath = resolveResource("layout", id);
			if (resPath != null) res= getXML(resPath);
		}
		return res;		
	}
	public function getDrawable(d:String):BitmapData
	{
		var res:BitmapData = null;
		var id = AndroidResourceParsers.parseAndroidId(d,"drawable");
		if (id!=null)
		{ //resource id reference found
			var resPath = resolveResource("drawable", id);
			if (resPath != null) res= getBitmapData(resPath);
		}
		return res;
	}	
	public function getColorRaw(c:String):AndroidColor
	{
		var id = AndroidResourceParsers.parseAndroidId(c, 'color');
		if(id!=null) return _loaderBuffer.getColor(id);
		return AndroidResourceParsers.parseAndroidColor(c);
	}
	
	public function getColor(id:String):String
	{
		var c = getColorRaw(id);
		return c.color();
	}
	public function getColorWithAlpha(id:String):String
	{
		var c = getColorRaw(id);
		return c.colorWithAlpha();
	}
	public function getDimensionRaw(d:String):AndroidDimension
	{
		var id = AndroidResourceParsers.parseAndroidId(d, 'dimen');
		if(id!=null) return _loaderBuffer.getDimension(id);
		return AndroidResourceParsers.parseAndroidDimension(d);
	}

	/**
	 * see http://developer.android.com/reference/android/content/res/Resources.html#getDimension%28int%29
	 */
	public function getDimension(id:String):Float
	{
		var d = getDimensionRaw(id);
		return _displayMetrics.getDimension(d);
	}
	/**
	 * see http://developer.android.com/reference/android/content/res/Resources.html#getDimensionPixelOffset%28int%29
	 */
	public function getDimensionPixelOffset(id:String):Int
	{
		var d = getDimensionRaw(id);
		return _displayMetrics.getDimensionPixelOffset(d);
	}
	/**
	 * see http://developer.android.com/reference/android/content/res/Resources.html#getDimensionPixelSize%28int%29
	 */
	public function getDimensionPixelSize(id:String):Int
	{
		var d = getDimensionRaw(id);
		return _displayMetrics.getDimensionPixelSize(d);
	}		

	
	/**
	 * if inputStr is a literal string, return it
	 * if it is a reference to a string resources (@string/stringid), then resolve it and return it
	 * resolve the string resource recursively, in order to support string resource aliases
	 */
	public function getString(s:String):String
	{
		var res:String = s;
		var id = AndroidResourceParsers.parseAndroidId(s, "string");
		if (id!=null) res =  _loaderBuffer.getString(id); 
		return res;
	}	
	

	

	public  function hasResource(resourceType:String, resourceName:String):Bool
	{
		return resolveResource(resourceType, resourceName) != null;
	}
	
	/**
	 * see http://developer.android.com/guide/topics/resources/providing-resources.html#BestMatch 
	 * for explanation of the resource matching algorithm  
	 * @param	resourceType
	 * @param	resourceName
	 * @return
	 */
	public function resolveResource(resourceType:String, resourceName:String):String
	{
		if (resourceName == null) return null;
		// TODO: instead of running getAllcompatibleresources all the times, I should run it only once, when the android configuration is known, and then use the sublist obtained for further processing (this optimization is also documented in android documentaiton)
		var buffered = _loaderBuffer.getBufferedMatchedResourceName(resourceType, resourceName);
		if (buffered != null) return androidResourcesBasePath+buffered;
		//--Need to sweat a bit for finding the matching resource
		var compatibleResources:Array<String> = getAllCompatibleResources(resourceType, resourceName);
		//-now run the algorithm (defined in android doc) that verify which of the compatible resources gives the best match
		var res = androidDeviceConfiguration.findBestMatchingResource(compatibleResources, resourceType);
	

//		var res:String = androidResourcesBasePath + resourceType + "/" + resourceName;
		
		_loaderBuffer.setBufferedMatchedResourceName(resourceType, resourceName, res);
//		if (hasAsset(res)) return res; //NO NEED to check this, since we start from the list of all existing assets
		return androidResourcesBasePath+res;
	}
	/**
	 * see http://developer.android.com/guide/topics/resources/providing-resources.html#BestMatch 
	 * for explanation of the resource matching algorithm  
	 * @param	resourceType
	 * @return
	 */
	public function resolveAllResourcesOfType(resourceType:String):Array<String>
	{
		var resOfSelectedType = new Array<String>();  //here I will fill the result of all resolved resources of selected type
		// TODO: instead of running getAllcompatibleresources all the times, I should run it only once, when the android configuration is known, and then use the sublist obtained for further processing (this optimization is also documented in android documentaiton)
		var remaining = getAllCompatibleResources(resourceType);
		while (remaining.length > 0)
		{
			var cur = remaining[0];
			var curname = cur.substr(cur.lastIndexOf('/')+1);
			var curnameregex = new EReg( '/'+curname, null); //match resource name
			var newRemaining = new Array<String>();
			var selected = new Array<String>();
			//select all resources with same name as firstname, and remove them from list
			for(s in remaining)
			{
				if (curnameregex.match(s)) 
					selected.push(s)
				else
					newRemaining.push(s);
			}
			remaining = newRemaining;
			//run findBestMatchingResource for each group with same resource name
			
			//-now run the algorithm (defined in android doc) that verify which of the compatible resources with name firstname  gives the best match
			var res = androidDeviceConfiguration.findBestMatchingResource(selected, resourceType);
			resOfSelectedType.push(androidResourcesBasePath+res);
		}
		return resOfSelectedType;
	}

	

	private function  getAllCompatibleResources(resourceType:String, resourceName:String=null):Array<String>
	{
		var list = new Array<String>();
		
		//first select resources that match requested resourceType and resourceName
		for (resource in _androidResourcesList)
		{
			var fndpos = resource.indexOf(resourceType);
			if (fndpos != 0) continue; //wrong resource type
			var namestartIdx = resource.indexOf('/', resourceType.length)+1;
			if (resourceName!=null && resource.indexOf(resourceName, namestartIdx) < 0) continue; //wrong resource name
			list.push(resource);
		}
		
		var reslist = new Array<String>(); //now filter according to current selected android configuration
		for (resource in list)
		{
			if (androidDeviceConfiguration.isCompatibleResource(resourceType, resource))
				reslist.push(resource);
		}		
		return reslist;
	}
	public  function getXML(resourceId:String):Xml {
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
	private  function getBitmapData(resourceId:String):BitmapData 
	{
		return Assets.getBitmapData(resourceId);
	}
	
	private  function hasAsset(resouceId:String):Bool
	{
		return Assets.exists(resouceId);
	}	
	
	/**
	 * Scan all resources in the path defined by androidResourcesBasePath
	 * do not store the full path to android resource: store only the <resource_type>/<resource_name>
	 */
	private function InitAndroidResourcesList():Void 
	{
		var reslist = openfl.Assets.list(); //all embedded assets
		_androidResourcesList = new Array<String>();
		for (res in reslist)
		{
			var fndidx = res.indexOf(androidResourcesBasePath);
			if (fndidx != 0) continue;
			_androidResourcesList.push(res.substr(androidResourcesBasePath.length));
		}
	}
	
}