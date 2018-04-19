-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2018-02-27 16:40:17 星期二
-- Description: 冥界入侵商店子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemMingjieShop = class("ItemMingjieShop", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--构造
function ItemMingjieShop:ctor()
	-- body
	self:myInit()
	parseView("item_mingjie_shop", handler(self, self.onParseViewCallback))
end
  
--解析布局回调事件
function ItemMingjieShop:onParseViewCallback( pView )
	-- body
	
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("ItemMingjieShop",handler(self, self.onDestroy))
end
function ItemMingjieShop:myInit(  )
	-- body
	self.tData = nil
	self.sItemName = ""
end

--初始化控件
function ItemMingjieShop:setupViews()
	-- body
	self.pLbNum=self:findViewByName("lb_num")
	self.pLbNum:setString("1")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn ,TypeCommonBtn.M_BLUE,getConvertedStr(3,10487))
	self.pBtn:onCommonBtnClicked(handler(self, self.onClickExchange))

	self.pLbName=self:findViewByName("lb_name")

	local tBtnTable ={}
	tBtnTable.img = getCostResImg(e_type_resdata.money)
	tBtnTable.tLabel={
		{"1",getC3B(_cc.white)}
	}
	self.pBtn:setBtnExText(tBtnTable)
	
	self.pLbName = self:findViewByName("lb_name")

	self.pLbDesc = self:findViewByName("lb_desc")

	self.pTxtTip=self:findViewByName("txt_tip")
	self.pTxtTip:setVisible(false)
	self.pTxtTip:setString(getConvertedStr(9,10186))
	setTextCCColor(self.pTxtTip,_cc.pwhite)
end

-- 修改控件内容或者是刷新控件数据
function ItemMingjieShop:updateViews()
	-- body
	if not self.tData then
		return
	end
	if self.tData.state == 1 then   --可兑换
		self.pLayBtn:setVisible(true)
		self.pTxtTip:setVisible(false)
		self.pBtn:setExTextVisiable(true)


		--普通消耗的价格
		if self.tData.c then
			local tItemData= getGoodsByTidFromDB(self.tData.c[1].k)

			if tItemData then
				self.pBtn:setExTextImg(tItemData.sIcon,true)
			end
			-- local tActData = Player:getActById(e_id_activity.mingjie)
			local sColor = _cc.white
			if getMyGoodsCnt(100171)  < self.tData.c[1].v then
				sColor = _cc.red
			end
			self.pBtn:setExTextLbCnCr(1,self.tData.c[1].v,getC3B(sColor))
		end
	else
		self.pLayBtn:setVisible(false)
		self.pTxtTip:setVisible(true)
		self.pBtn:setExTextVisiable(false)

	end
	--物品框
	if self.tData.ob then
		local tItemData = getGoodsByTidFromDB(self.tData.ob[1].k)
		if tItemData then
			if not self.pIcon then
				self.pIcon = IconGoods.new(TypeIconGoods.NORMAL)
				
				local pLayIcon = self:findViewByName("lay_icon")
				pLayIcon:addView(self.pIcon)
				centerInView(pLayIcon,self.pIcon)
			end

			self.pIcon:setCurData(tItemData)	
			self.pIcon:setNumber(self.tData.ob[1].v)
			local tStr ={}
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
 
function ItemMingjieShop:setData( _tData )
	-- body

	self.tData = _tData or self.tData
	self:updateViews()
end

function ItemMingjieShop:onClickExchange( _pView )
	-- body
	local tStr = {
		{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
		{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), self.tData.c[1].v)},
		{color = _cc.pwhite, text = getConvertedStr(3, 10487)},
		{color = _cc.yellow, text = self.sItemName},
	}

	SocketManager:sendMsg("mingjieShop",{tonumber(self.tData.i),0},handler(self,self.onBuyCallback))
	-- --展示购买对话框
	-- showBuyDlg(tStr, self.tData.c[1].v,function (  )
		
	-- end, 1)
end
function ItemMingjieShop:onBuyCallback( __msg,__oldMsg )
	-- body
	if  __msg.head.state == SocketErrorType.success then 
		local tData = Player:getActById(e_id_activity.mingjie)
		if tData then
			showGetAllItems(__msg.body.ob)
			tData:refreshDatasByServer(__msg.body)
			sendMsg(gud_refresh_activity)
		end
  	else
	   	--弹出错误提示语
	  	TOAST(SocketManager:getErrorStr(__msg.head.state))
	end  
end
--析构方法
function ItemMingjieShop:onDestroy()
	self:onPause()
end

-- 注册消息
function ItemMingjieShop:regMsgs( )
	-- body


end

-- 注销消息
function ItemMingjieShop:unregMsgs(  )
	-- body
	
end


--暂停方法
function ItemMingjieShop:onPause( )
	-- body
	self:unregMsgs()

end

--继续方法
function ItemMingjieShop:onResume( )
	-- body
	self:regMsgs()

end



return ItemMingjieShop
