----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 战斗力提升对话框 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemFCPromote = class("ItemFCPromote", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemFCPromote:ctor(  )
	--解析文件
	parseView("item_fc_promote", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemFCPromote:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	pView:setViewTouched(true)
	pView:setIsPressedNeedScale(false)
	pView:onMViewClicked(handler(self, self.onBgClicked))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemFCPromote", handler(self, self.onItemFCPromoteDestroy))
end

-- 析构方法
function ItemFCPromote:onItemFCPromoteDestroy(  )
    self:onPause()
end

function ItemFCPromote:regMsgs(  )
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.updateViews))
	regMsg(self, gud_equip_refine_success_msg, handler(self, self.updateViews))
	regMsg(self, gud_refresh_tnoly_lists_msg, handler(self, self.updateViews))
	regMsg(self, gud_refresh_weaponInfo, handler(self, self.updateViews))
end

function ItemFCPromote:unregMsgs(  )
	unregMsg(self, gud_refresh_hero)
	unregMsg(self, gud_equip_hero_equip_change)
	unregMsg(self, gud_equip_refine_success_msg)
	unregMsg(self, gud_refresh_tnoly_lists_msg)
	unregMsg(self, gud_refresh_weaponInfo)
end

function ItemFCPromote:onResume(  )
	self:regMsgs()
end

function ItemFCPromote:onPause(  )
	self:unregMsgs()
end

function ItemFCPromote:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtTitle = self:findViewByName("txt_title")
	setTextCCColor(self.pTxtTitle, _cc.yellow)
	self.pTxtPromote = self:findViewByName("txt_promote")
	local pLayBar = self:findViewByName("lay_bar")
	self.pBar = MCommonProgressBar.new({bar = "v1_bar_green_1.png", barWidth = 176, barHeight = 14})
	pLayBar:addView(self.pBar)
	centerInView(pLayBar, self.pBar)

	local pLayBtnGo = self:findViewByName("lay_btn_go")
	local pBtnGo = getCommonButtonOfContainer(pLayBtnGo, TypeCommonBtn.M_BLUE, getConvertedStr(3, 10162))
	pBtnGo:onCommonBtnClicked(handler(self, self.onGoClicked))
	self.pBtnGo = pBtnGo
end

function ItemFCPromote:updateViews(  )
	if not self.tCombatUpData then
		return
	end

	if not self.pImgIcon then
	   	local pImgBorderIcon = MUI.MImage.new(getIconBgByQuality(3))
	   	if pImgBorderIcon then
	   		self.pLayIcon:addView(pImgBorderIcon)
	   		centerInView(self.pLayIcon, pImgBorderIcon)
	   	end
	   	self.pImgIcon = MUI.MImage.new(self.tCombatUpData.sIcon)
	   	self.pLayIcon:addView(self.pImgIcon)
	   	centerInView(self.pLayIcon, self.pImgIcon)
	else
		self.pImgIcon:setCurrentImage(self.tCombatUpData.sIcon)
	end

	self.pTxtTitle:setString(self.tCombatUpData.name)

	local bIsOpen = self:getIsOpen() --开放
	local fPercent = 0

	if bIsOpen then
		fPercent = self:getPercent() --进度条比率
		if fPercent >= 1 then
			fPercent = 1
			self.pTxtPromote:setString(self.tCombatUpData.fulltips)
			setTextCCColor(self.pTxtPromote, _cc.green)
			-- self.pBtnGo:setBtnEnable(false)
			self.pBtnGo:updateBtnText(getConvertedStr(3, 10307))
			self.pBar:setBarImage("ui/bar/v1_bar_yellow_2.png")
		else
			self.pTxtPromote:setString(self.tCombatUpData.tips)
			setTextCCColor(self.pTxtPromote, _cc.white)
			-- self.pBtnGo:setBtnEnable(true)
			self.pBtnGo:updateBtnText(getConvertedStr(3, 10162))
			self.pBar:setBarImage("ui/bar/v1_bar_green_1.png")
		end
	else
		self.pTxtPromote:setString(getConvertedStr(3, 10306))
		setTextCCColor(self.pTxtPromote, _cc.white)
		-- self.pBtnGo:setBtnEnable(false)
		self.pBtnGo:updateBtnText(getConvertedStr(3, 10162))
		self.pBar:setBarImage("ui/bar/v1_bar_green_1.png")
	end
	self.pBar:setPercent(fPercent * 100)
	self.pBar:setProgressBarText(tostring(math.floor(fPercent * 100)) .. "%")
end

--tCombatUpData combatup表数据
function ItemFCPromote:setData( tCombatUpData )
	self.tCombatUpData = tCombatUpData
	self:updateViews()
end

--获取是否开启
--[[
1.武将等级
2.资质洗练
4.装备穿戴
5.装备洗练
6.科技等级

]]--
function ItemFCPromote:getIsOpen( )
	if not self.tCombatUpData then
		return
	end
	local nId = self.tCombatUpData.id
	if nId == 1 or nId == 2 or nId == 4 then  --武将等级
		local bIsOpen = getIsReachOpenCon(1,false)
		if not bIsOpen then
			return false 

		else
			return true
		end
	elseif nId == 5 then --装备洗炼
		local pBuildData = Player:getBuildData():getBuildById(e_build_ids.ylp)
		if pBuildData then
			return true
		else
			return false 
		end
	elseif nId == 6 then --大学院，科技
		local pBuildData = Player:getBuildData():getBuildById(e_build_ids.tnoly)
		if pBuildData then
			return true
		else
			return false 
		end
	elseif nId == 7 then --神兵开放等级
		local nLv = getWeaponInitDataByKey("openLevel")
		if nLv then
			return Player:getPlayerInfo().nLv >= nLv
		end
	end
	
end

--获取比值上限
function ItemFCPromote:getPercent( )
	if not self.tCombatUpData then
		return
	end
	local nId = self.tCombatUpData.id
	if nId == 1 then--每个上阵武将到达主公等级
		local tHeroList = Player:getHeroInfo():getOnlineHeroList()
		local nCount = 0
		for i=1,#tHeroList do
			nCount = nCount + tHeroList[i].nLv
		end
		local nTotal = Player:getPlayerInfo().nLv * 4
		if nTotal > 0 then
			return nCount/nTotal
		end
	elseif nId == 2 then --每个上阵武将到达当前品质最高资质
		local tHeroList = Player:getHeroInfo():getOnlineHeroList()
		local nCount = 0
		local nTotal = 0
		for i=1,#tHeroList do
			nCount = nCount + tHeroList[i]:getNowTotalTalent()
			nTotal = nTotal + tHeroList[i].nTalentLimitSum
		end
		if nTotal > 0 then
			return nCount/nTotal
		end
	elseif nId == 4 then --上阵武将装备品质到达最高品质
		local nQualityMax = getEquipQualityMax()
		local nEquipNum = 6
		local tHeroList = Player:getHeroInfo():getOnlineHeroList()
		local nTotal = 144
		local nCount = 0
		local tEquipVos = Player:getEquipData():getEquipVos()
		local tHeroIds = {}
		for i=1,#tHeroList do
			tHeroIds[tHeroList[i].nId] = true
		end
		for k,v in pairs(tEquipVos) do
			if tHeroIds[v.nHeroId] then
				local tEquipData = v:getConfigData()
				if tEquipData then
					nCount = nCount + tEquipData.nQuality
				end
			end
		end
		if nTotal > 0 then
			return nCount/nTotal
		end
	elseif nId == 5 then --装备洗炼等级是否到达该装备洗炼等级上限
		local tHeroList = Player:getHeroInfo():getOnlineHeroList()
		local tEquipVos = Player:getEquipData():getEquipVos()
		local tHeroIds = {}
		for i=1,#tHeroList do
			tHeroIds[tHeroList[i].nId] = true
		end
		local nTotal = 144
		local nCount = 0
		for k,v in pairs(tEquipVos) do
			if tHeroIds[v.nHeroId] then
				nCount = nCount + v:getCurrAttrLvTotal()
			end
		end
		if nTotal > 0 then
			return nCount/nTotal
		end
	elseif nId == 6 then --3007，3008，3015，3009，3010，3016，3020科技等级是否到达上限
		local tScienceIds = {3007, 3008, 3015, 3009, 3010, 3016, 3020}
		local nTotal = 0
		local nCount = 0
		for i=1,#tScienceIds do
			local tTnoly = Player:getTnolyData():getTnolyByIdFromAll(tScienceIds[i])
			if tTnoly then
				nCount = nCount + tTnoly.nLv
				nTotal = nTotal + tTnoly.nMaxLv
			end
		end
		if nTotal > 0 then
			return nCount/nTotal
		end
	elseif nId == 7 then --每个神兵等级到达主公等级
		local tWeaponList = Player:getWeaponInfo():getAllWeaponDatas()
		local nCount = 0
		for k,v in pairs(tWeaponList) do
			nCount = nCount + v.nWeaponLv
		end
		local nTotal = Player:getPlayerInfo().nLv * 6
		if nTotal > 0 then
			return nCount/nTotal
		end
	end

	return 0
end


function ItemFCPromote:onGoClicked( pView )
	if not self.tCombatUpData then
		return
	end
	--指定几个点击前往不读表，前往不同的界面
	local nId = self.tCombatUpData.id
	if nId == 1 then--每个上阵武将到达主公等级
		local bIsOpen = getIsReachOpenCon(1)
		if not bIsOpen then
			return
		end
		local tHeroData = nil
		local tHeroList = Player:getHeroInfo():getOnlineHeroList()
		for i=1,#tHeroList do
			if tHeroList[i].nLv < Player:getPlayerInfo().nLv then
				tHeroData = tHeroList[i]
			end
		end
		if not tHeroData then
			tHeroData = tHeroList[1]
		end
		if tHeroData then
			local DlgHeroUpdate = require("app.layer.hero.DlgHeroUpdate")
			local pDlg, bNew = getDlgByType(e_dlg_index.heroupdate)
			if not pDlg then
				pDlg = DlgHeroUpdate.new(tHeroData)
			end
			pDlg:showDlg(bNew)
		end
		return
	elseif nId == 4 then--上阵武将装备品质到达最高品质
		local nQualityMax = getEquipQualityMax()
		local nEquipNum = 6
		local tHeroList = Player:getHeroInfo():getOnlineHeroList() 
		local nCount = 0
		local tEquipVos = Player:getEquipData():getEquipVos()
		local tHeroIds = {}
		for i=1,#tHeroList do
			tHeroIds[tHeroList[i].nId] = true
		end
		local tHeroData = nil
		for k,v in pairs(tEquipVos) do
			if tHeroIds[v.nHeroId] then
				local tEquipData = v:getConfigData()
				if tEquipData then
					if tEquipData.nQuality < nQualityMax then
						tHeroData = Player:getHeroInfo():getHero(v.nHeroId)
						break
					end
				end
			end
		end
		if not tHeroData then
			tHeroData = tHeroList[1]
		end
		if tHeroData then
			local tObject = {} 
			tObject.tData = tHeroData --当前武将数据
			tObject.nType = e_dlg_index.heromain --dlg类型
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
		return
	end

	--发送消息打开dlg
	local tObject = {
	    nType = self.tCombatUpData.jump, --dlg类型
	}
	if tObject.nType == e_dlg_index.smithshop then
		tObject.nFuncIdx = self.tCombatUpData.jumptab
	end
	print("nTyp---------------",tObject.nType)
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function ItemFCPromote:onBgClicked( pView )
	if not self.tCombatUpData then
		return
	end
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.fcpromoteclicktip, --dlg类型
	    nCombatUpId = self.tCombatUpData.id,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

-- function ItemFCPromote:onHeroRefresh(  )
-- 	if not self.tCombatUpData then
-- 		return
-- 	end

-- 	local nId = self.tCombatUpData.id
-- 	if nId == 1 or nId == 2 then
-- 		self:updateViews()
-- 	end
-- end

-- function ItemFCPromote:onHeroEquipChange(  )
-- 	if not self.tCombatUpData then
-- 		return
-- 	end

-- 	local nId = self.tCombatUpData.id
-- 	if nId == 4  then
-- 		self:updateViews()
-- 	end
-- end

-- function ItemFCPromote:onEquipRefineSuccess(  )
-- 	if not self.tCombatUpData then
-- 		return
-- 	end

-- 	local nId = self.tCombatUpData.id
-- 	if nId == 5  then
-- 		self:updateViews()
-- 	end
-- end

-- function ItemFCPromote:onTnolyListRefresh(  )
-- 	if not self.tCombatUpData then
-- 		return
-- 	end

-- 	local nId = self.tCombatUpData.id
-- 	if nId == 6  then
-- 		self:updateViews()
-- 	end
-- end

-- function ItemFCPromote:onWeaponRefresh(  )
-- 	if not self.tCombatUpData then
-- 		return
-- 	end

-- 	local nId = self.tCombatUpData.id
-- 	if nId == 7  then
-- 		self:updateViews()
-- 	end
-- end

return ItemFCPromote


