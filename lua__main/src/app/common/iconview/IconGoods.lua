-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-19 17:50:56 星期三
-- Description: 物品icon，装备(正方形)icon（包括其他特殊类型） 底部高度40
-----------------------------------------------------

-------------------------------------------------------------------------------------------
--例子：
 	-- self.pLayIcon = self:findViewByName("lay_icon")
 	-- local pIconGoods = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, data, TypeIconGoodsSize.M)
 	-- pIconGoods:setIconIsCanTouched(false)
 	-- pIconGoods:setIsShowNumber(true)
 	-- pIconGoods:setIconClickedCallBack(function (  )
 	-- 	-- body
 	-- 	print("回调=====")
 	-- end)
-------------------------------------------------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemShgunTalent = require("app.layer.shogun.ItemShgunTalent")
local StarAttrLayer = require("app.layer.hero.StarAttrLayer")


local IconGoods = class("IconGoods", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- _nType：类型（TypeIconGoods）
-- _nShowType：展示类型（type_icongoods_show）
function IconGoods:ctor( _nType, _nShowType )
	-- body
	self:myInit()
	self.nType = _nType
	self.nShowType = _nShowType or self.nShowType
	parseView("icon_goods", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function IconGoods:myInit(  )
	-- body
	self.nType 				= nil 		--icon类型
	self.nShowType 			= type_icongoods_show.item --展示类型
	self.tCurData 			= nil 		--当前数据
	self._nHandlerClicked 	= nil 		--icon点击回调

	self.pLayStar 			= nil 		--星星层
	self.pLayLeftTop 		= nil 		--左上角层

	self.pBoxTX 			= nil       --玩家头像特效
	self.pLbSideIcon        = nil   	--图标文字
	self.pImgTitle 			= nil 		--称号
end

--解析布局回调事件
function IconGoods:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)

	self:setupViews()
end

--初始化控件
function IconGoods:setupViews( )
	-- body
	--base层
	self.pLayBase 			= 	self:findViewByName("default")
	self.pLayBase:setViewTouched(true)
	self.pLayBase:setIsPressedNeedScale(false)
	self.pLayBase:onMViewClicked(handler(self, self.onIconClicked))
	--icon层
	self.pLayBgQuality 		= 	self:findViewByName("lay_icon")
	--icon图标
	self.pImgIcon 			= 	self:findViewByName("img")
	--底部信息层
	self.pLayMore 			= 	self:findViewByName("lay_more")
	--底部文字
	self.pLbMore 			= 	self:findViewByName("lb_more")
	--数字背景
	self.pLayNum 			=  	self:findViewByName("lay_num")
	--数字
	self.pLbNum 			= 	self:findViewByName("lb_num")
	--神将标识
	self.pImgIg 			= 	self:findViewByName("img_ig")
	if self.nType == TypeIconGoods.NORMAL then       --普通类型
		self.pLayMore:removeSelf()
		self.pLayMore = nil
		self.pLbMore = nil
		self.pLayBgQuality:setPositionY(0)
		self.pLayBase:setLayoutSize(self.pLayBgQuality:getWidth(), self.pLayBgQuality:getHeight())
		self:setLayoutSize(self.pLayBase:getLayoutSize())
	elseif self.nType == TypeIconGoods.HADMORE then  --带底部信息

	end
	--默认显示品质特效
	self:setIsShowBgQualityTx(true)
end

-- 修改控件内容或者是刷新控件数据
function IconGoods:updateViews(  )
	-- body
	self:removeBoxTx()--清理
	if self.tCurData then
		-- dump(self.tCurData,"物品数据=",100)
		if self.nShowType == type_icongoods_show.hero then --武将样式
			self:updateHeroInfo()
		elseif self.nShowType == type_icongoods_show.tnolyTree then --科技树样式
			self:updateTnolyTree()
		elseif self.nShowType == type_icongoods_show.item then --物品样式
			self:updateItemInfo()
		elseif self.nShowType == type_icongoods_show.itemnum then --物品样式			
			self:updateItemInfoWithNum()
		elseif self.nShowType == type_icongoods_show.header then --玩家头像
			self:updateHeaderInfo()
		elseif self.nShowType == type_icongoods_show.chatPlayer then --聊天玩家头像
			self:updateChatPlayerInfo()
		elseif self.nShowType == type_icongoods_show.box then
			self:updateItemBox()
		elseif self.nShowType == type_icongoods_show.tech then
			self:updateTechInfo()
		end
	end
end

--隐藏图片
function IconGoods:hideIconImg(_bHide)
	-- body
	self.pImgIcon:setVisible(not _bHide)
end

--设置数据
function IconGoods:setCurData( _tData )

	if not _tData then
		return
	end
	-- body
	self.tCurData = _tData
	self:updateViews()
end

--获得底部层
function IconGoods:getMoreLayer(  )
	-- body
	return self.pLayMore
end

--设置底部文字
function IconGoods:setMoreText( _sStr )
	-- body
	if _sStr and self.pLbMore then
		self.pLayMore:setVisible(true)
		self.pLbMore:setString(_sStr, false)
	end
end

--设置底部Bg图片(在setMoreText后再用！！！)
function IconGoods:setMoreTextBg( nWidth, nHeight )
	if not self.pLayMoreBg then
		self.pLayMoreBg = MUI.MLayer.new()
		self.pLayMoreBg:setBackgroundImage("#v1_img_black50.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})
		self.pLayMore:addView(self.pLayMoreBg, -1)
	end
	if not nWidth then
		nWidth = self.pLbMore:getWidth()
	end
	local nWidth2 = self.pLayMore:getWidth()
	if not nHeight then
		nHeight = self.pLbMore:getHeight()
	end
	if nWidth < nWidth2 then
		nWidth = nWidth2
	end
	self.pLayMoreBg:setLayoutSize(nWidth, nHeight)
	centerInView(self.pLayMore, self.pLayMoreBg)
end

--设置底部文字大小
function IconGoods:setMoreTextSize( _nSize )
	-- body
	if _nSize and self.pLbMore then
		self.pLbMore:setSystemFontSize(_nSize)
	end
end

--设置底部文字颜色
function IconGoods:setMoreTextColor( _color)
	-- body
	if _color and self.pLbMore then
		self.pLbMore:setTextColor(getC3B(_color))
	end
end

--设置数量
function IconGoods:setNumber( _nNum, _symbol, _bZeroShow )
	-- body
	if not _nNum then
		return
	end
	if _symbol then
		self.pLbNum:setString(_symbol..getResourcesStr(_nNum), false)
	else
		self.pLbNum:setString(getResourcesStr(_nNum), false)
	end
	local nWidth = self.pLbNum:getWidth()
	if nWidth < 30 then
		nWidth = 30
	end
	self.pLayNum:setLayoutSize(nWidth + 4, self.pLayNum:getHeight())
	--动态设置位置
	self.pLayNum:setPositionX(self.pLayBgQuality:getWidth() - self.pLayNum:getWidth() - 6)
	self.pLbNum:setPositionX(self.pLayNum:getWidth() / 2)
	if _nNum > 0 then
		self:setIsShowNumber(true)
	else
		if _bZeroShow then
			self:setIsShowNumber(true)
		else
			self:setIsShowNumber(false)
		end		
	end
end

--设置消耗数值显示
function IconGoods:setCostStr( tStr )
	-- body
	if not tStr then
		return
	end
	self:setIsShowNumber(true)
	self.pLbNum:setString(tStr, false)
	local nWidth = self.pLbNum:getWidth()
	if nWidth < 30 then
		nWidth = 30
	end
	self.pLayNum:setLayoutSize(nWidth + 4, self.pLayNum:getHeight())
	--动态设置位置
	self.pLayNum:setPositionX(self.pLayBgQuality:getWidth() - self.pLayNum:getWidth() - 6)
	self.pLbNum:setPositionX(self.pLayNum:getWidth() / 2)	
end

--设置战术使用次数
function IconGoods:setTechUsedStr( tStr )
	-- body
	if not tStr then
		return
	end
	self:setIsShowNumber(true)
	self.pLbNum:setString(tStr, false)
	local nWidth = self.pLbNum:getWidth()
	if nWidth < 30 then
		nWidth = 30
	end
	self.pLayNum:setLayoutSize(nWidth + 4, self.pLayNum:getHeight())
	--动态设置位置
	self.pLayNum:setPositionX(self.pLayBgQuality:getWidth() - self.pLayNum:getWidth() - 6)
	self.pLbNum:setPositionX(self.pLayNum:getWidth() / 2)	
end

--设置数量颜色
function IconGoods:setNumberColor(_color)
	-- body
	setTextCCColor(self.pLbNum, _color)
end

--设置是否展示数量
function IconGoods:setIsShowNumber( _bEnbaled )
	-- body
	self.pLayNum:setVisible(_bEnbaled)
end

--展示星星层
--_nAll：总星星数
--_nCur：当前星星数
--_tDarkLight:暗亮列表(可以不传) {true,false,true,false}, true表示光，false表示暗
function IconGoods:initStarLayer( _nAll, _nCur, _tDarkLight)
	-- body
	if not _nAll or not _nCur then
		return
	end
	if not self.pLayStar then
		self.pLayStar = MUI.MLayer.new()
		self.pLayStar:setBackgroundImage("#v1_img_black50.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})
		self.pLayStar:setLayoutSize(self.pLayBgQuality:getWidth() - 12, 30)
		self.pLayStar:setPosition(6, 5)
		self.pLayBgQuality:addView(self.pLayStar,30)
	end
	showStarLayer(self.pLayStar, _nAll, _nCur, _tDarkLight)
end

--刷新星星层
--_nAll：总星星数
--_nCur：当前星星数
--_tDarkLight:暗亮列表(可以不传) {true,false,true,false}, true表示光，false表示暗
function IconGoods:refreshStarLayer( _nAll, _nCur, _tDarkLight)
	-- body
	if self.pLayStar then
		showStarLayer(self.pLayStar, _nAll, _nCur, _tDarkLight)
	end
end

--移除星星层
function IconGoods:removeStarLayer(  )
	-- body
	if self.pLayStar then
		self.pLayStar:removeSelf()
		self.pLayStar = nil
	end
end

--初始化左上角层
function IconGoods:initLeftTopLayer( )
	-- body
	if not self.pLayLeftTop then
		self.pLayLeftTop = MUI.MLayer.new()
		self.pLayLeftTop:setBackgroundImage("#v1_img_black50.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})
		self.pLayBgQuality:addView(self.pLayLeftTop,30)
		self.pLayLeftTop:setPositionY(80)
		--内容label
		local pLabel = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    })
		pLabel:setName("lb_left_top")
		pLabel:setPositionY(12)
		self.pLayLeftTop:addView(pLabel)
	end
end

--展示左上角层
--_sStr：左上角展示的字符串
function IconGoods:showLeftTopLayer( _sStr )
	-- body
	if not self.pLayLeftTop then
		self:initLeftTopLayer()
	end
	local pLabel = self.pLayLeftTop:findViewByName("lb_left_top")
	if pLabel then
		pLabel:setString(_sStr)
		--动态设置位置
		local nWidth = pLabel:getWidth()
		if nWidth < 30 then
			nWidth = 30
		end
		self.pLayLeftTop:setLayoutSize(nWidth + 4, 24)
		--动态设置位置
		self.pLayLeftTop:setPositionX(6)
		pLabel:setPositionX(self.pLayLeftTop:getWidth() / 2)
	end
end

--移除左上角层
function IconGoods:removeLeftTopLayer(  )
	-- body
	if self.pLayLeftTop then
		self.pLayLeftTop:removeSelf()
		self.pLayLeftTop = nil
	end
end

--设置icon点击回调
function IconGoods:setIconClickedCallBack( _handler )
	-- body
	self._nHandlerClicked = _handler
end

--点击事件
function IconGoods:onIconClicked( pView )
	-- body
	if self._nHandlerClicked then
		if self.tCurData then
			self._nHandlerClicked(self.tCurData)
		else
			if self.nCliskTy and self.nIndex then
				self._nHandlerClicked(self.nCliskTy,self.nIndex)
			else
				self._nHandlerClicked()
			end
		end
	else
		print("物品icon点击事件")

		if not self.tCurData then
			return
		end
		if self.tCurData.nGtype == e_type_goods.type_hero then
			self:onClickHeroed()
		else
			openIconInfoDlg(pView,self.tCurData)
		end

	end
end

--设置是否可以点击icon
function IconGoods:setIconIsCanTouched( _bEnbaled )
	-- body
	self.pLayBase:setViewTouched(_bEnbaled)
end

--设置icon缩放值
function IconGoods:setIconScale( _fScale )
	-- body
	self:setScale(_fScale)
	if self.pLbMore then
		--self.pLbMore:setScale(1 / _fScale)
	end
end

--移除品质框特效
function IconGoods:removeQualityTx(  )
	-- body
	removeBgQualityTx(self.pLayBgQuality)
end

--更新物品展示
function IconGoods:updateItemInfo( )
	-- body
	if not self.tCurData then
		return
	end
	--设置icon
	self:setIconImg(self.tCurData.sIcon)
	--设置Icon标签
	self:setSideIcon(self.tCurData.sSideIcon)
	--设置品质
	setBgQuality(self.pLayBgQuality,self.tCurData.nQuality,self.bShowQualityTx)
	--数量层隐藏	
	self:setIsShowNumber(false)
	--头像标签

	--设置名称
	self:setMoreText(self.tCurData.sName)
	self:setMoreTextColor(getColorByQuality(self.tCurData.nQuality))
end

--更新物品展示
function IconGoods:updateItemInfoWithNum(  )
	-- body
	if not self.tCurData then
		return
	end
	--设置icon
	self:setIconImg(self.tCurData.sIcon)
	--设置Icon标签
	self:setSideIcon(self.tCurData.sSideIcon)	
	--设置品质
	setBgQuality(self.pLayBgQuality,self.tCurData.nQuality,self.bShowQualityTx)
	--数量层隐藏		
	self:setIsShowNumber(true)
	self:setNumber(self.tCurData.nCt)
	--设置名称
	self:setMoreText(self.tCurData.sName)
	self:setMoreTextColor(getColorByQuality(self.tCurData.nQuality))
end

--更新头像
function IconGoods:updateHeaderInfo(  )
	-- body	
	if not self.tCurData then
		return
	end
	local tNpcData = nil
	if self.tCurData.getNpcData then 
		tNpcData = self.tCurData:getNpcData()
	end
	if tNpcData then
		self:removeBoxTx()
		--设置icon
		self:setIconImg(self.tCurData.sIcon)
		self:setIconBg(nil)
		setBgQuality(self.pLayBgQuality,tNpcData.nQuality)
	else
		self:updateBoxTx()--刷新头像框特效
		--设置icon
		self:setIconImg(self.tCurData.sIcon)
		--设置头像框
		self:setIconBg(self.tCurData.sIconBg)
	end
	--数量层隐藏		
	self:setIsShowNumber(false)
end

--更新聊天玩家头像
function IconGoods:updateChatPlayerInfo()

	if not self.tCurData then
		return
	end

	--设置icon
	if self.tCurData.sIcon then
		self:setIconImg(self.tCurData.sIcon)
	end
	--设置品质
	self.tCurData.nQuality = 100 --默认
	setBgQuality(self.pLayBgQuality,self.tCurData.nQuality)

	--数量层隐藏		
	self:setIsShowNumber(false)

	--显示等级
	-- --设置等级
	-- if self.tCurData.nLv then
	-- 	self:showLeftTopLayer(self.tCurData.nLv)
	-- else
	-- 	self:removeLeftTopLayer()
	-- end
end
--更新头像框
function IconGoods:updateItemBox(  )
	-- body	
	if not self.tCurData then
		return
	end
	self:updateBoxTx()--刷新头像框特效
	if self.nType == TypeIconGoods.NORMAL then       --普通类型
		self.pLayBgQuality:setPositionY(0)
	elseif self.nType == TypeIconGoods.HADMORE then  --带底部信息
		self.pLayBgQuality:setPositionY(40)
	end	
	--不显示头像
	self:setIconImg("ui/daitu.png")
	--设置icon

	if self.tCurData.sIcon then
		self.pLayBgQuality:setBackgroundImage(self.tCurData.sIcon)
	end

	--数量层隐藏		
	self:setIsShowNumber(false)	
end

--更新皇城战图标
function IconGoods:updateTechInfo(  )
	if not self.tCurData then
		return
	end
	--设置icon
	self:setIconImg(self.tCurData.sIcon)
	local nQuality = self.tCurData.nQuality or 3
	--设置品质
	setBgQuality(self.pLayBgQuality,nQuality)
	--数量层隐藏	
	self:setIsShowNumber(false)

	--设置名称
	self:setMoreText(self.tCurData.sName)
	self:setMoreTextColor(getColorByQuality(nQuality))
end


--更新科技树item
function IconGoods:updateTnolyTree()
	if not self.tCurData then
		return
	end
	--设置icon
	self:setIconImg(self.tCurData.sIcon)
	--设置品质
	setBgQuality(self.pLayBgQuality,self.tCurData.nQuality,self.bShowQualityTx)
	--设置段数
	local sStrNum = ""
	local tNextLimitData = self.tCurData:getNextLimitData()	
	if tNextLimitData then
		sStrNum = self.tCurData.nCurIndex .. "/" .. tNextLimitData.section		
	else
		sStrNum = self.tCurData.nCurIndex .. "/" .. self.tCurData.nCurIndex
	end
	self:setIsShowNumber(true)
	self.pLbNum:setString(sStrNum, false)
	local nWidth = self.pLbNum:getWidth()
	if nWidth < 30 then
		nWidth = 30
	end
	self.pLayNum:setLayoutSize(nWidth + 4, self.pLayNum:getHeight())
	--动态设置位置
	self.pLayNum:setPositionX(self.pLayBgQuality:getWidth() - self.pLayNum:getWidth() - 6)
	self.pLbNum:setPositionX(self.pLayNum:getWidth() / 2)


	--设置等级
	self:showLeftTopLayer(getLvString( self.tCurData.nLv , false))	
	
	--设置名称
	self:setMoreText(self.tCurData.sName)
end

--更新英雄状态数据
function IconGoods:updateHeroInfo()
	if not self.tCurData then
		return
	end

	-- if self.tCurData.nHave then
	-- 	if self.tCurData.nHave == 1 then
	-- 		self:setToGray( true)
	-- 		self:setMoreTextColor(_cc.gray)
	-- 	else
	-- 		self:setToGray( false)
	-- 		self:setMoreTextColor(getColorByQuality(self.tCurData.nQuality))
	-- 	end
	-- end

	if type(self.tCurData) == "table" then
		setBgQuality(self.pLayBgQuality,self.tCurData.nQuality)

		self:addStar()
		self:setMoreText(self.tCurData.sName .. getLvString( self.tCurData.nLv , true))
		self:setIconImg(self.tCurData.sIcon)
		self:addImgAction()
		self:setIsShowNumber(false)
		if self.tCurData.nIg == 1 then
			self.pImgIg:setCurrentImage("#v2_fonts_shen.png") 
			self.pImgIg:setVisible(true)
		else
			self.pImgIg:setVisible(false)
		end
		
	end

end

--显示英雄资质
function IconGoods:showHeroTalent(_bVisible)
	if not self.tCurData then
       return
	end
	if _bVisible then
		if not self.pTalentInfo then
			self.pTalentInfo = ItemShgunTalent.new(self.tCurData)
			self.pLayBgQuality:addView(self.pTalentInfo,21)
		else
			self.pTalentInfo:setVisible(true)
		end
	else
		if self.pTalentInfo then
			self.pTalentInfo:setVisible(false)
		end
	end
end

--英雄按钮点击
function IconGoods:onClickHeroed()
	if self.tCurData then
		local tObject = {}
		tObject.nType = e_dlg_index.heroinfo --dlg类型
		tObject.tData = self.tCurData
		tObject.bShowBaseData = true
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

-------------装备相关
--显示底部富文本
function IconGoods:setBottomRichText( tConTable, fontSize )
	if not self.pBottomText then
		if not fontSize then
			fontSize = 20
		end
		self.pBottomText = MUI.MLabel.new({text = "", size = fontSize})
		self.pLayMore:addView(self.pBottomText)
	-- else
	-- 	for i=1,#tConTable.tLabel do
	-- 		self.pBottomText:setLabelCnCr(i, tConTable.tLabel[i][1], tConTable.tLabel[i][2]) 
	-- 	end
	end
	
	self.pBottomText:setString(tConTable)
	local fX = self.pLayMore:getContentSize().width/2
	self.pBottomText:setPosition(fX, -self.pBottomText:getContentSize().height/2)
end

-------------装备相关

--设置折扣文本
--sStr
function IconGoods:setDiscount( sStr, nsize )
	local nFontSize = nsize or 20
	if sStr then
		if not self.pImgDiscount then
			self.pImgDiscount =  MUI.MImage.new("#v1_img_xinpin.png")
			self.pImgDiscount:setAnchorPoint(0,1)
	 		self:addView(self.pImgDiscount,99)
	 		self.pImgDiscount:setPosition(0,self:getContentSize().height)
		else
			self.pImgDiscount:setVisible(true)
		end
		if not self.pTxtDiscount then
			self.pTxtDiscount = MUI.MLabel.new({text = sStr, size = nFontSize})
			self.pTxtDiscount:setRotation(-45)
			self.pTxtDiscount:setAnchorPoint(0.5,0.5)
	 		self:addView(self.pTxtDiscount,100)
	 		self.pTxtDiscount:setPosition(27, self:getHeight() - 20)
		else
			self.pTxtDiscount:setSystemFontSize(nFontSize)
			self.pTxtDiscount:setVisible(true)
		end
	else
		if self.pImgDiscount then
			self.pImgDiscount:setVisible(false)
		end
		if self.pTxtDiscount then
			self.pTxtDiscount:setVisible(false)
		end
	end
end

--设置为锁住状态
function IconGoods:setLockedState()
	-- body
	self.pImgIcon:setVisible(true)
	setBgQuality(self.pLayBgQuality,2)

	--暂时先使用代图
	self:setIconImg("ui/daitu.png")
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
	self:setIsShowNumber(false)
	self:addImgAction()
end

--设置为加号状态
function IconGoods:setAddState(  )
	self.pImgIcon:setVisible(true)
	self:setIconImg("#v1_btn_tianjia.png")
	setBgQuality(self.pLayBgQuality,2)
	self:setIsShowNumber(false)
	self:addImgAction()
end



--移除锁住层
function IconGoods:removeLockedState(  )
	-- body
	if self.pLayLocked then
		self.pLayLocked:removeSelf()
		self.pLayLocked = nil
	end
end

--设置兵种
function IconGoods:setHeroType(  )
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
function IconGoods:removeHeroType(  )
	-- body
	if self.pImgHeroType then
		self.pImgHeroType:removeSelf()
		self.pImgHeroType = nil
	end
end

--设置星星层
function IconGoods:addStar()
	if self.tCurData and (type(self.tCurData) == "table") then		
		if not self.pAttrStart then
			self.pAttrStart = StarAttrLayer.new(0, 0.6)
			self.pLayBgQuality:addView(self.pAttrStart, 20)
			--设置位置
			self.pAttrStart:setPosition(self.pAttrStart:getWidth()/2,self.pAttrStart:getHeight()/2)
		end
		if self.tCurData.tSoulStar then
			self.pAttrStart:updateSoulStar(self.tCurData.tSoulStar)
			--设置位置
			self.pAttrStart:setPosition(self.pLayBgQuality:getWidth()/2 - self.pAttrStart:getWidth()/2, 6)
		end
	else
		print("self.tCurData is nil")
		self:removeStar()
	end
end

--移除星星
function IconGoods:removeStar(  )
	-- body
	if self.pAttrStart then
		self.pAttrStart:removeSelf()
		self.pAttrStart = nil
	end
end

--设置icon图片   _nOffsetWidth 宽的偏移量
function IconGoods:setIconImg(_img,_nOffsetWidth)
	-- body
	local nOffsetWidth = _nOffsetWidth or 0
	if _img then
		self.pImgIcon:setCurrentImage(_img)
		self.pImgIcon:setScale((__nItemWidth + nOffsetWidth)/ self.pImgIcon:getWidth())
	end
end
--设置标签
function IconGoods:setSideIcon( _sTitle )
	-- body
	if _sTitle and type(_sTitle) == "string" then
		if not self.pLbSideIcon then			
			--内容label
			local pLabel = MUI.MLabel.new({
			    text = _sTitle,
			    size = 16,
			    anchorpoint = cc.p(0.5, 0.5),
			    })
			pLabel:setName("lb_side_icon")
			setTextCCColor(pLabel, _cc.kyellow)
			pLabel:setPosition(self.pLayBgQuality:getWidth()/2 + 8, self.pLayBgQuality:getHeight() - 23)	
			pLabel:enableOutline(getC4B(_cc.byellow), 1)		
			self.pLbSideIcon = pLabel
			self.pLayBgQuality:addView(self.pLbSideIcon, 100)			
		else			
			self.pLbSideIcon:setString(_sTitle, false)
		end
	else
		if self.pLbSideIcon then
			self.pLbSideIcon:removeSelf()
			self.pLbSideIcon = nil
		end
	end
end

-- addImgAction 添加按钮图片动作
function IconGoods:addImgAction()
	-- body

	if (self.nCliskTy and self.nCliskTy == TypeIconHero.ADD) then

			self.pImgIcon:setToGray(false)
			-- self.pLayBgQuality:setToGray(true)
			local pScaleTo1 = cc.ScaleTo:create(0.5, 0.6)
			local pFadeTo1 = cc.FadeTo:create(0.5, 255*0.85)
			local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1)

			local pScaleTo2 = cc.ScaleTo:create(0.5,0.8)
			local pFadeTo2 = cc.FadeTo:create(0.5, 255)
			local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)
			setBgQuality(self.pLayBgQuality,2)

			self.pImgIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(action1,action2)))

	else
		self.pImgIcon:setToGray(false)
		self.pImgIcon:stopAllActions()
		self.pImgIcon:setScale(__nItemWidth / self.pImgIcon:getWidth())
	end

end

--移除添加特效动作
function IconGoods:stopAddImgAction()
	self.pImgIcon:setToGray(true)
	setBgQuality(self.pLayBgQuality,1)
	self.pImgIcon:stopAllActions()
	self.pImgIcon:setScale(__nItemWidth / self.pImgIcon:getWidth())
end



--设置品质框图片
function IconGoods:setIconBg(_img)
	-- body
	if _img and type(_img) == "string" then
		if not self.pImgBox then
			self.pLayBgQuality:setBackgroundImage("ui/daitu.png")
			self.pImgBox = MUI.MImage.new(_img)			
			self.pLayBgQuality:addView(self.pImgBox, 10)
		else
			self.pImgBox:setCurrentImage(_img)		
		end
		local nX = self.pLayBgQuality:getWidth()/2
		local nY = self.pLayBgQuality:getHeight()/2	
		self.pImgBox:setPosition(nX, nY)
	else	
		if self.pImgBox then
			self.pImgBox:removeSelf()
			self.pImgBox = nil
		end
	end
end

--设置头像框称号
function IconGoods:setIconTitleImg(_img)
	-- body
	if _img and type(_img) == "string" then
		if not self.pImgTitle then
			self.pLayBgQuality:setBackgroundImage("ui/daitu.png")
			self.pImgTitle = MUI.MImage.new(_img)			
			self.pLayBgQuality:addView(self.pImgTitle, 10)
		else
			self.pImgTitle:setCurrentImage(_img)		
		end
		local nX = self.pLayBgQuality:getWidth()/2
		local nY = 0 - self.pImgTitle:getHeight()/2 - 5
		self.pImgTitle:setPosition(nX, nY)

		self.pImgTitle:setViewTouched(true)
		self.pImgTitle:setIsPressedNeedScale(false)
		self.pImgTitle:onMViewClicked(function ( ... )
			-- body
			local tObject = {}
			tObject.nType = e_dlg_index.dlgiconsetting --dlg类型
			tObject.nPage = 3
			sendMsg(ghd_show_dlg_by_type,tObject)
		end)
	else	
		if self.pImgTitle then
			self.pImgTitle:removeSelf()
			self.pImgTitle = nil
		end
	end
end

function IconGoods:isShowHeaderTitle(  )
	-- body
	return self.pImgTitle ~= nil
end

function IconGoods:removeIconBg( )
	-- body
	self:removeQualityTx()
	self.pLayBgQuality:setBackgroundImage("ui/daitu.png")
end

--设置夺宝转盘选中图先
function IconGoods:setTurntableSelectedImg( bIsShow )
	if bIsShow then
		if not self.pSelectedImg then
			self.pSelectedImg = MUI.MImage.new("#v1_img_truqrjfi.png")
			-- self.pSelectedImg = MUI.MImage.new("#sg_htyl_x_gks_001.png")
			
			--self.pSelectedImg:setAnchorPoint(0, 0)
			local nX = self.pLayBgQuality:getPositionX() + self.pLayBgQuality:getWidth()/2
			local nY = self.pLayBgQuality:getPositionY() + self.pLayBgQuality:getHeight()/2
			self.pSelectedImg:setPosition(nX, nY)
			self.pLayBase:addView(self.pSelectedImg, 99)
			--centerInView(self.pLayBase, self.pSelectedImg)
			self.pSelectedImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		else
			self.pSelectedImg:setVisible(true)
		end
	else
		if self.pSelectedImg then
			self.pSelectedImg:setVisible(false)
		end
	end
	self.bIsShow = bIsShow
end


--在icon上加图片
function IconGoods:addImgOnIcon(_img)
	-- body
	if not self.pImgAdd then
		self.pImgAdd =  MUI.MImage.new(_img)
	 	self.pLayBgQuality:addView(self.pImgAdd, 99)
	 	self.pImgAdd:setPosition(self.pImgIcon:getPosition())
	else
		self.pImgAdd:setCurrentImage(_img)
	end
end

--置灰效果(文字和图片都置灰)
function IconGoods:setIconToGray( _state )
	-- body
	self:setToGray(_state)
	--加在上面的图片不置灰
	if self.pImgAdd then
		self.pImgAdd:setToGray(false)
	end
	if self.pLbMore and _state then
		setTextCCColor(self.pLbMore, _cc.gray)
	end
	--隐藏品质特效
	self:setIsShowBgQualityTx(not _state)
end

--设置显示品质特效(只对普通物品和科技有效)
function IconGoods:setIsShowBgQualityTx( _bShow )
	-- body
	self.bShowQualityTx = _bShow or false
	if self.tCurData == nil then return end

	setBgQuality(self.pLayBgQuality,self.tCurData.nQuality,self.bShowQualityTx)
end

function IconGoods:setIconSelected( _bSelected ,_bIsShowEffect)
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

function IconGoods:showSelectedEffect( )
	-- body

	if self.pImgSelected and self.pImgSelected:isVisible() then
		local fadeTo1 = cc.FadeTo:create(1, 120)
		local fadeTo2 = cc.FadeTo:create(1, 255)
		self.pImgSelected:runAction(cc.RepeatForever:create(cc.Sequence:create(fadeTo1, fadeTo2)))
	end

end

--刷新头像特效 self.pBoxTX
function IconGoods:updateBoxTx(  )
	-- body	
	--dump(self.tCurData, "self.tCurData", 100)
	if self.nShowType == type_icongoods_show.header then --玩家头像
		self.pBoxTX = getPlayerBoxTx(self.pLayBgQuality, self.tCurData.sB, self.pLayBgQuality:getWidth()/2, self.pLayBgQuality:getHeight()/2, 100)
	elseif self.nShowType == type_icongoods_show.box then
		self.pBoxTX = getPlayerBoxTx(self.pLayBgQuality, self.tCurData.sTid, self.pLayBgQuality:getWidth()/2, self.pLayBgQuality:getHeight()/2, 100)
	end 
end

function IconGoods:removeBoxTx(  )
	-- body
	if self.pBoxTX then
		self.pBoxTX:removeSelf()
		self.pBoxTX = nil
	end	
end

--左上角
function IconGoods:addCountryFlag( nCountry )
	local sImg = WorldFunc.getCountryFlagImg(nCountry)
	if not self.pImgCountryFlag then
		self.pImgCountryFlag = MUI.MImage.new(sImg)
		local pSize = self.pImgCountryFlag:getContentSize()
		self.pImgCountryFlag:setPosition(0 + pSize.width/2, self.pLayBgQuality:getContentSize().height - pSize.height/2 + 5)
		self.pLayBgQuality:addView(self.pImgCountryFlag, 20)
	else
		self.pImgCountryFlag:setCurrentImage(sImg)
	end
end

function IconGoods:removeCountryFlag(  )
	if self.pImgCountryFlag then
		self.pImgCountryFlag:removeSelf()
		self.pImgCountryFlag = nil
	end	 
end


return IconGoods