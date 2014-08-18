package com.eyebeyond.haxdroid;

/**
 * ...
 * @author dario
 */
class AndroidColor
{
	public var str(default,null):String; //the original str defining the resource
	private var colorstr:String; //six character hex value RRGGBB
	private var alphastr:String; //two character hex value for alpha channel
	public function new(str:String,colorstr=null,alphastr=null) 
	{
		this.str = str;
		this.colorstr = colorstr;
		this.alphastr= alphastr;
	}	
	public function color():String
	{
		return '0x$colorstr';
	}
	public function colorWithAlpha():String
	{
		return '0x$alphastr$colorstr';
	}
	public function alphaFloat():Float
	{
		return Std.parseFloat(alphastr) / 255;
	}
	public function alphaInt():String
	{
		return alphastr;
	}
	
}