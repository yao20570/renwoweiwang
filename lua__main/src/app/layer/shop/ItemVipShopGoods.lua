----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 11:28:56
-- Description: vip商店, 材料商店 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ShopFunc = require("app.layer.shop.ShopFunc")
local DlgAlert = require("app.common.dialog.DlgAlert")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemVipShopGoods = class("ItemVipShopGoods", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
--_bMinType是否使用小布局
function ItemVipShopGoods:ctor( _bMinType )
	--解析文件
	self.nIconType = TypeIconGoodsSize.L
	if _bMinType ~= nil and _bMinType == true then
		self.nIconType = TypeIconGoodsSize.M
		parseView("item_vip_shop_goods_m", handler(self, self.onParseViewCallback))
	else
		parseView("item_vip_shop_goods", handler(self, self.onParseViewCallback))
	end	
end

--解析界面回调
function ItemVipShopGoods:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemVipShopGoods", handler(self, self.onItemVipShopGoodsDestroy))
end

-- 析构方法
function ItemVipShopGoods:onItemVipShopGoodsDestroy(  )
    self:onPause()
end

function ItemVipShopGoods:regMsgs(  )
	regMsg(self, gud_buff_update_msg, handler(self, self.updateCd))
	regMsg(self, ghd_shop_buy_success_msg, handler(self, self.onShopBuySuccess))
	regMsg(self, gud_shop_data_update_msg, handler(self, self.updateViews))
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))
end

function ItemVipShopGoods:unregMsgs(  )
	unregMsg(self, gud_buff_update_msg)
	unregMsg(self, ghd_shop_buy_success_msg)
	unregMsg(self, gud_shop_data_update_msg)
	unregMsg(self, gud_refresh_baginfo)	
end

function ItemVipShopGoods:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function ItemVipShopGoods:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function ItemVipShopGoods:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	local nContWidth = 0
	local nTxtDexY = 0
	if self.nIconType == TypeIconGoodsSize.L then
		nContWidth = 290
		nTxtDexY = self.pTxtName:getPositionY() - self.pTxtName:getHeight()/2 - 30		
	else
		nContWidth = 260
		nTxtDexY = self.pTxtName:getPositionY() - self.pTxtName:getHeight()/2 - 12
	end	
	self.pTxtDesc = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 1),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(nContWidth, 80),
		})
	self.pTxtDesc:setPosition(self.pTxtName:getPositionX(), nTxtDexY)

	self:addView(self.pTxtDesc, 10)
	setTextCCColor(self.pTxtDesc, _cc.pwhite)

	self.pTxtPrivilege = self:findViewByName("txt_privilege")
	self.pTxtCd = self:findViewByName("txt_cd")

	-- self.pTxtBuffDay = self:findViewByName("txt_buff_day")
	-- setTextCCColor(self.pTxtBuffDay, _cc.green)

	--免费购买
	-- self.pLayBtnFreeBuy = self:findViewByName("btn_free_buy")
	-- local pBtnFreeBuy = getCommonButtonOfContainer(self.pLayBtnFreeBuy, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10326))
	-- pBtnFreeBuy:onCommonBtnClicked(handler(self, self.onFreeBuyClicked))
	-- self.pBtnFreeBuy = pBtnFreeBuy
	-- local tConTable = {}
	-- --文本
	-- local tLabel = {
	--  {"",getC3B(_cc.green)},
	-- }
	-- tConTable.tLabel = tLabel
	-- self.pBtnFreeBuy:setBtnExText(tConTable) 

	--购买
	self.pLayBtnBuy = self:findViewByName("btn_buy")
	local pBtnBuy = getCommonButtonOfContainer(self.pLayBtnBuy, TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
	pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))
	self.pBtnBuy = pBtnBuy

	-- local tConTable = {}
	-- tConTable.img = getCostResImg(e_type_resdata.money)
	-- --文本
	-- local tLabel = {
	--  {"0",getC3B(_cc.gray)},
	--  {"0",getC3B(_cc.white)},
	-- }
	-- tConTable.tLabel = tLabel
	-- self.pBtnBuy:setBtnExText(tConTable) 
	-- self.pBtnBuy:addRedLine(1)

	--商店文字
	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtnBuy})
	self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 1, "left")
	self.pImgLabel:followPos("center", self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height + 10, 3)
end

function ItemVipShopGoods:updateViews(  )
	if not self.tShopBase then
		return
	end	
	self:resetBtnType()

	--默认不显示时间
	self.nBuffId = nil
	--隐藏时效
	-- self.pTxtBuffDay:setVisible(false)
	--隐藏cd 
	self.pTxtCd:setVisible(false)
	--显示描述
	self.pTxtDesc:setString(ShopFunc.getShopGoodsDesc(self.tShopBase))
	--显示物品
	local tGoods = getGoodsByTidFromDB(self.tShopBase.id)

	-- print("name1--",tGoods.sName)
	-- print("id1--",self.tShopBase.id)
	if tGoods then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods, self.nIconType)		
		setTextCCColor(self.pTxtName, getColorByQuality(tGoods.nQuality))
		if self.tShopBase.num > 0 then
			self.pIcon:setNumber(self.tShopBase.num)
			-- self.pTxtName:setString(tGoods.sName.." x"..self.tShopBase.num)
		else
			local num = ShopFunc.getShopGoodsCnt(self.tShopBase.id)
			self.pIcon:setNumber(num)
			-- self.pTxtName:setString(tGoods.sName.." x"..num)			
		end
		self.pTxtName:setString(self.tShopBase.name)	
		--生效一天		
		if tGoods.sBuffId then
			--dump(tGoods.tBuffs, "tGoods.tBuffs", 100)			
			local buffid = tGoods:getVipBuffId(Player:getPlayerInfo().nVip)
			local tBuffData = getBuffDataByIdFromDB(buffid)
			--dump(tBuffData, "tBuffData", 100)
			if tBuffData then
				if tBuffData.nTime > 0 then
					local nDay = math.ceil(tBuffData.nTime/60/60/24)
					-- self.pTxtBuffDay:setString(string.format(getConvertedStr(3, 10329), nDay))
					-- self.pTxtBuffDay:setVisible(true)
					self.pImgLabel:hideImg()
					self.pImgLabel:setString(string.format(getConvertedStr(3, 10329), nDay))

					self.nBuffId = buffid
					self.pTxtCd:setVisible(true)
					self:updateCd()
				end
			end
		end
	end

	local bNeedVipGift, bHadVipGift, tStr = ShopFunc.getGoodVipGiftInfo( self.tShopBase.id )
	local ndiscount = tonumber(self.tShopBase.discount or 1) --折扣率

	local nPrivilegeBuy = ShopFunc.getShopVipPrivilegeNum(self.tShopBase.exchange)	
	if (bNeedVipGift == false) or (bNeedVipGift == true and bHadVipGift == true) then
		--可优惠次数
		local tStr = {
			{color=_cc.pwhite,text=getConvertedStr(3, 10323)},
			{color=_cc.blue,text="0"},
			{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
		}
		if nPrivilegeBuy > 0 then
			tStr[2] = {color=_cc.blue,text=nPrivilegeBuy}
		else
			tStr[2] = {color=_cc.red,text=nPrivilegeBuy}
		end
		self.pTxtPrivilege:setString(tStr)
		self.pTxtPrivilege:setVisible(ndiscount ~= 1)	
	else
		if (bNeedVipGift == true and bHadVipGift == false) then
			self.pTxtPrivilege:setString(tStr)
			self.pTxtPrivilege:setVisible(true)
		end
	end

	--免费
	self.bIsDayFree = Player:getShopData():getIsDayFreeId(self.tShopBase.id)
	local tCostStr = nil
	--消耗物品数
	local tItemCostData = ShopFunc.getShopVipItemCostData(self.tShopBase.exchange)
	if tItemCostData then
		local tGoods = getGoodsByTidFromDB(tItemCostData.nFreeCostId)
		if tGoods then
			-- self.pBtnFreeBuy:setExTextLbCnCr(1,string.format("%sX%s", tGoods.sName, getMyGoodsCnt(tItemCostData.nFreeCostId)))
			tCostStr = {
				{color=_cc.green,text=string.format("%sX%s", tGoods.sName, getMyGoodsCnt(tItemCostData.nFreeCostId))},
			}
		end
	end

	--免费
	self.bIsFreeCost = tItemCostData ~= nil --是否扣除东西免费
	if self.bIsDayFree or self.bIsFreeCost then

		--免费购买
		self.pBtnBuy:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(3, 10326))
		self.pBtnBuy:onCommonBtnClicked(handler(self, self.onFreeBuyClicked))
		if self.bIsDayFree then
			-- self.pBtnFreeBuy:setExTextLbCnCr(1,getConvertedStr(3, 10335))
			local tStr = {
				{color=_cc.green,text=getConvertedStr(3, 10335)},
			}
			self.pImgLabel:hideImg()
			self.pImgLabel:followPos("center", self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height + 10, 3)
			self.pImgLabel:showRedLine(false)
			self.pImgLabel:setString(tStr)
		else
			if tCostStr then
				self.pImgLabel:hideImg()
				self.pImgLabel:followPos("center", self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height + 10, 3)

				self.pImgLabel:showRedLine(false)
				self.pImgLabel:setString(tCostStr)
			end
		end
		-- self.pBtnFreeBuy:setExTextVisiable(true)
	--非免费
	else
		--
		self.pBtnBuy:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
		self.pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))
		local tStr = nil
		
		if nPrivilegeBuy > 0 and ndiscount ~= 1 then --显示原价

			if self.pImgLabel then 
				--重设按钮上的提示文字
				self.pImgLabel:remove()
				self.pImgLabel=nil
			end

			self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtnBuy})
			self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 1, "right")

			local nDiscountPrice=math.ceil(self.tShopBase.cost * self.tShopBase.discount)
			tStr = {
				{color=_cc.white,text=getConvertedStr(9,10002)},
				-- {color=_cc.white,text=math.ceil(self.tShopBase.cost * self.tShopBase.discount)},
			}
			local nLen = string.len(getConvertedStr(9,10002) ..tostring(self.tShopBase.cost))
			local fScale = nLen * 0.80
			self.pImgLabel:showRedLine(true, fScale)
			local  nPosX1 = 0
			local  nPosX2 = 0
			if string.len(self.tShopBase.cost) >=3 then
				nPosX1=self.pLayBtnBuy:getContentSize().width/2-18
				nPosX2=self.pLayBtnBuy:getContentSize().width/2+27
			else
				nPosX1=self.pLayBtnBuy:getContentSize().width/2-10
				nPosX2=self.pLayBtnBuy:getContentSize().width/2+35
			end
			self.pImgLabel:followPos("center", nPosX1, self.pLayBtnBuy:getContentSize().height + 10, 3)
			if not self.pTip then 
				self.pTip=MUI.MLabel.new({text =self.tShopBase.cost, size = 20})
				self.pTip:setAnchorPoint(0,0.5)
				
				self.pLayBtnBuy:addView(self.pTip)
			else
				self.pTip:setString(self.tShopBase.cost)
			end
			self.pTip:setPosition(nPosX2, self.pLayBtnBuy:getContentSize().height + 10)

	    	self.pBtnBuy:updateBtnText("")
	    	--按钮上的文字
	    	if  not self.pBtnLabel then 
	    		self.pBtnLabel = MImgLabel.new({text="", size = 20, parent =self.pLayBtnBuy})
				self.pBtnLabel:setImg(getCostResImg(e_type_resdata.money), 0.75, "left")
				self.pBtnLabel:followPos("center",self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height/2, 1)
	    	end
	    	local tStr2 = {
	    		{color=_cc.white, text=string.format(getConvertedStr(9,10001),nDiscountPrice)},
	    	}
	    	
			self.pBtnLabel:setString(tStr2)

		else --隐藏原价
			-- self.pBtnBuy:setExTextLbCnCr(1, "")
			-- self.pBtnBuy:setExTextLbCnCr(2, self.tShopBase.cost)
			-- self.pImgLabel:showRedLine(false)
			if self.pImgLabel then 
				--重设按钮上的提示文字
				self.pImgLabel:remove()
				self.pImgLabel=nil
			end
			-- if self.pTip then
			-- 	self.pTip:removeSelf()
			-- 	self.pTip=nil
			-- end
			-- if self.pBtnLabel then 
			-- 	self.pBtnLabel:remove()
			-- 	self.pBtnLabel=nil
			-- end

			tStr = {
				{color=_cc.white,text=self.tShopBase.cost},
			}
			self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtnBuy})
			self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 1, "left")

			self.pImgLabel:followPos("center", self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height + 10, 10)
			self.pImgLabel:showRedLine(false)
		end
		self.pImgLabel:showImg()
		self.pImgLabel:setString(tStr)
		-- self.pBtnBuy:setVisible(true)
		-- self.pBtnBuy:setExTextVisiable(true)
		-- self.pLayBtnBuy:setVisible(true)
		-- self.pBtnFreeBuy:setVisible(false)
		-- self.pBtnFreeBuy:setExTextVisiable(false)
		-- self.pLayBtnFreeBuy:setVisible(false)
	end	
	if self.pBtnBuy then
		if self.bShowBtnTx then
			self.pBtnBuy:showLingTx()
		else
			self.pBtnBuy:removeLingTx()
		end
	end		
end

function ItemVipShopGoods:resetBtnType( )
	-- body
	
	if self.pImgLabel then 
		--重设按钮上的提示文字
		self.pImgLabel:showRedLine(false)
		-- self.pImgLabel:remove()
		-- self.pImgLabel=nil
	end
	if self.pTip then
		self.pTip:removeSelf()
		self.pTip=nil
	end
	if self.pBtnLabel then 
		self.pBtnLabel:remove()
		self.pBtnLabel=nil
	end
end
function ItemVipShopGoods:updateCd(  )
	if not self.nBuffId then
		return
	end

	local tBuffVo = Player:getBuffData():getBuffVo(self.nBuffId)
	--dump(tBuffVo, "tBuffVo", 100)
	--倒计时
	if tBuffVo and tBuffVo:getRemainCd() > 0 then		
		local tStr = {
			{color=_cc.pwhite,text=getConvertedStr(3, 10325)},
			{color=_cc.red,text=formatTimeToHms(tBuffVo:getRemainCd())},
		}
		self.pTxtCd:setString(tStr)
		self.pTxtCd:setVisible(true)
	else
		self.pTxtCd:setVisible(false)
	end
end

--tShopBase:表格数据
function ItemVipShopGoods:setData( tShopBase , tNeedValue, nResId)
	self.tShopBase = tShopBase
	self.tNeedValue = tNeedValue
	self.nResId = nResId
	self:updateViews()
end

function ItemVipShopGoods:onFreeBuyClicked( pView )
	if not self.tShopBase then
		return
	end
	if self.bIsDayFree then
		SocketManager:sendMsg("reqShopBuy", {self.tShopBase.exchange, 2, 1})
		return
	end

	if self.bIsFreeCost then
		local tObject = {
		    nType = e_dlg_index.shopbatchbuy, --dlg类型
		    tShopBase = self.tShopBase,
			tNeedValue = self.tNeedValue,
		    nResId = self.nResId
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
		return
	end
end

function ItemVipShopGoods:onBuyClicked( pView )
	if not self.tShopBase then
		return
	end
	--
	local bNeedVipGift, bHadVipGift, tStr = ShopFunc.getGoodVipGiftInfo( self.tShopBase.id )
	if (bNeedVipGift == true and bHadVipGift == false) then
		local tObject = {
		    nType = e_dlg_index.vipgitfgoodtip, --dlg类型
		    tShopBase = self.tShopBase,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)	
	else
		local tObject = {
		    nType = e_dlg_index.shopbatchbuy, --dlg类型
		    tShopBase = self.tShopBase,
		    tNeedValue = self.tNeedValue,
		    nResId = self.nResId
		}
		sendMsg(ghd_show_dlg_by_type, tObject)	
	end
end

function ItemVipShopGoods:onShopBuySuccess( sMsgName, pMsgObj)
	if not self.tShopBase then
		return
	end
	if self.tShopBase.exchange == pMsgObj then
		self:updateViews()
	end
end

function ItemVipShopGoods:showBtnLingTx( _bshow )
	-- body
	self.bShowBtnTx = _bshow or false
end

return ItemVipShopGoods


