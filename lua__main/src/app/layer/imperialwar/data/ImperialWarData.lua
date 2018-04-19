----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-15 14:22:00
-- Description: 皇城战数据
-----------------------------------------------------
local Replay = require("app.layer.imperialwar.data.Replay")
local MyHeroShow = require("app.layer.imperialwar.data.MyHeroShow")
local EpangLineVo = require("app.layer.imperialwar.data.EpangLineVo")

--皇城战数据
local ImperialWarData = class("ImperialWarData")


function ImperialWarData:ctor(  )
	self.tFights = {} --战况
	self.tLines = {}
	self.nCloseEnterCd = 0
end

function ImperialWarData:release(  )
end

function ImperialWarData:setImperWarFights( tData )
	if not tData then
		return
	end
	self.tFights = {}
	for i=1,#tData do
		local tReplay = Replay.new(tData[i])
		table.insert(self.tFights, 1, tReplay)
	end
end

--nTab :e_imperwar_tab 全服，国家，个人
function ImperialWarData:getImperWarFights( nTab )
	if nTab == e_imperwar_tab.server then
		return self.tFights or {}
	end

	local tList = {}
	local nInfluence = Player:getPlayerInfo().nInfluence
	local sMyName = Player:getPlayerInfo().sName
	for i=1,#self.tFights do
		local tFight = self.tFights[i]
		if nTab == e_imperwar_tab.country then
			if tFight:getAtk():getCountry() == nInfluence or
				tFight:getDef():getCountry() == nInfluence then
				table.insert(tList, tFight)
			end
		elseif nTab == e_imperwar_tab.mine then
			if tFight:getAtk():getName() == sMyName or
				tFight:getDef():getName() == sMyName then
				table.insert(tList, tFight)
			end
		end
	end
	return tList
end

function ImperialWarData:addImperWarFight( tFight )
	if not tFight then
		return
	end
	table.insert(self.tFights, 1, tFight)
end

-------------------------------当前数据
function ImperialWarData:setCurrImperWarData( nSysCityId, tImperialWarVo)
	self.tCurrData = {nSysCityId = nSysCityId, tImperialWarVo = tImperialWarVo}
end

function ImperialWarData:getCurrImperWarData( )
	return self.tCurrData
end

function ImperialWarData:getCurrImperialWarVo()
	local tData = self:getCurrImperWarData()
	if not tData then
		return
	end
	return tData.tImperialWarVo
end

function ImperialWarData:getCurrImperialWarId( )
	local tData = self:getCurrImperWarData()
	if not tData then
		return
	end
	return tData.nSysCityId
end

-------------------------------当前数据


--当前开关
function ImperialWarData:setImperWarOpen( tData )
	if not tData then
		return
	end
	self.nOpenState = tData.s
	if tData.cd then
		self.nChangeCd = tData.cd
		self.nChangeCdSystemT = getSystemTime()
	end
	--  tc 距离当天活动结束时间/秒，没有时为nil
	self.nCloseEnterCd = tData.tc or 0
	self.nCloseEnterCdSystemT = getSystemTime()

	if not self:getImperWarIsOpen() then
		self.tLines = {} --清空所有线
	end
end

--获取开启活动状态
function ImperialWarData:getImperWarIsOpen( )
	return self.nOpenState == 1
end

--获取开启活动cd时间
function ImperialWarData:getOpenCd()
	-- if self:getImperWarIsOpen() then
	-- 	return 0
	-- end
	if self.nChangeCd and self.nChangeCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nChangeCd - (fCurTime - self.nChangeCdSystemT)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

--获取关闭入口倒计时
function ImperialWarData:getCloseEnterCd(  )
	if self.nCloseEnterCd and self.nCloseEnterCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nCloseEnterCd - (fCurTime - self.nCloseEnterCdSystemT)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    else
        return 0
    end
end

--设置当前积分
function ImperialWarData:setMyWarScore( nMyScore )
	self.nMyScore = nMyScore
end

--获取当前积分
function ImperialWarData:getMyWarScore(  )
	return self.nMyScore or 0
end

--设置当前
function ImperialWarData:setCountryWarScore( nCountryScore )
	self.nCountryScore = nCountryScore
end

--获取当前
function ImperialWarData:getCountryWarScore(  )
	return self.nCountryScore or 0
end

-------------------------------------------------可领取奖励
function ImperialWarData:setEpwAwards( tData )
	if not tData then
		return
	end
	self.nAwardRank = tData.rs	--Integer	排行奖励状态 0不可领取 1可以领取 2已经领取
	self.nAwardStage = tData.ss	--Integer	阶段奖励 0不可领取 1 可以领取 2已经领取
	sendMsg(ghd_refresh_epw_award_state)
end

function ImperialWarData:setRankAward( nAwardRank )
	self.nAwardRank = nAwardRank
	sendMsg(ghd_refresh_epw_award_state)
end

function ImperialWarData:setStageAward( nAwardStage )
	self.nAwardStage = nAwardStage
	sendMsg(ghd_refresh_epw_award_state)
end

function ImperialWarData:getIsStageAward(  )
	return self.nAwardStage == e_epwaward_state.get
end

function ImperialWarData:getIsRankAward(  )
	return self.nAwardRank == e_epwaward_state.get
end


-------------------------------------------------线路
function ImperialWarData:setLines( tData )
	self.tLines = {}
	self:addLines(tData)
end

function ImperialWarData:getLines(  )
	return self.tLines
end

function ImperialWarData:addLines( tData )
	if tData then
		for i=1,#tData do
			local tEpangLineVo = EpangLineVo.new(tData[i])
			self.tLines[tEpangLineVo:getId()] = tEpangLineVo
		end
	end
end

function ImperialWarData:delLines( tData )
	if tData then
		for i=1,#tData do
			local nId = tData[i].uuid
			self.tLines[nId] = nil
		end
	end
end

function ImperialWarData:getIsInLine( nId )
	if self:getImperWarIsOpen() then
		return self.tLines[nId] ~= nil
	end
	return false
end

return ImperialWarData