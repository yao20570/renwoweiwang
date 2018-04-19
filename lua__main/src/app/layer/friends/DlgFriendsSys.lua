-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-14 15:12:23 星期六
-- Description: 好友系统主界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemFriend = require("app.layer.friends.ItemFriend")
local DlgFriendsSys = class("DlgFriendsSys", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgfriends)
end)

function DlgFriendsSys:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_friends_sys", handler(self, self.onParseViewCallback))
end

function DlgFriendsSys:myInit(  )
	-- body
	self.nCurIndex = nil
	self.tListData = {}
	self.nNewFriend = 0

	self.bIsAdd = false
	self.bIsEnc = false
	self.bisGet = false

end

--解析布局回调事件
function DlgFriendsSys:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgFriendsSys",handler(self, self.onDlgFriendsSysDestroy))
end

function DlgFriendsSys:setupViews(  )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10542))	

	self.pLayRoot = self:findViewByName("lay_def")
	local layTop = self:findViewByName("lay_top")
	self.pLayTab = self:findViewByName("lay_tab")				
	self.pLbNullTip = self:findViewByName("lb_NullTip")
    self.pLbNullTip:setIgnoreOtherHeight(true)
    centerInView(self.pLbNullTip:getParent(), self.pLbNullTip)
	setTextCCColor(self.pLbNullTip, _cc.pwhite)			
	self.pImg = MUI.MImage.new("#v1_img_biaoqing.png", {scale9=false})
	self.pImg:setVisible(false)
    self.pImg:setIgnoreOtherHeight(true)
	self.pImg:setPosition(self.pLbNullTip:getPositionX(), self.pLbNullTip:getPositionY() + self.pLbNullTip:getHeight()/2 + self.pImg:getHeight()/2 + 20)	
	self.pLbNullTip:getParent():addView(self.pImg)		
	self.tTitles = {
		getConvertedStr(6, 10543),
		getConvertedStr(6, 10544),
		getConvertedStr(6, 10545),
	}
			
	self.pTComTabHost = TCommonTabHost.new(layTop,1,1,self.tTitles,handler(self, self.onIndexSelected))
	layTop:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()

	--按钮集
	self.pTabItems = self.pTComTabHost:getTabItems()							

	
end

--控件刷新
function DlgFriendsSys:updateViews(  )
	local pTabItem = self.pTabItems[2]--体力红点及时刷新
	if pTabItem then --报告
		local nNotReadNum = Player:getFriendsData():getVitRedCnt()
		showRedTips(pTabItem:getRedNumLayer(), 1, nNotReadNum, 2)			
	end
	self.nNewFriend = Player:getFriendsData():getNewFriendCnt()
	self.pTComTabHost:setDefaultIndex(self.nCurIndex)	
	
	self:updateListView()
	self:showBottomLayer()	
end

--下标选择回调事件
function DlgFriendsSys:onIndexSelected( _index )
	if self.nCurIndex == 1 and self.nCurIndex ~= _index then
		Player:getFriendsData():clearAllNew()
	end
	self.nCurIndex = _index	
	self:updateListView()
	self:showBottomLayer()
end

function DlgFriendsSys:showBottomLayer(  )
	-- body
	if not self.pLbFriendCnt then
		self.pLbFriendCnt = self:findViewByName("lb_friend_cnt") 
		self.pLbEnc = self:findViewByName("lb_encourage")
		self.pLbEnc:setVisible(false)
		self.pLbVit = self:findViewByName("lb_vit")

		self.pLayBot1 = self:findViewByName("lay_bot_1")
		self.pLayInput = self:findViewByName("lay_input")
		self.pTxtField = self:findViewByName("txt_field")
		self.pTxtField:registerScriptEditBoxHandler(handler(self, self.onContentPlayerName))
		self.pTxtField:setPlaceHolder(getConvertedStr(6, 10570))
		self.pLayAddF = self:findViewByName("lay_btn_addf")
		self.pBtnAddF = getCommonButtonOfContainer(self.pLayAddF, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10546))--添加好友
		self.pBtnAddF:onCommonBtnClicked(handler(self, self.onAddFriends))
		self.pLayOneKey = self:findViewByName("lay_btn_onekey")
		self.pBtnOneKey = getCommonButtonOfContainer(self.pLayOneKey, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10547))--一键鼓舞
		self.pBtnOneKey:onCommonBtnClicked(handler(self, self.onOneKeyEncou))

		self.pLayBot2 = self:findViewByName("lay_bot_2")
		self.pLayBtnGet = self:findViewByName("lay_get")
		self.pBtnGet = getCommonButtonOfContainer(self.pLayBtnGet, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10548))--一键获取
		self.pBtnGet:onCommonBtnClicked(handler(self, self.onGetVit))
	end
	self.pBtnOneKey:setBtnEnable(Player:getFriendsData():isHadEncFriend()) 
	self.pBtnGet:setBtnEnable(Player:getFriendsData():getVitRedCnt() > 0)
	--好友数刷新
	local tStr1 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10562)},
		{color=_cc.white, text=Player:getFriendsData():getFriendsCnt().."/"..getChatInitParam("friendNum")},
	}
	self.pLbFriendCnt:setString(tStr1, false)

	--鼓舞上限

	-- local tStr2 = {
	-- 	{color=_cc.pwhite, text=getConvertedStr(6, 10563)},
	-- 	{color=_cc.white, text=Player:getFriendsData():getEncourageCnt().."/"..getChatInitParam("sendPowerMaxLimit")},
	-- }
	-- self.pLbEnc:setString(tStr2, false)

	--体力或者黑名单刷新
	if self.nCurIndex == 2 then
		local nVit = tonumber(getChatInitParam("sendPowerOnce") or 0)
		local nCnt = tonumber(getChatInitParam("getPowerMaxLimit") or 0)
		local nVitMax = nVit*nCnt
		local tStr = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10564)},
			{color=_cc.white, text=(Player:getFriendsData():getHadVitCnt()*nVit).."/"..nVitMax},
		}
		self.pLbVit:setString(tStr, false)
	elseif self.nCurIndex == 3 then
		self.pLbVit:setString(getConvertedStr(6, 10589), false)
		setTextCCColor(self.pLbVit, _cc.pwhite)
	end


	if self.nCurIndex == 1 then--好友列表
		self.pLbFriendCnt:setVisible(true)	
		self.pLbVit:setVisible(false)
		self.pLayBot1:setVisible(true)
		self.pLayBot2:setVisible(false)
	elseif self.nCurIndex == 2 then--获取体力
		self.pLbFriendCnt:setVisible(false)
		self.pLbVit:setVisible(true)
		self.pLayBot1:setVisible(false)
		self.pLayBot2:setVisible(true)		
	elseif self.nCurIndex == 3 then--屏蔽列表
		self.pLbFriendCnt:setVisible(false)
		self.pLbVit:setVisible(true)
		self.pLayBot1:setVisible(false)
		self.pLayBot2:setVisible(false)		
	end
end
--刷新红点数量
function DlgFriendsSys:showNewFriendRed( _num )
	-- body
	local pTabItem = self.pTabItems[1]--新好友红点
	if pTabItem then --报告
		-- local nNotReadNum = Player:getFriendsData():getNewFriendCnt()
		showRedTips(pTabItem:getRedNumLayer(), 1, _num, 2)		
	end			
end

function DlgFriendsSys:updateListView()
	-- body
	self.tListData = {}
	if self.nCurIndex == 1 then--好友列表		
		self.tListData = Player:getFriendsData():getFriends()
		self.pLbNullTip:setString(getConvertedStr(6, 10559))
		self.nNewFriend = 0
	elseif self.nCurIndex == 2 then--获取体力
		self.tListData = Player:getFriendsData():getVitFriends()
		self.pLbNullTip:setString(getConvertedStr(6, 10560))
	elseif self.nCurIndex == 3 then--黑名单
		self.tListData = Player:getFriendsData():getBlacks()
		self.pLbNullTip:setString(getConvertedStr(6, 10561))
	end
	local nItemCnt = #self.tListData
	self.pLbNullTip:setVisible(nItemCnt==0)
	self.pImg:setVisible(nItemCnt==0)
	if not self.pListView then
		self.playList = self:findViewByName("lay_list")
		self.pListView = createNewListView(self.playList)	
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
		self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
		self.pListView:setItemCount(nItemCnt)
		self.pListView:reload(true)
	else
		self.pListView:setItemCount(nItemCnt)	
		self.pListView:notifyDataSetChange(true)
	end
	self:showNewFriendRed(self.nNewFriend)
end

--析构方法
function DlgFriendsSys:onDlgFriendsSysDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgFriendsSys:regMsgs(  )
	-- body
	--注册好友信息刷新消息
	regMsg(self, gud_refresh_friends_msg, handler(self, self.updateViews))
end
--注销消息
function DlgFriendsSys:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_friends_msg)	
end

--暂停方法
function DlgFriendsSys:onPause( )
	-- body
	self:unregMsgs()
	Player:getFriendsData():clearAllNew()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgFriendsSys:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()

end

function DlgFriendsSys:onListViewItemCallBack( _index, _pView )
	-- body
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemFriend.new()                        
        pTempView:setViewTouched(false)
        pTempView:setIsPressedNeedScale(false)
    end
    local friendVo = self.tListData[_index]
	pTempView:setCurData(friendVo, self.nCurIndex)		
	pTempView:setIconNew()
    return pTempView	
end

--添加好友
function DlgFriendsSys:onAddFriends(  )
	-- body
	print("添加好友")	
	if self.bIsAdd == true then
		return
	end
	self.bIsAdd = true
	local sName = self.pTxtField:getText()
	--local nId = tonumber(self.pTxtField:getText() or 0)
	SocketManager:sendMsg("reqAddFriend", {nil, sName}, handler(self, self.onGetDataFunc))--添加好友			
end

--一键鼓舞
function DlgFriendsSys:onOneKeyEncou(  )
	-- body
	print("一键鼓舞")	
	if self.bIsEnc == true then
		return
	end
	self.bIsEnc = true
	local bHaveRb = false
	for i = 1,#self.tListData do
       	if self.tListData[i].bIsRb then
       		SocketManager:sendMsg("playWithRobot", {self.tListData[i].sTid, 8}, handler(self,self.onGetDataFunc))
	       	self.tListData[i].nCanGet = 1
	       	bHaveRb = true
	    end
	end
	if bHaveRb then
		sendMsg(gud_refresh_friends_msg)
	end

	SocketManager:sendMsg("giveFriendVit", {nil}, handler(self, self.onGetDataFunc))--添加好友			
end

--一键获取体力
function DlgFriendsSys:onGetVit(  )
	-- body
	print("一键获取体力")
	if Player:getFriendsData():isGetVitFull() then
		TOAST(getConvertedStr(6, 10581))
		return
	end
	local nVit = tonumber(getChatInitParam("sendPowerOnce") or 0)
	if getIsOverMaxEnergy(nVit*Player:getFriendsData():getVitRedCnt()) then
		return
	end	
	if self.bisGet == true then
		return
	end
	self.bisGet = true

	SocketManager:sendMsg("getFriendVit", {nil}, handler(self, self.onGetDataFunc))--添加好友				
end

function DlgFriendsSys:onContentPlayerName( eventType )
	-- body
	local sInput = ""
	if eventType == "began" then
		self.pTxtField:setText("")
    elseif eventType == "ended" then
    elseif eventType == "changed" then
    elseif eventType == "return" then	
    end	
end

--接收服务端发回的登录回调
function DlgFriendsSys:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
    	if __msg.head.type == MsgType.reqAddFriend.id then--添加好友
    		
		elseif __msg.head.type == MsgType.getFriendVit.id then--已经领取体力
			
       	elseif __msg.head.type == MsgType.giveFriendVit.id then--一键鼓舞
   --     		for i = 1,#self.tListData do
   --     			if self.tListData[i].bIsRb then
	  --      			self.tListData[i].nCanGet = 1
	  --      		end
			-- end
       		TOAST(getConvertedStr(6, 10584))
       		
        end
    else
        --弹出错误提示语
        --TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
    if self.bIsAdd then
    	self.bIsAdd = false
	end
	if self.bisGet then
		self.bisGet = false
	end
    if self.bIsEnc then
    	self.bIsEnc = false
    end    
end
return DlgFriendsSys