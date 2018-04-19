local ImperialWarVo = class("ImperialWarVo")

function ImperialWarVo:ctor( tData )
    self.nHoldFire = tonumber(getEpangWarInitData("holdFire"))
	self.tAckTrps = {}
	self.nDefTrps = 0
	self.tEffectsDict = {}
	self.tBuysDict = {}
	self.nTrp = 0
	self.nTot = 0
	self:update(tData)
end

function ImperialWarVo:update( tData )
	if not tData then
		return
	end
	-- if tData.actCD then --  Long    距离开启活动的倒计时/秒数
	-- 	self.nActCd = tData.actCD
	-- 	self.nActCdSystemTime = getSystemTime()
	-- end
	if tData.ocT then -- Long    已占领秒数
		self.nOccTime = tData.ocT
		self.nOccSystemTime = getSystemTime()
	end
    if tData.fcd then --Long    备战倒计时
    	self.nPrepareCd = tData.fcd
    	self.nPrepareSystemT = getSystemTime()
    end
    self.nFireLay = tData.fire  or self.nFireLay --  Integer 当前建筑的火攻层数
    self.tAckTrps = tData.ackTrps or self.tAckTrps -- List<Pair<Integer,Long>>    进攻方兵力
    if self.tAckTrps then
        for i=#self.tAckTrps,1,-1 do
            if self.tAckTrps[i].v <= 0 then
                table.remove(self.tAckTrps, i)
            end
        end
    end
    
    self.nDefTrps = tData.defTrps or self.nDefTrps -- Long    防守方兵力
    if tData.effects then --List<Integer>   生效中的战术
    	self.tEffectsDict = {}
    	for i=1,#tData.effects do
    		local nId = tData.effects[i]
    		self.tEffectsDict[nId] = true
    	end
    end
    if tData.buys then --List<Pair<Integer,Integer>> 战术的已购买次数 k:战术ID V:已购买次数
    	self.tBuysDict = {}
    	for i=1,#tData.buys do
    		local k = tData.buys[i].k
    		local v = tData.buys[i].v
    		self.tBuysDict[k] = v
    	end
    end
   	self.nTrp = tData.trpP or self.nTrp --    Float   兵力百分比
    if tData.srCD then --    Long    突围CD
    	self.nSrCd = tData.srCD
    	self.nSrCdSystemTime = getSystemTime()
    end
    if tData.toCD then --Long    集结倒计时
    	self.nToCd = tData.toCD
    	self.nToCdSystemTime = getSystemTime()
    end
    self.nTot = tData.tot or self.nTot -- Integer 已使用集结次数
    if tData.fbcd then --   Long    火攻购买倒计时
    	self.nFireCd = tData.fbcd
    	self.nFireCdSystemTime = getSystemTime()
    end
    if tData.prcd then --   Long    祈雨购买倒计时
    	self.nPRainCd = tData.prcd
    	self.nPRainCdSystemTime = getSystemTime()
    end
    self.nCityId = tData.cid or self.nCityId --战报城池id
    self.bIsCanBroke = tData.isb == 1 --是否可以突破，在备战期不行的话就是人数不足

    self.bIsFight = tData.isf == 1 --打斗特效中，0没有发生战斗
    if self.bIsFight then
        sendMsg(ghd_imperialwar_show_fight)
    end
end

-- --距离开启活动的倒计时
-- function ImperialWarVo:getActionCd()
-- 	if self.nActCd and self.nActCd > 0 then
--         local fCurTime = getSystemTime()
--         local fLeft = self.nActCd - (fCurTime - self.nActCdSystemTime)
--         if(fLeft < 0) then
--             fLeft = 0
--         end
--         return fLeft
--     else
--         return 0
--     end
-- end
function ImperialWarVo:getCityId(  )
    return self.nCityId
end

--已占领秒数
function ImperialWarVo:getOccupyTime(  )
	if self.nOccTime then
		local fCurTime = getSystemTime()
		return self.nOccTime +  fCurTime - self.nOccSystemTime
	end
	return 0
end

-- 是否正在准备期间：等待进攻
function ImperialWarVo:getIsWaitAtk(  )
    return self.nPrepareCd == 0
end

-- 是否有攻击队伍
function ImperialWarVo:getIsNoAtk(  )
    return #self.tAckTrps == 0
end

-- 备战倒计时
function ImperialWarVo:getPrepareCd(  )
	if self.nPrepareCd and self.nPrepareCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nPrepareCd - (fCurTime - self.nPrepareSystemT)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

-- 获取火攻层数
function ImperialWarVo:getFireLay(  )
	return self.nFireLay
end

--进攻方兵力列表
function ImperialWarVo:getAckTrps(  )
	return self.tAckTrps
end

--防守兵力
function ImperialWarVo:getDefTrps(  )
	return self.nDefTrps
end

--是否生效
function ImperialWarVo:getTechIsEffect( nId )
	return self.tEffectsDict[nId]
end

--获取已购买次数
function ImperialWarVo:getTechBuyed( nId )
	return self.tBuysDict[nId] or 0
end

--获取兵力百分比
function ImperialWarVo:getTrp(  )
    --保留小数点1位向下取整
    local nRes = math.floor(self.nTrp * 1000)/10
	return nRes
end

--突围CD
function ImperialWarVo:getSrCd(  )
	if self.nSrCd and self.nSrCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nSrCd - (fCurTime - self.nSrCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

--集结倒计时
function ImperialWarVo:getToCd(  )
	if self.nToCd and self.nToCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nToCd - (fCurTime - self.nToCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

--火攻cd倒计时
function ImperialWarVo:getFireCd(  )
	if self.nFireCd and self.nFireCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nFireCd - (fCurTime - self.nFireCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

--祈雨cd倒计时
function ImperialWarVo:getPRainCd( )
	if self.nPRainCd and self.nPRainCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nPRainCd - (fCurTime - self.nPRainCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

--获取是否可以突破
function ImperialWarVo:getIsCanBroke(  )
    return self.bIsCanBroke
end

--是否允许外出操作 进行撤退或突破
function ImperialWarVo:getIsCanOutCtrl(  )
    if self:getIsWaitAtk() or self:getPrepareCd() > self.nHoldFire then
        return true
    end
    return false
end

function ImperialWarVo:getIsFight(  )
    return self.bIsFight
end

return ImperialWarVo