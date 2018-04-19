-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-24 11:00:07 星期五
-- Description: 重连对话框

-- 1.在游戏内断网，自动重连2次，失败后弹框重连2次，再失败后弹出重登框（重连成功不跳回主基地）
-- 2.后台切前台半个~1小时内，自动重连2次，失败后弹框重连2次，再失败后弹出重登框（重连成功跳回主基地）
-- 3.后台切前台超过1小时，进入游戏弹出重新登录框，点击回到登录选服界面（登录成功回到主基地）


--注意：弹出重连框默认都是自动重连
-- 		该对话框有两个失败次数 self.nFailCount 和 Player.nReconnetCount ，一个处理在展示重连框下的操作行为 一个处理是否自动重连
-----------------------------------------------------

local e_rectype_doing = { -- 当前的重连类型
	nti = -1, -- 无类型
	cnw = 0, -- 检测网络类型
	soc = 1, -- socket连接类型
	log = 2, -- 登录游戏类型
}

local MDialog = require("app.common.dialog.MDialog")
local DlgReconnect = class("DlgReconnect", function ()
	return MDialog.new()
end)

--bAuto：是否自动重连
--nCurType：重连类型
--nSecType：子类型
function DlgReconnect:ctor(bAuto, nCurType, nSecType)
	self:myInit()

	if bAuto == nil then
		bAuto = true
	end
	self.bAutoLink = bAuto
	self.nCurType = nCurType
	self.nSecType = nSecType or self.nSecType

    self:setIsNeedOutside(false)
    parseView("dlg_reconnect", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function DlgReconnect:myInit()
	self.eDlgType 		= e_dlg_index.reconnect  -- 对话框类型
	self.nCurType 		= e_disnet_type.cli      -- 0是断网了，1是帐号在其他地方登录了，2是服务端切换socket连接
	self.nSecType 		= e_second_type.normal   -- 第二类型
	self.bAutoLink 		= true                   -- 是否自动重连


    self.nUpHandler 	= nil                    -- 置空定时器
	self.fLastRecTime 	= 0                      -- 记录本次重新连接的时间
    self.nRecType 		= e_rectype_doing.nti    -- e_rectype_doing定义在文件顶部
    self.nRecCount 		= 0                      -- 第几次重连
    self.nFailCount 	= 0                      -- 重连失败的次数


    --重连后加载的协议
    self.nCurIndex  	= 0
	self.nCurFinishCount = 0                    -- 成功的个数
	self.nCurFailedCount = 0                    -- 失败的个数
end

--解析布局回调事件
function DlgReconnect:onParseViewCallback( pView )
	-- body
	self.pRecView = pView
	self:setContentView(self.pRecView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
    self:setDestroyHandler("DlgReconnect",handler(self, self.onDlgReconnectDestroy))
	
	if self.bAutoLink then
		self:doReconnect()
	end
end

--初始化控件
function DlgReconnect:setupViews()
	--最顶层
	self.pLayDefault 			=	self.pRecView:findViewByName("default")
	--描述层
	self.pLayBase 				= 	self.pRecView:findViewByName("viewgroup")
	--标题
	self.pLbTitle 				= 	self.pRecView:findViewByName("lb_title")
	setTextCCColor(self.pLbTitle,_cc.white)
	self.pLbTitle:setString(getConvertedStr(1, 10218))
	--内容
	self.pLbContent 			= 	self.pRecView:findViewByName("lb_msg")
	setTextCCColor(self.pLbContent,_cc.pwhite)
	--按钮
	self.pLayAction 			= 	self.pRecView:findViewByName("lay_action") 
	self.pBtnAction = getCommonButtonOfContainer(self.pLayAction,TypeCommonBtn.L_BLUE,getConvertedStr(1,10220))
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onActionClicked))

end

--修改控件内容或者是刷新控件数据
function DlgReconnect:updateViews()
	if(self.nCurType == e_disnet_type.ser) then -- 服务器强断socket
		self.pLbContent:setString(getConvertedStr(1, 10222))
		self.pBtnAction:updateBtnText(getConvertedStr(1, 10224))
	elseif(self.nCurType == e_disnet_type.acc) then -- 帐号在其他地方登录
		self.pLbContent:setString(getConvertedStr(1, 10225))
		self.pBtnAction:updateBtnText(getConvertedStr(1, 10224))
	elseif(self.nCurType == e_disnet_type.tok) then -- 令牌失效
		self.pLbContent:setString(getConvertedStr(1, 10226))
		self.pBtnAction:updateBtnText(getConvertedStr(1, 10224))
	elseif(self.nCurType == e_disnet_type.locked) then -- 帐号被封
		self.pLbContent:setString(getConvertedStr(1, 10227))
		self.pBtnAction:updateBtnText(getConvertedStr(1, 10224))
	else -- 网络异常
		if(getCurConStatus() == e_network_status.ing) then
			self.pLbContent:setString(getConvertedStr(1, 10228))
			self.pBtnAction:updateBtnText(getConvertedStr(1, 10223))
			self.pBtnAction:onCommonBtnClicked(handler(self, self.onExitClicked))
		else
			self.pLbContent:setString(getConvertedStr(1, 10229))
			self.pBtnAction:updateBtnText(getConvertedStr(1, 10220))
			self.pBtnAction:onCommonBtnClicked(handler(self, self.onExitClicked))
		end
	end
end

--析构方法
function DlgReconnect:onDlgReconnectDestroy()
	--强制关闭所有接口
	self:closeAllDoing()
	self:destroyHandler()
end


-- 执行重新连接socket
function DlgReconnect:doReconnect(  )
	-- 启用定时器
	self:restartUpdate()
	-- 切换连接状态
	exchangeConStatus(e_network_status.ing)
    -- 切换状态
	self:changeLoadingState(true)
	-- 记录本次重新连接的时间
    self.fLastRecTime = getSystemTime()
	-- 如果网络状态不管用，启动过程判断网络状态
	local bNet, bSoc = getIsNetworking()
	if((not bNet)  and device.platform ~= "windows") then
		self.nRecType = e_rectype_doing.cnw -- 类型定义为检测网络状态
		return
	end
    self.nRecCount = self.nRecCount + 1
    -- 强制关闭链接
	SocketManager:close()
	self.nRecType = e_rectype_doing.soc -- 类型定义为socket重连
	-- 重新连接
    SocketManager:onConnect()
end

-- 重启定时器
function DlgReconnect:restartUpdate(  )
	if(not self.nUpHandler) then
	    self.nUpHandler = MUI.scheduler.scheduleGlobal(
	        handler(self, self.onUpdateTime), 0.7)
	end
end

-- 取消handler
function DlgReconnect:destroyHandler(  )
	-- 取消定时刷新
    if(self.nUpHandler ~= nil) then
        MUI.scheduler.unscheduleGlobal(self.nUpHandler)
        self.nUpHandler = nil
    end
end

-- 每秒刷新
function DlgReconnect:onUpdateTime(  )
	if(getCurConStatus() ~= e_network_status.ing) then
		-- 暂停定时器
		self:destroyHandler()
		return
	end
	local fDis = getSystemTime() - self.fLastRecTime
	if(self.nRecType == e_rectype_doing.cnw) then -- 检测网络状态
		-- 网络恢复正常，直接执行重新连接
		local bNet, bSoc = getIsNetworking()
		if(bNet) then
			self:doReconnect()
			return
		end
		-- 如果检测超时了，执行超时显示
		if(fDis >= f_outtime_checknet) then
			self:onCheckNetFailed()
		end
	elseif(self.nRecType == e_rectype_doing.soc) then -- socket连接
		-- 如果已经连接上了
		if(SocketManager:isConnected()) then
			self:doLogin()
			return
		end
		if(fDis >= f_outtime_connect_socket) then
			-- 检测尝试的次数
			self:checkSocketRetryTime()
		end
	elseif(self.nRecType == e_rectype_doing.log) then
		if(fDis >= f_outtime_reconnect) then
			-- 重连失败
			self:onConnectFailed()
		end
	end
end

-- 检测是否超过次数
function DlgReconnect:checkSocketRetryTime( )
	-- 超过次数
	if(self.nRecCount >= f_outtime_count_socket) then
		-- 重连失败
		self:onSocketLinkFailed()
	else
		-- 强制断开连接
		SocketManager:close()
		-- 重新启动
		self:doReconnect()
	end
end

-- 检测网络状态超时了
function DlgReconnect:onCheckNetFailed(  )
	-- 网络状态异常，稍后重试
	self.pLbContent:setString(getConvertedStr(1, 10221))
	self.pBtnAction:updateBtnText(getConvertedStr(1, 10220))
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onActionClicked))
	-- 记录失败状态
	self:onConnectFailed()
end

-- socket连接失败
function DlgReconnect:onSocketLinkFailed( )
	-- 网络状态异常，稍后重试
	self.pLbContent:setString(getConvertedStr(1, 10221))
	self.pBtnAction:updateBtnText(getConvertedStr(1, 10220))
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onActionClicked))
	-- 记录失败状态
	self:onConnectFailed()
end

-- 切换loading状态
function DlgReconnect:changeLoadingState( bShowLoading )
	if(bShowLoading) then
		-- 增加loading框
		addLoadingAction(self.pLayDefault)
		self.pLayBase:setVisible(false)
	else
		-- 删除loading框
		releaseLoadingAction(self.pLayDefault)
		self.pLayBase:setVisible(true)
	end
	-- 改变背景颜色
	self:changeBackColor(bShowLoading)
end

-- 展示背景的颜色
-- bShowLoading（boolean）：是否展示loading圈
function DlgReconnect:changeBackColor( bShowLoading )
	if(bShowLoading) then
		-- 取消半透明的背景
		self:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
	else
		self:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_DEFAULT)
	end
end

-- 登陆到socket服务器
function DlgReconnect:doLogin()
	-- 启用定时器
	self:restartUpdate()
    -- 记录本次重新连接的时间
    self.fLastRecTime = getSystemTime()
    self.nRecType = e_rectype_doing.log -- 类型定义为数据同步
    -- 切换状态
	self:changeLoadingState(true)
	-- 切换连接状态
	exchangeConStatus(e_network_status.ing)
	-- 执行登录行为
	SOCKET_ENCRYPT_KEY = nil -- 重置加密值

	--初始化相关值
	self.nCurIndex = 1
	self.nCurFailedCount = 0
	self.nCurFinishCount = 0
	local tD = tSerDatas[self.nCurIndex]
    SocketManager:sendMsg(tD[1], {AccountCenter.acc, AccountCenter.token, 
        AccountCenter.subcid, AccountCenter.os, 
        AccountCenter.nowServer.id, 0}, 
        handler(self, self.onReconnectFunc),-1)
end

--接收服务端发回的数据回调
function DlgReconnect:onReconnectFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.login.id then
            -- 记录key值
            if(__msg.body and __msg.body.key) then
                SOCKET_ENCRYPT_KEY = __msg.body.key -- socket加密key值
            end
            self.nCurIndex = self.nCurIndex + 1
        	local tD = tSerDatas[self.nCurIndex]
            SocketManager:sendMsg(tD[1], {}, handler(self, self.onReconnectFunc),-1)
            -- self:startReloadDatas()
        elseif __msg.head.type == MsgType.loadPlayer.id then
            --这里是界面刷新，不需要对数据做任何操作
            self:startReloadDatas()
        elseif __msg.head.type == MsgType.loadBuildDatas.id then
            --这里是界面刷新，不需要对数据做任何操作
        elseif __msg.head.type == MsgType.loadHeroData.id then
            --这里是界面刷新, 不需要对数据做操作
        elseif __msg.head.type == MsgType.reqWorldCityData.id then
            --这里是界面刷新, 不需要对数据做操作
        elseif __msg.head.type == MsgType.loadFubenData.id then
            --这里是界面刷新，不需要对数据做任何操作   
        elseif __msg.head.type == MsgType.loadActivity.id then
            --这里是界面刷新，不需要对数据做任何操作             
        elseif __msg.head.type == MsgType.loadTnolyDatas.id then
            --这里是界面刷新，不需要对数据做任何操作 
        elseif __msg.head.type == MsgType.loadBag.id then            
            --这里是界面刷新，不需要对数据做任何操作
        elseif __msg.head.type == MsgType.reqWorldMyCountryWar.id then
            --这里是界面刷新，不需要对数据做任何操作
        elseif __msg.head.type == MsgType.loadResource.id then            
            --这里是界面刷新，不需要对数据做任何操作                      
        elseif __msg.head.type == MsgType.loadMissions.id then            
            --这里是界面刷新，不需要对数据做任何操作          
        end
        self.nCurFinishCount = self.nCurFinishCount + 1
    else
    	--获得异常类型
    	local nErrorType = SocketManager:checkSerCallBackState(__msg.head)
    	if nErrorType == 1 then         --认为完成一条请求
    	    self.nCurFinishCount = self.nCurFinishCount + 1
    	elseif nErrorType == 2 then     --协议有问题
    	    self.nCurFailedCount = self.nCurFailedCount + 1
    	elseif nErrorType == -1 then 	--账号异常
    		return
    	end
    end

	--判断是否所有的协议加载都是成功的
	if(self.nCurFailedCount > 0) then
		self.nCurIndex = 0
    	-- 获取数据失败，直接
		self:onConnectFailed()
	else
		-- 已经加载游戏数据完成
		if(self.nCurFinishCount >= #tSerDatas) then
			self:loadNextData(true)
		end
    end
end

-- 重新加载数据
function DlgReconnect:startReloadDatas(  )
    for i=self.nCurIndex+1, #tSerDatas, 1 do
    	-- 执行下一条接口
    	self:loadNextData(false)
    end
end

--是否需要请求下一条协议
--_tSecondPar：协议请求参数
function DlgReconnect:loadNextData( bEnd )
	-- body
	if(not bEnd) then
		local _tSecondPar = {}
        self.nCurIndex = self.nCurIndex + 1
        --获取下一条协议相关数据
        local nType, tD, tSPar = SocketManager:getNextSer(true,self.nCurIndex)
        if tD then
            if nType == 1 then --正常请求
                SocketManager:sendMsg(tD[1], _tSecondPar, handler(self, self.onReconnectFunc),-1)
            elseif nType == 2 then --带参数请求
                SocketManager:sendMsg(tD[1], tSPar, handler(self, self.onReconnectFunc),-1)
            elseif nType == 3 then --请求下一条协议
                self.nCurFinishCount = self.nCurFinishCount + 1
            end
        end
	else
		self.nCurIndex = 0
        self:onConnectSuccess()
	end
end

-- 重连成功
function DlgReconnect:onConnectSuccess( )
	-- 重设状态
	exchangeConStatus(e_network_status.nor)

	--重连接口消息获取刷新
	for k, v in pairs (tSerDatas) do
		if v[3] and table.nums(v[3]) > 0 then
			for key, msg in pairs (v[3]) do
				if #msg > 0 then
					tMsgReconnectDatas[msg] = {sMsgName=msg}
				end
			end
		else
			if v[1] ~= "login" then
				if v[2] == true then
					print("注意：重连接口（" .. v[1] .. "）没有注册消息名称==============")
				end
			end
		end
	end

	--这里需要判断是否需要切到主界面
	local bIsNeedHome = true
	--如果是客户端断网的情况下并且不是后台切换到前台
	if self.nCurType == e_disnet_type.cli and self.nSecType == e_second_type.normal then 
		--判断断网重连次数次数
		if Player.nReconnetCount < 3 then --小于三次说明是自动重连成功了，不需要切到主界面
			bIsNeedHome = false
		end
	end

	--重连成功，重置次数
	Player.nReconnetCount = 0
	--关闭对话框
	self:closeDlg()

 	--发送重连成功消息
    local tObj = {}
    tObj.bIsAuto = self.bAutoLink
	tObj.nSecType = self.nSecType
	tObj.bIsNeedHome = bIsNeedHome
    sendMsg(ghd_msg_reconnect_success, tObj)
end

-- 重连失败
function DlgReconnect:onConnectFailed( )
	-- 切换状态
	self:changeLoadingState(false)
	-- 停止定时器
	self:destroyHandler()
	-- 重置连接状态
	exchangeConStatus(e_network_status.out)
	self.nRecType = e_rectype_doing.nti -- 无状态
	self.nRecCount = 0
	self.nFailCount = self.nFailCount + 1
	
	--是否需要展示重连框
	--如果是客户端断网的情况下并且不是后台切换到前台同事也不在新手引导阶段
	if self.nCurType == e_disnet_type.cli and Player:getIsGuiding() == false then
		Player.nReconnetCount = Player.nReconnetCount + 1
		-- print("重连失败次数：" .. self.nFailCount)
		-- print("Player.nReconnetCount:" .. Player.nReconnetCount)
		if Player.nReconnetCount > 2 then
			if(self.nFailCount > 2) then
				self.pLbContent:setString(getConvertedStr(1, 10222))
				self.pBtnAction:updateBtnText(getConvertedStr(1, 10223))
				self.pBtnAction:onCommonBtnClicked(handler(self, self.onExitClicked))
			end
		else
			self:closeDlg()
		end
	else
		if(self.nFailCount >= 2) then
			self.pLbContent:setString(getConvertedStr(1, 10222))
				self.pBtnAction:updateBtnText(getConvertedStr(1, 10223))
				self.pBtnAction:onCommonBtnClicked(handler(self, self.onExitClicked))
		end
	end
end

-- 操作按钮事件
function DlgReconnect:onActionClicked(pView)
	if(self.nCurType == e_disnet_type.ser) then -- 服务器强断socket，退出重登
		AccountCenter.backToLoginScene()
	elseif(self.nCurType == e_disnet_type.acc) then -- 帐号在其他地方登录，退出重登
		AccountCenter.backToLoginScene()
	elseif(self.nCurType == e_disnet_type.tok) then -- 令牌失效
		AccountCenter.backToLoginScene()
	elseif(self.nCurType == e_disnet_type.locked) then -- 帐号被封
		AccountCenter.backToLoginScene()
	else -- 网络异常，重连
		self:doReconnect()
	end
end

-- 直接退出重新登录
function DlgReconnect:onExitClicked( pView )
	AccountCenter.backToLoginScene()
end

-- 关闭所有正在执行的接口
function DlgReconnect:closeAllDoing(  )
	-- 清除所有的界面回调刷新
	SocketManager:clearAllCallback(false)
end

return DlgReconnect
