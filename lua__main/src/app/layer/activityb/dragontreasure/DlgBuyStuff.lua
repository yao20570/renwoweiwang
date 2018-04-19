----------------------------------------------
-- Author: dengshulan
-- Date: 2017-12-08 15:11:16
-- 购买道具对话框
----------------------------------------------

local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgBuyStuff = class("DlgBuyStuff", function ()
	return DlgAlert.new(e_dlg_index.buystuff)
end)

--构造
function DlgBuyStuff:ctor()
	-- body
	self:myInit()	
	parseView("dlg_usestuff", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuyStuff:myInit()
	-- body
	self._nstuffs 	= 		99		--物品总量
	self._nselect 	=		1		--玩家当前选定的购买数量
	self.nPrice = 0
	self.pItemData = nil
	self.tCost = nil 				--购买消耗
	self.bRedoneSV = true --是否重算滑动条变化


	self.btnHandler = nil
end
  
--解析布局回调事件
function DlgBuyStuff:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgBuyStuff",handler(self, self.onDlgBuyStuffDestroy))
end

--初始化控件
function DlgBuyStuff:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10265))
	--头像层
	self.pLayIcon = self:findViewByName("lay_icon")
	--物品名称标签
	self.pLbName = self:findViewByName("lb_name")
	--物品说明	
	self.pLbExpline = self:findViewByName("lb_expline")
	setTextCCColor(self.pLbExpline, _cc.white)
	--减少按钮
	self.pLayBtnMinus 					= 			self:findViewByName("lay_btn_left")
	self.pBtnMinus 					= 			getSepButtonOfContainer(self.pLayBtnMinus,TypeSepBtn.MINUS, TypeSepBtnDir.right)
	self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	-- self.pBtnMinus:setViewTouched(true)
	-- self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--增加按钮
	self.pLayBtnPlus 					= 			self:findViewByName("lay_btn_right")
	self.pBtnPlus 					= 			getSepButtonOfContainer(self.pLayBtnPlus, TypeSepBtn.PLUS, TypeSepBtnDir.left)
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息
	-- self.pBtnPlus:setViewTouched(true)
	-- self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息



	self.pLbRichText = self:findViewByName("lb_rich_text")


	--拖动条
	self.playSliderBar				= 			self:findViewByName("lay_bar_bg")
	self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_3.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(248, 20)
	self.pSliderBar:setSliderValue(1)	--设置滑动条值默认为一半
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)

	self:refreshSelectedTip()

	self:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(7, 10079))
	self:setOnlyConfirmBtnHeight(0)
	self:setRightHandler(handler(self, self.onBuyBtnClicked))

	self.pBtnRight = self:getRightButton()

	--文本
	local tConTable = {}
	local tLabel = {
		{"10", getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.fontSize = 20
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pBtnRight:setBtnExText(tConTable)		

end

function DlgBuyStuff:refreshSelectedTip(  )	
	local sStr = {
		{text=getConvertedStr(7, 10266),color=_cc.pwhite},
	 	{text=self._nselect,color=_cc.pwhite},
	}
	self.pLbRichText:setString(sStr, false)

	--设置购买消耗
	if self.tCost then
		self.nPrice = self._nselect*self.tCost.v
		self.pBtnRight:setExTextLbCnCr(1, self.nPrice)
	end

end

-- 修改控件内容或者是刷新控件数据
function DlgBuyStuff:updateViews()
	-- body	
	--物品数据
	local itemdata = self.pItemData
	if not itemdata then
		return
	end
	--设置icon
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.item, itemdata, TypeIconGoodsSize.L)
	else
		self.pIcon:setCurData(itemdata)
	end
	
	self.pLbName:setString(itemdata.sName)--刷新名字
	setLbTextColorByQuality(self.pLbName,itemdata.nQuality)
	self.pLbExpline:setString(getTextColorByConfigure(itemdata.sDes) ,false)--物品说明
	

	--更新进度条显示	
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)

	--设置购买消耗
	if self.tCost then
		local sIcon = getCostResImg(self.tCost.k)
		self.pBtnRight:setExTextImg(sIcon)
	end
end

--滑动条释放消息回调
function DlgBuyStuff:onSliderBarRelease( pView )
	-- body
	self.bRedoneSV = true
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	self._nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
	if self._nselect <= 0 then
		self._nselect = 1
	end
	curvalue = self._nselect/self._nstuffs*100
	self.pSliderBar:setSliderValue(curvalue)		
end

--滑动滑动消息回调
function DlgBuyStuff:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
		if nselect <= 0 then
			nselect = 1
		end
		self._nselect = nselect
	else
		self.bRedoneSV = true
	end
	self:refreshSelectedTip()
end

--minusBtn减少按钮点击回调事件
function DlgBuyStuff:onMinusBtnClicked( pView )
	-- body	
	local nselect = self._nselect - 1
	if nselect < 1  then
		nselect = 1			
	end
	self._nselect = nselect
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--plusBtn增加按钮点击回调事件
function DlgBuyStuff:onPlusBtnClicked( pView )
	-- body
	local nselect = self._nselect + 1
	if nselect > self._nstuffs then
		nselect = self._nstuffs		
	end
	self._nselect = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--析构方法
function DlgBuyStuff:onDlgBuyStuffDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgBuyStuff:regMsgs( )
	-- body
end

-- 注销消息
function DlgBuyStuff:unregMsgs(  )
	-- body
end


--暂停方法
function DlgBuyStuff:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyStuff:onResume( )
	-- body
	-- self:updateViews()
	self:regMsgs()
end

--设置物品数据 _itemid-物品配表id
--_tCost:购买消耗(k, v)
--_msgtype:协议名字
--nMaxCnt:可购买的最大数量
--_handler 按钮回调
function DlgBuyStuff:setItemDataById( _itemdata, _itemid, _tCost, _msgtype, nMaxCnt,_handler )
	-- body
	local itemdata = _itemdata or getGoodsByTidFromDB(_itemid)--读取物品的配表数据
	if _tCost then
		self.tCost = _tCost
	end
	self._nstuffs = nMaxCnt or self._nstuffs
	self.sMsgType = _msgtype
	if itemdata then
		self.pItemData = itemdata	
		self:updateViews()
	else
		print("设置物品使用对话框的物品数据错误...")
	end
	-- dump(_handler,"251")
	self.btnHandler = _handler
end


--购买按钮回调
function DlgBuyStuff:onBuyBtnClicked( pView )	
	-- body	
	--发送购买物品消息
	--二次弹窗
	local function sendReq(  )
		if self.btnHandler then
			self.btnHandler(self._nselect)
			self:closeDlg(false)
		else
			if self.sMsgType then
				SocketManager:sendMsg(self.sMsgType, {self.pItemData.sTid, self._nselect})
			else
				SocketManager:sendMsg("reqBuyItem", {self.pItemData.sTid, self._nselect})
			end
			self:closeDlg(false)
		end
		
	end
	local tStr = {
		{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
		{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281), self.nPrice)},
		{color = _cc.pwhite, text = getConvertedStr(3, 10312)},
		{color = _cc.yellow, text = self.pItemData.sName},
	}
	showBuyDlg(tStr, self.nPrice, sendReq, 1)
end

return DlgBuyStuff
