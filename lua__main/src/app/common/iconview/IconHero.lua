-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-19 14:49:07 星期三
-- Description: 武将icon
-----------------------------------------------------

-------------------------------------------------------------------------------------------
--例子：
	-- self.pLayIcon = self:findViewByName("lay_icon")
	-- local pIconHero = getIconHeroByType(self.pLayIcon, TypeIconHero.NORMAL, data, TypeIconHeroSize.M)
	-- pIconHero:setIconIsCanTouched(false)
	-- pIconHero:setHeroType()
	-- pIconHero:removeHeroType()
	-- pIconHero:setHeroAdd()
	-- pIconHero:removeHeroAdd()
	-- pIconHero:setIconClickedCallBack(function (  )
	-- 	-- body
	-- 	print("回调=====")
	-- end)
-------------------------------------------------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local StarAttrLayer = require("app.layer.hero.StarAttrLayer")
local SoulStarLayer = require("app.layer.hero.SoulStarLayer")
local IconHero = class("IconHero", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- _nType：类型（TypeIconHero）
function IconHero:ctor( _nType )
	-- body
	self:myInit()
	self.nType = _nType
	parseView("icon_hero", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function IconHero:myInit(  )	-- body
	self.nType 				= nil 		--icon类型
	self.tCurData 			= nil 		--当前数据
	self._nHandlerClicked 	= nil 		--icon点击回调

	self.pLayLocked 		= nil 		--锁住层
	self.pImgHeroType 		= nil 		--兵种图标
	self.pImgHeroAdd 		= nil 		--小加号图标
	self.nWallNpc           = nil       --npc加号动画标示

	self.bIsFromSoulStarLayer = false 	--是否来自星魂界面
	self.nSoulStarPos 		= nil 	--星魂界面的第几个武将

end

--解析布局回调事件
function IconHero:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	self:setupViews()
end

--初始化控件
function IconHero:setupViews( )
	-- body
	--背景品质框
	self.pLayBgQuality 			= 	self:findViewByName("default")
	self.pLayBgQuality:setViewTouched(true)
	self.pLayBgQuality:setIsPressedNeedScale(false)
	self.pLayBgQuality:onMViewClicked(handler(self, self.onIconClicked))
	--icon图标
	self.pImgIcon 				= 	self:findViewByName("img")

	--ly额外信息
	self.pLyEx                  =   self:findViewByName("lay_ex")
	self.pLyEx:setZOrder(25)
	self.pLyEx:setVisible(false)
	--lb
	self.pLbEx                  =   self:findViewByName("lb_ex")
	--神将图标
	self.pImgIg                  =   self:findViewByName("img_ig")
	--红点层
	self.pLayRedTip         =   self:findViewByName("lay_redtip")
	if self.nType == TypeIconHero.NORMAL then --正常类型
		self:setNormalState()
	elseif self.nType == TypeIconHero.NULL then --空
		self:setNullState()
	elseif self.nType == TypeIconHero.ADD then  --加号
		self:setAddState()
	elseif self.nType == TypeIconHero.LOCK then --锁住
		self:setLockedState()
	end
end

-- 修改控件内容或者是刷新控件数据
function IconHero:updateViews(  )
	-- body
	if  type(self.tCurData) == "table" then
		-- dump(self.tCurData,"武将数据=",100)
		--设置icon
		--暂时先使用代图
		self:setIconImg(self.tCurData.sIcon)
		if self.tCurData.nIg == 1 then
			self.pImgIg:setVisible(true)
		else
			self.pImgIg:setVisible(false)
		end
		setBgQuality(self.pLayBgQuality,self.tCurData.nQuality)

		self:addStar()
	
		
	end
	self:addImgAction()
end

--移除品质框特效
function IconHero:removeQualityTx(  )
	-- body
	removeBgQualityTx(self.pLayBgQuality)
end

-- addImgAction 添加按钮图片动作
function IconHero:addImgAction()
	-- body
	--红点显示
	if self.nType == TypeIconHero.ADD then  --加号

		self:setRedTipState(1)

	else
		self:setRedTipState(0)
		-- self.pImgIcon:setToGray(false)
		-- self.pImgIcon:stopAllActions()
		-- self.pImgIcon:setScale(__nItemWidth / self.pImgIcon:getWidth())
	end
	--加号动画
	-- if self.nType == TypeIconHero.ADD then  --加号
	-- 	self:addImgAnimation()
	-- 	-- if self.nWallNpc  then
	-- 	-- 	if self.nWallNpc == 1 then
	-- 	-- 		self:addImgAnimation()
	-- 	-- 	else
	-- 	-- 		self.pImgIcon:setToGray(true)
	-- 	-- 		self.pImgIcon:stopAllActions()
	-- 	-- 		self.pImgIcon:setScale(__nItemWidth / self.pImgIcon:getWidth())
	-- 	-- 		setBgQuality(self.pLayBgQuality,1)
	-- 	-- 	end
	-- 	-- else
	-- 	-- 	if Player:getHeroInfo():bHaveHeroUp() then --如果是城墙的npc可以直接增加特效
	-- 	-- 		self:addImgAnimation()
	-- 	-- 	else
	-- 	-- 		self.pImgIcon:setToGray(true)
	-- 	-- 		self.pImgIcon:stopAllActions()
	-- 	-- 		self.pImgIcon:setScale(__nItemWidth / self.pImgIcon:getWidth())
	-- 	-- 		setBgQuality(self.pLayBgQuality,1)
	-- 	-- 	end
	-- 	-- end

	-- else
	-- 	self.pImgIcon:setToGray(false)
	-- 	self.pImgIcon:stopAllActions()
	-- 	self.pImgIcon:setScale(__nItemWidth / self.pImgIcon:getWidth())
	-- end
end

--移除添加特效动作
function IconHero:stopAddImgAction()
	--红点模式
	self:setRedTipState(0)
	self.pImgIcon:setToGray(true)
	self.pImgIcon:stopAllActions()
	self.pImgIcon:setScale(0.6)
	setBgQuality(self.pLayBgQuality,1)
	--动画模式
	-- self.pImgIcon:setToGray(true)
	-- self.pImgIcon:stopAllActions()
	-- self.pImgIcon:setScale(__nItemWidth / self.pImgIcon:getWidth())
	-- setBgQuality(self.pLayBgQuality,1)
end

--添加按钮的动作
function IconHero:addImgAnimation()
	-- body
	
	self.pImgIcon:setToGray(false)
	-- self.pLayBgQuality:setToGray(true)
	local pScaleTo1 = cc.ScaleTo:create(0.5, 0.6)
	local pFadeTo1 = cc.FadeTo:create(0.5, 255*0.85)
	local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1)

	local pScaleTo2 = cc.ScaleTo:create(0.5,0.8)
	local pFadeTo2 = cc.FadeTo:create(0.5, 255)
	local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)
	setBgQuality(self.pLayBgQuality,1)

	self.pImgIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(action1,action2)))
end

--设置数据
function IconHero:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end


--设置为空状态
function IconHero:setNullState(  )
	-- body
	self:removeHeroType()
	self:removeHeroAdd()
	self:removeLockedState()
	self:removeStar()
	self.pImgIcon:setVisible(false)
	self:addImgAction()
end

--设置为正常状态
function IconHero:setNormalState(  )
	-- body
	self:removeHeroType()
	self:removeHeroAdd()
	self:removeLockedState()
	self:setIconBgToGray(false)
	self.pImgIcon:setVisible(true)
	self:addImgAction()
end

--设置为加号状态
function IconHero:setAddState(  )
	-- body

	self:removeHeroType()
	self:removeHeroAdd()
	self:removeLockedState()
	self.pImgIcon:setVisible(true)
	self.pImgIg:setVisible(false)
	self:setIconImg("#v1_btn_tianjia.png")
	self.pImgIcon:setScale(0.6)
	self:removeStar()
	setBgQuality(self.pLayBgQuality,1)
	self:addImgAction()
end

--设置为锁住状态
function IconHero:setLockedState()
	-- body
	self:removeHeroType()
	self:removeHeroAdd()
	self.pImgIcon:setVisible(false)
	self.pImgIg:setVisible(false)
	if not self.pLayLocked then
		self.pLayLocked = MUI.MLayer.new()
    	self.pLayLocked:setBackgroundImage("#v1_img_black30.png")
    	self.pLayLocked:setLayoutSize(self.pLayBgQuality:getLayoutSize())
    	self.pLayBgQuality:addView(self.pLayLocked,100)
    	--锁住图标
		self.pImgLocked = MUI.MImage.new("#v1_img_lock.png")
		self.pImgLocked:setPosition(self.pLayLocked:getWidth() / 2, self.pLayLocked:getHeight() / 2)
		self.pLayLocked:addView(self.pImgLocked)
	end
	self:removeStar()
	self:addImgAction()
	setBgQuality(self.pLayBgQuality,1)
end

--移除锁住层
function IconHero:removeLockedState(  )
	-- body
	if self.pLayLocked then
		self.pLayLocked:removeSelf()
		self.pLayLocked = nil
	end
end

--设置兵种
function IconHero:setHeroType(  )
	-- body
	if self.tCurData and (type(self.tCurData) == "table") then
		if not self.pImgHeroType then
			self.pImgHeroType = MUI.MImage.new("#v1_img_gongjiang02.png")
			self.pLayBgQuality:addView(self.pImgHeroType, 20)
		end
		--兵种
		self.pImgHeroType:setCurrentImage(getSoldierTypeImg(self.tCurData.nKind))

		--设置位置
		self.pImgHeroType:setPosition(self.pImgHeroType:getWidth() / 2, self.pLayBgQuality:getHeight() - self.pImgHeroType:getHeight() / 2)
	else
		print("self.tCurData is nil")
	end
end

--移除兵种
function IconHero:removeHeroType(  )
	-- body
	if self.pImgHeroType then
		self.pImgHeroType:removeSelf()
		self.pImgHeroType = nil
	end
end

--设置小加号
function IconHero:setHeroAdd(  )
	-- body
	if self.tCurData then
		if not self.pImgHeroAdd then
			self.pImgHeroAdd = MUI.MImage.new("#v1_btn_tianjia.png")
			self.pImgHeroAdd:setAnchorPoint(cc.p(0.5, 0.5))
			self.pImgHeroAdd:setPosition(self.pLayBgQuality:getWidth() - self.pImgHeroAdd:getWidth()*0.4/2 -5
			 , self.pImgHeroAdd:getHeight()*0.4/2+5)
			self.pLayBgQuality:addView(self.pImgHeroAdd, 20)
			self.pImgHeroAdd:setScale(0.4)

			-- self.pLayBgQuality:setToGray(true)
			local pScaleTo1 = cc.ScaleTo:create(0.5, 0.8*0.4)
			local pFadeTo1 = cc.FadeTo:create(0.5, 255*0.85)
			local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1)

			local pScaleTo2 = cc.ScaleTo:create(0.5,1*0.4)
			local pFadeTo2 = cc.FadeTo:create(0.5, 255)
			local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)

			self.pImgHeroAdd:runAction(cc.RepeatForever:create(cc.Sequence:create(action1,action2)))
		end
	else
		print("self.tCurData is nil")
	end
end

--移除小加号
function IconHero:removeHeroAdd(  )
	-- body
	if self.pImgHeroAdd then
		self.pImgHeroAdd:removeSelf()
		self.pImgHeroAdd = nil
	end
end

--设置icon点击回调
function IconHero:setIconClickedCallBack( _handler )
	-- body
	self._nHandlerClicked = _handler
end

--设置星星层
function IconHero:addStar()
	if self.tCurData and (type(self.tCurData) == "table") and self.tCurData.tSoulStar then
		if self.tCurData.tSoulStar then
			if not self.pAttrStart then
				self.pAttrStart = SoulStarLayer.new(0, 0.55,self.pLayBgQuality:getWidth())
				self.pLayBgQuality:addView(self.pAttrStart, 20)
				--设置位置
				self.pAttrStart:setPosition(0,self.pAttrStart:getHeight()/2 + 7)
			end
		end		
		if self.tCurData.tSoulStar then
			if self.bIsFromSoulStarLayer then
				-- doDelayForSomething(self, function( )
				-- 	self.pImgCircle:runAction(cc.MoveTo:create(0.1, cc.p(51,self.pImgCircle:getHeight()/2)))
				-- 	self.pImgOpen:setCurrentImage("#v1_img_kaiqidi.png")
				-- end, 0.1)
				self.pAttrStart:showAddSoulStarAction(self.tCurData.tSoulStar,self.nSoulStarPos)
			else
				self.pAttrStart:updateSoulStar(self.tCurData.tSoulStar)
			end
			--设置位置
			-- self.pAttrStart:setPosition(self.pLayBgQuality:getWidth()/2 - self.pAttrStart:getWidth()/2, 6)
		end
		-- if not self.pImgStar then
		-- 	self.pImgStar = MUI.MImage.new("#v1_img_star5.png")
		-- 	self.pLayBgQuality:addView(self.pImgStar, 20)
		-- 	--设置位置
		-- 	self.pImgStar:setPosition(self.pImgStar:getWidth()/2,self.pImgStar:getHeight()/2)
		-- 	self.pLbStar =  MUI.MLabel.new({text="", size=20})
		-- 	self.pLbStar:setPosition(self.pImgStar:getWidth()/2,self.pImgStar:getHeight()/2-2)
		-- 	self.pLayBgQuality:addView(self.pLbStar, 21)
		-- end
		-- if  self.pLbStar then
		-- 	self.pLbStar:setString(self.tCurData.nStar)
		-- end
	else
		print("self.tCurData is nil")
		self:removeStar()
	end
end

-- --移除星星
-- function IconHero:removeSoulStar(  )
-- 	-- body
-- 	if self.pSoulStarLayer then
-- 		self.pSoulStarLayer:removeSelf()
-- 		self.pSoulStarLayer = nil
-- 	end
-- end

--移除星星
function IconHero:removeStar(  )
	-- body
	if self.pAttrStart then
		self.pAttrStart:removeSelf()
		self.pAttrStart = nil
	end
end
function IconHero:showSoulStarEffect( _nIndex )
	-- body
	if self.pAttrStart then
		self.pAttrStart:showSoulStarHollowToSolid(_nIndex)
	end
end

function IconHero:showAddStarEffect(  )
 	-- body
 	if self.pAttrStart then
		self.pAttrStart:showAddSoulStarAction()
	end

 end 
--设置是否来自星魂界面 主要用于星魂界面的升星动画判断
 function IconHero:setStarSoulLayer( _bFrom ,_nIndex)
 	-- body
 	self.bIsFromSoulStarLayer = _bFrom or self.bIsFromSoulStarLayer
 	self.nSoulStarPos = _nIndex
 end

--点击事件
function IconHero:onIconClicked( pView )
	-- body
	if self._nHandlerClicked then
		if self.tCurData then
			self._nHandlerClicked(self.tCurData)
		else
			self._nHandlerClicked(self.nType)
		end
	else
		-- print("武将icon点击事件")
		if self.nType == TypeIconHero.ADD then  --加号
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		-- else
		-- 	if self.tCurData and pView then
		-- 		openIconInfoDlg(pView,self.tCurData)
		-- 	end
		end
	end
end

--设置是否可以点击icon
function IconHero:setIconIsCanTouched( _bEnbaled )
	-- body
	self.pLayBgQuality:setViewTouched(_bEnbaled)
end


function IconHero:setType( _nType )
	if _nType then
		self.nType= _nType
	else
		return
	end
end

--设置icon类型
function IconHero:setIconHeroType(_nType)
	if _nType then
		self.nType= _nType
	else
		return
	end

	if self.nType == TypeIconHero.NORMAL then --正常类型
		self:setNormalState()
	elseif self.nType == TypeIconHero.NULL then --空
		self:setNullState()
	elseif self.nType == TypeIconHero.ADD then  --加号
		self:setAddState()
	elseif self.nType == TypeIconHero.LOCK then --锁住
		self:setLockedState()
	end


end

--设置英雄icon额外属性显示
function IconHero:setExInfo(_strEx,_strColor)
	if _strEx then
		self.pLyEx:setVisible(true)
		self.pLbEx:setString(_strEx)
		if _strColor then
			setTextCCColor(self.pLbEx, _strColor)
		end
	end
end

--设置英雄图片置灰
function IconHero:setIconBgToGray(_bToGray)
	-- self.pImgIcon:setToGray(_bToGray)
	self:setToGray(_bToGray)
end


--设置英雄右下角的文本显示
function IconHero:setRBBlackBgStr( sStr, sColor )
	if sStr == nil or sStr == "" then
		if self.pLayRBBlackBg then
			self.pLayRBBlackBg:setVisible(false)
		end
	else
		if not self.pLayRBBlackBg then
			local nWidth, nHeight = 40,40
			self.pLayRBBlackBg = MUI.MLayer.new()
	    	self.pLayRBBlackBg:setBackgroundImage("#v1_img_black50.png")
	    	self.pLayRBBlackBg:setLayoutSize(nWidth, nHeight)
	    	self:addView(self.pLayRBBlackBg,999)
	    	self.pLayRBBlackBg:setAnchorPoint(1,0)
	    	self.pLayRBBlackBg:setPosition(self:getContentSize().width, 0)

	    	if not self.pTxtRBBlackBgStr then
	    		self.pTxtRBBlackBgStr = MUI.MLabel.new({
				    text = sStr,
				    size = 20
				 })
	    		self.pTxtRBBlackBgStr:setPosition(nWidth/2, nHeight/2)
	    		self.pLayRBBlackBg:addView( self.pTxtRBBlackBgStr)
	    	end
	    else
	    	self.pLayRBBlackBg:setVisible(true)
	    	self.pTxtRBBlackBgStr:setString(sStr)
	    end
	    if sColor then
	    	setTextCCColor(self.pTxtRBBlackBgStr, sColor)
	    end
	end
end

--设置是否为wallnpc
function IconHero:setNpcHero(_nNpcHero)
	-- dump("setNpcHero")
	self.nWallNpc = _nNpcHero
	self:addImgAction()
end

--英雄按钮点击
--显示底部富文本
function IconHero:setBottomText( sStr )
	if sStr == nil or sStr == "" then
		if self.pTxtBottom then
			self.pTxtBottom:setVisible(false)
		end
	else
		if not self.pTxtBottom then
			self.pTxtBottom = MUI.MLabel.new({
			    text = sStr,
			    size = 20
			 })
			self:addView(self.pTxtBottom)
			self.pTxtBottom:setAnchorPoint(0.5,1)
			self.pTxtBottom:setPosition(cc.p(self:getContentSize().width/2,0))
		end
		self.pTxtBottom:setString(sStr)
	end
end

--设置icon图片
function IconHero:setIconImg(_img)
	-- body
	if _img then
		self.pImgIcon:setCurrentImage(_img)
		local fScale = __nItemWidth / self.pImgIcon:getWidth()
		if fScale > 1 then
			fScale = 1
		end
		self.pImgIcon:setScale(fScale)
	end
end
--添加红点状态:1显示红点, 0隐藏红点
function IconHero:setRedTipState(_state)
	-- body
	showRedTips(self.pLayRedTip, 0, _state)
end

-- function IconHero:setIconSelected( _bSelected )
-- 	-- body
-- 	if not self.pImgSelected then
-- 		self.pImgSelected =  MUI.MImage.new("#v1_img_truqrjfi.png")
-- 		-- self.pImgSelected:setScale(108/134)
-- 	 	self.pLayBgQuality:addView(self.pImgSelected, 99)
-- 	 	centerInView(self.pLayBgQuality, self.pImgSelected)	
-- 	end	
-- 	self.pImgSelected:setVisible(_bSelected)
-- end

function IconHero:setIconSelected( _bSelected ,_bIsShowEffect)
	-- body
	if _bSelected then
		if not self.pImgSelected then
			self.pImgSelected =  MUI.MImage.new("#v1_img_truqrjfi.png")
		 	self.pLayBgQuality:addView(self.pImgSelected, 99)
		 	centerInView(self.pLayBgQuality, self.pImgSelected)	
		end	
		self.pImgSelected:setVisible(_bSelected)

		if _bIsShowEffect then
			self:showSelectedEffect()
		end
	else
		if self.pImgSelected then
			self.pImgSelected:setVisible(_bSelected)
			self.pImgSelected:stopAllActions()
		end
	end

end

function IconHero:showSelectedEffect( )
	-- body

	if self.pImgSelected and self.pImgSelected:isVisible() then
		local fadeTo1 = cc.FadeTo:create(1, 120)
		local fadeTo2 = cc.FadeTo:create(1, 255)
		self.pImgSelected:runAction(cc.RepeatForever:create(cc.Sequence:create(fadeTo1, fadeTo2)))
	end

end


function IconHero:getCurData(  )
	-- body
	return self.tCurData
end
return IconHero