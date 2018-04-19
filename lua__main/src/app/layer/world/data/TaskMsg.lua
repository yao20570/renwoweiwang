local TaskMsg = class("TaskMsg")
--任务类
function TaskMsg:ctor( tData )
	self.nTargetLv = 0
	self.nCdMax = 1
	self.nCreateTime = 0
	self:update(tData)
end

function TaskMsg:update( tData )
	if not tData then
		return
	end
	--加速判断定前置条件
	local nPrevState = self.nState
	local nPrevCd = self:getCd()

	--赋值
	self.nType = tData.t or self.nType --Byte	任务类型 1:采集 2:攻打乱军 3:城战 4:国战 5:驻防
	self.sUuid = tData.u or self.sUuid --String	任务UUID
	self.sTargetName = tData.tn or self.sTargetName --String 目标名字
	self.nTargetLv   = tData.lv or self.nTargetLv -- Integer 目标等级
	self.nTargetX = tData.tx or self.nTargetX --Integer	目标X
	self.nTargetY = tData.ty or self.nTargetY --Integer	目标X
	self.nState = tData.s or self.nState --Integer	当前状态 1:前往状态 2:采集状态 3:攻击状态 4:返回状态 5:待战状态 6:驻防状态
	self.nCdMax = tData.tcd or self.nCdMax
	self.nCreateTime = tData.ct or self.nCreateTime --Integer 任务创建时间，用于任务列表排序
	if tData.cd then
		self.nCd = tData.cd --Integer	状态结束倒计时/秒(前往,返回,待战,驻防)
		self.nCdSystemTime = getSystemTime()

		--加速判断定
		if nPrevState == self.nState and math.abs(nPrevCd -self:getCd()) > 1 then
			self:setIsQuick(true)
		end
	end

	if tData.a then --String	出征军队信息 pos1:id1;pos2:id2
		self.tArmyInTask = {} --快捷查找任务字典
		self.tArmy = {} --顺序的队伍
		local tArmy = luaSplit(tData.a,",")
		for i=1,#tArmy do
			local nId = tonumber(tArmy[i])
			if nId then
				self.tArmyInTask[nId] = true
				table.insert(self.tArmy, nId)
			end
		end
	end

	self.bIsBot = tData.bot == 1	--Integer	是否突围任务0:不是 1:是
	self.nBoX = tData.boX or self.nBoX --	Integer	突围起点X
	self.nBoY = tData.boY or self.nBoY --	Integer	突围起点Y
	if self.nType == e_type_task.imperwar then
		local tSysCityData = getWorldCityDataByPos(self.nTargetX, self.nTargetY)
		if tSysCityData then
			self.sBotCityName = tSysCityData.name
			self.nBotCityId = tSysCityData.id
		end
	end
end

function TaskMsg:getIsBot( ) --是不是突围任务
	return self.bIsBot
end

function TaskMsg:getIsBotAnGo( )
	return self.bIsBot and self.nState == e_type_task_state.go
end

function TaskMsg:getBoX( )
	return self.nBoX
end

function TaskMsg:getBoY( )
	return self.nBoY
end

function TaskMsg:getBoName( )
	return self.sBotCityName or ""
end

function TaskMsg:getBoCityId( )
	return self.nBotCityId
end

function TaskMsg:getCd( )
	if self.nCd and self.nCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd - (fCurTime - self.nCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

function TaskMsg:getCdMax()
	return self.nCdMax
end

function TaskMsg:getIsQuick(  )
	return self.bIsQuick or false
end

function TaskMsg:setIsQuick( bIsQuick )
	self.bIsQuick = bIsQuick
end

function TaskMsg:getArmyNums(  )
	if self.tArmy then
		return #self.tArmy
	end
	return 0
end

--获取武将所属对伍
function TaskMsg:getArmyTeam( )
	if self.tArmy then
		for i=1,#self.tArmy do
			local nHeroId = self.tArmy[i]
			local tHero = Player:getHeroInfo():getHero(nHeroId)
			if tHero then
				if tHero.nP > 0 then
					return e_hero_team_type.normal
				elseif tHero.nCp > 0 then
					return e_hero_team_type.collect
				elseif tHero.nDp > 0 then
					return e_hero_team_type.walldef
				end
			end
		end
	end
	return e_hero_team_type.normal
end

return TaskMsg