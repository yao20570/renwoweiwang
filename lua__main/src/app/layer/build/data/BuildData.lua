-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-21 10:03:31 星期五
-- Description: 角色建筑的所有数据
-----------------------------------------------------
local Build = require("app.layer.build.data.Build")
local BPalaceData = require("app.layer.build.data.BPalaceData")
local BAtelierData = require("app.layer.build.data.BAtelierData")
local BCampData = require("app.layer.build.data.BCampData")
local BGateData = require("app.layer.build.data.BGateData")
local BStoreData = require("app.layer.build.data.BStoreData")
local BTnolyData = require("app.layer.build.data.BTnolyData")
local BChiefData = require("app.layer.build.data.BChiefData")
local BSuburb = require("app.layer.build.data.BSuburb")
local BRecruitData = require("app.layer.build.data.BRecruitData")

SUBBUILD_MINID = 1001 -- 郊外矿点的起始id
SUBBUILD_TOTAL_COUNT = 64 -- 郊外矿点的总个数

local BuildData = class("BuildData")

function BuildData:ctor(  )
	self:myInit()
end

function BuildData:myInit(  )
	-- body
	self.fBuyTeamLeftTime 				= 			nil 			    --（long）购买建筑升级队列失效时间
	self.fBuyTeamLastLoadTime 			= 			nil 				--（long）购买建筑升级队列最后失效时间
	self.nBuyTeamCt 					= 			0 					--（int）购买建筑升级队列次数
	self.nAutoUpTimes 					= 			0 			    	--（int）自动升级队列次数
	self.bAutoUpOpen 					= 			false 			    --（boolean）是否开启自动建造
	self.nAutoRecruit					= 			0 					-- (int) 自动招募城墙守卫次数
	self.nHadSecondQue 					= 			0 				     -- (int)是否拥有第二条建筑队列 0:未开启 1：开启

	self.tBuildUpdingLists 				= 			nil 			    --（table）建筑升级队列

	self.tAllBuilds 					= 			nil 				--（table）所有的建筑信息(城内)
	self.tSuburbBuilds 					= 			nil 				--（table）郊外资源田	
	--初始化所有的建筑
	self:initAllBuilds()
	self.fCollectCd 					= 			0 					--征收累计倒计时
	self.nColState 						= 			0 					--征收状态  0：不可征收  1：可征收 2：满征收

	self.nAbt = 0   	-- Integer	自动建造的方式 0默认功能建筑 1资源建筑优先 2自定义
	self.nLp  = 0		-- Integer	是否开启低等级优先自动升级 0为开启,1为不开启
	self.tUdp = {} 	-- List<Pair<Integer,Integer>>	自定义优先级 k-id,v-优先级	
	self.tNbi = {}

	self.nPw =	0 		--今天打包木头的次数
	self.nPc =	0 		--今天打包银币的次数
	self.nPf =	0 		--今天打包粮食的次数
	self.nRecruitState 					=	0 		--募兵府是否解锁, 1解锁,0未解锁
end

-- 根据服务端信息调整数据
-- nType：1：表示主动请求   2：表示后端推送
function BuildData:refreshDatasByService( tData, nType )
	-- dump(tData,"建筑数据=",100)
	--刷新购买的建造队列数据
	self:refreshBuildBuyLeftTime(tData)
	self.nAutoUpTimes 					= tData.atm or self.nAutoUpTimes     --自动升级队列次数
	self.nAutoRecruit 					= tData.arm or self.nAutoRecruit     --自动招募城墙守卫次数
	self.nHadSecondQue 				    = tData.ob or  self.nHadSecondQue	 --是否拥有第二条队列	
	self.nRecruitState 				    = tData.orc or  self.nRecruitState	 --募兵府是否解锁, 1解锁,0未解锁
	if tData.openAuto ~= nil then
		self.bAutoUpOpen 				= tData.openAuto 					 --是否开启自动建造
	end	
	--主动请求数据的时候 在数据刷新之前先重置建筑的状态
	if nType == 1 then
		self:resetBuildStatus()
	end

	--王宫数据初始化或者刷新
	self:refreshBuildDatas(tData.palace,e_build_ids.palace)
	--步兵营数据初始化或者刷新
	self:refreshBuildDatas(tData.infantry,e_build_ids.infantry)
	--骑兵营数据初始化或者刷新
	self:refreshBuildDatas(tData.sowar,e_build_ids.sowar)
	--弓兵营数据初始化或者刷新
	self:refreshBuildDatas(tData.archer,e_build_ids.archer)
	--仓库数据初始化或者刷新
	self:refreshBuildDatas(tData.store,e_build_ids.store)
	--科技院数据初始化或者刷新
	self:refreshBuildDatas(tData.tnoly,e_build_ids.tnoly)
	--作坊数据初始化或者刷新
	self:refreshBuildDatas(tData.atelier,e_build_ids.atelier)
	--城门数据初始化或者刷新
	self:refreshBuildDatas(tData.gate,e_build_ids.gate)
	--统帅府数据初始化或者刷新
	self:refreshBuildDatas(tData.drillGround,e_build_ids.tcf)
	--募兵府数据初始化或者刷新
	self:refreshBuildDatas(tData.recruting,e_build_ids.mbf)

	--郊外建筑初始化或者刷新
	self:refreshBuildSuburb(tData.rbuild,nType, true)
	--郊外未激活建筑	
	self:refreshBuildSuburb(tData.unActB,2, false)

	--建筑升级队列
	self:refreshBuildUpdingLists(tData.bqqs,nType)

	--主动请求(nType == 1)的时候需要初始化不可升级建筑的数据
	if nType == 1 then
		--刷新不可升级的建筑（是否解锁）
		self:refreshUnUpingBuilds(tData.ub)
	end
	self:refreshCollectCd(tData)
	self:refreshAutoBuildData(tData.abu, nType)--自动建造数据
	-- dump(self.tAllBuilds, "self.tAllBuilds", 100)

	--刷新资源打包次数
	if tData.pw or tData.pc or tData.pf then
		self:refreshResPackData(tData)
	end
end

--刷新资源打包次数
function BuildData:refreshResPackData(_tData)
	self.nPw = _tData.pw or self.nPw 			--今天打包木头的次数
	self.nPc = _tData.pc or self.nPc 			--今天打包银币的次数
	self.nPf = _tData.pf or self.nPf 			--今天打包粮食的次数
	sendMsg(gud_refresh_res_pack)
end

--获取今日资源打包的次数(木头、银币、粮食)
function BuildData:getResPackTimes()
	return self.nPw, self.nPc, self.nPf
end

function BuildData:refreshCollectCd(_tData)
	-- body
	self.fCollectCd 			= 		_tData.cul or self.fCollectCd  --征收累计倒计时

	if _tData.cul and _tData.cul > 0 then
		self.fLastLoadTime 		= 		getSystemTime() 			  --最后加载的时间	
	end

	--刷新资源田征收状态
	self:refreshSuburbColState()

end

--刷新资源田征收状态
function BuildData:refreshSuburbColState()
	-- body
	local nEveryTime = self:getResCollectTime()
	--获得满征收的时间
	local nMaxTime = self:getResCollectTimeMax()
	if self:getCollectLeftTime() > nEveryTime then
		self.nColState = 1
		if self:getCollectLeftTime() >= nMaxTime then --满征收
			self.nColState = 2
		end
	else
		self.nColState = 0
	end
end

--获得资源田征收状态
function BuildData:getColState()
	-- body
	return self.nColState
end

--设置资源田征收状态
function BuildData:setColState( _nState )
	-- body
	self.nColState = _nState
end

--获得征收累计时间
function BuildData:getCollectLeftTime( )
	-- body
	if self.fCollectCd and self.fCollectCd > 0 then
		-- 单位是秒
		local fCurTime = getSystemTime()
		-- 总共累计多少秒
		local fLeft = self.fCollectCd + (fCurTime - self.fLastLoadTime or 0)
		return fLeft
	else
		return 0
	end
end

--刷新数据（背包接口推送刷新）
function BuildData:refreshDataByBagPush( tData )
	--dump(tData, "tData", 100)
	-- body
	self.nAutoUpTimes 					= tData.atm or self.nAutoUpTimes     --自动升级队列次数
	self.nAutoRecruit 					= tData.arm or self.nAutoRecruit 	--自动招募城墙守卫次数
	--发送自动建造管理数据刷新消息
	sendMsg(ghd_auto_build_mgr_msg)
end

--初始化所有的建筑
function BuildData:initAllBuilds(  )
	-- body
	if not self.tAllBuilds then
		self.tAllBuilds = {}
		--不初始化城内建筑
		local tNoBuildDict = {
			[e_build_ids.house] = true,
			[e_build_ids.wood] = true,
			[e_build_ids.farm] = true,
			[e_build_ids.iron] = true,
			[e_build_ids.shop] = true,
			[e_build_ids.jbp] = true,
			-- [e_build_ids.mbf] = true,
			[e_build_ids.jxg] = true,
		}
		--城内的建筑默认显示
		local tAllBuilds = getAllBuildsFromDB()
		for k,tDBData in pairs(tAllBuilds) do
			local _nBuildId = tDBData.id
			if _nBuildId and not tNoBuildDict[_nBuildId] then
				local pBuildData = nil
				if _nBuildId == e_build_ids.palace then --王宫
					pBuildData = BPalaceData.new()
				elseif _nBuildId == e_build_ids.store then --仓库
					pBuildData = BStoreData.new()
				elseif _nBuildId == e_build_ids.tnoly then --科学院
					pBuildData = BTnolyData.new()
				elseif _nBuildId == e_build_ids.infantry
					or _nBuildId == e_build_ids.sowar
					or _nBuildId == e_build_ids.archer then --步兵营，骑兵营，弓兵营
					pBuildData = BCampData.new()
				elseif _nBuildId == e_build_ids.gate then --城门
					pBuildData = BGateData.new()
				elseif _nBuildId == e_build_ids.atelier then --作坊
					pBuildData = BAtelierData.new()
				elseif _nBuildId == e_build_ids.tcf then --统帅府
					pBuildData = BChiefData.new()
				elseif _nBuildId == e_build_ids.mbf then --募兵府
					pBuildData = BRecruitData.new()				
				else
					pBuildData = Build.new()
				end
				pBuildData:initDatasByDB(tDBData)
				pBuildData.bLocked = true --设置上锁
				self.tAllBuilds[_nBuildId] = pBuildData
			end
		end
	end	
end

--刷新建筑数据
--_tSerDatas：服务端数据
--_nBuildId：建筑id
function BuildData:refreshBuildDatas( _tSerDatas, _nBuildId )
	-- body
	if _tSerDatas and _nBuildId then
		local pBuildData = self.tAllBuilds[_nBuildId]
		if not pBuildData then --不存在数据，从配表中查询
			local tDBData = getBuildDatasByTid(_nBuildId)
			if tDBData then
				if _nBuildId == e_build_ids.palace then --王宫
					pBuildData = BPalaceData.new()
				elseif _nBuildId == e_build_ids.store then --仓库
					pBuildData = BStoreData.new()
				elseif _nBuildId == e_build_ids.tnoly then --科学院
					pBuildData = BTnolyData.new()
				elseif _nBuildId == e_build_ids.infantry
					or _nBuildId == e_build_ids.sowar
					or _nBuildId == e_build_ids.archer then --步兵营，骑兵营，弓兵营
					pBuildData = BCampData.new()
				elseif _nBuildId == e_build_ids.gate then --城门
					pBuildData = BGateData.new()
				elseif _nBuildId == e_build_ids.atelier then --作坊
					pBuildData = BAtelierData.new()
				elseif _nBuildId == e_build_ids.tcf then --统帅府
					pBuildData = BChiefData.new()
				elseif _nBuildId == e_build_ids.mbf then --募兵府
					pBuildData = BRecruitData.new()				
				end
				pBuildData:initDatasByDB(tDBData)
				self.tAllBuilds[tDBData.id] = pBuildData
			end
		end
		if pBuildData then
			pBuildData:refreshDatasByService(_tSerDatas)
			--之前没有解锁，现在解锁，需要发消息推送
			local bLocked = pBuildData.bLocked
			if bLocked ~= false then
				pBuildData.bLocked = false
				sendMsg(ghd_build_group_unlock_msg, _nBuildId)
			end
		end
	end
	if not _tSerDatas and _nBuildId == e_build_ids.mbf then  --募兵府特殊处理一下(判断有没有解锁建筑)
		local pBuildData = self.tAllBuilds[_nBuildId]
		local bLocked = pBuildData.bLocked
		if bLocked ~= false then
			pBuildData.bLocked = self.nRecruitState == 0
			if pBuildData.bLocked == false then --之前没有解锁，现在解锁，需要发消息推送
				sendMsg(ghd_build_group_unlock_msg, _nBuildId)
			end
		end
	end
end

--刷新解锁建筑
--_tSerDatas：服务端数据
--_nBuildId：建筑id
--_nCell：格子id
--_nType：解锁途径：1玩家等级解锁 2王宫等级解锁 3主线任务解锁 4副本解锁
--_orc:募兵府是否解锁
function BuildData:refreshBuildDatasForUnlocked( _tSerDatas, _nBuildId, _nCell, _nType, _orc )
	-- body
	if _tSerDatas then
		self:refreshBuildDatas(_tSerDatas, _nBuildId)
		--添加解锁数据
		addShowUnLockedBuild({self:getBuildByCell(_nCell)}, _nType)

		--如果是解锁城门，需要刷新主界面左边对联
		if _nCell == e_build_cell.gate then
			--发送消息刷新对联
			local tObj = {}
			tObj.nType = 2
			sendMsg(ghd_refresh_homeitem_msg, tObj)
		end
	else
		if _orc then
			if self.nRecruitState == 0 then
				self.nRecruitState = _orc
				if self.nRecruitState == 1 then
					self:refreshBuildDatas(_tSerDatas, _nBuildId)
					--添加解锁数据
					addShowUnLockedBuild({self:getBuildByCell(_nCell)}, _nType)
				end
			end
		end
	end
end

--刷新郊外建筑
-- tData：注意：这里的tData是一个lists
-- nType：1：表示主动请求   2：表示后端推送  
-- bAct: true 已经激活 false 未激活
function BuildData:refreshBuildSuburb( tData, nType , bAct)
	-- body
	-- tData = nil
	-- tData = {}
	-- for i = 1, 64 do
	-- 	local t = {}
	-- 	t.cul = 0
	-- 	if i <= 16 then
	-- 		t.id = e_build_ids.house
	-- 	elseif i <= 32 then
	-- 		t.id = e_build_ids.wood
	-- 	elseif i <= 48 then
	-- 		t.id = e_build_ids.farm
	-- 	elseif i <= 64 then
	-- 		t.id = e_build_ids.iron
	-- 	end
	-- 	t.lv = i
	-- 	t.loc = 1000 + i
	-- 	table.insert(tData, t)
	-- end	
	if tData then
		if nType == 1 then
			if self.tSuburbBuilds and table.nums(self.tSuburbBuilds) > 0 then
				self.tSuburbBuilds = nil
			end
			self.tSuburbBuilds = {}
			for k, v in pairs (tData) do
				local pBuildDBData = getBuildDataByIdFromDB(v.id)
				if pBuildDBData then
					local pSuburb = BSuburb.new()
					--先初始化数据库数据
					pSuburb:initDatasByDB(pBuildDBData)
					--重置服务器数据
					pSuburb:refreshDatasByService(v, bAct)
					--添加到列表中
					self.tSuburbBuilds[v.loc] = pSuburb
				end
			end
		elseif nType == 2 then
			if not self.tSuburbBuilds then
				self.tSuburbBuilds = {}
			end
			for k, v in pairs (tData) do
				local pSuburb = self:getSuburbByCell(v.loc)
				if not pSuburb then
					local pBuildDBData = getBuildDataByIdFromDB(v.id)
					if pBuildDBData then
						pSuburb = BSuburb.new()
						--先初始化数据库数据
						pSuburb:initDatasByDB(pBuildDBData)
						--添加到列表中
						self.tSuburbBuilds[v.loc] = pSuburb
					end
				end
				if pSuburb then
					pSuburb:refreshDatasByService(v, bAct)
				end
			end
		end
	end
end

--开启资源田
--_nType：解锁途径：1玩家等级解锁 2王宫等级解锁 3主线任务解锁 4副本解锁
-- bAct: true 已经激活 false 未激活
function BuildData:addSuburbBuild( tData, _nType, bAct )
	-- body
	if tData and table.nums(tData) > 0 then
		local tT = {}
		for k, v in pairs (tData) do
			local pSuburb = self:getSuburbByCell(v.loc)
			if not pSuburb then
				local pBuildDBData = getBuildDataByIdFromDB(v.id)
				if pBuildDBData then
					pSuburb = BSuburb.new()
					--先初始化数据库数据
					pSuburb:initDatasByDB(pBuildDBData)
					--添加到列表中
					if not self.tSuburbBuilds then
						self.tSuburbBuilds = {}
					end
					self.tSuburbBuilds[v.loc] = pSuburb
				end
			end
			if pSuburb then
				pSuburb:refreshDatasByService(v, bAct)
				table.insert(tT, pSuburb)
			end
		end
		--添加解锁数据
		addShowUnLockedBuild(tT,_nType)
		
		sendMsg(ghd_unlock_one_collect_all)
		
	end
end

--获得所有的建筑
function BuildData:getAllBuilds( )
	-- body
	return self.tAllBuilds
end

--通过id获取建筑
--_includeLocked: 是否包含已锁住的建筑, 默认不包含
function BuildData:getBuildById( _nId, _includeLocked )
	-- body
	if not _nId then
		return
	end
	if _includeLocked then
		return self.tAllBuilds[_nId]
	end
	if self.tAllBuilds[_nId] then
		if self.tAllBuilds[_nId]:getIsLocked() then
			return nil
		end
	end
	return self.tAllBuilds[_nId]
end

--通过格子下标获得建筑
function BuildData:getBuildByCell( _nCell )
	-- body
	if not _nCell then
		return
	end
	local pBuild = nil
	if self.tAllBuilds and table.nums(self.tAllBuilds) > 0 then
		for k, v in pairs (self.tAllBuilds) do
			if v.nCellIndex == _nCell then
				pBuild = v
				break
			end
		end
	end
	return pBuild
end

--获得郊外资源田建筑列表
function BuildData:getSuburbBuilds( )
	-- body
	return self.tSuburbBuilds
end

--通过id获取郊外资源建筑
function BuildData:getSuburbById( _nId )
	-- body
	if not _nId then
		return
	end
	local pBuild = nil
	if self.tSuburbBuilds and table.nums(self.tSuburbBuilds) > 0 then
		for k, v in pairs (self.tSuburbBuilds) do
			if v.sTid == _nId then
				pBuild = v
				break
			end
		end
	end
	return pBuild
end

--通过id获取已拥有的该郊外资源建筑
function BuildData:getSuburbOpenedById(_nId)
	if not _nId then
		return
	end
	local pBuild = {}
	if self.tSuburbBuilds and table.nums(self.tSuburbBuilds) > 0 then
		for k, v in pairs (self.tSuburbBuilds) do
			if v.sTid == _nId and v.bActivated and v.bLocked == false then
				table.insert(pBuild, v)
			end
		end
	end
	return pBuild
end
-- _nResId 建筑ID
function BuildData:getSuburbNumById( _nResId )
	-- body
	local nNum = 0
	if not _nResId then
		return nNum
	end
	local nBuildId = e_build_ids.house
	if _nResId == e_type_resdata.wood then
		nBuildId = e_build_ids.wood
	elseif _nResId == e_type_resdata.food then
		nBuildId = e_build_ids.farm
	elseif _nResId == e_type_resdata.iron then
		nBuildId = e_build_ids.iron
	elseif _nResId == e_type_resdata.coin then
		nBuildId = e_build_ids.house
	end
	local pBuild = {}
	if self.tSuburbBuilds and table.nums(self.tSuburbBuilds) > 0 then
		for k, v in pairs (self.tSuburbBuilds) do
			if v.sTid == nBuildId and v.bActivated and v.bLocked == false then
				table.insert(pBuild, v)
			end
		end
	end
	nNum = #pBuild
	return nNum
end

--通过格子下标获得郊外资源建筑
function BuildData:getSuburbByCell( _nCell )
	-- body
	if not _nCell then
		return
	end
	if self.tSuburbBuilds and table.nums(self.tSuburbBuilds) > 0 then
		return self.tSuburbBuilds[_nCell]
	end
	
end

--获得正在升级的队伍
function BuildData:getBuildUpdingLists( )
	-- body
	return self.tBuildUpdingLists
end

--通过建筑id从升级队伍中获得对应建筑
function BuildData:getUpingBuildById( _nId )
	-- body
	if not _nId then
		return
	end
	local pBuild = nil
	if self.tBuildUpdingLists and table.nums(self.tBuildUpdingLists) > 0 then
		for k, v in pairs (self.tBuildUpdingLists) do
			if v.sTid == _nId then
				pBuild = v
				break
			end
		end
	end
	return pBuild
end

--通过格子下标从升级队伍中获得对应建筑
function BuildData:getUpingBuildByCell( _nCell )
	-- body
	if not _nCell then
		return
	end
	local pBuild = nil
	if self.tBuildUpdingLists and table.nums(self.tBuildUpdingLists) > 0 then
		for k, v in pairs (self.tBuildUpdingLists) do
			if v.nCellIndex == _nCell then
				pBuild = v
				break
			end
		end
	end
	return pBuild
end

--升级队列数据刷新
-- tData：注意：这里的tData是一个lists
-- nType：1：表示主动请求   2：表示后端推送  3：新增一个升级中的建筑
function BuildData:refreshBuildUpdingLists( tData, nType )
	-- body
	-- dump(tData, "升级队列数据刷新", 100)
	if tData then
		if nType == 1 then
			-- local tBuildUpdingListsPrev = self.tBuildUpdingLists
			if self.tBuildUpdingLists and table.nums(self.tBuildUpdingLists) > 0 then
				self.tBuildUpdingLists = nil
			end
			self.tBuildUpdingLists = {}
			-- local tCdList = {}
			for k, v in pairs (tData) do
				if v.cd > 0 then
					local pBuild = nil
					if v.loc > n_start_suburb_cell then
						pBuild = self:getSuburbByCell(v.loc)
					else
						pBuild = self:getBuildByCell(v.loc)
					end
					-- tCdList[v.loc] = v.loc
					if pBuild then
						pBuild:refreshUpingDatas(v)
						table.insert(self.tBuildUpdingLists, pBuild)
						--通知基地建筑状态发生变化
						local tObject2 = {}
						tObject2.nCell = pBuild.nCellIndex
						sendMsg(gud_build_state_change_msg,tObject2)
					end
				end
			end

			-- if tBuildUpdingListsPrev then
			-- 	for k, pBuildData in pairs(tBuildUpdingListsPrev) do
			-- 		local nPrevCdLoc = tCdList[pBuildData.nCellIndex]
			-- 		if not nPrevCdLoc then
			-- 			pBuildData:setUpingCd(0)
			-- 			pBuildData:setBuildState(e_build_state.free)
			-- 		end
			-- 	end
			-- end
		elseif nType == 2 or nType == 3 then
			if not self.tBuildUpdingLists then
				self.tBuildUpdingLists = {}
			end
			for k, v in pairs (tData) do
				local pBuild = self:getUpingBuildByCell(v.loc)
				if not pBuild then
					if v.loc > n_start_suburb_cell then
						pBuild = self:getSuburbByCell(v.loc)
					else
						pBuild = self:getBuildByCell(v.loc)
					end
					if pBuild then
						table.insert(self.tBuildUpdingLists, pBuild)
					end
				end
				if pBuild then
					pBuild:refreshUpingDatas(v)
					--通知基地建筑状态发生变化
					local tObject2 = {}
					tObject2.nCell = pBuild.nCellIndex
					tObject2.nBuildId = v.id
					tObject2.nType = nType
					sendMsg(gud_build_state_change_msg,tObject2)
				end
			end
		end
	end
	--新手教程
	Player:getNewGuideMgr():checkIsShowUnloakGuide()
end

--新增一个建筑中的建筑
--nType：1.正常升级 2.立即完成
function BuildData:addBuildUpding( tData, nType )
	-- body
	if tData then
		if nType == 1 then
			self:refreshBuildUpdingLists(tData,3)
		elseif nType == 2 then
			for k, v in pairs (tData) do
				local pBuild = nil
				if v.loc > n_start_suburb_cell then
					pBuild = self:getSuburbByCell(v.loc)
				else
					pBuild = self:getBuildByCell(v.loc)
				end
				if pBuild then
					pBuild:refreshUpingDatas(v)
				end
			end
			--新手教程
			Player:getNewGuideMgr():checkIsShowUnloakGuide()
		end
	end
end

--新增一个操作到建筑中队列
function BuildData:actionForBuild( tData )
	-- body
	if tData then
		self:refreshBuildUpdingLists(tData,3)
	end
end

--移除一个建筑
--_nCell：格子下标 
--_nBuildId：建筑id
function BuildData:removeOneBuild( _nCell, _nBuildId )
	-- body
	if not _nCell or not _nBuildId then return end
	--从升级队列中移除
	if self.tBuildUpdingLists and table.nums(self.tBuildUpdingLists) > 0 then
		local nSize = table.nums(self.tBuildUpdingLists)
		for i = nSize, 1, -1 do 
			local pTemp = self.tBuildUpdingLists[i]
			if(pTemp and pTemp.nCellIndex == _nCell ) then
				table.remove(self.tBuildUpdingLists, i)
			end
		end
	end
	--发送消息通知界面移除建筑（消失）
	local tObject = {}
	tObject.nCell = _nCell
	sendMsg(ghd_remove_one_buildgroup_msg,tObject)
end

--移除一个正在升级的建筑数据
function BuildData:removeBuildUpding( tData )
	-- body
	if tData then
		local pBuild = self:getUpingBuildByCell(tData.loc)
		if not pBuild then
			if tData.loc > n_start_suburb_cell then
				pBuild = self:getSuburbByCell(tData.loc)
			else
				pBuild = self:getBuildByCell(tData.loc)
			end
		end
		if pBuild then
			--刷新数据
			pBuild:refreshUpingDatas(tData)
			--新手教程
			Player:getNewGuideMgr():checkIsShowUnloakGuide()
			if tData.recruting then
				pBuild:refreshDatasByService(tData.recruting)
			end
			pBuild:refreshDatasByService(tData)
		end
		--从升级队列中移除
		if self.tBuildUpdingLists and table.nums(self.tBuildUpdingLists) > 0 then
			local nSize = table.nums(self.tBuildUpdingLists)
			for i = nSize, 1, -1 do 
				local pTemp = self.tBuildUpdingLists[i]
				if(pTemp and pTemp.nCellIndex == tData.loc ) then
					table.remove(self.tBuildUpdingLists, i)
				end
			end
		end
	end
end

--刷新购买建筑队列剩余时间
function BuildData:refreshBuildBuyLeftTime( tData )
	-- body
	self.nBuyTeamCt 					= tData.m or self.nBuyTeamCt 		 --购买升级队列次数
	self.fBuyTeamLeftTime 				= tData.bqt or self.fBuyTeamLeftTime --购买建筑升级失效时间
	if tData.bqt then
		self.fBuyTeamLastLoadTime 		= getSystemTime() 					 --最后加载购买建筑升级失效时间
	end
	--通知基地建筑数据发生变化
	local tObject = {}
	tObject.nType = 1
	sendMsg(gud_build_data_refresh_msg,tObject)
end

-- 获取购买的建筑队列剩下时间
-- return(int):返回剩余时长
function BuildData:getBuildBuyFinalLeftTime(  )
	-- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	local fLeft = self.fBuyTeamLeftTime - (fCurTime - self.fBuyTeamLastLoadTime)
	if(fLeft < 0) then
		fLeft = 0
	end
	return fLeft
end

--根据类型（普通建造，黄金建造）获取建筑队列的状态
--_nType：1.默认队列 2.购买队列
--return： nState：0：空闲 1：建造中
-- 		   pCurBuild：当前类型的建造队列
function BuildData:getBuildingQueStateByType( _nType )
	-- body
	if not _nType then return end
	local nState = 0
	local pCurBuild = nil 
	local tUpingLists = self:getBuildUpdingLists() --当前正在升级的建造队列
	if tUpingLists and table.nums(tUpingLists) > 0 then
		for k, v in pairs (tUpingLists) do
			if _nType == v.nUpingType then --普通
				pCurBuild = v
				nState = 1
				break
			elseif _nType == v.nUpingType then --黄金
				pCurBuild = v
				nState = 1
				break
			end
		end
	end
	return nState, pCurBuild
end

--获取建筑队列状态
--return nState：0：有空闲队列 1：有可购买的建造队列 -1：没有空闲的建造队列
--       pFirstBuild：最快完成的建筑
function BuildData:getBuildingQueState(  )
	-- body
	local nState = 0
	local pFirstBuild = nil

	local nCurBuildQue = 0
	local tUpingLists = self:getBuildUpdingLists()
	if tUpingLists then
		nCurBuildQue = table.nums(tUpingLists)
	end
	--获得玩家可已拥有的建造队列数
	local nCanBuildQue = tonumber(getBuildParam("buildQueue"))
	if nCanBuildQue > nCurBuildQue then                  --有空闲的建造队列
		nState = 0
	elseif nCanBuildQue < nCurBuildQue then 	 		 --没有空闲队列
		nState = -1
		for k, v in pairs (tUpingLists) do
			if not pFirstBuild then
				pFirstBuild = v
			else
				if v:getBuildingFinalLeftTime() < pFirstBuild:getBuildingFinalLeftTime() then
					pFirstBuild = v
				end
			end
		end
	else 												 --有一条空闲队列
		--判断是否已经开启第二条建造队列
		local nHad = Player:getBuildData().nHadSecondQue
		if nHad == 0 then --未开启
			if nCurBuildQue == 0 then --当前没有建造队列
				nState = 0
			else
				nState = -1
				for k, v in pairs (tUpingLists) do
					if not pFirstBuild then
						pFirstBuild = v
					else
						if v:getBuildingFinalLeftTime() < pFirstBuild:getBuildingFinalLeftTime() then
							pFirstBuild = v
						end
					end
				end
			end
		else
			if self:getBuildBuyFinalLeftTime() <= 0 then   --有可购买的建造队列
				--（需要判断是黄金还是普通队列）
				for k, v in pairs (tUpingLists) do
					if not pFirstBuild then
						pFirstBuild = v
					else
						if v:getBuildingFinalLeftTime() < pFirstBuild:getBuildingFinalLeftTime() then
							pFirstBuild = v
						end
					end
				end
				local bPutong = true
				if pFirstBuild then --存在建筑队列
					if pFirstBuild.nUpingType == 2 then
						bPutong = false
					end
				end
				if bPutong then
					nState = 1
				else
					nState = 0
				end
			else 											 --购买的建造队列生效中
				nState = 0 										
			end
		end
	end
	return nState, pFirstBuild
end

--获取正在升级中的需要时间最短的建筑
function BuildData:getShortestUpingBuild()
	-- body
	local tUpingLists = self:getBuildUpdingLists()
	local nCurBuildQue = 0
	if tUpingLists then
		nCurBuildQue = table.nums(tUpingLists)
	end
	if nCurBuildQue > 0 then
		for i = nCurBuildQue, 1, -1 do
			if tUpingLists[i].nState ~= e_build_state.uping then
				table.remove(tUpingLists, i)
			end 
		end
		if table.nums(tUpingLists) > 0 then
			table.sort(tUpingLists, function(a, b)
				-- body
				return a:getBuildingFinalLeftTime() < b:getBuildingFinalLeftTime()
			end)
			return tUpingLists[1]
		end
	end
end

--获取兵营正在募兵中队列需要时间最短的兵营
function BuildData:getShortestCampBuild()
	local tCampingList = {}
	--步兵营
	local pInfantryData = self:getBuildById(e_build_ids.infantry)
	if pInfantryData then
		--正在募兵队列
		local tInfantryIng = pInfantryData:getRecruitingQue()
		if tInfantryIng then
			table.insert(tCampingList, pInfantryData)
		end
	end
	--骑兵营
	local pSowarData = self:getBuildById(e_build_ids.sowar)
	if pSowarData then
		local tSowarIng = pSowarData:getRecruitingQue()
		if tSowarIng then
			table.insert(tCampingList, pSowarData)
		end
	end
	--弓兵营
	local pArcherData = self:getBuildById(e_build_ids.archer)
	if pArcherData then
		local tArcherIng = pArcherData:getRecruitingQue()
		if tArcherIng then
			table.insert(tCampingList, pArcherData)
		end
	end
	--募兵府
	local pRecruitHouse = self:getBuildById(e_build_ids.mbf)
	if pRecruitHouse then
		local tIng = pRecruitHouse:getRecruitingQue()
		if tIng then
			table.insert(tCampingList, pRecruitHouse)
		end
	end
	-- dump(tCampingList, "tCampingList == ")
	--按招募剩余时间从小到大排序
	if #tCampingList > 0 then
		table.sort(tCampingList, function(a, b)
			return a:getRecruitingQue():getRecruitLeftTime() < b:getRecruitingQue():getRecruitLeftTime()
		end)
		return tCampingList[1]
	end
end

--获取资源田可征收时间间隔（秒）
function BuildData:getResCollectTime(  )
	-- body
	return tonumber(getBuildParam("levyIntervalShow")) or 900
end

--获得资源田征收满了的时间（秒）
function BuildData:getResCollectTimeMax(  )
	-- body
	return tonumber(getBuildParam("levyMaxNum")) or 43200
end

--刷新不可升级建筑的解锁状态
--_nType：解锁途径：1玩家等级解锁 2王宫等级解锁 3主线任务解锁 4副本解锁
function BuildData:refreshUnUpingBuilds( tData, _nType )
	if tData and table.nums(tData) > 0 then
		for k, v in pairs (tData) do
			local nId = tonumber(v)
			if self.tAllBuilds[nId] == nil then --没有在已经解锁的列表中
				local pBuildData = getBuildDataByIdFromDB(nId)
				if pBuildData then
					local pBuild = Build.new()
					pBuild:initDatasByDB(pBuildData)
					self.tAllBuilds[nId] = pBuild
					if not Player:getUILoginLayer()  then --存在登陆界面，说明不是断网重连
						--添加解锁数据
						addShowUnLockedBuild({pBuild},_nType)
					end
					
				end
			else
				--不可升级建筑的解锁状态
				local bLocked = self.tAllBuilds[nId].bLocked
				if bLocked ~= false then
					self.tAllBuilds[nId].bLocked = false
					sendMsg(ghd_build_group_unlock_msg, nId)
				end
			end
		end
	end
end

--获取皇宫等级
function BuildData:getPalaceLv()
	local nPalaceLv = 0
	local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
	if pPalacedata then
		if pPalacedata.nLv then
			nPalaceLv = pPalacedata.nLv
		end
	end
	return nPalaceLv
end

--获得可升级建筑列表
function BuildData:getCanUpBuildLists(  )
	-- body
	--获得所有的建筑
	local tAllUpBuilds = {}
	if self.tAllBuilds and table.nums(self.tAllBuilds) > 0 then
		--先判断城内建筑
		for k, v in pairs (self.tAllBuilds) do
			if v.nCanUp == 1 and v.bLocked == false and v.nState == e_build_state.free and v:isBuildCanUp(1) then --可升级的建筑没有锁住并且条件满足
				if v.nCellIndex == e_build_cell.tnoly then --科技院特殊处理(如果有正在研究的科技加多个判断)
					local tCurTonly = Player:getTnolyData():getUpingTnoly()
					--是否可以在研究科技的时候同时升级建筑
					local bUpingWithTecnologying = getIsCanTnolyUpingWithTecnologying()
					if tCurTonly then
						if bUpingWithTecnologying then
							table.insert(tAllUpBuilds, v)
						end
					else
						table.insert(tAllUpBuilds, v)
					end
				else
					table.insert(tAllUpBuilds, v)
				end
			end
		end
		
	end
	-- if table.nums(tAllUpBuilds) == 0 then --城内建筑没有可升级的
		--判断资源田是否有可升级的建筑
		if self.tSuburbBuilds and table.nums(self.tSuburbBuilds) > 0 then
			for k, v in pairs (self.tSuburbBuilds) do
				if v.nCanUp == 1 and v.bLocked == false and v.bActivated == true 
					and v.nState == e_build_state.free and v:isBuildCanUp(1) then --可升级的建筑没有锁住并且条件满足
					table.insert(tAllUpBuilds, v)
				end
			end
		end
	-- end

	--如果都没有可升级的 那么为nil
	if table.nums(tAllUpBuilds) == 0 then
		tAllUpBuilds = nil
	else
		--排序
		table.sort(tAllUpBuilds, function ( a, b )
			-- body
			if a.nUpOrder == b.nUpOrder then
				return a.nLv < b.nLv
			else
				return a.nUpOrder < b.nUpOrder
			end
		end)
	end
	return tAllUpBuilds
end

--是否可以一键征收
function BuildData:isCanCollectedFast(  )
	-- body
	local bCan = false
	-- if self.tSuburbBuilds and table.nums(self.tSuburbBuilds) > 0 then
	-- 	for k, v in pairs (self.tSuburbBuilds) do
	-- 		if v.nColState == 1 or v.nColState == 2 then --可征收，满征收
	-- 			bCan = true
	-- 			break
	-- 		end
	-- 	end
	-- end
	local nColState = self:getColState()
	if nColState == 1 or nColState == 2 then
		bCan = true
	end
	return bCan
end

--判断采集队列和城防队列是否解锁
--nIndex = 1 采集队列 nIndex = 2 采集队列 nIndex = 3 城防队列
function BuildData:getHeroQuenceOpenByIndex( nIndex )
	-- body
	if not nIndex then
		return false
	end
	local nIdx = nIndex 
	local bOpen = false
	local pChief = self:getBuildById(e_build_ids.tcf)
	if nIdx == 1 then
		bOpen = true
	elseif nIdx == 2 then
		bOpen = pChief ~= nil
	elseif nIdx == 3 then
		if pChief and pChief.nLv >= 2 then
			bOpen = true
		end
	end
	return bOpen
end
--重置建筑状态
function BuildData:resetBuildStatus( ... )
	-- body
	if not self.tAllBuilds and table.nums(self.tAllBuilds) <= 0 then
		return
	end
	for k, v in pairs(self.tAllBuilds) do
		v:setBuildState(e_build_state.free)		
	end	
	-- dump(self.tAllBuilds, "self.tAllBuilds", 100)
end
--_nType：1：表示主动请求   2：表示后端推送
function BuildData:refreshAutoBuildData( _tData, _nType )
	-- body
	if not _tData then
		return
	end
	if not self.tBuildOrders then
		self:initOrderBuilds()			
	end
	-- dump(_tData, "自动建造 _tData", 10)
	self.nAbt = _tData.abt or self.nAbt   	-- Integer	自动建造的方式 0默认功能建筑 1资源建筑优先 2自定义
	self.nLp  = _tData.lp  or self.nLp		-- Integer	是否开启低等级优先自动升级 0为开启,1为不开启
	if _tData.udp and #_tData.udp == 0 then --需要客户端初始化数据
		self:initCustomOrder()
	else
		self.tUdp = _tData.udp or self.tUdp 	-- List<Pair<Integer,Integer>>	自定义优先级 k-id,v-优先级			
		if _nType == 1 then --错误数据排查
			table.sort(self.tUdp, function ( a, b )
				-- body
				if a.v == b.v then
					return a.k < b.k
				else
					return a.v < b.v	
				end				
			end)
			for i = 1, #self.tUdp do
				self.tUdp[i].v = i
			end
		end
	end	
	self.tNbi = _tData.nbi or self.tNbi      --	Set<Integer>	不参与自动建筑的建筑id

end
--获取低等级优先的状态
function BuildData:getOpenLowLvFirst(  )
	-- body、
	if self.nLp == 0 then
		return 1
	else
		return 0
	end
end

function BuildData:getCustomOrders(  )
	-- body
	return self.tUdp
end

--初始化自定义 优先级
function BuildData:initCustomOrder(  )
	-- body
	self.tUdp = {}
	table.sort( self.tBuildOrders, function ( a, b )
		-- body
		return a.nUpOrder < b.nUpOrder
	end )	
	for order, build in pairs(self.tBuildOrders) do
		table.insert(self.tUdp, {k=build.sTid, v=order}) 
	end	
end

function BuildData:initOrderBuilds( )
	-- body
	self.tBuildOrders = {}
	local tBUilds = getAllBuildsFromDB()
	for k,tDBData in pairs(tBUilds) do
		local _nBuildId = tDBData.id
		if _nBuildId then
			pBuildData = Build.new()
			pBuildData:initDatasByDB(tDBData)
			if pBuildData.nCanUp == 1 then
				table.insert(self.tBuildOrders, pBuildData)			
			end			
		end
	end	
end

function BuildData:getAutoBuildList()
	-- body	
	--刷新建筑等级数据
	for idx, build in pairs(self.tBuildOrders) do
		local nCellIndex = build.nCellIndex
		if nCellIndex > 0 and nCellIndex < 1000 then --非资源建筑
			local pCurBuild = self:getBuildById(build.sTid)
			if pCurBuild then
				build.nLv = pCurBuild.nLv
			else
				build.nLv = 0
			end
		end
	end
	--排序
	if self.nAbt == 0 then     -- 0默认功能建筑 
		table.sort( self.tBuildOrders, function ( a, b )
			-- body
			local aMax = a:isBuildMaxLv()
			local bMax = b:isBuildMaxLv()
			if aMax == bMax then
				return a.nUpOrder < b.nUpOrder
			else
				return bMax
			end			
		end)											
	elseif self.nAbt == 1 then -- 1资源建筑优先
		table.sort( self.tBuildOrders, function ( a, b )
			-- body
			local aMax = a:isBuildMaxLv()
			local bMax = b:isBuildMaxLv()
			if aMax == bMax then
				return a.nSecUpOrder < b.nSecUpOrder
			else
				return bMax
			end							
		end)
	elseif self.nAbt == 2 then -- 2自定义
		if self:checkMyOrders() then
			return {}
		end
		table.sort( self.tBuildOrders, function ( a, b )
			-- body
			local nAOrder = self:getBuildOrderById(a.sTid) or 100
			local nBOrder = self:getBuildOrderById(b.sTid) or 100
			local aMax = a:isBuildMaxLv() 
			local bMax = b:isBuildMaxLv() 
			if aMax == bMax then
				if nAOrder == nBOrder then
					return a.nUpOrder < b.nUpOrder
				else
					return nAOrder < nBOrder
				end				
			else
				return bMax
			end							
		end)
	end	
	
	-- dump(self.tBuildOrders, "self.tBuildOrders", 100)
	return self.tBuildOrders
end

function BuildData:getMyOrdersCnt(  )
	-- body
	if self.tUdp then
		return #self.tUdp
	else
		return 0
	end	
end

function BuildData:checkMyOrders( ... )	--自定义序列中删除一满级的建筑
	-- body
	local nOrderMax = 100
	local tOrders = {}
	local bError = false
	for idx, v in pairs(self.tUdp) do		
		local nBuildId = v.k
		local pBuild = self:getBuildById(nBuildId)
		if pBuild and pBuild:isBuildMaxLv() then
			v.v = nOrderMax
			if not bError then
				bError = true
			end			
		end
		table.insert(tOrders, copyTab(v))
	end
	if not bError then
		return bError
	end
	table.sort(tOrders, function ( a, b)
		-- body
		return a.v < b.v
	end)
	local tParams = ""
	for idx, v in pairs(tOrders) do
		if v.v < nOrderMax then
			tParams = tParams..v.k..":"..idx..";"
		end 		
	end		
	SocketManager:sendMsg("reqCustomPriority", {tParams})
	return bError
end

--获取自定义优先级
function BuildData:getBuildOrderById( _nBuildId )
	-- body
	if not _nBuildId then
		return nil
	end	
	local nIdx = nil
	for k, v in pairs(self.tUdp) do
		if v.k == _nBuildId then
			nIdx = v.v
			break
		end
	end
	-- 如果已存储的自定义列表没有该建筑，则添加到末尾
	if not nIdx then
		for order, build in pairs(self.tBuildOrders) do
			local pBuild = self:getBuildById(_nBuildId)
			if (build.sTid == _nBuildId) and pBuild and (not pBuild:isBuildMaxLv()) and (not pBuild:getIsLocked()) then
				table.insert(self.tUdp, {k=build.sTid, v=(#self.tUdp) + 1}) 
				nIdx = #self.tUdp
				break
			end			
		end	
	end
	return nIdx
end


--是否开启自动建造
function BuildData:isOpenAutoBuildById( _nId )
	-- body
	if not _nId then
		return true
	end
	for k, v in pairs(self.tNbi) do
		if v == _nId then
			return false
		end
	end
	return true
end
--_nId 建筑ID
function BuildData:isBuildLockedById( _nId )
	-- body
	local pBuild = self:getBuildById(_nId)
	if pBuild then--建筑
		return pBuild:getIsLocked()
	else--郊外建筑
		local tSuburbs = self:getSuburbOpenedById(_nId)
		if tSuburbs and #tSuburbs > 0 then
			return false
		end
	end
	return true
end
return BuildData