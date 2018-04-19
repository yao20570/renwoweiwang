----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-29 22:21:20
-- Description: 通用领奖列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemNanBeiGetReward = class("ItemNanBeiGetReward", function()
	return ItemActGetReward.new()
end)

function ItemNanBeiGetReward:ctor(  )
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemNanBeiGetReward",handler(self, self.onItemNanBeiGetRewardDestroy))	
end

function ItemNanBeiGetReward:regMsgs(  )
end

function ItemNanBeiGetReward:unregMsgs(  )
end

function ItemNanBeiGetReward:onResume(  )
	self:regMsgs()
end

function ItemNanBeiGetReward:onPause(  )
	self:unregMsgs()
end


function ItemNanBeiGetReward:onItemNanBeiGetRewardDestroy(  )
	self:onPause()
end

function ItemNanBeiGetReward:setupViews(  )
	-- local pLayGroupTitle = self.pLayGroupTitle
	-- local tConTable = {}
 --    local tLabel = {
 --     {getConvertedStr(3, 10368)},
 --     {"0",getC3B(_cc.blue)},
 --     {getConvertedStr(3, 10007)},
 --    }
 --    tConTable.tLabel = tLabel
 --    self.pGroupTitle =  createGroupText(tConTable)
 --    pLayGroupTitle:addView(self.pGroupTitle)

	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
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


function ItemNanBeiGetReward:updateViews(  )
	if not self.tMission then
		return
	end
	--标题
	-- self.pGroupTitle:setLabelCnCr(2, tostring(self.tMission.nTimes) .. getConvertedStr(3, 10369))
	-- dump(self.tMission:getDescColorStr(),"self.tMission:getDescColorStr()") 
	self.pTxtBanner:setString(getTextColorByConfigure(self.sTitle))

	--物品列表
	local tDropList = self.tMission.tAward
	self:setGoodsListViewData(tDropList)

	local tData = Player:getActById(e_id_activity.nanbeiwar)
	if not tData then
		return
	end
    --是否已经领取
    local bIsGot = tData:getIsRewarded(self.tMission.nId)

    if bIsGot then
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

    	self.pBtnGet:setVisible(false)
    	self.pBtnGet:setExTextVisiable(false)
    else
    	self:hideRewardStateImg()
    	self.pBtnGet:setVisible(true)
    	self.pBtnGet:setExTextVisiable(true)
    	local nCurrTimes = Player:getActById(e_id_activity.nanbeiwar):getFinishTimes(self.tMission.nId)
    	local nNeedTimes = self.tMission.nTimes
    	self.pBtnGet:setExTextLbCnCr(1, nCurrTimes)
    	self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(nNeedTimes))
    	--是否可领敢
    	self.isCanGet = tData:getIsCanGetReward(self.tMission)
    	if self.isCanGet then
    		self.pBtnGet:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10213))
    	else
    		self.pBtnGet:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(3, 10367))
    	end
    end
end

--tMission: CountryWarActMission
function ItemNanBeiGetReward:setData( tMission ,_sTitle)
	self.tMission = tMission
	self.sTitle = _sTitle or ""
	self:updateViews()
end

function ItemNanBeiGetReward:onGetClicked( pView )
	if not self.tMission then
		return
	end
	if self.isCanGet then
		SocketManager:sendMsg("reqNanBeiWarReward", {self.tMission.nId}, function(__msg, __oldMsg)
			if __msg.body then
				--奖励动画展示
				showGetAllItems(__msg.body.ob, 1)
			end
		end)
	else
		--切换世界地图
		sendMsg(ghd_home_show_base_or_world, 2)
    	--关闭活动a界面
    	closeDlgByType( e_dlg_index.actmodela, false)
	end
end


return ItemNanBeiGetReward


