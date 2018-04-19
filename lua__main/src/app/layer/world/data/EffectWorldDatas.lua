EffectWorldDatas = {}
local sPath = ""
-- --点击特效
-- EffectWorldDatas["gridClicked1"] = 
-- {
-- 	nFrame = 36, -- 总帧数
-- 	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 1, -- 需要加亮
--    	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_czzb_001.png",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 7, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{0, 0},
-- 			}, -- 参数列表
-- 		},

-- 		{
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_czzb_001.png",
-- 			nSFrame = 8, -- 开始帧下标
-- 			nEFrame = 18, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{0, 255},
-- 			}, -- 参数列表
-- 		},

-- 		{
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_czzb_001.png",
-- 			nSFrame = 19, -- 开始帧下标
-- 			nEFrame = 36, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{255, 0},
-- 			}, -- 参数列表
-- 		},
-- 	},
-- }
-- --点击特效2
-- EffectWorldDatas["gridClicked2"] = 
-- {
-- 	nFrame = 16, -- 总帧数
-- 	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 1, -- 需要加亮
--    	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_czzb_001.png",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 5, -- 结束帧下标
-- 			tValues = {
-- 				{3.33,2.56},
-- 				{0, 125},
-- 			}, -- 参数列表
-- 		},

-- 		{
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_czzb_001.png",
-- 			nSFrame = 6, -- 开始帧下标
-- 			nEFrame = 16, -- 结束帧下标
-- 			tValues = {
-- 				{2.41,1.19},
-- 				{105, 0},
-- 			}, -- 参数列表
-- 		},
-- 	},
-- }

--进攻特效1
EffectWorldDatas["gridAtk1"] = 
{
	nFrame = 20, -- 总帧数
	x = 0, -- 初始时相对中心锚点的x偏移值
	y = 0, -- 初始时相对中心锚点的y偏移值
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
               nPerFrameTime = 1/25, -- 每帧播放时间（25帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jmtx_jggx_sa001_002",
			nSFrame = 1,
			nEFrame = 10,
			tValues = {
				{1.32, 1.5},
				{255, 255},
			}
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jmtx_jggx_sa001_002",
			nSFrame = 11,
			nEFrame = 20,
			tValues = {
				{1.5, 1.32},
				{255, 255},
			}
		},
	},
}

--进攻特效2
EffectWorldDatas["gridAtk2"] = 
{
	nFrame = 20, -- 总帧数
	x = 0, -- 初始时相对中心锚点的x偏移值
	y = 0, -- 初始时相对中心锚点的y偏移值
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
               nPerFrameTime = 1/25, -- 每帧播放时间（25帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jmtx_jggx_sa001_001x2",
			nSFrame = 1,
			nEFrame = 10,
			tValues = {
				{1.38, 1.38},
				{255, 150},
			}
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jmtx_jggx_sa001_001x2",
			nSFrame = 11,
			nEFrame = 20,
			tValues = {
				{1.38, 1.38},
				{150, 255},
			}
		},
	},
}

--进攻特效3
EffectWorldDatas["gridAtk3"] = 
{
	nFrame = 20, -- 总帧数
	x = 0, -- 初始时相对中心锚点的x偏移值
	y = 0, -- 初始时相对中心锚点的y偏移值
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
               nPerFrameTime = 1/25, -- 每帧播放时间（25帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jmtx_jggx_sa001_001x1",
			nSFrame = 1,
			nEFrame = 10,
			tValues = {
				{1.38, 1.38},
				{255, 150},
			}
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jmtx_jggx_sa001_001x1",
			nSFrame = 11,
			nEFrame = 20,

			tValues = {
				{1.38, 1.38},
				{150, 255},
			}
		},
	},
}

-- --进攻特效4
-- EffectWorldDatas["gridAtk4"] = 
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {0, -1}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 1, -- 需要加亮
--    	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_jggx_sa_002.png",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 10, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{200, 255},
-- 			}, -- 参数列表
-- 		},

-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_jggx_sa_002.png",
-- 			nSFrame = 11, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{255, 200},
-- 			}, -- 参数列表
-- 		},
-- 	},
-- }

-- --进攻特效5
-- EffectWorldDatas["gridAtk5"] = 
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 1, -- 需要加亮
--    	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_jggx_sa_001.png",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 10, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{255, 255},
-- 			}, -- 参数列表
-- 		},

-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_jggx_sa_001.png",
-- 			nSFrame = 11, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{255, 255},
-- 			}, -- 参数列表
-- 		},
-- 	},
-- }

-- --进攻特效6 
-- EffectWorldDatas["gridAtk6"] = 
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 1, -- 需要加亮
--    	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_jggx_sa_001.png",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 10, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{255, 0},
-- 			}, -- 参数列表
-- 		},

-- 		 {
-- 			nType = 5, -- 序列帧播放
-- 			sImgName = "sg_jmtx_jggx_sa_001.png",
-- 			nSFrame = 11, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = {
-- 				{1.25,1.25},
-- 				{0, 255},
-- 			}, -- 参数列表
-- 		},
-- 	},
-- }

--世界武将出征
EffectWorldDatas["heroBattleSel"] = 
{
	nFrame = 22, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jxfk_sa1_001.png",
			nSFrame = 1,
			nEFrame = 8,
			tValues = {-- 参数列表
				{1.00, 1.00}, -- 开始, 结束缩放值
				{127, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_jxfk_sa1_001.png",
			nSFrame = 9,
			nEFrame = 22,
			tValues = {-- 参数列表
				{1.00, 1.00}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}

--大地图乱军步兵
EffectWorldDatas["wildArmyInfantry"]  = 
{
	nFrame = 21, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_sjlk_bb_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 21, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--大地图乱军弓兵
EffectWorldDatas["wildArmyArcher"]  = 
{
	nFrame = 20, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_sjlk_gb_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--大地图乱军骑兵
EffectWorldDatas["wildArmyCavalry"]  = 
{
	nFrame = 18, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_sjlk_qb_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_1"] = 
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {0, 14}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_2"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {-19, 5}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_3"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {16, 5}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_4"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {-38, -3}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_5"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {-1, -3}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_6"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {33, -3}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_7"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {-21, -12}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_8"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {15, -10}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
-- --大地图乱军3x3
-- EffectWorldDatas["wildArmy3x3_9"] =
-- {
-- 	nFrame = 21, -- 总帧数
-- 	pos = {-3, -18}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--    	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
-- 	tActions = {
-- 		 {
-- 			nType = 1, -- 序列帧播放
-- 			sImgName = "sg_sjlk_bb01x_",
-- 			nSFrame = 1, -- 开始帧下标
-- 			nEFrame = 21, -- 结束帧下标
-- 			tValues = nil, -- 参数列表
-- 		},
-- 	},
-- }
--大地图乱军3x3
EffectWorldDatas["wildArmy3x3"] =
{
	nFrame = 21, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_sjlk_bb01x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 21, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	}
}

--红旗将上到下
EffectWorldDatas["redArmyUpToDown"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {2, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hq_sdx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--红旗将下到上
EffectWorldDatas["redArmyDownToUp"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-2, 41}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hq_xds_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--红旗将左到右
EffectWorldDatas["redArmyLeftToRight"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-2, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hq_zdy_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--红旗将左上到右下
EffectWorldDatas["redArmyLeftUToRightD"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-1, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hq_zsdyx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--红旗将左下到右上
EffectWorldDatas["redArmyLeftDToRightU"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-2, 45}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hq_zxdys_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--蓝旗将上到下
EffectWorldDatas["blueArmyUpToDown"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {0, 49}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lh_sdx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--蓝旗将下到上
EffectWorldDatas["blueArmyDownToUp"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-2, 43}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lh_xds_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--蓝旗将左到右
EffectWorldDatas["blueArmyLeftToRight"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {0, 46}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lq_zdy_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--蓝旗将左上到右下
EffectWorldDatas["blueArmyLeftUToRightD"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-1, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lq_zsdyx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--蓝旗将左下到右上
EffectWorldDatas["blueArmyLeftDToRightU"] = {
    sPlist = "tx/world/sg_warline_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {0, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lq_zxdys_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--冥王将上到下
EffectWorldDatas["redArmyUpToDown_gh"] = {
    sPlist = "tx/world/sg_mw_line_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {2, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_mw_sdx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--冥王将下到上
EffectWorldDatas["redArmyDownToUp_gh"] = {
    sPlist = "tx/world/sg_mw_line_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-2, 41}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_mw_xds_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--冥王将左到右
EffectWorldDatas["redArmyLeftToRight_gh"] = {
    sPlist = "tx/world/sg_mw_line_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-2, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_mw_zdy_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--冥王将左上到右下
EffectWorldDatas["redArmyLeftUToRightD_gh"] = {
    sPlist = "tx/world/sg_mw_line_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-1, 48}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_mw_zsdyx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--冥王将左下到右上
EffectWorldDatas["redArmyLeftDToRightU_gh"] = {
    sPlist = "tx/world/sg_mw_line_hero",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {-2, 45}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_mw_zxdys_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


--旋转光（循环播放）
EffectWorldDatas["sysCityUiLight"]  = {
    sPlist = "tx/world/sg_sjdt_xzg_zstx",
    nImgType = 1,
	nFrame = 13, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_sjdt_xzg_zstx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--箱子部分的呼吸效果
EffectWorldDatas["sysCityUiBox"]  = {
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.8,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "v1_img_zjm_hd",
			nSFrame = 0,
			nEFrame = 15,
			tValues = {-- 参数列表
				{60, 0}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "v1_img_zjm_hd",
			nSFrame = 16,
			nEFrame = 30,
			tValues = {-- 参数列表
				{0, 60}, -- 开始, 结束透明度值
			},
		},
	},
}

--旗子呼吸动画
EffectWorldDatas["sysCityUiFlag"] =
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "v1_btn_guozhan2",
			nSFrame = 0,
			nEFrame = 15,
			tValues = {-- 参数列表
				{70, 0}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "v1_btn_guozhan2",
			nSFrame = 16,
			nEFrame = 30,
			tValues = {-- 参数列表
				{0, 70}, -- 开始, 结束透明度值
			}
		},
	},
}

--小保护罩动画
EffectWorldDatas["smallProtectCover"] =
{
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_sjdt_xbhz_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--小征收动画
EffectWorldDatas["smallCollectCover"] =
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/90, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "rwww_sjdt_zs_zt_001",
			nSFrame = 1,
			nEFrame = 15,
			tValues = {-- 参数列表
				{1, 0.88}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "rwww_sjdt_zs_zt_001",
			nSFrame = 16,
			nEFrame = 30,
			tValues = {-- 参数列表
				{0.88, 1}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
	}
}

--定位呼吸灯效果
EffectWorldDatas["breathingLamp"] =
{
	nFrame = 40, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/40, -- 每帧播放时间（40帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "v1_img_dw_sj",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{0, 55}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "v1_img_dw_sj",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{55, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}

--头像1   小骷髅头
EffectWorldDatas["littleSkull1"] =
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.5,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_sjdt_wwgz_tx_001",
			nSFrame = 1,
			nEFrame = 12,
			tValues = {-- 参数列表
				{0, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_sjdt_wwgz_tx_001",
			nSFrame = 13,
			nEFrame = 30,
			tValues = {-- 参数列表
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}

EffectWorldDatas["littleSkull2"] =
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_sjdt_wwgz_tx_001",
			nSFrame = 1,
			nEFrame = 7,
			tValues = {-- 参数列表
				{0.5, 0.68}, -- 开始, 结束缩放值
				{0, 100}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_sjdt_wwgz_tx_001",
			nSFrame = 8,
			nEFrame = 24,
			tValues = {-- 参数列表
				{0.69, 1.12}, -- 开始, 结束缩放值
				{100, 0}, -- 开始, 结束透明度值
			},
		},
	},
}

--头像2   大骷髅头
EffectWorldDatas["bigSkull1"] =
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.5,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_sjdt_wwgz_tx_002",
			nSFrame = 1,
			nEFrame = 12,
			tValues = {-- 参数列表
				{0, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_sjdt_wwgz_tx_002",
			nSFrame = 13,
			nEFrame = 30,
			tValues = {-- 参数列表
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}

EffectWorldDatas["bigSkull2"] =
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_sjdt_wwgz_tx_002",
			nSFrame = 1,
			nEFrame = 7,
			tValues = {-- 参数列表
				{0.5, 0.68}, -- 开始, 结束缩放值
				{0, 100}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_sjdt_wwgz_tx_002",
			nSFrame = 8,
			nEFrame = 24,
			tValues = {-- 参数列表
				{0.69, 1.12}, -- 开始, 结束缩放值
				{100, 0}, -- 开始, 结束透明度值
			},
		},
	},
}
