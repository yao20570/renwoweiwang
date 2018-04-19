-- Author: maheng
-- Date: 2018-01-22 14:32:24
-- Vip 竞技场购买次数


local DlgAlert = require("app.common.dialog.DlgAlert")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgBuyArenaChallenge = class("DlgBuyArenaChallenge", function ()
	return DlgAlert.new(e_dlg_index.arenabuychallenge)
end)

--构造
function DlgBuyArenaChallenge:ctor()
	-- body
	self:myInit()	
	parseView("layout_buy_arena_challenge", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuyArenaChallenge:myInit()
	-- body
	self._nBuyTotal = 		2		--物品总量
	self._nselect 	=		1		--玩家当前选定的购买次数
	self.bRedoneSV = true --是否重算滑动条变化

	self.bBtnClick = false
end
  
--解析布局回调事件
function DlgBuyArenaChallenge:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgBuyArenaChallenge",handler(self, self.onDestroy))
end

--初始化控件
function DlgBuyArenaChallenge:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6, 10707))	
	self.pLayRoot = self:findViewByName("layout_buy_arena_challenge")
	self.playMinusTimes 			= 			self:findViewByName("lay_btn_left")
	self.playPlusTimes 				= 			self:findViewByName("lay_btn_right")
	self.pLbRichText  				= 			self:findViewByName("lb_select")
	self.playSliderBar				= 			self:findViewByName("lay_bar_bg")
	self.pLbTip1 					= 			self:findViewByName("lb_tip_1")
	self.pLbTip2 					= 			self:findViewByName("lb_tip_2")
	self.pLbTip2:setVisible(false)
	--减少按钮
	self.pBtnMinus 					= 			getSepButtonOfContainer(self.playMinusTimes,TypeSepBtn.MINUS,TypeSepBtnDir.right)
	self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--增加按钮	
	self.pBtnPlus 					= 			getSepButtonOfContainer(self.playPlusTimes,TypeSepBtn.PLUS,TypeSepBtnDir.left)
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息

	--拖动条	
	self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_3.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(250, 18)
	self.pSliderBar:setSliderValue(0)	--设置滑动条值默认为一半
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)

	--购买按钮
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	self:setRightBtnText(getConvertedStr(6,10296))
	self:setRightHandler(handler(self, self.onBuyBtnClicked))

	-- self.pLbTip1:setString(getConvertedStr(6, 10708), false)
	-- setTextCCColor(self.pLbTip1, _cc.white)
	-- self.pLbTip2:setString(getConvertedStr(6, 10709), false)
	-- setTextCCColor(self.pLbTip2, _cc.pwhite)
	-- if Player:getPlayerInfo():isVipLevelFull() then
	-- 	self.pLbTip2:setVisible(false)
	-- 	self.pLbTip1:setPositionY((self.pLbTip1:getPositionY() + self.pLbTip2:getPositionY())/2) 		
	-- else
	-- 	self.pLbTip2:setVisible(true) 				
	-- end		
	self.pLbTip = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0.5, 0.5),
		    align = cc.ui.TEXT_ALIGN_CENTER,
			valign = cc.ui.TEXT_VALIGN_CENTER,
		    color = cc.c3b(255, 255, 255),
		})
	self.pLbTip:setPosition(self.pLbTip1:getPositionX(), self.pLbTip1:getPositionY())
	self.pLayRoot:addView(self.pLbTip, 10)

end
--富文本显示
function DlgBuyArenaChallenge:refreshSelectedTip(  )	

	local sTip = string.format(getTipsByIndex(20143), self._nselect, self._nBuyTotal)
	self.pLbTip:setString(getTextColorByConfigure(sTip), false)

	local sStr = {
		{text=getConvertedStr(6, 10114),color=_cc.pwhite},
	 	{text=self._nselect,color=_cc.blue},
	 	-- {text="/"..self._nBuyTotal,color=_cc.pwhite}
	}
	self.pLbRichText:setString(sStr, false)
	
	--按钮上的金币提示
	local nCost = Player:getArenaData():getBuyChallengeCost(self._nselect)	
	local sColor = _cc.pwhite
	if nCost > Player:getPlayerInfo().nMoney then
		sColor = _cc.red
	end 
	if not self.pBtnExText then
		local tBtnTable = {}
		tBtnTable.parent = self.pBtnRight
		if nCost > 0 then
			tBtnTable.img = getCostResImg(e_resdata_ids.ybao)
			--文本
			tBtnTable.tLabel = {
				{nCost,getC3B(sColor)}
			}
		else	--免费		
			--文本
			tBtnTable.tLabel = {
				{getConvertedStr(6, 10319),getC3B(_cc.green)}
			}
		end
		tBtnTable.awayH = 5
		self.pBtnExText = MBtnExText.new(tBtnTable)
	else
		--todo	
		if nCost > 0 then--
			self.pBtnExText:setImg(getCostResImg(e_resdata_ids.ybao))
			self.pBtnExText:setLabelCnCr(1, nCost, getC3B(sColor))
		else	--免费				
			--文本
			self.pBtnExText:setImg(nil)
			self.pBtnExText:setLabelCnCr(1, getConvertedStr(6, 10319), getC3B(_cc.green))
		end		
		
	end

end

-- 修改控件内容或者是刷新控件数据
function DlgBuyArenaChallenge:updateViews()
	-- body		
	self._nBuyTotal = Player:getArenaData():getLeftVipChallengeTime()	

	--更新进度条显示	
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self._nselect/self._nBuyTotal*100)

	self:refreshSelectedTip()
end

--滑动条释放消息回调
function DlgBuyArenaChallenge:onSliderBarRelease( pView )
	-- body
	self.bRedoneSV = true
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	self._nselect = roundOff(self._nBuyTotal*curvalue/100, 1) --获取当前次数
	if self._nselect <= 0 then
		self._nselect = 1
	end
	curvalue = self._nselect/self._nBuyTotal*100
	self.pSliderBar:setSliderValue(curvalue)		
end

--滑动滑动消息回调
function DlgBuyArenaChallenge:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nselect = roundOff(self._nBuyTotal*curvalue/100, 1) --获取当前次数
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
function DlgBuyArenaChallenge:onMinusBtnClicked( pView )
	-- body	
	local nselect = self._nselect - 1
	if nselect < 1  then
		nselect = 1			
	end
	self._nselect = nselect
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nBuyTotal*100)	
end

--plusBtn增加按钮点击回调事件
function DlgBuyArenaChallenge:onPlusBtnClicked( pView )
	-- body
	local nselect = self._nselect + 1
	if nselect > self._nBuyTotal then
		nselect = self._nBuyTotal		
	end
	self._nselect = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nBuyTotal*100)	
end

function DlgBuyArenaChallenge:onBuyBtnClicked(  )
	-- body
	if self.bBtnClick  then
		return
	end
	self.bBtnClick = true 
	SocketManager:sendMsg("buyChallengeTimes", {self._nselect}, function ( __msg )
		-- body		
		self.bBtnClick = false
		if __msg.head.state == SocketErrorType.success then	
			TOAST(getConvertedStr(6, 10756))
			closeDlgByType(e_dlg_index.arenabuychallenge, false)
		else
			TOAST(SocketManager:getErrorStr(__msg.head.state))	
		end	
	end) 	
end

--析构方法
function DlgBuyArenaChallenge:onDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgBuyArenaChallenge:regMsgs( )
	-- body
end

-- 注销消息
function DlgBuyArenaChallenge:unregMsgs(  )
	-- body
end


--暂停方法
function DlgBuyArenaChallenge:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgBuyArenaChallenge:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgBuyArenaChallenge
