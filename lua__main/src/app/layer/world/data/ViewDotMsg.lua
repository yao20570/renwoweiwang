--视图点展示数据类
local ViewDotMsg = class("ViewDotMsg")

function ViewDotMsg:ctor( tData )
	self.tIsPGuardsBattled = {}
	self.bHasPaper = false
	self.nSysCityExp = 0
	self:update(tData)
end

function ViewDotMsg:update( tData )
	if not tData then
		return
	end
	self.nX = tData.x --x坐标
	self.nY = tData.y --y坐标
	self.nType = tData.t --视图点类型
	self.nMineType = tData.mt --矿点类型(矿点独有) [1客栈2木厂3农场4铁矿5金矿]
	self.nRemainRes = tData.res --矿点资源剩余量(矿点独有)
	self.nMineID = tData.mI --矿点模板ID(矿点独有)
	-- if self.nX ==  180 and self.nY == 120 and self.nMineID == 12002 then
	-- 	dump(tData)
	-- end
	self.bIsMeOccupy = tData.oc == 1 --矿点是否被我占领(矿点独有) 1：是 0：否
	self.bIsOccupyer = tData.ocM == 1 --矿点是否被占领(矿点独有) 1:是 0:否
	self.sOccupyerName = tData.oN --矿点占领者名字(矿点独有)
	self.nOccupyerLv = tData.olv --矿点占领者等级
	self.nOccupyerCountry = tData.oCu --矿点占领者国家(矿点独有)
	-- self.sOccupyerHeroName = tData.oh --矿点占领者英雄名字(矿点独有)
	self.nOccupyerHeroId = tData.hid --矿点占领者英雄id
	self.nOccupyerHeroLv = tData.hv --矿点占领者英雄等级(矿点独有)
	self.nOccupyerTroops = tData.ht --矿点占领者英雄带兵(矿点独有)
	self.nOccupyerTroopsMax = tData.mxt --矿点占领者英雄带兵上限(矿点独有)
	self.bOccupyerCHero = tData.ch == 1 --矿点占领者英雄是否是采集队列
	self.nKzt = tData.kzt   --kzt	Long	纣王剩下兵力
	self.nKztt = tData.kztt --kztt	Long	纣王总共兵力
	self.tKzps = tData.kzps --List<PointVO>	纣王位置
	if tData.kzgo then
		self.nKzGo = tData.kzgo --kztt 			纣王时间
		self.nKzGoSystemTime = getSystemTime()
	end
	
	if tData.ccd then
		self.nOccupyerCd = tData.ccd --字段表示采集倒计时秒
		self.nOccupyerCdSystemTime = getSystemTime()
	end
	
	if tData.hs then
		self.nOccupyerTemplate = tData.hs.t --采集武将模板
		self.nOccupyerIg = tData.hs.ig or 0 --采集武将是否神将
	end

	self.nCityId = tData.qq --玩家城池ID(玩家ID)
	self.nLevel = tData.lv --玩家城池等级(玩家城池独有)
	self.nCountry = tData.c --玩家城池所属国家(玩家城池独有)
	self.sName = tData.n --玩家名字(玩家城池独有)
	if tData.pt then
		self.nPlayerProtectCd = tData.pt --玩家城池保护CD(玩家城池独有)
		self.nPlayerProtectSystemTime = getSystemTime()
	end

	self.sSysCityName = tData.cn -- 系统城池名字（都城/名城独有）
	self.nSysCityExp = tData.cx or self.nSysCityExp --Long	系统城池经验(都城独有)
	self.bIsPGuardsUnlock = tData.ly == 1	--Integer	是否解锁御林军(都城独有)0:否 1:是
	if tData.gy then --Set<Integer>	已出战的御林军(都城独有)
		self.tIsPGuardsBattled = {}
		for i=1,#tData.gy do
			local tNpcList = getNpcGropById(tData.gy[i])
			if tNpcList then
				for j=1,#tNpcList do
					local sTid = tNpcList[j].sTid
					self.tIsPGuardsBattled[sTid] = true
				end
			end
		end
	end
	

	self.nSystemCityLv = tData.v --系统城池等级(系统城池独有) 
	self.nSystemCityId = tData.s --系统城池ID(系统城池独有) 
	-- self.nDropId = tData.d --系统城池掉落ID(系统城池独有)
	self.nSysCountry = tData.sc --系统城池所属国家（系统城池独有) 
	self.sLeader = tData.le --城主名字(系统城池独有)
	self.sLeaderLv = tData.cl --城主等级(系统城池独有)    
	self.sLeaderWGLv = tData.pl --城主王宫等级(系统城池独有)

	if tData.ewccd then
		self.nEWCaputerCd =  tData.ewccd --皇城战占领cd
		self.nEWCaputerCdSystemT = getSystemTime()
	end

	--集结cd时间
	if tData.tsec then
		self.nTogetherCd = tData.tsec
		self.nTogetherCdSystemT = getSystemTime()
	end

	if tData.rcd then
		self.nRetireTime = milliSecondToSecond(tData.rcd) --城主任期结束时间/毫秒(系统城池独有)
		self.nRetireTimeSystemTime = getSystemTime()
	end
	if tData.pcd then
		self.nProtectCd = milliSecondToSecond(tData.pcd) --系统城池保护时间/毫秒(系统城池独有)
		self.nProtectCdSystemTime = getSystemTime()
	end
	self.bIsHasCountryWar = tData.wc == 1 --系统城池是否有国战0:否 1:是

	self.nGarrisonTroopsMax = tData.at --	Integer	驻防最大兵力(系统城池独有)
	self.nCurrGarrisonTroops = tData.ct	--Integer	驻防当前兵力(系统城池独有) 
	if tData.hp then
		self.bHasPaper = tData.hp > 0 --是否有图纸，大于1就是有，小于等于0就是没有(系统城池独有) 
	end

	if tData.pc then --系统城池图纸倒计时/毫秒(系统城池独有)
		self.nPaperCd = milliSecondToSecond(tData.pc)
		self.nPaperCdSystemTime = getSystemTime()
	end

	if tData.lc then
		self.nCityOwnerApplyCd = milliSecondToSecond(tData.lc) --系统城池申请城主CD/毫秒(系统城池独有) 
		self.nCityOwnerApplyCdSystemTime  = getSystemTime()
	end
	self.bIsAtkMerit = tData.g == 1 -- Integer 是否攻下城池的功臣(系统城池独有)0:否 1:是
	if tData.ap then -- Integer	是否申请城主中(系统城池独有)0:否 1:是
		self:setIsApplyCityOwner(tData.ap == 1)
	end
	self:setFirstKill(tData.fk) --Integer 是否有首杀资格，(系统城池独有) 0:否 1:是
	self.nSysCityOwnerId = tData.ld --Long	城主ID (系统城池独有)

	self.nRebelId = tData.rI --乱军ID(乱军独有)
	-- self.nCanAck = tData.ak --是否能攻打该乱军(乱军独有)0:否 1:是

	-- self.bIsCalling = tData.cz == 0	--Integer	是否召唤中0是 1否 (玩家城池独有,同国玩家才有该字段)
	self:setCallInfo(tData.ci)--召唤数据(玩家城池独有,同国玩家才有该字段,召唤中才有该数据)

	self.bIsHasCityWar = tData.hc == 1 --是否有城战0:否 1:是

	self.bIsMoBing = tData.m == 1 --	Integer	是否魔化乱军1:是 0：否
	self.bIsHasBossWar = tData.br == 1 --	Integer	是否有boss战 0：否 1：是

	self.bIsHasGhostWar = tData.gh == 1 --是否有冥王战0:否 1:是
	self.nBossLv = tData.bl --	Integer	BOSS级别
	if tData.lt then --	Long	BOSS离开CD/秒
		self.nBossLeaveCd = tData.lt
		self.nBossLeaveCdSystemTime = getSystemTime()
	end
	self.nBossTroops = tData.bt	--Integer	BOSS兵力

	self.nGId = tData.gid --幽魂ID（幽魂独有)

	self.bEpwBattle = tData.ewb == 1 --皇城战双方有部队

	--自定义数据 --注意，自己的数据也要一样设置 ！！！
	-- self.bCanAck = self.nCanAck == 1 --乱军是否能打 
	self.sDotName = "" --名字
	self.nDotLv = 0 --
	if self.nType == e_type_builddot.wildArmy then
		if self.nRebelId then
			if self.bIsMoBing then
				local tWorldEnemyData = getAwakeArmyData(self.nRebelId)
				if tWorldEnemyData then
					self.sDotName = tWorldEnemyData.name
					self.nDotLv = tWorldEnemyData.level
					self.nDotCountry = e_type_country.qunxiong
				end
			else
				local tWorldEnemyData = getWorldEnemyData(self.nRebelId)
				if tWorldEnemyData then
					self.sDotName = tWorldEnemyData.name
					self.nDotLv = tWorldEnemyData.level
					self.nDotCountry = e_type_country.qunxiong
				end
			end
		end
	elseif self.nType == e_type_builddot.sysCity then 
		if self.nSystemCityId then
			local tWorldCityData = getWorldCityDataById(self.nSystemCityId)
			if tWorldCityData then
				self.sDotName = tWorldCityData.name
				--如果是都城或名城
				if tWorldCityData.kind == e_kind_city.ducheng or tWorldCityData.kind == e_kind_city.mingcheng then
					if self.sSysCityName then
						self.sDotName = self.sSysCityName
					end
				end
				self.nDotLv = self.nSystemCityLv
				self.nDotCountry = self.nSysCountry
				--重定坐标
				self.nX = tWorldCityData.tCoordinate.x
				self.nY = tWorldCityData.tCoordinate.y
			end
		end
	elseif self.nType == e_type_builddot.res then
		if self.nMineID then
			local tWorldMineData = getWorldMineData(self.nMineID)
			if tWorldMineData then
				self.sDotName = tWorldMineData.name
				self.nDotLv = tWorldMineData.nLevel
			end
		end
	elseif self.nType == e_type_builddot.city then
		self.sDotName = self.sName
		self.nDotLv = self.nLevel
		self.nDotCountry = self.nCountry
	elseif self.nType == e_type_builddot.boss then
		local tAwakeBoss = getAwakeBossData(self.nBossLv, Player:getWuWangDiff())
		if tAwakeBoss then
			self.sDotName = tAwakeBoss.name
		end
		self.nDotLv = self.nBossLv
	elseif self.nType == e_type_builddot.tlboss then
		self.sDotName = getConvertedStr(3, 10800)
		self.nBlockId = WorldFunc.getBlockId(self.nX, self.nY)
		self.tDotKeys = tData.tDotKeys
	elseif self.nType == e_type_builddot.ghostdom then   --幽魂
		if self.nGId then

			local tWorldEnemyData = getWorldGhostdomData(self.nGId)
			if tWorldEnemyData then
				self.sDotName = tWorldEnemyData.name
				self.nDotLv = tWorldEnemyData.level2
				self.nDotCountry = e_type_country.qunxiong
			end
		end
	elseif self.nType == e_type_builddot.zhouwang then   --纣王	
		local pKingZhou = WorldFunc.getKingZhouConfData()		
		if pKingZhou then
			self.sDotName = pKingZhou.sName
			self.nDotLv = pKingZhou.nLevel 
			self.nDotCountry = e_type_country.qunxiong
		end
		if self.tKzps then
			local tLeftPos = nil
			for i = 1, #self.tKzps do
				if tLeftPos then
					if self.tKzps[i].x <= tLeftPos.x and self.tKzps[i].y <= tLeftPos.y then
						tLeftPos = self.tKzps[i]
					end
				else
					tLeftPos = self.tKzps[i]
				end
			end
			self.nX = tLeftPos.x --x坐标
			self.nY = tLeftPos.y --y坐标
			self.tDotKeys = {}
			for k, v in pairs(self.tKzps) do
				table.insert(self.tDotKeys, string.format("%s_%s", v.x, v.y))
			end			
		else
			self.tDotKeys = nil	
		end
		
	end
	self.sDotKey = string.format("%s_%s", self.nX, self.nY) --格子唯一的标识
end

--召唤信息
function ViewDotMsg:setCallInfo( tData )
	if not tData then
		return
	end
	local CallInfo = require("app.layer.world.data.CallInfo")
	self.tCallInfo = CallInfo.new(tData)
end

--获取召唤信息
function ViewDotMsg:getCallInfo( )
	return self.tCallInfo
end

--获得系统城池保护时间/毫秒(系统城池独有)
function ViewDotMsg:getProtectCd( )
	if self.nProtectCd and self.nProtectCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nProtectCd - (fCurTime - self.nProtectCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--系统城池保护时间/毫秒(系统城池独有)
function ViewDotMsg:getPaperCd( )
	if self.nPaperCd and self.nPaperCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nPaperCd - (fCurTime - self.nPaperCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--系统城池申请城主CD/毫秒(系统城池独有)
function ViewDotMsg:getCityOwnerApplyCd( )
	if self.nCityOwnerApplyCd and self.nCityOwnerApplyCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCityOwnerApplyCd - (fCurTime - self.nCityOwnerApplyCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--城主任期结束时间/毫秒(系统城池独有) 
function ViewDotMsg:getRetireTime( )
	if self.nRetireTime and self.nRetireTime > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nRetireTime - (fCurTime - self.nRetireTimeSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--采集剩余时间
function ViewDotMsg:getOccupyerCdSystemTime(  )
	if self.nOccupyerCd and self.nOccupyerCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nOccupyerCd - (fCurTime - self.nOccupyerCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--皇城战占领时间
function ViewDotMsg:getEWCaputerCd( )
	local nCurrCd = 0
	if self.nEWCaputerCd then
		local fCurTime = getSystemTime()
		nCurrCd = self.nEWCaputerCd + (fCurTime - self.nEWCaputerCdSystemT)
	end
	return nCurrCd
end

--获取御林军是否出征
--nId: npc_monster id
function ViewDotMsg:getPGuardIsBattled( nId )
	if self.tIsPGuardsBattled[nId] then
		return true
	end
	return false
end

--是否设置是否申请过
function ViewDotMsg:setIsApplyCityOwner( bIsApply )
	self.bIsApplyCityOwner = bIsApply
end

--一般改名会用到
function ViewDotMsg:setCityName( sName )
	self.sSysCityName = sName
	self.sDotName = sName
end

--设置
function ViewDotMsg:setFirstKill( nValue )
	if not nValue then
		return
	end
	self.bIsFirstKill = nValue == 1 --Integer 是否有首杀资格，(系统城池独有) 0:否 1:是
end

function ViewDotMsg:setPos( nX, nY)
	if not nX or not nY then
		return
	end
	self.nX = nX
	self.nY = nY
end

function ViewDotMsg:getIsMe(  )
	if self.nCityId == Player:getPlayerInfo().pid then
		return true
	end
	return false
end

function ViewDotMsg:getDotName(  )
	if self:getIsMe() then
		return Player:getPlayerInfo().sName
	end
	return self.sDotName
end

function ViewDotMsg:getDotCountry(  )
	if self:getIsMe() then
		return Player:getPlayerInfo().nInfluence
	end
	return self.nDotCountry
end

function ViewDotMsg:getDotLv(  )
	if self:getIsMe() then
		return Player:getBuildData():getPalaceLv()
	end
	return self.nDotLv
end

--获取世界中坐标
function ViewDotMsg:getWorldMapPos( )
	if self.nType == e_type_builddot.sysCity then 
		if self.nSystemCityId then
			local tWorldCityData = getWorldCityDataById(self.nSystemCityId)
			if tWorldCityData then
				local tMapPos = tWorldCityData.tMapPos
				if tMapPos then
					return tMapPos.x, tMapPos.y
				end
			end
		end
	elseif self.nType == e_type_builddot.zhouwang then		
		local fPosX, fPosY = WorldFunc.getMapPosByDotPos(self.nX, self.nY )		
		return (fPosX + UNIT_WIDTH/2), fPosY
	else
		local fPosX, fPosY = WorldFunc.getMapPosByDotPos(self.nX, self.nY)
		return fPosX, fPosY
	end
	return nil
end

--获取系统城池城主名字
function ViewDotMsg:getSysCityOwnerName(  )
	if self.nSysCityOwnerId == Player:getPlayerInfo().pid then
		return Player:getPlayerInfo().sName
	end
	return self.sLeader
end

--获取系统城池等级
function ViewDotMsg:getSysCityOwnerLv(  )
	if self.nSysCityOwnerId == Player:getPlayerInfo().pid then
		return Player:getPlayerInfo().nLv
	end
	return self.sLeaderLv
end

--获取是否有系统城池是否有城主
function ViewDotMsg:getIsSysCityHasOwner( )
	return self.sLeader ~= nil and self:getRetireTime() > 0 
end

--不能发起国战
function ViewDotMsg:getIsCanCountryWar( )
	if self.nSystemCityId then
		--只剩下1个群雄都城（其他都城有国家了）
		if self.nSystemCityId == Player:getWorldData():getNoAttackCapital() then
			return false
		end
		--是都城
		local tCityData = getWorldCityDataById(self.nSystemCityId)
		if tCityData then
			if tCityData.kind == e_kind_city.ducheng then
				--自己有都城
				if Player:getWorldData():getIsHasCapital() then
					return false
				end
				--非群雄都城
				if self.nDotCountry ~= e_type_country.qunxiong then
					return false
				end
			end
		end		
	end
	return true
end

--是否群雄都城
function ViewDotMsg:getIsCapitalQun( )
	local tCityData = getWorldCityDataById(self.nSystemCityId)
	if tCityData then
		if tCityData.kind == e_kind_city.ducheng then
			return self.nSystemCityId == Player:getWorldData():getNoAttackCapital()
		end
	end
	return false
end

--获得玩家城池保护时间
function ViewDotMsg:getPlayerProtectCd( )
	if self:getIsMe() then
		return Player:getWorldData():getProtectCD()
	else
		if self.nPlayerProtectCd and self.nPlayerProtectCd > 0 then
			local fCurTime = getSystemTime()
			local fLeft = self.nPlayerProtectCd - (fCurTime - self.nPlayerProtectSystemTime)
			if(fLeft < 0) then
				fLeft = 0
			end
			return fLeft
		else
			return 0
		end
	end
	return 0
end

--获得Boss离开cd时间
function ViewDotMsg:getBossLeaveCd( )
	if self.nBossLeaveCd and self.nBossLeaveCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nBossLeaveCd - (fCurTime - self.nBossLeaveCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
	return 0
end

--获得纣王撤离时间
function ViewDotMsg:getZhouWangLeaveCd( )
	-- body
	if self.nKzGo and self.nKzGo > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nKzGo - (fCurTime - self.nKzGoSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
	return 0
end

--视图点是否在
function ViewDotMsg:getIsDotPosIn( nDotX, nDotY)
	if self.nType == e_type_builddot.sysCity then
		local tCityData = getWorldCityDataById(self.nSystemCityId)
		if tCityData then
			local tCoordinate = tCityData.tCoordinate
			if tCoordinate then
				if tCoordinate.x and tCoordinate.y and tCoordinate.x2 and tCoordinate.y2 then
					if tCoordinate.x <= nDotX and nDotX <= tCoordinate.x2 and
						 tCoordinate.y <= nDotY and nDotY <= tCoordinate.y2 then	 
						return true
					end
				elseif tCoordinate.x == nDotX and tCoordinate.y == nDotY then
					return true
				end
			end
		end
	elseif self.nType == e_type_builddot.zhouwang then		
		return self:isInKingZhou(nDotX, nDotY)
	else
		return self.nX == nDotX and self.nY == nDotY
	end
	return false
end

--
function ViewDotMsg:getDotKey()
	return self.sDotKey
end

function ViewDotMsg:getIsCenterCity( )
	return self.nSystemCityId == 11169
end

--写死
function ViewDotMsg:getCityImgSize( )
	if self.nSystemCityId and self.nSysCountry then
		local tCityData = getWorldCityDataById(self.nSystemCityId)
		if tCityData then
			local sImgPath = tCityData.tCityicon[self.nSysCountry]
			if sImgPath then
				local nIndex = tonumber(string.sub(sImgPath,-5,-5))
				if nIndex == 1 then
					return cc.size(181, 91)
				elseif nIndex == 2 then
					return cc.size(193, 102)
				elseif nIndex == 3 then
					if tCityData.kind == e_kind_city.zhongxing then
						return cc.size(382 + 100, 198 + 100)
					else
						return cc.size(382, 198)
					end
				end
			end
		end
	end
	return cc.size(UNIT_WIDTH, UNIT_HEIGHT)
end

--是否可以补城防
function ViewDotMsg:getIsCanFillCityDef(  )
	if self.nType == e_type_builddot.sysCity then 
		if self:getDotCountry() == Player:getPlayerInfo().nInfluence then
			return self.nCurrGarrisonTroops < self.nGarrisonTroopsMax 
		end
	end
	return false
end

--获取区域id (暂时只有限时Boss有)
function ViewDotMsg:getBlockId()
	return self.nBlockId
end

--获取多个格子 (暂时只有限时Boss有)
function ViewDotMsg:getDotKeys(  )
	return self.tDotKeys
end

--获取集结倒计时
function ViewDotMsg:getTogetherCd(  )
	if self.nTogetherCd and self.nTogetherCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nTogetherCd - (fCurTime - self.nTogetherCdSystemT)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
	return 0
end

--获取是否有集结
function ViewDotMsg:getIsTogether(  )
	return self:getTogetherCd() > 0
end

--是否是纣王试炼点
function ViewDotMsg:isInKingZhou( _nFx, _nFy )
	-- body
	if _nFx and _nFy and self.tKzps then		
		for k, v in pairs(self.tKzps) do
			if v.x == _nFx and v.y == _nFy then
				return true
			end
		end
	end
	return false
end

function ViewDotMsg:getKingZhouImgSize(  )
	-- body
	return cc.size(UNIT_WIDTH, UNIT_HEIGHT)
end

--皇城战据点是否有双方部队（有双方部队时显示特效）
function ViewDotMsg:getIsEpwBattle(  )
	return self.bEpwBattle
end

return ViewDotMsg