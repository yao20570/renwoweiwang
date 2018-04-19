-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-09 11:42:55 星期四
-- filename：FightGArmDatasA.lua
-- Description: 战斗特效数据(定义如下)   ----------------------------武将下----------------------
-- 			  	tFightArmDatas["单位id_方向_动作类型"]  
-- 				例如：tFightArmDatas["10001_1_1_1"]
-- 						单位id：10001
-- 						方向：1表示下方 2：表示上方
-- 						动作类型：1：待机  2：跑步  3：攻击   4：死亡
-- 						动作类型子分类：比如攻击有几种类型
-----------------------------------------------------


-------------------------------------------------- 武将10001动作 --------------------------------
--待机动作
tFightArmDatas["10001_1_1_1"] = 
{
	nFrame = 25, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["10001_1_1_2"] = 
{
	nFrame = 26, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 26, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightArmDatas["10001_1_2_1"] = 
{
	nFrame = 11, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_pb_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--攻击动作
tFightArmDatas["10001_1_3_1"] = 
{
	nFrame = 18, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_gj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["10001_1_3_2"] = 
{
	nFrame = 18, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_gj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--死亡动作
tFightArmDatas["10001_1_4_1"] = 
{
	nFrame = 24, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_sw_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["10001_1_4_2"] = 
{
	nFrame = 23, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_x_sw_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 23, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--重击动作
tFightArmDatas["10001_1_5_1"] = 
{
	nFrame = 14, -- 总帧数
	pos = {-3, 5}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_wj_x_",
			nSFrame = 2, -- 开始帧下标
			nEFrame = 14, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--飙血
tFightArmDatas["10001_1_6_1"] = 
{
	nFrame = 17, -- 总帧数
	pos = {53, 30}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_ss_",
			nSFrame = 11, -- 开始帧下标
			nEFrame = 17, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--蓄力
tFightArmDatas["10001_1_7_1"] = 
{
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