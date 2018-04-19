-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime:  2018-02-06 20:32:0 星期二
-- Description: 伤害排名
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemTLBossAward = class("ItemTLBossAward", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTLBossAward:ctor( )
	-- body	
	self:myInit()	
	parseView("item_tboss_award", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemTLBossAward:myInit()
end

--解析布局回调事件
function ItemTLBossAward:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemTLBossAward",handler(self, self.onItemTLBossAwardDestroy))
end

--初始化控件
function ItemTLBossAward:setupViews( )
	self.pTxtTitle = self:findViewByName("txt_title")
	self.pListView = self:findViewByName("lay_listview")
end

-- 修改控件内容或者是刷新控件数据
function ItemTLBossAward:updateViews( )
	if not self.tData then
		return
	end
	if self.tData.tKillDrop then
		self.pTxtTitle:setString(getConvertedStr(3, 10836))
	elseif self.tData.nRank then
		self.pTxtTitle:setString(string.format(getConvertedStr(3, 10818), self.tData.nRank))
	end
	gRefreshHorizontalList(self.pListView, self.tGoodsList, 10, 35)
end

-- 析构方法
function ItemTLBossAward:onItemTLBossAwardDestroy( )
end

function ItemTLBossAward:setCurData( tData)
	self.tData = tData
	self.tGoodsList = {}
	if self.tData then
		if self.tData.tKillDrop then
			self.tGoodsList = self.tData.tKillDrop
		elseif self.tData.tGoods then
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
	end
	self:updateViews()
end

return ItemTLBossAward