-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-4-2 14:51:49 星期一
-- Description: 募兵府数据
-----------------------------------------------------

local Build = require("app.layer.build.data.Build")
local RecruitRes = require("app.layer.recruitsodiers.RecruitRes")
local BRecruitData = class("BRecruitData", function()
	-- body
	return Build.new()
end)

function BRecruitData:ctor(  )
	-- body
	self:myInit()
end


function BRecruitData:myInit(  )
	self.nCpy 					= 		0 		--兵营容量
	self.nMoreQue 				= 		0 		--扩充队列数
	self.nRecruitMore 			= 		0 		--募兵加时次数
	self.nRecruitMaxTime 		= 		0 		--募兵最大时间(分钟)
	self.tRecruitTeams 			= 		{}  	--招募队列
	self.nRecruitTp 			= 		nil  	--募兵类型(1步,2骑,3弓)
end

--从服务端获取数据刷新
function BRecruitData:refreshDatasByService( tData )
	-- body
	-- dump(tData, "募兵府数据刷新 ====")
	self.nBuildId 				= 		tData.id or self.nBuildId 	      --建筑id
	self.nCellIndex 			= 		tData.loc or self.nCellIndex      --建筑格子下标（位置）
	self.nLv 					= 		tData.lv or self.nLv 		      --等级
	self.nRecruitTp 			= 		tData.tp or self.nRecruitTp       --募兵类型(1步,2骑,3弓)
	self.sDetailName 			= 		self:getDetailName()     		  --募兵府类型名字
	if self.nRecruitTp ~= nil then
		self.sName = self:getNewName()
	end

	--刷新募兵相关
	self:refreshRecruitMsg(tData)
	
	--刷新容量和队列数
	self:refreshCpyAndMoreQue(tData)
	--刷新招募队列
	if tData.recruits then
		self:refreshRecruitTeams(tData.recruits)
	end
end

--获取募兵府名字
function BRecruitData:getNewName()
	local sName = self.sName
	if self.nRecruitTp == e_mbf_camp_type.infantry then
		sName = getConvertedStr(7, 10436) --募兵府-步
	elseif self.nRecruitTp == e_mbf_camp_type.sowar then
		sName = getConvertedStr(7, 10437) --募兵府-骑
	elseif self.nRecruitTp == e_mbf_camp_type.archer then
		sName = getConvertedStr(7, 10438) --募兵府-弓
	end
	return sName
end

--获取募兵府类型名字
function BRecruitData:getDetailName()
	local sName = ""
	if self.nRecruitTp == e_mbf_camp_type.infantry then
		sName = getConvertedStr(1, 10081)..getConvertedStr(7, 10439) --步兵募兵府
	elseif self.nRecruitTp == e_mbf_camp_type.sowar then
		sName = getConvertedStr(1, 10082)..getConvertedStr(7, 10439) --骑兵募兵府
	elseif self.nRecruitTp == e_mbf_camp_type.archer then
		sName = getConvertedStr(1, 10083)..getConvertedStr(7, 10439) --弓兵募兵府
	end
	return sName
end

--刷新容量和队列数
function BRecruitData:refreshCpyAndMoreQue( tData )
	-- body
	self.nCpy 					= 		tData.cpy or self.nCpy
	self.nMoreQue 				= 		tData.qn or self.nMoreQue 		   --扩充队列数
end

--刷新募兵相关
function BRecruitData:refreshRecruitMsg( tData )
	-- body
	self.nRecruitMore 			= 		tData.rn or self.nRecruitMore 	   --募兵加时次数
	self.nRecruitMaxTime 		= 		tData.mm or self.nRecruitMaxTime   --募兵最大时间
end

--刷新招募队列
function BRecruitData:refreshRecruitTeams( tData )
	-- body
	--清除原有的数据
	if self.tRecruitTeams and table.nums(self.tRecruitTeams) > 0 then
		self.tRecruitTeams = nil
	end
	self.tRecruitTeams = {}
	if tData and table.nums(tData) > 0 then
		local bIng = false
		for k, v in pairs (tData) do
			local pRecruitTeam = RecruitRes.new()
			pRecruitTeam:refreshDatasByService(v)
			if pRecruitTeam.nType == e_camp_item.ing then --有生产中的队列
				bIng = true
			end
			table.insert(self.tRecruitTeams, pRecruitTeam)
		end
		if bIng then
			self.nState = e_build_state.producing 	        --设置当前状态为生产
		else
			self.nState = e_build_state.free 				--设置当前状态为空闲
		end
	else
		self.nState = e_build_state.free 				    --设置当前状态为空闲
	end
end

--获取当前招募队列
function BRecruitData:getRecruitTeams(  )
	-- body
	return self.tRecruitTeams
end

--获得当前募兵进行中的队列（有的话就只有一条）
function BRecruitData:getRecruitingQue(  )
	-- body
	local tQue = nil
	if self.tRecruitTeams and table.nums(self.tRecruitTeams) > 0 then
		for k, v in pairs (self.tRecruitTeams) do
			if v.nType == e_camp_item.ing then --有生产中的队列
				tQue = v
				break
			end
		end
	end
	return tQue
end

--获得当前募兵完成的队列
function BRecruitData:getRecruitedQue(  )
	-- body
	local tQue = nil
	if self.tRecruitTeams and table.nums(self.tRecruitTeams) > 0 then
		for k, v in pairs (self.tRecruitTeams) do
			if v.nType == e_camp_item.finish then --募兵完成
				tQue = v
				break
			end
		end
	end
	return tQue
end

--是否募兵已满
function BRecruitData:getIsFull()
	-- body
	--当前兵量
	local nCurCpy = 0
	if self.nRecruitTp == e_mbf_camp_type.infantry then --步兵
		nCurCpy = Player:getPlayerInfo().nInfantry
	elseif self.nRecruitTp == e_mbf_camp_type.sowar then --骑兵
		nCurCpy = Player:getPlayerInfo().nSowar
	elseif self.nRecruitTp == e_mbf_camp_type.archer then --弓兵
		nCurCpy = Player:getPlayerInfo().nArcher
	end
	--当前已有数量大于等于容量就满
	if nCurCpy >= self:getTotalCpy() then
		return true
	else
		return false
	end
end
--
function BRecruitData:getRecruitCpy( _nBuildId )
	-- body
	local nBuildId = nil
	if self.nRecruitTp == e_mbf_camp_type.infantry then
		nBuildId = e_build_ids.infantry
	elseif self.nRecruitTp == e_mbf_camp_type.sowar then
		nBuildId = e_build_ids.sowar
	elseif self.nRecruitTp == e_mbf_camp_type.archer then
		nBuildId = e_build_ids.archer
	end	
	if nBuildId and _nBuildId and nBuildId == _nBuildId then
		return self.nCpy
	else
		return 0
	end
end

function BRecruitData:getTotalCpy( )
	-- body
	local nCampCpy = 0
	local tBuildData = nil
	if self.nRecruitTp == e_mbf_camp_type.infantry then
		tBuildData = Player:getBuildData():getBuildById(e_build_ids.infantry, true)	
	elseif self.nRecruitTp == e_mbf_camp_type.sowar then
		tBuildData = Player:getBuildData():getBuildById(e_build_ids.sowar, true)		
	elseif self.nRecruitTp == e_mbf_camp_type.archer then
		tBuildData = Player:getBuildData():getBuildById(e_build_ids.archer, true)		
	end
	if tBuildData then
		nCampCpy = tBuildData.nCpy
	end
	
	return self.nCpy + nCampCpy		
end

--获得空闲的招募队列  --nType 1:获得空闲数，不管是否兵满 2：兵满时不返回
function BRecruitData:getFreeTeams( _nType)
	-- body
	local nType=_nType or 1
	local tFreeTeams = {}
	--该兵营总共可招募的队列个数
	local nAllTeamCt = self.nMoreQue + 1
	--已经在使用的队列个数
	local nUseTeamCt = table.nums(self.tRecruitTeams)
	--剩余可用队列个数
	local nLeftTeamCt = nAllTeamCt - nUseTeamCt
	--当前兵量
	local nCurCpy = 0
	if self.nRecruitTp == e_mbf_camp_type.infantry then --步兵
		nCurCpy = Player:getPlayerInfo().nInfantry
	elseif self.nRecruitTp == e_mbf_camp_type.sowar then --骑兵
		nCurCpy = Player:getPlayerInfo().nSowar
	elseif self.nRecruitTp == e_mbf_camp_type.archer then --弓兵
		nCurCpy = Player:getPlayerInfo().nArcher
	end
	--募兵基础速度
	local nSpeed = tonumber(getBuildParam("baseRecruitSpeed"))

	if nLeftTeamCt  > 0 then
		for i = 1, nLeftTeamCt do
			local pRecruitTeam = RecruitRes.new()
			--模拟后端数据
			local tT = {}
			if self:getTotalCpy() < nCurCpy and nType == 2 then			--兵力已满
				return nil
			else
				--获得当前
				if self:getTotalCpy() > nCurCpy then --兵营兵力不满的情况下
					tT.num = self.nRecruitMaxTime * nSpeed --默认满的
					tT.sd = self.nRecruitMaxTime * 60 --转化为秒
					tT.tp = 100
				else
					tT.num = 0 --默认满的
					tT.sd = 0 --转化为秒
					tT.tp = 200
				end
				-- pRecruitTeam.nCurNum = tT.num 		--当前数量(空闲队列才用到)
				pRecruitTeam.nCurNum = self:getRefreshNumByBuffPush(tT.num) --当前数量(空闲队列才用到)
				pRecruitTeam.nCurSD = tT.sd		    --当前需要时间(空闲队列才用到)
				pRecruitTeam:refreshDatasByService(tT)
				table.insert(tFreeTeams, pRecruitTeam)
			end
		end
	end
	return tFreeTeams
end

--推送BuffVo刷新空闲队列的募兵数
function BRecruitData:getRefreshNumByBuffPush(_num)
	local tBuffVos = Player:getBuffData():getCampBuffList()
	local nBuff = table.nums(tBuffVos)
	if nBuff == 0 then
		return _num
	end
	local nPreNum = _num

	if nBuff > 0 then
		for nId, tBuffVo in pairs(tBuffVos) do
			if not tBuffVo then break end
			local tBuffData = getBuffDataByIdFromDB(nId)

			local tEffects = tBuffData.tEffects
			for k, v in pairs(tEffects) do
				if self.nRecruitTp == e_mbf_camp_type.infantry then   -- 步兵
					if tonumber(v[1]) == e_build_buff.infantry then
						_num = _num + nPreNum * tonumber(v[2])
						break
					end
				elseif self.nRecruitTp == e_mbf_camp_type.sowar then  --骑兵
					if tonumber(v[1]) == e_build_buff.sowar then
						_num = _num + nPreNum * tonumber(v[2])
						break
					end
				elseif self.nRecruitTp == e_mbf_camp_type.archer then --弓兵
					if tonumber(v[1]) == e_build_buff.archer then
						_num = _num + nPreNum * tonumber(v[2])
						break
					end
				end

			end
		end
	end

	return _num
end

function BRecruitData:calBuffCurNum(_type, _num, _addPercent)
	-- body

end


--获得可扩充队列
function BRecruitData:getMoreTeam(  )
	-- body
	local tMoreTeam = {}

	--获得最大可扩充队列个数
	local nMax = getMaxCountCampTeam()
	--当前已经扩充的个数
	local nCurNum = self.nMoreQue

	if nMax > self.nMoreQue then --还可以扩充
		local pRecruitTeam = RecruitRes.new()
		--模拟后端数据
		local tT = {}
		tT.num = 0 --默认满的
		tT.sd = 0 --转化为秒
		tT.tp = 300
		pRecruitTeam:refreshDatasByService(tT)
		local tCurData = getCampTeamByQueueFromDB(self.nMoreQue)
		--获得下个队列增加数据
		local tNextData = getCampTeamByQueueFromDB(self.nMoreQue + 1)
		if tNextData then
			if tCurData then
				pRecruitTeam.nNextAddCpy = tNextData.institute*2 - tCurData.institute*2
			else
				pRecruitTeam.nNextAddCpy = tNextData.institute*2
			end
			pRecruitTeam.nCost = tonumber(tNextData.gold) or 0
		end
		table.insert(tMoreTeam, pRecruitTeam)
	end
	return tMoreTeam
end

--获取募兵府招募需要的粮草消耗量和铜钱消耗量
--_sTid:建筑id
function BRecruitData:getNeedCostFood(_curNum)
	-- body
	local nCostFood, nCostCoin = 0, 0
	local nScienceId
	--先看看有没有相关的科技buff
	if self.nRecruitTp == e_mbf_camp_type.infantry then
		nScienceId = 3007
	elseif self.nRecruitTp == e_mbf_camp_type.sowar then
		nScienceId = 3008
	elseif self.nRecruitTp == e_mbf_camp_type.archer then
		nScienceId = 3015
	end
	local tBbTech = Player:getTnolyData():getTnolyByIdFromAll(nScienceId)
	local tLvData = tBbTech:getLimitDataByLv(tBbTech.nLv)
	if tLvData then
		nCostFood = _curNum * (tonumber(getBuildParam("baseCost")) + tLvData.recruitfood)
	else
		nCostFood = _curNum * tonumber(getBuildParam("baseCost"))
	end
	nCostCoin = _curNum * tonumber(getBuildParam("recruitCoinCost"))
	return nCostFood, nCostCoin
end

return BRecruitData