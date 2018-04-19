----------------------------------------------------- 
-- author: xiesite
-- updatetime: 2018-03-22 18:00:31
-- Description: 国家宝藏物品提示
-----------------------------------------------------
local IconGoods = require("app.common.iconview.IconGoods")
local MCommonView = require("app.common.MCommonView")
					
local ItemTreasureShow = class("ItemTreasureGet", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTreasureShow:ctor( )
	-- body
	self:myInit()
	parseView("item_treasure_show", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemTreasureShow:onParseViewCallback( pView )
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	--注册析构方法
	self:setDestroyHandler("ItemTreasureShow",handler(self, self.onDestroy))
end
--初始化成员变量
function ItemTreasureShow:myInit(  )

end


function ItemTreasureShow:regMsgs(  )
end

function ItemTreasureShow:unregMsgs(  )
end

function ItemTreasureShow:onResume(  )
	self:regMsgs()
end

function ItemTreasureShow:onPause(  )
	self:unregMsgs()
end

function ItemTreasureShow:setupViews(  )
	self.pLyIcon = self:findViewByName("ly_icon")
	self.pLbTips = self:findViewByName("lb_tips")
	self.pLbTips:setString(getConvertedStr(1,10406))
	setTextCCColor(self.pLbTips, _cc.green)
end

function ItemTreasureShow:showTips()
	if self.pLbTips then
		self.pLbTips:setVisible(true)
	end
end

function ItemTreasureShow:hideTips()
	if self.pLbTips then
		self.pLbTips:setVisible(false)
	end
end

--析构方法
function ItemTreasureShow:onDestroy( )
	-- body
	self:onPause()
end

function ItemTreasureShow:updateViews(  )
	if not self.tData then
		return
	end
	if not self.pTempView then
	 	self.pTempView = IconGoods.new(TypeIconGoods.HADMORE)--HADMORE
		self.pTempView:setIconIsCanTouched(true)
		self.pLyIcon:addView(self.pTempView)
	end

	self.pTempView:setMoreTextColor(getColorByQuality(self.tData.nQuality))
	-- pTempView:setNumber(tTempData.nCt)
	self.pTempView:setScale(0.8)
	self.pTempView:setContentSize(cc.size(108*0.8, 108*0.8))

	self.pTempView:setCurData(self.tData)

 	local tData = Player:getNationalTreasureData()
 	if not tData then
 		return
 	end
 	local nState = tData:getState()
 	if nState == TreasureType.xb then
 		--现在
 		if self.tData.sTid == 100222 and tData:isGetGoldPaper() then
 			self:showTips()
 		else
 			self:hideTips()
 		end
 	elseif nState == TreasureType.zh then
	 	local id = tData:getGetConId()
	 	if id == self.tData.sTid then
	 		self:showTips()
	 	else
	 		self:hideTips()
	 	end
	else
		self:hideTips()
 	end
end
 

--_state 0-未完成，1-完成未领取，2-完成已领取
function ItemTreasureShow:setCurData( _tData )
	self.tData = _tData
	self:updateViews()
end


return ItemTreasureShow


