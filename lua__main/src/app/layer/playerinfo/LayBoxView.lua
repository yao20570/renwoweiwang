-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-02-06 14:36:23 星期二
-- Description: 头像框分页 
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemBoxs = require("app.layer.playerinfo.ItemBoxs")
local ScrollViewEx = require("app.common.listview.ScrollViewEx")
local LayBoxView = class("LayBoxView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayBoxView:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_box_view", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayBoxView:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayBoxView",handler(self, self.onDestroy))
end

-- --初始化参数
function LayBoxView:myInit()
	-- body
	self.nCurBoxSelectId = nil
	self.tItemBoxGroup = {}	
end

function LayBoxView:refreshData(  )
	-- body
	local tActorVo = Player:getPlayerInfo():getActorVo()	
	local tBoxs = Player:getPlayerInfo():getMyBoxDatas()
	self.pBoxListData = {}
	table.sort(tBoxs, function (a, b)
		-- body
		return a.nSequence < b.nSequence
	end)
	for k, v in pairs(tBoxs) do
		local nSequence = v.nSequence
		if not self.pBoxListData[nSequence] then
			self.pBoxListData[nSequence] = {}
		end
		table.insert(self.pBoxListData[nSequence], v)
	end	
	self.nCurBoxSelectId = tActorVo.sB
end

--初始化控件
function LayBoxView:setupViews( )
	-- body	
	self.pLayMain = self:findViewByName("lay_box_view") 
	self.pLayMain:setContentSize(self:getContentSize())	
    self.pLayBtn = self:findViewByName("lay_btn")
    self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10594))
    self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function LayBoxView:updateViews(  )
	-- body
	self:refreshData()
	self:updateBoxsView()
    self:refreshPrevView()
end

function LayBoxView:updateBoxsView( ... )
	-- body
	local bNew = false
	if not self.pBoxScroll then
		self.pLayBoxList = self:findViewByName("lay_box")
		self.pBoxScroll = ScrollViewEx.new( self.pLayBoxList:getWidth() - 40, self.pLayBoxList:getHeight())
		self.pBoxScroll:setAnchorPoint(0,0)		    
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pBoxScroll:setUpAndDownArrow(pUpArrow, pDownArrow)		    
	    self.pLayBoxList:addView(self.pBoxScroll)  
	    centerInView(self.pLayBoxList, self.pBoxScroll)  
	    self.pBoxScroll:setBounceable(true)		        	
	    bNew = true   	    
	end		
    for k, v in pairs(self.pBoxListData) do
    	if not self.tItemBoxGroup[k] then	    		
		 	local pTempView = ItemBoxs.new(self.pBoxListData[k], self.nCurBoxSelectId)			   		    
	        pTempView:setViewTouched(false) 
            pTempView:setAnchorPoint(0.5, 0)
	        pTempView:setIconClickHandler(handler(self, self.onBoxClickBack))  
	        self.pBoxScroll:addView(pTempView)		    
		    self.tItemBoxGroup[k] = pTempView	
		else
			self.tItemBoxGroup[k]:setCurData(self.pBoxListData[k], self.nCurBoxSelectId)
    	end
    end	
    if bNew then
		self.pBoxScroll:scrollToBegin(false)	    	
    	local pIconData = Player:getPlayerInfo():getBoxDataById(self.nCurBoxSelectId)    	
    	local nIdx = tonumber(pIconData.nSequence or 0)
    	local nY = self.pLayBoxList:getHeight() - self.tItemBoxGroup[nIdx]:getHeight() -  self.tItemBoxGroup[nIdx]:getPositionY()  	
    	if nY > 0 then
    		nY = 0
    	end
    	self.pBoxScroll:scrollTo(0,nY)
    end		
end

function LayBoxView:refreshPrevView(  )
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
	local pCurBoxBase = Player:getPlayerInfo():getBoxDataById(pActorVo1.sB)	
	--dump(pCurBoxBase, "pCurBoxBase", 100)
	--名称
	if not self.pLbPar1 then
		self.pLbPar1 = self:findViewByName("lb_pa_1")
	end
	self.pLbPar1:setString(pCurBoxBase.sName)
	--使用期限
	if not self.pLbPar2 then
		self.pLbPar2 = self:findViewByName("lb_pa_2")
	end
	if pCurBoxBase.nTime == -1 then
		local sStr = {
			{color=_cc.pwhite, text= getConvertedStr(6, 10649)},
			{color=_cc.pwhite, text= getConvertedStr(6, 10650)},
		}
		self.pLbPar2:setString(sStr, false)
	elseif pCurBoxBase:getBoxCdTime() > 0 then
		bIsNeedMF = true
		self.pLbPar2:setString(getIconBoxUseTime(pCurBoxBase:getBoxCdTime(), true), false)
	end
	--使用说明
	if not self.pLbPar3 then
		self.pLbPar3 = self:findViewByName("lb_pa_3")
	end
	self.pLbPar3:setString(pCurBoxBase.sDes)


	--当前选中
	local pActorVo2 	 = 			ActorVo.new()
  	pActorVo2:initData(pActorVo1.sI, self.nCurBoxSelectId, nil)
	if not self.pIcon2 then
		local pLayIcon2 = self:findViewByName("lay_icon_2")
		self.pIcon2 = getIconGoodsByType(pLayIcon2, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo2)
		self.pIcon2:setIconIsCanTouched(false)
	else
		self.pIcon2:setCurData(pActorVo2)
	end
	local pSelectBoxBase = Player:getPlayerInfo():getBoxDataById(pActorVo2.sB)
	--dump(pSelectBoxBase, "pSelectBoxBase", 100)
	if not self.pLbPar4 then
		self.pLbPar4 = self:findViewByName("lb_pa_4")
	end
	self.pLbPar4:setString(pSelectBoxBase.sName)
	if not self.pLbPar5 then
		self.pLbPar5 = self:findViewByName("lb_pa_5")
	end
	if pSelectBoxBase.nTime == -1 then
		local sStr = {
			{color=_cc.pwhite, text= getConvertedStr(6, 10649)},
			{color=_cc.pwhite, text= getConvertedStr(6, 10650)},
		}
		self.pLbPar5:setString(sStr, false)
	elseif pSelectBoxBase:getBoxCdTime() > 0 then
		bIsNeedMF = true
		self.pLbPar5:setString(getIconBoxUseTime(pSelectBoxBase:getBoxCdTime(), true), false)
	end	
	if not self.pLbPar6 then
		self.pLbPar6 = self:findViewByName("lb_pa_6")
	end
	self.pLbPar6:setString(pSelectBoxBase.sDes)
	if bIsNeedMF then
		regUpdateControl(self, handler(self, self.onUpdateTime))
	end	
end

function LayBoxView:onUpdateTime(  )
	-- body
	--当前佩戴
	local pActorVo1 = Player:getPlayerInfo():getActorVo()

	local pCurBoxBase = Player:getPlayerInfo():getBoxDataById(pActorVo1.sB)	
	--使用期限
	if not self.pLbPar2 then
		self.pLbPar2 = self:findViewByName("lb_pa_2")
	end
	if pCurBoxBase:getBoxCdTime() > 0 then
		self.pLbPar2:setString(getIconBoxUseTime(pCurBoxBase:getBoxCdTime(), true), false)
	end

	--当前选中
	local pActorVo2 	 = 			ActorVo.new()
  	pActorVo2:initData(pActorVo1.sI, self.nCurBoxSelectId, nil)
	local pSelectBoxBase = Player:getPlayerInfo():getBoxDataById(pActorVo2.sB)
	if not self.pLbPar5 then
		self.pLbPar5 = self:findViewByName("lb_pa_5")
	end
	if pSelectBoxBase:getBoxCdTime() > 0 then
		self.pLbPar5:setString(getIconBoxUseTime(pSelectBoxBase:getBoxCdTime(), true), false)
	end	
	if pCurBoxBase:getBoxCdTime() <= 0 and pSelectBoxBase:getBoxCdTime() <= 0 then
		unregUpdateControl(self)--停止计时刷新
	end
end

function LayBoxView:onBoxClickBack( _tData )
	-- body
	if not _tData then
		return
	end
	if self.nCurBoxSelectId ~= _tData.sTid then
		if _tData.nCd == 0 then
			TOAST(_tData.sTips)
			return
		end
		self.nCurBoxSelectId = _tData.sTid		
		self:updateBoxsView()
	    self:refreshPrevView()
	end
end

function LayBoxView:onBtnClicked(  )
	-- body	
	SocketManager:sendMsg("reqChangeCharacters", {self.nCurBoxSelectId, 2}, handler(self, self.onGetFunc)) 
end

function LayBoxView:onGetFunc( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success then
		TOAST(getConvertedStr(6, 10596))
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end	
end

--析构方法
function LayBoxView:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayBoxView:regMsgs( )
	-- body
    --注册玩家信息刷新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))

end

-- 注销消息
function LayBoxView:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_playerinfo)
end
--暂停方法
function LayBoxView:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayBoxView:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayBoxView
