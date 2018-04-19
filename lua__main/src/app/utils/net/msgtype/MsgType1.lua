----------------------------------------------------- 
-- author: wangxiaoshuo
-- updatetime: 2017-01-16 16:01:05 
-- Description: 网络协议的协议号
-----------------------------------------------------
MsgType = MsgType or {}
-- 登录接口
MsgType.login = {id=-102, keys = {"name","token","channel","os","sid", "ver"}}
-- 被服务器踢下线
MsgType.serOffline = {id=-101, keys = {}}

--加载玩家信息
MsgType.loadPlayer = {id=-2001, keys = {}}
--购买能量
MsgType.buyEnergy = {id=-2002, keys = {"num"}}
--推送刷新玩家信息
MsgType.pushPlayer = {id=-2003, keys = {}}
--请求能量恢复
MsgType.getEnergy = {id=-2007, keys = {}}


--推送刷新建筑信息
MsgType.pushBuildDatas = {id=-2100, keys = {}}
--建筑升级请求
MsgType.upBuild = {id=-2101, keys = {"location","buildId","operate","buildQueueId"}}
--建筑队列更新推送
MsgType.pushUpBuild = {id=-2102, keys = {}}
--建筑升级加速请求
MsgType.upFastBuild = {id=-2103, keys = {"location","buildId","item","isNow", "num"}}
--自动升级开启与关闭
MsgType.autoBuilding = {id=-2104, keys = {"flag"}}
--建造升级队列购买
MsgType.buyBuildTeam = {id=-2106, keys = {"day"}}
--征收资源
MsgType.collectRes = {id=-2108, keys = {"location","type"}}
--招募士兵
MsgType.recruitSolider = {id=-2112, keys = {"minute","buildId"}}
--招募操作
MsgType.recruitAction = {id=-2113, keys = {"buildId","operate","proId","item", "num"}}
--兵营调整
MsgType.updateCamp = {id=-2114, keys = {"operate","buildId"}}
--加载建筑信息
MsgType.loadBuildDatas = {id=-2119, keys = {}}
--建筑解锁推送
MsgType.pushBuildUnlock = {id=-2128, keys = {}}
--募兵招募队列更新推送
MsgType.pushRecruit = {id=-2129, keys = {}}
--建筑拆除等操作推送
MsgType.pushMoreActionBuild = {id=-2130, keys = {}}
--建筑拆除或者改造
MsgType.moreActionBuild = {id=-2131, keys = {"location","buildId","operate","rt","type","buildQueueId"}}
--建筑队列倒计时校验
MsgType.checkupingBuild = {id=-2134, keys = {"location"}}
--建筑协助数据返回
MsgType.helpupingBuild = {id=-2151, keys = {}}

--研究科技
MsgType.upTnoly = {id=-8200, keys = {"sid"}}
--加载科技
MsgType.loadTnolyDatas = {id=-8201, keys = {}}
--科技操作
MsgType.actionTnoly = {id=-8202, keys = {"operate", "itemId", "num"}}
--科技研究更新推送
MsgType.pushTnoly = {id=-8204, keys = {}}


--手机绑定
MsgType.phoneBind = {id=-4073, keys = {"state"}}

--实名认证
MsgType.realNameCheck = {id=-4112, keys = {"state"}}

--在线福利
MsgType.onlineWelfare = {id=-4075, keys = {"seconds"}}

--双旦活动
MsgType.doubleEgg = {id=-4077, keys = {""}}

--建筑解锁测试
MsgType.testBuild = {id=-1111, keys = {"location","buildId"}}
--加载玩家的剧情章节数据
MsgType.loadChapter = {id=-7200, keys = {""}}
--加载玩家的剧情章节数据
MsgType.chapterPush = {id=-7201, keys = {""}}
--领取目标奖励
MsgType.getChapterTaskPrize = {id=-7202, keys = {"tid"}}
--领取章节奖励
MsgType.getChapterPrize = {id=-7203, keys = {""}}

--寻访美人，寻访一次
MsgType.searchBeautyOne = {id=-4088, keys = {""}}
--寻访美人，寻访十次
MsgType.searchBeautyTen = {id=-4089, keys = {""}}
--寻访美人，招募武将
MsgType.getBeauty = {id=-4090, keys = {""}}
--装备打造活动
MsgType.equipmake = {id=-4100, keys = {"id"}}
--蓝装打造活动
MsgType.blueequipmake = {id=-4104, keys = {"id"}}
--科技兴国
MsgType.sciencepromote = {id=-4109, keys = {"id"}}
--周卡月卡活动
MsgType.monthweekcard = {id=-4107, keys = {"pid"}}
--科技兴国宝箱领取
MsgType.sciencepromoteaward = {id=-4111, keys = {}}
--[8112]记录玩家自选扫荡队列
MsgType.wipeteamset = {id=-8112, keys = {"hid"}}

--请求国家宝藏数据
MsgType.asknationaltreasure = {id=-6413, keys = {}}
--国家宝藏寻宝
MsgType.nationaltreasure = {id=-6414, keys = {}}
--国家宝藏祝贺
MsgType.treasurecongratu = {id=-6415, keys = {}}

--国家协助帮助别人,op-1帮助一个,2全部协助,helpId-协助对象id
MsgType.countryhelp = {id=-5045,keys = {"op","helpId"}} 
--请求加载国家协助数据
MsgType.loadcountryhelp = {id=-5046,keys = {}} 
--国家协助数据更新推送
MsgType.countryhelpupdate = {id=-5047,keys = {}} 
--国家协助得到帮助推送
MsgType.countrygethelpupdate = {id=-5048,keys = {}} 
--建筑请求协助 int	建筑位置
MsgType.buildupinghelp = {id=-2150,keys = {"location"}} 
--当前科技请求协助
MsgType.scienceupinghelp = {id=-8205,keys = {}} 
--装备打造请求协助
MsgType.makevoupinghelp = {id=-7016,keys = {}}
--打造数据更新推送
MsgType.makevoupdatepush = {id=-7017,keys = {}} 
--回归有礼领取
MsgType.regressGet = {id=-4117,keys = {"day"}} 