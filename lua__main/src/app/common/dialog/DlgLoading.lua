-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-03-22 20:18:02 星期三
-- Description: loading框
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local DlgLoading = class("DlgLoading", function ()
	return MDialog.new()
end)

--_nType：类型（-1：表示普通的loading，字符串为协议标志）
--_bDelay：是否需要延长展示
--_fDelayTime：延迟时间
--_fTimeOut：超时时间
function DlgLoading:ctor(_nType, _bDelay, _fDelayTime, _fTimeOut)
	self:myInit()
	self.nLoadingType = _nType or self.nLoadingType
	self.fDelayTime = _fDelayTime or f_delaytime_loading
	self.fTimeOut = _fTimeOut or self.fTimeOut

	-- 记录最后的时间
    self.fLastLoadTime = getSystemTime()

	-- 添加点击过滤，刻意处理消除问题
	self.pLayer = MUI.MLayer.new()
	self.pLayer:setContentSize(cc.size(display.width, display.height))
	self:setContentView(self.pLayer)
	self.pLayer:setViewTouched(true)
	self.pLayer:onMViewClicked( function (  )
		-- body
		print("无效层=====================")
	end)

    self:setIsNeedOutside(false)
    self:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)

    if _bDelay then
        self:runAction( -- loading显示层超时限制
    		cc.Sequence:create(cc.DelayTime:create(self.fDelayTime),
    		cc.CallFunc:create(handler(self, self.showLoadinView))))
    else
    	self:showLoadinView()
    end

    --注册析构方法
    self:setDestroyHandler("DlgLoading",handler(self, self.onDlgLoadingDestroy))
end

--初始化成员变量
function DlgLoading:myInit()
	self.nLoadingType 	= -1 					-- 类型（-1：表示普通的loading，字符串为协议标志）
	self.fDelayTime 	= 0 					-- 延迟时间
	self.fTimeOut 		= getOuttimeForSocket() -- 超时时间
	self.fRealTimeOut   = self.fTimeOut + 2 	-- 真正超时时间
	self.bRealTimeOut 	= true 				    -- 是否真正超时
	self.bChecking 		= false 				-- 检验中
	self.eDlgType 		= e_dlg_index.loading   -- 对话框类型
	self.fLastLoadTime 	= 0                     -- 最后开始加载的时间
end


--延迟s秒出现loading条,避免每次网络链接时都显示loading
function DlgLoading:showLoadinView( )
	-- 增加转圈
	addLoadingAction(self.pLayer)
    -- 注销定时器
	self:cancelUpdate()
    -- 启用定时器
    self.nUpHandler = MUI.scheduler.scheduleUpdateGlobal(
        handler(self, self.onUpdateTime), 1)
end

--超时响应
function DlgLoading:timeOut( )
	-- 消息发送超时了,需要消除自己让游戏继续运行下去
	print("发送超时,消除loading屏蔽框")
	-- 关闭所有loading框
    hideLoadingDlg(true)

    --如果当前在homelayer中，需要弹出重连框
	if Player:getUIHomeLayer() then
		-- 弹出重连对话框
	    showReconnectDlg(e_disnet_type.cli, true)
	end
end

--检查是否是正在超时
function DlgLoading:checkIfRealTimeOut(  )
	-- body
	self.bChecking = true
	--尝试请求一个简单的协议，看看有没有数据返回
	SocketManager:sendMsg("getEnergy", {}, function ( __msg, __oldMsg )
		-- body
		self.bRealTimeOut = false
	end,-1)
end

-- 定时器刷新
function DlgLoading:onUpdateTime(  )
	--如果当前断网并且在homelayer中，需要执行超时操作
	if(e_network_status.out == getCurConStatus() and Player:getUIHomeLayer()) then
		self:timeOut()
		return
	end
	local fDis = getSystemTime() - self.fLastLoadTime
	--展示loading框的时间超过最大值
	if(fDis >= self.fTimeOut) then
		--没有开始检验
		if self.bChecking == false then
			--超时再次验证
			if self.nLoadingType ~= -1 and type(self.nLoadingType) == "string" then --socket协议请求超时
				self:checkIfRealTimeOut()
			else
				self:timeOut()
			end
		--校验中...
		else 
			if fDis > self.fRealTimeOut then
				--真的是需要重连框了
				if self.bRealTimeOut then
					self:timeOut()
				end
			else
				--socket还是连接的，只是没有返回数据而已
				if self.bRealTimeOut == false then
					-- 注销定时器
					self:cancelUpdate()
					SocketManager:forceCloseCallbackByType(self.nLoadingType,false)
					-- 关闭所有loading框
    				hideLoadingDlg(true)
				end
			end
		end
	end
end

--析构方法
function DlgLoading:onDlgLoadingDestroy(  )
	-- body
	-- 注销定时器
	self:cancelUpdate()
end

--取消每秒刷新
function DlgLoading:cancelUpdate(  )
	-- body
	-- 注销定时器
	if(self.nUpHandler ~= nil) then
		MUI.scheduler.unscheduleGlobal(self.nUpHandler)
        self.nUpHandler = nil
    end
end

-- 重设最后加载的时间
function DlgLoading:resetLastTime( )
	self.fLastLoadTime = getSystemTime()
end

return DlgLoading