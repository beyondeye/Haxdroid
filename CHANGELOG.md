#Haxdroid V 0.1.0 22/8/2014
First release: 
##Supported Android Resources

- Drawables
- Layouts
- Values:
	- Colors
	- Strings
	- Dimensions

##Supported Android widgets
- LinearLayout
- ScrollView
- ListView
- Button
- TextView
- EditText
- CheckBox
- ImageView


##Supported Android widgets attributes

- General
	- android:id
	- android:enabled
- Layout related
	- android:layout_width
	- android:layout_height
	- android:padding
	- android:paddingTop
	- android:paddingBottom
	- android:paddingLeft
	- android:paddingRight
	- android:layout_gravity
- Text related
	- android:text
	- android:textColor
	- android:textAlignment
	- android:hint
- Image Related	
	- android:src
	- android:scaleType: only 'fitXY' currently supported
- Color related
	- android:alpha
	- android:background
- Specific to widgets
	- android:checked

##Known Issues
HaxeUI does not currently support separate "autoSize" for width and height of a widget. Take this into consideration when using  android:layout_width="wrap_content" 
or android:layout_height="wrap_content" 

