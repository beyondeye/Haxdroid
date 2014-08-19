package com.eyebeyond.haxdroid;

/**
 * Base class for all classer involved in the conversion process of Android XML Layout files
 * @author dario
 */
class AndroidXMLConverterModule
{
	private var _resloader:AndroidResourceLoader;
	private var _logger:IConverterLogger;
	public function new(resloader:AndroidResourceLoader,logger:IConverterLogger=null) 
	{
		_resloader = resloader;
		if (logger == null) logger = new DefaultConverterLogger();
		_logger = logger;
	}
	private function unknownAttribute(widget:Xml, attrname:String, attrval:String=null):Void
	{
		if(attrval!=null)
			_logger.warning('Do not know how to process attribute of widget ${widget.nodeName}: $attrname=$attrval');
		else
			_logger.warning('Do not know how to process attribute of widget ${widget.nodeName}: $attrname');
	}
	private function unsupportedHaxeUIFeature(widget:Xml, attrname:String):Void
	{
		_logger.warning('Attribute $attrname of widget ${widget.nodeName} has no equivalent in HaxeUI ');
	}	
	private function errorResolvingResource(widget:Xml, attrname:String, resname:String=null):Void
	{
		_logger.error('Failed resolving resource $resname referenced in widget ${widget.nodeName}, attribute $attrname');
	}		
}