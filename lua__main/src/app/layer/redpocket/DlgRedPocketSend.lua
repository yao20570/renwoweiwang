-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-11-27 14:13:23 星期一
-- Description: 红包操作
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgRedPocketSend = class("DlgRedPocketSend", function()
	-- body
	return MDialog.new(e_dlg_index.dlgredpocketsend)
end)

function DlgRedPocketSend:ctor( _nRedPocketId )
	-- body
	self:myInit(_nRedPocketId)
	parseView("lay_red_pocket_send", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgRedPocketSend:myInit( _nRedPocketId )
	-- body
	self.nRedPocket = _nRedPocketId or nil
end

--解析布局回调事件
function DlgRedPocketSend:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRedPocketSend",handler(self, self.onDestroy))
end

--初始化控件
function DlgRedPocketSend:setupViews(  )
	--body	
	self.pLayRoot 		= 		self:findViewByName("lay_default")
	self.pLayClose 		= 		self:findViewByName("lay_btn_close")
	self.pLayClose:setViewTouched(true)
	self.pLayClose:setIsPressedNeedScale(false)
	self.pLayClose:onMViewClicked(function (  )
		-- body
		self:closeDlg()
	end)

	self.pLbDesc1 = self:findViewByName("lb_des_1")
	self.pLbDesc1:setString(getTextColorByConfigure(GetRedPocketContById(1)), false)
	
	self.pLbDesc2 = self:findViewByName("lb_des_2")
	self.pLbDesc2:setString(getTextColorByConfigure(GetRedPocketContById(2)), false)

	self.pLayCatch = self:findViewByName("lay_btn_catch")
	self.pBtnCatch = getCommonButtonOfContainer(self.pLayCatch, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10602))
	self.pBtnCatch:onCommonBtnClicked(handler(self, self.onCatchRedPocket))
	self.pLaySend = self:findViewByName("lay_btn_send")
	self.pBtnSend = getCommonButtonOfContainer(self.pLaySend, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10603))
	self.pBtnSend:onCommonBtnClicked(handler(self, self.onSendRedPocket))
end

--控件刷新
function DlgRedPocketSend:updateViews(  )
	-- body

end

--析构方法
function DlgRedPocketSend:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgRedPocketSend:regMsgs(  )
	-- body

end
--注销消息
function DlgRedPocketSend:unregMsgs(  )
	-- body

end

--暂停方法
function DlgRedPocketSend:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgRedPocketSend:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--抢红包按钮
function DlgRedPocketSend:onCatchRedPocket(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgredpocketcatchdetail --dlg类型
	tObject.nRedPocket = self.nRedPocket
	sendMsg(ghd_show_dlg_by_type,tObject)
	self:closeDlg()
end
--发送红包按钮
function DlgRedPocketSend:onSendRedPocket(  )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgredpocketsenddetail --dlg类型
	tObject.nRedPocket = self.nRedPocket
	sendMsg(ghd_show_dlg_by_type,tObject)
	self:closeDlg()
end
return DlgRedPocketSend