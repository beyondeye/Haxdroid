#AndroidXMLToHaxeUI
##The problem
Haxe is a very powerful tool for cross platform development.But something I felt was missing from the Haxe eco-system was 
a way to manage assets and GUI of an application as a function of the device and execution environment. This is actually critical for cross-platform 
development to be practically viable.

Arguably one of the best of such systems currently available, is the [Android Resource Management System](http://developer.android.com/guide/topics/resources/overview.html)

The first purpose of this project is to bring the power of Android Resource Management to Haxe. The code in this repository contains a full emulator of the android resource management system,
that allow you to take the resource tree of an android application and automatically import, and use it from Haxe(+OpenFL). According to the way you define the execution configuration, 
(i.e. display size, language preferences, and so on, (see [here](http://developer.android.com/guide/topics/resources/providing-resources.html) for more details)) the resource management 
system will automatically provide your application with the right assets.

##From Android XML Layouts to HaxeUI XML layouts
The second purpose of this project is automatically generate [HaxeUI](http://haxeui.org/) XML based UI definitions from Android XML layouts. In other words
once you have designed the GUI of your application using Android Developer Tools or Xamarin Studio(including the visual UI designer available there),
you can translate it and use it in Haxe. Not all Android Widgets and all widget properties are currently supported. If you have requests for specific widgets or widget properties,
please feel free to open an Issue. I will do my best to include all most used widgets.

##Main benefits provided
- Powerful device and runtime configuration dependent asset management (GUI and localization)
- Allow for Android first cross platform development: develop your application first as a native Android application, then take the resources and import them directly in the haxe version of the
 application for deploying to additional platforms.
- Allow for cross platform GUI development based on Android UI design tools and HaxeUI, even if you do not design your application at all to run specifically on Android.


##Future Roadmap
The code for the Resource manager emulator already cover most of the important features of the original Android Resource Manager, but still need some work to complete
all features and certainly additionally testing is needed.

The code supporting translating Android Widget to HaxeUI widget is limited to a small number widget, need more work to extend to more Widgets

I am also considering the possibility of using a different haxe UI engine as target (for example [stablexui](https://github.com/RealyUniqueName/StablexUI))

I will be happy to hear about suggestion and request and open to collaborations

