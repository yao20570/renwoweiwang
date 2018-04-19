-- Author: maheng
-- Date: 2017-04-12 20:03:24
-- 玩家体力购买对话框


local DlgAlert = require("app.common.dialog.DlgAlert")
local MRichLabel = require("app.common.richview.MRichLabel")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgVitbuy = class("DlgVitbuy", function ()
	return DlgAlert.new(e_dlg_index.vitbuy)
end)

--构造
function DlgVitbuy:ctor()
	-- body
	self:myInit()
	parseView("dlg_vitbuy", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgVitbuy:myInit()
	-- body
	self.nBuyEnergytimes 	= 		nil		--玩家当天可以购买能量的总次数
	self.nresttimes 		= 		0		--玩家当天可以购买能量的剩余次数
	self.nselecttimes 		=		1 		--玩家当前选定的购买次数
	self.nMaxEnergry        =       tonumber(getGlobleParam("buyEnergy"))  --超过这个值不能购买
	-- self.bRedoneSV = true --是否重算滑动条变化
end
  
--解析布局回调事件
function DlgVitbuy:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgVitbuy",handler(self, self.onDlgVitbuyDestroy))
end

--初始化控件
function DlgVitbuy:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10080))
	--内容层
	self.pVitContent 				= 			self:findViewByName("Panel_13")
	--选择次数
	-- self.pLbSelTimes 				= 			self:findViewByName("lb_times")
	-- setTextCCColor(self.pLbSelTimes,_cc.pwhite)
	--减少按钮
	-- self.playMinusTimes 			=			self:findViewByName("lay_minus_times")
	-- self.pBtnMinus 					= 			getSepButtonOfContainer(self.playMinusTimes,TypeSepBtn.MINUS,TypeSepBtnDir.right)
	-- self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	-- --增加按钮
	-- self.playPlusTimes 				=			self:findViewByName("lay_plus_times")
	-- self.pBtnPlus 					= 			getSepButtonOfContainer(self.playPlusTimes,TypeSepBtn.PLUS,TypeSepBtnDir.left)
	-- self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息
	--拖动条
	local tVip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip)--获取玩家VIP等级对应的数据
	self.nBuyEnergytimes 			= 			tVip["buyenemy"]--玩家能购买能量的次数
	-- 屏蔽滑动
	self.playSliderBar				= 			self:findViewByName("lay_slider")
	self.playSliderBar:setVisible(false)
	-- self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
 --        {bar="ui/bar/v1_bar_b1.png",
 --        button="ui/bar/v2_btn_tuodong.png",
 --        barfg="ui/bar/v1_bar_yellow_3.png"}, 
 --        {scale9 = true, touchInButton=false})
	-- self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	-- self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	-- self.pSliderBar:setSliderSize(248, 20)
	-- self.pSliderBar:align(display.LEFT_BOTTOM)
	-- self.playSliderBar:addView(self.pSliderBar)



	--右侧确定按钮类型修改
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	--设置右边改名按钮的按钮事件
	self:setRightHandler(handler(self, self.onBtnRightClicked))	

	--设置购买提示
	--按钮上的金币提示
	local tBtnTable = {}
	tBtnTable.parent = self:getRightButton()
	tBtnTable.img = "#v1_img_qianbi.png"
	--文本
	tBtnTable.tLabel = {
		{"0",getC3B(_cc.blue)},
		{"/",getC3B(_cc.white)},
		{0,getC3B(_cc.white)}
	}
	tBtnTable.awayH = 5
	self.pBtnExText = MBtnExText.new(tBtnTable)

	--免费提示
	local pRightBtn = self:getRightButton()
	--显示免费 暂时保留
	-- self.pLbTip = MUI.MLabel.new({
 --        text=getConvertedStr(6, 10319),
 --        size=20,
 --        anchorpoint=cc.p(0.5, 0),       
 --        })
	-- setTextCCColor(self.pLbTip, _cc.blue)
	-- self.pLbTip:setPosition(pRightBtn:getPositionX() + pRightBtn:getWidth()/2, pRightBtn:getPositionY() + pRightBtn:getHeight() + 5)
	-- pRightBtn:getParent():addView(self.pLbTip, 10)
	-- self.pLbTip:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function DlgVitbuy:updateViews()
	-- body
	--今日还剩下购买次数
	self:refreshBuyTipsS(true)
--购买体力提示语1（是否购买体力）
	self:refreshBuyTipsF()
	self:refreshBuyTipsAct()
	
end

--刷新第一句提示语
function DlgVitbuy:refreshBuyTipsF(  )
	-- body
	--每购买一次可获取的能量值
	self.nCangetEvery = getGlobleParam("buyEnergyGet") or 100

    local strTips1 = {
    	{color=_cc.pwhite,text=getConvertedStr(1, 10393)},
    	{color=_cc.yellow,text=string.format(getConvertedStr(1, 10394),self.nCost)},
    	{color=_cc.pwhite,text=getConvertedStr(1, 10117)},
    	{color=_cc.blue,text=self.nCangetEvery},
    	{color=_cc.pwhite,text=getConvertedStr(1, 10075)},

    }
    self.pRichViewTips1 = MRichLabel.new({str=strTips1, fontSize=20, rowWidth=450})
    self.pRichViewTips1:setPosition(cc.p((self.pVitContent:getWidth() - self.pRichViewTips1:getWidth()) / 2, 135))
    self.pVitContent:addView( self.pRichViewTips1)

end

--刷新第二句提示语
--_bInit：是否初始化
function DlgVitbuy:refreshBuyTipsS( _bInit )
	-- body
	--获得剩余几次 和 总次数
	local nLeftBuy, nCanBuy, nHadBuy = Player:getPlayerInfo():getBuyEnergyLeftTimes()
	local pAct = Player:getActById(e_id_activity.energydiscount)--活动数据
	self.nCanBuy = nCanBuy
    if not self.pTextTip2 then
    	self.pTextTip2 =  MUI.MLabel.new({
    		text="",
    		size=20,
    		align = cc.ui.TEXT_ALIGN_LEFT,
			valign = cc.ui.TEXT_VALIGN_TOP,
			dimensions = cc.size(450, 0),
    		})
		self.pVitContent:addView(self.pTextTip2, 10)
	    self.pTextTip2:setAnchorPoint(cc.p(0.5,0.5))
		self.pTextTip2:setPosition(cc.p(self.pVitContent:getWidth() / 2, 115))
    end
    local tStr = {
		{color=_cc.pwhite,text=getConvertedStr(1, 10076)},
	    {color=_cc.blue,text=nLeftBuy},
	    {color=_cc.pwhite,text=string.format(getConvertedStr(1, 10077),nCanBuy)},
	    {color=_cc.blue,text=getConvertedStr(1, 10078)},
	    {color=_cc.pwhite,text=getConvertedStr(1, 10079)},
	}
    self.pTextTip2:setString(tStr)

    -- --设置购买拖动条
    -- if _bInit then
    -- 	if nLeftBuy > 0 then
    -- 		local nPercent = math.floor(1 / nLeftBuy * 100)
    -- 		self.pSliderBar:setSliderValue(nPercent)	--设置滑动条值默认为购买一次
    -- 	else
    -- 		self.pSliderBar:setSliderValue(0)
    -- 	end
    -- end
   	-- self.pLbSelTimes:setString(getConvertedStr(1, 10123) .. self.nselecttimes)
    --剩余次数
    self.nresttimes = nLeftBuy
    --显示剩余几次
    -- self.pRichViewTips1:updateLbByNum(2,self.nCangetEvery * self.nselecttimes)    
    --设置金币消耗
    self.nCost=0
    if pAct  then
    	local nActTime=pAct:getActDiscountTimes()
    	local nNormalSelectTime=0 			--普通购买的使用次数
    	if self.nselecttimes > nActTime and nActTime>0 then 		--所选次数大于活动次数
    		self.nCost=pAct:getEnergyDiscountCost(nActTime)
    		nNormalSelectTime = self.nselecttimes - nActTime
    		self.nCost = self.nCost + Player:getPlayerInfo():buyEnergyCost(nNormalSelectTime) or 0
    	elseif nActTime > 0 then
    		self.nCost = pAct:getEnergyDiscountCost(self.nselecttimes)
    	else
    		self.nCost = Player:getPlayerInfo():buyEnergyCost(self.nselecttimes) or 0
    	end
    	--可买次数那里添加活动优惠的次数
    	nLeftBuy=nLeftBuy+nActTime
    	nCanBuy = nCanBuy+pAct.nTc
    	
    else

    	self.nCost = Player:getPlayerInfo():buyEnergyCost(self.nselecttimes) or 0
    end

    local tStr = {
			{color=_cc.pwhite,text=getConvertedStr(1, 10076)},
		    {color=_cc.blue,text=nLeftBuy},
		    {color=_cc.pwhite,text=string.format(getConvertedStr(1, 10077),nCanBuy)},
		    {color=_cc.blue,text=getConvertedStr(1, 10078)},
		    {color=_cc.pwhite,text=getConvertedStr(1, 10079)},
		}
    self.pTextTip2:setString(tStr)

    -- local nCost = Player:getPlayerInfo():buyEnergyCost(self.nselecttimes) or 0
    if self.nCost > Player:getPlayerInfo().nMoney then
    	self.pBtnExText:setLabelCnCr(3, self.nCost)
    	 --设置拥有量
    	self.pBtnExText:setLabelCnCr(1,Player:getPlayerInfo().nMoney, getC3B(_cc.red))
    else
    	self.pBtnExText:setLabelCnCr(3, self.nCost)
    	 --设置拥有量
    	self.pBtnExText:setLabelCnCr(1,Player:getPlayerInfo().nMoney, getC3B(_cc.blue))
    end
   

 --    if nCost == 0 and nHadBuy == 0 then
	-- 	self.pLbTip:setVisible(true)
	-- 	self.pBtnExText:setVisible(false)
	-- else
	-- 	self.pLbTip:setVisible(false)
	-- 	self.pBtnExText:setVisible(true)		
	-- end
	
	if pAct then
		self.nresttimes=self.nresttimes+pAct:getActDiscountTimes()
	end

	--更新进度条显示	
	-- self.bRedoneSV = true
	-- self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)

end

--刷新第三句提示语
function DlgVitbuy:refreshBuyTipsAct(  )
	-- body
	local pAct = Player:getActById(e_id_activity.energydiscount)--活动数据
	if pAct then
		local nActDiscountTime=pAct:getActDiscountTimes()
	-- elseif pAct and pAct:getActFreeCallTimes() > 0 and nCalledNum == 1 then--活动免费
	-- 		--活动免费
	-- 		local sStr = {
	-- 			{color=_cc.pwhite, text=getConvertedStr(6, 10636)},
	-- 			{color=_cc.green, text=tostring(pAct.nFct)},
	-- 			{color=_cc.pwhite, text="/"..tostring(pAct.nTct)},
	-- 		}
	-- 		self.pLbTip:setString(sStr, false)
	-- 		local pFreeBtn = self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10169))
	-- 		pFreeBtn:onCommonBtnClicked(handler(self, self.onBtnFreeClicked))
	-- 		--停止计时器
	-- 		unregUpdateControl(self)
	-- 		return		

	    local strTips1 = {
	    	{color=_cc.pwhite,text=getConvertedStr(9, 10048)},
	    	{color=_cc.green,text=nActDiscountTime},
	    	{color=_cc.pwhite,text=getConvertedStr(3, 10324)},

	    }
	    if self.pRichViewTips2 then
	    	self.pRichViewTips2:setVisible(true)
	    else
	    	self.pRichViewTips2 = MRichLabel.new({str=strTips1, fontSize=20, rowWidth=450})
	    	self.pRichViewTips2:setPosition(cc.p((self.pVitContent:getWidth() - self.pRichViewTips2:getWidth()) / 2, 68))
	    	self.pVitContent:addView( self.pRichViewTips2)
	    end
	else
		if self.pRichViewTips2 then
			self.pRichViewTips2:setVisible(false)
		end
	end

end

--滑动条释放消息回调
function DlgVitbuy:onSliderBarRelease( pView )
	-- body
	-- self.bRedoneSV = true
	-- local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	-- self.nselecttimes = roundOff(self.nresttimes*curvalue/100, 1) --获取当前次数
	-- if self.nselecttimes <= 0 then
	-- 	self.nselecttimes = 1
	-- end
	-- curvalue = self.nselecttimes/self.nresttimes*100
	-- self.pSliderBar:setSliderValue(curvalue)
end

--滑动改变事件回调
function DlgVitbuy:onSliderBarChange( pView )
	-- body
	-- if self.bRedoneSV == true then
	-- 	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	-- 	local nselect = roundOff(self.nresttimes*curvalue/100, 1) --获取当前次数
	-- 	if nselect <= 0 then
	-- 		nselect = 1
	-- 	end
	-- 	self.nselecttimes = nselect
	-- end
	-- self:refreshBuyTipsS()
	-- self:refreshBuyTipsAct()
end

--minusBtn减少按钮点击回调事件
function DlgVitbuy:onMinusBtnClicked( pView )
	-- body
	-- local nselect = self.nselecttimes - 1
	-- if nselect < 1  then
	-- 	nselect = 1			
	-- end
	-- self.nselecttimes = nselect
	-- self.bRedoneSV = false
	-- self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)	
end

--plusBtn增加按钮点击回调事件
function DlgVitbuy:onPlusBtnClicked( pView )
	-- body
	-- local nselect = self.nselecttimes + 1
	-- if nselect > self.nresttimes then
	-- 	nselect = self.nresttimes		
	-- end
	-- self.nselecttimes = nselect	
	-- self.bRedoneSV = false
	-- self.pSliderBar:setSliderValue(self.nselecttimes/self.nresttimes*100)	
end

--析构方法
function DlgVitbuy:onDlgVitbuyDestroy()
	self:onPause()
end

-- 注册消息
function DlgVitbuy:regMsgs( )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

end

-- 注销消息
function DlgVitbuy:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end


--暂停方法
function DlgVitbuy:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgVitbuy:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--右侧确定按钮回调
function DlgVitbuy:onBtnRightClicked( pView )
	-- body
	if Player:getPlayerInfo().nEnergy >= self.nMaxEnergry then --没有选择购买次数
		TOAST(getTipsByIndex(20145))
	else
		-- 买后超出给个提示
		if getIsOverMaxEnergy(self.nCangetEvery) then
			local DlgAlert = require("app.common.dialog.DlgAlert")
		   	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		    	pDlg = DlgAlert.new(e_dlg_index.alert)
		    end
		    pDlg:setTitle(getConvertedStr(1,10034))
		    pDlg:setContent(string.format(getConvertedStr(1, 10392), tonumber(getGlobleParam("maxEnergy"))))
		    pDlg:setRightHandler(function ()
				if self and self.buyEnergy then
					self:buyEnergy(true)
					self:closeAlertDlg()
				end
		        closeDlgByType(e_dlg_index.alert, false)  
		    end)
		    pDlg:showDlg(bNew)
		else
			self:buyEnergy()
		end
	end
end

function DlgVitbuy:buyEnergy(_isAlert)
	if Player:getPlayerInfo().nMoney >= self.nCost then 
		SocketManager:sendMsg("buyEnergy", {self.nselecttimes}, function ( __msg, __oldMsg )
			if not _isAlert then
				self:closeAlertDlg()
			end
			-- body
			print("购买能量请求成功，这里以后需要做获得表现")
		end)
	else
   		local tObject = {}
		tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)   
	end
end

return DlgVitbuy
