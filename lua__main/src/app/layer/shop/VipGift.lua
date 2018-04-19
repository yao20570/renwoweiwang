----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 11:24:53
-- Description: vip礼包
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemVipGit = require("app.layer.shop.ItemVipGit")
local VipGift = class("VipGift", function(pSize)
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
	pView:setContentSize(pSize)
	return pView
end)

function VipGift:ctor( pSize )
	self.pSize = pSize

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("VipGift", handler(self, self.onVipGiftDestroy))
end

-- 析构方法
function VipGift:onVipGiftDestroy(  )
    self:onPause()
end

function VipGift:regMsgs(  )
	regMsg(self, ghd_refresh_playerviplv_msg, handler(self, self.updateViews))	
end

function VipGift:unregMsgs(  )
	unregMsg(self, ghd_refresh_playerviplv_msg)	
end

function VipGift:onResume(  )
	self:regMsgs()
end

function VipGift:onPause(  )
	self:unregMsgs()
end

function VipGift:setupViews(  )


end

function VipGift:updateViews(  )
	local pSize = self.pSize
	self.tVipLvs = getAvatarVipLvs()
	local nPos = 0
	for i = #self.tVipLvs, 1, -1 do
		if Player:getPlayerInfo():getIsBoughtVipGift(self.tVipLvs[i]) == false and
			Player:getPlayerInfo().nVip >= self.tVipLvs[i] then
			nPos = i
			break
		end
	end
	if nPos > 2 then
		nPos = nPos - 1 
	else
		nPos = 1
	end
	--listView
	if not self.pListView then
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 10),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	             right =  0,
	             top =  0,
	             bottom =  10},
	    }
	    self:addView(self.pListView)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)		   	
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemVipGit.new()
			end
			local tVipData = getAvatarVIPByLevel(self.tVipLvs[_index])
			pTempView:setData(tVipData)
		    return pTempView
		end)		
		self.pListView:setItemCount(#self.tVipLvs)		
		self:refreshScrollPos(nPos)
		self.pListView:reload(true)	
	else		
		self:refreshScrollPos(nPos)
		self.pListView:notifyDataSetChange(true, #self.tVipLvs)	
	end

end

function VipGift:refreshScrollPos( nPos )
 	-- body 	print(nPos, "nPos", 100)
 	if self.pListView and nPos and nPos > 0 then
 		self.pListView:scrollToPosition(nPos) 
 	end
 end 

return VipGift


