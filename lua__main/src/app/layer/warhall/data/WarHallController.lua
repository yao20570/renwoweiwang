--region NewFile_1.lua
--Author : wenzongyao
--Date   : 2018/3/20
--此文件由[BabeLua]插件自动生成


local WarHallData = require("app.layer.warhall.data.WarHallData")


-- 获得玩家基础信息单例
function Player:getWarHall()
    -- body
    if not Player.warHall then
        self:initWarHallData()
    end
    return Player.warHall
end

-- 初始化玩家基础数据
function Player:initWarHallData()
    if not Player.warHall then
        Player.warHall = WarHallData.new()
    end
    return "Player.warHall"
end

-- 释放玩家基础数据
function Player:releaseWarHallData()
    if Player.warHall then
        Player.warHall = nil        -- 玩家的基础信息
    end
    return "Player.warHall"
end




--endregion
