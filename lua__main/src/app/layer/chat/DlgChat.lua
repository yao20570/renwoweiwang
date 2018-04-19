-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-05-22 20:57:35
-- Description: 聊天主界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")
local ChatLayer = require("app.layer.chat.ChatLayer")
local ChatPrivateLayer = require("app.layer.chat.ChatPrivateLayer")
local ItemShowChatNums = require("app.layer.chat.ItemShowChatNums")
local RichText = require("app.common.richview.RichText")
local RichTextEx = require("app.common.richview.RichTextEx")
local BeAttackRedBorder = require("app.layer.world.BeAttackRedBorder")

local DlgChat = class("DlgChat", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgchat)
end)

--打开类型 nChattype
--私聊玩家信息 --tPChatInfo = {
--	nPlayerId = xx, sPlayerName = xxx,
--} 
function DlgChat:ctor(_nChattype, tPChatInfo)
	-- body
	self:myInit()

	self.nChatType = _nChattype
	self.tPChatInfo = tPChatInfo
	self:setTitle(getConvertedStr(5, 10094))
	self:setTitleSize(26)
	parseView("layout_chat_details", handler(self, self.onParseViewCallback))
	

	--注册析构方法
	self:setDestroyHandler("DlgChat",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgChat:myInit()
	self.bIsCostServer = isPChatCostServer()
	self.bIsNewServer = isNewServer()
	if self.bIsNewServer then
		self.tTabDict = {
			[e_lt_type.lm] = 1,
			[e_lt_type.sl] = 2,
		}
		self.tIndexDict = {
			[1] = e_lt_type.lm,
			[2] = e_lt_type.sl,
		}
		self.tTitles = {getConvertedStr(5,10124),getConvertedStr(5,10125)}
	else
		self.tTabDict = {
			[e_lt_type.sj] = 1,
			[e_lt_type.lm] = 2,
			[e_lt_type.sl] = 3,
		}
		self.tIndexDict = {
			[1] = e_lt_type.sj,
			[2] = e_lt_type.lm,
			[3] = e_lt_type.sl,
		}
		self.tTitles = {getConvertedStr(5,10123),getConvertedStr(5,10124),getConvertedStr(5,10125)}
	end
	
	self.nLimitsLv = 2 -- 发言等级
	self.tLimitsMinDis = 2000 --间隔发送时间
	self.nChatType = 1 --聊天类型(默认为世界)
	self.sLastSendStr = "" --最后发送的内容
	self.strTalkName = "" --私聊对象名称
	-- self.nJumpType =  1 --打开聊天框的时候,跳转类型

	self.tShowChatRecord = {} --显示聊天记录
	self.nZorderBeHitNotice = 100
	for i=1,3 do
		self.tShowChatRecord[i] = Player:getChatInfoByType(i)
	end

end

--类型转tab分页下标
function DlgChat:getTabIndexByType( nType )
	return self.tTabDict[nType] or 1
end

--tab分页转类型
function DlgChat:getTypeByTabIndex( nIndex )
	return self.tIndexDict[nIndex]
end

--解析布局回调事件
function DlgChat:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
    self:setupViews()
	self:onResume()

end

--设置数据
--tPChatInfo = {
--	nPlayerId = xx, sPlayerName = xxx,
--}
function DlgChat:setData( _nChattype, tPChatInfo)
	--私聊红点更新
	self:refreshSLReds()

	self.tPChatInfo = tPChatInfo
	if self.nChatType ~= _nChattype then
		self.nChatType = _nChattype
		if self.pTabHost then
			local nIndex = self:getTabIndexByType(self.nChatType)
			self.pTabHost:setDefaultIndex(nIndex)
		end
	else
		--私聊情况要设置对应玩家
		if self.nChatType == e_lt_type.sl then --私聊
			if self.pPrivateChat then
				self.pPrivateChat:setDefaultPChatPlayer(self.tPChatInfo)
				--数据作废
				self.tPChatInfo = nil
			end
		elseif self.nChatType == e_lt_type.sj then --世界
			--移到最下方
			if self.pWorldChat then
				self.pWorldChat:setSVScrollToEnd()
			end
		elseif self.nChatType == e_lt_type.lm then --军团
			--移到最下方
			if self.pCountryChat then
				self.pCountryChat:setSVScrollToEnd()
			end
		end
	end
end

--初始化控件
function DlgChat:setupViews()
	self.pRedLay = self.pView:findViewByName("lay_red")	
	
    -- 检测发送出去的数据有没有问题RichText
    self.pHideRichText = RichTextEx.new({width = 400, autow = true})
    self.pHideRichText:setVisible(false)
    self.pView:addView(self.pHideRichText)

    -- 标签内容层
    self.pLyContent = self.pView:findViewByName("ly_content")

    -- 被攻击提示层
    if not self.pBeAttackLayer then
        self.pBeAttackLayer = BeAttackRedBorder.new()
        self.pBeAttackLayer:setIgnoreOtherHeight(true)
        self.pBeAttackLayer:setContentSize(self.pLayBaseBg:getContentSize())
        self.pBeAttackLayer:requestLayout()
        self.pLayBaseBg:addView(self.pBeAttackLayer, self.nZorderBeHitNotice)
        centerInView(self.pLayBaseBg, self.pBeAttackLayer)
    end

    -- 分页标签
    self.pTabHost = FCommonTabHost.new(self.pLyContent, 1, 1, self.tTitles, handler(self, self.getLayerByKey), 1)

	-- 特意加载了国家和私聊
	for i=#self.tTitles,2, -1 do
		self.pTabHost:setDefaultIndex(i)
	end
    self.bIsTruelyTabHostSel = true --是否真正开始,前面setDefaultIndex都是做缓存

    -- 大于当前切换卡标签个数,默认跳到世界
    local nFirstIndex = self:getTabIndexByType(self.nChatType)
    self.pTabHost:setTabChangedHandler(handler(self, self.onChangeClickTab))
    self.pTabHost:setDefaultIndex(nFirstIndex)
    self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
    self.pLyContent:addView(self.pTabHost, 10)
    centerInView(self.pLyContent, self.pTabHost)

    -- 按钮集
    self.pTabItems = self.pTabHost:getTabItems()

    -- -- 第一次私聊特殊处理
    -- local pItem = self.pTabItems[e_lt_type.sl]
    -- if pItem then
    --     if self.tPChatInfo then
    --         self.nPChatPlayerId = self.tPChatInfo.nPlayerId
    --         showRedTips(pItem:getRedNumLayer(), 1, Player:getAllPrivateChatRed(self.nPChatPlayerId), 2)
    --     else
    --         showRedTips(pItem:getRedNumLayer(), 1, Player:getAllPrivateChatRed(), 2)
    --     end
    -- end

    --关闭回调
    self:setCloseHandler(function (  )
		Player:closePlayerPrivateChat()
    	self:closeOrHideDlg()
    end)
end

--通过key值获取内容层的layer
function DlgChat:getLayerByKey( _sKey, _tKeyTabLt )
	local pLayer = nil

	--下标
	local nIndex = nil
	for i=1,#_tKeyTabLt do
		if _sKey == _tKeyTabLt[i] then
			nIndex = i
			break
		end
	end
	--聊天类型
	local nChatType = self:getTypeByTabIndex(nIndex)
	if nChatType == e_lt_type.sj then
		pLayer = ChatLayer.new(1, nil, self.pTabHost:getCurContentSize())
		pLayer:setCurData(self.tShowChatRecord[1])
		self.pWorldChat = pLayer
	elseif nChatType == e_lt_type.lm then
		pLayer = ChatLayer.new(2, nil, self.pTabHost:getCurContentSize())
		pLayer:setCurData(self.tShowChatRecord[2])
		self.pCountryChat = pLayer
	elseif nChatType == e_lt_type.sl then
		pLayer = ChatPrivateLayer.new(3, nil, self.pTabHost:getCurContentSize())
		self.pPrivateChat = pLayer
	end
	return pLayer
end

--切换回调位置 _key 切换卡名字
function DlgChat:onChangeClickTab( _key, _nType)
	--如果之前是私聊的，且是真正的ClickTab,就设置私聊对象是nil，且记录关闭私聊对象红点记录
	if  self.bIsTruelyTabHostSel and self.nChatType == e_lt_type.sl then
		Player:closePlayerPrivateChat()
	end

	Player:clearTabChatRedCount(self.nChatType)--把切换之前,保留的红点清除掉
	--下标
	local nIndex = nil
	if _key == "tabhost_key_1" then
		nIndex = 1
	elseif _key == "tabhost_key_2" then
		nIndex = 2
	elseif _key == "tabhost_key_3" then
		nIndex = 3
	end

	--聊天类型
	local nChatType = self:getTypeByTabIndex(nIndex)
	if nChatType == e_lt_type.sj then
		self.nChatType = e_lt_type.sj -- 世界
		--移到最下方
		if self.pWorldChat then
			self.pWorldChat:setSVScrollToEnd()
		end
		self:setSendBtnStyle(true)

	elseif nChatType == e_lt_type.lm then
		self.nChatType = e_lt_type.lm -- 国家
		--移到最下方
		if self.pCountryChat then
			self.pCountryChat:setSVScrollToEnd()
		end
		self:setSendBtnStyle(true)
	elseif nChatType == e_lt_type.sl then-- 私聊
		self.nChatType = e_lt_type.sl -- 私聊
	end

	--刷新聊天头像？
	-- local pLayer = self.pTabHost:getTabLayer(_key)
	-- if pLayer then
	-- 	pLayer:refreshChatItem()
	-- end

	Player:clearTabChatRedCount(self.nChatType)--刚切换把之前的红点清除掉

	--如果之前是私聊的，且是真正的ClickTab,就设置私聊对象
	if  self.bIsTruelyTabHostSel and self.nChatType == e_lt_type.sl then
		if self.pPrivateChat then
			self.pPrivateChat:setDefaultPChatPlayer(self.tPChatInfo)
			--数据作废
			self.tPChatInfo = nil
		end
	end
end

-- 修改控件内容或者是刷新控件数据
function DlgChat:updateViews(  )
	-- 为了android特定的输入框，强制提取到分帧前来做
	--输入框内容
	if not self.pEditCon then
		-- --img
		self.pEditCon = self.pView:findViewByName("edit_con") -- -- 内容
		self.pEditCon:setPlaceHolder(getConvertedStr(5, 10131)) --输入框默认内容
	end
	self.pEditCon:setText("")
	local pBaseChat = getChatBaseDataByType(self.nChatType)
	if pBaseChat and pBaseChat.maxchar then
		self.pEditCon:setMaxLength(pBaseChat.maxchar)
	end
	
	--社交按钮(私聊)
	if not b_open_ios_shenpi then
		if not self.pLayBtn1 then
			self.pLayBtn1 = self.pView:findViewByName("lay_btn_sj")
			self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1, TypeCommonBtn.M_BLUE, getConvertedStr(5,10126))
			self.pBtn1:onCommonBtnClicked(handler(self,self.onLeftClick))			
		end
	end

	--发送
	if not self.pLayBtn2 then
		self.pLayBtn2 = self.pView:findViewByName("lay_btn_send")
		self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2, TypeCommonBtn.M_BLUE, getConvertedStr(5,10127))
		self.pBtn2:onCommonBtnClicked(handler(self,self.onRightClick))
		-- 特定的强制触摸标识（为了输入法缩回时坐标变化而定的）
		self.pBtn2.pContainer.__ftc = true
		self.bIsChatFree = true
	end
	--表情
	if not self.pImgEmo then
		self.pImgEmo = self.pView:findViewByName("img_emo")
		self.pImgEmo:setViewTouched(true)
		self.pImgEmo:setIsPressedNeedScale(false)
		self.pImgEmo:setIsPressedNeedColor(false)
		self.pImgEmo:onMViewClicked(handler(self, self.onEmoClick))
	end

	--显示聊天新增条目数
	self.pShowNumsView = ItemShowChatNums.new()
	self.pShowNumsView:setVisible(false)
	self.pShowNumsView:setPosition(530, 10)
	self.pLyContent:addView(self.pShowNumsView,99)
	
	self:refreshNewFriendRed()
	-- --屏蔽好友按钮
	-- if not self.pLayEdit then				
	-- 	self.pBtn1:setVisible(false)
	-- end
end

--表情点击按钮
function DlgChat:onEmoClick( )
	local DlgFlow = require("app.common.dialog.DlgFlow")

	local pDlg,bNew = getDlgByType(e_dlg_index.chatemo)
	if(not pDlg) then
		pDlg = DlgFlow.new(e_dlg_index.chatemo)
	end
	local DlgChatEmo = require("app.layer.chat.DlgChatEmo")
	local pChildView = DlgChatEmo.new()
	pDlg:showChildView(nil, pChildView)
	pChildView:setPosition((self:getWidth() - pChildView:getWidth())/2, 80)
	UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
	pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
end

--左边点击按钮
function DlgChat:onLeftClick( )
	local tObject = {}
	tObject.nType = e_dlg_index.dlgfriends --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

--右边点击按钮
function DlgChat:onRightClick()
-- 发言的内容
	local txt = self.pEditCon:getText()
	-- 需要等级限制
	local bGm = false
	if(txt and (string.find(txt, "*add"))) then
		bGm = true
	end


	if not false then
		if(txt and (string.find(txt, "*setlv"))) then
			bGm = true
		end
	end


	local pBaseChat = getChatBaseDataByType(self.nChatType)
	if pBaseChat and pBaseChat.needlevel then
		self.nLimitsLv =  pBaseChat.needlevel
	end


	if(not bGm) then
		if(Player.baseInfos.nLv < self.nLimitsLv) then
			TOAST(string.format(getConvertedStr(5, 10128), self.nLimitsLv))
			return
		end
	end
	-- 发言的时间间隔
	local fD = getSystemTime(false) - Player.fLastSendChatTime


	if(fD <= self.tLimitsMinDis and txt ~= ""
		and self.sLastSendStr == txt) then
		TOAST(getConvertedStr(5, 10129))
		return
	end
	local playerName = ""
	local content = string.gsub(txt, " ", "")
	-- if(self.nChatType == 3) then -- 如果是私聊
	-- 	-- playerName = self.pEditName:getText() or ""
	-- 	-- if(playerName == "") then
	-- 	-- 	TOAST(getConvertedStr(5, 10130))
	-- 	-- 	return
	-- 	-- end

	-- 	if (not self.strTalkName) or self.strTalkName == "" then
	-- 		TOAST(getConvertedStr(5, 10133))--提示输入私聊对象
	-- 		return
	-- 	end

	-- end
	content = content or ""
	if #content <= 0  then
		TOAST(getConvertedStr(5, 10131))
		return 
	end
	-- 记录最后的时间和内容
	Player.fLastSendChatTime = getSystemTime(false)
	self.sLastSendStr = txt


	local sPlayerName = nil
	if(self.nChatType == e_lt_type.sj) then-- 世界

	elseif self.nChatType == e_lt_type.lm then-- 军团

	elseif self.nChatType == e_lt_type.sl then-- 私聊
		local pChatLayer = self.pPrivateChat

		if pChatLayer then
			sPlayerName = pChatLayer:getPrivateChatName()
			local nPlayerId = Player:getCurrPChatId()  --获取当前私聊的对象id
			local tFriendData = Player:getFriendsData():getRecentFriendById(nPlayerId)

			if tFriendData and tFriendData.bIsRb then   --机器人的话不用真的发出去
				--官职
			-- 	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	  --  			local nOfficial = nil
	  --  			if tCountryDatavo then
	  --  				nOfficial = tCountryDatavo.nOfficial
	  --  			end
	  --  			--头像id
	  --  			local nHeadId = nil
	  --  			local nHeadBox = nil
	  --  			local nHeadTitle = nil
	  --  			local tAvatarVo = Player:getPlayerInfo():getActorVo()
	  --  			if tAvatarVo then
	  --  				nHeadId = tAvatarVo.sI
	  --  				nHeadBox= tAvatarVo.sB
	  --  				nHeadTitle= tAvatarVo.sT
	  --  			end
			-- 	--模拟消息数据
			-- 	local tData = {
			-- 		nAccperId = 3,
			-- 		sid = Player:getPlayerInfo().pid, 
			-- 		an = tFriendData.sName,
			-- 		ie = Player:getPlayerInfo().nInfluence,
			-- 		bt = nOfficial,
			-- 		sn = Player:getPlayerInfo().sName,
			-- 		vip = Player:getPlayerInfo().nVip,
			-- 		aid = {3}, --	List<Integer>	显示渠道
			-- 		cnt = self.sLastSendStr, --cnt String	内容
			-- 		st = getSystemTime(), --st	Long	消息时间
			-- 		tmsg = 1,
			-- 		-- pos = __msg.body.pos, --pos String	地理位置,
			-- 		s = Player:getWorldData():getMyCityBlockId(),
			-- 		ac = nHeadId,
			-- 		lv = Player:getPlayerInfo().nLv,
			-- 		box = nHeadBox,
			-- 		tit = nHeadTitle,
			-- 		ad = tFriendData.sTid
			-- 	}
			-- 	--dump(tData, "tData=====", 100)
			-- 	Player:addChatInfoToTmp(tData,false)
			-- 	self:updateViews()
			-- pChatLayer:setFriendIconTop()
				SocketManager:sendMsg("playWithRobot", {tFriendData.sTid, 8,self.sLastSendStr}, handler(self,self.onChatWithRb))

				return 
		else
			pChatLayer:setFriendIconTop()
		end
			
		end
		if (not sPlayerName) or sPlayerName == "" then
			TOAST(getConvertedStr(5, 10133))--提示输入私聊对象
			return
		end
	end

	--本地先容错，以防发出去害死其他人
    --用来验证发出去的数据富文本能否正确解析
	if self.pHideRichText then
		local tStr = getTextColorByConfigure(self.sLastSendStr)
		-- tStr = removeSysEmoInTable(tStr)
		tStr = getTableParseEmo(tStr)
		self.pHideRichText:setString(tStr)
	end

	--供策划跳转
	if N_PACK_MODE == 1000 or N_PACK_MODE == 1050 then
		local nBeginIndex, nLastIndex = string.find(self.sLastSendStr, "*worldpos ")
		if nBeginIndex then
			local sPosStr = string.sub(self.sLastSendStr, nLastIndex + 1, string.len(self.sLastSendStr))
			local tPos = luaSplit(sPosStr, " ")
			local nX = tonumber(tPos[1])
			local nY = tonumber(tPos[2])
			if nX and nY then
				sendMsg(ghd_world_location_dotpos_gm_msg, {nX = nX, nY = nY, isClick = true})
				closeDlgByType(e_dlg_index.dlgchat)
			end
			return
		end
	end

	--发送消息
	local function sendReq()

		SocketManager:sendMsg("sendChatData", {self.nChatType, sPlayerName ,self.sLastSendStr},handler(self, self.onGetDataFunc))
	end
	if self.bIsCostServer then
		if self.bIsChatFree then
			sendReq()
		else
			--购买
			local nCost = tonumber(getChatInitParam("chatcost"))
			local strTips = {
			    {color=_cc.pwhite,text=getConvertedStr(3, 10738)},
			    {color=_cc.yellow,text=string.format(getConvertedStr(3, 10281),nCost)},
			}
			--展示购买对话框
			showBuyDlg(strTips,nCost,function (  )
			    sendReq()
			end, 1, nil ,nil ,{nTipType = 2})
		end
	else
		sendReq()
	end
end

--添加聊天表情
function DlgChat:onInputEmo( sMsgName, pMsgObj)
	if pMsgObj then
		local sStr = self.pEditCon:getText()
		self.pEditCon:setText(sStr .. pMsgObj)
	end
end

--接收服务端发回的登录回调
function DlgChat:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.sendChatData.id then
       		if not gIsNull(self.updateViews) then
				self:updateViews()
			end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--显示隐藏的聊天数目
function DlgChat:showHideChat( sMsgName, pMsgObj)
	if pMsgObj and pMsgObj.nCount then
		--容错
		if not tolua.isnull(self.pShowNumsView) then
			if pMsgObj.nCount > 0 then
				self.pShowNumsView:setCurData(pMsgObj.nCount)
				self.pShowNumsView:setVisible(true)
			else
				self.pShowNumsView:setVisible(false)
			end
		end
	end
end

--刷新红点
function DlgChat:refreshReds( msgName,pMsg )
	if pMsg then
		if self.pTabItems then --容错
			for k,v in pairs(self.pTabItems) do
				local nChatType = self:getTypeByTabIndex(k)
				--刷当前tab
				if nChatType == self.nChatType and nChatType ~= e_lt_type.sl then
					showRedTips(v:getRedNumLayer(),1,0,2)
				else
					--刷指定Tab
					if nChatType == pMsg.nType and nChatType ~= e_lt_type.sl then
						showRedTips(v:getRedNumLayer(),1,Player:getTabChatRedCount(nChatType),2)
					end
				end
			end
		end
	end
end

--刷新私聊红点
function DlgChat:refreshSLReds( msgName, pMsg)
	if self.pTabItems then
		local nIndex = self:getTabIndexByType(e_lt_type.sl)
		local pTab = self.pTabItems[nIndex]
		if pTab then
			if self.nChatType == e_lt_type.sl then --打开状态记录非当前目标的红点
				showRedTips(pTab:getRedNumLayer(),1,Player:getAllPrivateChatRed(Player:getCurrPChatId()),2)
			else --关闭状态记录所有红点目标
				showRedTips(pTab:getRedNumLayer(),1,Player:getAllPrivateChatRed(),2)
			end
		end
		if self.pPrivateChat then
			self.pPrivateChat:refreshFriends()		
		end
	end
end

--
function DlgChat:onChangePChatPlayer( msgName, pMsg)
	self:refreshSLReds()
end


function DlgChat:refreshNewFriendRed(  )
	-- body
	-- if not self.pRedLay then
	-- 	self.pRedLay = self.pView:findViewByName("lay_red")		
	-- end
	showRedTips(self.pRedLay, 0, Player:getFriendsData():getNewFriendCnt() + Player:getFriendsData():getVitRedCnt())
end

--私聊按钮更新监听
function DlgChat:onPChatSendBtnChange( sMsgName, bIsFree )
	if self.bIsCostServer then
		if not self.pBtn2 then
			return
		end
		if self.nChatType ~= e_lt_type.sl then-- 私聊
			return
		end
		self:setSendBtnStyle(bIsFree)
	end
end

--发送按钮更新
function DlgChat:setSendBtnStyle( bIsFree )
	if self.bIsCostServer then
		if not self.pBtn2 then
			return
		end
	
		if self.bIsChatFree ~= bIsFree then
			self.bIsChatFree = bIsFree
			if self.bIsChatFree then
				self.pBtn2:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(5,10127))
			else
				self.pBtn2:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3,10735))
			end
		end
	end
end

function DlgChat:onChatWithRb( __msg,__oldMsg )
	-- body
	if __msg.head.state == SocketErrorType.success	then
		if not gIsNull(self.updateViews) then
			self:updateViews()
		end
		-- local SPlayerData = require("app.layer.rank.SPlayerData")
		-- if __msg.body.pm then
		-- 	local temp = SPlayerData.new()
		-- 	__msg.body.pm.rb = 1    --自己给他加上机器人标志
		-- 	temp:refreshDatasByService(__msg.body.pm)
		-- 	--刷新聊天头像数据				
		-- 	-- Player:recordPlayerCardInfo(temp)
		-- 	-- Player:getFriendsData():addRecentRecord(temp.nID, temp, 1, false)
		-- 	if not b_open_ios_shenpi then
		-- 		local tObj = {}
		-- 		tObj.tplayerinfo = temp
		-- 		tObj.tChatData = self.pData
		-- 		showRankPlayerInfo(tObj)						
		-- 	end
		-- end
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end			

end

-- 析构方法
function DlgChat:onDestroy(  )
	-- body
	nCollectCnt = 2
	self:onPause()
end

-- 注册消息
function DlgChat:regMsgs( )
	-- body

	--注册显示已经隐藏的聊天数据
	regMsg(self, gud_refresh_hide_chat_num, handler(self, self.showHideChat))
	
	--注册刷新红点方法
	regMsg(self, gud_refresh_chat_red, handler(self, self.refreshReds))	

	--注册刷新私聊红点方法
	regMsg(self, gud_refresh_sl_chat_red, handler(self, self.refreshSLReds))

	--注册刷新私聊红点
	regMsg(self, ghd_change_private_chat_player, handler(self, self.onChangePChatPlayer))

	--注册新好友红点刷新
	regMsg(self, ghd_item_home_menu_red_msg, handler(self, self.refreshNewFriendRed))

	--聊天表情
	regMsg(self, ghd_input_chat_emo, handler(self, self.onInputEmo))

	--私聊天发送按钮更改
	regMsg(self, ghd_pchat_send_btn_change, handler(self, self.onPChatSendBtnChange))
end

-- 注销消息
function DlgChat:unregMsgs(  )
	-- body
	--注销显示已经隐藏的聊天数据
	unregMsg(self, gud_refresh_hide_chat_num)	

	unregMsg(self, gud_refresh_chat_red)

	unregMsg(self, gud_refresh_sl_chat_red)	

	unregMsg(self, ghd_change_private_chat_player)	

	unregMsg(self, ghd_item_home_menu_red_msg)

	unregMsg(self, ghd_input_chat_emo)

	unregMsg(self, ghd_pchat_send_btn_change)
end


--暂停方法
function DlgChat:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgChat:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end


return DlgChat