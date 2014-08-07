package com.eyebeyond;

/**
 * ...
 * @author dario
 */
interface IConverterLogger
{
	var warningCount(default, null):Int;
	var errorCount(default, null):Int;
	function resetErrorsCounts():Void;
	function printErrorCount():Void;
	function warning(msg:String):Void;
	function error(msg:String):Void;	
	function info(msg:String):Void;

}