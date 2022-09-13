#*****************************************************************************
# Mouule: jcstudio.datetime
# Author: jclee95
# Chinese name: 李俊才
# Email: 291148484@163.com
# Author blog: https://blog.csdn.net/qq_28550263?spm=1001.2101.3001.5343
# Copyright Jack Lee. All rights reserved.
# Licensed under the MIT License.
#*****************************************************************************


class ValueError {
    ValueError(){
        throw "[Valueerror]: "
    }
    ValueError($s){
        throw "[Valueerror]: "+$s
    }
}

class StaticFuncs {
    static [System.Collections.ArrayList]range ([int]$a, [int]$b){
        $temp = [System.Collections.ArrayList]@();
        if($a -eq $b){
            return $temp;
        }
        elseif($a -lt $b){
            $i = $a;
            while ($i -lt $b) {
                $temp.Add($i);
                $i = $i + 1;
            }
            return $temp;
        }
        else{
            $i = $b;
            while ($i -lt $a) {
                $temp.Add($i);
                $i = $i + 1;
            }
            return $temp;
        }
    }

    static [System.Collections.ArrayList]range([int]$a){
        $temp = [System.Collections.ArrayList]@();
        $i = 0;
        while ($i -lt $a) {
            $temp.Add($i);
            $i = $i + 1;
        }
        return $temp
    }

    <# 返回某个月的天数 #>
    static [int]get_days([string]$yearmonth){
        $year, $month = $yearmonth.Split("/");
        $year = $year  -as [int];
        $month = $month  -as [int];
        $days = @{1=31; 3=31; 5=31; 7=31; 8=31; 10=31; 12=31; 4=30; 6=30; 9=30; 11=30};
        # 闰年
        if($year%4 -ne 0){
            $days[2] = 28
        }
        else{
            $days[2] = 29 
        }
        return $days[$month]
    }

    <# 判断某个月是否是大月（31天） #>
    static [bool]is_big_month([int]$month){
        if([StaticFuncs]::get_days($month) -eq 31){
            return $true;
        }
        else{
            return $false
        }
    }

    <# 返回日历表 #>
    static [string[]] get_calendar([string]$yearmonth) {
        $year, $month = $yearmonth.Split("/")
        $days = [StaticFuncs]::get_days($yearmonth)
        $calendar_list = [System.Collections.ArrayList]@();
    
        foreach ($i in [StaticFuncs]::range(1, $days+1)) {
            $temp_j = $i.ToString()
            if($i.ToString().Length -eq 1){
                $j = '0' + $temp_j
            }
            else{
                $j = $temp_j
            }
            $aday = $year + "/" + $month + "/" + $j
            $calendar_list.Add($aday)
        }
        return $calendar_list
    }

    static [string]next_month([int] $year, [int] $month){
        if($month -lt 12){
            return ($year.ToString() + "/0" +  ($month + 1).ToString());
        }
        elseif ($month -eq 12) {
            return ($year + 1).ToString() + "/" + "01"; 
        }
        else{
            [ValueError]::new("Month must be less than or equal to 12.");
        }
        return ""
    }

    <# date_begin 或 date_end 的格式如 2022/08/15 #>
    static [string[]] datelist([string]$date_begin, [string]$date_end) {
        $year_begin, $month_begin, $day_begin = $date_begin.Split("/");
        $year_end,   $month_end,   $day_end   = $date_end.Split("/");
        $date_list =  [System.Collections.ArrayList]@();

        $yearmonth = ($year_begin + $month_begin) -as [int];
        $yearmonth_end = ($year_end + $month_end) -as [int];


        while($yearmonth -le $yearmonth_end){
            
            $month_calendar = [StaticFuncs]::get_calendar($year_begin + "/" + $month_begin);
            foreach ($i in $month_calendar) {
                if (
                    ($i.Replace("/","") -as [int]) -ge ($date_begin.Replace("/","") -as [int]) 
                ) {
                    
                    if(
                        ($i.Replace("/","") -as [int]) -le ($date_end.Replace("/","") -as [int])
                    ){
                        
                        $date_list.Add($i);
                    }
                }
            }
            $yearmonth = [StaticFuncs]::next_month(
                $yearmonth.ToString().Substring(0,4) -as [int],
                $yearmonth.ToString().Substring(4,2) -as [int]
            )
            $year_begin = $yearmonth.Split("/")[0].ToString()
            $month_begin = $yearmonth.Split("/")[1].ToString()
            $yearmonth = $yearmonth.Replace("/","") -as [int]
        }
        return $date_list
    }
}

function Get-Today(){
    return (Get-Date).ToString().Split(" ")[0]
}

function Get-Present-Time() {
    return (Get-Date).ToString().Split(" ")[1]
}

<# 进位器状态枚举 #>
enum CarryEnum {
    CARRY = 1;    # 有进位
    NONE = 0;     # 无进退位
    BACK = 2;     # 有退位
}

<# 进位器 #>
class Carry{
    [int]$_value
    Carry(){
        $this._value = [CarryEnum].NONE;
    }
    Carry([CarryEnum]$b){
        $this._value = $b;
    }

    <# 标志进位 #>
    [void]set(){
        $this._value = [CarryEnum]::CARRY;
    }

    <# 标志退位 #>
    [void]set_back(){
        $this._value = [CarryEnum]::BACK;
    }

    <# 清空标志 #>
    [void]clear(){
        $this._value =[CarryEnum]::NONE;
    }

    <# 获取进位器状态 #>
    [int]get_state(){
        return $this._value;
    }
}

<#秒计数器#>
class Second{
    [int]$_value=0
    [Carry]$c;
    Second([int]$s){
        $this.c = [Carry]::new()
        $this.c.clear();
        if($s -lt 0){
            [ValueError]::new("Seconds must be greater than or equal to 0.")
        }elseif ($s -gt 59) {
            [ValueError]::new("Seconds must be less than or equal to 59.")
        }
        $this._value = $s;
    }
    <# 正向行走 #>
    [void]next(){
        # 已达 59
        if($this._value -ge 59){
            $this._value = 0;     # 置空
            $this.c.set();        # 标志进位
        }
        else{
            $this._value = $this._value + 1;
        }
        # Write-Host $this._value
    }

    <# 逆向行走 #>
    [void]last(){
        # 已到 0
        if($this._value -le 0){
            $this._value = 59;   # 置满
            $this.c.set_back();  # 标志退位
        }
        else{
            $this._value = $this._value - 1;
        }
        # Write-Host $this._value
    }

    [void]print(){
        $temp = $this._value.ToString();
        Write-Output $temp;
    }

    [string]get_value(){
        $s = $this._value.ToString();
        if($s.Length -eq 1){
            $s = "0" + $s;
        }
        return  $s;
        
    }
}

<# 分计数器 #>
class Minute {
    [int]$_value=0;               # 分针位
    [Carry]$c;                    # 进位
    [Second]$second;                   # 秒针位
    Minute([int]$m, [int]$s) {
        # 初始化分进退位标志引用对象
        $this.c = [Carry]::new();
        $this.c.clear();

        # 初始值校验
        if($m -lt 0){
            [ValueError]::new("Minutes must be greater than or equal to 0.")
        }elseif ($m -gt 59) {
            [ValueError]::new("Minutes must be less than or equal to 59.")
        }

        # 初始化秒位引用对象
        $this.second = [Second]::new($s);

        # 设置分初值
        $this._value = $m;
    }

    <# 正向行走（分针，即下一分钟） #>
    [void]next(){
        # 已达 59
        if($this._value -ge 59){
            $this._value = 0;     # 置空
            $this.c.set();        # 标志进位
        }
        else{
            $this._value = $this._value + 1;
        }
    }

    <# 逆向行走（分针，即上一分钟） #>
    [void]last(){
        # 已到 0
        if($this._value -le 0){
            $this._value = 59;   # 置满
            $this.c.set_back();  # 标志退位
        }
        else{
            $this._value = $this._value - 1;
        }
    }

    <# 正向行走（秒针，即下一秒） #>
    [void]next_second(){
        # 直接调用 Second 类的下一秒
        $this.second.next();
        
        # 判断进位
        if($this.second.c.get_state() -eq [CarryEnum]::CARRY){
            # 先完成进位
            $this.next();
            # 再将进位标志清空
            $this.second.c.clear()
        }
    }


    <# 逆向行走（秒针，即上一秒） #>
    [void]last_second(){
        # 直接调用 Second 类的上一秒
        $this.second.last();
        # 判断退位
        if($this.second.c.get_state() -eq [CarryEnum]::BACK){
            # 先完成退位
            $this.last();
            # 再将进位标志清空
            $this.second.c.clear()
        }
    }

    [void]print(){
        $temp = $this._value.ToString() + ":" + $this.second._value.ToString()
        Write-Output $temp;
    }

    [string]get_value(){
        $m = $this._value.ToString();
        if($m.Length -eq 1){
            $m = "0" + $m;
        }
        return  $m + ":" + $this.second.get_value();
        
    }

    [int]get_minute(){
        return $this._value;
    }

    [int]get_second(){
        return $this.second.get_value();
    }
}

<#时计数器#>
class Hour {
    [int]$_value=0;                    # 时针位
    [Carry]$c;                         # 进位
    [Minute]$minute;                   # 分针位（带秒位）

    # 使用当前的系统时间进行初始化
    Hour(){
        $h, $m, $s = (Get-Date).ToString().Split(" ")[1].Split(":");
        
        # 初始化秒位引用对象
        $this.minute = [Minute]::new($m, $s);
        
        # 设置小时初值
        $this._value = $h;
    }

    # 通过字符串表示的时间初始化，字符串形如 20:30:00
    Hour([string]$time){
        $h, $m, $s = $time.Split(":");

        # 初始化秒位引用对象
        $this.minute = [Minute]::new($m, $s);
        
        # 设置小时初值
        $this._value = $h;
    }

    # 指定具体时间进行初始化：分别指定时、分、秒
    Hour([int]$h, [int]$m, [int]$s) {
        # 初始化分进退位标志引用对象
        $this.c = [Carry]::new();
        $this.c.clear();

        # 初始值校验
        if($h -lt 0){
            [ValueError]::new("Hours must be greater than or equal to 0.")
        }elseif ($h -gt 59) {
            [ValueError]::new("Hours must be less than or equal to 59.")
        }

        # 初始化秒位引用对象
        $this.minute = [Minute]::new($m, $s);

        # 设置小时初值
        $this._value = $h;
    } 

    <# 正向行走（时针，即下一小时） #>
    [void]next(){
        # 已达 59
        if($this._value -ge 59){
            $this._value = 0;     # 置空
            $this.c.set();        # 标志进位
        }
        else{
            $this._value = $this._value + 1;
        }
    }

    <# 逆向行走（时针，即上一小时） #>
    [void]last(){
        # 已到 0
        if($this._value -le 0){
            $this._value = 59;   # 置满
            $this.c.set_back();  # 标志退位
        }
        else{
            $this._value = $this._value - 1;
        }
    }

    <# 正向行走（分针，即下一分钟） #>
    [void]next_minute() {
        # 掉用分的下一分钟方法
        $this.minute.next();
        # 只需要观察分种是否进位
        if($this.minute.c._value -eq [CarryEnum]::CARRY){
            # 先进位到小时，即求下一小时
            $this.next();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }


    <# 逆向行走（分针，即上一分钟） #>
    [void]last_minute() {
        # 掉用分的上一分钟方法
        $this.minute.last();
        # 只需要观察分种是否退位
        if($this.minute.c._value -eq [CarryEnum]::BACK){
            # 先求上一小时
            $this.last();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }


    <# 正向行走（秒针，即下一秒） #>
    [void]next_second() {
        # 掉用分的下一秒方法
        $this.minute.next_second();
        # 只需要观察分种是否进位
        if($this.minute.c._value -eq [CarryEnum]::CARRY){
            # 先进位到小时，即求下一小时
            $this.next();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }

    <# 逆向行走（秒针，即上一秒） #>
    [void]last_second() {
        # 调用分钟上一秒方法
        $this.minute.last_second()
        # 只需要观察分种是否退位
        if($this.minute.c._value -eq [CarryEnum]::BACK){
            # 先求上一小时
            $this.last();
            # 再清空分钟的进位标志
            $this.minute.c.clear()
        }
    }

    [void]print(){
        $temp = $this._value.ToString() + ":" + $this.minute._value.ToString() + ":" + $this.minute.s._value.ToString();
        Write-Output $temp;
    }

    [string]get_value(){
        $h = ($this._value).ToString();
        if($h.Length -eq 1){
            $h = "0" + $h;
        }
        return $h + ":" + $this.minute.get_value();
    }

    [int]get_hour(){
        return $this._value;
    }

    [int]get_minute(){
        return $this.minute.get_minute();
    }

    [int]get_second(){
        return $this.minute.get_second();
    }

}

<# 日期计数器 #>
class Date {
    [int]$year
    [int]$month
    [int]$day

    # 初始化为当前日期
    Date(){
        $y, $m, $d = (Get-Date).ToString().Split(" ")[0].Split("/");

        $this.year = $y;
        $this.month = $m;
        $this.day = $d;

        # 数据校验
        $this._d_check();
    }

    # 以分别指定的指定年、月、日的形式初始化
    Date([int]$y, [int]$m, [int]$d){
        $this.year = $y;
        $this.month = $m;
        $this.day = $d;

        # 数据校验
        $this._d_check();
    }

    # 以字符串初始化指定日期，例如 `2022/05/26`
    Date([string]$date){
        $yyyy,$mm,$dd = $date.Split("/");
        $this.year = $yyyy -as [int];
        $this.month = $mm -as [int];
        $this.day = $dd -as [int];

        # 数据校验
        $this._d_check();
    }

    _d_check(){
        if ($this.year -le 0) {
            Write-Host ("year = "+$this.year);
            [ValueError]::new("Year must be greater than 0.")
        }
        if ($this.month -le 0) {
            [ValueError]::new("Month must be greater than 0.")
        }
        if ($this.day -le 0) {
            [ValueError]::new("Day must be greater than 0.")
        }
    }

    <# 返回当前年份是否是闰年 #>
    [bool]is_leap_year(){
        if(($this.year % 4) -eq 0){
            return $true;
        }else{
            return $false;
        }
    }

    <# 下一天（明天），返回一个新的 Date 对象 #>
    [Date]next(){
        $yearmonth = $this.year.ToString() + "/" + $this.month.ToString();
        $days = [StaticFuncs]::get_days($yearmonth);
        
        if($this.day -lt $days) {
            $next_day = ($this.day +1).ToString();
            $next_month = $this.month.ToString();
            $next_year = $this.year.ToString();
            return [Date]::new($next_year, $next_month, $next_day);
        }
        elseif ($this.day -eq $days) {
            $next_day = "01";
            if($this.month -lt 1){
                [ValueError]::new("An impossible year, which is less than 1.")
            }
            elseif($this.month -lt 12) {
                $next_month = ($this.month+1).ToString();
                $this_year = $this.year.ToString();
                return [Date]::new($this_year, $next_month, $next_day);
            }
            elseif($this.month -eq 12){
                $next_month = "01";
                $next_year = ($this.year + 1).ToString();
                return [Date]::new($next_year, $next_month, $next_day);
            }
            else{
                [ValueError]::new("An impossible year, which is greater than 12.")
            }
            
        }
        else{
            [ValueError]::new("An impossible date, which is greater than the number of days in the month.")
        }
        return [Date]::new(0, 13, 32);
    }

    <# 上一天（昨天），返回一个新的 Date 对象 #>
    [Date]last(){
        if ($this.day -ne 1) {

            $last_day = ($this.day - 1).ToString()
            $last_month = $this.month.ToString();
            $last_year = $this.year.ToString();

            return [Date]::new($last_year, $last_month, $last_day)
        }
        # $this.day -eq 1
        else{
            if($this.month -ne 1){

                $last_month = ($this.month -1).ToString();
                if($last_month.Length -eq 1){
                    $last_month = '0' + $last_month;
                }

                $last_year = $this.year.ToString();
                $yearmonth = $last_year + "/" + $last_month;
                $days = [StaticFuncs]::get_days($yearmonth);
                $last_day = $days.ToString();

                return [Date]::new($last_year, $last_month, $last_day)
            }
            # $this.month -eq 1
            else{
                $last_month = "12";
                $last_year = ($this.year-1).ToString();
                $yearmonth = $this.year.ToString() + "/" + $this.month.ToString();
                $days = [StaticFuncs]::get_days($yearmonth);
                $last_day = $days.ToString();
                return [Date]::new($last_year, $last_month, $last_day);
            }
        }
    }

    <# n 天前，返回一个新的 Date 对象 #>
    [Date]ndays_ago([int]$n){
        $temp = [Date]::new($this.year, $this.month, $this.day);
        foreach ($i in [StaticFuncs]::range(0, $n)) {
            $temp = $temp.last();
        }
        return $temp
    }

    <# n 天后，返回一个新的 Date 对象 #>
    [Date]ndays_later([int]$n){
        $temp = [Date]::new($this.year, $this.month, $this.day);
        foreach ($i in [StaticFuncs]::range(0, $n)) {
            $temp = $temp.next();
        }
        return $temp
    }

    [string]get_value(){
        $m = $this.month.ToString()
        if($m.Length -eq 1){
            $m = "0" + $m;
        }
        $d = $this.day.ToString()
        if($d.Length -eq 1){
            $d = "0" + $d;
        }
        return $this.year.ToString() + "/" + $m + "/" + $d;
    }

    [string]print(){
        $temp = $this.year.ToString() + "/" + $this.month.ToString() + "/" + $this.day.ToString();
        Write-Host $temp;
        return $temp
    }
}

<# 日期时间计数器 #>
class DateTime {
    [Date]$date
    [Hour]$time

    # 例如字符串 `2022/05/26 20:59:25`
    DateTime([string]$dtm){
        $d, $t = $dtm.Split(" ");
        $this.date = [Date]::new($d);
        $this.time = [Date]::new($t);
    }

    <# 上一秒，可用作秒倒计时器 #>
    [void] last_second(){
        $this.time.last_second();
        # 若产生退位
        if($this.time.c._value -eq [CarryEnum]::BACK){
            # 完成从时间到日期的退位
            $this.date.last();
            # 清空退位标志
            $this.time.c.clear();
        }
    }

    <# 下一秒，可用作秒计时器 #>
    [void] next_second(){
        $this.time.next_second();
        # 若产生进位
        if($this.time.c._value -eq [CarryEnum]::CARRY){
            # 完成从时间到日期的进位
            $this.date.next();
            # 清空进位标志
            $this.time.c.clear();
        }
    }

    <# 上一分钟，可用作分倒计时器 #>
    [void] last_minute(){
        $this.time.last_minute();
        # 若产生退位
        if($this.time.c._value -eq [CarryEnum]::BACK){
            # 完成从时间到日期的退位
            $this.date.last();
            # 清空退位标志
            $this.time.c.clear();
        }
    }

    <# 下一分钟，可用作分计时器 #>
    [void] next_minute(){
        $this.time.next_minute();
        # 若产生进位
        if($this.time.c._value -eq [CarryEnum]::CARRY){
            # 完成从时间到日期的进位
            $this.date.next();
            # 清空进位标志
            $this.time.c.clear();
        }
    }

    <# 上一小时，可用作小时倒计时器 #>
    [void] last_hour(){
        $this.time.last();
        # 若产生退位
        if($this.time.c._value -eq [CarryEnum]::BACK){
            # 完成从时间到日期的退位
            $this.date.last();
            # 清空退位标志
            $this.time.c.clear();
        }
    }

    <# 下一小时，可用作小时计时器 #>
    [void] next_hour(){
        $this.time.next();
        # 若产生进位
        if($this.time.c._value -eq [CarryEnum]::CARRY){
            # 完成从时间到日期的进位
            $this.date.next();
            # 清空进位标志
            $this.time.c.clear();
        }
    }

    <# 前一天 #>
    [void] last_day(){
        $this.date.last();
    }

    <# 后一天 #>
    [void] next_day(){
        $this.date.next();
    }

    <# 下个月这个时候 #>
    [void] next_month(){
        # 如果本月是2月
        if($this.date.month -eq 2) {
            if($this.date.is_leap_year()){
                $this.date = $this.date.ndays_later(29);
            }else{
                $this.date = $this.date.ndays_later(28);
            }
        }
        # 如果本月是31天的大月
        elseif([StaticFuncs]::is_big_month($this.date.month)) {
            $this.date = $this.date.ndays_later(31);
        }
        # 否则是30天的小月
        else{
            $this.date = $this.date.ndays_later(30);
        }
    }

    <# 下一年这个时候 #>
    [void] next_year(){
        if($this.date.year.is_leap_year()){
            if($this.date.year -eq 2){
                if($this.date.day -eq 29){
                    $this.date.day = 28;
                }
            }
        }
        if($this.date.year -eq 12){
            $this.date.year = 0;
        }else{
            $this.date.year = $this.date.year + 1;
        }
    }

    [string]get_value(){
        return $this.date.get_value() + " " + $this.time.get_value();
    }

}


# 测试 datelist 函数功能
# $a = [StaticFuncs]::datelist("2022/02/05", "2022/03/06")
# echo "a = $a"

# 测试 进退位器
# $a = [CarryEnum]::CARRY;
# Write-Host $a

# 测试 秒计时器 功能
# $s = [Second]::new(59);
# $s.next();
# $s.print()


# 测试 分计时器 功能
# $m = [Minute]::new(0,0);
# $m.last_second();
# $m.print()

# 测试小时计时器功能
# $h = [Hour]::new(0,0,0)
# $h.last();
# $h.print()


# 测试 日期器 功能
# $data = [Date]::new("2020/01/01");
# $next = $data.last().last().next().next();
# $next = $data.ndays_ago(1);
# $next.get_value();

