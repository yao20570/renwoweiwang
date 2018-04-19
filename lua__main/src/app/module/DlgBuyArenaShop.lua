-- Author: maheng
-- Date: 2018-01-22 17:16:24
-- 竞技场商品批量购买


local DlgAlert = require("app.common.dialog.DlgAlert")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgBuyArenaShop = class("DlgBuyArenaShop", function ()
	return DlgAlert.new(e_dlg_index.dlgbuyarenashop)
end)

--构造
function DlgBuyArenaShop:ctor()
	-- body
	self:myInit()	
	parseView("dlg_usestuff", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuyArenaShop:myInit()
	-- body
	self.pData = nil
	self._nstuffs 	= 		99		--物品总量
	self._nselect 	=		1		--玩家当前选定的购买次数
	self.pRichView = nil --	富文本显示
	self.bRedoneSV = true --是否重算滑动条变化

	self.bBtnClick = false
end
  
--解析布局回调事件
function DlgBuyArenaShop:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgBuyArenaShop",handler(self, self.onDestroy))
end

--初始化控件
function DlgBuyArenaShop:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(3, 10336))
	--信息层
	self.pLayStuffInfo 				= 			self:findViewByName("lay_stuffinfo")
	--头像层
	self.pLayIcon = self:findViewByName("lay_icon")
	--物品名称标签
	self.pLbName = self:findViewByName("lb_name")
	--物品说明	
	self.pLbExpline = self:findViewByName("lb_expline")
	setTextCCColor(self.pLbExpline, _cc.white)
	--减少按钮
	self.playMinusTimes 					= 			self:findViewByName("lay_btn_left")
	self.pBtnMinus 					= 			getSepButtonOfContainer(self.playMinusTimes,TypeSepBtn.MINUS,TypeSepBtnDir.right)

	self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--增加按钮
	self.playPlusTimes 					= 			self:findViewByName("lay_btn_right")
	self.pBtnPlus 					= 			getSepButtonOfContainer(self.playPlusTimes,TypeSepBtn.PLUS,TypeSepBtnDir.left)

	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息

	--富文本显示
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
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	--设置滑动条值默认为一半
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)

	self:refreshSelectedTip()
end

function DlgBuyArenaShop:refreshSelectedTip(  )	
	local sStr = {
		{text=getConvertedStr(6, 10114),color=_cc.pwhite},
	 	{text=self._nselect,color=_cc.blue},
	 	{text="/"..self._nstuffs,color=_cc.pwhite}
	}
	self.pLbRichText:setString(sStr, false)
end

-- 修改控件内容或者是刷新控件数据
function DlgBuyArenaShop:updateViews()
	-- body	
	--物品数据
	if not self.pData then
		return
	end
	local itemdata = self.pData.tGood
	if not itemdata then
		return
	end
	--设置icon
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.itemnum, itemdata, TypeIconGoodsSize.L)
	else
		self.pIcon:setCurData(itemdata)
	end
	
	self.pLbName:setString(itemdata.sName)--刷新名字
	setLbTextColorByQuality(self.pLbName,itemdata.nQuality)
	self.pLbExpline:setString(itemdata.sDes)--物品说明

	self:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(6,10296))
	self:setRightHandler(handler(self, self.onBuyArenaShop))	
	
	--更新进度条显示	
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--滑动条释放消息回调
function DlgBuyArenaShop:onSliderBarRelease( pView )
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
function DlgBuyArenaShop:onSliderBarChange( pView )
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
function DlgBuyArenaShop:onMinusBtnClicked( pView )
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
function DlgBuyArenaShop:onPlusBtnClicked( pView )
	-- body
	local nselect = self._nselect + 1
	if nselect > self._nstuffs then
		nselect = self._nstuffs		
	end
	self._nselect = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--
function DlgBuyArenaShop:onBuyArenaShop(  )
	-- body
	if self.pData then
		if self.bBtnClick  then
			return
		end
		self.bBtnClick = true 
		SocketManager:sendMsg("buyArenaItem", {self.pData.idx, self._nselect}, function ( __msg )
			-- body
			self.bBtnClick = false
			if __msg.head.state == SocketErrorType.success then				
				closeDlgByType(e_dlg_index.dlgbuyarenashop, false)				
			else
				TOAST(SocketManager:getErrorStr(__msg.head.state))	
			end						
		end) 	
	end
end

--析构方法
function DlgBuyArenaShop:onDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgBuyArenaShop:regMsgs( )
	-- body
end

-- 注销消息
function DlgBuyArenaShop:unregMsgs(  )
	-- body
end


--暂停方法
function DlgBuyArenaShop:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyArenaShop:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgBuyArenaShop:setData( _tData )
	-- body
	self.pData = _tData	
	self:updateViews()
end

return DlgBuyArenaShop
