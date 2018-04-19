----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-01-22 16:30:31
-- Description: 推荐信显示item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
					
local ItemBeautyGift = class("ItemBeautyGift", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemBeautyGift:ctor( )
	-- body
	self:myInit()
	parseView("item_beauty_gift", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemBeautyGift:onParseViewCallback( pView )
	self.pView = pView
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemBeautyGift",handler(self, self.onDestroy))
end
--初始化成员变量
function ItemBeautyGift:myInit(  )
	-- body	 
	self.tItemIcons 			= 	{} 				--	是否已经得到
end


function ItemBeautyGift:regMsgs(  )
end

function ItemBeautyGift:unregMsgs(  )
end

function ItemBeautyGift:onResume(  )
	self:regMsgs()
end

function ItemBeautyGift:onPause(  )
	self:unregMsgs()
end


function ItemBeautyGift:onItemPeopleRebateGetRewardDestroy(  )
	self:onPause()
end

function ItemBeautyGift:setupViews(  )
	self.pLyIcons = {}--top层
	for i=1, 5 do
		local icon = self.pView:findViewByName("ly_icon_"..i)

		table.insert(self.pLyIcons , icon)
	end
 	
end

--析构方法
function ItemBeautyGift:onDestroy( )
	-- body
	self:onPause()
end

function ItemBeautyGift:updateViews(  )
 	if self.tData then
		local tGoodsData = getRewardItemsFromSever(self.tData)
		local nItemCnt = #tGoodsData
		for i = 1, 5 do
			if not self.tItemIcons[i] then
				pIconGoods = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum)
				pIconGoods:setScale(0.8)
				pIconGoods:setPositionX(10)
				self.pLyIcons[i]:addView(pIconGoods, 10)
				self.tItemIcons[i] = pIconGoods
			end
			if tGoodsData[i] then
				self.tItemIcons[i]:setVisible(true)
				self.tItemIcons[i]:setCurData(tGoodsData[i])
				addBgQualityTx(self.tItemIcons[i].pLayBgQuality, tGoodsData[i].nQuality)
			else
				removeBgQualityTx(self.tItemIcons[i].pLayBgQuality)
				self.tItemIcons[i]:setVisible(false)
			end
		end	

 	end
end

function ItemBeautyGift:setCurData( _tData )
	self.tData = _tData
	self:updateViews()
end


return ItemBeautyGift


