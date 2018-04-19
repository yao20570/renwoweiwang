-- Author: liangzhaowei
-- Date: 2017-06-07 17:49:01
-- 使用世界喇叭对话框


local DlgAlert = require("app.common.dialog.DlgAlert")
local MRichLabel = require("app.common.richview.MRichLabel")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgWorldLaba = class("DlgWorldLaba", function ()
	return DlgAlert.new(e_dlg_index.worldlaba)
end)

--构造
function DlgWorldLaba:ctor()
	-- body
	self:myInit()
	parseView("layout_world_laba", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgWorldLaba:myInit()
	-- body
	local tparam = getChatHornParam(1)
	self.nwordmax = tparam.limitchar or 0
end
  
--解析布局回调事件
function DlgWorldLaba:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgWorldLaba",handler(self, self.onDestroy))
end

--初始化控件
function DlgWorldLaba:setupViews()
	-- body
	--设置右边按钮样式
	-- self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	self:setRightBtnText(getConvertedStr(5, 10127))

	--设置标题
	self:setTitle(getConvertedStr(5,10145))

	--输入框
	self.pLayEdit = self:findViewByName("lay_edit_con")
	self.pEditCon = addCoupleLineEdit(self.pLayEdit, {gap=5})
	self.pEditCon:setPlaceHolder(string.format(getConvertedStr(5, 10146), self.nwordmax)) --输入框默认内容
	self.pEditCon:setText("")
	self.pEditCon:setMaxLength(50)
	self.pEditCon:registerScriptEditBoxHandler(handler(self, self.onContentEdit))
	--设置右键按钮点击事件
	self:setRightHandler(handler(self, self.onRightClick))
	--默认背景隐藏
	self:setContentBgTransparent()
end

-- 修改控件内容或者是刷新控件数据
function DlgWorldLaba:updateViews()
	-- body

end

--析构方法
function DlgWorldLaba:onDestroy()

end

-- 注册消息
function DlgWorldLaba:regMsgs( )
	-- body
end

-- 注销消息
function DlgWorldLaba:unregMsgs(  )
	-- body
end


--暂停方法
function DlgWorldLaba:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgWorldLaba:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

function DlgWorldLaba:onContentEdit( eventType )
	-- body
	local sInput = ""
	if eventType == "began" then
		-- sInput = self.pEditCon:getText()
    elseif eventType == "ended" then
		-- sInput = self.pEditCon:getText()
    elseif eventType == "changed" then
		sInput = self.pEditCon:getText()
		local nCurNum = getStringWordNum(sInput)
		if nCurNum <= self.nwordmax then
			self.pEditCon:setText(sInput)
		end		
    elseif eventType == "return" then

    end 
end

--右边按钮点击事件回调
function DlgWorldLaba:onRightClick( pView )
	local txt = self.pEditCon:getText()

	if txt == "" then
		TOAST(getConvertedStr(5, 10147))
		return
	end
	--print("getStringWordNum(txt)=", getStringWordNum(txt))
    SocketManager:sendMsg("useWorldLaba", {1,txt}, handler(self, self.onGetDataFunc))

end

--接收服务端发回的登录回调
function DlgWorldLaba:onGetDataFunc( __msg )
	--dump(__msg.body)
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.useWorldLaba.id then
        	closeDlgByType(e_dlg_index.worldlaba, false)
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


return DlgWorldLaba
