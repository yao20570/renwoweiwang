----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-06 17:41:00
-- Description: 魔神来临
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
-- local AttackTLBossHelp = require("app.layer.tlboss.AttackTLBossHelp")
local e_finger_target = {
	boss = 1,
	btn_dispatch = 2,
	btn_atk = 3,
}

local TLBossCome = class("TLBossCome", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function TLBossCome:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("layout_tboss_come", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TLBossCome:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TLBossCome", handler(self, self.onTLBossComeDestroy))
end

-- 析构方法
function TLBossCome:onTLBossComeDestroy(  )
    self:onPause()
    --去掉监听刷新
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
end

function TLBossCome:regMsgs(  )
end

function TLBossCome:unregMsgs(  )
end

function TLBossCome:onResume(  )
	self:regMsgs()
	self:updateViews()
	--刷新监听
	self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
		self:onLineMove()
	end,0.1)
	self:updateViews()
end

function TLBossCome:onPause(  )
	self:unregMsgs()

end

function TLBossCome:setupViews(  )
	local pTxtDesc = self:findViewByName("txt_desc")
	pTxtDesc:setString(getTextColorByConfigure(getTipsByIndex(20135)))

	local pLayBtn = self:findViewByName("lay_btn")
	local pGoBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10822))
	pGoBtn:onCommonBtnClicked(handler(self, self.onGoClicked))
	self.pGoBtn = pGoBtn

	local tConTable = {}
	--文本
	local tLabel = {
		{getConvertedStr(3, 10821),getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	pGoBtn:setBtnExText(tConTable)
	self.pLayContent = self:findViewByName("lay_content")
	--创建
	self.bIsCanGetItem = true
	-- self.pLayMoBingHelp = AttackTLBossHelp.new(self)		
	-- self.pLayContent:addView(self.pLayMoBingHelp, 1)
	-- self.pLayMoBingHelp:setPosition(60, 220)

	--Boss待机动画
	local pLayTLBossArm = MUI.MLayer.new()
	local pArm = MArmatureUtils:createMArmature(
        tFightSecArmDatas["2_5_1_1"], 
        pLayTLBossArm, 
        2, 
        cc.p(0,0),
        function ( _pArm )
        end, Scene_arm_type.normal)
    if pArm then
    	pArm:play(-1)
    end
    self.pLayTLBossArm = pLayTLBossArm

    --Boss名字和背景
	local pLayName = display.newNode()
	pLayName:setPosition(20, -120)
	pLayTLBossArm:addChild(pLayName, 1)

    --Boss名字和背景
	local pLayName = display.newNode()
	pLayName:setPosition(20, -120)
	pLayTLBossArm:addChild(pLayName, 1)
	local pImgName = display.newSprite("#v1_img_namebg3.png")
	pLayName:addChild(pImgName)
	local pTxtName = MUI.MLabel.new({
            text = getConvertedStr(3, 10800),
            size = 20,})
	pLayName:addChild(pTxtName, 2)
	local pImgIcon = display.newSprite("#v2_img_dengjidi02.png")
	pLayName:addChild(pImgIcon, 1)
	pImgIcon:setPositionX(-pImgName:getContentSize().width/2)
	local pSize = self.pLayContent:getContentSize()
	local nBossX, nBossY = pSize.width/2, pSize.height/2 + 80
	self.nBossX, self.nBossY = nBossX, nBossY
	pLayTLBossArm:setPosition(nBossX, nBossY)
	self.pLayContent:addView(pLayTLBossArm, 3)

	-------------------------Boss受击变红
	self.pLayTLBossArmRed = MUI.MLayer.new()
	self.pLayTLBossArmRed:setCascadeOpacityEnabled(true)
	local pArm = MArmatureUtils:createMArmature(
        tFightSecArmDatas["2_5_1_1"], 
        self.pLayTLBossArmRed, 
        2, 
        cc.p(0,0),
        function ( _pArm )
        end, Scene_arm_type.normal)
    if pArm then
    	pArm:play(-1)
    	pArm:setColor(cc.c3b(255, 0, 0))
    end
    self.pLayTLBossArmRed:setPosition(nBossX, nBossY)
	self.pLayContent:addView(self.pLayTLBossArmRed, 3)
	self.pLayTLBossArmRed:setOpacity(0)
    -------------------------Boss受击变红

    -------------------------创建Menu Layer
    local pSize = self.pLayContent:getContentSize()
    local nX, nY = self.pLayContent:getPosition()
    local nZoder = self.pLayContent:getLocalZOrder()
    local pParent = self.pLayContent:getParent()
    local pLayMenu = MUI.MLayer.new()
    self.pLayMenu = pLayMenu
    pLayMenu:setLayoutSize(pSize.width, pSize.height)
	pLayMenu:setPosition(nX, nY)
	pParent:addView(pLayMenu, nZoder)


	--Boss图标和加成
	local pImgBB = MUI.MImage.new("#v1_img_bujiang02b.png")
	self.pLayContent:addView(pImgBB, 10)
	pImgBB:setScale(0.5)
	local pImgQB = MUI.MImage.new("#v1_img_qibing02bb.png")
	self.pLayContent:addView(pImgQB, 10)
	pImgQB:setScale(0.5)
	local pImgGB = MUI.MImage.new("#v1_img_gongjiang02b.png")
	self.pLayContent:addView(pImgGB, 10)
	pImgGB:setScale(0.5)
	self.tTroopIcon = {
		[en_soldier_type.infantry] = pImgBB,
		[en_soldier_type.sowar] = pImgQB,
		[en_soldier_type.archer] = pImgGB,
	}
	local pTxtTroopPer = MUI.MLabel.new({
            text = "0",
            size = 20,})
	self.pTxtTroopPer = pTxtTroopPer
	pTxtTroopPer:setAnchorPoint(0, 0.5)
	pTxtTroopPer:setPosition(20, 160)
	-- pTxtTroopPer:setVisible(false)
	self.pLayContent:addView(pTxtTroopPer, 10)

	--播放介绍动画
	local pAct = cc.Sequence:create({
			cc.DelayTime:create(2),
			cc.CallFunc:create(function (  )  
		 		self:playIntroduceAnim()
		    end),
	 	})
	self.pLayTLBossArmRed:runAction(pAct)
	
end


function TLBossCome:setCanShowGetItem( bIsCanGetItem )
	self.bIsCanGetItem = bIsCanGetItem
end

function TLBossCome:getIsCanShowGetItem( )
	return self.bIsCanGetItem
end

function TLBossCome:updateViews(  )
	local nPer = Player:getTLBossData():getArmyAddPer()
	local tAddPerList = Player:getTLBossData():getArmyAddPerList()
	if nPer > 0 and #tAddPerList > 0 then
		--隐藏全部
		for k,v in pairs(self.tTroopIcon) do
			v:setVisible(false)
		end
		local nX ,nY, nOffsetX = 40, 200, 60
		for i=1,#tAddPerList do
			local nKey = tAddPerList[i]
			local pImgIcon = self.tTroopIcon[nKey]
			if pImgIcon then
				pImgIcon:setVisible(true)
				pImgIcon:setPosition(nX, nY)
				nX = nX + nOffsetX
			end
		end
		self.pTxtTroopPer:setString(string.format(getConvertedStr(3, 10837), nPer*100))
		self.pTxtTroopPer:setVisible(true)
	else
		for k,v in pairs(self.tTroopIcon) do
			v:setVisible(false)
		end
		self.pTxtTroopPer:setVisible(false)
	end

	self:updateGoBtn()	
end

function TLBossCome:updateGoBtn( )
	local nTLBossTime = Player:getTLBossData():getCdState()
	if nTLBossTime == e_tlboss_time.no then
		self.pGoBtn:setExTextLbCnCr(1, getConvertedStr(3, 10840), getC3B(_cc.red))
		self.pGoBtn:setBtnEnable(false)
	else
		self.pGoBtn:setExTextLbCnCr(1, getConvertedStr(3, 10821), getC3B(_cc.white))
		self.pGoBtn:setBtnEnable(true)
	end
end

function TLBossCome:onGoClicked( )
	local nTLBossTime = Player:getTLBossData():getCdState()
	if nTLBossTime == e_tlboss_time.no then
		TOAST(getConvertedStr(3, 10826))
		return
	end

	local nBlockId = Player:getWorldData():getMyCityBlockId()
	local tPos = Player:getTLBossData():getBLocatVo(nBlockId)
	if tPos then
		--跳转
		sendMsg(ghd_world_location_dotpos_msg, {nX = tPos:getX(), nY = tPos:getY(), isClick = false})	
		--关掉聊天界面
	   	closeAllDlg(false)
		closeDlgByType(e_dlg_index.dlgchat)
	end
end

----------------------------------------------介绍动画
local nFingerZorder = 10
local nSecondMenuZ = 9
local nHurtNumZorder = 8
local nRedArmZorder = 7
local nLineHeroZorder = 1
local nLineZorder = 0


--手指移动
--目标x,y
--nScaleFunc:缩小时回调
--nCBFunc:结束时回调
--nCBFuncDelay:结束时延时回调
function TLBossCome:playFingerArm( nX, nY, nScaleFunc, nCBFuncDelay, nCBFunc)
	-- print("nX, nY, nScaleFunc, nCBFuncDelay, nCBFunc=",nX, nY, nScaleFunc, nCBFuncDelay, nCBFunc)
	-- 锚点坐标（0，0）
	-- “v1_img_shouzhi.png”
	-- 时间    透明度     缩放值      位移
	-- 0秒      0%         100%    （X=69,Y=28）
	-- 0.45秒   100%       100%    （X=0，Y=0）
	-- 0.83秒   100%       70%     （x=0,,y=0）
	-- 1.20秒   50%       100%     （x=0,,y=0）
	-- 然后直接消失。
	if not self.pImgFinger then
		self.pImgFinger = MUI.MImage.new("#v1_img_shouzhi.png")
		self.pImgFinger:setAnchorPoint(0, 0)
		self.pLayMenu:addView(self.pImgFinger, nFingerZorder)
	end
	self.pImgFinger:stopAllActions()
	self.pImgFinger:setOpacity(0)
	self.pImgFinger:setPosition(nX + 69, nY + 28)
	self.pImgFinger:setScale(1)
	self.pImgFinger:setVisible(true)


	local tActList = {
	 	cc.Spawn:create({
						cc.FadeIn:create(0.45),
		    			cc.MoveTo:create(0.45, cc.p(nX, nY)),
		    		}),
	 	cc.ScaleTo:create(0.83 - 0.45, 0.7),
	}
	--
	if nScaleFunc then
		local pClickAct = cc.CallFunc:create(nScaleFunc)
		table.insert(tActList, pClickAct)
	end
	table.insert(tActList,
		cc.Spawn:create({
						cc.FadeTo:create(1.2 - 0.83, 255*0.5),
		    			cc.ScaleTo:create(1.2 - 0.83, 1),
		    		})
		)
	local pHideFunc = cc.CallFunc:create(function (  )
		self.pImgFinger:setVisible(false)
	end)
	table.insert(tActList, pHideFunc)
	--
	if nCBFuncDelay then
		table.insert(tActList, cc.DelayTime:create(nCBFuncDelay))
	end
	--
	if nCBFunc then
		local pClickAct = cc.CallFunc:create(nCBFunc)
		table.insert(tActList, pClickAct)
	end
	self.pImgFinger:runAction(cc.Sequence:create(tActList))
end

--弹出二级菜单
-- nBtnType:TypeCirleBtn.DISPATCH,TypeCirleBtn.ATTACK
function TLBossCome:playSecondMenu( nBtnType, nCBFuncDelay, nCBFunc)
	if not self.pImgCircle then
		self.pImgCircle = MUI.MImage.new("ui/v1_img_yuanhuan.png")
		self.pImgCircle:setAnchorPoint(0.5,1)
		self.pLayMenu:addView(self.pImgCircle, nSecondMenuZ)
		local nBossX, nBossY = self.nBossX, self.nBossY
		self.pImgCircle:setPosition(nBossX, nBossY - 40)

		self.nCBtnX, self.nCBtnY = nBossX, nBossY - 150
		local pLayBtn = MUI.MLayer.new()
		pLayBtn:setLayoutSize(100, 100)
		pLayBtn:setPosition(self.nCBtnX - 100/2, self.nCBtnY - 100/2)
		self.pLayMenu:addView(pLayBtn, nSecondMenuZ)
		local pBtnCircle = getCircleBtnOfContainer(pLayBtn, nBtnType, 0.8)
		self.pBtnCircle = pBtnCircle
		self.pLayBtns = {pLayBtn}
	end
	self.pBtnCircle:updateBtnType(nBtnType)
	self.pBtnCircle:setViewTouched(false)
	self:setSMenuVisible(true)
	for i=1,#self.pLayBtns do
		self.pLayBtns[i]:setVisible(false)
	end
	self.nScale = 0.8
	self.pImgCircle:setOpacity(255)
	self.pImgCircle:setScale(0.7)
	local tAction_1 = cc.Spawn:create(cc.ScaleTo:create(0.15, self.nScale + self.nScale*0.02), cc.FadeIn:create(0.2))
	local tAction_2 = cc.ScaleTo:create(0.3,self.nScale)
	self.pImgCircle:runAction(cc.Sequence:create(tAction_1, tAction_2))


	local nNum = 0
	local function showCb()
		nNum = nNum + 1
		if self.pLayBtns[nNum] then
			local btn = self.pLayBtns[nNum]:findViewByTag(20170724)
			if btn then
				self.pLayBtns[nNum]:setVisible(true)
				btn:showTx()
				self.pLayMenu:runAction(cc.Sequence:create(cc.DelayTime:create(0.04), cc.CallFunc:create(showCb)))
			end
		else
			--0.39上一个按钮特效播放最大的时间0.43 - 上面的0.04
			local pActList = {cc.DelayTime:create(0.39)}
			if nCBFuncDelay then
				table.insert(pActList, cc.DelayTime:create(nCBFuncDelay))
			end
			if nCBFunc then
				table.insert(pActList, cc.CallFunc:create(nCBFunc))
			end
			self.pLayMenu:runAction(cc.Sequence:create(pActList))
		end
	end
	self.pLayMenu:stopAllActions()
	self.pLayMenu:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(showCb)))
end

--设置显示或隐藏
function TLBossCome:setSMenuVisible( bIsShow )
	if self.pLayBtns then
		for k,v in pairs(self.pLayBtns) do
			v:setVisible(bIsShow)
		end
	end
	if self.pImgCircle then
		self.pImgCircle:setVisible(bIsShow)
	end
end

--播放手指点击
function TLBossCome:playCBtnClieck( )
	if self.pBtnCircle then 
		self.pBtnCircle:setColor(cc.c3b(100, 100, 100)) 
		local pAct = cc.Sequence:create({
				cc.ScaleTo:create(0.05, 0.6 , 0.6),
				cc.ScaleTo:create(0.05, 0.8, 0.8),
				cc.CallFunc:create(function (  )  
			 		self.pBtnCircle:setColor(cc.c3b(255, 255, 255))
			    end),
			    cc.DelayTime:create(0.2),
			    cc.CallFunc:create(function (  )  
			 		self:setSMenuVisible(false)
			    end),
		 	})
		self.pBtnCircle:stopAllActions()
		self.pBtnCircle:runAction(pAct)
	end
end

--Boss受击变红飘血
function TLBossCome:playBossRed( nCallBackFunc )
	--文字
	self:showAtkTLBossHurt(9999)

	--受击特效
	local tArmData1  = 
	{
		nFrame = 6, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 3,-- 初始的缩放值
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
	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        self.pLayContent, 
        nRedArmZorder, 
        cc.p(self.nBossX, self.nBossY),
        function ( _pArm )
        	_pArm:removeSelf()
        end, Scene_arm_type.normal)
    if pArm then
    	pArm:play(1)
    end

	-- 时间     透明度 
	-- 0秒        100%
	-- 0.25秒    0%
	self.pLayTLBossArmRed:setOpacity(255)
	self.pLayTLBossArmRed:runAction(cc.FadeOut:create(0.25))
	if nCallBackFunc then
		nCallBackFunc()
	end
end

--nNum 伤害数字
--bIsBest 是否最强一击
function TLBossCome:showAtkTLBossHurt( nNum, bIsBest)
	local nX, nY = self.nBossX, self.nBossY

	--伤害数字
	local sImg = "ui/atlas/v2_img_shanghaishuzih.png"
	if bIsBest then
		sImg = "ui/atlas/v2_img_shanghaishuzihh.png"
	end
	local pTxtNum = MUI.MLabelAtlas.new({text=":"..tostring(nNum), png=sImg, pngw=16, pngh=27, scm=48})
	self.pLayContent:addView(pTxtNum, nHurtNumZorder)
	pTxtNum:setPosition(nX, nY)
	

	-- 弹出动画：
	-- 时间    缩放值    位置（Y）    透明度
	-- 0秒       0%           0        100%
	-- 0.20秒    115%         0        100%
	-- 0.30秒    100%         0        100%
	-- 0.90秒    100%         18       100%
	-- 1.55秒    100%         36       0%
	pTxtNum:setScale(0)
	local pAct = cc.Sequence:create({
		cc.ScaleTo:create(0.20, 1.15),
		cc.ScaleTo:create(0.30 - 0.20, 1),
		cc.MoveTo:create(0.90 - 0.30, cc.p(nX, nY + 18)),
	 	cc.Spawn:create({
						cc.MoveTo:create(1.55 - 0.90, cc.p(nX, nY + 36)),
		    			cc.FadeOut:create(1.55 - 0.90),
		    		}),
	 	cc.CallFunc:create(function (  )
	 		pTxtNum:removeFromParent()
	 	end),
	 	})
	pTxtNum:runAction(pAct)
end

--行军路线
function TLBossCome:playWarLine( nCallBackFunc )
	local tEnd = cc.p(self.nBossX, self.nBossY - 80)
	local tStart = cc.p(tEnd.x + 280, tEnd.y + 150)

	--创建武将
	if not self.pHero then
		self.pHero, self.pArm = self:createHero(self.pLayContent,"blueArmyLeftUToRightD",nLineHeroZorder,cc.p(0,0))
		self:setArmFlipped(true ,0, "blueArmyLeftUToRightD")
	end
	self.pHero:setVisible(true)
	self.pHero:setPosition(cc.p(tStart.x, tStart.y))
	local function moveStep1CallBack(  )
   		--骑兵消失
   		self.pHero:setVisible(false)
   		--执行回调
   		if nCallBackFunc then
   			nCallBackFunc()
   		end
  	end
   	--小马移动
   	local pMove = cc.MoveTo:create(2,cc.p(( tEnd.x ) ,tEnd.y))
   	local callBack = cc.CallFunc:create(moveStep1CallBack)
   	local seqAct = cc.Sequence:create(pMove, callBack)
	self.pHero:runAction(seqAct)

	--显示线
	if not self.pLine then
		local tPos = {} 
		local fLength = cc.pGetDistance(tStart, tEnd)
		local pLine = self:createLine(self.pLayContent,fLength,1)
		
		local nAngle = getAngle(tStart.x, tStart.y, tEnd.x, tEnd.y)
		pLine:setRotation(nAngle)
		local nOffsetRadian = (nAngle + 90) * math.pi / 180;
		local nX, nY = tStart.x + 9 * math.cos(nOffsetRadian), tStart.y - 9 * math.sin(nOffsetRadian)
		pLine:setPosition(nX, nY)
		for i=1,LINE_NUM do
			local fX, fY = (i - 1) * LINE_SIDE, 0
			table.insert(tPos, cc.p(fX, fY))
		end
		self.pLine = pLine
		self.tPosList = tPos
		self.pPosIndex = 1
	end
end

--检路创建
function TLBossCome:createLine( pLay,nLength,nType )
	--创建线
	local sLineImg = nil
	if nType == 1 then
		sLineImg = "#v1_img_xjlxlv.png"
	elseif nType == 2 then
		sLineImg = "#v1_img_xjlxhong.png"
	elseif nType == 3 then
		sLineImg = "#v1_img_xjlxhuang.png"
	else
		sLineImg = "#v1_img_xjlxlv.png"
	end
	--创建裁剪区域
	local pLayLine = cc.ClippingNode:create() 
	local nX, nY, nW, nH = 0,0, nLength, 18
	local tPoint = {
		{nX, nY}, 
		{nX + nW, nY}, 
		{nX + nW, nY + nH}, 
		{nX, nY + nH},
	}
	local tColor = {
		fillColor = cc.c4f(255, 0, 0, 255),
	    borderWidth  = 1,
	    borderColor  = cc.c4f(255, 0, 0, 255)
	} 
	stencil =  display.newPolygon(tPoint,tColor)
	pLayLine:setStencil(stencil)
	pLay:addView(pLayLine, nLineZorder)

	nLength = math.ceil(nLength/LINE_LENGTH) * LINE_LENGTH

	--批处理
	local pBatchNode = display.newTiledBatchNode(sLineImg, "ui/p1_commonse3.png", cc.size(nLength,18), -LINE_MARGIN)
	pBatchNode:setAnchorPoint(cc.p(0,0))
	if pLayLine.addView then
		pLayLine:addView(pBatchNode)
	else
		pLayLine:addChild(pBatchNode)
	end
	pLayLine.pBatchNode = pBatchNode
	return pLayLine
end

function TLBossCome:setArmFlipped( _bFlip,_nRotate,_sName )
	if not self.pArm then
		return 
	end
	if self.pArm then
		self.pArm:setFlippedX(_bFlip)
		self.pArm:setRotation(_nRotate)
		self.pArm:setData(EffectWorldDatas[_sName])
	end
end

--释放行军路线
function TLBossCome:releaseLine( )
	if not tolua.isnull(self.pLine)  then
		self.pLine:removeFromParent(true)
		self.pLine = nil
	end
end


--创建武将
function TLBossCome:createHero( _parent,_sName,_zOrder,_tPos )
    -- 加载纹理
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(1, 1)
	local pArm = MArmatureUtils:createMArmature(
			EffectWorldDatas[_sName],
			pLay,
			10,
			cc.p(0,0),
			function ( _pArm )
			end, Scene_arm_type.normal)
	if pArm then
		pArm:play(-1)
	end
	pLay:setPosition(_tPos)
	_parent:addView(pLay,_zOrder)
	return pLay,pArm
end

--移动起来
function TLBossCome:onLineMove( )
	local pLine = self.pLine
	local pPosList = self.tPosList
	local pPosIndex = self.pPosIndex
	if pLine and pPosList and pPosIndex then
		pPosIndex = pPosIndex + 1
		if pPosIndex > #pPosList then
			pPosIndex = 1
		end
		
		--更新位置
		self.pPosIndex = pPosIndex
		local pPos = pPosList[pPosIndex]
		local pBatchNode = pLine.pBatchNode
		if pBatchNode then
			pBatchNode:setPosition(pPos)
		end
	end
end

--播放介绍动画
function TLBossCome:playIntroduceAnim( )
	-- 手指移动Boss  花费时间：1.2s
	-- 0s
	-- 弹出派迁按钮 花费时间：math.max(0.15+0.2+0.3, 0.1+0.04) （全部播放完）
	-- 2s
	-- 手指移动按钮 花费时间：1.2s
	-- 上面手指缩小时
	-- 按钮点击 花费时间：0.1s
	-- 行军线路 花费时间即为移动完时间
	-- 0s
	-- 手指移动Boss 花费时间：1.2s
	-- 0s
	-- 弹出攻击按钮 花费时间：math.max(0.15+0.2+0.3, 0.1+0.04) （全部播放完）
	-- 0s(可能要微调)
	-- 手指移动攻击 花费时间：0.1s
	-- 上面手指缩小时
	-- 按钮点击 花费时间：0.1s
	-- Boss变红+被击 花费时间：0.25s
	self:stopAllActions()
	--手指移动Boss
	self:playFingerArm(self.nBossX, self.nBossY, nil, nil, function()
		--弹出派迁按钮
		self:playSecondMenu(TypeCirleBtn.DISPATCH, nil, function()
			--手指移动按钮
			self:playFingerArm(self.nCBtnX, self.nCBtnY, function()
				--按钮点击
				self:playCBtnClieck()
				--行军线路
				self:playWarLine(function()
					--手指移动Boss
					self:playFingerArm(self.nBossX, self.nBossY, nil, nil, function()

						--弹出攻击按钮
						self:playSecondMenu(TypeCirleBtn.ATTACK, nil, function()

							--手指移动攻击
							self:playFingerArm(self.nCBtnX, self.nCBtnY, function()
								--按钮点击
								self:playCBtnClieck()
								end, nil, 
								function()
									--Boss变红+被击
									self:playBossRed(function()
										--2秒钟重置
										local pAct = cc.Sequence:create({
											cc.DelayTime:create(2),
										 	cc.CallFunc:create(function ()
										 		self:releaseLine()
										 		self:playIntroduceAnim()
										 	end),
										 	})
										self:runAction(pAct)
									end)
							end)

						end)

					end)

				end)
			end, nil, function()
			end)
		end)
	end)
end
----------------------------------------------介绍动画


return TLBossCome



