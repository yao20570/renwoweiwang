----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-01-16 16:01:05 
-- Description: 网络协议的协议号
-----------------------------------------------------
MsgType = MsgType or {}
--加载玩家背包信息
MsgType.loadBag = {id = -2300, keys = {}}
--背包数据更新
MsgType.pushBag = {id = -2301, keys = {}}
--使用物品
MsgType.useStuff = {id = -2302, keys = {"useId", "useNum", "type"}}

--雇用文官
MsgType.employCivil = {id = -2111, keys = {"id"}}
--请求更改角色名称或性别
MsgType.changeNameOrGender = {id = -2004, keys = {"name", "gender"}}
--改名卡使用
--name 新名字 type 1-正常使用 2.购买并使用
MsgType.useRenameCard = {id = -2304, keys = {"name", "type"}}
--[-2305]物品今天使用次数重置推送
MsgType.clearItemDayUseInfo = {id = -2305, keys = {}}
--[-2306]物品今天使用次数更新推送
MsgType.pushItemDayUseInfo = {id = -2306, keys = {}}


--资源加载
MsgType.loadResource = {id = -2109, keys = {}}
--资源推送
MsgType.pushResource = {id = -2110, keys = {}}
--文官倒计时刷新
MsgType.refreshOfficalCD = {id = -2115, keys = {}}	
--作坊添加生产项
MsgType.addProduceItem = {id = -2116, keys = {"itemId", "proId","flag"}}
--作坊生产完成推送
MsgType.pushProduceFinish = {id = -2124, keys = {}}
--获取生产时间 [2133]工坊生产材料需要多少时间
MsgType.getProduceTime = {id = -2133, keys = {"tp"}}
--购买生产队列 
MsgType.buyProduceQueue = {id = -2118, keys = {}}
--领取材料
MsgType.getProduction = {id = -2121, keys = {}}
--雇用研究员
MsgType.employResearcher = {id = -8203, keys = {"id"}}
--任务数据加载
MsgType.loadMissions = {id = -8400, keys = {}}
--任务数据更新推送
MsgType.refreshMission = {id = -8401, keys = {}}
--点击页面完成任务
MsgType.finishTask = {id = -8402, keys = {"taskId"}}
--任务完成领取奖励
MsgType.getTaskPrize = {id = -8403, keys = {"taskId"}}
--任务完成领取奖励
MsgType.getDailyTaskPrize = {id = -8405, keys = {"taskId"}}
--任务完成领取奖励
MsgType.getDailyScorePrize = {id = -8406, keys = {"targe"}}
--请求排行榜数据
MsgType.getRankData = {id = -8451, keys = {"type", "currPage", "size"}}
--获取其他玩家数据
MsgType.getRankPlayerInfo = {id = -8452, keys = {"id", "name"}}
--排行榜的数据刷新通知
MsgType.refreshRankInfoNotice = {id = -8453, keys = {}}
--[8454]查看玩家个人排行榜信息
MsgType.getMyRankInfo = {id = -8454, keys = {}}
--购买Vip礼包
MsgType.buyVipGift = {id = -2008, keys = {"vip"}}
--充值结果推送
MsgType.pushRecharge = {id = -2005, keys = {}}
--[2135]工坊队列倒计时检测
MsgType.checkProQueueCD = {id = -2135, keys = {"proId"}}
--[2136]工坊黄金加速完成
MsgType.atelierSpeedFinished = {id = -2136, keys = {}}



--选择国家
MsgType.choiceCountry = {id = -5000, keys = {"cid", "r"}}
--国家开发
MsgType.stateDevelopmen = {id = -5001, keys = {}}
--加载官员/官员候选人列表
MsgType.loadOfficialInfo = {id = -5002, keys = {}}
--投票给官员候选人
MsgType.officialVote = {id = -5003, keys = {"cid", "free"}}
--膜拜国王
MsgType.worshipKing = {id = -5004, keys = {}}
--发布公告
MsgType.announceDecree = {id = -5005, keys = {"notice"}}
--获取膜拜次数
MsgType.getWorshipTimes = {id = -5006, keys = {}}
--国家公告变更推送
MsgType.pushDecree = {id = -5007, keys = {}}
--加载国家数据
MsgType.loadCountryInfo = {id = -5015, keys = {}}
--获取城战积分箱子
MsgType.getCityFightBox = {id = -5008, keys = {"taskId"}}
--加载国家荣誉任务完成情况
MsgType.loadCountryGlory = {id = -5009, keys = {}}
--获取荣誉任务奖励
MsgType.getHonorTaskPrize = {id = -5010, keys = {"taskId"}}
--限时任务刷新推送
MsgType.pushLimitTask = {id = -5011, keys = {}}
--获取限时任务奖励
MsgType.getLimitTaskPrize = {id = -5012, keys = {"taskId"}} 
--罢免将军
MsgType.recallGeneral = {id = -5013, keys = {"officialId"}}
--任命将军
MsgType.appoinrGeneral = {id = -5014, keys = {"oid"}}
--加载国家日志
MsgType.loadCountryLog = {id = -5016, keys = {}}
--限时任务完成度变化推送
MsgType.limitTaskChange = {id = -5017, keys = {}}
--城战积分变化
MsgType.cityFightScoreChange = {id = -5018, keys = {}}
--升级爵位
MsgType.upNobility = {id = -5020, keys = {}}
--推送官员候选人数据更新
MsgType.pushCandidate = {id = -5021, keys = {}}
--加载我的国家城池
MsgType.loadCountryCity = {id = -5022, keys = {}}
--国家日志推送
MsgType.pushCountryLog = {id = -5023, keys = {}}
--加载将军候选人列表
MsgType.getGeneralCandidate = {id = -5024, keys = {}}
--官员任命罢免推送
MsgType.pushOfficial = {id = -5025, keys = {}}
--竞选开始推送
MsgType.pushStartVote = {id = -5027, keys = {}}
--竞选结束推送
MsgType.pushEndVote = {id = -5026, keys = {}}
--国家数据推送给
MsgType.pushCountryInfo = {id = -5019, keys = {}}
--国家城池数据推送
MsgType.pushCountryCity = {id = -5028, keys = {}}
--国家荣誉任务奖励推送
MsgType.pushHonorPrize = {id = -5029, keys = {}}
--[-5030]官员/候选人更名推送
MsgType.pushOfficialRename = {id = -5030, keys = {}}
--[-5031]官员竞选状态推送
MsgType.pushOfficialStatus = {id = -5031, keys = {}}
--[-5032]官员推送
MsgType.pushPoliticiansPoster = {id= -5032, keys = {}}

--活动
--[4006]国战排行领取奖励
MsgType.reqGZRankPrize = {id = -4006, keys= {"id"}}
--[4026][锻造排行1005]领取奖励
MsgType.reqDZRankPrize = {id = -4026, keys = {"grade"}}
--[4030][兵力排行1010]领取奖励
MsgType.reqBLRankPrize = {id = -4030, keys = {"grade"}}
--[4035][洗炼排行1015]领取奖励
MsgType.reqXLRankPrize = {id = -4035, keys = {"grade"}}
--[4028][屯粮排行1009]领取奖励
MsgType.reqTLRankPrize = {id = -4028, keys = {"lv"}}
--[4038][屯铁排行1019]领取奖励
MsgType.reqTTRankPrize = {id = -4038, keys = {"lv"}}
--[4043][攻城排行1020]领取奖励
MsgType.reqGCRankPrize = {id = -4043, keys = {"lv"}}
--[4044]全民返利刷新数据
MsgType.reloadpeoplerebate = {id = -4044, keys = {}}
--[4072][红包馈赠1026]领取红包馈赠
MsgType.reqredpacket = {id = -4072, keys = {"target"}}
--[4106][1043] 攻城拔寨领取奖励
MsgType.reqAttackVillage = {id = -4106, keys = {"id"}}
--[4110][1044]国家栋梁领取奖励
MsgType.reqNationPillars = {id = -4110, keys = {"lv"}}

--好友系统
--[4521]添加好友
MsgType.reqAddFriend = {id = -4521, keys = {"addAid", "addName"}}
--[-4527]添加好友推送
MsgType.pushFriendInfo = {id = -4527, keys = {}}
--[4528]删除好友
MsgType.deleteFriend = {id = -4528, keys = {"deleteAid"}}
--[4530]加载好友列表
MsgType.loadFriendsInfo = {id = -4530, keys = {}}
--[-4529]删除好友推送
MsgType.pushdeleteFriend = {id = -4529, keys = {}}
--[4522]赠送好友体力
MsgType.giveFriendVit = {id = -4522, keys = {"fid"}}
-- --[4524]请求赠送体力列表
-- MsgType.reqGiveVitList = {id = -4524, keys = {}}
--[4523]领取赠送的体力
MsgType.getFriendVit = {id = -4523, keys = {"fid"}}
--[-4525]赠送体力信息推送
MsgType.pushGiveVit = {id = -4525, keys = {}}
--[4537]加载最近联系人列表
MsgType.loadRecentFriends = {id = -4537, keys = {}}
--[4512]屏蔽玩家发言
MsgType.shieldFriend = {id = -4512, keys = {"shieldId", "shieldName"}}
--[4513]解除玩家禁言
MsgType.removeshieldFriend = {id = -4513, keys = {"shieldId"}}
--[4507]点赞玩家
MsgType.thumbupFriend = {id = -4507, keys = {"accepterId"}}
--被点赞推送
MsgType.pustthumbupMsg = {id = -4538, keys = {}}

--[4508]推送点赞数据
MsgType.reqThumbupData = {id = -4508, keys = {"accepterId"}}

--[4511]聊天信息举报
MsgType.reqTipOff = {id= -4511, keys = {"chatId", "type", "cause"}}

--4531最近联系人推送
MsgType.pushRecent = {id = -4531, keys = {}}

--4526好友数据零点推送
MsgType.pushFriendsData = {id = -4526, keys = {}}
--4537加载最近联系人数据

--七日等级子活动相关协议
--[4062]7日登基[13.科技排行]领取科技排行奖励
MsgType.reqSevenkingS = {id = -4062, keys = {"grade"}}
--[4065]7日登基[16.攻城排行]领取攻城排行奖励
MsgType.reqSevenkingC = {id = -4065, keys = {"grade"}}
--[4066]7日登基[17.装备排行]领取装备排行奖励
MsgType.reqSevenkingE = {id = -4066, keys = {"grade"}}
--[4068]7日登基[19.副本排行]领取副本排行奖励
MsgType.reqSevenkingD = {id = -4068, keys = {"grade"}}
--[4069]7日登基[20.王宫排行]领取王宫排行奖励
MsgType.reqSevenkingP = {id = -4069, keys = {"grade"}}
--[4070]7日登基[21.权倾天下]领取战力排行奖励
MsgType.reqSevenkingZ = {id = -4070, keys = {"grade"}}


--[2009]改变人物形象
MsgType.reqChangeCharacters = {id = -2009, keys = {"id", "type"}}
--[2012]校对限时头像时间
MsgType.checkTimeBox = {id = -2012, keys = {}}

--[4701]发送红包给所有人抢
MsgType.opencatchredpocket = {id=-4701, keys={"itemId", "num", "channel"}}
--[4702]发送红包给好友
MsgType.sendredpocket = {id=-4702, keys={"itemId", "num", "targeId"}}
--[4703]查看红包信息
MsgType.checkredpocket = {id=-4703, keys={"redPacketId"}}
--[4704]抢红包
MsgType.catchredpocket = {id=-4704, keys={"redPacketId"}}

--{4705}抢红包推送
MsgType.pushcatchredpocket = {id=-4705, keys={}}

--[4078]王权征收获取奖励
MsgType.reqroyaltycollect = {id=-4078, keys={"day"}}

--[4097]新王权征收获取奖励
MsgType.reqnewroyaltycollect = {id=-4097, keys={"day"}}

--高级御兵术
--MsgType.reqTroopLvUp = {id=-2138, keys={"type"}}
MsgType.reqTroopActivite = {id=-2140, keys={"type"}}


---------------------------------------竞技场 相关-------------------
--[6105]加载竞技场信息(没开放建筑或者没设置个人阵容不传个人数据)
MsgType.loadArenaData = {id = -6105, keys = {}}

--[6100]加载自己的竞技场视图
MsgType.loadArenaView = {id = -6100, keys = {}}

--[6101]竞技场挑战
MsgType.reqArenaChallenge = {id = -6101, keys = {"rank", "targeId"}}

--[6102]竞技场获取积分奖励
MsgType.reqArenaScoreAward = {id = -6102, keys = {"itg"}}

--[6103]扫荡
MsgType.reqArenaSweep = {id = -6103, keys = {"time"}}

--[6104]购买竞技场物品
MsgType.buyArenaItem = {id = -6104, keys = {"idx", "num"}}

--[6106]设置竞技场阵容
MsgType.adjustArenaLineUp = {id = -6106, keys = {"u"}}

--[-6107]竞技场数据更新
MsgType.pushArenaData = {id = -6107, keys = {}}

--[6108]查看战斗记录
MsgType.checkArenaRecord = {id = -6108, keys = {}}

--[6109]查看竞技场排行榜
MsgType.checkArenaRank = {id = -6109, keys = {"page", "size"}}

--[6110]查看幸运排行榜
MsgType.checkArenaLuckyRank = {id = -6110, keys = {}}

--[6111]竞技场购买挑战次数
MsgType.buyChallengeTimes = {id = -6111, keys = {"ten"}}

--查看竞技场玩家
MsgType.checkArenaPlayer = {id = -6112, keys = {"targeId"}}

--我的战斗记录推送
MsgType.pushMyArenaReport = {id = -6113, keys = {}}
--[6114]商店刷新
MsgType.reqRefreshArenaShop = {id = -6114, keys = {}}

--[6115]竞技场更新阵容显示战力
MsgType.reqCurShowCurCombat = {id = -6115, keys = {}}

--[6116]竞技场清除挑战cd时间
MsgType.clearChallengeCd = {id = -6116, keys = {}}
--[6117]刷新玩家挑战队列
MsgType.reqNewChallengeList = {id = -6117, keys = {}}
--[6118]领取排行奖励
MsgType.reqGetArenaRankPrize = {id = -6118, keys = {}}
--[6119]领取幸运奖励
MsgType.reqGetArenaLuckyPrize = {id = -6119, keys = {}}
--[6120]竞技场使用挑战令
MsgType.useArenaToken = {id = -6120, keys = {"itemId", "num"}}
--[6121]记录阅读的战报
MsgType.readArenaReport = {id = -6121, keys = {"reportId", "type", "op"}}
---------------------------------------竞技场 相关-------------------

---------------------------------------加速道具使用 相关-------------------
--[7015]装备道具加速
MsgType.speedMakeEquip = {id = -7015, keys = {"itemId", "num", "opt"}}
---------------------------------------加速道具使用 相关-------------------

---------------------------------------韬光养晦 相关-------------------
--[3631]加载韬光养晦数据
MsgType.loadTGYHData = {id = -3631, keys = {}}
--[-3632]数据推送
MsgType.pushTGYHData = {id = -3632, keys = {}}
--[3633]领取任务奖励
MsgType.reqTGYHReward = {id = -3633, keys = {"id"}}
--[3634]领取免费奖励
MsgType.reqTGYHFreeReward = {id = -3634, keys = {}}
---------------------------------------韬光养晦 相关-------------------

---------------------------------------自动建造管理-------------------
-- [2145]设置是否低等级优先升级
MsgType.reqLowGradePriority = {id = -2145, keys = {"state"}}
-- [2146]设置自动建造升级的类型
MsgType.reqAutoBuildType = {id = -2146, keys = {"state"}}
-- [2147]设置自定义自动建造优先级
MsgType.reqCustomPriority = {id = -2147, keys = {"param"}}
-- [2148]设置建筑是否开启自动建造
MsgType.reqOpenAutoBuild = {id = -2148, keys = {"buildId", "state"}}
---------------------------------------自动建造管理-------------------

---------------------------------------纣王试炼-------------------
--[4113][2028 纣王试炼获取国家积分排行]
MsgType.reqZhouwangCountryRank = {id = -4113, keys = {}}
--[4114][2028 纣王试炼碎片合成武将]
MsgType.makeHerobyZhowwangPiece = {id = -4114, keys = {"buy"}}
--[4115][2028 纣王试炼领取排行奖励]
MsgType.reqZhouwangRankPrize = {id = -4115, keys = {"grade"}}
-- [4116][2028 纣王试炼领取国家奖励]
MsgType.reqZhouwangCountryPrize = {id = -4116, keys = {}}
---------------------------------------纣王试炼-------------------

---------------------------------------国家任务-------------------
--[5049]加载国家任务
MsgType.LoadCountryTask = {id = -5049, keys = {}}
--[5050]国家任务数据推送
MsgType.pushCountryTask = {id = -5050, keys = {}}
--[5100]领取国家任务奖励
MsgType.getCountryTaskReward = {id = -5100, keys = {"taskId"}}
---------------------------------------国家任务-------------------
--[8114]更改主力队列武将的位置
MsgType.editOnLineHeros = {id = -8114, keys = {"hsIds"}}
--[8115]更改采集队列武将的位置
MsgType.editCollectHeros = {id = -8115, keys = {"hsIds"}}
--[8116]更改城防队列武将的位置
MsgType.editDefHeros = {id = -8116, keys = {"hsIds"}}
---------------------------------------------