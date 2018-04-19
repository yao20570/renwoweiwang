-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-13 16:47:52 星期三
-- Description: 战斗特效数据
-----------------------------------------------------
tTeamInSpaceOffset = {}    			--（table）存放武将内队伍间偏移量数据
tTeamOutSpaceOffset = {}    		--（table）存放武将外队伍间偏移量数据
tFightSecArmDatas = {}    			--（table）存放特效表现数据

import(".FSArmDatasA") 		        --分文件处理（小兵动作表现数据A）
import(".FSArmDatasB") 		        --分文件处理（小兵动作表现数据B）


e_type_fight_sec_action = {         -- 战斗动作
    stand                   = 1,        -- 待命
    run 					= 2, 		-- 跑步
    attack 					= 3, 		-- 攻击
    thump 					= 4, 		-- 重击
    death 					= 5, 		-- 死亡
    gather 				    = 6, 		-- 蓄力
}

--兵种间隔偏移量(上下方通用) ：1：步兵 2：骑兵 3：弓兵 
tTeamInSpaceOffset["1"] = {x = 65,y = 33}
tTeamInSpaceOffset["2"] = {x = 79,y = 40}
tTeamInSpaceOffset["3"] = {x = 65,y = 33}
--武将间隔偏移量(上下方通用) ：1：步兵 2：骑兵 3：弓兵 (组合)
tTeamOutSpaceOffset["1_1"] = {x = 79,y = 40}
tTeamOutSpaceOffset["1_2"] = {x = 93,y = 47}
tTeamOutSpaceOffset["1_3"] = {x = 79,y = 40}
tTeamOutSpaceOffset["2_1"] = {x = 93,y = 47}
tTeamOutSpaceOffset["2_2"] = {x = 102,y = 52}
tTeamOutSpaceOffset["2_3"] = {x = 93,y = 47}
tTeamOutSpaceOffset["3_1"] = {x = 79,y = 40}
tTeamOutSpaceOffset["3_2"] = {x = 93,y = 47}
tTeamOutSpaceOffset["3_3"] = {x = 79,y = 40}




--受到步兵攻击特效（受击）
tFightSecArmDatas["1_10"] = 
{
    sPlist = "tx/fight/p2_fight_hurt",
    nImgType = 2,
	nFrame = 6, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zdtx_bbsjgx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 6, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--受到骑兵攻击特效（受击）
tFightSecArmDatas["2_10"] = 
{
    sPlist = "tx/fight/p2_fight_hurt",
    nImgType = 2,
	nFrame = 8, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zdtx_qbsjgx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 8, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--受到弓兵攻击特效（受击）
tFightSecArmDatas["3_10"] = 
{
    sPlist = "tx/fight/p2_fight_hurt",
    nImgType = 2,
	nFrame = 6, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zdtx_gbsjgx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 6, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--受到重击特效（受击）
tFightSecArmDatas["4_10"] = 
{
    sPlist = "tx/fight/p2_fight_hurt",
    nImgType = 2,
	nFrame = 9, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_skill_bj_sj_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 9, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--暴击是的蓄力特效（蓄力）
tFightSecArmDatas["5_10"] = 
{
    sPlist = "tx/fight/p2_fight_hurt",
    nImgType = 2,
	nFrame = 4, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_skill_bj_xl_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 4, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--武将底部红色圈（旋转）
tFightSecArmDatas["2_1"] = 
{
    sPlist = "tx/fight/p1_fight_wj_circle",
    nImgType = 1,
	nFrame = 15, -- 总帧数
	pos = {-10, -5}, -- 特效的x,y轴位置（相对中心锚点的偏移）
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
tFightSecArmDatas["2_2"] = 
{
    sPlist = "tx/fight/p1_fight_wj_circle",
    nImgType = 1,
	nFrame = 15, -- 总帧数
	pos = {-9, -4}, -- 特效的x,y轴位置（相对中心锚点的偏移）
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
tFightSecArmDatas["2_3"] = 
{
    sPlist = "tx/fight/p1_fight_wj_circle",
    nImgType = 1,
	nFrame = 15, -- 总帧数
	pos = {-10, -5}, -- 特效的x,y轴位置（相对中心锚点的偏移）
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
tFightSecArmDatas["1_1"] = 
{
    sPlist = "tx/fight/p1_fight_wj_circle",
    nImgType = 1,
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
tFightSecArmDatas["1_2"] = 
{
    sPlist = "tx/fight/p1_fight_wj_circle",
    nImgType = 1,
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
tFightSecArmDatas["1_3"] = 
{
    sPlist = "tx/fight/p1_fight_wj_circle",
    nImgType = 1,
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
tFightSecArmDatas["100_1"] = 
{
    sPlist = "tx/fight/p1_fight_skill_bj_001",
    nImgType = 1,
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
tFightSecArmDatas["100_2"] = 
{
    sPlist = "tx/fight/p1_fight_skill_bj_001",
    nImgType = 1,
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
tFightSecArmDatas["100_3"] = 
{
    sPlist = "tx/world/p1_fight_skill_sep",
    nImgType = 1,
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
tFightSecArmDatas["100_4"] = 
{
    sPlist = "tx/world/p1_fight_skill_sep",
    nImgType = 1,
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
tFightSecArmDatas["100_5"] = 
{
    sPlist = "tx/world/p1_fight_skill_sep",
    nImgType = 1,
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
tFightSecArmDatas["101_1"] = 
{
    sPlist = "tx/fight/p1_fight_skill_gj_001",
    nImgType = 1,
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
tFightSecArmDatas["101_2"] = 
{
    sPlist = "tx/fight/p1_fight_skill_gj_001",
    nImgType = 1,
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
tFightSecArmDatas["102_1"] = 
{
    sPlist = "tx/fight/p1_fight_skill_qj_001",
    nImgType = 1,
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
tFightSecArmDatas["103_1"] = 
{
    sPlist = "tx/fight/p1_fight_skill_qj_001",
    nImgType = 1,
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
tFightSecArmDatas["103_2"] = 
{
    sPlist = "tx/fight/p1_fight_skill_qj_001",
    nImgType = 1,
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
tFightSecArmDatas["103_3"] = 
{
    sPlist = "tx/fight/p1_fight_skill_qj_001",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/20, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "sg_zd_hy_sss_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tFightSecArmDatas["103_4"] = 
{   
    sPlist = "tx/world/p1_tx_world",
    nImgType = 1,
	nFrame = 38, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/40, -- 每帧播放时间（12帧每秒）
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