-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-10 14:46:34 星期一
-- Description: 主界面底部模块
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local RichTextEx = require("app.common.richview.RichTextEx")
local ItemHomeMenu = require("app.layer.home.ItemHomeMenu")
-- local HomeTaskLayer = require("app.layer.country.HomeTaskLayer")
-- local WorldTargetLayer = require("app.layer.worldtarget.WorldTargetLayer")
-- local BeAttackNoticesLayer = require("app.layer.world.BeAttackNoticesLayer")

local HomeBottomLayer = class("HomeBottomLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function HomeBottomLayer:ctor(  )
	-- body
	self:myInit()
	parseView("layout_home_bottom", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function HomeBottomLayer:myInit(  )
	-- body
	 self.nChatType = 1 --聊天类型
end


--解析布局回调事件
function HomeBottomLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HomeBottomLayer",handler(self, self.onHomeBottomLayerDestroy))
end

--初始化控件
function HomeBottomLayer:setupViews( )
	-- body

	--世界基地切换层
	self.pMainChoice 			= self:findViewByName("lay_main_choice")
	self.pMainChoice:setViewTouched(true)
	self.pMainChoice:setIsPressedNeedScale(false)
	self.pMainChoice:onMViewClicked(handler(self, self.onMainClicked))

	--新手引导设置入口
	Player:getNewGuideMgr():setNewGuideFinger(self.pMainChoice, e_guide_finer.world_enter_btn)

	--时间
	self.pLbTime 				= self:findViewByName("lb_time")
	setTextCCColor(self.pLbTime,_cc.dblue)
	self:onUpdateEverySecond()

	--聊天层
	self.pLayChat 				= self:findViewByName("lay_chat")
	self.pLayChat:setViewTouched(true)
	self.pLayChat:setIsPressedNeedScale(false)
	self.pLayChat:onMViewClicked(handler(self, self.onChatClicked))

	--新好友红点
	self.pLayRed 				= self:findViewByName("lay_friend_red")
	--聊天内容
--	self.pLbChatCn = MUI.MLabel.new({
--	    text = "",
--	    size = 20,
--	    anchorpoint = cc.p(0, 0.5),
--	    align = cc.ui.TEXT_ALIGN_LEFT,
--		valign = cc.ui.TEXT_VALIGN_CENTER,
--	    color = cc.c3b(255, 255, 255),
--	    dimensions = cc.size(430, 60),

--	    })
    self.pLbChatCn = RichTextEx.new({width = 460, autow = true, maxlinecount = 2})
	self.pLbChatCn:setAnchorPoint(cc.p(0, 0.5))
	self.pLbChatCn:setPosition(10,self.pLayChat:getHeight() / 2)
	self.pLayChat:addView(self.pLbChatCn)


	--菜单listview
	self.pMenuLayer 			= self:findViewByName("lay_menu")
	local pListViewMenu = MUI.MListView.new {
	    viewRect = cc.rect(0, 0, self.pMenuLayer:getWidth(), self.pMenuLayer:getHeight()),
	    itemMargin = {
	    	left =  14,
            right =  0,
            top = 0 ,
            bottom =  0},
	    direction = MUI.MScrollLayer.DIRECTION_HORIZONTAL}
	self.pMenuLayer:addView(pListViewMenu)
	pListViewMenu:setBounceable(true)
	self.pListViewMenu = pListViewMenu

	self.tIndexList = nil
	if b_open_ios_shenpi then
		self.tIndexList = {
			e_home_bottom.hero,
			e_home_bottom.copy,
			e_home_bottom.country,
			e_home_bottom.mail,
			e_home_bottom.bag,
			e_home_bottom.godweapon,
			e_home_bottom.task,
			e_home_bottom.setting,
		}
	else
		self.tIndexList = {
			e_home_bottom.hero,
			e_home_bottom.copy,
			e_home_bottom.country,
			e_home_bottom.mail,
			e_home_bottom.bag,
			e_home_bottom.godweapon,
			e_home_bottom.task,
			e_home_bottom.friend,
			e_home_bottom.rank,
			e_home_bottom.setting,
		}
	end

	pListViewMenu:setItemCount(#self.tIndexList)
	pListViewMenu:setItemCallback(function ( _index, _pView )
		local nIndex = self.tIndexList[_index]
	    local pTempView = _pView
	    if pTempView == nil then
	    	pTempView = ItemHomeMenu.new()
	    end
	    pTempView:setGuideFingerUi(self)
	    --设置类型
	    pTempView:setCurIndex(nIndex)
	    return pTempView
	end)
	-- 载入所有展示的item
	pListViewMenu:reload()

	self.pListViewMenu = pListViewMenu

	pListViewMenu:onScroll(function(event)
		-- body
		if event.name == "began" then --开始
		elseif event.name == "moved" then
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()
		elseif event.name == "ended" then --结束
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()
		end
	end)
end

-- 修改控件内容或者是刷新控件数据
function HomeBottomLayer:updateViews(  )
	-- body
end

--接收聊天消息
function HomeBottomLayer:receiveChatData(msgName,pMsg)
	if pMsg then
		local nType = pMsg.nType
		self:refreshChatCn(nType)
    else
        -- 重连后
        self:refreshChatCn(e_lt_type.sj)
	end
end

-- 刷新聊天内容
function HomeBottomLayer:refreshChatCn(_nType)
	if _nType then
		local strRich = {}
		local nType = _nType
		local tChatData = Player:getChatInfoByType(nType)
		local nChatLong =  table.nums(tChatData)
		if tChatData and nChatLong > 0 then


			local pChatData = tChatData[nChatLong] --拿到需要显示的聊天数据
			if pChatData and pChatData.sCnt and pChatData.sSn  then
				local nMaxLen = 35 * string.len(getConvertedStr(5, 10188))
				local nTotalLen = 0

				if pChatData.nTmsg == 2 then --系统信息
					table.insert(strRich,{text= getConvertedStr(5, 10218).."：",color = _cc.white})
				elseif pChatData.nTmsg == 4 then --红包信息
					table.insert(strRich,{text= getConvertedStr(6, 10626).."：",color = _cc.white})
				elseif pChatData.nTmsg == 5 then --天降红包
					table.insert(strRich,{text= getConvertedStr(9, 10174).."：",color = _cc.white})
				else
					if pChatData.nSid == Player.baseInfos.pid then
						table.insert(strRich,{text= getConvertedStr(5, 10187),color = _cc.white})
					else
						table.insert(strRich,{text= pChatData.sSn.."：",color = _cc.white})
					end
				end

				if type(pChatData.sCnt) == "table" then
					for k,v in pairs(pChatData.sCnt) do
						table.insert(strRich,copyTab(v))
					end
				else
					table.insert(strRich,{text= pChatData.sCnt.."",color = _cc.white})
				end


				if strRich then
					local strAll = ""
					local nFind = 0 --截断是的k值
					for k,v in pairs(strRich) do
						if v.text then
							
							if nFind > 0 and k>nFind then--比当前切割位置要大的都不要显示
								v.text = ""
							else
								strAll =  strAll..v.text
								nTotalLen =  string.len(strAll)
								if nTotalLen > nMaxLen then

									--超过长度截取
									local nCutoutNum = 0
									nCutoutNum = string.len(v.text)-(nTotalLen-nMaxLen)
									local sSubStr, _str2 = SubUTF8String(v.text, nCutoutNum)--截取最后一段的长度
									v.text = sSubStr or ""

									--表情截取
									local strTag = "[0x" --标签开头标志
									local tStrSp = luaSplit(v.text,strTag)--切割
									if #tStrSp >1 then--有切割才需要分割
										local strFin = tStrSp[#tStrSp]--最后一个切割剩余
										local strJoint = ""--需要连接起来的字符串
										if not string.find(strFin,"]") then--寻找是否有表情结束标志
											for x,y in pairs(tStrSp) do
												if (x<(#tStrSp-1)) then--
													strJoint = strJoint..y..strTag
												else
													if #tStrSp ~= x then
														strJoint = strJoint..y
													end
												end
											end
											v.text = strJoint or ""
										end
									end
									v.text = v.text.."..." --切割了之后需要加"..."
									nFind = k
								end							
							end
						end
					end
				end

				self.nChatType = _nType
				self.tChatData = pChatData
				if strRich then
                    local tNewStr = clone(strRich) --为了不影响原数据
			        -- tStr = removeSysEmoInTable(tNewStr)
			        strRich = getTableParseEmo(tNewStr)
					self.pLbChatCn:setString(strRich,false)
					local pSize = self.pLbChatCn:getContentSize()
--					local nWidthMax = self.pLayChat:getWidth() - 20
--					if pSize.width >= nWidthMax then
--						self.pLbChatCn:setDimensions(nWidthMax,60)
--					else
--						self.pLbChatCn:setDimensions(nWidthMax,0)
--					end
				end
				-- if nTotalLen >= nMaxLen / 2 then
				-- 	self.pLbChatCn:setDimensions(430,60)
				-- else
				-- 	self.pLbChatCn:setDimensions(430,0)
				-- end
			end
		end
		
	end
end

-- 任务刷新, 如果是有关于底下菜单进入的UI,则触发列表位置改变
function HomeBottomLayer:checkNewTask()
	-- body
	local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	if tCurTask then
		local nCurTaskId = tCurTask.sTid
		if nCurTaskId == e_special_task_id.hero_enter or
			nCurTaskId == e_special_task_id.fuben_enter then
			self.pListViewMenu:scrollToPosition(1)
		end
	end
end


-- 析构方法
function HomeBottomLayer:onHomeBottomLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function HomeBottomLayer:regMsgs( )
	-- body
	--注册聊天消息
	regMsg(self, ghd_refresh_chat, handler(self, self.receiveChatData))
	regMsg(self, gud_refresh_chat, handler(self, self.receiveChatData))

	-- 任务刷新
	regMsg(self,gud_refresh_task_msg, handler(self, self.checkNewTask))
	
	--任务引导刷新底部列表消息
	-- regMsg(self,ghd_refresh_home_bottom_msg, handler(self, self.refreshListPos))
	--注册新好友红点刷新
	regMsg(self, ghd_item_home_menu_red_msg, handler(self, self.refreshNewFriendRed))	
	--私聊信息红点
	regMsg(self, gud_refresh_sl_chat_red, handler(self, self.refreshNewFriendRed))
	--解锁教程 低部按钮移到中间
	regMsg(self, ghd_homebottom_menu_center, handler(self, self.onMenuCenter))

end

--位置移动到任务按钮可见
function HomeBottomLayer:refreshListPos(sMsgName, pMsgObj)
	-- body
	if pMsgObj and pMsgObj.bIsShow then
		local pAction = cc.Sequence:create({
            cc.CallFunc:create(function()
                self.pListViewMenu:scrollToPosition(1)
            end),
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                self:showBtnTx()
            end)
    	})
		self:runAction(pAction)
	else
		if self.pArmLing then
			self.pArmLing:removeSelf()
			self.pArmLing = nil
		end
	end
end


--显示任务按钮呼吸灯特效
function HomeBottomLayer:showBtnTx()
	--获取任务按钮
	local pTaskBtn = self.pListViewMenu:getItemByIdx(3)
	if not pTaskBtn then
		return
	end
	-- body
	if not self.pArmLing then
		self.pArmLing = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["40"], 
			pTaskBtn, 
			10, 
			cc.p(pTaskBtn:getWidth() / 2, pTaskBtn:getHeight() / 2),
		    function ( _pArm )

		    end, Scene_arm_type.normal)
		self.pArmLing:play(-1)
	end

	if not self.pLayFinger then
        self.pLayFinger = MUI.MLayer.new()
        self.pMenuLayer:addView(self.pLayFinger, 1000)        
    end
    self.pLayFinger:setPosition(pTaskBtn:getPositionX() + pTaskBtn:getWidth()/2+5, pTaskBtn:getPositionY() + pTaskBtn:getHeight()/3)
	local DlgFlow = require("app.common.dialog.DlgFlow")
    local pDlg,bNew = getDlgByType(e_dlg_index.dlgbuildfinger)
    if(not pDlg) then
        pDlg = DlgFlow.new(e_dlg_index.dlgbuildfinger)
    end 
    local DotFinger = require("app.layer.world.DotFinger")
    local nFingerType = 1
    local pChildView = DotFinger.new(nFingerType)  
    pDlg:showChildView(pView, pChildView)
    pDlg:setToCenter()
    pChildView:setData(self.pLayFinger)
    UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
    pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
end

function HomeBottomLayer:refreshNewFriendRed(  )
	-- body
	if self.pLayRed then
		local nRedNum = Player:getAllPrivateChatRed( ) + Player:getFriendsData():getNewFriendCnt() + Player:getFriendsData():getVitRedCnt()
		showRedTips(self.pLayRed, 0, nRedNum)	
	end	
end

function HomeBottomLayer:onMenuCenter( sMsgName, pMsgObj )
	if not self.tIndexList or not self.pListViewMenu then
		return
	end
	for i=1,#self.tIndexList do
		if self.tIndexList[i] == pMsgObj then
			self.pListViewMenu:scrollToPosition(math.max(i - 2, 1), false)
			break
		end
	end
end

-- 注销消息
function HomeBottomLayer:unregMsgs(  )
	-- body
	--注销聊天消息
	unregMsg(self, ghd_refresh_chat)
	unregMsg(self, gud_refresh_chat)
	--销毁任务刷新消息
  	unregMsg(self, gud_refresh_task_msg)
	--销毁引导刷新消息
  	-- unregMsg(self, ghd_refresh_home_bottom_msg)
  	--撤销新好友红点
  	unregMsg(self, ghd_item_home_menu_red_msg)
	--私聊信息红点
	unregMsg(self, gud_refresh_sl_chat_red)
	--解锁教程 低部按钮移到中间
	unregMsg(self, ghd_homebottom_menu_center)
end


--暂停方法
function HomeBottomLayer:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)
end

--继续方法
function HomeBottomLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	self:refreshChatCn(e_lt_type.sj)
	regUpdateControl(self, handler(self, self.onUpdateEverySecond))
end

--设置当前显示基地还是世界
function HomeBottomLayer:setCurChoice( nCurChoice )
	self.nCurChoice = nCurChoice
	if self.nCurChoice == 1 then
		self.pMainChoice:setBackgroundImage("#v2_btn_shijierukou.png")
	elseif self.nCurChoice == 2 then
		self.pMainChoice:setBackgroundImage("#v2_btn_zhujidi.png")
	end
end

--世界基地切换点击事件
function HomeBottomLayer:onMainClicked( pView )
	local nCurChoice = self.nCurChoice
	if nCurChoice == 1 then
		nCurChoice = 2
	else
		nCurChoice = 1
	end
	sendMsg(ghd_home_show_base_or_world, nCurChoice)

	--新手引导
	if B_GUIDE_LOG then
		print("B_GUIDE_LOG HomeBottomLayer 世界基地切换点击回调")
	end
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pMainChoice)
end

--聊天点击事件
local nCheck = 0
function HomeBottomLayer:onChatClicked( pView )
	-- --测试
	--  if true then
	-- 	local tLevyResData = {
	-- 		{1025,	4,	901},
	-- 		{1026,	4,	901},
	-- 		{1027,	4,	901},
	-- 		{1028,	4,	901},
	-- 		{1029,	4,	901},
	-- 		{1030,	4,	901},
	-- 		{1031,	4,	901},
	-- 		{1032,	4,	901},
	-- 		{1033,	2,	901},
	-- 		{1034,	2,	901},
	-- 		{1035,	2,	901},
	-- 		{1036,	2,	901},
	-- 		{1037,	2,	901},
	-- 		{1038,	2,	901},
	-- 		{1039,	2,	901},
	-- 		{1040,	2,	901},
	-- 		{1041,	2,	901},
	-- 		{1042,	2,	901},
	-- 		{1043,	2,	901},
	-- 		{1044,	2,	901},
	-- 		{1045,	2,	901},
	-- 		{1046,	2,	901},
	-- 		{1047,	2,	901},
	-- 		{1048,	2,	901},
	-- 		{1049,	5,	901},
	-- 		{1050,	5,	901},
	-- 		{1051,	5,	901},
	-- 		{1052,	5,	901},
	-- 		{1053,	5,	901},
	-- 		{1054,	5,	901},
	-- 		{1055,	5,	901},
	-- 		{1056,	5,	901},
	-- 		{1057,	5,	901},
	-- 		{1058,	5,	901},
	-- 		{1059,	5,	901},
	-- 		{1060,	5,	901},
	-- 		{1061,	5,	901},
	-- 		{1062,	5,	901},
	-- 		{1063,	5,	901},
	-- 		{1064,	5,	901},
	-- 		{1001,	3,	901},
	-- 		{1002,	3,	901},
	-- 		{1003,	3,	901},
	-- 		{1004,	3,	901},
	-- 		{1005,	3,	901},
	-- 		{1006,	3,	901},
	-- 		{1007,	3,	901},
	-- 		{1008,	3,	901},
	-- 		{1009,	3,	901},
	-- 		{1010,	3,	901},
	-- 		{1011,	3,	901},
	-- 		{1012,	3,	901},
	-- 		{1013,	3,	901},
	-- 		{1014,	3,	901},
	-- 		{1015,	3,	901},
	-- 		{1016,	3,	901},
	-- 		{1017,	4,	901},
	-- 		{1018,	4,	901},
	-- 		{1019,	4,	901},
	-- 		{1020,	4,	901},
	-- 		{1021,	4,	901},
	-- 		{1022,	4,	901},
	-- 		{1023,	4,	901},
	-- 	}
	-- 	local nDelayAnimTime = 0
	-- 	self.tLevyDatas = {}
	-- 	self.nLevyDataIndex = 1
	-- 	for i=1,#tLevyResData do
	-- 		--发送消息刷新客栈征收状态
	-- 		local tObject = {}
	-- 		tObject.nCell = tLevyResData[i][1] --建筑格子下标
	-- 		tObject.nResFlyNum = 1
	-- 		tObject.nLevyResNum = 100
	-- 		tObject.nDelayAnimTime = nDelayAnimTime
	-- 		table.insert(self.tLevyDatas, tObject)
	-- 	end
	-- 	local nAddCount = 2
	-- 	self.nAddcheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
	-- 		for i=1,nAddCount do
	-- 			local tObject = self.tLevyDatas[self.nLevyDataIndex]
	-- 			if tObject then
	-- 				sendMsg(ghd_refresh_suburb_state_msg,tObject)
	-- 			end
	-- 			self.nLevyDataIndex = self.nLevyDataIndex + 1
	-- 		end
	--     	if self ~= nil and self.nAddcheduler ~= nil and self.nLevyDataIndex > #self.tLevyDatas then
	--             MUI.scheduler.unscheduleGlobal(self.nAddcheduler)
	--             self.nAddcheduler = nil
	--     	end
	--     end)
	--  	return
	-- end

	-- body
	-- TOAST("聊天")
	local tObject = {} 
	tObject.nType = e_dlg_index.dlgchat --dlg类型
	if self.nChatType == e_chat_channel.country_block then
		tObject.nChatType = e_chat_channel.country
	else
		tObject.nChatType = self.nChatType --聊天类型
	end
	if self.tChatData then
		local nPlayerId = self.tChatData:getPChatPlayerId()
		local sPlayerName = self.tChatData:getPChatPlayerName()
		if nPlayerId and sPlayerName then
			tObject.tPChatInfo = {
				nPlayerId = nPlayerId,
				sPlayerName = sPlayerName,
			}
		end
	end
	sendMsg(ghd_show_dlg_by_type,tObject)
end

-- 每秒的刷新（设置时间）
function HomeBottomLayer:onUpdateEverySecond(  )
	if(self.pLbTime) then
		self.pLbTime:setString(os.date("%H") 
			.. ":" .. os.date("%M"))
	end
	-- 每秒检测一次网络状态
	self:checkNetworkState()
end

-- 检测当前的网络状态
function HomeBottomLayer:checkNetworkState(  )
	-- 如果是非正常状态，直接返回
    if(getCurConStatus() ~= e_network_status.nor) then
        return
    end
	self.nCcnwt = self.nCcnwt or 0 -- 当前第几次检测
	self.nCcnwt = self.nCcnwt + 1
	if Player:getUIFightLayer() then
		self.nCcnwt = 1
	end
	if(self.nCcnwt >= 3) then -- 每3秒检测一次
		self.nCcnwt = 0
		-- 检测是否网络连接正常
		local bNet, bSoc = getIsNetworking()
		if(bNet == false or bSoc == false) then
			showReconnectDlg(e_disnet_type.cli, true)
		end
	end
end


return HomeBottomLayer