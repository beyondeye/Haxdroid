package com.eyebeyond;

/**
 * ...
 * @author dario
 */	
class AndroidDimension
{
	public var size:Int;
	public var units:String;		
	public function new() 
	{
		size = 0;
		units = "";
	}
	public function toString():String 
	{
		return '$size$units';
	}
}