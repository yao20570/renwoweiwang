--
-- Author: tanqian
-- Date: 2017-09-07 10:11:12
--福泽天下领取奖励项item
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemBlessGetReward = class("ItemBlessGetReward", function()
	return ItemActGetReward.new()
end)

function ItemBlessGetReward:ctor(  )
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemBlessGetReward",handler(self, self.onItemBlessGetRewardDestroy))	
end


function ItemBlessGetReward:setupViews(  )
	--标题文本
	local pLayGroupTitle = self.pLayGroupTitle
	local tConTable = {}
    local tLabel = {
     {getConvertedStr(8, 10010)},
     {"VIP0",getC3B(_cc.blue)},
     {getConvertedStr(8, 10011)},
     {"1",getC3B(_cc.white)},
     {getConvertedStr(8, 10012)},
    }
    tConTable.tLabel = tLabel
    self.pGroupTitle =  createGroupText(tConTable)
    pLayGroupTitle:addView(self.pGroupTitle)


    --领取按钮层
    local tConTable = {}
	--文本
	local tLabel = {
	 {"0",getC3B(_cc.green)},
	 {"/0",getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel

    --获取按钮
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(8, 10004))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet
	self.pBtnGet:setBtnExText(tConTable) 

	-- --创建文本
	-- self:createLabel()

	-- --文置偏移
	pLayBtnGet:setPositionX(500 - pLayBtnGet:getContentSize().width/2)
	-- self.pLabel:setPositionX(500)
	self.pImgGot:setPositionX(500)
end

function ItemBlessGetReward:updateViews(  )
	if not self.tData then
		return
	end
	local pActData = Player:getActById(e_id_activity.blessworld)
	if not pActData then
		return 
	end

	--VIP等级
	local nVip = self.tData.vip

	--要求达到数量
	local nNum = self.tData.num

	--实际达到数量
	local nCurNum = pActData:getNumByVipLv(nVip)

	--标题
	self.pGroupTitle:setLabelCnCr(2, "VIP"..nVip) 
	self.pGroupTitle:setLabelCnCr(4, nNum) 

	self.pBtnGet:setExTextLbCnCr(1, nCurNum)
    self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(nNum))
    self.pBtnGet:setExTextVisiable(true)

	--物品列表
	local tDropList = self.tData.awards
	self:setGoodsListViewData(tDropList)

	--是否已经领取
	local bIsGet = pActData:getIsGetReward(nVip)
	self.pImgGot:setVisible(bIsGet)
	if bIsGet then
		self.pBtnGet:setExTextVisiable(false)
		self.pBtnGet:setVisible(false)
    	self:setLabelVisible(false)
	end

	--是否可领取
    local bCanGet = pActData:gtIsCanGet(nVip)
    self.pBtnGet:setVisible(bCanGet)
    if bCanGet then
    	self.pImgGot:setVisible(false)
    	self:setLabelVisible(false)
    end
	
	--是否未达到
	local bNotReach = nCurNum <nNum
	self:setLabelVisible(bNotReach)
    if bNotReach then  
    	
    	self.pImgGot:setVisible(false)
    	self.pBtnGet:setVisible(false)
    	
    end

end

function ItemBlessGetReward:setData( _tData )
	self.tData = _tData
	self:updateViews()
end

--领取点击事件
function ItemBlessGetReward:onGetClicked( pView )

	SocketManager:sendMsg("getBlessWorldReward", {self.tData.vip}, function(__msg, __oldMsg)
		-- body
		if  __msg.head.state == SocketErrorType.success then
			
			--奖励动画展示
			showGetAllItems(__msg.body.o, 1)
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
		
	end)


end

function ItemBlessGetReward:regMsgs(  )
end

function ItemBlessGetReward:unregMsgs(  )
end

function ItemBlessGetReward:onResume(  )
	self:regMsgs()
end

function ItemBlessGetReward:onPause(  )
	self:unregMsgs()
end


function ItemBlessGetReward:onItemBlessGetRewardDestroy(  )
	self:onPause()
end
return ItemBlessGetReward