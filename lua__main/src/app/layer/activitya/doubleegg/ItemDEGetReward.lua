-- ItemDEGetReward.lua
----------------------------------------------------- 
-- author: xst
-- updatetime: 2017-12-11 15:12:20
-- Description: 领奖列表子项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemDEGetReward = class("ItemDEGetReward", function()
	return ItemActGetReward.new()
end)

function ItemDEGetReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemDEGetReward",handler(self, self.onItemDEGetRewardDestroy))	
end

function ItemDEGetReward:regMsgs(  )
end

function ItemDEGetReward:unregMsgs(  )
end

function ItemDEGetReward:onResume(  )
	self:regMsgs()
end

function ItemDEGetReward:onPause(  )
	self:unregMsgs()
end


function ItemDEGetReward:onItemDEGetRewardDestroy(  )
	self:onPause()
end

function ItemDEGetReward:setupViews()
	--第几天
	local pLayGroupTitle = self.pLayGroupTitle

    self.pGroupTitle =  MUI.MLabel.new({
    		text = "第1天",
    		size = 20,
    		anchorpoint = cc.p(0.5, 0.5),
    	})
    pLayGroupTitle:addView(self.pGroupTitle)
    centerInView(pLayGroupTitle, self.pGroupTitle)
    self.pGroupTitle:setPositionX(self.pGroupTitle:getPositionX() - self.pGroupTitle:getWidth()/2)

    --领取按钮层
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet

	self:setRewardStateImg("#v1_fonts_yiqiandao.png")

end


function ItemDEGetReward:updateViews(  )
	if not self.tLogData then
		return
	end

	--当前天数
	local nLogDay = self.tLogData.d

	--标题
	self.pGroupTitle:setString(string.format(getConvertedStr(7, 10110), nLogDay))

	--物品列表
	local tDropList = self.tLogData.is
	--奖励列表
	self:setGoodsListViewData(tDropList)

	local tAct = Player:getActById(e_id_activity.doubleegg)

    --是否已经领取
    local bIsGot = tAct:getIsRewarded(nLogDay)
    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

    	self.pBtnGet:setVisible(not bIsGot)
    	self:setLabelVisible(not bIsGot)
    end
    --是否可领取
    local bCanGet = tAct:getIsCanReward(nLogDay)
    self.pBtnGet:setVisible(bCanGet)
    if bCanGet then
    	self:hideRewardStateImg()
    	self:setLabelVisible(not bCanGet)
    end
    --是否未达到
    local bNotLog = tAct:getNotLog(nLogDay)
    if bNotLog then
    	self:setRewardStateImg("#v2_fonts_weidadao.png")

    	self.pBtnGet:setVisible(not bNotLog)
    end
end


function ItemDEGetReward:setItemSevenData( _tLogData )
	self.tLogData = _tLogData
	self:updateViews()
end

--领取点击事件
function ItemDEGetReward:onGetClicked( pView )
	SocketManager:sendMsg("doubleEgg", {}, function(__msg)
	    if  __msg.head.state == SocketErrorType.success then 
	        if __msg.head.type == MsgType.doubleEgg.id then
	       		if __msg.body.ob then
					--获取物品效果
					showGetItemsAction(__msg.body.ob)
	       		end
	        end
	    else
	        --弹出错误提示语
	        TOAST(SocketManager:getErrorStr(__msg.head.state))
	    end

		-- body
		-- if __msg.body and __msg.body.o then
		-- 	--奖励领取表现(包含有武将的情况走获得武将流程)
		-- 	showGetItemsAction(__msg.body.o)					
		-- end
	end)
end


return ItemDEGetReward