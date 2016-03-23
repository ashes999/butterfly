package nucleus.io;

import sys.FileSystem;

// static class
// TODO: replace string messages with exceptions that have a type and message
// eg. DirectoryDoesntExistException
class FileSystemExtensions
{
  public static function copyDirRecursively(srcPath:String, destPath:String) : Void
  {
    if (!FileSystem.exists(destPath))
    {
      FileSystem.createDirectory(destPath);
    }

    if (FileSystem.exists(srcPath) && FileSystem.isDirectory(srcPath))
    {
      var entries = FileSystem.readDirectory(srcPath);
      for (entry in entries)
      {
        if (FileSystem.isDirectory('${srcPath}/${entry}'))
        {
          FileSystem.createDirectory('${srcPath}/${entry}');
          copyDirRecursively('${srcPath}/${entry}', '${destPath}/${entry}');
        }
        else
        {
          sys.io.File.copy('${srcPath}/${entry}', '${destPath}/${entry}');
        }
      }
    }
    else 
    {
      throw srcPath + " doesn't exist or isn't a directory";
    }
  }

  public static function deleteDirRecursively(path:String) : Void
  {
    if (!FileSystem.exists(path))
    {
        throw 'Path ${path} doesn\'t exist';
    }
     
    if (!FileSystem.isDirectory(path))
    {
        throw 'Path ${path} isn\'t a directory';        
    }    
    
    var entries = FileSystem.readDirectory(path);
    for (entry in entries)
    {
    if (FileSystem.isDirectory('${path}/${entry}'))
    {
        deleteDirRecursively('${path}/${entry}');
    }
    else
    {
        FileSystem.deleteFile('${path}/${entry}');
    }
    }
    FileSystem.deleteDirectory(path);
    
  }

  public static function ensureDirExists(path:String) : Void
  {
    if (!FileSystem.exists(path))
    {
      throw path + " doesn't exist";
    }
    else if (!FileSystem.isDirectory(path))
    {
      throw path + " isn't a directory";
    }
  }
  
  /** If a directory exists, delete it. Recreate the directory. */
  public static function recreateDirectory(directory:String):Void
  {
    if (FileSystem.exists(directory))
    {
      // always clean/rebuild
      FileSystemExtensions.deleteDirRecursively(directory);
      FileSystem.createDirectory(directory);
    }
  }
  
  /** Get all files on a given path. Ignores .DS files/folders. */
  public static function getFiles(path:String) : Array<String>
  {
    var toReturn = new Array<String>();

    if (FileSystem.exists(path) && FileSystem.isDirectory(path))
    {
      var filesAndDirs = FileSystem.readDirectory(path);
      for (entry in filesAndDirs)
      {
        var relativePath = '${path}/${entry}';
        // Ignore .DS on Mac/OSX
        if (entry.indexOf(".DS") == -1 && !FileSystem.isDirectory(relativePath))
        {
          toReturn.push(relativePath);
        }
      }
    }

    return toReturn;
  }
}
