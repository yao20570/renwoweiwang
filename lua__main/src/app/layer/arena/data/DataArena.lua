-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-1 9:50:03 星期五
-- Description: 竞技场数据
-----------------------------------------------------

local ArenaRankViewRes = require("app.layer.arena.data.ArenaRankViewRes")
local ArenaFightRepotRes = require("app.layer.arena.data.ArenaFightRepotRes")
local DataArena = class("DataArena")

function DataArena:ctor(  )
	-- body
	self:myInit()
end


function DataArena:myInit(  )
	self.nChallenge 	= 0			-- c	Integer	今天还能挑战次数
	self.nVChallenge 	= 0				-- vc	Integer	今天VIP挑战次数
	self.nScore 		= 0				-- itg	Integer	积分
	self.nMyRank 		= 0			-- r	Integer	排名
	self.nPrevMyRank    = nil
	self.tGet 			= {}				-- get	Set<Integer>	已经领取的积分奖励
	self.nSsc 			= 0 			--我的默认队列战力
	self.nTsc 			= 0             --竞技场阵容战力
	--暂时用不到
	self.tLucky 		= {}			-- lucky	List<Pair<Integer,Integer>>	幸运排名信息
	self.tHeroVos 		= nil			-- myba	List<HeroVo>	我的个人阵容

	self.tArenaShow 	= {} --竞技场玩家列表数据

	self.tArenaRanks 	= {} --排行榜数据

	self.tArenaLuckys 	= {} --竞技场幸运列表

	self.tScoreConfs 	= {} --info List<HeroVo> 积分奖励列表

	self.tMrp 			= {} --我的战斗记录

	self.nScoreRedNum   = 0  --积分红点数

	self.tShop 			= {} --Set<Integer>	商店id
	self.tBs 			= {} --Set<Integer>	已购买商店id
	self.nRfn           = 0  --Integer	今日刷新商店次数

	self.nChallengeCd 	= nil --cd	Long	挑战cd时间
    self.nRf = 0 --rf	Integer	今天是否刷新了视图队列 1刷新了,0没有
	self.nLa = 0 --la	Integer	今天是否领取幸运排行奖励 1领取了,0没有
	self.nRa = 0 --ra	Integer	今天是否领取排行奖励 1领取了,0没有
	self.nYr = 0 --yr	Integer	昨天排行
	self.nYls = {} -- yls	List<YesterdayLuckInfo>	昨日幸运排名信息

	self.tReads = {}

end

--从服务端获取数据刷新
function DataArena:refreshDatasByService( tData )	
	-- dump(tData, "竞技场数据", 100)
	self.nChallenge 	= 	tData.c or self.nChallenge			-- c	Integer	今天还能挑战次数
	self.nVChallenge 	= 	tData.vc or self.nVChallenge				-- vc	Integer	今天VIP挑战次数
	self.nScore 		= 	tData.itg or self.nScore				-- itg	Integer	积分
				
	self.nMyRank 		= 	tData.r or self.nMyRank			-- r	Integer	排名
	self.tGet 			= 	tData.get or self.tGet				-- get	Set<Integer>	已经领取的积分奖励

	self.nSsc 			= 	tData.ssc or self.nSsc 	--当前默认整容的战力
	self.nTsc 			= 	tData.tsc or self.nTsc  --竞技场阵容战力
	--暂时用不到
	self.tLucky       	= 	tData.lucky or self.tLucky			-- lucky	List<Pair<Integer,Integer>>	幸运排名信息

	self.tScoreConfs  	= 	tData.info or self.tScoreConfs  --info List<HeroVo> 积分奖励列表、

	--刷新竞技场阵容
	self:updateArenaLineUp(tData.myba)                 -- myba	List<HeroVo>	我的个人阵容
	--刷新竞技场视图
	self:updateArenaView(tData.shows)                  --shows	List<ArenaRankViewRes>	展示的玩家信息

	self:updateScoreAwardStatus()						--刷新积分奖励状态

	--我的战斗记录
	if tData.mrp then
		self.tMrp = self:createFightReports(tData.mrp)   --mrp	List<ArenaFightRepotRes>	自己的记录
	end

	--商店数据
	self.tShop 	= tData.shop or self.tShop     -- Set<Integer>	商店id
	self.tBs 	= tData.bs or self.tBs         -- Set<Integer>	已购买商店id
	self.nRfn 	= tData.rfn or self.nRfn       -- Integer	今日刷新商店次数
	if tData.cd then --cd	Long	挑战cd时间
		self.nChallengeCd 	= 	tData.cd 	
		self.nLastTime = getSystemTime()
	end		
    self.nRf 			= 	tData.rf 	or 	self.nRf          --rf	Integer	今天是否刷新了视图队列 1刷新了,0没有
	self.nLa 			= 	tData.la 	or 	self.nLa          --la	Integer	今天是否领取幸运排行奖励 1领取了,0没有
	self.nRa 			= 	tData.ra 	or 	self.nRa          --ra	Integer	今天是否领取排行奖励 1领取了,0没有
	self.nYr 			= 	tData.yr 	or 	self.nYr          --yr	Integer	昨天排行
	self.nYls 			= 	tData.yls 	or 	self.nYls         -- yls	List<YesterdayLuckInfo>	昨日幸运排名信息
	if tData.yls and #tData.yls > 0 then
		table.sort(self.nYls, function ( a, b )
			-- body
			return a.lr < b.lr
		end)
	end

	--战斗不播放
	if getToastNCState() == 1 or self.nCountrySelected == 0 then
		--不播放战力变化特效
	else
		--播放战力变化特效
		self:playFCChangeTx()
	end	
end
--我的战斗记录推送
function DataArena:pushMyArenaReport( _tData )
	-- body
	-- dump(_tData, "我的战斗记录推送", 100)
	if not _tData then
		return
	end
	local pData = ArenaFightRepotRes.new(_tData)
	table.insert(self.tMrp, pData)
	table.sort(self.tMrp, function ( a, b )
		-- body
		return a.nOt > b.nOt
	end)
	self:keepMyRecordInMax()
	sendMsg(ghd_refresh_my_arena_red_msg) 
end

function DataArena:keepMyRecordInMax(  )
	-- body
	local nMax = tonumber(getArenaParam("recordCount") or 0)
	local nLen = #self.tMrp
	local nDel = nLen - nMax
	if nDel > 0 then
		for i= 1, nDel do
			table.remove(self.tMrp, nLen - i + 1)
		end
	end
end
--获取我的战斗记录红点
function DataArena:getMyFightRed( )
	-- body
	local nRedNum = 0
	if self.tMrp and #self.tMrp > 0 then
		for k, v in pairs(self.tMrp) do
			if v.bNew then
				nRedNum = nRedNum + 1
			end
		end
	end
	return nRedNum
end
--_nOp 1 当前玩家记录 2 大神记录
function DataArena:clearAllRecordNewMark( _nOp )
	-- body
	if not _nOp then
		return
	end
	if _nOp == 1 then
		if self.tMrp and #self.tMrp > 0 then
			for k, v in pairs(self.tMrp) do
				if v.bNew then
					v:clearNewMark()
				end			
			end
		end
		sendMsg(ghd_refresh_my_arena_red_msg)	
	else
		if self.tArp and #self.tArp > 0 then
			for k, v in pairs(self.tArp) do
				if not self:isTopBattleRecordRead() then
					table.insert(self.tReads, v.nReportId)
				end			
			end
		end
	end
	sendMsg(ghd_arena_record_change_msg)	
end
--_nOp 1 当前玩家记录 2 大神记录
function DataArena:clearRecordNewMark( _reportId, _nOp )
	-- body
	if not _reportId or not _nOp then
		return
	end
	if _nOp == 1 then
		if self.tMrp and #self.tMrp > 0 then
			for k, v in pairs(self.tMrp) do
				if _reportId == v.nReportId then
					v:clearNewMark()
				end
			end
			sendMsg(ghd_refresh_my_arena_red_msg) 
		end
	else
		if not self:isTopBattleRecordRead(_reportId) then
			table.insert(self.tReads, _reportId)
		end
	end
	sendMsg(ghd_arena_record_change_msg)
end


--设置竞技场战斗记录
function DataArena:setBattleRecords( _tData )
	-- body
	--self.tMrp = self:createFightReports(_tData.mrp)   --mrp	List<ArenaFightRepotRes>	自己的记录
	self.tReads = _tData.aread or self.tReads--已读列表
	self.tArp = self:createFightReports(_tData.arp)   --arp	List<ArenaFightRepotRes>	大神的记录	
end

--是否大神记录已经阅读
function DataArena:isTopBattleRecordRead( _nId )
	-- body
	local bRead = false
	if _nId and self.tReads and #self.tReads then
		for k, v in pairs(self.tReads) do
			if v == _nId then
				bRead = true
				break	
			end			
		end
	end
	return bRead
end

--刷新竞技场视图
function DataArena:updateArenaView( _tData )
	-- body
	if (not _tData) or (#_tData <= 0) then
		return
	end
	self.tArenaShow = {}
	for k, v in pairs(_tData) do
		local pArenaRankViewRes = ArenaRankViewRes.new()
		pArenaRankViewRes:refreshDatasByService(v, self:isRankLucky(v.rank))
		table.insert(self.tArenaShow, pArenaRankViewRes) 
	end
	if #self.tArenaShow > 0 then
		table.sort(self.tArenaShow, function ( a, b )
			-- body
			return (a.nRank < b.nRank and a.nRank > 0)
		end)
	end
	sendMsg(ghd_refresh_arena_view_msg)	
end

--是否是幸运数字
function DataArena:isRankLucky( _nRank )
	-- body
	if not _nRank then
		return false
	end	
	if self.tLucky  and #self.tLucky > 0 then
		for k, v in pairs(self.tLucky) do
			if v.k == _nRank then
				return true
			end
		end
	end
	return false
end

function DataArena:isLuckyPrevTime()
	local nRank = self.nYr or 0
	if self.nYls  and #self.nYls > 0 then
		for k, v in pairs(self.nYls) do
			if v.k == nRank then
				return true
			end
		end
	end
	return false	
end

-- 刷新英雄数据
function DataArena:updateArenaLineUp( _tData )
	if (not _tData) or (#_tData <= 0) then
		return 
	end
	self.tHeroVos = {}
	-- 获取英雄数据
	for k, v in pairs(_tData) do
		local pHero = getHeroDataById(v.h)
		pHero:refreshDatasByService(v)
		pHero.nArenaIdx = k
		table.insert(self.tHeroVos, pHero) --新增一个英雄
	end	
	-- sendMsg(ghd_arena_lineup_change_msg)
end

--获取竞技场阵容
function DataArena:getArenaLineUp(  )
	-- body
	return self.tHeroVos
end

function DataArena:getArenaFreeHeroList( )
	-- body
	local tMyHeros = Player:getHeroInfo():getHeroList()
	local tArenaFrees = {}
	if tMyHeros and #tMyHeros > 0 then
		for k, v in pairs(tMyHeros) do
			if not self:isHeroInArenaLineUp(v.nId) then
				table.insert(tArenaFrees, v)			
			end			
		end
	end
	return tArenaFrees
end

function DataArena:getArenaHeroRedNum( ... )
	-- body
	local nNumRed = 0
	local pHeroMgr = Player:getHeroInfo()
	if pHeroMgr and self.tHeroVos and #self.tHeroVos then
		for k, v in pairs(self.tHeroVos) do
			local pMyHero = pHeroMgr:getHero(v.nId)
			if pMyHero and v:getBaseSc() < pMyHero:getBaseSc() then
				nNumRed = nNumRed + 1
			end			
		end
	end
	return nNumRed
end

function DataArena:getArenaBestHeros( )
	-- body
	local tHeros = {}
	local tMyHeros = Player:getHeroInfo():getHeroList()
	if tMyHeros and #tMyHeros > 0 then
		table.sort(tMyHeros, function ( a, b )
			-- body
			return a:getBaseSc() > b:getBaseSc()
		end)
		for i = 1, Player:getHeroInfo().nOnlineNums do
			table.insert(tHeros, tMyHeros[i])
		end
	end
	return tHeros	
end

function DataArena:isHeroInArenaLineUp(_nId)
	local bArena = false
	if _nId and self.tHeroVos and #self.tHeroVos > 0 then
		for k, v in pairs(self.tHeroVos) do
			if v.nId ==  _nId then
				bArena = true	
				break
			end
		end
	end
	return bArena
end

--是否已经设置了竞技场阵容
function DataArena:isHaveSetArenaLineUp(  )
	-- body
	if self.tHeroVos == nil or #self.tHeroVos <= 0 then
		return false
	else
		return true
	end
end

--获取竞技场视图数据
function DataArena:getArenaViewDatas(  )
	-- body
	return self.tArenaShow
end

function DataArena:getMyArenaIdx(  )
	-- body
	if self.tArenaShow and #self.tArenaShow > 0 then
		for k, v in pairs(self.tArenaShow) do
			if v.nId == Player.baseInfos.pid then
				return k
			end
		end
	end	
	return nil	
end

--竞技场排行数据
function DataArena:refreshArenaRank( _tData )
	-- body
	if not _tData or #_tData <= 0 then
		return
	end
	for k, v in pairs(_tData) do
		self.tArenaRanks[v.rank] = copyTab(v)
	end
end
--获取排行数据
function DataArena:getArenaRankDatas( )
	-- body
	return self.tArenaRanks
end

function DataArena:getNextRankPage( )
	-- body
	local nCnt = table.nums(self.tArenaRanks)
	nCnt = math.ceil(nCnt/ARENA_RANK_PAGE_LENGTH) + 1
	if nCnt <= 5 then
		return nCnt
	else
		return nil
	end	
end
--清理排行榜数据
function DataArena:cleanArenaRank(  )
	-- body
	self.tArenaRanks = {}
end
--刷新列表
function DataArena:refreshArenaLuckyList( tData )
	-- body
	self.tArenaLuckys = {}
	for k, v in pairs(tData) do
		table.insert(self.tArenaLuckys, copyTab(v))
	end
end

--获取幸运列表
function DataArena:getArenaRankLuckys(  )
	-- body
	return self.tArenaLuckys
end

function DataArena:createFightReports( _tList )
	-- body
	local tList = {}
	if _tList and #_tList > 0 then
		for k, v in pairs(_tList) do
			local pData = ArenaFightRepotRes.new(v)
			table.insert(tList, pData)
		end
		table.sort(tList, function ( a, b )
			-- body
			return a.nOt > b.nOt
		end)
	end
	return tList
end
--获取自己的战斗记录
function DataArena:getMyFightRecords( ... )
	-- body
	return self.tMrp or {}
end

--获取大神的战斗记录
function DataArena:getGodsFightRecords( ... )
	-- body
	return self.tArp or {}
end

--积分奖励
function DataArena:getScoreAwardConfs( ... )
	-- body
	return self.tScoreConfs
end

--刷新积分奖励状态
function DataArena:updateScoreAwardStatus( ... )
	-- body
	self.nScoreRedNum = 0
	table.sort(self.tScoreConfs, function ( a, b )
		-- body		
		return a.i < b.i
	end)	
	local nMyScore = self.nScore
	local nPervS = 0
	for k, v in pairs(self.tScoreConfs) do
		if k > 1 then
			nPervS = self.tScoreConfs[k - 1].i
		else
			nPervS = 0
		end		
		if nMyScore > v.i then
			v.nPer = 100
		elseif nMyScore < nPervS then
			v.nPer = 0
		else
			v.nPer = (nMyScore - nPervS)/(v.i - nPervS)*100
		end
		--积分不足 未达成
		if v.i > nMyScore then
			v.nStatus = en_get_state_type.cannotget
		elseif v.i <= nMyScore then
			--已经领取
			if self:isHadGetAward(v.i) then
				v.nStatus = en_get_state_type.haveget
			else--可以领取
				v.nStatus = en_get_state_type.canget
				self.nScoreRedNum = self.nScoreRedNum + 1
			end
		end
		if not v.tGoods then
			v.tGoods = {}
			for k, item in pairs(v.aw) do
				local pItem = getGoodsByTidFromDB(item.k)
				if pItem then
					pItem.nCt = item.v
					table.insert(v.tGoods, pItem)
				end
			end
		end
	end	

end
--获取我的排行奖励
function DataArena:getMyRankRewards()
	local tRankReward = getArenaAwards()	
	local tRewards = nil
	local tSet = nil
	local nMyRank = self.nYr--领奖的排名	
	if tRankReward and table.nums(tRankReward) > 0 then
		for i, tConf in pairs(tRankReward) do
			if tConf.startrk and tConf.endrk then
				if nMyRank >= tConf.startrk and nMyRank <= tConf.endrk then
					tSet = tConf.tAwards
				end
			elseif tConf.startrk and not tConf.endrk then
				if nMyRank >= tConf.startrk then
					tSet = tConf.tAwards
				end					
			end
		end
	end
	if tSet and #tSet > 0 then
		tRewards = {}
		sortGoodsList(tSet)	
		for k, v in pairs(tSet)	do
			local pItem = getGoodsByTidFromDB(v.k)
			if pItem then
				pItem.nCt = v.v	
				table.insert(tRewards, pItem)			
			end				
		end		
	end
	return tRewards
end

function DataArena:isCanGetRankPrize( ... )
	-- body	
	return self.nRa == 0 and self.nYr > 0
end

function DataArena:isCanGetLuckyPrize()
	local isInLuckys = false
	if self.nYls and #self.nYls > 0 then
		for k, v in pairs(self.nYls) do
			if self.nYr == v.lr then
				isInLuckys = true
				break
			end
		end
	end		
	return (self.nLa ~= 1) and isInLuckys
end

function DataArena:getLuckyListData()	
	return self.nYls
end

--获取奖励积分红点
function DataArena:getScroeRedNum(  )
	-- body
	return self.nScoreRedNum
end

function DataArena:getRankRedNum(  )
	-- body
	if self:isCanGetRankPrize() then
		return 1
	else
		return 0
	end
	
end

function DataArena:getLuckyRedNum(  )
	-- body
	if self:isCanGetLuckyPrize() then
		return 1
	else
		return 0
	end
end

function DataArena:getMyRank( ... )
	-- body
	return self.nMyRank
end

--是否已经领取奖励
function DataArena:isHadGetAward( _nScore )
	-- body
	if not _nScore then
		return false
	end
	for k, v in pairs(self.tGet) do
		if v == _nScore then
			return true
		end
	end
	return false
end

--获取剩余的挑战购买次数
function DataArena:getLeftVipChallengeTime(  )
	-- body
	--总竞技场挑战的VIP购买次数
	local nTatol = getAvatarVIPByLevel(Player:getPlayerInfo().nVip).buyarena
	local nChallengeMax = tonumber(getArenaParam("fightInitCount") or 0)
	local nLeft = nTatol - self.nVChallenge
	return nLeft
end

function DataArena:isFullChallengeTime(  )
	-- body
	local tVipData = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
	local nBuyVipChallengeMax = tonumber(tVipData.buyarena or 0)
	if self.nVChallenge >= nBuyVipChallengeMax and self.nChallenge <= 0 then	
		return true
	else
		return false
	end
end
--购买花费 _nTimes 购买次数
function DataArena:getBuyChallengeCost( _nTimes )
	-- body
	if not self.tArenaCost then
		self.tArenaCost = {}
		local tCost = luaSplit(getArenaParam("fightBuyCosts"), ",")
		for k, v in pairs(tCost) do
			self.tArenaCost[k] = tonumber(v or 0)	
		end
	end
	
	local nCost = 0
	local nTatol = getAvatarVIPByLevel(Player:getPlayerInfo().nVip).buyarena
	for idx = 1, _nTimes do
		nCost = nCost + self.tArenaCost[self.nVChallenge + idx]
	end
	return nCost
	
end
--已经弃用
-- function DataArena:playRankChangeTx(  )
-- 	-- body
-- 		--战斗不播放		
-- 	if getToastNCState() ~= 1 then--判断是否允许弹窗类提示		
-- 		showRankChangeTx(self.nPrevMyRank, self.nMyRank)		
-- 	end
-- end

function DataArena:refreshPrevRank(  )
	-- body
	self.nPrevMyRank = self.nMyRank
end

--获取剩余刷新次数和次数刷新上限
function DataArena:getArenaShopRefreshNum( ... )
	-- body	
	if not self.tRefresh then
		self.tRefresh = {}
		local tRefcost = luaSplitMuilt(getArenaParam("refcost") or "", ";", ":")
		-- dump(tRefcost, "竞技场商店刷新次数")
		for k, v in pairs(tRefcost) do
			local tCost = {}
			tCost.nResId = tonumber(v[1] or 0)
			tCost.nCost = tonumber(v[2] or 0)
			self.tRefresh[k] = tCost
		end
		self.nTotalRefrsh = table.nums(self.tRefresh)
	end
	return self.nTotalRefrsh - self.nRfn, self.nTotalRefrsh
end

--_nTime 刷新次数
function DataArena:getShopRefrshCost(  )
	-- body
	if not self.tRefresh then
		self:getArenaShopRefreshNum()		
	end
	local nCurTime = self.nRfn + 1
	if nCurTime > self.nTotalRefrsh then
		return self.tRefresh[self.nTotalRefrsh] 
	else
		return self.tRefresh[nCurTime]
	end	
end

function DataArena:getArenaShopItems(  )
	-- body
	local tCurShopItems = {}
	for k ,v in pairs(self.tShop) do
		local pShopItem = getArenaShopByIdx(v)
		pShopItem.bHadBuy = self:isHadBuyArenaShop(v)
		table.insert(tCurShopItems, pShopItem)		
	end
	table.sort(tCurShopItems,function ( a,  b )
		-- body
		if a.bHadBuy == b.bHadBuy then
			return (a.column < b.column)
		else
			return (not a.bHadBuy)
		end
		
	end )
	return tCurShopItems
end

--是否已经购买商店商品
function DataArena:isHadBuyArenaShop(_nIdx)
	-- body
	if not _nIdx then
		return false
	end
	if self.tBs and #self.tBs > 0 then
		for k, v in pairs(self.tBs) do
			if v == _nIdx then
				return true
			end			
		end
	end 	
	return false
end

--竞技场挑战
function DataArena:isCanArenaChallenge()
	-- body
	return self.nChallenge > 0
end

function DataArena:getChallengeCd(  )
	-- body		
	if not self.nChallengeCd then
		return 0
	end		
	local fCurTime = getSystemTime()
	local fLeft = self.nChallengeCd - (fCurTime - self.nLastTime)
	if(fLeft < 0) then
		fLeft = 0
	end
	return fLeft			
end

--播放战力变化
function DataArena:playFCChangeTx( )
	showFCChangeTx(self.nPrevTsc, self.nTsc, nil, 2)
	self.nPrevTsc = self.nTsc
end

return DataArena