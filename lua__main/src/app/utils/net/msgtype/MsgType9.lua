--
-- Author: luwenjing
-- Date: 2017-10-30 9:59:33
--网络协议的协议号
MsgType = MsgType or {}
----------------------↓↓↓↓免费宝箱↓↓↓--------------------
--登录检查每日宝箱详细信息
MsgType.checkDailyGiftRes = {id=-6001, keys = {}}
--获取每日宝箱奖励
MsgType.getDailyGiftRes = {id=-6002, keys = {}}
--每日宝箱数据更新推送
MsgType.updateDailyGiftPush = {id=-6003, keys = {}}

----------------------↑↑↑↑免费宝箱↑↑↑---------------------

----------------------↓↓↓↓世界任务↓↓↓↓---------------------
MsgType.worldMissionPush = {id=-3501, keys = {}}
----------------------↑↑↑↑世界任务↑↑↑---------------------
----------------------↓↓↓↓武将游历↓↓↓↓---------------------
MsgType.heroTravelRes = {id=-6013, keys = {}}
MsgType.startHeroTravel = {id=-6014, keys = {"heroId","qid"}}
MsgType.HeroTravelFinish = {id=-6015, keys = {"qid"}}
MsgType.HeroTravelDataPush = {id=-6009, keys = {}}
----------------------↑↑↑↑武将游历↑↑↑---------------------
----------------------↓↓↓↓多次充值↓↓↓↓---------------------
MsgType.getSeveralRecharge = {id=-4081, keys = {"pid"}}
----------------------↑↑↑↑多次充值↑↑↑---------------------
----------------------↓↓↓↓充值签到↓↓↓↓---------------------
--领取签到奖励
MsgType.getRechargeSign = {id=-4079, keys = {"day"}} 
--领取免费签到奖励		
MsgType.getFreeRechargeSign = {id=-4080, keys = {}}				
----------------------↑↑↑↑充值签到↑↑↑---------------------
----------------------↓↓↓↓每日特惠↓↓↓↓---------------------
--领取签到奖励
MsgType.getEverydayPreference = {id=-4082, keys = {""}} 		
----------------------↑↑↑↑每日特惠↑↑↑---------------------
----------------------↓↓↓↓腊八拉霸↓↓↓↓---------------------
--请求拉霸抽奖
MsgType.getLabaReward = {id=-4084, keys = {"ten"}} 		
----------------------↑↑↑↑腊八拉霸↑↑↑---------------------
----------------------↓↓↓↓攻城掠地↓↓↓↓---------------------
--领取攻城掠地每日奖励
MsgType.getAttkCityDailyReward = {id=-4087, keys = {""}}
--领取攻城掠地宝箱奖励
MsgType.getAttkCityBxReward = {id=-4086, keys = {"id"}} 
--领取攻城掠地首杀奖励
MsgType.getFirstAttkCityReward = {id=-4085, keys = {""}}  		
----------------------↑↑↑↑攻城掠地↑↑↑---------------------
----------------------↓↓↓↓福星高照↓↓↓↓---------------------
--福星高照单开
MsgType.luckyStarOpenOne = {id=-4091, keys = {"buy"}}
--福星高照连开
MsgType.luckyStarOpenServeral = {id=-4092, keys = {"red","buy"}} 
--福星高照领奖励
MsgType.getLuckStarReward = {id=-4093, keys = {"open"}}  
--福星高照买红包		
MsgType.buyLuckStarRedPocket = {id=-4099, keys = {"buy"}}  		
----------------------↑↑↑↑福星高照↑↑↑---------------------

----------------------↓↓↓↓冥界入侵↓↓↓↓---------------------
--冥界入侵兑换属性
MsgType.mingjieExchangeAttr = {id=-3600, keys = {"index","costType"}}
--冥界入侵积分兑换
MsgType.mingjieShop = {id=-3601, keys = {"index","costType"}}
--冥王进攻
MsgType.pushGhostdomWar = {id=-3602, keys = {}}  
--冥王求援		
MsgType.reqGhostdomWarSupport = {id=-3603, keys = {}}  		
----------------------↑↑↑↑冥界入侵↑↑↑---------------------
----------------------↓↓↓↓武将收集↓↓↓↓---------------------
--领取奖励
MsgType.getHeroCollectReward = {id=-4108, keys = {"id"}}		
----------------------↑↑↑↑武将收集↑↑↑---------------------
----------------------↓↓↓↓机器人聊天↓↓↓↓---------------------
--机器人互动
MsgType.playWithRobot = {id=-4539, keys = {"rid","code","content"}}		
----------------------↑↑↑↑机器人聊天↑↑↑---------------------
----------------------↓↓↓↓国家商店↓↓↓↓---------------------
--加载国家商店信息
MsgType.loadCountryShop = {id=-5034, keys = {}}	
--国家商店信息推送	
MsgType.pushCountryShop = {id=-5035, keys = {}}	
--购买国家商店	
MsgType.buyCountryShop = {id=-5033, keys = {"id","type"}}		
----------------------↑↑↑↑国家商店↑↑↑---------------------
----------------------↓↓↓↓国家宝藏↓↓↓↓---------------------
--加载国家宝藏列表
MsgType.loadCountryTreasureList = {id=-5036, keys = {}}	
--国家宝藏--我的宝藏列表	
MsgType.loadMyCountryTreasure = {id=-5037, keys = {}}	
--国家宝藏求助列表	
MsgType.loadCountryTreasureHelpList = {id=-5038, keys = {"page","size"}}	
--国家宝藏请求挖掘
MsgType.reqDigCountryTreasure = {id=-5039, keys = {"type","tsid"}}
--国家宝藏请求刷新	
MsgType.reqRefreshCountryTreasure = {id=-5040, keys = {"type"}}
--国家宝藏求助
MsgType.reqAskHelpCountryTreasure = {id=-5041, keys = {"tsid"}}
--国家宝藏帮助
MsgType.reqHelpCountryTreasure = {id=-5042, keys = {"tsid"}}
--国家宝藏加速
MsgType.reqAccelerateCountryTreasure = {id=-5043, keys = {"tsid"}}
--国家宝藏领取
MsgType.reqGetCountryTreasure = {id=-5044, keys = {"tsid"}}
--国家宝藏数据刷新推送
MsgType.refreshCountryTreasure = {id=-5106, keys = {""}}
----------------------↑↑↑↑国家宝藏↑↑↑---------------------
----------------------↓↓↓↓世界相关↓↓↓↓--------------------
MsgType.reqSingalSysCityDot = {id=-3509, keys = {"x","y"}}
----------------------↑↑↑↑世界相关↑↑↑↑--------------------






