package com.eyebeyond;

/**
 * ...
 * @author dario
 */	
class AndroidDimension
{
	public var str(default,null):String; //the original string defining the dimension in resource file
	public var size(default,null):Int;
	public var units(default,null):String;	// TODO:: USE ENUM FOR UNITS, INSTEAD OF STRING	
	public function new(str:String,size:Int=0, units:String=null) 
	{
		this.str = str;
		this.size = size;
		this.units = units;
	}
	public function toString():String 
	{
		if (str != null) return str;
		return '$size$units';
	}
}