----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-29 22:21:20
-- Description: 触发式礼包
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local MImgLabel = require("app.common.button.MImgLabel")
local e_cost_type = {
	rmb = 1,
	gold = 2,
}
local nOffsetX = -8
local ItemTriggerGiftGetReward = class("ItemTriggerGiftGetReward", function()
	return ItemActGetReward.new()
end)

function ItemTriggerGiftGetReward:ctor(  )
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemTriggerGiftGetReward",handler(self, self.onItemTriggerGiftGetRewardDestroy))	
end

function ItemTriggerGiftGetReward:regMsgs(  )
end

function ItemTriggerGiftGetReward:unregMsgs(  )
end

function ItemTriggerGiftGetReward:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function ItemTriggerGiftGetReward:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end


function ItemTriggerGiftGetReward:onItemTriggerGiftGetRewardDestroy(  )
	self:onPause()
end

function ItemTriggerGiftGetReward:setupViews(  )
	--购买按钮
	self.pLayBtnBuy = self.pLayBtnGet
	self.pBtnBuy = getCommonButtonOfContainer(self.pLayBtnBuy, TypeCommonBtn.M_YELLOW,"")
	self.pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyBtnClicked))

	--购买礼包按钮上面的文字左边
	self.pCostLabelLeft = MImgLabel.new({text="", size = 20, parent = self.pLayBtnBuy})
	-- self.pCostLabelLeft:setImg(getCostResImg(e_type_resdata.money), 1, "right")
	self.pCostLabelLeft:followPos("center", self.pLayBtnBuy:getContentSize().width/2+2, self.pLayBtnBuy:getContentSize().height)

	--购买礼包按钮上面的文字右边
	-- self.pCostLabelRight=MUI.MLabel.new({text ="", size = 20})
	-- self.pCostLabelRight:setAnchorPoint(0,0.5)
	-- self.pCostLabelRight:setPosition(self.pLayBtnBuy:getContentSize().width/2 + nOffsetX, self.pLayBtnBuy:getContentSize().height + 10, 10)
	-- self.pLayBtnBuy:addView(self.pCostLabelRight)

	--礼包按钮中文字
	self.pBtnLabel = MImgLabel.new({text="", size = 20, parent =self.pLayBtnBuy})
	-- self.pBtnLabel:setImg(getCostResImg(e_type_resdata.money), 0.75, "left")
	self.pBtnLabel:followPos("center",self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height/2, 1)

	self.pImgGot:setCurrentImage("#v2_fonts_yigoumai.png")
end


function ItemTriggerGiftGetReward:updateViews(  )
	if not self.tTriGiftRes then
		return
	end

	self:setGoodsListViewData(self.tTriGiftRes:getItemKVList())

	--已买
	if self.tTriGiftRes.bIsTake then
		self.pLayBtnBuy:setVisible(false)
		self.pImgGot:setVisible(true)
	else
		self.pLayBtnBuy:setVisible(true)
		self.pImgGot:setVisible(false)

		local tConf = getTpackData(self.tTriGiftRes.nPid, self.tTriGiftRes.nGid)
		if not tConf then
			return
		end

		-- if tConf.buykind == e_cost_type.rmb then--人民币购买
			--按钮文字
			self.pBtnLabel:hideImg()
			local tStr = {
	    		{color=_cc.white, text="￥" .. tostring(tConf.disprice)..getConvertedStr(3, 10312)},
	    	}
			self.pBtnLabel:setString(tStr)
			--原价
			self.pCostLabelLeft:hideImg()
			local tStr = {
	    		{color=_cc.gray, text=getConvertedStr(3, 10523)},
	    		{color=_cc.yellow, text="￥" .. tostring(tConf.orgprice)},
	    	}
	    	self.pCostLabelLeft:setString(tStr)
	    	-- self.pCostLabelRight:setVisible(false)
	    	--红线
	    	local nLen = self.pCostLabelLeft:getContentSize().width
	    	-- self.pCostLabelLeft:followPos("center", self.pLayBtnBuy:getContentSize().width/2+ nOffsetX, self.pLayBtnBuy:getContentSize().height + 5, 10)
	    	--红线
			local fScale = (nLen + 10)/17
			self.pCostLabelLeft:showRedLine(true, fScale)   	
		-- else
		-- 	--按钮文字
		-- 	self.pBtnLabel:showImg()
		-- 	local tStr = {
	 --    		{color=_cc.white, text=tostring(tConf.cost)},
	 --    	}
		-- 	self.pBtnLabel:setString(tStr)

		-- 	--原价
		-- 	self.pCostLabelLeft:showImg()
		-- 	local tStr = {
	 --    		{color=_cc.gray, text=getConvertedStr(3, 10523)},
	 --    	}
	 --    	self.pCostLabelLeft:setString(tStr)
	 --    	self.pCostLabelRight:setVisible(true)
	 --    	local tStr = {
	 --    		{color=_cc.yellow, text=tostring(tConf.orgcost)},
	 --    	}
	 --    	self.pCostLabelRight:setString(tStr)

	 --    	local nLen = self.pCostLabelLeft:getContentSize().width + self.pCostLabelRight:getContentSize().width
	 --    	self.pCostLabelLeft:followPos("right", self.pLayBtnBuy:getContentSize().width/2 + nLen/2 - 15+ nOffsetX, self.pLayBtnBuy:getContentSize().height + 5, 10)
	 --    	self.pCostLabelRight:setPosition(self.pLayBtnBuy:getContentSize().width/2 + nLen/2 - 15+ nOffsetX, self.pLayBtnBuy:getContentSize().height + 5, 10)
	 --    	--红线
		-- 	local fScale = (nLen + 50)/17
		-- 	self.pCostLabelLeft:showRedLine(true, fScale)   
		-- end
	    self:updateCd()
	end
end

function ItemTriggerGiftGetReward:updateCd( )
	if not self.tTriGiftRes then
		return
	end

	local tTriGiftData = getTpackData(self.tTriGiftRes.nPid, self.tTriGiftRes.nGid)
	if not tTriGiftData then
		return
	end

	--已买
	if self.tTriGiftRes.bIsTake then
		--标签
		local tStr = {
			{text = tTriGiftData.name, color = _cc.white},
		}
		self.pTxtBanner:setString(tStr)
	else
		--标签
		local tStr = {
			{text = tTriGiftData.name.."(", color = _cc.white},
			{text = formatTimeToHms(self.tTriGiftRes:getCd2()), color = _cc.red},
			{text = ")", color = _cc.white},
		}
		self.pTxtBanner:setString(tStr)
	end
end

--tTriGiftRes: PlayTriGiftRes
function ItemTriggerGiftGetReward:setData( tTriGiftRes)
	self.tTriGiftRes = tTriGiftRes
	self.nCurrPid = self.tTriGiftRes.nPid
	self.nCurrGid = self.tTriGiftRes.nGid
	self:updateViews()
end

function ItemTriggerGiftGetReward:onBuyBtnClicked( )
	if not self.nCurrPid or not self.nCurrGid then
		return
	end

	local tConf = getTpackData(self.nCurrPid, self.nCurrGid)
	if not tConf then
		return
	end

	-- if tConf.buykind == e_cost_type.rmb then--人民币购买
		local tData = getRechargeDataByKey(tConf.rechargeid)
		if tData then
			reqRecharge(tData)
		end
	-- else
	-- 	local nCost = tConf.cost
	-- 	if nCost <= Player:getPlayerInfo().nMoney then
	-- 		SocketManager:sendMsg("reqBugTriggerGift", {self.nCurrPid})
	-- 	else
	-- 		local strTips = {
	-- 		    {color=_cc.pwhite,text=getConvertedStr(3, 10312)},
	-- 		    {color=_cc.blue,text=tConf.name},
	-- 		}
	-- 		showBuyDlg(strTips,nCost,function (  )
	-- 		    SocketManager:sendMsg("reqBugTriggerGift", {self.nCurrPid})
	-- 		end)
	-- 	end
	-- end
end


return ItemTriggerGiftGetReward


