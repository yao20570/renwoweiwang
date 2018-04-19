-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-09 17:14:15 星期四
-- Description: 登录界面
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local HomeLayer = require("app.layer.home.HomeLayer")
local DlgRegistered = require("app.layer.login.DlgRegistered")

local LoginLayer = class("LoginLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MROOTLAYER)
end)

-- _nType 登录类型
function LoginLayer:ctor(_nType)
	-- body
    --保存不需要降低色阶的纹理
    saveFilterSepTexture()
	self:myInit()
    --标志已经过了update.bin过程
    UPDATE_BIN_FINISH = true
    addTextureToCache("ui/p1_commmon1_sep",1,true) --强制引用
    addTextureToCache("ui/p1_commonse2",1,true) --强制引用
    addTextureToCache("ui/p1_commmon3_sep",1,true) --强制引用

    addTextureToCache("ui/p1_commmon4_sep",1,true) --强制引用
    addTextureToCache("ui/p1_commmon2_sep",1,true) --强制引用
    addTextureToCache("ui/p1_commonse1",1,true) --强制引用
    addTextureToCache("ui/p1_commonse3",1,true) --强制引用
    addTextureToCache("ui/p1_button1",1,true) --强制引用
    addTextureToCache("ui/p2_button1",1,true) --强制引用
    addTextureToCache("ui/language/cn/p1_font2",1,true) --强制引用

    saveLocalInfo(LOGOBG_VERSTR,"ver002")
    self.nInType = _nType or 1
	parseView("layout_login", handler(self, self.onParseViewCallback))
    closeFPS()
    --添加loading纹理
    addTextureToCache("tx/other/p1_loading",1,true) --强制引用
end

--初始化成员变量
function LoginLayer:myInit(  )
	-- body
    self.nInType        = 1      -- 1需要执行登录行为，0不需要执行登录行为，只是切换服务器而已，2重新登录
    --请求游戏服数据相关--------------
    self.nCurIndex      = 0      -- 当前请求的协议下标
    self.nOutSec        = 0      -- 超时时间
    self.nFailCount     = 0      -- 异常的次数
    self.sLastMsgType   = nil    -- 最后请求数据的接口
    self.bDataEnd       = false  -- 数据是否加载完成(socket请求)
    self.bTextureEnd    = false  -- 纹理是否加载完成 
    self.tPreLoadDatas  = nil    -- 预加载数据

    self.tSerLists      = nil    -- 服务器列表
    self.pLbServerName  = nil    -- 服务器名称

end
-- 安全的弹出登录框
function LoginLayer:saveForLoginView( nSecond )
    nSecond = nSecond or 1
    if(not AccountCenter.isNormalLogin) then
        self.loginViewForClicked:setViewTouched(false)
        self:performWithDelay(function (  )
            if(AccountCenter.acc == nil or string.len(AccountCenter.acc) <= 0) then
                self.loginViewForClicked:setIsPressedNeedScale(false)
                self.loginViewForClicked:setIsPressedNeedColor(false)
                self.loginViewForClicked:setViewTouched(true)
                self.loginViewForClicked:onMViewClicked(function (  )
                    -- 判断是否已登陆，若已登陆，则不再打开登陆窗口
                    if (AccountCenter.acc == nil or string.len(AccountCenter.acc) <= 0) then
                        showSDKLoginView(self, true)
                        -- 再继续延迟执行
                        self:saveForLoginView()
                    end
                end)
            end
        end, nSecond)
    end
end

--解析布局回调事件
function LoginLayer:onParseViewCallback( pView )
	-- body
	pView:setLayoutSize(self:getLayoutSize())
	self:addView(pView, 10)
    self.allView = pView:findViewByName("default")

    self.loginViewForClicked = pView
    self:saveForLoginView(6)
	centerInView(self, pView)
    Player:initUILoginLayer(self)

    Sounds.playMusic(Sounds.Music.shijie,true) 

	self:setupViews()

	self:onResume()

    

	--注册析构方法
	self:setDestroyHandler("LoginLayer",handler(self, self.onLoginLayerDestroy))
end


--初始化控件
function LoginLayer:setupViews( )
	-- body
    --进度条
    self.pSlider            =       self:findViewByName("slider")
    self.pSlider:align(display.LEFT_BOTTOM)
    self.pSlider:setPosition(10, self.pSlider:getPositionY()-self.pSlider:getHeight()/2)
    self.pSlider:onSliderValueChanged(function (  )
        -- body
        local curvalue = self.pSlider:getSliderValue() --滑动条当前值
        if curvalue > 8 then
            self.pSlider:getSliderBarBall():setVisible(true)
        else 
            self.bVi = false
            self.pSlider:getSliderBarBall():setVisible(false)
        end
    end)


    if(addBackgroundAndLogo) then
        addBackgroundAndLogo(2, self.loginViewForClicked,self.pSlider:getSliderBarBall())
    end

    --游戏提示语
    local pLayGameTips       =       self:findViewByName("lay_temp_tips")
    if showGameTips then
        showGameTips(pLayGameTips)
    end
    

    --进度
    self.pLbSlider          =       self:findViewByName("lb_slider")
    --提示语
    self.pLbTips            =       self:findViewByName("lb_tips")
    self.pLbTips:setString(getConvertedStr(1,10072))
    --进度条层
    self.pLayBottom         =       self:findViewByName("lay_bottom")
    self.pLayBottom:setVisible(false)

    --服务器列表层
    self.pTmpServerLayer    =       self:findViewByName("lay_tmp")
    --切换服务器点击层
    self.pLayChangeSer      =       self:findViewByName("lay_ser")
    self.pLayChangeSer:setViewTouched(true)
    self.pLayChangeSer:setIsPressedNeedScale(false)
    self.pLayChangeSer:onMViewClicked(handler(self, self.selectSerClicked))
    --当前选中的服务器
    self.pLbCurSer          =       self:findViewByName("lb_ser_name")
    setTextCCColor(self.pLbCurSer,_cc.pwhite)
    --当前服务器类型
    self.pImgState          =       self:findViewByName("img_state")
    --换区
    self.pLbChange          =       self:findViewByName("lb_ser_change")
    self.pLbChange:setString(getConvertedStr(1, 10260))
    setTextCCColor(self.pLbChange,_cc.pwhite)
    --Pk层
    self.pLayPk             =       self:findViewByName("lay_pk_tips")
    self.pLayPk:setViewTouched(true)
    self.pLayPk:setIsPressedNeedScale(false)
    self.pLayPk:onMViewClicked(handler(self, self.onPkClicked))
    --PK提示
    self.pLbPkTips          =       self:findViewByName("lb_pk")
    self.pLbPkTips:setString(getConvertedStr(1, 10261))
    setTextCCColor(self.pLbPkTips,_cc.pwhite)
    --PK勾
    self.pImgPk             =       self:findViewByName("img_pk")
    --默认选中
    self.pImgPk:setVisible(true)
    --登陆游戏服按钮
    self.pLayGoToGame       =        self:findViewByName("lay_gotogame") 
    self.pLayGoToGame:setViewTouched(true)
    self.pLayGoToGame:setIsPressedNeedScale(false)
    self.pLayGoToGame:onMViewClicked(handler(self, self.onStarGotoGameClicked))
    self.pBtnGotoGame       =        self:findViewByName("btn_gotogame") 
    --登录label
    self.pLbGotoGame        =       self:findViewByName("lb_gotogame")
    self.pLbGotoGame:setString(getConvertedStr(4, 10002))

    if(self.nInType == 1 or self.nInType == 2) then --需要展示登陆框
        self.pTmpServerLayer:setVisible(false)
        if(AccountCenter.isNormalLogin) then
            self:showDlgRegister()
        else
            -- 延迟展示登录行为
            self:performWithDelay(function (  )
                showSDKLoginView(self, self.nInType == 2)
            end, 0.03)
        end
    elseif self.nInType == 0 then
        self:showServerList()
    end

    -- -- 发送idfa到后台记录
    -- HttpManager:doFlushIdfaToServer(function ( event )
    --     if event.name == "completed" then
    --     end
    -- end)

    -- 获取开关状态
    HttpManager:doGetSwitchesFromServer(function ( event )
        if event.name == "completed" then
            local bOpenFloatIcon = true
            --非成功状态下
            if (event.data and event.data.s and tonumber(event.data.s) ~= 0)  then
                -- 打开sdk浮标
                showSDKFloatIcon(bOpenFloatIcon)
                return 
            end
            if event.data and event.data.r and event.data.r.limit_ids then
                local tT = string.split(event.data.r.limit_ids, "_")
                if(tT) then
                    for i, v in pairs(tT) do
                        local nIndex = tonumber(v)
                        if (nIndex == n_s_switches_tag_fubiao) then
                            -- sdk浮标开关控制
                            bOpenFloatIcon = false
                            if device.platform == "ios" then
                                b_open_ios_shenpi = true
                            end 
                        end
                    end
                end
            end
            if b_open_ios_shenpi then
                dealIosShenpi()
            end
            -- 打开sdk浮标
            showSDKFloatIcon(bOpenFloatIcon)
        end
    end)
end

--pk玩法点击事件
function LoginLayer:onPkClicked( pView )
    -- body
    self.pImgPk:setVisible(not self.pImgPk:isVisible())
end

--选中服务器
function LoginLayer:selectSerClicked( pView )
    -- body
    local DlgServerList = require("app.layer.serverlist.DlgServerList")
    local pDlg, bNew = getDlgByType(e_dlg_index.serverlist)
    if not pDlg then
        pDlg = DlgServerList.new()
        pDlg:showDlg(bNew)
    end
end

--点击进入游戏服
function LoginLayer:onStarGotoGameClicked(pView )
    -- body
    if self.pImgPk:isVisible() then
        if AccountCenter.nowServer and AccountCenter.nowServer.ad then
            -- dump(nState,"nState=",100)
            local nState = AccountCenter.analysisServer(AccountCenter.nowServer)
            if(nState == en_server_state.maintain and b_is_white_account == false ) then --维护状态
                local text = AccountCenter.nowServer.tips or getConvertedStr(1, 10278)
                local DlgAlert = require("app.common.dialog.DlgAlert")
                local pDlg = DlgAlert.new()
                if AccountCenter.nowServer.tips then
                    pDlg:setContentLetter(text, _cc.white, 20, 400, 0, cc.p(0, 0.5))
                else
                    pDlg:setContent(text)
                end
                
                pDlg:setTitle(getConvertedStr(1, 10218))
                pDlg:setOnlyConfirm(getConvertedStr(1, 10059))
                -- 设置外部不能点击关闭对话框
                pDlg:showDlg()
                -- TOAST(text)
                return
            end
            SocketManager:setServerAddress(AccountCenter.nowServer.ad) --ip端口
            self:loadGameData()
        else
            self:selectSerClicked()
        end
    else
        TOAST(getConvertedStr(1, 10262))
    end
end

--显示注册登陆界面
function LoginLayer:showDlgRegister()
    local pDlg, bNew = getDlgByType(e_dlg_index.register)
    if not pDlg then
        pDlg = DlgRegistered.new()
    end
    pDlg:setCloseDialogHandler(function (  )
        -- body
        self:showServerList()
    end)
    pDlg:showDlg(bNew,self)
end

--显示选中的服务器
function LoginLayer:showServerList()
     self.pTmpServerLayer:setVisible(true)
     --设置选中的服务器
     self.pLbCurSer:setString(AccountCenter.nowServer.ne)
end

-- 修改控件内容或者是刷新控件数据
function LoginLayer:updateViews(  )
	-- body
    --初始进度值
    self.pLbSlider:setString("0%")
    self.pSlider:setSliderValue(0)
end

-- 析构方法
function LoginLayer:onLoginLayerDestroy(  )
	-- body
    self:onPause()
    Player:releaseUILoginLayer()
    -- 取消定时刷新
    self:cancelUpdateForTime()
    -- 取消预加载
    self:cancelPreLoad()
    -- 销毁SDK登录的相关临时数据
    resetSDKLoginData()
end

-- 注册消息
function LoginLayer:regMsgs( )
	-- body
    --注册socket网络连接状态回调
    regMsg(self, ghd_socket_connection_event, handler(self, self.onSocketEventMsgRecived))
    --通知刷新登录界面
    regMsg(self, gud_refresh_login, handler(self, self.onRefreshServer))
    -- SDK登录成功
    regMsg(self, gud_sdkloginsucceed, handler(self, self.showServerList))
     -- 更新登陆界面进度条的消息
    regMsg(self, ghd_update_login_slider_value, handler(self, self.setSliderValueOnLogin))
end

-- 注销消息
function LoginLayer:unregMsgs(  )
	-- body
    --注销socket网络连接状态回调
    unregMsg(self, ghd_socket_connection_event)
    --注销刷新登录界面
    unregMsg(self, gud_refresh_login)
    --注销更新登陆界面进度条的消息
    unregMsg(self, ghd_update_login_slider_value)


    
end


--暂停方法
function LoginLayer:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function LoginLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--加载游戏数据
-- _force(bool): 是否是强制执行登陆行为，默认是false（为了兼容特殊包的处理）
function LoginLayer:loadGameData( _force )
    -- body
    if(not _force) then
        if(self:doSpecialLogin()) then
            return
        end
    end
    if self.fLastTimeLoadGame then
        local fCurTime = getSystemTime(false)
        if fCurTime - self.fLastTimeLoadGame <= 1000 then
            -- self.fLastTimeLoadGame = getSystemTime(false)
            return 
        end
    end 
    self.fLastTimeLoadGame = getSystemTime(false)
    -- 定时刷新界面，每1秒刷新一次
    if self.nUpdateHandler == nil then
        self.nUpdateHandler = MUI.scheduler.scheduleGlobal(handler(self, self.updateForTime), 1)
    end
    SocketManager:close()
    SocketManager:onConnect()

    --展示登陆过程UI
    self:showSerOrLoadingUI(2)
end
-- 执行特殊的登录行为
function LoginLayer:doSpecialLogin( )
    local hasSpecail = isFileExistCfg("specaillogin.txt", 1)
    G_SPECIALCLICK = G_SPECIALCLICK or 0
    if(hasSpecail and G_SPECIALCLICK>=6) then
        local DlgAlert = require("app.common.dialog.DlgAlert")
        local pDlg, bNew = DlgAlert.new(), true
        local fH = 500
        local fW = 500
        local function createContent( _pVg, _sStr, _fY, _tag )
            local pView1 = MUI.MLabel.new({text=_sStr, color=cc.c3b(255, 255, 255), size=18})
            pView1:setPosition(cc.p(fW/2, _fY - 10))
            _pVg:addView(pView1, 1)
            local pView2 = MUI.MInput.new({UIInputType=1,
                image="ui/bar/v1_bar_b4.png",
                fontSize=20,
                listener = function ( _state, _p )
                    -- print(_p:getText())
                end,
                size=cc.size(400, 50)})
            pView2:setPosition(cc.p(fW/2, pView1:getPositionY() - 50))
            pView2:setTag(_tag)
            _pVg:addView(pView2, 2)
            return pView1:getPositionY() - 90
        end
        local pVg = MUI.MLayer.new()
        self.pAllBg = pVg
        pVg:setContentSize(cc.size(fW, fH))
        pDlg:addContentView(pVg)
        local fY = fH - 0
        -- 增加账号
        fY = createContent(pVg, getConvertedStr(2, 10002), fY, 10001)
        -- 增加密码
        fY = createContent(pVg, getConvertedStr(2, 10003), fY, 10002)
        -- 增加服务器id
        fY = createContent(pVg, getConvertedStr(2, 10004), fY, 10003)

        pDlg:setTitle(getConvertedStr(2, 10005))
        pDlg:setOnlyConfirm(getConvertedStr(2, 10006))
        UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew, false)
        pDlg:setRightHandler(function ( _pView )
            local pAcc = self.pAllBg:findViewByTag(10001)
            local pToken = self.pAllBg:findViewByTag(10002)
            local pId = self.pAllBg:findViewByTag(10003)
            self.sAcctest = pAcc:getText()
            self.sTokentest = pToken:getText()
            self.sIdtest = pId:getText()
            if(self.sAcctest == nil or self.sAcctest == "") then
                TOAST(getConvertedStr(2, 10007))
                return
            end
            if(self.sTokentest == nil or self.sTokentest == "") then
                TOAST(getConvertedStr(2, 10008))
                return
            end
            if(self.sIdtest == nil or self.sIdtest == "") then
                TOAST(getConvertedStr(2, 10009))
                return
            end
            AccountCenter.acc = self.sAcctest
            AccountCenter.token = self.sTokentest
            AccountCenter.nowServer = nil
            local nId = tonumber(self.sIdtest)
            for i, v in pairs(AccountCenter.allServer) do
                if(nId ==  tonumber(v.id)) then
                    AccountCenter.nowServer = v
                    break
                end
            end
            if(AccountCenter.nowServer) then
                SocketManager:setServerAddress(AccountCenter.nowServer.ad) --ip端口
                UIAction.exitDialog(pDlg)
                self:loadGameData(true)
            else
                TOAST(getConvertedStr(2, 10010))
            end
        end)
        return true
    end
    return false
end

--socket连接状态
function LoginLayer:onSocketEventMsgRecived(msgName, pMsgObj)
    if pMsgObj then
        local nState = pMsgObj.nType
        if (nState == 1) then
            --连接成功
            myprint("连接成功, 开始请求登陆~")
            --切换网络为正常状态
            exchangeConStatus(e_network_status.nor)
            -- 请求socket连接，登录游戏服
            self:doLoginData()
        elseif (nState == 4) then
            --连接失败 
            TOAST("网络连接异常")
            --展示登陆游戏服按钮
            self:showSerOrLoadingUI(1)
        else
            TOAST(getConvertedStr(1,10071))
            self:cancelUpdateForTime()
            --展示登陆游戏服按钮
            self:showSerOrLoadingUI(1)
        end
    end
end

--请求socket连接，登录游戏服
function LoginLayer:doLoginData(  )
    -- body
    SOCKET_ENCRYPT_KEY = nil -- 重置加密值
    self.bDataEnd = false
    self.nCurIndex = 1
    self.nFailCount = 0
    local tD = tSerDatas[self.nCurIndex]
    self.sLastMsgType = tD[1] -- 重置当前接口名称
    SocketManager:sendMsg(tD[1], {AccountCenter.acc,AccountCenter.token,
        AccountCenter.subcid, AccountCenter.os, AccountCenter.nowServer.id, 0}, handler(self, self.onGetDataFunc),-1)
end


--接收服务端发回的登录回调
function LoginLayer:onGetDataFunc( __msg )
    local tSecondPar = {}
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.login.id then

			--io.read()
            --纹理预加载
            self:loadTexturePre()
            -- 加载控件缓存池
            self:doLoadViewsPool()
            --玩家登陆游戏服
            -- 记录key值
            if(__msg.body and __msg.body.key) then
                SOCKET_ENCRYPT_KEY = __msg.body.key -- socket加密key值
            end
        elseif __msg.head.type == MsgType.loadPlayer.id then
            --这里是界面刷新，不需要对数据做任何操作
        elseif __msg.head.type == MsgType.loadBuildDatas.id then
            --这里是界面刷新，不需要对数据做任何操作
        elseif __msg.head.type == MsgType.loadHeroData.id then
            --这里是界面刷新, 不需要对数据做操作
        elseif __msg.head.type == MsgType.reqWorldCityData.id then
            --这里是界面刷新, 不需要对数据做操作
        elseif __msg.head.type == MsgType.loadFubenData.id then
            --这里是界面刷新, 不需要对数据做操作
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
        elseif __msg.head.type == MsgType.loadNoticeData.id then            
            --这里是界面刷新，不需要对数据做任何操作          
        end

        if self.nCurIndex == #tSerDatas then
            tSecondPar = nil
        end
        --看看是否需要继续执行
        if self.loadNextData then
             self:loadNextData(tSecondPar)
        end
    else
        --获得异常类型
        local nErrorType = SocketManager:checkSerCallBackState(__msg.head)
        if nErrorType == 1 then         --请求下一条协议
            if self.nCurIndex == #tSerDatas then
                tSecondPar = nil
            end
            self:loadNextData(tSecondPar)
        elseif nErrorType == 2 then     --协议有问题
             dump( __msg.head,"error======",100)
             -- 检测是否超过次数
             local bCanOut = self:doCheckFailTime()
             if(bCanOut) then
                 self.nCurIndex = 0
             end
        end
    end
end

-- 执行失败次数的检测
-- return(bool): 是否已经超过失败次数了
function LoginLayer:doCheckFailTime(  )
    self.nFailCount = self.nFailCount + 1
    local bCanOut = false -- 是否可以执行超时行为
    if(self.nCurIndex == 1) then -- login接口一定超时
        bCanOut = true
    else
        if(self.nFailCount >= 3) then -- 有3个以上接口超时
            bCanOut = true
        end
    end
    -- 失败次数在允许范围内
    if(not bCanOut) then
        SocketManager:forceCloseCallbackByType(self.sLastMsgType)
        if(self.nCurIndex >= #tSerDatas) then
            self:loadNextData(nil)
        else
            self:loadNextData({})
        end
    end

    if bCanOut then
        print("失败次数超过上限==========这里为了排除错误打印")
        --展示登陆游戏服按钮
        self:showSerOrLoadingUI(1)
    end
    return bCanOut
end

--是否需要请求下一条协议
--_tSecondPar：协议请求参数
function LoginLayer:loadNextData( _tSecondPar )
    -- body
    self.nOutSec = 0
    if(_tSecondPar ~= nil) then
        self:showLoadingPercent()
        self.nCurIndex = self.nCurIndex + 1
        --获取下一条协议相关数据
        local nType, tD, tSPar = SocketManager:getNextSer(false,self.nCurIndex)
        if tD then
            if nType == 1 then --正常请求
                self.sLastMsgType = tD[1] -- 重置当前接口名称
                SocketManager:sendMsg(tD[1], _tSecondPar, handler(self, self.onGetDataFunc),-1)
            elseif nType == 2 then --带参数请求
                self.sLastMsgType = tD[1] -- 重置当前接口名称
                SocketManager:sendMsg(tD[1], tSPar, handler(self, self.onGetDataFunc),-1)
            elseif nType == 3 then --请求下一条协议
                -- 判断是否已经结束了，增加结束标识
                if self.nCurIndex == #tSerDatas then
                    _tSecondPar = nil
                end
                self:loadNextData(_tSecondPar)
            end
        end
    else
        -- 取消定时刷新
        self:cancelUpdateForTime()
        self:showLoadingPercent(100)
        self.nCurIndex = 0
        self.bDataEnd = true
        self:gotoHomelayer()
    end
end

--定时器刷新
function LoginLayer:updateForTime(  )
    -- body
    self.nOutSec = self.nOutSec + 1
    if self.nOutSec > f_outtime_login then --超过5s
        local bCanOut = self:doCheckFailTime()
        if(bCanOut) then
            -- TOAST(getConvertedStr(1,10071))
            Player:destroyPlayer()
            -- 取消定时刷新
            self:cancelUpdateForTime()
             -- 关闭所有请求连接
            SocketManager:clearAllCallback()
        end
    end
end

--销毁定时器
function LoginLayer:cancelUpdateForTime( ) 
    -- body
    if(self.nUpdateHandler ~= nil) then
        MUI.scheduler.unscheduleGlobal(self.nUpdateHandler)
        self.nUpdateHandler = nil
    end
end

--销毁每帧预加载
function LoginLayer:cancelPreLoad( )
    -- body
    if (self.nPreLoadingHandler ~= nil ) then
        MUI.scheduler.unscheduleGlobal(self.nPreLoadingHandler)
        self.nPreLoadingHandler = nil
    end
end

-- 显示当前加载的进度
function LoginLayer:showLoadingPercent( fPercent )
    if(self.nCurIndex and tSerDatas) then
        fPercent = fPercent or math.floor((self.nCurIndex/#tSerDatas*100))
        if fPercent then
            self.pLbSlider:setString(fPercent .. "%")
            self.tValueEndDatas = 50 --处理好协议请求数据认为50进度
            self.pSlider:setSliderValue(tonumber(fPercent * 0.5))
        end
    end
end

--纹理预加载
function LoginLayer:loadTexturePre(  )
    -- body
    if(self.nPreLoadingHandler == nil) then
        if(self.tPreLoadDatas == nil) then
            self.tPreLoadDatas = {}
            --预加载纹理
            local tTmpDatas = self:getPlist()
            for k, v in pairs(tTmpDatas) do
                self.tPreLoadDatas[#self.tPreLoadDatas+1] = v
            end
        end
        self.nCurPreIndex = 0 
        local nEveryCount = 3
        self.nMaxPreCount = table.nums(self.tPreLoadDatas)
        self.nCurCallIndex = 0
        self.nPreLoadingHandler = MUI.scheduler.scheduleUpdateGlobal(function (  )
            self.nCurCallIndex = self.nCurCallIndex + 1
            -- 前5帧都不执行操作
            if(self.nCurCallIndex <= 5) then
                return
            end
            local nCurMax = self.nCurPreIndex + nEveryCount
            if(nCurMax > self.nMaxPreCount) then
                nCurMax = self.nMaxPreCount
            end
            --每帧执行那么多个
            for i = self.nCurPreIndex + 1, nCurMax, 1 do
                self.nCurPreIndex = self.nCurPreIndex + 1
                local fJsonName = self.tPreLoadDatas[self.nCurPreIndex]
                if(string.find(fJsonName, "plist")) then -- 如果是plist文件
                    local tT = luaSplit(fJsonName, ".")
                    if tT and tT[1] then
                        if string.find(fJsonName, "p1_banner") then
                            addTextureToCache(tT[1], 3, true)
                        elseif string.find(fJsonName, "p1_hero_boss") then
                            addTextureToCache(tT[1], 3, true)
                        elseif string.find(fJsonName, "p1_icon3") or string.find(fJsonName, "p1_icon3_2")then
                            addTextureToCache(tT[1], 3, true)
                        else
                            if b_use_sec_fightlayer then --如果启用了第二版本的战斗表现
                                if string.find(fJsonName, "p2_fight_") then --战斗启用pvr方式加载
                                    addTextureToCache(tT[1], 2, true)
                                else
                                    addTextureToCache(tT[1], 1, true)
                                end
                            else
                                addTextureToCache(tT[1], 1, true)
                            end
                        end
                    end
                end
            end
            if(self.nCurPreIndex >= self.nMaxPreCount) then
                self:cancelPreLoad()
                self.bTextureEnd = true
                --初始化操作(获得物品的初始化布局)
                doInitShowGetItems()
                local pImgL = MUI.MImage.new("ui/bg_base/bg_base_2.jpg")
                local pImgR = MUI.MImage.new("ui/bg_base/bg_base_1.jpg")
                local pImgF = MUI.MImage.new("ui/bg_fight/bg_fight.jpg")
                -- 开始游戏
                self:gotoHomelayer()
            end
        end)
    end
    
end

--获得所有的plist
function LoginLayer:getPlist(  )
    -- body
    local tDatas = {}
    -- UI目录
    tDatas = getAllFileByLastName("ui",".plist")
    -- Icon目录
    local tTmpDatas = getAllFileByLastName("icon", ".plist")
    if(tTmpDatas) then
        table.merge(tDatas, tTmpDatas)
    end
    -- fight目录
--    local tTmpDatas = getAllFileByLastName("tx/fight", ".plist")
--    if(tTmpDatas) then
--        table.merge(tDatas, tTmpDatas)
--    end
    -- Font目录
    local tTmpDatas = getAllFileByLastName("ui/language/cn", ".plist")
    if(tTmpDatas) then
        table.merge(tDatas, tTmpDatas)
    end
    -- 世界特效目录
--    local tTmpDatas = getAllFileByLastName("tx/world", ".plist")
--    if(tTmpDatas) then
--        table.merge(tDatas, tTmpDatas)
--    end
    --特殊纹理需要预加载
    table.merge(tDatas,tNeedLoadFirstTexture)
    
    return tDatas
end
-- 加载控件缓存池
function LoginLayer:doLoadViewsPool(  )

    

    self:doLoadGamePool()

--    --判断是否已经加载缓存池了
--    if MViewPool:getInstance():isReady() then
--        --设置结束标识
--        self.bViewPoolEnd = true
--        -- 开始游戏
--        self:gotoHomelayer()
--        return
--    end
--    if(not b_open_viewpool) then
--        self:doLoadGamePool()
--        return
--    end
--    self.bViewPoolEnd = false
--    local data = {}
--    data[#data+1] = {name=POOL_NAME_LABEL, count= 300}
--    data[#data+1] = {name=POOL_NAME_LAYER, count= 300}
--    data[#data+1] = {name=POOL_NAME_FILLLAYER, count= 300}
--    data[#data+1] = {name=POOL_NAME_IMAGE, count= 300}
--    MViewPool:getInstance():initBasePool(data, 
--        function ( _name )
--            local pView = nil
--            if(_name == POOL_NAME_LABEL) then
--                pView = MUI.MLabel.new({text="", size=20, color=cc.c3b(255, 255, 255)})
--            elseif(_name == POOL_NAME_LAYER) then
--                pView = MUI.MLayer.new()
--            elseif(_name == POOL_NAME_FILLLAYER) then
--                pView = MUI.MFillLayer.new()
--            elseif(_name == POOL_NAME_IMAGE) then
--                pView = MUI.MImage.new("ui/daitu.png")
--            elseif(_name == POOL_NAME_IMAGENINE) then
--                pView = MUI.MImage.new("ui/daitu.png", {scale9=true})
--            end
--            return pView
--        end, 
--        function (  )
--            -- 强制设置为false，进入homelayer之后再设置为true
--            MViewPool:getInstance():setReady(false)
--            -- 执行游戏的缓存池
--            if self.doLoadGamePool then
--                self:doLoadGamePool()
--            end

--        end, 50
--    )
end
-- 执行游戏内容的缓存池控制
function LoginLayer:doLoadGamePool( )
    local IconGoods = require("app.common.iconview.IconGoods")
    self.bViewPoolEnd = false
    local nPerCount = 5 -- 每帧加载3个
    local tmpDatas = {}
    table.insert(tmpDatas, {cls=IconGoods, 
                            params = {TypeIconGoods.HADMORE, type_icongoods_show.itemnum}, 
                            name="icongoods",
                            curCount=0, 
                            maxCount= 50})    
    -- 总共执行30次，可以加载150个上限的缓存控件
    gRefreshViewsAsync(self, 30, function ( _bEnd, _index )
        local bLeft = true
        for k, v in pairs(tmpDatas) do            
            for i = 1, nPerCount do
                if v.curCount < v.maxCount then
                    bLeft = false
                    v.curCount = v.curCount + 1
                    pushViewToPool(v.cls.new(unpack(v.params)), v.name, false)
                end
            end
        end

        if(bLeft) then
            --设置结束标识
            self.bViewPoolEnd = true
            -- 开始游戏
            self:gotoHomelayer()
            -- 结束定时器
            gRemoveNodeFromPerFrameUpdate(self)
        end
    end,1)
end

--进入游戏（homelayer）
function LoginLayer:gotoHomelayer( )
    -- body
    if  self.bDataEnd and self.bTextureEnd and self.bViewPoolEnd then
        --预加载战斗音频
        doPreloadFightEffect()
        --进入主界面钱关闭掉在LoginLayer身上的所有对话框
        closeAllDlg(true)
        -- doDelayForSomething(self, function (  )
            -- body
            -- 登录游戏服成功的打点
            doSummitData3k(1)
            local pHomeLayer = HomeLayer.new()
            RootLayerHelper:replaceRootLayer(pHomeLayer,true)

            -- 特殊处理，预先创建聊天
            local DlgChat = require("app.layer.chat.DlgChat")
	        local pDlg, bNew = getDlgByType(e_dlg_index.dlgchat)
	        local nChatType = 1
	        local tPChatInfo = nil
	        if not pDlg then
	        	pDlg = DlgChat.new(nChatType, tPChatInfo)	
	        end
            local pParView = Player:getUIHomeLayer()
	        pDlg:showDlg(bNew,pParView,0)
            pDlg:hideDlg(false)
        -- end,0.01)
    end
end

--解锁刷新进度条的消息回调
function LoginLayer:setSliderValueOnLogin( sMsgName, tMsgObj )
    -- body
    if tMsgObj then
        local bEnd = tMsgObj.bEnd
        local nType = tMsgObj.nType

        if nType == 1 then --世界
            self.bWEnd = bEnd
        elseif nType == 2 then --城内建筑
            self.bBEnd = bEnd
        elseif nType == 3 then --资源田
            self.bSEnd = bEnd
        end
        local bEnd = false
        if self.bWEnd and self.bBEnd and self.bSEnd then
            self.tValueEndDatas =  100
            bEnd = true
        else
            self.tValueEndDatas =  self.tValueEndDatas + 2
        end
        if self.tValueEndDatas > 100 then
            self.tValueEndDatas = 100
        end
        self.pSlider:setSliderValue(self.tValueEndDatas)
        -- self.pSlider:setPercentToByTime(0.2,  self.tValueEndDatas, nil)
        if bEnd then
            --判断是否选择了国家
            if Player:getPlayerInfo():getIsCountrySelected() then
                --可以进来homelayer了
                sendMsg(ghd_open_yu_onhome_msg)
            else
                doDelayForSomething(self,function (  )
                    -- body
                    --可以进来homelayer了
                    sendMsg(ghd_open_yu_onhome_msg)
                end,0.21)
            end
        end
    end
end

--刷新服务器名称
function LoginLayer:onRefreshServer()
    self.pLbCurSer:setString(getServerNameByServer(AccountCenter.nowServer))
end

--展示登陆游戏服按钮或者加载过程UI
function LoginLayer:showSerOrLoadingUI( nType )
    -- body
    if nType == 1 then
        self.pTmpServerLayer:setVisible(true)
        self.pLayBottom:setVisible(false)
        -- self:cancelUpdateForTime()
    elseif nType == 2 then
        self.pTmpServerLayer:setVisible(false)
        self.pLayBottom:setVisible(true)
    end
end

return LoginLayer