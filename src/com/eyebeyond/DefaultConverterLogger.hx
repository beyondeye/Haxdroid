package com.eyebeyond;

/**
 * ...
 * @author dario
 */
class DefaultConverterLogger  implements IConverterLogger
{
	public var warningCount(default, null):Int;
	public var errorCount(default, null):Int;
	
	public function new() 
	{
		resetErrorsCounts();
	}
	public function resetErrorsCounts():Void
	{
		warningCount = 0;
		errorCount = 0;
	}
	public function printErrorCount():Void
	{
		trace('Total ${errorCount} errors and ${warningCount} warnings' );
	}
	public function warning(msg:String):Void
	{
		trace('Warning ${++warningCount}: ${msg}');
	}
	public function error(msg:String):Void
	{
		trace('Error ${++errorCount}: ${msg}');
	}
	public function info(msg:String):Void
	{
		trace(msg);
	}
	
}