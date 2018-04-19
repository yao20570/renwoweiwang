----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2017-12-22 14:27:20
-- Description: 充值签到列表子项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")
local ItemRechargeSignReward = class("ItemRechargeSignReward", function()
	return ItemActGetReward.new()
end)

function ItemRechargeSignReward:ctor(  )
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemRechargeSignReward",handler(self, self.onDestroy))	
end

function ItemRechargeSignReward:regMsgs(  )
end

function ItemRechargeSignReward:unregMsgs(  )
end

function ItemRechargeSignReward:onResume(  )
	self:regMsgs()
end

function ItemRechargeSignReward:onPause(  )
	self:unregMsgs()
end


function ItemRechargeSignReward:onDestroy(  )
	self:onPause()
end

function ItemRechargeSignReward:setupViews()
	self.tDayStr={
		"一",
		"二",
		"三",
		"四",
		"五",
		"六",
		"七",
		"八",
		"九",
		"十",
	}

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


function ItemRechargeSignReward:updateViews(  )
	if not self.tData then
		return
	end
	self:setLabelVisible(false)
	if self.nType == 1 then   --免费领取
		self.pBtnGet:setExTextVisiable(false)
		self.nState = self.tData:getFreeRewardState()
		if self.nState == 1 then 		--已领取
			
			self.pBtnGet:setVisible(false)
		    self:setRewardStateImg("#v2_fonts_yilingqu.png")

		else

			self:hideRewardStateImg()
			self.pBtnGet:setVisible(true)
			self.pBtnGet:updateBtnText(getConvertedStr(5, 10208))
	    	self.pBtnGet:updateBtnType(TypeCommonBtn.M_YELLOW)
		end
		--标题
		self.pTxtBanner:setString(getConvertedStr(9,10060))
		--物品列表
		local tDropList = self.tData.tFi
		--奖励列表
		self:setGoodsListViewData(tDropList)

	elseif self.nType == 2 then
		--当前天数
		local nDay = self.tData.d
		--第几天
		local sStr=getTextColorByConfigure(string.format(getConvertedStr(9, 10058), self.tDayStr[nDay],self.tData.g)) 
		--标题
		self.pTxtBanner:setString(sStr)

		--物品列表
		local tDropList = self.tData.i
		--奖励列表
		self:setGoodsListViewData(tDropList)

		local tAct = Player:getActById(e_id_activity.rechargesign)
    	self.pBtnGet:setExTextVisiable(false)

	    --奖励状态
	    self.nState = tAct:getRewardState(nDay)
	    if self.nState == 4 then		--已领取
		    self.pBtnGet:setVisible(false)
    		self:setRewardStateImg("#v2_fonts_yilingqu.png")

	    elseif self.nState == 1 then 	--可领取
	    	self:hideRewardStateImg()
	    	self.pBtnGet:setVisible(true)
	    	self.pBtnGet:updateBtnText(getConvertedStr(5, 10208))
	    	self.pBtnGet:updateBtnType(TypeCommonBtn.M_YELLOW)
	    elseif self.nState == 2 then 		--当天要完成的
    		self.pBtnGet:setExTextVisiable(true)

    		self.pBtnGet:setExTextLbCnCr(1, tAct.nG)
    		self.pBtnGet:setExTextLbCnCr(2, "/"..tostring(self.tData.g))

	    	self:hideRewardStateImg()
	    	self.pBtnGet:setVisible(true)

	    	self.pBtnGet:updateBtnText(getConvertedStr(9, 10059))
	    	self.pBtnGet:updateBtnType(TypeCommonBtn.M_BLUE)
	    elseif self.nState == 3 then		--未开启
		    self.pBtnGet:setVisible(false)
		    self:setRewardStateImg("#v2_fonts_weikaiqi.png")
		end
	end

 --    --是否可领取
 --    local bCanGet = tAct:getIsCanReward(nLogDay)
 --    self.pBtnGet:setVisible(bCanGet)
 --    if bCanGet then
 --    	self.pImgGot:setVisible(not bCanGet)
 --    	self:setLabelVisible(not bCanGet)
 --    end
 --    --是否未达到
 --    local bNotLog = tAct:getNotLog(nLogDay)
 --    self:setLabelVisible(bNotLog)
 --    if bNotLog then
 --    	self.pImgGot:setVisible(not bNotLog)
 --    	self.pBtnGet:setVisible(not bNotLog)
 --    end
end
--_nType 1- 免费签到 2-普通签到
function ItemRechargeSignReward:setData( _tData ,_nType)
	-- body
	self.tData=_tData
	self.nType= _nType or 1
	self:updateViews()
end

--领取点击事件
function ItemRechargeSignReward:onGetClicked( pView )
	if self.nType == 1 and self.nState == 0 then  --免费奖励
		SocketManager:sendMsg("getFreeRechargeSign", {}, function(__msg)
			-- body
			self:updateData(__msg.body)

			if __msg.body and __msg.body.ob then
				--奖励领取表现(包含有武将的情况走获得武将流程)
				showGetItemsAction(__msg.body.ob)					
			end
		end)
	elseif self.nType == 2 then  --普通签到
		if self.nState == 1 then 		--可领取
			SocketManager:sendMsg("getRechargeSign", {self.tData.d}, function(__msg)
				-- body
				self:updateData(__msg.body)
				if __msg.body and __msg.body.ob then
					--奖励领取表现(包含有武将的情况走获得武将流程)
					showGetItemsAction(__msg.body.ob)					
				end
			end)
		elseif self.nState == 2 then 		--要签到
			local tObject = {}
		    tObject.nType = e_dlg_index.dlgrecharge --dlg类型
		    sendMsg(ghd_show_dlg_by_type,tObject)   
		end
	end
end

function ItemRechargeSignReward:updateData( _tData )
	if not _tData then
		return
	end
	-- body
	local tActData = Player:getActById(e_id_activity.rechargesign)
	tActData:refreshDatasByServer(_tData)
	sendMsg(gud_refresh_activity) --通知刷新界面


end

return ItemRechargeSignReward