-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-20 20:27:51 星期一
-- filename：FightSArmDatasB.lua
-- Description: 定义跟FightGArmDatasA.lua文件一致 ----------------------------小兵上----------------------
-----------------------------------------------------

-------------------------------------------------- 步兵30002动作 --------------------------------
--待机动作
tFightArmDatas["30002_2_1_1"] = 
{
	nFrame = 20, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_s_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30002_2_1_2"] = 
{
	nFrame = 17, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_s_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 17, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightArmDatas["30002_2_2_1"] = 
{
	nFrame = 11, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_s_pb_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--攻击动作
tFightArmDatas["30002_2_3_1"] = 
{
	nFrame = 19, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_s_gj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30002_2_3_2"] = 
{
	nFrame = 20, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_s_gj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--死亡动作
tFightArmDatas["30002_2_4_1"] = 
{
	nFrame = 16, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_s_sw_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30002_2_4_2"] = 
{
	nFrame = 19, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_s_sw_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--重击动作
tFightArmDatas["30002_2_5_1"] = 
{
	nFrame = 9, -- 总帧数
	pos = {-20, 8}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_bb_s_",
			nSFrame = 7, -- 开始帧下标
			nEFrame = 9, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
-------------------------------------------------- 弓兵30004动作 --------------------------------
--待机动作
tFightArmDatas["30004_2_1_1"] = 
{
	nFrame = 19, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_1_2"] = 
{
	nFrame = 24, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightArmDatas["30004_2_2_1"] = 
{
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_pb_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--攻击动作1
tFightArmDatas["30004_2_3_1_1"] = 
{
	nFrame = 16, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_gj_a_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_3_1_2"] = 
{
	nFrame = 16, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_gj_a_02_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_3_1_3"] = 
{
	nFrame = 16, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_gj_a_03_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--攻击动作2
tFightArmDatas["30004_2_3_2_1"] = 
{
	nFrame = 22, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_gj_b_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 22, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_3_2_2"] = 
{
	nFrame = 23, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_gj_b_02_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 23, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_3_2_3"] = 
{
	nFrame = 23, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_gj_b_03_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 23, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--死亡动作
tFightArmDatas["30004_2_4_1"] = 
{
	nFrame = 15, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_sw_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 15, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_4_2"] = 
{
	nFrame = 24, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_gb_s_sw_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--重击
tFightArmDatas["30004_2_5_2_1"] = 
{
	nFrame = 18, -- 总帧数
	pos = {-37, -10}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_gb_",
			nSFrame = 9, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_5_2_2"] = 
{
	nFrame = 18, -- 总帧数
	pos = {-3, -29}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_gb_",
			nSFrame = 9, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30004_2_5_2_3"] = 
{
	nFrame = 18, -- 总帧数
	pos = {-43, 5}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_gb_",
			nSFrame = 9, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

-------------------------------------------------- 骑兵30006动作 --------------------------------
--待机动作
tFightArmDatas["30006_2_1_1"] = 
{
	nFrame = 21, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_s_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 21, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30006_2_1_2"] = 
{
	nFrame = 27, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_s_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 27, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--跑步动作
tFightArmDatas["30006_2_2_1"] = 
{
	nFrame = 10, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_s_pb_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 10, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--攻击动作
tFightArmDatas["30006_2_3_1"] = 
{
	nFrame = 16, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_s_gj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30006_2_3_2"] = 
{
	nFrame = 29, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_s_gj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 29, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--死亡动作
tFightArmDatas["30006_2_4_1"] = 
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_s_sw_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 30, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["30006_2_4_2"] = 
{
	nFrame = 25, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_qb_s_sw_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--重击动作
tFightArmDatas["30006_2_5_1"] = 
{
	nFrame = 16, -- 总帧数
	pos = {-22, 9}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_tx_zj_qb_s_",
			nSFrame = 12, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
