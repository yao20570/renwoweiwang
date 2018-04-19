----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-01-12 18:12:52 
-- Description: socket请求的管理类
-----------------------------------------------------
import(".msgtype.MsgType1")
import(".msgtype.MsgType2")
import(".msgtype.MsgType3")
import(".msgtype.MsgType4")
import(".msgtype.MsgType5")
import(".msgtype.MsgType6")
import(".msgtype.MsgType7")
import(".msgtype.MsgType8")
import(".msgtype.MsgType9")
import(".msgtype.MsgType10")
cc.net = require("framework.cc.net.init")
local PacketBuffer = import(".PacketBuffer")
local Protocol = import(".Protocol")
local WebSockets = import(".WebSockets")

B_CAN_REAL_SENDDATA = false -- 不能访问Socket接口了
USE_WEBSOCKET = true -- 是否使用websocket
local funcBackList = {} -- 所有回调方法的记录
local funcDataBackList = {} -- 数据回调的方法记录
local netIp = "inner.tmsjyx.com" -- 指定的服务器地址
local port = 10084			-- 端口号

SocketErrorType = { -- socket接口返回的状态类型
    outtime = 99, -- 超时强制返回
	success = 200, -- 成功, 消息默认值状态
    login_from_other = 204, -- 账户在别处登录
    token_unabled = 205, -- 令牌失效
    account_unabled = 575, -- 该帐号禁止在本设备登录
    no_citywar = 314, --本城没有城战
    no_available_army = 696, --兵力不足
}

--登录和重连的协议
tSerDatas = {
    -- 注释：
    -- 参数1：接口名字:
    -- 参数2：是否重连的时候要请求，
    -- 参数3：对应接口（这里的消息只是针对于ghd_开头的）请求后的刷新消息（如果不需要传“”）
    -- 登录接口
    {"login",true},              
    -- 加载玩家信息  
    {"loadPlayer",true,{ghd_unlock_build_msg}},   
     -- 加载建筑信息      
    {"loadBuildDatas",true,{ghd_unlock_build_msg}},    
    -- 加载科技数据
    {"loadTnolyDatas",true,{""}},     
    -- 加载武将数据
    {"loadHeroData",true,{""}}, 
    -- 加载副本数据
    {"loadFubenData",true,{""}},   
    -- 加载活动数据
    {"loadActivity",true,{""}},
    -- 加载城市数据
    {"reqWorldCityData",true,{""}},     
    -- 加载聊天数据
    {"loadChatData",true,{""}},      
    -- 加载背包数据
    {"loadBag",true, {""}},            
    -- 加载资源数据
    {"loadResource",true, {""}},       
    -- 加载我国国战列表
    {"reqWorldMyCountryWar",true,{""}},   
    --加载任务
    {"loadMissions",true, {""}},
    --加载装备
    {"reqEquipLoad",true, {""}},   
    --加载公告
    {"loadNoticeData",true, {""}},
    --加载商品数据
    {"reqShopLoad",true, {""}},
    --加载国家数据
    {"loadCountryInfo",true, {""}},    
    --加载国家官员数据
    {"loadOfficialInfo", true, {""}},
    --加过国家荣誉任务数据
    {"loadCountryGlory", true, {""}},
    --加载国家日志
    {"loadCountryLog", true, {""}},  
    --加载国家城池
    {"loadCountryCity", true, {""}},  
    --加载buff
    {"reqBuffLoad", true, {""}},
    --区域势力归属
    {"reqWorldCenterCity", true, {""}},  
    --加载神兵数据
    {"loadAllWeaponData", true, {""}},
    --加载邮件未读
    {"reqMailNotReadNums" ,true, {""}}, 
    --请求已经引导过的界面数据(建筑引导)
    {"reqGetAlreadyGuided" ,true, {""}}, 
    --世界打我的信息
    {"reqWorldCityWarInfo", true, {""}},
    --请求友军
    {"reqFriendArmys", true, {""}},
    --加载好友列表
    {"loadFriendsInfo", true, {""}},
    --加载最近联系人列表
    {"loadRecentFriends", true, {""}},
    --请求巡逻兵提示
    {"getOpenXLBTips",true,{""}},

    --请求每日宝箱信息
    {"checkDailyGiftRes",true,{""}},
    --请求名将推荐
    {"reqHeroRecommond",true,{""}},    

    --请求触发礼包列表
    {"reqTriggerGift",true,{""}},    
    {"loadNewTriggerGift",true,{""}},    

    --城池首杀
    {"reqCityFirstBlood",true,{""}},  
    --武将游历  
    {"heroTravelRes",true,{""}}, 
    --剧情  
    {"loadChapter",true,{""}}, 
    --竞技场
    {"loadArenaData", true, {""}},
    --每日抢答  
    {"reqEaxmBaseInfo",true,{""}}, 
    --进入抢答房间  
    {"reqExamState",true,{""}}, 
    --加载韬光养晦数据
    {"loadTGYHData", true, {""}},
    --限时Boss
    {"reqTLBossData",true,{""}}, 
    --加载过关斩将数据
    {"loadPassKillHeroData", true, {""}},
    --决战皇城活动开关
    {"reqImperWarOpen",true,{""}},
    --请求国家宝库
    {"asknationaltreasure",true,{""}},
    --请求国家商店数据
    {"loadCountryShop",true,{""}},
    --请求国家任务数据
    {"LoadCountryTask",true,{""}},
    --请求国家科技数据
    {"loadCountryTnoly",true,{""}},
    --
    {"loadcountryhelp",true,{""}},
    --请求皇城战加载线路
    {"reqEpwLine", true, {""}},
    --请求国家宝藏列表
    {"loadCountryTreasureList",true,{""}},
    --请求国家宝藏我的宝藏列表
    {"loadMyCountryTreasure",true,{""}},
    --请求国家求助列表
    {"loadCountryTreasureHelpList",true,{""}},
    --请求皇城战可领取信息
    {"reqEpwAward", true, {""}}

}   


SocketManager = class("SocketManager")
SocketManager.tLastMsgType = {} -- （MsgType）上一个接口的协议号


--获得下一个请求协议
--_bRec：boolean 是否重连
--_nIndex：请求下标
function SocketManager:getNextSer( _bRec, _nIndex )
    -- body
    local nType = 1  --1:表示正常请求，2：请求参数修改  3：加载下一条数据
    local tD = tSerDatas[_nIndex] --请求协议
    local tSecondPar = {}
    if tD then
        local sSocketMsgKey = tD[1]
        if (sSocketMsgKey == "loadCountryGlory") 
            or (sSocketMsgKey == "loadCountryInfo")
            or (sSocketMsgKey == "loadOfficialInfo") 
            or (sSocketMsgKey == "loadCountryCity") 
            or (sSocketMsgKey == "loadCountryLog") 
            or (sSocketMsgKey == "loadCountryShop")
            or (sSocketMsgKey == "LoadCountryTask")
            or (sSocketMsgKey == "loadCountryTnoly")
            or (sSocketMsgKey == "loadCountryTreasureList")
            or (sSocketMsgKey == "loadMyCountryTreasure")
            or (sSocketMsgKey == "loadcountryhelp")            
        then
            if isCountryOpen() == false then
                nType = 3
            end   
        end

        if (sSocketMsgKey == "loadCountryTreasureHelpList") then
            if isCountryOpen() == false then
                nType = 3
            else
                table.insert(tSecondPar, 1)
                table.insert(tSecondPar, 5)
                nType = 2
            end
        end
        --如果没有选择国家就跳过请求世界
        if (sSocketMsgKey == "reqWorldCityData") 
            or (sSocketMsgKey == "reqWorldMyCountryWar") 
            or (sSocketMsgKey == "reqFriendArmys") 
            or (sSocketMsgKey == "loadChatData")
            or (sSocketMsgKey == "reqImperWarFight") 
            or (sSocketMsgKey == "reqEpwLine")
        then
            if isSelectedCountry() == false then
                nType = 3
            end
        end
        --如果没有选择国家就跳过请求
        if (sSocketMsgKey == "reqWorldCityWarInfo") then            
            if isSelectedCountry() == false then
                nType = 3
            else
                table.insert(tSecondPar, Player:getPlayerInfo().pid)
                nType = 2
            end
        end
        --如果竞技场已经解锁        
        if (sSocketMsgKey == "loadArenaData") then
            if not getIsReachOpenCon(28,false) then
                nType = 3
            end            
        end

        --判断是否在答题房间      
        if (sSocketMsgKey == "reqExamState") then
            if Player:getExamData():getJosinState() ~= e_exam_join_state.join then
                nType = 3
            end
        end
        --韬光养晦开启
        if (sSocketMsgKey == "loadTGYHData") then
            if isRemainsOpen() == false then
                nType = 3
            end
        end
        --过关斩将如果满足等级条件才加载
        if (sSocketMsgKey == "loadPassKillHeroData") then
            if Player:getPassKillHeroData():isPassKillHeroOpen() == false then
                nType = 3
            end
        end
        
        if _bRec then           --重连请求
            if tD[2] == false then --该接口不需要请求
                nType = 3
            end
        else                    --登录请求
            if tD[2] then --该接口重连的时候需要请求
                if tD[3] == nil then
                    print("注意：重连接口（" .. tD[1] .. "）没有注册消息名称==============")
                end
            end
        end
    end

    return nType, tD, tSecondPar
end

--检查请求返回数据类型
--_tHeadMsg：请求返回数据
function SocketManager:checkSerCallBackState( _tHeadMsg )
    -- body
    local nErrorType = 1  --默认值1：表示有意义的返回码，2：表示不明返回码，-1：登录游戏服异常
    if _tHeadMsg.type == MsgType.login.id then
        if(SocketErrorType.token_unabled == _tHeadMsg.state) then
            closeDlgByType(e_dlg_index.reconnect,false)
            -- 登录令牌失效，需要重新登录
            showReconnectDlg(e_disnet_type.tok, false, true)
        elseif(SocketErrorType.account_unabled == _tHeadMsg.state) then
            closeDlgByType(e_dlg_index.reconnect,false)
            -- 该帐号禁止在本设备登录
            showReconnectDlg(e_disnet_type.locked, false, true)
        end
        nErrorType = -1
        TOAST(SocketManager:getErrorStr(_tHeadMsg.state))
    else
        nErrorType = 2
        TOAST(SocketManager:getErrorStr(_tHeadMsg.state))
    end
    return nErrorType

    
end

-- 判断socket是否连接着
function SocketManager:isConnected()
    if not self._socket then
        return false
    end
	local isConn;
    if(not USE_WEBSOCKET) then
        isConn= self._socket.isConnected
    else
        isConn= self._socket:isReady()
    end	
	return isConn	
end
-- 关闭socket
function SocketManager:close()
    if self._socket then
        bForceClose = true
        self._socket:close()
        self._socket = nil
    end
    -- 不能访问接口了
    B_CAN_REAL_SENDDATA = false
end
-- 设置域名地址
-- __add(string): 域名地址，包含端口号（例如：http://192.168.1.1:8000）
function SocketManager:setServerAddress(__add)
    if(not __add) then
        return false
    end
    local pos = string.find(__add, ":")
    if pos == nil then
        TOAST(getConvertedStr(1,10073))
        return
    end
    netIp = string.sub(__add, 1, pos-1)
    port = string.sub(__add, pos+1, -1)
end
--连接服务器
function SocketManager:onConnect()
    self._buf = PacketBuffer.new()
    if(not USE_WEBSOCKET) then
	   if not self._socket then
            self._socket = cc.net.SocketTCP.new(netIp, port, false)
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
            self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.onData))
        end
        -- 每帧获取一次数据
        self._socket:connect(netIp, port)
    else
        if not self._socket then
            self._socket = WebSockets.new("ws://" .. netIp .. ":" .. port)
            self._socket:addEventListener(WebSockets.OPEN_EVENT, handler(self, self.onStatus))
            self._socket:addEventListener(WebSockets.CLOSE_EVENT, handler(self, self.onStatus))
            self._socket:addEventListener(WebSockets.ERROR_EVENT, handler(self, self.onStatus))
            self._socket:addEventListener(WebSockets.MESSAGE_EVENT, handler(self, self.onData))
        end
    end
end

function SocketManager:onStatus(_event)
	local nState = -1
	if (not USE_WEBSOCKET) then
		if (_event.name == cc.net.SocketTCP.EVENT_CONNECTED) then
			-- print("socket连接成功")
			nState = 1
		elseif (_event.name == cc.net.SocketTCP.EVENT_CLOSE) then
			nState = 2
			-- print("socket关闭完成")
		elseif (_event.name == cc.net.SocketTCP.EVENT_CLOSED) then
			nState = 3
			-- 这个目前还没有看到会有回调到的地方
		elseif (_event.name == cc.net.SocketTCP.EVENT_CONNECT_FAILURE) then
			nState = 4
			-- print("socket连接失败")
		end
	else
		myprint("socket status " .. _event.name)
		if (_event.name == "OPEN") then
			nState = 1
		elseif (_event.name == "ERROR") then
			myprint("ERROR:" .. _event.error)
			nState = 4
		elseif (_event.name == "CLOSE") then			
			nState = 2			
		end
	
	end

	-- 发送socket链接状态类型
	sendMsg(ghd_socket_connection_event, { nType = nState })
end

-- 注册数据回调接口
-- __type 消息类型,用来得到是哪个消息
-- __func 回调函数
function SocketManager:registerDataCallBack( __type, __func )
    -- body
    local _type = tostring(-MsgType[__type].id) 
    -- 记录数据接口的回调
    if(funcDataBackList[_type] == nil) then
        funcDataBackList[_type] = __func
    end
end

--发送消息
-- __type 消息类型,用来得到是哪个消息
-- _msg 消息体,这里是一个表
-- __func 回调函数
-- __nDelayTime  Dlgloading框延迟时间（-1表是无需loading框， 0表示无需延迟，nil值为默认展示模式，not nil 为具体延迟时间）
function SocketManager:sendMsg(__type, _msg, __func, __nDelayTime, __bReconnect)
    local bConed, bSoc = getIsNetworking() -- 发送前的网络检测
    if(not bConed or not bSoc) then -- 连不上的情况
        myprint("发送"..__type.."异常,当前网络状况:" .. tostring(bConed) .. " 服务器连接状况:" .. tostring(bSoc))
        --回调失败
        local tData = MsgType[__type]
        if(tData) then
            if __func then
                __func(self:createNewErrorMsg(-tData.id), _msg)
            end
        end
        -- 打开重连对话框
        showReconnectDlg(e_disnet_type.cli,true)
        return
    end

    -- 如果登录接口102还没有准备好，不能访问
    if(__type ~= "login") then
        if(not B_CAN_REAL_SENDDATA) then
            print("如果登录接口102还没有准备好，不能访问")
            return
        end
    end

    --loading对话框控制
    local bHadLoadingDlg = true
    if __nDelayTime == nil then
        showLoadingDlg(__type,true)
    elseif __nDelayTime == 0 then
        showLoadingDlg(__type,false)
    elseif __nDelayTime == -1 then
        bHadLoadingDlg = false
    else
       showLoadingDlg(__type,true,__nDelayTime)
    end

    -----------------------------------------------------------------------------------------------
    -- 处理同一个接口不能频繁的请求，间隔不能小于fMinSpace毫秒
    local fCurTime = getSystemTime(false)
    local fMinSpace = 410 -- 最小的请求时间间隔，单位是毫秒
    local fLastSendTime = SocketManager.tLastMsgType[__type] or 0
    if(fCurTime - fLastSendTime <= fMinSpace) then -- 如果不超过fMinSpace毫秒
        -- 执行延迟发送操作，避开频率过于频繁的情况
        if(RootLayerHelper:getCurRootLayer()) then
            local fDe = (fMinSpace-(fCurTime - fLastSendTime)+20)/1000
            if(fDe <= 0.2) then
                fDe = fMinSpace/1000
            end
            local pS = cc.Sequence:create(
                cc.DelayTime:create(fDe),
                cc.CallFunc:create(function (  )
                    -- 刷新loading时间
                    refreshLoadingUpdateTime()
                    -- 重新执行一次接口
                    SocketManager:sendMsg(__type, _msg, __func, __nDelayTime,__bReconnect)
                end))
            RootLayerHelper:getCurRootLayer():runAction(pS)
            return
        end
    end
    -- 记录上一次发送消息的时间
    SocketManager.tLastMsgType[__type] = getSystemTime(false)
    -----------------------------------------------------------------------------------------------

    --判断是否是断网重连
    if __bReconnect == nil then
        __bReconnect = false
    end

    local msgDef = Protocol.getSend(__type)
    local msgbuf = PacketBuffer.createPacket(msgDef, _msg)
    local _type = ""..msgDef.ID
    if(true) then -- 故意模块化而已
		-- 将回调方法存储起来
	    if(funcBackList[_type] == nil) then
	        funcBackList[_type] = {}
	    end
	    -- 插入到最前面，回调的时候，直接拿最后一项
	    local tData = {callFunc = __func, tOldMsg=_msg, bLoading = bHadLoadingDlg, bRec = __bReconnect}
	    table.insert(funcBackList[_type], 1, tData)
    end
    -- 记录数据接口的回调(修改为在注册接收回调的时候去设置)
     if(funcDataBackList[_type] == nil) then
	     funcDataBackList[_type] = MsgType[__type].__dataCallback
	 end
    self._socket:send(msgbuf:getPack())
end
-- 每帧获取到数据之后，会回调到这里来
-- _event（table）: 后端返回的数据内容
function SocketManager:onData( _event )
    local tmsgs = nil
    if(not USE_WEBSOCKET) then
        tmsgs = self._buf:parsePackets(_event.data)
    else
--        local t = {}
--        for i = 1, #_event.message do
--            t[#t + 1] = string.char(_event.message[i])
--        end
--        local binary = table.concat(t)
--        tmsgs = self._buf:parsePackets(binary, _event.message)
        tmsgs = self._buf:parsePackets(_event.message)
    end
    for i, _msg in pairs(tmsgs) do
    	local _type = - _msg.head.type
		local _sub = "" .. _type
        --处理了用户登入游戏服后才可以执行后面的协议请求
        if _msg.head.type == MsgType.login.id then
            B_CAN_REAL_SENDDATA = true
        end
		-- 非超时的情况下，处理数据的重置
		if(_msg.head.state ~= SocketErrorType.outtime) then
			-- 判断是否存在数据回调
			if(funcDataBackList[_sub]) then
                local tFuncs = funcBackList[_sub]   
                if tFuncs then
                    local nCount = #tFuncs
                    local tCurCall = tFuncs[nCount]
                    if tCurCall then
                        funcDataBackList[_sub](_sub, _msg, tCurCall.tOldMsg)
                    else
                        funcDataBackList[_sub](_sub, _msg)
                    end
                else
                   -- myprint("push=" .. _sub)
                    funcDataBackList[_sub](_sub, _msg)
                end
			end
		end
		-- 回调界面刷新的接口
		self:callbackOnMsg(_sub, _msg)
    end
end
-- 回调到上次访问的接口来
-- _sub（string）：当前接口协议的名称
-- _msg（table）：当前返回的数据
function SocketManager:callbackOnMsg( _sub, _msg, _bCallback )
	if(_bCallback == nil) then
        _bCallback = true
    end
    --容错
    if _sub == nil then
        return
    end
    local tFuncs = funcBackList[_sub]        
    if(tFuncs) then
        local nCount = #tFuncs
        if(nCount > 0) then
            local bDataHandled = false
            local tCurCall = tFuncs[nCount]
            table.remove(tFuncs, nCount)--删掉
            if tCurCall then
                local fanc = tCurCall.callFunc
                if(fanc and _bCallback) then
                    -- 界面回调
                    fanc(_msg, tCurCall.tOldMsg)
                end
                --如果有对话框，那么关闭
                if tCurCall.bLoading == true then
                    hideLoadingDlg(true)
                end
            end
            -- 这里置空时不能拿tCurCall去置空，需要置空原始数据
            -- tFuncs[nCount] = nil
            -- nCount = nCount - 1
        end
        local nCount = #tFuncs
        if(nCount <= 0) then
            funcBackList[_sub] = nil
        end
    end
end
-- 创建一个新的错误返回消息包
-- _type(int): 接口的id
function SocketManager:createNewErrorMsg( _id )
    local msg = {}
    local __meta = {}
    __meta.type = _id
    __meta.bodylen = 0
    __meta.id = 0
    __meta.ver = 0
    __meta.state = SocketErrorType.outtime
    msg.head = __meta
    msg.body = {}
    return msg
end
-- 通过id关闭一个接口的回调，_id为正数
-- _id(int): 当前的id值
-- _bCallback(bool)：是否需要回调
function SocketManager:forceCloseCallbackById( _id, _bCallback )
	if(not _id) then
		print("强制关闭的接口id不存在")
		return
	end
	self:callbackOnMsg(_id, self:createNewErrorMsg(-_id), _bCallback)
end
-- 通过消息名称关系一个接口的回调, 
-- _msytype(string): 当前接口的名称
-- _bCallback(bool)：是否需要回调
function SocketManager:forceCloseCallbackByType( _msytype, _bCallback )
	if(not _msytype) then
		print("强制关闭的接口数据不存在")
		return
	end
	local tData = MsgType[_msytype]
	if(tData) then
		self:forceCloseCallbackById(-tData.id, _bCallback)
	end
end
-- 清除所有的界面回调刷新
-- _bCallback(bool)：是否需要回调后再清空
function SocketManager:clearAllCallback( _bCallback )
    myprint("=========================》SocketManager:clearAllCallback( _bCallback )")
	if(funcBackList) then
		if(_bCallback) then
			for i, v in pairs(funcBackList) do
				for jj, vv in pairs(v) do
					self:forceCloseCallbackById(i, false)
				end
			end	
		end
		-- 全部置空
        funcBackList = {}
	end
end

-- 获取错误提示
function SocketManager:getErrorStr( _type )
    -- body
    if tonumber(_type) == 99 then
        return getConvertedStr(1,10070)
    end
    -- 需要返回错误的信息
    return getTipsByIndex(tonumber(_type))
end



return SocketManager