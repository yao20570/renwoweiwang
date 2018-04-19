-- Author: liangzhaowei
-- Date: 2017-08-05 17:30:03
-- 登坛拜将数据
local Activity = require("app.data.activity.Activity")

local DataHeroMansion = class("DataHeroMansion", function()
	return Activity.new(e_id_activity.heromansion) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.heromansion] = function (  )
	return DataHeroMansion.new()
end

function DataHeroMansion:ctor()
   self:myInit()
end


function DataHeroMansion:myInit( )
	self.nF1	    =	0 --	Integer	免费刷新次数
	self.nF2	    =	0 --	Integer	免费刷新次数上限
	self.nCd	    =	0 --	Long	刷新次数恢复CD时间
	self.tCs	    =	{} --	List<CellVo>	格子信息
	self.np	        =	0 --	Integer	已经获得的将印数
	self.ns	        =	0 --	Integer	是否已经招募武将 0否 1是

	self.nSp        =	0 --	Integer	招募所需将印
	self.nRg        =	0 --	Integer	刷新花费
	self.nDs         =	0 --	Float	购买折扣数
	self.nMd        =	0 --	Float	最大购买折扣数
	self.nHid       =	0 --英雄id


	self.nLastRefreshCD = 0--   最后一次刷新cd时间的系统时间

	self.nFRed 		= 	0	--恢复刷新次数红点
	self.bCheck     = 	true --是否校对
	self.nF1 		=   self:getRecoverRecord()
end


-- 读取服务器中的数据
function DataHeroMansion:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	-- dump(_tData)

	if _tData.f1 and self:isChecking() then
		if self.nF1 and self.nF1 < _tData.f1 then
			self.nFRed = 1			
		end
		self:closeCheck()
	end
	self.nF1	    =	_tData.f1             or self.nF1 --	Integer	免费刷新次数	
	self.nF2	    =	_tData.f2             or self.nF2 --	Integer	免费刷新次数上限
	self.nCd	    =	tonumber(_tData.cd)   or self.nCd --	Long	刷新次数恢复CD时间
	if _tData.cd then
		self.nLastRefreshCD = getSystemTime(true)
	end
	self.tCs	    =	_tData.cs             or self.tCs --	List<CellVo>	格子信息
	self.np	        =	_tData.p              or self.np  --	Integer	已经获得的将印数
	self.nSp        =	_tData.sp              or self.nSp  --	Integer	招募所需将印
	self.ns	        =	_tData.s              or self.ns  --	Integer	是否已经招募武将 0否 1是

	self.nRg        =	_tData.rg              or self.nRg  --	Integer	刷新花费
	self.nDs         =	_tData.ds               or self.nDs   --	Float	购买折扣数
	self.nMd        =	_tData.md              or self.nMd  --	Float	最大购买折扣数
	self.nHid       =	_tData.hid              or self.nHid  --英雄id


	self:refreshActService(_tData)--刷新活动共有的数据

	-- dump(_tData)
	self:setRecoverRecord()--每次刷新数据，将剩余免费次数记录在本地
end

--获得恢复时间
function DataHeroMansion:getRecoverCD()
	local nTime = 0
	nTime = self.nCd -  ( getSystemTime(true)-self.nLastRefreshCD)
	if nTime < 0 then
		nTime = 0
	end
	return nTime
end
--是否校对
function DataHeroMansion:isCheckStatus(  )
	-- body
	return (self.nF1 < self.nF2) and (self:getRecoverCD() <= 0)
end

--获得当前打折数 返回(小数)
function DataHeroMansion:getSale()
	-- local fSale = 1
	-- local nBuyTime = 0
	-- for k,v in pairs(self.tCs) do
	-- 	if v.b then
	-- 		nBuyTime = nBuyTime + v.b
	-- 	end
	-- end

	-- if fSale <self.nMd  then
	-- 	fSale = self.nMd
	-- end

	
	return self.nDs
end

-- 获取红点方法
function DataHeroMansion:getRedNums()

	
	local nNums = 0

	--可以招募
	if self.ns  == 0 then
		if self.np >= self.nSp then
			nNums = 1
		end
	end

	--有免费次数
	-- if self.nF1 > 0 then
	-- 	nNums = nNums +1
	-- end

	nNums = self.nLoginRedNums + nNums + self.nFRed

	return nNums
end

function DataHeroMansion:openCheck(  )
	-- body
	self.bCheck = true
end

function DataHeroMansion:closeCheck(  )
	-- body
	self.bCheck = true
end

function DataHeroMansion:isChecking( )
	-- body
	return self.bCheck
end

function DataHeroMansion:getRecoverRedNum(  )
	-- body
	return self.nFRed
end

function DataHeroMansion:resetRecoverRed( )
	-- body
	self.nFRed = 0
end

function DataHeroMansion:setRecoverRecord(  )
	-- body
	saveLocalInfo("DataHeroMansion"..Player:getPlayerInfo().pid,tostring(self.nF1))
end

function DataHeroMansion:getRecoverRecord( )
	-- body
	local nNum = getLocalInfo("DataHeroMansion"..Player:getPlayerInfo().pid,"0")
	return tonumber(nNum or 0)
end
return DataHeroMansion