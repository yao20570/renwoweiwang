-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-10 10:29:40 星期五
-- Description: 切换卡itemTab
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local FCommonItemTab = class("FCommonItemTab", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- _nMType：1：一级切换卡 2：二级切换卡
--_nType：是否自适配宽度 1：是 2：否
--_nWidth：顶部页签宽度（0的情况下不自动适配宽度）
function FCommonItemTab:ctor( _nMType, _nType, _nWidth )
	-- body
	self:myInit()
	self.nMType = _nMType or 1
	self.nType = _nType or 1
	self.nViewWidth = _nWidth or 0

	if self.nMType == 1 then
		parseView("item_fcommon_tabItem", handler(self, self.onParseViewCallback))
	elseif self.nMType == 2 then
		parseView("item_scommon_tabitem", handler(self, self.onParseViewCallback))
	elseif self.nMType == 3 then
		parseView("item_hcommon_tabItem", handler(self, self.onParseViewCallback))
	end

	
end

--初始化成员变量
function FCommonItemTab:myInit(  )
	-- body
	self.pView 				= 		nil 					--当前布局层
	self.nMType 			=       1 				        --1：一级切换卡 2：二级切换卡
	self.nType 				= 		1 						--是否自适配宽度
	self.nViewWidth 		= 		0 						--自适配宽度（当self.nType == 2的时候该值没作用）
	self.bIsChecked 		= 		false 					--是否选中
end

--解析布局回调事件
function FCommonItemTab:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self.pView = pView
	self:addView(pView, 10)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FCommonItemTab",handler(self, self.onFCommonItemTabDestroy))
end

--初始化控件
function FCommonItemTab:setupViews( )
	-- body

	--设置可点击
	self:setViewTouched(true)
	--关闭缩放特效
	self:setIsPressedNeedScale(false)
	--关闭点击效果
	self:setIsPressedNeedColor(false)
	
	self.pLbTitle 				= 		self:findViewByName("lb_title")
	self.pTabItemBg 			= 		self:findViewByName("viewgroup")
	--设置宽度
	self:setCurLayoutSize()
end

-- 修改控件内容或者是刷新控件数据
function FCommonItemTab:updateViews(  )
	-- body
	-- 默认为不选中
	self:setChecked(false)
end

-- 析构方法
function FCommonItemTab:onFCommonItemTabDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function FCommonItemTab:regMsgs( )
	-- body
end

-- 注销消息
function FCommonItemTab:unregMsgs(  )
	-- body
end


--暂停方法
function FCommonItemTab:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FCommonItemTab:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

-- 设置title
function FCommonItemTab:setTabTitle( _sTitle )
	-- body
	self.pLbTitle:setString(_sTitle or "")
end

-- 获得title
function FCommonItemTab:getTitle(  )
	-- body
	return self.pLbTitle:getString() or ""
end
--设置状态
--_bState(boolean)：false or true
--_selectedImg:选中状态图片
function FCommonItemTab:setChecked( _bState, _selectedImg )
	-- body
	self.bIsChecked = _bState	
	if self.bIsChecked == true then
		if _selectedImg then
			self.pTabItemBg:setBackgroundImage(_selectedImg)
		else
			self.pTabItemBg:setBackgroundImage("#v1_btn_selected_biaoqian2.png")
		end
		setTextCCColor(self.pLbTitle, _cc.white)
	else
		if _selectedImg then
			self.pTabItemBg:setBackgroundImage(_selectedImg)
		else
			self.pTabItemBg:setBackgroundImage("#v1_btn_biaoqian2.png")
		end
		setTextCCColor(self.pLbTitle, _cc.pwhite)
	end
end 

--是否选中
function FCommonItemTab:isChecked(  )
	-- body
	return self.bIsChecked
end

--重新设置控件大小
function FCommonItemTab:resetLayoutSize( _nWidth )
	-- body
	self.nViewWidth = _nWidth or self.nViewWidth
	self:setCurLayoutSize()
end

--设置控件大小
function FCommonItemTab:setCurLayoutSize(  )
	-- body
	if self.nType == 1 then
		self.pTabItemBg:setLayoutSize(self.nViewWidth, self.pView:getHeight() or 0)
		self.pView:setLayoutSize(self.pTabItemBg:getLayoutSize())
	end
	self:setLayoutSize(self.pView:getLayoutSize())
	--设置标题位置
	self.pLbTitle:setPositionX(self:getWidth() / 2)
end

--设置文本颜色
function FCommonItemTab:setLableColor( sColor )
	setTextCCColor(self.pLbTitle, sColor)
end

--显示上锁
function FCommonItemTab:showTabLock( tPos, _nDisX )
	if not self.pImgLock then
		self.pImgLock = MUI.MImage.new("#v2_img_lock_tjp.png")
		-- self.pImgLock:setScale(0.6)
		if tPos then
			self.pImgLock:setPosition(tPos)
		else
			self.pImgLock:setPosition(20, self:getHeight() / 2)
		end
		self.pTabItemBg:addView(self.pImgLock,9)
	end
	if _nDisX then
		self.pLbTitle:setPositionX(self:getWidth() / 2 + _nDisX)
	end
	self.pImgLock:setVisible(true)
end

--隐藏上锁
function FCommonItemTab:hideTabLock()
	if self.pImgLock then
		self.pImgLock:setVisible(false)
		self.pLbTitle:setPositionX(self:getWidth() / 2)
	end
end



--显示正在打造
function FCommonItemTab:showIsMaking()
	-- body
	if not self.pLayMaking then
		self.pLayMaking = MUI.MLayer.new()
		self.pLayMaking:setLayoutSize(50, self:getHeight())
		self.pTabItemBg:addView(self.pLayMaking, 9)
		local pImg = MUI.MImage.new("#v2_fonts_dazaozhong.png")
		self.pLayMaking:addView(pImg)
		pImg:setScale(0.8)
		pImg:setPosition(pImg:getWidth()/2, self.pLayMaking:getHeight()/2 + 3)
	end
	self.pLayMaking:setVisible(true)
end

--隐藏正在打造
function FCommonItemTab:hideIsMaking()
	-- body
	if self.pLayMaking then
		self.pLayMaking:setVisible(false)
	end
end

--返回红点
function FCommonItemTab:getRedNumLayer( )
	local pLayRed = self.pLayRed
	if not pLayRed then
		pLayRed = MUI.MLayer.new()
		self.pLayRed = pLayRed
   		pLayRed:setContentSize(cc.size(26, 26))
   		local pItemSize = self:getContentSize()
   		pLayRed:setPosition(pItemSize.width - 26, pItemSize.height - 26)
   		self:addView(pLayRed, 10)
   	end
   	return self.pLayRed
end

return FCommonItemTab