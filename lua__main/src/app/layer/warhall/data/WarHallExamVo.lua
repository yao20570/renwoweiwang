--region 战争大厅数据->每日答题.lua
--Author : User
--Date   : 2018/3/21
--此文件由[BabeLua]插件自动生成
 
local MailFunc = require("app.layer.mail.MailFunc")

local WarHallBaseVo = require("app.layer.warhall.data.WarHallBaseVo")
local WarHallExamVo = class("WarHallExamVo", WarHallBaseVo)


--tWarHallConfig:table 配置数据
function WarHallExamVo:ctor(tWarHallConfig)
    WarHallExamVo.super.ctor(self, tWarHallConfig)
end

-- 获取描述(覆盖)
function WarHallExamVo:getDescript1()    
    return ""
end

-- 获取描述(覆盖)
function WarHallExamVo:getDescript2()
    local sRet = getConvertedStr(10, 10211)
    local tData = Player:getActById(e_id_activity.exam)
    if tData then
        local nOpenTimestamp = Player:getExamData():getActivityOpenLocalTimeStamp()
        local nCurTimestamp = getSystemTime(true)
        local nTimeSpan = nOpenTimestamp - nCurTimestamp
        if 0 < nTimeSpan and nTimeSpan < self.nBubbleShow * 60 then
            return getConvertedStr(10, 10207) .. getTimeLongStr(nTimeSpan,false,true) --开始倒计时
        else
            local sOpenTime = getExamConfig("openTime")
            local tTimeList = luaSplitMuilt(sOpenTime,":")
            sOpenTime = tTimeList[1]..":"..tTimeList[2]
            local sTime = string.format(self.sTimeFormat, sOpenTime)
            sRet = getTextColorByConfigure(sTime, _cc.pwhite)
        end
    end
    
    return sRet
end

-- 活动是否开启
function WarHallExamVo:isOpen()
    if self:isLock() == true then        
        --未解锁
        return false     
    end
    return Player:getExamData():isActivityInOpen()
end

-- 是否显示建筑气泡(可能需要函数覆盖)
function WarHallExamVo:isShowBuildingBubble()
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    local tData = Player:getActById(e_id_activity.exam)
    if tData then
        if Player:getExamData():isCanGetRankReward() then
            return true
        end  
        if Player:getExamData():isReadyStart() then
            return true
        else
            local nOpenTimestamp = Player:getExamData():getActivityOpenLocalTimeStamp()
            local nCurTimestamp = getSystemTime(true)
            local nTimeSpan = nOpenTimestamp - nCurTimestamp
            if 0 < nTimeSpan and nTimeSpan < self.nBubbleShow * 60 then
                return true
            end
        end
    end

    return false
end

function WarHallExamVo:isShowRedTip(  )
    -- body
    return self:isShowBuildingBubble()
end

function WarHallExamVo:reqData()
    --WarHallExamVo.super.reqData(self)
    SocketManager:sendMsg("getRankData", { e_rank_type.exam, 1, 20 })    
end

-- 是否能跳转面板(覆盖)
function WarHallExamVo:isCanOpenDlg()
    return WarHallExamVo.super.isCanOpenDlg(self)
end

return WarHallExamVo

--endregion
