----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 17:18:28
-- Description: 道具商店 道具集
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemShopItem = require("app.layer.shop.ItemShopItem")

local ItemShopItems = class("ItemShopItems", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--tShopBaseList:商品列表
function ItemShopItems:ctor( tShopBaseList )
	self.tShopBaseList = tShopBaseList

	--新建层
	local nWidth = 580
	local nHeight = 0
	local pView = MUI.MLayer.new()
	--local nOffsetH = 40
	local nOffsetH = 60
	local nItemWidth = nWidth/4	
	local nRow = math.ceil(#self.tShopBaseList/4)
	local nItemHeight = 170 + nOffsetH
	nHeight = nItemHeight
	if nRow > 0 then
		nHeight = nItemHeight * nRow
	end
	
	pView:setContentSize(cc.size(nWidth, nHeight))

	local nBeginX, nBeginY = 10, nHeight - nItemHeight
	self.nBeginX = nBeginX
	self.nBeginY = nBeginY
	--分侦
	self.nItemIndex = 1
	self.nAddcheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
		local tData = self.tShopBaseList[self.nItemIndex]
		if tData then
			local pItemShopItem = ItemShopItem.new(tData)
			local pUiSize = pItemShopItem:getContentSize()
			local nOffestX = (nItemWidth - pUiSize.width)/2
			local nOffsetY = (nItemHeight - pUiSize.height)/2
			pItemShopItem:setPosition(self.nBeginX + nOffestX, self.nBeginY + nOffsetY)
			pView:addView(pItemShopItem)
			if self.nItemIndex%4 == 0 then
				self.nBeginX = 10
				self.nBeginY = self.nBeginY - nItemHeight
			else
				self.nBeginX = self.nBeginX + nItemWidth
			end
		end
    	self.nItemIndex = self.nItemIndex + 1
    	if self.nItemIndex > #self.tShopBaseList then
    		if self.nAddcheduler then
	            MUI.scheduler.unscheduleGlobal(self.nAddcheduler)
	            self.nAddcheduler = nil
	        end
    	end
    end)

	-- for i=1,#self.tShopBaseList do
	-- 	local pItemShopItem = ItemShopItem.new(self.tShopBaseList[i])
	-- 	local pUiSize = pItemShopItem:getContentSize()
	-- 	local nOffestX = (nItemWidth - pUiSize.width)/2
	-- 	local nOffsetY = (nItemHeight - pUiSize.height)/2
	-- 	pItemShopItem:setPosition(nBeginX + nOffestX, nBeginY + nOffsetY)
	-- 	pView:addView(pItemShopItem)
	-- 	if i%4 == 0 then
	-- 		nBeginX = 10
	-- 		nBeginY = nBeginY - nItemHeight
	-- 	else
	-- 		nBeginX = nBeginX + nItemWidth
	-- 	end
	-- end

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemShopItems", handler(self, self.onItemShopItemsDestroy))

end
-- 析构方法
function ItemShopItems:onItemShopItemsDestroy(  )
    self:onPause()
    if self.nAddcheduler then
        MUI.scheduler.unscheduleGlobal(self.nAddcheduler)
        self.nAddcheduler = nil
    end
end

function ItemShopItems:regMsgs(  )
end

function ItemShopItems:unregMsgs(  )
end

function ItemShopItems:onResume(  )
	self:regMsgs()
end

function ItemShopItems:onPause(  )
	self:unregMsgs()
end

function ItemShopItems:setupViews(  )
	-- self.pLayWorld = self:findViewByName("lay_world")
end

function ItemShopItems:updateViews(  )
	
end

return ItemShopItems


