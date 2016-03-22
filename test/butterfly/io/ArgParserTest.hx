package butterfly.io;

import butterfly.io.ArgsParser;
import massive.munit.Assert;
import test.helpers.Assert2;

class ArgParserTest
{
	@Test
	public function extractProjectDirFromArgsThrowsWithNullOrEmptyArgs()
	{
		var message:String = Assert2.throws(function() {
           ArgsParser.extractProjectDirFromArgs(null);
        });
        Assert.isTrue(message.indexOf("Usage") > -1);
        
        message = Assert2.throws(function() {
           ArgsParser.extractProjectDirFromArgs(new Array<String>());
        });
        Assert.isTrue(message.indexOf("Usage") > -1);
        
        message = Assert2.throws(function() {
           ArgsParser.extractProjectDirFromArgs([""]);
        });
        Assert.isTrue(message.indexOf("Usage") > -1);
	}
}
