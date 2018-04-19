----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-15 21:11:24
-- Description: 行军详细
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemWorldBattleDetail = require("app.layer.worldbattle.ItemWorldBattleDetail")
local ItemWorldBattleDetailHit = require("app.layer.worldbattle.ItemWorldBattleDetailHit")
local WorldBattleDetail = class("WorldBattleDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nTabIndex 1,武将，2，来袭，3，国战，4，协防,
function WorldBattleDetail:ctor(  )
	--解析文件
	parseView("layout_world_battle_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function WorldBattleDetail:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldBattleDetail", handler(self, self.onWorldBattleDetailDestroy))

end

-- 析构方法
function WorldBattleDetail:onWorldBattleDetailDestroy(  )
    self:onPause()
end

function WorldBattleDetail:regMsgs(  )
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews)) --武将更换
	regMsg(self, gud_tcf_hero_pos_unlock_push, handler(self, self.updateViews))
	regMsg(self, gud_my_country_war_list_change, handler(self, self.updateViews)) --国战数量
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews)) --出征数量
	regMsg(self, gud_refresh_wall, handler(self, self.updateViews)) --已支援数量
	regMsg(self, gud_friend_army_list_change, handler(self, self.updateViews)) --友军驻防
	regMsg(self, gud_my_city_war_list_change, handler(self, self.updateViews)) --我的城战
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.updateViews)) --我的城池坐标发生改变
	regMsg(self, ghd_world_city_war_support_used, handler(self, self.onSupportUsed))--我的支援次数
	regMsg(self, ghd_refresh_palace_lv_msg, handler(self, self.updateViews))--统帅府数据刷新
end

function WorldBattleDetail:unregMsgs(  )
	unregMsg(self, gud_refresh_hero)
	unregMsg(self, gud_tcf_hero_pos_unlock_push)
	unregMsg(self, gud_my_country_war_list_change)
	unregMsg(self, gud_world_task_change_msg)
	unregMsg(self, gud_refresh_wall)
	unregMsg(self, gud_friend_army_list_change)
	unregMsg(self, gud_my_city_war_list_change)
	unregMsg(self, gud_world_my_city_pos_change_msg)
	unregMsg(self, ghd_world_city_war_support_used)
	unregMsg(self, ghd_refresh_palace_lv_msg)
end

function WorldBattleDetail:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function WorldBattleDetail:onPause(  )
	self:unregMsgs()
end

function WorldBattleDetail:setupViews(  )
	--拦截点击
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onBackClicked))

	--拦截点击
	local pLayBgView = self:findViewByName("view")
	pLayBgView:setViewTouched(true)
	pLayBgView:setIsPressedNeedScale(false)
	pLayBgView:setIsPressedNeedColor(false)

	local pLayBack = self:findViewByName("lay_back")
	pLayBack:setViewTouched(true)
	pLayBack:setIsPressedNeedScale(false)
	pLayBack:onMViewClicked(handler(self, self.onBackClicked))

	local pImgBack = self:findViewByName("img_back")
	pImgBack:setFlippedX(true)

	self.pLayTabHost = self:findViewByName("lay_tab")

	--切换卡层
	self.tTitles = {
		"1",
		"2",
		"3",
		"4",
		"5",
	}
	self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pTabItems = self.pTComTabHost:getTabItems()
	for i=1,#self.pTabItems do
		self.pTabItems[i].nIndex = i
	end
	self.pLayTabHost:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()
end

function WorldBattleDetail:updateViews(  )
	self:updateTitles()
	if self.nCurrTab == e_wolrdbattle_tab.hero then
		self:updateHeros()
	elseif self.nCurrTab == e_wolrdbattle_tab.collect_hero then
		self:updateCollectHeros()
	elseif self.nCurrTab == e_wolrdbattle_tab.hit then
		self:updateHit()
	elseif self.nCurrTab == e_wolrdbattle_tab.country_war then
		self:updateCountryWar()
	elseif self.nCurrTab == e_wolrdbattle_tab.support then
		self:updateSupport()
	end
end

--刷新标题文本
function WorldBattleDetail:updateTitles()
	local tStrList = {}

	--武将状态
	local tHeroState = Player:getWorldData():getHeroStateListByTeam(e_hero_team_type.normal)
	self.tHeroState = tHeroState
	local nAllNum = #tHeroState
	local nIdelNum = 0
	for i=1,#tHeroState do
		if tHeroState[i].heroId then
			nIdelNum = nIdelNum + 1
		end
	end
	local tHeroList = Player:getHeroInfo():getOnlineHeroList()
	--已出征/已上阵
	local nOnLineNum = #tHeroList
	local nOutNum = nOnLineNum - nIdelNum
	table.insert(tStrList, getConvertedStr(3, 10420) .. string.format("%s/%s", nOutNum, nOnLineNum))

	--武将采集
	local tHeroState = Player:getWorldData():getHeroStateListByTeam(e_hero_team_type.collect)
	self.tCollectHeroState = tHeroState
	local nAllNum = #tHeroState
	local nIdelNum = 0
	for i=1,#tHeroState do
		if tHeroState[i].heroId then
			nIdelNum = nIdelNum + 1
		end
	end
	local tHeroList = Player:getHeroInfo():getCollectHeroList()
	--已采集/已上阵
	local nOnLineNum = #tHeroList
	local nOutNum = nOnLineNum - nIdelNum

		--采集队列
	local pBChiefData = Player:getBuildData():getBuildById(e_build_ids.tcf)
	if pBChiefData then
		self.pTabItems[2]:setViewEnabled(true)				
		self.pTabItems[2]:hideTabLock()
		table.insert(tStrList, getConvertedStr(3, 10057) .. string.format("%s/%s", nOutNum, nOnLineNum))
	else
		--采集队列未开启	
		self.pTabItems[2]:showTabLock()
		self.pTabItems[2]:setViewEnabled(false)
		self.pTabItems[2]:onMViewDisabledClicked(handler(self, function (  )
			-- body
		    local nNeedLv = 0
		    local tBuild = getBuildDatasByTid(e_build_ids.tcf)
		    if tBuild then
		    	local tData = luaSplit(tBuild.open, ":") 
		    	if tData[2] and tonumber(tData[2]) then
		    		nNeedLv = tonumber(tData[2])
		    	end
		    end
		    TOAST(string.format(getTipsByIndex(20086), nNeedLv))
		end))
		table.insert(tStrList, getConvertedStr(3, 10057))
	end
	
	--我的城战信息
	self.tMyCityWarMsgs = Player:getWorldData():getMyCityWarMsgs()
	local tGhostWarNotices = Player:getWorldData():getGhostWarVo()
	if tGhostWarNotices and tGhostWarNotices:getCd() > 0 then
		table.insert(self.tMyCityWarMsgs,tGhostWarNotices)
	end
	table.insert(tStrList, getConvertedStr(3, 10421) .. tostring(#self.tMyCityWarMsgs))

	--显示国战数量
	self.tCountryWarMsgs = {}
	local nNeedLv = getWorldInitData("warOpen")
	if Player:getPlayerInfo().nLv >= nNeedLv then
		self.tCountryWarMsgs = Player:getWorldData():getMyCountryWarsList()
	end
	table.insert(tStrList, getConvertedStr(3, 10422) .. tostring(#self.tCountryWarMsgs))

	--来支援我的（包括在路上的)
	local tHelpDataList = {}
	--支援我的（包括在路上的)
	local tComingHelpVOs = Player:getWorldData():getFriendArmys()
	for i=1,#tComingHelpVOs do
		table.insert(tHelpDataList, {tComingHelpVO = tComingHelpVOs[i]})
	end
	--已驻防
	local tHelpMsgs = Player:getWorldData():getHelpMsgs()
	for i=1,#tHelpMsgs do
		table.insert(tHelpDataList, {tHelpMsg = tHelpMsgs[i]})
	end
	self.tHelpDataList = tHelpDataList
	local nHelpCount = #self.tHelpDataList
	table.insert(tStrList, getConvertedStr(3, 10423) .. tostring(nHelpCount))


	
	--刷新标题文本
	for i=1,#self.pTabItems do
		local sStr = tStrList[i]
		if sStr then
			self.pTabItems[i]:setTabTitle(sStr)
		end
	end
end

--更新武将数据
function WorldBattleDetail:updateHeros( )
	if self.nCurrTab ~= e_wolrdbattle_tab.hero then
		return
	end
	
	if not self.pListView then
		self:createListView(4)
	else
		self.pListView:notifyDataSetChange(true, 4)
	end
end

--更新采集武将数据
function WorldBattleDetail:updateCollectHeros( )
	if self.nCurrTab ~= e_wolrdbattle_tab.collect_hero then
		return
	end
	
	if not self.pListView then
		self:createListView(4)
	else
		self.pListView:notifyDataSetChange(true, 4)
	end
end

--更新被打
function WorldBattleDetail:updateHit( )
	if self.nCurrTab ~= e_wolrdbattle_tab.hit then
		return
	end
	if not self.pListView then
		self:createListView(#self.tMyCityWarMsgs)
	else
		self.pListView:notifyDataSetChange(true, #self.tMyCityWarMsgs)
	end
end

--更新国战数据
function WorldBattleDetail:updateCountryWar( )
	if self.nCurrTab ~= e_wolrdbattle_tab.country_war then
		return
	end
	if not self.pListView then
		self:createListView(#self.tCountryWarMsgs)
	else
		self.pListView:notifyDataSetChange(true, #self.tCountryWarMsgs)
	end
end

--更新支援
function WorldBattleDetail:updateSupport( )
	if self.nCurrTab ~= e_wolrdbattle_tab.support then
		return
	end
	--跑过来我支援
	if not self.pListView then
		self:createListView(#self.tHelpDataList)
	else
		self.pListView:notifyDataSetChange(true, #self.tHelpDataList)
	end
end

--标签切换
function WorldBattleDetail:onIndexSelected( nIndex )
	self.nCurrTab = nIndex
	if self.nCurrTab == e_wolrdbattle_tab.hero then
		self:updateHeros()
	elseif self.nCurrTab == e_wolrdbattle_tab.collect_hero then
		self:updateCollectHeros()
	elseif self.nCurrTab == e_wolrdbattle_tab.hit then
		self:updateHit()
	elseif self.nCurrTab == e_wolrdbattle_tab.country_war then
		self:updateCountryWar()
	elseif self.nCurrTab == e_wolrdbattle_tab.support then
		self:updateSupport()
	end
end

--标签切换
function WorldBattleDetail:changeTabIndex( nIndex )
	self.pTComTabHost:setDefaultIndex(nIndex)
end


--创建listView
function WorldBattleDetail:createListView(_count)
	local pContentLayer = self.pTComTabHost:getContentLayer()
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pContentLayer:getWidth(), pContentLayer:getHeight()),
		direction = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left =  10,
         right =  0,
         top =  5,
         bottom =  5}
    }
    
    local pContentLayer = self.pTComTabHost:getContentLayer()
    pContentLayer:addView(self.pListView)
    centerInView(pContentLayer, self.pListView )
    -- self.pListView:setPositionY(-15)

    --列表数据
    self.pListView:setItemCount(_count)
    self.pListView:setItemCallback(function ( _index, _pView ) 
   		local pItemData = nil
   		if self.nCurrTab == e_wolrdbattle_tab.hero then
   			pItemData = self.tHeroState[_index]
   		elseif self.nCurrTab == e_wolrdbattle_tab.collect_hero then
   			pItemData = self.tCollectHeroState[_index]
   		elseif self.nCurrTab == e_wolrdbattle_tab.hit then
   			pItemData = self.tMyCityWarMsgs[_index]
   		elseif self.nCurrTab == e_wolrdbattle_tab.country_war then
   			pItemData = self.tCountryWarMsgs[_index]
   		elseif self.nCurrTab == e_wolrdbattle_tab.support then
   			pItemData = self.tHelpDataList[_index]
   		end

        local pTempView = _pView
        if pTempView == nil then
        	pTempView = MUI.MLayer.new()
        	pTempView:setLayoutSize(540, 108)
    	end
    	local pWBDetail = pTempView.pWBDetail
    	local pWBDetailHit = pTempView.pWBDetailHit
    	if self.nCurrTab == e_wolrdbattle_tab.hit then --来袭
    		if pWBDetail then
    			pWBDetail:setVisible(false)
    		end
    		if pWBDetailHit then
    			pWBDetailHit:setVisible(true)
    		else
    			pWBDetailHit = ItemWorldBattleDetailHit.new()
    			pTempView.pWBDetailHit = pWBDetailHit
    			pTempView:addView(pWBDetailHit)
    		end
    		pWBDetailHit:setData(pItemData, self.nCurrTab, _index)
    	else
    		if pWBDetailHit then
    			pWBDetailHit:setVisible(false)
    		end
    		if pWBDetail then
    			pWBDetail:setVisible(true)
    		else
    			pWBDetail = ItemWorldBattleDetail.new()
    			pTempView.pWBDetail = pWBDetail
    			pTempView:addView(pWBDetail)
    		end
    		pWBDetail:setData(pItemData, self.nCurrTab, _index)
    	end
        return pTempView
	end)
	self.pListView:reload()
end


function WorldBattleDetail:onBackClicked( )
	sendMsg(ghd_show_world_battle_detail)
end

function WorldBattleDetail:onSupportUsed( sMsgName, pMsgObj )
	local sWarId = pMsgObj
	if sWarId and  type(sWarId) ~= "table" then
		--更新支援次数
		for i=1,#self.tMyCityWarMsgs do
			if self.tMyCityWarMsgs[i].nType == e_type_task.cityWar then
				if self.tMyCityWarMsgs[i].sWarId == sWarId then
					self.tMyCityWarMsgs[i].nSupport = self.tMyCityWarMsgs[i].nSupport + 1
					break
				end
			elseif self.tMyCityWarMsgs[i].nType == e_type_task.ghostdom then

				self.tMyCityWarMsgs[i].nSupport = self.tMyCityWarMsgs[i].nSupport + 1
			end
		end
		--更新显示
		if self.nCurrTab == e_wolrdbattle_tab.hit then
			self:updateHit()
		end
	elseif pMsgObj.gid then
		--更新支援次数
		for i=1,#self.tMyCityWarMsgs do
			if self.tMyCityWarMsgs[i].nType == e_type_task.ghostdom and self.tMyCityWarMsgs[i].sGid == pMsgObj.gid then

				self.tMyCityWarMsgs[i].nSupport = self.tMyCityWarMsgs[i].nSupport + 1
			end
		end
		--更新显示
		if self.nCurrTab == e_wolrdbattle_tab.hit then
			self:updateHit()
		end
	end

end

return WorldBattleDetail


