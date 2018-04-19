----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-11-23 14:42:20
-- Description: 红包馈赠领奖项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemRedPacketReward = class("ItemRedPacketReward", function()
	return ItemActGetReward.new()
end)

function ItemRedPacketReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemRedPacketReward",handler(self, self.onItemRedPacketRewardDestroy))	
end

function ItemRedPacketReward:regMsgs(  )
end

function ItemRedPacketReward:unregMsgs(  )
end

function ItemRedPacketReward:onResume(  )
	self:regMsgs()
end

function ItemRedPacketReward:onPause(  )
	self:unregMsgs()
end


function ItemRedPacketReward:onItemRedPacketRewardDestroy(  )
	self:onPause()
end

function ItemRedPacketReward:setupViews()
	--第几天
	-- local pTitle = self.pTxtBanner

	-- local tConTable = {}
 --    local tLabel = {
 --     {getConvertedStr(7, 10129)},
 --     {"1",getC3B(_cc.yellow)},
 --     {getConvertedStr(7, 10036)},
 --    }
 --    tConTable.tLabel = tLabel
 --    tConTable.fontSize = 20
 --    self.pGroupTitle =  createGroupText(tConTable)
 --    pLayGroupTitle:addView(self.pGroupTitle)

    --领取按钮层
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet

	local tConTable = {}
	--文本
	local tLabel = {
	 {"0",getC3B(_cc.green)},
	 {"/0",getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	self.pBtnGet:setBtnExText(tConTable) 
end


function ItemRedPacketReward:updateViews(  )
	if not self.tAwdInfo then
		return
	end

	--需消费黄金数量
	local nGold = self.tAwdInfo.t

	--标题
	local stitle = string.format(getConvertedStr(6, 10598), tostring(nGold)) 
	self.pTxtBanner:setString(getTextColorByConfigure(stitle), false)
	--self.pGroupTitle:setLabelCnCr(2, tostring(nGold))

	--物品列表
	local tDropList = self.tAwdInfo.i
	--奖励列表
	self:setGoodsListViewData(tDropList)

	self.tAct = Player:getActById(e_id_activity.redpacket)

    --是否已经领取
    self.bIsGot = self.tAct:getIsRewarded(nGold)
    if self.bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

    	self.pBtnGet:setVisible(false)
    	self.pBtnGet:setExTextVisiable(false)
    else
    	self:hideRewardStateImg()
    	self.pBtnGet:setVisible(true)
    	self.pBtnGet:setExTextVisiable(true)
    	local nCurrRecharge = self.tAct.nGoldNum
    	self.pBtnGet:setExTextLbCnCr(1, nCurrRecharge)
    	self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(nGold))
    	--是否可领取
    	self.isCanGet = self.tAct:getIsCanReward(nGold)
    	if self.isCanGet then
    		self.pBtnGet:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10213))
    	else
    		self.pBtnGet:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(6, 10301))
    	end
    end
end


function ItemRedPacketReward:setItemAwdInfo( _tData )
	self.tAwdInfo = _tData
	self:updateViews()
end

--领取点击事件
function ItemRedPacketReward:onGetClicked( pView )
	local nGold = self.tAwdInfo.t
	self.isCanGet = self.tAct:getIsCanReward(nGold)
	self.bIsGot = self.tAct:getIsRewarded(nGold)
	if not self.bIsGot and not self.isCanGet then		
		--跳转到充值界面
		local tObject = {}
		tObject.nType = e_dlg_index.dlgrecharge --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)  
		--closeDlgByType( e_dlg_index.actmodela, false)
	else
		SocketManager:sendMsg("reqredpacket", {self.tAwdInfo.t}, function(__msg, __oldMsg)
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
end


return ItemRedPacketReward