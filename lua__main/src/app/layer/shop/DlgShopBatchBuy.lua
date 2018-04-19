----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-15 13:40:28
-- Description: 商店批量购买操作面板
-----------------------------------------------------

-- 商店批量购买操作面板
local DlgCommon = require("app.common.dialog.DlgCommon")
local ShopFunc = require("app.layer.shop.ShopFunc")
local DlgShopBatchBuy = class("DlgShopBatchBuy", function()
	return DlgCommon.new(e_dlg_index.shopbatchbuy)
end)

function DlgShopBatchBuy:ctor(  )
	self.nBuyNum = 1
	self.nBuyNumMax = 1
	self.ntextPrivilegeNum = 0 --优惠次数
	self.bRedoneSV = false --是否重算滑动条变化
	parseView("dlg_shop_batch_buy", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgShopBatchBuy:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10336))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgShopBatchBuy",handler(self, self.onDlgShopBatchBuyDestroy))
end

-- 析构方法
function DlgShopBatchBuy:onDlgShopBatchBuyDestroy(  )
    self:onPause()
end

function DlgShopBatchBuy:regMsgs(  )
end

function DlgShopBatchBuy:unregMsgs(  )
end

function DlgShopBatchBuy:onResume(  )
	self:regMsgs()
end

function DlgShopBatchBuy:onPause(  )
	self:unregMsgs()
end

function DlgShopBatchBuy:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	self.pLayRoot = self:findViewByName("view")

	self.pTxtDesc = MUI.MLabel.new({
	    text = "",
	    size = 20,
	    anchorpoint = cc.p(0, 1),
	    align = cc.ui.TEXT_ALIGN_LEFT,
		valign = cc.ui.TEXT_VALIGN_TOP,
	    color = cc.c3b(255, 255, 255),
	    dimensions = cc.size(280, 0),
	})
	self.pTxtDesc:setPosition(142, 118)
	self.pTxtName:getParent():addView(self.pTxtDesc, 10)
	setTextCCColor(self.pTxtDesc, _cc.pwhite)

	--获得途径
	self.pLbGetFrom = self:findViewByName("txt_getfrom")


	self.pRichtextPrivilege = MUI.MLabel.new({text = "", size = 20})
	self.pLayRoot:addView(self.pRichtextPrivilege, 10)
	self.pRichtextPrivilege:setPosition(250, 20)

	local pTxtSelectTitle = self:findViewByName("txt_select_title")
	pTxtSelectTitle:setString(getConvertedStr(3, 10337))
	setTextCCColor(pTxtSelectTitle, _cc.pwhite)
	self.pTxtSelectTitle = pTxtSelectTitle

	--选择富文本
	self.pRichtextSelect = self:findViewByName("lay_richtext_select")

	--拖动条
	self.playSliderBar				= 			self:findViewByName("lay_bar_bg")
	self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v1_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_3.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(248, 20)
	self.pSliderBar:setSliderValue(0)	--设置滑动条值默认为一半
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)

	--减少按钮
	self.playMinusBtn 			=			self:findViewByName("lay_btn_sub")
	self.pBtnMinus 					= 			getSepButtonOfContainer(self.playMinusBtn,TypeSepBtn.MINUS, TypeSepBtnDir.right)
	self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--增加按钮
	self.playPlusBtn				=			self:findViewByName("lay_btn_add")
	self.pBtnPlus 					= 			getSepButtonOfContainer(self.playPlusBtn, TypeSepBtn.PLUS, TypeSepBtnDir.left)
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息

	--购买按钮
	self.pLayBtnBuy = self:findViewByName("lay_btn_buy")
	local pBtnBuy = getCommonButtonOfContainer(self.pLayBtnBuy, TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
	pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))
	self.pBtnBuy = pBtnBuy
	local tConTable = {}
	tConTable.img = getCostResImg(e_type_resdata.money)
	--文本
	local tLabel = {
	 {"0",getC3B(_cc.white)},
	}
	tConTable.tLabel = tLabel
	self.pBtnBuy:setBtnExText(tConTable) 

	self.pLbTips = self:findViewByName("lb_tips")
	self.pLbValue = self:findViewByName("lb_value")
	self.pLbTips:setVisible(false)
	self.pLbValue:setVisible(false)
end

function DlgShopBatchBuy:updateViews(  )
	if self.tShopBase then
		--vip商店
		if self.tShopBase.kind == e_type_shop.vip then
			--显示物品
			local tGoods = getGoodsByTidFromDB(self.tShopBase.id)
			if tGoods then
				self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)				
				if self.tShopBase.num > 0 then
					self.pIcon:setNumber(self.tShopBase.num)
					self.pTxtName:setString(tGoods.sName.." x"..self.tShopBase.num)
				else
					local num = ShopFunc.getShopGoodsCnt(self.tShopBase.id)
					self.pIcon:setNumber(num)
					self.pTxtName:setString(tGoods.sName.." x"..num)			
				end		
				setTextCCColor(self.pTxtName, getColorByQuality(tGoods.nQuality))		
			end

			--显示描述
			self.pTxtDesc:setString(ShopFunc.getShopGoodsDesc(self.tShopBase))
			--获得途径
			if tGoods.sTips then
				self.pLbGetFrom:setString(getTextColorByConfigure(tGoods.sTips) ,false)
			end

			--可优惠次数
			local nPrivilegeBuy = ShopFunc.getShopVipPrivilegeNum(self.tShopBase.exchange)
			self.ntextPrivilegeNum = nPrivilegeBuy


			self.nPrivilegeBuy = nPrivilegeBuy

			--拥有物品消耗次数
			local tItemCostData = ShopFunc.getShopVipItemCostData(self.tShopBase.exchange)			
			self.bIsFreeCost = tItemCostData ~= nil
			if self.bIsFreeCost then
	        	--显示替代品扣除
	        	self.nFreeCostId = tItemCostData.nFreeCostId
	        	self.nFreeCostNum = tItemCostData.nFreeCostNum

	        	local tItem = Player:getBagInfo():getItemDataById(self.nFreeCostId)
	        	if tItem and tItem.nCt > 0 then
		        	--购买上限	        
		        	self.nBuyNumMax = math.floor(tItem.nCt/self.nFreeCostNum)
		        	self.pBtnBuy:setExTextImg(nil) 
		        	--最小是1
					if self.nBuyNumMax <= 0 then
						self.nBuyNumMax = 1
					end
					--最大是99
					if self.nBuyNumMax > 99 then
						self.nBuyNumMax = 99
					end	 

					local tStr = {
						{color=_cc.pwhite,text=getConvertedStr(3, 10323)},
						{color=_cc.blue,text=self.ntextPrivilegeNum},
						{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
					}
					self.pRichtextPrivilege:setString(tStr)--updateLbByNum(2, self.ntextPrivilegeNum, _cc.blue)       
		        else
	    			--显示图片
	    			local nShowCt = self.ntextPrivilegeNum - self.nBuyNum
	    			if nShowCt < 0 then
	    				nShowCt = 0
	    			end
	    			local tStr = {
						{color=_cc.pwhite,text=getConvertedStr(3, 10323)},
						{color=_cc.red,text=nShowCt},
						{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
					}
					self.pRichtextPrivilege:setString(tStr)

					self.pBtnBuy:setExTextImg(getCostResImg(e_type_resdata.money))

					--数学渣求购买上限
					local nCurrMoney = Player:getPlayerInfo().nMoney
					if self.nPrivilegeBuy > 0 then
						local nPrivilegePrice = math.ceil(self.tShopBase.cost * self.tShopBase.discount)
						local nBuyNumMax1 = math.floor(nCurrMoney/nPrivilegePrice) 
						nCurrMoney = nCurrMoney - self.nPrivilegeBuy*nPrivilegePrice
						if nCurrMoney <= 0 then
							self.nBuyNumMax = nBuyNumMax1
						else
							local nBuyNumMax2 = math.floor(nCurrMoney/self.tShopBase.cost)
							self.nBuyNumMax = self.nPrivilegeBuy + nBuyNumMax2
						end
					else
						local nBuyNumMax = math.floor(nCurrMoney/self.tShopBase.cost)
						self.nBuyNumMax = nBuyNumMax
					end
					--最小是1
					if self.nBuyNumMax < 0 then
						self.nBuyNumMax = 1
					end

					if self.nBuyNumMax > 99 then
						self.nBuyNumMax = 99
					end	 
	        	end       	
			else
				--显示图片
				local tStr = {
					{color=_cc.pwhite,text=getConvertedStr(3, 10323)},
					{color=_cc.red,text=0},
					{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
				}
				self.pRichtextPrivilege:setString(tStr)
				self.pBtnBuy:setExTextImg(getCostResImg(e_type_resdata.money))
				--数学渣求购买上限
				local nCurrMoney = Player:getPlayerInfo().nMoney
				if self.nPrivilegeBuy > 0 then
					local nPrivilegePrice = math.ceil(self.tShopBase.cost * self.tShopBase.discount)
					local nBuyNumMax1 = math.floor(nCurrMoney/nPrivilegePrice) 
					nCurrMoney = nCurrMoney - self.nPrivilegeBuy*nPrivilegePrice
					if nCurrMoney <= 0 then
						self.nBuyNumMax = nBuyNumMax1
					else
						local nBuyNumMax2 = math.floor(nCurrMoney/self.tShopBase.cost)
						self.nBuyNumMax = self.nPrivilegeBuy + nBuyNumMax2
					end
				else
					local nBuyNumMax = math.floor(nCurrMoney/self.tShopBase.cost)
					self.nBuyNumMax = nBuyNumMax
				end
				--最小是1
				if self.nBuyNumMax <= 0 then
					self.nBuyNumMax = 1
				end

				if self.nBuyNumMax > 99 then
					self.nBuyNumMax = 99
				end
			end
			--校对当前可以选择的最大数量
			-- self.nBuyNumMax = ShopFunc.getGoodSelectMax(self.nBuyNumMax, self.tShopBase.id)
		--道具商店
		elseif self.tShopBase.kind == e_type_shop.goods then
			--显示物品
			local tGoods = getGoodsByTidFromDB(self.tShopBase.id)
			if tGoods then
				self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)
				self.pTxtName:setString(tGoods.sName or "")
				setTextCCColor(self.pTxtName, getColorByQuality(tGoods.nQuality))
				if self.tShopBase.num > 0 then
					self.pIcon:setNumber(self.tShopBase.num)
					self.pIcon:setIsShowNumber(true)
				else
					self.pIcon:setIsShowNumber(false)
				end
				self.pTxtDesc:setString(tGoods.sDes, false)
			end
			self.pRichtextPrivilege:setVisible(false)
			--购买上限
			self.nGoodsPrice = ShopFunc.getShopItemPrice(self.tShopBase.exchange)
			local nCurrMoney = Player:getPlayerInfo().nMoney
			local nBuyNumMax = math.floor(nCurrMoney/self.nGoodsPrice)
			self.nBuyNumMax = nBuyNumMax
			--最小是1
			if self.nBuyNumMax <= 0 then
				self.nBuyNumMax = 1
			end
			if self.nBuyNumMax > 99 then
				self.nBuyNumMax = 99
			end
		end
	elseif self.tShopMaterial then
		--显示物品
		local tGoods = getGoodsByTidFromDB(self.tShopMaterial.id)
		if tGoods then
			self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)
			self.pTxtName:setString(tGoods.sName or "")
			--显示描述
			self.pTxtDesc:setString(tGoods.sDes or "")
			
			setTextCCColor(self.pTxtName, getColorByQuality(tGoods.nQuality))
			self.pIcon:setNumber(self.tShopMaterial.num)

			--获得途径
			if tGoods.sTips then
				self.pLbGetFrom:setString(getTextColorByConfigure(tGoods.sTips) ,false)
			end
		end

		--可购买次数
		local nCanBuy = ShopFunc.getShopMaterialCanBuy(self.tShopMaterial.exchange)
		self.ntextPrivilegeNum = nCanBuy
		local nleftCanbuy = self.ntextPrivilegeNum - self.nBuyNum
		local sColor = _cc.red
		if nleftCanbuy > 0 then
			sColor = _cc.blue
		else
			nleftCanbuy = 0
		end
		local tStr = {
			{color=_cc.pwhite,text=getConvertedStr(3, 10330)},
			{color=sColor,text=nleftCanbuy},
			{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
		}
		self.pRichtextPrivilege:setString(tStr)
		self.nCanBuy = nCanBuy

		--价格
		--数学渣求购买上限
		local nCurrMoney = Player:getPlayerInfo().nMoney
		local nBuyNumMax = 0 
		local tPrice = luaSplit(self.tShopMaterial.prices, ";")
		local nBought = Player:getShopData():geMaterialBuyNum(self.tShopMaterial.exchange)
		for i=nBought + 1,#tPrice do
			nCurrMoney = nCurrMoney - tonumber(tPrice[i])
			if nCurrMoney <= 0 then
				break
			end
			nBuyNumMax = nBuyNumMax + 1
		end
		if nCurrMoney > 0 then
			nBuyNumMax = nBuyNumMax + math.floor(nCurrMoney/tonumber(tPrice[#tPrice]))
		end
		--可购买最大
		self.nBuyNumMax = math.min(ShopFunc.getShopMaterialCanBuy(self.tShopMaterial.exchange),nBuyNumMax)
		--最小是1
		if self.nBuyNumMax <= 0 then
			self.nBuyNumMax = 1
		end
		if self.nBuyNumMax > 99 then
			self.nBuyNumMax = 99
		end
	end
	--先刷新一次
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self.nBuyNum/self.nBuyNumMax*100)
	self:refreshSelectedTip()	
end

--minusBtn减少按钮点击回调事件
function DlgShopBatchBuy:onMinusBtnClicked( pView )	
	local nBuyNum = self.nBuyNum - 1
	if nBuyNum < 1 then
		nBuyNum = 1
	end
	self.nBuyNum = nBuyNum
	self.bRedoneSV = false			
 	--更新进度条显示	
	self.pSliderBar:setSliderValue(self.nBuyNum/self.nBuyNumMax*100)			
end

--plusBtn增加按钮点击回调事件
function DlgShopBatchBuy:onPlusBtnClicked( pView )
	local nBuyNum = self.nBuyNum + 1
	if nBuyNum > self.nBuyNumMax then
		nBuyNum = self.nBuyNumMax
	end
	self.nBuyNum = nBuyNum
	self.bRedoneSV = false			
	--更新进度条显示	
	self.pSliderBar:setSliderValue(self.nBuyNum/self.nBuyNumMax*100)
end

--滑动条释放消息回调
function DlgShopBatchBuy:onSliderBarRelease( pView )
	local nValue = self.pSliderBar:getSliderValue() --滑动条当前值
	local nBuyNum = roundOff(self.nBuyNumMax*nValue/100, 1) --获取当前次数
	if nBuyNum <= 0 then
		nBuyNum = 1
	end
	self.nBuyNum = nBuyNum
	self.bRedoneSV = true	
	--更新进度条显示	
	self.pSliderBar:setSliderValue(self.nBuyNum/self.nBuyNumMax*100)
end

function DlgShopBatchBuy:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local nValue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nBuyNum = roundOff(self.nBuyNumMax*nValue/100, 1) --获取当前次数
		if nBuyNum <= 0 then
			nBuyNum = 1
		end
		self.nBuyNum = nBuyNum	
	else	
		self.bRedoneSV = true
	end
	self:refreshSelectedTip()
end

--更新进度条和文字显示
function DlgShopBatchBuy:refreshSelectedTip(  )	
	self.pRichtextSelect:setString(string.format(getConvertedStr(1,10418), self.nBuyNum).."/"..string.format(getConvertedStr(1,10417), self.nBuyNumMax))
	
	--显示按钮文字
	if self.tShopBase then
		--vip商店
		if self.tShopBase.kind == e_type_shop.vip then			
			--普通商品扣费
			if self.bIsFreeCost then --材料免费
				local tGoods = getGoodsByTidFromDB(self.nFreeCostId)
				if tGoods then
					--显示玩家当前用的数量
					self.pBtnBuy:setExTextLbCnCr(1,string.format("%sX%s", tGoods.sName, self.nFreeCostNum * self.nBuyNum), getC3B(_cc.green))
					self.pBtnBuy:updateBtnText(getConvertedStr(3, 10326))
				end
			else
				--原价+（可优惠价）
				local nBuyNum = self.nBuyNum
				local nPrice = 0
				if self.nPrivilegeBuy > 0 then
					if nBuyNum >= self.nPrivilegeBuy then
						nPrice = nPrice + self.nPrivilegeBuy * math.ceil(self.tShopBase.discount * self.tShopBase.cost)
						nBuyNum = nBuyNum - self.nPrivilegeBuy 
					else
						nPrice = nPrice + nBuyNum * math.ceil(self.tShopBase.discount * self.tShopBase.cost)
						nBuyNum = 0
					end
				end
				if nBuyNum > 0 then
					nPrice = nPrice + nBuyNum * self.tShopBase.cost
				end
				self.nPrice = nPrice			
				if self.nPrice > Player:getPlayerInfo().nMoney then
					self.pBtnBuy:setExTextLbCnCr(1, self.nPrice, getC3B(_cc.red))
				else
					self.pBtnBuy:setExTextLbCnCr(1, self.nPrice, getC3B(_cc.pwhite))
				end
				
				local nCanPrivilegeCnt = self.ntextPrivilegeNum - self.nBuyNum
				local sColor = _cc.red
	 			if nCanPrivilegeCnt > 0 then
    				sColor = _cc.blue
    			else
    				nCanPrivilegeCnt = 0
    			end
    			local tStr = {
					{color=_cc.pwhite,text=getConvertedStr(3, 10323)},
					{color=sColor,text=nCanPrivilegeCnt},
					{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
				}
				self.pRichtextPrivilege:setString(tStr)
			end
		--道具商店
		elseif self.tShopBase.kind == e_type_shop.goods then
			self.nPrice = self.nBuyNum * self.nGoodsPrice
			if self.nPrice > Player:getPlayerInfo().nMoney then
				self.pBtnBuy:setExTextLbCnCr(1, self.nPrice, getC3B(_cc.red))
			else
				self.pBtnBuy:setExTextLbCnCr(1, self.nPrice, getC3B(_cc.pwhite))
			end
		end
	elseif self.tShopMaterial then
		--数学渣求购买价格
		self.nPrice = 0
		local tPrice = luaSplit(self.tShopMaterial.prices, ";")
		local nBought = Player:getShopData():geMaterialBuyNum(self.tShopMaterial.exchange)
		for i=1,self.nBuyNum do
			local nOnePrice = tonumber(tPrice[nBought + i]) or tonumber(tPrice[#tPrice])
			self.nPrice = self.nPrice + nOnePrice
		end
		if self.nPrice > Player:getPlayerInfo().nMoney then
			self.pBtnBuy:setExTextLbCnCr(1, self.nPrice, getC3B(_cc.red))
		else
			self.pBtnBuy:setExTextLbCnCr(1, self.nPrice, getC3B(_cc.pwhite))
		end
		
		local nLeftBuyCnt = self.ntextPrivilegeNum - self.nBuyNum
		local sColor = _cc.red
		if nLeftBuyCnt > 0 then
			sColor = _cc.blue
		else
			nLeftBuyCnt = 0
		end
		local tStr = {
			{color=_cc.pwhite,text=getConvertedStr(3, 10330)},
			{color=sColor,text=nLeftBuyCnt},
			{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
		}
		self.pRichtextPrivilege:setString(tStr)
	end
					

	if self.nResId then
		if self.tShopBase then
			self.pLbTips:setVisible(true)
			self.pLbValue:setVisible(true)
			self.pTxtSelectTitle:setPositionY(164)
			self.pRichtextSelect:setPositionY(164)
			self.pLbTips:setString(string.format(getConvertedStr(1,10414),getResStrById(self.nResId)))

			
			local nValue = 0
			if self.nResId == e_resdata_ids.yb then
				nValue = Player:getPlayerInfo().nCoin
			elseif self.nResId == e_resdata_ids.mc then
				nValue = Player:getPlayerInfo().nWood
			elseif self.nResId == e_resdata_ids.lc then
				nValue = Player:getPlayerInfo().nFood
			elseif self.nResId == e_resdata_ids.bt then
				nValue = Player:getPlayerInfo().nIron
			end
			if self.tShopBase.num then
				local num =  0
				if self.tShopBase.num > 0 then
					num = self.tShopBase.num
				else
					num = ShopFunc.getShopGoodsCnt(self.tShopBase.id)
				end
				nValue = num*self.nBuyNum + nValue

				local sValueStr = ""
				
				if self.tNeedValue and self.tNeedValue[self.nResId] then
					local nNeedValue = self.tNeedValue[self.nResId]
					if nValue < nNeedValue then
						sValueStr = string.format(getConvertedStr(1, 10416),getResourcesStr(nValue))
					else
						sValueStr = string.format(getConvertedStr(1, 10415),getResourcesStr(nValue))
					end
					self.pLbValue:setString(sValueStr.."/"..getResourcesStr(nNeedValue))
				else
					sValueStr = string.format(getConvertedStr(1, 10415),getResourcesStr(nValue))
					self.pLbValue:setString(sValueStr)
				end
			end
		else
			self.pLbTips:setVisible(false)
			self.pLbValue:setVisible(false)
			self.pTxtSelectTitle:setPositionY(146)
			self.pRichtextSelect:setPositionY(146)
		end
		
	else
		self.pLbTips:setVisible(false)
		self.pLbValue:setVisible(false)
		self.pTxtSelectTitle:setPositionY(146)
		self.pRichtextSelect:setPositionY(146)
	end

end

--设置数据
function DlgShopBatchBuy:setData( tData, tNeedValue, nResId)
	if not tData then
		return
	end
	self.tNeedValue = tNeedValue
	self.nResId = nResId
	if tData.kind == e_type_shop.material then
		self:setShopMaterial(tData)
	else
		self:setShopBase(tData)
	end
end

-- tShopBase:表格数据
function DlgShopBatchBuy:setShopBase( tShopBase )
	self.tShopBase = tShopBase
	self.tMaterialData = nil
	self:updateViews()
end

-- tShopMaterial:表格数据
function DlgShopBatchBuy:setShopMaterial( tShopMaterial )
	self.tShopBase = nil
	self.tShopMaterial = tShopMaterial
	self:updateViews()
end

--按钮
function DlgShopBatchBuy:onBuyClicked( pView )
	--显示按钮文字
	if self.tShopBase then
		local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
		if pPalacedata.nLv < self.tShopBase.palace then
			TOAST(string.format(getTipsByIndex(607), getLvString(self.tShopBase.palace)))
			return
		end

		--vip商店
		if self.tShopBase.kind == e_type_shop.vip then				
			--普通商品扣费

			function buyVipGood(  )
				-- body
				if self.bIsFreeCost then --材料免费
					if checkIsResourceEnough(self.nFreeCostId, self.nFreeCostNum * self.nBuyNum, true) then
						-- dump({self.tShopBase.exchange, 2, self.nBuyNum})
						SocketManager:sendMsg("reqShopBuy",{self.tShopBase.exchange,2, self.nBuyNum})
						self:closeDlg(false)				
					end
				else
					--二次弹窗
					local function sendReq(  )
						-- dump({self.tShopBase.exchange, 1, self.nBuyNum})
						SocketManager:sendMsg("reqShopBuy",{self.tShopBase.exchange,1, self.nBuyNum})
						self:closeDlg(false)
					end
					local sName = ""
					local tGoods = getGoodsByTidFromDB(self.tShopBase.id)
					if tGoods then
						sName = tGoods.sName
					end
					local tStr = {
				    	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
				    	{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281),self.nPrice)},
				    	{color = _cc.pwhite, text = getConvertedStr(3, 10312)},
				    	{color = _cc.yellow, text = sName},
				    }
					showBuyDlg(tStr, self.nPrice, sendReq, 1)
				end				
			end
			local AvatarVip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)
			local nBagMaxNum = 0--拥有上限
			local itemCnt = 0--当前拥有量
			if self.tShopBase.id == e_id_item.zdjz then --自动建造
				nBagMaxNum = AvatarVip.autobulid 
				itemCnt = Player:getBuildData().nAutoUpTimes
			elseif self.tShopBase.id == e_id_item.bccf then			
				nBagMaxNum = AvatarVip.citydef
				itemCnt = Player:getBuildData().nAutoRecruit	
			else
				--一般物品直接行使购买流程
				buyVipGood()
				return			
			end

			if self.nBuyNum + itemCnt <= nBagMaxNum then
				buyVipGood()
			else
				local DlgAlert = require("app.common.dialog.DlgAlert")
				local str = ShopFunc.getTipStr(Player:getPlayerInfo().nVip, itemCnt, nBagMaxNum)
			   	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
			    if(not pDlg) then
			        pDlg = DlgAlert.new(e_dlg_index.alert)
			    end
			    pDlg:setTitle(getConvertedStr(3, 10091))
			    pDlg:setContent(str,nil, 20, 400)
			    pDlg:setOnlyConfirm(getConvertedStr(1, 10059))
			    pDlg:showDlg(bNew)
			end
		--道具商店
		elseif self.tShopBase.kind == e_type_shop.goods then
			--二次弹窗
			local function sendReq(  )
				-- dump({self.tShopBase.exchange, 1, self.nBuyNum})
				SocketManager:sendMsg("reqShopBuy",{self.tShopBase.exchange,1, self.nBuyNum})
				self:closeDlg(false)
			end
			local sName = ""
			local tGoods = getGoodsByTidFromDB(self.tShopBase.id)
			if tGoods then
				sName = tGoods.sName
			end
			local tStr = {
		    	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
		    	{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), self.nPrice)},
		    	{color = _cc.pwhite, text = getConvertedStr(3, 10312)},
		    	{color = _cc.yellow, text = sName},
		    }
			showBuyDlg(tStr, self.nPrice, sendReq, 1)
		end
	elseif self.tShopMaterial then
		local pPalacedata = Player:getBuildData():getBuildById(e_build_ids.palace)--王宫数据
		if pPalacedata.nLv < self.tShopMaterial.palace then
			TOAST(string.format(getTipsByIndex(607), getLvString(self.tShopMaterial.palace)))
			return
		end

		--已超过购买次数
		if self.nCanBuy < self.nBuyNum then
			TOAST(getConvertedStr(3, 10339))
			return
		end

		--二次弹窗
		local function sendReq( )
			-- dump({self.tShopMaterial.exchange, 1, self.nBuyNum})
			SocketManager:sendMsg("reqShopBuy",{self.tShopMaterial.exchange,1, self.nBuyNum})
			self:closeDlg(false)
		end
		local sName = ""
		local tGoods = getGoodsByTidFromDB(self.tShopMaterial.id)
		if tGoods then
			sName = tGoods.sName
		end
		local tStr = {
	    	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
	    	{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), self.nPrice)},
	    	{color = _cc.pwhite, text = getConvertedStr(3, 10312)},
	    	{color = _cc.yellow, text = sName},
	    }
		showBuyDlg(tStr, self.nPrice, sendReq, 1)
	end
end




return DlgShopBatchBuy