-----------------------------------------------------
-- author: xiesite
-- updatetime:  2017-12-27 16:19:51
-- Description: 剧情章节数据
-----------------------------------------------------

local Goods = require("app.data.Goods")
local DataChatperTask = class("DataChatprtTatget", Goods)


function DataChatperTask:ctor(  )
	DataChatperTask.super.ctor(self,e_type_goods.type_chatper)
	-- body
	self:myInit()
end


function DataChatperTask:myInit( )
	--拓展字段
	self.tTargets  =  {} --章节数据
	self.sTid = 0 --章节id
	self.nO  = 0 --是否新开启，0-不是， 1-是

	--任务目标
	self.nCurNum 				=		0 			--当前完成的次数
	self.nTargetNum 			= 		1
	self.nIsGetPrize 			= 		0 			--是否已经领取奖励0未领取 1已领取
	self.nIsFinished 			=		0 			--是否已经完成0未完成 1已完成

end

function DataChatperTask:isNew()
	if self.nO == 1 then
		return true
	end
	return false
end

--_tData-章节数据, _o是否新开启
function DataChatperTask:refreshItemDataByService(_tData, _o)
	if not _tData then
		return
	end
	self.sTid = _tData.i or self.sTid
	self.nIsGetPrize = _tData.t or self.nIsGetPrize
	self.nO = _o or 0

	if _tData.ts then
		if #self.tTargets > 0 then
			for k, v in pairs(_tData.ts) do
				for key, target in pairs(self.tTargets) do
					if target.sTid == v.i then
						target:refreshItemDataByService(v)
					end
				end
			end
		else
			for k, v in pairs(_tData.ts) do
				local target = getChatperTaskBaseDataFromDB(v.i)
				if target then
					target:refreshItemDataByService(v)
					table.insert(self.tTargets, target)
				end
			end
		end
	end
	self:sortTargets()
	self:updateFinishState()
end

-- 用配置表DB中的数据来重置基础数据
function DataChatperTask:initDataByDB( tData )
	-- body
	--基本信息
	self.sTitle 				= 		tData.title or self.sTitle --标题
	self.sName 					= 		self.sTitle .." "..getConvertedStr(1, 10330)     

	--描述
	self.sDes					= 		tData.describe or self.sDes     --任务说明

	--拓展字段
	self.nDrop					= 		tData.drop or self.nDrop 	     --掉落ID

	self.tDialogs 				=	 	getChatperDialogData(self.sTid) or {} --剧情对话信息 order
 	local sortFunc = function(a, b)
 		if a.order < b.order then
 			return true
 		end
 	end
 	table.sort(self.tDialogs.s, sortFunc)
 	table.sort(self.tDialogs.e, sortFunc)
end
	
--nType对话类型 1-开启对话， 2-结束对话
function DataChatperTask:showDialog( nType, nDelay)
	local nTime = nDelay or 0.1
	doDelayForSomething(RootLayerHelper:getCurRootLayer(), function( )
		if nType == 1 and self.tDialogs.s and #self.tDialogs.s > 0 then
			openDialog(self.tDialogs.s, function()
				local tObject = {}
				tObject.nType = e_dlg_index.chatperInfo --dlg类型
				tObject.tData = Player:getPlayerTaskInfo():getChatperTask()
				if tObject.tData then
					sendMsg(ghd_show_dlg_by_type,tObject)
				end
			end)

		elseif nType == 2 and self.tDialogs.e and #self.tDialogs.e > 0 then
			openDialog(self.tDialogs.e, function()
				local tChatper = Player:getPlayerTaskInfo():getChatperTask()
				if tChatper then
					openChatperOpen()
				end
			end)
		end
	end, 0.1)	
end

function DataChatperTask:sortTargets()
	if self.tTargets and #self.tTargets > 0 then
		table.sort(self.tTargets, function(a,b)
			if a.nSort < b.nSort then
				return true
			elseif a.nSort > b.nSort then
				return false
			else
				return a.sTid < b.sTid
			end
		end)
	end
end

function DataChatperTask:getCurTask()
	if self.tTargets and self.tTargets[1] then
		--排序后判断首个任务状态，首个不是已领取代表有步骤没走完
		if self.tTargets[1].nGetPrizeState ~= 2 then
			return self.tTargets[1]
		end
	end
	--所有子章节完成后就返回章节状态,当前章节也完成就会返回nil
	if self.nIsGetPrize == 1 and self.nIsFinished == 1 then
		return nil
	end

	return self
end

function DataChatperTask:canGetReward()
	if self.nIsGetPrize == 0 and self.nIsFinished == 1 then
		return true
	else 
		return false
	end
end

function DataChatperTask:getTargets()
	return self.tTargets;
end

function DataChatperTask:updateTargetByService(_data)
	for i=1, #self.tTargets do
		if self.tTargets[i] and self.tTargets[i].sTid then
			self.tTargets[i]:refreshItemDataByService(_data)
		end
	end

	self:updateFinishState()
end

function DataChatperTask:updateFinishState()
	for i=1, #self.tTargets do
		if self.tTargets[i].nIsFinished == 0 then
			self.nIsFinished = 0
			return
		end
	end
	self.nIsFinished = 1
end

function DataChatperTask:setOpenStatus( nState )
	if nState then
		self.nO = nState
	end
end

return DataChatperTask
