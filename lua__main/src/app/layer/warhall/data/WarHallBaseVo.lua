--region 战争大厅基础数据.lua
--Author : wenzongyao
--Date   : 2018/3/20
--此文件由[BabeLua]插件自动生成

local WarHallBaseVo = class("WarHallBaseVo")


--tWarHallConfig:table 配置数据
function WarHallBaseVo:ctor(tWarHallConfig)

    assert(tWarHallConfig.id)--tWarHallConfig.sequence不能为nil
    self.nId            = tWarHallConfig.id             --对应eWallHallType
    self.nSequence      = tWarHallConfig.sequence       -- 
    self.nType          = tWarHallConfig.type           or 1
    self.sName          = tWarHallConfig.name           or ""
    self.sIcon          = tWarHallConfig.icon	        or "ui/daitu.png"
    self.sNamePicture   = tWarHallConfig.namepicture	or "ui/daitu.png"
    self.sBanner        = tWarHallConfig.banner	        or "ui/daitu.png"
    self.sBbbleFont     = tWarHallConfig.bubblefont	    or "ui/daitu.png" --气泡文字图片
    self.nShow          = tWarHallConfig.show	        or 0
    self.nOpen          = tWarHallConfig.open	        or "-1"
    self.sOpenTips      = tWarHallConfig.opentips	    or ""
    self.sTimeFormat    = tWarHallConfig.time	        or "" --时间格式
    self.nBubbleEffect  = tWarHallConfig.bubbleeffect   or 0
    self.nBubbleShow    = tWarHallConfig.bubbleshow	    or 0  --活动开启前n分钟显示气泡
    self.nPriority      = tWarHallConfig.priority	    or 0  --气泡优先级
    self.__sDescribe    = tWarHallConfig.describe       or "" --私有，用getTime()访问
    self.nDlgIndex      = tWarHallConfig.dlgindex       or 0
    
    self:init()
end

function WarHallBaseVo:init()
end

-- 获取描述(可能需要函数覆盖)
function WarHallBaseVo:getDescript1()    
    if self.__sDescribe ~= "" then
        return getTextColorByConfigure(self.__sDescribe, _cc.white)
    end
    return self.__sDescribe
end

-- 获取描述(可能需要函数覆盖)
function WarHallBaseVo:getDescript2()
    return ""
end

-- 获取时间(可能需要函数覆盖)
function WarHallBaseVo:getTime()    
    return ""
end

-- 请求数据(可能需要函数覆盖)
function WarHallBaseVo:reqData()
    -- 有需要则函数覆盖    
end

-- 活动是否开启
function WarHallBaseVo:isOpen()
    return false
end

-- 活动是否开锁
function WarHallBaseVo:isLock()
    if self.nOpen == "-1" then
        return false
    else
        local tAry = string.split(self.nOpen, ":")
        local eType = tonumber(tAry[1])
        local nValue = tonumber(tAry[2])
        if eType == 1 then      -- 判断玩家等级解锁            
            if Player:getPlayerInfo().nLv < nValue then
                return true
            end

        elseif eType == 2 then  -- 判断开服天数解锁            
            local sDate = AccountCenter.nowServer.st                -- 当前服务器开服时间(是字符串)
            local ary = string.split(sDate, " ")
            local aryDate = string.split(ary[1], "-")
            local t = { year = aryDate[1]
                        , month = aryDate[2]
                        , day   = aryDate[3]
                        , hour  = 0
                        , min   = 0
                        , sec   = 0 }
            local timestamp = os.time(t)                            -- 开服当天0点时间戳
            local openTimestamp = timestamp + nValue * 24 * 3600    -- 解锁当天0点时间戳
            local nLocalTime = getSystemTime(true)                  -- 当前时间戳
            return nLocalTime < openTimestamp

        end
    end

    return false
end

-- 是否显示建筑气泡(需要函数覆盖)
function WarHallBaseVo:isShowBuildingBubble() 
    return false
end

function WarHallBaseVo:isShowRedTip(  )
    -- body
    return false
end

-- 是否能跳转面板(需要函数覆盖)
function WarHallBaseVo:isCanOpenDlg()
    return true
end

return WarHallBaseVo


--endregion
