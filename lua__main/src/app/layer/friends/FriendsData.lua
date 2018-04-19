local FriendVo = require("app.layer.friends.FriendVo")

local FriendsData = class("FriendsData")

function FriendsData:ctor(  )
	self:myInit()
end

function FriendsData:myInit(  )
	-- body
	self.tFriends 	= 	{} 	--好友信息
	self.tBlacks	= 	{}	--黑名单
	self.tRecentC 	=   {} 	--最近联系人
	self.nGet 		=   0  --已经获取体力次数
end

--刷新好友信息数据
function FriendsData:refreshDatasByService( tData )
	-- body
	if tData.fs and #tData.fs > 0 then--刷新好友列表
		--self.tFriends = {}
		for k, v in pairs(tData.fs) do
			local tFriendVo = self:getFriendById(v.aid)
			if not tFriendVo then
				tFriendVo = FriendVo.new()	
				tFriendVo:refreshDatasByService(v)
				table.insert(self.tFriends, tFriendVo)	
			else
				tFriendVo:refreshDatasByService(v)
			end			
		end
	end
	if tData.ss and #tData.ss > 0 then--刷新黑名单列表
		--self.tBlacks = {}
		for k, v in pairs(tData.ss) do
			local tBlack = self:getBlackFriend(v.aid)
			if not tBlack then
				tBlack = FriendVo.new()
				tBlack:refreshDatasByService(v)
				table.insert(self.tBlacks, 1, tBlack)
			else
				tBlack:refreshDatasByService(v)
			end			
		end
		-- table.sort( self.tBlacks, function ( a, b )
		-- 	return a.nSt > b.nSt
		-- end )
	end
	if tData.rs and #tData.rs > 0 then--刷新最近联系人
		--self.tRecentC = {}
		for k, v in pairs(tData.rs) do
			local tBlack = self:getRecentFriendById(v.aid)
			if not tBlack then
				tBlack = FriendVo.new()
				tBlack:refreshDatasByService(v)
				table.insert(self.tRecentC, tBlack)
			else
				tBlack:refreshDatasByService(v)
			end			
		end
		self:keepRecentPChatPlayerLimit()
		-- table.sort( self.tRecentC, function ( a, b )
		-- 	-- body
		-- 	local nRedA = Player:getPrivateChatRed(a.sTid)
		-- 	local nRedB = Player:getPrivateChatRed(a.sTid)		
		-- 	if nRedA == nRedB then
		-- 		return a.nSt > b.nSt
		-- 	else
		-- 		return nRedA > nRedB
		-- 	end		
		-- end )		
	end	
	self.nGet = tData.get or self.nGet
end

--添加好友
function FriendsData:refreshFriendByService( tData )
	-- body
	if not tData then
		return 
	end
	local tFriendVo = self:getFriendById(tData.aid)
	if not tFriendVo then
		tFriendVo = FriendVo.new()	
		tFriendVo:setIsNew(true)
		tFriendVo:refreshDatasByService(tData)
		table.insert(self.tFriends, tFriendVo)
	else
		tFriendVo:refreshDatasByService(tData)	
	end
	
end

--刷新体力好友
function FriendsData:refreshFriendPowerByService( tData )
	-- body
	if not tData then
		return 
	end
	local tFriendVo = self:getFriendById(tData.aid)
	if tFriendVo then
		tFriendVo:refreshDatasByService(tData)	
	end
end

--新好友红点数
function FriendsData:getHomeMenuRedNum(  )
	-- body
	return self:getNewFriendCnt() + self:getVitRedCnt()
end
--体力红点
function FriendsData:getVitRedCnt(  )
	-- body
	local nCnt = 0
	if self:isGetVitFull() == false then
		local tt = self:getVitFriends()
		for k,v in pairs(tt) do
			if v.nGetEnergy == 0 then
				nCnt = nCnt + 1
			end
		end
	end
	return nCnt
end

--可领取体力次数已满
function FriendsData:isGetVitFull(  )
	-- body
	local nCnt = tonumber(getChatInitParam("getPowerMaxLimit") or 0)
	return self.nGet >= nCnt
end

--获取新朋友的数量
function FriendsData:getNewFriendCnt( )
	-- body
	local nCnt = 0 
	for k, v in pairs(self.tFriends) do
		if v:isNew() then
			nCnt = nCnt + 1
		end
	end	
	return nCnt
end

--清理新玩家状态
function FriendsData:clearAllNew(  )
	-- body
	for k, v in pairs(self.tFriends) do
		v:setIsNew(false)
	end
	sendMsg(ghd_item_home_menu_red_msg)
end

--添加黑名单
function FriendsData:refreshBlackByService( tData )
	-- body
	if not tData then
		return 
	end
	local tFriendVo = self:getBlackFriend(tData.aid)
	if not tFriendVo then
		tFriendVo = FriendVo.new()	
		tFriendVo:refreshDatasByService(tData)
		table.insert(self.tBlacks, 1, tFriendVo)	
	else
		tFriendVo:refreshDatasByService(tData)
	end
	
end

--删除好友
function FriendsData:removeFriendById( nId )
	-- body
	if not nId then
		return 
	end
	if self.tFriends and #self.tFriends > 0 then
		for k, v in pairs(self.tFriends) do
			if v.sTid == nId then
				table.remove(self.tFriends, k)
				return						
			end			
		end
	end	
end

--删除黑名单好友
function FriendsData:removeBlackFriend( nId )
	-- body
	if not nId then
		return 
	end
	if self.tBlacks and #self.tBlacks > 0 then
		for k, v in pairs(self.tBlacks) do
			if v.sTid == nId then
				table.remove(self.tBlacks, k)
				return						
			end			
		end
	end	
end

--获取好友数据根据玩家ID
function FriendsData:getFriendById( nId )
	-- body
	if not nId then
		return nil
	end
	for k, v in pairs(self.tFriends) do
		if v.sTid == nId then
			return  v
		end
	end
	return nil
end

--获取黑名单中的玩家数据根据玩家ID
function FriendsData:getBlackFriend( nId )
	-- body
	if not nId then
		return nil
	end
	for k, v in pairs(self.tBlacks) do
		if v.sTid == nId then
			return v
		end
	end
	return nil
end

--获取最近联系人
function FriendsData:getRecentFriendById( nId )
	-- body
	if not nId then
		return nil
	end
	for k, v in pairs(self.tRecentC ) do
		if v.sTid == nId then
			return v
		end
	end
	return nil
end

function FriendsData:removeRecentByID( nId )
	-- body
	if not nId then
		return 
	end
	if self.tRecentC and #self.tRecentC > 0 then
		for k, v in pairs(self.tRecentC) do
			if v.sTid == nId then
				table.remove(self.tRecentC, k)
				return						
			end			
		end
	end		
end
function FriendsData:refreshRecentByService( tData )
	-- body
	if not tData then
		return 
	end
	local tFriendVo = self:getRecentFriendById(tData.aid)
	if not tFriendVo then
		tFriendVo = FriendVo.new()	
		table.insert(self.tRecentC, tFriendVo)	
	end
	tFriendVo:refreshDatasByService(tData)	
	-- table.sort( self.tRecentC, function ( a, b )
	-- 	-- body
	-- 	local nRedA = Player:getPrivateChatRed(a.sTid)
	-- 	local nRedB = Player:getPrivateChatRed(a.sTid)		
	-- 	-- if nRedA == nRedB then
	-- 	-- 	return a.nSt > b.nSt
	-- 	-- else
	-- 	return nRedA > nRedB
	-- 	-- end		
	-- end )	
	self:keepRecentPChatPlayerLimit()
end
--获取好友
function FriendsData:getFriends(  )
	-- body
	if self.tFriends then
		table.sort( self.tFriends, function ( a, b )
			-- body
			local sAname = a.sName or ""
			local sBname = b.sName or ""
			if a.bNew == b.bNew then
				if a.nCanGet == b.nCanGet then
					return sAname < sBname							
				else
					return a.nCanGet == 0
				end					
			else
				return a.bNew
			end
		end )	
	end
	return self.tFriends
end

function FriendsData:getSendRedPocketFriends(  )
	-- body
	local tFriend = {}
	if self.tFriends then
		for k, v in pairs(self.tFriends) do
			if v.bIsRb == nil or not v.bIsRb then
				table.insert(tFriend, v)
			end
		end
		table.sort(tFriend, function (a, b)
			-- body
			local sAname = a.sName or ""
			local sBname = b.sName or ""
			if a.bNew == b.bNew then
				if a.nCanGet == b.nCanGet then
					return sAname < sBname							
				else
					return a.nCanGet == 0
				end					
			else
				return a.bNew
			end			
		end)
	end
	return tFriend
end

--是否存在可以鼓舞的对象
function FriendsData:isHadEncFriend( ... )
	-- body
	if not self.tFriends or #self.tFriends <= 0 then
		return false
	end
	local nCnt = 0
	for k, v in pairs(self.tFriends) do
		if v.nCanGet == 0 then
			nCnt = nCnt + 1
		end		
	end
	return nCnt > 0
end

--获取最近联系人
function FriendsData:getRecentCons(  )
	-- body
	return self.tRecentC
end
--获取好友数量
function FriendsData:getFriendsCnt( )
	-- body
	return #self.tFriends
end

--获取最近联系人数量
function FriendsData:getRecentConsCnt( )
	-- body
	return #self.tRecentC
end

--已经获取的体力
function FriendsData:getHadVitCnt(  )
	-- body
	return self.nGet
end

--获取黑名单数量
function FriendsData:getBlacksCnt(  )
	-- body
	return #self.tBlacks
end

--获取黑名单
function FriendsData:getBlacks(  )
	-- body		
	return self.tBlacks
end

--体力列表
function FriendsData:getVitFriends(  )
	-- body
	local tFriends = {}
	for k, v in pairs(self.tFriends) do
		if v.nGive == 1 then
			table.insert(tFriends, v)
		end
	end
	table.sort( tFriends, function ( a, b )
		-- body
		if a.nGetEnergy ~= b.nGetEnergy then
			return a.nGetEnergy < b.nGetEnergy
		else
			return a.nGt > b.nGt				
		end		
	end )		
	return tFriends
end
--添加最近联系人记录 _tData
--_nType 1 SPlayerData 2--chatdata 3 friendvo
--_bChangePos 是否改变最近联系人的顺序
function FriendsData:addRecentRecord( _nID, _tData, _nType, _bChangePos )
	-- body
	if not _nID or not _tData then
		return
	end
	if _nID == Player:getPlayerInfo().pid then
		return
	end	
	local bChange = _bChangePos or false
	local pFriend = self:getRecentFriendById(_nID)	
	if bChange then		
		if pFriend then
			for k, v in pairs(self.tRecentC) do
				if v.sTid == _nID then
					table.remove( self.tRecentC, k )
					break
				end			
			end
			pFriend = nil
		end
		pFriend = FriendVo.new()
	else
		if not pFriend then
			return
		end
	end
	local nType = _nType or 1
	if nType == 1 then--SPlayerData
		pFriend:refreshByChackPlayer(_tData)
	elseif nType == 2 then--chatdata
		pFriend:refreshByChatData(_tData)
	elseif nType == 3 then --friendVo
		pFriend = copyTab(_tData)
	end			
	sendMsg(ghd_chat_icon_refresh_msg, pFriend.sTid) 
	--dump(_tData, "_tData", 100)	
	if bChange then
		table.insert( self.tRecentC, pFriend )
	end	
	self:keepRecentPChatPlayerLimit()
end

--刷新已经获取的体力
function FriendsData:refreshHadGetVit( nCnt )
	-- body
	self.nGet = self.nGet + nCnt
end

--将私聊玩家数量超过30个就删掉之前的
function FriendsData:keepRecentPChatPlayerLimit( )
	local nMax = tonumber(getChatInitParam("nearestListMaxLimit"))
	local nDel = #self.tRecentC - nMax
	if nDel > 0 then
		for i=nDel,1, -1 do
			table.remove(self.tRecentC, i)
		end
	end
end

function FriendsData:isInBlackList( _nID )
	-- body
	if not _nID then
		return false
	end
	if not self.tBlacks or #self.tBlacks <= 0 then
		return false
	end
	for k, v in pairs(self.tBlacks) do
		if v.sTid == _nID then
			return true
		end 
	end
	return false
end
return FriendsData