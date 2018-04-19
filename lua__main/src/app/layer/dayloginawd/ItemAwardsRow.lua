-- ItemAwardsRow.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-30 13:57:23 星期五
-- Description: 每日登录奖励项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemAwardsRow = class("ItemAwardsRow", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemAwardsRow:ctor(nIndex)
	-- body	
	self:myInit(nIndex)	
	parseView("item_awd_row", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemAwardsRow:myInit(nIndex)
	-- body		
	self.nIndex 			= 	nIndex or 1
	self.tCurData 			= 	nil 				--当前数据	
end

--解析布局回调事件
function ItemAwardsRow:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemAwardsRow",handler(self, self.onItemAwardsRowDestroy))
end

--初始化控件
function ItemAwardsRow:setupViews()
	-- body
	self.pLayRoot = self:findViewByName("lay_row")
	local pLayIcon1 = self:findViewByName("lay_icon1")
	local pLayIcon2 = self:findViewByName("lay_icon2")
	local pLayIcon3 = self:findViewByName("lay_icon3")
	local pLayIcon4 = self:findViewByName("lay_icon4")
	self.pLayIcons = {[1] = pLayIcon1, [2] = pLayIcon2, [3] = pLayIcon3, [4] = pLayIcon4}
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
end

-- 修改控件内容或者是刷新控件数据
function ItemAwardsRow:updateViews()
	if not self.tCurData then return end
	for i = 1, 4 do
		local nIdx = (self.nIndex - 1) * 4 + i
		local tData = self.tCurData[nIdx]
		if tData then
			local tIconData = getGoodsByTidFromDB(tData.k)
			tIconData.nCt = tData.v
			getIconGoodsByType(self.pLayIcons[i], TypeIconGoods.HADMORE, type_icongoods_show.itemnum, tIconData, TypeIconEquipSize.L)
		end
	end
	local nItemCnt = #self.tCurData
	local nWidth = (500 - nItemCnt*110)/(nItemCnt + 1)
	for i = 1, nItemCnt do
		self.pLayIcons[i]:setPositionX(nWidth + (110 + nWidth)*(i-1))		
	end
end

-- 析构方法
function ItemAwardsRow:onItemAwardsRowDestroy()
	-- body
end

function ItemAwardsRow:setItemData(_data)
	self.tCurData = _data
	self:updateViews()
end


return ItemAwardsRow
