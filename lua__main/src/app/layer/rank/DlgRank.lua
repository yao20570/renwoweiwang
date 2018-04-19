-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-17 14:14:23 星期三
-- Description: 排行榜界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
--local RankItem = require("app.layer.rank.RankItem")
local ItemActCard = require("app.layer.activitya.ItemActCard")
local ActivityRankList = require("app.layer.activitya.ActivityRankList")
local DlgRank = class("DlgRank", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgrank)
end)

function DlgRank:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_rank", handler(self, self.onParseViewCallback))
	
end

function DlgRank:myInit(  )
	-- body	
	self.nCurIndex = -1 --选中的玩家序号
	self.tCurData = nil	--当前的列表数据
	self.tRankItems = {
			e_rank_type.world,
			e_rank_type.country,	
			e_rank_type.nobility,	
			e_rank_type.arena,	
		}		
	self.bIsAskingData = false

	self.nSelectTab = 1 --排行标签索引
	self.tActListName = {}	--活动列表名称	
	for k, v in pairs(self.tRankItems) do
		local rankData = getRankData(v)
		if rankData then
			self.tActListName[k] = rankData.name
		else
			self.tActListName[k] = ""
		end
	end	
	self.nType = self.tRankItems[self.nSelectTab]--排行类型

	self.nRankNum = 10--每页请求数据个数
end

--解析布局回调事件
function DlgRank:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	--设置标题
	self:setTitle(getConvertedStr(6,10233))
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgRank",handler(self, self.onDlgRankDestroy))
end

--控件刷新
function DlgRank:updateViews(  )
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			if(not self.pLayRoot) then
				self.pLayRoot 					= 		self:findViewByName("root")	
				self.pLyTabList     			= 		self:findViewByName("ly_tab_list")
				self.pLyTab 					=       self:findViewByName("ly_tab")
				self.pLayCont = self:findViewByName("lay_cont")
				self:createListView()

				self.pImgTop = self:findViewByName("img_top")
				self.pImgBot = self:findViewByName("img_bot")
				self.pImgBot:setFlippedY(true)

				--banner
				self.pLayBannerBg = self:findViewByName("lay_banner_bg")
				setMBannerImage(self.pLayBannerBg,TypeBannerUsed.phb)
			end
			self:checkShowCityFirstBlood()
			if(not self.pLayTopInfo) then
				self.pLayTopInfo = self:findViewByName("lay_top")
				--固定文字标签
				self.pLbTip1 = self:findViewByName("lb_tip_1")
				setTextCCColor(self.pLbTip1, _cc.blue)
				self.pLbTip1:setString(getConvertedStr(6, 10234))
				self.pLbTip2 = self:findViewByName("lb_tip_2")
				setTextCCColor(self.pLbTip2, _cc.pwhite)
				self.pLbTip2:setString(getConvertedStr(6, 10235))
				self.pLbTip3 = self:findViewByName("lb_tip_3")
				setTextCCColor(self.pLbTip3, _cc.pwhite)
				self.pLbTip3:setString(getConvertedStr(6, 10253))

				self.pLayBotInfo = self:findViewByName("lay_bot")
			end		
			--等级
			if(not self.pLbTip2) then
				self.pLbTip2 = self:findViewByName("lb_tip_2")
			end
			local sStr2 = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10235)},
				{color=_cc.blue, text=Player:getPlayerInfo().nLv},
			}
			self.pLbTip2:setString(sStr2, false)
			
			self:updateTips()

			--分享按钮层
			if(not self.pLayShareBtn) then
				self.pLayShareBtn = self:findViewByName("lay_btn_share")
				self.pBtnShare = getCommonButtonOfContainer(self.pLayShareBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10099), true)
				self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareBtnCallBack))
			end
			--富文本提示层
			if not self.pLbTip then
				self.pLbTip = self:findViewByName("lb_tip_4")
			end			
			local strs = {
				{color=_cc.pwhite,text=getConvertedStr(6, 10236)},
				{color=_cc.blue,text=getConvertedStr(6, 10237)},
				{color=_cc.pwhite,text=getConvertedStr(6, 10238)},
			}
			self.pLbTip:setString(strs, false)			
		elseif(_index == 2) then			
			if not self.pLayRankList then
				self.pLayRankList = ActivityRankList.new(false, self.pLayCont:getHeight(), 60)				
				self.pLayRankList:setItemHandler(handler(self, self.onRankItemClick))
				self.pLayRankList:setPosition(0, 0)
				self.pLayRankList:setScrollToFooterHandler(function ( ... )
					-- body
		    		local nnextPage = Player:getRankInfo().nCurrPage + 1
		    		self:sendGetRankDataRequest(nnextPage)						
				end)			
				self.pLayCont:addView(self.pLayRankList)		
			end	
		elseif(_index == 3) then

		elseif(_index >= 4 and _index <= 6) then
			--前三名

		end
		if _bEnd then
			self:sendGetRankDataRequest()
		end
	end)
end
--创建listView
function DlgRank:createListView()
	-- listview tab
	-- self.pTabListView = createNewListView(self.pLyTabList)
	local pSize = self.pLyTabList:getContentSize()
	self.pTabListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height ),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  5, 
	            bottom =  0},
	    }	
	self.pLyTabList:addView(self.pTabListView)
	self.pTabListView:setBounceable(true) --是否回弹
	self.pTabListView:setItemCount(table.nums(self.tActListName))
	self.pTabListView:setItemCallback(handler(self, self.onTabEveryCallback))
	self.pTabListView:reload()
end
--析构方法
function DlgRank:onDlgRankDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgRank:regMsgs(  )
	-- body
	--注册排行数据刷新新消息
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankInfo))		
	--注册玩家等级刷新
	regMsg(self, ghd_refresh_playerlv_msg, handler(self, self.updateViews))	
	--监听首杀红点
	regMsg(self, gud_city_first_blood_red, handler(self, self.updateCFBloodRedNum))
end
--注销消息
function DlgRank:unregMsgs( )
	-- body
	--注销排行数据刷新新消息
	unregMsg(self, gud_refresh_rankinfo)
	--注销玩家等级刷新
	unregMsg(self, ghd_refresh_playerlv_msg)	
	--注销监听首杀红点
	unregMsg(self, gud_city_first_blood_red)
end

--暂停方法
function DlgRank:onPause( )
	-- body		
	self:unregMsgs()	
	sendMsg(ghd_clear_rankinfo_msg)
	-- if not gIsNull(self.pLayRankList) and self.pLayRankList.onPause then
	-- 	self.pLayRankList:onPause()
	-- else
	-- 	self.pLayRankList = nil
	-- end	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgRank:onResume( _bReshow )
	-- body		
	self:regMsgs()	
	if _bReshow and self.pTabListView then
		-- if not gIsNull(self.pLayRankList) then
		-- 	self.pLayRankList:onResume(_bReshow)
		-- end	
		self.nSelectTab = 1 --排行标签索引
		self.pTabListView:notifyDataSetChange(false)				
	end
	self:updateViews()		
end

-- --列表项回调
-- function DlgRank:onListViewItemCallBack(_index, _pView)
-- 	-- body	
--     local pTempView = _pView
--     if pTempView == nil then
--         pTempView = RankItem.new(_index)                        
--         pTempView:setViewTouched(true)
--     end    
--     --pTempView:setCurDataByIdx(nIndex)
--     if self.tCurData then
-- 		pTempView:setCurData(self.tCurData[_index])
-- 	end
-- 	pTempView:setListItemHightlight(_index == self.nCurIndex)
-- 	pTempView:onMViewClicked(function ()
-- 		self.nCurIndex = _index
-- 		if pTempView.tCurData then
-- 			local pMsgObj = {}
-- 			pMsgObj.nplayerId = pTempView.tCurData.i
-- 			--发送获取其他玩家信息的消息
-- 			sendMsg(ghd_get_playerinfo_msg, pMsgObj)
-- 		end     
--     end)
--     return pTempView
-- end
--分享按钮点击事件回调
function DlgRank:onShareBtnCallBack( pView)
	-- body
	--print("分享按钮")
	local nRankType = self.tRankItems[self.nSelectTab]
	if nRankType == e_rank_type.world then
		openShare(pView, e_share_id.world_rank, {Player:getRankInfo().nMyRank})
	elseif nRankType == e_rank_type.country then
		openShare(pView, e_share_id.coutry_rank, {Player:getRankInfo().nMyRank})
	elseif nRankType == e_rank_type.nobility then
		local tCountryDatavo = Player:getCountryData():getCountryDataVo()
		local pBanneret = getBanneretByLv(tCountryDatavo.nNobility)	
		local sNobility = getConvertedStr(3, 10139)
		if pBanneret then
			sNobility = pBanneret.name
		end		
		openShare(pView, e_share_id.nobility, {sNobility, Player:getRankInfo().nMyRank})
	elseif nRankType == e_rank_type.arena then
		local pData = Player:getArenaData()
		if not pData then
			return
		end	
		openShare(pView, e_share_id.arena_rank, {pData.nMyRank})		
	end
end

--刷新排行方式
function DlgRank:updateRankInfo( _nrankType )	
	--还没有初始化
	if not self.pLayCont then
		return
	end
	self.pRankData = {}
	self.pRankData.tListData = copyTab(Player:getRankInfo():getRankDataList())
	self.pRankData.tMyData = copyTab(Player:getRankInfo():getMyRankInfo())
	self.pRankData.nRankType = Player:getRankInfo().nRankType
	-- if not self.pLayRankList then
	-- 	--排行数据显示
	-- 	self.pLayRankList = ActivityRankList.new(false, self.pLayCont:getHeight(), 60)
	-- 	self.nRankNum = self.pLayRankList:getReqRankNum()
	-- 	self.pLayRankList:setItemHandler(handler(self, self.onRankItemClick))
	-- 	self.pLayRankList:setPosition(0, 0)
	-- 	self.pLayRankList:setScrollToFooterHandler(function ( ... )
	-- 		-- body
 --    		local nnextPage = Player:getRankInfo().nCurrPage + 1
 --    		self:sendGetRankDataRequest(nnextPage)						
	-- 	end)
	-- 	self.pLayCont:addView(self.pLayRankList)
	-- end	
	self.pLayRankList:setCurData(self.pRankData)

	--排名
	if(not self.pLbTip1) then
		self.pLbTip1 = self:findViewByName("lb_tip_1")
	end
	local sStr1 = {
		{color=_cc.blue, text=getConvertedStr(6, 10234)},
		{color=_cc.yellow, text=""},
	}
	--我的当前排名	
	if Player:getRankInfo().nMyRank == 0 then
		sStr1[2].text = getConvertedStr(6, 10426)
	else
		sStr1[2].text = Player:getRankInfo().nMyRank
	end			
	self.pLbTip1:setString(sStr1, false)
	local nRankType = self.tRankItems[self.nSelectTab]
	--前三名玩家信息
	local tlistdata = Player:getRankInfo():getRankDataList()
	local pLayTopInfo = self:findViewByName("lay_top")
	for i = 1, 3 do
		if(self.ttopThree == nil) then
			self.ttopThree = {}
		end	
		if(not self.ttopThree[i]) then
			local ptopPlayerlayer = ItemActCard.new(i)
			if i == 1 then
				ptopPlayerlayer:setPosition(26, 10)
			elseif i == 2 then
				ptopPlayerlayer:setPosition(186, 10)
			elseif i == 3 then
				ptopPlayerlayer:setPosition(346, 10)
			end
			pLayTopInfo:addView(ptopPlayerlayer, 10)	
			self.ttopThree[i] = ptopPlayerlayer
		end 	
		if nRankType == e_rank_type.nobility then
			self.ttopThree[i]:setShowInfoIndex(getConvertedStr(1, 10065), "jw")
		elseif nRankType == e_rank_type.arena then
			self.ttopThree[i]:setShowInfoIndex(getConvertedStr(6, 10240), "jjzl")
		else
			self.ttopThree[i]:setShowInfoIndex(getConvertedStr(6, 10240), "h")
		end		
		self.ttopThree[i]:setCurData(tlistdata[i])			
	end
end

function DlgRank:onTabEveryCallback(_index, _pView )
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
	end

	return pView
end

--点击引导item回调
function DlgRank:clickTabItem(_pData)
	if _pData then
		if self.nSelectTab ~= _pData then
			--切换排行类型前清理排行数据
			sendMsg(ghd_clear_rankinfo_msg)
			self.nSelectTab = _pData
	    	--重新获取服务器列表数据
	    	self.pTabListView:notifyDataSetChange(false)
			self:sendGetRankDataRequest()	
			self:updateTips()
		end
	end
end

--发送获取下一页排行数据请求
function DlgRank:sendGetRankDataRequest(_npag)
	-- body
	local nCurtype = self.tRankItems[self.nSelectTab]
	local npag = _npag or 1
	local iscanask = Player:getRankInfo():isCanAskForNextPag(nCurtype)
	if self.bIsAskingData == true or iscanask == false then--判断是否正在请求数据
		return
	end
	self.nRankNum = self.pLayRankList:getReqRankNum()
	self.bIsAskingData = true
	SocketManager:sendMsg("getRankData", {nCurtype, npag, self.nRankNum}, handler(self, self.getRankRequestCakkBack))
end
--网络请求回到
function DlgRank:getRankRequestCakkBack(__msg)
	-- body
	self.bIsAskingData = false--请求返回，结束正在请求的状态
	if __msg.head.state == SocketErrorType.success	then				
		--请求成功
		--self:updateRankInfo()
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end

function DlgRank:onRankItemClick( _tData )
	-- body
	--dump(_tData, "_tData", 100)
	if _tData["c"] == e_type_country.qunxiong then
		return
	end

	local pMsgObj = {}
	pMsgObj.nplayerId = _tData["i"]
	pMsgObj.bToChat = false
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)
end

--城池首杀入口
function DlgRank:checkShowCityFirstBlood( )
	-- --关闭入口
	-- if Player:getWorldData():getCFBloodClose() then
	-- 	if self.pCFBlood then
	-- 		self.pCFBlood:setVisible(false)
	-- 	end
	-- 	return
	-- end

	if getIsReachOpenCon(14, false) then
		if self.pLyTabList then
			if not self.pCFBlood then
				local pImg = MUI.MImage.new("#v2_btn_chengchishousha.png")
				local pItem = MUI.MLayer.new()
				self.pCFBlood = pItem
				local pSize = pImg:getContentSize()
				pItem:setLayoutSize(pSize.width, pSize.height)
				pItem:addView(pImg)
				centerInView(pItem, pImg)
				pItem:setViewTouched(true)
				pItem:setIsPressedNeedScale(false)
				pItem:onMViewClicked(function (  )
					local tObject = {}
					tObject.nType = e_dlg_index.cityfirstblood --dlg类型
					sendMsg(ghd_show_dlg_by_type,tObject)
				end)
				-- pItem:setPositionY(-30)
				self.pLyTab:addView(pItem, 2)
			end
			self:updateCFBloodRedNum()
		end
	else
		if self.pCFBlood then
			self.pCFBlood:setVisible(false)
		end
	end
end

--更新首杀红点
function DlgRank:updateCFBloodRedNum( )
	if self.pCFBlood then
		local bIsNew = Player:getWorldData():getFirstBloodRedInBlock(Player:getWorldData():getMyCityBlockId())
		if bIsNew then
			showRedTips(self.pCFBlood, 0, 1, 2)
		else
			showRedTips(self.pCFBlood, 0, 0, 2)
		end
	end
end

function DlgRank:updateTips( ... )
	-- body
	--战力
	if(not self.pLbTip3) then
		self.pLbTip3 = self:findViewByName("lb_tip_3")
	end
	local nCurtype = self.tRankItems[self.nSelectTab]	
	local sStr3 = nil
	if nCurtype == e_rank_type.nobility then--爵位
		local tCountryDatavo = Player:getCountryData():getCountryDataVo()
		local pBanneret = getBanneretByLv(tCountryDatavo.nNobility)
		if pBanneret then
			sStr3 = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10749)},
				{color=_cc.blue, text=pBanneret.name},
			}
		else
			sStr3 = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10749)},
				{color=_cc.white, text=getConvertedStr(3, 10139)},
			}
		end
	elseif nCurtype == e_rank_type.arena then--竞技场
		sStr3 = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10827)},
			{color=_cc.white, text=Player:getArenaData().nTsc},
		}		
	else
		sStr3 = {
			{color=_cc.pwhite, text=getConvertedStr(6, 10253)},
			{color=_cc.blue, text=Player:getPlayerInfo().nScore},
		}
	end
	if nCurtype == e_rank_type.arena then
		self.pLbTip3:setPositionX(27)	
		self.pLbTip2:setVisible(false)
	else
		self.pLbTip2:setVisible(true)
		self.pLbTip3:setPositionX(172)			
	end
	
	self.pLbTip3:setString(sStr3,false)
end

return DlgRank