-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-20 13:52:21 星期四
-- Description: 特殊按钮2 （由一个MLayer和一个MImage拼成的按钮）
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local MSepView = class("MSepView", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_pContainer：存放按钮的父层
--_nType：按钮样式
function MSepView:ctor( _pContainer, _nType )
	-- body
	self:myInit()

	self.pContainer = _pContainer
	self.nType = _nType or self.nType

	self:setupViews()
	self:updateViews()
	--注册析构方法
	self:setDestroyHandler("MSepView",handler(self, self.onMSepViewDestroy))
end

--初始化成员变量
function MSepView:myInit(  )
	-- body
	self.pContainer 		= nil                      --存放按钮的父层
	self.nType 				= TypeSepBtn.PLUS_VIEW     --按钮样式
end

--初始化控件
function MSepView:setupViews( )
	-- body
	--按钮图片
	self.pImgSep = MUI.MImage.new("#v1_img_increase.png")
	self:addView(self.pImgSep)
	--设置背景框
	if self.nType == TypeSepBtn.PLUS_VIEW then 				--蓝色+号
		self:setLayoutSize(50, 50)
		self:setBackgroundImage("#v1_btn_blue4.png")
		self.pImgSep:setCurrentImage("#v1_img_increase.png")
	elseif self.nType == TypeSepBtn.I_VIEW then 			--蓝色i 
		self:setLayoutSize(50, 50)
		self:setBackgroundImage("#v1_btn_blue4.png")
		self.pImgSep:setCurrentImage("#v1_img_rules.png")
	elseif self.nType == TypeSepBtn.OPERATE_VIEW then 			--蓝色操作按钮 
		self:setLayoutSize(50, 50)
		self:setBackgroundImage("#v1_btn_blue4.png")
		self.pImgSep:setCurrentImage("#v1_img_caozuo.png")
	end
	self.pImgSep:setPosition(self:getWidth() / 2, self:getHeight() / 2)
end

-- 修改控件内容或者是刷新控件数据
function MSepView:updateViews(  )
	-- body
end

-- 析构方法
function MSepView:onMSepViewDestroy(  )
	-- body
end

--设置按钮是否可用
function MSepView:setBtnEnable( _bEnabled )
	-- body
	self:setViewEnabled( _bEnabled )
	self.pContainer:setViewEnabled(_bEnabled)
end

return MSepView