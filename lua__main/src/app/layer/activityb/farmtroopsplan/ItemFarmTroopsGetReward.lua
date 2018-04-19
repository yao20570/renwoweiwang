-- ItemFarmTroopsGetReward.lua
----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-08-07 15:19:31
-- Description: 屯田计划领奖列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemFarmTroopsGetReward = class("ItemFarmTroopsGetReward", function()
	return ItemActGetReward.new()
end)

function ItemFarmTroopsGetReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemFarmTroopsGetReward",handler(self, self.onItemFarmTroopsGetRewardDestroy))	
end

function ItemFarmTroopsGetReward:regMsgs(  )
end

function ItemFarmTroopsGetReward:unregMsgs(  )
end

function ItemFarmTroopsGetReward:onResume(  )
	self:regMsgs()
end

function ItemFarmTroopsGetReward:onPause(  )
	self:unregMsgs()
end


function ItemFarmTroopsGetReward:onItemFarmTroopsGetRewardDestroy(  )
	self:onPause()
end

function ItemFarmTroopsGetReward:setupViews(  )
    self.pLayRoot:setLayoutSize(600, 233)
    self.pLayRoot:setBackgroundImage("#v1_bg_kelashen.png", {scale9 = true, capInsets = cc.rect(22, 22, 1, 1)})
    self.pLyBanner = self:findViewByName("lay_banner")
    self.pLyBanner:setPositionY(191)
    self.pLayGoods:setLayoutSize(490, 178)
    -- self.pLayGoods:setBackgroundImage("#v1_img_black50.png", {scale9 = true, capInsets = cc.rect(10, 10, 1, 1)})
    self.pLayGoods:setPosition(0, self.pLayGoods:getPositionY() + 10)
    --获取按钮
	local pLayBtnGet = self.pLayBtnGet
	pLayBtnGet:setPosition(600 - pLayBtnGet:getContentSize().width + 22, pLayBtnGet:getPositionY() + 15)
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10079))
	pBtnGet:setScale(0.7)
	pBtnGet:updateBtnTextSize(26)
	pBtnGet:onCommonBtnClicked(handler(self, self.onBtnClicked))
	self.pBtnGet = pBtnGet

	--文置偏移
    self.pImgGot:setVisible(false)

end


function ItemFarmTroopsGetReward:updateViews()
	if not self.tFarmPlans then
		return
	end

	self.nPlanId = self.tFarmPlans.id

	--元宝
	self.nGold = self.tFarmPlans.cost[1].v

	--标题
	if not self.pGroupTitle then
		self.pGroupTitle =  MUI.MLabel.new({
    		text = "农务计划",
    		size = 20,
    		anchorpoint = cc.p(0.5, 0.5),
    	})
    	self.pLayGroupTitle:addView(self.pGroupTitle)
   		centerInView(self.pLayGroupTitle, self.pGroupTitle)
	end
	if self.nPlanId == e_farmplan_type.agricultural then    --农务
		self.pGroupTitle:setString(getConvertedStr(7, 10132))
		setTextCCColor(self.pGroupTitle, _cc.yellow)
	elseif self.nPlanId == e_farmplan_type.military then    --军务
		self.pGroupTitle:setString(getConvertedStr(7, 10134)) 
		setTextCCColor(self.pGroupTitle, _cc.red)
	elseif self.nPlanId == e_farmplan_type.business then    --商务
		self.pGroupTitle:setString(getConvertedStr(7, 10133)) 
		setTextCCColor(self.pGroupTitle, _cc.blue)
	end

	if not self.tAct then
		self.tAct = Player:getActById(e_id_activity.farmtroopsplan)
	end

	--如果没有购买计划
	if not self.tAct:isBoughtPlan(self.nPlanId) then
		if not self.pImgLabel then
			self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtnGet})
			self.pImgLabel:setImg("#v1_img_qianbi.png", 1, "left")
			self.pImgLabel:followPos("center", self.pBtnGet:getWidth()/2 - 4, self.pBtnGet:getHeight() + 25, 5)
		end

		local tLabel = {
			{text = self.nGold, color = getC3B(_cc.yellow)}
		}
		self.pImgLabel:setString(tLabel)
		self.pImgLabel:setVisible(true)

		self.pBtnGet:updateBtnText(getConvertedStr(7, 10079))
		self.pBtnGet:setBtnEnable(true)
		self.isCanGet = false
	else
		if self.pImgLabel and self.pImgLabel.remove then
			self.pImgLabel:remove()
		end
		if not self.lbBought then
			self.lbBought = MUI.MLabel.new({text = "", size = 20})
			self.pLayBtnGet:addView(self.lbBought, 10)
			self.lbBought:setPosition(self.pBtnGet:getWidth()/2 - 4, self.pBtnGet:getHeight() + 25)
			setTextCCColor(self.lbBought, _cc.green)
		end
		self.lbBought:setString(getConvertedStr(7, 10090))
		--如果能领取奖励
		self.nDay = self.tAct:isCanGetAward(self.nPlanId)
		if self.nDay then
			self.pBtnGet:setBtnEnable(true)
			self.pBtnGet:updateBtnText(getConvertedStr(7, 10086))
		else
			self.pBtnGet:setBtnEnable(false)
			self.pBtnGet:updateBtnText(getConvertedStr(7, 10087))
		end
		self.isCanGet = true
	end

	--物品列表
	local tDropList = self.tFarmPlans.aw
	--底部文字
	local tStr = {}
	tStr.str = string.format(getConvertedStr(7, 10110), 1)
	tStr.color = _cc.green

	self:setGoodsListViewData(tDropList, tStr, self.tAct, self.nPlanId)

end


function ItemFarmTroopsGetReward:setItemAwdInfo(_tData, _tAct)
	self.tFarmPlans = _tData
	self.tAct = _tAct
	self:updateViews()
end

--按钮事件点击
function ItemFarmTroopsGetReward:onBtnClicked( pView )
	if not self.tFarmPlans then
		return
	end
	if self.isCanGet then
		if self.nDay then
			SocketManager:sendMsg("reqGetFarmPlanAwards", {self.nPlanId, self.nDay}, function(__msg, __oldMsg)
				-- body
				if  __msg.head.state == SocketErrorType.success then
					local tAwd = self.tAct:getPlanAwards(__oldMsg[1], __oldMsg[2])
					--奖励动画展示
					showGetAllItems(tAwd, 1)
				end
			end)
		end
	else
		local strTips ={
			{color = _cc.pwhite,text = getConvertedStr(7, 10148)},--购买此计划?
		}
		--展示购买对话框
		showBuyDlg(strTips, self.nGold, function ()
		 	SocketManager:sendMsg("reqBuyFarmPlan", {self.nPlanId}, function(__msg)
				if  __msg.head.state == SocketErrorType.success then
					TOAST(getConvertedStr(7, 10135))
				end
			end)          
		end, 0, true)

	end
	
end


return ItemFarmTroopsGetReward
