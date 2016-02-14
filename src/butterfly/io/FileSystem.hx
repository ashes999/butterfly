package butterfly.io;

// static class
class FileSystem
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
}
