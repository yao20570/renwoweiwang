--region 战争大厅数据->过关斩将.lua
--Author : wenzongyao
--Date   : 2018/3/21
--此文件由[BabeLua]插件自动生成

local WarHallBaseVo = require("app.layer.warhall.data.WarHallBaseVo")

local WarHallEpwVo = class("WarHallEpwVo", WarHallBaseVo)


--tWarHallConfig:table 配置数据
function WarHallEpwVo:ctor(tWarHallConfig)
    WarHallEpwVo.super.ctor(self, tWarHallConfig)
end

-- 获取描述(覆盖)
function WarHallEpwVo:getDescript1()    
    return WarHallEpwVo.super.getDescript1(self)
end

-- 获取描述(覆盖)
function WarHallEpwVo:getDescript2()
    if Player:getImperWarData():getImperWarIsOpen() then
        return getConvertedStr(3, 10848)
    end
    local pData = Player:getImperWarData()
    return getConvertedStr(10, 10207) .. getTimeLongStr(pData:getOpenCd(),false,true) --开始倒计时
end

-- 活动是否开启
function WarHallEpwVo:isOpen()    
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    return true
end

-- 是否显示建筑气泡(可能需要函数覆盖)
function WarHallEpwVo:isShowBuildingBubble()
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    local bCan1 = Player:getImperWarData():getIsRankAward()
    local bCan2 = Player:getImperWarData():getIsStageAward()
    if bCan1 or bCan2 then
        return true
    end
        
    return Player:getImperWarData():getImperWarIsOpen()
end

function WarHallEpwVo:isShowRedTip(  )
    -- body
    return self:isShowBuildingBubble()
end

function WarHallEpwVo:reqData()
    WarHallEpwVo.super.reqData(this)
end

-- 是否能跳转面板(覆盖)
function WarHallEpwVo:isCanOpenDlg()
    -- return WarHallEpwVo.super.isCanOpenDlg(self)
    if self:isLock() == true then        
        --未解锁
        return false     
    end
    return true
end


return WarHallEpwVo

--endregion
