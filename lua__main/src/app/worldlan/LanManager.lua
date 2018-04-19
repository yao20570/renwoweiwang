-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-07 10:43:02 星期二
-- Description: 语言文字管理类
-----------------------------------------------------

-- 获取多国化的文本内容
-- nFileIndex（int）：负责人对应的文件下标
-- nId（int）：当前的内容的下标
function getConvertedStr( nFileIndex, nId )
    -- 初始化内容数据
    initLanguageContent()

    local t = nil
    local nLanType = getCurLanType()
    if (nLanType == 1 or nLanType == 2) then -- 中文简体 or 中文繁体
        if(nFileIndex == 1) then
            t = LanStr1
        elseif(nFileIndex == 2) then
            t = LanStr2
        elseif(nFileIndex == 3) then
            t = LanStr3
        elseif(nFileIndex == 4) then
            t = LanStr4
        elseif(nFileIndex == 5) then
            t = LanStr5
        elseif(nFileIndex == 6) then
            t = LanStr6
        elseif(nFileIndex == 7) then
            t = LanStr7
        elseif(nFileIndex == 8) then
           t = LanStr8
        elseif(nFileIndex == 9) then
           t = LanStr9
        elseif(nFileIndex == 10) then
           t = LanStr10
        else
            t = LanStr1
        end
    end
    local sStr = t[tostring(nId)]
    if(sStr == nil or string.len(sStr) <= 0) then
        sStr = getConvertedStr(1, 10000)
    end
    return sStr
end

-- 初始化语言内容
function initLanguageContent(  )
	-- body
	local nLanType = getCurLanType()
	if nLanType == 1 then --中文简体
		if not LanStr1 then
			require("app.worldlan.cn.LanStr1")
		end
		if not LanStr2 then
			require("app.worldlan.cn.LanStr2")
		end
		if not LanStr3 then
			require("app.worldlan.cn.LanStr3")
		end
		if not LanStr4 then
			require("app.worldlan.cn.LanStr4")
		end
		if not LanStr5 then
			require("app.worldlan.cn.LanStr5")
		end
		if not LanStr6 then
			require("app.worldlan.cn.LanStr6")
		end
		if not LanStr7 then
			require("app.worldlan.cn.LanStr7")
		end
        if not LanStr8 then
            require("app.worldlan.cn.LanStr8")
        end
        if not LanStr9 then
            require("app.worldlan.cn.LanStr9")
        end
        if not LanStr10 then
            require("app.worldlan.cn.LanStr10")
        end
	elseif nLanType == 2 then
		if not LanStr1 then
			require("app.worldlan.ft.LanStr1")
		end
		if not LanStr2 then
			require("app.worldlan.ft.LanStr2")
		end
		if not LanStr3 then
			require("app.worldlan.ft.LanStr3")
		end
		if not LanStr4 then
			require("app.worldlan.ft.LanStr4")
		end
		if not LanStr5 then
			require("app.worldlan.ft.LanStr5")
		end
		if not LanStr6 then
			require("app.worldlan.ft.LanStr6")
		end
		if not LanStr7 then
			require("app.worldlan.ft.LanStr7")
		end
        if not LanStr8 then
            require("app.worldlan.ft.LanStr8")
        end
        if not LanStr9 then
            require("app.worldlan.ft.LanStr9")
        end
        if not LanStr10 then
            require("app.worldlan.ft.LanStr10")
        end
	end
end

-- 获得当前语言类型 (默认为1 ，以后再做判断)
-- return 1：中文简体 2：中文繁体
function getCurLanType(  )
	-- body
	return 1
end


--获得等级字符串（物品或者人物等等）
-- _nLv（int）: 等级
--_bDiv：是否需要空格
function getLvString( _nLv , _bDiv)
    _nLv = _nLv or 0
    if _bDiv == false then
        return "Lv." .. _nLv
    else
        return " Lv." .. _nLv
    end
    
end

--获得Vip等级字符串
-- _nVipLv （int）：vip等级
function getVipLvString( _nVipLv )
    -- body
    return "VIP" .. _nVipLv
end

--获取坐标字符串
--nX,nY
function getWorldPosString( nX, nY)
    return nX .. "." .. nY
end

--根据数字获取相对应的英文字母
function getLetterByNum(_nNum)
    local tLetters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
    if tLetters[_nNum] then
        return tLetters[_nNum]
    else
        return nil
    end
end

-- 转化数字为星期
-- n:数字(如：1)
function numTranformToWeek(n)
    local sStr = ""
    n = tonumber(n)
    if n == 1 then
        sStr = getConvertedStr(1, 10051)
    elseif n == 2 then
        sStr = getConvertedStr(1, 10052)
    elseif n == 3 then
        sStr = getConvertedStr(1, 10053)
    elseif n == 4 then
        sStr = getConvertedStr(1, 10054)
    elseif n == 5 then
        sStr = getConvertedStr(1, 10055)
    elseif n == 6 then
        sStr = getConvertedStr(1, 10056)
    elseif n == 7 then
        sStr = getConvertedStr(1, 10057)
    end
    return sStr
end

--功能：统计字符串个数（数字算1个，字母算1个，汉子算1个）
function getStringWordNum(str)
    if not str then
        return 0
    end
    local lenInByte = #str
    local count = 0
    local i = 1
    while true do
        local curByte = string.byte(str, i)
        if i > lenInByte then
            break
        end
        local byteCount = 1
        if curByte > 0 and curByte < 128 then --数字,字母
            byteCount = 1
        elseif curByte>=128 and curByte<224 then
            byteCount = 2
        elseif curByte>=224 and curByte<240 then --汉字
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        else
            break
        end
        i = i + byteCount
        count = count + 1
    end
    return count
end

--功能：统计字符串中字符的个数
--返回：总字符个数、英文字符数、中文字符数
function getUtf8StringCount(str)
    local tmpStr=str
    local _,sum=string.gsub(str,"[^\128-\193]","")
    local _,countEn=string.gsub(tmpStr,"[%z\1-\127]","")
    return sum,countEn,sum-countEn
end


-- 获取显示资源数量的字符串(转换为带单位的字符串， 1b=10亿， 1m=100万，1k=1000)
-- 返回资源数量的字符串，如 1024=1.02k, 45374563=45.4m
-- _nCount(int): 当前数量
function formatCountToStr( _nCount )
    -- body
    if (not _nCount) then
        return ""
    end
    if _nCount >= 100000000000 then
        -- 100b == 1000亿
         return (cutOffNum(_nCount / 1000000000, 1)) .. "b"
    elseif _nCount >= 10000000000 then
        -- 10b == 100亿
        return (cutOffNum(_nCount / 1000000000, 0.1)) .. "b"
    elseif _nCount >= 1000000000 then
        -- 1b == 10亿
        return (cutOffNum(_nCount / 1000000000, 0.01)) .. "b"
    elseif _nCount >= 100000000  then
        -- 100m == 1亿
        return (cutOffNum(_nCount / 1000000, 1)) .. "m"
    elseif _nCount >= 10000000  then
        -- 10m = 1000万
        return (cutOffNum(_nCount / 1000000, 0.1)) .. "m"
    elseif _nCount >= 1000000 then
        -- 1m = 100万
        return (cutOffNum(_nCount / 1000000, 0.01)) .. "m"
    elseif _nCount >= 100000 then
        -- 100k = 10万
        return (cutOffNum(_nCount / 1000, 1)) .. "k"
    elseif _nCount >= 10000 then
        -- 10k = 1万
        return (cutOffNum(_nCount / 1000, 0.1)) .. "k" 
    elseif _nCount >= 1000 then
        -- 1k = 1千
        local nMCt = _nCount / 100
        local n1,n2 = math.modf(nMCt)
        if n2 > 0 then
            return (cutOffNum(_nCount / 1000, 0.01)) .. "k"
        else
            return (cutOffNum(_nCount / 1000, 0)) .. "k"
        end
    else
        --
        return math.ceil(_nCount) ..""  
    end

    return ""
end

--获取是否需要显示资源
function getIsFormatCount( nCount )
    return nCount >= 1000
end

-- 获取显示资源数量的字符串(转换为带单位的字符串， 1b=10亿， 1m=100万，1k=1000)
-- 返回资源数量的字符串，如 1024=1.02k, 45374563=45.4m
function getResourcesStr( nCount )
    -- body
    local _nCount = tonumber(nCount)
    if (not _nCount) then
        return ""
    end

    if _nCount >= 100000000000 then
        -- 100b == 1000亿
         return (cutOffNum(_nCount / 1000000000, 1)) .. "b"
    elseif _nCount >= 10000000000 then
        -- 10b == 100亿
        return (cutOffNum(_nCount / 1000000000, 0.1)) .. "b"
    elseif _nCount >= 999000000 then
        -- 1b == 10亿
        return (cutOffNum(_nCount / 1000000000, 0.01)) .. "b"
    elseif _nCount >= 100000000  then
        -- 100m == 1亿
        return (cutOffNum(_nCount / 1000000, 1)) .. "m"
    elseif _nCount >= 10000000  then
        -- 10m = 1000万
        return (cutOffNum(_nCount / 1000000, 0.1)) .. "m"
    elseif _nCount >= 999000 then
        -- 1m = 100万
        return (cutOffNum(_nCount / 1000000, 0.01)) .. "m"
    elseif _nCount >= 100000 then
        -- 100k = 10万
        return (cutOffNum(_nCount / 1000, 1)) .. "k"
    elseif _nCount >= 10000 then
        -- 10k = 1万
        return (cutOffNum(_nCount / 1000, 0.1)) .. "k" 
    elseif _nCount >= 1000 then
        -- 1k = 1千
        local nMCt = _nCount / 100
        local n1,n2 = math.modf(nMCt)
        if n2 > 0 then
            return (cutOffNum(_nCount / 1000, 0.01)) .. "k"
        else
            return (cutOffNum(_nCount / 1000, 0)) .. "k"
        end
    else
        --
        return math.ceil(_nCount) ..""  
    end

    return ""
end


-- 获取系统当前时间
-- isSecond(bool): 是否单位为秒，true为秒，false为毫秒
-- return（long）：isSecond为true返回秒，isSecond为false返回毫秒
function getSystemTime( isSecond )
    -- 默认是返回秒的
    if(isSecond == nil) then
        isSecond = true
    end
    if(isSecond) then
        return os.time()
    else -- socket.gettime() 返回的格式是 1223123123.XXXX， 小数点后的XXX代表毫秒数
        return math.floor(socket.gettime()*1000)
    end
end

--将一段时间格式化天,时,分,秒格式
--输入：n_time，要格式化的时间段，单位秒
--输出:{day = 1,hour = 1,minutes = 1,second = 1} 
--示例:getTimeFormat(3600*24 + 1) 得到的结果为{day = 1,hour = 0,minutes = 0,second = 1}
function getTimeFormat(n_time)
    local SECOND = 1
    local MINUTES = 60*SECOND
    local HOUR = 60*MINUTES
    local DAY = 24*HOUR

    local t =  {
        day = math.floor(n_time/DAY),
        hour =  math.floor((n_time%DAY)/HOUR),
        minutes = math.floor((n_time%HOUR)/MINUTES),
        second =  math.floor((n_time%MINUTES)/SECOND)
    }
    return t
end

function getTimeFormatCn( n_time )
    -- body
    local t = getTimeFormat(n_time)
    local str = ""
    if t.day > 0 then
        str = t.day..getConvertedStr(1, 10050) 
    end
    if t.hour > 0 then
        str = str..t.hour..getConvertedStr(6, 10475)
    end
    if t.minutes > 0 then
        str = str..t.minutes..getConvertedStr(6, 10476)
    end
    if t.second > 0 then
        str = str..t.second..getConvertedStr(6, 10477)
    end
    return str
end
-- 将时间格式化成时分秒
-- nTime（long）：要格式化的时间
-- bUnShowZeroBg: 是否不显示0开始，默认显示0开始
-- bIsChangeDay:  大于一天时是否转化为天
-- return（string）：格式化后的字符串
function formatTimeToHms( nTime, bUnShowZeroBg,bIsChangeDay)
    nTime = nTime or 0
    local date = nil
    local d = math.floor(nTime/(3600*24))
    if bIsChangeDay then
       nTime = nTime%(3600*24)
    end
    local h = math.floor(nTime/3600)
    local m = math.floor(nTime%3600/60)
    local s = math.min(math.ceil(nTime%60), 59)--不可能超过59
    if (bUnShowZeroBg and bUnShowZeroBg == true) then

        if (h > 0) then
            date = string.format("%02d:%02d:%02d", h, m, s)
        elseif (m > 0) then
            date = string.format("%02d:%02d", m, s)
        else
            date = string.format("%02d", s)
        end
    else
        date = string.format("%02d:%02d:%02d", h, m, s)
    end


    if bIsChangeDay then
        if d >= 1 then
            date = d.."D "..date
        end
    end

    return date
end

-- 将时间格式化成分秒
-- nTime（long）：要格式化的时间
-- bIsChangeDay:  大于一天时是否转化为天
-- return（string）：格式化后的字符串
function formatTimeToMs( nTime, bIsChangeDay)
    nTime = nTime or 0
    local h = math.floor(nTime/3600)
    local m = math.floor(nTime%3600/60)
    local s = math.min(math.ceil(nTime%60), 59)--不可能超过59
    local date = nil
    if (h > 0) then
        date = string.format("%02d:%02d:%02d", h, m, s)
    else
        date = string.format("%02d:%02d", m, s)
    end
    if bIsChangeDay then
        local d = math.floor(nTime/(3600*24))
        if d >= 1 then
            date = d..getConvertedStr(1, 10050)
        end
    end
    return date
end

-- 将时间格式化成指定的格式
-- nTime（long）：要格式化的时间,毫秒级数字
-- sFormat(string): 指定的格式 如"%Y-%m-%d %H:%M:%s"(默认)、"%Y-%m-%d"、"%H:%M:%S"
-- return（string）：格式化后的字符串
function formatTime( nTime, sFormat )
    nTime = tonumber(nTime)
    sFormat = sFormat or "%Y.%m.%d %H:%M:%S"
    -- 格式化时间
    return os.date(sFormat, nTime/1000)
end

-- 将时间格式化成制定的格式
-- _nTime（long） 时间为毫秒
-- return （string）月.日 00:00
-- bCn 需要中文格式
function formatTimeMDM(_nTime,bCn)

    local sTime = ""
    local sMn = "."
    local sDy = ""
    if bCn then
       sMn = getConvertedStr(5, 10193)
       sDy = getConvertedStr(5, 10194)
    end
    if _nTime then
        local nTime = tonumber(_nTime) 
        local tTime =  os.date("*t", nTime/1000)
        sTime = string.format("%02d",tTime.month)..sMn..string.format("%02d",tTime.day)..sDy.." "..
        string.format("%02d",tTime.hour)..":"..string.format("%02d",tTime.min)
    end
    return sTime
end

-- 将时间格式化成制定的格式
-- _nTime（long） 时间为毫秒
-- return （string）年.月.日 00:00:00
function formatTimeYMDM(_nTime,bCn)

    local sTime = ""
    local sYe = "."
    local sMn = "."
    local sDy = ""
    if bCn then
       sYe = getConvertedStr(5, 10197)
       sMn = getConvertedStr(5, 10193)
       sDy = getConvertedStr(5, 10194)
    end
    if _nTime then
        local nTime = tonumber(_nTime) 
        local tTime =  os.date("*t", nTime/1000)
        sTime = string.format("%04d",tTime.year)..sYe..string.format("%02d",tTime.month)..
        sMn..string.format("%02d",tTime.day)..sDy.." "..string.format("%02d",tTime.hour)..
        ":"..string.format("%02d",tTime.min)..":"..string.format("%02d",tTime.sec)
    end
    return sTime
end

-- 将时间格式化成只需要年月日
function formatTimeYMD(_nTime,bCn)
    local sTime = ""
    local sYe = "."
    local sMn = "."
    local sDy = ""
    if bCn then
       sYe = getConvertedStr(5, 10197)
       sMn = getConvertedStr(5, 10193)
       sDy = getConvertedStr(5, 10194)
    end

    if _nTime then
        local nTime = tonumber(_nTime) 
        local tTime =  os.date("*t", nTime/1000)
        sTime = string.format("%04d",tTime.year)..sYe..string.format("%02d",tTime.month)..
        sMn..string.format("%02d",tTime.day)..sDy
    end
    return sTime
end

-- 获取时间长度显示的字符串
-- _nTimeLong: 时间长度，单位：秒
-- _bFullTime: 是否显示完整的天时分秒。true: dhms; false: dhm/hms ，默认false
-- _isCn: 是否使用汉字（国际化时为本地化语言）
-- 返回时间字符串格式为：2d12h34m, 23h0m56s
-- _isTwo: 是否只显示两位 12h34m，0m56s
function formatTimeToStr( _nTimeLong, _bFullTime, _isCn, _isTwo )
    if (not _nTimeLong) then
        return ""
    end
    local tTime = getTimeFormat(_nTimeLong)
    _bFullTime = _bFullTime or false

    local strD = "d"
    local strH = "h"
    local strM = "m"
    local strS = "s"

    if (_isCn and _isCn == true) then
        strD = getConvertedStr(3, 10243)
        strH = getConvertedStr(3, 10244)
        strM = getConvertedStr(3, 10245)
        strS = getConvertedStr(3, 10246)
    end

    local sTimeLong = ""
    
    if _bFullTime then
        if tTime.day > 0 then
            sTimeLong = sTimeLong .. tTime.day .. strD
        end
        if tTime.hour > 0 or (tTime.day > 0 and (tTime.minutes > 0 or tTime.second > 0)) then
            sTimeLong = sTimeLong .. tTime.hour .. strH
        end
        if tTime.minutes > 0 or ((tTime.day > 0 or tTime.hour > 0) and tTime.second > 0) then
            sTimeLong = sTimeLong .. tTime.minutes .. strM
        end
        if tTime.second > 0 then
            sTimeLong = sTimeLong .. tTime.second .. strS
        end
    else
        local inHour = false
        if tTime.day > 0 then
            sTimeLong = sTimeLong .. tTime.day .. strD
        end
        if tTime.hour > 0 or (tTime.day > 0 and tTime.minutes > 0) then
            if _isTwo then
                inHour = true
            end
            sTimeLong = sTimeLong .. tTime.hour .. strH
        end
        if tTime.minutes > 0 or (tTime.day <= 0 and tTime.hour > 0 and tTime.second > 0) then
            sTimeLong = sTimeLong .. tTime.minutes .. strM
        end
        if tTime.day <= 0 and tTime.second > 0 and not inHour then
            sTimeLong = sTimeLong .. tTime.second .. strS
        end
    end

    return sTimeLong
end

-- 将字符串转换时间串
-- _sTimeStr: 时间字符串，格式必须是yyyy-mm-dd HH:MM:SS
-- isSecond(bool): 是否单位为秒，true为秒，false为毫秒
-- return（long）：isSecond为true返回秒，isSecond为false返回毫秒
function formatTimeStrToLong( _sTimeStr, _isSecond)
    if (not _sTimeStr) then
        return 0
    end
    -- 默认是返回秒的
    if(_isSecond == nil) then
        _isSecond = true
    end

    --从日期字符串中截取出年月日时分秒  
    local Y = string.sub(_sTimeStr, 1 ,4)  
    local M = string.sub(_sTimeStr, 6 ,7)  
    local D = string.sub(_sTimeStr, 9, 10)  
    local H = string.sub(_sTimeStr, 12, 13)  
    local MM = string.sub(_sTimeStr, 15, 16)  
    local SS = string.sub(_sTimeStr, 18, 19)  

    local nFlag = 1
    if (not _isSecond) then
        nFlag = 1000
    end
  
    --把日期时间字符串转换成对应的日期时间  
    return (os.time{year=Y, month=M, day=D, hour=H,min=MM,sec=SS}) * nFlag
end

-- 获取时间长度显示的字符串
-- _nTimeLong: 时间长度，单位：秒
-- _bFullTime: 是否显示完整的天时分秒。true: dhms; false: dhm/hms ，默认false
-- _isCn: 是否使用汉字（国际化时为本地化语言）
-- _isNoWord：是否用文字  （1D:12:01:11）    
-- 返回时间字符串格式为：2d12h34m, 23h0m56s
function getTimeLongStr( _nTimeLong, _bFullTime, _isCn ,_isNoWord)
    -- body
    if (not _nTimeLong) then
        return "0s"
    end

    local tTime = getTimeFormat(_nTimeLong)
    _bFullTime = _bFullTime or false

    local strD = "d"
    local strH = "h"
    local strM = "m"
    local strS = "s"

    if (_isCn and _isCn == true) then
        strD = getConvertedStr(3, 10243)
        strH = getConvertedStr(3, 10244)
        strM = getConvertedStr(3, 10245)
        strS = getConvertedStr(3, 10246)
    end

    if ( _isNoWord and _isNoWord == true) then
        strD = "D:"
        strH = ":"
        strM = ":"
        strS = ""
    end

    local sTimeLong = ""
    
    if _bFullTime then

        -- ddhhmmss
        if tTime.day > 0 then
            sTimeLong = sTimeLong .. tTime.day .. strD
        end
        if tTime.hour > 0 or (tTime.day > 0 and (tTime.minutes > 0 or tTime.second > 0)) then
            if tTime.hour < 10 then
                sTimeLong = sTimeLong .. "0"..tTime.hour .. strH
            else

                sTimeLong = sTimeLong .. tTime.hour .. strH
            end
        end
        if tTime.minutes > 0 or ((tTime.day > 0 or tTime.hour > 0) and tTime.second > 0) then
            if tTime.minutes < 10 then
                sTimeLong = sTimeLong .. "0"..tTime.minutes .. strM
            else
                sTimeLong = sTimeLong ..tTime.minutes .. strM
            end
        end
        if tTime.second > 0 then
            if tTime.second <10 then
                sTimeLong = sTimeLong .. "0".. tTime.second .. strS
            else
                sTimeLong = sTimeLong .. tTime.second .. strS
            end
        end
    else

        -- ddhhmm/hhmmss
        if tTime.day > 0 then
            sTimeLong = sTimeLong .. tTime.day .. strD
        end
        if tTime.hour > 0 or (tTime.day > 0 and tTime.minutes > 0) then

            sTimeLong = sTimeLong .. tTime.hour .. strH
        end
        if tTime.minutes > 0 or (tTime.day <= 0 and tTime.hour > 0 and tTime.second > 0) then
            sTimeLong = sTimeLong .. tTime.minutes .. strM
        end
        if tTime.day <= 0 and tTime.second > 0 then
            sTimeLong = sTimeLong .. tTime.second .. strS
        end
    end
    if(sTimeLong == "") then
        sTimeLong = "0" .. strS
    end

    return sTimeLong
end

-- 获取天数
-- _nTimeLong:单位为时
function getTimeDayStr( _nTimeLong )
    return math.ceil(_nTimeLong/24) .. getConvertedStr(3, 10243)
end

-- 将时间格式化成时分
-- nTime（long）：要格式化的时间
-- bIsChangeDay:  大于一天时是否转化为天
-- return（string）：格式化后的字符串
function formatTimeToDHM( nTime, bIsChangeDay)
    nTime = nTime or 0
    local h = math.floor(nTime/3600)
    local m = math.floor(nTime%3600/60)
    local s = math.ceil(nTime%60)
    local date = nil
    if (h > 0) then
        date = h..getConvertedStr(5, 10202)
    else
        date = m..getConvertedStr(5, 10203)
    end
    if bIsChangeDay then
        local d = math.floor(nTime/(3600*24))
        if d >= 1 then
            date = d..getConvertedStr(1, 10050)
        end
    end
    return date
end

-- 将时间格式化成时分
-- nTime（long）：要格式化的时间
-- return（string）：格式化后的字符串
function formatTimeToHMSWord( nTime )
    nTime = nTime or 0
    local d = math.floor(nTime/(3600*24))
    local h = math.floor(nTime/3600)
    local m = math.floor(nTime%3600/60)
    local s = math.ceil(nTime%60)
    local date = ""
        
    if (d > 0) then
        date = date..d..getConvertedStr(1, 10050)
        return date     
    end
    
    if (h > 0) then
        date = date..h..getConvertedStr(6, 10475)
        return date
    end
    
    if (m > 0) then
        date = date..m..getConvertedStr(6, 10476)
        return date
    end
    
    if (s > 0) then
        date = date..s..getConvertedStr(6, 10477)
        return date
    end
    return date
end

-- 将时间字符串转成秒数
-- _sTime ： "00:00:00"
function parseTimeFormatToNum(_sTime)
    if _sTime == nil then
        return 0
    end

    local num = 0    
    local tAry = string.split(_sTime, ":")
    for k, v in pairs(tAry) do
        num = num * 60 + tonumber(v)
    end
    return num
end


-- 根据颜色获取颜色字符串
-- nType(int): 类型，1是<font color='#ffffff'/>, 2是</font>
-- sColor（string）： 颜色值（ffffff）
function getColorStrByColor( nType, sColor )
    if(nType == 2) then
        return "</font>"
    end
    if(sColor) then
        return "<font color='#" .. sColor .. "'>"
    end
    return "<font color='#ffffff'>"
end

-- 将字符串颜色化
-- sStr（string）：当前字符串
-- sColor（string）：颜色值（ffffff）
function colorTheStr( sStr, sColor )
    sStr = sStr or ""
    local sTmp = getColorStrByColor(1, sColor) .. sStr
        .. getColorStrByColor(2)
    return sTmp
end

-- 给字符串加下划线
-- sStr（string）：当前字符串
function underLineTheStr( sStr )
    sStr = sStr or ""
    local sTmp = "<u>" .. sStr .. "</u>"
    return sTmp
end

-- 解析字符串中带html的内容
-- sStr(string) ： 需要解析的字符串
-- return(table): 返回解析后的表
function parseStrWithHtml( sStr )
    local tStr = {}
    local nBeginS, nEndS = string.find(sStr, "<font color%s*=%s*['%\"]#%x+['%\"]>")
    while nBeginS do
        local nBeginF, nEndF = string.find(sStr, "</font>")
        if nBeginF then
            --解析标签前的字符串，颜色为默认颜色
            if nBeginS > 1 then
                local temp = { str = string.sub(sStr, 1, nBeginS-1) }
                table.insert(tStr, temp)
            end
            --解析标签内的字符串与字符串颜色
            local pStrColor = string.sub(sStr, nBeginS, nEndS)
            pStrColor = string.match(pStrColor, "#%w+")
            pStrColor = string.gsub(pStrColor, "#", "")
            if(pStrColor and string.len(pStrColor) <= 0) then
                pStrColor = nil
            end
            local temp = { str = string.sub(sStr, nEndS+1, nBeginF-1), color = pStrColor }
            table.insert(tStr, temp)
        end
        if(nEndF) then
            --截取以解析的字符串，继续循环直到没有为止
            sStr = string.sub(sStr, nEndF+1, -1)
            nBeginS, nEndS = string.find(sStr, "<font color%s*=%s*['%\"]#%x+['%\"]>")
        else
            break
        end
    end
    -- 增加到列表中
    if(sStr and string.len(sStr) > 0) then
        table.insert(tStr, {str=sStr})
    end
    return tStr
end

--获取国家名字
function getCountryName( _nType )
    -- body
    local nCountryName = getConvertedStr(1,10118)
    _nType = _nType or 0
    if _nType == e_type_country.qunxiong then
        nCountryName = getConvertedStr(1,10118)
    elseif _nType == e_type_country.shuguo then
        nCountryName = getConvertedStr(1,10119)
    elseif _nType == e_type_country.weiguo then
        nCountryName = getConvertedStr(1,10120)
    elseif _nType == e_type_country.wuguo then
        nCountryName = getConvertedStr(1,10121)
    end
    return nCountryName
end

--获取国家名字缩写
--bIsBracket 是否带中括号
function getCountryShortName( nCountry, bIsBracket )
    -- body
    local nCountryName = ""
    if nCountry == e_type_country.qunxiong then
        nCountryName = getConvertedStr(3,10113)
    elseif nCountry == e_type_country.shuguo then
        nCountryName = getConvertedStr(3,10110)
    elseif nCountry == e_type_country.weiguo then
        nCountryName = getConvertedStr(3,10111)
    elseif nCountry == e_type_country.wuguo then
        nCountryName = getConvertedStr(3,10112)
    end
    if bIsBracket then
        return string.format("[%s]", nCountryName)
    end
    return nCountryName
end

--获取国家名字图片
function getCountryNameImg( nCountry )
    -- body
    local sCountryNameImg = ""
    if nCountry == e_type_country.shuguo then       
        sCountryNameImg ="#v2_fonts_hanbb.png"
    elseif nCountry == e_type_country.weiguo then
        sCountryNameImg ="#v2_fonts_qingcc.png"
    elseif nCountry == e_type_country.wuguo then
        sCountryNameImg ="#v2_fonts_chuaa.png"
    end
    return sCountryNameImg
end

--获得战斗类型
function getFightType( _nType  )
    -- body
    local sTypeName = getConvertedStr(1,10214)
    _nType = _nType or 1
    if _nType == 1 then --副本
        sTypeName = getConvertedStr(1,10214)
    elseif _nType == 2 then --城战
        sTypeName = getConvertedStr(1,10215)
    elseif _nType == 3 then --乱军战
        sTypeName = getConvertedStr(1,10216)
    elseif _nType == 4 then --国战
        sTypeName = getConvertedStr(1,10217)
    elseif _nType == 5 then --资源田战
        sTypeName = getConvertedStr(1,10236)
    elseif _nType == 6 then --讨伐战
        sTypeName = getConvertedStr(1,10237)
    elseif _nType == 8 then --竞技场
        sTypeName = getConvertedStr(6,10676)        
    elseif _nType == 9 then --限时Boss战
        sTypeName = getConvertedStr(3, 10831)
    elseif _nType == 10 then --过关斩将
        sTypeName = getConvertedStr(7, 10373)        
    end
    return sTypeName
end

--字符串截取
--s:要截取的字符串,可截取中文
--n:
function SubUTF8String(s, n)    
    local dropping = string.byte(s, n+1)    
    if not dropping then 
        return s 
    end    
    --UTF8是多字符集，但是第一个字符的最高位是11,其他的字符最高位是10XXXXXX
    if dropping >= 128 and dropping < 192 then    
        return SubUTF8String(s, n-1)    
    end    
    return string.sub(s, 1, n), string.sub(s, n+1, -1)
end

--获取设置项的名称
function getSettingItemName( _key )
    -- body
    if not _key then
        print("key 不能为空")
        return
    end
    if _key == gameSetting_eachButtonKey[1] then
        return getConvertedStr(6, 10269)
    elseif _key == gameSetting_eachButtonKey[2] then
        return getConvertedStr(6, 10270)
    elseif _key == gameSetting_eachButtonKey[3] then
        return getConvertedStr(6, 10271)
    elseif _key == gameSetting_eachButtonKey[4] then
        return getConvertedStr(6, 10272)
    elseif _key == gameSetting_eachButtonKey[5] then
        return getConvertedStr(6, 10520)
    elseif _key == gameSetting_eachButtonKey[6] then
        return getConvertedStr(6, 10531)        
    elseif _key == gameSetting_eachButtonKey[7] then
        return getConvertedStr(6, 10273)        
    elseif _key == gameSetting_eachButtonKey[8] then
        return getConvertedStr(6, 10274)
    elseif _key == gameSetting_eachButtonKey[9] then
        return getConvertedStr(6, 10275)
    elseif _key == gameSetting_eachButtonKey[10] then
        return getConvertedStr(6, 10276)
    elseif _key == gameSetting_eachButtonKey[11] then
        return getConvertedStr(6, 10277)
    elseif _key == gameSetting_eachButtonKey[12] then
        return getConvertedStr(6, 10278)
    elseif _key == gameSetting_eachButtonKey[13] then
        return getConvertedStr(6, 10279)
    elseif _key == gameSetting_eachButtonKey[14] then
        return getConvertedStr(6, 10280)
    elseif _key == gameSetting_eachButtonKey[15] then
        return getConvertedStr(6, 10281)
    elseif _key == gameSetting_eachButtonKey[16] then
        return getConvertedStr(6, 10282)
    elseif _key == gameSetting_eachButtonKey[17] then
        return getConvertedStr(6, 10283)
    elseif _key == gameSetting_eachButtonKey[18] then
        return getConvertedStr(6, 10284)
    elseif _key == gameSetting_eachButtonKey[19] then
        return getConvertedStr(6, 10389)
    elseif _key == gameSetting_eachButtonKey[20] then
        return getConvertedStr(3, 10736)
    elseif _key == gameSetting_eachButtonKey[21] then
        return getConvertedStr(3, 10838)
    elseif _key == gameSetting_eachButtonKey[22] then
        return getConvertedStr(6, 10843)        
    -- elseif _key == gameSetting_eachButtonKey[18] then
    --     return getConvertedStr(6, 10389)
    end
    print("未找到对应的设置项")
end

--获取服务器名称
function getServerNameByServer(_pServer)
    local strName = ""
    if _pServer and _pServer.id and _pServer.ne then
        strName = _pServer.ne
    end
    return strName
end


--转换免打扰时间字符串
function getNoDisturbTimeStr( _nstart, _nend )
    -- body
    if _nstart and _nend then
        return "（".._nstart..":00-".._nend..":00）"
    end    
end

--带货币单位的转换
function getRMBStr( nmoney )
    -- body
    if nmoney then
        return "¥"..nmoney
    end
end

--坐标显示
function getPosStr( nx, ny )
    -- body
    local x = nx or 0
    local y = ny or 0
    return "["..x..","..y.."]"
end

function getPosStrNoSign( nx, ny )
    -- body
    local x = nx or 0
    local y = ny or 0
    return x..","..y
end

--获取显示的属性文本
--主要显示的属性名和配表一样，只是兼容之前的代码
function getAttrUiStr( nType )
    if nType == e_id_hero_att.gongji then
        return getConvertedStr(3, 10393)
    elseif nType == e_id_hero_att.fangyu then
        return getConvertedStr(3, 10427)
    elseif nType == e_id_hero_att.bingli then
        return getConvertedStr(3, 10183)
    end
    return ""
end

--获取城池类型中文
function getCityKindStr( nKind )
    if nKind == 1 then
        return getConvertedStr(3, 10527)
    elseif nKind == 2 then
        return getConvertedStr(3, 10528)
    elseif nKind == 3 then
        return getConvertedStr(3, 10529)
    elseif nKind == 4 then
        return getConvertedStr(3, 10530)
    elseif nKind == 5 then
        return getConvertedStr(3, 10531)
    elseif nKind == 6 then
        return getConvertedStr(3, 10532)
    elseif nKind == 7 then
        return getConvertedStr(3, 10533)
    elseif nKind == 8 then
        return getConvertedStr(3, 10703)
    end
    return ""
end

--获取城池类型首杀文字
function getFirstBloodStr( nKind )
    if nKind == 1 then
        return getConvertedStr(3, 10593)
    elseif nKind == 2 then
        return getConvertedStr(3, 10594)
    elseif nKind == 3 then
        return getConvertedStr(3, 10595)
    elseif nKind == 4 then
        return getConvertedStr(3, 10596)
    elseif nKind == 5 then
        return getConvertedStr(3, 10597)
    elseif nKind == 6 then
        return getConvertedStr(3, 10598)
    elseif nKind == 7 then
        return getConvertedStr(3, 10599)
    elseif nKind == 8 then
        return getConvertedStr(3, 10600)
    end
    return ""
end

-- --文字变竖向（\n)
-- --str:名字文本
-- --bIsNameStyle: 是名字模式
-- function getVerticalStr( str, bIsNameStyle)
--     if not str then
--         return ""
--     end
--     -- local fontSize = 20
--     local lenInByte = #str
--     -- local width = 0
--     local tStr = {}
--     for i=1,lenInByte do
--         local curByte = string.byte(str, i)
--         local byteCount = 1;
--         if curByte>0 and curByte<=127 then
--             byteCount = 1
--         elseif curByte>=192 and curByte<223 then
--             byteCount = 2
--         elseif curByte>=224 and curByte<239 then
--             byteCount = 3
--         elseif curByte>=240 and curByte<=247 then
--             byteCount = 4
--         end
         
--         local char = string.sub(str, i, i+byteCount-1)
--         table.insert(tStr, char)
--         i = i + byteCount -1
         
--         -- if byteCount == 1 then
--         --     width = width + fontSize * 0.5
--         -- else
--         --     width = width + fontSize
--         -- end
--     end

--     local sVStr = ""
--     if #tStr == 2 and bIsNameStyle then
--         sVStr = tStr[1] .. "\n\n" .. tStr[2]
--     else
--         for i=1,#tStr do
--             sVStr = sVStr .. tStr[i] .. "\n"
--         end
--     end
--     return sVStr
-- end

--头像框时间
function getIconBoxUseTime( nTime, bPrevSHow )
    -- body
    local bPrev = bPrevSHow or false
    
    nTime = nTime or 0
    local h = math.floor((nTime%(3600*24))/3600)
    local m = math.floor(nTime%3600/60)
    local s = math.min(math.ceil(nTime%60), 59)--不可能超过59
    local date = nil
    if (h > 0) then
        date = string.format("%02d:%02d", h, m)
    else
        date = string.format("%02d:%02d", m, s)
    end

    local d = math.floor(nTime/(3600*24))   
    
    local sStr = nil
    if bPrev then
        if d > 0 then
            sStr = {
                {color=_cc.white, text=getConvertedStr(6, 10649)},
                {color=_cc.yellow, text=tostring(d)},
                {color=_cc.white, text=getConvertedStr(1, 10050)},
                {color=_cc.yellow, text=date},
            }
        else
            sStr = {
                {color=_cc.white, text=getConvertedStr(6, 10649)},
                {color=_cc.yellow, text=date},
            }
        end
        return sStr
    else
        if d > 0 then
            sStr = {
                {color=_cc.white, text=getConvertedStr(7, 10142)},
                {color=_cc.yellow, text=tostring(d)},
                {color=_cc.white, text=getConvertedStr(1, 10050)},
                {color=_cc.yellow, text=date},
            }
        else
            sStr = {
                {color=_cc.white, text=getConvertedStr(7, 10142)},
                {color=_cc.yellow, text=date},
            }
        end
        return sStr
    end

end
--获得距离下一天还有多久
function  getToNextDayTime(  )
    -- body
    local nOneDay=3600*24
    local nNowTime=getSystemTime()
    local tTime =  os.date("*t", nNowTime)
    -- sTime = string.format("%04d",tTime.year)..sYe..string.format("%02d",tTime.month)..
    -- sMn..string.format("%02d",tTime.day)..sDy.." "..string.format("%02d",tTime.hour)..
    -- ":"..string.format("%02d",tTime.min)..":"..string.format("%02d",tTime.sec)
    -- local tTime=getTimeFormat(nNowTime)
    -- dump(tTime)
    -- print("time--",tTime.hour,tTime.min,tTime.sec)
    local nLeftTime=nOneDay - tTime.hour * 3600 - tTime.min * 60 - tTime.sec
    local sLeftTime=getTimeLongStr(nLeftTime,true)
    -- return "11"
    return sLeftTime
end

function getResStrById(_resId)
    if _resId == e_resdata_ids.lc then
        return getConvertedStr(1,10093)
    elseif _resId == e_resdata_ids.yb then
        return getConvertedStr(1,10091)
    elseif _resId == e_resdata_ids.mc then
        return getConvertedStr(1,10092)
    elseif _resId == e_resdata_ids.bt then
        return getConvertedStr(1,10094)
    end
end