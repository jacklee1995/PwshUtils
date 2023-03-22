#*****************************************************************************
# Copyright Jack Lee. All rights reserved.
# Licensed under the MIT License.
# Email: 291148484@163.com
# https://blog.csdn.net/qq_28550263?spm=1001.2101.3001.5343
#*****************************************************************************

class Logger {
    [string]$Lines
    [string]$SavePath
    [bool]$log

    Logger([string]$SavePath){
        $this.Lines = '';
        $this.log = $True;
        $this.SavePath = $SavePath;
    }

    Logger([string]$SavePath, [bool]$log){
        $this.Lines = '';
        $this.log = $log;
        $this.SavePath = $SavePath;
    }
    
    [string]getDataTime(){
        return  Get-Date -Format 'yyyy-MM-dd hh:mm:ss'
    }

    [void]writeLog($color,$logmessages)
    {
        write-host -ForegroundColor $color $logmessages
        $logmessages >> $this.SavePath
    }

    [void]Trace($s){
        $msg = $this.getDataTime() + " [TRACE] " + $s
        if ($this.log){
            $this.writeLog('DarkGreen',$msg)
        }
    }

    [void]Info($s){
        $msg = $this.getDataTime() + " [INFO] " + $s
        if ($this.log){
            $this.writeLog('Gray',$msg)
        }
    }

    [void]Debug($s){
        $msg = $this.getDataTime() + " [DEBUG] " + $s
        if ($this.log){
            $this.writeLog('DarkBlue',$msg)
        }
    }

    [void]Warn($s){
        $msg = $this.getDataTime() + " [WARN] " + $s
        if ($this.log){
            $this.writeLog('Yellow',$msg)
        }
    }

    [void]Error($s){
        $msg = $this.getDataTime() + " [ERROR] " + $s
        if ($this.log){
            $this.writeLog('Red',$msg)
        }
    }

    [void]Critical($s){
        $msg = $this.getDataTime() + " [CRITICAL] " + $s
        if ($this.log){
            $this.writeLog('Magenta',$msg)
        }
    }
}
