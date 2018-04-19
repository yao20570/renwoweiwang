--region 战争大厅数据->魔神来袭.lua
--Author : wenzongyao
--Date   : 2018/3/21
--此文件由[BabeLua]插件自动生成

local WarHallBaseVo = require("app.layer.warhall.data.WarHallBaseVo")

local WarHallBossVo = class("WarHallBossVo", WarHallBaseVo)


--tWarHallConfig:table 配置数据
function WarHallBossVo:ctor(tWarHallConfig)
    WarHallBossVo.super.ctor(self, tWarHallConfig)
end

-- 获取描述(可能需要函数覆盖)
function WarHallBossVo:getDescript1()    
    return WarHallBossVo.super.getDescript1(self)
end

-- 获取描述(可能需要函数覆盖)
function WarHallBaseVo:getDescript2()
    local sRet = getConvertedStr(10, 10211) --未开启

    local tData = Player:getActById(e_id_activity.tlboss)
    if tData then
        local tTLBossData = Player:getTLBossData()    
        if tTLBossData.nTimeState == e_tlboss_time.no then            
            sRet = getConvertedStr(10, 10207) .. getTimeLongStr(tTLBossData:getCd(),false,true) --开始倒计时

        elseif tTLBossData.nTimeState == e_tlboss_time.ready then
            sRet = getConvertedStr(10, 10208) .. getTimeLongStr(tTLBossData:getCd(),false,true) --准备倒计时
                
        elseif tTLBossData.nTimeState == e_tlboss_time.begin then                               --战斗中
            sRet = getConvertedStr(10, 10209)

        end
    end  

    
    return sRet
end

-- 活动是否开启
function WarHallBossVo:isOpen()
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    local tData = Player:getActById(e_id_activity.tlboss)
    if tData == nil then
        return false
    end  

    local tTLBossData = Player:getTLBossData()    
    return tTLBossData.nTimeState ~= e_tlboss_time.no
end

-- 是否显示建筑气泡(可能需要函数覆盖)
function WarHallBossVo:isShowBuildingBubble()
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    local tData = Player:getActById(e_id_activity.tlboss)
    if tData and tData:getRedNums() > 0 then
        return true
    end

    local tTLBossData = Player:getTLBossData()  
    if tTLBossData then  
        return tTLBossData.nTimeState ~= e_tlboss_time.no
    end

    return false
end
function WarHallBossVo:isShowRedTip(  )
    -- body
    return self:isShowBuildingBubble()
end
-- 是否能跳转面板(覆盖)
function WarHallBossVo:isCanOpenDlg()
    return WarHallBossVo.super.isCanOpenDlg(self)
end

return WarHallBossVo

--endregion
