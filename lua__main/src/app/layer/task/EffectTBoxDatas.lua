EffectTBoxDatas = {}
local sPath = ""

--宝箱特效1
EffectTBoxDatas["tbox1"] = {
		nFrame = 24, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2_02",
				nSFrame = 1,
				nEFrame = 5,
				tValues = {
					{1, 1.1},
					{0, 65},
				},-- 参数列表
			},
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2_02",
				nSFrame = 6,
				nEFrame = 21,
				tValues = {
					{1.1, 1.43},
					{60, 0},
				},-- 参数列表			
			},
		},
}

EffectTBoxDatas["tbox2"] = {
		nFrame = 24, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）	
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2_02",
				nSFrame = 1,
				nEFrame = 12,
				tValues = {
					{1,	1},
					{102, 166},
				},
			},
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2_02",
				nSFrame = 13,
				nEFrame = 24,
				tValues = {
					{1, 1},
					{166, 102},
				},
			},
		},
}

EffectTBoxDatas["tbox3"] = {
	nFrame = 24, -- 总帧数
	pos = {0, 0},
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/8, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "v1_img_guojia_renwubaoxiang2",
			nSFrame = 1,
			nEFrame = 24,
			tValues = {
				{1, 1},
				{255, 255},
			},
		},
	},
}

EffectTBoxDatas["tbox4"] = {
		nFrame = 24, -- 总帧数
		pos = {0, 0},
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/8, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2",
				nSFrame = 1,
				nEFrame = 5,
				tValues = {
					{1, 1},
					{0, 102},
				},
			},
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2",
				nSFrame = 6,
				nEFrame = 14,
				tValues = {
					{1, 1},
					{98, 0},
				},
			},
		},	
}

EffectTBoxDatas["tbox5"] = {
		nFrame = 24, -- 总帧数
		pos = {0, 0},
		fScale = 1,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/8, -- 每帧播放时间（24帧每秒）
		tActions = {
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2_01",
				nSFrame = 1,
				nEFrame = 12,
				tValues = {
					{1, 1},
					{64, 191},
				},
			},
			{
				nType = 5, -- 渐隐（透明度）
				sImgName = "v1_img_guojia_renwubaoxiang2_01",
				nSFrame = 13,
				nEFrame = 24,
				tValues = {
					{1, 1},
					{191, 64},
				},
			},
		},	
} 