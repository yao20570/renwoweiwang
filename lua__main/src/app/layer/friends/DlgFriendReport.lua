-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-26 10:08:40 星期四
-- Description: 举报
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemCheck = require("app.layer.friends.ItemCheck")
local DlgFriendReport = class("DlgFriendReport", function()
	return DlgCommon.new(e_dlg_index.dlgfriendreport)
end)

function DlgFriendReport:ctor(_tData)
	-- body
	self:myInit()
	self.tData = _tData
	parseView("dlg_friend_report", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgFriendReport:myInit(  )
	-- body
	self.tItems = {}
end

--解析布局回调事件
function DlgFriendReport:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView,true) --加入内容层
	self:setTitle(getConvertedStr(5, 10143))
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgFriendReport",handler(self, self.onDestroy))
end

function DlgFriendReport:setupViews(  )
	-- body
	self.pLayRoot = self:findViewByName("dlg_friend_report")
	self.pLayTop = self:findViewByName("lay_top")
	self.pLbTip = self:findViewByName("lb_tip")
	setTextCCColor(self.pLbTip, _cc.pwhite)
	self.pLbTip:setString(getConvertedStr(6, 10571))
	--
	self.pLbTitle = self:findViewByName("lb_title_s")
	self.pLbTitle:setString(getConvertedStr(6, 10541), false)
	setTextCCColor(self.pLbTitle, _cc.white)
	--玩家名字
	self.pLbName = self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.white)
	--时间
	self.pLbTime = self:findViewByName("lb_time")
	setTextCCColor(self.pLbTime, _cc.pwhite)
	--聊天内容
	self.pLbCont = self:findViewByName("lb_cont") 


	self.pLayBot = self:findViewByName("lay_bot")

	local nHeight = self.pLayBot:getHeight()
	local nHDis = nHeight/5
	for i = 1, 5 do
		if not self.tItems[i] then
			local nX = 100
			local nY = nHeight - nHDis*i
			local pItem = ItemCheck.new(getConvertedStr(6, 10571 + i), false)
			pItem:setPosition(nX, nY)
			pItem:setItemClickParam(i)
			pItem:onItemClick(function ( bChecked, param)
				-- body
				--dump(param, "param", 100)
				local _index = param
				self:updateCheckGroup(_index)
			end)
			self.pLayBot:addView(pItem, 10)
			self.tItems[i] = pItem
		end
	end


	local pBtn = self:getOnlyConfirmButton(TypeCommonBtn.L_RED, getConvertedStr(5, 10143))
	pBtn:onCommonBtnClicked(handler(self, self.onReportCallBack))
end

-- 修改控件内容或者是刷新控件数据
function DlgFriendReport:updateViews(  )
	if self.tData then
		--dump(self.tData, "self.tData", 100)
		self.pLbName:setString(self.tData.sSn, false)
		self.pLbTime:setString(self:formatShowTime(self.tData.nSt), false)
		local tStr = nil
		if type(self.tData.sCnt) == "table" then
			tStr = self.tData.sCnt
		else
			tStr = getTextColorByConfigure(self.tData.sCnt)
		end		
		self.pLbCont:setString(tStr, false)
	end
end

-- 析构方法
function DlgFriendReport:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgFriendReport:regMsgs( )
	-- body
end

-- 注销消息
function DlgFriendReport:unregMsgs(  )
	-- body
end


--暂停方法
function DlgFriendReport:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgFriendReport:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

function DlgFriendReport:setCurData( _tData )
	-- body
	self.tData = _tData
	self:updateViews()
end

function DlgFriendReport:formatShowTime( fTime )
	-- body
	local sStr = ""
	local tData = os.date("*t", fTime/1000)
	local fCurTime = getSystemTime()
	local tCurData = os.date("*t", fCurTime)
	local fDisTime = fTime/1000 - fCurTime
	if(tCurData.year == tData.year and tData.yday == tCurData.yday) then -- 同一天
		if(tData.hour <= 9) then
			tData.hour = "0" .. tData.hour
		end
		if(tData.min <= 9) then
			tData.min = "0" .. tData.min
		end
		sStr = getConvertedStr(5, 10134) .. tData.hour .. ":" .. tData.min
	elseif(tCurData.year == tData.year and tCurData.yday-tData.yday == 1) then -- 昨天
		if(tData.hour <= 9) then
			tData.hour = "0" .. tData.hour
		end
		if(tData.min <= 9) then
			tData.min = "0" .. tData.min
		end
		sStr = getConvertedStr(5, 10135) .. tData.hour .. ":" .. tData.min
	else
		sStr = formatTime(fTime)
	end
	return sStr	
end

function DlgFriendReport:onReportCallBack(  )
	-- body
	--print("举报")	
	if self.tData and self.tData.bIsRb then
		TOAST(getConvertedStr(6, 10578))		
		self:closeDlg(false)
	else
		local nCause = self:getSelectedCheckIndex()
		if nCause then
			--print("nCause=", nCause)
			SocketManager:sendMsg("reqTipOff", {self.tData.nId, self.tData.nAccperId, nCause}, handler(self, self.onGetDataFunc))	--举报						
		else
			TOAST(getConvertedStr(6, 10577))
		end
	end
end

function DlgFriendReport:updateCheckGroup( _index )
	-- body
	--print("_index=", _index)
	for k= 1, 5  do
		local pItem = self.tItems[k]
		if k ~= _index then
			pItem:setItemSelected(false)
		end
	end
end

function DlgFriendReport:getSelectedCheckIndex(  )
	-- body
	for k, v in pairs(self.tItems) do
		if v:isItemSelected() then
			return k
		end
	end	
	return nil
end

function DlgFriendReport:onGetDataFunc( __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "reqTipOff", 100)
		if __msg.body then	
			TOAST(getConvertedStr(6, 10578))		
			self:closeDlg(false)			
		end
	else
		TOAST(getConvertedStr(6, 10579))
	end	
end
return DlgFriendReport