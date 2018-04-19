----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-05 11:58:31
-- Description: 全民反利领奖列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemPeopleRebateGetReward = class("ItemPeopleRebateGetReward", function()
	return ItemActGetReward.new()
end)

function ItemPeopleRebateGetReward:ctor(  )
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemPeopleRebateGetReward",handler(self, self.onItemPeopleRebateGetRewardDestroy))	
end

function ItemPeopleRebateGetReward:regMsgs(  )
end

function ItemPeopleRebateGetReward:unregMsgs(  )
end

function ItemPeopleRebateGetReward:onResume(  )
	self:regMsgs()
end

function ItemPeopleRebateGetReward:onPause(  )
	self:unregMsgs()
end


function ItemPeopleRebateGetReward:onItemPeopleRebateGetRewardDestroy(  )
	self:onPause()
end

function ItemPeopleRebateGetReward:setupViews(  )
	--标题文本
	local pLayGroupTitle = self.pLayGroupTitle
	local tConTable = {}
    local tLabel = {
     {getConvertedStr(3, 10373)},
     {"0",getC3B(_cc.blue)},
     {getCostResName(e_type_resdata.money)},
    }
    tConTable.tLabel = tLabel
    self.pGroupTitle =  createGroupText(tConTable)
    pLayGroupTitle:addView(self.pGroupTitle)

    --获取按钮
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10213))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet

	--创建文本
	self:createLabel()

	--文置偏移
	pLayBtnGet:setPositionX(500 - pLayBtnGet:getContentSize().width/2)
	self.pLabel:setPositionX(500)
	self.pImgGot:setPositionX(500)
end


function ItemPeopleRebateGetReward:updateViews(  )
	if not self.tPeopleRecBackAllVo then
		return
	end

	--元宝
	local nGold = self.tPeopleRecBackAllVo.nGold

	--标题
	self.pGroupTitle:setLabelCnCr(2, nGold) 

	--物品列表
	local tDropList = self.tPeopleRecBackAllVo.tAwards
	self:setGoodsListViewData(tDropList)

    --是否领取按钮
    self.pImgGot:setVisible(false)
    self.pLabel:setVisible(false)
    self.pBtnGet:setVisible(false)
    local tData = Player:getActById(e_id_activity.peoplerebate)
	if tData then
		local bIsGot = tData:getIsGotReward(nGold)
		local bIsCanGet = tData:getIsCanGetReward(nGold)
		if bIsGot then
			self:setRewardStateImg("#v2_fonts_yilingqu.png")
			-- self.pImgGot:setVisible(true)
		elseif bIsCanGet then
			self:hideRewardStateImg()
			self.pBtnGet:setVisible(true)
		else
			self:setRewardStateImg("#v2_fonts_weidadao.png")
			-- self.pLabel:setVisible(true)
		end
	end
end

--tPeopleRecBackAllVo: PeopleRecBackAllVo
function ItemPeopleRebateGetReward:setData( tPeopleRecBackAllVo )
	self.tPeopleRecBackAllVo = tPeopleRecBackAllVo
	self:updateViews()
end

function ItemPeopleRebateGetReward:onGetClicked( pView )
	if not self.tPeopleRecBackAllVo then
		return
	end
	SocketManager:sendMsg("reqPeopleRebateReward", {self.tPeopleRecBackAllVo.nGold}, function ( __msg )
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.reqPeopleRebateReward.id then
				showGetAllItems(__msg.body.o)
			end
	    end
	end)
end


return ItemPeopleRebateGetReward


