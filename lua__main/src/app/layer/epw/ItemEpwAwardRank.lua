----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-27 15:23:00
-- Description: 皇城战 皇城战排行子节点
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemEpwAwardRank = class("ItemEpwAwardRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemEpwAwardRank:ctor(  )
	--解析文件
	parseView("item_epw_award_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemEpwAwardRank:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemEpwAwardRank", handler(self, self.onItemEpwAwardRankDestroy))
end

-- 析构方法
function ItemEpwAwardRank:onItemEpwAwardRankDestroy(  )
    self:onPause()
end

function ItemEpwAwardRank:regMsgs(  )
end

function ItemEpwAwardRank:unregMsgs(  )
end

function ItemEpwAwardRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemEpwAwardRank:onPause(  )
	self:unregMsgs()
end

function ItemEpwAwardRank:setupViews(  )
	self.pTxtTitle = self:findViewByName("txt_title")
	self.pListView = self:findViewByName("lay_listview")
end

function ItemEpwAwardRank:updateViews(  )
	if not self.tData then
		return
	end
	if self.tData.nRank1 == self.tData.nRank2 then
		self.pTxtTitle:setString(string.format(getConvertedStr(3, 10723), self.tData.nRank1))
	else
		self.pTxtTitle:setString(string.format(getConvertedStr(3, 10724), self.tData.nRank1, self.tData.nRank2))
	end
	gRefreshHorizontalList(self.pListView, self.tGoodsList, 10, 35)
end

function ItemEpwAwardRank:setData( tData )
	self.tData = tData
	self.tGoodsList = {}
	if self.tData and self.tData.tGoods then
		for i=1,#self.tData.tGoods do
			local k = self.tData.tGoods[i].k
			local v = self.tData.tGoods[i].v
			local tGoods = getGoodsByTidFromDB(k)
			if tGoods then
				tGoods.nCt = v
				table.insert(self.tGoodsList, tGoods)
			end
		end
	end
	self:updateViews()
end

return ItemEpwAwardRank


