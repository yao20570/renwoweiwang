-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-29 16:44:23 星期一
-- Description: 抢红包
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgRedPocketCatchDetail = class("DlgRedPocketCatchDetail", function()
	-- body
	return MDialog.new(e_dlg_index.dlgredpocketcatchdetail)
end)

function DlgRedPocketCatchDetail:ctor( _nRedPocketId )
	-- body
	self:myInit(_nRedPocketId)
	parseView("lay_red_pocket_catch_detail", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgRedPocketCatchDetail:myInit( _nRedPocketId )
	-- body
	self.nGoodId = _nRedPocketId or nil
	self.nresttimes 		= 		0		--玩家当天可以购买能量的剩余次数
	self.nselecttimes 		=		1 		--玩家当前选定的购买次数	
	self.bRedoneSV = true --是否重算滑动条变化	

	self.bIsClick = false 
end

--解析布局回调事件
function DlgRedPocketCatchDetail:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRedPocketCatchDetail",handler(self, self.onDestroy))
end

--初始化控件
function DlgRedPocketCatchDetail:setupViews(  )
	--body	
	self.pLayRoot 		= 		self:findViewByName("lay_default")
	self.pLayClose 		= 		self:findViewByName("lay_btn_close")
	self.pLayClose:setViewTouched(true)
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:onMViewClicked(function (  )
		-- body
		self:closeDlg()
	end)

	self.pLayIcon = self:findViewByName("lay_icon")	

	self.pLbPara1 = self:findViewByName("lb_par_1")	
	setTextCCColor(self.pLbPara1, _cc.yellow)

	self.pLbPara2 = self:findViewByName("lb_par_2")
	setTextCCColor(self.pLbPara2, _cc.white)
	self.pLbPara2:setString(getConvertedStr(6, 10604))
	self.pLbPara3 = self:findViewByName("lb_par_3")	
	setTextCCColor(self.pLbPara3, _cc.white)
	self.pLbPara3:setString(getConvertedStr(6, 10605))
	--红包配置
	local tData = getRedPocketData(self.nGoodId)
	--dump(tData, "tData", 100)
	self.nMax = tData.maxnum
	self.nMin = tData.minnum	

	self.pLbPara4 = self:findViewByName("lb_par_4")	
	self.pLayBar = self:findViewByName("lay_bar")
	self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v2_bar_yellow_honbao.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(254, 18)
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.pLayBar:addView(self.pSliderBar)


	self.pImgReduce = self:findViewByName("img_btn_reduce")
	self.pImgReduce:setViewTouched(true)
	self.pImgReduce:setIsPressedNeedScale(false)
	self.pImgReduce:onMViewClicked(handler(self, self.onReduce))
	self.pImgIncrease = self:findViewByName("img_btn_increase")
	self.pImgIncrease:setViewTouched(true)
	self.pImgIncrease:setIsPressedNeedScale(false)
	self.pImgIncrease:onMViewClicked(handler(self, self.onIncrease))	

	self.bIsNewServer = isNewServer()
	if self.bIsNewServer then
		self.pLayRight = self:findViewByName("lay_btn_right")
		self.pBtnRight = getCommonButtonOfContainer(self.pLayRight, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10608))
		self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClick))
		self.pLayRight:setPositionX((self.pLayRoot:getWidth()-self.pLayRight:getWidth())/2)

		local pLayLeft = self:findViewByName("lay_btn_left")
		pLayLeft:setVisible(false)
	else
		self.pLayLeft = self:findViewByName("lay_btn_left")
		self.pBtnLeft = getCommonButtonOfContainer(self.pLayLeft, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10607))
		self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClick))

		self.pLayRight = self:findViewByName("lay_btn_right")
		self.pBtnRight = getCommonButtonOfContainer(self.pLayRight, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10608))
		self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClick))
	end

	
	

	local pGood = Player:getBagInfo():getItemDataById(self.nGoodId)
	--dump(pGood, "pGood", 100)
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, pGood)
		self.pIcon:setIconIsCanTouched(false)
	else
		self.pIcon:setCurData(pGood)
	end
	self.pLbPara1:setString(pGood.sName or "", false)

	self.nresttimes 		= 		tData.maxnum or 2		--玩家当天可以购买能量的剩余次数
	self.nselecttimes 		=		tData.minnum or 2 		--玩家当前选定的购买次数
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)	
end

--控件刷新
function DlgRedPocketCatchDetail:updateViews(  )
	-- body
	--print("self.nGoodId=", self.nGoodId)
	self:refreshBuyTipsS(true)
end

--析构方法
function DlgRedPocketCatchDetail:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgRedPocketCatchDetail:regMsgs(  )
	-- body

end
--注销消息
function DlgRedPocketCatchDetail:unregMsgs(  )
	-- body

end

--暂停方法
function DlgRedPocketCatchDetail:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgRedPocketCatchDetail:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--减少
function DlgRedPocketCatchDetail:onReduce(  )
	-- body

	local nselect = self.nselecttimes - 1
	if nselect <= self.nMin  then
		nselect = self.nMin			
	end
	self.nselecttimes = nselect
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)		
end
--增加
function DlgRedPocketCatchDetail:onIncrease(  )
	-- body
	local nselect = self.nselecttimes + 1
	if nselect > self.nMax then
		nselect = self.nMax		
	end
	self.nselecttimes = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)		
end

function DlgRedPocketCatchDetail:onSliderBarRelease(pView)
	-- body
	self.bRedoneSV = true
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	self.nselecttimes = roundOff(self.nresttimes*curvalue/100, 1) --获取当前次数
	if self.nselecttimes <= self.nMin then
		self.nselecttimes = self.nMin
	end
	curvalue = self.nselecttimes/self.nresttimes*100
	self.pSliderBar:setSliderValue(curvalue)	
end

function DlgRedPocketCatchDetail:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nselect = roundOff(self.nresttimes*curvalue/100, 1) --获取当前次数
		if nselect <= self.nMin then
			nselect = self.nMin
		end
		self.nselecttimes = nselect		
	else
		self.bRedoneSV = true	
	end		
	self:refreshBuyTipsS()
end

function DlgRedPocketCatchDetail:refreshBuyTipsS(  )
	-- body
	local sStr = {
		{color=_cc.white, text=getConvertedStr(6, 10606)},
		{color=_cc.yellow, text=self.nselecttimes}
	}
	self.pLbPara4:setString(sStr, false)

end

--世界
function DlgRedPocketCatchDetail:onLeftClick(  )
	-- body
	print("世界")
	if self.bIsClick == true then
		return
	end 
	self.bIsClick = true
	SocketManager:sendMsg("opencatchredpocket", {self.nGoodId, self.nselecttimes, 1},handler(self, self.onCatchRedPocket)) 	
end
--国家
function DlgRedPocketCatchDetail:onRightClick(  )
	-- body
	print("国家")
	if self.bIsClick == true then
		return
	end 
	self.bIsClick = true	
	SocketManager:sendMsg("opencatchredpocket", {self.nGoodId, self.nselecttimes, 2},handler(self, self.onCatchRedPocket)) 	
end

function DlgRedPocketCatchDetail:onCatchRedPocket( __msg, __oldMsg )
	-- body
	if __msg.head.type == MsgType.opencatchredpocket.id then 		--兵营调整
		if __msg.head.state == SocketErrorType.success then			
			TOAST(getConvertedStr(6, 10614))
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end	    
    self:closeDlg()
    self.bIsClick = false
end

return DlgRedPocketCatchDetail