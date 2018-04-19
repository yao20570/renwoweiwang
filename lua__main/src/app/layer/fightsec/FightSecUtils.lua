-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-12 16:36:37 星期二
-- Description: 战斗工具类
-----------------------------------------------------

__fSScale 			 = 			0.66 			 --战斗层初始缩放比例
__fEScale 			 = 			1.00 			 --战斗层最终缩放比例

__nMoveSpeed         = 			150 			 --移动速度
__nMaxShowCt 	     = 			6 				 --最大显示的队列个数

__fightCenterX 		 = 			display.width / 2  --战斗表现层中点X的坐标
__fightCenterY 		 = 			display.height / 2 --战斗表现层中点Y的坐标

__fStartOffsetX 	 = 			413 			 --开始战斗初始化阵容的开始x轴偏移值
__fStartOffsetY 	 = 			202              --开始战斗初始化阵容的开始y轴偏移值

__fFightOffsetX 	 = 			32 				 --混战区终点坐标x轴偏移值
__fFightOffsetY 	 = 			16 				 --混战区终点坐标y轴偏移值

__fStandOffsetX 	 = 			136 		     --待命区终点坐标x轴偏移值
__fStandOffsetY 	 = 			66				 --待命区终点坐标y轴偏移值


__bHasEndCallback 	 = 			false 			 --是否已经结束回调	

__showFightLayer 	 = 			nil 			 --展示战斗表现的层
__nFightLayerTopH 	 = 			nil 			 --战斗界面顶层高度



--获得用来战斗的武将数据
function __getHeroInfoForFightById( _hid , _hs)
	-- body
	local tHeroInfo = getGoodsByTidFromDB(_hid)
	if tHeroInfo then
		if tHeroInfo.nGtype ~= e_type_goods.type_hero and tHeroInfo.nGtype ~= e_type_goods.type_npc then
			tHeroInfo = nil
		end
		if _hs then
			tHeroInfo.nIg= _hs.ig
		end
	end
	return tHeroInfo
end

-- 移动到某一个位置
function __moveToPos( _pView, _tPos, _handler )

	if not _pView or not _tPos or not _handler then
		print("__moveToPos is nil")
		return
	end
	--计算距离
	local nDis =  math.sqrt((_tPos.x - _pView:getPositionX())
							* (_tPos.x - _pView:getPositionX()) 
							+ (_tPos.y - _pView:getPositionY()) 
							* (_tPos.y - _pView:getPositionY()))
	if nDis <= 0 then
		return false
	end
	--计算时间
	local tTime = nDis / __nMoveSpeed
	--移动
	local actionMoveTo = cc.MoveTo:create(tTime, _tPos)
	--回调
	local fCallback = cc.CallFunc:create(_handler)
	local actions = cc.Sequence:create(actionMoveTo,fCallback)
	_pView:runAction(actions)
	return true
end

-- Boss从上到下出现
function __tlBossUpAndDownToPos( _pView, _tPos, _handler )
	if not _pView or not _tPos or not _handler then
		print("__tlBossUpAndDownToPos is nil")
		return
	end
	doDelayForSomething(_pView, function (  )
        --隐藏之前的
		_pView:setVisible(false)
		__upAndDownToPos(_pView, _tPos, _handler)
    end, 1 )
end

function __upAndDownToPos( _pView, _tPos, _handler )
	if not _pView or not _tPos or not _handler then
		print("__upAndDownToPos is nil")
		return
	end
	local pLayer = _pView:getParent()
	local nZoder = 0
	local nX, nY = _tPos.x + 50, _tPos.y - 5
	--1、地面光效
	-- 第一层：
	-- “rwww_sjbs_dlxg_dl_003”
	-- （缩放值x=364%,y=175%）
	-- 时间    透明度    是否加亮
	-- 0秒       0%        加亮
	-- 0.38秒   100%       加亮
	-- 0.40秒    0%        加亮
	local pImgFloor1 = display.newSprite("#rwww_sjbs_dlxg_dl_003.png")
	pImgFloor1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor1:setPosition(nX, nY)
	pLayer:addChild(pImgFloor1, nZoder)
	pImgFloor1:setScale(3.64, 1.75)
	pImgFloor1:setOpacity(0)
	local pAct = cc.Sequence:create({
		cc.FadeIn:create(0.38),
		cc.FadeOut:create(0.40 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor1:removeSelf()
	 	end),
		})
	pImgFloor1:runAction(pAct)

	-- 第二层：
	-- “rwww_sjbs_dlxg_dl_003”
	-- （缩放值x=176%,y=85%）

	-- 时间    透明度    是否加亮
	-- 0秒       0%        加亮
	-- 0.38秒   100%       加亮
	-- 0.60秒    0%        加亮
	local pImgFloor2 = display.newSprite("#rwww_sjbs_dlxg_dl_003.png")
	pImgFloor2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor2:setPosition(nX, nY)
	pLayer:addChild(pImgFloor2, nZoder)
	pImgFloor2:setScale(1.76, 0.85)
	pImgFloor2:setOpacity(0)
	local pAct = cc.Sequence:create({
		cc.FadeIn:create(0.38),
		cc.FadeOut:create(0.60 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor2:removeSelf()
	 	end),
		})
	pImgFloor2:runAction(pAct)

	-- 第三层：
	-- “rwww_sjbs_dlxg_dl_003”
	-- （缩放值x=95%,y=45%）

	-- 时间    透明度    是否加亮
	-- 0秒       0%        加亮
	-- 0.38秒   100%       加亮
	-- 0.40秒    0%        加亮
	local pImgFloor3 = display.newSprite("#rwww_sjbs_dlxg_dl_003.png")
	pImgFloor3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor3:setPosition(nX, nY)
	pLayer:addChild(pImgFloor3, nZoder)
	pImgFloor3:setScale(0.95, 0.45)
	pImgFloor3:setOpacity(0)
	local pAct = cc.Sequence:create({
		cc.FadeIn:create(0.38),
		cc.FadeOut:create(0.40 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor3:removeSelf()
	 	end),
		})
	pImgFloor3:runAction(pAct)

	-- 2、从上往下掉的光效。
	-- “rwww_sjbs_dlxg_dl_008”
	-- （缩放值x=200%,y=200%）
	-- 时间    透明度        坐标         是否加亮
	-- 0秒      30%     (x=-5，y=1000)      加亮
	-- 0.38秒   100%    (x=-5，y=150)       加亮
	-- 0.45秒   0%      (x=-5，y=150)       加亮
	local pImgFloor4 = display.newSprite("#rwww_sjbs_dlxg_dl_008.png")
	pImgFloor4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgFloor4:setPosition(nX -5, nY + 1000)
	pLayer:addChild(pImgFloor4, nZoder)
	pImgFloor4:setScale(2)
	pImgFloor4:setOpacity(0.3 * 255)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.38),
			cc.MoveTo:create(0.38, cc.p(nX -5, nY + 150)),
		}),
		cc.CallFunc:create(function ( )
			--(当“2、从上往下掉的光效。”播放至0.38秒，播放该效果)
			--原地爆炸
	 		__playBlastArms(pLayer, nX, nY)
	 		--显示
	 		_pView:setVisible(true)
	 		_pView:setPosition(_tPos)
	 		if _handler then
	 			_handler()
	 		end
	 	end),
		cc.FadeOut:create(0.45 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgFloor4:removeSelf()
	 	end),
		})
	pImgFloor4:runAction(pAct)

	__tlbossBlack(pLayer)
end

--爆破的光效
-- 1、BOSS的上层（层级比BOSS大）光效。
-- 2、BOSS的下层（层级比BOSS小）光效。
function __playBlastArms( pLayer, nX, nY )
	--1、BOSS的上层光效。
	local nZoder = 999
	local nTag = 201838
	local pLayBlast = pLayer:getChildByTag(nTag)
	if not pLayBlast then
		pLayBlast = MUI.MLayer.new()
		pLayer:addChild(pLayBlast, nZoder, nTag)
		centerInView(pLayer, pLayBlast)
	end

	local tArmData1  =  {
		nFrame = 15, -- 总帧数
		pos = {2, 94}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 2.4,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_007",
				nSFrame = 1,
				nEFrame = 3,
				tValues = {-- 参数列表
					{255, 150}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_007",
				nSFrame = 4,
				nEFrame = 15,
				tValues = {-- 参数列表
					{150, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        pLayBlast, 
        nZoder, 
        cc.p(nX + 25,nY+ 15+50),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.fight)
    if pArm then
    	pArm:play(1)
    end

    local tArmData2  = 
	{
		nFrame = 12, -- 总帧数
		pos = {-11, 161}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 2,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "rwww_sjbs_lgxg_bk_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 12, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData2, 
        pLayBlast, 
        nZoder, 
        cc.p(nX,nY+25+50),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.fight)
    if pArm then
    	pArm:play(1)
    end

    local nZoder = 0
    --2、BOSS的下层光效。
    local tArmData1  =  {
		nFrame = 20, -- 总帧数
		pos = {1, 20}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.5,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_001",
				nSFrame = 1,
				nEFrame = 6,
				tValues = {-- 参数列表
					{100, 255}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_001",
				nSFrame = 7,
				nEFrame = 21,
				tValues = {-- 参数列表
					{255, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        pLayer, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.fight)
    if pArm then
    	pArm:play(1)
    end
    
    local tArmData2  = 
	{
		nFrame = 12, -- 总帧数
		pos = {5, 60}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 2,-- 初始的缩放值
		nBlend = 0, -- 需要加亮
	   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			 {
				nType = 1, -- 序列帧播放
				sImgName = "rwww_sjbs_d_bk_",
				nSFrame = 1, -- 开始帧下标
				nEFrame = 12, -- 结束帧下标
				tValues = nil, -- 参数列表
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData2, 
        pLayer, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.fight)
    if pArm then
    	pArm:play(1)
    end

    local tArmData3  =  {
		nFrame = 16, -- 总帧数
		pos = {7, 15}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.5,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_002",
				nSFrame = 1,
				nEFrame = 5,
				tValues = {-- 参数列表
					{125, 255}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_002",
				nSFrame = 6,
				nEFrame = 16,
				tValues = {-- 参数列表
					{255, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData3, 
        pLayer, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.fight)
    if pArm then
    	pArm:play(1)
    end

    local tArmData4  =  {
		nFrame = 16, -- 总帧数
		pos = {3, 8}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1,-- 初始的缩放值
	        fScaleX = 3.38, 
	        fScaleY = 1.87, 
		nBlend = 1, -- 需要加亮
	  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
		tActions = {
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_004",
				nSFrame = 1,
				nEFrame = 3,
				tValues = {-- 参数列表
					{255, 100}, -- 开始, 结束透明度值
				}, 
			},
			{
				nType = 2, -- 透明度
				sImgName = "rwww_sjbs_dlxg_dl_004",
				nSFrame = 4,
				nEFrame = 14,
				tValues = {-- 参数列表
					{95, 0}, -- 开始, 结束透明度值
				}, 
			},
		},
	}
	local pArm = MArmatureUtils:createMArmature(
        tArmData4, 
        pLayer, 
        nZoder, 
        cc.p(nX,nY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.fight)
    if pArm then
    	pArm:play(1)
    end


	-- 扩散动画1：
	-- “rwww_sjbs_dlxg_dl_006”
	-- 时间       透明度      缩放值
	-- 0秒         100%      （x=513%,y=215%）
	-- 0.55秒      0%        （x=587%,y=246%）
	local pImgSpread1 = display.newSprite("#rwww_sjbs_dlxg_dl_006.png")
	pImgSpread1:setPosition(nX, nY)
	pLayer:addChild(pImgSpread1, nZoder)
	pImgSpread1:setScale(5.13, 2.15)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeOut:create(0.55),
			cc.ScaleTo:create(0.55, 5.87, 2.46),
		}),
		cc.CallFunc:create(function ( )
	 		pImgSpread1:removeSelf()
	 	end),
		})
	pImgSpread1:runAction(pAct)

	-- 扩散动画2：
	-- “rwww_sjbs_dlxg_dl_005”
	-- 时间       透明度      缩放值             是否加亮
	-- 0秒         100%     （x=525%,y=244%）       加亮
	-- 0.23秒      65%      （x=640%,y=300%）       加亮
	-- 0.73秒      0%       （x=771%,y=357%）       加亮
	local pImgSpread2 = display.newSprite("#rwww_sjbs_dlxg_dl_005.png")
	pImgSpread2:setPosition(nX, nY)
	pLayer:addChild(pImgSpread2, nZoder)
	pImgSpread2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgSpread2:setScale(5.25, 2.44)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeTo:create(0.23, 255 * 0.65),
			cc.ScaleTo:create(0.23, 6.4, 3),
		}),
		cc.Spawn:create({
			cc.FadeOut:create(0.73 - 0.23),
			cc.ScaleTo:create(0.73 - 0.23, 7.71, 3.57),
		}),
		cc.CallFunc:create(function ( )
	 		pImgSpread2:removeSelf()
	 	end),
		})
	pImgSpread2:runAction(pAct)

	__tlbossShake(pLayer)
end

--播放TLBoss地震
function __tlbossShake( pLayer )
	-- 震动动画(全满震动)
	-- 时间         位置（Y）
	-- 0                 0
	-- 0.06秒            -4
	-- 0.17秒            2    （-4 到 2 = 6 像素）
	-- 0.28秒            0
	local nX, nY = pLayer:getPosition()
	local pMoveTo1 = cc.MoveTo:create(0.06, cc.p(nX, nY - 4))
	local pMoveTo2 = cc.MoveTo:create(0.17 -0.06, cc.p(nX, nY + 2))
	local pMoveTo3 = cc.MoveTo:create(0.28 - 0.17, cc.p(nX, nY))
	pLayer:runAction(cc.Sequence:create({pMoveTo1,pMoveTo2,pMoveTo3})) 
end

--播放TLBoss变暗
function __tlbossBlack( pLayer )
	-- --播放TLBoss变黑
	-- 黑屏动画“rwww_sjboss_hp_ts_01” 缩放值：“x=2500%,y=3000%”
	-- 时间      透明度  
	-- 0秒         0%
	-- 0.35秒      35%
	-- 0.38秒      50%
	-- 0.88秒      0%
	local pImgBlack = MUI.MImage.new("#rwww_sjboss_hp_ts_01.png")
	pImgBlack:setScale(32, 40)
	pLayer:addChild(pImgBlack, 999)
	centerInView(pLayer, pImgBlack)
	pImgBlack:setOpacity(0) 
	local pAct = cc.Sequence:create({
		cc.FadeTo:create(0.35, 255*0.35),
		cc.FadeTo:create(0.38 - 0.35, 255*0.5),
		cc.FadeOut:create(0.88 - 0.38),
		cc.CallFunc:create(function ( )
	 		pImgBlack:removeFromParent()
	 	end)
		})
	pImgBlack:runAction(pAct)
end