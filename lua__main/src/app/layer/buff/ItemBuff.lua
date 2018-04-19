-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-14 10:28:19 星期四
-- Description: 增益buff
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MBtnExText = require("app.common.button.MBtnExText")
local ShopFunc = require("app.layer.shop.ShopFunc")
local ItemBuff = class("ItemBuff", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType：TypeItemInfoSize（大小类型）
function ItemBuff:ctor( _nType )
	-- body
	self:myInit()
	parseView("item_buff", handler(self, self.onParseViewCallback))	
end

--初始化成员变量
function ItemBuff:myInit(  )
	-- body
	self.tCurData 			= 	nil 				--当前数据	
	self.nHandler 			= 	nil 				--回调事件
	self.bIsIconCanTouched 	= 	false

	self.tBaseData 			= nil
end

--解析布局回调事件
function ItemBuff:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemBuff",handler(self, self.onDestroy))
end

--初始化控件
function ItemBuff:setupViews( )
	-- body
	--背景
	self.pLayBg				=		self:findViewByName("img_bg")
	--名字
	self.pLbName 			= 		self:findViewByName("lb_name")
	--icon
	self.pLayIcon 			= 		self:findViewByName("lay_icon")

	--信息
	self.pLbMsg 			= 		self:findViewByName("lb_desc")
	setTextCCColor(self.pLbMsg, _cc.pwhite)

	self.pLbCD 				= 		self:findViewByName("lb_cd")	

	--按钮层
	self.pLayBtn 			= 		self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10128))	
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	--额外信息
	local tBtnTable = {}
	tBtnTable.parent = self.pBtn
	--文本
	tBtnTable.tLabel = {
		{getConvertedStr(6, 10135), getC3B(_cc.white)},
		{0,getC3B(_cc.blue)}		
	}
	self.pBtnExTextHad = MBtnExText.new(tBtnTable)
end

-- 修改控件内容或者是刷新控件数据
function ItemBuff:updateViews( )
	-- body
	if self.tCurData then		
		--名字
		self.pLbName:setString(self.tCurData.sName,false)
		--描述		
		self.pLbMsg:setString(self.tCurData.sDes,false)
		--数量更新
		self.pBtnExTextHad:setLabelCnCr(2, self.tCurData.nCt)
		--从更新
		local picon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL, type_icongoods_show.item, self.tCurData, TypeIconHeroSize.M)
		picon:setIconIsCanTouched(self.bIsIconCanTouched)
		--picon:setIconClickedCallBack(handler(self, self.onIconClickCallBack))
		setLbTextColorByQuality(self.pLbName, self.tCurData.nQuality)
		--dump(self.tCurData, "self.tCurData", 100)
		local nBuffid = self.tCurData:getVipBuffId(Player:getPlayerInfo().nVip)
		local pBuffVo = Player:getBuffData():getBuffVo(nBuffid)
		local nleftTime = 0
		if pBuffVo then
			nleftTime = pBuffVo:getRemainCd()
			local sStr = {
				{color=_cc.pwhite, text=getConvertedStr(3, 10325).." "},
				{color=_cc.red, text=formatTimeToHms(nleftTime)}
			}
			self.pLbCD:setString(sStr, false)
		end
		self.pLbCD:setVisible(nleftTime > 0)
		if nleftTime > 0 then
			regUpdateControl(self, handler(self, self.onUpdateTime))
		else
			unregUpdateControl(self)--停止计时刷新
		end
	end
end

function ItemBuff:onUpdateTime(  )
	-- body
	if self.tCurData then
		local nBuffid = self.tCurData:getVipBuffId(Player:getPlayerInfo().nVip)
		local pBuffVo = Player:getBuffData():getBuffVo(nBuffid)
		local nleftTime = 0
		if pBuffVo then
			nleftTime = pBuffVo:getRemainCd()
			local sStr = {
				{color=_cc.pwhite, text=getConvertedStr(3, 10325).." "},
				{color=_cc.red, text=formatTimeToHms(nleftTime)}
			}
			self.pLbCD:setString(sStr, false)
		end
		self.pLbCD:setVisible(nleftTime > 0)
	end	
end
-- 析构方法
function ItemBuff:onDestroy(  )
	-- body

end

function ItemBuff:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

--设置点击事件回到
function ItemBuff:setClickCallBack( _handler)
	-- body
	self.nHandler = _handler
end

--按钮点击回调
function ItemBuff:onBtnClicked( pView )
	-- body
	if self.nHandler then
		self.nHandler(self.tCurData)
	end	
end

--改为金币消耗提示
function ItemBuff:changeExToGold(  )
	-- body
	if self.tCurData then
		self.tBaseData = getShopDataById(self.tCurData.sTid)
		local tCostStr = nil
		if self.tBaseData then
			--免费
			self.bIsDayFree = Player:getShopData():getIsDayFreeId(self.tCurData.sTid)
			
			--消耗物品数
			local tItemCostData = ShopFunc.getShopVipItemCostData(self.tBaseData.exchange)
			if tItemCostData then
				local tGoods = getGoodsByTidFromDB(tItemCostData.nFreeCostId)
				if tGoods then
					-- self.pBtnFreeBuy:setExTextLbCnCr(1,string.format("%sX%s", tGoods.sName, getMyGoodsCnt(tItemCostData.nFreeCostId)))
					tCostStr = {
						{text=tGoods.sName},
						{text=string.format("X%s",getMyGoodsCnt(tItemCostData.nFreeCostId))},
					}
				end
			end

			--免费
			self.bIsFreeCost = tItemCostData ~= nil --是否扣除东西免费
		end
		if self.bIsDayFree or self.bIsFreeCost then

			--免费购买
			self.pBtn:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(3, 10326))
			self.pBtn:onCommonBtnClicked(handler(self, self.onFreeBuyClicked))
			if self.bIsDayFree then
				-- self.pBtnFreeBuy:setExTextLbCnCr(1,getConvertedStr(3, 10335))
				local tStr = {
					{color=_cc.green,text=getConvertedStr(3, 10335)},
				}
				self.pBtnExTextHad:setVisible(true)
				self.pBtnExTextHad:setLabelCnCr(1,tStr)
			else
				if tCostStr then
					self.pBtnExTextHad:setVisible(true)
					self.pBtnExTextHad:setLabelCnCr(1,tCostStr[1].text,getC3B(_cc.green))
					self.pBtnExTextHad:setLabelCnCr(2,tCostStr[2].text,getC3B(_cc.green))
				end
			end
		else

			if self.pBtnExTextHad then
				self.pBtnExTextHad:setBtnExTextEnabled(false)
			end
			if not self.pBtnExTextGold then
				local tBtnTable = {}
				tBtnTable.parent = self.pBtn
				tBtnTable.img = "#v1_img_qianbi.png"
				--文本
				tBtnTable.tLabel = {
					{"0",getC3B(_cc.blue)},
					{"/",getC3B(_cc.white)},
					{0,getC3B(_cc.white)},
					
				}
				if self.nSizeType == TypeItemInfoSize.M then
					tBtnTable.awayH = 6
				end
				self.pBtnExTextGold = MBtnExText.new(tBtnTable)
			end
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:updateBtnText(getConvertedStr(1,10117))

			self.pBtnExTextGold:setBtnExTextEnabled(true)
			local sColor = getC3B(_cc.blue)
			if self.tCurData.nPrice > Player:getPlayerInfo().nMoney then
				sColor = getC3B(_cc.red)
			end
			self.pBtnExTextGold:setLabelCnCr(3,self.tCurData.nPrice)
			self.pBtnExTextGold:setLabelCnCr(1,Player:getPlayerInfo().nMoney,sColor)
		end
	end
end

--刷新金币需求
function ItemBuff:refreshExGold( _nValue )
	-- body
	if self.pBtnExTextGold then
		local sColor = getC3B(_cc.blue)
		if _nValue > Player:getPlayerInfo().nMoney then
			sColor = getC3B(_cc.red)
		end
		self.pBtnExTextGold:setLabelCnCr(1,_nValue, sColor)
	end
end

--改为拥有提示
function ItemBuff:changeExToHad( sBtnStr )
	-- body
	if self.tCurData then
		if self.pBtnExTextHad then
			self.pBtnExTextHad:setBtnExTextEnabled(true)
		end
		if self.pBtnExTextGold then
			self.pBtnExTextGold:setBtnExTextEnabled(false)
		end
		self.pBtnExTextHad:setLabelCnCr(1, getConvertedStr(6, 10135), getC3B(_cc.white))
		self.pBtnExTextHad:setLabelCnCr(2, getMyGoodsCnt(self.tCurData.sTid), getC3B(_cc.blue))
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(sBtnStr or getConvertedStr(6, 10128))		
	end

end

--获得操作按钮
function ItemBuff:getAcionBtn(  )
	-- body
	return self.pBtn
end

--获得金币提示
function ItemBuff:getExGold(  )
	-- body
	return self.pBtnExTextGold 
end

--获得拥有提示
function ItemBuff:getExHad(  )
	-- body
	return self.pBtnExTextHad 
end

--设置按钮是否可见
function ItemBuff:setBtnVisible(_bVisible)
	-- body
	local bisVisible = _bVisible or false
	if self.pBtn then--设置按钮可见状态对应其是否响应
		self.pBtn:setVisible(bisVisible)
		self.pLayBtn:setViewTouched(bisVisible)
	end
end

-- --icon点击消息
-- function ItemBuff:onIconClickCallBack( pView )
-- 	-- body
-- 	if self.tCurData then--显示物品详情对话框
-- 		showItemInfoDlg(self.tCurData.sTid)
-- 	end
-- end

--设置Icon是否响应
function ItemBuff:setIsIconCanTouched( _istouched )
	-- body
	self.bIsIconCanTouched = _istouched or false
	self:updateViews()
end

--设置新品
function ItemBuff:setIconNew()
	-- body	
    local pIconGoods = self.pLayIcon:findViewByName("p_icon_goods_name")   
    if pIconGoods and self.tCurData then    
    	-- dump(self.tCurData, "self.tCurData",100)
    	if self.tCurData.nRedNum >= 1 then
    		pIconGoods:setDiscount(getConvertedStr(6, 10313))
    	else
    		pIconGoods:setDiscount()
    	end
    end
end

function ItemBuff:onFreeBuyClicked( pView )
	if not self.tBaseData then
		return
	end
	if self.bIsDayFree then
		SocketManager:sendMsg("reqShopBuy", {self.tBaseData.exchange, 2, 1})
		return
	end

	if self.bIsFreeCost then
		local tObject = {
		    nType = e_dlg_index.shopbatchbuy, --dlg类型
		    tShopBase = self.tBaseData,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
		return
	end
end


return ItemBuff