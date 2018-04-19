-- Author: maheng
-- Date: 2017-05-26 11:56:24
-- 联系客服对话框


local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgContactService = class("DlgContactService", function ()
	return DlgAlert.new(e_dlg_index.dlgcontactservice)
end)

--构造
function DlgContactService:ctor()
	-- body
	self:myInit()
	parseView("dlg_contact_service", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgContactService:myInit()
	-- body

end
  
--解析布局回调事件
function DlgContactService:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, false)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgContactService",handler(self, self.onDlgContactServiceDestroy))
end

--初始化控件
function DlgContactService:setupViews()
	-- body
	self:setTitle(getConvertedStr(6, 10258))
	self.pLbTip = self:findViewByName("lb_tip")
	setTextCCColor(self.pLbTip, _cc.pwhite)
	self.pLbTip:setString(getConvertedStr(6, 10266))

	--添加标签起始高度250, 间隔40，从上到下


	self:setContentBgTransparent()
end

-- 修改控件内容或者是刷新控件数据
function DlgContactService:updateViews()
	-- body

end

--析构方法
function DlgContactService:onDlgContactServiceDestroy()
	self:onPause()
end

-- 注册消息
function DlgContactService:regMsgs( )
	-- body
end

-- 注销消息
function DlgContactService:unregMsgs(  )
	-- body
end


--暂停方法
function DlgContactService:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgContactService:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end
return DlgContactService
