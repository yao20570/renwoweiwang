EffectTaskDatas = {}
local sPath = ""

--获取任务奖励特效
EffectTaskDatas["taskLayer"] = {
		nFrame = 17, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1.3,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 1, -- 渐隐（透明度）
				sImgName = "sg_zjm_rw_s0_",
				nSFrame = 1,
				nEFrame = 17,
				tValues = nil,-- 参数列表
			}
		},
}
--获取任务奖励光环特效
EffectTaskDatas["ringAf1"] = {
		nFrame = 11, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "sg_zjm_rw_XX_02",
				nSFrame = 1,
				nEFrame = 3,
				tValues = {
					{0.9,	1},
					{0, 255},
				},
			},
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "sg_zjm_rw_XX_02",
				nSFrame = 4,
				nEFrame = 11,
				tValues = {
					{1.04, 1.28},
					{255, 0},
				},
			},
		},
}

EffectTaskDatas["ringAf2"] = {
		nFrame = 11, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "sg_zjm_rw_XX_01",
				nSFrame = 1,
				nEFrame = 4,
				tValues = {
					{1, 1},
					{255, 120},
				},
			},
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "sg_zjm_rw_XX_01",
				nSFrame = 5,
				nEFrame = 15,
				tValues = {
					{1, 1},
					{115, 0},
				},
			},
		},
}

EffectTaskDatas["ringAf3"] = {
		nFrame = 11, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_btn_zbrw",
				nSFrame = 1,
				nEFrame = 3,
				tValues = {
					{1.22, 1.35},
					{255, 127},
				},
			},
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_btn_zbrw",
				nSFrame = 4,
				nEFrame = 12,
				tValues = {
					{1.39, 1.71},
					{118, 0},
				},
			},
		},
}
--平常光圈动画
EffectTaskDatas["ringNormalAf"] = {
		nFrame = 13, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1.36,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 1, -- 渐隐（透明度）
				sImgName = "sg_zjm_rw_gq_",
				nSFrame = 1,
				nEFrame = 13,
				tValues = nil,
			},
			
		},
}

--底框呼吸
EffectTaskDatas["bgbreath1"] = {
		nFrame = 30, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/30, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 2, -- 渐隐（透明度）
				sImgName = "sg_txkk_akl_gx_002",
				nSFrame = 0,
				nEFrame = 15,
				tValues = {
					{100, 255},					
				},
			},
			{
				nType = 2, -- 渐隐（透明度）
				sImgName = "sg_txkk_akl_gx_002",
				nSFrame = 16,
				nEFrame = 30,
				tValues = {
					{255, 100},					
				},
			},
			
		},
}

EffectTaskDatas["bgbreath2"] = {
		nFrame = 30, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/30, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 2, -- 渐隐（透明度）
				sImgName = "sg_txkk_akl_gx_003",
				nSFrame = 0,
				nEFrame = 15,
				tValues = {
					{255, 125},					
				},
			},
			{
				nType = 2, -- 渐隐（透明度）
				sImgName = "sg_txkk_akl_gx_003",
				nSFrame = 16,
				nEFrame = 30,
				tValues = {
					{125, 255},					
				},
			},
			
		},
}

--奖励状态特效
EffectTaskDatas["onprize_1"]  = 
{
	nFrame = 5, -- 总帧数
	pos = {-19, 23}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_rwtih_sd_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 5, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

EffectTaskDatas["onprize_2"]  = 
{
	nFrame = 5, -- 总帧数
	pos = {-19, -22}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_rwtih_sd_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 5, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

EffectTaskDatas["onprize_3"]  = 
{
	nFrame = 5, -- 总帧数
	pos = {8, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_rwtih_fk_sd_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 5, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}