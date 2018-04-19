-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-18 11:51:49 星期一
-- Description: 统帅府
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")
local TroopsVo = require("app.layer.chiefhouse.TroopsVo")
local BChiefData = class("BChiefData", function()
	-- body
	return Build.new()
end)

function BChiefData:ctor(  )
	-- body
	self:myInit()
end


function BChiefData:myInit(  )
	self.nCq 	= 	0 		--采集队列数
	self.nDq 	= 	0 		--城防队列数
	self.tTroops 	= 	{}		--高级御兵术
	self.nStage = 	0 		--当前高级御兵术阶段
	self.nVc 	= 	0  		--Vip回复次数
	self.nCd 	= 	0 		--高级御兵术cd时间
	self.nRate 	= 	0       --下次升级的提升额度
	self.nNailiFill = 1
	self.nNailiFillCd = 0    --一分钟剩余cd时间补充耐力时间
end

--从服务端获取数据刷新
function BChiefData:refreshDatasByService( tData )
	-- body
	--dump(tData, "统帅府tData", 100)
	self.nCellIndex 			= 		tData.loc or self.nCellIndex    --建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		    --等级
	
	self.nCq 					= 		tData.cq or self.nCq			--采集队列数
	self.nDq 					= 		tData.dq or self.nDq 			--城防队列数	
	self.nStage 				= 		tData.stage or self.nStage 		--当前高级御兵术阶段	

	self.nVc 					= 		tData.vc or self.nVc 			--Vip回复次数
	self.nCd 					= 		tData.cd or self.nCd  			--高级御兵术cd时间
	self.nRate 					= 		tData.rate or self.nRate		--下次升级的提升额度
	self.nNailiFill             =       tData.of or self.nNailiFill --是否开启自动补耐久 0不开启 1开启
	self.nNailiFillCd			=       tData.scd or self.nNailiFillCd   --一分钟剩余cd时间补充耐力时间

	if tData.cd then
		self.nLastLoadTime = getSystemTime() --最后一次刷新cd的时间
	end

	if tData.tq and #tData.tq > 0 then--高级御兵术
		for k, v in pairs(tData.tq) do
			if not self.tTroops[v.type] then
				self.tTroops[v.type] = TroopsVo.new()				
			end 	
			self.tTroops[v.type]:refreshDatasByService(v)		
		end		
	end	
	--统帅府数据刷新
	sendMsg(ghd_refresh_chiefhouse_msg)
end
--获取当前御兵术
function BChiefData:getCurTroopVo( nType )
	-- body
	return self.tTroops[nType]
end

function BChiefData:getTroopItemsData(  )
	-- body
	local tDataList = {}
	for i = self.nStage, self.nStage + 2 do
		local pBaseTroop = getTroopsVoById(i)
		if pBaseTroop then
			table.insert(tDataList, pBaseTroop)
		else
			pBaseTroop = getTroopsVoById(i - 3)
			if pBaseTroop then
				table.insert(tDataList, pBaseTroop)
			else
				print("高级御兵术配表数据错误！")
			end
		end
	end
	return tDataList
end

function BChiefData:getTroopCdTime(  )
	-- body
	if self.nCd and self.nCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd - (fCurTime - self.nLastLoadTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end	
end
--获取当前花费
function BChiefData:getGoldCost(  )
	-- body
	if not self.tCost  then
		self.tCost = {}
		local tCostParams = luaSplitMuilt(getWallInitParam("queueGoldRecover"), ";", ":")
		for k, v in pairs(tCostParams) do
			local nTime = tonumber(v[1] or 0)--次数
			local nCost = tonumber(v[2] or 0)--花费
			self.tCost[nTime] = nCost
		end
	end
	--dump(self.tCost, "self.tCost", 100)
	return self.tCost[self.nVc + 1]
end
--获取当前VIP升级次数
function BChiefData:getLeftLvUpTimes( )
	-- body
	if not self.tVipLvUp then
		self.tVipLvUp = {}
		local tTimes = luaSplitMuilt(getWallInitParam("queueVipRecover"), ";", ":")
		for k, v in pairs(tTimes) do
			local nVip = tostring(v[1] or "0")
			local nTimes = tonumber(v[2] or "0")
			self.tVipLvUp[nVip] = nTimes
		end
	end
	--dump(self.tVipLvUp, "self.tVipLvUp",100)
	local nCurVip = Player:getPlayerInfo().nVip
	return self.tVipLvUp[tostring(nCurVip)], self.nVc
end
--获取开启采集队列数
function BChiefData:getCollectQueue( )
	return self.nCq
end

--获取开启城防队列数
function BChiefData:getWalldefQueue( )
	return self.nDq
end

--是否是激活状态
function BChiefData:isShowActivate()
	-- body
	local pBaseTroop = getTroopsVoById(self.nStage)
	if pBaseTroop == nil then return false end
	local pTroopVo = self:getCurTroopVo(pBaseTroop.type)
	if pTroopVo.nStage == 100 and pTroopVo.nSec == pBaseTroop.section  then 
		return true, pBaseTroop.icon
	else
		return false
	end
end


function  BChiefData:getNailiFillCd(  )
	return self.nNailiFillCd
end

function BChiefData:setNailiFillCdSub( nSubCd )
	self.nNailiFillCd = self.nNailiFillCd - nSubCd
	if self.nNailiFillCd < 0 then
		self.nNailiFillCd = 0
	end
end

function BChiefData:isTroopCanLvUp(  )
	-- body
	--御兵术升级CD
	local bCan = false	
	if self:getTroopCdTime() <= 0 and self.nLv >= 3 then
		local pBaseTroop = getTroopsVoById(self.nStage)
		if pBaseTroop then			
			local pTroopVo = self:getCurTroopVo(pBaseTroop.type)
			local nLimitLv = tonumber(pBaseTroop.lvlimit or 0)
			if (pTroopVo.nStage < 100 or pTroopVo.nSec < pBaseTroop.section) and Player:getPlayerInfo().nLv >= nLimitLv  then 				
				bCan = true 
			end		
		end
	end
	return bCan
end

return BChiefData