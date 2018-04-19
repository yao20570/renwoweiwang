-- Author: maheng
-- Date: 2017-06-10 10:34:24
-- 国王发送圣旨对话框


local DlgAlert = require("app.common.dialog.DlgAlert")


local DlgSendDecree = class("DlgSendDecree", function ()
	return DlgAlert.new(e_dlg_index.dlgsenddecree)
end)

--构造
function DlgSendDecree:ctor()
	-- body
	self:myInit()
	parseView("dlg_send_decree", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgSendDecree:myInit()
	-- body
	self.sContent = nil
	self.ntimes = 0
end
  
--解析布局回调事件
function DlgSendDecree:onParseViewCallback( pView )
	-- body
	
	self:addContentView(pView, true)
	self:setupViews()

	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgSendDecree",handler(self, self.onDlgSendDecreeDestroy))
end

--初始化控件
function DlgSendDecree:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10376))
	self.pLbTip1 = self:findViewByName("lb_tip_1")
	self.pLbTip1:setString(getConvertedStr(6, 10370), false)
	setTextCCColor(self.pLbTip1, _cc.pwhite)

	self.pLbTip2 = self:findViewByName("lb_tip_2")
	self.pLbTip2:setString(getConvertedStr(6, 10371), false)
	setTextCCColor(self.pLbTip2, _cc.pwhite)

	-- self.pLbTip3 = self:findViewByName("lb_tip_3")
	-- self.pLbTip3:setString(getConvertedStr(6, 10372), false)
	-- setTextCCColor(self.pLbTip3, _cc.pwhite)

	self.pLayEdit = self:findViewByName("lay_edit")	
	local pi = self:findViewByName("lay_edit_cont")
	self.pInput = addCoupleLineEdit(pi, {gap=0})

	self.ntimes = tonumber(getCountryParam("maxModifyNoticeTimes"))

	local tCountryDatavo = Player:getCountryData():getCountryDataVo()	
	if not tCountryDatavo.sAffiche or tCountryDatavo.sAffiche == "" then
		self.pInput:setPlaceHolder(getConvertedStr(6, 10373))
		self.pInput:setFontColor(getC3B(_cc.gray))
	else
		self.sContent = tCountryDatavo.sAffiche
		self.pInput:setText(self.sContent)
		self.pInput:setFontColor(getC3B(_cc.pwhite))
	end
	self.pInput:setMaxLength(99)
	self.pInput:registerScriptEditBoxHandler(handler(self, self.onContentEdit))

	-- self.pLbCurWordNum = self:findViewByName("lb_word_num")
	-- setTextCCColor(self.pLbCurWordNum, _cc.blue) 
	-- self.pLbCurWordNum:setString("0", false)

	-- self.pLbWordMax = self:findViewByName("lb_word_max")
	-- setTextCCColor(self.pLbWordMax, _cc.pwhite)
	self.nwordmax = tonumber(getCountryParam("maxNoticeLenght"))
	-- self.pLbWordMax:setString("/"..self.nwordmax, false)

	local sStr1 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10371)},
		{color=_cc.pwhite, text=getStringWordNum(self.sContent)},
		{color=_cc.pwhite, text="/"..self.nwordmax},
	}
	self.pLbTip2:setString(sStr1, false)
	--self.pLbSendNum = self:findViewByName("lb_send_num") 
	--setTextCCColor(self.pLbSendNum, _cc.blue)
	--self.pLbCurWordNum:setString(getStringWordNum(self.sContent), false)

	-- self.pLbSendMax = self:findViewByName("lb_send_max")
	-- setTextCCColor(self.pLbSendMax, _cc.pwhite)
	
	-- self.pLbSendMax:setString("/"..self.ntimes, false)
	
	self.pBtnRight:updateBtnText(getConvertedStr(6, 10380))
	self:setRightHandler(handler(self,self.onRightBtnClicked))
	--文本
	local tLLabel = {
			{getConvertedStr(6, 10372),getC3B(_cc.pwhite)},
			{0,getC3B(_cc.blue)},
			{"/",getC3B(_cc.pwhite)},
			{self.ntimes,getC3B(_cc.pwhite)},

		}
	local tBtnLTable = {}

	tBtnLTable.tLabel = tLLabel
	self.pLExText =  self.pBtnRight:setBtnExText(tBtnLTable)


	self:setContentBgTransparent()
end

-- 修改控件内容或者是刷新控件数据
function DlgSendDecree:updateViews()
	-- body
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()	
	local nleft = self.ntimes - tCountryDatavo.nAfficheCnt
	if nleft <= 0 then
		nleft = 0 
	end
	-- self.pLbSendNum:setString(nleft, false)
	self.pLExText:setLabelCnCr(2,nleft)
	--self:updateLabelPosition()
end

--析构方法
function DlgSendDecree:onDlgSendDecreeDestroy()
	self:onPause()	
end

-- 注册消息
function DlgSendDecree:regMsgs( )
	-- body
end

-- 注销消息
function DlgSendDecree:unregMsgs(  )
	-- body
end


--暂停方法
function DlgSendDecree:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgSendDecree:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgSendDecree:onContentEdit(eventType)
	local sInput = ""
	if eventType == "began" then
		-- sInput = self.pInput:getText()
    elseif eventType == "ended" then
		-- sInput = self.pInput:getText()
    elseif eventType == "changed" then
		sInput = self.pInput:getText()
		local nCurNum = getStringWordNum(sInput)
		if nCurNum <= self.nwordmax then
			self.pInput:setText(sInput)
		end		
		--self.pLbCurWordNum:setString(nCurNum, false)
		local sStr1 = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10371)},
			{color=_cc.pwhite, text=nCurNum},
			{color=_cc.pwhite, text="/"..self.nwordmax},
		}
		self.pLbTip2:setString(sStr1, false)		
		--self:updateLabelPosition()
    elseif eventType == "return" then
    	self.sContent = self.pInput:getText()
    end    
end

-- --标签位置调整
-- function DlgSendDecree:updateLabelPosition( )
-- 	-- body
-- 	local x = self.pLayEdit:getWidth()
-- 	self.pLbWordMax:setPositionX(x)
-- 	self.pLbCurWordNum:setPositionX(x - self.pLbWordMax:getWidth())
-- 	self.pLbTip2:setPositionX(x - self.pLbWordMax:getWidth() - self.pLbCurWordNum:getWidth())
-- 	self.pLbSendMax:setPositionX(x)
-- 	self.pLbSendNum:setPositionX(x - self.pLbSendMax:getWidth())
-- 	self.pLbTip3:setPositionX(x - self.pLbSendMax:getWidth() - self.pLbSendNum:getWidth())
-- end

--发送
function DlgSendDecree:onRightBtnClicked( pview )
	-- body
	SocketManager:sendMsg("announceDecree", {self.sContent},handler(self, self.onAnnounceDecree))
	self:closeAlertDlg()
end
function DlgSendDecree:onAnnounceDecree( __msg )
	-- body
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.announceDecree.id then

        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end	
end
return DlgSendDecree
