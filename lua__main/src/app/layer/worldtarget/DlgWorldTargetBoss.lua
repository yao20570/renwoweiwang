----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-11 09:33:36
-- Description: 世界目标 世界Boss
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemWorldTargetBoss = require("app.layer.worldtarget.ItemWorldTargetBoss")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgWorldTargetBoss = class("DlgWorldTargetBoss", function()
	return DlgCommon.new(e_dlg_index.worldtargetboss, 660-130, 130)
end)

function DlgWorldTargetBoss:ctor(  )
	parseView("dlg_world_target_boss", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldTargetBoss:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, true) --加入内容层
	self:setTitle(getConvertedStr(3, 10384))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldTargetBoss",handler(self, self.onDlgWorldTargetBossDestroy))
end

-- 析构方法
function DlgWorldTargetBoss:onDlgWorldTargetBossDestroy(  )
    self:onPause()
end

function DlgWorldTargetBoss:regMsgs(  )
	regMsg(self, gud_world_target_boss_refresh, handler(self, self.updateViews))
end

function DlgWorldTargetBoss:unregMsgs(  )
	unregMsg(self, gud_world_target_boss_refresh)
end

function DlgWorldTargetBoss:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgWorldTargetBoss:onPause(  )
	self:unregMsgs()
end

function DlgWorldTargetBoss:setupViews(  )
	self.pImgTitle = self:findViewByName("img_title")

	local pTxtBarTitle = self:findViewByName("txt_bar_title")
	pTxtBarTitle:setString(getConvertedStr(3, 10391))

	self.pLayBossBar = self:findViewByName("lay_boss_bar")
	local pSize = self.pLayBossBar:getContentSize()
	self.pBossBar = MCommonProgressBar.new({bar = "v1_bar_yellow_c5.png", barWidth = pSize.width, barHeight = pSize.height})
	self.pBossBar:setPosition(pSize.width/2, pSize.height/2)
	self.pLayBossBar:addView(self.pBossBar)

	local pLayGoods = self:findViewByName("lay_content")
	local nBeginX = 0
	self.pItemBossList = {}
	for i=1,4 do
		local pItemWorldTargetBoss = ItemWorldTargetBoss.new()
		table.insert(self.pItemBossList, pItemWorldTargetBoss)
		pItemWorldTargetBoss:setPositionX(nBeginX)
		pLayGoods:addView(pItemWorldTargetBoss)
		nBeginX = nBeginX + pItemWorldTargetBoss:getContentSize().width
	end

	local pLayBtn = self:findViewByName("lay_btn")
	self.pBottomBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10393))
	self.pBottomBtn:onCommonBtnClicked(handler(self, self.onBottomClicked))

	self.pTxtTip = self:findViewByName("txt_tip")
	self.pTxtTip:setString(getTipsByIndex(10042))

	--布局中默认的按钮隐藏
	local pBtn = self:getOnlyConfirmButton()
	pBtn:setVisible(false)
	if self.pLayContent then
		self.pLayContent:setZOrder(10)
	end
end

function DlgWorldTargetBoss:updateViews(  )
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end

	--介绍
	-- self.pTxtTip:setString(tWorldTargetData.info)

	if tWorldTargetData.nTargetType == e_type_world_target.worldBoss then
		--打董卓显示新的标题
		if tWorldTargetData.id == 9 then
			self.pImgTitle:setCurrentImage("#v1_fonts_jbsjbkqafg.png")
		end
		
		--显示Boss
		local tWorldBossVo = Player:getWorldData():getWorldBossVo()
		if tWorldBossVo then
			--武将
			self.tBossList = tWorldBossVo:getBossList()
			for i=1,#self.pItemBossList do
				local pItemWorldTargetBoss = self.pItemBossList[i]
				local tBossData = self.tBossList[i]
				if tBossData then
					pItemWorldTargetBoss:setData(tBossData)
					pItemWorldTargetBoss:setVisible(true)
				else
					pItemWorldTargetBoss:setVisible(false)
				end
			end

			--进度条
			local nCurrTroops = tWorldBossVo:getCurrTroops()
			local nTotalTroops = tWorldBossVo:getTotalTroops()
			if nTotalTroops == 0 then
				self.pBossBar:setPercent(100)
			else
				self.pBossBar:setPercent(nCurrTroops/nTotalTroops * 100)
			end
			self.pBossBar:setProgressBarText(string.format("%s/%s",nCurrTroops,nTotalTroops))

			--今天是否打过世界Boss
			if Player:getWorldData():getIsAttackedBoss( ) then
				self.pBottomBtn:updateBtnText(getConvertedStr(3, 10394))
				self.pBottomBtn:setBtnEnable(false)
			else
				self.pBottomBtn:updateBtnText(getConvertedStr(3, 10393))
				self.pBottomBtn:setBtnEnable(true)
			end
		end
	end
end

function DlgWorldTargetBoss:onBottomClicked( pView )
	local tWorldBossVo = Player:getWorldData():getWorldBossVo()
	if tWorldBossVo then
		local tObject = {}
		tObject.nType = e_dlg_index.armylayer --dlg类型
		tObject.nArmyType = en_army_type.worldboss -- 部队类型
		tObject.sTitle = getNpcGropListDataById(tWorldBossVo.nNpcId).name -- 部队界面标题
		tObject.tMyArmy = Player:getHeroInfo():getOnlineHeroList(true) --我方部队

		local tEnemyNew = {}
		local tEnemy = getNpcGropById(tWorldBossVo.nNpcId) --地方部队
		local tBossList = tWorldBossVo:getBossList()
		for i=1,#tEnemy do
			for j=1,#tBossList do
				if tEnemy[i].nId == tBossList[j].nNpcId then
					local bIsKilled = tBossList[j]:getIsKilled()
					if not bIsKilled then
						tEnemy[i].nTroops = tBossList[j]:getCurrTroops()
						table.insert(tEnemyNew, tEnemy[i])
					end
					break
				end
			end
		end
		tObject.tEnemy = tEnemyNew --地方部队
		tObject.nEnemyArmyFight = getNpcGropListDataById(tWorldBossVo.nNpcId).score or 0 --敌方战力
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
	closeDlgByType(e_dlg_index.worldtargetboss, false)
end

return DlgWorldTargetBoss