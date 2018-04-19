-- Author: xiesite
-- Date: 2018-03-06 10:20:36
-- 科技兴国数据


local Activity = require("app.data.activity.Activity")

local DataSciencePromote = class("DataSciencePromote", function()
	return Activity.new(e_id_activity.sciencepromote) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.sciencepromote] = function (  )
	return DataSciencePromote.new()
end

function DataSciencePromote:ctor()
    self:myInit()
end


function DataSciencePromote:myInit( )
	self.tFi = {}		--完成情况
	self.tAlaw = {}		--已经获得的奖励
	self.tConf = {}		--配置
 	self.nTake = 0 		--是否可以领取宝箱
end

--读取服务器中的数据
function DataSciencePromote:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end

	self.tFi = _tData.fi or self.tFi
	self.tAlaw = _tData.alaw or self.tAlaw
	self.tConf = _tData.conf or self.tConf
	self.nTake = _tData.take or self.nTake

	self:refreshActService(_tData)--刷新活动共有的数据
end

function DataSciencePromote:getListByPage( _page )
	local list = {}
	if self.tConf then
		for k, v in ipairs(self.tConf) do
			if v.page == _page then
				table.insert(list, copyTab(v))
			end
		end
	end
	return list
end

--是否完成这一页
function DataSciencePromote:isFinishByPage( _page )
	local page = self:getListByPage(_page)
	if page then
		for k, v in ipairs(page) do
			if not self:isFinish(v.i) then
				return false
			end
		end
		return true
	end
	return false
end

function DataSciencePromote:rednumByPage( _page )
	local page = self:getListByPage(_page)
	if page then
		for k, v in ipairs(page) do
			if self:isFinish(v.i) then
				if not self:isGet(v.i) then
					return true
				end
			end
		end
	end
	return false	
end

--返回已经完成到第几页
function DataSciencePromote:inPage()
	for i=1, 5 do
		if not self:isFinishByPage(i) then
			return i - 1
		end
	end
	return 5
end

function DataSciencePromote:getConfById( _id )
	if self.tConf then
		for k, v in ipairs(self.tConf) do
			if v.i == _id then
				return v
			end
		end
	end
	return {}
end

function DataSciencePromote:getTargetById( _id )
	local tConf = self:getConfById(_id)
	if tConf and tConf.targe then
		return tConf.targe
	end
	return 0
end

--获取完成情况
function DataSciencePromote:getFiById( _id )
	if self.tFi then
		for k, v in ipairs(self.tFi) do
			if v.k == _id then
				return v.v
			end
		end
	end
	return 0
end

--是否已经领取奖励
function DataSciencePromote:isGet( _id )
	if self.tAlaw then
		for k, v in ipairs(self.tAlaw) do
			if _id == v then
				return true
			end
		end
	end
	return false
end

-- tAlaw
--是否已经完成
function DataSciencePromote:isFinish( _id )
	local nCur = self:getFiById(_id)
	local nTarget = self:getTargetById(_id)
	if nCur >=  nTarget then
		return true
	else
		return false
	end
end

function DataSciencePromote:canGetAward()
	if self.tConf then
		for k, v in ipairs(self.tConf) do
			if not self:isFinish(v.i) then
				return false
			end
		end
	end
	return true
end

function DataSciencePromote:getTake()
	return self.nTake 
end

--获取红点方法
function DataSciencePromote:getRedNums()
	local nNums = 0
	if self:canGetAward() then
		nNums = nNums + 1
	end
	if self.tConf then
		for k, v in ipairs(self.tConf) do
			if self:isFinish(v.i) then
				if not self:isGet(v.i) then
					nNums = nNums + 1
					break
				end
			end
		end
	end
	nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataSciencePromote