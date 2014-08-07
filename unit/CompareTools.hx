package ;

/**
 * Various helper function for comparing objects
 * @author dario
 */
class CompareTools
{

	public static inline function isSpace(c:Int):Bool
	{
		return switch(c)
		{
			case 9, 10, 11, 12, 13, 32:
				true;
			default:
				false;
		}
	}
	/**
	 * return true if two strings match, when ignoring extra blanks
	 */
	public static function match_ignoreblanks(a:String, b:String):Bool
	{
		var len_a = a.length, len_b = b.length;
		var i_a = -1, i_b=-1;
		var eof_a=false, eof_b=false;
		var char_a:Int, char_b:Int;
		while (true)
		{
			do
			{
				if (++i_a >= len_a) 
				{
					eof_a = true;
					break;
				}
				char_a = StringTools.fastCodeAt(a, i_a);
			} while ( isSpace(char_a));
			do
			{
				if (++i_b >= len_b)
				{
					eof_b = true;
					break;
				}
				char_b = StringTools.fastCodeAt(b, i_b);
			} while ( isSpace(char_b));
			if (eof_a && eof_b) return true;
			if (eof_a || eof_b) return false;
			//now we have to matching characters to compare
			if (char_a != char_b) return false;
		}
	}

	
}