package nucleus.io;

import massive.munit.Assert;
import nucleus.io.FileSystemExtensions;
import sys.FileSystem;
import sys.io.File;
import test.helpers.Assert2;

class FileSystemExtensionTest
{
    private static inline var TEST_FILES_ROOT = "test/temp";
    private static inline var TEST_FILES_DIR = '${TEST_FILES_ROOT}/filesystemext';

    @Before
    public function createTestFilesDirectory()
    {
        FileSystem.createDirectory(TEST_FILES_DIR);
    }

    @After
    public function deleteTestFiles()
    {
        nucleus.io.FileSystemExtensions.deleteDirRecursively(TEST_FILES_DIR);
        FileSystem.deleteDirectory(TEST_FILES_DIR);
    }
    
    @Test
    public function copyDirRecursivelyCopiesSubDirectoriesAndFiles()
    {
        // Set up a directory tree of files/folders to delete        
        var srcDir:String = '${TEST_FILES_ROOT}/source';
        FileSystem.createDirectory(srcDir);
        File.saveContent('${srcDir}/hi.txt', "root hi.txt");
        
        FileSystem.createDirectory('${srcDir}/abc');
        File.saveContent('${srcDir}/abc/hi.txt', "abc hi.txt");
        
        FileSystem.createDirectory('${srcDir}/def');
        File.saveContent('${srcDir}/def/hi.txt', "def hi.txt");
                
        FileSystem.createDirectory('${srcDir}/def/ghi');
        File.saveContent('${srcDir}/def/ghi/hi.txt', "ghi hi.txt");
        
        // Copy directory and verify all files/folders copied over.
        var destDir = '${TEST_FILES_ROOT}/destDir1';
        FileSystemExtensions.copyDirRecursively(srcDir, destDir);
        
        AssertDirExists(destDir);
        AssertDirExists('${destDir}/abc');
        AssertDirExists('${destDir}/def');
        AssertDirExists('${destDir}/def/ghi');
        
        var content:String = AssertFileExists('${destDir}/hi.txt');
        Assert.isTrue(content == "root hi.txt");
        var content:String = AssertFileExists('${destDir}/abc/hi.txt');
        Assert.isTrue(content == "abc hi.txt");
        var content:String = AssertFileExists('${destDir}/def//hi.txt');
        Assert.isTrue(content == "def hi.txt");
        var content:String = AssertFileExists('${destDir}/def/ghi/hi.txt');
        Assert.isTrue(content == "ghi hi.txt");
    }
    
    @Test
    public function copyDirRecursivelyThrowsIfPathIsFile()
    {
        File.saveContent('${TEST_FILES_ROOT}/hi', "this is a txt file, not a directory!");
        var message:String = Assert2.throws(function()
        {
            FileSystemExtensions.copyDirRecursively('${TEST_FILES_ROOT}/hi', '${TEST_FILES_ROOT}/hee');
        });
        Assert.isTrue(message.indexOf("directory") > -1);
    }
    
    @Test
    public function copyDirRecursivelyThrowsIfPathDoesntExist()
    {
        var message:String = Assert2.throws(function()
        {
            FileSystemExtensions.copyDirRecursively('${TEST_FILES_ROOT}/doesntexist', '${TEST_FILES_ROOT}');
        });
        Assert.isTrue(message.indexOf("exist") > -1);
    }
    
    @Test
    public function deleteDirRecursivelyDeletesSubDirectoriesAndFiles()
    {
        
    }
    
    @Test
    public function ensureDirExistsThrowsIfDirectoryDoesntExist()
    {
        
    }   
    
    @Test
    public function ensureDirExistsThrowsIfDirectoryIsFile()
    {
        
    }
    
    @Test
    public function ensureDirExistsDoesntThrowIfDirectoryExists()
    {
        
    }
    
    @Test
    public function recreateDirectoryCreatesDirectoryIfItDoesntExist()
    {
        
    }
    
    @Test
    public function recreateDirectoryDeletesDirectoryIfItExists()
    {
        
    }
    
    @Test
    public function getFilesGetsFilesAndFoldersButIgnoresDsDirectory()
    {
        
    }
    
    @Test
    public function getFilesThrowsIfDirectoryDoesntExist()
    {
        
    }
    
    @Test
    public function getFilesThrowsIfPathIsAFile()
    {
        
    }
    
    // Assert that a file exists. Return its contents;
    private function AssertFileExists(fileName:String):String
    {
        Assert.isTrue(FileSystem.exists(fileName));
        Assert.isFalse(FileSystem.isDirectory(fileName));        
        return File.getContent(fileName);
    }
    
    private function AssertDirExists(path:String):Void
    {
        Assert.isTrue(FileSystem.exists(path));
        Assert.isTrue(FileSystem.isDirectory(path));        
    }
}