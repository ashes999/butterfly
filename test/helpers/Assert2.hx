package test.helpers;

import massive.munit.Assert;

class Assert2
{
    // TODO: PR this into munit
    public static function throws(code:Dynamic):Dynamic
    {
        try
        {
            code();
            Assert.fail("Expected exception wasn't thrown!");
            return null; // needed to compile
        }
        catch (e:Dynamic)
        {
            return e;
        }
    }
}