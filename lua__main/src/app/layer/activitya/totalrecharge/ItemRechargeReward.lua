--
-- Author: tanqian
-- Date: 2017-09-05 18:12:16
--活动累计充值奖励项
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemRechargeReward = class("ItemRechargeReward", function()
	return ItemActGetReward.new()
end)

function ItemRechargeReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemRechargeReward",handler(self, self.onItemConsumeRewardDestroy))	
end

function ItemRechargeReward:regMsgs(  )
end

function ItemRechargeReward:unregMsgs(  )
end

function ItemRechargeReward:onResume(  )
	self:regMsgs()
end

function ItemRechargeReward:onPause(  )
	self:unregMsgs()
end


function ItemRechargeReward:onItemConsumeRewardDestroy(  )
	self:onPause()
end

function ItemRechargeReward:setupViews()
	local pLayGroupTitle = self.pLayGroupTitle
	local tConTable = {}
    local tLabel = {
     {getConvertedStr(8, 10002)},
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


function ItemRechargeReward:updateViews(  )
	if not self.tAwdInfo then
		return
	end

	--需消费黄金数量
	local nGold = self.tAwdInfo.g

	--标题
	self.pGroupTitle:setLabelCnCr(2, tostring(nGold))

	--物品列表
	local tList = self.tAwdInfo.ad
	--奖励列表
	self:setGoodsListViewData(tList)

	self.tAct = Player:getActById(e_id_activity.totalrecharge)

	self.pBtnGet:setExTextLbCnCr(1, self.tAct.nRechargeNum)
    self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(self.tAwdInfo.g))

    self.pBtnGet:setExTextVisiable(true)

    --是否已经领取
    local bIsGot = self.tAct:getIsRewarded(nGold)
    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

    	self.pBtnGet:setExTextVisiable(false)
    	self.pBtnGet:setVisible(not bIsGot)
    	self:setLabelVisible(not bIsGot)
    end
    --是否可领取
    local bCanGet = self.tAct:getIsCanReward(nGold)
    self.pBtnGet:setVisible(bCanGet)
    if bCanGet then
    	self.pImgGot:setVisible(not bCanGet)
    	self:setLabelVisible(not bCanGet)
    end
    --是否未达到
    local bNotReach = self.tAct:getNotReach(nGold)
    if bNotReach then
    	self:setRewardStateImg("#v2_fonts_weidadao.png")
    	self.pBtnGet:setVisible(not bNotReach)
    end
end


function ItemRechargeReward:setItemAwdInfo( _tData )
	self.tAwdInfo = _tData
	self:updateViews()
end

--领取点击事件
function ItemRechargeReward:onGetClicked( pView )
	SocketManager:sendMsg("getTotalRechargeReward", {self.tAwdInfo.g}, function(__msg, __oldMsg)
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


return ItemRechargeReward