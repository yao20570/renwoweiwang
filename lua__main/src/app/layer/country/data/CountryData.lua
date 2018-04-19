--Author : maheng
--Date   : 2018/04/16
--国家数据



local PoliticiansPoster = require("app.layer.country.data.PoliticiansPoster")
local CountryDataVo = require("app.layer.country.data.CountryDataVo")
local OfficialVO = require("app.layer.country.data.OfficialVO")
local CandidateVO = require("app.layer.country.data.CandidateVO")
local CountryLog = require("app.layer.country.data.CountryLog")
local CountryCityVo = require("app.layer.country.data.CountryCityVo")
--国家数据
local CountryData = class("CountryData")


function CountryData:ctor(  )
	--body
	self:myInit()
end

function CountryData:myInit(  )
	-- body
	--国家基础数据
	self.tCountryDataVo 	= 		CountryDataVo.new()	--国家基础数据
	--国家官员、官员候选人
	self.nOfficialStatus 	= 		nil --竞选状态 0：不需要官员选举 1：选举中 2.官员任职中
	self.nCampaignCD 		= 		0 --竞选倒计时/距离下次竞选倒计时(单位/秒)
	self.nLastCampaignCD 	=  		0
	self.tOfficial			= 		{} --官员列表 [非竞选中才有该字段]
	self.tCandidate 		= 		{} --候选人列表 [竞选中才有该字段] 
	self.sSupport			= 		nil --支持人名字
	self.tPoliticiansPoster = 		{} --政要海报列表 
	--荣誉任务完成情况
	self.nCityFightTime = 0
	self.nCountryFightTime = 0
	self.nCountryDevelopTime = 0
	self.nSd = 0
	self.tHonorTask = {}--getCountryHonorTask()
	--国家日志
	self.tCountryLog = {}
	--将军候选人列表
	self.tGeneralCandidate = {}
	--当前积分盒子数据
	self.tScoreBoxs = getScoreBoxsBaseData()
	--国家城池
	self.tCountryCity = nil
	--当天已召唤次数
	self.nCalledNumToday = 0
end
--刷新国家基础数据
function CountryData:refreshCountryDataByService(_data )
	-- body
	self.tCountryDataVo:refreshDataByService(_data)
end

--刷新积分盒子数据
function CountryData:refreshScoreBoxsByService( _data )
	-- body
	if _data and #_data > 0 then
		for k, v in pairs(_data) do
			if self.tScoreBoxs[v] then--已经领取盒子的状态改变
				self.tScoreBoxs[v]:updateByService(true)
			end
		end
	end
end
--刷新国家城池数据
function CountryData:refreshCountryCityByService( _data )
	-- body
	if _data.cvs then--刷新表	
		self.tCountryCity = {}	
		for k, v in pairs(_data.cvs) do
			local pcity = CountryCityVo.new()
			pcity:refreshDataByService(v)
			table.insert(self.tCountryCity, pcity)
		end
	elseif _data.cv then
		if _data.s and _data.s == 1 then--删除
			--删除城池
			self:removeCountryCityByID(_data.cv.t)
		else
			local pcity = self:getCountryCityDataByID(_data.cv.t)
			if pcity then			
				pcity:refreshDataByService(_data.cv)
			else
			 	pcity = CountryCityVo.new()
			 	pcity:refreshDataByService(_data.cv)
			 	table.insert(self.tCountryCity, pcity)	
			end	
		end		
	end
	--刷新城池红点状态
	for k, v in pairs(self.tCountryCity) do
		v:refreshRedNum()
	end
end

function CountryData:getCityRedNum(  )
	-- body
	local nNum = 0
	if self.tCountryCity and #self.tCountryCity > 0 then
		for k, v in pairs(self.tCountryCity) do
			nNum = nNum + v:getCityRedNum()
		end
	end
	return nNum
end

function CountryData:clearCountryCityRed(  )
	-- body
	if self.tCountryCity and #self.tCountryCity > 0 then
		for k, v in pairs(self.tCountryCity) do
			v:clearRedRecord()
		end
	end
	sendMsg(gud_refresh_countrycity_msg)
end
--通过城池ID获取城池数据
function CountryData:getCountryCityDataByID( _id )
	-- body	
	if not _id or not self.tCountryCity then
		return nil
	end
	local tcity = nil
	if _id then
		for k, v in pairs(self.tCountryCity) do
			if v.nID == _id then
				tcity = v
				break
			end
		end
	end
	return tcity
end
--删除国家城池数据
function CountryData:removeCountryCityByID( nId )
	-- body
	if not nId or not self.tCountryCity then
		return
	end	
	for k, v in pairs(self.tCountryCity) do
		if v.nID == nId then
			table.remove(self.tCountryCity, k)
			break
		end
	end
end
--获取国家城池数据
function CountryData:getCountryCitys(  )
	-- body
	if (not self.tCountryCity) or (#self.tCountryCity <= 0) then
		return
	end
	table.sort( self.tCountryCity, function ( a, b )
		-- body
		return a:isMineCity()
	end )
	return self.tCountryCity
end

--判断当前玩家是否是城主
--return false 当前玩家没有城池 true 当前玩家拥有城池
function CountryData:isPlayerBeCityMaster( )
	-- body
	local tcitys = self:getCountryCitys()
	if not tcitys or #tcitys <= 0 then
		return false
	end
	for k, v in pairs(tcitys) do
		if v:isMineCity() == true then
			return true
		end
	end
	return false
end
--获取下一个目标积分
function CountryData:getNextTargetScore(  )
	-- body
	local ncurScore = self:getCountryDataVo().nScore
	for k, v in pairs(self.tScoreBoxs) do
		if v.nTargetNum > ncurScore then
			return v.nTargetNum
		elseif v.nTargetNum <= ncurScore and v.bIsGetAward == false then
			return v.nTargetNum
		end
	end
	return self.tScoreBoxs[#self.tScoreBoxs].nTargetNum
end

--获取下一个目标积分盒子
function CountryData:getNextTargetScoreBox(  )
	-- body
	local ncurScore = self:getCountryDataVo().nScore
	for k, v in pairs(self.tScoreBoxs) do
		if v.nTargetNum >= ncurScore and v.bIsGetAward == false then
			return v
		end
	end
	return nil
end

--获取积分进度
function CountryData:getScoreBoxPercent(  )
	-- body
	local ncurScore = self:getCountryDataVo().nScore
	local nBoxNum = #self.tScoreBoxs --积分盒子
	local pboxscore = self:getNextTargetScoreBox()
	if not pboxscore then
		return 100
	end
	if pboxscore.nTid - 1 == 0 then
		return ncurScore/pboxscore.nTargetNum/nBoxNum*100
	else
		local ppreBox = self.tScoreBoxs[pboxscore.nTid - 1]
		return ((pboxscore.nTid - 1) + (ncurScore - ppreBox.nTargetNum)/(pboxscore.nTargetNum - ppreBox.nTargetNum))/nBoxNum*100
	end		
end

--获取当前可领奖的积分盒子
function CountryData:getCurPrizeScoreBox(  )
	-- body	
	if not self.tScoreBoxs or #self.tScoreBoxs <= 0 then
		return nil
	end	
	local ncurScore = self:getCountryDataVo().nScore
	for k, v in pairs(self.tScoreBoxs) do
		if v.nTargetNum <= ncurScore and v.bIsGetAward == false then		
			return v
		end
	end	
	return nil
end

--获取积分盒子
function CountryData:getScoreBoxDatas(  )
	-- body
	return self.tScoreBoxs
end

--获取奖励进度弹窗显示的积分盒子数据
function CountryData:getScoreBoxById(nId)
	-- body
	if not nId then
		return nil
	end
	return self.tScoreBoxs[nId]
end

--获得国家任务数据
function CountryData:getCountryTaskData(  )
	-- body
	local pTaskData = nil
	local tTaskList = self:getOpenCountryTask()
	if tTaskList and #tTaskList > 0 then
		table.sort( tTaskList, function ( a, b )
			-- body
			if a.nIsGetPrize == b.nIsGetPrize then
				if a.nIsFinished == b.nIsFinished then
					if a.nType == b.nType then
						return a.sTid < b.sTid
					else
						return a.nType < b.nType --
					end
				else
					return a.nIsFinished > b.nIsFinished --已完成的优先
				end
			else
				return a.nIsGetPrize < b.nIsGetPrize --未领奖优先
			end
		end )
		pTaskData = tTaskList[1]
	end
	return pTaskData
end

--官员/候选人列表刷新
function CountryData:refreshOfficialAndCandidate( _data )
	-- body
	self.nOfficialStatus 	= 		_data.c  or self.nOfficialStatus --竞选状态 0：不需要官员选举 1：选举中 2.官员任职中
	self.nCampaignCD		= 		_data.cd or self.nCampaignCD--竞选倒计时/距离下次竞选倒计时(单位/秒)	
	if _data.cd then
		self.nLastCampaignCD 	= 		getSystemTime()
	end
	self.sSupport			= 		_data.sn or self.sSupport --支持人名字
	--刷新官员列表
	self.tOfficial = {}
	if _data.os and #_data.os > 0 then		
		local ttable = _data.os
		for k, v in pairs(ttable) do
			local tdata = OfficialVO.new()
			tdata:refreshDataByService(v)
			table.insert(self.tOfficial, tdata)
		end
	end
	--dump(self.tOfficial, "self.tOfficial", 100)
	--刷新候选人列表
	self.tCandidate = {}
	if _data.cs and #_data.cs > 0 then
		local ttable = _data.cs 
		for k, v in pairs(ttable) do
			local tdata = CandidateVO.new()
			tdata:refreshDataByService(v)
			table.insert(self.tCandidate, tdata)
		end
	end		
	--刷新政要海报列表
	self.tPoliticiansPoster = {}
	if _data.ps and #_data.ps then
		local ttable = _data.ps
		for k, v in pairs(ttable) do
			local tdata = PoliticiansPoster.new()
			tdata:refreshDataByService(v)
			self.tPoliticiansPoster[tdata.nOfficial] = tdata
			-- table.insert(self.tPoliticiansPoster, tdata)
		end		
		-- table.sort( self.tPoliticiansPoster, function ( a, b )--票数降序排列
		-- 	-- body
		-- 	return a.nOfficial < b.nOfficial
		-- end )
	end		
	--国家官员红点
	sendMsg(ghd_country_home_menu_red_msg)		
end

function CountryData:refreshOfficialStatus( _data )
	-- body
	self.nOfficialStatus 	= 		_data.c  or self.nOfficialStatus --竞选状态 0：不需要官员选举 1：选举中 2.官员任职中
	self.nCampaignCD		= 		_data.cd or self.self.nCampaignCD--竞选倒计时/距离下次竞选倒计时(单位/秒)	
	if _data.cd then
		self.nLastCampaignCD 	= 		getSystemTime()
	end	
	--国家官员红点
	sendMsg(ghd_country_home_menu_red_msg)		
end

--刷新国家荣誉任务数据刷新
function CountryData:refreshHonorTasksByService(_data )
	-- body	
	self.nCityFightTime = _data.ca or self.nCityFightTime--Integer	城战完成次数
	self.nCountryFightTime = _data.co or self.nCountryFightTime--Integer	国战完成次数
	-- self.nCountryDevelopTime = _data.de or self.nCountryDevelopTime--Integer	开发完成次数
	self.tHonorTask = getCountryHonorTask()
	self.nSd = _data.sd or self.nSd
	for k, v in pairs(self.tHonorTask) do
		v:updateByService(_data)
	end
	--国家荣誉红点
	sendMsg(ghd_country_home_menu_red_msg)
end

--获取国家荣誉任务
function CountryData:getCountryGloryTask(  )
	-- body
	return self.tHonorTask
end

--刷新国家日志
function CountryData:loadCountryLog( _data )
	-- body
	if _data.es and #_data.es > 0 then
		self.tCountryLog = {}
		for k, v in pairs(_data.es) do
			local itemlog = CountryLog.new()
			itemlog:updateByService(v)
			table.insert(self.tCountryLog, itemlog)
		end
		table.sort( self.tCountryLog, function ( a, b )
			-- body
			return a.nTime > b.nTime
		end )	
		local cnt = getCountryParam("maxLogSize")
		local curCnt = #self.tCountryLog
		for i = cnt, curCnt do
			table.remove(self.tCountryLog, #self.tCountryLog) 
		end		
	end
end



--国家日志推送
function CountryData:updateNewCountryLog( _data )
	-- body	
	if _data.e then
		local itemlog = CountryLog.new()
		itemlog:updateByService(_data.e)
		table.insert(self.tCountryLog, itemlog)
		table.sort( self.tCountryLog, function ( a, b )
			-- body
			return a.nTime > b.nTime
		end )		
		local cnt = getCountryParam("maxLogSize")
		local curCnt = #self.tCountryLog
		for i = cnt, curCnt do
			table.remove(self.tCountryLog, #self.tCountryLog) 
		end	
	end
end 

--获取国家日志
function CountryData:getCountryLog(  )
	-- body
	return self.tCountryLog
end

--刷新将军候选人列表
function CountryData:refreshGeneralCandidate(_data)
	self.tGeneralCandidate = {}
	if _data and #_data > 0 then
		for k, v in pairs(_data) do
			local tdata = CandidateVO.new()
			tdata:refreshDataByService(v)
			table.insert(self.tGeneralCandidate, tdata)
		end
	end
end

--或促将军候选人
function CountryData:getGeneralCandidate( )
	-- body
	if self.tGeneralCandidate and #self.tGeneralCandidate > 0 then
		table.sort( self.tGeneralCandidate, function (a, b  )--官员id升序排列
				-- body
			return a.nSword > b.nSword			
		end)		
	end
	return self.tGeneralCandidate
end

function CountryData:getCountryDataVo(  )
	-- body
	return self.tCountryDataVo
end
--读取竞选CD时间
function CountryData:getLeftCampaignTime(  )
	-- body
	local ncurtime = getSystemTime()
	local nlefttime = self.nCampaignCD - (ncurtime - self.nLastCampaignCD)
	if nlefttime < 0 then
		nlefttime = 0
	end
	return nlefttime
end

--获取当前竞选状态
function CountryData:getCurOfficialStatus(  )
	-- body
	local nstatus = self.nOfficialStatus
	return nstatus
end
--获取当前官员列表
function CountryData:getOfficialsData(  )	
	-- body
	local tOfficial = {}
	if self.tOfficial and #self.tOfficial > 0 then
		for k, v in pairs(self.tOfficial) do
			table.insert(tOfficial, v)
		end
		table.sort( tOfficial, function (a, b  )--官员id升序排列
				-- body
				if a.nOfficial == b.nOfficial then
					return a.nSword > b.nSword
				else
					return a.nOfficial < b.nOfficial
				end			
		end)		
	end
	return tOfficial
end

--获取将军列表
function CountryData:getGeneralsData(  )
	-- body
	local tGenerals = {}
	for k, v in pairs(self.tOfficial) do
		if v.nOfficial == e_official_ids.general then
			table.insert(tGenerals, v)
		end
	end
	table.sort( tGenerals, function (a, b  )--官员id升序排列
			-- body
			if a.nOfficial == b.nOfficial then
				return a.nSword > b.nSword
			else
				return a.nOfficial < b.nOfficial
			end			
	end)	
	return tGenerals
end

--获取是否有官职
function CountryData:getIsHasOfficial( )
	local tVo = self:getCountryDataVo()
	if tVo then
		if tVo.nOfficial and tVo.nOfficial ~= 0 then
			return true
		end
	end
	return false
end

--获取当前官员候选人列表
function CountryData:getCandidateData(  )
	-- body
	if self.tCandidate and #self.tCandidate > 0 then
		table.sort( self.tCandidate, function ( a, b )--票数降序排列
			-- body
			if a.nVotes == b.nVotes  then
				return a.nSword > b.nSword
			else
				return a.nVotes > b.nVotes	
			end			
		end )
	end
	return self.tCandidate
end

function CountryData:refreshSupportInfo( nCandidateID )
	-- body
	local pCandidate = self:getCandidateByID(nCandidateID)
	if pCandidate then
		self.sSupport = pCandidate.sName or self.sSupport
	end	
end

--根据ID获取当前候选人
function CountryData:getCandidateByID( _id )
	-- body
	if not _id then
		return nil
	end
	for k, v in pairs(self.tCandidate) do
		if v.nID == _id then
			return v
		end
	end	
end

--根据ID获取官员
function CountryData:getOfficialByID( _id )
	-- body
	if not _id or (not self.tOfficial or #self.tOfficial <= 0) then
		return nil
	end
	for k, v in pairs(self.tOfficial) do
		if v.nID == _id then
			return v
		end
	end	
end

function CountryData:pushrefreshName( tData )
	-- body
	if not tData then
		return
	end
	local pCandidate = self:getCandidateByID(tData.a)
	if pCandidate then
		pCandidate:refreshDataByService(tData)
	end
	local pOfficial = self:getOfficialByID(tData.a)
	if pOfficial then
		pOfficial:refreshDataByService(tData)
	end
end

--候选人票数刷新
function CountryData:updateCandidateByService( _data )
	-- body
	if not _data then
		return
	end
	local pCandidate = self:getCandidateByID(_data.a)
	if pCandidate then
		pCandidate:refreshDataByService(_data)
	end	
end

--获取官员海报
function CountryData:getPoliticiansPoster( )
	-- body
	return self.tPoliticiansPoster
end

--官员更新
function CountryData:updateOfficialByService( _data )
	-- body
	if _data and _data.c then
		if _data.c == 0 then--被罢免
			for k, v in pairs(self.tOfficial) do
				if v.nID == _data.a then
					table.remove(self.tOfficial, k)
					break
				end
			end
		elseif _data.c == 1 then--被任命
			local tdata = OfficialVO.new()
			tdata:refreshDataByService(_data.o)
			table.insert(self.tOfficial, tdata)
			for k, v in pairs(self.tGeneralCandidate) do
				if v.nID == tdata.nID then
					table.remove(self.tGeneralCandidate, k)					
				end
			end
		end
	end
end

--今天可以召唤次数
function CountryData:setCalledNumToday( tData )
	if not tData then
		return
	end
	self.nCalledNumToday = tData
end
 
function CountryData:getCalledNumToday(  )
	return self.nCalledNumToday
end

--获取国家官员红点
function CountryData:getOfficialRedNum(  )
	-- body
	local nRedNum = 0
	if self.nOfficialStatus and self.nOfficialStatus == 1 and self.tCountryDataVo and self.tCountryDataVo.nT <= 0 then
		nRedNum = 1
	end	
	return nRedNum
end

--国家荣誉红点
function CountryData:getCountryHonorRedNum( )
	-- body
	local nRedNum = 0
	for k, v in pairs(self.tHonorTask) do
		if v:isShowRed() == true then
			nRedNum = nRedNum + 1
		end
	end
	return nRedNum
end

--国家膜拜红点
function CountryData:getMobaiRedNum( )
	-- body
	local nRedNum = 0
	if self:getCountryDataVo():isHadWorship() == false and self:getCountryDataVo().tKingVo then
		nRedNum = 1
	end
	return nRedNum
end

--国家爵位红点
function CountryData:getNobilityRedNum( )
	-- body
	local nRedNum = 0
	local tCountryDatavo = self:getCountryDataVo()
	local tbanneret = getCountryBanneret()
	local bIsEnough = true	
	if tbanneret and tbanneret[tCountryDatavo.nNobility] then	
		local data = tbanneret[tCountryDatavo.nNobility]
		if data.cost then			
			local tcost = luaSplit(data.cost, ";")	
			for i = 1, 5 do
				if tcost[i] then
					local ttmp = luaSplit(tcost[i], ":")
					local resid = tonumber(ttmp[1])
					local num = tonumber(ttmp[2])
					local myCnt = getMyGoodsCnt(resid)
					if num > myCnt then
						bIsEnough = false
						break
					end
				end
			end
		else		
			bIsEnough = false
		end
	end
	if bIsEnough == true then
		nRedNum = 1
	end
	return nRedNum
end

--国家开发红点
function CountryData:getDevelopRedNum( )
	-- body
	local nRedNum = 0
	local tCountryDatavo = self:getCountryDataVo()
	local tdevelop = getCountryDevelop()
	if tCountryDatavo.nExploit < table.nums(tdevelop) then
		local tCost = luaSplitMuilt(tdevelop[tCountryDatavo.nExploit + 1].cost, ";", ":")	
		--local bIsEnough = true	
		local bISFree = true
		for k, v in pairs(tCost) do
			local nResID = tonumber(v[1]) or 0
			local nNum = tonumber(v[2]) or 0
			--local nMyCnt = getMyGoodsCnt(nResID)
			if nNum > 0 then
				bISFree = false
			end
			-- if nMyCnt < nNum then
			-- 	bIsEnough = false
			-- 	break
			-- end
		end
		if bISFree == true then
			nRedNum = 1
		end
		-- if bIsEnough == true then
		-- 	nRedNum = 1
		-- end
	end
	return nRedNum
end

function CountryData:getCountryHelpRedNum()
	local nRedNum = 0
	local tData = Player:getCountryHelpData()
	if tData and tData:haveHelps() then
		nRedNum = 1
	end
	return nRedNum
end

function CountryData:getCountryTaskRedNum()
	local nRedNum = 0
	local pData = Player:getCountryTaskData()
	if pData then
		nRedNum = pData:getCountryTaskRed()
	end
	return nRedNum
end

--国家入口红点
function CountryData:getCounrtyMenuRedNum(  )
	-- body
	local pTreasureData = Player:getCountryTreasureData()
	local pTnolyData = Player:getCountryTnoly()
	local nRedNum = 0
	local nopenlv = tonumber(getCountryParam("openLv")) --国家未开放不显示红点	
	if Player:getPlayerInfo().nLv >= nopenlv then
		nRedNum = self:getOfficialRedNum() 
		+ self:getCountryHonorRedNum() 
		-- + self:getMobaiRedNum() 
		+ self:getNobilityRedNum() 
		+ self:getCountryHelpRedNum()
		+ self:getCountryTaskRedNum()
		-- + self:getDevelopRedNum()
		+ pTreasureData:getRedNum()
		+ pTnolyData:getRedNum()
	end		
	return nRedNum
end

function CountryData:getShortFightData(  )
	-- body
	if self:getIsHasOfficial() then
		return self:getCountryDataVo():getShortFightCnt()
	else
		return nil
	end
end

function CountryData:refreshPoster( _tData )
	-- body
	if not _tData then
		return
	end
	if not self.tPoliticiansPoster then
		return
	end
	local pPoster = self:getPosterByOfficial(_tData.j)
	if not pPoster then
		pPoster = PoliticiansPoster.new()
		pPoster:refreshDataByService(_tData)
		table.insert(self.tPoliticiansPoster, pPoster)
	else
		pPoster:refreshDataByService(_tData)
	end	
	table.sort( self.tPoliticiansPoster, function ( a, b )--票数降序排列
		-- body
		return a.nOfficial < b.nOfficial
	end )
end

function CountryData:getPosterByOfficial( _nOfficial )
	-- body	
	if not _nOfficial then
		return nil
	end	
	if self.tPoliticiansPoster then
		for k, v in pairs(self.tPoliticiansPoster) do
			if v.nOfficial == _nOfficial then
				return v
			end
		end
	end
	return nil
end

function CountryData:release(  )

end
return CountryData