-- Author: xiesite
-- Date: 2018-03-14 14:27:56
-- 英雄经验升级item

local MCommonView = require("app.common.MCommonView")
local ItemFubenChapterReward = class("ItemFubenChapterReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local SPLVTYPE = {
	recruit = 1, --招募
	countryWp = 2, --国器
	resource = 3,  --资源(补给)
	equip =  4, --装备
	drawing = 5, --图纸

}

--_index 下标 _type 类型
function ItemFubenChapterReward:ctor()
	-- body
	self:myInit()

	parseView("item_fuben_chapter_reward", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemFubenChapterReward",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenChapterReward:myInit()
 
end

--解析布局回调事件
function ItemFubenChapterReward:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemFubenChapterReward:setupViews( )
	
end

-- 修改控件内容或者是刷新控件数据
function ItemFubenChapterReward:updateViews( )
	if not self.pData then
		return
	end

	--是招募的话用蒙版
	if self.pData.nType == SPLVTYPE.recruit or self.pData.nType == SPLVTYPE.equip then
		if self.pImContent then
			self.pImContent:setVisible(false)
		end
		if not self.clippingNode then
			local stencil = display.newSprite("#radius.png")
			stencil:setScale(0.95)
			self.clippingNode = cc.ClippingNode:create()
			self.clippingNode:setStencil(stencil)
			self.clippingNode:setAlphaThreshold(0.5);
			self.clippingNode:setAnchorPoint(cc.p(0.5,0.5))
			self.clippingNode:setPosition(cc.p(35,35))
			local pImContent = MUI.MImage.new(self.pData.sIcon)
			pImContent:setScale(0.6)
			self.clippingNode.pImContent = pImContent
			if self.clippingNode.addView then
				self.clippingNode:addView(pImContent)
			else
				self.clippingNode:addChild(pImContent)
			end
			if self.pData and self.pData.sIcon then
				pImContent:setCurrentImage(self.pData.sIcon)
			end

			self:addView(self.clippingNode, 999)
		else
			self.clippingNode:setVisible(true)
			if self.pData and self.pData.sIcon then
				self.clippingNode.pImContent:setCurrentImage(self.pData.sIcon)
			end
		end
	else
		if self.clippingNode then
			self.clippingNode:removeFromParent(true)
			self.clippingNode = nil
		end		
		if not self.pImContent then
			self.pImContent = MUI.MImage.new(self.pData.sIcon)
			self.pImContent:setScale(0.6)
			self.pImContent:setPosition(cc.p(35,35))
			self:addView(self.pImContent, 999)
		else
			self.pImContent:setVisible(true)
			if self.pData and self.pData.sIcon then
				self.pImContent:setCurrentImage(self.pData.sIcon)
			end
		end
	end
 
end

--析构方法
function ItemFubenChapterReward:onDestroy( )
 
end

--设置数据 _data
function ItemFubenChapterReward:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:updateViews()
end

return ItemFubenChapterReward