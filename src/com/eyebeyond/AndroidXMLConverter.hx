package com.eyebeyond;
import Xml;


 

class AndroidXMLConverter
{
	private var _logger:IConverterLogger = null;
	private var _resloader:AndroidResourceLoader;
	private var _nodeConverter:AndroidXMLNodeConverter;
	public function new(resloader:AndroidResourceLoader, logger:IConverterLogger=null) 
	{
		if (resloader == null) throw "AndroidXMLConverter called in invalid resloader";
		_resloader = resloader;
		_logger = logger;
		if (_logger == null) _logger = new DefaultConverterLogger();
		_nodeConverter =  new AndroidXMLNodeConverter(resloader,_logger);
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
			_logger.warning("Could not find processor for '" + node.nodeName + "'");
		}
		
		for (child in node.elements())
		{
			var childResult = processXmlNode(child);
			result.addChild(childResult);
		}
		return result;
	}
	
	
}