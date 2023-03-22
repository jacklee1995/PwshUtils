<#
@Auth: Jack Lee;
@Email: 291148484@163.com;
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>
using namespace System;
using namespace System.Collections;
using namespace System.Collections.Generic;

class Path{
    static [string]abspath([string]$path){
        <#
        Return absolute path

        Params
        ======
        - $path [string] Path of file.
        #>
        return Resolve-Path -Path $path; 
    }

    static [string]basename([string]$path){
        <#
        Returns the file name from the absolute path value represented by a string.

        Params
        ======
        - $path [string] The absolute path of the file.
        - $extension [bool] Whether to remove the extension.
        #>
        return  [System.IO.Path]::GetFileName($path)
    }
    static [string]basename([string]$path,[bool]$extension=$True){
        if($extension){
            return  [System.IO.Path]::GetFileName($path)
        }
        else{
            return [System.IO.Path]::GetFileNameWithoutExtension($path)
        }
    }

    static [string]rootname([string]$path){
        <# Return root directory information #>
        return [System.IO.Path]::GetPathRoot($path)
    }

    static [string]get_temp_path(){
        <# Returns the path of the current system temporary directory. #>
        return [System.IO.Path]::GetTempPath()
    }

    static [string]get_dirpath([string]$path){
        <#
        Returns the absolute path of the parent folder.

        Params
        ======
        - $path [string] Represents the absolute path of a file.
        #>
	    return [System.IO.Path]::GetDirectoryName($path)
	}

    static [string]get_dirname([string]$path){
        <#
        Returns the name of the folder where the file or subfolder is located.

        Params
        ======
        - $path [string] Represents the absolute path of a file.
        #>
        return [Path]::basename([System.IO.Path]::GetDirectoryName($path))
    }
    static [string]get_dirname([string]$path, [bool]$absolute=$True){
        if($absolute){
            return [System.IO.Path]::GetDirectoryName($path)
        }
        else{
            return [Path]::basename([System.IO.Path]::GetDirectoryName($path))
        }
    }

    static [bool] exists([string]$path){
        <#
        Determine whether the specified file or directory exists.

        Params
        ======
        - $path [string] The path value represented by a string.

        Returns
        =======
        - $True  exist.
        - $False non-existent.
        #>
        return Test-Path -Path $path
    }

    static [string]relpath([string]$relativeTo, [string]$path){
        <#
        Returns the relative path from one path to another.

        Params
        ======
        - $relativeTo [string] The source path relative to the result. This path is always treated as a directory.
        - $path [string] Target path.
        Returns
        =======
        [string] Relative path, or path if the paths do not share the same root.

        Exceptions
        ==========
        - [ArgumentNullException] The value of $relativeTo or $path is null。
        - [ArgumentException] $relativeTo or $path is actually null.
        #>
        return [System.IO.Path]::GetRelativePath($relativeTo, $path)
    }

    static [string[]] get_items([string]$path){
        <#
        Get all subprojects in the specified directory. 

        Params
        ======
        - $path [string] The path value represented by a string.
        - $sift [string] Optional, used to indicate the filtered content.
          * When the parameter value is' file', only the absolute path of 
            the files in it will be returned.
          * When the parameter value is' folder', the absolute path of the 
            directory (folder) in it is returned.

        Notes
        =====
          This method only gets the current level of subdirectories, while 
          the folders containing subdirectories will not be traversed.
          If you need to recursively obtain all descendants directories, 
          you should consider using `get_descendants()` method instead.
        #>
        $item_obj = Get-ChildItem $path |  Sort-Object
        $ary = [ArrayList]::new()
        foreach ($item in $item_obj){
            $ary.Add($item.ToString())
        }
        return $ary
    }
    static [string[]] get_items([string]$path, [string]$sift){
        if($sift -eq 'file'){
            $files = Get-ChildItem $path | Where-Object {$_.PSIsContainer -eq $False} | Sort-Object;
            $ary = [ArrayList]::new()
            foreach ($item in $files){
                $ary.Add($item.ToString())
            }
            return $ary
        }elseif ($sift -eq 'folder') {
            $folders = Get-ChildItem $path | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object;
            $ary = [ArrayList]::new()
            foreach ($item in $folders){
                $ary.Add($item.ToString())
            }
            return $ary
        }else{
            $item_obj = Get-ChildItem $path |  Sort-Object
            $ary = [ArrayList]::new()
            foreach ($item in $item_obj){
                $ary.Add($item.ToString())
            }
            return $ary
        }
    }

    static [string[]] get_descendants([string]$path){
        <#
        Get all items in the specified directory, and recursively traverse all descendant folders.

        Params
        ======
        - $path [string] The path value represented by a string.
        - $sift [string] Optional, used to indicate the filtered content.
          * When the parameter value is' file', only the absolute path of the files in it will be returned.
          * When the parameter value is' folder', the absolute path of the directory (folder) in it is returned.
        #>
        $ary = [ArrayList]::new();
        $item_obj = Get-ChildItem $path |  Sort-Object; # current directory
        foreach ($item in $item_obj){
            if([Path]::is_dirname($item)){
                $sub_ary = [Path]::get_descendants($item);
                $ary.AddRange($sub_ary);
            }
            else{
                $ary.Add($item);
            }
        }
        return $ary
    }
    static [string[]] get_descendants([string]$path, [string]$sift){
        $files = Get-ChildItem $path | Where-Object {$_.PSIsContainer -eq $False} | Sort-Object;
        $folders = Get-ChildItem $path | Where-Object {$_.PSIsContainer -eq $True} | Sort-Object;
        $ary = [ArrayList]::new()
        # only file
        if($sift -eq 'file'){
            if($null -ne $files){
                foreach ($file in $files){
                    $ary.Add($file)
                }
            }
            foreach ($item in $folders){
                $ary.AddRange([Path]::get_descendants($item,'file'))
            }
        }
        # only dir
        elseif ($sift -eq 'folder') {
            if($null -ne $folders){
                foreach ($item in $folders){
                    $ary.Add($item);
                    $ary.AddRange([Path]::get_descendants($item,'folder'))
                }
            }
        }
        # all
        else{
            $item_obj = Get-ChildItem $path |  Sort-Object; # current directory
            foreach ($item in $item_obj){
                if([Path]::is_dirname($item)){
                    $sub_ary = [Path]::get_descendants($item);
                    $ary.AddRange($sub_ary);
                }
                else{
                    $ary.Add($item);
                }
            }
        }
        return $ary
    }

    static [string[]]filter_files([string]$path, [string]$sub_string){
        <#
        Filter the files containing the specified string from the specified directory.

        Params
        ======
        - $path [string] 
        - $sub_string [string] 
        - $recursion [bool] Recursively search all descendant directories, defaulf $False
        #>
        $ary = [ArrayList]::new();
        foreach ($item in [Path]::get_items($path,'file')) {
            if([Path]::basename($item).Contains($sub_string)){
                $ary.Add($item)
            }
        }
        return $ary
    }
    static [string[]]filter_files([string]$path, [string]$sub_string, [bool]$recursion){
        $ary = [ArrayList]::new();
        if($recursion){
            $all = [Path]::get_descendants($path,'file')
        }else{
            $all = [Path]::get_items($path,'file')
        }
        
        foreach ($item in $all) {
            if([Path]::basename($item).Contains($sub_string)){
                $ary.Add($item)
            }
        }
        return $ary
    }

    static [string[]]filter_dirs([string]$path, [string]$sub_string){
        $ary = [ArrayList]::new();
        foreach ($item in [Path]::get_items($path,'folder')) {
            if([Path]::basename($item).Contains($sub_string)){
                $ary.Add($item)
            }
        }
        return $ary
    }
    static [string[]]filter_dirs([string]$path, [string]$sub_string, [bool]$recursion){
        $ary = [ArrayList]::new();
        if($recursion){
            $all = [Path]::get_descendants($path,'folder')
        }else{
            $all = [Path]::get_items($path,'folder')
        }
        
        foreach ($item in $all) {
            if([Path]::basename($item).Contains($sub_string)){
                $ary.Add($item)
            }
        }
        return $ary
    }

    static [System.DateTime]get_modify_time([string]$path){
        <#
        Returns the last modification time of a file or directory.

        Params
        ======
        - $path [string] The path value represented by a string.
        #>
        return [System.IO.DirectoryInfo]::new($path).LastWriteTime
    }

    static [bool]is_dirname([string]$path){
        <#
        Specifies whether the path represents a folder.

        Params
        ======
        - $path [string] The path value represented by a string.

        Returns
        =======
         - $True  If the specified path represents a folder
         - $False Versa

        Notes
        =====
          In most cases, you can also use the command: 
          `Test-Path -Path $path -PathType leaf `, 
          However, using the `Test-Path` command can't deal with 
          the case that the file name contains "[" as the powershell 
          compiler will throw back an error in this case.
        #>
        return [Path]::has_attributes($path,"Directory")
    }

    static [bool]is_filename([string]$path){
        <#
        Returns whether the specified path value represents a file.

        Params
        ======
        - $path The path value represented by a string.

        Notes
        =====
          In most cases, you can also use the command: 
          `Test-Path -Path $path -PathType leaf `, 
          However, using the `Test-Path` command can't deal with 
          the case that the file name contains "[" as the powershell 
          compiler will throw back an error in this case.
        #>
        return -not [Path]::has_attributes($path,"Directory")
    }

    static [bool]is_newer_than($path, $time){
        <#
        Test whether the time of a file is before the specified date.

        Params
        ======
        - $path [string] The path value represented by a string.
        - $time A point-in-time string, such as "July 13, 2009"

        Returns
        =======
        - $True  If the modification time of the specified file is newer than this point in time;
        - $False Versa。
        #>
        return Test-Path -Path $path -NewerThan $time
    }

    static [bool]is_empty([string]$path){
        <#
        The folder is not empty, or the specified path is a file.

        Params
        ======
        - $path [string] The path value represented by a string.

        Retuens
        =======
        - $True  Folder is empty.
        - $False The folder is not empty, or the specified path is a file.
        #>
        if([Path]::is_dirname($path)){
            if((Get-ChildItem $path).count -eq 0){
                return $True
            }
            else{
                return $False
            }
        }
        else{
            write-host -ForegroundColor Yellow "Warning: The actual parameter of the variable `$path is a file name while a folder name is expected. "
            return $False
        }
    }

    static [bool]is_abs([string]$path){
        <# 
        Determine whether the path value represents an absolute path.

        Params
        ======
        - $path [string] The path value represented by a string.

        Retuens
        =======
        - $True  Is an absolute path.
        - $False Versa.
        #>
        return Split-Path -Path $path -IsAbsolute
    }

    static [string[]]get_attributes([string]$path){
        <#
        Gets the operator of attribute description of the directory.
        #>
        return [System.IO.File]::GetAttributes($path).ToString().Split(", ")
    }
    static [bool]has_attributes([string]$path, [string]$attributes){
        <#
        Returns whether the file or directory contains an attribute descriptor.

        Params
        ======
        - $path [string] The path value represented by a string.
        - $attributes [string] Represents an attribute descriptor of a directory. The value of $attributes could be:
            * Archive 此文件标记为包含在增量备份操作中。 每当修改文件时，Windows 会设置该属性，并且在增量备份期间处理文件时，备份软件应进行清理该属性。
            * Compressed 此文件是压缩文件。
            * Device 留待将来使用。
            * Directory 此文件是一个目录。 Directory 在 Windows、Linux 和 macOS 上受支持。
            * Encrypted 此文件或目录已加密。 对于文件来说，表示文件中的所有数据都是加密的。 对于目录来说，表示新创建的文件和目录在默认情况下是加密的。
            * Hidden 文件是隐藏的，因此没有包括在普通的目录列表中。 Hidden 在 Windows、Linux 和 macOS 上受支持。
            * IntegrityStream 文件或目录包括完整性支持数据。 在此值适用于文件时，文件中的所有数据流具有完整性支持。 此值将应用于一个目录时，所有新文件和子目录在该目录中和默认情况下应包括完整性支持。
            * Normal 该文件是没有特殊属性的标准文件。 仅当其单独使用时，此特性才有效。 Normal 在 Windows、Linux 和 macOS 上受支持。
            * NoScrubData 文件或目录从完整性扫描数据中排除。 此值将应用于一个目录时，所有新文件和子目录在该目录中和默认情况下应不包括数据完整性。
            * NotContentIndexed 将不会通过操作系统的内容索引服务来索引此文件。
            * Offline 此文件处于脱机状态， 文件数据不能立即供使用。
            * ReadOnly 文件为只读文件。 ReadOnly 在 Windows、Linux 和 macOS 上受支持。 在 Linux 和 macOS 上，更改 ReadOnly 标记是权限操作。
            * ReparsePoint 文件包含一个重新分析点，它是一个与文件或目录关联的用户定义的数据块。 ReparsePoint 在 Windows、Linux 和 macOS 上受支持。
            * SparseFile 此文件是稀疏文件。 稀疏文件一般是数据通常为零的大文件。
            * System 此文件是系统文件。 即，该文件是操作系统的一部分或者由操作系统以独占方式使用。
            * Temporary 文件是临时文件。 临时文件包含当执行应用程序时需要的，但当应用程序完成后不需要的数据。 文件系统尝试将所有数据保存在内存中，而不是将数据刷新回大容量存储，以便可以快速访问。 当临时文件不再需要时，应用程序应立即删除它。
            
        Retuens
        =======
        - $True  Includes.
        - $False Not includes.

        #>
        return [Path]::get_attributes($path).Contains($attributes)
    }
    
    static [int64]$counter;
    static [int64]get_size([string]$path){
        <#
        Returns the file size, or an error if the file does not exist.

        Params
        ======
        - $path [string] The path value represented by a string.
        #>
        [Path]::counter = -1;
        return [Path]::get_size($path,[Path]::counter)
    }

    static [int64]get_size([string]$path,[string]$ParentId){
        $count_size = 0;
        $file_infos = Get-ChildItem $path;
        # If it is a file, directly return the file size.
        if($file_infos.Attribute -eq 'Archive'){
            write-host $path+" is a file."
            $count_size = $count_size + $file_infos.Length;
        }
        # If it is a directory, the total size is calculated recursively.
        else{
            $count = $file_infos.Count;
            for ($i = 0; $i -lt $file_infos.Count; $i++) {
                $child = $file_infos[$i];
                [Path]::counter = [Path]::counter+1; # Each one is assigned an ID separately.
                $ID = [Path]::counter;
                
                # If it is a file, the size is accumulated.
                if([Path]::is_filename($child)){
                    $count_size =  $count_size + $child.Length;
                }
                # If it is a directory, continue to recursively accumulate the size.
                else{
                    $count_size =  $count_size + [Path]::get_size($child,$ID)
                }
                # Progress bar display
                $percent = $i / $count;  # Calculate the percentage by subentry.
                if($ParentId -eq -1){
                    Write-Progress -ID $ID -Activity ("Total counts "+$count.ToString()+"bytes of path: "+$child.ToString()) -Status "$percent% completed." -PercentComplete $percent;
                }else{
                    Write-Progress -ID $ID -ParentId $ParentId -Activity ("Total counts "+$count.ToString()+"bytes of path: "+$child.ToString()) -Status "$percent% completed." -PercentComplete $percent;
                }
            }
        }
        return $count_size
    }
    
    static [string]join($path, $childpath){
        <# 
        Connect the directory and file name into a path.

        Params
        ======
        - $path [string] The path value represented by a string.
        - $childpath [string] childpath path value represented by a string.

        #>
        return Join-Path -Path $path -ChildPath $childpath
    }
    
    static [string[]]split([string]$path){
        <#
        Divide the path into two parts: dirname and basename.

        Params
        ======
        - path [string] The path value represented by a string.

        Returns
        =======
        - $dirname   The absolute path of the folder.
        - $basename  Subfile or subdirectory name
        #>
        $dirname = Split-Path -Path $path -Leaf;
        $basename = Split-Path -Path $path;
        return $dirname,$basename
    }
    
    static [string[]]get_enviroment(){
        return [Environment]::GetEnvironmentVariable('Path', 'Machine')
    }

    static [void]set_enviroment($path){
        [Environment]::SetEnvironmentVariable('Path', $path,'Machine')
    }
    
    static [void]set_enviroment($path,$env_var_target){
        if($env_var_target -eq 'Machine'){
            [Environment]::SetEnvironmentVariable('Path', $path,'Machine')
        }
        elseif($env_var_target -eq 'User'){
            [Environment]::SetEnvironmentVariable('Path', $path,'User')
        }
        else{
            write-host -ForegroundColor Red "ValueError: The value of variable  `"`$env_var_target`" can only be one of 'Machine' or 'User'." 
        }   
    }

    static [void]delete([string]$path){
        <#
        Delete the file or directory corresponding to the specified path.

        Params
        ======
        - path [string] The path value represented by a string.

        #>
        Remove-Item $path;
    }
    
    static [void]make($path){
        <#
        Create a series of folders according to the given path.

        Params
        ======
        - path [string] The path value represented by a string.

        #>
        New-Item -Path ([Path]::dirname($path, $True)) -Name ([Path]::basename($path)) -ItemType "directory" 
    }
}
