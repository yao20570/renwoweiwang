--region 战争大厅数据->竞技场.lua
--Author : wenzongyao
--Date   : 2018/3/21
--此文件由[BabeLua]插件自动生成

local WarHallBaseVo = require("app.layer.warhall.data.WarHallBaseVo")

local WarHallArenaVo = class("WarHallArenaVo", WarHallBaseVo)


--tWarHallConfig:table 配置数据
function WarHallArenaVo:ctor(tWarHallConfig)
    WarHallArenaVo.super.ctor(self, tWarHallConfig)
end

-- 活动是否开启
function WarHallArenaVo:isOpen()
    if self:isLock() == true then        
        --未解锁
        return false     
    end
    return true
end

-- 获取描述(覆盖)
function WarHallArenaVo:getDescript1()    
    return ""
end

-- 获取描述(覆盖)
function WarHallArenaVo:getDescript2()
    local leftTimes = 0
    local pData = Player:getArenaData()
    if pData and pData.nChallenge then
        leftTimes = pData.nChallenge
    end
    return string.format(getConvertedStr(10, 10206) .. leftTimes)
end

-- 是否显示建筑气泡(覆盖)
function WarHallArenaVo:isShowBuildingBubble()
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    local bCan = false
    local pData = Player:getArenaData()
    if pData then
        local isSetted = pData:isHaveSetArenaLineUp()
        if isSetted then            -- 已经设置了竞技场阵容
            bCan = pData:isCanArenaChallenge()
        else
            bCan = true
        end
    end
    return bCan
end
function WarHallArenaVo:isShowRedTip(  )
    -- body
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    local bCan = false
    local pData = Player:getArenaData()
    if pData then
        local isSetted = pData:isHaveSetArenaLineUp()
        if isSetted then            -- 已经设置了竞技场阵容
            bCan = pData:isCanArenaChallenge()
        else
            bCan = true
        end
        local nNum =pData:getScroeRedNum() + pData:getRankRedNum() + pData:getLuckyRedNum() + pData:getArenaHeroRedNum()
        if nNum > 0 then
            bCan = true
        end

    end
    return bCan
end

-- 请求数据(覆盖)
function WarHallArenaVo:reqData()
    --MsgType.checkArenaRank = {id = -6109, keys = {"page", "size"}}
    SocketManager:sendMsg("checkArenaRank", {1, ARENA_RANK_PAGE_LENGTH}) --刷新排行奖励数据
end

-- 是否能跳转面板(覆盖)
function WarHallArenaVo:isCanOpenDlg()
    return WarHallArenaVo.super.isCanOpenDlg(self)
end


return WarHallArenaVo

--endregion
