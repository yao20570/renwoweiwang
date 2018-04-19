-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-02-06 14:36:23 星期二
-- Description: 头像分页 
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemIcons = require("app.layer.playerinfo.ItemIcons")
local ScrollViewEx = require("app.common.listview.ScrollViewEx")
local LayIconView = class("LayIconView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayIconView:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_icon_view", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayIconView:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayIconView",handler(self, self.onDestroy))
end

-- --初始化参数
function LayIconView:myInit()
	-- body
	self.nCurIconSelectId = nil
	self.tItemIconGroup = {}
end

function LayIconView:refreshData(  )
	-- body
	local tActorVo = Player:getPlayerInfo():getActorVo()	
	local tIcons = Player:getPlayerInfo():getMyIconDatas()
	self.pIconListData = {}
	table.sort(tIcons, function (a, b)
		-- body
		return a.nSequence < b.nSequence
	end)
	for k, v in pairs(tIcons) do
		local nSequence = v.nSequence
		if not self.pIconListData[nSequence] then
			self.pIconListData[nSequence] = {}
		end
		table.insert(self.pIconListData[nSequence], v)
	end	
	self.nCurIconSelectId = tActorVo.sI
end

--初始化控件
function LayIconView:setupViews( )
	-- body	
	--顶部信息层
	self.pLayMain = self:findViewByName("lay_icon_view") 
	self.pLayMain:setContentSize(self:getContentSize())
    self.pLayBtn = self:findViewByName("lay_btn")
    self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10594))
    self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
    self.pLayIconList = self:findViewByName("lay_icon_list")
end

-- 修改控件内容或者是刷新控件数据
function LayIconView:updateViews(  )
	-- body
	self:refreshData()
	self:updateIconsView()
end

function LayIconView:updateIconsView(  )
	-- body
	local bNew = false
	if not self.pIconScroll then
		self.pIconScroll = ScrollViewEx.new( self.pLayIconList:getWidth() - 40, self.pLayIconList:getHeight())
		self.pIconScroll:setAnchorPoint(0,0)	    
    	--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pIconScroll:setUpAndDownArrow(pUpArrow, pDownArrow)	    
	    self.pLayIconList:addView(self.pIconScroll)
	   	centerInView(self.pLayIconList, self.pIconScroll)
	    self.pIconScroll:setBounceable(true)		    	   
	    bNew = true   	    
	end		
    for k, v in pairs(self.pIconListData) do
    	if not self.tItemIconGroup[k] then	    		
		 	local pTempView = ItemIcons.new(self.pIconListData[k], self.nCurIconSelectId)			   		    
	        pTempView:setViewTouched(false) 
	        pTempView:setIconClickHandler(handler(self, self.onIconClickBack))  
            pTempView:setAnchorPoint(0.5, 0)
	        self.pIconScroll:addView(pTempView)		    
		    self.tItemIconGroup[k] = pTempView	
		else
			self.tItemIconGroup[k]:setCurData(self.pIconListData[k], self.nCurIconSelectId)
    	end
    end	

    if bNew then
		self.pIconScroll:scrollToBegin(false)    	
    	local pIconData = Player:getPlayerInfo():getIconDataById(self.nCurIconSelectId)    	
    	local nIdx = tonumber(pIconData.nSequence or 0)
    	local nY = self.pLayIconList:getHeight() - self.tItemIconGroup[nIdx]:getHeight() -  self.tItemIconGroup[nIdx]:getPositionY()  
    	if nY > 0 then
    		nY = 0
    	end 	    	    	
    	self.pIconScroll:scrollTo(0,nY) 	    	    
    end		
end

function LayIconView:onIconClickBack( _tData )
	-- body
	if not _tData then
		return
	end
	if self.nCurIconSelectId ~= _tData.sTid then
		if _tData.nCd == 0 then
			local tTips = luaSplit(getTipsByIndex(20061), ";")
			TOAST(tTips[_tData.nSequence])
			return
		end
		self.nCurIconSelectId = _tData.sTid
		self:updateIconsView()
	end
end


function LayIconView:onBtnClicked(  )
	-- body	
	SocketManager:sendMsg("reqChangeCharacters", {self.nCurIconSelectId, 1}, handler(self, self.onGetFunc)) 
end

function LayIconView:onGetFunc( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		TOAST(getConvertedStr(6, 10596))
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end	
end

--析构方法
function LayIconView:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayIconView:regMsgs( )
	-- body
	--注册玩家信息刷新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
end

-- 注销消息
function LayIconView:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_playerinfo)
end
--暂停方法
function LayIconView:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayIconView:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayIconView
