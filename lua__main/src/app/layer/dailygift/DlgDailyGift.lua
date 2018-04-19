-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-1-3 11:33:17 星期三
-- Description: 免费宝箱对话框
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local MBtnExText = require("app.common.button.MBtnExText")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")
local ShopFunc = require("app.layer.shop.ShopFunc")

local DlgDailyGift = class("DlgDailyGift", function ()
	return DlgAlert.new(e_dlg_index.dlgdailygift, nil, 70)
end)

--构造
function DlgDailyGift:ctor()
	-- body
	parseView("dlg_daily_gift", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function DlgDailyGift:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, false)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgDailyGift",handler(self, self.onDestroy))
end

--初始化控件
function DlgDailyGift:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10186))

	-- self.pTxtRewardTitle2=self:findViewByName("txt_reward_title2")
	local pLayBtn1=self:findViewByName("lay_daily_gift_btn")
	self.pBtnDailyGift = getCommonButtonOfContainer(pLayBtn1, TypeCommonBtn.M_YELLOW, getConvertedStr(5, 10208), false)
	self.pBtnDailyGift:onCommonBtnClicked(handler(self, self.onDailyGiftClicked))
	setMCommonBtnScale(pLayBtn1, self.pBtnDailyGift, 0.8)
	self.pTxtTime=self:findViewByName("txt_time")
	setTextCCColor(self.pTxtTime, _cc.red)
	local pLayBtn2=self:findViewByName("lay_discount_gift_btn")
	self.pBtnDiscount = getCommonButtonOfContainer(pLayBtn2, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10524), false)
	self.pBtnDiscount:onCommonBtnClicked(handler(self, self.onDiscountClicked))
	setMCommonBtnScale(pLayBtn2, self.pBtnDiscount, 0.8)

	--折扣商品价格
	self.pImgLabel = MImgLabel.new({text="", size = 18, parent = pLayBtn2})
	self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 0.8, "left")
	-- self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 1, "center")
	self.pImgLabel:followPos("center", pLayBtn2:getContentSize().width/2, pLayBtn2:getContentSize().height + 10, 10)


	self.pLayIcon1= self:findViewByName("lay_icon1")
	self.pLayIcon2= self:findViewByName("lay_icon2")
	
	self.tGoods = nil

	local pTxtDesc1= self:findViewByName("txt_desc1")
	pTxtDesc1:setString(getConvertedStr(9,10068))
	self.pTxtDesc2= self:findViewByName("txt_desc2")
	self.pTxtDesc2:setString(getConvertedStr(9,10069))

	
end

-- 修改控件内容或者是刷新控件数据
function DlgDailyGift:updateViews()
	-- body
	self.tData = Player:getDailyGiftData()

	if not self.pIcon1 then
        
        self.pIcon1 = IconGoods.new(TypeIconGoods.HADMORE)
        self.pLayIcon1:addView(self.pIcon1)
                    -- -- centerInView(self.tItemPosList[i],pTempView)
        self.pIcon1:setIconScale(0.8)
    end
    if self.tData and self.tData.tNob and #self.tData.tNob > 0 then
    	local tTempData= self.tData.tNob[1] 
	    local pItemData = getGoodsByTidFromDB(tTempData.k)
	    if pItemData then
            self.pIcon1:setCurData(pItemData)
            self.pIcon1:setMoreText(pItemData.sName)
            self.pIcon1:setMoreTextColor(_cc.pwhite)
        end
        self.pIcon1:setNumber(tTempData.v)
    end

    local nLeftTime =self.tData:getNextRewardTime()
 
	if nLeftTime then		--还有可领取次数
		if nLeftTime==0 then		--倒计时到达，可领取奖励
			self.pBtnDailyGift:setBtnEnable(true)

			self.pBtnDailyGift:updateBtnText(getConvertedStr(5, 10208))
			self.pTxtTime:setVisible(false)

		else			--倒计时未到，不能领取奖励
			self.pTxtTime:setVisible(true)

			self.pBtnDailyGift:updateBtnText(getConvertedStr(5, 10220))
			self.pBtnDailyGift:setBtnEnable(false)
			self.pTxtTime:setString(formatTimeToHms(nLeftTime),false)
			
			regUpdateControl(self, handler(self, self.onUpdateTime))		--注册更新倒计时
			
		end
	else 			--今日次数已用完
	end

	--今日折扣
	local tShopBaseList = getOpenShopBaseDataByKind(e_type_shop.goods) --获得道具商店的所有物品
	local tDiscountItem=nil
	for i=1,#tShopBaseList do
		local v=tShopBaseList[i]
		if Player:getShopData():getIsDiscountId(v.exchange) then
			tDiscountItem = v
			break
		end
	end

	if tDiscountItem then
		--显示物品
		self.tGoods = getGoodsByTidFromDB(tDiscountItem.id)
		if self.tGoods then

			if not self.pIcon2 then
				self.pIcon2 = IconGoods.new(TypeIconGoods.HADMORE)
		        self.pLayIcon2:addView(self.pIcon2)
		                    -- -- centerInView(self.tItemPosList[i],pTempView)
		        self.pIcon2:setIconScale(0.8)
		    end
	    	--显示数字
			if tDiscountItem.num > 0 then
				self.pIcon2:setNumber(tDiscountItem.num)
				self.pIcon2:setIsShowNumber(true)
			else
				self.pIcon2:setIsShowNumber(false)
			end

			-- if pItemData then
	        self.pIcon2:setCurData(self.tGoods)
	        self.pIcon2:setMoreText(self.tGoods.sName)
	        self.pIcon2:setMoreTextColor(_cc.pwhite)
	        -- end

			--显示折扣
			if Player:getShopData():getIsDiscountId(tDiscountItem.exchange) then
				self.pIcon2:setDiscount(tostring(tDiscountItem.discount * 100).."%")
			else
				self.pIcon2:setDiscount(nil)
			end
			local nPrice = ShopFunc.getShopItemPrice(tDiscountItem.exchange)

			--显示价格
			local tStr = {
	    		{color=_cc.white, text=nPrice or 0}
	    	}
	    	self.pImgLabel:setString(tStr)
			self.pTxtDesc2:setString(self.tGoods.sDes)

	    end

	else
		local pLay2=self:findViewByName("lay_discount_gift")
		pLay2:setVisible(false)
	end

end
function DlgDailyGift:onDailyGiftClicked(  )
	-- body

	local  nLeftTime = self.tData:getNextRewardTime()
	if nLeftTime then
		if nLeftTime==0 then
			SocketManager:sendMsg("getDailyGiftRes", {}, handler(self, self.getDailyGiftCallback))
		else
			TOAST(string.format(getConvertedStr(6,10580),getTimeFormatCn(nLeftTime)))
		end

	end

end

--计时刷新
function DlgDailyGift:onUpdateTime()
	-- body
	local nLeftTime = self.tData:getNextRewardTime()
	if nLeftTime then
		if nLeftTime==0 then
			unregUpdateControl(self)--停止计时刷新
			self.pBtnDailyGift:setBtnEnable(true)
			self.pBtnDailyGift:updateBtnText(getConvertedStr(5, 10208))
			

			self.pTxtTime:setVisible(false)
		else

			self.pTxtTime:setString(formatTimeToHms(nLeftTime),false)

		end
	end
end

--领取宝箱奖励回调
function DlgDailyGift:getDailyGiftCallback( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.getDailyGiftRes.id then 			--领取宝箱奖励
		if __msg.head.state == SocketErrorType.success then
			--后面完善表现
			self:updateViews()
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end
end


function DlgDailyGift:onDiscountClicked(  )
	-- body
	local tOb = {}
    tOb.nType = e_dlg_index.shop
    if self.tGoods then
    	tOb.nGoodsId = self.tGoods.sTid
    	tOb.nDefIdx=3
    	sendMsg(ghd_show_dlg_by_type, tOb)
    	self:closeDlg(false)
    end 
end

--析构方法
function DlgDailyGift:onDestroy()
	self:onPause()
end

-- 注册消息
function DlgDailyGift:regMsgs( )
	-- body
	-- 注册免费宝箱推送回调
	regMsg(self, ghd_daily_gift_push, handler(self, self.updateViews))
	regMsg(self,gud_shop_data_update_msg,handler(self,self.updateViews))

end

-- 注销消息
function DlgDailyGift:unregMsgs(  )
	-- body
	unregMsg(self, ghd_daily_gift_push)
	unregMsg(self, gud_shop_data_update_msg)
	unregUpdateControl(self)
end


--暂停方法
function DlgDailyGift:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function DlgDailyGift:onResume( )
	-- body
	self:regMsgs()

end



return DlgDailyGift
