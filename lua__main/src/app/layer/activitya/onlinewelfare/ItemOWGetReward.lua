-- ItemOWGetReward.lua
----------------------------------------------------- 
-- author: xst
-- updatetime: 2017-12-20 18:06:20
-- Description: 领奖列表子项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemOWGetReward = class("ItemOWGetReward", function()
	return ItemActGetReward.new()
end)

function ItemOWGetReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemOWGetReward",handler(self, self.onItemDEGetRewardDestroy))	
end

function ItemOWGetReward:regMsgs(  )
end

function ItemOWGetReward:unregMsgs(  )
end

function ItemOWGetReward:onResume(  )
	self:regMsgs()
	self:resSchedule()
end

function ItemOWGetReward:onUpdateTime(  )
	self.pLbState:setString( string.format(getConvertedStr(1,10320), formatTimeToMs(self.nOt+(getSystemTime()-self.nSt)))) 
	self:updateViews()
end

function ItemOWGetReward:onPause(  )
	self:unregMsgs()
	self:unresSchedule()
end


function ItemOWGetReward:onItemDEGetRewardDestroy(  )
	self:onPause()
end

function ItemOWGetReward:setupViews()
	--第几天
	local pLayGroupTitle = self.pLayGroupTitle

    self.pGroupTitle =  MUI.MLabel.new({
    		text = "第1天",
    		size = 20,
    		anchorpoint = cc.p(0.5, 0.5),
    	})
    pLayGroupTitle:addView(self.pGroupTitle)
    centerInView(pLayGroupTitle, self.pGroupTitle)
    self.pGroupTitle:setAnchorPoint(0, 0.5)
    self.pGroupTitle:setPositionX(5)

    --领取按钮层
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet

	self.pImgGot:setPositionY(self.pImgGot:getPositionY()-10)
	self.pLbState:setPositionY(self.pLbState:getPositionY()-10)
	self.pLbState:setPositionX(self.pLbState:getPositionX()-5)

	self.pLbState:setVisible(true)
	setTextCCColor(self.pLbState, "4eff00")
end


function ItemOWGetReward:updateViews()
	if not self.tLogData then
		return
	end
	--当前天数
	local nLogSec = self.tLogData.seconds

	--标题
	self.pGroupTitle:setString(string.format(getConvertedStr(1, 10319), nLogSec/60))

	--物品列表
	local tDropList = self.tLogData.awards
	--奖励列表
	self:setGoodsListViewData(tDropList)

	local tAct = Player:getActById(e_id_activity.onlinewelfare)

    --是否已经领取
    local bIsGot = tAct:getIsRewarded(nLogSec)
    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")
    	self.pBtnGet:setVisible(not bIsGot)
    	self:setLabelVisible(not bIsGot)
    end
    --是否可领取
    local bCanGet = tAct:getIsCanReward(nLogSec)
    self.pBtnGet:setVisible(bCanGet)
    if bCanGet then
    	self.pImgGot:setVisible(not bCanGet)
    	self:setLabelVisible(not bCanGet)
    end
    --是否未达到
    local bNotLog = tAct:getNotLog(nLogSec)
    if bNotLog then
    	self:setRewardStateImg("#v2_fonts_weidadao.png")
    	self.pImgGot:setVisible(bNotLog)
    	self.pBtnGet:setVisible(not bNotLog)
    end

    if tAct:isShowCD(nLogSec) then
    	self:showCD()
    else
    	self:hideCD()
    end
end


function ItemOWGetReward:setItemData( _tLogData)
	self.tLogData = _tLogData
	local tAct = Player:getActById(e_id_activity.onlinewelfare)
	self.nSt = tAct.nStartST
	self.nOt = tAct.nOt
	self:onUpdateTime()
	-- self:updateViews()
end

--领取点击事件
function ItemOWGetReward:onGetClicked( pView )
	SocketManager:sendMsg("onlineWelfare", {self.tLogData.seconds}, function(__msg)
		dump(__msg, "__msg")
	    if  __msg.head.state == SocketErrorType.success then 
	        if __msg.head.type == MsgType.onlineWelfare.id then
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

function ItemOWGetReward:showCD()
	--注册定时器，每隔interval刷新
	self.pLbState:setVisible(true)
end

function ItemOWGetReward:hideCD()
	self.pLbState:setVisible(false)
end

function ItemOWGetReward:resSchedule()
	if(not self.nUpHandler) then
	    self.nUpHandler = MUI.scheduler.scheduleGlobal(
	        handler(self, self.onUpdateTime), 1)
	end
	-- body
end

function ItemOWGetReward:unresSchedule()
	if(self.nUpHandler) then
		MUI.scheduler.unscheduleGlobal(self.nUpHandler)
		self.nUpHandler = nil
	end
end

return ItemOWGetReward