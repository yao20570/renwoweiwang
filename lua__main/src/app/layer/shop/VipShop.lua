----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 11:24:53
-- Description: vip商店
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemVipShopGoods = require("app.layer.shop.ItemVipShopGoods")
local VipShop = class("VipShop", function(pSize, nGoodsId)
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
	pView:setContentSize(pSize)
	return pView
end)

function VipShop:ctor( pSize, nGoodsId )
	self.nGoodsId = nGoodsId or 0
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("VipShop", handler(self, self.onVipShopDestroy))
end


-- 析构方法
function VipShop:onVipShopDestroy(  )
    self:onPause()
end

function VipShop:regMsgs(  )
	--vip礼包购买刷新
	regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.updateViews))	
end

function VipShop:unregMsgs(  )
	unregMsg(self, gud_vip_gift_bought_update_msg)	
end

function VipShop:onResume(  )
	self:regMsgs()
end

function VipShop:onPause(  )
	self:unregMsgs()
end

function VipShop:setupViews(  )

end

function VipShop:updateViews(  )
	local tShopBaseList= getOpenShopBaseDataByKind(e_type_shop.vip)  
   	self.tShopBaseList = tShopBaseList    	
   	if not self.pListView then
   		local nSubIndex = 0
		for i=1,#tShopBaseList do
			if tShopBaseList[i].id == self.nGoodsId then
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
		    	pTempView  = ItemVipShopGoods.new()
			end			
			pTempView:showBtnLingTx(self.nSubIndex and self.nSubIndex == _index)
			if self.tShopBaseList[_index].id == e_resdata_ids.yb 
				or self.tShopBaseList[_index].id == e_resdata_ids.bt
				or self.tShopBaseList[_index].id == e_resdata_ids.mc
				or self.tShopBaseList[_index].id == e_resdata_ids.lc  then
				pTempView:setData(self.tShopBaseList[_index],nil,self.tShopBaseList[_index].id)

			else
				pTempView:setData(self.tShopBaseList[_index])
			end			
		    return pTempView
		end)	 

	   	self.pListView:setItemCount(#self.tShopBaseList)
		if nSubIndex > 0 then 
			self.nSubIndex = nSubIndex
			self.pListView:scrollToPosition(nSubIndex, true) 
		end	   	
		self.pListView:reload(true)
	else   
		self.nSubIndex = nil
		self.pListView:notifyDataSetChange(true, #self.tShopBaseList)
   	end


end
--筛选VIP礼包活动商品
function VipShop:filterVipLimitItem( tlist )
	-- body
	if not tlist or #tlist <= 0 then
		return {}
	end
	--dump(getArmyVipLvLimit(e_id_item.bbgm), "getArmyVipLvLimit(e_id_item.bbgm)", 100)
	local tTable = {}
	for k, v in pairs(tlist) do 
		if v.id == e_resdata_ids.bb then
			local nvip = getArmyVipLvLimit(e_id_item.bbgm)			
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then						
				table.insert(tTable, v)				
			end		
		elseif v.id == e_resdata_ids.qb then
			local nvip = getArmyVipLvLimit(e_id_item.qbgm)
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
				table.insert(tTable, v)				
			end	
		elseif v.id == e_resdata_ids.gb then
			local nvip = getArmyVipLvLimit(e_id_item.gbgm)
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) == true then
				table.insert(tTable, v)				
			end	
		else
			table.insert(tTable, v)
		end
	end
	table.sort( tTable, function ( a, b )
		return a.exchange < b.exchange
	end )
	return tTable
end
return VipShop


