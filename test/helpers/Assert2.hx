package test.helpers;

class Assert2
{
	// TODO: PR this into munit
	public static function throws(code:Void -> Void):String
	{
		try {
			code();
			throw "Exception wasn't thrown";
		} catch (actual:String) {
			return actual;
		} catch (actual:Dynamic) {
			throw "Unexpected exception";			
		}
	}
}