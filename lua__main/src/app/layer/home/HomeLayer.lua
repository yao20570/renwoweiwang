-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-17 17:09:10 星期五
-- Description: 主界面
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local HomeBottomLayer = require("app.layer.home.HomeBottomLayer")
local HomeTopLayer = require("app.layer.home.HomeTopLayer")
local HomeWorldTop = require("app.layer.home.HomeWorldTop")
local HomeCenterLayer = require("app.layer.home.HomeCenterLayer")
local HomeBaseLayer = require("app.layer.home.HomeBaseLayer")
local WorldPanel = require("app.layer.world.WorldPanel")
local BeAttackRedBorder = require("app.layer.world.BeAttackRedBorder")
local WorldBattleMenus = require("app.layer.worldbattle.WorldBattleMenus")
local WorldBattleDetail = require("app.layer.worldbattle.WorldBattleDetail")
local WorldSmallMap = require("app.layer.world.WorldSmallMap")
local OverView = require("app.layer.home.OverView")
local OverViewTipLayer = require("app.layer.home.OverViewTipLayer")
local HomeLayer = class("HomeLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MROOTLAYER)
end)

function HomeLayer:ctor(  )
	-- body
	self.fTimess = getSystemTime(false)
	self:myInit()
	-- 增加当前层的临时数据
	exchangeEmptyTmpMidLayer(self)
	parseView("layout_home", handler(self, self.onParseViewCallback))

--	if(b_open_viewpool) then
--		self:performWithDelay(function (  )
--			-- 正式启用缓存池
--			MViewPool:getInstance():setReady(true)
--		end, 2)
--	end
end

--初始化成员变量
function HomeLayer:myInit(  )
	-- body
	self.nZorderWTop 			= 		250 	--世界顶部层
	self.nZorderRebuildReward   =       210     --重建提示层 
	self.nZorderBlack			=       206     --黑色动画层
	self.nZorderBeHitNotice     =       205     --被攻击提示层 
	self.nZorderBattleMenu      =       203     --行军层
	self.nZorderTLBossSRank     =       202     --限时Boss层
	self.nZorderWorldArrow      =       201     --世界箭头层
	self.nZorderCenter 			= 		200 	--中间层级
	self.nZorderTop 			= 		100     --顶部层级
	self.nZorderBottom 			= 		100     --底部层级
	self.nZorderSmallMap        =       51      --小地图层
	self.nZorderShine 			= 		50 		--阳光层
	self.nZorderBase 			= 		20 		--基底层级
	self.nZorderWorld 			= 		10 		--世界层级
	self.nPreLv                 =       Player:getPlayerInfo().nLv --主公上一等级
	self.nPreVipLv              =       Player:getPlayerInfo().nVip --主公上一等级
	self.nCurLoginTime 			=       getSystemTime(false)
	self.bLogicStart 			= 		nil 	--是否加载完显示在主城界面
	self.bIsTLBRankShow         =       false   --默认隐藏限时排行榜
end

--解析布局回调事件
function HomeLayer:onParseViewCallback( pView )
	-- body
	pView:setLayoutSize(self:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	Player:initUIHomeLayer(self)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HomeLayer",handler(self, self.onHomeLayerDestroy))
end

--初始化控件
function HomeLayer:setupViews( )
	-- body
	self.pViewFill 				= self:findViewByName("view")
	--内容层
	self.pHomeContent 		    = self:findViewByName("content")
	--设置大小
	self.pHomeContent:setLayoutSize(display.width, display.height)
	self.pViewFill:requestLayout()

	--阳光层
	self.pLayShine 				= MUI.MLayer.new()
	self.pLayShine:setLayoutSize(display.width, display.height)
	self.pHomeContent:addView(self.pLayShine,self.nZorderShine)
	--添加阳光粒子效果
	self:addShineTx()

	--公告层
	self.pLayNotice 			= self:findViewByName("lay_notice")
	self.pLayNotice:setVisible(false)
-- gDumpTextureInfo()
-- gDumpLuaInfo()

	--左右云
	-- self.pImgYuRight 			= self:findViewByName("img_right")
	-- self.pImgYuLeft 			= self:findViewByName("img_left")
	-- self.pImgYuLeft:setFlippedX(true)
	-- self.pImgYuLeft:setFlippedY(true)

	-- self.pImgYuRight:setVisible(false)
	-- self.pImgYuLeft:setVisible(false)
	
	-- --设置位置
	-- self.pImgYuRight:setPosition(display.width / 2 - 80,display.height / 2)
	-- self.pImgYuLeft:setPosition(display.width / 2 + 80,display.height / 2)

myprint("time1=" .. (getSystemTime(false) - self.fTimess))
	--主界面顶部
	self.pHomeTop 	 			= HomeTopLayer.new()
	self.pHomeContent:addView(self.pHomeTop,self.nZorderTop)
	--设置位置
	self.pHomeTop:setPositionY(display.height - self.pHomeTop:getHeight())

	self.pLayNotice:setPositionY(self.pHomeTop:getPositionY() - 80 )

	self.pLayNotice:setLocalZOrder(1000)
	--世界顶部
	self.pWorldTop 				= HomeWorldTop.new()
	self.pHomeContent:addView(self.pWorldTop,self.nZorderWTop)
	--设置位置
	self.pWorldTop:setPositionY(display.height - self.pWorldTop:getHeight())

	--主界面底部
	self.pHomeBottom 			= HomeBottomLayer.new()
	self.pHomeContent:addView(self.pHomeBottom,self.nZorderBottom)

	--被攻击提示层
	self.pBeAttackLayer = BeAttackRedBorder.new()
    self.pBeAttackLayer:setIgnoreOtherHeight(true)
    self.pBeAttackLayer:setContentSize(self:getContentSize())
    self.pBeAttackLayer:requestLayout()
    self:addView(self.pBeAttackLayer, self.nZorderBeHitNotice)
    centerInView(self, self.pBeAttackLayer)

    --行军菜单层
    self.pWorldBattleMenus = WorldBattleMenus.new()
    self:addView(self.pWorldBattleMenus, self.nZorderBattleMenu)
   	self.pWorldBattleMenus:setPosition(display.width - 102, self.pHomeBottom:getHeight())

myprint("time2=" .. (getSystemTime(false) - self.fTimess))


    --行军详细界面
    self.pWorldBattleDetail = WorldBattleDetail.new()
    self:addView(self.pWorldBattleDetail, self.nZorderBattleMenu)
   	local nY = self.pHomeBottom:getHeight()
    self.pWBDetailOutPos = cc.p(display.width + self.pWorldBattleDetail:getContentSize().width, nY)
    self.pWBDetailInPos = cc.p(display.width - self.pWorldBattleDetail:getContentSize().width, nY)
    self.pWorldBattleDetail:setPosition(self.pWBDetailOutPos)

	--主界面中间层
	--计算中间层的大小
	local nCenterH = display.height - self.pHomeTop:getHeight() - self.pHomeBottom:getHeight()
	self.pHomeCenter 			= HomeCenterLayer.new(nCenterH)
	self.pHomeContent:addView(self.pHomeCenter,self.nZorderCenter)
	--设置位置
	self.pHomeCenter:setPositionY(self.pHomeBottom:getHeight())

myprint("time3=" .. (getSystemTime(false) - self.fTimess))
	
	--主界面基地
	self.pHomeBase 				= HomeBaseLayer.new(nCenterH + 85 + 56) --修改基地为中间显示的大小
	self.pHomeBase:setPositionY(self.pHomeBottom:getHeight() - 56) 
	self.pHomeContent:addView(self.pHomeBase,self.nZorderBase)

myprint("time4=" .. (getSystemTime(false) - self.fTimess))

	--已经选择了国家
	if Player:getPlayerInfo():getIsCountrySelected() then
		sendMsg(gud_load_chat_data)
	else
		--显示国家选择界面
		local DlgChoiceCountry = require("app.layer.country.DlgChoiceCountry")			
		local pDlg, bNew = getDlgByType(e_dlg_index.dlgchoicecountry)
		if not pDlg then
			pDlg = DlgChoiceCountry.new()
		end				
		pDlg:showDlg(bNew, self)	
	end

	--创建世界地图层
	self:getWorldPanel()
	local pSmallMap = self:getWorldSmallMap()
	local pSize = pSmallMap:getContentSize()
	local nTopH = self.pWorldTop:getHeight()

	--世界箭头层
	self.pLayWorldArrow = MUI.MLayer.new()
	self.pHomeContent:addView(self.pLayWorldArrow, self.nZorderWorldArrow)
	self.pLayWorldArrow:setLayoutSize(display.width, display.height)
	self.pLayWorldArrow:setPosition(display.width - 60 , display.height - pSize.height - nTopH - 45 )
	--世界箭头
	-- self.pArrowImg = MUI.MImage.new("#v1_img_sj_fanhui.png")
	self.pArrowImg = MUI.MImage.new("#v2_img_xiaoxia.png")
	self.pArrowImg:setViewTouched(true)
	self.pLyArrowImg = MUI.MLayer.new()
	--这个层取矩形
	self.pLyArrowImg:setLayoutSize(self.pArrowImg:getContentSize().height, self.pArrowImg:getContentSize().height)
	-- self.pLyArrowImg:setBackgroundImage("#v1_bg_popup3.png")
	local pSize = self.pArrowImg:getContentSize()
	-- local nAnchorX = (self.pArrowImg:getContentSize().height/2)/self.pArrowImg:getContentSize().width

	local pArrowLabel = MUI.MLabel.new({"",size=16})
	pArrowLabel:setPositionY(-15)
	pArrowLabel:enableOutline(cc.c4b(0, 0, 0, 255*0.5), 1)
	self.pArrowImg:setAnchorPoint(cc.p(0.5,0.5))
	self.pLyArrowImg:addChild(pArrowLabel, 10)
	self.pLyArrowImg.pArrowLabel = pArrowLabel

	local pArrowImage =  MUI.MImage.new("#v2_btn_czlba1.png")
	pArrowImage:setPositionY(12)
	pArrowImage:setAnchorPoint(cc.p(0.5,0.5))
	self.pLyArrowImg:addChild(pArrowImage, 9)
	self.pLyArrowImg.pArrowImage = pArrowImage


	self.pLyArrowImg:setVisible(false)
	self.pLayWorldArrow:addView(self.pLyArrowImg)
	self.pLyArrowImg:addView(self.pArrowImg)

	--先播放登陆音效
	-- Sounds.playMusic(Sounds.Music.shijie,true) 
	--更新loginlayer进度条
	updateLoginSlider(1,true)
	-- self.pHomeCenter:setVisible(true)
	-- self.pWorldTop:setVisible(false)
	-- self.pHomeTop:setVisible(true)
	myprint("time5=" .. (getSystemTime(false) - self.fTimess))

	-- -- 默认先隐藏小地图
	-- if self.pWorldSmallMap then
	-- 	self.pWorldSmallMap:setVisible(false)
	-- end
	-- if self.pWorldPanel then
	-- 	--等世界地图渲染好了隐藏起来，减少节点数（这里也是让世界的相机优先渲染）
	-- 	-- doDelayForSomething(self.pWorldPanel,function (  )
	-- 		-- body
	-- 		self.pWorldPanel:setVisible(false)
	-- 		--默认显示基地
	--  		self:showBaseOrWorld(1)
	-- 	-- end,0.2)
	-- end

	self:showBaseOrWorld(1)
	-- 强制增加战力提升的特效
	showFCChangeTx(0, 1, self)
	-- 强制增加竞技场排行的特效
	-- showRankChangeTx(0, 1, self)
	if b_open_overview then
		--左侧总览图片
		self.pImgOverView = MUI.MImage.new("#v2_btn__zjm_ukjt.png")
	    self:addView(self.pImgOverView, self.nZorderCenter)
		self.pImgOverView:setPosition(self.pImgOverView:getWidth()/2, 376 + self.pImgOverView:getHeight()/2)
		self.pImgOverView:setViewTouched(true)
		self.pImgOverView:setIsPressedNeedScale(false)
		self.pImgOverView:onMViewClicked(handler(self, self.onOverViewMenuClicked))

		self.bIsOpenOverView = getIsReachOpenCon(11, false)
		if self.bIsOpenOverView then
			self.pImgOverView:setVisible(true)
		else
			self.pImgOverView:setVisible(false)
		end
	else
		self.pImgOverView = nil
	end
end

-- 修改控件内容或者是刷新控件数据
function HomeLayer:updateViews(  )
	-- body
end

--
function HomeLayer:doFirstEnterHome(  )
	-- body
	if self.pHomeBase then
		print("time6=" .. (getSystemTime(false) - self.fTimess))
		self.pHomeBase:showScaleAtFirst()
		-- 播放音乐
		Sounds.playMusic(Sounds.Music.zhucheng,true) 

		self.bAfterEnterHome = true
		--上线显示总览文字冒泡提示
		if self.sOverViewTip then
			self.pOverViewTip:setVisible(true)
			self.pOverViewTip:setTips(self.sOverViewTip)
		end
	end
end

-- 析构方法
function HomeLayer:onHomeLayerDestroy(  )
	-- body
	self:onPause()
	self:cancelSendMsgSchedule()
	-- 释放占用
	releaseEmptyTmpMidLayer(self)
	--这里特别注意一下，释放数据修改在AccountCenter中的doClearBeforeBacktologin中，如果是退出游戏那么数据肯定会被回收掉
	-- Player:destroyPlayer()
end

-- 注册消息
function HomeLayer:regMsgs( )
	-- body
	-- 注册游戏恢复的消息
	regMsg(self,ghd_backtoforeground_msg, handler(self, self.onEnterForeground))
	-- 显示主界面
	regMsg(self,ghd_home_show_base_or_world, handler(self, self.onShowBaseOrWorld))
	-- 注册重连成功消息
	regMsg(self,ghd_msg_reconnect_success, handler(self, self.onReconnectSuccess))
	-- 打开任务领奖多画框
	regMsg(self,ghd_open_dlg_gettaskprize, handler(self, self.openDlgGetTaskPrize))
	-- 任务刷新
	regMsg(self,gud_refresh_task_msg, handler(self, self.onRefreshTask))
	-- 建筑等级升级对话框对主界面的影响
	regMsg(self,ghd_home_change_for_buildup_msg, handler(self, self.onHomeChangeByBuildUp))
	-- 注册主公等级变化消息
	regMsg(self, ghd_refresh_playerlv_msg, handler(self, self.onPlayerLvUp))
	-- 注册全屏对话框展示与关闭消息
	regMsg(self, ghd_state_for_filldlg_msg, handler(self, self.onFillDlgState))
	-- 注册背景音乐的开启消息（世界或者基地）
	regMsg(self, ghd_open_worldorbase_music_msg, handler(self, self.onOpenMusic))
	-- 注册打开云消息
	regMsg(self, ghd_open_yu_onhome_msg, handler(self, self.onOpenYu))
	-- 注册登陆后逻辑
	regMsg(self, ghd_do_logined_logic, handler(self, self.logicStartFunc))

	--注册行军菜单详情
	regMsg(self, ghd_show_world_battle_detail, handler(self, self.showWorldBattleDetail))

	--注册刷新活动红点
	regMsg(self, gud_refresh_act_red, handler(self, self.onRefrshActRed))

	--注册国家滚屏消息
	regMsg(self,ghd_refresh_chat,handler(self, self.addSystemNotice))

	--注册玩家Vip等级变化消息
	regMsg(self, ghd_refresh_playerviplv_msg, handler(self, self.onPlayerVipLvUp))

	--注册总览菜单显示与隐藏消息
	regMsg(self, ghd_showorhide_overview_menu, handler(self, self.showOrHideOverViewMenu))
	--注册总览文字冒泡提示消息
	regMsg(self, ghd_show_overview_tip, handler(self, self.showOverViewTip))
	--监听小排行榜的显示
	regMsg(self, ghd_show_tlboss_small_rank, handler(self, self.onTLBossSRankShow))
	--监听TLBoss来了
	regMsg(self, ghd_show_tlboss_warning, handler(self, self.onTLBossWarning))
	--注册装备打造完成消息
	regMsg(self, ghd_equip_make_finish_msg, handler(self, self.equipFinishMakeFunc))

end

-- 注销消息
function HomeLayer:unregMsgs(  )
	-- body
	-- 销毁游戏恢复的消息
    unregMsg(self, ghd_backtoforeground_msg)
    -- 销毁主界面注册消息
  	unregMsg(self, ghd_home_show_base_or_world)
  	-- 销毁重连成功消息
  	unregMsg(self, ghd_msg_reconnect_success)
  	unregMsg(self, ghd_open_dlg_gettaskprize)
  	unregMsg(self, gud_refresh_task_msg)
  	unregMsg(self, ghd_home_change_for_buildup_msg)
  	--注销等级变化消息
  	unregMsg(self, ghd_refresh_playerlv_msg)
  	--注销全屏对话框展示与关闭消息
  	unregMsg(self, ghd_state_for_filldlg_msg)
  	--注销背景音乐的开启消息（世界或者基地）
  	unregMsg(self, ghd_open_worldorbase_music_msg)
  	--注销打开云消息
  	unregMsg(self, ghd_open_yu_onhome_msg)
  	--注销登陆后逻辑
  	unregMsg(self, ghd_do_logined_logic)
  	--注销行军菜单详情
  	unregMsg(self, ghd_show_world_battle_detail)

	--注销刷新活动红点
  	unregMsg(self, gud_refresh_act_red)

  	--注销国家滚屏消息
  	unregMsg(self,ghd_refresh_chat)
  	--注销总览菜单显示与隐藏消息
  	unregMsg(self,ghd_showorhide_overview_menu)
  	--注销装备打造完成消息
  	unregMsg(self,ghd_equip_make_finish_msg)
  	--注销小排行榜的显示
	unregMsg(self, ghd_show_tlboss_small_rank)
	--注销TLBoss来了
	unregMsg(self, ghd_show_tlboss_warning)
end


--暂停方法
function HomeLayer:onPause( )
	-- body
	if not gIsNull(self.pHomeTop) then
		self.pHomeTop:onPause()
	end
	if not gIsNull(self.pWorldTop) then
		self.pWorldTop:onPause()
	end
	if not gIsNull(self.pHomeBottom) then
		self.pHomeBottom:onPause()
	end
	if not gIsNull(self.pHomeBase) then
		self.pHomeBase:onPause()
	end
	if not gIsNull(self.pHomeCenter) then
		self.pHomeCenter:onPause()
	end
	if not gIsNull(self.pWorldPanel) then
		self.pWorldPanel:onPause()
	end
	self:unregMsgs()
end

--继续方法
function HomeLayer:onResume( )
	-- body
	if not gIsNull(self.pHomeTop) then
		self.pHomeTop:onResume()
	end
	if not gIsNull(self.pWorldTop) then
		self.pWorldTop:onResume()
	end
	if not gIsNull(self.pHomeBottom) then
		self.pHomeBottom:onResume()
	end
	if not gIsNull(self.pHomeBase) then
		self.pHomeBase:onResume()
	end
	if not gIsNull(self.pHomeCenter) then
		self.pHomeCenter:onResume()
	end
	if not gIsNull(self.pWorldPanel) then
		self.pWorldPanel:onResume()
	end
	self:updateViews()
	self:regMsgs()
end

-- 进入前台,这里只是一个临时的过度，用来控制数据别那么快加载而已
function HomeLayer:onEnterForeground()
	-- 延迟执行正常的进入
	doDelayForSomething(self,function (  )
		self:onRealEnterForeground()
	end, 0.5)
end

-- 进入前台
function HomeLayer:onRealEnterForeground()
	myprint("进入前台============>")
	-- 判断到切换到后台的时间
	if(n_last_foreground_time and n_last_background_time and 
	    n_last_foreground_time > n_last_background_time) then
	    local fTempDis = n_last_foreground_time - n_last_background_time
	    local nAutoRecTime = 60 * 60 * 0.5 --超过半个小时就自动重连
	    if fTempDis >= nAutoRecTime then --超过半个钟自动重连一下
	        showReconnectDlg(e_disnet_type.cli, true, false,e_second_type.backToFore)
	    else
	    	--主界面部分UI执行刷新操作
	    	--刷新对联
			self:refreshCouplet()
			--行军线路数据更新
			self:reqWorldWarLine()
	    end
	else
		--主界面部分UI执行刷新操作
		--刷新对联
		self:refreshCouplet()
		--行军线路数据更新
		self:reqWorldWarLine()
	end
	sendMsg(ghd_real_enter_foreground)
end

--重连成功消息回调
function HomeLayer:onReconnectSuccess( sMsgName, pMsgObj )
	-- body
	print("重连成功=========")
	if pMsgObj then
		--是否自动重连
		local bIsAutoRec = pMsgObj.bIsAuto
		--是否是后台切前台
		local nSecType = pMsgObj.nSecType
		local bIsNeedHome = pMsgObj.bIsNeedHome

		-- 分帧刷新消息
		self:startSendMsgSchedule()

		--刷新建筑数据
		self.pHomeBase:refreshBuildGroups()
		--刷新对联
		self:refreshCouplet()
		--若已经选择国家才执行新手
		if Player:getPlayerInfo().nCountrySelected == 1 then
			--重新执行新手引导
			self:logicStartFunc()
		end

		if bIsNeedHome == true then --需要切到主界面
			--关闭所有的对话框
			closeAllDlg(true)
			--切换到主基地
		   	sendMsg(ghd_home_show_base_or_world, 1)
		end
		--存在战斗界面就关闭
		if Player:getUIFightLayer() then
			sendMsg(ghd_fight_close)
		end

		--发送重连成功消息
		sendMsg(gud_reconnect_success)
	end
end

--分帧发送重连消息
function HomeLayer:startSendMsgSchedule(  )
	-- body
	self:cancelSendMsgSchedule()
	local nIndex = 1
	self.nSendMsgScheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
		local tKeys = table.keys(tMsgReconnectDatas)
		local pMsgDatas = tMsgReconnectDatas[tKeys[nIndex]]
		if pMsgDatas then
			Gf_doRealSendOneMsg(pMsgDatas)
		end
		nIndex = nIndex + 1
		if self ~= nil and self.nSendMsgScheduler ~= nil and nIndex > table.nums(tMsgReconnectDatas) then
	        self:cancelSendMsgSchedule()
	        tMsgReconnectDatas = nil
	        tMsgReconnectDatas = {}
		end
	end)
end

--取消分帧刷新消息
function HomeLayer:cancelSendMsgSchedule(  )
	-- body
	if self.nSendMsgScheduler then
		MUI.scheduler.unscheduleGlobal(self.nSendMsgScheduler)
		self.nSendMsgScheduler = nil
	end
end

--刷新对联
function HomeLayer:refreshCouplet(  )
	-- body
	--发送消息刷新对联
	local tObj = {}
	tObj.nType = 2
	sendMsg(ghd_refresh_homeitem_msg, tObj)
end

--线路重新请求
function HomeLayer:reqWorldWarLine( )
	sendMsg(ghd_world_war_line_req, tObj)
end

--设置是基地还是世界
function HomeLayer:onShowBaseOrWorld( sMsgName, pMsgObj )
	if pMsgObj then		
		self:showBaseOrWorld(pMsgObj)
		--打开基地或世界界面和任务检测消息
		sendMsg(ghd_open_dlg_task_msg, pMsgObj + 100)
	else
		myprint("HomeLayer:onShowBaseOrWorld 参数错误 ",pMsgObj)
	end
end

--获取当前是基地还是世界
function HomeLayer:getCurChoice( )
	return self.nCurChoice
end

--显示世界还基地
--nIndex: 1:基地,2:世界
function HomeLayer:showBaseOrWorld( nIndex )
	--开启判断
	if nIndex == 2 then --世界未开启提示
		local bIsOpen = getIsReachOpenCon(4)
		if not bIsOpen then
			return
		end
	end
	if self.nCurChoice == nIndex then
		if nIndex == 2 then
			--隐藏总览
			if self.pImgOverView then
				self.pImgOverView:setVisible(false)
			end
		end
		return
	end
	--隐藏总览
	if self.pImgOverView then
		self.pImgOverView:setVisible(false)
	end

	self.nCurChoice = nIndex

	--显示基地
	if nIndex == 1 then
		if self.pWorldPanel then
			self.pWorldPanel:setVisible(false)
			if(self.pWorldPanel and self.pWorldPanel._camera) then
				self.pWorldPanel._camera:setVisible(false)
                self.pWorldPanel._camera2:setVisible(false)
			end
		end
		if self.pWorldSmallMap then
			self.pWorldSmallMap:setVisible(false)
		end

		--隐藏世界玩法说明图标
		if self.pImgWorldHelp then
			self.pImgWorldHelp:setVisible(false)
		end

		--隐藏或显示
		-- self.pHomeCenter:setVisible(true)
		self.pHomeCenter:changeToWorldOrBase(1)
		self.pWorldTop:setVisible(false)
		self.pHomeTop:setVisible(true)
		self.pHomeBase:setVisible(true)
		self.pLayWorldArrow:setVisible(false)
		if Player.bRealyShowHome then
			-- 播放音乐
			Sounds.playMusic(Sounds.Music.zhucheng,true) 
		end

		--判断是否显示总览
		if self.pImgOverView then
			if self.bIsOpenOverView then
				self.pImgOverView:setVisible(true)
			else
				self.pImgOverView:setVisible(false)
			end
		end
		if not tolua.isnull(self.pVictoryArm) then
			self.pVictoryArm:removeSelf()
		end
		if not tolua.isnull(self.pFailArm) then
			self.pFailArm:removeSelf()
		end
		--隐藏限时Boss小排行榜
		sendMsg(ghd_show_tlboss_small_rank, false)
	elseif nIndex == 2 then --显示世界
		--初始化
		self:getWorldPanel()
		if self.pWorldPanel then
			-- self.pWorldPanel:stopAllActions()
			self.pWorldPanel:setVisible(true)
		end
		if self.pWorldSmallMap then
			self.pWorldSmallMap:setVisible(true)
		end
		if not self.bFirst then
			if self.pWorldPanel and self.pWorldPanel.pWorldLayer then
				-- self.pWorldPanel.pWorldLayer:JumpToMyCityDot()
				self.pWorldPanel.pWorldLayer:doFirstEnterLogic()
			end
			self.bFirst = true
		end

		--隐藏或显示
		-- self.pHomeCenter:setVisible(false)
		self.pHomeCenter:changeToWorldOrBase(2)
		
		self.pWorldTop:setVisible(true)
		self.pHomeTop:setVisible(false)
		self.pHomeBase:setVisible(false)
		self.pLayWorldArrow:setVisible(true)
		--播放音乐
		Sounds.playMusic(Sounds.Music.shijie,true) 
		if(self.pWorldPanel and self.pWorldPanel._camera) then
			self.pWorldPanel._camera:setVisible(true)
            self.pWorldPanel._camera2:setVisible(true)
		end
	else
		myprint("HomeLayer:showBaseOrWorld 参数错误 ",nIndex)
		return
	end

	--其他部分设置数据
	self.pHomeBottom:setCurChoice(self.nCurChoice)

    -- 延迟一帧后gc lua，因为Sounds.playMusic很耗时，GCMgr:gc也很耗时
    self.nAddScheduler = MUI.scheduler.performWithDelayGlobal(function ()
        GCMgr:gcByMax()
    end, 0.01)
end

--获得世界地图层
function HomeLayer:getWorldPanel( )
	--小地图
	if not self.pWorldSmallMap then
		local pWorldSmallMap = WorldSmallMap.new()
		local pSize = pWorldSmallMap:getContentSize()
		local nTopH = self.pWorldTop:getHeight()
		pWorldSmallMap:setPosition(display.width - pSize.width, display.height - pSize.height - nTopH + 10)
		self.pHomeContent:addView(pWorldSmallMap, self.nZorderSmallMap)
		self.pWorldSmallMap = pWorldSmallMap
	end

	-- body
	if not self.pWorldPanel then
		--大地图主界面主地图界面
		local nBottomH = self.pHomeBottom:getHeight()
		local nTopH = self.pWorldTop:getHeight()
		self.pWorldPanel = WorldPanel.new(display.width, display.height, nBottomH, nTopH)
		self.pHomeContent:addView(self.pWorldPanel,self.nZorderWorld)
		-- --设置对联关联
		-- local pWorldLeft = self.pWorldPanel:getWorldLeft()
		-- if pWorldLeft then
		-- 	local pNoticesLayer = self.pHomeBottom:getBeAttackNoticesLayer()
		-- 	if pNoticesLayer then
		-- 		pNoticesLayer:setWorldLeft(pWorldLeft)
		-- 	end
		-- end
	end
end

--弹出主线任务完成奖励面板
function HomeLayer:openDlgGetTaskPrize( sMsgName, pMsgObj )
 	if B_GUIDE_LOG then
 		print("主线任务奖励")
 	end
 	if pMsgObj and pMsgObj.nTaskId then
		local nLayerType = self
		--如果是招募任务, 把层级放到最上面
		if pMsgObj.nTaskId == e_special_task_id.recruit_xiaoqiao or
			pMsgObj.nTaskId == e_special_task_id.recruit_jingke or
			pMsgObj.nTaskId == e_special_task_id.recruit_hero then

			nLayerType = getRealShowLayer(self, e_layer_order_type.toastlayer)
		end
		showDlgTaskPrize(nLayerType, pMsgObj.nTaskId)
 	end
end 

--新手引导检测
function HomeLayer:checkNewGuide()
	if B_GUIDE_LOG then
		print("任务刷新 新手引导检测 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	end
	if not b_open_guide then return end
	Player:getNewGuideMgr():showNewGuideByTask()
	--新功能解锁触发引导
	-- Player:getNewGuideMgr():showNewFuncGuide()
end

--添加国家滚屏
function HomeLayer:addSystemNotice(msgName, pMsg )
	 if pMsg then
		local nType = pMsg.nType
		-- local tData = pMsg.data
		if nType == 4 then  --滚屏类型
			self.pLayNotice:setVisible(true)
			local tData = Player:getSystemNoticeData(self.nCurLoginTime)		
			local SystemNotice = require("app.layer.systemnotice.SystemNotice")
			for i=1,#tData do
				if not Player:isHaveRoll(tData[i].nId) then
					if not self.pNotice then
						--喇叭消息层
						self.pNotice = SystemNotice.new()
						self.pLayNotice:addView(self.pNotice)
					end
				-- self.pNotice:setCurData(tData)
					self.pNotice:setCurData(tData[i])
				end
			
			end
		end
	end
end

--刷新活动红点
function HomeLayer:onRefrshActRed()
	Player:getActRedNums()
end

--
function HomeLayer:onHomeChangeByBuildUp(sMsgName, pMsgObj)
	-- body
	if pMsgObj and pMsgObj.nType then
		local ntype = pMsgObj.nType or 1
		if ntype == 1 then--隐藏
			self.pHomeTop:setVisible(false)
			self.pHomeCenter.pLayLeft:setVisible(false)
			self.pHomeCenter.pLayRight:setVisible(false)
			self.pHomeCenter.pHomeBuffs:setVisible(false)
		elseif ntype == 2 then--显示
			self.pHomeTop:setVisible(true)
			self.pHomeCenter.pLayLeft:setVisible(true)
			self.pHomeCenter.pLayRight:setVisible(true)
			self.pHomeCenter.pHomeBuffs:setVisible(true)
		end
	end
end

--升级奖励弹窗
function HomeLayer:onPlayerLvUp()
	-- body
	-- 玩家升级统计
	doSummitData3k(3)
	local nCurLv = Player:getPlayerInfo().nLv
	if nCurLv > self.nPreLv then
		--弹出升级奖励界面
		local tLvUp = getAvatarLvUpByLevel(nCurLv)
		if tLvUp and tLvUp.award then
			local function func(  )
				local tObject = {}
				tObject.nType = e_dlg_index.dlglevelupawards --dlg类型
				tObject.tData = tLvUp.award
				sendMsg(ghd_show_dlg_by_type,tObject)
				if Player:getUIHomeLayer() then --在主界面才播放音效
					--播放音效
					Sounds.playEffect(Sounds.Effect.lvup)
				end
			end
			showSequenceFunc(e_show_seq.kindreward, func)
		end
		--触发按等级解锁功能
		Player:getNewGuideMgr():showNewGuideByLvRange(self.nPreLv, nCurLv)
	end
	self.nPreLv = nCurLv
	--发送请求我国国战列表
	if nCurLv == getWorldInitData("warOpen") then
		SocketManager:sendMsg("reqWorldMyCountryWar",{})
	end 
end

--Vip等级升级奖励弹窗
function HomeLayer:onPlayerVipLvUp(  )
 	-- body
	local nCurVipLv = Player:getPlayerInfo().nVip
	local tVipLvUp = getAvatarVIPByLevel(nCurVipLv)
	if tVipLvUp.describe and nCurVipLv > self.nPreVipLv then
		self.nPreVipLv = nCurVipLv
		local function func(  )
			local tObject = {}
			tObject.nType = e_dlg_index.dlglevelupawards --dlg类型
			tObject.tData = tVipLvUp.describe
			tObject.nAwardType = 1
			sendMsg(ghd_show_dlg_by_type,tObject)
			if Player:getUIHomeLayer() then --在主界面才播放音效
				--播放音效
				Sounds.playEffect(Sounds.Effect.lvup)
			end
		end
		showSequenceFunc(e_show_seq.kindreward, func)
	end 	
 end 

--设置子控件消息监听在pHomeContent隐藏时是否监听
--bIsListen: 
 function HomeLayer:setChildMsgListen( bIsListen )
 	--print("HomeLayer:setChildMsgListen===========",bIsListen)
 	if bIsListen then
 	-- 	gRefreshViewsAsync(self, 6, function (  _bEnd, _index  )
 	-- 		if _index == 1 then
		--  		if not gIsNull(self.pHomeTop) then
		-- 			self.pHomeTop:onResume()
		-- 		end
		-- 	elseif _index == 2 then
		-- 		if not gIsNull(self.pWorldTop) then
		-- 			self.pWorldTop:onResume()
		-- 		end
		-- 	elseif _index == 3 then
		-- 		if not gIsNull(self.pHomeBottom) then
		-- 			self.pHomeBottom:onResume()
		-- 		end
		-- 	elseif _index == 4 then
		-- 		if not gIsNull(self.pWorldPanel) then
		-- 			self.pWorldPanel:onResume()
		-- 		end
		-- 	elseif _index == 5 then
		-- 		if not gIsNull(self.pHomeCenter) then
		-- 			self.pHomeCenter:onResume()
		-- 		end
		-- 	elseif _index == 6 then
		-- 		if not gIsNull(self.pHomeBase) then
		-- 			self.pHomeBase:onResumePart()
		-- 		end
		-- 	end
		-- end)
		
		if not gIsNull(self.pHomeBase) then
			self.pHomeBase:onResumePart()
		end
	else
	 -- 	if not gIsNull(self.pHomeTop) then
		-- 	self.pHomeTop:onPause()
		-- end
		-- if not gIsNull(self.pWorldTop) then
		-- 	self.pWorldTop:onPause()
		-- end
		-- if not gIsNull(self.pHomeBottom) then
		-- 	self.pHomeBottom:onPause()
		-- end
		-- if not gIsNull(self.pHomeCenter) then
		-- 	self.pHomeCenter:onPause()
		-- end
		-- if not gIsNull(self.pWorldPanel) then
		-- 	self.pWorldPanel:onPause()
		-- end
		
		if not gIsNull(self.pHomeBase) then
			self.pHomeBase:onPausePart()
		end
	end
 end

--全屏对话框展示与关闭消息毁掉
function HomeLayer:onFillDlgState( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		if nType == 1 then
			self.pHomeContent:setVisible(false)
			-- --过渡层
			-- if(not self.pTmpLaySeqLayer) then
			-- 	self.pTmpLaySeqLayer = MUI.MLayer.new()
			-- 	self.pTmpLaySeqLayer:setLayoutSize(display.width, display.height)
			-- 	self.pTmpLaySeqLayer:setBackgroundImage("#v1_bg_1.png",{scale9 = true,capInsets=cc.rect(32,32, 1, 1)})
			-- 	self:addView(self.pTmpLaySeqLayer,100)
			-- end
			-- self.pTmpLaySeqLayer:setVisible(true)
			--关闭子对像消息监听
			self:setChildMsgListen(false)
		elseif nType == 2 then
			self.pHomeContent:setVisible(true)
			-- if self.pTmpLaySeqLayer then
			-- 	self.pTmpLaySeqLayer:setVisible(false)
			-- end
			--开启子对像消息监听
			self:setChildMsgListen(true)
		end
	end
end

--开启背景音乐
function HomeLayer:onOpenMusic( sMsgName, pMsgObj )
	-- body
	if self.nCurChoice == 1 then --基地
		-- 播放音乐
		Sounds.playMusic(Sounds.Music.zhucheng,true) 
	elseif self.nCurChoice == 2 then --世界
		-- 播放音乐
		Sounds.playMusic(Sounds.Music.shijie,true) 
	end
end

--设置展示homelayer回调
function HomeLayer:setShowHomeLayerCallBack( _nHnalder )
	-- body
	self.nCallShowHomeLayer = _nHnalder
end

--打开云消息回调
function HomeLayer:onOpenYu( sMsgName, pMsgObj )
	-- body
	if self.nCallShowHomeLayer then
		self.nCallShowHomeLayer()
		--移除开机图相关纹理
		removeTextureForLanConfig()
	end

	if(device.platform == "ios") then -- iPhoneX适配: 显示顶部和底部的补缺图
        local luaoc = require("framework.luaoc")
        luaoc.callStaticMethod("PlatformSDK", "showIphoneSafeArea", {show="1"})
    end
	--右边云
	-- local actionR = cc.MoveBy:create(0.68, cc.p(910, -630))
	-- local actionEndR = cc.CallFunc:create(function (  )
	-- 	-- body
	-- 	self.pImgYuRight:setVisible(false)
	-- 	self.pImgYuRight:removeSelf()
	-- 	self.pImgYuRight = nil
	-- end)
	-- local allActionsR = cc.Sequence:create(actionR,actionEndR)
	-- self.pImgYuRight:runAction(allActionsR)
	-- --左边云
	-- local actionL = cc.MoveBy:create(0.68, cc.p(-910, 630))
	-- local actionEndL = cc.CallFunc:create(function (  )
	-- 	-- body
	-- 	self.pImgYuLeft:setVisible(false)
	-- 	self.pImgYuLeft:removeSelf()
	-- 	self.pImgYuLeft = nil
	-- end)
	-- local allActionsL = cc.Sequence:create(actionL,actionEndL)
	-- self.pImgYuLeft:runAction(allActionsL)
end

--登陆逻辑
function HomeLayer:logicStartFunc(  )
	self.bLogicStart = true
	--新手引导检测
	releaseShowSequenceData()
	Player:getNewGuideMgr():setHomeLayer(self)
	Player:getGirlGuideMgr():setHomeLayer(self)
	Player:getNewGuideMgr():initModelUnlock()
	self:checkNewGuide()
	
	--弹出主线任务完成奖励面板
	local curAgencyTask = Player:getPlayerTaskInfo():getCurAgencyTask()
 	if curAgencyTask and (curAgencyTask.nIsFinished == 1 and curAgencyTask.nIsGetPrize == 0) then
 		--打开奖励面板
 		local pMsgObj = {}
 		pMsgObj.nTaskId = curAgencyTask.sTid
		sendMsg(ghd_guide_finger_show_or_hide, false)
		self:openDlgGetTaskPrize(ghd_open_dlg_gettaskprize, pMsgObj)		
	end

	--弹出重新建筑任务奖励面板
	local tReward = Player:getWorldData():getRebuildReward()
	if tReward and #tReward > 0 then
		sendMsg(ghd_guide_finger_show_or_hide, false)
 		--打开奖励面板
		showDlgReBuildReward(self)
	end

	--飘出离线获得的物品
	local tOffLineReward = Player:getWorldData():getOffLineReward()
	if tOffLineReward and #tOffLineReward > 0 then
		showGetAllItems(tOffLineReward)
		Player:getWorldData():clearOffLineReward()
	end

	--离线触发礼包
	local nPid, nGid = Player:getTriggerGiftData():getOffLineTpackPidGid()
	if nPid and nGid then
		-- showDlgTriggerGift(nTriGiftPid, self)
		openDlgTriggerGift(nPid, nGid, self)
		--关闭离线标识
		Player:getTriggerGiftData():closeAllOffLineTpackPid()
	end

	--检测是否有每日登录奖励领取
	-- sendMsg(gud_refresh_dayloginawards) --通知刷新界面

	--检测Npc任务
	sendMsg(gud_refresh_task_msg)
	--好友以及主界面菜单红点
	sendMsg(ghd_item_home_menu_red_msg)
	--顺序面板开始
	showFirstSequenceFunc()
	--国家城池数据刷新
	sendMsg(gud_refresh_countrycity_msg)
end

--装备打造完成提示
function HomeLayer:equipFinishMakeFunc( sMsgName, pMsgObj )
	-- body
	if self.bLogicStart then
		if pMsgObj and pMsgObj.tEquipData then
			TOAST(string.format(getConvertedStr(7, 10335), pMsgObj.tEquipData.sName))
		end
	end
end

--显示行军菜单详情
function HomeLayer:showWorldBattleDetail( sMsgName, pMsgObj )
	local nTabIndex = pMsgObj
	if nTabIndex then
		--切换
		self.pWorldBattleDetail:changeTabIndex(nTabIndex)
		--移入
		self.pWorldBattleDetail:stopAllActions()
		self.pWorldBattleDetail:runAction(cc.MoveTo:create(0.1, self.pWBDetailInPos))
		--隐藏
		self.pWorldBattleMenus:setVisibleEx(false)
	else
		--移出
		self.pWorldBattleDetail:stopAllActions()
		self.pWorldBattleDetail:runAction(cc.MoveTo:create(0.1, self.pWBDetailOutPos))
		--显示
		self.pWorldBattleMenus:setVisibleEx(true)
	end
end

--显示与隐藏总览菜单
function HomeLayer:showOrHideOverViewMenu(sMsgName, pMsgObj)
	-- body
	if not self.pOverView then
		--总览界面
	    self.pOverView = OverView.new()
	    self:addView(self.pOverView, self.nZorderCenter)
	    self.pOverViewOutPos = cc.p(-self.pOverView:getContentSize().width, 0)
	    self.pOverViewInPos = cc.p(0, 0)
	    self.pOverView:setPosition(self.pOverViewOutPos)
	end
	if pMsgObj then
		--移入
		self.pOverView:stopAllActions()
		self.pOverView:runAction(cc.MoveTo:create(0.1, self.pOverViewInPos))
		--隐藏
		self.pImgOverView:setVisible(false)
		self.pOverView:onScrollToBegin()
		B_OVERVIEW_LAYER = true
	else
		--移出
		self.pOverView:stopAllActions()
		self.pOverView:runAction(cc.MoveTo:create(0.1, self.pOverViewOutPos))
		--显示
		self.pImgOverView:setVisible(true)
		B_OVERVIEW_LAYER = false
	end
end

--显示总览文字冒泡提示
function HomeLayer:showOverViewTip(sMsgName, pMsgObj)
	if pMsgObj and pMsgObj.sTip then
		if not self.pImgOverView or not self.pImgOverView:isVisible() then
			return
		end
		if not self.pOverViewTip then
			self.pOverViewTip = OverViewTipLayer.new()
			self:addView(self.pOverViewTip, self.nZorderCenter)
			self.pOverViewTip:setPosition(self.pImgOverView:getWidth() + 12, self.pImgOverView:getPositionY() - self.pOverViewTip:getHeight()/2)
		end

		--如果已经进入基地直接显示
		if self.bAfterEnterHome then
			self.pOverViewTip:setVisible(true)
			self.pOverViewTip:setTips(pMsgObj.sTip)
		else
			--先保存数据,等进入基地再显示
			self.sOverViewTip = pMsgObj.sTip
		end
	end
end

--总览点击事件
function HomeLayer:onOverViewMenuClicked( )
	--检测新手
 	self:showOrHideOverViewMenu(1, true)
 end

--任务刷新
function HomeLayer:onRefreshTask( )
	--检测新手
 	self:checkNewGuide()
 	if self.pImgOverView then
	 	self.bIsOpenOverView = getIsReachOpenCon(11, false)
		if self.bIsOpenOverView and self.nCurChoice == 1 then
			self.pImgOverView:setVisible(true)
		else
			self.pImgOverView:setVisible(false)
		end
	end
 end

--添加阳光特效
function HomeLayer:addShineTx(  )
	-- body
    if(b_close_paritcle_of_android == true) then
        return
    end

	local pParitcle1 =  createParitcle("tx/other/lizi_yg_zjm_07.plist")
	pParitcle1:setPosition(744, display.height - 1)
	pParitcle1:setScale(2)
	self.pLayShine:addView(pParitcle1)

	local pParitcle2 =  createParitcle("tx/other/lizi_yg_zjm_04.plist")
	pParitcle2:setPosition(642, display.height -21)
	pParitcle2:setScale(0.5)
	self.pLayShine:addView(pParitcle2)

	local pParitcle3 =  createParitcle("tx/other/lizi_yg_zjm_01.plist")
	pParitcle3:setPosition(668, display.height - 3)
	pParitcle3:setScale(2.5)
	self.pLayShine:addView(pParitcle3)

	local pParitcle4 =  createParitcle("tx/other/lizi_yg_zjm_03.plist")
	pParitcle4:setPosition(698, display.height + 9)
	pParitcle4:setScale(2.5)
	self.pLayShine:addView(pParitcle4)

	local pParitcle5 =  createParitcle("tx/other/lizi_yg_zjm_04.plist")
	pParitcle5:setPosition(686, display.height - 12)
	pParitcle5:setScale(0.5)
	self.pLayShine:addView(pParitcle5)
	--设置阳光常态播放
	pParitcle1:setNeedCheckScreen(false)
	pParitcle2:setNeedCheckScreen(false)
	pParitcle3:setNeedCheckScreen(false)
	pParitcle4:setNeedCheckScreen(false)
	pParitcle5:setNeedCheckScreen(false)
end

function HomeLayer:getWorldSmallMap(  )
	return self.pWorldSmallMap
end

function HomeLayer:getHomeBottom(  )
	return self.pHomeBottom
end

function HomeLayer:getHomeCenter( )
	-- body

	return self.pHomeCenter
end

--获取箭头
function HomeLayer:getArrowImg(  )
	return self.pArrowImg
end

--获取箭头层
function HomeLayer:getLyArrowImg(  )
	return self.pLyArrowImg
end

--显示或隐藏伤害排行榜
function HomeLayer:onTLBossSRankShow( sMsgName, pMsgObj )
	--显示或隐藏
	local bIsShow = pMsgObj
	if bIsShow == nil then --没有的时候就取反
		self.bIsTLBRankShow = not self.bIsTLBRankShow
	else
		self.bIsTLBRankShow = bIsShow
	end

	if self.bIsTLBRankShow then
		--伤害排行榜
		if self.pTLBossHarmSRank then
			self.pTLBossHarmSRank:setVisible(true)
		else
			local TLBossHarmSRank = require("app.layer.tlboss.TLBossHarmSRank")
			self.pTLBossHarmSRank = TLBossHarmSRank.new()
			self.pTLBossHarmSRank:setPosition(20, display.height * 0.52)
			self.pHomeContent:addView(self.pTLBossHarmSRank, self.nZorderTLBossSRank)
		end
		
		--次数排行榜
		if self.pTLBossHitNumSRank then
			self.pTLBossHitNumSRank:setVisible(true)
		else
			local TLBossHitNumSRank = require("app.layer.tlboss.TLBossHitNumSRank")
			self.pTLBossHitNumSRank = TLBossHitNumSRank.new()
			self.pTLBossHitNumSRank:setPosition(display.width - self.pTLBossHitNumSRank:getContentSize().width - 20, display.height * 0.52)
			self.pHomeContent:addView(self.pTLBossHitNumSRank, self.nZorderTLBossSRank)
		end
	else
		if self.pTLBossHarmSRank then
			self.pTLBossHarmSRank:setVisible(false)
		end

		if self.pTLBossHitNumSRank then
			self.pTLBossHitNumSRank:setVisible(false)
		end
	end
end

--获取是否显示
function HomeLayer:getIsTLBRankShow(  )
	return self.bIsTLBRankShow
end

--限时Boss警告
function HomeLayer:onTLBossWarning(  )
	showTLBossWarning(self, self.nZorderBeHitNotice)
end

return HomeLayer