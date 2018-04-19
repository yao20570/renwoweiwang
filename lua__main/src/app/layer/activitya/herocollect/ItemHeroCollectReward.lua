----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-02-28 17:23:20
-- Description: 武将收集列表子项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemHeroCollectReward = class("ItemHeroCollectReward", function()
	return ItemActGetReward.new()
end)

function ItemHeroCollectReward:ctor(  )
	self:setupViews()
	self:myInit()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemHeroCollectReward",handler(self, self.onDestroy))	
end

function ItemHeroCollectReward:myInit(  )
	-- body
	self.tTitle={
		getConvertedStr(9,10164),
		getConvertedStr(9,10165),
		getConvertedStr(9,10166),
		getConvertedStr(9,10167),
		getConvertedStr(9,10168),
		getConvertedStr(9,10169),
		getConvertedStr(9,10170),
	}
end

function ItemHeroCollectReward:regMsgs(  )
end

function ItemHeroCollectReward:unregMsgs(  )
end

function ItemHeroCollectReward:onResume(  )
	self:regMsgs()
end

function ItemHeroCollectReward:onPause(  )
	self:unregMsgs()
end


function ItemHeroCollectReward:onDestroy(  )
	self:onPause()
end

function ItemHeroCollectReward:setupViews()

    --领取按钮层
	local pLayBtnGet = self.pLayBtnGet
	local pBtnGet = getCommonButtonOfContainer(pLayBtnGet,TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet = pBtnGet

	self:setRewardStateImg("#v1_fonts_yiqiandao.png")

	 --领取按钮层
    local tConTable = {}
	--文本
	local tLabel = {
	 {"0",getC3B(_cc.green)},
	 {"/0",getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	self.pBtnGet:setBtnExText(tConTable) 

end

function ItemHeroCollectReward:updateViews(  )
	if not self.tData then
		return
	end
	self:setLabelVisible(false)
	local sStr=getTextColorByConfigure(string.format(self.tTitle[self.tData.quality],self.tData.num))
	--标题
	self.pTxtBanner:setString(sStr)

	--物品列表
	local tDropList = self.tData.ob
	--奖励列表
	self:setGoodsListViewData(tDropList)

	self.pBtnGet:setExTextVisiable(true)

    self.pBtnGet:setExTextLbCnCr(1, self.tData.curNum)
    self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(self.tData.num))
	if self.tData.state == 3 then		--已领取
		self.pBtnGet:setExTextVisiable(false)
		self.pBtnGet:setVisible(false)
    	self:setRewardStateImg("#v2_fonts_yilingqu.png")

	elseif self.tData.state == 1 then 	--可领取
	    self:hideRewardStateImg()
	    self.pBtnGet:setVisible(true)
	    self.pBtnGet:updateBtnText(getConvertedStr(5, 10208))
	    self.pBtnGet:updateBtnType(TypeCommonBtn.M_YELLOW)
	elseif self.tData.state == 2 then 		--未完成
    	

	    self:hideRewardStateImg()
	    self.pBtnGet:setVisible(true)

	    self.pBtnGet:updateBtnText(getConvertedStr(3, 10367))
	    self.pBtnGet:updateBtnType(TypeCommonBtn.M_BLUE)
	end
end

function ItemHeroCollectReward:setData( _tData ,_nType)
	-- body
	self.tData=_tData
	self.nType= _nType or 1
	self:updateViews()
end

--领取点击事件
function ItemHeroCollectReward:onGetClicked( pView )
	if self.tData.state == 1 then  --可领奖
		-- print()
		SocketManager:sendMsg("getHeroCollectReward", {self.tData.id}, function(__msg)
			-- body
			if  __msg.head.state == SocketErrorType.success then 
				self:updateData(__msg.body)
				if __msg.body and __msg.body.ob then
					--奖励领取表现(包含有武将的情况走获得武将流程)
					showGetItemsAction(__msg.body.ob)					
				end
			end
		end)
	elseif self.tData.state == 2 then  --未完成
			self:jumpToLayer()
	end
end

function ItemHeroCollectReward:jumpToLayer( )
	-- body
	local tActData = Player:getActById(e_id_activity.herocollect)
	local  nDlgId = tActData:getJumpLayerId(self.tData.id)

	local tObject = {}
	if nDlgId == e_dlg_index.fubenmap then  --跳转副本

		
	elseif nDlgId == e_dlg_index.herorecommend then  --跳转名将推荐

		local bIsBought3 = Player:getPlayerInfo():getIsBoughtVipGift(3)
		local bIsBought6 = Player:getPlayerInfo():getIsBoughtVipGift(6)
		local bIsBought9 = Player:getPlayerInfo():getIsBoughtVipGift(9)
		--有时间就显示，没时间就关闭显示
		local nCd = Player:getPlayerInfo():getHeroRecommondCd()
		
		if nCd > 0 then
			if bIsBought3 and self.tData.quality == 3 then
				nDlgId=e_dlg_index.fubenmap
			elseif bIsBought6 and self.tData.quality == 4 then
				nDlgId=e_dlg_index.fubenmap
			elseif bIsBought9 and self.tData.quality == 5 then
				nDlgId=e_dlg_index.fubenmap
			end
 
			tObject.nQuality = self.tData.quality
		else
			nDlgId=e_dlg_index.fubenmap
		end
	
	elseif nDlgId == e_dlg_index.actmodela then  --跳转七日签到
		local tActData = Player:getActById(e_id_activity.sevendaylog)
		if tActData then
			
			tObject.nActID = tonumber(e_id_activity.sevendaylog) or 0 --活动id
		else
			nDlgId=e_dlg_index.fubenmap
		end

	end

	if nDlgId == e_dlg_index.herorecommend then
		closeDlgByType(e_dlg_index.actmodela,false)
	end

	tObject.nType = nDlgId --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
	
end

function ItemHeroCollectReward:updateData( _tData )
	if not _tData then
		return
	end
	-- body
	local tActData = Player:getActById(e_id_activity.herocollect)
	tActData:refreshDatasByServer(_tData)
	sendMsg(gud_refresh_activity) --通知刷新界面

end

return ItemHeroCollectReward