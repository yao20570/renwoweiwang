-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-01-27 15:37:17 星期六
-- Description: 福星高照奖励详情子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemLuckyStarReward = class("ItemLuckyStarReward", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--构造
function ItemLuckyStarReward:ctor()
	-- body
	self:myInit()
	parseView("item_lucky_star_reward", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function ItemLuckyStarReward:onParseViewCallback( pView )
	-- body
	
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("ItemLuckyStarReward",handler(self, self.onDestroy))
end
function ItemLuckyStarReward:myInit(  )
	-- body
	self.tData = nil
end

--初始化控件
function ItemLuckyStarReward:setupViews()
	-- body
	self.pTxtTip = self:findViewByName("txt_tip")
	setTextCCColor(self.pTxtTip,_cc.green)

	self.pLayReward = self:findViewByName("lay_list")

	self.pTxtTitle = self:findViewByName("txt_title")

	
end

-- 修改控件内容或者是刷新控件数据
function ItemLuckyStarReward:updateViews()
	-- body
	if not self.tData then
		return
	end

	if not self.pListView then
		local nCurrCount = #self.tData.tAs
		local pLayGoods = self.pLayReward
		self.pListView = MUI.MListView.new {
		    viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		    direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		    itemMargin = {left = 12,
		        right =  0,
		        top = 5,
		        bottom = 5},
		}
		pLayGoods:addView(self.pListView)
		centerInView(pLayGoods, self.pListView)

		self.pListView:setItemCallback(function ( _index, _pView )
			local tItemData = luaSplit(self.tData.tAs[_index],":")
            local pItemData = self.tData.tAs[_index] --getGoodsByTidFromDB(tItemData[1])
                local pTempView = _pView
                if pTempView == nil then
                    pTempView = IconGoods.new(TypeIconGoods.NORMAL)
                end
                pTempView:setScale(0.8)
                pTempView:setCurData(pItemData)
				pTempView:setNumber(pItemData.nCt)
                return pTempView
            end)
		self.pListView:setItemCount(nCurrCount)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nCurrCount)
	end

	local sTitle = ""
	if self.tData.nL == self.tData.nR then
		sTitle = string.format(getConvertedStr(6, 10455), tostring(self.tData.nL))
	else
		sTitle = string.format(getConvertedStr(6, 10454), tostring(self.tData.nL), tostring(self.tData.nR))
	end
	self.pTxtTitle:setString(sTitle, false)
	self.pTxtTip:setString(getConvertedStr(9,10134))

end

function ItemLuckyStarReward:setData( _tData )
	-- body

	self.tData = _tData or self.tData
	self:updateViews()
end

--析构方法
function ItemLuckyStarReward:onDestroy()
	self:onPause()
end

-- 注册消息
function ItemLuckyStarReward:regMsgs( )
	-- body


end

-- 注销消息
function ItemLuckyStarReward:unregMsgs(  )
	-- body
	
end


--暂停方法
function ItemLuckyStarReward:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function ItemLuckyStarReward:onResume( )
	-- body
	self:regMsgs()

end



return ItemLuckyStarReward
