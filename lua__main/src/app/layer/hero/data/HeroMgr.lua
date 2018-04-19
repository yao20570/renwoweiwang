--
-- Author: liangzhaowei
-- Date: 2017-04-21 15:18:58
-- 英雄管理数据体
-----------------------------------------------------
local HeroMgr = class("HeroMgr")


function HeroMgr:ctor(  )
	self:myInit()
	-- 初始化基础数据
	self:initBaseDatas()
end

function HeroMgr:myInit(  )
	self.tHeroList 								= {} 		-- 英雄列表
	self.nOnlineNums                            = 1         -- 武将可上阵数量
	self.tFe                                    = {}       -- 免费培养数据   {f	免费次数 c	恢复CD}
	self.nAuto                                  = 0        --	是否自动补兵 0否 1是
	self.nLastFeTime                            = 0        --最后一次刷新培养cd时间
	self.tSm                                    = {}       --英雄推演数据
	self.nLastFreshFcd                          = 0        --最后一次刷新良将cd的时间
	self.nLastFreshGcd                          = 0        --最后一次刷新神将结束cd的时间
	self.nAttrIndex								= 1  	   --最后关闭界面的时候打开属性item的索引
	self.nChooseList 							= {}	   --服务器返回的自选队列

	self.tSm.fc   = 0   --Integer	良将推演次数
	self.tSm.gc   = 0   --Integer	神将推演次数
	self.tSm.fcd  = 0   --Long	    免费良将推演CD
	self.tSm.gf   = 0   --Integer	神将推演是否免费 0否1是
	self.tSm.prg  = 0   --Integer	神将推演开启进度
	self.tSm.gop  = 0   --Integer	神将推演是否开启 0否1是
	self.tSm.gcd  = 0   --Long	    神将推演关闭时间
	
end



-- 刷新数据
function HeroMgr:refreshDatasByService( _tData )
	if (not _tData) then
		return 
	end

	-- dump(_tData,"_tData")
	--bat	武将上阵数更新
	self.nOnlineNums = _tData.bat or self.nOnlineNums

	
	--刷新武将培养次数
	self:refreshTrainTimes(_tData)

	self.nAuto       = _tData.auto or self.nAuto -- 是否自动补兵 0否 1是

	if _tData.hs then
		-- 刷新英雄列表数据
		self:refreshHeroListDatasByService(_tData.hs)
	end

	if _tData.ho then
		self:updateHeroData(_tData.ho)
	end

	--推演数据
	if _tData.sm then
	   self:updateSummonVo(_tData.sm)
	   sendMsg(gud_refresh_buy_hero) --通知拜将台数据
	end

	--自选队列
	if _tData.oq then
		self:updateChooseHeros(_tData.oq)
	end
end

--刷新武将培养次数
function HeroMgr:refreshTrainTimes(_tData)
	-- body
	self.tFe         = _tData.fe or self.tFe ---免费培养数据
	if _tData.fe then
		self.nLastFeTime = getSystemTime(true)
		sendMsg(ghd_item_home_menu_red_msg)
	end
end

--获取武将培养红点
function HeroMgr:getTalentRedNum(  )
	-- body
	local nRedNum = 0
	local nFreeMax = tonumber(getHeroInitData("trainFreeMax"))
	local tHeroOnlineList = Player:getHeroInfo():getBusyHeroList() --所有上阵武将
	for k, v in pairs(tHeroOnlineList) do
		local bMaxTalent = true--是否达到最大资质 (true 为没有达到)
		local pHeroData = v
		if pHeroData and pHeroData.nTalentLimitSum and pHeroData.getNowTotalTalent then
			if pHeroData:getNowTotalTalent() >= pHeroData.nTalentLimitSum then
				bMaxTalent = false
			end
		end

		--培养红点
		if self.tFe and self.tFe.f and self.tFe.f >= nFreeMax 
		  and (pHeroData.nQuality~= 1) and bMaxTalent then
		  	nRedNum = nRedNum + self.tFe.f
		end
	end

	return nRedNum
end

--获取武将培养红点
function HeroMgr:getTalentRedNumByTeam( _nTeamType )
	-- body
	local nRedNum = 0
	local nFreeMax = tonumber(getHeroInitData("trainFreeMax"))
	local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroListByTeam(_nTeamType) --所有上阵武将
	for k, v in pairs(tHeroOnlineList) do
		local bMaxTalent = true--是否达到最大资质 (true 为没有达到)
		local pHeroData = v
		if pHeroData and pHeroData.nTalentLimitSum and pHeroData.getNowTotalTalent then
			if pHeroData:getNowTotalTalent() >= pHeroData.nTalentLimitSum then
				bMaxTalent = false
			end
		end

		--培养红点
		if self.tFe and self.tFe.f and self.tFe.f >= nFreeMax 
		  and (pHeroData.nQuality~= 1) and bMaxTalent then
		  	nRedNum = nRedNum + self.tFe.f
		end
	end

	return nRedNum
end

-- 初始化英雄管理的基础数据
function HeroMgr:initBaseDatas(  )

end


--刷新推演数据
function HeroMgr:updateSummonVo(_tData)
	if _tData then
		self.tSm.fc    =  	_tData.fc	or  self.tSm.fc      --Integer	良将推演次数
		self.tSm.gc    =  	_tData.gc	or  self.tSm.gc      --Integer	神将推演次数
		self.tSm.fcd   =   	_tData.fcd	or  self.tSm.fcd     --Long	    免费良将推演CD
		self.tSm.gf    =  	_tData.gf	or  self.tSm.gf      --Integer	神将推演是否免费 0否1是
		self.tSm.prg   =   	_tData.prg	or  self.tSm.prg     --Integer	神将推演开启进度
		self.tSm.gop   =   	_tData.gop	or  self.tSm.gop     --Integer	神将推演是否开启 0否1是
		self.tSm.gcd   =   	_tData.gcd	or  self.tSm.gcd     --Long	    神将推演关闭时间
		if _tData.fcd then --免费良将推演CD
			self.nLastFreshFcd  = getSystemTime(true)
		end
		if _tData.gcd then -- 神将推演关闭时间
			self.nLastFreshGcd  = getSystemTime(true)
		end
	end
end

-- 刷新英雄数据
function HeroMgr:updateHeroData( _tData )
	if (not _tData) then
		return 
	end
	-- 获取英雄数据
	local pHero = self:getHero(_tData.h)
	if (not pHero) then
		pHero = getHeroDataById(_tData.t)
		if (not pHero) then
			return 
		end
		table.insert(self:getHeroList(),pHero) --新增一个英雄

		
	end

	pHero:refreshDatasByService(_tData)
	
end

-- 刷新英雄列表数据
function HeroMgr:refreshHeroListDatasByService( _tData )
	if (not _tData) then
		return 
	end

	for k,v in pairs(_tData) do
		self:updateHeroData(v) -- 刷新英雄数据
	end

end
-- 刷新英雄数据
function HeroMgr:refreshHeroDatasByService( _tData )
	if (not _tData) then
		return 
	end

	self:updateHeroData(_tData) -- 刷新英雄魂魄数据

end

-- 获取培养cd时间
function HeroMgr:getTrainTime()
	local nTime = -12345
	if self.tFe.c then
		if self.tFe.c == 0 and self.tFe.f < tonumber(getHeroInitData("trainFreeMax")) then
			SocketManager:sendMsg("renewTrainTimes", {}, function (__msg)
			end)
		end
		nTime = self.tFe.c - (getSystemTime(true) - self.nLastFeTime)
	end
	return nTime
end

function HeroMgr:getTrainCount()
	-- body
	return self.tFe.f or 0
end



---------------------------- 英雄数据管理 ----------------------------
-- 获取拥有的英雄列表
function HeroMgr:getHeroList()
	if (not self.tHeroList) then
		self.tHeroList = {}
	end

	return self.tHeroList
end

-- 根据英雄的id获取英雄对象
-- _sHeroId： 英雄唯一标识
function HeroMgr:getHero( _nId )
	local pHero = nil
	if (not _nId) then
		return pHero
	end
	for k,v in pairs(self:getHeroList() or {}) do
		if (v and v.nId == _nId) then
			pHero = v
			break
		end
	end
	return pHero
end

--根据英雄的唯一标志获取英雄对象
function HeroMgr:getHeroByKey( _sKey )
	-- body
	local pHero = nil
	if (not _sKey) then
		return pHero
	end
	for k,v in pairs(self:getHeroList() or {}) do
		if (v and v.nKey == _sKey) then
			pHero = v
			break
		end
	end
	return pHero
end

--获取拥有该品质的英雄数量
function HeroMgr:getHeroNumByQuality( _nQuality )
	-- body
	local nNum = 0
	if (not _nQuality) then
		return 0
	end
	for k,v in pairs(self:getHeroList() or {}) do

		if (v and v.nQuality == _nQuality) then
			nNum = nNum + 1
		end
	end
	return nNum
end

-------------------------- 上阵英雄队列--------------------------------------
-- _bBattle上阵战斗顺序
function HeroMgr:getOnlineHeroList(_bBattle)
	local tList = {}
	if table.nums(self.tHeroList)> 0 then
		for k,v in pairs(self.tHeroList) do
			if v.nP > 0 then --如果位置大于0则为上阵
				table.insert(tList,v) 
			end
		end

		table.sort( tList, function (a,b)
			return a.nP < b.nP
		end )
	end

	if not _bBattle or _bBattle == false then
		return tList
	else
		local tHeroOrder = self:getLocalHeroOrder()
		table.sort( tList, function (a,b)
			--使用默认的重置
			if tHeroOrder and table.nums(tHeroOrder) == 0 then
				if a.nLv < b.nLv then
					return true
				else
					if a.nLv > b.nLv then
						return false
					else
						if a.nBaseTalentSum > b.nBaseTalentSum then
							return true
						else
							if a.nBaseTalentSum < b.nBaseTalentSum then
								return false
							else
								if a.nId > b.nId then
									return true
								else
									return false
								end
							end
						end
					end
				end
			else
				if tHeroOrder[a.nId] and tHeroOrder[b.nId] then
					return tHeroOrder[a.nId] < tHeroOrder[b.nId]
				else
					return a.nP < b.nP	
				end
			end

			
		end )	
		return tList
	end

end

function HeroMgr:saveLocalHeroOrder( _tHeroOrder )
	-- body
	if not _tHeroOrder then
		saveLocalInfo("HeroBattleOrder"..Player:getPlayerInfo().pid, "0")--重置数据
		return
	end
	local sHeroIds = table.concat(_tHeroOrder, ";")	
	saveLocalInfo("HeroBattleOrder"..Player:getPlayerInfo().pid, sHeroIds)--本地记录 玩家上阵顺序	
end

function HeroMgr:getLocalHeroOrder( )
	-- body
	local sHeroIds = getLocalInfo("HeroBattleOrder"..Player:getPlayerInfo().pid, "0")--本地记录 玩家上阵顺序	
	local tHeroOrder = {}
	if sHeroIds ~= "0" then	
		local tHeros = luaSplit(sHeroIds, ";")	
		if tHeros and #tHeros > 0 then		
			for k, v in pairs(tHeros) do
				tHeroOrder[tonumber(v)] = k
			end
		end
	end	
	return tHeroOrder
end
-------------------------- 上阵英雄队列--------------------------------------

-------------------------- 上阵采集队列--------------------------------------
-- _bBattle上阵采集队列
function HeroMgr:getCollectHeroList(_bBattle)
	local tList = {}
	if table.nums(self.tHeroList)> 0 then
		for k,v in pairs(self.tHeroList) do
			if v.nCp > 0 then --如果位置大于0则为上阵
				table.insert(tList,v) 
			end
		end

		table.sort( tList, function (a,b)
			return a.nCp < b.nCp
		end )
	end

	if not _bBattle or _bBattle == false then
		return tList
	else
		local tHeroOrder = self:getLocalHeroOrder()
		table.sort( tList, function (a,b)
			if tHeroOrder[a.nId] and tHeroOrder[b.nId] then
				return tHeroOrder[a.nId] < tHeroOrder[b.nId]
			else
				return a.nCp < b.nCp	
			end
			
		end )	
		return tList
	end
end

--获取上阵队列数据
function HeroMgr:getHeroOnlineCollectQueue()
	-- body
	local tList = {}
	local tHeroOnlineList = self:getCollectHeroList() --上阵队列
	local nOnLineNum = self:getCollectQueueNums()
	for i=1,4 do
		if tHeroOnlineList[i] then
			tList[i] = tHeroOnlineList[i]
		else
			--锁住类型待添加
			if i> nOnLineNum then
				tList[i] = TypeIconHero.LOCK
			else
				tList[i] = TypeIconHero.ADD
			end
		end
	end
	return tList
end

--获取是否还有武将可以上阵
function HeroMgr:bHaveHeroUpCollect()
	local bHave = false
	local nNums = table.nums(self:getCollectHeroList())
	local nFreeHero = table.nums(self:getFreeHeroList())
	local nOnLineNums = self:getCollectQueueNums()
	if (nNums < nOnLineNums) and (nFreeHero > 0) then
		bHave = true
	end

	return bHave
end

--获取采集可上阵武将数量
function HeroMgr:getCollectQueueNums( )
	local pChiefData = Player:getBuildData():getBuildById(e_build_ids.tcf)
	if pChiefData then
		return pChiefData.nCq
	end
	return 0
end

-------------------------- 上阵采集队列--------------------------------------

-------------------------- 上阵城防队列--------------------------------------
function HeroMgr:getDefenseHeroList(_bBattle)
	local tList = {}
	if table.nums(self.tHeroList)> 0 then
		for k,v in pairs(self.tHeroList) do
			if v.nDp > 0 then --如果位置大于0则为上阵
				table.insert(tList,v) 
			end
		end

		table.sort( tList, function (a,b)
			return a.nDp < b.nDp
		end )
	end

	if not _bBattle or _bBattle == false then
		return tList
	else
		local tHeroOrder = self:getLocalHeroOrder()
		table.sort( tList, function (a,b)
			if tHeroOrder[a.nId] and tHeroOrder[b.nId] then
				return tHeroOrder[a.nId] < tHeroOrder[b.nId]
			else
				return a.nDp < b.nDp	
			end
			
		end )
		return tList
	end
end

--获取上阵队列数据
function HeroMgr:getHeroOnlineDefenseQueue()
	-- body
	local tList = {}
	local tHeroOnlineList = self:getDefenseHeroList() --上阵队列
	local nOnLineNum = self:getDefenseQueueNums()
	for i=1,4 do
		if tHeroOnlineList[i] then
			tList[i] = tHeroOnlineList[i]
		else
			--锁住类型待添加
			if i> nOnLineNum then
				tList[i] = TypeIconHero.LOCK
			else
				tList[i] = TypeIconHero.ADD
			end
		end
	end
	return tList
end

--获取自选队列
function HeroMgr:getHeroSelfChooseQueue()
	local tList = {}
	local tChooseList = {}
	if self.nChooseList and #self.nChooseList > 0 and table.nums(self.tHeroList)> 0 then
		for i=1, #self.nChooseList do
			for k,v in pairs(self.tHeroList) do
				if v.nId == self.nChooseList[i].h then
					table.insert(tChooseList,v) 
					break
				end
			end
		end
	end

	local tOnlineList = self:getHeroOnlineQueue()
	for i=1, #tOnlineList do
		if tChooseList[i] then
			table.insert(tList, copyTab(tChooseList[i]))
		else
			if type(tOnlineList[i]) == "table" then
				table.insert(tList, TypeIconHero.ADD)
			else
				table.insert(tList, tOnlineList[i])
			end
		end
	end
	return tList
end

--获取是否还有武将可以上阵
function HeroMgr:bHaveHeroUpDefense()
	local bHave = false
	local nNums = table.nums(self:getDefenseHeroList())
	local nFreeHero = table.nums(self:getFreeHeroList())
	local nOnLineNums = self:getDefenseQueueNums()
	if (nNums < nOnLineNums) and (nFreeHero > 0) then
		bHave = true
	end

	return bHave
end

--获取城防可上阵武将数量
function HeroMgr:getDefenseQueueNums( )
	local pChiefData = Player:getBuildData():getBuildById(e_build_ids.tcf)
	if pChiefData then
		return pChiefData.nDq
	end
	return 0
end
-------------------------- 上阵城防队列--------------------------------------

-------------------------- 拥有未上阵英雄队列--------------------------------------
function HeroMgr:getFreeHeroList()
	local tList = {}
	if table.nums(self.tHeroList)> 0 then
		for k,v in pairs(self.tHeroList) do
			if v.nP == 0 and v.nCp == 0 and v.nDp == 0 then --如果位置等于0则为上阵
				table.insert(tList,v) 
			end
		end
	end


	return tList

end

--获取上阵武将列表（不区分队列类型）
function HeroMgr:getBusyHeroList( ... )
	-- body
	local tList = {}
	if table.nums(self.tHeroList)> 0 then
		for k,v in pairs(self.tHeroList) do
			if v.nP > 0 or v.nCp > 0 or v.nDp > 0 then --如果位置等于0则为上阵
				table.insert(tList,v) 
			end
		end
	end
	return tList
end

function HeroMgr:getChooseSelfFreeHeroList()
	local tList = {}
	if table.nums(self.tHeroList)> 0 then
		for k,v in pairs(self.tHeroList) do
			local bHave = false
			for key, value in pairs(self.nChooseList) do
				if value.h == v.nId then
					bHave = true
					break
				end
			end
			if not bHave then
				table.insert(tList,v) 
			end
		end
	end
	return tList
end
-- 

-------------------------- 拥有未上阵英雄队列--------------------------------------


--------------------自选队列--------------------------
function HeroMgr:updateChooseHeros(_heroData)
	self.nChooseList = _heroData
end

function HeroMgr:getChooseList()
	return self.nChooseList
end

-------------------------- 获取聚贤馆的展示英雄队列--------------------------------
function HeroMgr:getShogunList()
	local tList = {}
	local tOnlineList = self:getOnlineHeroList()
	for i=1,4 do
		if not tOnlineList[i] then
			if i> self.nOnlineNums then
				tOnlineList[i] = TypeIconHero.LOCK --锁住状态
			else
				tOnlineList[i] = TypeIconHero.ADD --可添加状态
			end
		end
	end
	local nIndex = 1
    --上阵列表
    tList[nIndex] = tOnlineList


	return tList	
end

--获取武将列表(根据单个英雄整合所有的武将)
function HeroMgr:getSoleHeroList()
	--获得所有武将的唯一标志
	if self.tAllHeroKeys == nil or table.nums(self.tAllHeroKeys) <= 0 then
		self.tAllHeroKeys = getAllHeroKeys()
	end
	
	if self.tSoleHeroData == nil then
		self.tSoleHeroData = {}
	end
	--根据key值获取武将相关数据
	for k, v in pairs (self.tAllHeroKeys) do
		if self.tSoleHeroData[v.category] == nil then --判断星级列表是否存在
			self.tSoleHeroData[v.category] = {}
		end
		--先从玩家自身查找
		local pCurHero = self:getHeroByKey(v.key)

		local nIndex = nil --缓存列表的数据下标
		if table.nums(self.tSoleHeroData[v.category]) > 1 then
			for m, n in pairs (self.tSoleHeroData[v.category]) do
				if n.nKey == v.key then
					nIndex = m
					break
				end
			end
		end
		--如果玩家数据存在
		if pCurHero then
			pCurHero.nHave = 1 --已拥有
			if nIndex then --缓存列表也存在
				self.tSoleHeroData[v.category][nIndex] = pCurHero
			else
				table.insert(self.tSoleHeroData[v.category], pCurHero)
			end
		else
			if not nIndex then --缓存列表不存在
				pCurHero = getHeroDataById(v.key) --注意：玩家没有改武将的时候 key值==id值
				table.insert(self.tSoleHeroData[v.category], pCurHero)
			end
		end
	end

	return self.tSoleHeroData
end

--获取星级列表
function HeroMgr:getStarHeroList()

	local tSoleHero = self:getSoleHeroList()
	for k,v in pairs(tSoleHero) do
		if k> 1 then
			table.sort( v, function (a,b)
                if a.nHave == b.nHave then
					if a.nQuality ==  b.nQuality then
						if a:getBaseTotalTalent() == b:getBaseTotalTalent() then						
							return a.nKey < b.nKey
						else
							return a:getBaseTotalTalent() > b:getBaseTotalTalent()
						end
					else
						return a.nQuality > b.nQuality
					end
                else
                	return a.nHave > b.nHave
                end
			end )
		end
	end
--    print("\n")
--    for _, l in pairs(tSoleHero) do
--        for k, v in pairs(l) do
--            print("HeroMgr:getStarHeroList()", _, v.nHave, v.nQuality, v:getBaseTotalTalent(), v.nKey)
--        end
--    end

	return tSoleHero
end


--获取当前上阵位置状态 _nPos
function HeroMgr:getOnlinePosState(_nPos)
	-- body
	if (not _nPos ) or _nPos > 4 then
		return
	end

	local nState = TypeIconHero.LOCK


	if table.nums(self:getOnlineHeroList()) >= _nPos then
		nState = TypeIconHero.NORMAL
	else
		if _nPos> self.nOnlineNums then
			nState = TypeIconHero.LOCK --锁住状态
		else
			nState = TypeIconHero.ADD --可添加状态
		end
	end

	return nState
end

--获取当前上阵位置状态 _nPos
function HeroMgr:getDefensePosState(_nPos)
	-- body
	if (not _nPos ) or _nPos > 4 then
		return
	end

	local nState = TypeIconHero.LOCK
	--城防上阵队列上阵数量
	local nLineUpNums = self:getDefenseQueueNums()
	if table.nums(self:getDefenseHeroList()) >= _nPos then
		nState = TypeIconHero.NORMAL
	else
		if _nPos> nLineUpNums then
			nState = TypeIconHero.LOCK --锁住状态
		else
			nState = TypeIconHero.ADD --可添加状态
		end
	end

	return nState
end

--获取当前上阵位置状态 _nPos
function HeroMgr:getCollectPosState(_nPos)
	-- body
	if (not _nPos ) or _nPos > 4 then
		return
	end

	local nState = TypeIconHero.LOCK
	--城防上阵队列上阵数量
	local nLineUpNums = self:getCollectQueueNums()
	if table.nums(self:getDefenseHeroList()) >= _nPos then
		nState = TypeIconHero.NORMAL
	else
		if _nPos> nLineUpNums then
			nState = TypeIconHero.LOCK --锁住状态
		else
			nState = TypeIconHero.ADD --可添加状态
		end
	end

	return nState
end
-------------------------- 获取聚贤馆的展示英雄队列--------------------------------

--获取上阵队列数据
function HeroMgr:getHeroOnlineQueue()
	-- body
	local tList = {}
	local tHeroOnlineList = self:getOnlineHeroList() --上阵队列
	for i=1,4 do
		if tHeroOnlineList[i] then
			tList[i] = tHeroOnlineList[i]
		else
			--锁住类型待添加
			if i> self.nOnlineNums then
				tList[i] = TypeIconHero.LOCK
			else
				tList[i] = TypeIconHero.ADD
			end
		end
	end
	return tList
end


---------------------------获取拜将台数据----------------------------------------------
function HeroMgr:getBuyHeroData()
	local tData = {}
	if self.tSm then
		tData = self.tSm
	end
    return tData
end

--获取良将免费剩余cd
function HeroMgr:getFreeBuyLiangCd()
	local nCd = 0
	nCd = self.tSm.fcd - (getSystemTime(true)- self.nLastFreshFcd)
	if nCd < 0 then
		nCd = 0
	end	
	return nCd
end

--获取神将关闭剩余cd
function HeroMgr:getLeftCloseLiangCd()
	local nCd = 0
	nCd = self.tSm.gcd - (getSystemTime(true)- self.nLastFreshGcd)
	if nCd < 0 then
		nCd = 0
	end	
	return nCd
end

--关闭神将推演
function HeroMgr:closeShen()
	-- body
	self.tSm.gop = 0
end

--获取是否还有武将可以上阵
function HeroMgr:bHaveHeroUp()
	local bHave = false
	local nNums = table.nums(self:getOnlineHeroList())
	local nFreeHero = table.nums(self:getFreeHeroList())
	if (nNums < self.nOnlineNums) and (nFreeHero > 0) then
		bHave = true
	end

	return bHave
end

--获取拜将台是否有免费次数
function HeroMgr:getBuyHeroFree()
	local bFree = false
	--良将判断
	if self:getFreeBuyLiangCd() == 0 then
		bFree = true
	--暂时屏蔽神将判断, 因为现在屏蔽了神将入口
	else
		if self.tSm.gf == 1 and self.tSm.gop == 1 then
			bFree = true
		end
	end
	
	return bFree
end

------------------特殊处理界面相关---------------------
function HeroMgr:setAttrIndex(_nAttrIndex)
	self.nAttrIndex = _nAttrIndex
end
----------------------------------------------类型相关方法
--根据队伍类型 获取上阵列表
function HeroMgr:getOnlineHeroListByTeam( nTeamType, _bBattle )
	if nTeamType == e_hero_team_type.collect then
		return self:getCollectHeroList(_bBattle)
	elseif nTeamType == e_hero_team_type.walldef then
		return self:getDefenseHeroList(_bBattle)
	else
		return self:getOnlineHeroList(_bBattle)
	end
end

function HeroMgr:getAttrIndex()
	return self.nAttrIndex
end

--根据队伍类型 获取上阵列表
function HeroMgr:getHeroOnlineQueueByTeam( nTeamType )
	if nTeamType == e_hero_team_type.collect then
		return self:getHeroOnlineCollectQueue()
	elseif nTeamType == e_hero_team_type.walldef then
		return self:getHeroOnlineDefenseQueue()
	elseif nTeamType == e_hero_team_type.selfchoose then
		return self:getHeroSelfChooseQueue()
	else
		return self:getHeroOnlineQueue()
	end
end

--判断是不是主力武将
function HeroMgr:getIsNormalHero(_nId)
	local tNormalList = self:getHeroOnlineQueueByTeam(e_hero_team_type.normal)
	for k, v in pairs(tNormalList) do
		if type(v) == "table" then
			if v.nId == _nId then
				return true
			end
		end
	end
	return false
end

--根据队伍类型 获取是否有武将上阵
function HeroMgr:bHaveHeroUpByTeam( nTeamType )
	if nTeamType == e_hero_team_type.collect then
		return self:bHaveHeroUpCollect()
	elseif nTeamType == e_hero_team_type.walldef then
		return self:bHaveHeroUpDefense()
	else
		return self:bHaveHeroUp()
	end
end

--根据队伍类型 获取可以上阵数量
function HeroMgr:getOnLineNumsByTeam( nTeamType )
	if nTeamType == e_hero_team_type.collect then
		return self:getCollectQueueNums()
	elseif nTeamType == e_hero_team_type.walldef then
		return self:getDefenseQueueNums()
	else
		return self.nOnlineNums
	end
end

--根据队伍类型 获取位置状态
function HeroMgr:getOnlinePosStateByTeam( nTeamType, nPos )
	if nTeamType == e_hero_team_type.collect then
		return self:getCollectPosState(nPos)
	elseif nTeamType == e_hero_team_type.walldef then
		return self:getDefensePosState(nPos)
	else
		return self:getOnlinePosState(nPos)
	end
end
--获取武将菜单红点数
function HeroMgr:getHomeMenuRedNum(  )
	-- 获取武将培养红点
	local nRedNum = self:getTalentRedNum()
	-- 有更好的装备
	local tHeroOnlineList = self:getBusyHeroList() --上阵队列
	for k,v in pairs(tHeroOnlineList) do
		local bHasBetterEquip = Player:getEquipData():getIsHasBetterEquip( v.nId)
		if bHasBetterEquip then
			nRedNum = nRedNum + 1
			break
		end
		--是否可以进阶
		if v and v.advanceRedNum and v:advanceRedNum() then
			nRedNum = nRedNum + 1
		end
	end
	--
	if self:bHaveHeroUpByTeam(e_hero_team_type.normal) 
		or self:bHaveHeroUpByTeam(e_hero_team_type.collect) 
		or self:bHaveHeroUpByTeam(e_hero_team_type.walldef) then
		nRedNum = nRedNum + 1
	end
	return nRedNum
end
--获取武将队列分页红点数
function HeroMgr:getTabHeroRedNum( _nTeamType )
	-- body
	local nRedNum = 0
	local bUnLock = false
	local tBuildData=Player:getBuildData():getBuildById(e_build_ids.tcf)
	if _nTeamType == e_hero_team_type.collect then		
		if tBuildData then
			bUnLock = true
		end
	elseif _nTeamType == e_hero_team_type.walldef then
		if tBuildData and tBuildData.nLv >= tsf_open_citydef_team_lv then
			bUnLock = true
		end
	else
		bUnLock = true
	end
	
	if bUnLock then
		nRedNum = self:getTalentRedNumByTeam(_nTeamType)
		--有更好的装备
		local tHeroOnlineList = self:getOnlineHeroListByTeam(_nTeamType) --上阵队列
		for k,v in pairs(tHeroOnlineList) do
			local bHasBetterEquip = Player:getEquipData():getIsHasBetterEquip( v.nId)
			if bHasBetterEquip then
				nRedNum = nRedNum + 1
				break
			end
			--是否可以进阶
			if v and v.advanceRedNum and v:advanceRedNum() then
				nRedNum = nRedNum + 1
			end
		end
		
		if self:bHaveHeroUpByTeam(_nTeamType) then
			nRedNum = nRedNum + 1
		end
	end
	return nRedNum
end

function HeroMgr:isOpenQuenceByType( _nTeamType )
	-- body
	local tBuildData=Player:getBuildData():getBuildById(e_build_ids.tcf)
	if _nTeamType == e_hero_team_type.normal then
		return true
	elseif _nTeamType == e_hero_team_type.collect then
		if tBuildData then
			return true
		end	
	elseif _nTeamType == e_hero_team_type.walldef then
		if tBuildData and tBuildData.nLv >= tsf_open_citydef_team_lv then
			return true
		end
	end
	return false	
end

--根据上阵位置获取武将数据
function HeroMgr:getOnLineHeroByPos( _nPos )
	-- body
	local pHero = nil
	local tOnLineHeros = self:getOnlineHeroList()
	for k, v in pairs(tOnLineHeros) do
		if v.nP == _nPos then
			pHero = v	
			break		
		end
	end
	return pHero
end

return HeroMgr
