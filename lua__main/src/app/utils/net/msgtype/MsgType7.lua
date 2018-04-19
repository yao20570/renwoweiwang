----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-01-16 16:01:05 
-- Description: 网络协议的协议号
-----------------------------------------------------
MsgType = MsgType or {}

------------------------------------- 公告 ------------------------------------

--加载公告列表数据
MsgType.loadNoticeData = {id=-4520, keys = {}}

--请求阅读公告(公告id和版本)
MsgType.reqReadNoticeData = {id=-4515, keys = {"nid", "ver"}}

------------------------------------- 公告 ------------------------------------


------------------------------------- 神兵 ------------------------------------

--加载玩家的神兵数据
MsgType.loadAllWeaponData = {id=-7100, keys = {}}

--请求打造神兵(神兵id)
MsgType.reqBuildWeapon = {id=-7101, keys = {"afId"}}

--打造神兵完成后请求新神兵数据(神兵id)
MsgType.reqWeaponNewData = {id=-7102, keys = {"afId"}}

--请求加速打造神兵
MsgType.reqSpeedBuilding = {id=-7103, keys = {"afId"}}

--请求神兵升级
MsgType.reqWeaponLevelUp = {id=-7104, keys = {"afId"}}

--请求神兵进阶
MsgType.reqWeaponAdvance = {id=-7105, keys = {"afId"}}

--进阶神兵完成后请求
MsgType.reqAdvancedWeaponData = {id=-7106, keys = {"afId"}}

--请求加速进阶神兵
MsgType.reqSpeedAdvance = {id=-7107, keys = {"afId"}}

--神兵碎片推送
MsgType.refreshFragments = {id=-7108, keys = {}}

--请求购买神兵碎片
MsgType.reqBuyFragments = {id=-7109, keys = {"afId", "num"}}

--商队兑换(选择消耗资源id和兑换资源id)
MsgType.reqResExchange = {id = -8506, keys = {"ex", "target"}}

--[-8009]副本关卡数据推送
MsgType.refreshFbLevelData = {id = -8009, keys = {}}

--[8010]副本数据更新推送
MsgType.pushFbNewData = {id=-8010, keys = {}}

------------------------------------- 神兵 ------------------------------------

------------------------------------- 分享 ------------------------------------
--请求分享
MsgType.reqShare = {id = -4533, keys = {"nid", "param", "channelId", "infoId","type"}}

------------------------------------- 分享 ------------------------------------

------------------------------------- 成长基金 --------------------------------
--请求购买基金
MsgType.reqBuyGrowFounds = {id = -4002, keys = {}}
--请求获取基金奖励
MsgType.reqGetFoundsAwards = {id = -4003, keys = {"id"}}
--请求已购买基金人数
MsgType.reqBuyFoundsPlayerNum = {id = -4037, keys = {}}

--(新版成长基金)请求获取奖励
MsgType.reqGetNewFoundsAwards = {id = -4083, keys = {"id", "vn"}}
------------------------------------- 成长基金 --------------------------------
------------------------------------- 礼包兑换 --------------------------------
--请求兑换礼包
MsgType.reqRechargeGift = {id = -2206, keys = {"cdkey"}}
------------------------------------- 礼包兑换 --------------------------------
------------------------------------- 每日登录 --------------------------------
--检查是否可以领取每日奖励
-- MsgType.reqCheckDayAwards = {id = -4019, keys = {}}
--请求领取每日奖励
-- MsgType.reqGetDayAwards = {id = -4018, keys = {}}
--每日奖励0点推送
MsgType.pushDayLoginAwards = {id = -4041, keys = {}}
------------------------------------- 每日登录 --------------------------------
------------------------------------- 七天登录 --------------------------------
--请求领取七天登录奖励
MsgType.reqSevenDayAwards = {id = -4005, keys = {"day"}}
------------------------------------- 七天登录 --------------------------------
------------------------------------- 特卖商场 --------------------------------
--请求购买特价商品
MsgType.reqBuySaleGoods = {id = -4042, keys = {"id"}}
------------------------------------- 特卖商场 --------------------------------

------------------------------------- 消费好礼 --------------------------------
--请求领取消费好礼奖励
MsgType.reqConsumeAwards = {id = -4033, keys = {"target"}}
------------------------------------- 消费好礼 --------------------------------

------------------------------------- 屯田计划 --------------------------------
--请求购买计划
MsgType.reqBuyFarmPlan = {id = -4022, keys = {"type"}}
--请求领取计划奖励
MsgType.reqGetFarmPlanAwards = {id = -4023, keys = {"type", "day"}}
------------------------------------- 屯田计划 --------------------------------

------------------------------------- 功能引导 --------------------------------
--请求已经引导过的界面数据(建筑引导)
MsgType.reqGetAlreadyGuided = {id = -2010, keys = {}}
--记录已经引导过的界面id
MsgType.reqPlayGuideDlg = {id = -2011, keys = {"rid"}}
------------------------------------- 功能引导 --------------------------------

--强制撤回信息推送
MsgType.pushRecallMsg = {id = -4532, keys = {}}

--请求活动加速
MsgType.reqEnemySpeed = {id = -4040, keys = {"itemId", "loc"}}

--------------------------------- 七日为王 --------------------------------
--[1.每日登录]领取登录奖励
MsgType.reqDailyLoginAwd = {id = -4050, keys = {"day"}}
--[2.主公等级]领取等级奖励
MsgType.reqLevelAwd = {id = -4051, keys = {"lvl"}}
--[3.初战天下]领取击杀乱军奖励
MsgType.reqKillArmyAwd = {id = -4052, keys = {"reb"}}
--[4.科技升级]领取科技奖励
MsgType.reqTnolyupAwd = {id = -4053, keys = {"scie"}}
--[5.觅得良将]领取武将奖励
MsgType.reqRecruitHeroAwd = {id = -4054, keys = {"idx"}}
--[6.再战天下]领取BOSS奖励
MsgType.reqKikkBossAwd = {id = -4055, keys = {"boss"}}
--[7.备战天下]领取装备奖励
MsgType.reqEquipAwd = {id = -4056, keys = {"idx"}}
--[8.副本推进]领取副本通关的奖励
MsgType.reqFubenAwd = {id = -4057, keys = {"cid"}}
--[9.逐鹿天下]领取城战胜利的奖励
MsgType.reqCityFightAwd = {id = -4058, keys = {"city"}}
--[10.全力冲刺]领取道具加速奖励
MsgType.reqItemSpeedAwd = {id = -4059, keys = {"sp"}}
--[11.军事升级]领取兵营奖励
MsgType.reqCampAwd = {id = -4060, keys = {"cp"}}
--[12.神兵之威]领取神兵奖励
MsgType.reqShenbingAwd = {id = -4061, keys = {"af"}}
--[14.兵强马壮]领取募兵奖励
MsgType.reqTroopsAwd = {id = -4063, keys = {"re"}}
--[15.国泰民安]领取资源田奖励
MsgType.reqResourceAwd = {id = -4064, keys = {"rs"}}
--[18.装备洗炼]领取洗炼奖励
MsgType.reqSuccinctAwd = {id = -4067, keys = {"tr"}}

--------------------------------- 七日为王 --------------------------------

--------------------------------- 新首充活动 --------------------------------
--[4071]新首充活动奖励领取
MsgType.getNewFirstRechargeAwards = {id=-4071, keys = {}}

--------------------------------- 新首充活动 --------------------------------

--------------------------------- 寻龙夺宝 --------------------------------
--[4074]寻龙夺宝请求抽取, type:1抽一次, 10抽10次
MsgType.reqDragonTreasure = {id=-4074, keys = {"type"}}
--[4076]购买物品
MsgType.reqBuyItem = {id=-4076, keys = {"itemId", "num"}}

--------------------------------- 寻龙夺宝 --------------------------------

--[2013]查看玩家战力评分
MsgType.reqCheckPowerOut = {id=-2013, keys = {"id"}}
--[2014]查看玩家对比数据
MsgType.reqPowerBalance = {id=-2014, keys = {"red", "blue"}}

----------------------------------触发礼包-----------------------------------
--[-6016]加载新触发礼包
MsgType.loadNewTriggerGift = {id=-6016, keys = {}}
--[-6017]新触发礼包推送
MsgType.pushNewTriggerGift = {id=-6017, keys = {}}
----------------------------------触发礼包-----------------------------------

----------------------------------装备-----------------------------------
--[-7014]装备强化
--euid: 装备uuid, blessStone: 使用祝福石数量
MsgType.reqEquipStrengthen = {id=-7014, keys = {"euid", "blessStone"}}

----------------------------------装备-----------------------------------

--[-4101]活动a副本推进奖励
MsgType.reqFubenPassReward = {id=-4101, keys = {"id"}}
--[-4102]活动a主公升级奖励
MsgType.reqPlayerLvUpReward = {id=-4102, keys = {"id"}}
--[-4103]活动a装备洗炼奖励
MsgType.reqEquipRefineReward = {id=-4103, keys = {"id"}}
--[-4105]活动a神器升级奖励
MsgType.reqArtifactMakeReward = {id=-4105, keys = {"id"}}


----------------------------------武将星魂-----------------------------------
--[-8111]激活和突破
MsgType.reqHeroSoulActive = {id=-8111, keys = {"hid", "type", "stage", "pos"}}
--[-8113]星魂还原
MsgType.reqHeroSoulRecover = {id=-8113, keys = {"hid"}}
----------------------------------武将星魂-----------------------------------

----------------------------------过关斩将-----------------------------------
--[-6300]登录加载数据
MsgType.loadPassKillHeroData = {id=-6300, keys = {}}
--[-6301]过关斩将闯关
MsgType.reqPassKillHeroFight = {id=-6301, keys = {"hids"}}
--[-6302]重置副本
MsgType.reqResetFight = {id=-6302, keys = {}}
--[-6303]购买过关斩将物品
MsgType.reqBuyPassGoods = {id=-6303, keys = {"id"}}
--[-6304]重置过关斩将商店
MsgType.reqResetPassShop = {id=-6304, keys = {}}
--[-6305]过关斩将数据刷新推送
MsgType.pushPassKillHeroData = {id=-6305, keys = {}}
--[-6306]战报阅读记录
MsgType.reqReadPassKillHeroReport = {id=-6306, keys = {"reportId"}}
--[-6307]过关斩将上阵
MsgType.reqPassKillHeroOnline = {id=-6307, keys = {"heroId"}}
----------------------------------过关斩将-----------------------------------

----------------------------------资源打包-----------------------------------
--[-2149]资源打包
MsgType.reqPackResours = {id=-2149, keys = {"type"}}
--[-2100]资源打包次数推送
-- MsgType.pushPackResours = {id=-2100, keys = {}}
----------------------------------资源打包-----------------------------------
----------------------------------募兵府-----------------------------------
--[-2143]募兵府创建
MsgType.reqBuildRecruitHouse = {id=-2143, keys = {"buildId", "loc", "type"}}
----------------------------------募兵府-----------------------------------

----------------------------------国家科技-----------------------------------
--[-5101]国家科技-加载科技
MsgType.loadCountryTnoly = {id=-5101, keys = {}}
--[-5102]国家科技-科技捐献
MsgType.reqTnolyDonate = {id=-5102, keys = {"sid", "type"}}
--[-5103]国家科技-恢复捐献
MsgType.reqDonateRecover = {id=-5103, keys = {}}
--[-5104]国家科技-数据更新
MsgType.pushRefreshCountryTnoly = {id=-5104, keys = {}}
--[-5105]国家科技-科技推荐
MsgType.reqRecommendTnoly = {id=-5105, keys = {"sid", "opt"}}
----------------------------------国家科技-----------------------------------

--[-4118]2030王者归来领取奖励
MsgType.reqWelcomebackAwards = {id=-4118, keys = {"day"}}
