--region NewFile_1.lua
--Author : User
--Date   : 2018/3/22
--此文件由[BabeLua]插件自动生成

local WarHallData = class("WarHallData")

eWallHallType = {
    Exam = 1,       --每日答题
    Arena = 2,      --竞技场
    MingJie = 3,    --冥界入侵
    Boss = 4,       --魔神来袭
    Expedite = 5,   --过关斩将
    epw = 6,        --阿房宫战斗
}

--战争大厅活动基础类
local WarHallBaseVo = require("app.layer.warhall.data.WarHallBaseVo")
-- 数据类注册（都继承WarHallBaseVo）
tWarHallDataClass = {}
tWarHallDataClass[eWallHallType.Exam]       = require("app.layer.warhall.data.WarHallExamVo")
tWarHallDataClass[eWallHallType.Arena]      = require("app.layer.warhall.data.WarHallArenaVo")
tWarHallDataClass[eWallHallType.MingJie]    = require("app.layer.warhall.data.WarHallMingJieVo")
tWarHallDataClass[eWallHallType.Boss]       = require("app.layer.warhall.data.WarHallBossVo")
tWarHallDataClass[eWallHallType.Expedite]   = require("app.layer.warhall.data.WarHallExpediteVo")
tWarHallDataClass[eWallHallType.epw]   = require("app.layer.warhall.data.WarHallEpwVo")

-- 获取数据类
function getWarHallCreateClass(eType)
    local tClass = tWarHallDataClass[eType] or WarHallBaseVo
    return tClass
end



function WarHallData:ctor()
    self:init()
end

function WarHallData:init()
    self.tActivityList = {}
    local tSysAct = getSystemActivitys()
    for k, v in pairs(tSysAct) do        
        if v.show == 1 then -- 配置标记为显示的
            local eType = v.id
            local class = getWarHallCreateClass(eType)
            self.tActivityList[eType] = class.new(v)
        end
    end

end

-- 全部的活动
function WarHallData:getList()
    return self.tActivityList
end

-- 获取战争大厅显示列表
function WarHallData:newListByType(nType)
    local list = {}
    --对应类型的
    for k, v in pairs(self.tActivityList) do
        if v.nType == nType then
            table.insert(list, v)
        end
    end

    return list
end


return WarHallData

--endregion
