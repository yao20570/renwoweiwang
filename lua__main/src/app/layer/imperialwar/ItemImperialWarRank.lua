----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-3-17 11:58:00
-- Description: 武王击杀排行 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemImperialWarRank = class("ItemImperialWarRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemImperialWarRank:ctor(  )
	--解析文件
	parseView("item_imperial_war_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemImperialWarRank:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemImperialWarRank", handler(self, self.onItemImperialWarRankDestroy))
end

-- 析构方法
function ItemImperialWarRank:onItemImperialWarRankDestroy(  )
    self:onPause()
end

function ItemImperialWarRank:regMsgs(  )
end

function ItemImperialWarRank:unregMsgs(  )
end

function ItemImperialWarRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemImperialWarRank:onPause(  )
	self:unregMsgs()
end

function ItemImperialWarRank:setupViews(  )
	self.pTxtRank = self:findViewByName("txt_rank")
	self.pTxtCountry = self:findViewByName("txt_country")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtScore = self:findViewByName("txt_score")
end

function ItemImperialWarRank:updateViews(  )
	if not self.tData then
		return
	end

	--当前排名
	local nRank = self.tData.x
	self.pTxtRank:setString(nRank)

	--国家
	local nCountry = self.tData.c
	self.pTxtCountry:setString(getCountryShortName(nCountry))
	setTextCCColor(self.pTxtCountry, getColorByCountry(nCountry))

	--名字
	self.pTxtName:setString(self.tData.n)	

	--积分
	self.pTxtScore:setString(self.tData.qa)	
end

--排行榜信息
function ItemImperialWarRank:setData( tData )
	self.tData = tData
	self:updateViews()
end

return ItemImperialWarRank


