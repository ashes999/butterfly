package butterfly.io;

using butterfly.extensions.StringExtensions;

class ArgsParser
{
    public static function extractProjectDirFromArgs(args:Array<String>):String
    {
        if (args == null || args.length != 1 || StringExtensions.isNullOrWhitespace(args[0]))
        {
            throw "Usage: neko Main.n <source directory>";
        }

        var projectDir:String = args[0];
        trace("Using " + projectDir + " as project directory");
        FileSystem.ensureDirExists(projectDir);
            
        return projectDir;
    }
}