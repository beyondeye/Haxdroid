package com.eyebeyond.haxdroid;
import Xml;


 

class AndroidXMLConverter
{
	public var logger(default,null):IConverterLogger = null;
	private var _resloader:AndroidResourceLoader;
	private var _nodeConverter:AndroidXMLNodeConverter;
	public function new(resloader:AndroidResourceLoader, logger_:IConverterLogger=null) 
	{
		if (resloader == null) throw "AndroidXMLConverter called in invalid resloader";
		_resloader = resloader;
		logger = logger_;
		if (logger == null) logger = new DefaultConverterLogger();
		_nodeConverter =  new AndroidXMLNodeConverter(resloader,logger);
	}
	public function processXml(node:Xml):Xml 
	{
		var rootNode = processXmlNode(node.firstElement());
		if (rootNode == null) return null;
		var res = Xml.createDocument();
		res.addChild(rootNode); 
		return res;
	}	

	private function processXmlNode(node:Xml):Xml
	{
		if (node == null) {
			return null;
		}		
		
		var result:Xml = _nodeConverter.process(node);
		if (result == null) 
		{
			logger.warning("Could not find processor for '" + node.nodeName + "'");
		}
		
		for (child in node.elements())
		{
			var childResult = processXmlNode(child);
			result.addChild(childResult);
		}
		return result;
	}
	
	
}