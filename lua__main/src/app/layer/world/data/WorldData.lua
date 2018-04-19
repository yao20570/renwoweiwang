----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-06 14:44:20
-- Description: 地图数据
-----------------------------------------------------
local ViewDotMsg = require("app.layer.world.data.ViewDotMsg")
local TaskMsg = require("app.layer.world.data.TaskMsg")
local HelpMsg = require("app.layer.world.data.HelpMsg")
local Dot = require("app.layer.world.data.Dot")
local CountryWarOverview = require("app.layer.world.data.CountryWarOverview")
local SystemcityOcpyInfo = require("app.layer.world.data.SystemcityOcpyInfo")
local TaskMovePush = require("app.layer.world.data.TaskMovePush")
local CountryWarMsg = require("app.layer.world.data.CountryWarMsg")
local CityWarNotice = require("app.layer.world.data.CityWarNotice")
local Elector = require("app.layer.world.data.Elector")
local MainCityOccupyVO = require("app.layer.world.data.MainCityOccupyVO")
local WorldBossVO = require("app.layer.world.data.WorldBossVO")
local ComingHelpVO = require("app.layer.world.data.ComingHelpVO")
local BossLocation = require("app.layer.world.data.BossLocation")
local LimitBossLocation = require("app.layer.world.data.LimitBossLocation")
local CityFirstBloodVO = require("app.layer.cityfirstblood.data.CityFirstBloodVO")
local GhostWarVO = require("app.layer.world.data.GhostWarVO")
local KingZhouLoction = require("app.layer.world.data.KingZhouLoction")
require("app.layer.world.data.EffectWorldDatas")
B_IS_WARLINE_TEST = false

--建筑点类型
e_type_builddot = {
	mobing      = -4, --魔兵（这里只用于检索我的城池附近的视图点)
	null 		= 0, --空地点
	city 		= 1, --玩家城池
	sysCity 	= 2, --系统城池
	res 		= 3, --资源田
	wildArmy 	= 4, --乱军
	boss        = 5, --张角BOSS
	tlboss      = 7, --限时BOSS
	ghostdom    = 6, --幽魂
	zhouwang 	= 8, --纣王
}

--国家代号
e_type_country = {
	-- qunxiong 	= 0, --群雄(黄,群雄)
	shuguo 		= 1, 	--红，汉
	weiguo 		= 2, 	--蓝，秦
	wuguo 		= 3, 	--绿，楚
	qunxiong 	= 4, 	--灰, 群雄
}

--矿点类型
e_type_mines = {
	inn  = 1,--客栈
	mill = 2,--木厂
	farm = 3,--农场
	iron = 4,--铁矿
	gold = 5,--金矿
}

--任务类型
e_type_task = {
	collection 	= 1,--采集 
	wildArmy 	= 2,--攻打乱军 
	cityWar 	= 3,--城战
	countryWar 	= 4,--国战
	garrison 	= 5,--驻防
	boss 		= 6,--Boss
	tlboss      = 7,--tlboss
	ghostdom 	= 8,--幽魂
	imperwar    = 9,--皇城任务
	zhouwang 	= 10,--纣王试炼
}

--任务状态
e_type_task_state = {
	idle        = 0,--空闲状态
	go 			= 1,--前往状态
	collection 	= 2,--采集状态
	attack 		= 3,--攻击状态
	back 		= 4,--返回状态
	waitbattle	= 5,--待战状态
	garrison    = 6,--驻防状态
}

--任务输入
e_type_task_input = {
	call 	= 2,--行军召回
	quick	= 3,--行军加速
}

--城战玩家互动状态
e_type_citywar_act = {
	hit     = 0, --打
	support = 1, --有人支援我
}

--系统城类型
e_kind_city = {
	junyin = 1, --郡营
	junxian = 2, --郡县
	juncheng = 3, --郡城
	zhouxian = 4, --州县
	zhoufu = 5, --州府
	zhoucheng = 6, --州城
	mingcheng = 7, --名城
	ducheng = 8, --都城
	zhongxing = 9, --中心
	firetown = 10, --烽火台
}

--目标类型
e_type_world_target = {
	wildArmy = 1, --击杀乱军
	sysCity = 2,  --攻占城池
	worldBoss = 3,--世界boss
	capital = 4, --攻占都城:都城数量
}

--区域类型
e_type_block = {
	jun = 1, --郡
	zhou = 2,--州
	kind = 3, --皇城
}

--前往帮助
e_type_coming_help = {
	garrison = 1, --前来驻防
	help     = 2, --前来协防
}

--短途战,合围战，奔袭战
e_citywar_type = {
	short = 1,
	combin = 2,
	quickCombin = 3
}

--战争类型
e_war_type = {
	city = 1,--城战
	country = 2,--国战
	countryStart = 3,--发起国战
	boss = 4,--Boss战
}

--搜索类型
e_type_search = {
	wildArmy = 0, --乱军
	inn  = 1,--客栈
	mill = 2,--木厂
	farm = 3,--农场
	iron = 4,--铁矿
	gold = 5,--金矿
}

--
e_jumpto_world_type = {
	null=0,
	activity=1,
	bag=2,
}

e_share_type = {
	boss = 1,
	player = 2,
	city =3,
	syscity=4,
	countrywar=5,
	citywar=6,
	becitywar=7,
	call=8,
	bosssupport=9,
	tlboss = 10,
	ghostsupport = 11,
}

--战报类型类型
e_war_report_type = {
	fuben = 1,--副本
	city = 2,--城战
	wildarmy = 3,--乱军
	country = 4,--国战
	reswar = 5,--资源田
	worldboss = 6,--世界boss
	zhouwang = 7,--纣王
	tlboss = 9, --限时boss
	killhero = 10, --过关斩将
}

--世界行军列表tab
--1,武将，2采集武将，3，来袭，4，国战，5，协防,
e_wolrdbattle_tab = {
	hero = 1,
	collect_hero = 2,
	hit = 3,
	country_war = 4,
	support = 5
}

--世界开启状态
e_world_open_state = {
	jun = 0, --郡
	zhou = 1, --州
	kind = 2, --王
}

--系统城池燃烧特效类型
e_sys_city_effect = {
	none  = 0 , --无特效
	normal = 1, --普通城火焰
	ghost = 2, --冥王入侵
}


--地图数据类
local WorldData = class("WorldData")

function WorldData:ctor(  )
	self.nSeasonDay = 0
	self.nWildArmyLv = 0
	self.nKilledWildArmyNum = 0   -- 今日已击杀乱军数量
	self.tBuildDots = {}
	self.tBlockOrginDots = {}
	self.tBlockReqTime = {}
	self.tBlockCountry = {}
	self.tBlockDots = {}
	self.tBlockDotsParsed = {}
	self.tBlockCWOV = {}
	self.tBlockSCOI = {}
	self.tBlockBoss = {}
	self.tBlockTLBoss = {}
	self.tBlockZhou = {}
	self.tTaskMovePushs = {}
	self.tTasks = {}
	-- self.nProtectCD = 0
	self.tMyCountryWars = {} --我国国战列表
	self.tMyCountryWarCityIds = {} --我国国战发起的城池id
	self.tCityWarNotices = {} --城战提醒通知
	self.tHelpMsgs = {}
	self.tMainCityOccupyVOs = {}

	self.tTaskAtkEffect = {} --进击特效显示
	self.tCapitalInfo = {}
	self.bHaveNewHelpMsg = false --是否有新增的城防 

	self.nVipFreeCalled = 0 --已使用vip免费召回次数
	self.tCanSeeBlock = {}
	self.tCanMigrateBlock = {}
	self.nWildArmyKill = 0

	self.tWArmyFightPos = {}
	self.tNewBossDict = {}
	self.bIsNewTLBoss = false
	
	--小地图视图点已解析完的数据
	self.tParsedDot = {}

	--城池首杀数据
	self.tCityFirstBloodDict = {}
	self.tCFBloodNewLocal = {}

	--世界搜索记录
	self.tWorldSearch = {}

	--总改变点集俣
	self.tRefreshDotPos = {}

	--默认数据
	self.nX = 1
	self.nY = 1
	self.nMyBlockId = WorldFunc.getBlockId(self.nX, self.nY)
end

function WorldData:release()
end

--视图点展示数据类集
function WorldData:createViewDotMsgList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tData2 = ViewDotMsg.new(tData[i])
		local sKey = tData2:getDotKey()
		if sKey then
			tRes[sKey] = tData2
		end
	end
	return tRes
end

--任务数据展示类集
function WorldData:createTaskMsgList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tData2 = TaskMsg.new(tData[i])
		local sUuid = tData2.sUuid
		tRes[sUuid] = tData2
	end
	return tRes
end

--驻防数据展示类集
function WorldData:createHelpMsgList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		table.insert(tRes,HelpMsg.new(tData[i]))
	end
	return tRes
end

--创建地图点列表
function WorldData:createDotList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local pDot = Dot.new(tData[i])
		tRes[pDot.sDotKey] = pDot
	end
	return tRes
end

--创建地图点
--tData源数据
function WorldData:createDot( tData, nBlockId)
	if not self.tBlockDots[nBlockId] then
		self.tBlockDots[nBlockId] = {}
	end
	--不作二次解析
	local pDot = nil
	if self.tParsedDot[tData] then
		pDot = self.tParsedDot[tData]
		--因为第二次申求会删除
		self.tBlockDots[nBlockId][pDot.sDotKey] = pDot
	else
		pDot = Dot.new(tData)
		self.tBlockDots[nBlockId][pDot.sDotKey] = pDot
		--记录
		self.tParsedDot[tData] = pDot
	end
	return pDot
end


--创建城战纵览列表
function WorldData:createCountryWarOverviewList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tCountryWarOverview = CountryWarOverview.new(tData[i])
		tRes[tCountryWarOverview.nId] = tCountryWarOverview
	end
	return tRes
end

--创建区域内各个城池占领信息列表
function WorldData:createSystemcityOcpyInfoList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tSystemcityOcpyInfo = SystemcityOcpyInfo.new(tData[i])
		tRes[tSystemcityOcpyInfo.nId] = tSystemcityOcpyInfo
	end
	return tRes
end

--创建区域内各个城池Boss位置定位信息列表
function WorldData:createBossLocationDict( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tBossLocation = BossLocation.new(tData[i])
		tRes[tBossLocation.sDotKey] = tBossLocation
	end
	return tRes
end

--创建区域内限时Boss的定位信息
function WorldData:createLimitBossLocation( tData )
	if not tData then
		return
	end
	return LimitBossLocation.new(tData)
end

--创建区域内的纣王试炼定位信息
function WorldData:createKingZhouLoction( tData )
	-- body
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tKingZhouLoction = KingZhouLoction.new(tData[i])
		tRes[tKingZhouLoction.sDotKey] = tKingZhouLoction
	end
	return tRes		
end

--创建世界移动数据推送列表
function WorldData:createTaskMovePushList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tTaskMovePush = TaskMovePush.new(tData[i])
		tRes[tTaskMovePush.sUuid] = tTaskMovePush
	end
	return tRes
end

--创建国战数据列表
function WorldData:createCountryWarMsgs( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tCountryWarMsg = CountryWarMsg.new(tData[i])
		tRes[tCountryWarMsg.sId] = tCountryWarMsg
	end
	return tRes
end

--创建自己的城战列表
function WorldData:createCityWarNoticeList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tCityWarNotice = CityWarNotice.new(tData[i])
		table.insert(tRes, tCityWarNotice )
	end
	return tRes
end

--创建城市竞选者列表
function WorldData:createElectorList( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tElector = Elector.new(tData[i])
		table.insert(tRes, tElector)
	end
	return tRes
end

--城市数据(加载城池) 3000
function WorldData:onLoadCityRes( tData )
	if not tData then
		return
	end
	---数据差比较
	local pPrevX, pPrevY = self.nX, self.nY
	local nPrevSeasonDay = self.nSeasonDay
	local nVipFreeCalled = self.nVipFreeCalled

	--------------------
	self:setMyCityPos(tData.x, tData.y) --设置我的坐标
	-- if tData.pCD then
	-- 	self.nProtectCD = tData.pCD --Integer	保护罩剩余时间
	-- 	self.nProtectCDSystemTime = getSystemTime()
	-- end
	self.nSeasonDay = tData.s or self.nSeasonDay --Integer	季节天

	self.nWildArmyLv = tData.ml or self.nWildArmyLv --Integer	已击杀乱军最大的等级

	self.nKilledWildArmyNum = tData.kr or self.nKilledWildArmyNum --Integer	今日已击杀乱军数量

	self:updateArroundDots(tData.ds, tData.x, tData.y)--List<ViewDotMsg>	周围视图点	

	if tData.t then --List<TaskMsg>	任务列表
		self.tTasks = self:createTaskMsgList(tData.t)
	end

	if tData.h then --List<HelpMsg>	驻防列表
		self.tHelpMsgs = self:createHelpMsgList(tData.h)
	end

	if tData.cn then --List<CityWarNotice>	城战提示列表
		self.tCityWarNotices = self:createCityWarNoticeList(tData.cn)
	end

	self.nCapitalId = tData.cid or self.nCapitalId --	Long	我国都城城池ID

	self:setRebuildReward(tData.rb, tData.sb) --重建获得的物资, --是否高级重建

	self:setMyWorldTargetId(tData.ws) --Integer	玩家当前所处的世界目标任务序号

	-- self:setWorldBossExist(tData.bx) --Integer	世界BOSS是否存在 0：否 1:是
	self:setWorldBossVo(tData.bv) --WorldBossVO	世界BOSS
	self:setWildArmyKill(tData.mk)	--Integer	世界目标我击杀的乱军数量
	self:setWorldTargetId(tData.cs) --Integer	当前世界的目标
	self:setUsedMoveCity(tData.lm) --List<Integer>	已消耗低迁前往指定区域的序号
	self:setNoAttackCapital(tData.bc) --Integer 不能攻打的都城
	self:setAttackedBoss(tData.kb) --Integer 今天是否打过世界Boss 0：否 1:是
	self:setCapitalInfo(tData.dcs) --List<Pair<Integer,Long>> 如果没有该势力Id，就没有占领都城

	self:setTodayFreeChangeCity(tData.mzt)
	-- dump(tData.ws, "tData.ws 玩家当前所处的世界目标任务序号", 100)
	-- dump(tData.bx, "tData.bx 世界BOSS是否存在 0：否 1:是", 100)
	-- dump(tData.bv, "tData.bv 世界BOSS", 100)
	-- dump(tData.mk, "tData.mk 世界目标我击杀的乱军数量", 100)
	-- dump(tData.cs, "tData.cs 当前世界的目标", 100)
	-- dump(tData.lm, "tData.lm 已消耗低迁前往指定区域的序号", 100)
	-- dump(tData.kb, "tData.kb 今天是否打过世界boss0:否 1:是", 100)	

	self.nVipFreeCalled = tData.vfm or self.nVipFreeCalled --已使用vip免费召回次数

	self:setWildArmyMids(tData.mids) --Set<Integer>	已请求刷新任务乱军的任务ID集合
	--------------------------

	--坐标不一样发送迁城跳转
	if pPrevX ~= self.nX or pPrevY ~= self.nY then
		sendMsg(gud_world_my_city_pos_change_msg)
	end
	--季节天不一样
	if nPrevSeasonDay ~= self.nSeasonDay then
		sendMsg(gud_world_season_day_change)
	end
	--任务更新
	if tData.t then
		sendMsg(gud_world_task_change_msg)
	end
	--驻防更新
	if tData.h then
		sendMsg(gud_refresh_wall)
	end
	--城战列表更新
	if tData.cn then
		sendMsg(gud_world_my_city_be_attack_msg)
	end
	--已使用vip免费召回次数更改
	if nVipFreeCalled ~= self.nVipFreeCalled then
		sendMsg(ghd_world_vipfree_called_change)
	end

	self:setGhostWarVo(tData.gw) --GhostWarVO	冥王入侵
end

--设置重建获得物资
function WorldData:setRebuildReward( tData, nSuperReBuild )
	if not tData then
		return
	end
	self.tRebuildReward = tData
	self.bIsSuperReBuild = nSuperReBuild == 1
end

--乱军击杀过的最大等级
function WorldData:setWildArmyLv( nLv )
	if not nLv then
		return
	end
	self.nWildArmyLv = nLv
	sendMsg(ghd_can_kill_wildarmy_lv_change)
end

--获取乱军等级是否可以打
--nLv !!! 乱军的前置等级
function WorldData:getWildArmyIsCanAtk( nLv )
	if not self.nWildArmyLv then
		return false
	end
	if nLv <= self.nWildArmyLv then
		return true
	end
	return false
end

--获取乱军等级可以打
function WorldData:getCanAtkWildArmyLv( )
	return self.nWildArmyLv + 1
end

--获取今日已击杀乱军数量
function WorldData:getKilledWildArmyNum()
	-- body
	return self.nKilledWildArmyNum
end

--设置季节日
function WorldData:setSeasonDay( nSeasonDay )
	self.nSeasonDay = nSeasonDay
end

--区域块响应数据(显示小地图专用) 3009
function WorldData:onLoadBlockRes( tData, nBlockId)
	if not tData then
		return
	end
	self.tBlockCountry[nBlockId] = tData.c -- Integer	区域块所属国家
	-- local nT1 = getSystemTime(false)
	self.tBlockDots[nBlockId] = self:createDotList(tData.dots) --List<Integer> 地图点数 +---+| 9bit | 9bit | 6bit | 2bit | +---+| x | y | 皇宫等级 | 势力0：群雄 1：蜀 2: 魏 3: 吴 |
	-- local nT2 = getSystemTime(false)
	-- self.tBlockDotsParsed[nBlockId] = true
	-- print("#tData.dots used time ============== ",#tData.dots, nT2 - nT1)
	-- self.tBlockDots[nBlockId] = {} --清容
	-- self.tBlockDotsParsed[nBlockId] = false
	-- self.tBlockOrginDots[nBlockId] = tData.dots --涉级到数据解析效率，当用到的时候再进行解析
	self.tBlockCWOV[nBlockId] = self:createCountryWarOverviewList(tData.os) --List<CountryWarOverview>	城战纵览
	self.tBlockSCOI[nBlockId] = self:createSystemcityOcpyInfoList(tData.cs) --List<SystemcityOcpyInfo>	区域内各个城池占领信息
	self.tBlockBoss[nBlockId] = self:createBossLocationDict(tData.bls) --List<BossLocation>	纣王boss分布
	self.tBlockTLBoss[nBlockId] = self:createLimitBossLocation(tData.lb) --LimitBossLocation	限时boss位置
	self.tBlockZhou[nBlockId] = self:createKingZhouLoction(tData.kzs) --KingZhouLoction	纣王试炼位置
	--测试
	if B_IS_WARLINE_TEST then
		tData.tp = {}
		for i=1,100 do
			local _tp = {
				i = i,--	Long	角色ID
				u = "test_id"..tostring(i),
				n = "玩家"..tostring(i),
				s = 1,--	Integer	任务状态 1:前往 4:返回
				c = 1,--	Integer	玩家国家
				sx = 250,
				sy = 250,
				ex = math.random(1, 500),
				ey = math.random(1, 500),
				cd = 3162,
				ms = 8,
				hids = {200001},	--Set<Integer>	出征英雄
			}
			table.insert(tData.tp, _tp)
		end
	end
	--清空旧的区域行军线路数据（放这里处理是为了处理显示即时和延迟的问题)
	self:delTaskMovePush(nBlockId)
	local tTaskMovePushs = self:createTaskMovePushList(tData.tp) --List<TaskMovePush>	区域内行军任务
	if tTaskMovePushs then
		for k,v in pairs(tTaskMovePushs) do
			self.tTaskMovePushs[k] = v
		end
	end
	-- dump(tData.tp,"tData.tp",100)
	-- dump(self.tTaskMovePushs,"self.tTaskMovePushs",100)
end

--清空指定区域的世界推送线路图
--nBlockId：指定的区域。
function WorldData:delTaskMovePush( nBlockId )
	for k, v in pairs(self.tTaskMovePushs) do
		if v:getIsInBlockId(nBlockId) then
			self.tTaskMovePushs[k] = nil
		end
	end
end

--除指定区域的世界推送线路都要删除(用于世界视图滑动进入不同的区域时调用)
--nBlockId：指定的区域。
function WorldData:delTaskMovePushExcept( nBlockId )
	for k, v in pairs(self.tTaskMovePushs) do
		if not v:getIsInBlockId(nBlockId) then
			self.tTaskMovePushs[k] = nil
		end
	end
end

--区域点数据是否全部解析完成
function WorldData:getIsBlockDataParsed( nBlockId )
	return self.tBlockDotsParsed[nBlockId] or false
end

--设置区域点数据解析完成
function WorldData:setIsBlockDataParsed( nBlockId )
	self.tBlockDotsParsed[nBlockId] = true
end

--迁城数据返回3001
function WorldData:onMigrateRes( tData )
	if not tData then
		return
	end
	--设置我的位置
	self:setMyCityPos(tData.x, tData.y)
	--设置周围数据
	self:updateArroundDots(tData.dots, tData.x, tData.y)

	--迁城后打印
	-- local tArroundDots = self:createViewDotMsgList(tData.dots) --周围视图点
	-- for k,tViewDotMsg in pairs(tArroundDots) do
	-- 	if tViewDotMsg:getIsMe() then
	-- 		dump(tViewDotMsg)
	-- 	end
	-- end
end

--3505免费迁往州
function WorldData:onFreeToState( tData )
	if not tData then
		return
	end
	--设置我的位置
	self:setMyCityPos(tData.x, tData.y)
	--设置周围数据
	self:updateArroundDots(tData.vds, tData.x, tData.y)
end

--[-3037]被迁城推送
function WorldData:pushBeMigrated( tData )
	if not tData then
		return
	end

	local nX, nY = tData.x, tData.y
	if nX and nX then
		--更新我的位置
		self:setMyCityPos(nX, nY)
		--更新我的视图点位置
		local tViewDotMsg = self:getMyViewDotMsg()
		if tViewDotMsg then
			tViewDotMsg:setPos(nX, nY)
		end
	end

	self:setRebuildReward(tData.rb, tData.sb) --重建获得的物资, --是否高级重建
	--直接刷新界面
	local pDlg, bNew = getDlgByType(e_dlg_index.rebuildreward)
	if pDlg then
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG 直接刷新界面")
		end
		sendMsg(ghd_world_rebuild_reward_show)
	else
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG 显示重建界面")
		end
		--显示重建界面
		showDlgReBuildReward()
	end
end

--设置我的城池坐标
function WorldData:setMyCityPos( nX, nY )
	if not nX or not nY then
		return
	end

	local nPrevX = self.nX
	local nPrevY = self.nY

	--记录新数据
	self.nX = nX
	self.nY = nY
	self.nMyBlockId = WorldFunc.getBlockId(self.nX, self.nY)
	self.sDotKey = string.format("%s_%s", self.nX, self.nY)


	--新位置与旧位置不在同一个区域id时,要申请区域相关的数据(服务器不推~)
	if nPrevX and nPrevY then
		local nPrevBlockId = WorldFunc.getBlockId(nPrevX, nPrevY)
		local nBlockId = WorldFunc.getBlockId(self.nX, self.nY)
		if nPrevBlockId ~= nBlockId then
			SocketManager:sendMsg("reqWorldMyCountryWar", {})
		end
	end
end

--任务状态变更推送 3006
function WorldData:onTaskMsgPush( tData )
	if not tData then
		return
	end
	local sUuid = tData.u
	if sUuid then
		if self.tTasks[sUuid] then
			--是皇家战任务且前往
			local bIsImperGo = false
			if self.tTasks[sUuid].nType == e_type_task.imperwar and self.tTasks[sUuid].nState == e_type_task_state.go then
				bIsImperGo = true
			end
			
			--更新数据
			self.tTasks[sUuid]:update(tData)

			--是皇家战任务且待战中就播放
			if bIsImperGo and self.tTasks[sUuid].nState == e_type_task_state.waitbattle then
				TOAST(string.format(getConvertedStr(3, 10841), self.tTasks[sUuid].sBotCityName))
			end
		else
			self.tTasks[sUuid] = TaskMsg.new(tData)
		end
	end
	--
	self:updateTaskAtkEffect()
end

--视图点消失推送3007
function WorldData:onDotDispear( tData )
	if not tData then
		return
	end
	local sDotKey = string.format("%s_%s", tData.x,tData.y)
	for nType,tDots in pairs(self.tBuildDots) do
		if nType ~= e_type_builddot.sysCity then
			if tDots[sDotKey] then
				self.tBuildDots[nType][sDotKey] = nil
				break
			end
		end
	end
	--视图点消失小地图
	local nBlockId = WorldFunc.getBlockId(tData.x, tData.y)
	if nBlockId then
		self:updateBlockDots(nBlockId, nil, {sDotKey})
	end
	--保存
	self:saveRefreshDotPos(tData.x,tData.y)
end

--世界行军推送 3005
function WorldData:onTaskMovePush( tData )
	if not tData then
		return
	end
	local sUuid = tData.u
	if sUuid == nil and tData.c then --御林军特殊处理
		sUuid = "fuck_ylz_"..tostring(tData.c)
		tData.u = sUuid
	end
	if sUuid then
		if self.tTaskMovePushs[sUuid] then
			self.tTaskMovePushs[sUuid]:update(tData)
		else
			self.tTaskMovePushs[sUuid] = TaskMovePush.new(tData)
		end
	end

	-- sendMsg(sgnd, _msgObj)
	--
	self:updateTaskAtkEffect()
end

--区域内城战发生变化推送3014
function WorldData:onBlockCWOVPush( tData )
	if not tData then
		return
	end

	local nCityId = tData.i
	local tCityData = getWorldCityDataById(nCityId)
	if not tCityData then
		return
	end

	local nBlockId = tCityData.map
	if not self.tBlockCWOV[nBlockId] then
		self.tBlockCWOV[nBlockId] = {}
	end
	self.tBlockCWOV[nBlockId][nCityId] = CountryWarOverview.new(tData)
end

--区域内城池占领发生变化推送3015
function WorldData:onBlockSCOIPush( tData )
	if not tData then
		return
	end

	local nCityId = tData.i
	local tCityData = getWorldCityDataById(nCityId)
	if not tCityData then
		return
	end

	local nBlockId = tCityData.map
	if not self.tBlockSCOI[nBlockId] then
		self.tBlockSCOI[nBlockId] = {}
	end
	self.tBlockSCOI[nBlockId][nCityId] = SystemcityOcpyInfo.new(tData)
end

--我国国战列表3016
function WorldData:onLoadMyCountryWar( tData )
	if not tData then
		return
	end
	self.tMyCountryWars = self:createCountryWarMsgs(tData.wars) or {}
end

--我国国战列表推送3021
function WorldData:onPushMyCountryWar( tData )
	if not tData then
		return
	end

	local sId=string.format("%s_%s",tData.i,tData.sC)

	
	if self.tMyCountryWars[sId] then 
		self.tMyCountryWars[sId]:update(tData)
	else
		local tCountryWarMsg = CountryWarMsg.new(tData)
		self.tMyCountryWars[tCountryWarMsg.sId] = tCountryWarMsg
	end
	
end

--移除我国国战列表推送3022
-- function WorldData:delMyCountryWar( nId )
-- 	if self.tMyCountryWars[nId] then
-- 		self.tMyCountryWars[nId] = nil
-- 	end
-- end

--删除任务3019
function WorldData:delTaskMsgByUuid( sUuid)
	if not sUuid then
		return
	end
	--删除自己的线路
	if self.tTasks[sUuid] then
		self.tTasks[sUuid] = nil
	end
	--（因为世界推送移动任务也包括自己的行路，所以也一起删除)
	if self.tTaskMovePushs[sUuid] then
		self.tTaskMovePushs[sUuid] = nil
	end

	--
	self:updateTaskAtkEffect()
end

--视图点变化推送3020
function WorldData:onDotChange( tData )
	if not tData then
		return
	end
	--限时Boss不在这里加入
	if tData.t == e_type_builddot.tlboss then
		return
	end

	local tViewDotMsg = ViewDotMsg.new(tData)
	local nType = tViewDotMsg.nType
	if not self.tBuildDots[nType] then
		self.tBuildDots[nType] = {}
	end
	if nType == e_type_builddot.sysCity then
		local nSystemCityId = tViewDotMsg.nSystemCityId
		self.tBuildDots[nType][nSystemCityId] = tViewDotMsg
	else
		--如果发过来是新的自己就删掉旧的自己，先兼容一下迁移遗留问题
		if tViewDotMsg:getIsMe() then
			self:delMyViewDotMsg()
		end
		local sDotKey = tViewDotMsg.sDotKey
		--是不是新召唤的Boss,要进行特效播播放标记
		if nType == e_type_builddot.boss then
			if not self.tBuildDots[nType][sDotKey] then
				self:setIsNewBoss(sDotKey, true)
			end
		end
		
		self.tBuildDots[nType][sDotKey] = tViewDotMsg
	end
	--保存
	self:saveRefreshDotPos(tViewDotMsg.nX, tViewDotMsg.nY)
	--更新小地图
	local nBlockId = WorldFunc.getBlockId(tViewDotMsg.nX, tViewDotMsg.nY)
	if nBlockId then
		self:updateBlockDots(nBlockId, {tViewDotMsg})
	end
	--发送数据更改
	sendMsg(gud_world_dot_change_msg, tViewDotMsg)
end

--根据位置获取视图点
function WorldData:getViewDotMsg( nX, nY)
	for k,tBuildDots in pairs(self.tBuildDots) do
		for sDotKey, tViewDotMsg in pairs(tBuildDots) do
			if tViewDotMsg:getIsDotPosIn(nX, nY) then
				return tViewDotMsg
			end
		end
	end
	return nil
end
--[-3602]冥王入侵提醒推送
function WorldData:onGhostAttackNotice( tData )
	if not tData then
		return
	end
	self:setGhostWarVo(tData)
end

--[-3023]城战提醒推送
function WorldData:onHitMyCityNotice( tData )
	if not tData then
		return
	end
	if tData.n then
		self.tCityWarNotices = self:createCityWarNoticeList(tData.n)
	end
end

--[-3031]我的城池驻防
function WorldData:onMyCityGarrison( tData )
	if not tData then
		return
	end
	if tData.gs and table.nums(tData.gs) > table.nums(self.tHelpMsgs) then
		self:setHaveNewHelpMsgs(true)
	end

	if tData.gs then
		self.tHelpMsgs = self:createHelpMsgList(tData.gs) --驻防列表
	end
end

--获取是否有新增的城防 
function WorldData:getHaveNewHelpMsgs()
	return self.bHaveNewHelpMsg 
end

--设置有新增的城防
function WorldData:setHaveNewHelpMsgs(_bHave)
	-- body
	self.bHaveNewHelpMsg = _bHave
end

--获取城战提醒列表
function WorldData:getCityWarNotices(  )
	return self.tCityWarNotices
end

--当前是否有人出征打我
function WorldData:getOtherIsAttackMe( )
	local bIsShortCdHitNotice = false
	local tCityWarNotices = self:getCityWarNotices()
	for i=1,#tCityWarNotices do
		local tNotice = tCityWarNotices[i]
		if tNotice:getCd() > 0 and tNotice:checkTargetIsMe() then --只显示cd大于0的
			if tNotice.nType == e_type_citywar_act.hit then  --最短cd打我消息
				bIsShortCdHitNotice = true
				break
			end
		end
	end
	if not bIsShortCdHitNotice then
		local tGhostWarNotices = self:getGhostWarVo()
		if tGhostWarNotices and tGhostWarNotices:getCd() > 0 then
			bIsShortCdHitNotice = true
		end
	end
	return bIsShortCdHitNotice
end

--获取保护倒计时
function WorldData:getProtectCD(  )
	-- if self.nProtectCD and self.nProtectCD > 0 then
	-- 	local fCurTime = getSystemTime()
	-- 	local fLeft = self.nProtectCD - (fCurTime - self.nProtectCDSystemTime)
	-- 	if(fLeft < 0) then
	-- 		fLeft = 0
	-- 	end
	-- 	return fLeft
	-- else
	-- 	return 0
	-- end

	local buffvo = Player:getBuffData():getBuffVo(e_buff_ids.cityprotect)
	if buffvo then
		return buffvo:getRemainCd()
	end
	return 0
end

--获取自己城池视图点坐标
function WorldData:getMyCityDotPos(  )
	return self.nX or 1, self.nY or 1
end

--获取我自己的视图点信息
function WorldData:getMyViewDotMsg( )
	if not self.tBuildDots[e_type_builddot.city] then
		return
	end

	for k, tViewDotMsg in pairs(self.tBuildDots[e_type_builddot.city]) do
		if tViewDotMsg:getIsMe() then
			return tViewDotMsg
		end
	end
	return nil
end

--获取自己城池的blockId
function WorldData:getMyCityBlockId()
	return self.nMyBlockId
end

--获取自己城池的block类型
function WorldData:getMyCityBlockType(  )
	-- body
	local tBlockData = getWorldMapDataById(self:getMyCityBlockId())
	if tBlockData then
		return tBlockData.type 
	else
		return nil
	end
end

--更新视图点 3008
function WorldData:updateArroundDots( arroundDots, nX, nY)
	-- dump(arroundDots,"arroundDots")
	if arroundDots then
		--空地表
		local nSearchX = getWorldInitData("searchX")
		local nSearchY = getWorldInitData("searchY")
		local tNullGrid = {}
		local nBeginX = nX - nSearchX
		local nBeginY = nY - nSearchY
		for i=nBeginX, nSearchX + nX do
			for j = nBeginY, nSearchY + nY do
				local sKey = string.format("%s_%s",i, j)
				tNullGrid[sKey] = true
			end
		end

		--清空之前数据
		-- self.tBuildDots = {}
		local tArroundDots = self:createViewDotMsgList(arroundDots) --周围视图点
		for k,v in pairs(tArroundDots) do
			
			--除了系统城池有id字段，其他都不是用自定义sDotKey做唯一值
			--限时Boss不在这里加入
			if v.nType ~= e_type_builddot.null and v.nType ~= e_type_builddot.tlboss then
				local tDots = self.tBuildDots[v.nType]
				if not self.tBuildDots[v.nType] then
					self.tBuildDots[v.nType] = {}
					tDots = self.tBuildDots[v.nType]
				end
				if v.nType == e_type_builddot.sysCity then
					tDots[v.nSystemCityId] = v
				else
					if v:getIsMe() then
						--删除掉我的旧数据
						self:delMyViewDotMsg()
					end
					tDots[v.sDotKey] = v
				end
				tNullGrid[v.sDotKey] = nil
			end
		end

		--清空除系统城池外的数据
		for nType,tDots in pairs(self.tBuildDots) do
			if nType ~= e_type_builddot.sysCity then
				for sNullDotKey,v in pairs(tNullGrid) do
					self.tBuildDots[nType][sNullDotKey] = nil
				end
			end
		end
		--可视范围里的视图点更新
		sendMsg(gud_world_search_around_msg, {nX = nX, nY = nY})

		--小地图视图点更新
		local nBlockId = WorldFunc.getBlockId(nX, nY)
		if nBlockId then
			self:updateBlockDots(nBlockId, tArroundDots, sNullDotKey)
		end
	end
end

--删除自己的城池旧数据（用于迁城，被迁城，击飞)
function WorldData:delMyViewDotMsg( )
	if not self.tBuildDots[e_type_builddot.city] then
		return
	end
	for k, tViewDotMsg in pairs(self.tBuildDots[e_type_builddot.city]) do
		if tViewDotMsg:getIsMe() then
			--删除小地图我的点
			local nBlockId = WorldFunc.getBlockId(tViewDotMsg.nX, tViewDotMsg.nY)
			if nBlockId then
				self:updateBlockDots(nBlockId, nil, {tViewDotMsg.sDotKey})
			end
			--删除大地图视图点
			self.tBuildDots[e_type_builddot.city][k] = nil
		end
	end
end

--前端显示在框外的数据就删除
function WorldData:delViewDotMsg( tViewDotMsg )
	if tViewDotMsg then
		local nDotType = tViewDotMsg.nType
		if nDotType then
			if self.tBuildDots[nDotType] then
				if nDotType == e_type_builddot.sysCity then
					self.tBuildDots[nDotType][tViewDotMsg.nSystemCityId] = nil
				else
					--自己不是在这里删除,因为要在小地图上面显示坐标
					if nDotType == e_type_builddot.city then
						if tViewDotMsg:getIsMe() then
							return
						end
					end
					self.tBuildDots[nDotType][tViewDotMsg.sDotKey] = nil
				end
			end
		end
	end
end

--获取区域视图点(显示小地图专用)
--nBlockId:区域id
function WorldData:getBlockDots( nBlockId )
	if self.tBlockDots[nBlockId] then
		return self.tBlockDots[nBlockId]
	end
	return {}
end

--BlockId:获取视图点原始数据
function WorldData:getBlockOrginDots( nBlockId )
	if self.tBlockOrginDots[nBlockId] then
		return self.tBlockOrginDots[nBlockId]
	end
	return {}
end

--是否存在区域视图点数据
function WorldData:isBlockDataExist( nBlockId)
	return self.tBlockDots[nBlockId] ~= nil
	-- return self.tBlockOrginDots[nBlockId] ~= nil
end

--获取建筑点数据集
function WorldData:getBuildDots( nType )
	return self.tBuildDots[nType] or {}
end

--获取小地图系统城池占领情况
function WorldData:getBlockSCOI( nBlockId )
	return self.tBlockSCOI[nBlockId] or {}
end

--获取小地图攻击系统城池情况
function WorldData:getBlockCWOV( nBlockId )
	return self.tBlockCWOV[nBlockId] or {}
end

--获取小地图Boss定位
function WorldData:getBlockBoss( nBlockId )
	return self.tBlockBoss[nBlockId] or {}
end

--获取小地图的纣王试炼定位
function WorldData:getBlockKingZhou( nBlockId )
	-- body
	return self.tBlockZhou[nBlockId] or {}
end
--获取系统建筑点
--nSysCityId: 城池id
function WorldData:getSysCityDot( nSysCityId )
	local tBuildDots = self:getBuildDots(e_type_builddot.sysCity)
	return tBuildDots[nSysCityId]
end

--获取玩家城池建筑点
--nCityId: 城池id
function WorldData:getCityDot( nCityId )
	local tBuildDots = self:getBuildDots(e_type_builddot.city)
	for k,v in pairs(tBuildDots) do
		if v.nCityId == nCityId then
			return v
		end
	end
	return nil
end


--获取任务
function WorldData:getTaskMsgByTPos(nType, nX, nY )
	local tTaskList = {}
	for k,v in pairs(self.tTasks) do
		if v.nType == nType then
			if v.nTargetX == nX and v.nTargetY == nY then
				table.insert(tTaskList, v)
			end
		end
	end
	return tTaskList
end

--获取任务
function WorldData:getTaskMsgs(  )
	return self.tTasks
end

--获取任务
function WorldData:getTaskMsgByUuid( sUuid)
	return self.tTasks[sUuid]
end

--获取当前显示最优cd的任务(行军中世界右下角显示cd的任务)
function WorldData:getShortestCdTask()
	-- body
	local nGoCd = nil
	local tGoTask = nil
	local nStayCd = nil
	local tStayTask = nil
	local nBackCd = nil
	local tBackTask = nil
	local tTaskMsgs = self.tTasks
	local nTaskCount = 0
	for k,v in pairs(tTaskMsgs) do
		nTaskCount = nTaskCount + 1
		if v.nState == e_type_task_state.go then
			if nGoCd then
				if v:getCd() < nGoCd  then
					nGoCd = v:getCd()
					tGoTask = v
				end
			else
				nGoCd = v:getCd()
				tGoTask = v
			end
		elseif v.nState == e_type_task_state.waitbattle or v.nState == e_type_task_state.collection or v.nState == e_type_task_state.garrison then
			if nStayCd then
				if v:getCd() < nStayCd  then
					nStayCd = v:getCd()
					tStayTask = v
				end
			else
				nStayCd = v:getCd()
				tStayTask = v
			end
		elseif v.nState == e_type_task_state.back then
			if nBackCd then
				if v:getCd() < nBackCd  then
					nBackCd = v:getCd()
					tBackTask = v
				end
			else
				nBackCd = v:getCd()
				tBackTask = v
			end
		end
	end
	--出征队列数量
	local tTaskMsg = tGoTask or tStayTask or tBackTask
	return tTaskMsg
end

--获取是否可以迁城
function WorldData:getIsCanMove( )
	if self.tTasks then
		return table.nums(self.tTasks) == 0
	end
	return true
end

--获取世界移动任务推送
function WorldData:getTaskMovePushs()
	return self.tTaskMovePushs
end

--获取世界移动任务推送
function WorldData:getTaskMovePushByUuid( sUuid)
	return self.tTaskMovePushs[sUuid]
end

--获取英雄状态列表
function WorldData:getHeroStateList( )
	local tRes = {}
	for k,tTask in pairs(self.tTasks) do
		table.insert(tRes, {tTask = tTask})
	end
	--根据创建时间来排序(后出征往上排)
	table.sort(tRes, function(a, b)
		return a.tTask.nCreateTime > b.tTask.nCreateTime
	end)

	local tHeroList = Player:getHeroInfo():getOnlineHeroList()
	for i=1,#tHeroList do
		local pHero = tHeroList[i]
		if self:getHeroState(pHero.nId) == e_type_task_state.idle then
			table.insert(tRes, {heroId = pHero.nId})
		end
	end
	return tRes
end

--获取英雄状态列表(区分不同队伍)
function WorldData:getHeroStateListByTeam( nTeamType )
	local tRes = {}
	for k,tTask in pairs(self.tTasks) do
		if tTask:getArmyTeam() == nTeamType then
			table.insert(tRes, {tTask = tTask})
		end
	end
	--根据创建时间来排序(后出征往上排)
	table.sort(tRes, function(a, b)
		return a.tTask.nCreateTime > b.tTask.nCreateTime
	end)

	local tHeroList = Player:getHeroInfo():getOnlineHeroListByTeam(nTeamType)
	for i=1,#tHeroList do
		local pHero = tHeroList[i]
		if self:getHeroState(pHero.nId) == e_type_task_state.idle then
			table.insert(tRes, {heroId = pHero.nId})
		end
	end
	return tRes
end

--获取英雄状态
function WorldData:getHeroState( nId )
	for k,tTask in pairs(self.tTasks) do
		if tTask.tArmyInTask[nId] then
			return tTask.nState
		end
	end
	return e_type_task_state.idle
end

--获取英雄所属的位置
function WorldData:getHeroInTask( nId )
	for k,tTask in pairs(self.tTasks) do
		if tTask.tArmyInTask[nId] then
			return tTask
		end
	end
	return nil
end

--获取我国国战列表(我所在的区域，按cd排序)
function WorldData:getMyCountryWarsList(  )
	local tRes = {}
	local nMyBlockId = self:getMyCityBlockId()
	for k,v in pairs(self.tMyCountryWars) do
		local tCityData = getWorldCityDataById(v.nId)
		if tCityData and tCityData.map == nMyBlockId then
			table.insert(tRes, v)
		end
	end
	table.sort(tRes, function ( a , b )
		return a:getCd() < b:getCd()
	end)
	return tRes
end

--获取我国国战中的数据
function WorldData:getMyCountryWar( sId )
	return self.tMyCountryWars[sId]
end

--判断系统城池国战是否有我国参与进攻
function WorldData:getSysCityIsMyCountryAtk( nCityId )
	for k,v in pairs(self.tMyCountryWars) do
		if v.nId == nCityId then
			if v.nAtkCountry == Player:getPlayerInfo().nInfluence then
				return true
			end
		end
	end
	return false
end

--判断系统城池国战是否有我国防守
function WorldData:getSysCityIsMyCountryDef( nCityId )
	for k,v in pairs(self.tMyCountryWars) do
		if v.nId == nCityId then
			if v.nDefCountry == Player:getPlayerInfo().nInfluence then
				return true
			end
		end
	end
	return false
end

--获取自己的驻守数据
function WorldData:getHelpMsgs( )
	return self.tHelpMsgs
end

--更新我的任务倒计时(到时间就关掉)
function WorldData:updateTaskCd( )
	--世界行军任务倒计时
	local tDelKeys = {} --删除标记
	local bIsShowBackTip = false
	for k,tTask in pairs(self.tTasks) do
		if tTask:getCd() == 0 and tTask.nState == e_type_task_state.back then
			table.insert(tDelKeys, k)
			bIsShowBackTip = true
		end
	end
	if #tDelKeys > 0 then
		for i=1,#tDelKeys do
			self.tTasks[tDelKeys[i]] = nil
		end
		sendMsg(gud_world_task_change_msg)
	end
	--弹出出征回来
	if bIsShowBackTip then
		TOAST(getTipsByIndex(20007))
	end
end

--更新世界行军倒计时(到时间就关掉)
function WorldData:updateTaskMovePushsCd( )
	--世界行军任务倒计时
	local tDelKeys = {} --删除标记
	for k,tTask in pairs(self.tTaskMovePushs) do
		if tTask:getCd() == 0 then
			table.insert(tDelKeys, k)
		end
	end
	if #tDelKeys > 0 then
		for i=1,#tDelKeys do
			self.tTaskMovePushs[tDelKeys[i]] = nil
		end
	end
end

--更新我国国战列表
function WorldData:updateMyCountryWarsCd( )
	--世界行军任务倒计时
	local tDelKeys = {} --删除标记
	for k,v in pairs(self.tMyCountryWars) do
		if v:getCd() == 0 then
			table.insert(tDelKeys, k)
		end
	end
	if #tDelKeys > 0 then
		for i=1,#tDelKeys do
			self.tMyCountryWars[tDelKeys[i]] = nil
		end
		sendMsg(gud_my_country_war_list_change)
	end
end

--更新我国世界Boss离开时间，时间开了就
function WorldData:updateBossLeaveCd( )
	local tBuildDots = self.tBuildDots[e_type_builddot.boss]
	if not tBuildDots then
		return
	end

	local tDelKeys = {}
	for k,tViewDotMsg in pairs(tBuildDots) do
		if tViewDotMsg:getBossLeaveCd() <= 0 then
			table.insert(tDelKeys, k)
			tBuildDots[k] = nil
		end
	end

	if #tDelKeys > 0 then
		sendMsg(ghd_world_boss_leave, tDelKeys)
	end
end

--更新纣王试炼离开时间
function WorldData:updateKingZhouLeaveCd( )
	local tBuildDots = self.tBuildDots[e_type_builddot.zhouwang]
	if not tBuildDots then
		return
	end

	local tDelKeys = {}
	for k,tViewDotMsg in pairs(tBuildDots) do
		if tViewDotMsg:getZhouWangLeaveCd() <= 0 then
			table.insert(tDelKeys, k)
			tBuildDots[k] = nil
		end
	end

	if #tDelKeys > 0 then
		sendMsg(ghd_world_kingzhou_leave, tDelKeys)
	end
end

--判断我国是否有都城
function WorldData:getIsHasCapital( )
	return self.nCapitalId ~= nil
end

--获取我国国战列表数字
function WorldData:getMyCountryWarNum(  )
	if self.tMyCountryWars then
		return table.nums(self.tMyCountryWars)
	end
	return 0
end

--获取与我国国战相关的
function WorldData:getMyCountryWarByCityId( nSysCityId )
	if self.tMyCountryWars then
		for k,v in pairs(self.tMyCountryWars) do
			if v.nId == nSysCityId then
				if v:getIsMyCountryJoin() then
					return true
				end
				break
			end
		end
	end
	return nil
end

--键盘输入框记录
function WorldData:getKeyBoardX( )
	if not self.tKeyBoardNumX then
		local nX, nY = Player:getWorldData():getMyCityDotPos()
		local sStr = tostring(nX)
		self.tKeyBoardNumX = {}
		local nLen = string.len(sStr)
		for i=1,nLen do
			table.insert(self.tKeyBoardNumX, string.sub(sStr,i, i))
		end
	end
	return self.tKeyBoardNumX
end

function WorldData:addKeyBoardXNum( nNum, bIsClear )
	if not self.tKeyBoardNumX or bIsClear then
		self.tKeyBoardNumX = {}
	end
	table.insert(self.tKeyBoardNumX, nNum)
end

function WorldData:delKeyBoardXNum(  )
	if self.tKeyBoardNumX then
		if #self.tKeyBoardNumX > 0 then
			table.remove(self.tKeyBoardNumX)
		end
	end
end

function WorldData:getKeyBoardY( tNum )
	if not self.tKeyBoardNumY then
		local nX, nY = Player:getWorldData():getMyCityDotPos()
		local sStr = tostring(nY)
		self.tKeyBoardNumY = {}
		local nLen = string.len(sStr)
		for i=1,nLen do
			table.insert(self.tKeyBoardNumY, string.sub(sStr,i, i))
		end
	end
	return self.tKeyBoardNumY
end

function WorldData:addKeyBoardYNum( nNum, bIsClear)
	if not self.tKeyBoardNumY or bIsClear then
		self.tKeyBoardNumY = {}
	end
	table.insert(self.tKeyBoardNumY, nNum)
end

function WorldData:delKeyBoardYNum(  )
	if self.tKeyBoardNumY then
		if #self.tKeyBoardNumY > 0 then
			table.remove(self.tKeyBoardNumY)
		end
	end
end

--nCityId:城市id,
--sName:名字
function WorldData:setCtiyName( nCityId, sName )
	local tBuildDots = self:getBuildDots(e_type_builddot.sysCity)
	local tViewDotMsg = tBuildDots[nCityId]
	if tViewDotMsg then
		tViewDotMsg:setCityName(sName)
		sendMsg(ghd_syscity_rename_success_msg)
	end
end

--获取系统城池数据
function WorldData:getSysCityDotById( nCityId )
	local tBuildDots = self:getBuildDots(e_type_builddot.sysCity)
	if tBuildDots[nCityId] then
		return tBuildDots[nCityId]
	end
	return nil
end

--保存右上角地图点击位置数据
-- local tData = {
-- 	nBlockId = nBlockId,
-- 	fViewCX = fViewCX,
-- 	fViewCY = fViewCY,
-- }
function WorldData:saveSamllMapClickedData( tData )
	self.tSamllMapClickedData = tData
end

function WorldData:getSamllMapClickedData(  )
	return self.tSamllMapClickedData
end

--列出所有区域中心城的占领信息
--tData List<MainCityOccupyVO>
function WorldData:setMainCityOccupyVOs( tData )
	if not tData then
		return
	end
	for i=1,#tData do
		local nCityId = tData[i].c
		if self.tMainCityOccupyVOs[nCityId] then
			self.tMainCityOccupyVOs[nCityId]:update(tData[i])
		else
			self.tMainCityOccupyVOs[nCityId] = MainCityOccupyVO.new(tData[i])
		end
	end
end

--推送区域中心城的占领信息
function WorldData:pushMainCityOccupyVO( tData )
	local nCityId = tData.c
	if self.tMainCityOccupyVOs[nCityId] then
		self.tMainCityOccupyVOs[nCityId]:update(tData)
	else
		self.tMainCityOccupyVOs[nCityId] = MainCityOccupyVO.new(tData)
	end
end

--获取区域中心城的占领国
--nCityId:城市id
function WorldData:getMainCityCaptureCountry( nCityId )
	local nCountry = nil
	if self.tMainCityOccupyVOs then
		if self.tMainCityOccupyVOs[nCityId] then
			nCountry = self.tMainCityOccupyVOs[nCityId].nCountry
		end
	end
	return nCountry or e_type_country.qunxiong
end

--记录进攻特效，发生变化时发送消耗显示或隐藏攻击特效 
function WorldData:updateTaskAtkEffect(  )
	local tTaskAtkEffect = {}
	--自己的任务
	for k,tTask in pairs(self.tTasks) do
		local nTaskType = tTask.nType
		local nTaskState = tTask.nState

		if nTaskType == e_type_task.wildArmy or 
			nTaskType == e_type_task.cityWar or
			nTaskType == e_type_task.countryWar then

			if nTaskState == e_type_task_state.go or
			 nTaskState == e_type_task_state.attack or 
			 nTaskState == e_type_task_state.waitbattle then

				if tTask:getCd() > 0 then
					
					local sDotKey = string.format("%s_%s", tTask.nTargetX, tTask.nTargetY)
					tTaskAtkEffect[sDotKey] = true

				end
			end
		end
	end
	--世界的行军任务
	for k,tTaskMovePush in pairs(self.tTaskMovePushs) do
		local nTaskState = tTaskMovePush.nState
		if nTaskState == e_type_task_state.go or
		 nTaskState == e_type_task_state.waitbattle then
			if tTaskMovePush:getCd() > 0 then

				local tViewDotMsg = self:getViewDotMsg(tTaskMovePush.nEndX, tTaskMovePush.nEndY)
				if tViewDotMsg then

					if tViewDotMsg.nType == e_type_builddot.sysCity or
						tViewDotMsg.nType == e_type_builddot.wildArmy then 
							
							local sDotKey = string.format("%s_%s", tTaskMovePush.nEndX, tTaskMovePush.nEndY)
							tTaskAtkEffect[sDotKey] = true
					end
				end
			end
		end
	end

	--判断特效列表是否发生改变
	if table.nums(self.tTaskAtkEffect) == table.nums(tTaskAtkEffect) then
		for k,v in pairs(tTaskAtkEffect) do
			if not self.tTaskAtkEffect[k] then
				self.tTaskAtkEffect = tTaskAtkEffect
				--发送消息
				sendMsg(ghd_world_dot_attack_effect)
				return
			end
		end
	else
		self.tTaskAtkEffect = tTaskAtkEffect
		--发送消息
		sendMsg(ghd_world_dot_attack_effect)
	end
end

--判断视图点是否显示攻击特效
function WorldData:getViewDotIsShowAtkEffect( nDotX, nDotY)
	if not nDotX or not nDotY then
		return false
	end

	local sDotKey = string.format("%s_%s", nDotX, nDotY)
	return self.tTaskAtkEffect[sDotKey] or false
end

--获取离我点最近的空白处
function WorldData:getNullPosNear( )
	--循环10次
	local nStep = 10
	local nLeftX  = self.nX 
	local nLeftY  = self.nY 
	local nRightX = self.nX 
	local nRightY = self.nY 
	while nStep ~= 0 do
		local nLeftX  = nLeftX - 1
		local nLeftY  = nLeftY - 1
		local nRightX = nRightX + 1
		local nRightY = nRightY + 1
		for nX = nLeftX, nRightX do
			for nY = nLeftY, nRightY do
				if nX > 0 and nX <= WORLD_GRID and nY > 0 and nY <= WORLD_GRID then
					if nX == nLeftX or nX == nRightX or nY == nLeftY or nY == nRightY then
						--不是装饰物
						local tDecorateData = getDecorateData(string.format("%s_%s", nX, nY))
						if not tDecorateData then
							--不是城池周围
							local bIsInAround = WorldFunc.checkIsSySCityAround(nX, nY)
							if not bIsInAround then
								--不是点
								local pDot = self:getViewDotMsg(nX, nY)
								if not pDot then
									return  nX, nY
								end
							end
						end
					end
				end
			end
		end
		nStep = nStep - 1
	end
	return nil
end

--获取离我城池最近的视图点
function WorldData:getViewDotMsgNear( nType, nLv)
	if not self.nX or not self.nY then
		return
	end

	local bIsMoBing = false
	if nType == e_type_builddot.mobing then --魔兵特殊处理
		nType = e_type_builddot.wildArmy
		bIsMoBing = true
	end

	if not self.tBuildDots[nType] then
		return
	end

	local pMyPos = cc.p(self.nX, self.nY)
	local sBestKey = nil
	local fBestDistance = nil
	local nLowLv = nil
	for k,tViewDotMsg in pairs(self.tBuildDots[nType]) do
		local bIsNeedChecked = true
		if bIsMoBing then --如果检测的是魔兵
			if not tViewDotMsg.bIsMoBing then
				bIsNeedChecked = false
			end
		end
		if bIsNeedChecked then
			if nLv == nil then
				if sBestKey then
					local nLv2 = tViewDotMsg:getDotLv()
					local fDistance2 = cc.pGetDistance(cc.p(tViewDotMsg.nX, tViewDotMsg.nY), pMyPos)
					if nLv2 < nLowLv  then
						sBestKey = k
						nLowLv = nLv2
						fBestDistance = fDistance2
					elseif nLv2 == nLowLv then
						if fDistance2 < fBestDistance then
							sBestKey = k
							nLowLv = nLv2
							fBestDistance = fDistance2
						end
					end
				else
					sBestKey = k
					nLowLv = tViewDotMsg:getDotLv()
					fBestDistance = cc.pGetDistance(cc.p(tViewDotMsg.nX, tViewDotMsg.nY), pMyPos)
				end
			else
				if tViewDotMsg:getDotLv() == nLv then
					if sBestKey then
						local fDistance = cc.pGetDistance(cc.p(tViewDotMsg.nX, tViewDotMsg.nY), pMyPos)
						if fDistance < fBestDistance then
							sBestKey = k
							fBestDistance = fDistance
							-- print("1sBestKey==========",sBestKey)
							-- print("1fBestDistance==========",fBestDistance)
						end
					else
						sBestKey = k
						-- print("0sBestKey==========",sBestKey)
						fBestDistance = cc.pGetDistance(cc.p(tViewDotMsg.nX, tViewDotMsg.nY), pMyPos)
						-- print("0fBestDistance==========",fBestDistance)
					end
				end
			end
		end
	end
	-- print("sBestKey=========",sBestKey)
	if sBestKey then
		return self.tBuildDots[nType][sBestKey]
	end
	return nil
end

--重建获得的物资
function WorldData:getRebuildReward( )
	return self.tRebuildReward
end

--清空重建的物资(防止断线重联时进来)
function WorldData:clearRebuildReward( )
	self.tRebuildReward = nil
end

--获取是否高级重建
function WorldData:getIsSuperReBuild(  )
	return self.bIsSuperReBuild
end

--设置我的当前目标
function WorldData:setMyWorldTargetId( tData )
	if tData then
		self.nMyWorldTargetId = tData
		sendMsg(gud_my_world_target_refresh)
	end
end

--获取我的当前目标
function WorldData:getMyWorldTargetId(  )
	return self.nMyWorldTargetId
end

-- --获取世界Boss是否存在
-- function WorldData:getWorldBossExist(  )
-- 	return self.nWorldBossExist == 1
-- end

-- --设置世界Boss是否存在
-- function WorldData:setWorldBossExist( tData )
-- 	if tData then
-- 		self.nWorldBossExist = tData
-- 	end
-- end

--获取世界BossVo
function WorldData:getWorldBossVo(  )
	return self.tWorldBossVO
end

--设置世界BossVo
function WorldData:setWorldBossVo( tData )
	if tData then
		self.tWorldBossVO = WorldBossVO.new(tData)
		sendMsg(gud_world_target_boss_refresh)
	end
end

--获取世界目标击杀乱军
function WorldData:getWildArmyKill(  )
	return self.nWildArmyKill
end

--设置世界目标击杀乱军
function WorldData:setWildArmyKill( tData )
	if tData then
		self.nWildArmyKill = tData
		sendMsg(gud_world_target_wild_amry_kill_refresh)
	end
end


--获取世界目标最高
function WorldData:getWorldTargetId(  )
	return self.nWorldTargetId
end

--设置世界目标最高
function WorldData:setWorldTargetId( tData )
	if tData then
		self.nWorldTargetId = tData
		--形成可见字典，减少运算
		self:refreshBlockCanSee()
		--形成迁城字典，减少运算
		self:refreshBlockCanMigrate()
		
		sendMsg(gud_world_target_top_refresh)
	end
end

--设置冥王入侵GhostWarVo
function WorldData:setGhostWarVo( tData )
	if tData then
		self.tGhostWarVO = GhostWarVO.new(tData)
		-- sendMsg(gud_world_target_boss_refresh)
		sendMsg(gud_my_city_war_list_change)
		
	end
end
--获取冥王入侵提醒列表
function WorldData:getGhostWarVo(  )
	return self.tGhostWarVO
end


--获取已消耗迁城消耗
function WorldData:getUsedMoveCity(  )
	return self.tUsedMoveCity
end

--获取已消耗迁城消耗
function WorldData:setUsedMoveCity( tData )
	self.tUsedMoveCity = tData
end

--是否已使用首次前往州迁城道具
function WorldData:getIsUsedMoveCity( nTargetId )
	if self.tUsedMoveCity then
		for i=1,#self.tUsedMoveCity do
			if self.tUsedMoveCity[i] == nTargetId then
				return true
			end
		end
	end
	return false
end

--设置不能攻打的都城
function WorldData:setNoAttackCapital( tData )
	self.nNoAttackCapital = tData
end

--获取不能国战的都城
function WorldData:getNoAttackCapital( )
	return self.nNoAttackCapital
end

--获取今天是否已经打过世界Boss
function WorldData:getIsAttackedBoss(  )
	return self.nAttakedBoss == 1
end

--设置今天是否已经打过世界Boss
function WorldData:setAttackedBoss( tData )
	if not tData then
		return
	end
	self.nAttakedBoss = tData
end

--设置都城占领信息
function WorldData:setCapitalInfo( tData )
	if not tData then
		return
	end
	for i=1,#tData do
		self.tCapitalInfo[tData[i].k] = tData[i].v
	end
	sendMsg(gud_world_target_capital_refresh)
end

--设置当天已经使用的免费迁城次数
function WorldData:setTodayFreeChangeCity( tData )
	-- body
	if not tData then
		return
	end
	self.nMzt = tData
	sendMsg(ghd_refresh_freetostate_msg)
end
--获取当天剩余的免费迁城次数
function WorldData:getTodayFreeChangeCityTimes( )
	-- body
	local nMax = tonumber(getWorldInitData("maxFreeMigrate2Zhou"))
	if not self.nMzt then
		return nMax
	else
		return nMax - self.nMzt
	end	
end


--判断都城是否占领
function WorldData:getAllCapitalIsCapture( )
	return table.nums(self.tCapitalInfo) >= 3
end

--获取都城占领信息
function WorldData:getCapitalInfo( )
	return self.tCapitalInfo
end

--是否可以领取世界目标乱军奖励
function WorldData:getIsCanGetWTWildArmyReward( )
	local nMyTargetId = self:getMyWorldTargetId()
	if not nMyTargetId then
		return false
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return false
	end

	--乱军奖励
	if tWorldTargetData.nTargetType == e_type_world_target.wildArmy then
		if  self:getWildArmyKill() >= tWorldTargetData.nTargetValue then
			return true
		end
	end
	return false
end

--是否可以领取世界目标攻打城池奖励
function WorldData:getIsCanGetWTSysCityReward(  )
	local nMyTargetId = self:getMyWorldTargetId()
	if not nMyTargetId then
		return false
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return false
	end

	--攻打系统城池
	if tWorldTargetData.nTargetType == e_type_world_target.sysCity then
		--世界任务比当前任务高
		local nWorldTargetId = self:getWorldTargetId()
		if nWorldTargetId and nWorldTargetId > nMyTargetId then
			return true
		end
	end
	return false
end

--是否可以领取世界目标都城奖励
function WorldData:getIsCanGetWTCapitalReward(  )
	local nMyTargetId = self:getMyWorldTargetId()
	if not nMyTargetId then
		return false
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return false
	end

	--攻打都城
	if tWorldTargetData.nTargetType == e_type_world_target.capital then
		--世界任务比当前任务高
		local nWorldTargetId = self:getWorldTargetId()
		if nWorldTargetId and nWorldTargetId > nMyTargetId then
			return true
		end
	end
	return false
end

--更新区域视图点信息
--nBlockId: 区域id
--tArroundDots: 视图点集
--tNullGrid: 清除视图点
function WorldData:updateBlockDots( nBlockId, tArroundDots, tNullGrid)
	if tNullGrid then
		for k,sDotKey in pairs(tNullGrid) do
			if self.tBlockDots[nBlockId] then
				self.tBlockDots[nBlockId][sDotKey] = nil
			end
			if self.tBlockBoss[nBlockId] then
				self.tBlockBoss[nBlockId][sDotKey] = nil
			end
			if self.tBlockZhou[nBlockId] then
				self.tBlockZhou[nBlockId][sDotKey] = nil
			end
		end
	end

	--更新区域信息(为了实现更新小地图信息)
	local tBlockCityDots = nil
	local tBlockSysCityDots = nil
	local tBlockBossDots = nil
	local tBlockZhouDots = nil
	if tArroundDots then
		for k,v in pairs(tArroundDots) do
			if v.nType == e_type_builddot.city then
				if self.tBlockDots[nBlockId] then
					if tBlockCityDots == nil then
						tBlockCityDots = {}
					end
					local tDot = Dot.new(nil, v)
					self.tBlockDots[nBlockId][tDot.sDotKey] = tDot
					table.insert(tBlockCityDots, tDot)
				end
			elseif v.nType == e_type_builddot.sysCity then
				if self.tBlockSCOI[nBlockId] then
					if tBlockSysCityDots == nil then
						tBlockSysCityDots = {}
					end
					local tDot = SystemcityOcpyInfo.new(nil, v)
					self.tBlockSCOI[nBlockId][v.nSystemCityId] = tDot
					table.insert(tBlockSysCityDots, tDot)
				end
			elseif v.nType == e_type_builddot.boss then
				if self.tBlockBoss[nBlockId] then
					if tBlockBossDots == nil then
						tBlockBossDots = {}
					end
					local tDot = BossLocation.new(nil, v)
					self.tBlockBoss[nBlockId][tDot.sDotKey] = tDot
					table.insert(tBlockBossDots, tDot)
				end
			elseif v.nType == e_type_builddot.zhouwang then	
				if self.tBlockZhou[nBlockId] then
					if tBlockZhouDots == nil then
						tBlockZhouDots = {}
					end
					local tDot = KingZhouLoction.new(nil, v)
					self.tBlockZhou[nBlockId][tDot.sDotKey] = tDot
					table.insert(tBlockZhouDots, tDot)
				end						
			end
		end
	end

	--视图点更新指定的视图点信息
	sendMsg(ghd_smallmap_search_around_msg, {nBlockId, tNullGrid, tBlockCityDots, tBlockSysCityDots, tBlockBossDots, tBlockZhouDots})
end

--区域是否解锁
--nX,nY:视图点坐标
function WorldData:getBlockIsCanSeeByPos( nX, nY )
	local nBlockId = WorldFunc.getBlockId(nX, nY)
	if nBlockId then
		return self:getBlockIsCanSee(nBlockId)
	end
	return false
end

--获取是否查看地图
--郡	所在地
--开州 (郡	所有的州，归属本州的两个郡,州	所有的州，归属本州的两个郡)
--开启阿房宫 郡	所有区域,州	所有的州，州	所有区域, 阿房宫	所有区域)
function WorldData:getBlockIsCanSee( nBlockId )
	if not nBlockId then
		return false
	end
	return self.tCanSeeBlock[nBlockId] or false
end

--获取世界开启阶段（获取玩法阶段）
--return --0开郡,--1开州,--2开皇城
function WorldData:getWorldOpenState( )
	local nState = 0
	local nWorldTargetId = self:getWorldTargetId()
	if nWorldTargetId then
		local nTargetId = nWorldTargetId - 1
		local tTargetData = getWorldTargetData(nTargetId)
		if tTargetData then
			nState = tTargetData.stateba 
		end
	end
	return nState
end

--刷新可见区域
function WorldData:refreshBlockCanSee(  )
	--地图开的状态
	local nState = self:getWorldOpenState()

	--是否可见
	local function isCanSee( nBlockId )
		local nMyBlockId = self:getMyCityBlockId()
		if nState == 0 then--0开郡
			return nMyBlockId == nBlockId
		elseif nState == 1 then--1开州
			--自己所属于的州
			local nMyZhouId = nil
			local tBlockData = getWorldMapDataById(nMyBlockId)
			if tBlockData then
				if tBlockData.type == e_type_block.kind then
					--容错，还没有开启皇城，不可能进入这里
					return true
				elseif tBlockData.type == e_type_block.jun then
					nMyZhouId = tBlockData.subordinate
				elseif tBlockData.type == e_type_block.zhou then
					nMyZhouId = nMyBlockId
				end
			end
			--遍历所有的区域数据
			local tBlockDatas = getWorldMapData()
			for k,v in pairs(tBlockDatas) do
				--所有的州或从属州的郡
				if v.type == e_type_block.zhou or v.subordinate == nMyZhouId then
					if v.id == nBlockId then
						return true
					end
				end
			end
		elseif nState == 2 then--2开皇城
			return true
		end
		return false
	end

	--字典
	self.tCanSeeBlock = {}
	--遍历所有的区域数据
	local tBlockDatas = getWorldMapData()
	for nBlockId,v in pairs(tBlockDatas) do
		local bIsCanSee = isCanSee(nBlockId)
		if bIsCanSee then
			self.tCanSeeBlock[nBlockId] = true
			-- --test---
			-- self.tCanSeeBlock[nBlockId]=false
		end
	end
	-- dump(self.tCanSeeBlock)

end


--区域是否迁移
--玩法阶段	玩家所在	查看地图	迁移范围
--郡
--郡		郡			所在地		所在地
--州
--郡	所有的州，归属本州的两个郡	本州，归属本州的两个郡
--州	所有的州，归属本州的两个郡	本州，归属本州的两个郡
--阿房宫
--郡	所有区域	所有区域
--州	所有区域	所有区域
--阿房宫	所有区域	所有区域
function WorldData:getBlockIsCanMigrate( nBlockId )
	if not nBlockId then
		return false
	end
	return self.tCanMigrateBlock[nBlockId] or false
end

--刷新可迁移区域
function WorldData:refreshBlockCanMigrate(  )
	--地图开的状态
	local nState = self:getWorldOpenState()

	--是否可以迁移
	local function isCanMigrate( nBlockId )
		local nMyBlockId = self:getMyCityBlockId()
		if nState == 0 then--0开郡
			return nMyBlockId == nBlockId
		elseif nState == 1 then--1开州
			--自己所属于的州
			local nMyZhouId = nil
			local tBlockData = getWorldMapDataById(nMyBlockId)
			if tBlockData then
				if tBlockData.type == e_type_block.kind then
					--容错，还没有开启皇城，不可能进入这里
					return true
				elseif tBlockData.type == e_type_block.jun then
					nMyZhouId = tBlockData.subordinate
				elseif tBlockData.type == e_type_block.zhou then
					nMyZhouId = nMyBlockId
				end
			end

			--本州
			if nBlockId == nMyZhouId then
				return true
			end
			--遍历所有的区域数据
			--归属本州的两个郡
			local tBlockDatas = getWorldMapData()
			for k,v in pairs(tBlockDatas) do
				if v.subordinate == nMyZhouId then
					if v.id == nBlockId then
						return true
					end
				end
			end
		elseif nState == 2 then--2开皇城
			return true
		end
		return false
	end

	--字典
	self.tCanMigrateBlock = {}
	--遍历所有的区域数据
	local tBlockDatas = getWorldMapData()
	for nBlockId,v in pairs(tBlockDatas) do
		local bIsCanSee = isCanMigrate(nBlockId)
		if bIsCanSee then
			self.tCanMigrateBlock[nBlockId] = true
		end
	end
end

--根据位置判断,是否可以开启城战，或国战
--视图点坐标,nDotX, nDotY 
--战争类型 nWarType
function WorldData:getIsCanWarByPos( nDotX, nDotY, nWarType)
	--[[
	玩法阶段	玩家所在	城战		发起国战	参与国战
	郡			郡			所在地		所在地		所在地

	开州		郡			所在地		所在地		所在地
				州			所在地		所在地		所有州

	开启阿房宫	郡			所在地		所在地		所在地
				州			所有州		所有州		所有州
				阿房宫		所有区域	所在地		所有区域]]

	--容错
	local nMyBlockId = self:getMyCityBlockId()
	if not nMyBlockId then
		return false
	end
	
	local nTargetBlockId = WorldFunc.getBlockId(nDotX, nDotY)
	if not nTargetBlockId then
		return false
	end

	--Boss不可以跨区
	if nWarType == e_war_type.boss then
		return nMyBlockId == nTargetBlockId
	end

	--地图开的状态
	local nState = self:getWorldOpenState()

	if nState == 0 then --0开郡
		local tBlockData = getWorldMapDataById(nMyBlockId)
		if tBlockData then
			if tBlockData.type == e_type_block.jun then--郡
				if nMyBlockId == nTargetBlockId then
					return true
				end
			end
		end
	elseif nState == 1 then --1开州
		local tBlockData = getWorldMapDataById(nMyBlockId)
		if tBlockData then
			if tBlockData.type == e_type_block.jun then--郡
				if nMyBlockId == nTargetBlockId then
					return true
				end
			elseif tBlockData.type == e_type_block.zhou then--州
				if e_war_type.city == nWarType then
					-- if nMyBlockId == nTargetBlockId then
					-- 	return true
					-- end
					local tTargetBlockData = getWorldMapDataById(nTargetBlockId)
					if tTargetBlockData then
						if tTargetBlockData.type == e_type_block.zhou then--州
							return true
						end
					end					
				elseif e_war_type.countryStart == nWarType then
					-- if nMyBlockId == nTargetBlockId then
					-- 	return true
					-- end
					local tTargetBlockData = getWorldMapDataById(nTargetBlockId)
					if tTargetBlockData then
						if tTargetBlockData.type == e_type_block.zhou then--州
							return true
						end
					end					
				elseif e_war_type.country == nWarType then
					local tTargetBlockData = getWorldMapDataById(nTargetBlockId)
					if tTargetBlockData then
						if tTargetBlockData.type == e_type_block.zhou then--州
							return true
						end
					end
				end

			end
		end
	elseif nState == 2 then --2开皇城
		local tBlockData = getWorldMapDataById(nMyBlockId)
		if tBlockData then
			if tBlockData.type == e_type_block.jun then--郡
				if nMyBlockId == nTargetBlockId then
					return true
				end
			elseif tBlockData.type == e_type_block.zhou then--州
				local tTargetBlockData = getWorldMapDataById(nTargetBlockId)
				if tTargetBlockData then
					if tTargetBlockData.type == e_type_block.zhou then--州
						return true
					end
				end
			elseif tBlockData.type == e_type_block.kind then--皇城
				if e_war_type.city == nWarType then
					return true
				elseif  e_war_type.countryStart == nWarType then
					local tTargetBlockData = getWorldMapDataById(nTargetBlockId)
					if tTargetBlockData then
						if nMyBlockId == nTargetBlockId then
							return true
						end
					end
				elseif e_war_type.country == nWarType then
					return true
				end
			end
		end
	end

	return false
end

--获取我的城战信息按cd排列
function WorldData:getMyCityWarMsgs()
	local tRes = {}
	if self.tMyCityWarMsgs then
		for i=1,#self.tMyCityWarMsgs do
			if self.tMyCityWarMsgs[i]:checkTargetIsMe() then
				table.insert(tRes, self.tMyCityWarMsgs[i])
			end
		end
	end
	-- if self.tGhostWarVO and self.tGhostWarVO:getCd()>0 then
	-- 	if self.tGhostWarVO:checkTargetIsMe() then
	-- 		table.insert(tRes, self.tGhostWarVO)
	-- 	end
	-- end
	return tRes
end

--设置我的城战信息
function WorldData:setMyCityWarMsgs( tCityWarMsgs )
	self.tMyCityWarMsgs = tCityWarMsgs
end

--获取我的uuid
function WorldData:getMyCityWarByUuid( sWarId )
	if not self.tMyCityWarMsgs then
		return
	end
	for i=1,#self.tMyCityWarMsgs do
		if self.tMyCityWarMsgs[i].sWarId == sWarId then
			return self.tMyCityWarMsgs[i]
		end
	end
	return nil
end

--推送我的城战信息
function WorldData:addMyCityWarMsg( tCityWarMsg )
	if not tCityWarMsg then
		return
	end

	if not self.tMyCityWarMsgs then
		self.tMyCityWarMsgs = {}
	end

	local bIsNew = true
	for i=1,#self.tMyCityWarMsgs do
		if self.tMyCityWarMsgs[i].sWarId == tCityWarMsg.sWarId then
			self.tMyCityWarMsgs[i] = tCityWarMsg
			bIsNew = false
			break
		end
	end
	if bIsNew then
		table.insert(self.tMyCityWarMsgs, tCityWarMsg)
	end
	--排序
	table.sort(self.tMyCityWarMsgs, function ( a , b )
		return a:getCd() < b:getCd()
	end)
end

--更新我国国战列表
function WorldData:updateMyCityWarsCd( )
	if not self.tMyCityWarMsgs then
		return
	end
	local bIsDel = false
	local tMyCityWarMsgs = {}
	for i=1,#self.tMyCityWarMsgs do
		if self.tMyCityWarMsgs[i]:getCd() > 0 then
			table.insert(tMyCityWarMsgs, self.tMyCityWarMsgs[i])
		else
			bIsDel = true
		end
	end
	if bIsDel then
		self.tMyCityWarMsgs = tMyCityWarMsgs
		sendMsg(gud_my_city_war_list_change)
	end
end


--获取友军驻防列表
function WorldData:getFriendArmys( )
	return self.tComingHelpVOs or {}
end

--设置友军驻防数据
function WorldData:setFriendArmys( tData )
	if not tData then
		return
	end
	self.tComingHelpVOs = {}
	for i=1,#tData do
		table.insert(self.tComingHelpVOs, ComingHelpVO.new(tData[i]))
	end
end

--推送我的城战信息
function WorldData:addFriendArmy( tData )
	if not tData then
		return
	end

	if not self.tComingHelpVOs then
		self.tComingHelpVOs = {}
	end
	local tComingHelpVO = ComingHelpVO.new(tData)
	local bIsNew = true
	for i=1,#self.tComingHelpVOs do
		if self.tComingHelpVOs[i].sUuid == tComingHelpVO.sUuid then
			self.tComingHelpVOs[i] = tComingHelpVO
			bIsNew = false
			break
		end
	end
	if bIsNew then
		table.insert(self.tComingHelpVOs, tComingHelpVO)
	end
end

--推送我的城战信息
function WorldData:subFriendArmy( tData )
	if not tData then
		return
	end
	local tComingHelpVO = ComingHelpVO.new(tData)
	for i=1,#self.tComingHelpVOs do
		if self.tComingHelpVOs[i].sUuid == tComingHelpVO.sUuid then
			table.remove(self.tComingHelpVOs, i)
			break
		end
	end
end

--更新我国国战列表
function WorldData:updateFriendArmysCd( )
	if not self.tComingHelpVOs then
		return
	end
	local bIsDel = false
	local tComingHelpVOs = {}
	for i=1,#self.tComingHelpVOs do
		--cd一过就关掉
		if self.tComingHelpVOs[i]:getCd() > 0 then
			table.insert(tComingHelpVOs, self.tComingHelpVOs[i])
		else
			bIsDel = true
		end
	end
	if bIsDel then
		self.tComingHelpVOs = tComingHelpVOs
		sendMsg(gud_friend_army_list_change)
	end
end


--是否正处于攻打乱军前往状态
function WorldData:isGoAheadState()
	-- body
	for k, v in pairs(self.tTasks) do
		if v.nType == 2 and v.nState == 1 then
			return true
		end
	end
	return false
end

--武将全部出征
function WorldData:getIsAllBattleAuto()
	return getSettingInfo("AllHeroBattle") == "1"
end

--武将全部出征
function WorldData:setIsAllBattleAuto( bIsAuto )
	local sOpenValue = "0"
	if bIsAuto then
		sOpenValue = "1"
	end
	saveLocalInfo("AllHeroBattle"..Player:getPlayerInfo().pid, sOpenValue)
end

--设置上一个搜索点
function WorldData:setPrevSearchDot( nX, nY)
	self.pPrevSearchDot = cc.p(nX, nY)
end

--设置上一次搜索点
function WorldData:getPrevSearchDot( )
	return self.pPrevSearchDot
end

--清容上一次搜索点
function WorldData:clearPrevSearchDot( )
	self.pPrevSearchDot = nil
end

--设置世界地图乱军特效等级
function WorldData:setWildArmyCirEffectLv( nLv )
	self.nWildArmyCirEffectLv = nLv
end

--获取世界地图乱军特效特级
function WorldData:getWildArmyCirEffectLv( )
	return self.nWildArmyCirEffectLv
end

--设置请求区域视图点信息秒数
function WorldData:setLoadBlockSecond( nSecond )
	self.nLoadBlockSecond = nSecond
end

--获取请求区域视图点信息秒数
function WorldData:getLoadBlockSecond( )
	return self.nLoadBlockSecond
end

--获取指定区域视图点请求数据的时间
function WorldData:getBlockReqTime( nBlockId )
	return self.tBlockReqTime[nBlockId]
end

--更新指定区域视图点请求数据的时间
function WorldData:setBlockReqTime( nBlockId )
	self.tBlockReqTime[nBlockId] = getSystemTime()
end

--获取是否需要请求数
function WorldData:getIsNeedReqBlock( nBlockId )
	local nPrevTime = self:getBlockReqTime(nBlockId)
	if nPrevTime then
		return (getSystemTime() - nPrevTime) >= 60 
	end
	return true
end

--获取行军召回vip免费召回次数
function WorldData:getVipFreeCall( )
	local nNum = 0
	local tVipData = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
	if tVipData then
	 	nNum = math.max(tVipData.freemarchback - self.nVipFreeCalled, 0)
	end
	return nNum
end

function WorldData:getCountryFightTaskPos( _nCityKind )
	-- body
	local tSysCityData = getWorldCityData()
	local nMyBlockId = self:getMyCityBlockId()
	local nX, nY = self:getMyCityDotPos()
	local tCitys = {}
	if _nCityKind then
		for k, v in pairs(tSysCityData) do
			if nMyBlockId == v.map and v.kind == _nCityKind then
				table.insert(tCitys, v)
			end
		end
	end
	-- 
	function calDis( a, x, y )
		-- body
		return math.pow(a.tCoordinate.x - x, 2) + math.pow(a.tCoordinate.y - y, 2)
	end
	--dump(tCitys, "tCitys", 100)
	if #tCitys > 0 then
		table.sort(tCitys, function ( a, b )
			-- body
			return calDis(a, nX, nY) < calDis(b, nX, nY)
		end)
		return tCitys[1] 
	end	
	return nil
end

--根据位置获取Boss
function WorldData:getBossViewDotByPos( nX, nY)
	if not self.tBuildDots[e_type_builddot.boss] then
		return
	end
	local sDotKey = string.format("%s_%s", nX, nY)
	return self.tBuildDots[e_type_builddot.boss][sDotKey]
end

--获取是否播放乱军动画中
function WorldData:setWArmyFightPos( sDotKey, bIsPlay)
	self.tWArmyFightPos[sDotKey] = bIsPlay
end

--判断是否播放乱军动画中
function WorldData:getPosIsWArmyFight( sDotKey )
	return self.tWArmyFightPos[sDotKey] or false
end

--获取被攻击的点
function WorldData:getBeAttackPos( )
	return self.nBeAttackX, self.nBeAttackY
end

--设置播放标记特点
function WorldData:setIsNewBoss( sDotKey, bIsNew)
	self.tNewBossDict[sDotKey] = bIsNew
end

--获取是否新的Boss
function WorldData:getIsNewBoss( sDotKey )
	return self.tNewBossDict[sDotKey]
end

--设置离线获得的奖励
function WorldData:setOffLineReward( tData)
	if not tData then
		return
	end
	self.tOffLineReward = tData
end

--清空离线物品(防止断线重联时进来)
function WorldData:clearOffLineReward( )
	self.tOffLineReward = nil
end

--离线获得物品
function WorldData:getOffLineReward( )
	return self.tOffLineReward
end
 
---------------------------城池首杀
function WorldData:getCFBloodClose( )
	return self.bCFBloodClose
end

function WorldData:setCFBloodClose( bIsClose )
	self.bCFBloodClose = bIsClose
end

function WorldData:setCityFirstBlood( tData )
	if not tData then
		return
	end
	self.tCityFirstBloodDict = {}
	for i=1,#tData do
		local tCFBloodVo = CityFirstBloodVO.new(tData[i])
		local nKind = tCFBloodVo.nCityType
		local nSysCityId = tCFBloodVo.nSysCityId
		local tCityData = getWorldCityDataById(nSysCityId)
		if tCityData then
			local nBlockId = tCityData.map
			local sKey = string.format("%s_%s",nBlockId, nKind)
			self.tCityFirstBloodDict[sKey] = tCFBloodVo
		end
	end
end

--获取首杀记录
function WorldData:getCityFirstBlood( nKind, nBlockId )
	if not nKind or not nBlockId then
		return
	end
	local sKey = string.format("%s_%s",nBlockId, nKind)
	return self.tCityFirstBloodDict[sKey]
end

--更新首杀记录
function WorldData:updateCityFirstBlood( tData )
	if not tData then
		return
	end
	local nKind = tData.ct
	if not nKind then
		return
	end
	local nSysCityId = tData.id
	if not nSysCityId then
		return
	end
	local tCityData = getWorldCityDataById(nSysCityId)
	if not tCityData then
		return
	end
	local nBlockId = tCityData.map

	local sKey = string.format("%s_%s",nBlockId, nKind)
	if self.tCityFirstBloodDict[sKey] then
		self.tCityFirstBloodDict[sKey]:update(tData)
	else
		self.tCityFirstBloodDict[sKey] = CityFirstBloodVO.new(tData)
	end
end

--是否是新的首杀记录
function WorldData:getIsNewCFBlood( nKind, nBlockId )
	if not nKind or not nBlockId then
		return
	end
	local sKey = string.format("%s_%s",nBlockId, nKind)
	if not self.tCityFirstBloodDict[sKey] then
		return false
	end

	local sKey = string.format("%s_%s_cfblood_new", Player:getPlayerInfo().pid, sKey)
	if not self.tCFBloodNewLocal[sKey] then
		local sLocal = getLocalInfo(sKey, "")
		self.tCFBloodNewLocal[sKey] = sLocal
	end
	if self.tCFBloodNewLocal[sKey] == "1" then
		return false
	end
	return true
end

--添加已阅首杀本地记录
function WorldData:addNewLocalCFBlood( nKind, nBlockId)
	if not nKind or not nBlockId then
		return
	end
	local sKey = string.format("%s_%s",nBlockId, nKind)
	--没有数据不记录
	if not self.tCityFirstBloodDict[sKey] then
		return
	end
	--已记录的不操作
	local sKey = string.format("%s_%s_cfblood_new", Player:getPlayerInfo().pid, sKey)
	self.tCFBloodNewLocal[sKey] = "1"
	sendMsg(gud_city_first_blood_red)
end

--一次性写入本地
function WorldData:flushNewLocalCFBlood( )
	local tData = {}
	for k,v in pairs(self.tCFBloodNewLocal) do
		if v == "1" then
			tData[k] = v
		end
	end
	saveLocalInfoList(tData)
end

--获取区域首杀
function WorldData:getFirstBloodsInBlock( nBlockId )
	local tRes = {}
	for k,v in pairs(self.tCityFirstBloodDict) do
		if v:getBlockId() == nBlockId then
			table.insert(tRes, v)
		end
	end
	return tRes
end

--获取区域首杀最高
function WorldData:getFirstBloodTopInBlock( nBlockId )
	local tData = nil
	for k,v in pairs(self.tCityFirstBloodDict) do
		if v:getBlockId() == nBlockId then
			if tData then
				if tData:getKind() < v:getKind() then
					tData = v
				end
			else
				tData = v
			end
		end
	end
	return tData
end

--获取首杀红点记录标识
function WorldData:getFirstBloodRed(  )
	local bIsHas = false
	for k,v in pairs(self.tCityFirstBloodDict) do
		local sKey = string.format("%s_%s_cfblood_new", Player:getPlayerInfo().pid, k)
		if not self.tCFBloodNewLocal[sKey] then
			local sLocal = getLocalInfo(sKey, "")
			self.tCFBloodNewLocal[sKey] = sLocal
		end
		if self.tCFBloodNewLocal[sKey] == "1" then
		else
			bIsHas = true
		end
	end
	return bIsHas
end

--获取首杀红点记录
function WorldData:getFirstBloodRedInBlock( _nBlockId )
	local bIsHas = false
	for k,v in pairs(self.tCityFirstBloodDict) do
		local tKey = luaSplit(k, "_")
		if tKey and tKey[1] then
			local nBlockId = tonumber(tKey[1])
			if nBlockId == _nBlockId then
				local sKey = string.format("%s_%s_cfblood_new", Player:getPlayerInfo().pid, k)
				if not self.tCFBloodNewLocal[sKey] then
					local sLocal = getLocalInfo(sKey, "")
					self.tCFBloodNewLocal[sKey] = sLocal
				end
				if self.tCFBloodNewLocal[sKey] == "1" then
				else
					bIsHas = true
				end
			end
		end
	end
	return bIsHas
end

-------------------------世界搜索
--获取世界搜索上一次的目标
function WorldData:getWorldSearchTypePrev( )
	return self.nWorldSearchTypePrev or e_type_search.wildArmy
end

--设置世界搜索上一次的目标
function WorldData:setWorldSearchType( nType )
	self.nWorldSearchTypePrev = nType
end

--获取世界搜索上一次的记录
--nType :目标类型
function WorldData:getWorldSearchLvPrev( nType)
	return self.tWorldSearch[nType] or 1
end

--设置世界搜索记录
--nType:搜索类型
--nLv: 目标等级
function WorldData:setWorldSearchLv( nType, nLv )
	self.tWorldSearch[nType] = nLv
end

--获取当前区域显示上下限
--nType:搜索类型
function WorldData:getWorldSearchLvRange( nType )
	--策划吴航说写死,除非热三改了
	--单位可选择等级上限与下限由玩家所在区域决定							
	--郡：乱军1-22级，不存在资源田（置灰，点击时跳字提醒“到达州城后开启”）							
	--州：乱军1-22级，金矿5-7级，其他资源田4-7级							
	--阿房宫：乱军1-22级，所有资源田8-10级							
	local tData = {
		[e_type_block.jun] = {
			[e_type_search.wildArmy] = {1, 22},
		},
		[e_type_block.zhou] = {
			[e_type_search.wildArmy] = {1, 22},
			[e_type_search.inn]  = {4, 7},
			[e_type_search.mill] = {4, 7},
			[e_type_search.farm] = {4, 7},
			[e_type_search.iron] = {4, 7},
			[e_type_search.gold] = {5, 7},
		},
		[e_type_block.kind] = {
			[e_type_search.wildArmy] = {1, 22},
			[e_type_search.inn]  = {8, 10},
			[e_type_search.mill] = {8, 10},
			[e_type_search.farm] = {8, 10},
			[e_type_search.iron] = {8, 10},
			[e_type_search.gold] = {8, 10},
		},
	}

	local nBlockId = self:getMyCityBlockId()
	local tBlockData = getWorldMapDataById(nBlockId)
	if tBlockData then
		if tData[tBlockData.type] then
			return tData[tBlockData.type][nType]
		end
		return nil
	end
	return nil
end


--设置已请求刷新任务乱军的任务ID集合
function WorldData:setWildArmyMids(tmids)
	if not self.tMids then
		self.tMids = {}
	end
	self.tMids = tmids or {}
end

function WorldData:getWildArmyMids( )
	-- body
	return self.tMids
end
--是否可以请求刷新任务乱军 _nMissionID 任务ID
function WorldData:isCanReqTaskWildArmy( _nMissionID )
	-- body
	if not _nMissionID then
		return false
	end
	if self.tMids and #self.tMids > 0 then
		for k, v in pairs(self.tMids) do
			if _nMissionID == tonumber(v or 0) then
				return false
			end
		end
	end
	return true
end

--判断是否有正在驻战的限时Boss任务
function WorldData:getHasWaitBattleTask( nTaskType, nX, nY)
	local nBlockId = WorldFunc.getBlockId(nX, nY)
	for k,v in pairs(self.tTasks) do
		if v.nState == e_type_task_state.waitbattle then
			if nTaskType == e_type_task.tlboss then
				if WorldFunc.getBlockId(v.nTargetX, v.nTargetY) == nBlockId then
					return true
				end
			end
		end
	end
	return false
end

--判断是否有正在驻战的限时Boss任务
function WorldData:getHasJoinTLBoss( nX, nY )
	local nBlockId = WorldFunc.getBlockId(nX, nY)
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.tlboss then
			if v.nState == e_type_task_state.waitbattle or v.nState == e_type_task_state.go then
				if WorldFunc.getBlockId(v.nTargetX, v.nTargetY) == nBlockId then
					return true
				end
			end
		end
	end
	return false
end

--------------------------------------------决战皇城
--判断自己是否正在突围中移动中）
function WorldData:getIsBreakouting( )
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.imperwar then
			if v.nState == e_type_task_state.go and v:getIsBot() then
				return true
			end
		end
	end
	return false
end

--获取突围任务城市名字
function WorldData:getBreakoutCityName( )
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.imperwar then
			if v.nState == e_type_task_state.go and v:getIsBot() then
				return v:getBoName()
			end
		end
	end
	return false
end

--判断是否有武将到达决战皇城城池
function WorldData:getIsWaitBattleInEW( )
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.imperwar then
			if v.nState == e_type_task_state.waitbattle then
				return true
			end
		end
	end
	return false
end

--获取武将决战皇城时，正在待战的城池id
function WorldData:getWaitBattleInEWCityId( )
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.imperwar then
			if v.nState == e_type_task_state.waitbattle then
				return v:getBoCityId()
			end
		end
	end
	return nil
end

--判断是否有派动参加决战皇城任务
function WorldData:getHasGoEW( )
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.imperwar then
			if v.nState == e_type_task_state.go and not v:getIsBot() then
				return true
			end
		end
	end
	return false
end

--获取参加决战皇城任务前进cd
function WorldData:getGOEWMoveCd( )
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.imperwar then
			if v.nState == e_type_task_state.go and not v:getIsBot() then
				return v:getCd()
			end
		end
	end
	return 0
end

--判断是否有派动参加决战皇城任务
function WorldData:getImperWarTask( )
	for k,v in pairs(self.tTasks) do
		if v.nType == e_type_task.imperwar then
			return v
		end
	end
	return nil
end
--------------------------------------------决战皇城

function WorldData:onSingalSysCity( _tData )
	-- body
	local tViewDotMsg = ViewDotMsg.new(_tData.dot)
	local nType = tViewDotMsg.nType
	if not self.tBuildDots[nType] then
		self.tBuildDots[nType] = {}
	end
	if nType == e_type_builddot.sysCity then
		local nSystemCityId = tViewDotMsg.nSystemCityId
		self.tBuildDots[nType][nSystemCityId] = tViewDotMsg
	end
end

--------------------------------------------地图点刷新
--记录更新点
function WorldData:saveRefreshDotPos( nX, nY )
	self:delRefreshDotPos(nX, nY)
	table.insert(self.tRefreshDotPos, 1, {nX = nX, nY = nY})
end

--清除更新点
function WorldData:delRefreshDotPos( nX, nY )
	for i=#self.tRefreshDotPos, 1, -1 do
		if self.tRefreshDotPos[i].nX == nX and self.tRefreshDotPos[i].nY == nY then
			table.remove(self.tRefreshDotPos, i)
		end
	end
end

--清除更新点
function WorldData:delRefreshDotPosAll(  )
	self.tRefreshDotPos = {}
end

--获取最新更新点
function WorldData:getRefreshDotPos(  )
	return self.tRefreshDotPos[1]
end




return WorldData