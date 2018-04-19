--
-- Author: tanqian
-- Date: 2017-09-05 18:22:21
--每日返利奖励项item
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemRebateReward = class("ItemRebateReward", function()
	return ItemActGetReward.new()
end)

function ItemRebateReward:ctor()

	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemRebateReward",handler(self, self.onItemRebateRewardDestroy))	
end

function ItemRebateReward:regMsgs(  )
end

function ItemRebateReward:unregMsgs(  )
end

function ItemRebateReward:onResume(  )
	self:regMsgs()
end

function ItemRebateReward:onPause(  )
	self:unregMsgs()
end


function ItemRebateReward:onItemRebateRewardDestroy(  )
	self:onPause()
end

function ItemRebateReward:setupViews()
	
	local pLayGroupTitle = self.pLayGroupTitle
	local tConTable = {}
    local tLabel = {
     {getConvertedStr(8, 10009)},
     {"1",getC3B(_cc.yellow)},
     {getConvertedStr(8, 10003)},
    }
    tConTable.tLabel = tLabel
    tConTable.fontSize = 20
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
	
	local pLayBtnGet = self.pLayBtnGet
	self.pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(8, 10004))
	self.pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet:setBtnExText(tConTable) 

end


function ItemRebateReward:updateViews(  )
	if not self.tAwdInfo then
		return
	end

	--需充值黄金数量
	local nGold = self.tAwdInfo.g

	--标题
	self.pGroupTitle:setLabelCnCr(2, tostring(nGold))

	--物品列表
	local tList = self.tAwdInfo.ad
	--奖励列表
	self:setGoodsListViewData(tList)

	self.tAct = Player:getActById(e_id_activity.dayrebate)


    self.pBtnGet:setExTextLbCnCr(1, self.tAct.nRechargeNum)
    self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(self.tAwdInfo.g))
    self.pBtnGet:setExTextVisiable(true)

    --是否已经领取
    local bIsGot = self.tAct:getIsRewarded(nGold)
  
    if bIsGot then  --已领取
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")
    	self.pBtnGet:setExTextVisiable(false)
    	self.pBtnGet:setVisible(not bIsGot)
    	-- self.pBtnGet:updateBtnText(getConvertedStr(8, 10006))
    	-- self.pBtnGet:setBtnEnable(false)
    end
    --是否可领取
    local bCanGet = self.tAct:getIsCanReward(nGold)
    self.pBtnGet:setVisible(bCanGet)
    if bCanGet then
    	self:hideRewardStateImg()
    	-- self:setLabelVisible(not bCanGet)
    	-- self.pBtnGet:setBtnEnable(true)
    	-- self.pBtnGet:updateBtnText(getConvertedStr(8, 10004))
    
    end
    --是否未达到
    local bNotReach = self.tAct:getNotReach(nGold)
    -- self:setLabelVisible(bNotReach)
    if bNotReach then  --显示去充值
    	
    	self:setRewardStateImg("#v2_fonts_weidadao.png")
    	self.pBtnGet:setVisible(not bNotReach)
    	-- self.pBtnGet:setBtnEnable(true)
    	-- self.pBtnGet:updateBtnText(getConvertedStr(8, 10001))
    end
end


function ItemRebateReward:setItemAwdInfo( _tData )
	self.tAwdInfo = _tData
	self:updateViews()
end

--领取点击事件
function ItemRebateReward:onGetClicked( pView )

	SocketManager:sendMsg("getDayRebatReward", {self.tAwdInfo.g}, function(__msg, __oldMsg)
		-- body
		if  __msg.head.state == SocketErrorType.success then
			local tAwd = self.tAct:getAwdByGoldType(__oldMsg[1])
			--奖励动画展示
			showGetAllItems(tAwd, 1)
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
		
	end)


end


return ItemRebateReward