-----------------------------------------------------
-- author: wangxs
-- updatetime:   2017-05-09 11:09:29 星期二
-- Description: 科学院
-----------------------------------------------------

local ItemTechnology = require("app.layer.technology.ItemTechnology")
local DlgBase = require("app.common.dialog.DlgBase")
local TnolyListTopLayer = require("app.layer.technology.TnolyListTopLayer")
local ItemPalaceCivil = require("app.layer.palace.ItemPalaceCivil")
local LayRecommendTnoly = require("app.layer.technology.LayRecommendTnoly")

local DlgTechnology = class("DlgTechnology", function()
	-- body
	return DlgBase.new(e_dlg_index.technology)
end)

function DlgTechnology:ctor(_nTarScienceId)
	-- body
	self:myInit(_nTarScienceId)

	parseView("dlg_technology", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgTechnology:myInit( _nTarScienceId )
	-- body
	self.tUpingTnoly 			= 			nil 		--升级中的科技
	self.tCanUpLists 			= 			nil 		--可升级科技
	self.tCurUping 				= 			nil 		--当前正在研究的队列
	self.nTarScienceId          =           _nTarScienceId  --指定升级科技
	self.nTarPos                =           nil         --指定的科技位置
	self.bIsScrollToTar         =           false         --是否已经跳到过指定的科技位置
end

--解析布局回调事件
function DlgTechnology:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()

	self:initData()
	-- self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgTechnology",handler(self, self.onDlgTechnologyDestroy))
end

--初始化控件
function DlgTechnology:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("default")
	--设置标题
	self:setTitle(self.tBuildInfo.sName .. getLvString(self.tBuildInfo.nLv,true))
	
	--雇佣层
	self.pLayUse = self:findViewByName("lay_msg")
	self.pItemPalaceCivil = ItemPalaceCivil.new(e_hire_type.researcher, true) --研究员信息Item	
	self.pLayUse:addView(self.pItemPalaceCivil,10)
	--listview
	self.pLayListView 			= 	self:findViewByName("listview")
	self.pListView = MUI.MListView.new {
	    viewRect = cc.rect(0, 0, self.pLayListView:getWidth(), self.pLayListView:getHeight()),
	    itemMargin = {
	    	left =  0,
		    right = 0,
		    top = 0,
		    bottom = 0},
	    direction = MUI.MScrollView.DIRECTION_VERTICAL}
	self.pLayListView:addView(self.pListView)
	self.pListView:setBounceable(true)
	self.pListView:setItemCount(0) 
	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))

	--科技总览
	-- self.pLayAll  	 			= 	self:findViewByName("lay_all")
	-- self.pBtnAll = getCommonButtonOfContainer(self.pLayAll,TypeCommonBtn.M_YELLOW,getConvertedStr(1,10171))
	-- self.pBtnAll:onCommonBtnClicked(handler(self, self.onAllClicked))

	--国际化语言文字
	local pLbText 					= 	self:findViewByName("lb_title2")
	setTextCCColor(pLbText,_cc.white)
	pLbText:setString(getConvertedStr(1, 10173))

end

-- 修改控件内容或者是刷新控件数据
function DlgTechnology:updateViews(  )
	-- body
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			--获得科技院数据
			local tTnolyData = Player:getBuildData():getBuildById(e_build_ids.tnoly)
			if tTnolyData then
				--标题
				local sTitle = tTnolyData.sName .. getLvString(tTnolyData.nLv)
				self:setTitle(sTitle)
			end

			--雇佣层
			if not self.pLayUse then
				self.pLayUse = self:findViewByName("lay_msg")
				self.pItemPalaceCivil = ItemPalaceCivil.new(e_hire_type.researcher, true) --研究员信息Item
				self.pLayUse:addView(self.pItemPalaceCivil,10)
				self.pItemPalaceCivil:hideDiBg()
			else
				self:refreshResearcherInfo()
			end
			--科技总览
			if not self.pLayAll then
				self.pLayAll = self:findViewByName("lay_all")
				self.pBtnAll = getCommonButtonOfContainer(self.pLayAll,TypeCommonBtn.M_YELLOW,getConvertedStr(1,10171))
				self.pBtnAll:onCommonBtnClicked(handler(self, self.onAllClicked))
			end
			--国际化语言文字
			if not self.pLbText then
				self.pLbText = self:findViewByName("lb_title2")
				setTextCCColor(self.pLbText,_cc.white)
				self.pLbText:setString(getConvertedStr(1, 10173))
			end
			--顶部banner文字提示
			if not self.pLbTopTip then
				local pLayTopTip = self:findViewByName("lay_top_tip")
				pLayTopTip:setVisible(true)
				self.pLbTopTip = self:findViewByName("lb_toptip")
				self.pLbTopTip:setString(getTextColorByConfigure(getTipsByIndex(20014)), false)
				--顶部banner图
				local pBannerImage 			= 		self:findViewByName("lay_banner_bg")
				local pMBanner = setMBannerImage(pBannerImage,TypeBannerUsed.kjy)
				pMBanner:setMBannerOpacity(100)

			end
		elseif(_index == 2) then
			local nCurrCount = table.nums(self.tCanUpLists)
			--列表层
			if not self.pLayListView then
				self.pLayListView = self:findViewByName("listview")
				self.pListView = MUI.MListView.new {
				    viewRect = cc.rect(0, 0, self.pLayListView:getWidth(), self.pLayListView:getHeight()),
				    itemMargin = {
				    	left =  0,
					    right = 0,
					    top = 0,
					    bottom = 0},
				    	direction = MUI.MScrollView.DIRECTION_VERTICAL
				    }
				self.pLayListView:addView(self.pListView)
				self.pListView:setBounceable(true)
				self.pListView:setItemCount(nCurrCount or 0) 
				self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
				-- -- 判断顶部
				self:refreshLvItem()
				-- 定位显示的位置
				self:refreshTarTnoly()
				--上下箭头
				local pUpArrow, pDownArrow = getUpAndDownArrow()
				self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
				-- 刷新整个列表
				self.pListView:reload(true)
			else
				-- 判断顶部
				self:refreshLvItem()
				-- 定位显示的位置
				self:refreshTarTnoly()
				-- 刷新整个列表
				self.pListView:notifyDataSetChange(false, nCurrCount)
			end
			if not self.pLayBot then
				--底部层
				self.pLayBot = self:findViewByName("lay_bottom")
				--科技推荐层
				self.pLayRecTnoly = self:findViewByName("lay_recom_tnoly")
			end
			--推荐科技
			local pRecTnoly = self.tRecommendLists[1]
			local bShowRecommend = false
			--存在推荐科技
			if pRecTnoly then
				bShowRecommend = true --是否显示底部推荐科技
				if self.tUpingTnoly then
					--如果是正在研究的科技则隐藏
					if self.tUpingTnoly.sTid == pRecTnoly.sTid then
						bShowRecommend = false
					end
				end
			end
			if bShowRecommend then
				if not self.pRecommendView then
					self.pRecommendView = LayRecommendTnoly.new(pRecTnoly)
					self.pLayRecTnoly:addView(self.pRecommendView, 10)
				end
				self.pRecommendView:setRecommendData(pRecTnoly)
				self.pLayBot:setVisible(false)
				self.pLayRecTnoly:setVisible(true)
			else
				self.pLayBot:setVisible(true)
				if self.pLayRecTnoly then
					self.pLayRecTnoly:setVisible(false)
				end
			end
		elseif(_index == 3) then
			-- -- 判断顶部
			self:refreshLvItem()
			-- 定位显示的位置
			self:refreshTarTnoly()
			self.bIsScrollToTar = true    --只定位一次
		end
	end)

end

-- 析构方法
function DlgTechnology:onDlgTechnologyDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgTechnology:regMsgs( )
	-- body
	-- 注册科技数据变化消息
	regMsg(self, gud_refresh_tnoly_lists_msg, handler(self, self.onRefresh))
	--注册研究员数据变化消息
	regMsg(self, ghd_refresh_researcher_msg, handler(self, self.refreshResearcherInfo))
	--玩家信息数据变化消息
	regMsg(self, gud_refresh_playerinfo, handler(self,self.onRefresh))
end

-- 注销消息
function DlgTechnology:unregMsgs(  )
	-- body
	-- 销毁科技数据变化消息
	unregMsg(self, gud_refresh_tnoly_lists_msg)
	--注销研究员数据变化消息
	unregMsg(self, ghd_refresh_researcher_msg)
	--注销玩家信息数据变化消息
	unregMsg(self, gud_refresh_playerinfo)
end


--暂停方法
function DlgTechnology:onPause( )
	-- body
	self:unregMsgs()
	if not gIsNull(self.pUpingView) then
		self.pUpingView:onPause()
	end
end

--继续方法
function DlgTechnology:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	if not gIsNull(self.pUpingView) then
		self.pUpingView:onResume()
	end
end


--总览点击事件
function DlgTechnology:onAllClicked( _pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.tnolytree --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)

end


--初始化数据
function DlgTechnology:initData( )
	-- body
	self.tUpingTnoly = Player:getTnolyData():getUpingTnoly()
	self.tCanUpLists = Player:getTnolyData():getCanUpTnolyLists()
	--推荐列表
	self.tRecommendLists = Player:getTnolyData():getRecommendLists()

	--优先级排序
	table.sort(self.tCanUpLists, function ( a, b )
		local r
		local bMaxLvA = a:isMaxLv()
		local bMaxLvB = b:isMaxLv()
		if bMaxLvA == bMaxLvB then
			local bCheckA = a:checkisLocked(false)
			local bCheckB = b:checkisLocked(false)
			if bCheckA == bCheckB then
				if a.nOrder <= 10 and b.nOrder <= 10 then --推荐项			
					if a.nCurIndex == b.nCurIndex == 0 then
						r = a.nOrder < b.nOrder
					elseif a.nCurIndex > 0 and b.nCurIndex > 0 then
						r = a.fLastStudytime > b.fLastStudytime
					else
						r = a.nCurIndex > b.nCurIndex
					end
				elseif a.nOrder > 10 and b.nOrder > 10 then
					if a.nCurIndex == b.nCurIndex == 0 then
						r = a.nOrder < b.nOrder
					elseif a.nCurIndex > 0 and b.nCurIndex > 0 then
						r = a.fLastStudytime > b.fLastStudytime
					else
						r = a.nCurIndex > b.nCurIndex
					end
				else
					r = a.nOrder < b.nOrder
				end
				return r
			else
				return bCheckB
			end
		else
			return bMaxLvB
		end

	end)
end

--刷新队列数据
function DlgTechnology:refreshLvItem(  )
	-- body
	--如果有正在研究的科技
	if self.tUpingTnoly then
		self:addUpingView()
		--如果正在研究的科技就是目标科技就取消目标定位, 定位到正在研究的科技
		if self.tUpingTnoly.sTid == self.nTarScienceId then
			self.nTarScienceId = nil
		end
	else
		self:removeUpingView()
	end
end

--如果有目标科技的话移动到指定科技
function DlgTechnology:refreshTarTnoly()
	-- body
	if self.tCanUpLists then
		if self.nTarScienceId then
			for k, v in pairs(self.tCanUpLists) do
				if self.nTarScienceId == v.sTid then
					self.nTarPos = k
				end
			end			
			if self.nTarPos and not self.bIsScrollToTar then
				if self.tUpingTnoly then
					if self.nTarPos > 5 then
						self.pListView:scrollToPosition(self.nTarPos)
					end
				else
					if self.nTarPos > 6 then
						self.pListView:scrollToPosition(self.nTarPos)
					end
				end
			end
		else
			--如果有正在研究的科技移到顶部
			if self.pUpingView then
				self.pListView:scrollToBegin()
			end
		end
	end
end

function DlgTechnology:onScrollToBegin()
	-- body
	if self.pUpingView then
		self.pListView:scrollToBegin()
	end
end

--列表项回调
function DlgTechnology:onListViewItemCallBack( _index, _pView )
	-- body
	local tTempData = self.tCanUpLists[_index]
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemTechnology.new(1)  
    end
    pTempView:setCurData(tTempData, self.nTarScienceId)
    return pTempView
end

--添加正在研究中的布局
function DlgTechnology:addUpingView(  )
	-- body
	if not self.pUpingView then
		self.pUpingView = TnolyListTopLayer.new()
		self.pListView:addHeaderView(self.pUpingView)
	end
	self.pUpingView:setCurData(self.tUpingTnoly)
end

--移除正在研究中的布局
function DlgTechnology:removeUpingView(  )
	-- body
	self.pListView:removeHeaderView()
	self.pUpingView = nil
end

--科技消息回调刷新
function DlgTechnology:onRefresh(  )
	-- body
	self:initData()
	self:updateViews()
end
--刷新研究员信息刷新
function DlgTechnology:refreshResearcherInfo(  )
	-- body
	if self.pItemPalaceCivil then
		self.pItemPalaceCivil:updateViews()
	end
end
return DlgTechnology