-- NationalTreasureData.lua
-----------------------------------------------------
-- author: xiesite
-- updatetime:  2018-03-22 14:12:17
-- Description: 阿房宫宝藏数据
-----------------------------------------------------

local NationalTreasureData = class("NationalTreasureData")

TreasureType = {
	xb = 1, --寻宝
	zh = 2,--祝贺
}

function NationalTreasureData:ctor(  )
	-- body
	self:myInit()
end


function NationalTreasureData:myInit(  )
 	self.nState = 1 	--当前活动的状态
 	self.nNum = 0 					--这次获得获得的总图纸数
 	self.nLeftNum = 0 				--金色图纸剩余数量
 	self.nPoint = 0 				--拥有积分
 	self.nOpen = 0 					--国家宝藏是否开启 0不开启 1开启
 	self.nCd = 0 					--活动结束CD
 	self.nIsCongratulate = 0 		--是否已经祝贺 0否 1是
 	self.nCanCongratulate = 0 		--是否有资格祝贺
 	self.nGetCon = nil 				--祝福获得的图纸
 	self.nGds = {}					--获得图纸列表
 	self.nTimes = 0 				--已经寻宝次数
 	self.nMaxTimes = 0 				--最大寻宝次数
 	self.tCostList = {}  			--每次的价格信息
 	self.nType = 2 					--活动类型
 	self:setCost()
end

--从服务端获取数据刷新
function NationalTreasureData:refreshDatasByService( tData, bPush )
	--dump(tData, "refreshDatasByService  寻宝数据", 100)
	-- 测试数据
	-- tData.gds = {{n="主公1", i=100071}, {n="主公2", i=100072},{n="主公3", i=100073}, {n="主公4", i=100074},{n="主公5", i=100075}, {n="主公6", i=100076}}
	self.nOpen = tData.k or self.nOpen
	-- self.nNum = tData.k or self.nOpen
	self.nLeftNum = tData.n or self.nLeftNum
	-- self.nPoint = tData.n or self.nLeftNum
	self.nState = tData.s or self.nState
	self.nTimes = tData.t or self.nTimes
	if tData.cd then
		self.nCd = tData.cd
		self.nRefreshLoginTime = getSystemTime()
	end
	self.nIsCongratulate = tData.c or self.nIsCongratulate
	self.nGetCon = tData.i or self.nGetCon
	self.nGds = tData.gds or self.nGds
	self.nCanCongratulate = tData.j or self.nCanCongratulate
	self.nNum = tData.tot or self.nNum

	sendMsg(ghd_national_treasure_update)
end

function NationalTreasureData:setCost()
	local sCostStr = getEpangWarInitData("cost")
	local tList = luaSplitMuilt(sCostStr,"|")
	self.nMaxTimes = #tList
	for i=1, #tList do
		local tCostInfo = luaSplitMuilt(tList[i],",",";")
		local tCostTypeInfo = {}
		if tCostInfo[2] then
			for num=1, #tCostInfo[2] do
				local tCostValueInfo = luaSplitMuilt(tCostInfo[2][num],":")
				if tonumber(tCostValueInfo[1]) == 20 then
					if tCostValueInfo[2] then
						tCostTypeInfo[1] = tonumber(tCostValueInfo[2])
					end
				elseif tonumber(tCostValueInfo[1]) == 10 then
					if tCostValueInfo[2] then
						tCostTypeInfo[2] = tonumber(tCostValueInfo[2])
					end
				end
			end
			self.tCostList[tonumber(tCostInfo[1])] = tCostTypeInfo
		end
	end
end

function NationalTreasureData:isOpen()
	if self.nCd > 0 and self.nOpen == 1 then
		return true
	end
	return false
end
--
function NationalTreasureData:getState( )
 	return self.nState
end

--国家获得橙色图纸数
function NationalTreasureData:getAwardNum()
	return self.nNum
end

--剩下橙色图纸数
function NationalTreasureData:getLeftNum()
	return self.nLeftNum
end

--需要的积分和元宝
function NationalTreasureData:getCost()
	local tCost = self.tCostList[self.nTimes+1] 
	if tCost then
		local nJf = tCost[1] or 0
		local nYb = tCost[2] or 0
		return nJf, nYb
	end
	return 0, 0
end

--拥有的积分
function NationalTreasureData:getPoint()
	return self.nPoint 
end

--用完寻宝次数
function NationalTreasureData:isFinish()
	if self.nMaxTimes <= self.nTimes then
		return true
	else
		return false
	end
	
end

--是否获得金色图纸
function NationalTreasureData:isGetGoldPaper()
	if self.nGds then
		for i=1, #self.nGds do
			local sName = self.nGds[i].n or self.nGds[i][1]
			if sName == Player:getPlayerInfo().sName then
				return true
			end
		end
	end
	return false
end

function NationalTreasureData:getNameList()
	if self.nGds then
		local tList = {}
		for i=1, #self.nGds do
			local nIndex = math.ceil(i/2)
			if not tList[nIndex] then
				tList[nIndex] = {}
			end
			table.insert(tList[nIndex], copyTab(self.nGds[i]))
		end
		return tList
	end
	return {} 
end

--获取活动剩余时间
function NationalTreasureData:getRemainTime()
	local sTime = ""
	sTime = getConvertedStr(5, 10210)
	local nNowTime = getSystemTime()
	local nTime  = self.nCd - (nNowTime-self.nRefreshLoginTime)
	sTime = "(".. sTime..getTimeLongStr(nTime,false,true)..")"
	return sTime
end

function NationalTreasureData:getLeftTime()
	if self.nState == 1 or self.nState == 2 then
		local nNowTime = getSystemTime()
		local nTime  = self.nCd - (nNowTime-self.nRefreshLoginTime)
		if nTime >= 0 then
			return nTime;
		else
			return 0
		end
	else
		return 0
	end
end

--是否已经祝贺
function NationalTreasureData:isCongratulate()
	return self.nIsCongratulate == 1
end

--是否可以祝贺
function NationalTreasureData:canCongratulate()
	return self.nCanCongratulate == 1
end

function NationalTreasureData:getRedNums()
	local nRedNum = 0
	local sRedState = getLocalInfo("nationaltreasurerednums"..Player:getPlayerInfo().pid,"false")
	if sRedState == "false" then
		nRedNum = nRedNum + 1
	end
	if self.nState == 1 then
		if self.nTimes < self.nMaxTimes and self:canCongratulate() then
			local nJf, nYb = self:getCost()
			local nPoint = getMyGoodsCnt(e_type_resdata.royalscore)
			local nMoney = Player:getPlayerInfo().nMoney
			if nPoint >= nJf and nMoney >= nYb then
				nRedNum = nRedNum + 1
			end
		end
	else
		if self.nCanCongratulate == 1 then
			if self.nIsCongratulate == 0 then
				nRedNum = nRedNum + 1
			end
		end
	end
	return nRedNum
end

function NationalTreasureData:getGetConId()
	return self.nGetCon
end 

return NationalTreasureData
