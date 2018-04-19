-- Author: liangzhaowei
-- Date: 2017-04-24 16:45:45
-- 英雄属性item

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
local ItemChat = require("app.layer.chat.ItemChat")
local ItemChatCard = require("app.layer.chat.ItemChatCard")
local ItemRedPocket = require("app.layer.chat.ItemRedPocket")
local ItemRedPocketRecord = require("app.layer.chat.ItemRedPocketRecord")

local ItemChatFriend = require("app.layer.chat.ItemChatFriend")


local ChatLayer = class("ChatLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

--创建函数
--从哪条消息打开的
--tPChatInfo = {
-- 	nPlayerId,
-- 	sPlayerName,
-- }
--从好友打开
function ChatLayer:ctor(_type, tPChatInfo, pSize)
	self.pSize = pSize
	self:myInit()
	self.nChatType = _type or 1
	self.nPlayerId = nil
	self.sPlayerName = nil
	if tPChatInfo then
		self.nPlayerId = tPChatInfo.nPlayerId
		self.sPlayerName = tPChatInfo.sPlayerName
	end

	
	--获取聊天数据最大数目
	self.nMaxDataNum = MAX_SHOW_CHAT_COUNT[self.nChatType]

	parseView("layout_chat_layer", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ChatLayer",handler(self, self.onDestroy))

	--刷新消息
	regMsg(self, ghd_refresh_chat, handler(self, self.addChatItem))
	regMsg(self, gud_refresh_chat, handler(self, self.addChatItem))

	--注册撤回消息刷新
	regMsg(self, ghd_refresh_recall_chat, handler(self, self.removeChatItem))

	--刷新消息
	regMsg(self, ghd_chat_icon_refresh_msg, handler(self, self.refreshChatIcons))

	--刷新红包数据
	regMsg(self, ghd_refresh_redpocket_msg, handler(self, self.refreshRedPocketItem))

end

--初始化参数
function ChatLayer:myInit()
	self.pData = {} --数据
	self.nChatType = 1 -- 聊天类型，1世界，2军团，3私聊
	self.tShowData = {} --显示聊天数据
	self.nLastIndex = 0 --最后添加的下标
	self.nLastChatTime = 0 --最后聊天数据的聊天时间
	self.nMaxDataNum = 50 --聊天数据最大数目
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
	self.tFreeRPacketPItem = {} --空余item列表 红包 
	self.tFreeRPRecordItem = {} --空余item列表 红包记录
	self.tFreeCardItem = {} --空余item列表 卡牌


	self.tRecordChatData = {} --获取聊天记录

	self.nAddItemCount = 0 --需要显示添加的聊天条目数

	self.bSlideDown = false -- 是否滑到底部

	self.bShowTips = true --是否可以显示提示(最顶)

end

--刷新数据
function ChatLayer:initChatItem( )
	--获取聊天记录
	self.tRecordChatData = nil
	self.tRecordChatData = self:getChatRecord()
	--聊天数量
	local nTableNums =  #self.tRecordChatData 

	
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
	if self.tScreenData then
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
		end
	end

	self:scheduleOnceAddTnoly(self.tScreenData,2,true,true, firstCallBack)
end

--解析布局回调事件
function ChatLayer:onParseViewCallback( pView )
	-- self:setContentSize(pView:getContentSize())
	self:setContentSize(self.pSize.width, self.pSize.height)
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:initChatItem()
end

--初始化控件
function ChatLayer:setupViews( )

	self.pLyChat = self:findViewByName("ly_chat") 
	
	self.pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 10, self.pLyChat:getWidth(), self.pLyChat:getHeight()),
        touchOnContent = false,
        direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
    self.pLyChat:addView(self.pSv)
	
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

--滑动到最顶通知
function ChatLayer:noticeMaxTop()
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
function ChatLayer:scheduleOnceAddTnoly( tData, nReType, bScrollToEnd, bInit, nCallBackFunc, bScrollEndInAdd)
	--容错
	if not tData then
		return
	end
	if (#tData<= 0)  then
		return
	end
	--默认插入方式
	if not nReType then
		nReType = 2
	end


	--当前刷新帧下标
	local nIndex =  1
	--总数量
	local nNewIndex = #tData
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
						if #self.tShowChatItem>self.nMaxItemNum then
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
						if #self.tShowChatItem>self.nMaxItemNum then
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
function ChatLayer:onDestroy(  )

	if self.nAddScheduler then
        MUI.scheduler.unscheduleGlobal(self.nAddScheduler)
        self.nAddScheduler = nil
	end


	for k,v in pairs(self.tFreeChatItem) do
		if v then
			v:release()
		end
	end
	for k,v in pairs(self.tFreeRPacketPItem) do
		if v then
			v:release()
		end
	end
	for k,v in pairs(self.tFreeRPRecordItem) do
		if v then
			v:release()
		end
	end
	for k,v in pairs(self.tFreeCardItem) do
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

	unregMsg(self, ghd_refresh_redpocket_msg)

	self:closePChatPlayer()
end


--如果是撤回消息
function ChatLayer:removeChatItem(msgName, pMsg)
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
function ChatLayer:addChatItem( msgName, pMsg)
	if pMsg then
		--类型
		local nType = pMsg.nType
		--私聊对象玩家id
		local nPlayerId = pMsg.nPlayerId
		--发送者玩家id
		local nSenderId = pMsg.nSenderId
		--私聊对象者名字
		local sPlayerName = pMsg.sPlayerName
		local bIsMe = nSenderId == Player:getPlayerInfo().pid
		if self.nChatType == nType then
			-- if self.nChatType == e_lt_type.sl then  --私聊
			-- 	if self.nPlayerId == nil and self:getPrivateChatName() == sPlayerName then
			-- 		self.nPlayerId = nPlayerId
			-- 	end

			-- 	if self.nPlayerId == nPlayerId then --是同一个玩家
			-- 		self:addChatData(bIsMe)
			-- 	end
			-- else
				self:addChatData(bIsMe)
			-- end
		end
    else
        self:addChatData(true)
	end
end
--刷新聊天数据
function ChatLayer:refreshChatItem( msgName, pMsg )
	-- body
	local nSid = pMsg
	for k, v in pairs(self.tShowChatItem) do
		local pData = v:getData()
		if nSid == pData.nSid then
			v:updateViews()
		end
	end
end
--刷新聊天头像
function ChatLayer:refreshChatIcons( msgName, pMsg )
	-- body	
	local nSid = pMsg
	local bRefresh = false --是否需要重置聊天界面
	for k, v in pairs(self.tShowChatItem) do
		local pData = v:getData()
		if nSid == pData.nSid and v.updatePlayerIcon then
			v:updateViews()
			if not bRefresh then
				bRefresh = true
			end			
		end
	end
	if bRefresh and self.pSv then		
		self.pSv:updateSizeFromChild()
	end
end

function ChatLayer:refreshRedPocketItem( msgName, pMsg )
	-- body
	local nNid = pMsg
	for k, v in pairs(self.tShowChatItem) do
		local pData = v:getData()
		if nNid == pData.nId then
			v:updateViews()
		end
	end
end
--获取里面是否有我发送的消息
function ChatLayer:getIsSendByMe( tScreenData )
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
function ChatLayer:addChatData( bIsMe )
	--记录聊天数据
	--释放lua数据
	self.tRecordChatData = self:getChatRecord()
	local nTableNums =  #self.tRecordChatData --目前聊天记录条数
	local nAddIndex = 0 --现在刷新到哪一项(默认刷新到最后一项)
	local nShowMaxNums = #self.tScreenData --显示的数量
	--需要刷新的数据
	local pItem = self.tShowChatItem[#self.tShowChatItem]
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
	if self.tScreenData then
		table.sort(self.tScreenData,function (a,b)
            return a.nSt < b.nSt
		end)
	end
	

	self:scheduleOnceAddTnoly(self.tScreenData, 2, self.bSlideDown or bIsMe)
end

--设置数据 _data
function ChatLayer:setCurData(_tData)
	if not _tData then
		return
	end
	self.pData = _tData or {}
end


--获取聊天记录
function ChatLayer:getChatRecord( )
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
	if tData then
		table.sort(tData,function (a,b)
           return a.nSt < b.nSt
		end)
	end
		
	return tData
end


--获取已经加入的聊天高度
function ChatLayer:getAddedItemHeight()
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
--tData ：ChatData
function ChatLayer:getChatByFreePool( tData )
	if not tData then
		return
	end

	local nType = 2 --自己类型
	
	if tData then
		if tData.nSid ~= Player.baseInfos.pid  then --别人类型
			nType = 1
		end
	end

	--控件
	local pItem = nil
	if tData:getIsRedPacket() then --红包
		local nRemoveNums = 0 --移聊的下标
		--在空闲的列表中寻找对应的类型
		for k,v in pairs(self.tFreeRPacketPItem) do
			if v.nType and nType == v.nType then
				nRemoveNums = k
				pItem = v
				pItem:setCurData(tData)
				break
			end
		end
		--移除
		if nRemoveNums > 0 then
			table.remove(self.tFreeRPacketPItem,nRemoveNums)
		end

		--没有的情况下就创建一个
		if not pItem then
			pItem = ItemRedPocket.new(tData)
			pItem:retain()
		end
	elseif tData:getIsRPRecord() then --红包记录
		local nRemoveNums = 0 --移聊的下标
		--在空闲的列表中寻找对应的类型
		for k,v in pairs(self.tFreeRPRecordItem) do
			if v.nType and nType == v.nType then
				nRemoveNums = k
				pItem = v
				pItem:setCurData(tData)
				break
			end
		end
		--移除
		if nRemoveNums > 0 then
			table.remove(self.tFreeRPRecordItem,nRemoveNums)
		end

		--没有的情况下就创建一个
		if not pItem then
			pItem = ItemRedPocketRecord.new(tData)
			pItem:retain()
		end
	elseif tData:getIsCard() then --卡牌式聊天
		local nRemoveNums = 0 --移聊的下标
		--在空闲的列表中寻找对应的类型
		for k,v in pairs(self.tFreeCardItem) do
			if v.nType and nType == v.nType then
				nRemoveNums = k
				pItem = v
				pItem:setCurData(tData)
				break
			end
		end
		--移除
		if nRemoveNums > 0 then
			table.remove(self.tFreeCardItem,nRemoveNums)
		end

		--没有的情况下就创建一个
		if not pItem then
			pItem = ItemChatCard.new(tData)
			pItem:retain()
		end

	else --普通聊天
		local nRemoveNums = 0 --移聊的下标
		--在空闲的列表中寻找对应的类型
		for k,v in pairs(self.tFreeChatItem) do
			if v.nType and nType == v.nType then
				nRemoveNums = k
				pItem = v
				pItem:setCurData(tData)
				break
			end
		end
		--移除
		if nRemoveNums > 0 then
			table.remove(self.tFreeChatItem,nRemoveNums)
		end

		--没有的情况下就创建一个
		if not pItem then
			pItem = ItemChat.new(tData)
			pItem:retain()
		end
	end

	return pItem
end


--将对话框加入回收池
--pData: ItemChat
function ChatLayer:pushChatToFreePool( pData )
	if pData then
		local tData = pData:getData()
		if tData then
			pData:removeFromParent()
			if tData:getIsRedPacket() then --红包
				table.insert(self.tFreeRPacketPItem, pData)
			elseif tData:getIsRPRecord() then --红包记录
				table.insert(self.tFreeRPRecordItem, pData)
			elseif tData:getIsCard() then --卡牌式聊天
				table.insert(self.tFreeCardItem, pData)
			else --普通聊天
				table.insert(self.tFreeChatItem, pData)
			end
		end
	end
end

--获取私聊玩家名字
function ChatLayer:getPrivateChatName( )
	if self.pFriend then
		return self.pFriend:getPrivateChatName()
	end
	return nil
end

--根据tPChatInfo更改玩家信息
--tPChatInfo = {
--	nPlayerId = xx, sPlayerName = xxx,
--}
function ChatLayer:changePChatPlayerByPChatInfo( tPChatInfo)
	if not tPChatInfo then
		return 
	end
	--
	self:changePChatPlayer(tPChatInfo.nPlayerId, tPChatInfo.sPlayerName )
	Player:clearPrivateChatRed(tPChatInfo.nPlayerId)	
end

--更换玩家
function ChatLayer:changePChatPlayer( nPlayerId, sName )
	--容错
	if not nPlayerId or not sName then
		print("XXXXXXXXXXXX")
		return
	end

	--设置发送玩家名字
	if self.pFriend then
		self.pFriend:setPlayerInfo(nPlayerId, sName)
	end

	--通知聊天窗口主私聊tab的对象记录
	sendMsg(ghd_change_private_chat_player, nPlayerId)
	
	--玩家id相同返回
	if self.nPlayerId == nPlayerId then
		print("XXXXXXXXXXXX2")
		return
	end

	if self.nPlayerId then
		--如果玩家id不同之前的玩家id就发送关闭4536
		SocketManager:sendMsg("closePlayerPrivateChat", {self.nPlayerId})
		self.nPlayerId = nil
	end

	--设置新玩家id
	self.nPlayerId = nPlayerId
	self.sPlayerName = sName

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

	--判断是否有当前玩家id的红点，有就请求私聊信息4535，否则就直接获取本地存储的信息
	-- local nRedNum = Player:getPrivateChatRed(self.nPlayerId)
	-- if nRedNum > 0 then
		SocketManager:sendMsg("privateChatPlayerReq", {self.nPlayerId}, function (  )
			if self and self.initChatItem then
				self:initChatItem()
			end
		end)
	-- else
	-- 	--刷新数据
	-- 	self.nLastChatTime = 0
	-- 	self:initChatItem()
	-- end
end

--关掉之前的玩家私聊
function ChatLayer:closePChatPlayer( )
	if self.nChatType == e_lt_type.sl then
		if self.nPlayerId then
			--如果玩家id不同之前的玩家id就发送关闭4536
			SocketManager:sendMsg("closePlayerPrivateChat", {self.nPlayerId})
			self.nPlayerId = nil
		end
	end
end

--滚动到低部
function ChatLayer:setSVScrollToEnd(  )
	--如果已经加入的item高度大于滑动层的高度
	if self.pSv then
		--如果已经加入的item高度大于滑动层的高度
		if self:getAddedItemHeight() >self.pSv:getHeight() then
    		self.pSv:scrollToEnd(false)
    	end
	end
	self.bSlideDown = true
end

return ChatLayer