-- region 字符串转化时间.lua
-- Author : wenzongyao
-- Date   : 2018/3/22
-- 此文件由[BabeLua]插件自动生成


-- parseStrToTimestamp("2018-8-15 12:23:22") 2018-8-15 12:23:22时间戳   
function parseDateTimeToTimestamp(sDateTime)
    local ary = string.split(sDateTime, " ")
    local aryDate = string.split(ary[1], "-")
    local aryTime = string.split(ary[2], ":")
    local t = {
        year = aryDate[1],
        month = aryDate[2],
        day = aryDate[3],
        hour = aryTime[1],
        min = aryTime[2],
        sec = aryTime[3]
    }
    local timestamp = os.time(t)    
    return timestamp
end

-- parseStrToTimestamp("2018-8-15") 2018-8-15零时时间戳
function parseDateToTimestamp(sDate)
    local ary = string.split(sDate, "-")    
    local t = {
        year = ary[1],
        month = ary[2],
        day = ary[3],
        hour = 0,
        min = 0,
        sec = 0
    }
    local timestamp = os.time(t)    
    return timestamp
end

-- parseStrToTimestamp("12:23:22")    当天12:23:22 时间戳
function parseTimeToTimestamp(sTime)
    local ary = string.split(sTime, ":")

    local nCurTimeStamp = getSystemTime(true)
    local tDateTime = os.date("*t", nCurTimeStamp)    
    tDateTime.hour = ary[1]
    tDateTime.min = ary[2]
    tDateTime.sec = ary[3]

    local timestamp = os.time(tDateTime)    
    return timestamp
end

-- endregion
