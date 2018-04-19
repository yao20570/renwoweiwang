----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-03-20 15:01:30
-- Description: 地图上的纣王试炼视图点
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DotLabel = require("app.layer.world.DotLabel")
local nShowYAdd = -10
local nWarZorder = 2
local nPosZ = 1
local nHpZorder = 10 --血条层次
local nSwordArmZorder = 10
local nCaremaMask = 10
local ZhouTrialDot = class("ZhouTrialDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)

--pWorldLayer：世界层
--pImgDot 视图点图片（减少drawcall）
function ZhouTrialDot:ctor( pWorldLayer, pImgDot, pClickNode)
	self.pWorldLayer= pWorldLayer

	self.pImgDot = pImgDot
	self.pClickNode = pClickNode
	WorldFunc.setCameraMaskForView(self.pImgDot)
	--解析文件
	parseView("layout_world_zhou_trial", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ZhouTrialDot:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView, 1)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
    self:setDestroyHandler("ZhouTrialDot",handler(self, self.onZhouTrialDotDestroy))
end

function ZhouTrialDot:onZhouTrialDotDestroy(  )
	self:onPause()
end

function ZhouTrialDot:onResume(  )
	self:regMsgs()
end

function ZhouTrialDot:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function ZhouTrialDot:regMsgs( )
end

function ZhouTrialDot:unregMsgs( )
end

function ZhouTrialDot:setupViews(  )
	local pTxtName = self:findViewByName("txt_name")
	pTxtName:setVisible(false) --隐藏起来 只拿来获取texture
	self.pLayLvBg = self:findViewByName("lay_lv_bg")

	local pTxtLv = MUI.MLabel.new({text = "1", size = 22})
	pTxtLv:setVisible(false) --隐藏起来 只拿来获取texture
	self.pLayLvBg:addChild(pTxtLv, 100)

	--乱军坐标和位置
	self.tWArmyLvBgPos = {x = 61, y = 0}

	--创建一个等级背景框
	self.pBbLvBg = createCCBillBorad("#v1_img_dengjidi2.png")
	self.pBbLvBg:setPosition3D(cc.vec3(61, 16, 1))
	self.pLayLvBg:addChild(self.pBbLvBg,99)

	---Boss名字面板
	self.pBbNameBg = createCCBillBorad("ui/daitu.png")
	self.pBbNameBg:setPosition3D(cc.vec3(self.pBbNameBg:getContentSize().width / 2 + 15, 14, 0))
	self.pLayLvBg:addChild(self.pBbNameBg,100)

	--Boss名字
	self.pBbName = DotLabel.new(pTxtName)
	self.pBbNameBg:addChild(self.pBbName,20)

	self.pBbLv = DotLabel.new(pTxtLv)
	self.pBbLvBg:addChild(self.pBbLv,100)

	--设置层大小
	local tSize = self:getContentSize()
	self.pClickNode:setLayoutSize(tSize)
	
	--图标		
	local pKingZhou = WorldFunc.getKingZhouConfData()
	if pKingZhou then
		--名字
		self.pBbName:setString(pKingZhou.sName)
		self.pBbLv:setString(pKingZhou.nLevel)
		self.pImgDot:setCurrentImage(pKingZhou.sRoleImg)
		self.pImgDot:setScale(1.2)	 					
	end
	local pParent = self.pImgDot:getParent()
	self.pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["55"],
		pParent,
		10,
		cc.p(tSize.width/2,tSize.height/2),
		function ( pArm )
		end, Scene_arm_type.world)	
	--名字面板
	WorldFunc.updateBbNameBgByStrWidth(self.pBbNameBg, self.pBbName:getContentSize().width)	
	if self.pArm then
		WorldFunc.setCameraMaskForView(self.pArm)
		self.pArm:play(-1)
	end
	self.pImgDot:setVisible(false)



	--位置居中
	local nNameBgW = self.pBbNameBg:getContentSize().width
	local nNameBgH = self.pBbNameBg:getContentSize().height
	local nLvBgW = self.pBbLvBg:getContentSize().width
	local nLvBgH = self.pBbLvBg:getContentSize().height
	self.pBbNameBg:setPosition3D(cc.vec3(self.tWArmyLvBgPos.x + nLvBgW/2 - 10, self.tWArmyLvBgPos.y, 0))
	self.pBbName:setPosition3D(cc.vec3(nNameBgW/2, nNameBgH/2, 1))
	self.pBbLvBg:setPosition3D(cc.vec3(self.pBbNameBg:getPositionX() - nNameBgW/2 - nLvBgW/2 + 10, self.tWArmyLvBgPos.y - 1, 1))
	self.pBbLv:setPosition3D(cc.vec3(nLvBgW/2, nLvBgH/2, 2))
	
	--设置相机类型
	WorldFunc.setCameraMaskForView(self)

	self:initZhouDotBar()
end

--需要双摄机处理
function ZhouTrialDot:initZhouDotBar(  )
	-- if self.pLayBarCd then
	-- 	return
	-- end
	if not self.bIsInited then
		self.bIsInited = true
	else
		return
	end	
	if not self.pWorldLayer:getIsCamera2Inited() then
		return
	end
	local nX, nY = UNIT_WIDTH/2 - 25, UNIT_HEIGHT/2 - 10
	local pLayTLBossHp = MUI.MLayer.new()
	pLayTLBossHp:setContentSize(161,20)
	self:addChild(pLayTLBossHp, nHpZorder)
	self.pLayTLBossHp = pLayTLBossHp	
	pLayTLBossHp:setPosition(nX - 70, nY + 120)	
	
	local pImgTLBossBg = display.newSprite("ui/bar/v2_bar_bboss.png")
	pImgTLBossBg:setPosition(161/2, 20/2)
	pImgTLBossBg:setOpacity(0.5*255)
	pLayTLBossHp:addChild(pImgTLBossBg)
	-- pImgTLBossBg:setCameraMask(nCaremaMask ,true)

	--步骤一：进度条序列帧动画
	--血条进度条
	local pImgJdt = display.newSprite("ui/bar/v2_bar_yellow_boss.png")
	self.pImgJdt = pImgJdt
	local pProJdt = cc.ProgressTimer:create(pImgJdt)
	pProJdt:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	pProJdt:setBarChangeRate(cc.p(1, 0))
	pProJdt:setMidpoint(cc.p(0, 0.5))
	pProJdt:setPosition(161/2, 20/2)
	pLayTLBossHp:addChild(pProJdt, 1)
	self.pProJdt = pProJdt
	-- self.pProJdt:setCameraMask(nCaremaMask,true)

	-- self.pLayBarCd = self:findViewByName("lay_bar")
	-- self.pLayBarCd:setZOrder(1)
	-- self.pCallCdBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
	-- 	    {
	-- 	    	bar="ui/bar/v2_bar_bboss.png",
	-- 	    	button="ui/update_bin/v1_ball.png",
	-- 	    	barfg="ui/bar/v2_bar_yellow_boss.png",
	-- 	    }, 
	-- 	    {
	-- 	    	scale9 = false, 
	-- 	    	touchInButton=false
	-- 	    })
	-- 	    :setSliderSize(161, 20)
	-- 	    :align(display.LEFT_BOTTOM)
 --    --设置为不可触摸
 --    self.pCallCdBar:setViewTouched(false)
 --    self.pCallCdBar:setSliderValue(100)
	-- self.pLayBarCd:addView(self.pCallCdBar, 10)
	-- local nX, nY = self.pCallCdBar:getPosition()
	-- nX = nX - 20
	-- nY = nY + 30
	-- self.pCallCdBar:setPosition(nX, nY)

	self.pBbPer = MUI.MLabel.new({
            text = "",
            size = 20,
        })
	self.pBbPer:enableOutline(getC4B("211300"), 1)
	self.pBbPer:setPosition(pLayTLBossHp:getWidth()/2, pLayTLBossHp:getHeight()/2)
	-- self.pBbPer:setCameraMask(nCaremaMask,true)
	pLayTLBossHp:addChild(self.pBbPer, 15)

	self.pBgMark = MUI.MImage.new("#v2_img_dengjidi03.png")
	self.pBgMark:setPosition(0, self.pBbPer:getPositionY())
	-- self.pBgMark:setCameraMask(nCaremaMask,true)
	pLayTLBossHp:addChild(self.pBgMark, 15)		

	pLayTLBossHp:setCameraMask(nCaremaMask ,true)
end

--设置服务器数据
--tData:ViewDotMsg
function ZhouTrialDot:setData( tData )
	self.tData = tData	
	self:updateViews()
end

--获取数据
function ZhouTrialDot:getData(  )
	return self.tData
end

function ZhouTrialDot:getDotKey()
	if not self.tData then
		return
	end
	return self.tData.sDotKey
end

--获取dotkey集
function ZhouTrialDot:getDotKeys(  )
	return self.tDotKey or {}
end

--生成dotKey集
function ZhouTrialDot:setDotKeys( tDotKey )
	self.tDotKey = tDotKey
end

--获取是否在dotKey中
function ZhouTrialDot:getIsInDotKey( sDotKey )
	if self.tDotKey then
		for i=1,#self.tDotKey do
			if self.tDotKey[i] == sDotKey then
				return true
			end
		end
	end
	return false
end

--设置显示视图
function ZhouTrialDot:setViewRect( pRect )
	self.pViewRect = pRect
end

--获取显示视图
function ZhouTrialDot:getViewRect(  )
	return self.pViewRect
end

--更新
function ZhouTrialDot:updateViews(  )
	if not self.tData then
		return
	end
	local fX, fY = self.tData:getWorldMapPos()
    --防止重复刷新
	if self.nX ~= self.tData.nX or self.nY ~= self.tData.nY then
		self.nX = self.tData.nX
		self.nY = self.tData.nY
		--更新坐标
		
		self:setPosition(fX, fY)

		self.pImgDot:setPosition(fX, fY + nShowYAdd)
		self.pArm:setPosition(cc.p(fX, fY + nShowYAdd))
		self.pClickNode:setPosition(fX, fY)
	end	
	--
	if self.nKzt ~= self.tData.nKzt or self.nKztt ~= self.tData.nKztt then
		self.nKzt = self.tData.nKzt
		self.nKztt = self.tData.nKztt
		-- self.pCallCdBar:setSliderValue(self.nKzt/self.nKztt*100)
		self.pProJdt:setPercentage(self.nKzt/self.nKztt*100)
		local nPrecent = roundOff(self.nKzt/self.nKztt*100, 0.1)
		self.pBbPer:setString(nPrecent.."%")	
	end
end

--隐藏
function ZhouTrialDot:setVisibleEx( bIsShow )
	if not bIsShow then
		--清空数据
		self:delViewDotMsg()			
	end
	self:setVisible(bIsShow)
	-- self.pImgDot:setVisible(bIsShow)
	self.pArm:setVisible(bIsShow)
	self.pClickNode:setVisible(bIsShow)
end

function ZhouTrialDot:delViewDotMsg( )
	--清空数据
	if self.tData then
		Player:getWorldData():delViewDotMsg(self.tData)
		self.tData = nil
	end
end

return ZhouTrialDot
