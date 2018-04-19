-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-25 16:05:40 星期四
-- Description: 复选Item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemCheck = class("ItemCheck", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCheck:ctor( _sTxt, _bSelected )
	-- body
	self:myInit(_sTxt, _bSelected)	
	
	parseView("item_check", handler(self, self.onParseViewCallback))
	
	
end

--初始化成员变量
function ItemCheck:myInit( _sTxt, _bSelected )
	-- body	
	self.sTxt = _sTxt or ""
	self.bSelected = _bSelected or false
	self.nHandler 			= 	nil 				--回调事件
	self.bIsIconCanTouched 	= 	false
	self.tParam = nil
end

--解析布局回调事件
function ItemCheck:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemCheck",handler(self, self.onItemCheckDestroy))
end

--初始化控件
function ItemCheck:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("item_check")
	self.pImgCheck = self:findViewByName("img_check")
	self.pLbCont = self:findViewByName("lb_cont")
	self.pLbCont:setString(self.sTxt, false)	
	if self.bSelected then
		self.pImgCheck:setCurrentImage("#v2_img_gouxuan.png")
	else
		self.pImgCheck:setCurrentImage("#v2_img_gouxuankuang.png")
	end	
	self:setViewTouched(true)
	self:onMViewClicked(function (  )
		-- body
		self:setItemSelected(self:isItemSelected() ~= true)
		if self.nHandler then
			self.nHandler(self:isItemSelected(), self.tParam)
		end
	end)
	self:setLayoutSize(self.pLbCont:getPositionX() + self.pLbCont:getWidth(), self:getHeight())
end

-- 修改控件内容或者是刷新控件数据
function ItemCheck:updateViews( )
	-- body

end

-- 析构方法
function ItemCheck:onItemCheckDestroy(  )
	-- body
end

--设置点击事件回到
function ItemCheck:onItemClick( _handler)
	-- body
	self.nHandler = _handler
end

function ItemCheck:setItemClickParam( _param )
	-- body
	self.tParam = _param
end
function ItemCheck:setTxt( _sStr )
	-- body
	if not _sStr then
		self.sTxt = _sStr	
		self.pLbCont:setString(self.sTxt, false)	
	end
end

function ItemCheck:setItemSelected( _bSelected )
	-- body
	self.bSelected = _bSelected or false
	if self.bSelected then
		self.pImgCheck:setCurrentImage("#v2_img_gouxuan.png")
	else
		self.pImgCheck:setCurrentImage("#v2_img_gouxuankuang.png")
	end
end

function ItemCheck:isItemSelected(  )
	-- body
	return self.bSelected
end
return ItemCheck