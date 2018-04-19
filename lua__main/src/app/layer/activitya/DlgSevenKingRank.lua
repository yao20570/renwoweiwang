-----------------------------------------------------
-- author: maheng
-- Date: 2017-10-30 10:45:21
-- Description: 七日等级的排行类型子活动
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ActivityRankList = require("app.layer.activitya.ActivityRankList")
local ItemActivityRankPrize = require("app.layer.activitya.ItemActivityRankPrize")
local ItemActCard = require("app.layer.activitya.ItemActCard")
local DlgSevenKingRank = class("DlgSevenKingRank", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgsevenkingrank)
end)

function DlgSevenKingRank:ctor(_nType, _bShowRank)
	-- body
	self:myInit(_nType, _bShowRank)	
	self:setTitle(getConvertedStr(5, 10195))--游戏活动
	parseView("lay_seven_king_rank", handler(self, self.onParseViewCallback))

	--self:refreshData()
	self:setupViews()
	self:onResume()
	
	--注册析构方法
	self:setDestroyHandler("DlgSevenKingRank",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgSevenKingRank:myInit(_nType, _bShowRank)
	self.tActListName = {}	--活动列表名称
	self.tActList     = {}  --活动列表
	self.nSelectTab = 1 --当前所选择的活动
	self.nRankType = _nType    --默认进来选择的活动
	self.pLayRankInfo = nil
	self.pActivityData = nil
	self.bShowRank = true --当前显示排行榜
	self.bGuide = _bShowRank == 1
	self.bMoving = false--是否切换中

	self.pLayRankList = nil
	self.pRankAcrds = nil

	self.pRankData = {}

	self.bIsAskingData = false

	self.nRankNum = 10--每页请求数据个数
end

--刷新数据
function DlgSevenKingRank:refreshData()
	--获得活动列表
	self.pActivityData = Player:getActById(e_id_activity.sevenking)
	if not self.pActivityData then
		return
	end
	self.tActListName = {}
	self.tActList = self.pActivityData:getRankData()	--活动列表
	if self.tActList and table.nums(self.tActList)> 0 then
		for k,v in pairs(self.tActList) do
			local prankData = getRankData(v.nRankType)
			if prankData and prankData.name then
				table.insert(self.tActListName,prankData.name)
			end
		end
	end
end

--根据活动ID获取对应的索引值
function DlgSevenKingRank:getActIndexByID( nRankType )
	-- body
	if not nRankType then
		return 1
	end
	local nidx = 1	
	if self.tActList and #self.tActList > 0 then
		for k, v in pairs(self.tActList) do
			if v.nRankType  == nRankType then
				nidx = k
				break
			end
		end
	end
	return nidx
end

--解析布局回调事件
function DlgSevenKingRank:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层


end

--初始化控件
function DlgSevenKingRank:setupViews( )

end

--创建listView
function DlgSevenKingRank:createListView()
	-- listview tab
	-- self.pTabListView = createNewListView(self.pLyTabList)
	local pSize = self.pLyTabList:getContentSize()
	self.pTabListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height + 10 ),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }	
	self.pLyTabList:addView(self.pTabListView)
	self.pTabListView:setBounceable(true) --是否回弹
	self.pTabListView:setItemCount(table.nums(self.tActListName))
	self.pTabListView:setItemCallback(handler(self, self.onTabEveryCallback))
	self.pTabListView:reload()
end

-- 没帧回调 _index 下标 _pView 视图
function DlgSevenKingRank:onTabEveryCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tActListName[_index] then
			local ItemServerTab = require("app.layer.serverlist.ItemServerTab")
			pView = ItemServerTab.new()
			pView:setHandler(handler(self, self.clickTabItem))
		end
	end

	if _index and self.tActListName[_index] then
		pView:setCurData(self.tActListName[_index],_index,self.nSelectTab)	
		local pLayred = pView:getRedLayer()
		local Index = self.pActivityData:getActDataByRankType(self.tActList[_index].nRankType)
		local rednum = self.pActivityData:getRedNumsByIndex(Index)
		pLayred:setVisible(true)
		showRedTips(pLayred, 0, rednum)
	end

	return pView
end


--点击引导item回调
function DlgSevenKingRank:clickTabItem(_pData)
	if _pData then
		if self.nSelectTab ~= _pData then
			--切换排行类型前清理排行数据
			sendMsg(ghd_clear_rankinfo_msg)
			self.nSelectTab = _pData
	    	--重新获取服务器列表数据
	    	self.pTabListView:notifyDataSetChange(false)
			self:updateRankPrize()
			if self.bShowRank == false then
				self:switchView()
			end	    		    
		end
	end
end
--
function DlgSevenKingRank:updateRankPrize()
	self.tCurData = self:getSelectActData()--当前的子活动数据
	local nCnt = #self.tCurData.tConfs
	--dump(self.tCurData, "self.tCurData",100)
	--移动到某项
	local nTarPos = 1
	for k, v in pairs(self.tCurData.tConfs) do
		if v.nStatus == en_get_state_type.canget then  --可领取
			nTarPos = k
			break
		end
	end	
	if not self.pPrizeList then
		--排行奖励数据		
		self.pPrizeList = createNewListView(self.pLayPrizeList)
		self.pPrizeList:setItemCallback(function ( _index, _pView ) 
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemActivityRankPrize.new()                        
		        pTempView:setViewTouched(false)   
		        pTempView:setBalanceTime(self.pActivityData:getBalanceTimeStr())     
		    end   
		    local tConfs = self.tCurData.tConfs
		    if tConfs and tConfs[_index] then
		    	pTempView:setCurData(tConfs[_index])    	
		    end 
		    pTempView:setGetPrizeHandler(handler(self, self.reqGetPrize)) 
		    return pTempView	
		end)		
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pPrizeList:setUpAndDownArrow(pUpArrow, pDownArrow)		
		self.pPrizeList:setItemCount(nCnt)
		if nTarPos > 1 then
			self.pPrizeList:scrollToPosition(nTarPos)
		end				
		self.pPrizeList:reload(false)
	else
		if nTarPos > 1 then
			self.pPrizeList:scrollToPosition(nTarPos)
		end				
		self.pPrizeList:notifyDataSetChange(false, nCnt)
	end
	self:refreshRankData(self.tCurData.nRankType, 1, handler(self, self.updateRankInfo))
	--重新获取服务器列表数据
	self.pTabListView:notifyDataSetChange(false)
	local Index = self.pActivityData:getActDataByRankType(self.tActList[self.nSelectTab].nRankType)		
	showRedTips(self.pLayRed, 0, self.pActivityData:getRedNumsByIndex(Index))

end

function DlgSevenKingRank:updateRankInfo(  )
	-- body
	self.pRankData = {}
	self.pRankData.tListData = copyTab(Player:getRankInfo():getRankDataList())
	self.pRankData.tMyData = copyTab(Player:getRankInfo():getMyRankInfo())
	self.pRankData.nRankType = Player:getRankInfo().nRankType
	self.nRankType = Player:getRankInfo().nRankType
	self:updateRankLevel(self.tCurData.tConfs, self.pRankData.tListData, self.pRankData.tMyData)

	self.pLayRankList:setCurData(self.pRankData)	
	local sStr = self.pActivityData:getRankActTipsByRankType(self.nRankType)
	if sStr then
		self.pTxtDesc:setString(sStr, false)	
	else
		self.pTxtDesc:setString("", false)	
	end
	--dump(self.bGuide, "self.bGuide", 100)
	if self.bGuide ~= nil and  self.bGuide ~= self.bShowRank then
		if self.bShowRank then
			self.pLayRankList:stopAllActions()
			self.pLayRankList:setPosition(0, self.pLayCont:getHeight())
			self.pLayRankList:setVisible(false)
			--self.pLayRankList:setOpacity(0)
			self.pLayPrizeList:stopAllActions()
			self.pLayPrizeList:setPosition(0, 0)
			self.pLayPrizeList:setVisible(true)
			-- self.pLayPrizeList:setOpacity(255)
			self.bMoving = false

			self.bShowRank = false
		else
			self.pLayRankList:stopAllActions()
			self.pLayRankList:setPosition(0, 0)
			self.pLayRankList:setVisible(true)
			-- self.pLayRankList:setOpacity(255)
			self.pLayPrizeList:stopAllActions()
			self.pLayPrizeList:setPosition(0, 0 - self.pLayCont:getHeight())
			self.pLayRankList:setVisible(false)
			self.bMoving = false
			-- self.pLayPrizeList:setOpacity(0)
			self.bShowRank = true
		end
		if self.bShowRank then
			self.pLbTip:setString(getConvertedStr(6, 10447), false)
		else
			self.pLbTip:setString(getConvertedStr(6, 10448), false)				
		end	
		self.bGuide = nil
	end
	--排行前三名的显示刷新
	if not self.pRankAcrds then
		self.pRankAcrds = {}
	end
	for i = 1, 3 do
		if not self.pRankAcrds[i] then
			local pRankCard = ItemActCard.new(i)
			if i == 1 then
				pRankCard:setPosition(186, 40)
			elseif i == 2 then
				pRankCard:setPosition(36, 20)
			elseif i == 3 then
				pRankCard:setPosition(336, 20)
			end
			self.pLayTopInfo:addView(pRankCard, 10)	
			self.pRankAcrds[i] = 	pRankCard
		end
		if self.pRankData.tListData[i] then
			self.pRankAcrds[i]:setCurData(self.pRankData.tListData[i])
		else
			self.pRankAcrds[i]:setCurData(nil)
		end		
	end	
end

--根据排行配置更新排行等级
function DlgSevenKingRank:updateRankLevel( _tConfs, _tDatalist, _myInfo)
	-- body
	function _func( _tConfs, _nRank )
		-- body
		if not _nRank or _nRank == 0 then
			return 0
		end	
		if _tConfs then
			for k, v in pairs(_tConfs) do
				if _nRank >= v.nL and _nRank <= v.nR then
					return v.nId
				end			
			end
		end
		return 0
	end
	for k, v in pairs(_tDatalist) do
		v.ph = _func(_tConfs, v.x)
	end
	_myInfo.ph = _func(_tConfs, _myInfo.x)
end

function DlgSevenKingRank:refreshRankData( _nType, _npag, handler )
	-- body
 	local nCurRank = Player:getRankInfo().nRankType
	local iscanask = Player:getRankInfo():isCanAskForNextPag(_nType)
	local nPage = _npag or 1
	if self.bIsAskingData == true or iscanask == false then--判断是否正在请求数据
		if nPage == 1 and nCurRank == _nType and handler then--当前已有数据且不翻页的情况下直接刷新数据
			handler()
		end
		return
	end
	self.bIsAskingData = true
	SocketManager:sendMsg("getRankData", {_nType, nPage, self.nRankNum}, function ( __msg )
		-- body
		if handler then
			handler()
		end		
		self.bIsAskingData = false
	end)
	-- end
end
--获取当前选择活动数据
function DlgSevenKingRank:getSelectActData()
	local pData = {}
	if self.tActList[self.nSelectTab] then
		pData = self.tActList[self.nSelectTab] 
	end

	return pData
end

-- 修改控件内容或者是刷新控件数据
function DlgSevenKingRank:updateViews(  )


	gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
		if(_index == 1) then
			self:refreshData()
			--ly
			if not self.pLyTabList then

				self.pLyTabList     			= 		self.pView:findViewByName("ly_tab_list")
				--创建奖励列表
				self:createListView()		

				local nCount = table.nums(self.tActListName) or 0
				if self.pTabListView and self.tActListName then
					self.pTabListView:setItemCount(nCount)
					self.pTabListView:notifyDataSetChange(true)
				end
				self.nSelectTab = self:getActIndexByID(self.nRankType)					
			end						
		elseif _index == 2 then
			if not self.pLyContent then
				self.pLyContent 			    = 		self.pView:findViewByName("ly_content")
				self.pLayTopInfo = self.pView:findViewByName("lay_top")
				self.pTxtDesc = MUI.MLabel.new({
					    text = "",
					    size = 20,
					    anchorpoint = cc.p(0, 1),
					    align = cc.ui.TEXT_ALIGN_LEFT,
			    		valign = cc.ui.TEXT_VALIGN_TOP,
					    color = cc.c3b(255, 255, 255),
					    dimensions = cc.size(492, 0),
					})
				self.pTxtDesc:setPosition(15, self.pLayTopInfo:getHeight() - 20)
				self.pLayTopInfo:addView(self.pTxtDesc, 10)
				setTextCCColor(self.pTxtDesc, _cc.pwhite)
				self.pLayBotInfo = self.pView:findViewByName("lay_bot")	
				self.pLayJump = self.pView:findViewByName("lay_jump") 
				self.pLbTip = self.pView:findViewByName("lb_tip")
				self.pLbTip:setString(getConvertedStr(6, 10447), false)
				setTextCCColor(self.pLbTip, _cc.white)		
				self.pLayJump:setViewTouched(true)
				self.pLayJump:setIsPressedNeedScale(false)
				self.pLayJump:onMViewClicked(handler(self, self.switchView))
				self.pLayCont = self.pView:findViewByName("lay_cont")

				self.pLayRed = self:findViewByName("lay_red")
			
				--奖励列表层
				self.pLayPrizeList = self.pView:findViewByName("lay_prizelist")
				self.pLayPrizeList:setIgnoreOtherHeight(true)
                self.pLayPrizeList:setVisible(false)				
				--排行列表数据显示刷新
	
				--排行数据显示
				self.pLayRankList = ActivityRankList.new(true)					
                self.pLayRankList:setIgnoreOtherHeight(true)                
				self.pLayRankList:setItemHandler(handler(self, self.onRankItemClick))
				self.pLayRankList:setPosition(0, 0)
				self.pLayRankList:setScrollToFooterHandler(function ( ... )
					-- body
		    		local nnextPage = Player:getRankInfo().nCurrPage + 1
		    		self:refreshRankData(self.tCurData.nRankType, nnextPage, handler(self, self.updateRankInfo))
				end)
				self.pLayCont:addView(self.pLayRankList)					
		

				self.pLayBannerBg = self.pView:findViewByName("lay_banenr_bg")
				setMBannerImage(self.pLayBannerBg,TypeBannerUsed.phb2)	
			end
		end
		if _bEnd then			
			if self.tActList and self.tActList[self.nSelectTab] then
				self.nRankNum = self.pLayRankList:getReqRankNum()
				self:updateRankPrize()
				if table.nums(self.tActList)>11 and self.pTabListView then
					self.pTabListView:scrollToPosition(self.nSelectTab, false)
				end
			end	
		end
	end)


end
-- 析构方法
function DlgSevenKingRank:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgSevenKingRank:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateRankPrize))
	regMsg(self, gud_refresh_actlist, handler(self, self.refreshlist))

end

-- 注销消息
function DlgSevenKingRank:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
	unregMsg(self, gud_refresh_actlist)
end


--暂停方法
function DlgSevenKingRank:onPause( )
	-- body
	self:unregMsgs()
	sendMsg(ghd_clear_rankinfo_msg)
end

--继续方法
function DlgSevenKingRank:onResume( _bReshow )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--刷新排行界面
function DlgSevenKingRank:refreshlist()
	local pActData = Player:getActById(e_id_activity.sevenking)
	if not pActData then
		self:closeDlg(false)
	end
	--self:clickTabItem(1)	
end

function DlgSevenKingRank:setSelectParam( _nRankType, _bSHowRank )
	-- body
	self.nRankType = _nRankType or self.nRankType
	self.bGuide = _bSHowRank == 1
	--print("resume _nType=", _nRankType, "  _bShowRank=", _bSHowRank)
	self:updateViews()
end

function DlgSevenKingRank:reqGetPrize( _tData )
	-- body
	--dump(_tData, "_tData", 100)
	local sReq = nil
	local ngrade = _tData.nId
	if self.nRankType == e_rank_type.sr_tnoly then
		sReq = "reqSevenkingS"
	elseif self.nRankType == e_rank_type.sr_cf then
		sReq = "reqSevenkingC"
	elseif self.nRankType == e_rank_type.sr_equip then
		sReq = "reqSevenkingE"
	elseif self.nRankType == e_rank_type.sr_fuben then
		sReq = "reqSevenkingD"
	elseif self.nRankType == e_rank_type.sr_palace then
		sReq = "reqSevenkingP"
	elseif self.nRankType == e_rank_type.sr_combat then
		sReq = "reqSevenkingZ"
	end	
	if sReq then
		--dump(sReq, "sReq", 100)
		SocketManager:sendMsg(sReq, {ngrade}, function ( __msg, __oldMsg )
			-- body
			if __msg.head.state == SocketErrorType.success then
				if __msg.body and __msg.body.o then
					showGetAllItems(__msg.body.o)
				end
			else
			    TOAST(SocketManager:getErrorStr(__msg.head.state))
	        end
		end)
	end
end

--切换显示
function DlgSevenKingRank:switchView(  )
	-- body	
	if self.bMoving == true then
		return
	end	
	if self.bShowRank then
		self.pLbTip:setString(getConvertedStr(6, 10448), false)
	else
		self.pLbTip:setString(getConvertedStr(6, 10447), false)		
	end	
	local ndelay = 0.5
	self.bMoving = true	
	if self.bShowRank then		
		local moveVec = cc.p(0, self.pLayCont:getHeight())	
		self.pLayRankList:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), 
			cc.FadeOut:create(ndelay)), 
			cc.CallFunc:create(function (  )
				-- body
				self.pLayRankList:setVisible(false)
				self.bMoving = false
				self.bShowRank = false
			end)))		

        self.pLayPrizeList:setPositionY( -self.pLayCont:getHeight())
		self.pLayPrizeList:runAction(cc.Sequence:create(cc.CallFunc:create(function(  )
				-- body
				self.pLayPrizeList:setVisible(true)
			end), 
			cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), cc.FadeIn:create(ndelay))))
	else
		local moveVec = cc.p(0, 0 - self.pLayCont:getHeight())	
		self.pLayRankList:runAction(cc.Sequence:create(cc.CallFunc:create(function (  )
				-- body
				self.pLayRankList:setVisible(true)
			end), 
			cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), cc.FadeIn:create(ndelay))))

		self.pLayPrizeList:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), 
			cc.FadeOut:create(ndelay)), 
			cc.CallFunc:create(function (  )
				-- body
				self.pLayPrizeList:setVisible(false)
				self.bMoving = false
				self.bShowRank = true
			end)))
	end	
end

function DlgSevenKingRank:onRankItemClick( _tData )
	-- body
	--dump(_tData, "_tData", 100)

	local pMsgObj = {}
	pMsgObj.nplayerId = _tData["i"]
	pMsgObj.bToChat = false
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)
end

return DlgSevenKingRank