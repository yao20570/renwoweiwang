----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-19 15:18:36
-- Description: 攻城掠地
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataAttkCity = class("DataAttkCity", function()
	return Activity.new(e_id_activity.attackcity) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.attackcity] = function (  )
	return DataAttkCity.new()
end

function DataAttkCity:ctor()
   self:myInit()
end


function DataAttkCity:myInit( )
	self.tTs= {}                               --List<TakeCityTaskVO> 任务列表 
	self.tFds ={}                              --List<TaskFinishDetail> 任务已完成信息 
	self.nP = 0                                -- Integer 玩家活跃积分 
	self.tBs ={}                               --List<BoxAward> 宝箱列表数据 
	self.tGs = {}                              --Set<Integer> 玩家已领取的宝箱ID 
	-- self.nFtf = 0 							   -- Integer <首次攻破城池>任务是否完成0:否 1:是 
	self.nFtg = 0 							   --Integer <首次攻破城池>奖励是否领取0:否 1:是 
	
	self.nDbg = 0 
	self.nD = 0 								--开启天数
end


-- 读取服务器中的数据
--_tData(ConsumeIronRes)
function DataAttkCity:refreshDatasByServer( _tData )
	-- dump(_tData,"attkcity")
	if not _tData then
	 	return
	end
	-- self.tTs= _tData.ts or self.tTs            --List<TakeCityTaskVO> 任务列表 
	-- self.tFds = _tData.fds or self.tFds        --List<TaskFinishDetail> 任务已完成信息 
	self:updateProgress(_tData)
	self.nP = _tData.p or self.nP              -- Integer 玩家活跃积分 
	self.tBs = _tData.bs or self.tBs           --List<BoxAward> 宝箱列表数据 
	self.tGs = _tData.gs or self.tGs           --Set<Integer> 玩家已领取的宝箱ID 
	-- self.nFtf = _tData.ftf or self.nFtf          -- Integer <首次攻破城池>任务是否完成0:否 1:是 
	self.nFtg = _tData.ftg or self.nFtg 	   --Integer <首次攻破城池>奖励是否领取0:否 1:是 
	self.nDbg = _tData.dbg or self.nDbg 
	self.nD  = _tData.d or self.nD
	self:refreshActService(_tData)--刷新活动共有的数据
end

--return nState  1 未达到、2 可领取 3 已领取 
function DataAttkCity:getBxState( _nId,_nPoint )
	-- body
	local nState = 1
	if self.nP < _nPoint then
		return nState
	else
		nState = 2
		for i = 1,#self.tGs do
			if _nId == self.tGs[i] then
				nState = 3 
			end
		end
	end
	return nState
end
function DataAttkCity:updateProgress( _tData )
	-- body
	local tChangeList ={}
	if _tData.fds then
		for k,v in pairs(self.tFds) do
			for kk,vv in pairs(_tData.fds) do
				if v.id == vv.id and v.process ~=vv.process then   --有一个变化了的进度
					local tTemp={id = v.id,num = vv.process-v.process}
					table.insert(tChangeList,tTemp)
				end
			end
		end
	end
	for i = 1,#tChangeList do
		local tTemp=getAttkCityTaskById(tChangeList[i].id)
		if tTemp then
			local sStr=string.format(getConvertedStr(9,10131),tTemp.title,tTemp.score)
			TOAST(sStr)
		end
	end
	self.tFds = _tData.fds or self.tFds        --List<TaskFinishDetail> 任务已完成信息 

end
function DataAttkCity:getProcessById( _nId )
	-- body
	local nProcess = 0
	for i = 1,#self.tFds do
		if self.tFds[i].id == _nId then
			return self.tFds[i].process
		end
	end
end

function DataAttkCity:getCurDay(  )
	-- body
	
	local nD = self.nD
	if nD >5 then
		nD = 5
	end

	return nD

end
--return nState 1 未完成、2 已完成、3 已领取
function DataAttkCity:getFirstAttkCityState(  )
	-- body
	local nState = 1
	for i=1,#self.tFds do
		if self.tFds[i].id == 1 then  		--已完成
			nState=2
			break
		end
	end
	if nState == 2 then
		if self.nFtg == 1 then --已领取
			nState = 3
		end
	end

	return nState
end

-- 获取红点方法
function DataAttkCity:getRedNums()
	local nRedNum = 0 
	local bIsFirst = 0
	local bIsBx = 0
	local bIsDaily = 0
	--首次攻城
	if self:getFirstAttkCityState() == 2 then
		nRedNum = nRedNum + 1
		bIsFirst = 1
	end
	--宝箱奖励
	local tRewardData = getAttkCityBxData() 
	if tRewardData then
		for k,v in pairs(tRewardData) do
			if self:getBxState(v.id,v.cost) == 2 then
				nRedNum = nRedNum + 1
				bIsBx = 1
			end
		end
	end
	--每日宝箱
	if self.nDbg == 0 then

		nRedNum = nRedNum + 1
		bIsDaily = 1
	end
	return nRedNum , bIsFirst,bIsBx, bIsDaily

end
function DataAttkCity:getOnlyTimeStr(  )
	-- body
	
	local nNowTime = getSystemTime()
	local nTime  = self.nRemainTime - (nNowTime-self.nRefreshLoginTime)
	local sTime = getTimeLongStr(nTime,true,false,true)
	return sTime
end



return DataAttkCity