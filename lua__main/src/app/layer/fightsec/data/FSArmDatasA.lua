-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-13 16:57:02 星期三
-- Description: 定义下方士兵表现数据
-- 			  	tFightArmDatas["单位id_方向_动作类型"]  
-- 				例如：tFightArmDatas["1_1_1_1"]
-- 						方向：1表示下方 2：表示上方
-- 						兵种类型：1：步兵  2：骑兵  3：弓兵  4：武将
-- 						动作类型：1：待机  2：跑步  3：普攻 4：强攻  5：捅死
-- 						动作类型子分类：比如攻击有几种类型
-----------------------------------------------------



-------------------------------------------------- 下方===《步兵》===动作 --------------------------------
--待机动作
tFightSecArmDatas["1_1_1_1"] = 
{
    sPlist = "tx/fight/p2_fight_bb_x",
    nImgType = 2,
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_dj_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightSecArmDatas["1_1_2_1"] = 
{
    sPlist = "tx/fight/p2_fight_bb_x",
    nImgType = 2,
	nFrame = 11, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_pb_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--普攻动作
tFightSecArmDatas["1_1_3_1"] = 
{
    sPlist = "tx/fight/p2_fight_bb_x",
    nImgType = 2,
	nFrame = 19, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_pg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--强攻动作
tFightSecArmDatas["1_1_4_1"] = 
{
    sPlist = "tx/fight/p2_fight_bb_x",
    nImgType = 2,
	nFrame = 20, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_qg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--捅死动作
tFightSecArmDatas["1_1_5_1"] = 
{
    sPlist = "tx/fight/p2_fight_bb_x",
    nImgType = 2,
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/20, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_ts_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
-------------------------------------------------- 下方===《骑兵》===动作 --------------------------------
--待机动作
tFightSecArmDatas["1_2_1_1"] = 
{
    sPlist = "tx/fight/p2_fight_qb_x",
    nImgType = 2,
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_x_dj_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightSecArmDatas["1_2_2_1"] = 
{
    sPlist = "tx/fight/p2_fight_qb_x",
    nImgType = 2,
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_x_pb_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--普攻动作
tFightSecArmDatas["1_2_3_1"] = 
{
    sPlist = "tx/fight/p2_fight_qb_x",
    nImgType = 2,
	nFrame = 13, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/30, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_x_pg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--强攻动作
tFightSecArmDatas["1_2_4_1"] = 
{
    sPlist = "tx/fight/p2_fight_qb_x",
    nImgType = 2,
	nFrame = 25, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/30, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_x_qg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--捅死动作
tFightSecArmDatas["1_2_5_1"] = 
{
    sPlist = "tx/fight/p2_fight_qb_x",
    nImgType = 2,
	nFrame = 13, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/20, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_x_ts_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
-------------------------------------------------- 下方===《弓兵》===动作 --------------------------------
--待机动作
tFightSecArmDatas["1_3_1_1"] = 
{
    sPlist = "tx/fight/p2_fight_gb_x",
    nImgType = 2,
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_x_dj_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightSecArmDatas["1_3_2_1"] = 
{
    sPlist = "tx/fight/p2_fight_gb_x",
    nImgType = 2,
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_x_pb_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--普攻动作
tFightSecArmDatas["1_3_3_1"] = 
{
    sPlist = "tx/fight/p2_fight_gb_x",
    nImgType = 2,
	nFrame = 9, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_x_pg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 9, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--强攻动作
tFightSecArmDatas["1_3_4_1"] = 
{
    sPlist = "tx/fight/p2_fight_gb_x",
    nImgType = 2,
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_x_qg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--捅死动作
tFightSecArmDatas["1_3_5_1"] = 
{
    sPlist = "tx/fight/p2_fight_gb_x",
    nImgType = 2,
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/20, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_x_ts_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
-------------------------------------------------- 下方===《武将》===动作 --------------------------------
--待机动作
tFightSecArmDatas["1_4_1_1"] = 
{
    sPlist = "tx/fight/p2_fight_wj_x",
    nImgType = 2,
	nFrame = 13, -- 总帧数
	pos = {2, 9}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_dj_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightSecArmDatas["1_4_2_1"] = 
{
    sPlist = "tx/fight/p2_fight_wj_x",
    nImgType = 2,
	nFrame = 11, -- 总帧数
	pos = {2, 9}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_pb_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--普攻动作
tFightSecArmDatas["1_4_3_1"] = 
{
    sPlist = "tx/fight/p2_fight_wj_x",
    nImgType = 2,
	nFrame = 16, -- 总帧数
	pos = {2, 9}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_pg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--强攻动作
tFightSecArmDatas["1_4_4_1"] = 
{
    sPlist = "tx/fight/p2_fight_wj_x",
    nImgType = 2,
	nFrame = 15, -- 总帧数
	pos = {2, 9}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_qg_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 15, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--捅死动作
tFightSecArmDatas["1_4_5_1"] = 
{
    sPlist = "tx/fight/p2_fight_wj_x",
    nImgType = 2,
	nFrame = 11, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/20, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_ts_aa_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--蓄力动作
tFightSecArmDatas["1_4_6_1"] = 
{
    sPlist = "tx/fight/p2_fight_wj_x",
    nImgType = 2,
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_xl_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}