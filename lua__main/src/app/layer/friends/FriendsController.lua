-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-16 11:46:24 星期一 
-- Description: 好友信息数据
-----------------------------------------------------

local FriendsData = require("app.layer.friends.FriendsData")


--获得玩家建筑单例
function Player:getFriendsData(  )
	-- body
	if not Player.pFriendsData then
		self:initBuildData()
	end
	return Player.pFriendsData
end

-- 初始化玩家建筑数据
function Player:initFriendsData(  )
	if not Player.pFriendsData then
		Player.pFriendsData = FriendsData.new() --玩家的基础信息表
	end
	return "Player.pFriendsData"
end

--释放玩家建筑数据
function Player:releaseFriendsData(  )
	if Player.pFriendsData then
		Player.pFriendsData = nil --玩家的基础信息
	end
	return "Player.pFriendsData"
end

--[4521]添加好友
--MsgType.reqAddFriend = {id = -4521, keys = {"addAid", "addName"}}
SocketManager:registerDataCallBack("reqAddFriend",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "reqAddFriend", 100)
		if __msg.body then			
			Player:getFriendsData():refreshFriendByService(__msg.body)
			sendMsg(gud_refresh_friends_msg)
			sendMsg(ghd_item_home_menu_red_msg)

			TOAST(getConvertedStr(6,10582))
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[-4527]添加好友推送
--MsgType.pushFriendInfo = {id = -4527, keys = {}}
SocketManager:registerDataCallBack("pushFriendInfo",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "pushFriendInfo", 100)
		if __msg.body then
			Player:getFriendsData():refreshFriendByService(__msg.body)	
			sendMsg(gud_refresh_friends_msg)
			sendMsg(ghd_item_home_menu_red_msg)				
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--[4528]删除好友
--MsgType.deleteFriend = {id = -4528, keys = {"deleteAid"}}
SocketManager:registerDataCallBack("deleteFriend",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "deleteFriend", 100)
		if __msg.body then
			Player:getFriendsData():removeFriendById(__msg.body.did)
			sendMsg(gud_refresh_friends_msg) 
			sendMsg(ghd_item_home_menu_red_msg)	
			--删除好友成功
			TOAST(getConvertedStr(6, 10585))					
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--[4530]加载好友列表
--MsgType.loadFriendsInfo = {id = -4530, keys = {}}
SocketManager:registerDataCallBack("loadFriendsInfo",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		--dump(__msg.body, "loadFriendsInfo", 100)
		if __msg.body then
			--登陆的红点数
			-- local tRedNum = {}
			-- local tRs = __msg.body.rs --最近联系人
			-- if tRs and #tRs > 0 then
			-- 	for i=1,#tRs do
			-- 		local nRed = tRs[i].nr
			-- 		local nPid = tRs[i].aid
			-- 		table.insert(tRedNum, {k = nPid, v = nRed})
			-- 	end
			-- 	-- dump(tRedNum)
			-- end
			-- Player:loadPrivateChatRed(tRedNum)
			--

			Player:getFriendsData():refreshDatasByService(__msg.body)		
			sendMsg(gud_refresh_friends_msg) 
			sendMsg(ghd_item_home_menu_red_msg)		
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))				
	end
end)

--[4526]推送好友列表
--MsgType.pushFriendsData = {id = -4526, keys = {}}
SocketManager:registerDataCallBack("pushFriendsData",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		--dump(__msg.body, "pushFriendsData", 100)
		if __msg.body then
			-- --登陆的红点数
			-- local tRedNum = {}
			-- local tRs = __msg.body.rs --最近联系人
			-- if tRs and #tRs > 0 then
			-- 	for i=1,#tRs do
			-- 		local nRed = tRs[i].nr
			-- 		local nPid = tRs[i].aid
			-- 		table.insert(tRedNum, {k = nPid, v = nRed})
			-- 	end
			-- 	-- dump(tRedNum)
			-- end
			-- Player:loadPrivateChatRed(tRedNum)
			--

			Player:getFriendsData():refreshDatasByService(__msg.body)		
			sendMsg(gud_refresh_friends_msg) 
			sendMsg(ghd_item_home_menu_red_msg)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[-4529]删除好友推送
--MsgType.pushdeleteFriend = {id = -4529, keys = {}}
SocketManager:registerDataCallBack("pushdeleteFriend",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "pushdeleteFriend", 100)
		if __msg.body then
			Player:getFriendsData():removeFriendById(__msg.body.did)	
			sendMsg(gud_refresh_friends_msg) 
			sendMsg(ghd_item_home_menu_red_msg)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[4522]赠送好友体力
--MsgType.giveFriendVit = {id = -4522, keys = {"fid"}}
SocketManager:registerDataCallBack("giveFriendVit",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "giveFriendVit", 100)
		if __msg.body and __msg.body.bs then
			local tIDs = __msg.body.bs
			if #tIDs > 0 then			
				for k, v in pairs(tIDs) do
					local tt = {}
					tt["aid"] = v
					tt["on"] = 1
					Player:getFriendsData():refreshFriendPowerByService(tt)	
				end
			end
			sendMsg(gud_refresh_friends_msg)			
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[4524]请求赠送体力列表
--MsgType.reqGiveVitList = {id = -4524, keys = {}}
-- SocketManager:registerDataCallBack("reqGiveVitList",function ( __type, __msg )
-- 	-- body
-- 	if (__msg.head.state == SocketErrorType.success) then
-- 		dump(__msg.body, "reqGiveVitList", 100)
-- 		if __msg.body then
			

-- 		end
-- 	end
-- end)

--[4523]领取赠送的体力
--MsgType.getFriendVit = {id = -4523, keys = {"fid"}}
SocketManager:registerDataCallBack("getFriendVit",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "getFriendVit", 100)
		if __msg.body then
			if __msg.body.bs and #__msg.body.bs > 0 then
				local tIDs = __msg.body.bs
				if #tIDs > 0 then			
					for k, v in pairs(tIDs) do
						local tt = {}
						tt["aid"] = v
						tt["g"] = 1
						Player:getFriendsData():refreshFriendPowerByService(tt)	
					end
					Player:getFriendsData():refreshHadGetVit(#tIDs)
				end
				sendMsg(gud_refresh_friends_msg)
				sendMsg(ghd_item_home_menu_red_msg)				
			end
			if __msg.body.ob then
				showGetAllItems(__msg.body.ob)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[-4525]赠送体力信息推送
--MsgType.pushGiveVit = {id = -4525, keys = {}}
SocketManager:registerDataCallBack("pushGiveVit",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "pushGiveVit", 100)
		if __msg.body then			
			Player:getFriendsData():refreshFriendPowerByService(__msg.body)	
			sendMsg(gud_refresh_friends_msg)
			sendMsg(ghd_item_home_menu_red_msg)	
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[4537]加载最近联系人列表
--MsgType.loadRecentFriends = {id = -4537, keys = {}}
SocketManager:registerDataCallBack("loadRecentFriends",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		--dump(__msg.body, "loadRecentFriends", 100)
		if __msg.body then
			--登陆的红点数
			local tRedNum = {}
			local tRs = __msg.body.rs --最近联系人
			if tRs and #tRs > 0 then
				for i=1,#tRs do
					local nRed = tRs[i].nr
					local nPid = tRs[i].aid
					table.insert(tRedNum, {k = nPid, v = nRed})
				end
				-- dump(tRedNum)
			end
			Player:loadPrivateChatRed(tRedNum)	

			Player:getFriendsData():refreshDatasByService(__msg.body)		
			sendMsg(gud_refresh_friends_msg) 
			sendMsg(ghd_item_home_menu_red_msg)	
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[4512]屏蔽玩家发言
--MsgType.shieldFriend = {id = -4512, keys = {"shieldId", "shieldName"}}
SocketManager:registerDataCallBack("shieldFriend",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		--dump(__msg.body, "shieldFriend", 100)
		if __msg.body then			
			Player:getFriendsData():refreshBlackByService(__msg.body)
			Player:getFriendsData():removeRecentByID(__msg.body.aid)
			sendMsg(gud_refresh_friends_msg)
			--屏蔽成功
			TOAST(getConvertedStr(6, 10587))
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[4513]解除玩家禁言
--MsgType.removeshieldFriend = {id = -4513, keys = {"shieldId"}}
SocketManager:registerDataCallBack("removeshieldFriend",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "removeshieldFriend", 100)
		if __msg.body then
			Player:getFriendsData():removeBlackFriend(__msg.body.aid)
			sendMsg(gud_refresh_friends_msg)
			--解除屏蔽成功
			TOAST(getConvertedStr(6, 10588))
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[4507]点赞玩家
--MsgType.thumbupFriend = {id = -4507, keys = {"accepterId"}}
SocketManager:registerDataCallBack("thumbupFriend",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "thumbupFriend", 100)
		if __msg.body then
			--点赞成功
			TOAST(getConvertedStr(6, 10586))			
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--[4508]推送点赞数据
--MsgType.reqThumbupData = {id = -4508, keys = {"accepterId"}}
SocketManager:registerDataCallBack("reqThumbupData",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "reqThumbupData", 100)
		if __msg.body then
			

		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)


--[4511]聊天信息举报
--MsgType.reqTipOff = {id= -4511, keys = {"chatId", "type", "cause"}}
SocketManager:registerDataCallBack("reqTipOff",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "reqTipOff", 100)
		if __msg.body then
			

		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)

--4531最近联系人推送
--MsgType.pushRecent = {id = -4531, keys = {}}
SocketManager:registerDataCallBack("pushRecent",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		-- dump(__msg.body, "pushRecent", 100)
		if __msg.body then
			Player:getFriendsData():refreshRecentByService(__msg.body)
			sendMsg(gud_refresh_friends_msg)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))			
	end
end)


--被点赞推送
--MsgType.pustthumbupMsg = {id = -4538, keys = {}}
SocketManager:registerDataCallBack("pustthumbupMsg",function ( __type, __msg )
	-- body
	if (__msg.head.state == SocketErrorType.success) then
		--dump(__msg.body, "pushRecent", 100)
		if __msg.body and __msg.body.sn then
			local sTipStr = __msg.body.sn..getConvertedStr(6, 10671) 
			TOAST(sTipStr)
		end	
	end
end)