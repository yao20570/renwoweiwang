----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-18 11:13:24
-- Description: 邮件数据
-----------------------------------------------------
--邮件类型
e_type_mail = {
	report 		= 1, --报告
	detect 		= 2, --侦查
	system 		= 3, --系统
	saved 		= 4, --已保存
	activity 	= 5, --已保存
}

--邮件战斗类型
e_type_mail_fight = {
	copy        = 1, --副本战斗
	cityWar		= 2, --城战
	wileArmy 	= 3, --乱军
	countryWar	= 4, --国战
	res 		= 5, --资源田
	worldBoss 	= 6, --世界boss
	awakeBoss 	= 7, --纣王boss
	arena 		= 8, --竞技场
	ltBoss 		= 9, --限时boss
	expedite 	= 10, --过关斩将
	ghost 		= 11, --幽魂
	ghostWar 	= 12, --冥王入侵
	zhouwang 	= 14, --纣王试炼
}

--侦查武将状态
e_state_hero_scout = {
	go = 1, --前往状态
	stay = 2, --停留状态
	garrison = 3, --驻守家园状态
	back = 4, --返回状态
}

--目标丢失类型
e_type_lose = {
	city = 1, 		--玩家城池
	sysCity = 2,    --系统城池
	mines = 3,		--矿点
	wileArmy = 4, 	--4：乱军
	boss = 5 ,		--boss

}

--目标丢失状态
e_state_lose = {
	pos = 1, --不在原地
	protect = 2, --保护中
}

--进攻方或防守方类型
e_type_atk_def = {
	player = 1,
	npc = 2,
	sysCity = 3,
	wildArmy = 4,
	mine=5,
	ghostdom = 6,
	ghostBoss = 7,
	kingzhou = 8,
}

--邮件模板类型
e_type_mail_report={
	cityWar=1,		--城战
	countryWar=2,	--国战
	wildArmy=3,		--乱军
	collect=4,		--采集
	mine=5,			--矿点
	detect=6,		--侦查
	garrison=7,		--驻防
	lose=8,			--丢失
	beDetected=9,   --被侦查
	armyFull=10,   	--驻防目标城门驻军已满

}


local FightHeroInfo = require("app.layer.mail.data.FightHeroInfo")
--邮件数据类
local MailData = class("MailData")

function MailData:ctor(  )
	self.tMailMsgs = {}
	self.tMailList = {} --顺序列表用于删除和添加
	self.tIsReqCountryWarBattle = {} --国战战斗者列表信息已请求集合

	self.tMailPage = {} --当前页码
	self.tMailPageCount = {} --每页大小
	self.tMailPageMax = {} --总页数
	self.tAllMailCount = {} --总条数
	self.tNotReadNums = {} --未读总数
	self.nLastEnterCategory = nil  --上次离开查看的邮件类型
	self.nRetentionNum = getMailInitData("retentionNum")
	self:clearAllMailReqed()
end

function MailData:release(  )
end

function MailData:createScoutHeroInfo( tData )
	if not tData then
		return
	end
	local tRes = {}
	tRes.bIsNpc = tData.npc == 1 --	Integer	是否NPC 0:否 1:是
	tRes.nHeroId = tData.hid	--Integer	英雄模板ID
	tRes.nTroops = tData.trp	--Integer	武将兵力
	tRes.nHeroLv = tData.lv	--Integer	武将等级
	tRes.nHeroState = tData.s		--Integer	武将状态 1：移动状态 2.停留状态 3.驻守家园状态
	tRes.nCd = tData.cd	--Integer	状态结束倒计时/秒(前往,返回)
	tRes.sTarget = tData.ta	--String	目的地 (前往,采集,返回,待战)
	tRes.nTargetLv = tData.tlv	--Integer	目的地等级 (前往,采集,返回,待战)
	tRes.sGarrisonName = tData.n	--	String	驻防玩家名字(友方驻守武独有)
	tRes.nGarrsionLv = tData.gl	--Integer	驻防玩家等级(友方驻守武独有)
	tRes.nGarrsionCountry = tData.c		--Integer	驻防玩家国家(友方驻守武独有)
	if tData.hs then
		tRes.nTemplate=tData.hs.t
		tRes.nIg=tData.hs.ig
	end
	return tRes
end

function MailData:createScoutHeroInfos( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		table.insert(tRes, self:createScoutHeroInfo(tData[i]))
	end
	return tRes
end

function MailData:createScoutResult( tData )
	if not tData then
		return
	end
	local tRes = {}
	tRes.nType = tData.type	--Integer	侦查结果:1,2,3(1：返回PART1 2:返回PART1、2 3:返回PART1、2、3)
	tRes.nX = tData.x	--Integer	x(Part1内容)
	tRes.nY = tData.y	--Integer	y(Part1内容)
	tRes.nCountry = tData.c	--Integer	国家(Part1内容)
	tRes.sName = tData.n	--String	名字(Part1内容)
	tRes.nLv = tData.lv	--Integer	等级(Part1内容)
	tRes.nCityPerson = tData.pc	--Integer	城内百姓(Part1内容)
	tRes.nSliver = tData.sl	--Long	银币(Part1内容)
	tRes.nWood = tData.wo	--Long	木(Part1内容)
	tRes.nFood = tData.fo	--Long	粮草(Part1内容)
	tRes.nWallLv = tData.wl	--Integer	城墙等级 (Part2内容)
	tRes.nPower = tData.sc	--Long	战力 (Part2内容)
	tRes.nInfantry = tData["in"] --	Long	步兵(Part2内容)
	tRes.nCavalry = tData.sw	--Long	骑兵 (Part2内容)
	tRes.nArcher = tData.ar	--Long	弓兵 (Part2内容)
	tRes.tScoutHeroInfos = self:createScoutHeroInfos(tData.ts) --	List<ScoutHeroInfo>	进行中任务 (Part3内容)
	return tRes
end

function MailData:createFightHeroInfo( tData )
	if not tData then
		return
	end
	return FightHeroInfo.new(tData)
end

function MailData:createFightHeroInfos( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		table.insert(tRes, self:createFightHeroInfo(tData[i]))
	end
	return tRes
end

function MailData:createFightDetail( tData )
	if not tData then
		return
	end
	local tRes = {}

	tRes.bIsWin = tData.win	== 1		--int	进攻方是否胜利 0:失败 1:胜利

	

	tRes.sFightRid = tData.fightRID	--String	战斗结果ID
	tRes.nTime = tData.time		--long	战斗发生时间
	tRes.sDefName = tData.dn			--String	防守方名称
	tRes.nDefCountry = tData.dc			--Integer	防守方国家
	tRes.nDefLv = tData.dl			--Integer	防守方等级
	tRes.nDefX = tData.dx			--Integer	目标x坐标
	tRes.nDefY = tData.dy			--Integer	目标y坐标
	tRes.nDefTroops = tData.dt			--Integer	目标总兵力
	tRes.nDefLoseTroops = tData.dtl			--Integer	目标损失的兵力
	tRes.tDefHeros = self:createFightHeroInfos(tData.dh)			--List<FightHeroInfo>	防守方战斗英雄信息
	tRes.sAtkName = tData.an			--String	进攻方名字
	tRes.nAtkCountry = tData.ac			--Integer	进攻方国家
	tRes.nAtkLv = tData.al			--Integer	进攻方等级
	tRes.nAtkX = tData.ax			--Integer	进攻方x坐标
	tRes.nAtkY = tData.ay			--Integer	进攻方y坐标
	tRes.nAtkTroops = tData.at			--Integer	进攻方总兵力
	tRes.nAtkLoseTroops = tData.atl			--Integer	进攻方损失的兵力
	tRes.tAtkHeros = self:createFightHeroInfos(tData.ah)		--List<FightHeroInfo>	进攻方英雄信息
	tRes.sDefSid = tData.dsid --String 防守方头像Id
	tRes.sAtkSid = tData.asid --String 进功方头像Id
	tRes.sJumpMail = tData.jm --String 要跳转到的邮件id
	return tRes
end

function MailData:createFightDetails( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		table.insert(tRes, self:createFightDetail(tData[i]))
	end
	return tRes
end

function MailData:createGoHeroInfo( tData )
	if not tData then
		return
	end
	
	local tRes = {}
	tRes.nHeroId = tData.hid	--Integer	英雄id
	tRes.nHeroLv = tData.lv	--Integer	等级
	tRes.nTroops = tData.t	--Integer	带兵量
	tRes.tHs = tData.hs 	--进阶的武将id数据   
	return tRes
end

function MailData:createGoHeroInfos( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		table.insert(tRes, self:createGoHeroInfo(tData[i]))
	end
	return tRes
end

--创建邮件
function MailData:createMailMsg( tData )
	if not tData then
		return
	end
	local tRes = tData --由于邮件牵扯到表格的参数配置，这里直接赋值

	tRes.nCategory = tData.c --Integer	邮件分类1:报告 2:侦查 3:系统  4:已保存
	tRes.nId = tData.mid --	Integer	邮件模板ID
	tRes.sPid = tData.id --	String	邮件ID
	tRes.nReciveId = tData.rid --	Long	接收者ID
	tRes.bIsReaded = tData.o == 1 --	Integer	是否已读（0未读，1已读）
	tRes.nSendTime = tData.st --	Long	邮件发送时间
	tRes.tFillContent = tData.rc --	List<String>	邮件内容填充内容
	tRes.tRewardItemList = tData.r --List<Pair<Integer,Long>>	邮件奖励物品
	tRes.tItemList = tData.i --	List<Pair<Integer,Long>>	展示进攻获得物品[攻击/防守邮件独有](乱军收获)
	tRes.tLoseItemList = tData.lost	--List<Pair<Integer,Long>>	失去物品 [攻击/防守邮件独有]
	tRes.bIsGot = tData.get == 1 --	Integer	奖励是否领取 1:是 0：否
	tRes.tScoutResult = self:createScoutResult(tData.sr) --	ScoutResult	侦查结果[侦查邮件独有]
	tRes.nWin = tData.win --Integer	进攻方是否胜利 0:否 1:是[攻击/防守邮件独有]
	tRes.bIsWin = tRes.nWin == 1 --	自定义类型

	tRes.sFightRid = tData.fightRID	--String	战斗结果ID[攻击/防守邮件独有]
	tRes.nFightType = tData.ft --副本战斗1，城战2，乱军战3，国战4，资源田战斗5 世界boss6 纣王boss7 竞技场8 限时boss9 过关斩将10 幽魂11 冥王12
	--资源田和战斗城战dsid
	tRes.tFightDetails = self:createFightDetails(tData.fds)	--List<FightDetail>	矿点战斗列表[矿点邮件独有]
	tRes.nMine = tData.mine	--Integer	矿点模板ID[矿点邮件独有]
	tRes.nMineX = tData.mx	--Integer	矿点X位置[矿点邮件独有]
	tRes.nMineY = tData.my	--Integer	矿点Y位置[矿点邮件独有]
	tRes.nCollectTime = tData.ct	--Integer	采集时间[矿点邮件独有]
	tRes.nMineHeroId = tData.hid	--int	武将ID[矿点邮件独有]
	tRes.nMineHeroLv = tData.hl	--Integer	武将等级[矿点邮件独有](采集报告)
	tRes.nMineHeroExp = tData.he	--Integer	武将经验 [矿点邮件独有](采集报告)
	tRes.nMineNum = tData.mineNum --	Long	采集量
	tRes.nLoseType = tData.tt --目标类型 1：玩家城池 2:系统城池 3:矿点 4：乱军[目标丢失邮件独有]
	tRes.nLoseState = tData.lt --丢失类型 1:不在原地，2：保护中[目标丢失邮件独有]
	tRes.nLoseId = tData.tid --乱军/矿点模板ID/系统城池id(保护中)[目标丢失邮件独有]
	tRes.nLoseCityLv = tData.pl --玩家城市等级[目标丢失邮件独有]
	tRes.nLoseCountry = tData.pc --玩家国家[目标丢失邮件独有]
	tRes.nLoseX = tData.x --目标X[目标丢失邮件独有]
	tRes.nLoseY = tData.y --目标Y[目标丢失邮件独有]
	tRes.tGoHeros = self:createGoHeroInfos(tData.hs) --出征英雄列表
	tRes.nDty = tData.dty --防守类进攻类型

	tRes.tBlockId = tData.bn --Integer	国战进攻区域ID
	tRes.sDefName = tData.dn	--String	防守方名称
	tRes.nDefCountry = tData.dc	--Integer	防守方国家
	tRes.nDefLv = tData.dl	--Integer	防守方等级
	tRes.nDefX = tData.dx	--Integer	目标x坐标
	tRes.nDefY = tData.dy	--Integer	目标y坐标
	tRes.nDefTroops = tData.dt	--Integer	目标总兵力
	tRes.nDefLoseTroops = tData.dtl	--Integer	目标损失的兵力
	tRes.tDefHeros = self:createFightHeroInfos(tData.dh) --	List<FightHeroInfo>	防守方战斗英雄信息
	tRes.sAtkName = tData.an	--String	进攻方名字
	tRes.nAtkCountry = tData.ac	--Integer	进攻方国家
	tRes.nAtkLv = tData.al	--Integer	进攻方等级
	tRes.nAtkX = tData.ax	--Integer	进攻方x坐标
	tRes.nAtkY = tData.ay	--Integer	进攻方y坐标
	tRes.nAtkTroops = tData.at	--Integer	进攻方总兵力
	tRes.nAtkLoseTroops = tData.atl	--Integer	进攻方损失的兵力
	tRes.tAtkHeros = self:createFightHeroInfos(tData.ah)	--List<FightHeroInfo>	进攻方英雄信息

	tRes.nAty = tData.aty --进攻方类型
	tRes.nAid = tData.aid --进攻方模板id
	tRes.nDid = tData.did --用来表示乱军和系统城池的模板id 或矿点
	tRes.sDefSid = tData.dsid --String 防守方头像Id(只有是玩家的时候才)
	tRes.sAtkSid = tData.asid --String 进功方头像Id(只有是玩家的时候才)
	tRes.nLmt = tData.lmt -- long 毫秒级别的时间戳(保存或保存撤销时的时间戳）

	tRes.sTitle = tData.title --String 标题
	tRes.sCreatName  = tData.cn or getConvertedStr(3, 10209) --cn	String	自定义邮件发件人名字
	tRes.sContent = tData.content --String 内容

	tRes.sReceiverName = tData.rn --接收邮件者名字(国战邮件独有)
	tRes.nReceiverLv = tData.rl --接收邮件者等级(国战邮件独有)

	tRes.nDefCityLv = tData.pal --防守方的皇宫等级（   城战的进攻和防守邮件都有）
	tRes.bIsMoBing = tData.magic == 1 --是否是魔兵
	tRes.nBossLv = tData.blv      --攻打纣王bossid
	tRes.nBossDif = tData.bdif      --攻打纣王难度
	
	-- if tRes.sAtkName==Player:getPlayerInfo().sName then 		--我为进攻方是，我的结果就是bIsWin的值
	-- 	tRes.bMyResult=tRes.bIsWin
	-- else
	-- 	tRes.bMyResult=not tRes.bIsWin
	-- end
	--自定义数据
	--有机率获取物品
	if (tRes.nFightType == e_type_mail_fight.wileArmy or 
		tRes.nFightType == e_type_mail_fight.awakeBoss or 
		tRes.nFightType == e_type_mail_fight.ghost or
		tRes.nFightType == e_type_mail_fight.ghostWar or
		tRes.nFightType == e_type_mail_fight.zhouwang) 	
		and tRes.tItemList then
		local tRandomItems = {}
		for i=1,#tRes.tItemList do
			if not getGoodsIsResouce(tRes.tItemList[i].k) then
				table.insert(tRandomItems, tRes.tItemList[i])
				-- tRes.tRandomItem = tRes.tItemList[i]
				-- break
			end
		end
		--如果物品超过一个取品质最高的那个
		if #tRandomItems > 1 then
			table.sort(tRandomItems, function(a, b)
				-- body 
				local tItemA = getGoodsByTidFromDB(a.k)
				local tItemB = getGoodsByTidFromDB(b.k)
				if tItemA and tItemB then
					return tItemA.nQuality > tItemB.nQuality
				else
					return false
				end
			end)
		end
		tRes.tRandomItem = tRandomItems[1]
		tRes.tRandomItems = tRandomItems
		--寻找奖励中是否有召唤券
		for i, v in pairs(tRandomItems) do 
			if v.sTid==e_item_ids.cjzhq or v.sTid==e_item_ids.cjzhq then
				tRes.tRandomItem=v
			end
		end
		
	end

	local tSortKey = {
		[e_item_ids.cjzhq] = 1,
		[e_item_ids.cjzhq] = 2,
		[e_type_resdata.coin] = 3,
		[e_type_resdata.wood] = 4,
		[e_type_resdata.food] = 5,
	}
	local function sortFunc( a, b )
		if tSortKey[a.k] and tSortKey[b.k] then
			return tSortKey[a.k] < tSortKey[b.k]
		elseif tSortKey[a.k] and not tSortKey[b.k] then
			return true
		elseif not tSortKey[a.k] and tSortKey[b.k] then
			return false
		end

	    local tGoodA=getGoodsByTidFromDB(a.k)
	    local tGoodB=getGoodsByTidFromDB(b.k)
	    if tGoodA and tGoodB then
	        return tGoodA.nQuality>tGoodB.nQuality
	    end
		return a.k < b.k
    end
    
    if tRes.tRewardItemList then
    	--去掉数量为0的物品
    	for i = #tRes.tRewardItemList, 1, -1 do
    		if tRes.tRewardItemList[i].v <= 0 then
    			table.remove(tRes.tRewardItemList, i)
    		end
    	end
    	table.sort( tRes.tRewardItemList , sortFunc)
    end
    
    if tRes.tItemList then
    	--去掉数量为0的物品
    	for i = #tRes.tItemList, 1, -1 do
    		if tRes.tItemList[i].v <= 0 then
    			table.remove(tRes.tItemList, i)
    		end
    	end
    	table.sort( tRes.tItemList , sortFunc)
    end
	if tRes.tLoseItemList then
		--去掉数量为0的物品
    	for i = #tRes.tLoseItemList, 1, -1 do
    		if tRes.tLoseItemList[i].v <= 0 then
    			table.remove(tRes.tLoseItemList, i)
    		end
    	end
		table.sort( tRes.tLoseItemList , sortFunc)
	end
	return tRes
end

--创建邮件集合
function MailData:sortTable( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tMailMsg = self:createMailMsg(tData[i])
		tRes[tMailMsg.sPid] = tMailMsg
	end
	return tRes
end


--创建邮件集合
function MailData:createMailMsgs( tData )
	if not tData then
		return
	end
	local tRes = {}
	for i=1,#tData do
		local tMailMsg = self:createMailMsg(tData[i])
		tRes[tMailMsg.sPid] = tMailMsg
	end
	return tRes
end

--设置总邮件总条数增减
function MailData:offsetMailAllCount( nCategory, nNum, bIsEqual)
	if bIsEqual then
		self.tAllMailCount[nCategory] = nNum
	else
		if self.tAllMailCount[nCategory] then
			self.tAllMailCount[nCategory] = self.tAllMailCount[nCategory] + nNum
		else
			self.tAllMailCount[nCategory] = nNum
		end
	end
	if self.tAllMailCount[nCategory] < 0 then
		self.tAllMailCount[nCategory] = 0
	end
	if self.tAllMailCount[nCategory] > self.nRetentionNum then
		self.tAllMailCount[nCategory] = self.nRetentionNum
	end
end

--清空最大邮件数量
function MailData:clearAllMailCount( nCategory )
	--清空数据
	self.tMailMsgs[nCategory] = {}
	self.tMailList[nCategory] = {}
	self:offsetMailAllCount(nCategory, 0, true)
	self.tMailReqed[nCategory] = false --标记为false,需要再次请求
end

--[3051]加载邮件
--tData 服务端数据
--nCategory 邮件类型
--nLoadedNum 已加载数量
function MailData:onLoadMail( tData, nCategory, nLoadedNum)
	if not tData then
		return
	end
	self.tMailPage[nCategory] = tData.c	--Integer	当前页码大小
	self.tMailPageMax[nCategory] = tData.a	--Integer	总页数
	self.tMailPageCount[nCategory] = tData.ps	--Integer	每页
	self:offsetMailAllCount(nCategory, tData.t, true) --Integer	总条数
	--如果是0开始请求就清空所有数据（游戏置到后台后，收到邮件数据，再置到前台，会请求一次数据，当红点不一致时，从0开始请求数据)
	if nLoadedNum == 0 then
		self.tMailMsgs[nCategory] = {}
		self.tMailList[nCategory] = {}
	end
	self:addMailNew(tData.m)--List<MailMsg>	邮件列表

	self.tMailReqed[nCategory] = true
end

--[3052]将邮件设置为已读状态
--nCategory 邮件类型
--sPid 指定邮件，为nil时就是全部设置
function MailData:onMailReaded( nCategory, sPid)
	if self.tMailMsgs[nCategory] then
		if sPid then
			if not self.tMailMsgs[nCategory][sPid].bIsReaded then
				self.tMailMsgs[nCategory][sPid].bIsReaded = true
				--修改红点数
				self:subNotReadNums(nCategory, 1)
			end
		else
			for k,v in pairs(self.tMailMsgs[nCategory]) do
				if not v.bIsReaded then
					v.bIsReaded = true
				end
			end
			--修改红点数
			self:subNotReadNumsAll(nCategory)
		end
	end
end

--[3053]删除邮件
--nCategory 邮件类型
--sPid 指定邮件，为nil时就是全部删除
function MailData:onMailDel( nCategory, sPid)
	if self.tMailMsgs[nCategory] then
		if sPid then
			--删除指定邮件
			self:deleteMail(nCategory, sPid)
			--只有进来能删除，进来肯定是已读了，所以未读红点数不用-1
		else
			--清空数据
			self:clearAllMailCount(nCategory)
			--不用修改红点数，因为协议返回时会转过来

			--一键删除成功，要重新请求一下该类型的数据和未读红点
			SocketManager:sendMsg("reqMailLoad", {nCategory, 0})
		end
	end
end

--[3054]推送新邮件
function MailData:onPushMailNew( tData )
	if not tData then
		return
	end
	self:addMailNew(tData.m, true)
end

--加入新的邮件
--tData 服务器数据
--bIsPush 是否推送
--bIsSave 是否是保存的或取消保存
function MailData:addMailNew( tData, bIsPush, bIsSave)
	if not tData then
		return
	end
	--选出新增的邮件数量和数据
	local nMaxNum=self.nRetentionNum
	for i=1, #tData do
		local nCategory = tData[i].c
		local sPid = tData[i].id
		if self.tMailMsgs[nCategory] and self.tMailMsgs[nCategory][sPid] then
			--过滤旧的数据
		else
			local tMailMsg = self:createMailMsg(tData[i])
			self:__addMailNew(tMailMsg, bIsPush, bIsSave)
		end
	end
end

--加入新的邮件数据
--tMailMsg：数据
--bIsPush: 是否有推送
--bIsSave 是否是保存的或取消保存
function MailData:__addMailNew( tMailMsg, bIsPush, bIsSave)
	if not tMailMsg then
		return
	end
	local nCategory = tMailMsg.nCategory
	local sPid = tMailMsg.sPid
	
	--类型
	if not self.tMailMsgs[nCategory] then
		self.tMailMsgs[nCategory] = {}
	end
	if not self.tMailList[nCategory] then
		self.tMailList[nCategory] = {}
	end
	--已加入的就不加
	if self.tMailMsgs[nCategory][sPid] then
		return
	end
	self.tMailMsgs[nCategory][sPid] = tMailMsg

	--是否推送或从保存进来
	if bIsPush or bIsSave then
		table.insert(self.tMailList[nCategory], 1, tMailMsg)
		--总邮件数+1
		self:offsetMailAllCount(nCategory, 1)
		if bIsPush then
			--添加红点数
			self:addNotReadNums(nCategory, 1)

			--推送战报
			local tMailData = getMailDataById(tMailMsg.nId)
			--如果需要显示结果就发送消息
			if tMailData and tMailData.result and tMailData.result > 0 then
				--重置引导时间
		 		N_LAST_CLICK_TIME = getSystemTime()
				tMailMsg.nResult = tMailData.result
				--展示结果提示
				local tObj = {}
				tObj.tMailMsg = tMailMsg
				tObj.tMailData = tMailData
				sendMsg(ghd_battle_result, tObj)
			end
		end
	else
		table.insert(self.tMailList[nCategory], tMailMsg)
	end

	--判断是否已经达到邮件的最大数量
	local nMaxNum = self.nRetentionNum
	if self.tMailList[nCategory] and #self.tMailList[nCategory] > nMaxNum then
		local tMailMsg = self.tMailList[nCategory][nMaxNum]
		self:deleteMail(nCategory, tMailMsg.sPid)
	end
end

--邮件数量超过配置的最大数量时的强制删除最后一个
function MailData:deleteMail( _nCategory, _sPid)
	--删除字典中的数据
	if self.tMailMsgs[_nCategory] then
		local tMail=self.tMailMsgs[_nCategory][_sPid]
		if tMail then
			if tMail.bIsReaded == false then  --未读的时候更新邮件红点数
				self:subNotReadNums(_nCategory, 1)
			end
			self.tMailMsgs[_nCategory][_sPid] = nil
		end
	end

	--删除列表中的数据
	if self.tMailList[_nCategory] then
		for i=1,#self.tMailList[_nCategory] do
			if self.tMailList[_nCategory][i].sPid == _sPid then
				table.remove(self.tMailList[_nCategory], i)
				break
			end
		end
	end

	--更新总量
	self:offsetMailAllCount(_nCategory, -1)
end

--[3055]保存邮件
--nCategory 邮件类型
--sPid 指定邮件
function MailData:onMailSave( nCategory, sPid)
	local _tMailMsg = self:getMailMsg(sPid, nCategory)
	if _tMailMsg then
		--复制数据
		local tMailMsg = clone(_tMailMsg)
		--记录当前nLmt
		tMailMsg.nLmt = getSystemTime(false)

		--删除之前类别中的邮件数据
		self:deleteMail(nCategory, sPid)

		--新增现在类别中的邮件数据
		tMailMsg.nCategory = e_type_mail.saved
		self:__addMailNew(tMailMsg, false, true)
	end
end

--[3056]获取邮件物品
--nCategory 邮件类型
--sPid 指定邮件，为nil时就是全部领取
function MailData:onMailGet( nCategory, sPid)
	if self.tMailMsgs[nCategory] then
		if sPid then
			if self.tMailMsgs[nCategory][sPid] then
				self.tMailMsgs[nCategory][sPid].bIsGot = true
			end
			--不用修改红点数，因为进入邮件领取，未读会转成已读，红点数就已经修改了
		else
			--把可领取的设置为已读
			for k,v in pairs(self.tMailMsgs[nCategory]) do
				if v.tRewardItemList and #v.tRewardItemList > 0 then
					v.bIsGot = true
					v.bIsReaded = true
				end
			end
			--不用修改红点数，因为协议返回时会转过来
		end
	end
end
--[3056]获取邮件物品
--nCategory 邮件类型
--_tData 能领取奖励的邮件
function MailData:onMailServeralGet( _nCategory,_tData )
	-- body
	if not _tData then
		return
	end
	--把可领取的设置为已读
	for i = 1, #_tData do
		local vv= _tData[i]
		for k,v in pairs(self.tMailMsgs[_nCategory]) do
			if v.tRewardItemList and #v.tRewardItemList > 0 and vv == v.sPid then
				v.bIsGot = true
				v.bIsReaded = true
			end
		end
	end

end
--[3058]设置邮件战斗者列表信息
--tData:服务器数据
--sFightRid: 战报id
function MailData:setCountryWarBattle( tData, sFightRid)
	local bIsRefresh = false
	for nCategory,tMailMsgs in pairs(self.tMailMsgs) do
		for sPid, tMailMsg in pairs(tMailMsgs) do
			if tMailMsg.sFightRid == sFightRid then
				--设置已请求战报
				self.tIsReqCountryWarBattle[sFightRid] = true
				--更新数据
				self:setCountryWarBattleInMail(tMailMsg, tData)

				bIsRefresh = true
			end
		end
	end

	--发送更新
	if bIsRefresh then
		sendMsg(gud_mail_country_war_battle_req_msg)
	end
end

--设置邮件战斗者列表
function MailData:setCountryWarBattleInMail( tMailMsg, tData)
	if not tMailMsg or not tData then
		return
	end

	tMailMsg.nDefCountry = tData.defCountry		--int	防守方国家
	tMailMsg.nDefTroops = tData.defTroop		--int	防守方总兵力
	tMailMsg.nDefLoseTroops = tData.defLostTroop	--int	防守方损失的兵力
	tMailMsg.tDefHeros = self:createFightHeroInfos(tData.defHero) 			--List<FightHeroInfo>	防守方战斗英雄信息
	tMailMsg.nAtkCountry = tData.ackCountry		--int	进攻方国家
	tMailMsg.nAtkTroops = tData.ackTroop		--int	进攻方总兵力
	tMailMsg.nAtkLoseTroops = tData.ackLostTroop	--int	进攻方兵力
	tMailMsg.tAtkHeros = self:createFightHeroInfos(tData.ackHero) --			List<FightHeroInfo>	进攻方战斗英雄信息

end

--[3059]撤销保存邮件
--sPid 邮件唯一id
function MailData:onMailSaveCancel( sPid )
	local _tMailMsg = self:getMailMsg(sPid, e_type_mail.saved)
	if _tMailMsg then
		local tMailData = getMailDataById(_tMailMsg.nId)
		if not tMailData then
			return
		end
		--找出原来的类别
		local nCategory = tMailData.kind
		if not nCategory then
			return
		end

		--复制数据
		local tMailMsg = clone(_tMailMsg)
		--从保存组别移除
		self:deleteMail(e_type_mail.saved, sPid)

		--更新当前nLmt
		tMailMsg.nLmt = getSystemTime(false)

		--新增别的类别
		tMailMsg.nCategory = nCategory
		self:__addMailNew(tMailMsg, false, true)
	end
end

--获取邮件列表
--nCategory 邮件类型
function MailData:getMailMsgList( nCategory )
	return self.tMailList[nCategory] or {}
end

--获取是否已请求国战战斗列表
function MailData:getIsReqCountryWarBattle( sFightRid )
	return self.tIsReqCountryWarBattle[sFightRid]
end

--获取邮件
--sPid 指定邮件
--nCategory 邮件类型(为nil就全局搜索)
function MailData:getMailMsg( sPid, nCategory)
	if nCategory then
		if self.tMailMsgs[nCategory] then
			return self.tMailMsgs[nCategory][sPid]
		end
	else
		for k,v in pairs(self.tMailMsgs) do
			if v[sPid] then
				return v[sPid]
			end
		end
	end
	return nil
end

--获取服务器发过来的总条数
--nCategory 邮件类型
function MailData:getMailPageItemMax( nCategory )
	return self.tAllMailCount[nCategory] or 0
end

--获取邮件数量
--nCategory 邮件类型
function MailData:getCurrMailCount( nCategory )
	if self.tMailList[nCategory] then
		return #self.tMailList[nCategory]
	end
	return 0
end

--要打开的侦查邮件
function MailData:setDetectMailId( sMailId )
	self.sDetectMailId = sMailId
end

function MailData:getDetectMailId(  )
	return self.sDetectMailId
end

--判断是否有加载更多
function MailData:getIsHasLoadMore( nCategory )
	local nMaxNum = self.nRetentionNum
	local nCurrLoaded = self:getCurrMailCount(nCategory)
	if nCurrLoaded >= nMaxNum then
		return false
	end
	local nTotal = self:getMailPageItemMax(nCategory)
	return nCurrLoaded < nTotal
end

--判断是否已请求服务器加载
function MailData:getIsHasReqLoaded( nCategory )
	return self.tMailReqed[nCategory]
end

--清容已请求服务器标识，用于容错,下次打开界面时再请求
function MailData:clearAllMailReqed(  )
	self.tMailReqed = {}
end

----------测试数据
function MailData:initTestData()
	local tMailMsg = {}
	tMailMsg.c	 =	1	--Integer	邮件分类
	tMailMsg.mid = 	12	--Integer	邮件模板ID
	tMailMsg.id	 =  1		--String	邮件ID
	tMailMsg.rid = 1		--Long	接收者ID
	tMailMsg.o	= 0		--Integer	是否已读（0未读，1已读）
	tMailMsg.st	= 0		--Long	邮件发送时间
	tMailMsg.rc	= nil		--List<String>	邮件内容填充内容
	tMailMsg.r	= {
	{k = 100001,v = 1},{k = 100002,v = 1},{k = 100003,v = 1},{k = 100004,v = 1},
	{k = 100001,v = 1},{k = 100002,v = 1},{k = 100003,v = 1},{k = 100004,v = 1},
	}		--List<Pair<Integer,Long>>	邮件奖励物品
	tMailMsg.i	= {{k = 100001,v = 1},{k = 100002,v = 1},{k = 100003,v = 1},{k = 100004,v = 1}}		--List<Pair<Integer,Long>>	展示进攻获得物品[攻击/防守邮件独有]
	tMailMsg.lost = {{k = 100001,v = 1},{k = 100002,v = 1},{k = 100003,v = 1},{k = 100004,v = 1}}	--List<Pair<Integer,Long>>	失去物品 [攻击/防守邮件独有]
	tMailMsg.get = 1		--Integer	奖励是否领取 1:是 0：否

	local sr = {}
	sr.type = 3	--Integer	侦查结果:1,2,3(1：返回PART1 2:返回PART1、2 3:返回PART1、2、3)
	sr.x = 1		--Integer	x(Part1内容)
	sr.y = 1		--Integer	y(Part1内容)
	sr.c = 1		--Integer	国家(Part1内容)
	sr.n = "名字"		--String	名字(Part1内容)
	sr.lv = 1		--Integer	等级(Part1内容)
	sr.pc = 1		--Integer	城内百姓(Part1内容)
	sr.sl = 99999		--Long	银币(Part1内容)
	sr.wo = 1		--Long	木(Part1内容)
	sr.fo = 1		--Long	粮草(Part1内容)
	sr.wl = 1		--Integer	城墙等级 (Part2内容)
	sr.sc = 1		--Long	战力 (Part2内容)
	sr["in"] = 1		--Long	步兵(Part2内容)
	sr.sw = 1		--Long	骑兵 (Part2内容)
	sr.ar = 1		--Long	弓兵 (Part2内容)

	local ts = {}
	for i=1,10 do
		local tt = {}
		tt.npc = i%1		--Integer	是否NPC 0:否 1:是
		tt.hid = 200031		--Integer	英雄模板ID
		tt.trp = 1		--Integer	武将兵力
		tt.lv = 1		--Integer	武将等级
		tt.s = i%3+1		--Integer	武将状态 1：移动状态 2.停留状态 3.驻守家园状态
		tt.cd = 1	--Integer	状态结束倒计时/秒(前往,返回)
		tt.ta = "目的地"		--String	目的地 (前往,采集,返回,待战)
		tt.tlv = 1		--Integer	目的地等级 (前往,采集,返回,待战)
		tt.n = "玩家名字"		--String	驻防玩家名字(友方驻守武独有)
		tt.gl = "玩家等级"		--Integer	驻防玩家等级(友方驻守武独有)
		tt.c = 1		--Integer	驻防玩家国家(友方驻守武独有)
		table.insert(ts, tt )
	end
	sr.ts = ts		--List<ScoutHeroInfo>	进行中任务 (Part3内容)

	tMailMsg.sr	= sr		--ScoutResult	侦查结果[侦查邮件独有]
	tMailMsg.win = 0		--Integer	进攻方是否胜利 0:否 1:是[攻击/防守邮件独有]
	tMailMsg.fightRID = 1	--String	战斗结果ID[攻击/防守邮件独有]
	tMailMsg.ft	= 4		--Integer	战斗类型 2-乱军 3-资源田 4-城战 5-国战 <当类型是国战时请求3058获取战斗者列表信息>
	local fds = {}
	for i=1,10 do
		local fd = {}
		fd.win = 1		--int	进攻方是否胜利 0:失败 1:胜利
		fd.fightRID = 0	--String	战斗结果ID
		fd.time	= 0	--long	战斗发生时间
		fd.dn = "防守方"			--String	防守方名称
		fd.dc = 1			--Integer	防守方国家
		fd.dl = 1			--Integer	防守方等级
		fd.dx = 1			--Integer	目标x坐标
		fd.dy = 1			--Integer	目标y坐标
		fd.dt = 99			--Integer	目标总兵力
		fd.dtl = 88		--Integer	目标损失的兵力
		local tFightHeroInfos = {}
		for i=1,10 do
			local tFightHeroInfo = {}
			tFightHeroInfo.npc = 1	--Integer	是否为NPC 0:否 1:是
			tFightHeroInfo.pn = "假的"	--String	所属玩家名字
			tFightHeroInfo.hlv = 1	--Integer	英雄等级
			tFightHeroInfo.hn = "假英雄"	--String	英雄名字
			tFightHeroInfo.k = 1	--Integer	杀敌数
			tFightHeroInfo.p = 9	--Integer	威望
			table.insert(tFightHeroInfos, tFightHeroInfo)
		end
		fd.dh = tFightHeroInfos			--List<FightHeroInfo>	防守方战斗英雄信息


		fd.an = "进攻方"			--String	进攻方名字
		fd.ac = 2			--Integer	进攻方国家
		fd.al = 2			--Integer	进攻方等级
		fd.ax = 2			--Integer	进攻方x坐标
		fd.ay = 2			--Integer	进攻方y坐标
		fd.at = 111			--Integer	进攻方总兵力
		fd.atl = 11		--Integer	进攻方损失的兵力
		local tFightHeroInfos = {}
		for i=1,10 do
			local tFightHeroInfo = {}
			tFightHeroInfo.npc = 1	--Integer	是否为NPC 0:否 1:是
			tFightHeroInfo.pn = "假的"	--String	所属玩家名字
			tFightHeroInfo.hlv = 1	--Integer	英雄等级
			tFightHeroInfo.hn = "假英雄"	--String	英雄名字
			tFightHeroInfo.k = 1	--Integer	杀敌数
			tFightHeroInfo.p = 9	--Integer	威望
			table.insert(tFightHeroInfos, tFightHeroInfo)
		end
		fd.ah = tFightHeroInfos			--List<FightHeroInfo>	进攻方英雄信息
		table.insert(fds, fd)
	end


	tMailMsg.fds = fds		--List<FightDetail>	矿点战斗列表[矿点邮件独有]
	tMailMsg.mine = 12001		--Integer	矿点模板ID[矿点邮件独有]
	tMailMsg.mx	 = 10		--Integer	矿点X位置[矿点邮件独有]
	tMailMsg.my	 = 10		--Integer	矿点Y位置[矿点邮件独有]
	tMailMsg.ct  = 10000	--Integer	采集时间[矿点邮件独有]
	tMailMsg.hn	 = "假的武将"		--String	武将名字[矿点邮件独有]
	tMailMsg.hid = 200031	--int	武将ID[矿点邮件独有]
	tMailMsg.hl	 = 1		--Integer	武将等级[矿点邮件独有]
	tMailMsg.he	 = 1		--Integer	武将经验 [矿点邮件独有]
	tMailMsg.mineNum = 9999		--	Long	采集量

	tMailMsg.dn	 = "防守方名称"		--String	防守方名称
	tMailMsg.dc	 = 1		--Integer	防守方国家
	tMailMsg.dl	= 1		--Integer	防守方等级
	tMailMsg.dx	 = 230		--Integer	目标x坐标
	tMailMsg.dy	= 450		--Integer	目标y坐标
	tMailMsg.dt	= 1		--Integer	目标总兵力
	tMailMsg.dtl = 2		--Integer	目标损失的兵力

	local tFightHeroInfos = {}
	for i=1,10 do
		local tFightHeroInfo = {}
		tFightHeroInfo.npc = 1	--Integer	是否为NPC 0:否 1:是
		tFightHeroInfo.pn = "假的"	--String	所属玩家名字
		tFightHeroInfo.hlv = 1	--Integer	英雄等级
		tFightHeroInfo.hn = "假英雄"	--String	英雄名字
		tFightHeroInfo.k = 1	--Integer	杀敌数
		tFightHeroInfo.p = 9	--Integer	威望
		table.insert(tFightHeroInfos, tFightHeroInfo)
	end
	tMailMsg.dh	= tFightHeroInfos		--List<FightHeroInfo>	防守方战斗英雄信息
	tMailMsg.an	= "进攻方名字"		--String	进攻方名字
	tMailMsg.ac	= 2		--Integer	进攻方国家
	tMailMsg.al	= 2		--Integer	进攻方等级
	tMailMsg.ax	= 1		--Integer	进攻方x坐标
	tMailMsg.ay	= 1		--Integer	进攻方y坐标
	tMailMsg.at	= 2		--Integer	进攻方总兵力
	tMailMsg.atl = 9		--Integer	进攻方损失的兵力

	local tFightHeroInfos = {}
	for i=1,5 do
		local tFightHeroInfo = {}
		tFightHeroInfo.npc = 1	--Integer	是否为NPC 0:否 1:是
		tFightHeroInfo.pn = "假的"	--String	所属玩家名字
		tFightHeroInfo.hlv = 1	--Integer	英雄等级
		tFightHeroInfo.hn = "假英雄"	--String	英雄名字
		tFightHeroInfo.k = 1	--Integer	杀敌数
		tFightHeroInfo.p = 9	--Integer	威望
		table.insert(tFightHeroInfos, tFightHeroInfo)
	end
	tMailMsg.ah	= tFightHeroInfos		--List<FightHeroInfo>	进攻方英雄信息


	tMailMsg.tt = 4 --目标类型 1：玩家城池 3:矿点 4：乱军[目标丢失邮件独有]
	tMailMsg.lt = 1--丢失类型 1:不在原地，2：保护中[目标丢失邮件独有]
	tMailMsg.tid = 13001--乱军/矿点模板ID[目标丢失邮件独有]
	tMailMsg.pl = 1 --玩家城市等级[目标丢失邮件独有]
	tMailMsg.pc = 1 --玩家国家[目标丢失邮件独有]
	tMailMsg.x = 1--目标X[目标丢失邮件独有]
	tMailMsg.y = 1--目标Y[目标丢失邮件独有]

	tMailMsg.did = 13001 --乱军或国战id
	local hs = {}
	for i=1,10 do
		local ff = {}
		ff.hid = 200031
		ff.lv = i --等级
		ff.t = i --带兵量
		table.insert(hs, ff)
	end
	tMailMsg.hs = hs

	local tMailMsgs = {}
	for i=1,10 do
		local newMsg = clone(tMailMsg)
		newMsg.id = i
		table.insert(tMailMsgs, newMsg)
	end
	
	print("设置测试数据====",#tMailMsgs)
	local tData = {}
	tData.c	 = 1 --Integer	当前页码
	tData.ps = 10 --Integer	每页大小
	tData.a	 = 11 --Integer	总页数
	tData.t	 = 100 --Integer	总条数
	tData.m	 =  tMailMsgs--List<MailMsg>	邮件列表

	self:onLoadMail(tData, 1)
end

--根据战报id获取所属邮件数据
function MailData:getMailMsgByFightRid( sFightRid )
	for k,v in pairs(self.tMailMsgs) do
		if v.sFightRid == sFightRid then
			return v
		end
	end
	return nil
end

--设置未读邮件
--tData：未读红点数据
function MailData:setNotReadNums( tData )
	if not tData then
		return
	end
	self.tNotReadNums = {}
	for i=1,#tData do
		local nCategory = tData[i].k
		local nNum = tData[i].v
		self.tNotReadNums[nCategory] = nNum
	end
end

--设置单个未读邮件数量
function MailData:setNotReadNum( nCategory, nNum)
	if not nCategory or not nNum then
		return
	end
	self.tNotReadNums[nCategory] = nNum
end

--添加相应的邮件未阅数字
function MailData:addNotReadNums( nCategory, nNum)
	if not self.tNotReadNums[nCategory] then
		self.tNotReadNums[nCategory] = nNum
	else
		self.tNotReadNums[nCategory] = self.tNotReadNums[nCategory] + nNum
	end
end

--删除相应的邮件未阅数字
function MailData:subNotReadNums( nCategory, nNum)
	if not self.tNotReadNums[nCategory] then
		return
	end

	self.tNotReadNums[nCategory] = self.tNotReadNums[nCategory] - nNum
	if self.tNotReadNums[nCategory] < 0 then
		self.tNotReadNums[nCategory] = 0
	end
end

--删除相应的邮件未阅数字全部
function MailData:subNotReadNumsAll( nCategory)
	self.tNotReadNums[nCategory] = 0
end

--获取相应的邮件未阅数字
function MailData:getNotReadNums( nCategory )
	return self.tNotReadNums[nCategory] or 0
end

--获取相应的邮件未阅数字总和
function MailData:getNotReadNumsAll( ) 
	local nNum = 0
	for k,v in pairs(self.tNotReadNums) do
		nNum = nNum + v
	end
	return nNum
end

--邮件是否显示(今日已获圣诞袜: %s/%s)
--_tMailMsg:邮件信息
function MailData:getAwardExtraStr( _tMailMsg )
	-- body
	local tRewards = _tMailMsg.tItemList
	local bHasSDW = false --是否有圣诞袜
	if tRewards and table.nums(tRewards) > 0 then
		for i, v in pairs(tRewards) do 
			if v.k == e_item_ids.sdw then
				bHasSDW = true
				break
			end
		end
	end
	local tActData = Player:getActById(e_id_activity.dragontreasure)
	local sExLabel = ""
	if bHasSDW and tActData then
		--(今日已获圣诞袜: %s/%s)
		sExLabel = string.format(getConvertedStr(7, 10298), tActData.nDc, tActData.nTdc)
	end
	return sExLabel
end

return MailData