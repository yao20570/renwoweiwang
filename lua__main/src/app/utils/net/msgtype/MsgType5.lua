----------------------------------------------------- 
-- author: liangzhaowei
-- updatetime: 2017-01-16 16:01:05 
-- Description: 网络协议的协议号
-----------------------------------------------------
MsgType = MsgType or {}

--加载副本数据
MsgType.loadFubenData = {id=-8000, keys = {}}

--加载副本章节数据
MsgType.loadFubenSectionData = {id=-8001, keys = {"cid"}}

--加载武将信息
MsgType.loadHeroData = {id=-8100, keys = {}}

--副本挑战关卡
MsgType.challengeFubenLevel = {id=-8002, keys = {"oid","hsIds"}}

--副本扫荡关卡
MsgType.sweepFubenLevel = {id=-8003, keys = {"oid","times","hsIds"}}

--副本抽将
MsgType.fubenConscribeHero = {id=-8004, keys = {"oid"}}

--军资补给
MsgType.fubenSupplyRes = {id=-8005, keys = {"oid"}}

--购买军资补给
MsgType.buyFubenSupplyRes = {id=-8006, keys = {"oid"}}

--开启资源田
--[8007]开启资源田
MsgType.openresbuild = {id = -8007, keys = {"oid"}}

--购买装备补给
MsgType.buyFubenEquip = {id=-8008, keys = {"oid"}}

--恢复武将免费培养次数
MsgType.renewTrainTimes = {id=-8102, keys = {}}

--武将数据变化推送
MsgType.pushChangeHeroData = {id=-8103, keys = {}}

--城墙招募
MsgType.wallRecruitDef = {id=-2122, keys = {"operate"}}

---[2123]城墙守卫治疗或训练
--id	String	守卫ID
--type	int	1.治疗 2.训练
MsgType.wallDefChangeState = {id=-2123, keys = {"id","type"}}

--[-2125]城墙自动招募守卫推送
MsgType.pushWallAutoDef = {id=-2125, keys = {}}

--[2126]城墙守卫自动招募开关
--s	int	0:关闭 1：开启
MsgType.wallAutoDefSw = {id=-2126, keys = {"s"}}

--[2127]城墙操作
--operate	int	1.更换武将顺序 2.一键提升守卫
--seq	String	武将顺序，可选 (逗号分隔)
MsgType.wallOperation = {id=-2127, keys = {"operate","seq"}}


-- [8105]武将补兵
-- hid	int	武将ID
MsgType.heroAddSoldier = {id=-8105, keys = {"hid"}}

-- [8106]设置自动补兵
-- auto	int	自动补兵 [0否 1是]
MsgType.autoAddSoldier = {id=-8106, keys = {"auto"}}


-- [8101]培养英雄
MsgType.trainHero = {id=-8101, keys = {"hid","type"}}


-- [8104]武将上阵
-- hid	int	武将ID
-- pos	int	上阵位置
MsgType.goToFight = {id=-8104, keys = {"hid","pos"}}




-- [4501]发送聊天信息
-- accperId	long	接受者的id(1世界;2国家;3私聊)
-- accName	String	接收者名字
-- content	String	聊天内容
MsgType.sendChatData = {id=-4501, keys = {"accperId","accName","content"}}

-- [-4502]聊天信息推送
MsgType.pushChatData = {id=-4502, keys = {}}

-- [4503]加载聊天信息
MsgType.loadChatData = {id=-4503, keys = {}}

-- [4535]请求私聊玩家消息
MsgType.privateChatPlayerReq = {id = -4535, keys = {"targeId"}}

-- [4536]关闭私聊玩家消息
MsgType.closePlayerPrivateChat = {id = -4536, keys = {"targeId"}}

-- [4504]使用喇叭发言
-- type	int	使用喇叭的类型
-- content	String	发布内容
-- MsgType.useHornChat = {id=-4504, keys = {"type","content"}}

-- [4507]点赞玩家
--accepterId 被点赞玩家的id
MsgType.likePeople = {id=-4507, keys = {"accepterId"}}

-- [4508]推送点赞数据
MsgType.pushLikePeople = {id=-4508, keys = {}}

-- [4504]使用世界喇叭聊天
-- type	int	喇叭类型(1普通喇叭)
-- content 发送信息
MsgType.useWorldLaba = {id=-4504, keys = {"type","content"}}

-- [4510]开启、关闭地理位置
-- status	int	0为检查 2/1为开关
MsgType.chatPosSw = {id=-4510, keys = {"status"}}


-- [8107]武将推演
-- type	int	1免费良将 2花费一次良将 3花费十次良将 4免费神将 5花费一次神将 6花费十次神将
-- cost	int	花费的消耗[对应配表配置的物品]
MsgType.buyHero = {id=-8107, keys = {"type","cost"}}

-- [8108]武将使用经验丹
-- hid	int	武将ID
-- iid	int	物品ID
-- type	int	使用方式 0使用已有道具 1是金币购买并使用
MsgType.useExpElixir = {id=-8108, keys = {"hid","iid","type","num"}}

-- [8109]武将进阶
-- hid	int	武将id
-- type	int	1为普通进阶 2为神级进阶
MsgType.heroAdvance = {id=-8109, keys = {"hid","type"}}

-- [2201]加载可以开启的活动
MsgType.loadActivity = {id=-2201, keys = {}}

-- [-2202]运营活动开启推送
MsgType.pushOpenActivity = {id=-2202, keys = {}}

-- [-2203]运营活动关闭推送
MsgType.pushCloseActivity = {id=-2203, keys = {}}

-- [-2204]运营活动移除推送
MsgType.pushRemoveActivity = {id=-2204, keys = {}}

-- [-2205]定点重置推送
MsgType.pushZeroActivity = {id=-2205, keys = {}}


-- [-2207]运营活动数据刷新推送
MsgType.pushRefreshActivity = {id=-2207, keys = {}}


-- [4008][首冲好礼2004]领取礼品
MsgType.getFirstRecharge = {id=-4008, keys = {}}

-- [-4009][首冲好礼1016]推送
MsgType.pushFirstRecharge = {id=-4009, keys = {}}

-- [4004][王宫升级]领取奖励
MsgType.getUpdatePlace= {id=-4004, keys = {"lv"}}

-- [-2132]城墙损兵更新推送
MsgType.pushWallChangeDef= {id=-2132, keys = {}}

-- [-4534]查询个人分享
-- 字段名	类型	说明
-- type	int	查询个人分享所在频道
-- cid	long	查询个人分享的聊天信息的id
MsgType.checkShareMoreCnt = {id=-4534, keys = {"type","cid"}}

-- [-2137]建筑队列加速推送
MsgType.pushExpediteBuild = {id=-2137, keys = {}}


-- [4010][登坛拜将2007]购买物品
-- pos	int	格子位置
-- id	int	购买物品ID
MsgType.buyHeroMansion = {id=-4010, keys = {"pos","id"}}


-- type	int	0免费 1花费
-- [4011][登坛拜将2007]刷新物品
MsgType.freshHeroMansion = {id=-4011, keys = {"type"}}

-- [4012][登坛拜将2007]恢复免费次数
MsgType.freeHeroMansion = {id=-4012, keys = {}}

-- [4013][登坛拜将2007]招募武将
MsgType.recruitHeroMansion = {id=-4013, keys = {}}