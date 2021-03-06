-- ItemSevDayGetReward.lua
----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2017-07-04 20:53:20
-- Description: 领奖列表子项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemSevDayGetReward = class("ItemSevDayGetReward", function()
	return ItemActGetReward.new()
end)

function ItemSevDayGetReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemSevDayGetReward",handler(self, self.onItemSevDayGetRewardDestroy))	
end

function ItemSevDayGetReward:regMsgs(  )
end

function ItemSevDayGetReward:unregMsgs(  )
end

function ItemSevDayGetReward:onResume(  )
	self:regMsgs()
end

function ItemSevDayGetReward:onPause(  )
	self:unregMsgs()
end


function ItemSevDayGetReward:onItemSevDayGetRewardDestroy(  )
	self:onPause()
end

function ItemSevDayGetReward:setupViews()
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


function ItemSevDayGetReward:updateViews(  )
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

	local tAct = Player:getActById(e_id_activity.sevendaylog)

    --是否已经领取
    local bIsGot = tAct:getIsRewarded(nLogDay)
    -- self.pImgGot:setVisible(bIsGot)
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

    	-- self.pImgGot:setVisible(not bCanGet)
    	self:setLabelVisible(not bCanGet)
    end
    --是否未达到
    local bNotLog = tAct:getNotLog(nLogDay)
    -- self:setLabelVisible(bNotLog)
    if bNotLog then
    	self:setRewardStateImg("#v2_fonts_weidadao.png")
    	
    	-- self.pImgGot:setVisible(not bNotLog)
    	self.pBtnGet:setVisible(not bNotLog)
    end
end


function ItemSevDayGetReward:setItemSevenData( _tLogData )
	self.tLogData = _tLogData
	self:updateViews()
end

--领取点击事件
function ItemSevDayGetReward:onGetClicked( pView )
	SocketManager:sendMsg("reqSevenDayAwards", {self.tLogData.d}, function(__msg)
		-- body
		if __msg.body and __msg.body.o then
			--奖励领取表现(包含有武将的情况走获得武将流程)
			showGetItemsAction(__msg.body.o)					
		end
	end)
end


return ItemSevDayGetReward