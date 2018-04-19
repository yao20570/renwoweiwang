----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-09 11:23:14
-- Description: 国家荣誉排行
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemVoteLayer = require("app.layer.country.ItemVoteLayer")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemActivityRank = require("app.layer.activitya.ItemActivityRank")
local CountryGloryRankLayer = class("CountryGloryRankLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function CountryGloryRankLayer:ctor( _ranktype )
	-- body
	self:myInit(_ranktype)
	parseView("country_glory_rank_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function CountryGloryRankLayer:myInit( _ranktype )
	-- body
	self.nRankType = _ranktype or e_rank_type.cityfight
	self.tCurData = nil
end

--解析布局回调事件
function CountryGloryRankLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()	

	--注册析构方法
	self:setDestroyHandler("CountryGloryRankLayer",handler(self, self.onCountryGloryRankLayerDestroy))
end

--初始化控件
function CountryGloryRankLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	-- self.pLayTitle = self:findViewByName("lay_title")
	-- self.pTitleBg1 = self:findViewByName("title_bg_1")
	-- self.pTitleBg2 = self:findViewByName("title_bg_2")
    self.pLayTop = self:findViewByName("lay_top")
	self.pLayTab = self:findViewByName("lay_tab")
    self.pLayBottom = self:findViewByName("lay_bottom")

	self.pTitleLayer = ItemVoteLayer.new()
	--self.pTitleLayer:setPosition(0, self.pLayTab:getHeight() - 120)
	self.pLayTab:addView(self.pTitleLayer, 20)
	-- self.pLbTitle = self:findViewByName("lb_title")
	-- setTextCCColor(self.pLbTitle, _cc.white)
	-- self.pLbTitle:setString(getConvertedStr(6, 10358))
	-- self.tTitleGroup = {}
	-- for i = 1, 4 do
	-- 	self.tTitleGroup[i] = self:findViewByName("lb_title_"..i)
	-- 	setTextCCColor(self.tTitleGroup[i], _cc.white)	
	-- end

	-- self.tTitleGroup[1]:setString(getConvertedStr(6, 10242))
	-- self.tTitleGroup[2]:setString(getConvertedStr(6, 10244))
	-- self.tTitleGroup[3]:setString(getConvertedStr(6, 10359))
	-- self.tTitleGroup[4]:setString(getConvertedStr(6, 10360))

	-- self.pLayContent = self:findViewByName("lay_content")
	-- self.tItemGroup = {}	
	-- for i = 1, 5 do 
	-- 	local pitem = ItemVoteLayer.new()		
	-- 	pitem:setPosition(0, 300 - (i-1)*60)
	-- 	pitem:getBtn():setVisible(false)
	-- 	self.pLayTab:addView(pitem, 10)
	-- 	self.tItemGroup[i] = pitem
	-- end

	local str1 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10236)},
		{color=_cc.pwhite,text=numTranformToWeek(getCountryParam("resetRankDay"))},
		{color=_cc.red,text=getCountryParam("resetRankTime")},
		{color=_cc.pwhite,text=getConvertedStr(6, 10503)},		
	}
	if not self.pLbPar1 then
		self.pLbPar1 = MUI.MLabel.new({
	        text="",
	        size=20,
	        anchorpoint=cc.p(0, 0.5),
	        dimensions = cc.size(500, 0),
	        })	
		self.pLbPar1:setPosition(20, 65)
		self.pLayBottom:addView(self.pLbPar1, 10)
	end
	self.pLbPar1:setString(str1, false)


	if not self.pLbPar3 then
		self.pLbPar3 = MUI.MLabel.new({
	        text="",
	        size=20,
	        anchorpoint=cc.p(0, 0.5),
	        dimensions = cc.size(500, 0),
	        })	
		self.pLbPar3:setPosition(20, 35)
		self.pLbPar3:setString(getTextColorByConfigure(getTipsByIndex(10054)), false)
		self.pLayBottom:addView(self.pLbPar3, 10)	
	end		
	--排行
	self.tTitles = {getConvertedStr(6, 10358), getConvertedStr(6, 10407), getConvertedStr(6, 10408)}
	self.pTComTabHost = TCommonTabHost.new(self.pLayTop,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pLayTop:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()
	self.pTComTabHost:setDefaultIndex(1)
	--按钮集
	self.pTabItems =  self.pTComTabHost:getTabItems()	
end

function CountryGloryRankLayer:onIndexSelected( _nIndex )
	-- body
	if _nIndex == 1 then
		self.nRankType = e_rank_type.cityfight
	elseif _nIndex == 2 then
		self.nRankType = e_rank_type.countryfight
	else
		self.nRankType = e_rank_type.country_science
	end
	-- --获取当前类型的排行数据
	self:getRankInfoFormService()
end
-- 修改控件内容或者是刷新控件数据
function CountryGloryRankLayer:updateViews( )
	-- body	
	if not self.pLbPar2 then
		self.pLbPar2 = MUI.MLabel.new({
	        text="",
	        size=20,
	        anchorpoint=cc.p(1, 0.5),
	        dimensions = cc.size(500, 0),
	        })	
		self.pLbPar2:setPosition(590, 65)
		self.pLayBottom:addView(self.pLbPar2, 10)
	end
	local nVotes = Player:getCountryData():getCountryDataVo().nVotes
	local Str2 = {
		{color=_cc.pwhite, text=getConvertedStr(6, 10504)},
		{color=_cc.blue, text=nVotes or 0},
	}
	self.pLbPar2:setString(Str2)	


	-- --dump(self.tCurData, "self.tCurData", 100)	
	-- local t1, t2 = getRankSetTypePos(self.nRankType)
	-- local nwidth = self.pLayTitle:getWidth()	
	-- --标题更新
	-- -- for i = 1, 4 do
	-- -- 	if t2[i] and t1[i] then				
	-- -- 		self.tTitleGroup[i]:setVisible(true)
	-- -- 		self.tTitleGroup[i]:setString(t2[i])
	-- -- 		self.tTitleGroup[i]:setPositionX(t1[i]*nwidth)
	-- -- 	else
	-- -- 		self.tTitleGroup[i]:setVisible(false)
	-- -- 	end
	-- -- end	

	-- local rankdata = getRankData( self.nRankType )--字段索引
	-- local ttypes = luaSplit(rankdata.sort, ";")
	-- for i = 1, 5 do
	-- 	local pitem = self.tItemGroup[i]
	-- 	if self.tCurData[i] then
	-- 		local data = self.tCurData[i]
	-- 		pitem:setVisible(true)
	-- 		local tlabels = pitem.tLbValues					
	-- 		for k = 1, 5 do
	-- 			if ttypes[k] and t1[k] then
	-- 				tlabels[k]:setVisible(true)
	-- 				tlabels[k]:setPositionX(t1[k]*nwidth)
	-- 				tlabels[k]:setString(data[ttypes[k]])
	-- 				setTextCCColor(tlabels[k], _cc.pwhite) 
	-- 			else
	-- 				tlabels[k]:setVisible(false)
	-- 			end
				
	-- 		end			
	-- 	else
	-- 		--pitem:setVisible(false)			
	-- 		pitem:showEmpty(getConvertedStr(6, 10417))
	-- 	end
	-- end
end

function CountryGloryRankLayer:updateRankInfo(  )
	-- body
	--数据更新
	self.tCurData = Player:getRankInfo():getRankDatasByRankType(self.nRankType)	
	if not self.tCurData then
		self.tCurData = {}
	end	
--dump(self.tCurData, "self.tCurData", 100)	
	local t1, t2 = getRankSetTypePos(self.nRankType)
	local nwidth = self.pLayTab:getWidth()	
	self.pTitleLayer:setColumns(#t2)
	self.pTitleLayer:showRankTitles(t2, t1)
	--标题更新
	-- for i = 1, 4 do
	-- 	if t2[i] and t1[i] then				
	-- 		self.tTitleGroup[i]:setVisible(true)
	-- 		self.tTitleGroup[i]:setString(t2[i])
	-- 		self.tTitleGroup[i]:setPositionX(t1[i]*nwidth)
	-- 	else
	-- 		self.tTitleGroup[i]:setVisible(false)
	-- 	end
	-- end	
	if not self.pListView then
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, 640, self.pLayTab:getHeight() - 120 ),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }	
		self.pLayTab:addView(self.pListView)
		self.pListView:setBounceable(true) --是否回弹
		self.pListView:setItemCallback(handler(self, self.onTabEveryCallback))
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(table.nums(self.tCurData))		
		self.pListView:reload(false)
	else
		self.pListView:notifyDataSetChange(false, table.nums(self.tCurData))		
	end


	-- local rankdata = getRankData( self.nRankType )--字段索引
	-- local ttypes = luaSplit(rankdata.sort, ";")
	-- for i = 1, 5 do
	-- 	local pitem = self.tItemGroup[i]
	-- 	if self.tCurData[i] then
	-- 		local data = self.tCurData[i]
	-- 		pitem:setVisible(true)
	-- 		local tlabels = pitem.tLbValues					
	-- 		for k = 1, 5 do
	-- 			if ttypes[k] and t1[k] then
	-- 				tlabels[k]:setVisible(true)
	-- 				tlabels[k]:setPositionX(t1[k]*nwidth)
	-- 				tlabels[k]:setString(data[ttypes[k]])
	-- 				setTextCCColor(tlabels[k], _cc.pwhite) 
	-- 			else
	-- 				tlabels[k]:setVisible(false)
	-- 			end
				
	-- 		end			
	-- 	else
	-- 		--pitem:setVisible(false)			
	-- 		pitem:showEmpty(getConvertedStr(6, 10417))
	-- 	end
	-- end	
end

function CountryGloryRankLayer:onTabEveryCallback( _index, _pView )
	-- body
 	local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemActivityRank.new(60, 640)                        
        pTempView:setViewTouched(false)
    end   
    if self.tCurData then
    	pTempView:setCurData(self.tCurData[_index])
    end
    return pTempView
end
-- 析构方法
function CountryGloryRankLayer:onCountryGloryRankLayerDestroy(  )
	-- body
	self:onPause()
end


--注册消息
function CountryGloryRankLayer:regMsgs(  )
	-- body
end
--注销消息
function CountryGloryRankLayer:unregMsgs(  )
	-- body
end

--暂停方法
function CountryGloryRankLayer:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function CountryGloryRankLayer:onResume( _bReshow )
	-- body		
	-- if _bReshow then
	-- 	-- --获取当前类型的排行数据
	-- 	self:getRankInfoFormService()
	-- end
	self:regMsgs()
	self:updateViews()
end

function CountryGloryRankLayer:setTitle( _str )
	-- body
	if not _str then
    	return
    end
    --self.pLbTitle:setString(_str)
end

function CountryGloryRankLayer:getRankInfoFormService()
	-- body
	--		
	SocketManager:sendMsg("getRankData", {self.nRankType, 1}, function ( __msg, __oldmsg )
		-- body
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.getRankData.id then
				if __oldmsg[1] == self.nRankType then
					self:updateRankInfo()				
				end				
			end
		else
	        TOAST(SocketManager:getErrorStr(__msg.head.state))
	        print("getRankData error.."..__oldmsg[1])
	    end
	end, -1)
end
return CountryGloryRankLayer


