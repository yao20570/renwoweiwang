----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-21 14:52:00
-- Description: 自定义单选按钮
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local RadioBtn = class("RadioBtn", function()
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5, 0.5)
	return pView
end)

function RadioBtn:ctor( sBgImg, sSelectedImg )
	local pImgBg = MUI.MImage.new(sBgImg)
	self.pImgSelected = MUI.MImage.new(sSelectedImg)
	local nWidth = math.max(pImgBg:getContentSize().width, self.pImgSelected:getContentSize().width)
	local nHeight = math.max(pImgBg:getContentSize().height, self.pImgSelected:getContentSize().height)
	self:setContentSize(cc.size(nWidth, nHeight))
	self:addView(pImgBg)
	self:addView(self.pImgSelected)
   	centerInView(self, pImgBg)
   	centerInView(self, self.pImgSelected)
   	self.pImgSelected:setVisible(false)
   	self.bIsSelected = false

   	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onLayClicked))
end

function RadioBtn:setSelectedHandler( nHandler )
	self.nSelectedHandler = nHandler
end

function RadioBtn:setSelected( bIsSelected )
	if self.bIsSelected ~= bIsSelected then
		self.bIsSelected = bIsSelected
		self.pImgSelected:setVisible(self.bIsSelected)
	end
end

function RadioBtn:getIsSelected()
	return self.bIsSelected
end

function RadioBtn:onLayClicked( pView )
	if self.bIsSelected then
		return
	end
	self:setSelected(not self.bIsSelected)
	self.pImgSelected:setVisible(self.bIsSelected)
	if self.nSelectedHandler then
		self.nSelectedHandler(self)
	end
end

return RadioBtn
 	