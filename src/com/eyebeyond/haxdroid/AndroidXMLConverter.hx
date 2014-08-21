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
		var rootNode = processXmlNode(node.firstElement(),null);
		if (rootNode == null) return null;
		var res = Xml.createDocument();
		res.addChild(rootNode); 
		return res;
	}	

	/**
	 * 
	 * @param	srcNode: node to convert
	 * @param	dstParentNode: converted parent of srcNode
	 * @return converted srcNode
	 */
	private function processXmlNode(srcNode:Xml,dstParentNode:Xml):Xml
	{
		if (srcNode == null) {
			return null;
		}		
		//NOTE: need to pass dstParentNode because there are some conversion operations
		//      that depend from the context of which is the parent node, and
		//      what are its attributes
		var dstNode:Xml = _nodeConverter.process(srcNode,dstParentNode);
		if (dstNode == null) 
		{
			logger.warning("Could not find processor for '" + srcNode.nodeName + "'");
		}
		
		for (srcChildNode in srcNode.elements())
		{
			var dstChildNode = processXmlNode(srcChildNode,dstNode);
			dstNode.addChild(dstChildNode);
		}
		return dstNode;
	}
	
	
}