--region 战争大厅数据->过关斩将.lua
--Author : wenzongyao
--Date   : 2018/3/21
--此文件由[BabeLua]插件自动生成

local WarHallBaseVo = require("app.layer.warhall.data.WarHallBaseVo")

local WarHallExpediteVo = class("WarHallExpediteVo", WarHallBaseVo)


--tWarHallConfig:table 配置数据
function WarHallExpediteVo:ctor(tWarHallConfig)
    WarHallExpediteVo.super.ctor(self, tWarHallConfig)
end

-- 获取描述(覆盖)
function WarHallExpediteVo:getDescript1()    
    return WarHallExpediteVo.super.getDescript1(self)
end

-- 获取描述(覆盖)
function WarHallExpediteVo:getDescript2()
    local pData = Player:getPassKillHeroData()
    local sLeftTimes = getConvertedStr(10, 10210) .. pData:getLeftVipResetTimes()
    return sLeftTimes
end

-- 活动是否开启
function WarHallExpediteVo:isOpen()    
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    return true
end

-- 是否显示建筑气泡(可能需要函数覆盖)
function WarHallExpediteVo:isShowBuildingBubble()
    if self:isLock() == true then        
        --未解锁
        return false     
    end
        
    local pData = Player:getPassKillHeroData()
    return pData:getLeftVipResetTimes() > 0
end

function WarHallExpediteVo:isShowRedTip(  )
    -- body
    if self:isLock() == true then        
        --未解锁
        return false     
    end
        
    local pData = Player:getPassKillHeroData()
    if pData:getLeftVipResetTimes() > 0 then
        return true
    end
    return false
end

function WarHallExpediteVo:reqData()
    WarHallExpediteVo.super.reqData(this)
end

-- 是否能跳转面板(覆盖)
function WarHallExpediteVo:isCanOpenDlg()
    return WarHallExpediteVo.super.isCanOpenDlg(self)
end


return WarHallExpediteVo

--endregion
