-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-09 14:51:03 星期四
-- filename：FightGArmDatasB.lua  
-- Description: 定义跟FightGArmDatasA.lua文件一致 ----------------------------武将上----------------------
-----------------------------------------------------

-------------------------------------------------- 武将10002动作 --------------------------------
--待机动作
tFightArmDatas["10002_2_1_1"] = 
{
	nFrame = 25, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_s_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["10002_2_1_2"] = 
{
	nFrame = 26, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_s_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 26, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightArmDatas["10002_2_2_1"] = 
{
	nFrame = 11, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_s_pb_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--攻击动作
tFightArmDatas["10002_2_3_1"] = 
{
	nFrame = 18, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_s_gj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["10002_2_3_2"] = 
{
	nFrame = 18, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_s_gj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--死亡动作
tFightArmDatas["10002_2_4_1"] = 
{
	nFrame = 24, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_s_sw_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["10002_2_4_2"] = 
{
	nFrame = 23, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_wj_s_sw_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 23, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--重击动作
tFightArmDatas["10002_2_5_1"] = 
{
	nFrame = 15, -- 总帧数
	pos = {4, 23}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_wj_s_",
			nSFrame = 2, -- 开始帧下标
			nEFrame = 15, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--飙血
tFightArmDatas["10002_2_6_1"] = 
{
	nFrame = 17, -- 总帧数
	pos = {-42, -24}, -- 特效的x,y轴位置（相对中心锚点的偏移）
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
tFightArmDatas["10002_2_7_1"] = 
{
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_xl_s_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}