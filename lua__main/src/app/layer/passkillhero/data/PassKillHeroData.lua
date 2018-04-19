-- PassKillHeroData.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-14 17:08:17 星期三
-- Description: 过关斩将数据
-----------------------------------------------------

local json = require("framework.json")
local OutpostVo = require("app.layer.passkillhero.data.OutpostVo")
local ExpediteReportRes = require("app.layer.passkillhero.data.ExpediteReportRes")

local PassKillHeroData = class("PassKillHeroData")

function PassKillHeroData:ctor(  )
	-- body
	self:myInit()
end


function PassKillHeroData:myInit(  )
	self.pOutpostVo 				= nil 		--过关斩将副本信息
	self.nResetTimes 				= 0 		--今天重置的次数
	self.tHeroProList 				= {}		--List<Pair<Integer,Integer>>武将剩下百分比血量
	self.tAlaw 						= {}		--Set<Integer>已经兑换的物品
	self.tShopId 					= {}		--Set<Integer>商店列表id
	self.nRfn 						= 0 		--今日刷新商店次数
	self.tRp 						= {} 		--过关斩将战报记录
	self.nPass 	 					= nil 		--是否全部通关, 1是, 0否
	--自己定义
	self.tHeroOnlineList 	 		= {} 		--已上阵武将

	--测试数据
	-- local tData = {}
	-- tData.op = {
	-- 	battleArray = 
	-- 	{
	-- 		[1] = {bloor = 1724,npc = 708381},
	-- 		[2] = {bloor = 1576,npc = 708382}
	-- 	},
	-- 	country = 4, id = 70838, level = 6, name = "魔兵", npc = 1, oid = 1
	-- }
	-- tData.pass = 0
	-- tData.rs = 0
	-- tData.shop = {35,4,39,11,60,14}

	-- self:refreshDatasByService( tData )
end

--从服务端获取数据刷新
function PassKillHeroData:refreshDatasByService( tData, bLoginLoad )
	-- dump(tData, "过关斩将数据", 100)
	--刷新过关斩将副本信息
	self:updateOutpostVo(tData.op)                 				--op <OutpostVo>过关斩将副本信息
	local nResetTimes   = self.nResetTimes
	self.nResetTimes 	= 	tData.rs or self.nResetTimes		-- Integer	今天重置的次数
	if tData.pro then
		self.tHeroProList = self:refreshHeroProList(tData.pro) 		-- List<Pair<Integer,Integer>>武将剩下百分比血量
	end
	self.tPro 			= tData.pro or self.tPro
	--商店数据
	self.tAlaw 			= 	tData.alaw or self.tAlaw			-- Set<Integer>已经兑换的物品
	self.tShopId 		= 	tData.shop or self.tShopId			-- Set<Integer>商店列表id
	self.nRfn 			=	tData.srs or self.nRfn      		-- Integer	今日刷新商店次数
	local nPass 		=	self.nPass
	self.nPass 			=	tData.pass or self.nPass      		-- Integer	是否全部通关, 1是, 0否
	if nPass == 0 and nPass ~= self.nPass then
		self.nChange = true 		--记录状态改变，用于处理通关动画
	else
		self.nChange = false
	end
	--过关斩将战报记录
	if tData.rp then
		self.tRp = self:createFightReports(tData.rp)  			--rp List<ExpediteReportRes>过关斩将战报记录
	end
	--重置数据，为动画做处理
	if nResetTimes < self.nResetTimes then
		local tObject = {}
		tObject.isReSet  =  true
		sendMsg(gud_refresh_pass_kill_hero_msg,tObject)
	else
		sendMsg(gud_refresh_pass_kill_hero_msg)
	end
	--如果是登录加载, 取出上次上阵武将数据
	if bLoginLoad then
		local data = getLocalInfo("PassKillHeroData"..Player:getPlayerInfo().pid, "")--取出上次离开游戏时上阵的武将数据
		local sPa = nil
        if data and data ~= "" then
            sPa = json.decode(data)
        end
		self.tHeroOnlineList = sPa or {}
	end
end

--上阵后英雄的数据
function PassKillHeroData:refreshHeroInfo(_tData)
	-- body
	-- dump(_tData, "上阵后英雄的数据 ==")
	local tData = _tData.hs
	if table.nums(tData) > 1 then
		self.tHeroOnlineList = tData
	else
		local bFind = false
		for k, v in pairs(self.tHeroOnlineList) do
			if tData[1].h == v.h then
				v = tData[1]
				bFind = true
			end
		end
		if bFind == false then
			table.insert(self.tHeroOnlineList, tData[1])
		end
	end

	local str = json.encode(self.tHeroOnlineList)
	saveLocalInfo("PassKillHeroData"..Player:getPlayerInfo().pid, str)--本地记录上阵武将数据

	--发送更新过关斩将上阵队列消息
	sendMsg(gud_refresh_pass_kill_online_hero_msg)
end

--获取上阵后英雄的数据(兵力,战力)
function PassKillHeroData:getAfterOnlineHeroData()
	return self.tHeroOnlineList
end

 
--刷新过关斩将副本信息
function PassKillHeroData:updateOutpostVo( _tData )
	-- body
	if not _tData then
		return
	end
	if self.pOutpostVo then
		self.pOutpostVo:update(_tData)
	else
		self.pOutpostVo = OutpostVo.new(_tData)
	end
end

--刷新武将剩下百分比血量
function PassKillHeroData:refreshHeroProList(_tData)
	-- body
	local tHeroList = Player:getHeroInfo():getHeroList() --获取拥有的英雄列表
	for k, v in pairs(tHeroList) do
		self.tHeroProList[v.nId] = 1
	end
	for k, v in pairs(_tData) do
		self.tHeroProList[v.k] = v.v
	end
	local tOnline = self:getOnlineHero()
	for k, v in pairs(tOnline) do
		if self:getHeroProById(v.nId) <= 0 then
			self:saveOfflineHero(v.nId)
		end
	end
	return self.tHeroProList
end

--获取武将血量列表
function PassKillHeroData:getHeroProList()
	-- body
	local tHeroList = Player:getHeroInfo():getHeroList() --获取拥有的英雄列表
	for k, v in pairs(tHeroList) do
		self.tHeroProList[v.nId] = 1
	end
	for k, v in pairs(self.tPro) do
		self.tHeroProList[v.k] = v.v
	end
	return self.tHeroProList or {}
end

--获取武将剩下百分比血量
function PassKillHeroData:getHeroProById(_nId)
	return self.tHeroProList[_nId] or 1
end

--保存上阵武将
function PassKillHeroData:saveOnlineHero(_nHeroId, _nIndex)
	local tHero = Player:getHeroInfo():getHero(_nHeroId)
	if tHero then
		local sHeroIds = getLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, "")
		local tHeroId = luaSplit(sHeroIds, ";")
		local nPos = 1
		if tHeroId[_nIndex] then
			tHeroId[_nIndex] = _nHeroId
			nPos = _nIndex
			sHeroIds = ""
			for k, v in pairs(tHeroId) do
				if k == 1 then
					sHeroIds = v
				else
					sHeroIds = sHeroIds..";"..v
				end
			end
		else
			if sHeroIds ~= "" then
				sHeroIds = sHeroIds..";".._nHeroId
			else
				sHeroIds = _nHeroId
			end
			local tHeroId = luaSplit(sHeroIds, ";")
			for k, v in ipairs(tHeroId) do
				if tonumber(v) == _nHeroId then
					nPos = k
					break
				end
			end
		end

		saveLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, sHeroIds)--本地记录 玩家上阵武将
		--请求上阵武将
		SocketManager:sendMsg("reqPassKillHeroOnline", {tostring(nPos)..","..tostring(_nHeroId)})
	end
end

--请求上阵武将
function PassKillHeroData:reqOnlineHero(sHeroIds)
	-- body
	self.tHeroOnlineList = {} --列表重置, 清空原先的列表
	local tHeroId = luaSplit(sHeroIds, ";")
	if table.nums(tHeroId) > 0 and tHeroId[1] ~= "" then
		local sReq = "" 			-- pos,hid;pos,hid;...格式
		for k, v in ipairs(tHeroId) do
			if k == 1 then
				sReq = tostring(k)..","..v
			else
				sReq = sReq..";"..tostring(k)..","..v
			end
		end
		SocketManager:sendMsg("reqPassKillHeroOnline", {sReq})
	end
end

--下阵武将
function PassKillHeroData:saveOfflineHero(_nHeroId)
	local sHeroIds = getLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, "")
	local tHeroId = luaSplit(sHeroIds, ";")
	local bFindHero = false
	for i = table.nums(tHeroId), 1, -1 do
		if tonumber(tHeroId[i]) == _nHeroId then
			table.remove(tHeroId, i)
			bFindHero = true
		end
	end
	--如果在已上阵队列中找到了要下阵的武将
	if bFindHero then
		sHeroIds = ""
		for k, v in pairs(tHeroId) do
			if k == 1 then
				sHeroIds = v
			else
				sHeroIds = sHeroIds..";"..v
			end
		end
		saveLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, sHeroIds)--本地记录 玩家上阵武将

		for i = #self.tHeroOnlineList, 1, -1 do
			if self.tHeroOnlineList[i].h == _nHeroId then
				table.remove(self.tHeroOnlineList, i)
			end
		end
		local str = json.encode(self.tHeroOnlineList)
		saveLocalInfo("PassKillHeroData"..Player:getPlayerInfo().pid, str)--本地记录上阵武将数据

		--下阵的时候顺序可能有变, 再重新请求上阵武将
		local tHeroId = luaSplit(sHeroIds, ";")
		if table.nums(tHeroId) > 0 and tHeroId[1] ~= "" then
			--请求上阵武将
			self:reqOnlineHero(sHeroIds)
		else
			-- 发送更新过关斩将上阵队列消息
			sendMsg(gud_refresh_pass_kill_online_hero_msg)
		end

	end
end

--获取已上阵武将
--_bReq:是否请求上阵武将数据
function PassKillHeroData:getOnlineHero(_bReq)
	--获取本地记录
	local sHeroIds = getLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, "")
	local tHeroId = luaSplit(sHeroIds, ";")
	local tHeroOnlineList = {}
	local tHeroOnlineData = self:getAfterOnlineHeroData()
	for k, v in pairs(tHeroId) do
		local tHero = copyTab(Player:getHeroInfo():getHero(tonumber(v)))
		if tHero then
			table.insert(tHeroOnlineList, tHero)
			for k, v in pairs(tHeroOnlineData) do
				if tHero.nId == v.h then
					tHero.nSc = v.sc
					tHero.nLt = v.lt
					break
				end
			end
		end
	end
	if _bReq then
		--请求上阵武将
		self:reqOnlineHero(sHeroIds)
	end
	return tHeroOnlineList
end

--重新设置上阵队列(顺序发生改变)
function PassKillHeroData:setOnlineHero(_tHeroOnlineList)
	-- body
	local sHeroIds = ""
	for k, v in ipairs(_tHeroOnlineList) do
		if k == 1 then
			sHeroIds = v.nId
		else
			sHeroIds = sHeroIds..";"..v.nId
		end
	end
	saveLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, sHeroIds)--本地记录 玩家上阵武将
	--请求上阵武将
	self:reqOnlineHero(sHeroIds)
end

--上阵最大战力武将(从大到小)
function PassKillHeroData:onlineMaxPowerHeros()
	local pHeroInfo = Player:getHeroInfo()
	--可上阵数量
	local nCanOnLine = pHeroInfo.nOnlineNums
	--所有已拥有的没死的武将
	local tHeroList = self:getNotDeadHeroList()
	if #tHeroList <= 0 then
		TOAST(getConvertedStr(7, 10397))
		return
	end
	local sHeroIds = ""
	for k, v in pairs(tHeroList) do
		if k <= nCanOnLine then
			if k == 1 then
				sHeroIds = v.nId
			else
				sHeroIds = sHeroIds..";"..v.nId
			end
		end
	end
	saveLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, sHeroIds)--本地记录 玩家上阵武将

	--请求上阵武将
	self:reqOnlineHero(sHeroIds)

	--发送更新过关斩将上阵队列消息
	-- sendMsg(gud_refresh_pass_kill_online_hero_msg)
	TOAST(getConvertedStr(7, 10387))
end

function PassKillHeroData:getTarget(tEnemys, tNotIncludeEnemysIdxs, tMyHeros, isRelateFun)
    local tRecordEnemyIds = {}
    for i1, enemy in ipairs(tEnemys) do
        if not tNotIncludeEnemysIdxs[i1] then
            for i2, hero in ipairs(tMyHeros) do
                if isRelateFun(hero, enemy) then
		            tNotIncludeEnemysIdxs[i1] = true
		            tRecordEnemyIds[i1] = hero
		            table.remove(tMyHeros, i2)
	            	break
        		end
            end
        end 
    end
    return tRecordEnemyIds
end

--上阵最佳克制武将
--_tEnemy: 敌方部队
function PassKillHeroData:onlineBestDefeatHeros(_tEnemy)
	local tMyHeros = self:getNotDeadHeroList() 	 --所有已拥有的没死的武将
	local tEnemys = copyTab(_tEnemy)			 --敌方部队

	for i = #tEnemys, 1, -1 do
		if tEnemys[i].nBlood == 0 then
			table.remove(tEnemys, i)
		end
	end
	--敌将大于本方阵容数量的话，只匹配本阵容武将数量的敌方武将
	if #tMyHeros < #tEnemys then
		for i = #tEnemys, #tMyHeros+1, -1 do
			table.remove(tEnemys, i)
		end
	end

	if #tMyHeros <= 0 then
		TOAST(getConvertedStr(7, 10397))
		return
	end

	--克制
	local function restrainFun(hero, enemy)
	    if hero.nKind == en_soldier_type.infantry then
	    	if enemy.nKind == en_soldier_type.archer then
	    		return true
	    	end
	    elseif hero.nKind == en_soldier_type.sowar then
	    	if enemy.nKind == en_soldier_type.infantry then
	    		return true
	    	end
	    elseif hero.nKind == en_soldier_type.archer then
	    	if enemy.nKind == en_soldier_type.sowar then
	    		return true
	    	end
	    end
	    return false
	end

	--不克制
	local function notRestrainFun(hero, enemy)
	    if hero.nKind == enemy.nKind then
	        return true
	    else
	        return false
	    end
	end

	--被克制
	local function beRestrainedFun(hero, enemy)
	    if hero.nKind == en_soldier_type.infantry then
	    	if enemy.nKind == en_soldier_type.sowar then
	    		return true
	    	end
	    elseif hero.nKind == en_soldier_type.sowar then
	    	if enemy.nKind == en_soldier_type.archer then
	    		return true
	    	end
	    elseif hero.nKind == en_soldier_type.archer then
	    	if enemy.nKind == en_soldier_type.infantry then
	    		return true
	    	end
	    end
	    return false
	end

	local tNotIncludeEnemysIdxs = {}
	local tKezhi = self:getTarget(tEnemys, tNotIncludeEnemysIdxs, tMyHeros, restrainFun)
	local tBuKezhi = self:getTarget(tEnemys, tNotIncludeEnemysIdxs, tMyHeros, notRestrainFun)
	local tBeikezhi = self:getTarget(tEnemys, tNotIncludeEnemysIdxs, tMyHeros, beRestrainedFun)

	local tSortedMyHeros = {}
	table.merge(tSortedMyHeros, tKezhi)
	table.merge(tSortedMyHeros, tBuKezhi)
	table.merge(tSortedMyHeros, tBeikezhi)
	-- dump(tKezhi, "tKezhi ==")
	-- dump(tBuKezhi, "tBuKezhi ==")
	-- dump(tBeikezhi, "tBeikezhi ==")

	for i2, hero in ipairs(tMyHeros) do
	    table.insert(tSortedMyHeros, hero)
	end

	local pHeroInfo = Player:getHeroInfo()
	--可上阵数量
	local nCanOnLine = pHeroInfo.nOnlineNums
	local sHeroIds = ""
	for k, v in pairs(tSortedMyHeros) do
		if k <= nCanOnLine then
			if k == 1 then
				sHeroIds = v.nId
			else
				sHeroIds = sHeroIds..";"..v.nId
			end
		end
	end
	saveLocalInfo("PassKillHero"..Player:getPlayerInfo().pid, sHeroIds)--本地记录 玩家上阵武将

	--请求上阵武将
	self:reqOnlineHero(sHeroIds)

	--发送更新过关斩将上阵队列消息
	-- sendMsg(gud_refresh_pass_kill_online_hero_msg)
	TOAST(getConvertedStr(7, 10388))

	-- local tRelativeHero = {}

	-- local tHero = data
	-- local tEnemy = data
	-- while #tHero ~= 0 and #tEnemy ~= 0 do
	-- 	local tKZ = {} --克制
	-- 	local tXD = {} --相等
	-- 	for tEnemy do
	-- 		for tHero do
	-- 			if tHero[i] 克制 tEnmey[1] then 
	-- 				table.insert(tKZ, {hero = tHero[i], enemy = tEnmey[1]}
	-- 			elseif tHero[i] 相等 tEnmey[1] then 
	-- 				table.insert(tXD, {hero = tHero[i], enemy = tEnmey[1]}
	-- 			end
	-- 		end
	-- 	end
	-- 	--
	-- 	if #tKZ > 0 then --有最优的
	-- 		table.insert(tRelativeHero,tKZ[1])
	-- 		for tHero do
	-- 			if tHero[i] == tKZ[1].hero then
	-- 				table.remove(tHero, i)
	-- 				break
	-- 			end
	-- 		end
	-- 		for tEnemy do
	-- 			if tEnemy[i] == tKZ[1].enemy then
	-- 				table.remove(tEnemy, i)
	-- 				break
	-- 			end
	-- 		end
	-- 	elseif #tXD > 0 then --有相等的
	-- 		table.insert(tRelativeHero,tXD[1])
	-- 		for tHero do
	-- 			if tHero[i] == tXD[1].hero then
	-- 				table.remove(tHero, i)
	-- 				break
	-- 			end
	-- 		end
	-- 		for tEnemy do
	-- 			if tEnemy[i] == tXD[1].enemy then
	-- 				table.remove(tEnemy, i)
	-- 				break
	-- 			end
	-- 		end
	-- 	else
	-- 		break --都是被克
	-- 	end
	-- end


	-- local tResLast = {}--结果

	-- for enemydata do
	-- 	for tRelativeHero do
	-- 		if enemydata[i] == tRelativeHero[i] then
	-- 			tResLast[i] == tRelativeHero[i].hero
	-- 		end
	-- 	end
	-- end
	-- for enemydata then
	-- 	if tResLast[i] == nil then
	-- 		tResLast[i] = tHero[i]
	-- 		table.remove(tHero, i)
	-- 	end
	-- end
	-- for tHero do
	-- 	table.insert(tResLast, tHero[i])
	-- end
end

--武将是否已上阵
function PassKillHeroData:getIsOnlineById(_nId)
	local tOnline = self:getOnlineHero()
	for k, v in pairs(tOnline) do
		if v.nId == _nId then
			return true
		end
	end
	return false
end

--是否有可上阵的武将
function PassKillHeroData:bHaveHeroUp()
	local bHave = false
	local nNums = table.nums(self:getOnlineHero())
	local nFreeHero = table.nums(self:getNotDeadHeroList())
	if nFreeHero <= 0 then
		return false
	end
	if nNums < nFreeHero then
		bHave = true
	end

	return bHave
end
--未阵亡队列
function PassKillHeroData:getNotDeadHeroList()
	local tNotDeadList = {}
	local tHeroProList = self:getHeroProList()
	if tHeroProList and table.nums(tHeroProList) > 0 then
		for k, v in pairs(tHeroProList) do
			if v > 0 then
				local pHero = Player:getHeroInfo():getHero(k)
				table.insert(tNotDeadList, pHero)
			end
		end
	end
	if #tNotDeadList > 0 then
		table.sort(tNotDeadList, function(a, b)
			--比较武将的裸战力
			return a:getBaseSc() > b:getBaseSc()
		end)
	end
	return tNotDeadList
end

--武将阵亡状态(1未阵亡, 0阵亡)
function PassKillHeroData:getDeadType(_nId)
	local nType = 0
	if self:getHeroProById(_nId) > 0 then
		nType = 1
	end
	return nType
end

--战报记录
function PassKillHeroData:createFightReports( _tList )
	-- body
	local tList = {}
	if _tList and #_tList > 0 then
		for k, v in pairs(_tList) do
			local pData = ExpediteReportRes.new(v)
			table.insert(tList, pData)
		end
		table.sort(tList, function ( a, b )
			-- body
			return a.nOt > b.nOt
		end)
	end
	return tList
end

--过关斩将是否开启
function PassKillHeroData:isPassKillHeroOpen()
    -- body
    local nOpenlv = tonumber(getExpediteParam("openLevel"))
    if Player:getPlayerInfo().nLv < nOpenlv then
        return false        
    else
        return true
    end 
end

--获取今日闯关剩余重置次数
function PassKillHeroData:getLeftVipResetTimes()
	-- body
	local nLeft = 0
	--过关斩将总重置次数(根据vip等级)
	local tVipData = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
	local nTotal = tVipData.expedreset
	nLeft = nTotal - self.nResetTimes
	return nLeft
end

--是否已通过所有关卡
function PassKillHeroData:isPassAllOid()
	return self.nPass == 1
end

--是否拥有可上阵的武将
function PassKillHeroData:getHasNotDeadHero()
	local bHasHero = false
	local tHeroList = Player:getHeroInfo():getHeroList() --获取拥有的英雄列表
	if table.nums(tHeroList) > table.nums(self.tPro) then
		bHasHero = true
	else
		for k, v in pairs(self.tPro) do
			if v.v > 0 then
				bHasHero = true
				break
			end
		end
	end
	return bHasHero
end

--获取商店剩余刷新次数和次数刷新上限
function PassKillHeroData:getShopRefreshNum()
	-- body	
	if not self.tRefresh then
		self.tRefresh = {}
		local tRefcost = luaSplit(getExpediteParam("fightBuyCosts") or "", ",")
		-- dump(tRefcost, "过关斩将商店刷新次数")
		for k, v in pairs(tRefcost) do
			local tCost = {}
			tCost.nResId = e_resdata_ids.ybao
			tCost.nCost = tonumber(v or 0)
			self.tRefresh[k] = tCost
		end
		self.nTotalRefrsh = table.nums(self.tRefresh)
	end
	return self.nTotalRefrsh - self.nRfn, self.nTotalRefrsh
end

--获取商店刷新消耗
function PassKillHeroData:getShopRefrshCost()
	if not self.tRefresh then
		self:getShopRefreshNum()		
	end
	local nCurTime = self.nRfn + 1
	if nCurTime > self.nTotalRefrsh then
		return self.tRefresh[self.nTotalRefrsh] 
	else
		return self.tRefresh[nCurTime]
	end
end

--是否已购买商品
--_nIdx:商品兑换id
function PassKillHeroData:isHadBuyShopItem(_nIdx)
	if not _nIdx then
		return false
	end
	if self.tAlaw and #self.tAlaw > 0 then
		for k, v in pairs(self.tAlaw) do
			if v == _nIdx then
				return true
			end			
		end
	end 	
	return false
end

--获取过关斩将商店物品列表
function PassKillHeroData:getShopItems()
	local tCurShopItems = {}
	for k, v in pairs(self.tShopId) do
		local pShopItem = getExpediteShopItemByIdx(v)
		if pShopItem then
			pShopItem.bHadBuy = self:isHadBuyShopItem(v)
			table.insert(tCurShopItems, pShopItem)
		end		
	end
	table.sort(tCurShopItems,function ( a,  b )
		-- body
		if a.bHadBuy == b.bHadBuy then
			return (a.place < b.place)
		else
			return (not a.bHadBuy)
		end
		
	end )
	return tCurShopItems
end

--设置已读
function PassKillHeroData:setRead(_reportId)
	-- body
	for k, v in pairs(self.tRp) do
		if v.nReportId == _reportId then
			v.bIsReaded = true
			break
		end
	end
end

return PassKillHeroData
