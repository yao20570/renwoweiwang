-- Author: liangzhaowei
-- Date: 2017-06-07 14:35:03
-- 私聊对像item

local MCommonView = require("app.common.MCommonView")
local ItemChatFriend = class("ItemChatFriend", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemChatFriend:ctor()
	-- body
	self:myInit()

	parseView("item_chat_ask_friend", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemChatFriend",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemChatFriend:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemChatFriend:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	

	self:setupViews()
	self:onResume()
end

--初始化控件
function ItemChatFriend:setupViews( )
	--ly 
	-- self.pLayBtn1 = self:findViewByName("ly_btn_friend")
	-- self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1, TypeCommonBtn.M_BLUE, getConvertedStr(5,10138))
	-- self.pBtn1:onCommonBtnClicked(handler(self,self.onLeftClick))
	self.pLayBtn2 = self:findViewByName("ly_btn_recent")
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2, TypeCommonBtn.M_BLUE, getConvertedStr(5,10139))
	self.pBtn2:onCommonBtnClicked(handler(self,self.onRightClick))   

	self.pLayRed = self:findViewByName("lay_red")


	--lb
	self.pLbAsk = self:findViewByName("lb_ask")
	setTextCCColor(self.pLbAsk,_cc.pwhite)
	self.pLbAsk:setString(getConvertedStr(5, 10137))
	
	self.pEditCon = self:findViewByName("edit_text")
	self.pEditCon:setPlaceHolder(getConvertedStr(5, 10136)) --私聊好友名字
	self.pEditCon:setText("")
end

-- 修改控件内容或者是刷新控件数据
function ItemChatFriend:updateViews(  )
	--刷新红点
	self:refreshReds()
end


--左边点击按钮
function ItemChatFriend:onLeftClick( )
		
end

--右边点击按钮
function ItemChatFriend:onRightClick()
	local tObject = {}				
	tObject.nType = e_dlg_index.dlgfriendselect --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--接收服务端发回的登录回调
function ItemChatFriend:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.loadchatfriend.id then
       		-- dump(__msg.body,"sendChatData")
       		self:updateViews()
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


--析构方法
function ItemChatFriend:onDestroy(  )
	self:onPause()
end

function ItemChatFriend:regMsgs( )
	regMsg(self, gud_refresh_sl_chat_red, handler(self, self.refreshReds))	
end

function ItemChatFriend:unregMsgs( )
	unregMsg(self, gud_refresh_sl_chat_red)
end

function ItemChatFriend:onPause( )
	self:unregMsgs()
end

function ItemChatFriend:onResume( )
	self:updateViews()
	self:regMsgs()
end

function ItemChatFriend:refreshReds( )
	showRedTips(self.pLayRed,1,Player:getAllPrivateChatRed(self.nPlayerId),1)
end


--设置数据 _data
function ItemChatFriend:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--self.pLbN:setString(self.pData.sName or "")
end

--获取私聊名字
function ItemChatFriend:getPrivateChatName()
	return self.pEditCon:getText()
end 

--
function ItemChatFriend:setPlayerInfo( nPlayerId, sName )
	self.nPlayerId = nPlayerId
	self.pEditCon:setText(sName or "")

	--通知聊天窗口主私聊tab的对象记录
	sendMsg(ghd_change_private_chat_player, nPlayerId)
end

return ItemChatFriend