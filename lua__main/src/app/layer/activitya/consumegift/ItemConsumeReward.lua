-- ItemConsumeReward.lua
----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2017-08-05 10:49:20
-- Description: 领奖列表子项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemConsumeReward = class("ItemConsumeReward", function()
	return ItemActGetReward.new()
end)

function ItemConsumeReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemConsumeReward",handler(self, self.onItemConsumeRewardDestroy))	
end

function ItemConsumeReward:regMsgs(  )
end

function ItemConsumeReward:unregMsgs(  )
end

function ItemConsumeReward:onResume(  )
	self:regMsgs()
end

function ItemConsumeReward:onPause(  )
	self:unregMsgs()
end


function ItemConsumeReward:onItemConsumeRewardDestroy(  )
	self:onPause()
end

function ItemConsumeReward:setupViews()
	--第几天
	local pLayGroupTitle = self.pLayGroupTitle
	local tConTable = {}
    local tLabel = {
     {getConvertedStr(7, 10129)},
     {"1",getC3B(_cc.yellow)},
     {getConvertedStr(7, 10036)},
    }
    tConTable.tLabel = tLabel
    tConTable.fontSize = 20
    self.pGroupTitle =  createGroupText(tConTable)
    pLayGroupTitle:addView(self.pGroupTitle)

    --领取按钮层
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet

end


function ItemConsumeReward:updateViews(  )
	if not self.tAwdInfo then
		return
	end

	--需消费黄金数量
	local nGold = self.tAwdInfo.t

	--标题
	self.pGroupTitle:setLabelCnCr(2, tostring(nGold))

	--物品列表
	local tDropList = self.tAwdInfo.i
	--奖励列表
	self:setGoodsListViewData(tDropList)

	self.tAct = Player:getActById(e_id_activity.consumegift)

    --是否已经领取
    local bIsGot = self.tAct:getIsRewarded(nGold)
    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

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
    -- self:setLabelVisible(bNotReach)
    if bNotReach then
    	self:setRewardStateImg("#v2_fonts_weidadao.png")
    	self.pBtnGet:setVisible(not bNotReach)
    end
end


function ItemConsumeReward:setItemAwdInfo( _tData )
	self.tAwdInfo = _tData
	self:updateViews()
end

--领取点击事件
function ItemConsumeReward:onGetClicked( pView )
	SocketManager:sendMsg("reqConsumeAwards", {self.tAwdInfo.t}, function(__msg, __oldMsg)
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


return ItemConsumeReward