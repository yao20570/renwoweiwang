-- Author: liangzhaowei
-- Date: 2017-05-10 10:22:45
-- 椭圆形开关 (64*28)

local MCommonView = require("app.common.MCommonView")
local MOvalSw = class("MOvalSw", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数  _nState 开关状态 0为关闭状态
function MOvalSw:ctor(_nState)
	-- body
	self:myInit()

	self.nState = _nState or 0

	parseView("item_oval_sw", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("MOvalSw",handler(self, self.onDestroy))
	
end


--解析布局回调事件
function MOvalSw:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	--img
	self.pImgOpen = self:findViewByName("img_open")--开关底图
	self.pImgCircle = self:findViewByName("img_circle") --圆点

	--ly
	self.pLyMain = self:findViewByName("ly_main") --主层



	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)

	self:setViewTouched(true)
	self:onMViewClicked(handler(self, self.onViewClicked))

	self:setupViews()
	self:updateViews()
end


--初始化参数
function MOvalSw:myInit()
	self.pData = {} --数据
	self.nState = 0 --关闭状态
	self.pHandler = nil --回调
end

--设置回调
function MOvalSw:setHandler(_handler)
	if _handler then
		self.pHandler = _handler
	end
end

--按钮回调
function MOvalSw:onViewClicked(pView)


	if self.pHandler then
		self:pHandler()
	end
end

--初始化控件
function MOvalSw:setupViews( )
	if self.nState == 0 then
		self.pImgCircle:setPositionX(14)
		self.pImgOpen:setCurrentImage("#v1_img_meikaiqi.png")
	elseif self.nState == 1 then
		self.pImgCircle:setPositionX(51)
		self.pImgOpen:setCurrentImage("#v1_img_kaiqidi.png")
	end
end

--设置状态
function MOvalSw:setState(_nType)

	if _nType ==  0 or _nType == 1 then
		self.nState = _nType
	else
		return
	end	

	if self.nState == 0 then
		self.pImgCircle:setPositionX(51)
		self.pImgOpen:setCurrentImage("#v1_img_kaiqidi.png")

		doDelayForSomething(self, function( )
			self.pImgCircle:runAction(cc.MoveTo:create(0.1, cc.p(14,self.pImgCircle:getHeight()/2)))
			self.pImgOpen:setCurrentImage("#v1_img_meikaiqi.png")
		end, 0.1)			
	elseif self.nState == 1 then
		self.pImgCircle:setPositionX(14)
		self.pImgOpen:setCurrentImage("#v1_img_meikaiqi.png")
		doDelayForSomething(self, function( )
			self.pImgCircle:runAction(cc.MoveTo:create(0.1, cc.p(51,self.pImgCircle:getHeight()/2)))
			self.pImgOpen:setCurrentImage("#v1_img_kaiqidi.png")
		end, 0.1)	
	end	
end

-- 修改控件内容或者是刷新控件数据
function MOvalSw:updateViews(  )
	
end



--析构方法
function MOvalSw:onDestroy(  )
end




return MOvalSw