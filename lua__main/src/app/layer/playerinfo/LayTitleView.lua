-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-02-06 14:36:23 星期二
-- Description: 头像框分页 
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemTitleShow = require("app.layer.playerinfo.ItemTitleShow")
local LayTitleView = class("LayTitleView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayTitleView:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_title_view", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayTitleView:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayTitleView",handler(self, self.onDestroy))
end

-- --初始化参数
function LayTitleView:myInit()
	-- body
	self.nCurTitleSelectId = nil
	self.pTitleList = nil
end

function LayTitleView:refreshData(  )
	-- body
	local tActorVo = Player:getPlayerInfo():getActorVo()	
	local tTitles = Player:getPlayerInfo():getMyTitleDatas()	
	self.pTitleListData = {}
	for k, v in pairs(tTitles) do
		table.insert(self.pTitleListData, v) 
	end
	table.sort(self.pTitleListData, function (a, b)
		-- body
		local aSort = a:getSortNum()
		local bSort = b:getSortNum()
		if aSort ~= bSort then
			return aSort > bSort
		else
			return a.nPriority < b.nPriority
		end
		
	end)	
	self.nCurTitleSelectId = tActorVo.sT
end

--初始化控件
function LayTitleView:setupViews( )
	-- body	
	self.pLayMain = self:findViewByName("lay_title_view") 
	self.pLayMain:setContentSize(self:getContentSize())		
	self.pLayTitleList = self:findViewByName("lay_title")
end

-- 修改控件内容或者是刷新控件数据
function LayTitleView:updateViews(  )
	-- body
	self:refreshData()
	self:refreshPrevView()
	local nCnt = table.nums(self.pTitleListData)
	if not self.pTitleList then
		local nSelectIdx = nil
		for k, v in pairs(self.pTitleListData) do
			if self.nCurTitleSelectId == v.sTid then
				nSelectIdx = k
				break
			end				
		end				
	    self.pTitleList = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, 600, self.pLayTitleList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 10 ,
            bottom = 5 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pTitleList:setBounceable(true) --是否回弹
        self.pTitleList:setPosition((self.pLayTitleList:getWidth() - self.pTitleList:getWidth())/2, 0)
        self.pLayTitleList:addView(self.pTitleList, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pTitleList:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pTitleList:setItemCount(nCnt)
		self.pTitleList:setItemCallback(handler(self, self.onEveryCallback))
		if nSelectIdx then
			self.pTitleList:scrollToPosition(nSelectIdx, true) 	
		end					
		self.pTitleList:reload(false)		
	else		
		self.pTitleList:notifyDataSetChange(false, nCnt)		
	end	
end

function LayTitleView:onEveryCallback ( _index, _pView ) 
    local pView = _pView
    local pData = self.pTitleListData[_index]
	if not pView then
		pView = ItemTitleShow.new(pData, self.nCurTitleSelectId)
		pView:setViewTouched(true)
		pView:setIsPressedNeedScale(false)
	else
		pView:setCurData(pData, self.nCurTitleSelectId)													
	end
	pView:setBtnClickHandler(handler(self, self.onItemBtnClickBack))
	return pView
end
function LayTitleView:refreshPrevView(  )
	-- body
	--当前佩戴
	unregUpdateControl(self)--停止计时刷新
	local bIsNeedMF  = false --是否需要秒刷新
	local pActorVo1 = Player:getPlayerInfo():getActorVo()
	if not self.pIcon1 then
		local pLayIcon1 = self:findViewByName("lay_icon_1")
		self.pIcon1 = getIconGoodsByType(pLayIcon1, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo1)
		self.pIcon1:setIconIsCanTouched(false)
	else
		self.pIcon1:setCurData(pActorVo1)
	end	
	self.pIcon1:setIconTitleImg(pActorVo1.sTitle)
	local pCurTitleBase = Player:getPlayerInfo():getTitleDataById(pActorVo1.sT)		
	--是否使用称号
	if not self.pLbPar2 then
		self.pLbPar2 = self:findViewByName("lb_pa_2")
		self.pLbPar2:setString(getConvertedStr(6, 10752))
		setTextCCColor(self.pLbPar2, _cc.red)
	end
	--倒计时
	if not self.pLbPar3 then
		self.pLbPar3 = self:findViewByName("lb_pa_3")
	end	
	if pCurTitleBase then		
		self.pLbPar2:setVisible(false)
		self.pLbPar3:setVisible(true)				
		if pCurTitleBase:getCdTime() > 0 then
			bIsNeedMF = true	
			local sStr = {
				{color=_cc.pwhite, text= getConvertedStr(6, 10753)},
				{color=_cc.red, text= formatTimeToMs(pCurTitleBase:getCdTime())},
			}
			self.pLbPar3:setString(sStr, false)			
		elseif pCurTitleBase.nCd == -1 then --永久有效
			local sStr = {
				{color=_cc.pwhite, text= getConvertedStr(6, 10753)},
				{color=_cc.white, text= getConvertedStr(6, 10650)},
			}
			self.pLbPar3:setString(sStr, false)					
		end
	else
		self.pLbPar2:setVisible(true)
		self.pLbPar3:setVisible(false)
	end

	if bIsNeedMF then
		regUpdateControl(self, handler(self, self.onUpdateTime))
	end	
end

function LayTitleView:onUpdateTime(  )
	-- body
	--当前佩戴
	local pActorVo1 = Player:getPlayerInfo():getActorVo()
	local pCurTitle = Player:getPlayerInfo():getTitleDataById(pActorVo1.sT)	
	if pCurTitle then
		if pCurTitle:getCdTime() >= 0 then
			local sStr = {
				{color=_cc.pwhite, text= getConvertedStr(6, 10753)},
				{color=_cc.red, text= formatTimeToMs(pCurTitle:getCdTime())},
			}
			self.pLbPar3:setString(sStr, false)	
		elseif pCurTitle.nCd == -1 then --永久有效
			local sStr = {
				{color=_cc.pwhite, text= getConvertedStr(6, 10753)},
				{color=_cc.white, text= getConvertedStr(6, 10650)},
			}
			self.pLbPar3:setString(sStr, false)	
		end
		return	
	end
	self.pLbPar3:setVisible(false)
	unregUpdateControl(self)--停止计时刷新

end

function LayTitleView:onItemBtnClickBack( _tData )
	-- body
	if not _tData then
		return
	end
	SocketManager:sendMsg("reqChangeCharacters", {_tData.sTid, 3}, handler(self, self.onGetFunc)) 
end

function LayTitleView:onGetFunc( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		TOAST(getConvertedStr(6, 10596))
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end	
end
--析构方法
function LayTitleView:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayTitleView:regMsgs( )
	-- body
    --注册玩家信息刷新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))

end

-- 注销消息
function LayTitleView:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_playerinfo)
end
--暂停方法
function LayTitleView:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayTitleView:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayTitleView
