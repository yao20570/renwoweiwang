-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-02-27 10:48:17 星期二
-- Description: 冥界入侵兑换子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemMingjieExchange = class("ItemMingjieExchange", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--构造
function ItemMingjieExchange:ctor()
	-- body
	self:myInit()
	parseView("item_mingjie_exchange", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function ItemMingjieExchange:onParseViewCallback( pView )
	-- body
	
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("ItemMingjieExchange",handler(self, self.onDestroy))
end
function ItemMingjieExchange:myInit(  )
	-- body
	self.tData = nil
	self.tAttrName = ""
end

--初始化控件
function ItemMingjieExchange:setupViews()
	-- body
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayNum = self:findViewByName("lay_num")
	self.pLbNum=self:findViewByName("lb_num")
	self.pLbNum:setString("1")
	self.pLayBtn1 = self:findViewByName("lay_btn1")
	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1 ,TypeCommonBtn.M_BLUE,"")
	self.pBtn1:onCommonBtnClicked(handler(self, self.onClickExchange))

	self.pLayBtn2 = self:findViewByName("lay_btn2")
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2 ,TypeCommonBtn.M_YELLOW,"")
	self.pBtn2:onCommonBtnClicked(handler(self, self.onClickExchange))


	-- local tBtnTable1 ={}
	-- tBtnTable1.img = getCostResImg(e_type_resdata.coin)
	-- tBtnTable1.tLabel={
	-- 	{"1",getC3B(_cc.white)}
	-- }
	-- tBtnTable1.awayH=-55

	-- self.pBtn1:setBtnExText(tBtnTable1)
	-- self.pBtn1:setExTextZorder(1000)

	--价格
	self.pImgLabel1 = MImgLabel.new({text="", size = 20, parent = self.pLayBtn1})
	self.pImgLabel1:setImg(getCostResImg(e_type_resdata.coin), 0.35, "left")
	self.pImgLabel1:followPos("center", self.pLayBtn1:getContentSize().width/2, self.pLayBtn1:getContentSize().height/2, 8)

	--黄金价格
	self.pImgLabel2 = MImgLabel.new({text="", size = 20, parent = self.pLayBtn2})
	self.pImgLabel2:setImg(getCostResImg(e_type_resdata.money), 1, "left")
	self.pImgLabel2:followPos("center", self.pLayBtn2:getContentSize().width/2, self.pLayBtn2:getContentSize().height/2, 8)

	-- local tBtnTable2 ={}
	-- tBtnTable2.img = getCostResImg(e_type_resdata.money)
	-- tBtnTable2.tLabel={
	-- 	{"1",getC3B(_cc.white)}
	-- }
	-- tBtnTable2.awayH=-55
	-- self.pBtn2:setBtnExText(tBtnTable2)
	-- self.pBtn2:setExTextZorder(1000)
	self.pLbName=self:findViewByName("lb_name")
	self.pLbDesc=self:findViewByName("lb_desc")
	self.pTxtTip=self:findViewByName("txt_tip")
	self.pTxtTip:setVisible(false)
	self.pTxtTip:setString(getConvertedStr(9,10186))
	setTextCCColor(self.pTxtTip,_cc.pwhite)
	
end

-- 修改控件内容或者是刷新控件数据
function ItemMingjieExchange:updateViews()
	-- body
	if not self.tData then
		return
	end
	if self.tData.state == 1 then   --可兑换
		self.pLayBtn1:setVisible(true)
		self.pLayBtn2:setVisible(true)
		self.pTxtTip:setVisible(false)
		self.pBtn1:setExTextVisiable(true)
		self.pBtn2:setExTextVisiable(true)
		--普通消耗的价格
		if self.tData.c then
-- 
			local tItemData= getGoodsByTidFromDB(100170)

			if tItemData then
				self.pImgLabel1:setImg(tItemData.sIcon,0.35,"left")
				-- self.pBtn1:setExTextImg(tItemData.sIcon,true)
			end
			-- local tActData = Player:getActById(e_id_activity.mingjie)
			local sColor = _cc.white
			if getMyGoodsCnt(100170)  < self.tData.c then
				sColor = _cc.red
			end
			self.pImgLabel1:setString(self.tData.c)
			setTextCCColor(self.pImgLabel1,sColor)
			-- self.pBtn1:setExTextLbCnCr(1,self.tData.c,getC3B(sColor))
		end
		--元宝消耗的价格
		if self.tData.g then
			local sColor = _cc.white
			if getMyGoodsCnt(e_type_resdata.money) < self.tData.g then
				sColor = _cc.red
			end
			self.pImgLabel2:setString(self.tData.g)
			setTextCCColor(self.pImgLabel2,sColor)
			-- self.pBtn2:setExTextLbCnCr(1,self.tData.g,getC3B(sColor))
		end
	else   --不可兑换
		self.pLayBtn1:setVisible(false)
		self.pLayBtn2:setVisible(false)
		self.pBtn1:setExTextVisiable(false)
		self.pBtn2:setExTextVisiable(false)
		self.pTxtTip:setVisible(true)

	end

	--物品框
	if self.tData.attr and #self.tData.attr > 0 then
		local tAttr = getBaseAttData(self.tData.attr[1].k)
		if tAttr then
			self.pLayIcon:setBackgroundImage("#v1_img_touxiangkuanghong.png")

			
			local tAttrData = getMingjieAttrDataById(self.tData.i)
			if not self.pImg then
				self.pImg = MUI.MImage.new(tAttrData.sIcon)
				-- self.pImg:setAnchorPoint(0,0)

				self.pImg:setPosition(self.pLayIcon:getWidth()/2, self.pLayIcon:getHeight()/2)
				self.pLayIcon:addView(self.pImg)
			else
				self.pImg:setCurrentImage(tAttrData.sIcon)
			end

			self.tAttrName = tAttrData.name
			if self.tData.t > 0 then
				tStr = {
					{color=_cc.blue, text=self.tAttrName},
					{color=_cc.blue, text="("},
					{color=_cc.green,text=self.tData.num .. "/" .. self.tData.t},
					{color=_cc.blue, text=")"},
				}
			else
				tStr = {
					{color=_cc.blue, text=self.tAttrName},
				}
			end
	   		self.pLbName:setString(tStr)

	   		self.pLbDesc:setString(tAttrData.desc)
	   		
	   	end
	elseif self.tData.item and #self.tData.item > 0 then

		local tItemData = getGoodsByTidFromDB(self.tData.item[1].k)
		if tItemData then
			self.pLayIcon:removeBackground()
			if not self.pIcon then
				self.pItemIcon = IconGoods.new(TypeIconGoods.NORMAL)

				self.pLayIcon:addView(self.pItemIcon)
				centerInView(self.pLayIcon,self.pItemIcon)
			end
			self.pLayNum:setVisible(false)

			self.pItemIcon:setCurData(tItemData)	
			self.pItemIcon:setNumber(self.tData.item[1].v)
			local tStr = {}
			if self.tData.t > 0 then
				tStr = {
					{color=_cc.blue, text=tItemData.sName},
					{color=_cc.blue, text="("},
					{color=_cc.green,text=self.tData.num .. "/" .. self.tData.t},
					{color=_cc.blue, text=")"},
				}
			else
				tStr = {
					{color=_cc.blue, text=tItemData.sName},
				}
			end


			self.sItemName=tItemData.sName
	   		self.pLbName:setString(tStr)
	   		self.pLbDesc:setString(tItemData.sDes)
	   	end
	end

end
 
function ItemMingjieExchange:setData( _tData )
	-- body

	self.tData = _tData or self.tData
	self:updateViews()
end

function ItemMingjieExchange:onClickExchange( _pView )
	-- body

	local sName = _pView:getName()
	local nCostType = -1 
	if sName == "lay_btn1" then
		nCostType = 0 

	elseif sName == "lay_btn2" then
		nCostType = 1
	end
	if nCostType ~= -1 then
		if nCostType == 1 then
			local tStr = {
				{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
				{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), self.tData.g)},
				{color = _cc.pwhite, text = getConvertedStr(3, 10487)},
				{color = _cc.yellow, text = self.tAttrName},
			}
			--展示购买对话框
			showBuyDlg(tStr, self.tData.g,function (  )
				SocketManager:sendMsg("mingjieExchangeAttr",{tonumber(self.tData.i),nCostType},handler(self,self.onExchangeCallback))
			end, 1)
		else
			SocketManager:sendMsg("mingjieExchangeAttr", {tonumber(self.tData.i),nCostType},handler(self,self.onExchangeCallback))
		end
		
	end
end
function ItemMingjieExchange:onExchangeCallback( __msg,__oldMsg )
	-- body
	-- dump(__oldmsg)
	if  __msg.head.state == SocketErrorType.success then 
		-- dump(__msg.body,"attr")
		-- showGetItemsAction(__msg.body.atts)
		if __msg.body.ob then
			showGetAllItems(__msg.body.ob)
		end
		local tData = Player:getActById(e_id_activity.mingjie)
		if tData then
			tData:refreshDatasByServer(__msg.body)
			tData:refreshAttrCost(__msg.body,__oldMsg[1])
			sendMsg(gud_refresh_activity)
		end
  	else
	   	--弹出错误提示语
	  	TOAST(SocketManager:getErrorStr(__msg.head.state))
	end  
end

--析构方法
function ItemMingjieExchange:onDestroy()
	self:onPause()
end

-- 注册消息
function ItemMingjieExchange:regMsgs( )
	-- body


end

-- 注销消息
function ItemMingjieExchange:unregMsgs(  )
	-- body
	
end


--暂停方法
function ItemMingjieExchange:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function ItemMingjieExchange:onResume( )
	-- body
	self:regMsgs()

end



return ItemMingjieExchange
