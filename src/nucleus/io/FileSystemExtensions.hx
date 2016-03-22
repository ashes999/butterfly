package nucleus.io;

import sys.FileSystem;

// static class
class FileSystemExtensions
{
  public static function copyDirRecursively(srcPath:String, destPath:String) : Void
  {
    if (!sys.FileSystem.exists(destPath)) {
      sys.FileSystem.createDirectory(destPath);
    }

    if (sys.FileSystem.exists(srcPath) && sys.FileSystem.isDirectory(srcPath))
    {
      var entries = sys.FileSystem.readDirectory(srcPath);
      for (entry in entries) {
        if (sys.FileSystem.isDirectory('${srcPath}/${entry}')) {
          sys.FileSystem.createDirectory('${srcPath}/${entry}');
          copyDirRecursively('${srcPath}/${entry}', '${destPath}/${entry}');
        } else {
          sys.io.File.copy('${srcPath}/${entry}', '${destPath}/${entry}');
        }
      }
    } else {
      throw srcPath + " doesn't exist or isn't a directory";
    }
  }

  public static function deleteDirRecursively(path:String) : Void
  {
    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
    {
      var entries = sys.FileSystem.readDirectory(path);
      for (entry in entries) {
        if (sys.FileSystem.isDirectory('${path}/${entry}')) {
          deleteDirRecursively('${path}/${entry}');
          sys.FileSystem.deleteDirectory('${path}/${entry}');
        } else {
          sys.FileSystem.deleteFile('${path}/${entry}');
        }
      }
    }
  }

  public static function ensureDirExists(path:String) : Void
  {
    if (!sys.FileSystem.exists(path)) {
      throw path + " doesn't exist";
    } else if (!sys.FileSystem.isDirectory(path)) {
      throw path + " isn't a directory";
    }
  }
  
  /** If a directory exists, delete it. Recreate the directory. */
  public static function recreateDirectory(directory:String):Void {
    if (sys.FileSystem.exists(directory)) {
      // always clean/rebuild
      FileSystemExtensions.deleteDirRecursively(directory);
      sys.FileSystem.createDirectory(directory);
    }
  }
  
  /** Get all files on a given path. Ignores .DS files/folders. */
  public static function getFiles(path:String) : Array<String>
  {
    var toReturn = new Array<String>();

    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path)) {
      var filesAndDirs = sys.FileSystem.readDirectory(path);
      for (entry in filesAndDirs) {
        var relativePath = '${path}/${entry}';
        // Ignore .DS on Mac/OSX
        if (entry.indexOf(".DS") == -1 && !sys.FileSystem.isDirectory(relativePath)) {
          toReturn.push(relativePath);
        }
      }
    }

    return toReturn;
  }
}
