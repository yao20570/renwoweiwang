----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 11:24:53
-- Description: 材料商店
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemMaterialShopGoods = require("app.layer.shop.ItemMaterialShopGoods")
local MaterialShop = class("MaterialShop", function(pSize, nGoodsId)
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
	pView:setContentSize(pSize)
	return pView
end)

function MaterialShop:ctor( pSize, nGoodsId )
	self.nGoodsId = nGoodsId or 0
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("MaterialShop", handler(self, self.onMaterialShopDestroy))
end

-- 析构方法
function MaterialShop:onMaterialShopDestroy(  )
    self:onPause()
end

function MaterialShop:regMsgs(  )
end

function MaterialShop:unregMsgs(  )
end

function MaterialShop:onResume(  )
	self:regMsgs()
end

function MaterialShop:onPause(  )
	self:unregMsgs()
end

function MaterialShop:setupViews(  )

end

function MaterialShop:updateViews(  )

	self.tShopMaterialList = getOpenShopMaterialData()
	if not self.pListView then
   		local nSubIndex = 0--初次进入进行引导
		for i=1,#self.tShopMaterialList do
			if self.tShopMaterialList[i].id == self.nGoodsId then
				nSubIndex = i
				break
			end
		end   
		local pSize = self:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, 570, pSize.height - 30),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	             right =  0,
	             top =  0,
	             bottom =  10},
	    }
	    self:addView(self.pListView)
	    centerInView(self,self.pListView)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)		    
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemMaterialShopGoods.new()
			end
			pTempView:showBtnLingTx(self.nSubIndex and self.nSubIndex == _index)
			pTempView:setData(self.tShopMaterialList[_index])
		    return pTempView
		end)

		self.pListView:setItemCount(#self.tShopMaterialList)
		if nSubIndex > 0 then 
			self.nSubIndex = nSubIndex
			self.pListView:scrollToPosition(nSubIndex, true) 
		end	   	
		self.pListView:reload(true)
	else
		self.nSubIndex = nil
		self.pListView:notifyDataSetChange(true, #self.tShopMaterialList)
	end

	local nCnt = self.pListView:getItemCount()
	if not self.pLbTip then
		self.pLbTip = MUI.MLabel.new({
	        text="",
	        size=22,
	        anchorpoint=cc.p(0.5, 0.5),
	        })

		local tparam = luaSplit(getTipsByIndex(10033), ":")
		local str = string.format(tparam[1], getShopMaterialLimit())
		local sColor = tparam[2]
		setTextCCColor(self.pLbTip, sColor)
		self.pLbTip:setString(str, false)
		self:addView(self.pLbTip, 10)
		centerInView(self, self.pLbTip)
	end
	if not nCnt or nCnt <= 0 then
		self.pLbTip:setVisible(true)
	else
		self.pLbTip:setVisible(false)
	end	
end

return MaterialShop


