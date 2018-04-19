-- DayLoginData.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-30 13:57:23 星期五
-- Description: 每日登录数据
-----------------------------------------------------

-- 公告数据类
local DayLoginData = class("DayLoginData")



function DayLoginData:ctor()
	self.nHasDayAwards               = 1      --是否有每日登录奖励可领取
	self.tAwardsList                 = {}         --List<Pair<Integer,Long>>奖励列表
	self.nCurDay 					 = 1    --现在是第几天
	self.tGuideInterface             = {}     --已经引导过的界面列表
end

--[4019]检查是否可以领取每日奖励
function DayLoginData:onDayLoginAwards( tData )
	-- body
	local tNoticeInfo = self:createDayLoginAwdInfo(tData)
	
end

--根据服务端信息调整每日登录奖励信息
function DayLoginData:refreshDatasByService(_tData)
	-- body
	if not _tData then return end
	self.nHasDayAwards         = _tData.rec or self.nHasDayAwards --每日奖励是否领取 0未领取1已领取
	self.tAwardsList           = _tData.ob  or self.tAwardsList   --List<Pair<Integer,Long>>奖励列表
	self.nCurDay 			   = _tData.day or self.nCurDay
end

--设置是否可领取
function DayLoginData:setGetAwardState(_state)
	-- body
	self.nHasDayAwards = _state
end


--获取是否有奖励可领取
function DayLoginData:isHasDayLoginAwards()
	-- body
	return self.nHasDayAwards == 0
end

--获取奖励列表
function DayLoginData:getAwardsList()
	return self.tAwardsList
end
--获取当天登录奖励
function DayLoginData:getCurAwardList( )
	return self.tAwardsList[tostring(self.nCurDay)]
end

--设置已经引导过的界面
function DayLoginData:setAlreadyGuidedView(_data)
	if not _data then
		return
	end
	if type(_data) == "table" then
		for k, v in pairs(_data) do
			self.tGuideInterface[v] = true
		end
	else
		self.tGuideInterface[_data] = true
	end
end

--获取已经引导过的界面
function DayLoginData:getAlreadyGuidedView()
	-- body
	return self.tGuideInterface
end


return DayLoginData