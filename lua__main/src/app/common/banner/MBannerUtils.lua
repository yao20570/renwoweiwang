-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-11-22 10:50:41 星期三
-- Description: 自定义banner图管理类
-----------------------------------------------------



--banner类型
TypeBanner = {
	Size640X192 = 1, 		--640x192
	Size524X200 = 2, 		--524x200
	Size640X270 = 3, 		--640x270
	Size640X268 = 4, 		--640x268
	Size524X315 = 5, 		--524x315
	Size524X370 = 6, 		--524x370
	Size524X460 = 7, 		--524x370
	Size524X600 = 8, 		--524x370
	Size550X212 = 9, 		--536X141
	Size586X253 = 10, 		--586X253
	Size640X253 = 11,       --640X253
	Size524X200Pos116X94 = 12,--524x200
	Size640X215 = 13,       --640X215
	Size640X270PosZero = 14,       --640X270
	Size640X230 = 15,		--640X230
    Size640X368 = 16,       --640X315
    Size522X200 = 17,       --522X200
}

--banner参数配置
TypeBannerAttrs = {}
TypeBannerAttrs[TypeBanner.Size640X192] = {
	x = 0,
	y = 90,
	width = 640,
	height = 192,
}

TypeBannerAttrs[TypeBanner.Size524X200] = {
	x = 58,
	y = 76,
	width = 524,
	height = 200,
}

TypeBannerAttrs[TypeBanner.Size640X270] = {
	x = 0,
	y = 22,
	width = 640,
	height = 270,
}
TypeBannerAttrs[TypeBanner.Size640X270PosZero] = {
	x = 0,
	y = 0,
	width = 640,
	height = 270,
}
TypeBannerAttrs[TypeBanner.Size640X215] = {
	x = 0,
	y = 0,
	width = 640,
	height = 215,
}

TypeBannerAttrs[TypeBanner.Size640X268] = {
	x = 0,
	y = 23,
	width = 640,
	height = 268,
}

TypeBannerAttrs[TypeBanner.Size524X315] = {
	x = 58,
	y = 0,
	width = 524,
	height = 315,
}

TypeBannerAttrs[TypeBanner.Size524X370] = {
	x = 58,
	y = 524,
	width = 522,
	height = 370,
}

TypeBannerAttrs[TypeBanner.Size524X460] = {
	x = 58,
	y = 240,
	width = 522,
	height = 460,
}

TypeBannerAttrs[TypeBanner.Size524X600] = {
	x = 58,
	y = 270,
	width = 522,
	height = 600,
}

TypeBannerAttrs[TypeBanner.Size550X212] = {
	x = 0,
	y = 0,
	width = 550,
	height = 212,
}

TypeBannerAttrs[TypeBanner.Size586X253] = {
	x = 7,
	y = 8,
	width = 586,
	height = 253,
}

TypeBannerAttrs[TypeBanner.Size640X253] = {
	x = 0,
	y = 50,
	width = 640,
	height = 253,
}

TypeBannerAttrs[TypeBanner.Size524X200Pos116X94] ={
	x = 116,
	y = 94,
	width = 524,
	height = 200,
}

TypeBannerAttrs[TypeBanner.Size640X230] ={
	x = 0,
	y = 40,
	width = 640,
	height = 230,
}

TypeBannerAttrs[TypeBanner.Size640X368] ={
	x = 0,
	y = 100,
	width = 640,
	height = 315,
}

TypeBannerAttrs[TypeBanner.Size522X200] ={
	x = 0,
	y = 0,
	width = 522,
	height = 200,
}

-- Size640X230

--banner条用处
TypeBannerUsed = {
	--洗练铺
	xlp = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--铁匠铺
	tjp = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--兵营
	by = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--神兵
	sb = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--王宫
	wg = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_wg.jpg",
	},
	--将军府
	jjf = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},
	--主线任务
	zxrw = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},
	--每日任务
	mrrw = {
		nType = TypeBanner.Size640X268,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--商店
	sd = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_sd.jpg",
	},
	--工坊
	gf = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_sd.jpg",
	},
	--上阵武将
	szwj = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},
	--城门
	cm = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},
	--仓库
	ck = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},
	--科技院
	kjy = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},
	--背包
	bb = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},
	--触发礼包
	tg = {
		nType = TypeBanner.Size550X212,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},
	--帮助
	bz = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},
	--装备背包
	zbbb = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},


	--南征北战
	ac_nzbz = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},
	--七天签到
	ac_qtqd = {
		nType = TypeBanner.Size522X200,
		sImage = "ui/banner_ui/v2_img_qitian.jpg",
	},
	--每日返利
	ac_mrfl = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd6.jpg",
	},
	--消费好礼
	ac_sfhl = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd6.jpg",
	},
	--累计充值
	ac_ljcz = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},
	--副本掉落
	ac_fbdl = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},
	--工坊加速
	ac_gfjs = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},
	--经验翻倍
	ac_jyfb = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},
	--乱军加速
	ac_ljjs = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},
	--乱军迁城
	ac_ljqc = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},
	--采集加量
	ac_cjjl = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},
	--乱军图纸
	ac_ljtz = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},
	--物产加速
	ac_wcjs = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--乱军资源
	ac_ljzy = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},
	--兑换礼包
	ac_dhlb = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd6.jpg",
	},
	--每日吃鸡
	ac_mrcj = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd6.jpg",
	},
	--七日为王
	ac_qrww = {
		nType = TypeBanner.Size524X315,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},

	--红包馈赠
	ac_hbkz = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},

	--手机绑定
	ac_sjbd = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd6.jpg",
	},

	--实名认证
	ac_smrz = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd6.jpg",
	},

	--免费召唤
	ac_mfzh = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},
	
	--双旦活动
	ac_sdhd = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},

	--神兵暴击
	ac_sbbj = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},

	--阿房宫采集
	ac_afgcj = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},

	--在线福利
	ac_zxfl = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},

	ac_zbdz = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},

	ac_dzlz = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},

	ac_hgyl = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},

	--排行榜
	phb = {
		nType = TypeBanner.Size524X370,
		sImage = "ui/v2_bg_kejizonglan.jpg",
	},
	--排行榜2
	phb2 = {
		nType = TypeBanner.Size524X460,
		sImage = "ui/v2_bg_kejizonglan.jpg",
	},
	--排行榜3
	phb3 = {
		nType = TypeBanner.Size524X600,
		sImage = "ui/v2_bg_kejizonglan.jpg",
	},


	--王宫升级
	fl_wgsj = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_wg.jpg",
	},
	--成长基金
	fl_czjj = {
		nType = TypeBanner.Size640X253,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--特价卖场
	fl_tjmc = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ac/v2_img_hd6.jpg",
	},
	--登坛拜将
	fl_dtbj = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_sd.jpg",
	},
	--全民返利
	fl_qmfl = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_wg.jpg",
	},
	--福泽天下
	fl_fztx = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_sd.jpg",
	},
	--屯田计划
	fl_ttjh = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},
	--夺宝转盘
	fl_dbzp = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_wg.jpg",
	},
	--耗铁有礼
	fl_htyl = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--武王伐纣
	fl_wwfz = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},
	--寻龙夺宝
	fl_xldb = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_wg.jpg",
	},
	--战力提升
	zltj = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",	
	},
	--体力折扣
	ac_tlzk = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},
	--出征界面
	czjm = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},
	--充值签到
	ac_czqd = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},
	--特惠礼包
	thlb = {
		nType = TypeBanner.Size524X200Pos116X94,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},

	--每日特惠
	fl_mrth = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},

	--腊八拉霸
	fl_lblb = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_sd.jpg",
	},

	--寻访美人
	fl_xfmr = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_sd.jpg",
	},
	--攻城掠地
	gcld = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_xlp.jpg",
	},

	--每日抢答
	fl_mrqd = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_sd.jpg",
	},

	ac_ykzk = {
		nType = TypeBanner.Size640X215,
		sImage = "ui/banner_ac/v2_bg_banner_yueka.jpg",
 	},

	--冥界入侵
	fl_mjrq = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_tsf.jpg",
	},

	--武将收集
	ac_wjsj = {
		nType = TypeBanner.Size524X200,
		sImage = "ui/banner_ac/v2_img_hd4.jpg",
	},

	--攻城拔寨
	ac_gcbz = {
		nType = TypeBanner.Size640X192,
		sImage = "ui/banner_ui/v2_img_cm.jpg",
	},

	ac_kjxg = {
		nType = TypeBanner.Size640X230,
		sImage = "ui/banner_ui/v2_img_qgqshuang.jpg",
	},

	--韬光养晦 秦
	ac_remaim_qin = {
		nType = TypeBanner.Size640X270PosZero,
		sImage = "ui/banner_ui/v2_img_qgqshuang.jpg",
	},	

	--韬光养晦 汉
	ac_remaim_han = {
		nType = TypeBanner.Size640X270PosZero,
		sImage = "ui/banner_ui/v2_img_hglbang.jpg",
	},	

	--韬光养晦 楚
	ac_remaim_chu = {
		nType = TypeBanner.Size640X270PosZero,
		sImage = "ui/banner_ui/v2_img_cgxyu.jpg",
	},		

    --战争大厅
	zzdt = {
		nType = TypeBanner.Size640X368,
		sImage = "ui/banner_ui/v2_bg_zhanzhengdating.jpg",
	},	
	--发展礼包
	ac_fzlb = {
		nType = TypeBanner.Size640X270,
		sImage = "ui/banner_ui/v2_img_ck.jpg",
	},	
}



local MBanner = require("app.common.banner.MBanner")

--设置banner图
--_pContainer：存放banner容器层
--_nType：banner使用类型（TypeBannerUsed）
function setMBannerImage( _pContainer, _nType, _sImg)
	-- body
	local pBanner = _pContainer:findViewByName("my_banner_name")
	if _nType and _sImg then
		_nType.sImage = _sImg
	end
	if not pBanner then
		pBanner = MBanner.new(_nType)
		pBanner:setName("my_banner_name")
		_pContainer:addView(pBanner)
		pBanner:setPosition((_pContainer:getWidth() - pBanner:getWidth()) / 2,(_pContainer:getHeight() - pBanner:getHeight()) / 2)
	end
	return pBanner
end