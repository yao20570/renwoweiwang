-- Author: maheng
-- Date: 2017-11-21 11:23:45
-- 私聊

local f_up_div = 2 -- 上边距离
local f_left_div = 20 -- 左边具体
local f_down_div = 2 -- 下边距离
local f_right_div = 20 -- 右边边具体
local f_min_height = 80 -- 每行最低高度
local f_top_time_height = 35 -- 顶部时间需要显示的高度
local n_item_flew_h = 20 --整个item的偏移量 
local INITCHATMAXNUM = 8

local RICHTEXTTAG = 4981 --文本view的tag
local MCommonView = require("app.common.MCommonView")
-- local ItemChat = require("app.layer.chat.ItemChat")
local ItemPrivateChat = require("app.layer.chat.ItemPrivateChat")
local ItemPrivateFriendChat = require("app.layer.chat.ItemPrivateFriendChat")

local ChatPrivateLayer = class("ChatPrivateLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

--创建函数
--从哪条消息打开的
--tPChatInfo = {
-- 	nPlayerId,
-- 	sPlayerName,
-- }
--从好友打开
function ChatPrivateLayer:ctor(_type, tPChatInfo, pSize)
	self.pSize = pSize
	-- body
	self.nChatType = _type or 1
	self:myInit()
	self.nPlayerId = nil
	self.sPlayerName = nil
	--dump(tPChatInfo, 'tPChatInfo', 100)
	self.tPChatInfo = tPChatInfo or nil
	-- if tPChatInfo then
	-- 	self.nPlayerId = tPChatInfo.nPlayerId
	-- 	self.sPlayerName = tPChatInfo.sPlayerName
	-- end

	
	--获取聊天数据最大数目
	-- self.nMaxDataNum = MAX_SHOW_CHAT_COUNT[self.nChatType]

	parseView("layout_chat_private_layer", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ChatPrivateLayer",handler(self, self.onDestroy))

	--刷新消息
	regMsg(self, ghd_refresh_chat, handler(self, self.addChatItem))
	regMsg(self, gud_refresh_chat, handler(self, self.addChatItem))

	--注册撤回消息刷新
	regMsg(self, ghd_refresh_recall_chat, handler(self, self.removeChatItem))

	--刷新消息
	regMsg(self, ghd_chat_icon_refresh_msg, handler(self, self.refreshChatIcons))

end

--初始化参数
function ChatPrivateLayer:myInit()
	self.pData = {} --数据
	self.tShowData = {} --显示聊天数据
	self.nLastIndex = 0 --最后添加的下标
	self.nLastChatTime = 0 --最后聊天数据的聊天时间
	self.nMaxDataNum = MAX_SHOW_CHAT_COUNT[self.nChatType] --聊天数据最大数目
	self.nMaxItemNum = MAX_SHOW_CHAT_COUNT[self.nChatType] --聊天item最大数目

	self.bAddChatItem = false --是否在添加聊天item中
	self.bFreshChatItem = false --是否在刷新聊天item中

	self.nSlideLoadItemNums = 20 --每次滑动增加条目数
	-- self.nNowTopSlideNums = 1 --现在滑动到的位置
	self.nFlewItemNums = 0 --item偏移位置


	self.tScreenData = {} --存在屏幕当前数据
	self.nNeedRefreshIndex = 0 --需要刷新的数据下标


	self.tShowChatItem = {} --显示itemlayer
	self.tFreeChatItem = {} --空余item列表

	self.tRecordChatData = {} --获取聊天记录

	self.nAddItemCount = 0 --需要显示添加的聊天条目数

	self.bSlideDown = false -- 是否滑到底部

	self.bShowTips = true --是否可以显示提示(最顶)

	self.tFriendsData = {}
end

--刷新数据
function ChatPrivateLayer:initChatItem( )
	--获取聊天记录
	self.tRecordChatData = nil
	self.tRecordChatData = self:getChatRecord()	
	--聊天数量
	local nTableNums =  table.nums(self.tRecordChatData) 	
	
	--第一次初始化只需要 INITCHATMAXNUM 固定的聊天信息条数
	--需要刷新的数据
	self.tScreenData = {}
	local nIndex = 0
	for i=nTableNums,1,-1 do
		if self.tRecordChatData and self.tRecordChatData[i] and (nIndex < INITCHATMAXNUM) then
			table.insert(self.tScreenData,self.tRecordChatData[i])
			nIndex = nIndex +1
		end
	end

	--排序
	if table.nums(self.tScreenData)> 0 then
		table.sort(self.tScreenData,function (a,b)
            return a.nSt < b.nSt
		end)
	end

	self.bSlideDown = true

	--显示完8条 znftodo 因为一开始显示30条会卡，所以先显示8条不分帧，后面显示28条分帧
	local function firstCallBack( )
		--之后的第9条下标
		local nPrevIndex = nTableNums - nIndex
		--当前数据的下标是8条下标
		local nCurrIndex = nIndex
		--最后显示的下标
		local nEndIndex = self.nMaxItemNum - nIndex
		--显示的数据
		local tScreenData = {}
		for i=nPrevIndex,1,-1 do
			if self.tRecordChatData and self.tRecordChatData[i] and (nCurrIndex <= self.nMaxItemNum) then
				table.insert(tScreenData,self.tRecordChatData[i])
				nCurrIndex = nCurrIndex +1
			end
		end
		--数量>0
		if #tScreenData > 0 then
			self.tScreenData = tScreenData
			--时间排序
			if table.nums(self.tScreenData)> 0 then
				table.sort(self.tScreenData,function (a,b)
		            return a.nSt < b.nSt
				end)
			end
			--再进行分帧处理
			self:scheduleOnceAddTnoly(self.tScreenData, 1, false, false, nil, true)
		else
			--********************************************
			--临时处理点击头像切换联系人会出现内容没显示 
			local nY = self.pSv:getHeight()-self.pSv.scrollNode:getHeight()
			if nY > 0 then
				self.pSv:scrollTo(0,self.pSv:getHeight()-self.pSv.scrollNode:getHeight())
			else
				self.pSv:scrollTo(0,0)
			end
		end
	end
	self:scheduleOnceAddTnoly(self.tScreenData,2,true,true, firstCallBack)
end

--解析布局回调事件
function ChatPrivateLayer:onParseViewCallback( pView )

	self:setContentSize(self.pSize.width, self.pSize.height)
	self:addView(pView)
	centerInView(self, pView)

	--ly   
	self.pLayRoot = self:findViewByName("layout_chat_private_layer")
	self.pLyFriendBg= self:findViewByName("lay_friend_list_bg")      	
	self.pLyChat = self:findViewByName("lay_chat_detail") 
	self.pLayTip = self:findViewByName("lay_tip")   
	self.pLbTip = self:findViewByName("lb_tip")  	
	self.pLbTip:setString(getConvertedStr(6, 10629))
	self.pLayLeft = self:findViewByName("lay_fill1")
	self.pLyListBot = self:findViewByName("lay_list_bot") 
	self.pLyListTop = self:findViewByName("lay_list_top") 
	self.pImgTop = self:findViewByName("img_top")
	self.pImgBot = self:findViewByName("img_bot")
	self.pLayFriendList = self:findViewByName("lay_friend_list")	
	self.pImgBot:setFlippedY(true)
	self:setupViews()	
	--self:initChatItem()
end

--初始化控件
function ChatPrivateLayer:setupViews( )
	self.pSv = nil
	if self.nChatType == e_lt_type.sl then
		self.pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 10, self.pLyChat:getWidth(), self.pLyChat:getHeight() - 80),
		        touchOnContent = false,
		        direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
	    self.pLyChat:addView(self.pSv)
        --创建私聊对象窗口
	   	Player:clearPrivateChatRed(self.nPlayerId)	
	end
	
    self.pSv:onScroll(function ( event )
    	--是否移到最下
		self.bSlideDown = false
        if event.name == "scrollToHeader" then --最上面回调
        	self:noticeMaxTop()--最顶通知
        elseif event.name == "scrollToFooter" then --最下面回调
        	self.bSlideDown = true
        elseif event.name == "scrollEnd" then
        end
    end)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pSv:setUpAndDownArrow(pUpArrow, pDownArrow)
end

--最近联系人
function ChatPrivateLayer:refreshFriends(  )
	-- body
	local tListData = Player:getFriendsData():getRecentCons()
	self.tFriendsData = {}
	local bIsFreeChat = true --是否免费发送聊天信息
	for k, v in pairs(tListData) do
		table.insert(self.tFriendsData, 1, v)
		--敌对国家不免费私聊
		if self.nPlayerId == v:getTid() and Player:getPlayerInfo().nInfluence ~= v:getInfluence() then
			bIsFreeChat = false
		end
	end
	--私聊发送按钮更改
	sendMsg(ghd_pchat_send_btn_change, bIsFreeChat)

	local nDataNum = table.nums(self.tFriendsData)
	if not self.pFriendList then
		self.pFriendList = MUI.MListView.new {
				viewRect   = cc.rect(0, 0, self.pLayFriendList:getWidth(), self.pLayFriendList:getHeight()),
				direction  = MUI.MScrollView.DIRECTION_VERTICAL,
				itemMargin = {left =  0,
		            right =  0,
		            top =  0, 
		            bottom =  0},
		    }	
		self.pLayFriendList:addView(self.pFriendList)
		self.pFriendList:setBounceable(true) --是否回弹
		self.pFriendList:setItemCallback(handler(self, self.onTabEveryCallback))
		self.pFriendList:setItemCount(nDataNum)		
		self.pFriendList:reload()	
	else
		self.pFriendList:notifyDataSetChange(false, nDataNum)
	end
	self:showDefaultInfo(nDataNum)
end

function ChatPrivateLayer:showDefaultInfo( _nCnt )
	-- body
	if not self.pNullUi then
		local tLabel = {
		    str = getConvertedStr(6, 10466),
		}		
		local pNullUi = getLayNullUiImgAndTxt(tLabel)	
		pNullUi:setVisible(false)
		self.pLayRoot:addView(pNullUi)
		centerInView(self.pLayRoot, pNullUi)
		self.pNullUi = pNullUi
	end	
	local bShowDef = (_nCnt == 0)
	if bShowDef == self.pLayLeft:isVisible() then
		self.pLyFriendBg:setVisible(not bShowDef)
		self.pLyChat:setVisible(not bShowDef)
		self.pLayLeft:setVisible(not bShowDef)
		self.pNullUi:setVisible(bShowDef)
	end

	-- if bShowDef then
	-- 	self.pLyFriendBg:setVisible(false)
	-- 	self.pLyChat:setVisible(false)
	-- 	self.pLayLeft:setVisible(false)
	-- 	-- self.pLyListBot:setVisible(false)
	-- 	-- self.pLyListTop:setVisible(false)
	-- 	-- self.pLayFriendList:setVisible(false)
	-- else
	-- 	self.pLyFriendBg:setVisible(true)
	-- 	self.pLyChat:setVisible(true)
	-- 	self.pLayLeft:setVisible(true)
	-- 	-- self.pLyListBot:setVisible(true)
	-- 	-- self.pLyListTop:setVisible(true)
	-- 	-- self.pLayFriendList:setVisible(true)
	-- end	
end

-- 没帧回调 _index 下标 _pView 视图
function ChatPrivateLayer:onTabEveryCallback( _index, _pView )
	local pView = _pView
	if not pView then
		pView = ItemPrivateFriendChat.new()
		pView:setHandler(handler(self, self.clickTabItem))		
	end
	local pFriendData = self.tFriendsData[_index]
	if pFriendData then
		pView:setCurData(pFriendData)
		pView:setItemSelected(self.nPlayerId == pFriendData.sTid)		
	end
	pView:setHandler(handler(self, self.clickTabItem))
	return pView
end

function ChatPrivateLayer:clickTabItem( _pData  )
	-- body
	if _pData then		
		local nPlayerID = _pData.sTid
		local nPlayerName = _pData.sName
		if self.nPlayerId then
			if nPlayerID ~= self.nPlayerId then
				self:changePChatPlayer(nPlayerID, nPlayerName )
			else
				local nPlayerId = Player:getCurrPChatId()  --获取当前私聊的对象id
				local tFriendData = Player:getFriendsData():getRecentFriendById(nPlayerID)
				
				if tFriendData and tFriendData.bIsRb then   --机器人的话走另一套协议
			
					SocketManager:sendMsg("playWithRobot", {nPlayerID, 6}, function ( __msg ,__oldMsg)
						-- body
						if __msg.head.state == SocketErrorType.success	then
							--print("获取其他玩家数据成功！")
						    --查看玩家数据
						    local SPlayerData = require("app.layer.rank.SPlayerData")
						    if __msg.body.pm then
								local temp = SPlayerData.new()
								__msg.body.pm.rb = 1    --自己给他加上机器人标志
								temp:refreshDatasByService(__msg.body.pm)
								--刷新聊天头像数据				
								-- Player:recordPlayerCardInfo(temp)
								-- Player:getFriendsData():addRecentRecord(temp.nID, temp, 1, false)
								if not b_open_ios_shenpi then
									local tObj = {}
									tObj.tplayerinfo = temp
									-- tObj.tChatData = self.pData
									showRankPlayerInfo(tObj)						
								end
							end
						else		
							TOAST(SocketManager:getErrorStr(__msg.head.state))
						end			
					end)
				else
					local pMsgObj = {}
					pMsgObj.nplayerId = self.nPlayerId				
					pMsgObj.bToChat = false
					--发送获取其他玩家信息的消息
					sendMsg(ghd_get_playerinfo_msg, pMsgObj)	
				end			
			end
		end
	end	
end

--滑动到最顶通知
function ChatPrivateLayer:noticeMaxTop()
	local pCpData = self.tShowChatItem[1]
	if pCpData and pCpData.getData and pCpData:getData().nId then
		local nShowId = pCpData:getData().nId
		local tData = Player:getChatInfoByType(self.nChatType, nil, self.nPlayerId)
		if tData and tData[1] and tData[1].nId then
			if nShowId == tData[1].nId then
				if self.bShowTips then
					doDelayForSomething(self,function ()
						self.bShowTips = true--可以提示
						TOAST(getConvertedStr(5, 10285))
					end,0.1)
					self.bShowTips = false--不能继续提示
				end
			end
		end
	end

end

--分帧加载 
-- tData 需要刷新的数据 
-- nReType 插入类型 1代表头部插入, 2尾部插入 
-- bScrollToEnd是否定位到尾部
-- bInit 初始化的时候,不需要分帧
-- nCallBackFunc 分帧后回调
-- bScrollEndInAdd 每一帧新加精灵都置底（其实应该要回滚到之前的位置，这个底层不知道支不支持，先这样znftodo）
function ChatPrivateLayer:scheduleOnceAddTnoly( tData, nReType, bScrollToEnd, bInit, nCallBackFunc, bScrollEndInAdd)
	--容错
	if not tData then
		return
	end
	if (table.nums(tData)<= 0)  then
		return
	end
	--默认插入方式
	if not nReType then
		nReType = 2
	end


	--当前刷新帧下标
	local nIndex =  1
	--总数量
	local nNewIndex = table.nums(tData)
	--分帧
	if not self.nAddScheduler then
		self.nAddScheduler = MUI.scheduler.scheduleUpdateGlobal(function ()
			--需要增加的数量
			local nAddChat = 1
			if bInit then --是否需要一次过加载聊信息. true为是
				nAddChat = nNewIndex
			end
			--遍历增加的数量
			for i=1, nAddChat do
				local pItem = nil
				if nReType == 1 then --头部插入
					pItem = self:getChatByFreePool(tData[nNewIndex-nIndex+1]) --从空闲的对象池中获取
					if pItem then
					    self.pSv:insertView(pItem,1)
					    pItem.psv = self.pSv
					    table.insert(self.tShowChatItem,1,pItem)
					    --当超过最大长度时，从下面开始移除
						if table.nums(self.tShowChatItem)>self.nMaxItemNum then
							local nShowLongIndex = table.nums(self.tShowChatItem)
							self.pSv:removeView(nShowLongIndex)
							self:pushChatToFreePool(self.tShowChatItem[nShowLongIndex]) --加入到空闲的对象池
							table.remove(self.tShowChatItem,nShowLongIndex) --超过显示的个数时 移除底部的一个
						end
						--强制添加并置底
						if bScrollEndInAdd then
							self.pSv:scrollToEnd(false)
						else
							--???
						    -- if not bScrollToEnd then
						    -- 	 self.pSv:scrollToPosition(nIndex,false)
						    -- 	 print("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ3")
						    -- end
						end
					end
				elseif nReType == 2 then --尾部插入
					pItem = self:getChatByFreePool(tData[nIndex]) --从空闲的对象池中获取
					if pItem then
						--之前的位置
						local nPrevScrollX, nPrevScrollY = self.pSv:getScrollNode():getPosition()
					    self.pSv:addView(pItem)
					    pItem.psv = self.pSv
					    table.insert(self.tShowChatItem,pItem)
					    --当超过最大长度时，从上面开始移除
						if table.nums(self.tShowChatItem)>self.nMaxItemNum then
							self.pSv:removeView(1)
							self:pushChatToFreePool(self.tShowChatItem[1]) --加入到空闲的对象池
							table.remove(self.tShowChatItem,1) --超过显示的个数时 移除头顶的一个
						else
							--保持不移动
							nPrevScrollY = nPrevScrollY - pItem:getContentSize().height
						end
						--强制添加并置底
						if bScrollEndInAdd then
							self.pSv:scrollToEnd(false)
						else
							--保持不移动
							if not bScrollToEnd then
								self.pSv:scrollTo(nPrevScrollX, nPrevScrollY, false)
							end
						end
					end
				end

				--下标加1
				nIndex = nIndex + 1
				--当下标已大过最大数就停止
				if self ~= nil and self.nAddScheduler ~= nil and nIndex > nNewIndex then

					--移除帧刷新器
			        MUI.scheduler.unscheduleGlobal(self.nAddScheduler)
			        self.nAddScheduler = nil

			        if bScrollToEnd then
			        	--如果已经加入的item高度大于滑动层的高度
			        	if self:getAddedItemHeight() >self.pSv:getHeight() then
				        	self.pSv:scrollToEnd(false)
			        	end
			        end

			        --全部结束回调
			        if nCallBackFunc then
			        	nCallBackFunc()
			        end
				end
			end
		end)
	end
end



--析构方法
function ChatPrivateLayer:onDestroy(  )

	if self.nAddScheduler then
        MUI.scheduler.unscheduleGlobal(self.nAddScheduler)
        self.nAddScheduler = nil
	end


	for k,v in pairs(self.tFreeChatItem) do
		if v then
			v:release()
		end
	end

	for k,v in pairs(self.tShowChatItem) do
		if v then
			v:release()
		end
	end

	--注册撤回消息刷新
	unregMsg(self, ghd_refresh_recall_chat)

	unregMsg(self, ghd_refresh_chat)
	unregMsg(self, gud_refresh_chat)

	unregMsg(self, ghd_chat_icon_refresh_msg)
end


--如果是撤回消息
function ChatPrivateLayer:removeChatItem(msgName, pMsg)
	-- body
	if pMsg then
		local tType = pMsg.tRecallType
		local nRecallId = pMsg.nRecallId
		local bRefresh = false
		for k, v in pairs(tType) do
			if self.nChatType == v then
				bRefresh = true
			end
		end
		if bRefresh and nRecallId then
			local nShowCnt = #self.tShowChatItem
			for k = nShowCnt, 1, -1 do
				local _tData = self.tShowChatItem[k]:getData()
				if _tData.nMap == nRecallId then
					self.pSv:removeView(k)
					self:pushChatToFreePool(self.tShowChatItem[k]) --加入到空闲的对象池
					table.remove(self.tShowChatItem, k)
				end
			end
		end
	end
end

--增加聊天数据
function ChatPrivateLayer:addChatItem( msgName, pMsg)
	if pMsg then
		--类型
		local nType = pMsg.nType
		--私聊对象玩家id
		local nPlayerId = pMsg.nPlayerId
		--发送者玩家id
		local nSenderId = pMsg.nSenderId
		local bIsMe = nSenderId == Player:getPlayerInfo().pid
		if self.nChatType == nType then

			if self.nChatType == e_lt_type.sl then  --私聊
				if self.nPlayerId == nPlayerId then --是同一个玩家
					self:addChatData(bIsMe)
				end
			else
				self:addChatData(bIsMe)
			end
			--更新玩家列表
			self:refreshFriends()
		end
	end
end
--刷新聊天数据
function ChatPrivateLayer:refreshChatItem( msgName, pMsg )
	-- body
	if self.pFriendList then
		self.pFriendList:notifyDataSetChange(false)	
	end	
	local nSid = pMsg
	for k, v in pairs(self.tShowChatItem) do
		local pData = v:getData()
		if nSid == pData.nSid then
			v:updateViews()
		end
	end
end

function ChatPrivateLayer:refreshChatIcons( ... )
	-- body
	if self.pFriendList then
		self.pFriendList:notifyDataSetChange(false)	
	end
end

--获取里面是否有我发送的消息
function ChatPrivateLayer:getIsSendByMe( tScreenData )
	if tScreenData then
		for k,v in pairs(tScreenData) do
			if v.nSid == Player:getPlayerInfo().pid then
				return true
			end
		end
	end
	return false
end

--增加聊天数据
function ChatPrivateLayer:addChatData( bIsMe )
	--记录聊天数据
	--释放lua数据
	self.tRecordChatData = nil
	self.tRecordChatData = self:getChatRecord()
	local nTableNums =  table.nums(self.tRecordChatData) --目前聊天记录条数
	local nAddIndex = 0 --现在刷新到哪一项(默认刷新到最后一项)
	local nShowMaxNums = table.nums(self.tScreenData) --显示的数量
	--需要刷新的数据
	local pItem = self.tShowChatItem[table.nums(self.tShowChatItem)]
	if pItem  then
		local pCpData = pItem:getData()
		if pCpData then
			--最新的一条数据
			for i=1,nTableNums do
				local pCpData2 = self.tRecordChatData[i]
				if pCpData.nSt == pCpData2.nSt then
					nAddIndex = i --记录位置
					break
				end
			end
		end
	end
	--如果为最后一项的话,就不在刷新
	if nAddIndex == nTableNums then 
		return 
    elseif nAddIndex == 0 then --如果没有找到就拿最新需要显示的项(一下子一大堆数据)
    	nAddIndex = nTableNums - self.nSlideLoadItemNums
    else
    	nAddIndex = nAddIndex + 1
    end
    --顺序
   	local nIndex = nAddIndex
   	if nIndex < 1 then
   		nIndex = 1
   	end
    local nEndIndex = nIndex + self.nMaxItemNum -- 需要添加的聊天个数
    if nEndIndex > nTableNums then
    	nEndIndex = nTableNums
    end


	--显示的数据
	--记录 栏截止已聊天的数据
	local tIdKeys = {}
	if self.tScreenData then
		for k,v in pairs(self.tScreenData) do
			if v.nId then
				tIdKeys[v.nId] = true
			end
		end
	end
	--设置数据
	self.tScreenData = {}
	for i=nIndex,nTableNums do
		if i <= nEndIndex then
			table.insert(self.tScreenData,self.tRecordChatData[i])
		end
	end

	--栏截止已聊天的数据
	for i=#self.tScreenData, 1, -1 do
		local nId = self.tScreenData[i].nId
		if nId then
			if tIdKeys[nId] then
				-- print("出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦出错啦")
				table.remove(self.tScreenData, i)
			end
		end
	end

	--排序
	if table.nums(self.tScreenData)> 0 then
		table.sort(self.tScreenData,function (a,b)
            return a.nSt < b.nSt
		end)
	end
	
	self:scheduleOnceAddTnoly(self.tScreenData, 2, self.bSlideDown or bIsMe)
end

--设置数据 _data
function ChatPrivateLayer:setCurData(_tData)
	if not _tData then
		return
	end
	self.pData = _tData or {}
end


--获取聊天记录
function ChatPrivateLayer:getChatRecord( )
	--数据
	local tData = {}
	--聊天记录数据
	if self.nChatType == e_lt_type.sl then
		if self.nPlayerId then
			tData = Player:getChatInfoByType(self.nChatType, self.nMaxDataNum, self.nPlayerId)
		end
	else
		tData = Player:getChatInfoByType(self.nChatType,self.nMaxDataNum)
	end

	--时间先后排序
	if tData and table.nums(tData)> 0 then
		table.sort(tData,function (a,b)
           return a.nSt < b.nSt
		end)
	end
		
	return tData
end


--获取已经加入的聊天高度
function ChatPrivateLayer:getAddedItemHeight()
	-- body
	local nH = 0
	if self.tShowChatItem and table.nums(self.tShowChatItem)> 0 then
		for k,v in pairs(self.tShowChatItem) do
			nH = nH + v:getHeight()
		end
	end

	return nH
end

--获取闲置的数据池
--pData：ChatData
function ChatPrivateLayer:getChatByFreePool( pData )
	local pItem = nil
	local nType = 2 --自己类型
	local nRemoveNums = 0 --移聊的下标
	if pData then
		if pData.nSid ~= Player.baseInfos.pid  then --别人类型
			nType = 1
		end
		
		--在空闲的列表中寻找对应的类型
		for k,v in pairs(self.tFreeChatItem) do
			if v.nType and nType == v.nType then
				nRemoveNums = k
				pItem = v
				pItem:setCurData(pData)
				break
			end
		end
		--移除
		if nRemoveNums > 0 then
			table.remove(self.tFreeChatItem,nRemoveNums)
		end

		--没有的情况下就创建一个
		if not pItem then
			pItem = ItemPrivateChat.new(pData)
			pItem:retain()
		end
	end

	return pItem
end


--将对话框加入回收池
--pData: ItemChat
function ChatPrivateLayer:pushChatToFreePool( pData )
	if pData then
		pData:removeFromParent()
		table.insert(self.tFreeChatItem, pData)
	end
end

--获取私聊玩家名字
function ChatPrivateLayer:getPrivateChatName( )
	return self.sPlayerName
end
--获取私聊玩家id
function ChatPrivateLayer:getPrivateChatId( )
	return self.nPlayerId
end
--设置默认选中玩家
--tPChatInfo 指定玩家
function ChatPrivateLayer:setDefaultPChatPlayer( tPChatInfo )
	--刷新玩家数据
	local tListData = Player:getFriendsData():getRecentCons()
	self.tFriendsData = {}
	for k, v in pairs(tListData) do
		table.insert(self.tFriendsData, 1, v)
	end
	--设定指定玩家
	local nPlayerId = nil
	local sPlayerName = nil
	if tPChatInfo then
		nPlayerId = tPChatInfo.nPlayerId
		sPlayerName = tPChatInfo.sPlayerName	
	else
		local nIndex = 1
		for i=1, #self.tFriendsData do
			if self.tFriendsData[i].sTid == self.nPlayerId then
				nIndex = i
				break
			end
		end
		local _pData = self.tFriendsData[nIndex]
		if _pData then
			nPlayerId = _pData.sTid
			sPlayerName = _pData.sName			
		end	
	end
	self:changePChatPlayer(nPlayerId, sPlayerName)
end

--更换指定玩家
function ChatPrivateLayer:changePChatPlayer( nPlayerId, sPlayerName )
	self.nPlayerId = nPlayerId
	self.sPlayerName = sPlayerName
	--如果新玩家跟之前玩家不一样就
	local nPChatIdPrev = Player:getCurrPChatId()
	if nPChatIdPrev and nPChatIdPrev ~= self.nPlayerId then
		Player:closePlayerPrivateChat()
	end
	--设置当前的玩家对象
	Player:setCurrPChatId(self.nPlayerId)
	--通知聊天窗口主私聊tab的对象记录
	sendMsg(ghd_change_private_chat_player, self.nPlayerId)
	--更新玩家列表
	self:refreshFriends()
	--请求当前玩家数据
	self:reqPrivateChatData(self.nPlayerId)
end

--请求私聊指定私聊对象数据
function ChatPrivateLayer:reqPrivateChatData( nPlayerId )
	if not nPlayerId then
		return
	end
	--暂停定时器
	if self.nAddScheduler then
        MUI.scheduler.unscheduleGlobal(self.nAddScheduler)
        self.nAddScheduler = nil
	end
	--将当前显示的全部加重置
	local nShowLongIndex = #self.tShowChatItem
	for i=nShowLongIndex,1,-1 do
		self.pSv:removeView(i)
		self:pushChatToFreePool(self.tShowChatItem[i]) --加入到空闲的对象池
		table.remove(self.tShowChatItem,i) --超过显示的个数时 移除底部的一个
	end
	local tFriendData = Player:getFriendsData():getRecentFriendById(nPlayerId)

	if tFriendData and tFriendData.bIsRb then   --机器人的话走另一套协议
		SocketManager:sendMsg("playWithRobot", {nPlayerId,10}, function ( __msg,__oldMsg )
			if __msg.body then
				local nSid = __oldMsg[1]
				Player:setPrivateChatList(nSid, __msg.body.rs)
				Player:clearPrivateChatRed(nSid)
			end
			if self and self.initChatItem then
				self:initChatItem()
			end
		end)
	else
		SocketManager:sendMsg("privateChatPlayerReq", {nPlayerId}, function (  )
			if self and self.initChatItem then
				self:initChatItem()
			end
		end)
	end
end

--将目标头像置顶
function ChatPrivateLayer:setFriendIconTop(  )
	local pFriendVo = Player:getFriendsData():getRecentFriendById(self.nPlayerId)
	if pFriendVo then
		Player:getFriendsData():addRecentRecord(self.nPlayerId, pFriendVo, 3, true)		
		self:refreshFriends()
	end
end



return ChatPrivateLayer