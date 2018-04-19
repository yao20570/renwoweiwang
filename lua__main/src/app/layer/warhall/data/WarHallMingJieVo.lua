--region 战争大厅数据->冥界入侵.lua
--Author : wenzongyao
--Date   : 2018/3/21
--此文件由[BabeLua]插件自动生成

local WarHallBaseVo = require("app.layer.warhall.data.WarHallBaseVo")

local WarHallMingJieVo = class("WarHallMingJieVo", WarHallBaseVo)


--tWarHallConfig:table 配置数据
function WarHallMingJieVo:ctor(tWarHallConfig)
    WarHallMingJieVo.super.ctor(self, tWarHallConfig)
end

-- 获取描述(覆盖)
function WarHallMingJieVo:getDescript1()    
    return WarHallMingJieVo.super.getDescript1(self)
end

-- 获取描述(覆盖)
function WarHallMingJieVo:getDescript2()
    local sRet = getConvertedStr(9, 10221)
    local tData = Player:getActById(e_id_activity.mingjie)
    if tData then
        if tData.nS == 0 then
            sRet = getConvertedStr(10, 10212) .. getTimeLongStr(tData:getStageLeftTime(),false,true)
        elseif tData.nS == 1 then
            sRet = getConvertedStr(10, 10213) .. getTimeLongStr(tData:getStageLeftTime(),false,true)
        elseif tData.nS == 2 then
            sRet = getConvertedStr(10, 10214) .. getTimeLongStr(tData:getStageLeftTime(),false,true)
        end
    end
    return sRet
end

-- 活动是否开启(覆盖)
function WarHallMingJieVo:isOpen()
    if self:isLock() == true then        
        --未解锁
        return false     
    end

    local tData = Player:getActById(e_id_activity.mingjie)
    if tData then
        return true
    end

    return false
end

-- 是否显示建筑气泡(覆盖)
function WarHallMingJieVo:isShowBuildingBubble()
   if self:isLock() == true then        
       --未解锁
       return false     
   end

   local tData = Player:getActById(e_id_activity.mingjie)
    if tData then
       if tData:getRedNums() > 0 then
           return true
       end   

       -- if tData.nS == 0 then
       --     --准备阶段
       --     local nLeftTime = tData:getStageLeftTime()
       --     if nLeftTime < self.nBubbleShow * 60 then
       --         return true
       --     end
       -- elseif tData.nS == 1 then            
       --     return tData:getStageLeftTime() > 0
       -- elseif tData.nS == 2 then            
       --     return tData:getStageLeftTime() > 0
       -- end
    end
    return false
end
function WarHallMingJieVo:isShowRedTip( )
  -- body
  if self:isLock() == true then        
       --未解锁
       return false     
   end

   local tData = Player:getActById(e_id_activity.mingjie)
    if tData then
       if tData:getRedNums() > 0 then
           return true
       end   
    end
    return false
end

-- 是否能跳转面板(覆盖)
function WarHallMingJieVo:isCanOpenDlg()
    -- local tData = Player:getActById(e_id_activity.mingjie)
    -- if tData == nil then
    --     TOAST(getConvertedStr(10, 10215))
    --     return false
    -- end
    return WarHallMingJieVo.super.isCanOpenDlg(self)
    
    -- return true
end

return WarHallMingJieVo

--endregion
