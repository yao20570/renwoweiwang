-- Author: luwenjing
-- Date: 2018-02-28 17:13:03
-- 武将收集数据

local Activity = require("app.data.activity.Activity")

local DataHeroCollect = class("DataHeroCollect", function()
	return Activity.new(e_id_activity.herocollect) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.herocollect] = function (  )
	return DataHeroCollect.new()
end

function DataHeroCollect:ctor()
	-- body
   self:myInit()
end


function DataHeroCollect:myInit( )
 	self.tTs = {}	-- List<CollectHeroTaskVO> 任务列表 
	self.tGets = {}	-- List<Integer> 已领取的奖励 

end

-- 读取服务器中的数据
function DataHeroCollect:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end
	self.tTs = _tData.ts or self.tTs	-- List<CollectHeroTaskVO> 任务列表 
	self.tGets = _tData.gets or self.tGets	-- List<Integer> 已领取的奖励 
	--物品排序
	for i=1,#self.tTs do
		sortGoodsList(self.tTs[i].ob)
	end

	self:setRewardState()
	self:refreshActService(_tData)--刷新活动共有的数据
end
--1--已完成 2--未完成 3--已领取
function DataHeroCollect:setRewardState()

	for i=1,#self.tTs do
		local nState = 2
		local nNum =  Player:getHeroInfo():getHeroNumByQuality(self.tTs[i].quality) --获取该品质的英雄数量
		if nNum >= self.tTs[i].num then   --已完成任务
			for j = 1,#self.tGets do
				if self.tGets[j] == self.tTs[i].id then
					nState = 3
					break
				end
			end
			if nState ==2 then
				nState = 1
			end
		end

		self.tTs[i].curNum = nNum
		self.tTs[i].state = nState
	end
	self:resortList()
end

function DataHeroCollect:resortList(  )
	-- body
	table.sort(self.tTs,function ( a,b )
		-- body
		if a.state == b.state then
			return a.id < b.id
		else
			return a.state < b.state
		end
	end)

end

function DataHeroCollect:getJumpLayerId(_nId )
	-- body
	local tTemp=luaSplit(self.tParam,"|")
	
	for i=1,#tTemp do
		local tTemp2= luaSplit(tTemp[i],",")
		
		if tTemp2 and #tTemp2 > 1 then
			if tonumber(tTemp2[1]) == _nId then
				return tonumber(tTemp2[#tTemp2])
			end
		end
	end

end

-- 获取红点方法
function DataHeroCollect:getRedNums()
	local nNums = 0
	for i=1,#self.tTs do
		if self.tTs[i].state == 1 then
			nNums = nNums + 1
		end
	end
	return nNums
end

return DataHeroCollect