----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-15 18:38:12
-- Description: 出征菜单
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemWorldBattleMenu = class("ItemWorldBattleMenu", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWorldBattleMenu:ctor(  )
	--解析文件
	parseView("item_world_battle_menu", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWorldBattleMenu:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWorldBattleMenu", handler(self, self.onItemWorldBattleMenuDestroy))
end

-- 析构方法
function ItemWorldBattleMenu:onItemWorldBattleMenuDestroy(  )
    self:onPause()
    unregUpdateControl(self)
end

function ItemWorldBattleMenu:regMsgs(  )
end

function ItemWorldBattleMenu:unregMsgs(  )
end

function ItemWorldBattleMenu:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function ItemWorldBattleMenu:onPause(  )
	self:unregMsgs()
end

function ItemWorldBattleMenu:setupViews(  )
	self.pLayView = self:findViewByName("view")
	self.pLayView:setViewTouched(true)
	self.pLayView:setIsPressedNeedScale(false)
	self.pLayView:onMViewClicked(handler(self, self.onEnterClicked))

	self.pLayRed = self:findViewByName("lay_red")
	self.pImgIcon = self:findViewByName("img_icon")
	self.pTxtCd = self:findViewByName("txt_cd")
end

function ItemWorldBattleMenu:updateViews(  )
	--1,武将，2，来袭，3，国战，4，协防
	if not self.tData then
		return
	end
	local sImgList = {
		[e_wolrdbattle_tab.hero] = "#v2_founts_wujiang.png",
		[e_wolrdbattle_tab.collect_hero] = "#v2_founts_caiji.png",
		[e_wolrdbattle_tab.hit] = "#v2_founts_laixi.png",
		[e_wolrdbattle_tab.country_war] = "#v2_founts_guozhan.png",
		[e_wolrdbattle_tab.support] = "#v2_founts_zhufang.png",
	}
	local nTabIndex = self.tData.nTabIndex
	local sImg = sImgList[nTabIndex]
	if sImg then
		self.pImgIcon:setCurrentImage(sImg)
	end
	--红点
	showRedTips(self.pLayRed, 1, self.tData.nRedNum)
	--更新cd
	self:updateCd()
end

function ItemWorldBattleMenu:setData( tData )
	self.tData = tData
	if self.tData == nil then
		unregUpdateControl(self)
	else
		regUpdateControl(self, handler(self, self.updateCd))
		self:updateViews()
	end
end

function ItemWorldBattleMenu:updateCd( )
	if not self.tData then
		unregUpdateControl(self)
		return
	end
	local nCd = 0
	local sTargetName = nil
	local nTabIndex = self.tData.nTabIndex
	if nTabIndex == e_wolrdbattle_tab.hero or nTabIndex == e_wolrdbattle_tab.collect_hero then
		local tTaskMsg = self.tData.tTaskMsg
		if tTaskMsg then
			nCd = tTaskMsg:getCd()
			--TLBoss特殊处理,皇城战特效处理
			if tTaskMsg.nType == e_type_task.tlboss and tTaskMsg.nState == e_type_task_state.waitbattle then
				sTargetName =  tTaskMsg.sTargetName
			elseif tTaskMsg.nType == e_type_task.imperwar and tTaskMsg.nState == e_type_task_state.waitbattle then
				sTargetName =  tTaskMsg.sTargetName or tTaskMsg:getBoName()
			end
		end
	elseif nTabIndex == e_wolrdbattle_tab.hit then
		local tCityWarMsg = self.tData.tCityWarMsg
		if tCityWarMsg then
			nCd = tCityWarMsg:getCd()
		end
	elseif nTabIndex == e_wolrdbattle_tab.country_war then
		local tCountryWarMsg = self.tData.tCountryWarMsg
		if tCountryWarMsg then
			nCd = tCountryWarMsg:getCd()
		end
	elseif nTabIndex == e_wolrdbattle_tab.support then
		local tHelpData = self.tData.tHelpData
		if tHelpData.tComingHelpVO then
			nCd = tHelpData.tComingHelpVO:getCd()
		end
		if tHelpData.tHelpMsg then
			nCd = tHelpData.tHelpMsg:getCd()
		end
	end
	if sTargetName then
		self.pTxtCd:setString(sTargetName)
		unregUpdateControl(self)
	else
		if nCd > 0 then
			self.pTxtCd:setString(formatTimeToStr(nCd,nil,nil,true))
		else
			if nTabIndex == e_wolrdbattle_tab.hit then    --冥界的入侵结束后 没推送 暂时这样处理
				sendMsg(gud_my_city_war_list_change)
			end
			unregUpdateControl(self)
		end
	end
end

function ItemWorldBattleMenu:onEnterClicked( pView )
	if not self.tData then
		return
	end
	local nTabIndex = self.tData.nTabIndex
	sendMsg(ghd_show_world_battle_detail, nTabIndex)
end

return ItemWorldBattleMenu


