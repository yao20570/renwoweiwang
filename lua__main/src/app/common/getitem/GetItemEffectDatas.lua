----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-17 14:57:51
-- Description: 获取物品特效
-----------------------------------------------------
if GetItemEffectDatas then return end

GetItemEffectDatas = {}
--稻草序列
GetItemEffectDatas["levyFood"]  = 
{
	nFrame = 5, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_by_zysj_dc_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 5, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


--钢块序列
GetItemEffectDatas["levyIron"]  =
{
	nFrame = 5, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_by_zysj_gk_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 5, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--金币序列
GetItemEffectDatas["levyCoin"]  = 
{
	nFrame = 5, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.8,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_by_zysj_jb_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 5, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--木头序列
GetItemEffectDatas["levyWood"] =
{
	nFrame = 5, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_by_zysj_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 5, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

-- 透明度
GetItemEffectDatas["levyNum"]  = {
	nFrame = 5, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_zszy_sswrgm_0001",
			nSFrame = 1,
			nEFrame = 5,
			tValues = {-- 参数列表
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}