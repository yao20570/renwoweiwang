-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-27 14:14:23 星期一
-- Description: 红包发送界面
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgRedPocketSendDetail = class("DlgRedPocketSendDetail", function()
	-- body
	return MDialog.new(e_dlg_index.dlgredpocketsenddetail)
end)

function DlgRedPocketSendDetail:ctor( _nRedPocketId )
	-- body
	self:myInit(_nRedPocketId)
	parseView("lay_red_pocket_send_detail", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgRedPocketSendDetail:myInit( _nRedPocketId )
	-- body
	self.nGoodId = _nRedPocketId or nil
	self.nresttimes 		= 		0		--玩家当天可以购买能量的剩余次数
	self.nselecttimes 		=		1 		--玩家当前选定的购买次数	
	self.bRedoneSV = true --是否重算滑动条变化

	self.bIsClick = false 		
end

--解析布局回调事件
function DlgRedPocketSendDetail:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRedPocketSendDetail",handler(self, self.onDestroy))
end

--初始化控件
function DlgRedPocketSendDetail:setupViews(  )
	--body	
	self.pLayRoot 		= 		self:findViewByName("lay_default")
	self.pLayClose 		= 		self:findViewByName("lay_btn_close")
	self.pLayClose:setViewTouched(true)
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:onMViewClicked(function (  )
		-- body
		self:closeDlg()
	end)

	self.pLayIcon1 = self:findViewByName("lay_icon_1")
	self.pLayIcon2 = self:findViewByName("lay_icon_2")
	self.pIconFriend = getIconHeroByType(self.pLayIcon2, TypeIconHero.ADD, nil, TypeIconHeroSize.L)
	--self.pIconFriend:setIconIsCanTouched(false)
	self.pIconFriend:setIconClickedCallBack(handler(self, self.onIconClicked))


	self.pLbPara1 = self:findViewByName("lb_par_1")	
	setTextCCColor(self.pLbPara1, _cc.yellow)	

	self.pLbPara2 = self:findViewByName("lb_par_2")
	setTextCCColor(self.pLbPara2, _cc.white)
	self.pLbPara2:setString(getConvertedStr(6, 10609))
	--
	self.pLbPara3 = self:findViewByName("lb_par_3")	
	setTextCCColor(self.pLbPara3, _cc.white)
	self.pLbPara3:setString(getConvertedStr(6, 10610))
	--赠送红包数量
	self.pLbPara4 = self:findViewByName("lb_par_4")	
	setTextCCColor(self.pLbPara4, _cc.white)
	self.pLbPara4:setString(getConvertedStr(6, 10605))
	--红包总金额
	self.pLbPara5 = self:findViewByName("lb_par_5")	
	setTextCCColor(self.pLbPara5, _cc.white)
	self.pLbPara5:setString(getConvertedStr(6, 10605))

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

	--红包配置
	local pGood = Player:getBagInfo():getItemDataById(self.nGoodId)

	self.nMax = pGood.nCt
	self.nMin = 1		
	--dump(pGood, "pGood", 100)
	if not self.pIcon1 then
		self.pIcon1 = getIconGoodsByType(self.pLayIcon1, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, pGood)
		self.pIcon1:setIconIsCanTouched(false)
	else
		self.pIcon1:setCurData(pGood)
	end
	self.pLbPara1:setString(pGood.sName or "", false)

	self.pImgReduce = self:findViewByName("img_btn_reduce")
	self.pImgReduce:setViewTouched(true)
	self.pImgReduce:setIsPressedNeedScale(false)
	self.pImgReduce:onMViewClicked(handler(self, self.onReduce))
	self.pImgIncrease = self:findViewByName("img_btn_increase")
	self.pImgIncrease:setViewTouched(true)
	self.pImgIncrease:setIsPressedNeedScale(false)
	self.pImgIncrease:onMViewClicked(handler(self, self.onIncrease))	

	self.pLayLeft = self:findViewByName("lay_btn_left")
	self.pBtnLeft = getCommonButtonOfContainer(self.pLayLeft, TypeCommonBtn.M_YELLOW, getConvertedStr(1, 10058))
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClick))
	self.pLayRight = self:findViewByName("lay_btn_right")
	self.pBtnRight = getCommonButtonOfContainer(self.pLayRight, TypeCommonBtn.M_BLUE, getConvertedStr(1, 10059))
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClick))

	self.nresttimes 		= 		self.nMax 
	self.nselecttimes 		=		self.nMin
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)		
end

--控件刷新
function DlgRedPocketSendDetail:updateViews(  )
	-- body

end

--析构方法
function DlgRedPocketSendDetail:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgRedPocketSendDetail:regMsgs(  )
	-- body
	regMsg(self, ghd_selected_redpocket_msg, handler(self, self.updateCurFriendData))	
end
--注销消息
function DlgRedPocketSendDetail:unregMsgs(  )
	-- body
	unregMsg(self, ghd_selected_redpocket_msg)
end

--暂停方法
function DlgRedPocketSendDetail:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgRedPocketSendDetail:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--减少
function DlgRedPocketSendDetail:onReduce(  )
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
function DlgRedPocketSendDetail:onIncrease(  )
	-- body
	local nselect = self.nselecttimes + 1
	if nselect > self.nMax then
		nselect = self.nMax		
	end
	self.nselecttimes = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)		
end

function DlgRedPocketSendDetail:onSliderBarRelease(pView)
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

function DlgRedPocketSendDetail:onSliderBarChange( pView )
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

function DlgRedPocketSendDetail:refreshBuyTipsS(  )
	-- body
	local sStr = {
		{color=_cc.white, text=getConvertedStr(6, 10612)},
		{color=_cc.yellow, text=self.nselecttimes}
	}
	self.pLbPara4:setString(sStr, false)

	local pData = getRedPocketData(self.nGoodId)
	local nMoney = pData.money
	local sStr1 = {
		{color=_cc.white, text=getConvertedStr(6, 10611)},
		{color=_cc.yellow, text=self.nselecttimes*nMoney}
	}
	self.pLbPara5:setString(sStr1, false)	

end

--世界
function DlgRedPocketSendDetail:onLeftClick(  )
	-- body
	self:closeDlg()
end
--国家
function DlgRedPocketSendDetail:onRightClick(  )
	-- body
	print("发送好友")
	if self.pCurFriendVo then
		if self.bIsClick == true then
			return
		end
		self.bIsClick = true
		SocketManager:sendMsg("sendredpocket", {self.nGoodId, self.nselecttimes, self.pCurFriendVo.sTid}, function ( __msg, __oldMsg )
			-- body
			if __msg.head.type == MsgType.sendredpocket.id then 		--兵营调整
				if __msg.head.state == SocketErrorType.success then			
					TOAST(getConvertedStr(6, 10614))
					self:closeDlg()	
				else
				    TOAST(SocketManager:getErrorStr(__msg.head.state))
		        end
		    end			    		
		    self.bIsClick = false
		end) 	
	else
		TOAST(getConvertedStr(6, 10613))		
	end
end

function DlgRedPocketSendDetail:onIconClicked( pData )
	-- body
	local tObject = {}				
	tObject.nType = e_dlg_index.dlgfriendselect --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

function DlgRedPocketSendDetail:updateCurFriendData( msgName,pMsg )
	-- body
	self.pCurFriendVo = pMsg.pData or nil
	self.pIconFriend:setCurData(self.pCurFriendVo)
	if self.pCurFriendVo then
		self.pLbPara3:setString(self.pCurFriendVo.sName)		
	else
		self.pLbPara3:setString(getConvertedStr(6, 10610), false) 
	end
end
return DlgRedPocketSendDetail