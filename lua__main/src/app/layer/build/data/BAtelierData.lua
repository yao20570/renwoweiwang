-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 18:16:51 星期五
-- Description: 作坊数据 
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")
local AtelierProduceData = require("app.layer.atelier.AtelierProduceData")

local BAtelierData = class("BAtelierData", function()
	-- body
	return Build.new()
end)

function BAtelierData:ctor(  )
	-- body
	self:myInit()
end


function BAtelierData:myInit(  )
	self.nBuyQueue 		= 		0 		--购买队列数
	self.nQueue 		= 		0	 	--队列数
	self.tProQueue 		= 		nil 	--生产队列
	self.tWaitQueue 	= 		nil 	--等待队列
	self.tFinshQueue 	= 		nil		--生产完成队列
	self.nOutQueue 		= 		0 		--离线生产队列数
	self.nNd 			= 		0 		--预计生产时间
	self.nOpenGuideCnt 	= 		0 		--工坊引导对话框打开次数

	self.nPrevIdx 		= 		1 		--上次离开时选中的下标
end

--从服务端获取数据刷新
function BAtelierData:refreshDatasByService( tData )
	--dump(tData, "工坊：", 100)
	-- body
	self.nBuyQueue 				= 		tData.bq or self.nBuyQueue 		--购买队列数
	self.nQueue 				= 		tData.q or self.nQueue	 		--队列数
	self.nOutQueue 				= 		tData.oq or self.nOutQueue	 	--离线生产队列数
	self.nCellIndex 			= 		tData.loc or self.nCellIndex  	--建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		  	--等级
	--刷新生产队列
	if tData.pros then
		self.tProQueue = {}
		for k, v in pairs(tData.pros) do			
			local tmpdata = AtelierProduceData.new(true)--自动刷新cd
			tmpdata:refreshDatasByService(v)
			table.insert(self.tProQueue, tmpdata)
		end
	else
		self.tProQueue			= 		self.tProQueue
	end
	--刷新等待队列
	if tData.wpros then
		self.tWaitQueue = {}
		for k, v in pairs(tData.wpros) do
			local tmpdata = AtelierProduceData.new(false)--自动刷新cd
			tmpdata:refreshDatasByService(v)
			table.insert(self.tWaitQueue, tmpdata)
		end
	else
		self.tWaitQueue			= 		self.tWaitQueue
	end
	--刷新生产完成队列
	if tData.fpros then
		self.tFinshQueue = {}
		for k, v in pairs(tData.fpros) do
			local tmpdata = AtelierProduceData.new(false)--自动刷新cd
			tmpdata:refreshDatasByService(v)
			table.insert(self.tFinshQueue, tmpdata)
		end
	else
		self.tFinshQueue			= 		self.tFinshQueue
	end
	if self:isAtelierProducing() == true then
		self.nState = e_build_state.producing
	else
		self.nState = e_build_state.free
	end	
	--发送工坊数据刷新消息
	sendMsg(ghd_refresh_atelier_msg)

end	

--根据序号获取生产队列数据
function BAtelierData:getProQueueItemByIdx( _idx )
	-- body

	if not self.tProQueue or not _idx then
		return nil
	end
	local data = nil
	for k, v in pairs(self.tProQueue) do
		if v and v.nId == _idx then
			data = v
			return data
		end
	end
	return nil
end

--获取生产Cd
function BAtelierData:getProQueueCDByIdx( _idx )
	-- body
	local tProQueue = self:getProQueueItemByIdx(_idx)
	if tProQueue then
		return tProQueue:getProduceCD()
	else
		return 0
	end
end
--根据序号获取等待队列数据
function BAtelierData:getWaitQueueItemByIdx( _idx )
	-- body
	if not self.tWaitQueue or not _idx then
		return nil
	end
	local data = nil
	for k, v in pairs(self.tWaitQueue) do
		if v and v.nId == _idx then
			data = v
			return data
		end
	end
	return nil
end
--根据序号获取完成队列数据
function BAtelierData:getFinshQueueItemByIdx( _idx )
	-- body
	if not self.tFinshQueue or not _idx then
		return nil
	end
	local data = nil
	for k, v in pairs(self.tFinshQueue) do
		if v and v.nId == _idx then
			data = v
			return data
		end
	end
	return nil
end

--获取队列中最先生产的完成的队列数据
function BAtelierData:getFirstFinshQueueItem(  )
	-- body
	if not self.tFinshQueue then
		return nil
	end
	return self.tFinshQueue[1]
end

--获取生产队列中剩余生产时间最短的加速消费
function BAtelierData:getSpeedProQueueCost(  )
	-- body
	local nCost = 0
	if not self.tProQueue or #self.tProQueue <= 0 then
		nCost = 0
	end
	table.sort( self.tProQueue, function ( a, b )
		-- body
		return a:getProduceCD() < b:getProduceCD()
	end )
	nCost = getGoldByTime(self.tProQueue[1]:getProduceCD())
	return nCost
end

--获取生产队列中剩余生产时间最短生产队列
function BAtelierData:getShortTimeProQueue(  )
	-- body

	if not self.tProQueue or #self.tProQueue <= 0 then
		return nil
	end
	table.sort( self.tProQueue, function ( a, b )
		-- body
		return a:getProduceCD() < b:getProduceCD()
	end )
	return self.tProQueue[1]
end

--获取生产队列长度
function BAtelierData:getProQueueNum(  )
	-- body
	if self.tProQueue then
		return #self.tProQueue
	else
		return 0
	end
end

--刷新生产时间
function BAtelierData:refreshProduceTimeByService( tData )
	-- body
	if not tData then
		return
	end
	self.nNd = tData.nd or self.nNd
end

--获取生产时间
function BAtelierData:getProduceTime(  )
	-- body
	return self.nNd
end
--打开工坊引导对话框
function BAtelierData:openGuide( )
	-- body
	self.nOpenGuideCnt = self.nOpenGuideCnt + 1
end
--是否打开工坊引导
function BAtelierData:isCanOpenGuild( )
	-- body
	if self.nOpenGuideCnt > 0 then
		return false
	else
		return true
	end

end

--是否正在生产
function BAtelierData:isAtelierProducing(  )
	-- body
	if self.tProQueue and #self.tProQueue > 0  then 
		return true
	else
		if self.tFinshQueue and #self.tFinshQueue > 0 then
			return true
		end
	end
	return false
end

--获取正在生产队列数目
function BAtelierData:getFinishedQueueNum( )
	-- body
	if self.tFinshQueue then
		return #self.tFinshQueue
	end
	return 0
end

function BAtelierData:setProduceRecord( nIdx )
	-- body
	self.nPrevIdx = nIdx
	saveLocalInfo("Atelier_Cur_Index"..Player:getPlayerInfo().pid, self.nPrevIdx)
end

function BAtelierData:getProduceRecord(  )
	-- body
	local sPreIdx = getLocalInfo("Atelier_Cur_Index"..Player:getPlayerInfo().pid, "1")
	return tonumber(sPreIdx)
end
return BAtelierData