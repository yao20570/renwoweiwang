----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2018-01-19 17:10:45
-- Description: 特惠礼包界面(送审)
-----------------------------------------------------
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemPacketGiftGetReward = class("ItemPacketGiftGetReward", function()
	return ItemActGetReward.new()
end)

function ItemPacketGiftGetReward:ctor(  )
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemPacketGiftGetReward",handler(self, self.onItemPacketGiftGetRewardDestroy))	
end

function ItemPacketGiftGetReward:regMsgs(  )
end

function ItemPacketGiftGetReward:unregMsgs(  )
end

function ItemPacketGiftGetReward:onResume(  )
	self:regMsgs()
end

function ItemPacketGiftGetReward:onPause(  )
	self:unregMsgs()
end


function ItemPacketGiftGetReward:onItemPacketGiftGetRewardDestroy(  )
	self:onPause()
end

function ItemPacketGiftGetReward:setupViews(  )
	--购买按钮
	self.pLayBtnBuy = self.pLayBtnGet
	self.pBtnBuy = getCommonButtonOfContainer(self.pLayBtnBuy, TypeCommonBtn.M_YELLOW,"")
	self.pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyBtnClicked))

	--购买礼包按钮上面的文字左边
	self.pCostLabelLeft = MImgLabel.new({text="", size = 20, parent = self.pLayBtnBuy})
	-- self.pCostLabelLeft:setImg(getCostResImg(e_type_resdata.money), 1, "right")
	self.pCostLabelLeft:followPos("center", self.pLayBtnBuy:getContentSize().width/2+2, self.pLayBtnBuy:getContentSize().height)

	
	--礼包按钮中文字
	self.pBtnLabel = MImgLabel.new({text="", size = 20, parent =self.pLayBtnBuy})
	-- self.pBtnLabel:setImg(getCostResImg(e_type_resdata.money), 0.75, "left")
	self.pBtnLabel:followPos("center",self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height/2, 1)

	self.pImgGot:setCurrentImage("#v2_fonts_yigoumai.png")
end


function ItemPacketGiftGetReward:updateViews(  )
	if not self.tPacketShowVo then
		return
	end

	self.pTxtBanner:setString(self.tPacketShowVo.sPackName)
	self:setGoodsListViewData(self.tPacketShowVo.tItemKVList)

	--已买
	if self.tPacketShowVo.bIsTake then
		self.pLayBtnBuy:setVisible(false)
		self.pImgGot:setVisible(true)
	else
		self.pLayBtnBuy:setVisible(true)
		self.pImgGot:setVisible(false)

		--按钮文字
		self.pBtnLabel:hideImg()
		local tStr = {
	    	{color=_cc.white, text="￥" .. tostring(self.tPacketShowVo.nPrice)..getConvertedStr(3, 10312)},
	    }
		self.pBtnLabel:setString(tStr)
		--原价
		self.pCostLabelLeft:hideImg()
		local tStr = {
	    	{color=_cc.gray, text=getConvertedStr(3, 10523)},
	    	{color=_cc.yellow, text="￥" .. tostring(self.tPacketShowVo.nOriPrice)},
	    }
	    self.pCostLabelLeft:setString(tStr)
	    --红线
	    local nLen = self.pCostLabelLeft:getContentSize().width
	    --红线
		local fScale = (nLen + 10)/17
		self.pCostLabelLeft:showRedLine(true, fScale)

	end
end


function ItemPacketGiftGetReward:setData( tPacketShowVo)
	self.tPacketShowVo = tPacketShowVo
	self:updateViews()
end

function ItemPacketGiftGetReward:onBuyBtnClicked( )
	local tData = getRechargeDataByKey(self.tPacketShowVo.sPid)
	if tData then
		reqRecharge(tData)
	end
end


return ItemPacketGiftGetReward


