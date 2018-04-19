----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-01-16 16:01:05 
-- Description: 网络协议的协议号
-----------------------------------------------------
MsgType = MsgType or {}

------------世界
--加载城市数据3000
MsgType.reqWorldCityData = {id=-3000, keys = {}}

--搜索周围视图点3008
MsgType.reqWorldAroundDot = {id=-3008, keys = {"x", "y"}}

--加载区域地图内城市分布点3009
MsgType.reqWorldBlock = {id=-3009, keys = {"blockIndex"}}

--玩家迁城3001
MsgType.reqWorldMigrate = {id=-3001, keys = {"type", "blockIndex", "x", "y", "ifbuy"}}

--创建世界任务3002
MsgType.reqWorldTask = {id = -3002, keys = {"type", "x", "y", "hids", "warId", "acker", "warType", "cwID", "ct"}}

--输入任务指令3003
MsgType.reqWorldTaskInput = {id = -3003, keys = {"taskUUID", "orderNumber", "costItem", "ifbuy"}}

--任务状态变更推送3006
MsgType.pushWorldTask = {id = -3006, keys = {}}

--视图点消失推送3007
MsgType.pushWorldDotDispear = {id = -3007, keys = {}}

--行军推送3005
MsgType.pushWorldTaskMove = {id = -3005, keys = {}}

--区域内城战发生变化推送3014
MsgType.pushWorldBCWar = {id = -3014, keys = {}}

--区域内城池占领发生变化推送3015
MsgType.pushWorldBCOccupy = {id = -3015, keys = {}}

--发起国战3010
MsgType.reqWorldCountryWar = {id = -3010, keys = {"id"}}

--查看城战信息3011
MsgType.reqWorldCityWarInfo = {id = -3011, keys = {"owner"}}

--查看城池国战信息3012
MsgType.reqWorldCountryWarInfo = {id = -3012, keys = {"id"}}

--侦查3004
MsgType.reqWorldDetect = {id = -3004, keys = {"x", "y", "type", "costType"}}

--查看玩家驻防信息3013
MsgType.reqWorldGarrisonInfo = {id = -3013, keys = {"x", "y"}}

--查看我国国战列表3016
MsgType.reqWorldMyCountryWar = {id = -3016, keys = {}}

--征收图纸3017
MsgType.reqWorldLevyPaper = {id = -3017, keys = {"cityID"}}

--申请城主3018
MsgType.reqWorldApplyCityOwner = {id = -3018, keys = {"x", "y"}}

--我国国战列表推送3021
MsgType.pushWorldMyCountryWar = {id = -3021, keys = {}}

--我的任务移除推送3019
MsgType.pushWorldDelTask = {id = -3019, keys = {}}

--视图点变化推送3020
MsgType.pushWorldDotChange = {id = -3020, keys = {}}

--[3505]免费迁往州
MsgType.freetostate = {id = -3505, keys = {}}

--移除我国国战列表推送3022
-- MsgType.pushWorldDelMyCountryWar = {id = -3022, keys = {}} --cd时间自己关掉，废弃掉

--临时测试
MsgType.reqWorldTempBaseData = {id = -8888, keys = {"c"}}

--[-3023]城战提醒推送
MsgType.pushWorldHitMyCityNotice = {id = -3023, keys = {}}

--[3024]加载城主候选人列表
MsgType.reqWorldCityCandidate = {id = -3024, keys = {"id", "begin"}}

--[3025]遣返友军驻防
MsgType.reqWorldGarrisonBack = {id = -3025, keys = {"tid"}}

--[3026]季节变化推送
MsgType.pushWorldSeasonDay = {id = -3026, keys = {}}

--[3030]城主卸任
MsgType.reqWorldAbandonCityOwner = {id = -3030, keys = {"cityID"}}

--[3027]发起召唤
MsgType.reqWorldReqCall = {id = -3027, keys = {}}

--[3046]重发召唤公告
MsgType.reqWorldReqCallNotice = {id = -3046, keys = {}}

--[3028]参与召唤
MsgType.reqWorldJoinCall = {id = -3028, keys = {"caller"}}

--[3029]查看召唤信息
-- MsgType.reqWorldCheckCall = {id = -3029, keys = {}}

--[3031]推送我自己城池的协防信息
MsgType.pushWorldMyCityGarrison = {id = -3031, keys = {}}

--[3032]补充城防
MsgType.reqSupplyCity = {id = -3032, keys = {"cityID"}}

--[3033]修改名城/都城名字
MsgType.reqWorldCityRename = {id = -3033, keys = {"cityID", "n", "ifBuy"}}

--[3034]列出所有区域中心城的占领信息
MsgType.reqWorldCenterCity = {id = -3034, keys = {} }

--[-3035]区域中心城占领信息推送
MsgType.pushWorldCenterCity = {id = -3035, keys = {} }

--[-3036]乱军击杀过的最大等级
MsgType.pushWorldWildArmyLv = {id = -3036, keys = {} }

--[-3037]被迁城推送
MsgType.pushBeMigrated = {id = -3037, keys = {}}

--[-3038]领取一血图纸
MsgType.reqSysCityFKPaper = {id = -3038, keys = {"cityID"}}

--[3039]城战请求支援
MsgType.reqCityWarSupport = {id = -3039, keys = {"tid", "warID"}}

--[3047]城战
MsgType.pushWorldCityData = {id = -3047, keys = {} }

--[-3048]推送我的城战推送
MsgType.pushMyCityWarMsg = {id = -3048, keys = {}}

--[-3049]加载正在赶往的友军帮助列表
MsgType.reqFriendArmys = {id = -3049, keys = {}}

--[-3050]友军帮助推送
MsgType.pushFriendArmy = {id = -3050, keys = {}}

--[-3500]乱军战斗画面推送
MsgType.pushWildArmyFight  = {id = -3500, keys = {}}

------------邮件
--[3051]加载邮件
MsgType.reqMailLoad = {id = -3051, keys = {"category", "count"}}

--[3052]将邮件设置为已读状态
MsgType.reqMailReaded = {id = -3052, keys = {"category", "mid"}}

--[3053]删除邮件
MsgType.reqMailDel = {id = -3053, keys = {"category", "mid"}}

--[3054]推送新邮件
MsgType.pushMailNew = {id = -3054, keys = {}}

--[3055]保存邮件
MsgType.reqMailSave = {id = -3055, keys = {"category", "mid"}}

--[3056]获取邮件物品
MsgType.reqMailGet = {id = -3056, keys = {"category", "mid"}}

--[3057]加载战斗回放
MsgType.reqMailFightReplay = {id = -3057, keys = {"rid"}}

--[3058]加载邮件战斗者列表信息
MsgType.reqMailBattle = {id = -3058, keys = {"rid"}}

--[3059]撤销保存邮件
MsgType.reqMailSaveCancel = {id = -3059, keys = {"mid"}}

--[3060]获取邮件未读数量
MsgType.reqMailNotReadNums = {id = -3060, keys = {}}

--[3061]获取单封邮件，先从本地查询是否有，一般用于FigthDetail.jm字段
MsgType.reqMailDetail  = {id = -3061, keys = {"mid"}}

------------装备操作
--[7000]加载玩家装备数据
MsgType.reqEquipLoad = {id = -7000, keys = {}}

--[-7001]装备数据变化推送
MsgType.pushEquipChange = {id = -7001, keys = {}}

--[7002]装备恢复免费洗炼次数
MsgType.refreshEquipFreeTrain = {id = -7002, keys = {}}

--[7003]装备洗炼
MsgType.reqEquipTrain = {id = -7003, keys = {"euid", "type"}}

--[7004]装备高级洗炼
MsgType.reqEquipHighTrain = {id = -7004, keys = {"euid"}}

--[7005]穿上装备
MsgType.reqEquipWear = {id = -7005, keys = {"euids", "hid"}}

--[7006]解下装备
MsgType.reqEquipTakeOff = {id = -7006, keys = {"euids"}}

--[7007]购买装备容量
MsgType.reqEquipCapacity = {id = -7007, keys = {}}

--[7008]打造装备
MsgType.reqEquipMake = {id = -7008, keys = {"eid"}}

--[7009]雇佣铁匠
MsgType.reqSmithHire = {id = -7009, keys = {"smithId"}}

--[7010]铁匠加速打造
MsgType.reqMakeQuick = {id = -7010, keys = {}}

--[7011]金币加速完成装备打造
MsgType.reqMakeQuickByCoin = {id = -7011, keys = {}}

--[7012]领取打造的装备
MsgType.reqEquipGet = {id = -7012, keys = {}}

--[7013]分解装备
MsgType.reqEquipDecompose = {id = -7013, keys = {"euid"}}

------------商店
--[8501]商店数据更新推送
MsgType.pushShopUpdate = {id = -8501, keys = {}}

--[8502]加载数据
MsgType.reqShopLoad = {id = -8502, keys = {}}

--[8503]珍宝阁翻牌
MsgType.reqTreasureShopFlip = {id = -8503, keys = {"i"}} --i	int	兑换ID

--[8504]购买珍宝阁物品
MsgType.reqTreasureShopBuy = {id = -8504, keys = {"index"}} --index	int	兑换ID

--[8500]购买商店物品
MsgType.reqShopBuy = {id = -8500, keys = {"exchange", "type", "num"}}

------------buff系统
--[8300]加载buff数据
MsgType.reqBuffLoad = {id = -8300, keys = {}}


------------活动
--[4001][南征北战]获取任务奖励
MsgType.reqNanBeiWarReward = {id = -4001, keys = {"id"}}

--[4014]全民返利领取奖励
MsgType.reqPeopleRebateReward = {id = -4014, keys = {"target"}} 

--[4034][夺宝转盘 2010]转盘
MsgType.reqSnatchturn = {id = -4034, keys = {"type"}} --type	int	1：1次免费幸运转盘 2： 1次付费幸运转盘 3：10次付费幸运转盘 4：1次王者转盘 5.10次王者转盘

--[4020][耗铁有礼 2008]转盘
MsgType.reqConsumeironTurn = {id = -4020, keys = {"time", "type"}} --time	int	传1次或10次 type	int	0免费 1花费

--[4048]吃鸡
MsgType.reqEatChicken = {id = -4048, keys = {}}

--[4049]补鸡
MsgType.reqFillChicken = {id = -4049, keys = {}}

--[3106]兑换武王奖励
MsgType.reqWuWangExchange = {id = -3106, keys = {"id"}}

------------新手
--[8404]新手引导步骤记录
MsgType.reqGuideRecord = {id = -8404, keys = {"step"}}

------------世界目标
--[3040]领取世界目标奖励
MsgType.regWorldTargetReward = {id = -3040, keys = {"id"}}

--[3041]完成世界目标后消耗低迁迁城
MsgType.reqWorldTargetUsedMoveCity = {id = -3041, keys = {"ifBuy"}}

--[-3042]世界目标数据刷新推送
MsgType.pushWorldTargetRefresh = {id = -3042, keys = {}}

--[-3044]击打世界Boss
MsgType.regAttackWorldBoss = {id = -3044, keys = {"hids"}}

--[-3045]不能打的都城推送
MsgType.pushNoAttackCapitalCity = {id = -3045, keys = {}}

------------武王讨伐
--[-3101]对BOSS发起战争
MsgType.reqWorldBossWar = {id = -3101, keys = {"x", "y"}}

--[-3103]加载国家积分
MsgType.reqWuWangCountryScore = {id = -3103, keys = {}}

--[-3100]召唤纣王
MsgType.reqZhouWangCall = {id = -3100, keys = {"itemID", "x", "y"}}

--[-3104]加载boss战争列表
MsgType.reqWorldBossWarList = {id = -3104, keys = {"x", "y"}}

--[-3105]请求支援
MsgType.reqWorldBossSupport = {id = -3105, keys = {"x", "y"}}

-----------名将推荐
--[-6005]名将推荐请求
MsgType.reqHeroRecommond = {id = -6005, keys = {""}}

--[-6004]名将推荐推送
MsgType.pushHeroRecommond = {id = -6004, keys = {""}}

-----------触发礼包
--[-6007]加载触发礼包
MsgType.reqTriggerGift = {id = -6007, keys = {""}}

--[-6008]购买触发礼包返回
MsgType.reqBugTriggerGift = {id = -6008, keys = {"pid"}}

--[-6006]触发礼包推送
MsgType.pushTriggerGift = {id = -6006, keys = {""}}



-----------池城首杀
--[-3502]加载城池首杀数据
MsgType.reqCityFirstBlood = {id = -3502, keys = {""}}

--[-3503]城池首杀数据推送
MsgType.pushCityFirstBlood = {id = -3503, keys = {""}}


--[3504]世界目标搜索
MsgType.reqWorldSearch = {id = -3504, keys = {"tid"}} --要搜索目标的模板id

--[3506]国战求援
MsgType.reqCountryWarSupport = {id = -3506, keys = {"cityID","warID"}} --要搜索目标的模板id


------------------乱军查找
MsgType.reqSearchWildArmy = {id = -3507, keys = {}}

------------------生成一个任务乱军
MsgType.reqTaskWildArmy = {id = -3508, keys = {"mid"}}

----------校场
--武将加入统帅府队列中
MsgType.reqHeroAddTcfTeam = {id = -2139, keys = {"hid", "pos", "type"}} --hid武将id,pos位置,type类型(1采集队列,2城防队列)

--等级升级推送位置变化
MsgType.pushHeroTeamNums = {id = -2141, keys = {}}

--请求解锁位置
MsgType.reqUnLockTcfPos = {id = -2138, keys = {"type"}} --按顺序,type 1采集 2城防 3高级御兵术

--请求耐力恢复
MsgType.reqWalldefHeroRecover = {id = -8110, keys = {"hid"}} --hid武将id

--耐力补充
MsgType.autoAddHeroNaili = {id = -2142, keys = {"auto"}} --0是关闭，1是开启


----------年兽来袭
MsgType.reqNianAttack = {id = -4094, keys = {"time", "free"}} --攻击次数,是否免费(不免费，1免费)

MsgType.reqNianHurtGift = {id = -4095, keys = {"hurt"}} --礼包

MsgType.reqCountryNianHurt = {id = -4096, keys = {}} --国家

MsgType.reqNianHp = {id = -4098, keys = {}} --年兽来袭刷新血量


----------限时Boss
--限时BOSS加载数据
MsgType.reqTLBossData = {id = -6200, keys = {}}
--限时BOSS获取排行榜
MsgType.reqTLBossRank = {id = -6201, keys = {}}
--限时BOSS攻击
MsgType.reqTLBossAttack = {id = -6202, keys = {"buy"}} --是否购买攻击 0否 1是
--限时BOSS强击
MsgType.reqTLBossSAttack = {id = -6203, keys = {}}
--限时BOSS数据更新推送
MsgType.pushTLBossData = {id = -6204, keys = {}}
--[6205]BOSS领取伤害排行奖励
MsgType.reqGetHarmRankAward = {id = -6205,keys = {}}
--[6206]BOSS领取次数排行奖励
MsgType.reqGetHitNumRankAward = {id = -6206,keys = {}}
--[6207]BOSS领取最终击杀奖励
MsgType.reqGetFinalKillAward = {id = -6207,keys = {}}

----------决战阿房宫
--加载战场6400
MsgType.reqImperBattlefield = {id = -6400, keys = {"cid"}} --城的id

--加载战况6401
MsgType.reqImperWarFight = {id = -6401, keys = {"cid"}} --加载战况

--战况推送6402
MsgType.pushImperWarFight = {id = -6402, keys = {}}

--查看我的武将6403
MsgType.reqImperWarMyHero = {id = -6403, keys = {}}

--加载我的积分6404
MsgType.reqImperWarMyScore = {id = -6404, keys = {}}

--加载攻防部队数据6405
MsgType.reqImperWarArmy = {id = -6405, keys = {}}

--加载血战皇城活动状态
MsgType.reqImperWarOpen = {id = -6406, keys = {}}

--推送血战皇城活动状态
MsgType.pushImperWarOpen = {id = -6407, keys = {}}

--兑换6408
MsgType.reqRoyalBankExchange = {id = -6408, keys = {"id"}}

--[6409]请求突围
MsgType.reqImperWarBreakout = {id = -6409, keys = {"cid"}} --	要突围到的城池ID

--[6410]使用战术
MsgType.reqImperWarTech = {id = -6410, keys = {"tid", "cid"}} --战术id

--
MsgType.stopImperWarPush = {id = -6411, keys = {"code", "cityID"}} -- 1:退出战报窗口 2:退出战场窗口

--推送战场数据6412
MsgType.pushImperBattlefield = {id = -6412, keys = {} }

--皇城战斗结果通知
MsgType.pushIWarFightNotice = {id = -6416, keys = {}}

--皇城获取指定战报
MsgType.reqEpwFightState = {id = -6417, keys = {"cityID", "rid"}} --

--[6418]加载驻军线
MsgType.reqEpwLine = {id = -6418, keys = {}}

--[6419]更新驻军线
MsgType.pushEpwLine = {id = -6419, keys = {}}

--[6420]请求集结相关数据
MsgType.reqTogetherData = {id = -6420, keys = {"cid"}}

--[6421]加载奖励领取状态
MsgType.reqEpwAward = {id = -6421, keys = {}}

--[6422]可领取推送状态
MsgType.pushEpwAward = {id = -6422, keys = {}}

--[6423]领取奖励
MsgType.reqGetEpwAward = {id = -6423, keys = {"type"}} --1领取排行奖励 2领取阶段奖励


----------新国家系统 国家城池
MsgType.reqCountryCity = {id = -5107, keys = {}}

MsgType.pushCountryCityNew = {id = -5108, keys = {}}