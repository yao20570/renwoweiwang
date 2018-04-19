-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-16 10:52:30 星期四
-- Description: 对话框管理类
-----------------------------------------------------

local DlgUnableTouch = require("app.common.dialog.DlgUnableTouch")
local DlgLoading = require("app.common.dialog.DlgLoading")
local DlgReconnect = require("app.common.dialog.DlgReconnect")


-- e_dlg_index.alert
-- 说明：字段命名为文件名对应的标志名字(全部小写),方便识别和查找
-- 		 举例：DlgMyName =====>   myname = 100,
e_dlg_index = { -- 对话框的类型
    other                   = 1,        -- 其他对话框
    unabletouch             = 2,        -- 屏蔽层对话框
    exitalert               = 3,        -- 退出对话框
    reconnect               = 4,        -- 重连对话框
    loading                 = 5,        -- 加载对话框
    flow                    = 6,        -- 悬浮对话框
    base                    = 7,        -- 全屏对话框
    alert                   = 8,        -- 基础对话框
    common                  = 9,        -- 通用对话框
    taskhome                = 101,	    -- 主界面
    taskworld               = 102,      -- 世界
    ------------------------------------wangxs(王晓烁)       (下标从1000-1499)------------------
    playerinfo              = 1000,     --玩家基础信息
    buildlvup               = 1002,     --建筑升级    
    buildprop               = 1003,     --建筑升级道具使用
    buildbuyteam            = 1004,     --购买建筑队列
    camp                    = 1005,     --兵营
    buyrecruit              = 1006,     --扩充募兵队列
    buyrectime              = 1007,     --扩大募兵上限
    technology              = 1008,     --科学院
    uptnolycost             = 1009,     --研究科技详情框
    tnolytree               = 1010,     --科技树
    mail                    = 1011,     --邮件
    unlockbuild             = 1012,     --建筑解锁提示框
    chatperInfo             = 1013,     --剧情任务界面
    chatperopen             = 1014,     --剧情开启界面
    searchbeauty            = 1015,     --寻访美人
    iteminfoTips            = 1016,     --物品提示
    beautygift              = 1017,     --寻访物品
    monthweekcard           = 1018,     --周卡月卡
    cardTips                = 1019,     --周卡月卡提示框
    sciencepromote          = 1020,     --科技兴国
    fubenwipeteam           = 1021,     --扫荡队伍
    nationaltreasure        = 1022,     --国家宝库
    newcountryhelp          = 1023,     --新国家帮助
    ------------------------------------xieruidong(谢锐东)   (下标从1500-1999)------------------
    overscene               = 1500,     -- 过度场景
    ------------------------------------zhangnianfeng(张年峰)(下标从2000-2499)------------------
    blockmap                = 2000,     --区域地图
    wildarmy                = 2001,     --乱军详细
    citydetail              = 2002,     --城池详细
    citywarprotectconfirm   = 2003,     --城战发起保护状态确认界面
    citywar                 = 2004,     --城战面板
    battlehero              = 2005,     --武将出征面板
    citygarrison            = 2006,     --城池驻防
    countrywar              = 2007,     --国战面板
    collectres              = 2008,     --采集面板
    syscitycollect          = 2009,     --系统城池资源征收面板
    cityownerapply          = 2010,     --城主申请
    syscitydetail           = 2011,     --系统城池详细
    dotfinger               = 2012,     --视图点上的手指
    cityownercandidate      = 2023,     --城主申请候选人
    worldmap                = 2024,     --世界地图
    poskeypad               = 2025,     --小键盘
    callplayer              = 2026,     --玩家召唤
    citywarhelp             = 2027,     --城战求助面板
    citygarrisoncall        = 2028,     --城池驻防召回
    maildetail              = 2029,     --邮件详细
    smithshop               = 2030,     --铁匠铺
    refineshop              = 2031,     --洗炼铺
    equipbag                = 2032,     --装备背包
    hiddenattropendesc      = 2033,     --隐藏属性开启说明
    newguide                = 2034,     --新手引导
    fcpromote               = 2035,     --战力提升途径
    fcpromoteclicktip       = 2036,     --战力提升途径点击提示
    treasureshop            = 2037,     --珍宝阁
    treasureunknow          = 2038,     --未知珍宝阁购买
    shop                    = 2039,     --商店
    shopbatchbuy            = 2040,     --商店批量购买
    peoplerebate            = 2041,     --全民返利
    worldtarget             = 2042,     --世界目标
    worldtargetarmy         = 2043,     --世界目标乱军
    worldtargetboss         = 2044,     --世界目标Boss
    worldtargetcity         = 2045,     --世界目标系统城池
    worldtargetcapital      = 2046,     --世界目标都城
    getreward               = 2047,     --通用获取奖励
    rebuildreward           = 2048,     --重建奖励
    maildetailsys           = 2049,     --系统邮件
    maildetailcitywar       = 2050,     --城战邮件
    maildetailcountrywar    = 2051,     --国战邮件
    maildetailwildarmy      = 2052,     --乱军邮件
    maildetailcollect       = 2053,     --采集邮件
    maildetailmine          = 2054,     --矿点占领邮件
    maildetaildetect        = 2055,     --侦查邮件
    maildetailgarrison      = 2056,     --驻防邮件
    maildetaillose          = 2057,     --邮件丢失
    maildetaildetectme      = 2058,     --遭到侦查
    snatchturn              = 2059,     --夺宝转盘
    consumeiron             = 2060,     --耗铁有礼
    season                  = 2061,     --季节
    wuwang                  = 2062,     --武王活动
    wuwangkillrank          = 2063,     --武王击杀排行
    zhouwangdetail          = 2064,     --纣王详细
    bosswar                 = 2065,     --Boss界面
    bosswarhelp             = 2066,     --Boss求援
    chatemo                 = 2067,     --聊天表情面板
    herorecommend           = 2068,     --武将推荐
    triggergift             = 2069,     --触发礼包
    cityfirstblood          = 2070,     --城池首杀
    worldsearch             = 2071,     --世界搜索
    worldmapfirstblood      = 2072,     --城池首杀世界地图
    nianattack              = 2073,     --年兽来袭
    tlbosshitresult         = 2074,     --限时Boss连击结果
    tlboss                  = 2075,     --限时Boss
    imperialwarhero         = 2076,     --皇城决战武将
    imperialwararmy         = 2077,     --皇城攻防部队
    royalbank               = 2078,     --皇城秘库
    eqw                     = 2079,     --决战阿房宫
    imperwarreport          = 2080,     --皇城战战报
    countrycity             = 2081,     --新国家城池
    unlockmodel             = 2082,     --建筑功能提示框
    ------------------------------------maihuahao(麦华豪)    (下标从2500-2999)------------------
    register                = 2500,     --登录对话框
    ------------------------------------liangzhaowei(粱兆威) (下标从3000-3499)------------------
    fubenlayer              = 3000,     --副本界面
    fubenmap                = 3001,     --副本关卡地图
    armylayer               = 3002,     --设置部队界面
    fubenresult             = 3003,     --副本战斗结果界面
    heromain                = 3004,     --英雄主界面
    heroinfo                = 3005,     --英雄详情界面
    selecthero              = 3006,     --选择上阵武将界面
    conscribehero           = 3007,     --招募英雄
    showgethero             = 3008,     --展示获得的英雄
    shogunlayer             = 3009,     --将军府
    wall                    = 3010,     --城墙
    operatewalldefcost      = 3011,     --城墙守卫操作花费
    fubenbutyitemtips       = 3012,     --副本资源关购买提示框
    wallgarrison            = 3013,     --城墙驻防
    dlgchat                 = 3014,     --聊天界面
    dlgherolineup           = 3015,     --英雄上阵界面
    -- dlgheroparameter        = 3016,     --英雄基础参数界面 --已弃用
    herotrain               = 3017,     --英雄培养界面
    heroupdate              = 3018,     --英雄升级界面
    serverlist              = 3019,     --服务器列表
    worldlaba               = 3020,     --世界喇叭使用对话框
    buyhero                 = 3021,     --拜将台
    buyheropreview          = 3022,     --推演预览界面
    buyheroshowget          = 3023,     --推演获得界面
    worlduseresitem         = 3024,     --世界使用道具  
    actmodela               = 3025,     --活动模板a列表  
    actmodelb               = 3026,     --活动模板b入口
    updateplace             = 3027,     --王宫升级
    showicontips            = 3028,     --icon描述框
    heromansion             = 3029,     --登坛拜将(活动)
    showheromansion         = 3030,     --登坛拜将活动获得英雄框
    nheroadvance            = 3031,     --武将普通进阶
    mheroadvance            = 3032,     --武将进阶神将
    ------------------------------------maheng(马恒)   (下标从3500-3999)------------------
    rename                  = 3500,     --玩家改名对话框                                                                
    vitbuy                  = 3501,     --玩家购买体力                                
    palace                  = 3502,     --王宫    
    civilemploy             = 3503,     --雇用 
    warehouse               = 3504,     --仓库         
    costtip                 = 3505,     --花费提示
    resoutput               = 3506,     --资源产量信息
    getresource             = 3507,     --获取资源
    useitems                = 3508,     --使用物品
    bag                     = 3509,     --背包
    iteminfo                = 3510,     --物品信息显示对话框
    getcityprotect          = 3511,     --获取主城保护对话框
    atelier                 = 3512,     --工坊
    atelierproduce          = 3513,     --工坊生产
    atelierbespeak          = 3514,     --工坊预约生产
    atelierguide            = 3515,     --工坊引导
    dlgtask                 = 3516,     --任务主界面
    dlgtaskcountry          = 3517,     --国家任务主界面
    taskdetails             = 3518,     --任务详情对话框
    dlgrank                 = 3519,     --排行榜
    dlgrankplayerinfo       = 3520,     --排行榜中的玩家信息弹框
    dlgsettingmain          = 3521,     --设置主界面
    dlgcontactservice       = 3522,     --联系客服弹框
    dlggamesetting          = 3523,     --游戏设置界面
    dlgnodisturbsetting     = 3524,     --游戏免打扰设置对话框
    dlgvipprivileges        = 3525,     --vip特权
    dlgrecharge             = 3526,     --充值
    dlgcountry              = 3527,     --国家界面
    dlgcountryofficials     = 3528,     --国家官员
    gettaskprize            = 3529,     --领取任务奖励对话框
    dlggeneralrenmian       = 3530,     --将军任免对话框  
    dlgcountrylog           = 3531,     --国家日志
    dlgcountryglory         = 3532,     --国家荣誉
    dlgcountrycity          = 3533,     --国家城池
    dlgofficialprivilege    = 3534,     --官员特权
    dlgsenddecree           = 3535,     --发送圣旨
    dlgcountrydevelop       = 3536,     --国家开发对话框
    dlgnobilitypromote      = 3537,     --爵位升级
    dlgchoicecountry        = 3538,     --选择国家对话框
    dlgequipdecomtip        = 3539,     --装备分解详情提示
    dlgfirstrecharge        = 3540,     --首充对话框
    taskprizeprogress       = 3541,     --任务奖励进度弹窗
    dlgplayerlvup           = 3542,     --玩家升级引导对话框
    dlgfreebenefits         = 3543,     --免费活动   
    dlgbuildfinger          = 3544,     --建筑相关任务引导手指 
    vipgitfgoodtip          = 3545,     --vip礼包相关提示
    dlgbuildsuburb          = 3546,     --重建资源建筑
    dlgtaskfinger           = 3547,     --任务手指
    equipdetails            = 3548,     --装备详情
    dlgfriends              = 3549,     --好友界面  
    dlgfriendselect         = 3550,     --好友选择界面    
    dlgfriendreport         = 3551,     --举报界面
    dlgsevenkingrank        = 3552,     --七日登基的排行类型子活动
    mansionitemtip          = 3553,     --登坛拜将物品购买提示
    dlgiconsetting          = 3554,     --头像设置
    dlgredpocketsend        = 3555,     --发送红包
    dlgredpocketsenddetail  = 3556,     --发红包
    dlgredpocketcatchdetail = 3557,     --抢红包
    dlgredpocketopen        = 3558,     --开红包
    dlgredpocketcheck       = 3559,     --红包详情
    dlgbuffs                = 3560,     --增益buff
    dlgroyaltycollect       = 3561,     --王权征收
    dlgchiefhouse           = 3562,     --统帅府
    troopsdetail            = 3563,     --高级御兵术
    dlgarena                = 3564,     --竞技场
    -- arenaprizepreview       = 3565,     --竞技场奖励预览--弃用
    arenabattlerecord       = 3566,     --竞技场战斗记录
    -- arenaadjustlineup       = 3567,     --竞技场阵容调整--弃用
    arenabuychallenge       = 3568,     --Vip竞技场挑战次数
    dlgbuyarenashop         = 3569,     --竞技场商品
    arenaplayerinfo         = 3570,     --竞技场玩家信息
    arenafightdetail        = 3571,     --竞技场战斗详情
    inputnum                = 3572,     --数字键盘
    dlgpowerbalance         = 3573,     --战力对比
    dlgremains              = 3574,     --韬光养晦
    autobuild               = 3575,     --自动建造
    custombuildorder        = 3576,     --编辑自定义建筑优先级
    zhouwangtrial           = 3577,     --纣王试炼
    useitemsbytip           = 3578,     --批量使用Tip
    dlgusefragments         = 3579,     --纣王碎片
    zhouwangtrialdetail     = 3580,     --纣王试炼视图点击弹窗
    usearenatoken           = 3581,     --使用竞技场挑战令
    dlgzhouwangdots         = 3582,     --纣王试炼点信息
    dlgdevelopgift          = 3583,     --发展礼包
    dlgfemaleheros          = 3584,     --女将对话框
    ------------------------------------dengshulan(邓淑澜)   (下标从4000-4499)------------------
    dlghelpcenter           = 4000,     --帮助中心
    dlghelpcontent          = 4001,     --帮助内容
    dlgnoticemain           = 4002,     --公告列表
    dlgnoticecontent        = 4003,     --公告内容
    dlgweaponmain           = 4004,     --神兵列表
    dlgweaponinfo           = 4005,     --神兵信息
    dlgspeedupadvance       = 4006,     --加速生产对话框
    dlgmerchants            = 4007,     --商队界面
    dlgequipfullattr        = 4008,     --装备满属性信息对话框
    dlgshare                = 4009,     --分享小弹窗
    dlgfriendshare          = 4010,     --好友分享弹窗
    dlgrechargetip          = 4011,     --充值二次确认窗口
    dlggrowfound            = 4012,     --成长基金
    dlgbuygrowthfound       = 4013,     --成长基金购买对话框
    dayloginawards          = 4014,     --每日登录奖励
    dlglevelupawards        = 4015,     --升级奖励弹窗
    dlgspecialsale          = 4016,     --特价卖场活动
    dlgfarmtroopsplan       = 4017,     --屯田计划活动
    taskguidetip            = 4018,     --任务引导提示框
    lockherotip             = 4019,     --解锁上阵武将提示对话框
    dlgweaponshareinfo      = 4020,     --神兵分享对话框
    dlgemploytip            = 4021,     --科技院正在升级且已买vip5礼包时雇佣提示对话框
    rescollect              = 4022,     --资源征收弹窗
    dlgnewfirstrecharge     = 4023,     --新版首充界面
    restructsuburb          = 4024,     --改建资源田界面
    dragontreasure          = 4025,     --寻龙夺宝
    buystuff                = 4026,     --购买道具对话框
    gettargetgoodstip       = 4027,     --寻龙夺宝获得目标物品弹窗
    dlgnewgrowfound         = 4028,     --新版成长基金
    dlgpowermark            = 4029,     --战力评分
    dlgequipinfo            = 4030,     --装备信息
    dlgteachplay            = 4031,     --教你玩
    dlgteachplaydetail      = 4032,     --教你玩第二个窗口
    dlgherostarsoul         = 4033,     --武将星魂
    dlgpasskillhero         = 4034,     --过关斩将
    killheroselhero         = 4035,     --过关斩将选择上阵武将界面
    expeditefightdetail     = 4036,     --过关斩将战报详情
    dlgcountrytnoly         = 4037,     --国家科技界面
    restructrecruit         = 4038,     --改建募兵府弹窗dlgrecruitsodiers
    dlgrecruitsodiers       = 4039,     --募兵府界面
    dlgcountrytnolydetail   = 4040,     --国家科技详情界面
    dlgtnolyedit            = 4041,     --国家科技编辑推荐界面
    dlgwelcomeback          = 4042,     --运营活动王者归来
    ------------------------------------谭倩(4500-4999)---------------------------------------------
    dlgblessworld           = 4500,      --活动福泽天下
    dlgactloginaward        = 4501,      --活动每日收贡
    dlgworldhelp            = 4502,      --世界玩法说明对话框
    ------------------------------------卢文靖(5000-5499)---------------------------------------------
    dlgactivitydesc         = 5000,     --活动规则
    dlgareanotopen          = 5001,     --区域为开放
    dlgherotravel           = 5002,     --武将游历
    dlgseveralrecharge      = 5003,     --多次充值活动
    dlgdailygift            = 5004,     --免费宝箱对话框
    everydaypreference      = 5005,     --每日特惠
    dlgeverypreferencedetail      = 5006,     --每日特惠礼包详情
    dlgviprechargedetail    = 5007,     --vip充值规则说明
    laba                    = 5008,     --腊八拉霸活动
    labarewarddetail        = 5009,     --腊八拉霸奖励预览
    wuwangforcast           = 5010,     --纣王预告
    monthcarddesc           = 5011,     --月卡说明
    attkcity                = 5012,     --攻城掠地
    actaskdetail            = 5013,     --攻城掠地任务详情
    acbxdetail              = 5014,     --攻城掠地宝箱详情
    luckystar               = 5015,     --福星高照
    dlgluckystaropenall     = 5016,     --福星高照全开对话框
    ghostdomdetail          = 5017,     --幽魂详情
    mingjie                 = 5018,     --冥界入侵活动界面
    ghostdomAtkDetail       = 5019,     --冥界入侵敌军详情
    dlgcountrytreasure      = 5020,     --国家宝藏
    dlgcountryshop          = 5021,     --国家商店
    ------------------------------------温宗耀(5500-5999)---------------------------------------------
    dlgactivityexam         = 5500,     --每日抢答
    dlgwarhall              = 5501,     --战阵大厅


}

--打开中的全屏对话框数量
tShowingFillDlgs = {}
--对话框参数配置
tDlgParams = {} --参数t：0：表示特殊对话框  1：表示全屏对话框  2：中屏对话框 3：小屏对话框
                --参数h：代表已经处理过onresume和onpause行为，可以参与对话框的队列管理
                --       -1表示打开过1次后不再关闭，1表示打开后可以用队列上限来关闭
                --参数cf: 代表过度界面需要展示几帧的时长，与界面中gRefreshViewsAsync的帧数相互对应
                --参数gct: 释放所有没被引用的texture, spriteFrame

------------------------------------wangxs(王晓烁)       (下标从1000-1499)------------------
tDlgParams["1000"] = {t = 1--[[, h=1]]}           -- 玩家基础信息
tDlgParams["1002"] = {t = 0--[[, h=-1]]}          --建筑升级  
tDlgParams["1003"] = {t = 2}
tDlgParams["1004"] = {t = 2}
tDlgParams["1005"] = {t = 1}
tDlgParams["1006"] = {t = 3}
tDlgParams["1007"] = {t = 3}
tDlgParams["1008"] = {t = 1}
tDlgParams["1009"] = {t = 2}
tDlgParams["1010"] = {t = 1--[[, h=-1]]}          --科技树
tDlgParams["1011"] = {t = 1}
tDlgParams["1012"] = {t = 0}
tDlgParams["1015"] = {t = 1}
tDlgParams["1018"] = {t = 1}
tDlgParams["1019"] = {t = 2}
tDlgParams["1020"] = {t = 1}
tDlgParams["1021"] = {t = 2}
tDlgParams["1022"] = {t = 1}           --国家宝库
tDlgParams["1023"] = {t = 1}           --新国家帮助
------------------------------------xieruidong(谢锐东)   (下标从1500-1999)------------------
tDlgParams["1500"] = {t = 0}
------------------------------------zhangnianfeng(张年峰)(下标从2000-2499)------------------
tDlgParams["2000"] = {t = 1}
tDlgParams["2001"] = {t = 2}
tDlgParams["2002"] = {t = 2}
tDlgParams["2003"] = {t = 2}
tDlgParams["2004"] = {t = 0}
tDlgParams["2005"] = {t = 1}
tDlgParams["2006"] = {t = 2}
tDlgParams["2007"] = {t = 0}
tDlgParams["2008"] = {t = 1--[[, h=1]]}           --采集面板
tDlgParams["2009"] = {t = 2}
tDlgParams["2010"] = {t = 2}
tDlgParams["2011"] = {t = 2}
tDlgParams["2012"] = {t = 0}
tDlgParams["2023"] = {t = 2}
tDlgParams["2024"] = {t = 1--[[, h=1]]}           --世界地图
tDlgParams["2025"] = {t = 0}
tDlgParams["2026"] = {t = 2}
tDlgParams["2027"] = {t = 2}
tDlgParams["2028"] = {t = 2}
tDlgParams["2029"] = {t = 1}
tDlgParams["2030"] = {t = 1}
tDlgParams["2031"] = {t = 1}
tDlgParams["2032"] = {t = 1--[[, h=1]]}           --装备背包
tDlgParams["2033"] = {t = 0}
tDlgParams["2035"] = {t = 1--[[, h=1]]}           --战力提升途径
tDlgParams["2036"] = {t = 0}
tDlgParams["2037"] = {t = 1--[[, h=1]]}           --珍宝阁
tDlgParams["2038"] = {t = 2}
tDlgParams["2039"] = {t = 1}
tDlgParams["2040"] = {t = 2}
tDlgParams["2041"] = {t = 1--[[, h=1]]}           --全民返利
tDlgParams["2043"] = {t = 2}
tDlgParams["2044"] = {t = 2}
tDlgParams["2045"] = {t = 2}
tDlgParams["2046"] = {t = 2}
tDlgParams["2047"] = {t = 0}
tDlgParams["2048"] = {t = 0}
tDlgParams["2068"] = {t = 0}
tDlgParams["2069"] = {t = 2}
tDlgParams["2070"] = {t = 1}
tDlgParams["2071"] = {t = 0}
tDlgParams["2072"] = {t = 1}
tDlgParams["2073"] = {t = 1}
tDlgParams["2074"] = {t = 2}
tDlgParams["2075"] = {t = 1}
tDlgParams["2076"] = {t = 2}
tDlgParams["2077"] = {t = 2}
tDlgParams["2078"] = {t = 2}
tDlgParams["2079"] = {t = 1}
tDlgParams["2080"] = {t = 1}
tDlgParams["2081"] = {t = 1}
tDlgParams["2082"] = {t = 0}
------------------------------------liangzhaowei(粱兆威) (下标从3000-3499)------------------
tDlgParams["3000"] = {t = 1--[[, h=1]]}           --副本界面
tDlgParams["3001"] = {t = 1, gct = true--[[, h=1]]} --副本关卡地图
tDlgParams["3002"] = {t = 1}
tDlgParams["3003"] = {t = 0}
tDlgParams["3004"] = {t = 1--[[, h=1]], cf=6}     --英雄主界面
tDlgParams["3005"] = {t = 2}
tDlgParams["3006"] = {t = 2}
tDlgParams["3007"] = {t = 2}
tDlgParams["3008"] = {t = 2}
tDlgParams["3009"] = {t = 1}
tDlgParams["3010"] = {t = 1}
tDlgParams["3011"] = {t = 3}
tDlgParams["3012"] = {t = 3}
tDlgParams["3013"] = {t = 2}
tDlgParams["3014"] = {t = 1, h=-1}          --聊天界面
tDlgParams["3015"] = {t = 1, gct = true--[[, h=-1]]}          --英雄上阵界面
tDlgParams["3016"] = {t = 2}
tDlgParams["3017"] = {t = 2}
tDlgParams["3018"] = {t = 2}
tDlgParams["3019"] = {t = 1}
tDlgParams["3020"] = {t = 3}
tDlgParams["3021"] = {t = 1, gct = true} -- 拜将台
tDlgParams["3022"] = {t = 1}
tDlgParams["3023"] = {t = 1}
tDlgParams["3024"] = {t = 2}
tDlgParams["3025"] = {t = 1, gct = true}                    --活动模板a入口
tDlgParams["3026"] = {t = 1, gct = true--[[, h=1]]}           --活动模板b入口
tDlgParams["3027"] = {t = 1}
tDlgParams["3028"] = {t = 0}
tDlgParams["3029"] = {t = 1}
tDlgParams["3030"] = {t = 1}
tDlgParams["3031"] = {t = 2}
tDlgParams["3032"] = {t = 1}
------------------------------------maheng(马恒)   (下标从3500-3999)------------------
tDlgParams["3500"] = {t = 3}
tDlgParams["3501"] = {t = 3}
tDlgParams["3502"] = {t = 1--[[, h=1]]}           --王宫
tDlgParams["3503"] = {t = 2}
tDlgParams["3504"] = {t = 1--[[, h=1]]}           --仓库   
tDlgParams["3505"] = {t = 3}
tDlgParams["3506"] = {t = 2}
tDlgParams["3507"] = {t = 2}
tDlgParams["3508"] = {t = 3}
tDlgParams["3509"] = {t = 1}
tDlgParams["3510"] = {t = 3}
tDlgParams["3511"] = {t = 2}
tDlgParams["3512"] = {t = 1--[[, h=1]]}           --工坊
tDlgParams["3513"] = {t = 1--[[, h=1]]}           --工坊生产
tDlgParams["3514"] = {t = 1--[[, h=1]]}           --工坊预约生产
tDlgParams["3515"] = {t = 0}
tDlgParams["3516"] = {t = 1}
tDlgParams["3517"] = {t = 1--[[, h=1]]}           --国家任务主界面
tDlgParams["3518"] = {t = 2}
tDlgParams["3519"] = {t = 1--[[, h=1]]}           --排行榜
tDlgParams["3520"] = {t = 2}
tDlgParams["3521"] = {t = 1}
tDlgParams["3522"] = {t = 3}
tDlgParams["3523"] = {t = 1}
tDlgParams["3524"] = {t = 3}
tDlgParams["3525"] = {t = 1}
tDlgParams["3526"] = {t = 1--[[, h=-1]]}          --充值
tDlgParams["3527"] = {t = 1}
tDlgParams["3528"] = {t = 1--[[, h=1]]}           --国家官员
tDlgParams["3529"] = {t = 0--[[, h=-1]]}          --领取任务奖励对话框
tDlgParams["3530"] = {t = 1--[[, h=1]]}           --将军任免对话框  
tDlgParams["3531"] = {t = 1--[[, h=1]]}           --国家日志
tDlgParams["3532"] = {t = 1}
tDlgParams["3533"] = {t = 2}
tDlgParams["3534"] = {t = 2}
tDlgParams["3535"] = {t = 3}
tDlgParams["3536"] = {t = 2}
tDlgParams["3537"] = {t = 2}
tDlgParams["3538"] = {t = 0}
tDlgParams["3539"] = {t = 2}
tDlgParams["3540"] = {t = 1--[[, h=1]]}           --首充对话框
tDlgParams["3541"] = {t = 3}
tDlgParams["3542"] = {t = 2}
tDlgParams["3543"] = {t = 1}
tDlgParams["3544"] = {t = 0}
tDlgParams["3545"] = {t = 3}
tDlgParams["3546"] = {t = 2}
tDlgParams["3547"] = {t = 0}
tDlgParams["3548"] = {t = 2}
tDlgParams["3549"] = {t = 1}
tDlgParams["3550"] = {t = 2}
tDlgParams["3551"] = {t = 2}
tDlgParams["3552"] = {t = 1--[[, h=1]]}           --七日登基的排行类型子活动
tDlgParams["3553"] = {t = 3}
tDlgParams["3554"] = {t = 1}
tDlgParams["3555"] = {t = 0}
tDlgParams["3556"] = {t = 0}
tDlgParams["3557"] = {t = 0}
tDlgParams["3558"] = {t = 0}
tDlgParams["3559"] = {t = 0}
tDlgParams["3560"] = {t = 2}
tDlgParams["3561"] = {t = 0}
tDlgParams["3562"] = {t = 1}
tDlgParams["3563"] = {t = 1}
tDlgParams["3564"] = {t = 1}
tDlgParams["3565"] = {t = 2}
tDlgParams["3566"] = {t = 1}
tDlgParams["3567"] = {t = 2}
tDlgParams["3568"] = {t = 3}
tDlgParams["3569"] = {t = 3}
tDlgParams["3570"] = {t = 2}
tDlgParams["3571"] = {t = 1}
tDlgParams["3572"] = {t = 0}
tDlgParams["3573"] = {t = 3}
tDlgParams["3574"] = {t = 1}
tDlgParams["3575"] = {t = 1}
tDlgParams["3576"] = {t = 3}
tDlgParams["3577"] = {t = 1}
tDlgParams["3578"] = {t = 3}
tDlgParams["3579"] = {t = 3}
tDlgParams["3580"] = {t = 2}
tDlgParams["3581"] = {t = 3}
tDlgParams["3582"] = {t = 3}
tDlgParams["3583"] = {t = 1}
tDlgParams["3584"] = {t = 1}
------------------------------------dengshulan(邓淑澜)   (下标从4000-4499)------------------
tDlgParams["4000"] = {t = 1}
tDlgParams["4001"] = {t = 1}
tDlgParams["4002"] = {t = 1}
tDlgParams["4003"] = {t = 2}
tDlgParams["4004"] = {t = 1--[[, h=1]]}           --神兵列表
tDlgParams["4005"] = {t = 1}
tDlgParams["4006"] = {t = 3}
tDlgParams["4007"] = {t = 1}
tDlgParams["4008"] = {t = 2}
tDlgParams["4009"] = {t = 0}
tDlgParams["4010"] = {t = 2}
tDlgParams["4011"] = {t = 3}
tDlgParams["4012"] = {t = 1--[[, h=1]]}           --成长基金
tDlgParams["4013"] = {t = 3}
tDlgParams["4014"] = {t = 2}
tDlgParams["4015"] = {t = 0}
tDlgParams["4016"] = {t = 1--[[, h=1]]}           --特价卖场活动
tDlgParams["4017"] = {t = 1--[[, h=1]]}           --屯田计划活动
tDlgParams["4018"] = {t = 0}
tDlgParams["4019"] = {t = 3}
tDlgParams["4020"] = {t = 2}
tDlgParams["4021"] = {t = 3}
tDlgParams["4022"] = {t = 2}
tDlgParams["4023"] = {t = 0}
tDlgParams["4024"] = {t = 2}
tDlgParams["4026"] = {t = 3}
tDlgParams["4027"] = {t = 3}
tDlgParams["4028"] = {t = 1}
tDlgParams["4029"] = {t = 3}
tDlgParams["4030"] = {t = 3}
tDlgParams["4031"] = {t = 3}
tDlgParams["4034"] = {t = 1}           --过关斩将
tDlgParams["4035"] = {t = 2}           --过关斩将选择上阵武将界面
tDlgParams["4036"] = {t = 1}           --过关斩将战报详情
tDlgParams["4037"] = {t = 1}           --国家科技界面
tDlgParams["4038"] = {t = 3}           --改建募兵府弹窗
tDlgParams["4039"] = {t = 1}           --募兵府界面
tDlgParams["4040"] = {t = 3}           --国家科技详情界面
tDlgParams["4041"] = {t = 1}           --国家科技编辑推荐界面
tDlgParams["4042"] = {t = 1}           --运营活动王者归来

------------------------------------谭倩(4500-4999)---------------------------------------------
tDlgParams["4500"] = {t = 1}
tDlgParams["4501"] = {t = 1}
tDlgParams["4502"] = {t = 2}

------------------------------------温宗耀(5500-5999)---------------------------------------------
tDlgParams["5500"] = {t = 1}
tDlgParams["5501"] = {t = 1}

GLOBAL_DIALOG_ZORDER = 10000        --对话框Zorder值
tAllDlgs = {} 						--所有对话框

local nCoverCount = 0 -- 不可点击层的计数

--对话框背景颜色半透明
GLOBAL_DIALOG_BG_COLOR_DEFAULT = cc.c4b(0, 0, 0, 150)
--对话框背景颜色全透明
GLOBAL_DIALOG_BG_COLOR_TRANSPARENT = cc.c4b(0, 0, 0, 0)

-- 对话框的不同分层
e_layer_order_type = {
    normallayer = 839, -- 普通对话框层
    unablelayer = 849, -- 不可点击层
    guidelayer  = 859, -- 引导层
    toastlayer  = 869, -- 提示语层
    exitlayer   = 879, -- 退出层
}

-- 把对话框加入到当前队列中
-- pDlg（SDialog）: 当前显示的对话框
function addDlgToArray( pDlg )
    if(not pDlg) then
        return
    end
    -- 判断是否已经存在
    local pTempDlg = getDlgByType(pDlg.eDlgType)
    if(not pTempDlg and pDlg.eDlgType) then -- 不存在，加入到队列中
        table.insert(tAllDlgs, 1, pDlg)
    end
end

-- 获取已经存在的对话框
-- eDlgType(e_dlg_index): 对话框类型
-- return(SDialog, bool): 对话框, 是否需要新的界面
function getDlgByType( eDlgType )
    if(not tAllDlgs) then
        tAllDlgs = {}
    end
    if(not eDlgType) then
        return nil
    end
    local pDlg = nil
    for i, v in pairs(tAllDlgs) do
        if(v and eDlgType and v.eDlgType == eDlgType) then
            pDlg = v
            break
        end
    end
    return pDlg, pDlg == nil
end


-- 关闭对话框
-- eDlgType(e_dlg_index): 对话框类型
-- bNeedAction(bool): 是否需要关闭动画
function closeDlgByType( eDlgType, bNeedAction )
    if(eDlgType == nil) then
        return false
    end
    local pDlg = getDlgByType(eDlgType, false)
    if(pDlg) then
        if tDlgParams[tostring(eDlgType)] and tDlgParams[tostring(eDlgType)].h and b_open_ui_cach then
            pDlg:hideDlg(bNeedAction)
        else
            pDlg:closeDlg(bNeedAction)
        end
        --不可点击计数重置
        if eDlgType == e_dlg_index.unabletouch then
            nCoverCount = 0
        end
    end
end

-- 关闭所有对话框
-- _bForce(bool): 是否强制关闭所有对话框
function closeAllDlg( _bForce )
    if tAllDlgs and #tAllDlgs > 0 then
        local nSize = table.nums(tAllDlgs)
        for i=nSize, 1, -1 do 
            local pDlg = tAllDlgs[i]
            if(pDlg) then
                if(pDlg.eDlgType ~= e_dlg_index.overscene) then
                    if(_bForce) then
                        if pDlg.closeDlg then
                            pDlg:closeDlg(false)

                            --不可点击计数重置
                            if pDlg.eDlgType == e_dlg_index.unabletouch then
                                nCoverCount = 0
                            end
                        end
                    else
                        closeDlgByType(pDlg.eDlgType, false)
                    end
                end
            end
        end
    end
end

-- 把对话框中队列中清除
-- pDlg（SDialog）：当前要删除的对话框
function removeDlgFromArray( pDlg )
    if(not pDlg) then
        return
    end
    -- 判断是否已经存在
    if(not tAllDlgs) then
        tAllDlgs = {}
    end
    for i, v in pairs(tAllDlgs) do
        if(v and pDlg.eDlgType and v.eDlgType == pDlg.eDlgType) then
            table.remove(tAllDlgs, i)
            break
        end
    end
end


--获得当前正在展示中的对话框(并且有上层对话框需要隐藏)
function getShowingAndNeedHideDlgs(  )
	-- body
	local tShowingDlgs = {}
	if not tAllDlgs or table.nums(tAllDlgs) <= 0 then
		return tShowingDlgs
	end

	for k, v in pairs (tAllDlgs) do
		if v.isShowing and v:isShowing() and v.bNeedHide == true then
			table.insert(tShowingDlgs, v)
		end
	end
	return tShowingDlgs
end

--获得当前正在展示中的对话框
function getShowingDlgs(  )
	-- body
	local tShowingDlgs = {}
	if not tAllDlgs or table.nums(tAllDlgs) <= 0 then
		return tShowingDlgs
	end

	for k, v in pairs (tAllDlgs) do
		if v.isShowing and v:isShowing() then
			table.insert(tShowingDlgs, v)
		end
	end
	return tShowingDlgs
end

--获得除了特定对话框之外当前正在展示中的(非透明)对话框
function getShowingDlgSWithoutSpe( _speDlg )
    -- body
    local tShowingDlgs = {}
    if not tAllDlgs or table.nums(tAllDlgs) <= 0 then
        return tShowingDlgs
    end
    for k, v in pairs (tAllDlgs) do
        if v.isShowing and v:isShowing() and v.eDlgType ~= _speDlg.eDlgType 
            and isEqualC4B(v:getDialogBgColor(),GLOBAL_DIALOG_BG_COLOR_DEFAULT) then
            table.insert(tShowingDlgs, v)
        end
    end
    return tShowingDlgs
end

--展示无效层对话框
function showUnableTouchDlg(_func)
    nCoverCount = nCoverCount + 1
    if(nCoverCount == 1) then
        local dlg = DlgUnableTouch.new(_func)
        -- 找到控制层
        local pParView = getRealShowLayer(RootLayerHelper:getCurRootLayer(), 
            e_layer_order_type.unablelayer)
        UIAction.enterDialog(dlg, pParView, nil, false)
    end
end

-- 关闭不可触摸层的对话框
--bForce：是否强制关闭
function hideUnableTouchDlg(bForce)
    if(nCoverCount <= 0) then
        return
    end

    if bForce == nil then
        bForce = false
    end
    nCoverCount = nCoverCount - 1

    if(bForce) then
        nCoverCount = 0
    end
    
    if(nCoverCount == 0) then
        local dlg = getDlgByType(e_dlg_index.unabletouch)
        if dlg then
            UIAction.exitDialog(dlg)
        end
    end
end


-- 展示loading对话框
--_nType：类型（-1：表示普通的loading，字符串为协议标志）
--_bDelay：是否需要延长展示
--_fDelayTime：延迟时间
--_fTimeOut：超时时间
local nLoadingCount = 0
function showLoadingDlg(_nType, _bDelay, _fDelayTime, _fTimeOut)
    _nType = _nType or -1
    if _bDelay == nil then
        _bDelay = true
    end
    nLoadingCount = nLoadingCount + 1
    if(nLoadingCount == 1) then
        -- 找到控制层
        local dlg = DlgLoading.new(_nType, _bDelay,_fDelayTime, _fTimeOut)
        UIAction.enterDialog(dlg, 
            RootLayerHelper:getCurRootLayer(), true, false, false)
        -- 记录loading框的层级
        -- dlg:setZOrder(1)
    end
end

-- 是否关闭loading框
-- _bForceClose（bool）：是否强制关闭loading框
function hideLoadingDlg( _bForceClose )
    -- 如果没有任何loading框
    if(nLoadingCount <= 0) then
        return
    end
    -- 默认为不关闭
    if(_bForceClose == nil) then
        _bForceClose = false
    end
    nLoadingCount = nLoadingCount -1
    if(_bForceClose) then
        nLoadingCount = 0
    end
    if(nLoadingCount == 0) then
        -- 找到控制层
        local dlg = getDlgByType(e_dlg_index.loading)
        if dlg then
            UIAction.exitDialog(dlg)
        end
    end
end

-- 刷新loading框的显示时间
function refreshLoadingUpdateTime(  )
    local dlg = getDlgByType( e_dlg_index.loading )
    if (dlg and dlg.resetLastTime) then
        dlg:resetLastTime()
    end
end

-- 展示重连对话框
-- nType(e_disnet_type): 0客户端断网，1帐号在别处登录，2服务端强制断开
-- bAuto(bool)：是否自动发起重连
-- bForce(bool): 是否强制展示
-- nSecType(e_second_type)：子类型
function showReconnectDlg( nType, bAuto, bForce, nSecType )
    if not Player:getUIHomeLayer() and not bForce then
        return
    end
    if(not isForegroundReady()) then
        -- 延迟s秒再继续操作
        doDelayForSomething(RootLayerHelper:getCurRootLayer(), function (  )
            showReconnectDlg(nType, bAuto, bForce, nSecType)
        end, 1.1 )
        return
    end
    -- 关闭所有loading框
    hideLoadingDlg(true)

    local pDlg1, bNew = getDlgByType(e_dlg_index.reconnect)
    if pDlg1 and pDlg1.nCurType then
        UIAction.enterDialog(pDlg1, Player:getUIHomeLayer()
            or RootLayerHelper:getCurRootLayer(), bNew)
        pDlg1:setZOrder(1)
        return 
    end
    -- 记录断开的状态
    exchangeConStatus(e_network_status.out)
    if(Player:getUIHomeLayer()) then
        -- 关闭所有连接
        SocketManager:clearAllCallback(false)
    end
    -- 弹出重连对话框
    nType = nType or e_disnet_type.cli
    nSecType = nSecType or e_second_type.normal
    local pDlg, bNew = getDlgByType(e_dlg_index.reconnect)
    if(not pDlg or pDlg.nCurType == nil) then
        pDlg = DlgReconnect.new(bAuto, nType, nSecType)
    end
    UIAction.enterDialog(pDlg, Player:getUIHomeLayer()
        or RootLayerHelper:getCurRootLayer(), bNew)
    pDlg:setZOrder(1)
end

-- 关闭重连对话框(该方法暂时舍弃掉)
-- function hideReconnectDlg(  )
--     -- 恢复网络状态
--     exchangeConStatus(e_network_status.nor)
--     -- 关闭对话框
--     local pDlg, bNew = getDlgByType(e_dlg_index.reconnect)
--     if(pDlg) then
--         UIAction.exitDialog(pDlg)
--     end
-- end

-- 获取loading的动画
function addLoadingAction( pParView )
    if(not pParView) then
        return
    end
    local nTag = 98038322
    local pActionLayer = MUI.MLayer.new(true)
    pActionLayer:setLayoutSize(102, 102)
    pActionLayer:setTag(nTag)

    pParView:addView(pActionLayer, 10) 
    centerInView(pParView, pActionLayer)

    for i = 1, 4 do
        local pArm = MArmatureUtils:createMArmature(
            tNormalCusArmDatas["loading_" .. i], 
            pActionLayer, 
            10 + i, 
            cc.p(pActionLayer:getWidth() / 2,pActionLayer:getHeight() / 2),
            function ( _pArm )

            end, Scene_arm_type.normal)
        if pArm then
            pArm:setTag(nTag + i)
            pArm:play(-1)
        end
    end
    -- for i = 1, 5 do
    --     local pArm = MArmatureUtils:createMArmature(
    --         tNormalCusArmDatas["27_" .. i], 
    --         pParView, 
    --         10, 
    --         cc.p(pParView:getWidth() / 2,pParView:getHeight() / 2),
    --         function ( _pArm )

    --         end)
    --     if pArm then
    --         pArm:setTag(nTag + i)
    --         pArm:play(-1)
    --     end
    -- end
end

-- 取消loading数据
function releaseLoadingAction( pParView )
    if(not pParView) then
        return
    end
    local nTag = 98038322
    local pActionLayer = pParView:getChildByTag(nTag)
    if pActionLayer then
        for i = 1, 4 do
            local pImg = pActionLayer:getChildByTag(nTag + i)
            if pImg then
                pImg:removeSelf()
                pImg = nil
            end
        end
        pActionLayer:removeSelf()
        pActionLayer = nil
    end
end

-- 初始化不同对话框的层级，为了限定不同对话框的不同控制
-- nType(e_layer_order_type): 层类型
function getRealShowLayer( _rootlayer, nType )
    local pParView = _rootlayer
    if(_rootlayer == Player:getUIHomeLayer()) then
        pParView = Player:getUIHomeLayer()
    elseif(_rootlayer == Player:getUIFightLayer()) then
        pParView = Player:getUIFightLayer()
    elseif(_rootlayer == Player:getUILoginLayer()) then
        pParView = Player:getUILoginLayer()
    end
    if(pParView) then
        local nBaseOrder = 99985
        -- 退出层，最高层级，用于存放退出对话框
        if(nType == e_layer_order_type.exitlayer) then
            if(not pParView.pUtilsExitLayer) then
                pParView.pUtilsExitLayer = MUI.MLayer.new()
                pParView.pUtilsExitLayer:setContentSize(cc.size(display.width,
                    display.height))
                pParView:addView(pParView.pUtilsExitLayer, nBaseOrder+nType)
            end
            return pParView.pUtilsExitLayer
        end
        -- 不可点击层：包括loading层，不可点击层，弹幕层
        if(nType == e_layer_order_type.unablelayer) then
            if(not pParView.pUtilsUnableLayer) then
                pParView.pUtilsUnableLayer = MUI.MLayer.new()
                pParView.pUtilsUnableLayer:setLayoutSize(display.width,display.height)
                pParView:addView(pParView.pUtilsUnableLayer, nBaseOrder+nType)
            end
            return pParView.pUtilsUnableLayer
        end
        -- 新手引导层
        if(nType == e_layer_order_type.guidelayer) then
            if(not pParView.pUtilsGuideLayer) then
                pParView.pUtilsGuideLayer = MUI.MLayer.new()
                pParView.pUtilsGuideLayer:setLayoutSize(display.width,display.height)
                pParView:addView(pParView.pUtilsGuideLayer, nBaseOrder+nType)
            end
            return pParView.pUtilsGuideLayer
        end
        -- 普通对话框层
        if(nType == e_layer_order_type.normallayer) then
            if(not pParView.pUtilsDlgLayer) then
                pParView.pUtilsDlgLayer = MUI.MLayer.new()
                pParView.pUtilsDlgLayer:setLayoutSize(display.width,display.height)
                pParView:addView(pParView.pUtilsDlgLayer, nBaseOrder+nType)
            end
            return pParView.pUtilsDlgLayer
        end
        -- 提示语层
        if(nType == e_layer_order_type.toastlayer) then
            if(not pParView.pUtilsToastLayer) then
                pParView.pUtilsToastLayer = MUI.MLayer.new()
                pParView.pUtilsToastLayer:setLayoutSize(display.width,display.height)
                pParView:addView(pParView.pUtilsToastLayer, nBaseOrder+nType)
            end
            return pParView.pUtilsToastLayer
        end
    end
    return _rootlayer
end

-- 改变当前临时保存层的数据
-- pRootLayer(SRootLayer): 当前需要展示的rootlayer
function exchangeEmptyTmpMidLayer( pRootLayer )
    if(not pRootLayer) then
        return
    end
    if(Player:getTmpMidLayer() == nil) then
        local TmpMidLayer = require("app.layer.home.TmpMidLayer")
        Player:initTmpMidLayer(TmpMidLayer.new())
        Player:getTmpMidLayer():setTag(9638524)
        Player:getTmpMidLayer():retain()
    else
        -- 从父控件中清除自己
        Player:getTmpMidLayer():removeSelf()
    end
    -- 增加到新的控件中
    pRootLayer:addView(Player:getTmpMidLayer())
end

-- 释放自己对临时层的占用
-- pRootLayer(SRootLayer): 当前需要展示的rootlayer
function releaseEmptyTmpMidLayer( pRootLayer )
    if(not pRootLayer) then
        return
    end
    local pView = pRootLayer:findViewByTag(9638524)
    if(pView) then
        pView:removeSelf()
    end
end

--检测对话框是否展示中
function checkIfHadShowed( _nDlgType )
    -- body
    if not tAllDlgs or table.nums(tAllDlgs) <= 0 then
        return false
    end

    if not _nDlgType then
        return false
    end

    local bHad = false
    for k, v in pairs (tAllDlgs) do
        if v.eDlgType == _nDlgType and v.isShowing and v:isShowing() then
            bHad = true
            break
        end
    end
    return bHad
end

--判断是否是全屏对话框
function checkIsFillDlg( _nDlgType )
    -- body
    local bTrue = false
    if not _nDlgType then return bTrue end
    if tDlgParams[tostring(_nDlgType)] and tDlgParams[tostring(_nDlgType)].t == 1 then --那么就是全屏对话框
        bTrue = true
    end
    return bTrue
end

--展示被隐藏的层
function sendMsgToShowHome( _nDlgType )
    -- body
    if not _nDlgType then
        return
    end
    if checkIsFillDlg(_nDlgType) then
        tShowingFillDlgs[tostring(_nDlgType)] = nil
        if table.nums(tShowingFillDlgs) == 0 then
            local tObj = {}
            tObj.nType = 2
            sendMsg(ghd_state_for_filldlg_msg, tObj)
        end
    end
end

--再次检测是否需要展示homelayer（二次验证）
function checkToShowHome(  )
    -- body
    if tShowingFillDlgs and table.nums(tShowingFillDlgs) > 0 then
        local bClear = true
        for k, v in pairs (tShowingFillDlgs) do
            local pDlg = getDlgByType(tonumber(k))
            if pDlg then
                if pDlg:isShowing() then
                    bClear = false
                    break
                end
            end
        end
        if bClear then --如果清除
            tShowingFillDlgs = {}
            local tObj = {}
            tObj.nType = 2
            sendMsg(ghd_state_for_filldlg_msg, tObj)
        end
    end
end

--隐藏需要展示的层
function sendMsgToHideHome(_nDlgType)
    -- body
     if not _nDlgType then
        return
    end
    if checkIsFillDlg(_nDlgType) then --那么就是全屏对话框
        tShowingFillDlgs[tostring(_nDlgType)] = 1
        if table.nums(tShowingFillDlgs) == 1 then
            --如果是全屏对话框，那么发送消息
            local tObj = {}
            tObj.nType = 1
            sendMsg(ghd_state_for_filldlg_msg, tObj)
        end
    end
end
N_MAX_KEEP_DLG_COUNT = 24 -- 最多数量的对话框缓存个数
-- 检测所有对话框的队列，根据上限值，关闭最早打开的对话框
function checkAllDlgSequence(  )
    tAllDlgs = tAllDlgs or {}
    -- 总个数都不超过上限数，直接返回
    if(N_MAX_KEEP_DLG_COUNT >= #tAllDlgs) then
        return
    end
    local pLastOldDlg = nil
    local nCount = 0 -- 隐藏的对话框总个数

    for i = #tAllDlgs, 1, -1 do
        if tolua.isnull(v) then
            table.remove(tAllDlgs, i)
        else
            if v:isVisible() == false then
                local tmp = tDlgParams[tostring(v.eDlgType)]
                if(tmp and tmp.h >= 1 and b_open_ui_cach) then
                    -- 隐藏中的个数加1
                    nCount = nCount + 1
                    if(pLastOldDlg == nil) then -- 记录第一个对话框
                        pLastOldDlg = v
                    else -- 判断显示的时间，记录最早显示过的对话框
                        if(pLastOldDlg.fLsatShowTime > v.fLsatShowTime) then
                            pLastOldDlg = v
                        end
                    end
                end
            end
        end
    end
    -- 如果隐藏的对话框个数比上限值小，直接返回
    if(N_MAX_KEEP_DLG_COUNT >= nCount) then
        return
    end
    -- 如果存在已经超过上限的对话框，关闭它
    if(pLastOldDlg) then
        UIAction.exitDialog(pLastOldDlg)
    end
end
-- 暂时关闭缓存池，延迟一段时间再重新打开
--function updatePoolState( _eType )
--    if(not b_open_viewpool) then
--        return
--    end
--    local tTmp = tDlgParams[tostring(_eType)]
--    if(tTmp and tTmp.h and b_open_ui_cach) then
--        -- 暂时关闭缓存池，延迟一段时间再重新打开
--        MViewPool:getInstance():setReady(false)
--        Player:getTmpMidLayer():performWithDelay(function (  )
--            MViewPool:getInstance():setReady(true)
--        end, 0.8)
--    end
--end

function checkOverDlg( _dlg, _func )
    if(not _dlg) then
        if(_func) then
            _func()
        end
        return
    end
    local _eType = _dlg.eDlgType
    local tTmp = tDlgParams[tostring(_eType)]
    if(tTmp and tTmp.cf) then
        if(true) then -- 展示过度层
            if(_func) then
                _func()
            end
            showOverDlg(tTmp.cf)
        else -- 等待界面加载完再显示内容
            showUnableTouchDlg()
            _dlg:setVisible(false)
            scheduleOnceCallback(_dlg, function (  )
                hideUnableTouchDlg()
                _dlg:setVisible(true)
                if(_func) then
                    _func()
                end
            end, tTmp.cf+1)
        end
    else
        if(_func) then
            _func()
        end
    end
end

-- 显示过度场景对话框
function showOverDlg( _fTime )
    _fTime = _fTime or 1
    -- 找到控制层
    local nDtag = 898452
    local parView = getRealShowLayer(RootLayerHelper:getCurRootLayer(), 
        e_layer_order_type.toastlayer)
    local dlg = parView:findViewByTag(nDtag)
    if(not dlg) then
        local DlgOverScene = require("app.common.dialog.DlgOverScene")
        dlg = DlgOverScene.new()
        dlg:setTag(nDtag)
        parView:addView(dlg)
    end
    scheduleOnceCallback(dlg, function (  )
        local tag = 87524
        dlg:stopActionByTag(tag)
        dlg:setOpacity(255)
        local ac = cc.Sequence:create({
            cc.DelayTime:create(0.05),
            cc.FadeOut:create(0.3),
            cc.CallFunc:create(function (  )
                hideOverDlg()
            end)
            })
        ac:setTag(tag)
        dlg:runAction(ac)
    end, _fTime)
end
-- 隐藏过度场景
function hideOverDlg(  )
    -- 找到控制层
    local nDtag = 898452
    local parView = getRealShowLayer(RootLayerHelper:getCurRootLayer(), 
        e_layer_order_type.toastlayer)
    local dlg = parView:findViewByTag(nDtag)
    if dlg then
        dlg:removeSelf()
    end
end