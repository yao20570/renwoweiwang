----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 20:10:00
-- Description: 出征武将界面
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local ItemBattleHero = require("app.layer.world.ItemBattleHero")
local DragChangeListView = require("app.layer.world.DragChangeListView")
local nImperialCityMapId = 1013 --皇城mapId
local DlgBattleHero = class("DlgBattleHero", function()
	return DlgBase.new(e_dlg_index.battlehero)
end)

function DlgBattleHero:ctor(  )
	parseView("dlg_battle_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgBattleHero:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10046))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBattleHero",handler(self, self.onDlgBattleHeroDestroy))
end

-- 析构方法
function DlgBattleHero:onDlgBattleHeroDestroy(  )
    self:onPause()
end

function DlgBattleHero:regMsgs(  )
	regMsg(self, gud_dlg_battle_hero_selected_msg, handler(self, self.updateViews))
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateHeroStates))
	regMsg(self, gud_refresh_hero, handler(self, self.updateHeros))
	regMsg(self, gud_buff_update_msg, handler(self, self.updateBuffEffect))
end

function DlgBattleHero:unregMsgs(  )
	unregMsg(self, gud_dlg_battle_hero_selected_msg)
	unregMsg(self, gud_world_task_change_msg)
	unregMsg(self, gud_refresh_hero)
	unregMsg(self, gud_buff_update_msg)
end

function DlgBattleHero:onResume(  )
	self:regMsgs()
end

function DlgBattleHero:onPause(  )
	self:unregMsgs()
end

function DlgBattleHero:setupViews(  )
	local pLayBannerBg = self:findViewByName("lay_banner_bg")
	local pBanner = setMBannerImage(pLayBannerBg, TypeBannerUsed.czjm)
	pBanner:setMBannerOpacity(0.2*255)

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")--名字与等级合并
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	setTextCCColor(self.pTxtMoveTime, _cc.green)
	self.pImgFlag = self:findViewByName("img_flag")

	local pLayBanner = self:findViewByName("lay_banner")
	local pLayBannerTip = self:findViewByName("lay_banner_tip")
	pLayBannerTip:setString(getConvertedStr(3, 10557))
	local pLayBannerTip2 = self:findViewByName("txt_banner_tip2")
	pLayBannerTip2:setString(getConvertedStr(3, 10431))
	local pLayBannerTip3 = self:findViewByName("txt_banner_tip3")
	-- pLayBannerTip3:setString(getConvertedStr(3, 10131))
	pLayBannerTip3:setString(getTextColorByConfigure(getTipsByIndex(20034)))
	-- setTextCCColor(pLayBannerTip3, _cc.yellow)

	--是否全选开关
	local pLaySwitch = self:findViewByName("lay_switch")
	local bIsAuto = Player:getWorldData():getIsAllBattleAuto()
	local nState = 0
	if bIsAuto then
		nState = 1
	else
		nState = 0
	end
	self.pOvalSw = getOvalSwOfContainer(pLaySwitch, handler(self, self.onOvalSw), nState)


	local tConfigs = {
		{x = 20, w = 600,h = 130},
		{x = 20, w = 600,h = 130},
		{x = 20, w = 600,h = 130},
		{x = 20, w = 600,h = 130},
	}

	local pHero1 = ItemBattleHero.new(1)
	local pHero2 = ItemBattleHero.new(2)
	local pHero3 = ItemBattleHero.new(3)
	local pHero4 = ItemBattleHero.new(4)
	self.pHeroList = {
		pHero1,
		pHero2,
		pHero3,
		pHero4,
	}

	--拖动层实验
	local pLayContent = self:findViewByName("lay_content")
	local pSize = pLayContent:getContentSize()
	local pDragChangeListView = DragChangeListView.new(pSize, 2)
	self.pDragChangeListView = pDragChangeListView
	pLayContent:addView(pDragChangeListView)
	local fY = pSize.height - 10
	for i=1,#self.pHeroList do
		local tConf = tConfigs[i]
		local fX = tConf.x + tConf.w/2
	    pDragChangeListView:addItem(self.pHeroList[i], cc.p(fX, fY - tConf.h + tConf.h/2))
	    fY = fY - tConf.h - 10
	end

	local pLayBtnBattle = self:findViewByName("lay_btn_battle")
	self.pBtnBattle = getCommonButtonOfContainer(pLayBtnBattle, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10064))
	self.pBtnBattle:setBtnExText({tLabel = {
		--出征兵力
		{getConvertedStr(3, 10556)}, 
		{"0",getC3B(_cc.green)}, 
		--扣粮
		{getConvertedStr(3, 10066)}, 
		{"0",getC3B(_cc.green)}, 
		{"/0"}
	}})
	self.pBtnBattle:onCommonBtnClicked(handler(self, self.onBattleClicked))	


	--增益道具其本图片
	local sBuffItem = getDisplayParam("buffItem")
	local tBuffItem = luaSplit(sBuffItem, ";")
	local tImgBuff = {}
	local nX, nY = 98, 26
	local nOffsetX = 4
	for i=1,#tBuffItem do
		local nId = tonumber(tBuffItem[i])
		if nId then
			local tItem = getGoodsByTidFromDB(nId)
			if tItem then
				local nBuffId = tItem:getVipBuffId(Player:getPlayerInfo().nVip)
				if nBuffId then
					local tBuff = getBuffDataByIdFromDB(nBuffId)
					if tBuff then						
						local pImgBg = MUI.MImage.new("#v1_img_shuruA.png")
						pImgBg:setPosition(nX, nY)
						pLayBanner:addView(pImgBg)
						local pImg = MUI.MImage.new(tBuff.sIcon)
						tImgBuff[nBuffId] = pImg
						pLayBanner:addView(pImg, 1)
						pImg:setPosition(nX, nY)
						nX = nX + pImg:getContentSize().width + nOffsetX
					end
				end
			end
		end
	end
	self.tImgBuff = tImgBuff

	local pLayClick = self:findViewByName("lay_buff_click")
	pLayClick:setViewTouched(true)
	pLayClick:setIsPressedNeedScale(false)
	pLayClick:setIsPressedNeedColor(false)
	pLayClick:onMViewClicked(function ( _pView )
	    local tObject = {
		    nType = e_dlg_index.dlgbuffs, --dlg类型
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end)
end

function DlgBattleHero:updateViews(  )
	if self.tData then
		--图标
		if self.tData.nType == e_type_builddot.city then
			WorldFunc.getCityIconOfContainer(self.pLayIcon, self.tData.nDotCountry, self.tData.nDotLv, true)
			--旗子
			WorldFunc.setImgCountryFlag(self.pImgFlag, self.tData.nDotCountry)
		elseif self.tData.nType == e_type_builddot.sysCity then
			WorldFunc.getSysCityIconOfContainer(self.pLayIcon, self.tData.nSystemCityId ,self.tData.nDotCountry, true)
			--旗子
			WorldFunc.setImgCountryFlag(self.pImgFlag, self.tData.nDotCountry)
		elseif self.tData.nType == e_type_builddot.wildArmy then
			if self.tData.bIsMoBing then
				--魔君图标
				WorldFunc.getMoBingIconOfContainer(self.pLayIcon, self.tData.nRebelId, true)
 
				--旗子
				self.pImgFlag:setCurrentImage("#v2_img_emobiaozhi.png")
			else
				--乱军图标
				WorldFunc.getWildArmyIconOfContainer(self.pLayIcon, self.tData.nRebelId, true)

				--乱军动画
				-- if not self.pArmyArm then
				-- 	local pArmyArm = WorldFunc.getWildArmyArmOfContainer(self.pLayIcon, self.tData.nRebelId)
				-- 	if pArmyArm then
				-- 		self.pArmyArm = pArmyArm
				-- 		self.pLayIcon:setScale(0.8)	
				-- 	end
				-- end

				--旗子
				WorldFunc.setImgCountryFlag(self.pImgFlag, e_type_country.qunxiong)
			end
		elseif self.tData.nType == e_type_builddot.boss then
			WorldFunc.getBossIconOfContainer(self.pLayIcon, self.tData.nBossLv, true)
			--旗子
			WorldFunc.setWorldBossFlag(self.pImgFlag, self.tData.nBossLv)
		elseif self.tData.nType == e_type_builddot.tlboss then
			WorldFunc.getTLBossIconOfContainer(self.pLayIcon,true)
			WorldFunc.setWorldBossFlag(self.pImgFlag, 3)
		elseif self.tData.nType == e_type_builddot.ghostdom then
			WorldFunc.getWildArmyIconOfContainer(self.pLayIcon, self.tData.nGId, true,false,e_type_builddot.ghostdom)
		elseif self.tData.nType == e_type_builddot.zhouwang then--纣王
			WorldFunc.getZhouwangIconOfContainer(self.pLayIcon, true)
			--旗子
			WorldFunc.setImgCountryFlag(self.pImgFlag, self.tData.nDotCountry)
		end
	
		--限时Boss和纣王没有等级
		if self.tData.nType == e_type_builddot.tlboss then
			self.pTxtName:setString(self.tData:getDotName())
		else
			--名字与等级合并显示
			self.pTxtName:setString(self.tData:getDotName() .." ".. getLvString(self.tData.nDotLv,true))
		end
		
		--坐标
		self.pTxtPos:setString(getConvertedStr(3, 10109)  .. getWorldPosString(self.tData.nX, self.tData.nY))
		--行动时间
		self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. formatTimeToMs(self.nMoveTime))
	end

	-- --更新出征按钮
	-- local bIsSelected = false
	-- for i=1,#self.pHeroList do
	-- 	local pHero = self.pHeroList[i]
	-- 	if pHero:isVisible() and pHero:getIsSelected() then
	-- 		bIsSelected = true
	-- 		break
	-- 	end
	-- end
	-- self.pBtnBattle:setBtnEnable(bIsSelected) 
	--
	-- self:updateTroops()
	self:updateCostFood()
	self:updateBuff()

	--新手引导, 出征按钮显示特效
	if bIsSelected then
		local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
		local nArmyLv = Player:getNewGuideMgr():getHeroBattleArmyLv()
		--如果乱军等级是配表要攻打的等级或者当前任务是攻打任意2个乱军就显示特效指引
		if self.tData.nDotLv == nArmyLv or (tCurTask and tCurTask.sTid == e_special_task_id.beat_two_army) then
			self.pBtnBattle:showLingTx()
			--新手引导指引出征按妞
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnBattle, e_guide_finer.go_battle_btn)
		else
			self.pBtnBattle:removeLingTx()
		end
	else
		self.pBtnBattle:removeLingTx()
	end
end

function DlgBattleHero:updateBuffEffect(  )
	-- body
	self:updateBuff()
	self:updateMoveTime()
end

--更新增益
function DlgBattleHero:updateBuff( )
	for nBuffId, pImg in pairs(self.tImgBuff) do
		local tVo = Player:getBuffData():getBuffVo(nBuffId)
		if tVo then
			pImg:setToGray(false)
		else
			pImg:setToGray(true)
		end
	end
end

function DlgBattleHero:updateMoveTime( )
	-- body
	--重新计算行军时间
	self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.nX, self.nY, self.nRatio)
    --行动时间
	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. formatTimeToMs(self.nMoveTime))
end

--更新武将状态
function DlgBattleHero:updateHeroStates( )
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		if pHero:isVisible() then
			pHero:updateHeroState()
		end
	end
	self:updateViews()
end

-- --更新兵力
-- function DlgBattleHero:updateTroops()
-- 	local nTroops = 0
-- 	for i=1,#self.pHeroList do
-- 		local pHero = self.pHeroList[i]
-- 		if pHero:isVisible() and pHero:getIsSelected() then
-- 			nTroops = nTroops + pHero:getTroops()
-- 		end
-- 	end
-- 	self.nTroops = nTroops

-- 	local tStr = {
--     	{color=_cc.pwhite, text= getConvertedStr(3, 10065)},
--     	{color=_cc.green, text= " "..tostring(self.nTroops)},
--     }
-- 	self.pLayBannerTip:setString(tStr)
-- end

--更新粮草
function DlgBattleHero:updateCostFood()
	--兵力
	local nTroops = 0
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		if pHero:isVisible() and pHero:getIsSelected() then
			nTroops = nTroops + pHero:getTroops()
		end
	end


	self.nTroops = nTroops
    self.pBtnBattle:setExTextLbCnCr(2, tostring(self.nTroops))

    	--不消耗粮草
	if self.nType == e_type_task.cityWar or self.nType == e_type_task.countryWar then
		self.pBtnBattle:setExTextLbCnCr(3, "")
		self.pBtnBattle:setExTextLbCnCr(4, "")
		self.pBtnBattle:setExTextLbCnCr(5, "")
	else
		self.pBtnBattle:setExTextLbCnCr(3, "　　"..getConvertedStr(3, 10066))
	    --扣粮
		local nCostFood = WorldFunc.getCostFood(self.nTroops, self.nMoveTime)
		local sColor = _cc.green
		if Player:getPlayerInfo().nFood < nCostFood then
			sColor = _cc.red
		end
		self.pBtnBattle:setExTextLbCnCr(4, getResourcesStr(Player:getPlayerInfo().nFood), getC3B(sColor))
		self.pBtnBattle:setExTextLbCnCr(5, "/"..getResourcesStr(nCostFood))
	end
end

function DlgBattleHero:onBattleClicked( pView )
	--
	--当所有武将当前兵力<最大兵力的10%，点击按钮弹出错误提示“请为武将补充兵力！”
	local bIsAllNoTroops = true
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		if pHero:isVisible() then
			if not pHero:getIsNoTroops() then
				bIsAllNoTroops = false
				break
			end
		end
	end
	if bIsAllNoTroops then
		TOAST(getConvertedStr(3, 10560))
		return
	end

	--有武将当前兵力>=最大兵力的10%，没有勾选任何武将出征，点击按钮弹出错误提示“请至少选择一名武将出征！”
	local bIsSelected = false
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		if pHero:isVisible() and pHero:getIsSelected() then
			bIsSelected = true
			break
		end
	end
	if not bIsSelected then
		TOAST(getConvertedStr(3, 10561))
		return
	end

	--新手引导出征按钮已点
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.go_battle_btn)

	self.tGoHeroIds = nil
	--加入城战
	if self.tCityWarMsg then
		--不可以跨区
		if not Player:getWorldData():getIsCanWarByPos(self.tData.nX, self.tData.nY, e_war_type.city) then
			TOAST(getTipsByIndex(20032))
			return
		end
		
		--移动时间过长
		if self.nMoveTime > self.tCityWarMsg:getCd() then
			TOAST(getTipsByIndex(20031))
			return
		end
	end
	--加入国战
	if self.tCountryWarMsg then
		--不可以跨区
		if not Player:getWorldData():getIsCanWarByPos(self.tData.nX, self.tData.nY, e_war_type.country) then
			TOAST(getTipsByIndex(20032))
			return
		end

		--移动时间过长
		if self.nMoveTime > self.tCountryWarMsg:getCd() then
			TOAST(getTipsByIndex(20031))
			return
		end
	end

	--武将列表字符串
	local tHeros = {}
	local pHeroList = self.pDragChangeListView:getItemList()
	for i=1,#pHeroList do--正序加入列表
		local pHero = pHeroList[i]
		if pHero:isVisible() and pHero:getIsSelected() then
			if pHero:getIsBusy() then
				TOAST(getConvertedStr(3, 10095))
				return
			end
			table.insert(tHeros, pHero:getHeroId())
		end
	end


	-- --驻守上限(由于本地数据可能不准，去掉此判断，由后端拦截)
	-- if self.nType == e_type_task.garrison then
	-- 	if #tHeros > self.nCanGarrisonNum then
	-- 		--驻守城池武将已达上限
	-- 		TOAST(getConvertedStr(3, 10365))
	-- 		return
	-- 	end
	-- end

	-- dump(tHeros,"tHeros")

	if #tHeros > 0 then
		--记录这次出征Id数据
		self.tGoHeroIds = tHeros
		--国战时候加二次提醒
		if self.nType == e_type_task.countryWar then
			--还有保护cd时间
			if WorldFunc.checkIsAttackCityInProtect(handler(self, self.sendBattleReq)) then
				return
			end
		end

		--发送请求
		self:sendBattleReq()
	else
		TOAST(getConvertedStr(3, 10100))
	end
end

--判断出征武将是否可以自动补兵
function DlgBattleHero:checkHeroIsCanFillTroops( nHeroId )
	if not nHeroId then
		print("DlgBattleHero:checkHeroIsCanFillTroops no nHeroId")
		return false
	end

	if self:checkHeroIsEnoughtTroops(nHeroId) then
		print("DlgBattleHero:checkHeroIsCanFillTroops hero is enough")
		return false
	end

	local tHero = Player:getHeroInfo():getHero(nHeroId)
	if tHero then
		local nLeftNums = 0
		if tHero.nKind == en_soldier_type.infantry then --步
			nLeftNums = Player:getPlayerInfo().nInfantry-- - nWillAddSoldier 
		elseif tHero.nKind == en_soldier_type.sowar then --骑
			nLeftNums = Player:getPlayerInfo().nSowar--  - nWillAddSoldier
		elseif tHero.nKind == en_soldier_type.archer then --弓
			nLeftNums = Player:getPlayerInfo().nArcher-- - nWillAddSoldier
		end
		if nLeftNums > 0 then
			return true
		end
	end
	print("DlgBattleHero:checkHeroIsCanFillTroops no nHeroData",nHeroId)
	return false
end

--判断出征武将是否足兵
function DlgBattleHero:checkHeroIsEnoughtTroops( nHeroId )
	if not nHeroId then
		print("DlgBattleHero:checkHeroIsEnoughtTroops no nHeroId")
		return false
	end
	local tHero = Player:getHeroInfo():getHero(nHeroId)
	if tHero then
		local nCurrTroops = tHero.nLt
		local nMaxTroops = tHero:getProperty(e_id_hero_att.bingli)
		-- print("nCurrTroops >= nMaxTroops", nCurrTroops, nMaxTroops, nCurrTroops >= nMaxTroops)
		return nCurrTroops >= nMaxTroops
	end
	print("DlgBattleHero:checkHeroIsEnoughtTroops no nHeroData")
	return false
end


--出征时的出战士的自动补兵处理
--a.进行操作时，界面不能立即关闭，要给一个兵力条滚动效果，可以像血条处理一样，固定时间内滚完，只是根据长度不同速度不同
--b.系统设置里，需要增加一个这个的开关，默认打开，若玩家关闭则不生效，这个星威关注下
--c.当前有多少就补多少，若还是不足，则转入下一流程
function DlgBattleHero:herosFillTroopsCtrl( )
	if not self.tGoHeroIds then
		TOAST(getConvertedStr(3, 10449))
		return
	end

	--记录可以自动补兵的数据
	self.tReqFillHeroId = {}
	for i=1, #self.tGoHeroIds do
		local nHeroId = self.tGoHeroIds[i]
		if self:checkHeroIsCanFillTroops(nHeroId) then
			table.insert(self.tReqFillHeroId, nHeroId)
		end
	end

	--满足的条要先进行补兵
	if #self.tReqFillHeroId > 0 then
		SocketManager:sendMsg("heroAddSoldier", {self.tReqFillHeroId[1]}, handler(self, self.onHeroFillTroops))
	else
		self:__sendBattleReq()
	end
end

--接收服务端发回的登录回调
function DlgBattleHero:onHeroFillTroops( __msg, __msgOld )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.heroAddSoldier.id then
        	--容错
        	if self and self.tReqFillHeroId then
        		--从自动补兵中删除
	        	local nReqHeroId = __msgOld[1]
	        	--print("DlgBattleHero:onHeroFillTroops nReqHeroId", nReqHeroId)
	        	for i=1,#self.tReqFillHeroId do
	        		if nReqHeroId == self.tReqFillHeroId[i] then
	        			table.remove(self.tReqFillHeroId, i)
	        			break
	        		end
	        	end
	        	--dump(self.tReqFillHeroId, "self.tReqFillHeroId", 100)
	        	--从自动补兵列表中抽出可以下一个补兵的武将
	        	if #self.tReqFillHeroId > 0 then
	        		for i=1,#self.tReqFillHeroId do
	        			local nHeroId = self.tReqFillHeroId[i]
	        			--判断是否可以补兵（发送命令后返回)
						if self:checkHeroIsCanFillTroops(nHeroId) then
							SocketManager:sendMsg("heroAddSoldier", {nHeroId}, handler(self, self.onHeroFillTroops))
							return
						end
	        		end
	        	end
	        	--进入增兵动画结束出征状态
	        	self:waitFillTroopsBattle()
        	else
        		TOAST(getConvertedStr(3, 10451))
        	end
        end
    else
    	TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--发送出征请求
function DlgBattleHero:sendBattleReq( )
	local nAuto = tonumber(getSettingInfo("AutoIncreaseForces"))
	--dump(nAuto, "nAuto", 100)
	if nAuto == 1 then
		self:herosFillTroopsCtrl()
	else
		self:__sendBattleReq()
	end
end

--进入增兵动画结束出征状态
function DlgBattleHero:waitFillTroopsBattle(  )
	if not self.tGoHeroIds then
		TOAST(getConvertedStr(3, 10449))
		return
	end
	if(self.__isWaiting) then
		TOAST(getConvertedStr(3, 10450))
		return
	end
	self.__isWaiting = true

	--开启不可触碰检测
	showUnableTouchDlg()
	--发送请求
	local function nFunc()
		--关闭不可触碰检测
		hideUnableTouchDlg()
		self:__sendBattleReq()
	end
	--
	doDelayForSomething(self, nFunc, 0.3)
end

--真正发送出征请求函数
function DlgBattleHero:__sendBattleReq( )
	if not self.tGoHeroIds then
		TOAST(getConvertedStr(3, 10449))
		return
	end

	local function reqFunc( )
		local sHids = table.concat(self.tGoHeroIds, ",")
		-- dump(sHids,"sHids")
		-- dump({self.nType, self.nX,
		-- 		self.nY, sHids, self.sWarId, self.nAcker, self.nWarType, self.nCwID, self.nCostType})
		SocketManager:sendMsg("reqWorldTask", {self.nType, self.nX,
				self.nY, sHids, self.sWarId, self.nAcker, self.nWarType, self.nCwID, self.nCostType}, 
				handler(self, self.onCreateTaskMsg))

		--关闭前面的界面
		if self.nType == e_type_task.cityWar then
			closeDlgByType(e_dlg_index.citydetail, false)
			closeDlgByType(e_dlg_index.citywar, false)
		elseif self.nType == e_type_task.garrison then
			closeDlgByType(e_dlg_index.citygarrison, false)
		elseif self.nType == e_type_task.wildArmy then
			closeDlgByType(e_dlg_index.wildarmy, false)
		elseif self.nType == e_type_task.countryWar then
			closeDlgByType(e_dlg_index.countrywar, false)
		elseif self.nType == e_type_task.boss then
			closeDlgByType(e_dlg_index.bosswar, false)
		elseif self.nType == e_type_task.ghostdom then
			closeDlgByType(e_dlg_index.ghostdomdetail, false)
		elseif self.nType == e_type_task.zhouwang then
			closeDlgByType(e_dlg_index.dlgZhouwangtrial, false)
		end

	end

	--不满兵是否继续出征
	for i=1,#self.tGoHeroIds do
		if not self:checkHeroIsEnoughtTroops(self.tGoHeroIds[i]) then
			--二次确认框
			local DlgAlert = require("app.common.dialog.DlgAlert")
		    local pDlg = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		        pDlg = DlgAlert.new(e_dlg_index.alert)
		    end
		    pDlg:setTitle(getConvertedStr(3, 10091))
		    pDlg:setContent(getConvertedStr(3, 10417))
		    pDlg:setRightHandler(function (  )
		        pDlg:closeDlg(false)
		        reqFunc()
		    end)
		    pDlg:showDlg(bNew)
			return
		end
	end

	--发送
	reqFunc()
end



--城战发起触发
function DlgBattleHero:setDataByCityWar( pMsgObj )
	local tData = pMsgObj.tViewDotMsg --视图点数据
	local nWarType = pMsgObj.nWarType --战术
	local nCostType = pMsgObj.nCostType --战斗消耗类型
	self.nType = e_type_task.cityWar
	self.nWarType = nWarType
	self.nAcker = 1
	self.nX = tData.nX
	self.nY = tData.nY
	self.nCostType = nCostType
	self:setData(tData)
end

--加入城战
--tData:tViewDotMsg
--sWarId：参战的id
function DlgBattleHero:setDataByJoinCityWar( tData, sWarId, tCityWarMsg)
	self.nType = e_type_task.cityWar
	self.sWarId = sWarId
	self.nX = tData.nX
	self.nY = tData.nY
	self.tCityWarMsg = tCityWarMsg
	self.nWarType = self.tCityWarMsg.nWarType --兼容后端出错
	self:setData(tData)
end

--国战
--tData:tViewDotMsg
--nCwID：发起的国家
function DlgBattleHero:setDataByCountryWar( tData, nCwID, tCountryWarMsg)
	self.nType = e_type_task.countryWar
	self.nX = tData.nX
	self.nY = tData.nY
	self.nCwID = nCwID
	self.tCountryWarMsg = tCountryWarMsg
	self:setData(tData)
end


--驻守
--tData:tViewDotMsg
function DlgBattleHero:setDataByGarrison( tData, nCanGarrisonNum)
	self.nType = e_type_task.garrison
	self.nX = tData.nX
	self.nY = tData.nY
	self:setData(tData)
	self.nCanGarrisonNum = nCanGarrisonNum
end

--野军
--tData:tViewDotMsg
function DlgBattleHero:setDataByWildArmy( tData)
	self.nType = e_type_task.wildArmy
	self.nX = tData.nX
	self.nY = tData.nY
	self:setData(tData)
end

--攻打世界Boss
--tData:tViewDotMsg
function DlgBattleHero:setDataByBoss( tData )
	self.nType = e_type_task.boss
	self.nX = tData.nX
	self.nY = tData.nY
	self:setData(tData)
end

--攻打限时世界Boss
--tData:tViewDotMsg
function DlgBattleHero:setDataByTLBoss( tData )
	self.nType = e_type_task.tlboss
	self.nX = tData.nX
	self.nY = tData.nY
	self:setData(tData)
end

--幽魂
--tData:tViewDotMsg
function DlgBattleHero:setDataByGhostdom( tData)
	self.nType = e_type_task.ghostdom
	self.nX = tData.nX
	self.nY = tData.nY
	self:setData(tData)
end

--纣王试炼
--tData:tViewDotMsg
function DlgBattleHero:setDataByZhouTrial( tData)
	self.nType = e_type_task.zhouwang
	self.nX = tData.nX
	self.nY = tData.nY
	self:setData(tData)
end

--出征皇城战
--tData:tViewDotMsg
function DlgBattleHero:setDataByImperialCity( tData )
	self.nType = e_type_task.imperwar
	self.nX = tData.nX
	self.nY = tData.nY
	self:setData(tData)
end


--基本设置
function DlgBattleHero:setData( tData )
	self.tData = tData
	--行军时间
	if self.nType == e_type_task.cityWar then
		--阿房宫时间
		local nMyBlockId = Player:getWorldData():getMyCityBlockId()
		local nTargetBlockId = WorldFunc.getBlockId(self.nX, self.nY)
		self.bIsMarchTimes = false
		if nMyBlockId ~= nTargetBlockId then
			if nMyBlockId == nImperialCityMapId then
				self.bIsMarchTimes = true
			end
		end
		self.nMoveTime = 0
		if self.bIsMarchTimes then
			local tTimes = getWorldInitData("marchTimes")
			if self.nWarType == 1 then --短途
				self.nMoveTime = tTimes[1]
			elseif self.nWarType == 2 then --合围
				self.nMoveTime = tTimes[2]
			elseif self.nWarType == 3 then --奔
				self.nMoveTime = tTimes[3]
			end
		else
			self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.nX, self.nY)
		end
	else
		--加速度时间
		self.nRatio = nil
		if self.nType == e_type_task.boss then
			if tData then
				self.nRatio = WorldFunc.getBossSpeedAdd(tData.nBossLv)
			end
		elseif self.nType == e_type_task.tlboss then
			self.nRatio = tonumber(getBossInitData("speedRate"))
		elseif self.nType == e_type_task.zhouwang then
			self.nRatio = tonumber(getKingZhouInitData("marchQuickRate"))
		elseif self.nType == e_type_task.wildArmy then
			self.nRatio = getArmyRatioInNewGuide(self.tData.nDotLv)
		end
		--行军时间
		self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.nX, self.nY, self.nRatio)
	end
	
	--行军数
	self.nTroops = 0
	--设置武将
	local tHeroList = Player:getHeroInfo():getOnlineHeroList(true)
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		if tHeroList[i] then
			pHero:setData(tHeroList[i])
			self.pDragChangeListView:includeItem(pHero)
		else
			if i > Player:getHeroInfo().nOnlineNums then
				pHero:setData(nil, TypeIconHero.LOCK)
			else
				pHero:setData(nil, TypeIconHero.ADD)
			end
			self.pDragChangeListView:excludeItem(pHero)
		end
	end
	self.pDragChangeListView:resetFoundItem()

	--是否全选武将
	self:selectedHerosBySwitch()
end

--设置出征后回调
function DlgBattleHero:setBattledFunc( nHandler )
	self.nBattledFunc = nHandler
end

--创建任务返回
function DlgBattleHero:onCreateTaskMsg( __msg , __oldmsg)
	if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqWorldTask.id then
        	self:saveHeroOrder()
        	--播放音效
        	Sounds.playEffect(Sounds.Effect.setout)
        	if self.nBattledFunc then
        		self.nBattledFunc()
        	end
        	--兼容可能出错，znftodo
        	if self.onCloseClicked then
        		self:onCloseClicked()
        	end
        end
    else
    	--已经在Controller报了错，这里不用写
        -- TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
    self.__isWaiting = nil
end

--记录武将顺序
function DlgBattleHero:saveHeroOrder(  )
	-- body
	local tHeros = {}
	local pHeroList = self.pDragChangeListView:getItemList()
	for i=1,#pHeroList do--正序加入列表
		local pHero = pHeroList[i]
		table.insert(tHeros, pHero:getHeroId())
	end	
	Player:getHeroInfo():saveLocalHeroOrder(tHeros)
end

--武将发生更改
function DlgBattleHero:updateHeros( )
	--更新武将状态
	local tNewAddHeroList = {}
	local tHeroList = Player:getHeroInfo():getOnlineHeroList(true)
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		if pHero:getNullType() == TypeIconHero.ADD then
			pHero:setData(tHeroList[i])
			self.pDragChangeListView:includeItem(pHero)
			table.insert(tNewAddHeroList, pHero)
		else
			pHero:setData(tHeroList[i])
		end
	end
	if #tNewAddHeroList > 0 then
		self.pDragChangeListView:resetFoundItem()
		--
		local bIsAuto = Player:getWorldData():getIsAllBattleAuto()
		for i=1,#tNewAddHeroList do
			local pHero = tNewAddHeroList[i]
			if pHero:isVisible() then
				pHero:setIsSelected(bIsAuto)
			end
		end
		self:updateViews()
	end


	--更新武将兵力
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		pHero:updateHeroRecruit()
	end
end

--根据开关选择武将
function DlgBattleHero:selectedHerosBySwitch( )
	local bIsAuto = Player:getWorldData():getIsAllBattleAuto()
	for i=1,#self.pHeroList do
		local pHero = self.pHeroList[i]
		if pHero:isVisible() then
			pHero:setIsSelected(bIsAuto)
		end
	end
	self:updateViews()
end

--自动全部出征
function DlgBattleHero:onOvalSw()
	local bIsAuto = not Player:getWorldData():getIsAllBattleAuto()
	if bIsAuto then
		self.pOvalSw:setState(1)
	else
		self.pOvalSw:setState(0)
	end
	--设置数据
	Player:getWorldData():setIsAllBattleAuto(bIsAuto)
	self:selectedHerosBySwitch()
end

return DlgBattleHero