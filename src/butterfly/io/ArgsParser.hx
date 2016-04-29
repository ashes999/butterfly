package butterfly.io;

using noor.io.FileSystemExtensions;
using noor.StringExtensions;
import sys.FileSystem;

class ArgsParser
{
    public static function extractProjectDirFromArgs(args:Array<String>):String
    {
        if (args == null || args.length != 1 || args[0].isNullOrWhitespace())
        {
            throw "Usage: neko Main.n <source directory>";
        }

        var projectDir:String = args[0];
        trace("Using " + projectDir + " as project directory");
        FileSystemExtensions.ensureDirectoryExists(FileSystem, projectDir);
            
        return projectDir;
    }
}