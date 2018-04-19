----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-08 15:25:00
-- Description: 限时Boss
-----------------------------------------------------
e_tlboss_time = {
	no = 0,--活动未开始
	ready = 1, --活动准备中
	begin = 2, --活动已开始
}

e_tlboss_award = {
	no = 0,--不可领取
	get = 1, --可以领取
	got = 2, --已领取
}

--限时Boss数据类
local TLBossData = class("TLBossData")
local PointVO = require("app.layer.tlboss.data.PointVO")
local BossRankVo = require("app.layer.tlboss.data.BossRankVo")
local BossStageVo = require("app.layer.tlboss.data.BossStageVo")
local BossLocatVo = require("app.layer.tlboss.data.BossLocatVo")
local BossLineVo = require("app.layer.tlboss.data.BossLineVo")



function TLBossData:ctor(  )
	self.nTimeState = e_tlboss_time.no
	self.nMyHarm = 0
	self.tHarmRankList = {}
	self.tHitNumRankList = {}
	self.nMyHarmRank = 0
	self.nMyHitNumRank = 0
	self.nMyHitNum = 0
	self.tBLocatVos = {}
	self.tNewBossDict = {}
	self.tBossLineVoDict = {}
	self.nArmyAddPer = 0 --兵种加乘系数
	self.tArmyAddPer = {} --兵种加乘表
	self.bShowedFinger = false --是否打开过相关的Ui界面
end

function TLBossData:release(  )
end

function TLBossData:refreshDataByService( _data, _bIsLoad)
	if not _data then
		return
	end
	local nTimeStatePrev = self.nTimeState
	self.nTimeState = _data.st or self.nTimeState --	Long	boss活动时间状态 0活动未开始 1活动准备中 2活动已开始
	--是否这一次是否转化为no
	if nTimeStatePrev and self.nTimeState ~= nTimeStatePrev and self.nTimeState == e_tlboss_time.no then
		--重置行军线路
		_data.lines = {}
		--重置打开Ui bool值
		self:setIsShowedFinger(false)
	end

	self.nCd = _data.cd or self.nCd --	Long	boss活动时间倒计时间 (st=1开始倒计时)(st=2准备倒计时)(st=3剩余倒时间)
	if _data.cd then
		self.nCdSystemTime = getSystemTime()
	end
	if _data.bs then --	BossStageVo	boss阶段数据
		if self.tBossStageVo then
			self.tBossStageVo:update(_data.bs)
		else
			self.tBossStageVo = BossStageVo.new(_data.bs)
		end
	end
	if self.tBossStageVo then
		self.tBossStageVo:setTimeState(self.nTimeState)
	end
	
	-- if _data.p then	--PointVO	boss所在的地图点(只供界面跳转使用)
	-- 	if self.tPointVo then
	-- 		self.tPointVo:update(_data.p)
	-- 	else
	-- 	 	self.tPointVo = PointVO.new(_data.p)
	-- 	 end
	-- end
	if _data.ls then --boss所在的地图点(只供界面跳转使用)
		local tPrevData = self.tBLocatVos
		self.tBLocatVos = {}
		for i=1,#_data.ls do
			local nBlockId = _data.ls[i].b
			self.tBLocatVos[nBlockId] = BossLocatVo.new(_data.ls[i])
		end
		--位置标志新的
		if not _bIsLoad then
			for nBlockId,v in pairs(self.tBLocatVos) do
				if tPrevData[nBlockId] then
					if tPrevData[nBlockId]:getX() ~= v:getX() or tPrevData[nBlockId]:getY() ~= v:getY() then
						self:setIsNewTLBoss(nBlockId, true)
					end
				else
					self:setIsNewTLBoss(nBlockId, true)
				end
			end
			self.nTLBossNewTime = getSystemTime()
		end
		sendMsg(gud_tlboss_world_pos_refersh)
	end

	self.nMyHarm = _data.h or self.nMyHarm	--Long	我攻击boss的伤害
	self.nMyHitNum =  _data.f or self.nMyHitNum --	Integer	我攻击boss的次数
	--rkh	List<BossRankVo>	伤害排行榜数据
	if _data.rkh then
		self.tHarmRankList = {}
		for i=1,#_data.rkh do
			table.insert(self.tHarmRankList, BossRankVo.new(_data.rkh[i]))
		end
	end
	--rkf	List<BossRankVo>	攻击排行榜数据
	if _data.rkf then
		self.tHitNumRankList = {}
		for i=1,#_data.rkf do
			table.insert(self.tHitNumRankList, BossRankVo.new(_data.rkf[i]))
		end
	end
	self.nMyHarmRank = _data.hr or self.nMyHarmRank --	Integer	我的伤害排行名次
	-- ht	Integer	伤害排行领取状态(0不能领取 1可以领取 2已经领取)
	self.nMyHitNumRank = _data.fr or self.nMyHitNumRank	--Integer	我的攻击排行名次
	-- ft	Integer	攻击排行领取状态(0不能领取 1可以领取 2已经领取)
	-- kt	Integer	击杀奖励领取状态 (0不能领取 1可以领取 2已经领取)
	-- o	List<Pair<Integer,Long>>	获得东西
	-- fight	RpFight	攻击boss返回战报数据
	-- storm	List<List<Pair<Integer,Long>>>	强击boss返回获得物品

	if _data.fCd then --Long	攻击bossCD时间
		self.nAttackCd = _data.fCd
		self.nAttackCdSystemTime = getSystemTime()
		sendMsg(ghd_tlboss_attack_cd)
	end

	if _data.sCd then --Long	强击bossCD时间
		self.nSAttackCd = _data.sCd
		self.nSAttackCdSystemTime = getSystemTime()
		sendMsg(ghd_tlboss_sattack_cd)
	end

	if _data.dt then --Long 死亡倒计时
		self.nDeathCd = _data.dt
		self.nDeathCdSystemTime = getSystemTime()
	end

	self.sLastName = _data.lan --String 最后一击玩家名字

	local bIsLineChange = false
	if _data.lines then --boss 行军路线
		self.tBossLineVoDict = {}
		for i=1, #_data.lines do
			local tBossLineVo = BossLineVo.new(_data.lines[i])
			self:addTLBossLine(tBossLineVo)
		end
		bIsLineChange = true
	end

	if _data.al then --新增boss 行军
		local tBossLineVo = BossLineVo.new(_data.al)
		self:addTLBossLine(tBossLineVo)
		bIsLineChange = true
	end

	if _data.rl then --删除boss 行军
		local tBossLineVo = BossLineVo.new(_data.rl)
		self:delTLBossLine(tBossLineVo)
		bIsLineChange = true
	end

	if bIsLineChange then
		sendMsg(ghd_tlboss_line_change)
	end

	if _data.ar then
		self.nArmyAddPer = _data.ar --兵种加乘系数
	end

	if _data.at then
		self.tArmyAddPer = _data.at --兵种加乘
	end

	if _data.comeCd then --下次降临来临时间
		self.nComeCd = _data.comeCd
		self.nComeCdSystemTime = getSystemTime()
	end

	if _data.fightCd then --下次挑战Cd时间
		self.nFightCd = _data.fightCd
		self.nFightCdSystemTime = getSystemTime()
	end

	self.nTh = _data.th or self.nTh --	Integer	领取伤害排行奖励 0不可领取 1可以领取 2已经领取
	self.nTf = _data.tf or self.nTf --	Integer	领取次数排行奖励 0不可领取 1可以领取 2已经领取
	self.nTk = _data.tk or self.nTk --	Integer	领取最终击杀奖励 0不可领取 1可以领取 2已经领取

	self.nLastCountry = _data.lac --最终击杀国家

	--红点模板B刷新
	local bIsHasRed = false
	if self:getTh() == e_tlboss_award.get or self:getTf() == e_tlboss_award.get or self:getTk() == e_tlboss_award.get then
		bIsHasRed = true
	end
	if self.bIsHasRed ~= bIsHasRed then
		self.bIsHasRed = bIsHasRed
		sendMsg(gud_refresh_activity)
	end

	--数据刷新
	sendMsg(gud_tlboss_data_refresh)
end

--领取伤害排行奖励
function TLBossData:getTh(  )
	return self.nTh
end

--领取次数排行奖励
function TLBossData:getTf(  )
	return self.nTf
end

--领取最终击杀奖励
function TLBossData:getTk(  )
	return self.nTk
end

function TLBossData:getArmyAddPer( )
	return self.nArmyAddPer
end

function TLBossData:getArmyAddPerList( )
	return self.tArmyAddPer
end

function TLBossData:getCd( )
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

function TLBossData:getComeCd( )
    if self.nComeCd and self.nComeCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nComeCd - (fCurTime - self.nComeCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

function TLBossData:getFightCd( )
    if self.nFightCd and self.nFightCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nFightCd - (fCurTime - self.nFightCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

function TLBossData:getCdState( )
	return self.nTimeState
end

-- function TLBossData:getBossPos( )
-- 	return self.tPointVo
-- end

function TLBossData:getBLocatVos()
	return self.tBLocatVos
end

function TLBossData:getBLocatVo( nBlockId)
	if self.tBLocatVos then
		return self.tBLocatVos[nBlockId]
	end
	return nil
end

function TLBossData:getHarmRankList( )
	return self.tHarmRankList
end

function TLBossData:getHitNumRankList( )
	return self.tHitNumRankList
end

function TLBossData:getMyHarmRank( )
	return self.nMyHarmRank
end

function TLBossData:getMyHitNumRank(  )
	return self.nMyHitNumRank
end

function TLBossData:getMyHarm( )
	return self.nMyHarm
end

function TLBossData:getMyHitNum( )
	return self.nMyHitNum
end

function TLBossData:getAttackCd( )
    if self.nAttackCd and self.nAttackCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nAttackCd - (fCurTime - self.nAttackCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

function TLBossData:getSAttackCd( )
    if self.nSAttackCd and self.nSAttackCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nSAttackCd - (fCurTime - self.nSAttackCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

function TLBossData:getDeathCd( )
    if self.nDeathCd and self.nDeathCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nDeathCd - (fCurTime - self.nDeathCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end


function TLBossData:getBossStageVo(  )
	return self.tBossStageVo
end

--设置播放标记特点
function TLBossData:setIsNewTLBoss( nBlockId, bIsNew)
	self.tNewBossDict[nBlockId] = bIsNew
end

--获取是否新的Boss
function TLBossData:getIsNewTLBoss( nBlockId )
	if self.tNewBossDict[nBlockId] then
		--一定时间为true
		if self.nTLBossNewTime and getSystemTime() - self.nTLBossNewTime > 2 then
			return false
		end
		return true
	end
	return false
end

--显示世界上的限时Boss（是否离场）
function TLBossData:getIsShowWorldTLBoss( )
	local nTLBossTime = self:getCdState()
	if nTLBossTime == e_tlboss_time.no and self:getDeathCd() <= 0 then
		return false
	end
	return true	
end

--世界上的限时Boss(是否死亡)
function TLBossData:getIsTLBossDeath(  )
	local nTLBossTime = self:getCdState()
	return nTLBossTime == e_tlboss_time.no
end

--获取最后一击的名字
function TLBossData:getLastName()
	return self.sLastName
end

--获取最后一击的国家
function TLBossData:getLastCountry( )
	return self.nLastCountry
end

--获取BossLineVo字典
function TLBossData:getTLBossLines( nBlockId )
	return self.tBossLineVoDict[nBlockId]
end

--添加BossLineVo(增加里面的多条或一条)
function TLBossData:addTLBossLine( tBossLineVo )
	if not tBossLineVo then
		return
	end
	local nBlockId = tBossLineVo:getBlockId()
	if self.tBossLineVoDict[nBlockId] then
		local tPoints = tBossLineVo:getPoints()
		for k,tPointVo in pairs(tPoints) do
			self.tBossLineVoDict[nBlockId]:addPoint(tPointVo)
		end
	else
		self.tBossLineVoDict[nBlockId] = tBossLineVo
	end
end

--删除BossLineVo(删除里面的多条或一条)
function TLBossData:delTLBossLine( tBossLineVo )
	if not tBossLineVo then
		return
	end
	local nBlockId = tBossLineVo:getBlockId()
	if self.tBossLineVoDict[nBlockId] then
		local tPoints = tBossLineVo:getPoints()
		for k,tPointVo in pairs(tPoints) do
			self.tBossLineVoDict[nBlockId]:delPoint(tPointVo)
		end
	end
end

--获取是否存在线路点
function TLBossData:getIsTLBossPoint( nBlockId, sDotKey )
	if self.nTimeState == e_tlboss_time.no then
		return false
	end
	
	local tBLineVo = self:getTLBossLines(nBlockId)
	if tBLineVo then
		local tPointDict = tBLineVo:getPoints()
		if tPointDict[sDotKey] then
			return true
		end
	end
	return false
end

--开战期间是否打开过BossUI框
function TLBossData:getIsShowedFinger(  )
	if self.nTimeState == e_tlboss_time.begin then
		return self.bShowedFinger
	end
	return true
end

--记录开战期间找开BossUI框
function TLBossData:setIsShowedFinger( bIsShowed )
	self.bShowedFinger = bIsShowed
	sendMsg(ghd_show_tlboss_finger)
end


return TLBossData