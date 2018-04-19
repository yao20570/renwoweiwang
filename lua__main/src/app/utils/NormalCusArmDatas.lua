-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-11 19:42:06 星期二
-- Description: 基本特效数据表
-----------------------------------------------------

tNormalCusArmDatas = {}    			--（table）存放特效表现数据

---------------------↓基地冒泡黄色底图特效（例如 免费加速，满征收）↓---------------------
tNormalCusArmDatas["1"] = 
{
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.17,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/15, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_zjm_ppdh_ll_x_01",
			nSFrame = 1,
			nEFrame = 12,
			tValues = {-- 参数列表
				{1.00, 1.00}, -- 开始, 结束缩放值
				{200, 200}, -- 开始, 结束透明度值
			},
		},
	},
}

tNormalCusArmDatas["2"] = 
{
	nFrame = 15, -- 总帧数
	pos = {1, 1}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.17,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "",
			nSFrame = 1,
			nEFrame = 6,
			tValues = {-- 参数列表
				{1.02, 0.97}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "",
			nSFrame = 7,
			nEFrame = 12,
			tValues = {-- 参数列表
				{0.97, 1.02}, -- 开始, 结束缩放值
				{255, 255}, -- 开始, 结束透明度值
			},
		},
	},
}
tNormalCusArmDatas["3"] = 
{
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.17,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "",
			nSFrame = 1,
			nEFrame = 6,
			tValues = {-- 参数列表
				{1.02, 0.97}, -- 开始, 结束缩放值
				{25, 70}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "",
			nSFrame = 7,
			nEFrame = 12,
			tValues = {-- 参数列表
				{0.97, 1.02}, -- 开始, 结束缩放值
				{70, 25}, -- 开始, 结束透明度值
			},
		},
	},
}
tNormalCusArmDatas["4"] = 
{
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.17,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧（序列帧）
			sImgName = "sg_zjm_ppdh_ll_",
			nSFrame = 1,
			nEFrame = 12,
			tValues = nil,-- 参数列表
		},
	},
}
---------------------↑基地冒泡黄色底图特效（例如 免费加速，满征收）↑---------------------

---------------------↓按钮特效（例如 领取）↓---------------------
tNormalCusArmDatas["5"] = 
{
	nFrame = 12, -- 总帧数
	pos = {-2, 2}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧（序列帧）
			sImgName = "sg_jmtx_re_jxan_",
			nSFrame = 1,
			nEFrame = 12,
			tValues = nil,-- 参数列表
		},
	},
}
---------------------↑按钮特效（例如 领取）↑---------------------

--守军提升特效
tNormalCusArmDatas["7"]  = 
{
        sPlist = "tx/other/sg_tx_jmtx_smjsj",
        nImgType = 1,
		nFrame = 18, -- 总帧数
		x = 0, -- 初始时相对中心锚点的x偏移值
		y = 20, -- 初始时相对中心锚点的y偏移值
		fScale = 1.5,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
        nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "sg_tx_jmtx_smjsj_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 18, -- 结束帧下标
				nSValue = nil,
				nSValue2 = nil,
				nEValue = nil,
				nEValue2 = nil,
			},
		},
}

---------------------↓建筑解锁光晕效果↓---------------------
tNormalCusArmDatas["8"] = 
{
	nFrame = 45, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间
	tActions = {
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_guqt__2_sa1_003",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{0.78, 1.50}, -- 开始, 结束缩放值
				{0, 100}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 渐隐（透明度）
			sImgName = "sg_guqt__2_sa1_003",
			nSFrame = 21,
			nEFrame = 45,
			tValues = {-- 参数列表
				{1.50, 2.46}, -- 开始, 结束缩放值
				{100, 0}, -- 开始, 结束透明度值
			},
		},
	},
}
---------------------↑建筑解锁光晕效果↑---------------------

---------------------↓主界面火焰↓---------------------
tNormalCusArmDatas["9"]  = 
{
	nFrame = 16, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_ldhy_zjm_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["9_1"]  = 
{
	nFrame = 16, -- 总帧数
	pos = {1182, 1506}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_ldhy_yh_zjm_01",
			nSFrame = 1,
			nEFrame = 16,
			tValues = {-- 参数列表
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}
tNormalCusArmDatas["9_2"]  = 
{
	nFrame = 16, -- 总帧数
	pos = {1176, 1537}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_ldhy_zjm_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["9_3"]  = 
{
	nFrame = 16, -- 总帧数
	pos = {1023, 1457}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_ldhy_zjm_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑主界面火焰↑---------------------

---------------------↓主界面瀑布↓---------------------
tNormalCusArmDatas["10_1"]  = 
{
	nFrame = 12, -- 总帧数
	pos = {2678, 1293}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_pb_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["10_2"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {3556, 864}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_pb_y_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["10_3"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {3925, 456}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_pb_z_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["10_4"]  = 
{
	nFrame = 13, -- 总帧数
	pos = {3920, 651}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_pubu_sx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑主界面瀑布↑---------------------

---------------------↓主界水↓---------------------
tNormalCusArmDatas["11_1"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {2198, 1491}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.43,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_dcj_ditu_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["11_2"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {2496, 936}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.43,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_dcj_ditu_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["11_3"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {1518, 429}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.43,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_dcj_ditu_i_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["11_4"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {550, 215}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.43,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_dcj_ditu_g_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["11_5"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {3212, 931}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.43,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_dcj_ditu_p_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["11_6"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {3755, 404}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.43,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_dcj_ditu_d_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["11_7"]  = 
{
	nFrame = 25, -- 总帧数
	pos = {2919, 95}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.43,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_dcj_ditu_k_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑主界水↑---------------------
---------------------↓获得物品刷刷刷特效↓---------------------
tNormalCusArmDatas["12_1"]  = 
{
    sPlist = "tx/world/sg_jmtx_hdwpdh",
    nImgType = 1,
	nFrame = 14, -- 总帧数
	pos = {0, 40}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_jmtx_hdwpdh_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 14, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["12_2"]  = 
{
	nFrame = 15, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 8, -- 移动+透明度
			sImgName = "sg_jmtx_hdwpdh_gy_001",
			nSFrame = 1,
			nEFrame = 4,
			tValues = {-- 参数列表
				{0, 19}, -- 移动前坐标
				{0, 34}, -- 移动后坐标
				{100, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透明度
			sImgName = "sg_jmtx_hdwpdh_gy_001",
			nSFrame = 5,
			nEFrame = 9,
			tValues = {-- 参数列表
				{0, 39}, -- 移动前坐标
				{0, 60}, -- 移动后坐标
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透明度
			sImgName = "sg_jmtx_hdwpdh_gy_001",
			nSFrame = 10,
			nEFrame = 15,
			tValues = {-- 参数列表
				{0, 64}, -- 移动前坐标
				{0, 86}, -- 移动后坐标
				{212, 0}, -- 开始, 结束透明度值
			},
		},
	},
}
---------------------↑获得物品刷刷刷特效↑---------------------
---------------------↓工坊建筑特效↓---------------------
tNormalCusArmDatas["13_1"]  = 
{
	nFrame = 19, -- 总帧数
	pos = {30, 132}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jztx_yw_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["13_2"]  = 
{
--    sPlist = "tx/world/sg_zjm_gf_jzd",
--    nImgType = 1,
	nFrame = 12, -- 总帧数
	pos = {-23, 21}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_gf_jzdhfc_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["13_3"]  = 
{
--    sPlist = "tx/world/sg_zjm_gf_jzd",
--    nImgType = 1,
	nFrame = 12, -- 总帧数
	pos = {16, -68}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_gf_jzdhxfc_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["13_4"]  = 
{
--    sPlist = "tx/world/sg_zjm_gf_jzd",
--    nImgType = 1,
	nFrame = 36, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 4, -- 移动
			sImgName = "sg_zjm_gf_jzd_0hxfc_12",
			nSFrame = 1,
			nEFrame = 18,
			tValues = {-- 参数列表
				{111, 24}, -- 移动前坐标
				{111, 18}, -- 移动后坐标
			},
		},
		{
			nType = 4, -- 移动
			sImgName = "sg_zjm_gf_jzd_0hxfc_12",
			nSFrame = 19,
			nEFrame = 36,
			tValues = {-- 参数列表
				{111, 18}, -- 移动前坐标
				{111, 24}, -- 移动后坐标
			},
		},
	},
}
---------------------↑工坊建筑特效↑---------------------
---------------------↓铁匠铺建筑特效↓---------------------
tNormalCusArmDatas["14_1"]  = 
{
	nFrame = 19, -- 总帧数
	pos = {-14, 75}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.8,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jztx_yw_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["14_2"]  = 
{
	nFrame = 19, -- 总帧数
	pos = {63, 114}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.8,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jztx_yw_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["14_3"]  = 
{
	nFrame = 24, -- 总帧数
	pos = {54, -97}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.65,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jztx_hy_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["14_4"]  = 
{
	nFrame = 24, -- 总帧数
	pos = {163, -43}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.65,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jztx_hy_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

tNormalCusArmDatas["14_5"]  = 
{
    sPlist = "tx/world/sg_zjm_tjp",
    nImgType = 1,
	nFrame = 12, -- 总帧数
	pos = {14, -28}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_tjp1_jzdhxfc_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["14_6"]  = 
{
    sPlist = "tx/world/sg_zjm_tjp",
    nImgType = 1,
	nFrame = 12, -- 总帧数
	pos = {145, -61}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_tjp2_jzdhxfc_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

---------------------↑铁匠铺建筑特效↑---------------------
---------------------↓农场瀑布特效↓---------------------
tNormalCusArmDatas["15"]  = 
{
	nFrame = 12, -- 总帧数
	pos = {28, 16}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jzdh_nc_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑农场瀑布特效↑---------------------
---------------------↓将军府特效↓---------------------
tNormalCusArmDatas["16_1"]  = 
{
    sPlist = "tx/world/sg_zjm_jzdh_jjf",
    nImgType = 1,
	nFrame = 12, -- 总帧数
	pos = {26, 47}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jzdh_jjf_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["16_2"]  = 
{
	nFrame = 24, -- 总帧数
	pos = {42, -57}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jztx_hy_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["16_3"]  = 
{
	nFrame = 24, -- 总帧数
	pos = {101, -28}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jztx_hy_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑将军府特效↑---------------------

---------------------↓科学院特效↓---------------------
tNormalCusArmDatas["17_1"]  = 
{
	nFrame = 26, -- 总帧数
	pos = {-26, 16}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_kjy_h_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 26, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["17_2"]  = 
{
	nFrame = 26, -- 总帧数
	pos = {70, -28}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_kjy_h_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 26, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--主界面科技院动画
tNormalCusArmDatas["17_3"] = {
	nFrame = 50, -- 总帧数
	pos = {69, 69}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_jztx_zjm_kjy_s_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 50, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

tNormalCusArmDatas["17_4"]  = 
{
	nFrame = 40, -- 总帧数
	pos = {67, 65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_zjm_kjy_g_002",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{255, 150}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_zjm_kjy_g_002",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{150, 255}, -- 开始, 结束透明度值
			},
		},
	},
}

tNormalCusArmDatas["17_5"]  = 
{
	nFrame = 26, -- 总帧数
	pos = {166, 10}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_kjy_h_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 26, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


tNormalCusArmDatas["17_6"]  = 
{
	nFrame = 40, -- 总帧数
	pos = {67, 65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_zjm_kjy_g_001",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{150, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_zjm_kjy_g_001",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{255, 150}, -- 开始, 结束透明度值
			},
		},
	},
}
---------------------↑科学院特效↑---------------------
---------------------↓步兵营特效↓---------------------
tNormalCusArmDatas["18_1"] = 
{
	nFrame = 32, -- 总帧数
	pos = {62, -45}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_bbgjdj_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 32, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["18_2"] = 
{
	nFrame = 17, -- 总帧数
	pos = {52, -56}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 17, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["18_3"] = 
{
	nFrame = 19, -- 总帧数
	pos = {52, -56}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_gj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["18_4"] = 
{
	nFrame = 21, -- 总帧数
	pos = {52, -56}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_gj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 21, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["18_5"] = 
{
	nFrame = 19, -- 总帧数
	pos = {52, -56}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_gj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["18_6"] = 
{
	nFrame = 20, -- 总帧数
	pos = {52, -56}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["18_7"] = 
{
	nFrame = 20, -- 总帧数
	pos = {52, -56}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "zd_bb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

tNormalCusArmDatas["19_1"] = 
{
	nFrame = 17, -- 总帧数
	pos = {72, -44}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
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
tNormalCusArmDatas["19_2"] = 
{
	nFrame = 20, -- 总帧数
	pos = {72, -44}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
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
tNormalCusArmDatas["19_3"] = 
{
	nFrame = 19, -- 总帧数
	pos = {72, -44}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
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
tNormalCusArmDatas["19_4"] = 
{
	nFrame = 20, -- 总帧数
	pos = {72, -44}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
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
tNormalCusArmDatas["19_5"] = 
{
	nFrame = 20, -- 总帧数
	pos = {72, -44}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
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
tNormalCusArmDatas["19_6"] = 
{
	nFrame = 20, -- 总帧数
	pos = {72, -44}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
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
tNormalCusArmDatas["19_7"] = 
{
	nFrame = 20, -- 总帧数
	pos = {72, -44}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
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
---------------------↑步兵营特效↑---------------------
---------------------↓弓兵营特效↓---------------------
tNormalCusArmDatas["20_1"] = 
{
	nFrame = 24, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_2"] = 
{
	nFrame = 22, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_b_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 22, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_3"] = 
{
	nFrame = 16, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_a_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_4"] = 
{
	nFrame = 20, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_5"] = 
{
	nFrame = 24, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_6"] = 
{
	nFrame = 16, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_a_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_7"] = 
{
	nFrame = 20, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_8"] = 
{
	nFrame = 20, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["20_9"] = 
{
	nFrame = 4, -- 总帧数
	pos = {41, -52}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jzdh_gby_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 4, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


tNormalCusArmDatas["21_1"] = 
{
	nFrame = 16, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_a_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_2"] = 
{
	nFrame = 20, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_3"] = 
{
	nFrame = 24, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_4"] = 
{
	nFrame = 16, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_a_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_5"] = 
{
	nFrame = 20, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_6"] = 
{
	nFrame = 20, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_7"] = 
{
	nFrame = 24, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_8"] = 
{
	nFrame = 22, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_b_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 22, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["21_9"] = 
{
	nFrame = 4, -- 总帧数
	pos = {54, -58}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jzdh_gby_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 4, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

tNormalCusArmDatas["22_1"] = 
{
	nFrame = 24, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_2"] = 
{
	nFrame = 16, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_a_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_3"] = 
{
	nFrame = 20, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_4"] = 
{
	nFrame = 20, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_5"] = 
{
	nFrame = 24, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_b_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 24, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_6"] = 
{
	nFrame = 22, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_b_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 22, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_7"] = 
{
	nFrame = 16, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_gj_a_01_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_8"] = 
{
	nFrame = 20, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "gb_x_dj_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["22_9"] = 
{
	nFrame = 4, -- 总帧数
	pos = {65, -65}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_jzdh_gby_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 4, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑弓兵营特效↑---------------------
---------------------↓骑兵营特效↓---------------------
tNormalCusArmDatas["23"] = 
{
	nFrame = 29, -- 总帧数
	pos = {63, -51}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_qby_qbhd_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 29, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑骑兵营特效↑---------------------
---------------------↓水车特效↓---------------------
tNormalCusArmDatas["24"] = 
{
	nFrame = 13, -- 总帧数
	pos = {3478, 890}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_shuiche_dh_q1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 13, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑水车特效↑---------------------
---------------------↓基地旗帜特效↓---------------------
tNormalCusArmDatas["25_1"] = 
{
	nFrame = 11, -- 总帧数
	pos = {863, 1433}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_qizi_dh_q1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["25_2"] = 
{
	nFrame = 11, -- 总帧数
	pos = {1116, 1559}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_qizi_dh_q1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["25_3"] = 
{
	nFrame = 11, -- 总帧数
	pos = {815, 1456}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_qizi_dh_q1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["25_4"] = 
{
	nFrame = 11, -- 总帧数
	pos = {1068, 1581}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_qizi_dh_q1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["25_5"] = 
{
	nFrame = 11, -- 总帧数
	pos = {904, 1411}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_qizi_dh_q1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["25_6"] = 
{
	nFrame = 11, -- 总帧数
	pos = {1157, 1536}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_qizi_dh_q1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 11, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑基地旗帜特效↑---------------------

---------------------↓战斗结果特效↓---------------------
-- 链接龙骨的红色字体呼吸效果。（循环播放）

-- tNormalCusArmDatas["24_1"]  = {
-- 	nFrame = 60, -- 总帧数
-- 	pos = {-131, 296}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 1, -- 需要加亮
--     nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		{
-- 			nType = 2, -- 透明度
-- 			sImgName = "sg_zdsl_js_sl_s2g_001",
-- 			nSFrame = 1,
-- 			nEFrame = 30,
-- 			tValues = {-- 参数列表
-- 				{20, 125}, -- 开始, 结束透明度值
-- 			}, 
-- 		},
-- 		{
-- 			nType = 2, -- 透明度
-- 			sImgName = "sg_zdsl_js_sl_s2g_001",
-- 			nSFrame = 31,
-- 			nEFrame = 60,
-- 			tValues = {-- 参数列表
-- 				{125, 20}, -- 开始, 结束透明度值
-- 			},
-- 		},
-- 	},
-- }



-- tNormalCusArmDatas["24_2"]  = {
-- 	nFrame = 60, -- 总帧数
-- 	pos = {134, 296}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 1, -- 需要加亮
--     nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		{
-- 			nType = 2, -- 透明度
-- 			sImgName = "sg_zdsl_js_sl_s2g_002",
-- 			nSFrame = 1,
-- 			nEFrame = 30,
-- 			tValues = {-- 参数列表
-- 				{20, 125}, -- 开始, 结束透明度值
-- 			}, 
-- 		},
-- 		{
-- 			nType = 2, -- 透明度
-- 			sImgName = "sg_zdsl_js_sl_s2g_002",
-- 			nSFrame = 31,
-- 			nEFrame = 60,
-- 			tValues = {-- 参数列表
-- 				{125, 20}, -- 开始, 结束透明度值
-- 			},
-- 		},
-- 	},
-- }

-- 扫光动画 “龙头扫光动画 1”“龙头扫光动画 2”需要等星星全部播放完毕，才同时播放出来。  “胜利扫光”需要“龙头扫光动画 1”播放完，才播放“胜利扫光”。

-- （每个7秒播放一次）



-- 龙头扫光动画 1


tNormalCusArmDatas["24_3"]  = {
    sPlist = "tx/world/sg_zdsl_js_sl",
    nImgType = 1,
	nFrame = 19, -- 总帧数
	pos = {250, 293}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.3,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zdsl_lg_sg_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}



-- 龙头扫光动画 2（这个需要将序列帧动画翻转过来）


tNormalCusArmDatas["24_4"]  = {
    sPlist = "tx/world/sg_zdsl_js_sl",
    nImgType = 1,
	nFrame = 19, -- 总帧数
	pos = {-246, 294}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.3,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zdsl_lg_sg_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}




-- -- 胜利扫光

-- -- 需要等待龙头扫光动画1播放结束，才开始播放


tNormalCusArmDatas["24_5"]  = {
    sPlist = "tx/world/sg_zdsl_js_sl",
    nImgType = 1,
	nFrame = 20, -- 总帧数
	pos = {-1, 289}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.3,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zdsl_js_sl_sg_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

---------------------↓战斗结果特效↓---------------------

---------------------↓icon品质特效↓---------------------
tNormalCusArmDatas["26"] = 
{
	-- nFrame = 12, -- 总帧数
	-- x = -2, -- 初始时相对中心锚点的x偏移值
	-- y = -2, -- 初始时相对中心锚点的y偏移值
	-- fScale = 1.68,-- 初始的缩放值
	-- nBlend = 1, -- 需要加亮
 --    nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	-- tActions = {
	-- 	 {
	-- 		nType = 1, -- 序列帧播放
	-- 		sImgName = "sg_jm_gqr_",
	-- 		nSFrame = 1, -- 开始帧下标
	-- 		nEFrame = 12, -- 结束帧下标
	-- 		nSValue = nil,
	-- 		nSValue2 = nil,
	-- 		nEValue = nil,
	-- 		nEValue2 = nil,
	-- 	},
	-- },
    sPlist = "tx/world/p1_tx_gqr",
    nImgType = 1,
	nFrame = 12, -- 总帧数
	x = 0, -- 初始时相对中心锚点的x偏移值
	y = -1, -- 初始时相对中心锚点的y偏移值
	fScale = 1.68,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/18, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_jm_gqr_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			nSValue = nil,
			nSValue2 = nil,
			nEValue = nil,
			nEValue2 = nil,
		},
	},
}
---------------------↑icon品质特效↑---------------------
---------------------↓loading特效↓---------------------
tNormalCusArmDatas["27_1"] = 
{
	nFrame = 60, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_01",
			nSFrame = 1,
			nEFrame = 60,
			tValues = {-- 参数列表
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}
tNormalCusArmDatas["27_2"] = 
{
	nFrame = 60, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 6, -- 旋转
			sImgName = "sg_loading_x_02",
			nSFrame = 1,
			nEFrame = 60,
			tValues = {-- 参数列表
				{0, 360}, -- 开始, 结束旋转角度值
			},
		},
	},
}
tNormalCusArmDatas["27_3"] = 
{
	nFrame = 60, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_04",
			nSFrame = 1,
			nEFrame = 15,
			tValues = {-- 参数列表
				{255, 127}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_04",
			nSFrame = 16,
			nEFrame = 30,
			tValues = {-- 参数列表
				{127, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_04",
			nSFrame = 31,
			nEFrame = 45,
			tValues = {-- 参数列表
				{255, 127}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_04",
			nSFrame = 46,
			nEFrame = 60,
			tValues = {-- 参数列表
				{127, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}
tNormalCusArmDatas["27_4"] = 
{
	nFrame = 60, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_01",
			nSFrame = 1,
			nEFrame = 60,
			tValues = {-- 参数列表
				{127, 127}, -- 开始, 结束透明度值
			},
		},
	},
}
tNormalCusArmDatas["27_5"] = 
{
	nFrame = 60, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_03",
			nSFrame = 1,
			nEFrame = 60,
			tValues = {-- 参数列表
				{255, 255}, -- 开始, 结束透明度值
			},
		},
	},
}

--第一层：序列帧动画（自循环）
tNormalCusArmDatas["loading_1"] = 
{
	nFrame = 45, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_01",
			nSFrame = 1,
			nEFrame = 45,
			tValues = {-- 参数列表
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

tNormalCusArmDatas["loading_2"] = 
{
	nFrame = 45, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 6, -- 旋转
			sImgName = "sg_loading_x_02",
			nSFrame = 1,
			nEFrame = 45,
			tValues = {-- 参数列表
				{0, 360}, -- 开始, 结束旋转角度值
			},
		},
	},
}

--第二层：序列帧动画（自循环）
tNormalCusArmDatas["loading_3"] = 
{
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/15, -- 每帧播放时间（15帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_loadingfa_x_",
			nSFrame = 1, -- 开始帧下标	
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--第三层：顶部光晕（自循环）
tNormalCusArmDatas["loading_4"] = 
{
	nFrame = 36, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_04",
			nSFrame = 1,
			nEFrame = 18,
			tValues = {-- 参数列表
				{255, 127}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_loading_x_04",
			nSFrame = 19,
			nEFrame = 36,
			tValues = {-- 参数列表
				{127, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

---------------------↑loading特效↑---------------------

---------------------↑进度条特效↑---------------------
tNormalCusArmDatas["progress_1"] = {
    nFrame = 30, -- 总帧数
    pos = {-36, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
    fScale = 1,-- 初始的缩放值
    nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（30帧每秒）
    tActions = {
        {
            nType = 5, -- 透明度
            sImgName = "sg_jdt_tjp_tptmd_02",
            nSFrame = 1,
            nEFrame = 30,
            tValues = {-- 参数列表
                {1, 1}, -- 开始, 结束透明度值
                {255, 255},
            }, 
        },	           
    },
}
tNormalCusArmDatas["progress_2"] = {
    nFrame = 30, -- 总帧数
    pos = {-30, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
    fScale = 1,-- 初始的缩放值
    nBlend = 1, -- 需要加亮
    nPerFrameTime = 1/24, -- 每帧播放时间（30帧每秒）
    tActions = {
        {
            nType = 5, -- 透明度
            sImgName = "sg_jdt_tjp_tptmd_01",
            nSFrame = 1,
            nEFrame = 15,
            tValues = {-- 参数列表
                {1.0, 1.0}, -- 开始, 结束缩放值
				{255, 150}, -- 开始, 结束透明度值
            }, 
        },
        {
            nType = 5, -- 透明度
            sImgName = "sg_jdt_tjp_tptmd_01",
            nSFrame = 16,
            nEFrame = 30,
            tValues = {-- 参数列表
				{1.0, 1.0}, -- 开始, 结束缩放值
				{150, 255}, -- 开始, 结束透明度值
            },
        },
    },
}

---------------------↑进度条特效↑---------------------
---------------------↑基地水龙头特效↑---------------------
tNormalCusArmDatas["28_1"] = {
    nFrame = 25, -- 总帧数
	pos = {1073, 1278}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lxs_zjm_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["28_2"] = {
    nFrame = 25, -- 总帧数
	pos = {1443, 1228}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lxs_zjm035_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["28_4"] = {
    nFrame = 25, -- 总帧数
	pos = {1324, 1309}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lxs_zjm03_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
tNormalCusArmDatas["28_3"] = {
    nFrame = 25, -- 总帧数
	pos = {1217, 1392}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_lxs_zjm0301_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 25, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑基地水龙头特效↑---------------------
---------------------↑基地巡逻兵特效↑---------------------
--右下到左上 y++
tNormalCusArmDatas["29_1"] = {
  	nFrame = 20, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/20, -- 每帧播放时间（20帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_xs_sw_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--左上到右下 y--
tNormalCusArmDatas["29_2"] = {
   	nFrame = 20, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/20, -- 每帧播放时间（20帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_sx_sw_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 20, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

---------------------↓守门侍卫特效↓-------------------
--守卫1
tNormalCusArmDatas["29_3"] = {
   	nFrame = 18, -- 总帧数
	pos = {1792 + 2, 875 + 7}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_qbx_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--守卫2
tNormalCusArmDatas["29_4"] = {
   	nFrame = 18, -- 总帧数
	pos = {2275, 1372}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_qbx_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--守卫3
tNormalCusArmDatas["29_5"] = {
   nFrame = 18, -- 总帧数
	pos = {1499, 1111}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_qbx_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--守卫4
tNormalCusArmDatas["29_6"] = {
   	nFrame = 18, -- 总帧数
	pos = {1872 - 8, 912 }, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_qbx_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--守卫5
tNormalCusArmDatas["29_7"] = {
   	nFrame = 18, -- 总帧数
	pos = {2184, 1328}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_qbx_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--守卫6
tNormalCusArmDatas["29_8"] = {
   nFrame = 18, -- 总帧数
	pos = {1390, 1057}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xlb_qbx_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 18, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

---------------------↑守门侍卫特效↑---------------------
---------------------↑基地巡逻兵特效↑---------------------
---------------------↑乌云特效↑---------------------
tNormalCusArmDatas["30_1"] = {
    nFrame = 200, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2.8,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 8, -- 移动+透明度
			sImgName = "ui/sg_heiyun_sa_zjm_001",
			nSFrame = 1,
			nEFrame = 24,
			tValues = {-- 参数列表
				{0, 0}, -- 移动前坐标
				{40, 3}, -- 移动后坐标
				{0, 55}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "ui/sg_heiyun_sa_zjm_001",
			nSFrame = 25,
			nEFrame = 155,
			tValues = {-- 参数列表
				{40, 3}, -- 移动前坐标
				{210, 13}, -- 移动后坐标
				{55, 55}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "ui/sg_heiyun_sa_zjm_001",
			nSFrame = 156,
			nEFrame = 200,
			tValues = {-- 参数列表
				{210, 13}, -- 移动前坐标
				{310, 18}, -- 移动后坐标
				{55, 0}, -- 开始, 结束透明度值
			},
		},


	},
}
tNormalCusArmDatas["30_2"] = {
    nFrame = 200, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	fScaleX = -2.2,
	fScaleY = 2.2,
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 8, -- 移动+透明度
			sImgName = "ui/sg_heiyun_sa_zjm_001",
			nSFrame = 1,
			nEFrame = 24,
			tValues = {-- 参数列表
				{0, 0}, -- 移动前坐标
				{40, 3}, -- 移动后坐标
				{0, 55}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "ui/sg_heiyun_sa_zjm_001",
			nSFrame = 25,
			nEFrame = 155,
			tValues = {-- 参数列表
				{40, 3}, -- 移动前坐标
				{210, 13}, -- 移动后坐标
				{55, 55}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "ui/sg_heiyun_sa_zjm_001",
			nSFrame = 156,
			nEFrame = 200,
			tValues = {-- 参数列表
				{210, 13}, -- 移动前坐标
				{310, 18}, -- 移动后坐标
				{55, 0}, -- 开始, 结束透明度值
			},
		},
	},
}
---------------------↑乌云特效↑---------------------
---------------------↑基地鱼特效↑---------------------
tNormalCusArmDatas["31"] = {
    nFrame = 63, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_yqdh_zjm_cj_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 63, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑基地鱼特效↑---------------------

----------------↑主界面任务按钮上的呼吸灯效果↑---------------
tNormalCusArmDatas["40"] =  {
	nFrame = 40, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/40, -- 每帧播放时间（40帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_rwanhxdgx_zjm_001",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{255, 125}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_rwanhxdgx_zjm_001",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{125, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}
----------------↑主界面任务按钮上的呼吸灯效果↑---------------

--------------------↓主界面丹顶鹤特效↓-------------------------

--丹顶鹤下飞上
tNormalCusArmDatas["41_1"] = {
	nFrame = 26, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_ddh_xfs_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 26, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--丹顶鹤上飞下
tNormalCusArmDatas["41_2"] = {
	nFrame = 26, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_ddh_sfx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 26, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


--------------------↑主界面丹顶鹤特效↑-------------------------

--------------------↓主界面白鹭特效↓-------------------------
--白鹭下飞上
tNormalCusArmDatas["42_1"] = {
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_blsqt_xfs_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--白鹭上飞下
tNormalCusArmDatas["42_2"] = {
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_zjm_blsqt_sfx_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


--------------------↑主界面白鹭特效↑-------------------------

--------------------↑副本新关卡提醒特效↑-------------------------

--第6个位置的提醒
tNormalCusArmDatas["43"] = {
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_fbtxtx_s_sda_003",
			nSFrame = 1,
			nEFrame = 15,
			tValues = {-- 参数列表
				{0.6, 0.9}, -- 开始, 结束缩放值
				{0, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_fbtxtx_s_sda_003",
			nSFrame = 16,
			nEFrame = 30,
			tValues = {-- 参数列表
				{0.95, 1.3}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}

tNormalCusArmDatas["43_1"] = {
	nFrame = 40, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "v1_img_touying_fb.png",
			nSFrame = 1,
			nEFrame = 40,
			tValues = {-- 参数列表
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

tNormalCusArmDatas["43_2"] = {
	nFrame = 40, -- 总帧数
	pos = {0, 53}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.5,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_004",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{255, 150}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_004",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{150, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

tNormalCusArmDatas["43_3"]  =  
{
	nFrame = 40, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.7,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_003",
			nSFrame = 1,
			nEFrame = 40,
			tValues = {-- 参数列表
				{150, 150}, -- 开始, 结束透明度值
			}, 
		},
	},
}

-- tNormalCusArmDatas["43_4"]  =  
-- {
-- 	nFrame = 40, -- 总帧数
-- 	pos = {0, 60}, -- 特效的x,y轴位置（相对中心锚点的偏移）
-- 	fScale = 1,-- 初始的缩放值
-- 	nBlend = 0, -- 需要加亮
--   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
-- 	tActions = {
-- 		{
-- 			nType = 2, -- 透明度
-- 			sImgName = "v1_img_zjgqzd",
-- 			nSFrame = 1,
-- 			nEFrame = 20,
-- 			tValues = {-- 参数列表
-- 				{255, 255}, -- 开始, 结束透明度值
-- 			}, 
-- 		},
-- 		{
-- 			nType = 2, -- 透明度
-- 			sImgName = "v1_img_zjgqzd",
-- 			nSFrame = 21,
-- 			nEFrame = 40,
-- 			tValues = {-- 参数列表
-- 				{255, 255}, -- 开始, 结束透明度值
-- 			}, 
-- 		},
-- 	},
-- }

tNormalCusArmDatas["43_5"]  =  
{
	nFrame = 40, -- 总帧数
	pos = {0, 76}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "v2_img_jingyingguanqia",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{0, 100}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "v2_img_jingyingguanqia",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{100, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}

tNormalCusArmDatas["43_6"]  =  
{
	nFrame = 40, -- 总帧数
	pos = {0, 66}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_001",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{255, 150}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_001",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{150, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

--第1-5个位置的提醒
tNormalCusArmDatas["44"]  = 
{
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_fbtxtx_s_sda_003",
			nSFrame = 1,
			nEFrame = 15,
			tValues = {-- 参数列表
				{0.54, 0.73}, -- 开始, 结束缩放值
				{0, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_fbtxtx_s_sda_003",
			nSFrame = 16,
			nEFrame = 30,
			tValues = {-- 参数列表
				{0.73, 0.92}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}

tNormalCusArmDatas["44_1"]  =  
{
	nFrame = 40, -- 总帧数
	pos = {0, -1}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.9,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "v1_img_touying_fb",
			nSFrame = 1,
			nEFrame = 40,
			tValues = {-- 参数列表
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

tNormalCusArmDatas["44_2"]  =  
{
	nFrame = 40, -- 总帧数
	pos = {-2, 49}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.2,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_004",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{255, 150}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_004",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{150, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

tNormalCusArmDatas["44_3"]  =  
{
	nFrame = 40, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.5,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_003",
			nSFrame = 1,
			nEFrame = 40,
			tValues = {-- 参数列表
				{150, 150}, -- 开始, 结束透明度值
			}, 
		},
	},
}


tNormalCusArmDatas["44_4"]  =  
{
	nFrame = 40, -- 总帧数
	pos = {0, 55}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 0.75,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_001",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{255, 150}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "sg_fbtxtx_s_sda_001",
			nSFrame = 21,
			nEFrame = 40,
			tValues = {-- 参数列表
				{150, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

--------------------↑副本新关卡提醒特效↑-------------------------
--------------------↓主界面鱼群特效↓-------------------------
--白鱼跳
tNormalCusArmDatas["45_1"] = {
	nFrame = 27, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_smby_taoyue_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 27, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--红鱼跳
tNormalCusArmDatas["45_2"] = {
	nFrame = 27, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_smhy_taoyue_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 27, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--白色游鱼
tNormalCusArmDatas["45_3"] = {
	nFrame = 98, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hyyd_sz1_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 98, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
--------------------↑主界面鱼群特效↑-------------------------


--------------------↓主界面白云特效↓-------------------------
--第一层 云：
tNormalCusArmDatas["46_1"] = {
	nFrame = 2484, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 8, -- 移动+透明度
			sImgName = "sg_zjm_yun_x_l_03",
			nSFrame = 1,
			nEFrame = 552,
			tValues = {-- 参数列表
				{0, 0}, -- 移动前坐标
				{520, 0}, -- 移动后坐标
				{0, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_03",
			nSFrame = 553,
			nEFrame = 1932,
			tValues = {-- 参数列表
				{520, 0}, -- 移动前坐标
				{1830, 0}, -- 移动后坐标
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_03",
			nSFrame = 1933,
			nEFrame = 2484,
			tValues = {-- 参数列表
				{1830, 0}, -- 移动前坐标
				{2355, 0}, -- 移动后坐标
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}


tNormalCusArmDatas["46_2"] = {
	nFrame = 2160, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 8, -- 移动+透明度
			sImgName = "sg_zjm_yun_x_l_04",
			nSFrame = 1,
			nEFrame = 480,
			tValues = {-- 参数列表
				{0, 0}, -- 移动前坐标
				{520, 0}, -- 移动后坐标
				{0, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_04",
			nSFrame = 481,
			nEFrame = 1680,
			tValues = {-- 参数列表
				{520, 0}, -- 移动前坐标
				{1830, 0}, -- 移动后坐标
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_04",
			nSFrame = 1681,
			nEFrame = 2160,
			tValues = {-- 参数列表
				{1830, 0}, -- 移动前坐标
				{2355, 0}, -- 移动后坐标
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}


tNormalCusArmDatas["46_3"] = {
	nFrame = 2700, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 8, -- 移动+透明度
			sImgName = "sg_zjm_yun_x_l_05",
			nSFrame = 1,
			nEFrame = 600,
			tValues = {-- 参数列表
				{0, 0}, -- 移动前坐标
				{520, 0}, -- 移动后坐标
				{0, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_05",
			nSFrame = 601,
			nEFrame = 2100,
			tValues = {-- 参数列表
				{520, 0}, -- 移动前坐标
				{1830, 0}, -- 移动后坐标
				{255, 255}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_05",
			nSFrame = 2101,
			nEFrame = 2700,
			tValues = {-- 参数列表
				{1830, 0}, -- 移动前坐标
				{2355, 0}, -- 移动后坐标
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}
--第一层 云影子
tNormalCusArmDatas["46_4"] = {
	nFrame = 2160, -- 总帧数
	pos = {-105, -560}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 10,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 8, -- 移动+透明度
			sImgName = "sg_zjm_yun_x_l_01",
			nSFrame = 1,
			nEFrame = 480,
			tValues = {-- 参数列表
				{0, 0}, -- 移动前坐标
				{520, 0}, -- 移动后坐标
				{0, 30}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_01",
			nSFrame = 481,
			nEFrame = 1680,
			tValues = {-- 参数列表
				{520, 0}, -- 移动前坐标
				{1830, 0}, -- 移动后坐标
				{30, 30}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 8, -- 移动+透p明度
			sImgName = "sg_zjm_yun_x_l_01",
			nSFrame = 1681,
			nEFrame = 2160,
			tValues = {-- 参数列表
				{1830, 0}, -- 移动前坐标
				{2355, 0}, -- 移动后坐标
				{30, 0}, -- 开始, 结束透明度值
			},
		},
	},
}

--------------------↑主界面白云特效↑-------------------------

---------------------世界地图帮助动画--------------------------
tNormalCusArmDatas["47_1"] = {
    sPlist = "tx/other/sg_gj_ts",
    nImgType = 1,
	nFrame = 15, -- 总帧数
	pos = {12, -10}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/36, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 6, -- 旋转
			sImgName = "sg_gj_t0s_01",
			nSFrame = 1,
			nEFrame = 4,
			tValues = {-- 参数列表
				{42, -45}, -- 开始, 结束旋转角度值
			},
		},
		{
			nType = 6, -- 旋转
			sImgName = "sg_gj_t0s_01",
			nSFrame = 5,
			nEFrame = 7,
			tValues = {-- 参数列表
				{-43, -40}, -- 开始, 结束旋转角度值
			},
		},
		{
			nType = 6, -- 旋转
			sImgName = "sg_gj_t0s_01",
			nSFrame = 8,
			nEFrame = 15,
			tValues = {-- 参数列表
				{-29, 42}, -- 开始, 结束旋转角度值
			},
		},
	},
}

tNormalCusArmDatas["47_2"] = {
    sPlist = "tx/other/sg_gj_ts",
    nImgType = 1,
	nFrame = 15, -- 总帧数
	pos = {-12, -10}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
  	nPerFrameTime = 1/36, -- 每帧播放时间（30帧每秒）
	tActions = {
		{
			nType = 6, -- 旋转
			sImgName = "sg_gj_t0s_02",
			nSFrame = 1,
			nEFrame = 4,
			tValues = {-- 参数列表
				{-42, 42}, -- 开始, 结束旋转角度值
			},
		},
		{
			nType = 6, -- 旋转
			sImgName = "sg_gj_t0s_02",
			nSFrame = 5,
			nEFrame = 7,
			tValues = {-- 参数列表
				{40, 36}, -- 开始, 结束旋转角度值
			},
		},
		{
			nType = 6, -- 旋转
			sImgName = "sg_gj_t0s_02",
			nSFrame = 8,
			nEFrame = 15,
			tValues = {-- 参数列表
				{26, -42}, -- 开始, 结束旋转角度值
			},
		},
	},
}

tNormalCusArmDatas["47_3"] = {
    sPlist = "tx/other/sg_gj_ts",
    nImgType = 1,
	nFrame = 15, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/36, -- 每帧播放时间（30帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_gj_ts_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 15, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}
---------------------↑世界地图帮助动画↑-------------------------


---------------------副本抽将动画-------------------------

tNormalCusArmDatas["48"] = {
	nFrame = 30, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/24, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_fkgx_fb_001",
			nSFrame = 1,
			nEFrame = 3,
			tValues = {-- 参数列表
				{1.4, 1.45}, -- 开始, 结束缩放值
				{255, 76}, -- 开始, 结束透明度值
			},
		},
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "sg_fkgx_fb_001",
			nSFrame = 4,
			nEFrame = 18,
			tValues = {-- 参数列表
				{1.46, 1.82}, -- 开始, 结束缩放值
				{75, 0}, -- 开始, 结束透明度值
			},
		},
	},
}

---------------------副本抽将动画-------------------------


---------------------神龙夺宝特效-------------------------

tNormalCusArmDatas["49_1"] = {
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2.2,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "sg_xldb_yw_y_01",
			nSFrame = 1,
			nEFrame = 20,
			tValues = {-- 参数列表
				{255, 255}, -- 开始, 结束透明度值
			}, 
		},
	},
}

tNormalCusArmDatas["49_2"] = {
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2.2,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_xldb_yw_x_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

---------------------神龙夺宝特效-------------------------


---------------------进阶进度条特效-------------------------

tNormalCusArmDatas["50"] = {
    sPlist = "tx/other/sg_wjjj_jdt",
    nImgType = 1,
	nFrame = 6, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_wjjj_jdt_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 6, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


---------------------神龙夺宝特效-------------------------

---------------------头像框特效-------------------------
--头像框i141005专用
tNormalCusArmDatas["51_1"]  =  
{
    sPlist = "tx/other/sg_txk_dh_vip12",
    nImgType = 1,
	nFrame = 12, -- 总帧数
	pos = {0, 21}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.3,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_txk_dh_vip12_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--头像框i141004专用
--左边火焰
tNormalCusArmDatas["51_2"]  =  
{
	nFrame = 16, -- 总帧数
	pos = {-44, -7}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hytx_xk_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--右边火焰
tNormalCusArmDatas["51_3"]  =  
{
	nFrame = 16, -- 总帧数
	pos = {44, -7}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
        fScaleX = -1, 
        fScaleY = 1, 
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/12, -- 每帧播放时间（12帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "sg_hytx_xk_a_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 16, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}


---------------------头像框特效-------------------------


---------------------竞技场特效-------------------------
tNormalCusArmDatas["52"]  = 
{
	nFrame = 12, -- 总帧数
	pos = {103, -27}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（8帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "rwww_jjc_qz_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

---------------------竞技场特效-------------------------

--------------主界面 活动加速按钮 点击反馈效果----------------------
--建筑效果
tNormalCusArmDatas["52_1"]  = 
{
    sPlist = "tx/world/rwww_hddj_fkxg",
    nImgType = 1,
	nFrame = 19, -- 总帧数
	pos = {0, 45}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
   	nPerFrameTime = 1/30, -- 每帧播放时间（20帧每秒）
	tActions = {
		 {
			nType = 1, -- 序列帧播放
			sImgName = "rwww_hddj_fkxg_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 19, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

tNormalCusArmDatas["52_2"]  = 
{
    sPlist = "tx/world/rwww_hddj_fkxg",
    nImgType = 1,
	nFrame = 11, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 2,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/30, -- 每帧播放时间（20帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "rwww_hddj_fkxg_x_001",
			nSFrame = 1,
			nEFrame = 3,
			tValues = {-- 参数列表
				{50, 255}, -- 开始, 结束透明度值
			}, 
		},
		{
			nType = 2, -- 透明度
			sImgName = "rwww_hddj_fkxg_x_001",
			nSFrame = 4,
			nEFrame = 11,
			tValues = {-- 参数列表
				{210, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}
--气泡效果
tNormalCusArmDatas["53_1"] =  {
    sPlist = "tx/world/rwww_hddj_fkxg",
    nImgType = 1,
	nFrame = 14, -- 总帧数
	pos = {0, 6}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.4,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/20, -- 每帧播放时间（20帧每秒）
	tActions = {
		{
			nType = 2, -- 透明度
			sImgName = "rwww_hddj_fkxg_x_002",
			nSFrame = 1,
			nEFrame = 14,
			tValues = {-- 参数列表
				{255, 0}, -- 开始, 结束透明度值
			}, 
		},
	},
}


tNormalCusArmDatas["53_2"] = 
{
    sPlist = "tx/world/rwww_hddj_fkxg",
    nImgType = 1,
	nFrame = 9, -- 总帧数
	pos = {0, 6}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/20, -- 每帧播放时间（20帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "rwww_hddj_fkxg_x_002",
			nSFrame = 1,
			nEFrame = 9,
			tValues = {-- 参数列表
				{1.4, 1.9}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}

--图片特效
tNormalCusArmDatas["54"] = 
{
	nFrame = 9, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1,-- 初始的缩放值
	nBlend = 1, -- 需要加亮
  	nPerFrameTime = 1/20, -- 每帧播放时间（20帧每秒）
	tActions = {
		{
			nType = 5, -- 缩放 + 透明度
			sImgName = "v1_img_zjm_tzqpz",
			nSFrame = 1,
			nEFrame = 6,
			tValues = {-- 参数列表
				{1, 1.35}, -- 开始, 结束缩放值
				{255, 0}, -- 开始, 结束透明度值
			},
		},
	},
}
--------------主界面 活动加速按钮 点击反馈效果----------------------

--------------世界纣王试炼效果----------------------
tNormalCusArmDatas["55"]  = 
{
	nFrame = 12, -- 总帧数
	pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
	fScale = 1.2,-- 初始的缩放值
	nBlend = 0, -- 需要加亮
   	nPerFrameTime = 1/8, -- 每帧播放时间（24帧每秒）
	tActions = {
		{
			nType = 1, -- 序列帧播放
			sImgName = "rwww_zw_dj_dh_",
			nSFrame = 1, -- 开始帧下标
			nEFrame = 12, -- 结束帧下标
			tValues = nil, -- 参数列表
		},
	},
}

--------------世界纣王试炼效果----------------------
