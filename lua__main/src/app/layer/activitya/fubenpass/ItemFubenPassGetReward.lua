----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2018-02-27 11:13
-- Description: 通用领奖列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemFubenPassGetReward = class("ItemFubenPassGetReward", function()
	return ItemActGetReward.new()
end)

--点击领取按钮响应间隔
local nDistanceTime = 1000

function ItemFubenPassGetReward:ctor(  )
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemFubenPassGetReward",handler(self, self.onItemFubenPassGetRewardDestroy))	
end

function ItemFubenPassGetReward:regMsgs(  )
end

function ItemFubenPassGetReward:unregMsgs(  )
end

function ItemFubenPassGetReward:onResume(  )
	self:regMsgs()
end

function ItemFubenPassGetReward:onPause(  )
	self:unregMsgs()
end


function ItemFubenPassGetReward:onItemFubenPassGetRewardDestroy(  )
	self:onPause()
end

function ItemFubenPassGetReward:setupViews(  )
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet
	
	local tConTable = {}
	--文本
	local tLabel = {
	 {"0",getC3B(_cc.green)},
	 {"/0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	self.pBtnGet:setBtnExText(tConTable) 

end


function ItemFubenPassGetReward:updateViews(  )
	if not self.tConf then
		return
	end
	--标题
	local tStr = {
		{text = getConvertedStr(7, 10338), color = _cc.white},
		{text = self.tConf.nTarFubenId, color = _cc.green},
		{text = getConvertedStr(7, 10339), color = _cc.white}
	}
	self.pTxtBanner:setString(tStr)

	--物品列表
	local tDropList = self.tConf.tAwards
	self:setGoodsListViewData(tDropList)

	local tData = Player:getActById(e_id_activity.fubenpass)
	if not tData then
		return
	end
    --是否已经领取
    local bIsGot = tData:getIsRewarded(self.tConf.nIndex)

    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

    	self.pBtnGet:setVisible(false)
    	self.pBtnGet:setExTextVisiable(false)
    else
    	self:hideRewardStateImg()
    	self.pBtnGet:setVisible(true)
    	self.pBtnGet:setExTextVisiable(true)
    	if tData.nCurPassId > self.tConf.nTarFubenId then
    		self.pBtnGet:setExTextLbCnCr(1, self.tConf.nTarFubenId)
    	else
    		self.pBtnGet:setExTextLbCnCr(1, tData.nCurPassId)
    	end
    	self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(self.tConf.nTarFubenId))
    	--是否可领取
    	self.isCanGet = tData:getIsCanReward(self.tConf.nIndex)
    	if self.isCanGet then
    		self.pBtnGet:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10213))
    	else
    		self.pBtnGet:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(3, 10367))
    	end
    end
end

function ItemFubenPassGetReward:setData(_tConf)
	self.tConf = _tConf
	self:updateViews()
end

function ItemFubenPassGetReward:onGetClicked( pView )
	if self.isCanGet then
		--加一个响应时间间隔, 以防玩家点击过快
		if self.nLastClickTime then
			local nCurTime = getSystemTime(false)
			if (nCurTime - self.nLastClickTime) < nDistanceTime then
				return
			end
		end
		self.nLastClickTime = getSystemTime(false)
		SocketManager:sendMsg("reqFubenPassReward", {self.tConf.nIndex}, function(__msg, __oldMsg)
			if __msg.body then
				--奖励动画展示
				showGetAllItems(__msg.body.ob, 1)
			end
		end)
	else
		--跳到副本界面
		local bIsOpen = getIsReachOpenCon(2)
		if not bIsOpen then
			return
		end
		local tObject = {}
		tObject.nType = e_dlg_index.fubenmap 	--跳到副本
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end


return ItemFubenPassGetReward


