----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-29 22:21:20
-- Description: 通用领奖列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemFarmPlanAward  = require("app.layer.activityb.farmtroopsplan.ItemFarmPlanAward")
local ItemActGetReward = class("ItemActGetReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemActGetReward:ctor(  )
	--解析文件
	parseView("item_activity_nanbeiwar", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemActGetReward:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemActGetReward", handler(self, self.onItemActGetRewardDestroy))
end

-- 析构方法
function ItemActGetReward:onItemActGetRewardDestroy(  )
end

function ItemActGetReward:setupViews(  )
	self.pLayRoot = self:findViewByName("default")
	self.pLayGroupTitle = self:findViewByName("lay_group_title")
	self.pImgGot = self:findViewByName("img_got")
	self.pLayGoods = self:findViewByName("lay_icons")
	self.pLayBtnGet = self:findViewByName("lay_btn_get")
	self.pTxtBanner = self:findViewByName("txt_banner")
	self.pLbState = self:findViewByName("lb_state")
end

--未达到
function ItemActGetReward:createLabel()
	-- body
	--label
	self.pLabel = MUI.MLabel.new({
	    text = getConvertedStr(7, 10089),
	    size = 22,
	    anchorpoint = cc.p(0.5, 0.5),
	})
	self.pLabel:setPosition(425, 83)
	self.pLayRoot:addView(self.pLabel, 10, 10)
end

--设置未达到是否可见
function ItemActGetReward:setLabelVisible(bVis)
	-- body
	if not self.pLabel then
		self:createLabel()
	end
	self.pLabel:setVisible(bVis)
end

--设置奖励状态图片
function ItemActGetReward:setRewardStateImg(_img)
	-- body
	self.pImgGot:setCurrentImage(_img)
	self.pImgGot:setVisible(true)
end
--设置奖励状态图片
function ItemActGetReward:hideRewardStateImg()
	-- body
	self.pImgGot:setVisible(false)
end

-------------------------------------------------

--列表项回调
function ItemActGetReward:onGoodsListViewCallBack( _index, _pView )
	-- body
	local tTempData = self.tDropList[_index]
    local pTempView = _pView
    
	if self.tStr then
		if pTempView == nil then
			pTempView = ItemFarmPlanAward.new()
			pIconView = IconGoods.new(TypeIconGoods.NORAML)--HADMORE
			pIconView:setIconIsCanTouched(true)
			pTempView:addView(pIconView, 2)
			pIconView:setPosition(0, 45)
			pIconView:setTag(999)
		end

		local sStr = string.format(getConvertedStr(7, 10110), _index)
		pTempView:setItemInfo(sStr, self.tStr.color)

		local pIconView = pTempView:getChildByTag(999)
		if pIconView then
			local nGoodsId = tTempData.k
		    local nCt = tTempData.v
		    local pGoods = getGoodsByTidFromDB(nGoodsId)
		    pIconView:setCurData(pGoods) 
			pIconView:setMoreTextColor(getColorByQuality(pGoods.nQuality))
			pIconView:setNumber(nCt)
			pIconView:setScale(0.8)
			if self.tAct and self.nPlanId then
				if self.tAct:hasGotAward(self.nPlanId, _index) then
					pIconView:setIconToGray(true)
					pIconView:removeQualityTx()
					pIconView:addImgOnIcon("#v1_fonts_yilingqu.png")
					pTempView:setTextToGray(true)
				end
			end
		end

		
	else
		if pTempView == nil then
			pTempView = IconGoods.new(TypeIconGoods.NORAML)--HADMORE
			pTempView:setIconIsCanTouched(true)
	    end
	    local nGoodsId = tTempData.k
	    local nCt = tTempData.v
	    local pGoods = getGoodsByTidFromDB(nGoodsId)
	    pTempView:setCurData(pGoods) 
		pTempView:setMoreTextColor(getColorByQuality(pGoods.nQuality))
		pTempView:setNumber(nCt)
		pTempView:setScale(0.8)
	end

    return pTempView
end

--设置数据
-- tDropList:List<Pair<Integer,Long>>
-- _str:底部文字
-- _tAct:活动数据
function ItemActGetReward:setGoodsListViewData( tDropList, _tStr, _tAct, _nPlanId )
	if not tDropList then
		return
	end
	self.tStr = _tStr
	self.tAct = _tAct
	self.nPlanId = _nPlanId

	if _nPlanId then
		self.tDropList = tDropList
		local nCurrCount = #self.tDropList
		--容错
		if not self.pListView then
			local pLayGoods = self.pLayGoods
		    self.pListView = MUI.MListView.new {
		        viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		        itemMargin = {left = 6,
		            right =  -15,
		            top = 5,
		            bottom = 5},
		    }
		    pLayGoods:addView(self.pListView)
		    centerInView(pLayGoods, self.pListView)
		    self.pListView:setPositionY(self.pListView:getPositionY() - 20)
			self.pListView:setItemCallback(handler(self, self.onGoodsListViewCallBack))
			self.pListView:setItemCount(nCurrCount)
			self.pListView:reload(true)
		else
			self.pListView:notifyDataSetChange(true, nCurrCount)
		end
	else
		local tCurDatas = getRewardItemsFromSever(tDropList)
		gRefreshHorizontalList(self.pLayGoods, tCurDatas)
	end
	
end

return ItemActGetReward


