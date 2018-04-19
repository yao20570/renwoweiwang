-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-20 17:7:40 星期五
-- Description: 好友选择对话框
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemFriendSelect = require("app.layer.friends.ItemFriendSelect")

local DlgFriendSelect = class("DlgFriendSelect", function()
	return DlgCommon.new(e_dlg_index.dlgfriendselect)
end)

function DlgFriendSelect:ctor()
	-- body
	self:myInit()

	parseView("dlg_friend_select", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgFriendSelect:myInit(  )
	-- body
	self.tData = {} --英雄数据

	self.nCurIndex = 1

	self.tListData = {}
	self.tFriends 		= {} --好友列表
	self.tcontacts    	= {} --最近联系人

	self.tTitles = {getConvertedStr(6,10566),getConvertedStr(6,10567)}
end

--初始化数据
function DlgFriendSelect:initData()
	--数据处理
	self.tFriends 		= {} --好友列表
	self.tcontacts    	= {} --最近联系人
end

--解析布局回调事件
function DlgFriendSelect:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView,false) --加入内容层
	self:setTitle(getConvertedStr(7, 10067))
	self:initData()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgFriendSelect",handler(self, self.onDestroy))
end

-- 修改控件内容或者是刷新控件数据
function DlgFriendSelect:updateViews(  )
	if not self.pLaySelect then
		self.pLaySelect = self:findViewByName("lay_friend_select")
		self.pLayTab = self:findViewByName("lay_tab")
		self.pLbNullTip = self:findViewByName("lb_NullTip")
		setTextCCColor(self.pLbNullTip, _cc.pwhite)	
		self.pLbNullTip:setString(getConvertedStr(6, 10561), false)	
		--无支线任务时候的默认表情
		self.pImg = MUI.MImage.new("#v2_img_kongwutishi.png", {scale9=false})
		self.pImg:setVisible(false)
		self.pLaySelect:addView(self.pImg)
		self.pImg:setPosition(self.pLbNullTip:getPositionX(), self.pLbNullTip:getPositionY() + self.pLbNullTip:getHeight()/2 + self.pImg:getHeight()/2 + 20)								
	end
	--self:setTitle(string.format(self.tTitles[2],Player:getFriendsData():getRecentConsCnt(),getChatInitParam("nearestListMaxLimit")))
	self:updateListView()	
end

function DlgFriendSelect:updateListView(  )
	-- body
	self.tListData = {}
	self.tListData = Player:getFriendsData():getSendRedPocketFriends()
	self.pLbNullTip:setString(getConvertedStr(6, 10560))	
	local nItemCnt = #self.tListData
	self.pLbNullTip:setVisible(nItemCnt==0)
	self.pImg:setVisible(nItemCnt==0)
	if not self.pListView then
		self.pListView = createNewListView(self.pLayTab)	
		self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
		self.pListView:setItemCount(nItemCnt)
		self.pListView:reload(false)
	else
		self.pListView:setItemCount(nItemCnt)	
		self.pListView:notifyDataSetChange(false)
	end

end

function DlgFriendSelect:onListViewItemCallBack( _index, _pView )
	-- body
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemFriendSelect.new()                        
        pTempView:setViewTouched(false)
        pTempView:setIsPressedNeedScale(false)
    end
    local friendVo = self.tListData[_index]
	pTempView:setCurData(friendVo)	
    return pTempView
end

-- 析构方法
function DlgFriendSelect:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgFriendSelect:regMsgs( )
	-- body
	--注册好友信息刷新消息
	regMsg(self, gud_refresh_friends_msg, handler(self, self.updateViews))	

	--注册红点
	regMsg(self, gud_refresh_sl_chat_red, handler(self, self.updateChatRed))		
end

-- 注销消息
function DlgFriendSelect:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_friends_msg)		

	unregMsg(self, gud_refresh_sl_chat_red)		
end


--暂停方法
function DlgFriendSelect:onPause( )
	-- body
	self:unregMsgs()
	self.nTarPos = nil
end

--继续方法
function DlgFriendSelect:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

function DlgFriendSelect:updateChatRed( msgName,pMsg )
	self:updateListView()
end

return DlgFriendSelect