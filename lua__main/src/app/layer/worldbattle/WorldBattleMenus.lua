----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-15 18:38:12
-- Description: 世军出征菜单
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local WorldBattleMenus = class("WorldBattleMenus", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nTabIndex 1,武将，2，来袭，3，国战，4，协防
function WorldBattleMenus:ctor(  )
	self:myInit()
end

--解析界面回调
function WorldBattleMenus:myInit(  )
	self.bIsForceVisible = true
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldBattleMenus", handler(self, self.onWorldBattleMenusDestroy))
end

-- 析构方法
function WorldBattleMenus:onWorldBattleMenusDestroy(  )
    self:onPause()
end

function WorldBattleMenus:regMsgs(  )
	regMsg(self, gud_my_country_war_list_change, handler(self, self.updateViews)) --国战数量
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews)) --出征数量
	regMsg(self, gud_refresh_wall, handler(self, self.updateViews)) --已支援数量
	regMsg(self, gud_friend_army_list_change, handler(self, self.updateViews)) --友军驻防
	regMsg(self, gud_my_city_war_list_change, handler(self, self.updateViews)) --我的城战
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.updateViews)) --我的城池坐标发生改变
end

function WorldBattleMenus:unregMsgs(  )
	unregMsg(self, gud_my_country_war_list_change)
	unregMsg(self, gud_world_task_change_msg)
	unregMsg(self, gud_refresh_wall)
	unregMsg(self, gud_friend_army_list_change)
	unregMsg(self, gud_my_city_war_list_change)
	unregMsg(self, gud_world_my_city_pos_change_msg)
end

function WorldBattleMenus:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function WorldBattleMenus:onPause(  )
	self:unregMsgs()
end

function WorldBattleMenus:setupViews(  )
	--刷新显示列表
	local ItemWorldBattleMenu = require("app.layer.worldbattle.ItemWorldBattleMenu")
	self.pMenus = {}
	local nX = 13
	local nY = 20
	for i=1,1 do
		local pMenu = ItemWorldBattleMenu.new()
		pMenu:setPosition(nX, nY)
		nY = nY + pMenu:getContentSize().height + 20
		self:addView(pMenu)
		table.insert(self.pMenus, pMenu)
	end

	--这里创建一个国家互助按钮
	local ItemHelpMenu = require("app.layer.newcountry.newcountryhelp.ItemHelpMenu")
	self.pHelpMenu = ItemHelpMenu.new()
	self:addView(self.pHelpMenu)
end

--获取指定任务
function WorldBattleMenus:getTargetInTask( tTaskMsgLineUp )
	local tStayTask = nil
	local tBackTask = nil
	local tGoTask = nil
	--抵达时间
	--停留时间（城战，国战，采集，驻防)	
	--返回时间
	local nGoCd = nil
	local nStayCd = nil
	local nBackCd = nil
	for k,v in pairs(tTaskMsgLineUp) do
		if v.nState == e_type_task_state.go then
			if nGoCd then
				if v:getCd() < nGoCd  then
					nGoCd = v:getCd()
					tGoTask = v
				end
			else
				nGoCd = v:getCd()
				tGoTask = v
			end
		elseif v.nState == e_type_task_state.waitbattle or v.nState == e_type_task_state.collection or v.nState == e_type_task_state.garrison then
			if nStayCd then
				if v:getCd() < nStayCd  then
					nStayCd = v:getCd()
					tStayTask = v
				end
			else
				nStayCd = v:getCd()
				tStayTask = v
			end
		elseif v.nState == e_type_task_state.back then
			if nBackCd then
				if v:getCd() < nBackCd  then
					nBackCd = v:getCd()
					tBackTask = v
				end
			else
				nBackCd = v:getCd()
				tBackTask = v
			end
		end
	end
	return tGoTask or tStayTask or tBackTask
end

function WorldBattleMenus:updateViews(  )
	if not self.bIsForceVisible then
		return
	end
	--显示出征数量
	--出征数量
	--武将→来袭→国战→驻防→采集只显示一个排序(但是红点是汇总的)
	local tMenus = {}

	--所有任务
	local tTaskMsgs = Player:getWorldData():getTaskMsgs()
	--获取上阵相关的任务
	local tTaskMsgLineUp = {}
	for k,v in pairs(tTaskMsgs) do
		if v:getArmyTeam() == e_hero_team_type.normal then
			tTaskMsgLineUp[k] = v
		end
	end
	--出征队列数量
	local tTaskMsg = self:getTargetInTask(tTaskMsgLineUp)
	if tTaskMsg then
		table.insert(tMenus, {nTabIndex = e_wolrdbattle_tab.hero, nRedNum = table.nums(tTaskMsgLineUp), tTaskMsg = tTaskMsg})
	end
	
	--我的城战信息
	local tMyCityWarMsgs = Player:getWorldData():getMyCityWarMsgs()
	if tMyCityWarMsgs[1] then
		if #tMenus == 0 then
			table.insert(tMenus, {nTabIndex = e_wolrdbattle_tab.hit, nRedNum = table.nums(tMyCityWarMsgs), tCityWarMsg = tMyCityWarMsgs[1]})
		else
			tMenus[1].nRedNum = tMenus[1].nRedNum + table.nums(tMyCityWarMsgs)
		end
	end

	--冥界入侵信息(来袭)
	local tGhostWarNotices = Player:getWorldData():getGhostWarVo()
	if tGhostWarNotices and tGhostWarNotices:getCd() > 0 then
		local bHasCityWar = false
		--刷新列表显示
		for i=1,#tMenus do
			if tMenus[i].nTabIndex == e_wolrdbattle_tab.hit then
					tMenus[i].nRedNum = tMenus[i].nRedNum + 1
					if tGhostWarNotices:getCd() < tMenus[i].tCityWarMsg:getCd() then
						tMenus[i].tCityWarMsg = tGhostWarNotices
					end
					bHasCityWar = true
			end
		end
		if not bHasCityWar then
			if #tMenus == 0 then
				table.insert(tMenus, {nTabIndex = e_wolrdbattle_tab.hit, nRedNum = 1 , tCityWarMsg = tGhostWarNotices})
			else
				tMenus[1].nRedNum = tMenus[1].nRedNum + 1
			end
		end		
	end

	--国战
	local tCountryWarMsgs = {}
	local nNeedLv = getWorldInitData("warOpen")
	if Player:getPlayerInfo().nLv >= nNeedLv then
		tCountryWarMsgs = Player:getWorldData():getMyCountryWarsList()
	end
	if tCountryWarMsgs[1] then
		if #tMenus == 0 then
			table.insert(tMenus, {nTabIndex = e_wolrdbattle_tab.country_war, nRedNum = table.nums(tCountryWarMsgs), tCountryWarMsg = tCountryWarMsgs[1]})
		else
			tMenus[1].nRedNum = tMenus[1].nRedNum + table.nums(tCountryWarMsgs)
		end
	end

	--来支援我的（包括在路上的)
	local tComingHelpVOs = Player:getWorldData():getFriendArmys()
	local tHelpMsgs = Player:getWorldData():getHelpMsgs()
	local tHelpDataList = {}
	for i=1,#tComingHelpVOs do
		table.insert(tHelpDataList, {tComingHelpVO = tComingHelpVOs[i]})
	end
	for i=1,#tHelpMsgs do
		table.insert(tHelpDataList, {tHelpMsg = tHelpMsgs[i]})
	end
	if #tHelpDataList > 0 then
		if #tMenus == 0 then
			table.insert(tMenus, {nTabIndex = e_wolrdbattle_tab.support, nRedNum = #tHelpDataList, tHelpData = tHelpDataList[1]})
		else
			tMenus[1].nRedNum = tMenus[1].nRedNum + #tHelpDataList
		end
	end

	--获取采集相关的任务
	local tTaskMsgCollect = {}
	for k,v in pairs(tTaskMsgs) do
		if v:getArmyTeam() == e_hero_team_type.collect then
			tTaskMsgCollect[k] = v
		end
	end
	--采集队列数量
	local tTaskMsg = self:getTargetInTask(tTaskMsgCollect)
	if tTaskMsg then
		if #tMenus == 0 then
			table.insert(tMenus, {nTabIndex = e_wolrdbattle_tab.collect_hero, nRedNum = table.nums(tTaskMsgCollect), tTaskMsg = tTaskMsg})
		else
			tMenus[1].nRedNum = tMenus[1].nRedNum + table.nums(tTaskMsgCollect)
		end
	end

	local nY = 20
	--刷新列表显示
	for i=1,#self.pMenus do
		local pMenu = self.pMenus[i]
		local tData = tMenus[i]
		if tData then
			pMenu:setData(tData)
			pMenu:setVisible(true)
			nY = nY + pMenu:getContentSize().height + 20
		else
			pMenu:setData(nil)
			pMenu:setVisible(false)
		end
	end

	if self.pHelpMenu then
		self.pHelpMenu:setPosition(28, nY)
	end
end

function WorldBattleMenus:setVisibleEx( bIsShow )
	self.bIsForceVisible = bIsShow
	if bIsShow then
		self:setVisible(true)
		self:updateViews()
	else
		self:setVisible(false)
	end
end

return WorldBattleMenus


