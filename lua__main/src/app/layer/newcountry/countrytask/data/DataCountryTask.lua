----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-04-03 16:56:33
-- Description: 国家任务数据
-----------------------------------------------------

local BCountryTask = require("app.layer.newcountry.countrytask.data.BCountryTask")
--免费宝箱数据
local DataCountryTask = class("DataCountryTask")

function DataCountryTask:ctor(  )
	self:myInit()
end

function DataCountryTask:myInit(  )		
	self.tTask = {}
	self.tGet 	= {}
	self.nCd = nil
end

-- 读取服务器中的数据
function DataCountryTask:refreshDatasByService( _tData )
	-- dump(_tData,"国家任务", 100)
	if not _tData then
	 	return
	end
	--任务刷新时间
	self.nCd = _tData.cd or self.nCd
	if _tData.cd then
		self.nLastLoadTime = getSystemTime()
	end
	--领奖数据刷新
	self.tGet 	= _tData.alaw or self.tGet --已领取奖励的任务ID
	--任务完成情况刷新
	if _tData.task then
		self.tTask = {}
		for idx, v in pairs(_tData.task) do
			local pBaseTask = getCountryTaskById(v.k)
			if pBaseTask then
				local pTask = BCountryTask.new(pBaseTask)
				if pTask then
					pTask:updateByService(v.v, self:isTaskGetRewardById(v.k))
					table.insert(self.tTask, pTask)
				end
			else
				print("countrytask data error ！！！！！！！！！！")
			end
		end
		if #self.tTask > 0 then
			table.sort(self.tTask, function ( a, b )
				-- body
				return a.nId < b.nId
			end)
		end
	else
		for k, v in pairs(self.tTask) do
			v:updateStatus(self:isTaskGetRewardById(v.nId))
		end		
	end	
end


function DataCountryTask:getCountryTaskList( )
	-- body
	return self.tTask
end

function DataCountryTask:isTaskGetRewardById( _id )
	-- body
	if not _id then
		return false
	end
	for k, v in pairs(self.tGet) do
		if v == _id then
			return true
		end
	end

	return false
end

function DataCountryTask:getCdTime( ... )
	-- body	
	-- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	if self.nCd then
		local fLeft = self.nCd - (fCurTime - self.nLastLoadTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

function DataCountryTask:getCountryTaskRed(  )
	-- body
	local nNum = 0
	if self.tTask and #self.tTask > 0 then
		for k, v in pairs(self.tTask) do
			if v:isCanGetReward() then
				nNum = nNum + 1				
			end
		end
	end
	return nNum
end

return DataCountryTask