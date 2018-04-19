----------------------------------------------------- 
-- author: liangzhaowei
-- Date: 2017-06-01 14:45:42
-- Description: 聊天数据的管理类
-----------------------------------------------------
local ChatData = require("app.layer.chat.data.ChatData")
local ActorVo = require("app.layer.playerinfo.ActorVo")
e_lt_type = { -- 聊天类型 必须与后端对应
	sj = 1, -- 世界
	lm = 2, -- 军团
	sl = 3, -- 私聊
	gp = 4, -- 滚屏    
}
e_lt_type_count = table.nums(e_lt_type)

-- -1，个人发送/分享
-- 1，世界系统公告
-- 2，国家公告
-- 3，私聊频道
-- 4，国家同区域公告
--频道
e_chat_channel = {
	share = -1,
	world_sys = 1,
	country = 2,
	private_chat = 3,
	country_block = 4,
}



--信息类型 1玩家,2系统信息 3世界喇叭
e_chat_type = {
	player = 1,
	sys = 2,
	horn = 3,
	sysRedPocket = 5,
}

--分享编号id
e_share_id = {
	equip                 =  1,   --装备
	hero                  =  2,   --武将
	weapon                =  3,   --神兵
	exam                  =  22,  --答题
	res_output            =  23,  --我的资源产量
	role_pos              =  24,  --玩家坐标
	city_pos              =  25,  --城池坐标
	world_rank            =  26,  --我当前世界排名
	coutry_rank           =  27,  --我当前国家排名
	boss                  =  35,  --纣王
	countrywar 			  =  42,  --国战
	becitywar 			  =  40,  --被打的求援
	citywar				  =  39,  --打人的求援
	call				  =  41,  --召唤
	bosssupport			  =  43,  --纣王求援
	powermark			  =  52,  --战力评分分享
	arena_aw			  =  53,  --挑战胜利
	arena_dl              =  54,  --防守失败
	arena_dw              =  55,  --防守胜利
	arena_al              =  56,  --挑战失败
	nobility 			  =  57,  --爵位
	tlboss_pos            =  58,  --限时Boss位置
	tlboss_rank           =  59,  --排行榜活动 
	ghostsupport          =  50,  --冥界求援 
	passhero_suc          =  61,  --过关斩将胜利 
	passhero_fail         =  62,  --过关斩将失败 
	imperwar_rank         =  60,  --皇城战排行
	arena_rank		      =	 63,  --竞技场排行
	zhoutril_pos          =  64,  --纣王试炼试图点位置
	epw_state_win         =  65,  --皇城战战况胜利
	epw_state_lose        =  66,  --皇城战战况失败
	country_treasure_help =  67,  --宝藏求助信息
}
MAX_SHOW_CHAT_COUNT_DEFAULT = {}
MAX_SHOW_CHAT_COUNT = {}
FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT = {}
FISRT_MAX_SHOW_CHAT_COUNT = {}



-- N_MAX_SHOW_CHAT_COUNT_DEFAULT = 60   MAX_SHOW_CHAT_COUNT[e_lt_type[sj]]
-- N_FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT = 30
-- N_MAX_SHOW_CHAT_COUNT = N_MAX_SHOW_CHAT_COUNT_DEFAULT             -- 显示最多的条数
-- N_FISRT_MAX_SHOW_CHAT_COUNT = N_FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT -- 进入游戏时初始化的聊天条数
N_CLEAN_MAX_CHAT_COUNT = 150 -- 推送的聊天数量达到此数，发起回收lua数据的行为
local n_every_dc = 1 -- 每次推送出去刷新的条数

local nCurUpCount = 0 -- 当前调用了第几帧
local fMinDisChatTimeShow = 2*60*1000 -- 显示时间的最小间隔
local fLastItemChatTime1 = 0 -- 上一条世界聊天数据的时间
local fLastItemChatTime2 = 0 -- 上一条联盟聊天数据的时间
local fLastItemChatTime3 = 0 -- 上一条私聊聊天数据的时间
local tBackgroungTmpChatDatas = {} -- 从后台回来的临时聊天数据

local nRecallId = nil        -- 当前需要撤回的消息map或id
local nCurrPChatId = nil         -- 当前私聊对象id


--加载聊天信息
SocketManager:registerDataCallBack("loadChatData",function ( __type, __msg )
	if __msg.body then
		-- dump(__msg.body,"chat",10)
		Player:refreshAllChatInfosByService( __msg.body.rec, __msg.body.lbrec, false)

		--sendMsg(ghd_refresh_chat) --通知刷新界面
		sendMsg(gud_refresh_chat) --通知刷新界面延迟更新，因为短线重连时还在e_network_status.ing状态中
        
	end
end)

--聊天信息请求
SocketManager:registerDataCallBack("sendChatData",function ( __type, __msg, __oldMsg )
	--dump(__msg,"sendChatData=",100)
	if __msg.head.state == SocketErrorType.success then
		if __msg.body.valid == 1 and __oldMsg then --是否有效 1则需要用到这条信息
			--官职
			local tCountryDatavo = Player:getCountryData():getCountryDataVo()
   			local nOfficial = nil
   			if tCountryDatavo then
   				nOfficial = tCountryDatavo.nOfficial
   			end
   			--头像id
   			local nHeadId = nil
   			local nHeadBox = nil
   			local nHeadTitle = nil
   			local tAvatarVo = Player:getPlayerInfo():getActorVo()
   			if tAvatarVo then
   				nHeadId = tAvatarVo.sI
   				nHeadBox= tAvatarVo.sB
   				nHeadTitle= tAvatarVo.sT
   			end
   			--模拟消息数据
			local tData = {
				nAccperId = __oldMsg.accperId,
				sid = Player:getPlayerInfo().pid, 
				an = __oldMsg.accName,
				ie = Player:getPlayerInfo().nInfluence,
				bt = nOfficial,
				sn = Player:getPlayerInfo().sName,
				vip = Player:getPlayerInfo().nVip,
				aid = __msg.body.aid, --	List<Integer>	显示渠道
				cnt = __msg.body.cnt, --cnt String	内容
				st = __msg.body.st, --st	Long	消息时间
				tmsg = 1,
				pos = __msg.body.pos, --pos String	地理位置,
				s = Player:getWorldData():getMyCityBlockId(),
				ac = nHeadId,
				lv = Player:getPlayerInfo().nLv,
				box = nHeadBox,
				tit = nHeadTitle,
			}
			--dump(tData, "tData=====", 100)
			Player:addChatInfoToTmp(tData,false)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--聊天信息推送
SocketManager:registerDataCallBack("pushChatData",function ( __type, __msg )
	if __msg.body then
		Player:addChatInfoToTmp( __msg.body ,false)
	end
end)

--通用分享接口
SocketManager:registerDataCallBack("reqShare",function ( __type, __msg )
	if __msg.head.state == SocketErrorType.success then
		-- TOAST(getConvertedStr(7,10070))
		TOAST(getTipsByIndex(10076))
		closeShareAboutDlg()
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--强制撤回信息推送
SocketManager:registerDataCallBack("pushRecallMsg",function ( __type, __msg )
	if __msg.body then
		-- dump(__msg.body, "强制撤回信息推送 --")
		Player:removeRecallItem(__msg.body.id)
	end
end)

--获取单个玩家的聊天记录
SocketManager:registerDataCallBack("privateChatPlayerReq",function ( __type, __msg, __msgOld )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			local nSid = __msgOld[1]
			Player:setPrivateChatList(nSid, __msg.body.rec)
			Player:clearPrivateChatRed(nSid)
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--{4705}抢红包推送
SocketManager:registerDataCallBack("pushcatchredpocket",function ( __type, __msg, __msgOld )
	if __msg.head.state == SocketErrorType.success then
		if __msg.body then
			-- dump(__msg.body, "__msg.body", 100)
			local tData = __msg.body
			local tmp = tData
			tmp.bRP = true
			Player:addChatInfoToTmp( tmp ,false)

		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end)

--{4705}抢红包推送
SocketManager:registerDataCallBack("catchredpocket",function ( __type, __msg, __msgOld )
	if __msg.head.state == SocketErrorType.success then	
		--dump(__msg.body, "__msg.body", 100)
		local pRPData = {}	
		pRPData.nRpId = __msgOld[1]
		pRPData.pData = __msg.body	
		pRPData.nChatID = __msgOld[2]
		pRPData.tChatData = __msgOld[3]
		local tObj = {}
		tObj.nType = e_dlg_index.dlgredpocketcheck
		tObj.pData = pRPData		
		sendMsg(ghd_show_dlg_by_type,tObj)	
		--获得特效
		if __msg.body.ob then
			showGetAllItems(__msg.body.ob)
		end
		Player:updateRedPocketById(__msgOld[3], __msg.body.get) 
		closeDlgByType(e_dlg_index.dlgredpocketopen)  

		local tObj1 = {}
		tObj1.nRpId = __msgOld[1]	
		tObj1.nRpt = __msg.body.get
		sendMsg(ghd_catch_red_pocket,tObj1)	

	else		    
		local nRpId = __msgOld[1]
		showRedPacketDetail(nRpId, __msgOld[2], __msgOld[3])
    end
end)



-- 初始数据
function Player:initChatData()
	Player.tRollChatInfos = {}
	Player.tPrivateChatRedNum = {} --id:红点
	Player.tPrivateChatDict = {} --key为玩家id,value为聊天信息(一开始不推送，需要自己单独请求，有新消息就会推送)
	Player.nLastPChatPlayerId = nil
	Player.tPlayerAvatar = {}
	Player:resetAllChatInfos()
--聊天默认显示最大数量
MAX_SHOW_CHAT_COUNT_DEFAULT = {
	[e_lt_type.sj] = getChatBaseDataByType(e_lt_type.sj).recordcount*2, -- 世界
	[e_lt_type.lm] = getChatBaseDataByType(e_lt_type.lm).recordcount*2, -- 国家
	[e_lt_type.sl] = getChatBaseDataByType(e_lt_type.sl).recordcount*2, -- 私聊
}

--聊天实际显示最大数量(包括喇叭)
MAX_SHOW_CHAT_COUNT = {
	[e_lt_type.sj] = MAX_SHOW_CHAT_COUNT_DEFAULT[e_lt_type.sj], -- 世界
	[e_lt_type.lm] = MAX_SHOW_CHAT_COUNT_DEFAULT[e_lt_type.lm], -- 国家
	[e_lt_type.sl] = MAX_SHOW_CHAT_COUNT_DEFAULT[e_lt_type.sl], -- 私聊
}

--进入游戏时初始化的默认聊天条数
FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT = {
	[e_lt_type.sj] = getChatBaseDataByType(e_lt_type.sj).recordcount, -- 世界
	[e_lt_type.lm] = getChatBaseDataByType(e_lt_type.lm).recordcount, -- 国家
	[e_lt_type.sl] = getChatBaseDataByType(e_lt_type.sl).recordcount, -- 私聊
}

--进入游戏时初始化的聊天实际条数
FISRT_MAX_SHOW_CHAT_COUNT = {
	[e_lt_type.sj] = FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT[e_lt_type.sj], -- 世界
	[e_lt_type.lm] = FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT[e_lt_type.lm], -- 国家
	[e_lt_type.sl] = FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT[e_lt_type.sl], -- 私聊
}
	return "Player.pChatData"
end

-- 移除聊天数据
function Player:removeChatData()
	Player.tRollChatInfos = {}
	Player.nLastPChatPlayerId = nil
	Player:resetAllChatInfos()
	return "Player.pChatData"
end

-- -- 根据服务端数据加载本地聊天数据
-- -- tData（table）：服务端数据
-- -- bUp(bool):是否需要刷新界面
-- function Player:loadAllChatInfosByService( tData )

-- 	if tData and table.nums(tData)>0 then
-- 		--根据聊天信息内容以及类型分配聊天数据
-- 		for k,v in pairs(tData) do
-- 			if v.aid and table.nums(v.aid) > 0 then --聊天类型数组
-- 				for x,y in pairs(v.aid) do
-- 					table.insert(Player.chatInfos[y],v)--根据后端的聊天类型分离聊天数据
-- 				end
-- 			end
-- 		end
-- 	end
-- end


--判断当前滚屏数据是否已经在播放记录表里面
function Player:isHaveRoll( _nId )
	if not _nId then
		return true
	end
	for k,v in pairs(Player.tRollChatInfos or {}) do
		if v and v.id == _nId then
			return true 
		end
	end
	return false 
end
-- 重置所有的聊天数据
function Player:resetAllChatInfos( )
    -- 服务器临时数据
	Player.tSeverTmpDatas = {} 
	Player.tSeverTmpDatas[e_lt_type.sj] = {} -- 世界
	Player.tSeverTmpDatas[e_lt_type.lm] = {} -- 军团
	Player.tSeverTmpDatas[e_lt_type.sl] = {} -- 私聊
	Player.tSeverTmpDatas[e_lt_type.gp] = {} -- 滚屏

    -- 所有的聊天数据
	Player.chatInfos = {} 
	Player.chatInfos[e_lt_type.sj] = {} -- 世界
	Player.chatInfos[e_lt_type.lm] = {} -- 军团
	Player.chatInfos[e_lt_type.sl] = {} -- 私聊
	Player.chatInfos[e_lt_type.gp] = {} -- 滚屏

	Player.fLastSendChatTime = 0 -- 最后发言的时间
	Player.chatRedCount = {}
	for i=1, 4, 1 do
		if i == e_lt_type.sl then
			Player.chatRedCount[i] = Player:getPrivateChatByPlayer()
		else
			Player.chatRedCount[i] = 0
		end
	end
	Player.bIsChatReset = true -- 是否重置了聊天消息
	tBackgroungTmpChatDatas = {}

	nCurrPChatId = nil
end

-- 根据类型获取数据列表
-- nType(e_lt_type): 1世界，2军团，3私聊, 4滚屏 
--只提供前20条数据
-- nPlayerId 私聊对象
-- return(table): 只提供前nLeftCount条数据
function Player:getChatInfoByType(nType, nLeftCount, nPlayerId)
    -- nType 私聊特殊处理
    if nType == e_lt_type.sl and nPlayerId then
        return Player:getPrivateChatByPlayer(nPlayerId)
    end

    local tList = Player.chatInfos[nType]
    if (tList == nil) then
        tList = { }
    end

    if (nLeftCount) then
        if (tList and #tList > nLeftCount) then
            -- 清除掉多余的
            for i = #tList - nLeftCount, 1, -1 do
                table.remove(tList, i)
            end
        end

    end
    return tList
end
--获取系统滚频信息
function Player:getSystemNoticeData( nLoginTime )
	-- body
	local tList = Player.chatInfos[e_lt_type.gp]
	if(tList == nil) then
		tList = {}
	end
	local tNotices = {}
	for k, v in pairs(tList) do
		if v.nSt > nLoginTime then
			table.insert(tNotices, v)
		end
	end
	return tNotices	
end
-- 根据服务端数据刷新本地聊天数据
-- tData（table）：服务端数据
-- tLabaData(table) : 世界喇叭数据
-- bUp(bool):是否需要刷新界面
function Player:refreshAllChatInfosByService( tData, tLabaData, bUp )
	--分类聊天信息
	local tServerChat = {}

	tServerChat[e_lt_type.sj] = {} -- 世界
	tServerChat[e_lt_type.lm] = {} -- 军团
	tServerChat[e_lt_type.sl] = {} -- 私聊
	tServerChat[e_lt_type.gp] = {} -- 滚屏


	if tData then
		--根据聊天信息内容以及类型分配聊天数据
		self:insertChatData(tData, tServerChat)
	end

	if tLabaData then
		local nLaba = table.nums(tLabaData)
		if nLaba > 0 then
			-- N_MAX_SHOW_CHAT_COUNT = nLaba + N_MAX_SHOW_CHAT_COUNT_DEFAULT
			-- N_FISRT_MAX_SHOW_CHAT_COUNT = nLaba + N_FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT

			--世界聊天显示数改变(加上喇叭数)
			local nType = e_lt_type.sj
			MAX_SHOW_CHAT_COUNT[nType] = nLaba + MAX_SHOW_CHAT_COUNT_DEFAULT[nType]
			FISRT_MAX_SHOW_CHAT_COUNT[nType] = nLaba + FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT[nType]
			--国家聊天数改变(加上喇叭数)
			local nType = e_lt_type.lm
			MAX_SHOW_CHAT_COUNT[nType] = nLaba + MAX_SHOW_CHAT_COUNT_DEFAULT[nType]
			FISRT_MAX_SHOW_CHAT_COUNT[nType] = nLaba + FISRT_MAX_SHOW_CHAT_COUNT_DEFAULT[nType]

			self:insertChatData(tLabaData, tServerChat, true)
		end
	end

	-- dump(tServerChat,"tServerChat")


	--根据类型初始化每条聊天数据
	for k,v in pairs(tServerChat) do
		local nMax = #v
		for x,y in pairs(v) do
			if ((nMax-x) < FISRT_MAX_SHOW_CHAT_COUNT[k]) then
				self:addingChatInfoByService(y, bUp)
			end
		end
	end
end

function Player:insertChatData( tData, tServerChat, bBefore)
	-- body
	for k,v in pairs(tData) do
		if v.aid and #v.aid > 0 then --聊天类型数组
			for x,y in pairs(v.aid) do
				local pData = copyTab(v)
				pData.nAccperId = y
				if tServerChat[y] and y ~= e_lt_type.gp then --登录时不需要滚屏信息
					if bBefore then
						table.insert(tServerChat[y], 1, pData)--根据后端的聊天类型分离聊天数据
					else
						table.insert(tServerChat[y], pData)--根据后端的聊天类型分离聊天数据
					end
				end
			end
		end
	end
end

-- 增加单条数据到列表中
-- tData(table): 服务器的数据
-- bUp(bool):是否需要刷新界面
function Player:addingChatInfoByService( tData, bUp )
	if(not tData) then
		return
	end
	if(bUp == nil) then
		bUp = false
	end
	local nType = tData.nAccperId --接收者类型
	local bRP = tData.bRP or false
	-- dump(nType,"addingChatInfoByService....nType")
	local tList = Player:getChatInfoByType(nType)
	local pTemp = ChatData.new()
	pTemp:refreshByService(tData)
	pTemp.bRP = bRP
	if bRP then
		local sStr = {
			{color=_cc.white, text=string.format(getConvertedStr(6, 10627), pTemp.sSn)},
			{color=_cc.syellow, text=getConvertedStr(6, 10621)}
		}
		pTemp.sCnt = sStr
	end
	--记录玩家头像
	if not bRP then
		self:recordPlayerAvatars(tData)
	end
	-- dump(tList,"tList")
	-- dump(pTemp,"pTemp")

	-- if (bUp == false) then
	-- 	pTemp.bLoadData = true -- 请求服务器加载的数据（非推送数据）
	-- end
	if(tList) then
		-- 先加入列表中
		table.insert(tList, pTemp)

		-- dump(tList,"tList")
		if(nType == 1) then
			-- 超过10分钟
			if((pTemp.nSt - fLastItemChatTime1) >= fMinDisChatTimeShow) then
				pTemp.bShTime = true
			end
			fLastItemChatTime1 = pTemp.nSt
		elseif(nType == 2) then
			-- 超过10分钟
			if((pTemp.nSt - fLastItemChatTime2) >= fMinDisChatTimeShow) then
				pTemp.bShTime = true
			end
			fLastItemChatTime2 = pTemp.nSt
		elseif(nType == 3) then
			-- 超过10分钟
			if((pTemp.nSt - fLastItemChatTime3) >= fMinDisChatTimeShow) then
				pTemp.bShTime = true
			end
			fLastItemChatTime3 = pTemp.nSt
			--记录私聊
			Player:getFriendsData():addRecentRecord(pTemp.nSid, tData, 2, true)
		end
		-- 强制不显示分割时间
		pTemp.bShTime = false
		
		-- 如果是私聊的就单独加入列表中
		if nType == e_lt_type.sl then
			Player:addPrivateChatOne(pTemp)
		end

		if(bUp) then
			--如果该条消息是正在撤回的消息就不刷新界面
			if pTemp.nMap == nRecallId or pTemp.nId == nRecallId then  
				return
			end
			local tMsg = {}
			tMsg.nType = nType
			tMsg.nPlayerId = pTemp:getPChatPlayerId()
			tMsg.sPlayerName = pTemp:getPChatPlayerName()
			tMsg.nSenderId = pTemp.nSid
			sendMsg(ghd_refresh_chat,tMsg) --通知刷新界面


			if (not Player.chatRedCount[nType]) then
				Player.chatRedCount[nType] = 0
			end


			local pChatBase =  getChatBaseDataByType(nType)
			if pChatBase and pChatBase.recordcount then
				if Player.chatRedCount[nType] < pChatBase.recordcount then
					Player.chatRedCount[nType] = Player.chatRedCount[nType]+1
				end
			else
				Player.chatRedCount[nType] = Player.chatRedCount[nType]+1
			end

			-- 发送红点提示
			local tRedMsg = {}
			tRedMsg.nType = nType
			tRedMsg.nReds = Player.chatRedCount[nType]

			-- dump(tRedMsg.nReds,"tRedMsg.nReds")
			sendMsg(gud_refresh_chat_red,tRedMsg)


		end
	end
end
-- 将服务端的聊天数据临时保存起来（定时多少帧提交一条数据去刷新）
-- tData（table）：服务端数据
-- bForceAdd(bool): 是否强制推送键入
function Player:addChatInfoToTmp( _tData, bForceAdd )
	if(not _tData) then
		return
	end
	if(bForceAdd == nil) then
		bForceAdd = false
	end

	--喇叭发送时的消息
	-- if getIsNeedSendChatMsg() then
	-- 	bForceAdd = true
	-- end
	local tData = _tData
	-- 如果是玩家自己的发的消息，并且不是私聊的，直接返回
	-- if(not bForceAdd) then
	-- 	if(b_open_ss_chat and (tData.sid and tData.sid == Player:getPlayerInfo().pid)) then 
	-- 		return
	-- 	end
	-- end
    
    --放进显示缓存列表
	if tData.aid and #tData.aid > 0 then
		for k,v in pairs(tData.aid) do
			local pData = copyTab(tData)
			pData.nAccperId = v --加入聊天接受者类型
            
            -- 加入到临时表
			table.insert(Player.tSeverTmpDatas[v], pData) 

            -- 多于上限，则先移除(私聊得再到下一数据层,滚屏每上限)
            if v == e_lt_type.sj or v == e_lt_type.lm then
                if #Player.tSeverTmpDatas[v] > MAX_SHOW_CHAT_COUNT_DEFAULT[v] then
                    table.remove(Player.tSeverTmpDatas[v], 1)
                end
            end

		end
	end
	
    
end

-- addShareInfoToTep

-- 清除多余的条目
function Player:removeOutIndexChatInfos( nType )
	local tList = Player:getChatInfoByType(nType) 
	if(tList) then
		local nTotoal = #tList
		if(nTotoal > MAX_SHOW_CHAT_COUNT[nType]) then
			-- for i=nTotoal-N_MAX_SHOW_CHAT_COUNT, 1, -1 do
			-- 	-- 删除一条数据，并且删除控件
			-- 	local pMsgObj = MsgObj.new(nType, 0)
			-- 	pMsgObj.nDeleteIndex = i
			-- 	sendMsg(MSG_CHAT_CHANGED, pMsgObj)
			-- 	-- 实际从列表中清除数据
			-- 	table.remove(tList, i)
			-- end
		end
	end
end

--清除服务器推送的需要清除的条目(暂时只有滚屏才会撤销)
--_nId:需要撤回的聊天记录id
function Player:removeRecallItem(_nId)
	-- body
	nRecallId = _nId
	local num = e_lt_type_count
	local tRecallType = {}  --需要撤回的类型放这里
	for i = 1, num do
		local bCanSend = false
		local tList = Player:getChatInfoByType(i)
		for k = #tList, 1, -1 do
			local tData = tList[k]
			if tData.nMap == _nId or tData.nId == _nId then
				table.remove(tList, k)
				bCanSend = true
			end
		end
		if bCanSend then
			table.insert(tRecallType, i)
		end
	end
	local tMsg = {}
	tMsg.tRecallType = tRecallType
	tMsg.nRecallId = nRecallId
	sendMsg(ghd_refresh_recall_chat, tMsg) --通知刷新界面
end

-- 分发聊天数据到
function doDelieverChatInfo()
    -- 每5帧分发一次聊天数据到UI取渲染
    nCurUpCount = nCurUpCount + 1
    if (nCurUpCount > e_lt_type_count) then
        -- 归零，开始新的循环
        nCurUpCount = 0
    else
        -- 推送n_every_dc条聊天到UI
        local tTempChatDatas = Player.tSeverTmpDatas[nCurUpCount]
        if tTempChatDatas ~= nil and tTempChatDatas[1] ~= nil then
            Player:addingChatInfoByService(tTempChatDatas[1], true)            
            table.remove(tTempChatDatas, 1)-- 加入后删除掉数据
        end
    end
end


-- 恢复后台回来后，聊天数据的正常展示
function resetBackgroundTmpDatas(  )
	if(tBackgroungTmpChatDatas) then
		for i, v in pairs(tBackgroungTmpChatDatas) do
			Player:addChatInfoToTmp(v)
		end
		tBackgroungTmpChatDatas = {}
	end
end


----------------------------------------------------------私聊
--登陆私聊红点
--tData:List<Pair<k,v>> 列表 k nSid, v RedNum
function Player:loadPrivateChatRed( tData )
	if not tData then
		return
	end
	for i=1,#tData do
		local nSid = tonumber(tData[i].k)
		local nRedNum = tData[i].v
		if nSid and nRedNum then
			Player.tPrivateChatRedNum[nSid] = nRedNum
			Player.nLastPChatPlayerId = nSid
		end
	end

	Player.chatRedCount[e_lt_type.sl] = Player:getAllPrivateChatRed()
end

--私聊红点增加
--nSid:私聊发送者id
function Player:addPrivateChatRed( nSid )
	if not nSid then
		return
	end

	--当前私聊id不加红点
	if nCurrPChatId == nSid then
		return
	end

	local nRedNum = Player.tPrivateChatRedNum[nSid] or 0
	nRedNum = nRedNum + 1
	
	local pChatBase =  getChatBaseDataByType(e_lt_type.sl)
	if pChatBase and pChatBase.recordcount then
		nRedNum = math.min(nRedNum, pChatBase.recordcount)
	end
	Player.tPrivateChatRedNum[nSid] = nRedNum
	Player.nLastPChatPlayerId = nSid

	--更新红点
	local tRedMsg = {}
	tRedMsg.nType = e_lt_type.sl
	tRedMsg.nReds = Player:getAllPrivateChatRed()
	sendMsg(gud_refresh_sl_chat_red, tRedMsg)
end

--清空某个玩家红点信息
--nSid:私聊发送者id
function Player:clearPrivateChatRed( nSid )
	if not nSid then
		return
	end
	Player.tPrivateChatRedNum[nSid] = nil

	--更新红点
	local tRedMsg = {}
	tRedMsg.nType = e_lt_type.sl
	tRedMsg.nReds = Player:getAllPrivateChatRed( )
	sendMsg(gud_refresh_sl_chat_red, tRedMsg)
end

--获取红点信息
function Player:getPrivateChatRed( nSid )
	return Player.tPrivateChatRedNum[nSid] or 0
end

--获取全部私聊总数
function Player:getAllPrivateChatRed( nNoInSid )
	local nCount = 0
	for k,v in pairs(Player.tPrivateChatRedNum) do
		if k ~= nNoInSid then
			nCount = nCount + v
		end
	end
	return nCount
end

--根据玩家获取私聊信息
--nSid 目标玩家id
function Player:getPrivateChatByPlayer( nSid )
	if not nSid then
		return {}
	end
	return Player.tPrivateChatDict[nSid] or {}
end

--设置玩家私聊信息列表
--nSid：玩家id
--tData：PrivateChatRes 列表
function Player:setPrivateChatList( nSid, tData )
	if not nSid then
		return
	end

	--清空信息
	Player.tPrivateChatDict[nSid] = nil

	if not tData then
		return	
	end

	--设置数据
	local tMsgList = {}
	for i=1,#tData do
		local pTemp = ChatData.new()
		pTemp:refreshByService(tData[i])
		table.insert(tMsgList, pTemp)
	end
	if #tData > 0 then 
		self:recordPlayerAvatars(tData[#tData])			
	end
	--超过30条就删除
	local pChatBase =  getChatBaseDataByType(e_lt_type.sl)
	if pChatBase and pChatBase.recordcount then
		-- 清除掉多余的
		for i=#tMsgList-pChatBase.recordcount*2, 1, -1 do
			table.remove(tMsgList, i)
		end
	end
	Player.tPrivateChatDict[nSid] = tMsgList
end

--插入玩家私聊信息单列
--tData: ChatData
function Player:addPrivateChatOne( tData )
	if not tData then
		return
	end
	--容错
	local nSid = tData:getPChatPlayerId()
	if not nSid then
		return
	end
	local tMsgList = Player.tPrivateChatDict[nSid] or {}
	table.insert(tMsgList, tData)

	--超过30条就删除
	local pChatBase =  getChatBaseDataByType(e_lt_type.sl)
	if pChatBase and pChatBase.recordcount then
		-- 清除掉多余的
		for i=#tMsgList-pChatBase.recordcount*2, 1, -1 do
			table.remove(tMsgList, i)
		end
	end
	Player.tPrivateChatDict[nSid] = tMsgList

	--更新红点信息
	if tData.nSid ~= Player:getPlayerInfo().pid then
		Player:addPrivateChatRed(nSid)
	end
end

--获取私聊红点
function Player:getTabChatRedCount( nType )
	return Player.chatRedCount[nType]
end

--清空Tab按钮上的聊天红点(点击切换卡时调用)
function Player:clearTabChatRedCount( nType )
	if not nType then
		return
	end
	if nType == e_lt_type.sl then
		return
	end
	local nCount = Player.chatRedCount[nType]
	if nCount > 0 then
		Player.chatRedCount[nType] = 0
		local tRedMsg = {}
		tRedMsg.nType = nType
		tRedMsg.nReds = 0
		sendMsg(gud_refresh_chat_red,tRedMsg)
	end
end

--获取最新的聊天玩家id（已废弃）
function Player:getLastPChatPlayerId( )
	return Player.nLastPChatPlayerId
end
----------------------------------------------------------私聊
--记录玩家的头像数据
function Player:recordPlayerAvatars( pTemp )
	-- body
	if not pTemp then
		return
	end
	local nSid = tonumber(pTemp.sid or 0)
	local bRefresh = false
	if not self.tPlayerAvatar then
		self.tPlayerAvatar = {}
	end
	if not self.tPlayerAvatar[nSid] then		
		self.tPlayerAvatar[nSid] = ActorVo.new()
		self.tPlayerAvatar[nSid]:initData(pTemp.ac, pTemp.box, pTemp.tit)
		bRefresh = true
	else
		local pAvatar = self.tPlayerAvatar[nSid]
		if pTemp.tmsg == 1 and (pAvatar.sI ~= pTemp.ac or pAvatar.sB ~= pTemp.box or pAvatar.sT ~= pTemp.tit) then
			self.tPlayerAvatar[nSid]:initData(pTemp.ac, pTemp.box, pTemp.tit)
			bRefresh = true
		end
	end	
	if bRefresh then
		sendMsg(ghd_chat_icon_refresh_msg, nSid) 
	end	
end

function Player:recordPlayerCardInfo( pTemp )
	-- body
	if not pTemp then
		return
	end
	local nSid = tonumber(pTemp.nID or 0)
	local bRefresh = false
	if not self.tPlayerAvatar then
		self.tPlayerAvatar = {}
	end
	if not self.tPlayerAvatar[nSid] then		
		self.tPlayerAvatar[nSid] = ActorVo.new()
		self.tPlayerAvatar[nSid]:initData(pTemp.sI, pTemp.sB, pTemp.sT)
		bRefresh = true
	else
		local pAvatar = self.tPlayerAvatar[nSid]
		if pAvatar.sI ~= pTemp.sI or pAvatar.sB ~= pTemp.sB or pAvatar.sT ~= pTemp.sB then
			self.tPlayerAvatar[nSid]:initData(pTemp.sI, pTemp.sB, pTemp.sT)
			bRefresh = true
		end
	end	
	if bRefresh then
		sendMsg(ghd_chat_icon_refresh_msg, nSid) 
	end	
end

--获取头像
function Player:getChatAvatorById( _nId )
	-- body	
	return self.tPlayerAvatar[_nId]
end
--刷新红包数据状态
function Player:updateRedPocketById( _nId, _nRpt )
	-- body
	local tChatData = nil
	if not _nId then
		return nil
	end
	for k, v in pairs(Player.chatInfos[e_lt_type.sj]) do
		if v.nId == _nId then
			tChatData = v			
		end
	end
	if not tChatData then
		for k, v in pairs(Player.chatInfos[e_lt_type.lm]) do
			if v.nId == _nId then
				tChatData = v			
			end
		end
	end
	if tChatData then
		tChatData:updateRedPock(_nRpt)			
		sendMsg(ghd_refresh_redpocket_msg, _nId)		
	end
end

--设置当前私聊的玩家id
function Player:setCurrPChatId( nPChatId )
	nCurrPChatId = nPChatId
end

--获取当前私聊的玩家id
function Player:getCurrPChatId(  )
	return nCurrPChatId
end

--关闭私聊对象红点记录
function Player:closePlayerPrivateChat(  )
	local nPlayerId = Player:getCurrPChatId()
	if nPlayerId then
		SocketManager:sendMsg("closePlayerPrivateChat", {nPlayerId})
		Player:setCurrPChatId(nil)
	end
end