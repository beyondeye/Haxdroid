#Haxdroid Documentation
By (Dario Elyasy)[http://il.linkedin.com/in/darioe/], [eye-beyond.com](http://eye-beyond.com)
##The problem
Haxe is a very powerful tool for cross platform development.But something I felt was missing from the Haxe eco-system was 
a way to manage assets and GUI of an application as a function of the device and the execution environment. This is actually critical for cross-platform 
development to be practically viable.

Arguably one of the best such systems currently available, is the [Android Resource Management System](http://developer.android.com/guide/topics/resources/overview.html)

The first purpose of this project is to bring the power of Android Resource Management to Haxe. The code in this repository contains a full emulator of the android resource management system,
that allows you to take the resource tree of an android application and automatically import it, and use it from Haxe(+OpenFL). According to the way you define the execution configuration, 
(i.e. display size, language preferences, and so on, (see [here](http://developer.android.com/guide/topics/resources/providing-resources.html) for more details)) the resource management 
system will automatically provide your application with the right assets.

##From Android XML Layouts to HaxeUI XML layouts
The second purpose of this project is automatically generate [HaxeUI](http://haxeui.org/) XML based UI definitions from Android XML layouts. In other words
once you have designed the GUI of your application using Android Developer Tools or Xamarin Studio(including the visual UI designer available there),
you can automatically translate it and use it in Haxe. Not all Android Widgets and all widget properties are currently supported. If you have requests for specific widgets or widget properties,
please feel free to open an Issue. I will do my best to include all most used widgets.


##Main benefits provided
- Powerful device and runtime configuration dependent asset management (GUI and localization)
- Allow for Android-first cross platform development: develop your application first as a native Android application, then take the resources and import them directly in the haxe version of the
 application for deploying to additional platforms.
- Allow for cross platform GUI development based on Android UI design tools and HaxeUI, even if you do not design your application at all to run specifically on Android.

##Dependencies
Of course you need to have [OpenFL](http://www.openfl.org/documentation/setup/install-haxe/) and its dependencies installed.

Additionally you need to install [HaxeUI](http://haxeui.org/download.jsp) and [Mockatoo](https://github.com/misprintt/mockatoo). Mockatoo is used only in unit tests. 

##Development Roadmap
The code for the Resource manager emulator already implements many of the most important features of the original Android Resource Manager, but it still needs some work to be completed.

The code supporting translating Android Widget to HaxeUI widget is limited to a small number widget, need more work to extend to more Widgets

I am also considering the possibility of adding another UI engine as target (for example [stablexui](https://github.com/RealyUniqueName/StablexUI))

I will be happy to hear about suggestions and requests and I am open to collaborations.
##Usage
First create an instance of AndroidResourceLoader. You can give to the constructor a string parameter with the path to the root of Android resources directory. The default is "androidres"
which resolves to assets/androidres.
```haxe
var resloader = new AndroidResourceLoader();
```
Secondly you should set the Android Device Configuration, with properties, like ScreenPixelDensity, Language and so, on. For a default configuration with parameters adjusted to match a PC, 
you can call 
```haxe
resloader.androidDeviceConfiguration.setConfigurationForDesktopPC();
```
Now you can access directly Android resources with methods of AndroidResourceLoader, like `getLayout()`, `getDrawable()`, `getColor()` and so on, or you can
use the automatic Android XML layout translation, like this
```haxe
		var androidxml = resloader.getLayout("@layout/oneimage.xml");
		var converter = new AndroidXMLConverter(resloader);
		var haxeui_xml = converter.processXml(androidxml);
```
For more example of usages, look at unit tests.

##Supported Android Resources
Look [here](http://developer.android.com/guide/topics/resources/providing-resources.html) for an overview on Android resources 
- [Drawables](http://developer.android.com/guide/topics/resources/drawable-resource.html):  only bitmaps currently supported
- [Layouts](http://developer.android.com/guide/topics/resources/layout-resource.html)
- Values:
	- [Colors](http://developer.android.com/guide/topics/resources/more-resources.html#Color)
	- [Strings](http://developer.android.com/guide/topics/resources/string-resource.html): only simple strings currently supported
	- [Dimensions](http://developer.android.com/guide/topics/resources/more-resources.html#Dimension)

##Supported Android widgets
- [LinearLayout](http://developer.android.com/guide/topics/ui/layout/linear.html)
- [ScrollView] (http://developer.android.com/reference/android/widget/ScrollView.html)
- [ListView] (http://developer.android.com/guide/topics/ui/layout/listview.html)
- [Button] (http://developer.android.com/guide/topics/ui/controls/button.html)
- [TextView] (http://developer.android.com/reference/android/widget/TextView.html)
- [EditText] (http://developer.android.com/guide/topics/ui/controls/text.html)
- [CheckBox] (http://developer.android.com/guide/topics/ui/controls/checkbox.html)
- [ImageView] (http://developer.android.com/reference/android/widget/ImageView.html)


##Supported Android widgets attributes
See android documentation of supported widgets for details about supported widget attributes
- General
	- android:id
	- android:enabled
- Layout related
	- android:layout_width,
	- android:layout_height
	- android:minWidth
	- android:minHeight
- Text related
	- android:text
	- android:textColor
	- android:textAlignment: only 'center' currently supported
	- android:hint
- Image Related	
	- android:src
	- android:scaleType: only 'fitXY' currently supported
- Color related
	- android:alpha
	- android:background: both background color and background image supported
- Specific to widgets
	- android:checked

##Known Issues
