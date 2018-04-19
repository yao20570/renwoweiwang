-- Author: maheng
-- Date: 2017-06-29 11:30:40
-- 活动排行模板pa版 (517*1066)

local MCommonView = require("app.common.MCommonView")
local ItemActCard = require("app.layer.activitya.ItemActCard")
--local ItemActivityRank = require("app.layer.activitya.ItemActivityRank")
local ItemActivityRankPrize = require("app.layer.activitya.ItemActivityRankPrize")
local ActivityRankList = require("app.layer.activitya.ActivityRankList")
local ItemActRankContent = class("ItemActRankContent", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

--创建函数 _nId
function ItemActRankContent:ctor(_nId)
	-- body
	self:myInit(_nId)

	parseView("dlg_activity_rank", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemActRankContent",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActRankContent:myInit(_nId)
	self.pData = {} --数据
	self.nActType = _nId 
	self.pItemTime = nil --时间Item
	-- self.pItemTimeM = nil --时间Item
	self.tListTitles = nil --排行榜标签
	self.tListData = nil --列表数据

	self.bIsAskingData = false--是否正在请求数据

	self.tMyRankLbs = nil

	self.nGetPrizeHandler = nil	

	self.bIsMoveing = false
	self.bShowRank = true --当前显示排行榜
end

--解析布局回调事件
function ItemActRankContent:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:setupViews()
end

--初始化控件
function ItemActRankContent:setupViews( )
	--body
	self.pLayRoot = self:findViewByName("root")
	self.pLayTopInfo = self:findViewByName("lay_top")
	self.pLayBotInfo = self:findViewByName("lay_bot")	
	self.pLayJump = self:findViewByName("lay_jump") 
	self.pLbTip = self:findViewByName("lb_tip")
	self.pLbTip:setString(getConvertedStr(6, 10447), false)
	setTextCCColor(self.pLbTip, _cc.white)		
	self.pLayJump:setViewTouched(true)
	self.pLayJump:setIsPressedNeedScale(false)
	self.pLayJump:onMViewClicked(handler(self, self.switchView))
	self.pLayCont = self:findViewByName("lay_cont")	

	--banner
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.phb2)				

	local pLayRed = MUI.MLayer.new()
	local x = self.pLayJump:getWidth() - 20
	local y = self.pLayJump:getHeight() - 20
	pLayRed:setPosition(x, y)
	pLayRed:setLayoutSize(20, 20)
	self.pLayJump:addView(pLayRed, 10)
	self.pLayRed = pLayRed

	--奖励列表层
	self.pLayPrizeList = self:findViewByName("lay_prizelist")	
    self.pLayPrizeList:setIgnoreOtherHeight(true)
	--排行列表数据显示刷新
	if not self.pLayRankList then	
		--排行数据显示
		self.pLayRankList = ActivityRankList.new(true)			
        self.pLayRankList:setIgnoreOtherHeight(true)
		self.pLayRankList:setItemHandler(handler(self, self.onRankItemClick))
		self.pLayRankList:setPosition(0, 0)
		self.pLayRankList:setScrollToFooterHandler(function ( ... )
			-- body
    		local nnextPage = Player:getRankInfo().nCurrPage + 1
    		self:sendGetRankDataRequest(nnextPage)						
		end)
		self.pLayCont:addView(self.pLayRankList)					
	end	

	--排行前三的信息卡
	self.pRankCard1 = ItemActCard.new(1)
	--self.pRankCard1:setPlayerCardTouched(false)
	self.pRankCard1:setPosition(186, 70)
	self.pLayTopInfo:addView(self.pRankCard1, 10)

	self.pRankCard2 = ItemActCard.new(2)
	--self.pRankCard2:setPlayerCardTouched(false)
	self.pRankCard2:setPosition(26, 30)
	self.pLayTopInfo:addView(self.pRankCard2, 10)
	
	self.pRankCard3 = ItemActCard.new(3)
	--self.pRankCard3:setPlayerCardTouched(false)
	self.pRankCard3:setPosition(346, 30)
	self.pLayTopInfo:addView(self.pRankCard3, 10)
end

-- 修改控件内容或者是刷新控件数据
function ItemActRankContent:updateViews()
	self:refreshView()
end

--刷新内容
function ItemActRankContent:refreshView()
	if not self.pData then
		return
	end	
	--dump(self.pData.nHz, "self.pData.nHz=", 100)
	--排行页面活动时间显示
	if not self.pLayTime then
		self.pLayTime = self:findViewByName("lay_time")
	end
	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLayTime,self.pData,cc.p(0,0))
	end
	self.pItemTime:setCurData(self.pData)
	--奖励界面活动时间显示
	-- if not self.pLayTimeM then
		-- self.pLayTimeM = self:findViewByName("lay_time_m")
	-- end
	-- if not self.pItemTimeM then
	-- 	self.pItemTimeM = createActTime(self.pLayTimeM,self.pData,cc.p(0,0))
	-- end
	-- self.pItemTimeM:setCurData(self.pData)
	--活动描述
	if not self.pLbDesc then
		self.pLbDesc = self:findViewByName("lb_des")
	end
	self.pLbDesc:setString(self.pData.sDesc)

	--设置banner图
	-- if self.pData.tBanners and table.nums(self.pData.tBanners) > 0 then
	-- 	local nIndex = 1
	-- 	for k, v in pairs (self.pData.tBanners) do
	-- 		if nIndex == 1 then
	-- 			self:setBannerImg(v)
	-- 		elseif nIndex == 2 then
	-- 			self:setBannerMImg(v)
	-- 		end
	-- 		nIndex = nIndex + 1
	-- 	end
	-- end
end

--析构方法
function ItemActRankContent:onDestroy(  )
	-- body
	--发送清理排行榜消息
	sendMsg(ghd_clear_rankinfo_msg)
end

--设置数据 _data
function ItemActRankContent:setCurData(_tData)
	if not _tData then
		return
	end
	self.pData = _tData or {}
	self:refreshView()
end

--设置列表页banner图片 
-- function ItemActRankContent:setBannerImg(_str)
-- 	if not self.pImgBann then
-- 		self.pImgBann = self:findViewByName("img_banner_b")
-- 	end
-- 	if self.pImgBann and _str then
-- 		self.pImgBann:setCurrentImage(_str)
-- 	end
-- end
--设置领奖页面banner图片 
-- function ItemActRankContent:setBannerMImg(_str)
-- 	if not self.pImgbannM then
-- 		self.pImgbannM = self:findViewByName("img_banner_s")
-- 	end
-- 	if self.pImgbannM and _str then
-- 		self.pImgbannM:setCurrentImage(_str)
-- 	end
-- end

--设置时间
function ItemActRankContent:setActTime()
	if self.pData then
		if self.pItemTime then
			self.pItemTime:setCurData(self.pData)
		end
		-- if self.pItemTimeM then
		-- 	self.pItemTimeM:setCurData(self.pData)
		-- end
	end
end

--设置奖励获取按钮回调
function ItemActRankContent:setGetPrizeHandler( _handler )
	-- body
	self.nHandlerGetPrize = _handler
end
--初始化排行标题
function ItemActRankContent:initListTitles(  )
	-- body
	self.tListTitles = {}
	local nw = self.pLayListTitle:getWidth()/5
	for i = 1, 5 do 
		local pLabel = MUI.MLabel.new({
	        text = "",
	        size = 20,
	        anchorpoint=cc.p(0.5, 0.5)
        })
		pLabel:setViewTouched(false)
		self.pLayListTitle:addView(pLabel, 100)
		pLabel:setPosition(nw*(i-1) + nw/2, self.pLayListTitle:getHeight()/2)
		self.tListTitles[i] = pLabel
	end
	--根据配表初始化标题
	local nwidth = self.pLayListTitle:getWidth()
	local nheight = self.pLayListTitle:getHeight()	
	local ncurType = getRankTypeByActType(self.nActType)--当前排行类型	
	if ncurType then
		local t1, t2 = getRankSetTypePos(ncurType)
		for i = 1, 5 do
			if t2[i] and t1[i] then				
				self.tListTitles[i]:setVisible(true)
				self.tListTitles[i]:setString(t2[i])
				self.tListTitles[i]:setPositionX(t1[i]*nwidth)
			else
				self.tListTitles[i]:setVisible(false)
			end	    
		end	
	end
end

--设置排行前三的显示数据索引
function ItemActRankContent:setRankCardDataIndex( sTip, sIdx )
	-- body	
	self.pRankCard1:setShowInfoIndex(sTip, sIdx)
	self.pRankCard2:setShowInfoIndex(sTip, sIdx)
	self.pRankCard3:setShowInfoIndex(sTip, sIdx)
end

--礼品列表
function ItemActRankContent:onPrizeViewItemCallBack( _index, _pView )
	-- body
 	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemActivityRankPrize.new()                        
        pTempView:setViewTouched(false)   
        pTempView:setBalanceTime(self.pData:getBalanceTimeStr())     
    end   
    local tConfs = Player:getActById(self.nActType):getPrizeConfs()
    if tConfs and tConfs[_index] then
    	pTempView:setCurData(tConfs[_index])    	
    end 
    pTempView:setGetPrizeHandler(self.nHandlerGetPrize)    
    return pTempView	
end

function ItemActRankContent:sendGetRankDataRequest( npage )
	-- body
	local nCurtype = getRankTypeByActType(self.nActType)
	if not nCurtype then
		return 
	end	
	local npag = npage or 1
	local iscanask = Player:getRankInfo():isCanAskForNextPag(nCurtype)
	if self.bIsAskingData == true or iscanask == false then--判断是否正在请求数据
		return
	end
	self.bIsAskingData = true
	SocketManager:sendMsg("getRankData", {nCurtype, npag, 15}, handler(self, self.getRankRequestCakkBack))
end

--网络请求回到
function ItemActRankContent:getRankRequestCakkBack(__msg)
	-- body
	--dump(__msg.body, "__msg.body",10)
	self.bIsAskingData = false--请求返回，结束正在请求的状态
	if __msg.head.state == SocketErrorType.success	then				
		--请求成功
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end
--重新请求排行数据
function ItemActRankContent:reReqRankInfo( )
	-- body
	self:sendGetRankDataRequest()
end

--根据排行配置更新排行等级
function ItemActRankContent:updateRankLevel( _tConfs, _tDatalist, _myInfo)
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

--排行列表刷新数据整理刷新
function ItemActRankContent:refreshRankList(  )
	-- body
	--排行榜数据
	self.pRankData = {}
	self.pRankData.tListData = copyTab(Player:getRankInfo():getRankDataList())
	self.pRankData.tMyData = copyTab(Player:getRankInfo():getMyRankInfo())
	self.pRankData.nRankType = Player:getRankInfo().nRankType
	local tConfs = Player:getActById(self.nActType):getPrizeConfs()
	self:updateRankLevel(tConfs, self.pRankData.tListData, self.pRankData.tMyData)
	self.pLayRankList:setCurData(self.pRankData)	

	--排行前三名信息卡更新
	self.pRankCard1:setCurData(self.pRankData.tListData[1])
	self.pRankCard2:setCurData(self.pRankData.tListData[2])
	self.pRankCard3:setCurData(self.pRankData.tListData[3])

end

--刷新我的排行数据
function ItemActRankContent:refreshMyRankInfo(  )
	-- body
end

--刷新奖励状态
function ItemActRankContent:refreshRankPrize()
	-- body	
	local tConfs = Player:getActById(self.nActType):getPrizeConfs()
	if not tConfs or #tConfs <= 0 then--数据异常
		return
	end 
	--移动到某项
	local nTarPos = 1
	for k, v in pairs(tConfs) do
		if v.nStatus == en_get_state_type.canget then  --可领取
			nTarPos = k
			break
		end
	end
	local nCurCnt = #tConfs
	if not self.pPrizeView then	
		local pSize = self.pLayPrizeList:getContentSize()
		self.pPrizeView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 20),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }
	    self.pLayPrizeList:addView(self.pPrizeView)
	    self.pLayPrizeList:setPositionY(-self.pLayPrizeList:getHeight())

		-- self.pPrizeView = createNewListView(self.pLayPrizeList)
	    self.pPrizeView:setItemCallback(handler(self, self.onPrizeViewItemCallBack))    	    	
		self.pPrizeView:setItemCount(nCurCnt)
		if nTarPos > 1 then
			self.pPrizeView:scrollToPosition(nTarPos)
		end
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pPrizeView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pPrizeView:reload(true)	
	else
		if nTarPos > 1 then
			self.pPrizeView:scrollToPosition(nTarPos)
		end
		self.pPrizeView:notifyDataSetChange(true, nCurCnt)	
	end
	showRedTips(self.pLayRed, 0, self.pData:getRedNums(true))
end

--切换显示
function ItemActRankContent:switchView(  )
	-- body	
	if self.bIsMoveing == true then
		return
	end	
	if self.bShowRank then
		self.pLbTip:setString(getConvertedStr(6, 10448), false)
	else
		self.pLbTip:setString(getConvertedStr(6, 10447), false)		
	end	
	local ndelay = 0.5
	self.bIsMoveing = true	
	if self.bShowRank then		
		local moveVec = cc.p(0, self.pLayCont:getHeight())	
		self.pLayRankList:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), 
			cc.FadeOut:create(ndelay)), 
			cc.CallFunc:create(function (  )
				-- body
				self.pLayRankList:setVisible(false)
				self.bIsMoveing = false
				self.bShowRank = false
			end)))		

        self.pLayPrizeList:setPositionY( -self.pLayCont:getHeight())
		self.pLayPrizeList:runAction(cc.Sequence:create(cc.CallFunc:create(function(  )
				-- body
				self.pLayPrizeList:setVisible(true)
			end), 
			cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), 
			cc.FadeIn:create(ndelay))))
	else
		local moveVec = cc.p(0, 0 - self.pLayCont:getHeight())	
		self.pLayRankList:runAction(cc.Sequence:create(cc.CallFunc:create(function (  )
				-- body
				self.pLayRankList:setVisible(true)
			end), 
			cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), 
			cc.FadeIn:create(ndelay))))
		self.pLayPrizeList:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), 
			cc.FadeOut:create(ndelay)), 
			cc.CallFunc:create(function (  )
				-- body
				self.pLayPrizeList:setVisible(false)
				self.bIsMoveing = false
				self.bShowRank = true
			end)))
	end	
end

function ItemActRankContent:onRankItemClick( _tData )
	-- body
	--dump(_tData, "_tData", 100)

	local pMsgObj = {}
	pMsgObj.nplayerId = _tData["i"]
	pMsgObj.bToChat = false
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)
end
return ItemActRankContent