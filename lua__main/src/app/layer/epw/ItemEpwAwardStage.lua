----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-27 15:23:00
-- Description: 皇城战 皇城战排行子节点
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemEpwAwardStage = class("ItemEpwAwardStage", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemEpwAwardStage:ctor(  )
	--解析文件
	parseView("item_epw_award_stage", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemEpwAwardStage:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemEpwAwardStage", handler(self, self.onItemEpwAwardStageDestroy))
end

-- 析构方法
function ItemEpwAwardStage:onItemEpwAwardStageDestroy(  )
    self:onPause()
end

function ItemEpwAwardStage:regMsgs(  )
end

function ItemEpwAwardStage:unregMsgs(  )
end

function ItemEpwAwardStage:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemEpwAwardStage:onPause(  )
	self:unregMsgs()
end

function ItemEpwAwardStage:setupViews(  )
	self.pTxtTitle = self:findViewByName("txt_title")
	self.pTxtScore = self:findViewByName("txt_score")
	self.pTxtCScore = self:findViewByName("txt_cscore")
	self.pListView = self:findViewByName("lay_listview")
end

function ItemEpwAwardStage:updateViews(  )
	if not self.tData then
		return
	end
	local nMyScore = Player:getImperWarData():getMyWarScore()
	local nCountryScore = Player:getImperWarData():getCountryWarScore()

	local nStage = self.tData.nStage
	self.pTxtTitle:setString(string.format(getConvertedStr(3, 10965), nStage))

	local nScore = self.tData.nScore
	local sColor = nil
	if nMyScore >= nScore then
		sColor = _cc.green
	else
		sColor = _cc.red
	end
	local tStr = {
	    {color=_cc.white,text=getConvertedStr(3, 10966)},
	    {color=sColor,text=getResourcesStr(nScore)},
	}
	self.pTxtScore:setString(tStr)


	local nCScore = self.tData.nCScore
	local sColor = nil
	if nCountryScore >= nCScore then
		sColor = _cc.green
	else
		sColor = _cc.red
	end
	local tStr = {
	    {color=_cc.white,text=getConvertedStr(3, 10964)},
	    {color=sColor,text=getResourcesStr(nCScore)},
	}
	self.pTxtCScore:setString(tStr)
	
	gRefreshHorizontalList(self.pListView, self.tGoodsList, 10, 35)
end

function ItemEpwAwardStage:setData( tData )
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

return ItemEpwAwardStage


