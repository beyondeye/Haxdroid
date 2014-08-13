#AndroidXMLToHaxeUI
##The problem I want to solve
Haxe is a very powerful tool for cross platform development. Something I feel is missing from the Haxe eco-system is how a way 
to better manage assets in 
The code can be subdivided in two main modules.
The first module almost fully emulate the Android Resource Management system on top of Openfl
The second module, translate Android XML Layout files (GUI definition) in XML based GUI in HaxeUI
Not all Android Widgets and Android Widgets properties are supported
I have also implemented emulation of several Android widgets as custom HaxeUI components (TODO: make list)
The code depends on the Mockatoo library for the Unit Tests. You can easily remove this dependency by deleting the test code
Motivation
-Device dependent GUI support (without it, cross platform GUI support has no practical meaning) based on Android Resource Management system emulation
-Visual UI editor (use Graphical Layout editor in ADT for eclipse or Xamarin Studio)
-better combined cross platform/ native development: If you want to develop native code for Android, it make it easier to port the app to other platforms (support for "Android first" cross platform development
-I am open to contributors to extend the number of android widgets supported
-If somebody is interested in creating a similar tool for iOS GUI I will be happy to collaborate. I currently don't know much about iOS app resource manager format, but I can help in adding support for iOS widgets translation to haxeui  

-a concept similar as OpenFl is to the Flash development platform but for the Android development platform??

See screenshots of demos below (show android screen and same gui automatically ported to HaxeUI

