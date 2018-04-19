-- Author: dshulan
-- Date: 2017-06-27 20:03:24
-- 充值对话框


local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgRechargeTip = class("DlgRechargeTip", function ()
	return DlgAlert.new(e_dlg_index.dlgrechargetip)
end)

--构造
function DlgRechargeTip:ctor()
	-- body
	self:myInit()
end

--初始化成员变量
function DlgRechargeTip:myInit()
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgRechargeTip",handler(self, self.onDlgRechargeTipDestroy))
end
  
--解析布局回调事件
function DlgRechargeTip:onParseViewCallback( pView )
	-- body
	
end

--初始化控件
function DlgRechargeTip:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10034))
	self:setRightBtnText(getConvertedStr(7, 10071))
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	--设置内容
	self:setContent(getConvertedStr(7, 10072))
	self:setRightHandler(function()
		-- 跳到充值界面
		local tObject = {}
	    tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	    sendMsg(ghd_show_dlg_by_type,tObject)   
	    self:closeAlertDlg()
	end)
end

-- 修改控件内容或者是刷新控件数据
function DlgRechargeTip:updateViews()
	-- body
	
end

--析构方法
function DlgRechargeTip:onDlgRechargeTipDestroy()
	self:onPause()
end

-- 注册消息
function DlgRechargeTip:regMsgs( )
	-- body
end

-- 注销消息
function DlgRechargeTip:unregMsgs(  )
	-- body
end


--暂停方法
function DlgRechargeTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgRechargeTip:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgRechargeTip
