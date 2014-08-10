package ;


/**
 * Various helper function for comparing objects
 * @author dario
 */
class CompareTools
{
	/**
	 * return true if two strings match, when ignoring extra blanks
	 */
	public static function match_ignoreblanks(a:String, b:String):Bool
	{
		var cmpa = new StringCompareWithoutExtraBlanksIterator(a);
		var cmpb = new StringCompareWithoutExtraBlanksIterator(b);
		while (true)
		{
			cmpa.next(); cmpb.next();
			if (cmpa.isEof && cmpb.isEof) return true;
			if (cmpa.isEof || cmpb.isEof) return false;
			if (cmpa.curchar != cmpb.curchar) return false;
		}
	}

	
}

/**
 * A helper class used for comparing strings while ignoring extra blanks
 */
class StringCompareWithoutExtraBlanksIterator
{
	public var s(default,null):String;
	public  var curi(default,null):Int;
	public var slen(default,null):Int;
	public  var isEof(default,null):Bool;
	public  var curchar(default, null):Int;

	public function new(s:String) 
	{
		this.s = s;
		slen = s.length;
		isEof = false;
		curi = -1;
		curchar = -1;
	}
	private static inline function isSpace(c:Int):Bool
	{
		return switch(c)
		{
			case 9, 10, 11, 12, 13, 32:
				true;
			default:
				false;
		}
	}		
	public function next():Void
	{
		if (++curi >= slen) 
		{
			isEof = true;
			return;
		}
		curchar = StringTools.fastCodeAt(s, curi);
		if (isSpace(curchar)) 
		{
			curchar = 32;
			//skip multiple blanks
			while(true)
			{
				if (++curi >= slen) break;
				var nxtchar = StringTools.fastCodeAt(s, curi);
				if (!isSpace(nxtchar)) break; 
			}
			--curi;
		}		
	}
	
}