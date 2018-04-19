--region GC管理器
--Author : wenzongyao
--Date   : 2018/2/7
--此文件由[BabeLua]插件自动生成

GCMgr = {}

local MaxGCMemory = 30 * 1024 -- 初始GC内存上限（初始的）
local AddGCMemory = 20 * 1024 -- 回收内存增量
MaxGCMemory = MaxGCMemory + AddGCMemory

-- 检查计算 CheckCount == CheckCD时如果TimeCost<FrameFreeFlag比较空闲则进行回收
CheckCount = 0
local CheckCD = 60 * 10 -- 3600帧后检查
  
TimeCost = 999999
local MaxCost = 5      -- TimeCost低于MaxCost(毫秒)代表比较空闲

local isTOAST = false    -- 关闭tip

function GCMgr:checkTimeStart()
    self.startTimestamp = getSystemTime(false)
end

function GCMgr:checkTimeEnd()
    self.endTimestamp = getSystemTime(false)
    TimeCost = self.endTimestamp - self.startTimestamp
end

-- 达到一定时间，进行gc(必须配合GCMgr:checkTimeStart， GCMgr:checkTimeEnd使用)
function GCMgr:gcByCount()
    CheckCount = CheckCount + 1
    if CheckCount >= CheckCD then
        if TimeCost < MaxCost then
            self:gc()
        end
    end
end

-- 达到指定上限，进行gc
function GCMgr:gcByMax()    
--    local perCount = math.floor(collectgarbage("count"))
--    if perCount > MaxGCMemory then     
--        self:gc()
--    end
end

-- 进行gc
function GCMgr:gc()
    local perCount = math.floor(collectgarbage("count"))
    collectgarbage("collect")
    local curCount = math.floor(collectgarbage("count"))
    MaxGCMemory = curCount + AddGCMemory
    CheckCount = 0
--    if isTOAST then
--        TOAST(string.format("上限回收===>回收:%s, 当前:%s, 重置上限:%s", curCount - perCount, curCount, MaxGCMemory))
--    end
--    release_print(string.format("上限回收===>回收:%s, 当前:%s, 重置上限:%s", curCount - perCount, curCount, MaxGCMemory))
end

--endregion
