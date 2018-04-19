----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-1-24 20:02:21
-- Description: 年兽来袭数据

-----------------------------------------------------
local Activity = require("app.data.activity.Activity")
local RankAwardRes = require("app.layer.activityb.nianattack.RankAwardRes")
local HarmAwardRes = require("app.layer.activityb.nianattack.HarmAwardRes")
local DataNianAttack = class("DataNianAttack", function()
	return Activity.new(e_id_activity.nianattack) 
end)

e_ngift_state = {
	get = 1,
	got = 2,
	no = 3
}

--创建自己(方便管理)
tActivityDataList[e_id_activity.nianattack] = function (  )
	return DataNianAttack.new()
end

-- _index
function DataNianAttack:ctor()
	-- body
   self:myInit()
end


function DataNianAttack:myInit( )
	self.nAttackedCount = 0
	self.nFreeAttackCount = 0
	self.nBossHp = 0
	self.nBossHpMax = 0
	self.nBossLv = 0
	self.nCost = 0
	self.nMyHurt = 0 --我的伤害值
	self.nHarmAwardTop = 0
	self.nRedPocket = 0 --获取红包数
	self.tGiftGot = {} --已领取礼包字典
	self.tGiftList = {}
	self.tRAResList = {}
end


-- 读取服务器中的数据
function DataNianAttack:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end

	-- dump(_tData,"_tData======",100)

	self.nAttackedCount = _tData.ac or self.nAttackedCount --已攻击次数
	self.nFreeAttackCount = _tData.tf or self.nFreeAttackCount --免费次数

	if _tData.aw then --已经领取的奖励
		self.tGiftGot = {}
		for i=1,#_tData.aw do
			local nIndex = _tData.aw[i]
			self.tGiftGot[nIndex] = true
		end
	end

	if _tData.raw then --个人排行榜奖励
		self.tRAResList = {}
		for i=1,#_tData.raw do
			local tRARes = RankAwardRes.new(_tData.raw[i])
			table.insert(self.tRAResList, tRARes)
		end

	end

	if _tData.hs then --伤害奖励
		self.tGiftList = {}
		for i=1,#_tData.hs do
			local tHARes = HarmAwardRes.new(_tData.hs[i])
			table.insert(self.tGiftList, tHARes)
		end
		table.sort(self.tGiftList, function ( a, b )
			return a.nHarm < b.nHarm
		end)
	end

	self.nBossHp = _tData.bhp or self.nBossHp --Boss血量

	self.nBossHpMax = _tData.thp or self.nBossHpMax --Boss总血量

	self.nBossLv = _tData.blv or self.nBossLv --今日刷新次数

	self.nCost = _tData.cost or self.nCost --单次费用cost

	self.nMyHurt = _tData.td or self.nMyHurt --我的伤害值

	self.nRedPocket = _tData.rc or self.nRedPocket --获得红包数量

	self:refreshActService(_tData)--刷新活动共有的数据

end

-- 获取红点方法
function DataNianAttack:getRedNums()
	local nGetAwardHarm = self:getLowAwardHarm()
	if nGetAwardHarm then
		return 1
	end

	if self.nFreeAttackCount > self.nAttackedCount then
		return 1
	end

	return 0
end

-- 获取可以领取的最小的奖励阶段
function DataNianAttack:getLowAwardHarm(  )
	for i=1,#self.tGiftList do
		local nHarm = self.tGiftList[i].nHarm
		if self.nMyHurt >= nHarm then
			if not self.tGiftGot[nHarm] then
				return nHarm
			end
		end
	end
	return nil
end

-- 获取物品状态
function DataNianAttack:getHarmGiftState( _nHarm )
	for i=1,#self.tGiftList do
		local nHarm = self.tGiftList[i].nHarm
		if nHarm == _nHarm and self.nMyHurt >= nHarm  then
			if self.tGiftGot[nHarm] then
				return e_ngift_state.got
			else
				return e_ngift_state.get
			end
		end
	end
	return e_ngift_state.no
end

--获取伤害进度百分比
--tBarPercent 刻度百分比
function DataNianAttack:getHarmPercent( tBarPercent )
	local nCurScore = self.nMyHurt
	local nIndex = 0
	for i=1,#self.tGiftList do
		if nCurScore >= self.tGiftList[i].nHarm then
			nIndex = i
		end
	end

	if nIndex >= #tBarPercent then
		return 100
	end

	local nPrevPercent = 0
	local nRemainHurt = nCurScore
	local nPrevHarm = 0
	if self.tGiftList[nIndex] then
		nPrevPercent = tBarPercent[nIndex]
		nRemainHurt = nCurScore - self.tGiftList[nIndex].nHarm
		nPrevHarm = self.tGiftList[nIndex].nHarm
	end

	local nNextPercent = tBarPercent[nIndex + 1]
	local nNextHarm = self.tGiftList[nIndex + 1].nHarm
	local nNeedHarm = nNextHarm - nPrevHarm
	local nCurrPercent = (nRemainHurt/nNeedHarm) * (nNextPercent - nPrevPercent) + nPrevPercent

	return nCurrPercent
end

function DataNianAttack:getMyHarm(  )
	return self.nMyHurt
end

function DataNianAttack:getHarmGift(  )
	return self.tGiftList
end

function DataNianAttack:getRankAwardList(  )
	return self.tRAResList
end

function DataNianAttack:getRedPocket()
	return self.nRedPocket
end

return DataNianAttack