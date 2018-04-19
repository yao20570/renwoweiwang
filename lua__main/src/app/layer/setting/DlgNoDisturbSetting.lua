-- Author: maheng
-- Date: 2017-04-21 11:56:24
-- 免打扰设置对话框


local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgNoDisturbSetting = class("DlgNoDisturbSetting", function ()
	return DlgAlert.new(e_dlg_index.dlgnodisturbsetting)
end)

--构造
function DlgNoDisturbSetting:ctor()
	-- body
	self:myInit()
	parseView("dlg_no_disturb_setting", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgNoDisturbSetting:myInit()
	-- body
	self.sStart = "22"
	self.sEnd   = "8"
	self.sStatus = "1"
end
  
--解析布局回调事件
function DlgNoDisturbSetting:onParseViewCallback( pView )
	-- body
	self:addContentView(pView)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgNoDisturbSetting",handler(self, self.onDlgNoDisturbSettingDestroy))
end

--初始化控件
function DlgNoDisturbSetting:setupViews()
	-- body
	self:setTitle(getConvertedStr(6, 10289))

	self.sStart = getLocalInfo("No_Disturb_Start", "22")
	self.sEnd 	= getLocalInfo("No_Disturb_End", "8")
	self.sStatus = getSettingInfo("NoDisturb")
	--固定标签
	self.pLbTip1 = self:findViewByName("lb_tip_1")
	setTextCCColor(self.pLbTip1, _cc.pwhite)
	self.pLbTip1:setString(getConvertedStr(6, 10269), false)
	self.pLbTip2 = self:findViewByName("lb_tip_2")
	setTextCCColor(self.pLbTip2, _cc.pwhite)
	self.pLbTip2:setString(getConvertedStr(6, 10090), false)
	self.pLbTip3 = self:findViewByName("lb_tip_3")
	setTextCCColor(self.pLbTip3, _cc.pwhite)
	self.pLbTip3:setString(getConvertedStr(6, 10147))
	self.pLbTip4 = self:findViewByName("lb_tip_4")
	setTextCCColor(self.pLbTip4, _cc.pwhite)
	self.pLbTip4:setString(getConvertedStr(6, 10172))
	self.pLbTip5 = self:findViewByName("lb_tip_5")
	setTextCCColor(self.pLbTip5, _cc.pwhite)
	self.pLbTip5:setString(getConvertedStr(6, 10173))
	self.pLbTip6 = self:findViewByName("lb_tip_6")
	setTextCCColor(self.pLbTip6, _cc.pwhite)
	self.pLbTip6:setString(getConvertedStr(6, 10173))
	--开启状态
	self.pLbStatus = self:findViewByName("lb_status")
	self.pLbStatus:setPositionX(self.pLbTip1:getPositionX() + self.pLbTip1:getWidth())
	self.pLbStatus:setString(getConvertedStr(6, 10286))
	setTextCCColor(self.pLbStatus, _cc.green)
	--时间
	self.pLbTime = self:findViewByName("lb_time")
	self.pLbTime:setPositionX(self.pLbTip2:getPositionX() + self.pLbTip2:getWidth())	
	self.pLbTime:setString(getNoDisturbTimeStr(self.sStart,self.sEnd))
	setTextCCColor(self.pLbTime, _cc.pwhite)
	--开启按钮
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10090))
	setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.8)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
	--开始时间
	self.pTexStartTip 		= 			self:findViewByName("tf_start")
	self.pTexStartTip:setPlaceHolder(self.sStart)
	self.pTexStartTip:setText(self.sStart)
	self.pTexStartTip:registerScriptEditBoxHandler(handler(self, self.onContentStartTime))
	
	--结束时间
	self.pTexEndTip 		= 			self:findViewByName("tf_end")
	self.pTexEndTip:setPlaceHolder(self.sEnd)
	self.pTexEndTip:setText(self.sEnd)
	self.pTexEndTip:registerScriptEditBoxHandler(handler(self, self.onContentEndTime))
	--关闭默认背景
	self:setContentBgTransparent()
	self:setRightHandler(function()
		setSettingInfo("NoDisturb", self.sStatus)
		saveLocalInfo("No_Disturb_Start", self.sStart)
		saveLocalInfo("No_Disturb_End", self.sEnd)
		sendMsg(ghd_no_desturb_status_change)
		self:closeAlertDlg()
	end)
end

-- 修改控件内容或者是刷新控件数据
function DlgNoDisturbSetting:updateViews()
	-- body
	if self.sStatus == "1" then		
		self.pLbStatus:setString(getConvertedStr(6, 10286))
		setTextCCColor(self.pLbStatus, _cc.green)
		self.pBtn:updateBtnText(getConvertedStr(6, 10288))
		self.pBtn:updateBtnType(TypeCommonBtn.M_RED)	
	else		
		self.pLbStatus:setString(getConvertedStr(6, 10287))
		setTextCCColor(self.pLbStatus, _cc.red)
		self.pBtn:updateBtnText(getConvertedStr(6, 10090))
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)	
	end
	self.pLbTime:setString(getNoDisturbTimeStr(self.sStart,self.sEnd))		
end

--析构方法
function DlgNoDisturbSetting:onDlgNoDisturbSettingDestroy()
	self:onPause()
end

-- 注册消息
function DlgNoDisturbSetting:regMsgs( )
	-- body
end

-- 注销消息
function DlgNoDisturbSetting:unregMsgs(  )
	-- body
end


--暂停方法
function DlgNoDisturbSetting:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgNoDisturbSetting:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end
--按钮回调
function DlgNoDisturbSetting:onBtnClicked( pView )
	-- body
	if self.sStatus == "1" then		
		self.sStatus = "0"
	else		
		self.sStatus = "1"
	end
	self:updateViews()	
	setSettingInfo("NoDisturb", self.sStatus)
	saveLocalInfo("No_Disturb_Start", self.sStart)
	saveLocalInfo("No_Disturb_End", self.sEnd)	
	sendMsg(ghd_no_desturb_status_change)	
end
--开始时间输入监听
function DlgNoDisturbSetting:onContentStartTime( eventType )
	-- body
	local sInput = ""
	if eventType == "changed" then
		sInput = self.pTexStartTip:getText()
		if getStringWordNum(sInput) > 2 then
			sInput = SubUTF8String(sInput, 2)
		end
		sInput = tonumber(sInput)
		if sInput then
			if  sInput >= 24 then
				sInput = math.floor(sInput/10)
			end
			self.pTexStartTip:setText(sInput)
			self.pTexStartTip:setPlaceHolder(sInput)
		else
			self.pTexStartTip:setText("0")
		end
		
    elseif eventType == "return" then
		self.sStart = self.pTexStartTip:getText()	
		self:updateViews()					
    end	
end

function DlgNoDisturbSetting:onContentEndTime( eventType )
	-- body
	local sInput = ""
	if eventType == "changed" then
		sInput = self.pTexEndTip:getText()
		if getStringWordNum(sInput) > 2 then
			sInput = SubUTF8String(sInput, 2)
		end
		sInput = tonumber(sInput)
		if sInput then
			if  sInput >= 24 then
				sInput = math.floor(sInput/10)
			end			
			self.pTexEndTip:setText(sInput)			
			self.pTexEndTip:setPlaceHolder(sInput)
		else
			self.pTexEndTip:setText("0")
		end		
    elseif eventType == "return" then
		self.sEnd = self.pTexEndTip:getText()	
		self:updateViews()					
    end		
end
return DlgNoDisturbSetting
