package butterfly.io;

class ArgsParser
{
    public static function extractProjectDirFromArgs(args:Array<String>):String {
        if (args.length != 1)
        {
            throw "Usage: neko Main.n <source directory>";
        }

        var projectDir:String = args[0];
        trace("Using " + projectDir + " as project directory");
        FileSystem.ensureDirExists(projectDir);
            
        return projectDir;
    }
}