----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-30 13:42:14
-- Description: 世界视图点的文字标签
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DotLabel = class("DotLabel",function ( pTxtHide, pColor )
	pTxtHide:setString("1")
	pTxtHide:updateContent()
	local tChildrens = pTxtHide:getChildren()
	local pTexture = tChildrens[1]:getTexture()
	return cc.BillBoard:createWithTexture(pTexture, cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
end)

function DotLabel:ctor( pTxtHide, pColor)
	self.pTxtHide = pTxtHide
	self.pColor = pColor or getC3B(cc.white)
end

function DotLabel:setString( sStr )
	--是否强制更新
	if self.bIsForceSet then
	else
		if self.sStrPrev == sStr then
			return
		end
	end
	self.sStrPrev = sStr
	self.pTxtHide:setTextColor(self.pColor)
	self.pTxtHide:setString( sStr, false )
	self.pTxtHide:updateContent()
	local tChildrens = self.pTxtHide:getChildren()
	if(tChildrens[1]) then
	    local pTexture = tChildrens[1]:getTexture()
	    self:setTexture(pTexture)
	    --重新设置一下大小
	    self:setTextureRect(cc.rect(0,0,self.pTxtHide:getContentSize().width,self.pTxtHide:getContentSize().height))
	end
	self.bIsNeedUpStr = false
end

function DotLabel:setTextColor( pColor )
	if self.pColor.r ~= pColor.r or 
		self.pColor.g ~= pColor.g or 
		self.pColor.b ~= pColor.b then 
		self.pColor = pColor
		if self.sStrPrev then
			self:setStrigForce(self.sStrPrev)
		end
	end
end

function DotLabel:setStrigForce(sStr)
	self.bIsForceSet = true
	self:setString(sStr)
	self.bIsForceSet = false
end

return DotLabel