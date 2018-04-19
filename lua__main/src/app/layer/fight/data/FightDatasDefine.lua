-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-09 14:49:24 星期四
-- Description: 战斗特效数据 引用类
-----------------------------------------------------

tFightArmDatas = {}    			--（table）存放特效表现数据

import(".FightGArmDatasA")    	--分文件处理（武将动作表现数据A）
import(".FightGArmDatasB") 		--分文件处理（武将动作表现数据B）
import(".FightSArmDatasA") 		--分文件处理（小兵动作表现数据A）
import(".FightSArmDatasB") 		--分文件处理（小兵动作表现数据B）
import(".FightMatrixPos") 		--阵型坐标配置文件
import(".TestReportData") 		--战报测试数据

e_type_fight_action = {         -- 战斗动作
    stand                   = 1,        -- 待命
    run 					= 2, 		-- 跑步
    attack 					= 3, 		-- 攻击
    death 					= 4, 		-- 死亡
    thump 					= 5, 		-- 重击
    blood 					= 6, 		-- 飙血
    gather 					= 7, 		-- 蓄力
}

--武将底部红色圈（旋转）
tFightArmDatas["2_1"] = 
{
	nFrame = 15, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_lsegh_s_wj_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 15, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--武将底部红色圈（缩放透明）
tFightArmDatas["2_2"] = 
{
	nFrame = 15, -- 总帧数
	pos = {1, 1}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "zd_lsegh_s_wj_s_02",
			nSFrame = 1,
			nEFrame = 7,
			tValues = {-- 参数列表
				{1.04, 1.00}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "zd_lsegh_s_wj_s_02",
			nSFrame = 8,
			nEFrame = 15,
			tValues = {-- 参数列表
				{1.00, 1.04}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
	},
}
--武将底部红色圈（缩放）
tFightArmDatas["2_3"] = 
{
	nFrame = 15, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 2, -- 渐隐（透明度）
			sImgName = "zd_lsegh_s_wj_s_01",
			nSFrame = 1,
			nEFrame = 7,
			tValues = {-- 参数列表
				{255, 50}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 渐隐（透明度）
			sImgName = "zd_lsegh_s_wj_s_01",
			nSFrame = 8,
			nEFrame = 15,
			tValues = {-- 参数列表
				{50, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}
--武将底部蓝色圈（旋转）
tFightArmDatas["1_1"] = 
{
	nFrame = 15, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_lsegh_x_wj_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 15, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--武将底部蓝色圈（缩放透明）
tFightArmDatas["1_2"] = 
{
	nFrame = 15, -- 总帧数
	pos = {0, -1}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "zd_lsegh_x_wj_s_02",
			nSFrame = 1,
			nEFrame = 7,
			tValues = {-- 参数列表
				{1.04, 1.00}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "zd_lsegh_x_wj_s_02",
			nSFrame = 8,
			nEFrame = 15,
			tValues = {-- 参数列表
				{1.00, 1.04}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
	},
}
--武将底部蓝色圈（缩放）
tFightArmDatas["1_3"] = 
{
	nFrame = 15, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 2, -- 渐隐（透明度）
			sImgName = "zd_lsegh_x_wj_s_01",
			nSFrame = 1,
			nEFrame = 7,
			tValues = {-- 参数列表
				{255, 50}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 渐隐（透明度）
			sImgName = "zd_lsegh_x_wj_s_01",
			nSFrame = 8,
			nEFrame = 15,
			tValues = {-- 参数列表
				{50, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

--步将技能
tFightArmDatas["100_1"] = 
{
	nFrame = 24, -- 总帧数
	pos = {0, 50}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.5,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_bjjn_jzd_",
			nSFrame = 3, -- 开始帧下标
			nEFrame = 15, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_15",
			nSFrame = 16,
			nEFrame = 24,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}
tFightArmDatas["100_2"] = 
{
	nFrame = 17, -- 总帧数
	pos = {1, 217}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.5,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_jqcha_lla_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 17, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["100_3"] = 
{
	nFrame = 21, -- 总帧数
	pos = {2, 7}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2.78,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_002",
			nSFrame = 1,
			nEFrame = 3,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{0, 0}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_002",
			nSFrame = 4,
			nEFrame = 6,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{255, 70}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_002",
			nSFrame = 7,
			nEFrame = 21,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{70, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}
tFightArmDatas["100_4"] = 
{
	nFrame = 6, -- 总帧数
	pos = {3, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.58,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_001",
			nSFrame = 1,
			nEFrame = 3,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{0, 0}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_001",
			nSFrame = 4,
			nEFrame = 6,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}
tFightArmDatas["100_5"] = 
{
	nFrame = 23, -- 总帧数
	pos = {1, -2}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_003",
			nSFrame = 1,
			nEFrame = 3,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{0, 0}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_003",
			nSFrame = 4,
			nEFrame = 16,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_bjjn_jzd_X_003",
			nSFrame = 17,
			nEFrame = 23,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}

--弓将技能
tFightArmDatas["101_1"] = 
{
	nFrame = 6, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_jntx_dz_gjjn_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 6, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["101_2"] = 
{
	nFrame = 14, -- 总帧数
	pos = {0, -198}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_jntx_dz_gjjn_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 14, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--骑将技能
tFightArmDatas["102_1"] = 
{
	nFrame = 9, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/20, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_zd_hy_pmsf_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 9, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["103_1"] = 
{
	nFrame = 9, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/20, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_zd_hy_pms_",
			nSFrame = 1, -- 开始帧下标 
			nEFrame = 9, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["103_2"] = 
{
	nFrame = 20, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_zd_hy_xah_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["103_3"] = 
{
	nFrame = 23, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_zd_hy_sss_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 23, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightArmDatas["103_4"] = 
{
	nFrame = 38, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/36, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_zd_hy_dhy_001",
			nSFrame = 1,
			nEFrame = 4,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{0, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_zd_hy_dhy_001",
			nSFrame = 5,
			nEFrame = 19,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_zd_hy_dhy_001",
			nSFrame = 20,
			nEFrame = 38,
			tValues = {-- 参数列表
				{1, 1}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}


