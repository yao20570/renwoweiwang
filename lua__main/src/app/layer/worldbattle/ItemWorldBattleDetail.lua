----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-15 22:27:00
-- Description: 行军战斗细节
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemWorldBattleDetail = class("ItemWorldBattleDetail", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWorldBattleDetail:ctor(  )
	--解析文件
	parseView("item_world_battle_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWorldBattleDetail:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWorldBattleDetail", handler(self, self.onItemWorldBattleDetailDestroy))
end

-- 析构方法
function ItemWorldBattleDetail:onItemWorldBattleDetailDestroy(  )
    self:onPause()
end

function ItemWorldBattleDetail:regMsgs(  )
end

function ItemWorldBattleDetail:unregMsgs(  )
end

function ItemWorldBattleDetail:onResume(  )
	self:regMsgs()
	--开启更新cd
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()

end

function ItemWorldBattleDetail:onPause(  )
	self:unregMsgs()
end

function ItemWorldBattleDetail:setupViews(  )
	--隐藏背景底图
	-- local pLayBg = self:findViewByName("lay_bg")
	-- setGradientBackground(pLayBg)

	self.pTxtTask = self:findViewByName("txt_task")
	self.pImgArrow = self:findViewByName("img_arrow")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayCityIcon = self:findViewByName("lay_city_icon")
	-- self.pLayCityIcon:setScale(0.4)
	self.pLayHeadIcon = self:findViewByName("lay_head_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pTxtPos = self:findViewByName("txt_pos")
	-- setTextCCColor(self.pTxtPos, _cc.gray)
	self.pLayCd = self:findViewByName("lay_cd")


	self.pLayBtn1 = self:findViewByName("lay_btn1")
	self.pLayBtn2 = self:findViewByName("lay_btn2")
	self.pTxtCd = self:findViewByName("txt_cd")
	self.pTxtTip = self:findViewByName("txt_tip")

	self.pLayCollectHeroLock = self:findViewByName("lay_collect_hero_lock")
	self.pTxtUnLockTip1 = self:findViewByName("txt_unlock_tip1")
	self.pTxtUnLockTip2 = self:findViewByName("txt_unlock_tip2")
	self.pLayBtnUnLock = self:findViewByName("lay_btn_unlock")
	self.pLayLockIcon = self:findViewByName("lay_lock_icon")

	self.pLayLocation = self:findViewByName("lay_location")
	self.pLayLocation:setViewTouched(true)
	self.pLayLocation:setIsPressedNeedScale(false)
	self.pLayLocation:onMViewClicked(handler(self, self.onLocationClicked))

	self.pLayMuiltIcon = self:findViewByName("lay_mulit_icon")
	local pLayIcon1 = self:findViewByName("lay_icon1")
	local pLayIcon2 = self:findViewByName("lay_icon2")
	local pLayIcon3 = self:findViewByName("lay_icon3")
	local pLayIcon4 = self:findViewByName("lay_icon4")
	self.pLayIcons = {
		pLayIcon1,
		pLayIcon2,
		pLayIcon3,
		pLayIcon4,
	}

	self.pCdBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
		    {
		    	bar="ui/bar/v1_bar_b1.png",
		   	 	button="ui/update_bin/v1_ball.png",
		    	barfg="ui/bar/v1_bar_blue_3.png"
		    }, 
		    {
		    	scale9 = false, 
		    	touchInButton=false
		    })
		    :setSliderSize(142, 14)
		    :align(display.LEFT_BOTTOM)
    --设置为不可触摸
    self.pCdBar:setViewTouched(false)
	self.pLayCd:addView(self.pCdBar)

	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1,TypeCommonBtn.O_BLUE)
	setMCommonBtnScale(self.pLayBtn1, self.pBtn1, 0.7)
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2,TypeCommonBtn.O_BLUE)
	setMCommonBtnScale(self.pLayBtn2, self.pBtn2, 0.7)
end

function ItemWorldBattleDetail:updateViews(  )
	--清空武将信息
	self.sTaskId = nil
	self.nState = nil
	self.nTaskType = nil
	--更新数据
	if self.nTabIndex == e_wolrdbattle_tab.hero or self.nTabIndex == e_wolrdbattle_tab.collect_hero then
		if self.tData then			
			--设置任务
			if self.tData.tTask then
				self.sTaskId = self.tData.tTask.sUuid
				local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
				if tTask then
					--设置基本显示
					self:setCommonHeroUisInTask()
					--
					self.nState = tTask.nState
					self.nTaskType = tTask.nType
					if self.nTaskType == e_type_task.collection then
						self:setCollectionStyle(tTask)
					elseif self.nTaskType == e_type_task.wildArmy then
						self:setArmyStyle(tTask)
					elseif self.nTaskType == e_type_task.cityWar then
						self:setCityWarStyle(tTask)
					elseif self.nTaskType == e_type_task.countryWar then
						self:setCountryWarStyle(tTask)
					elseif self.nTaskType == e_type_task.garrison then
						self:setGarrisonStyle(tTask)
					elseif self.nTaskType == e_type_task.boss then
						self:setBossStyle(tTask)
					elseif self.nTaskType == e_type_task.tlboss then --限时Boss
						self:setTLBossStyle(tTask)
					elseif self.nTaskType == e_type_task.ghostdom then   --幽魂
						self:setGhostdomStyle(tTask)
					elseif self.nTaskType == e_type_task.imperwar then --皇城
						self:setImperWarStyle(tTask)
					elseif self.nTaskType == e_type_task.zhouwang then --纣王试炼
						self:setZhouwangStyle(tTask)--显示于						
					end
					self:setMulitHero(tTask.tArmy, true)
				end
			elseif self.tData.heroId then --设置武将
				self:setCommonHeroUisNoTask()
				self:setIdleSytle()
				--停止倒计时
				unregUpdateControl(self)
			end
		else
			--设置未上阵
			self:setCommonHeroUisNoTask()
			self:setNullSytle()
			--停止倒计时
			unregUpdateControl(self)
		end
	elseif self.nTabIndex == e_wolrdbattle_tab.hit then
		self:setCityWarMsg()
	elseif self.nTabIndex == e_wolrdbattle_tab.country_war then
		self:setCountryWar()
	elseif self.nTabIndex == e_wolrdbattle_tab.support then
		self:setHelpData()
	end
end

--设置数据
function ItemWorldBattleDetail:setData( tData, nTabIndex, nItemIndex)
	self.tData = tData
	self.nTabIndex = nTabIndex
	self.nItemIndex = nItemIndex
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

------------------------------------------武将
--设置通用武将UI显示
function ItemWorldBattleDetail:setCommonHeroUisInTask( )
	self.pImgArrow:setVisible(true)
	self.pTxtTask:setVisible(true)
	self.pLayBtn1:setVisible(true)
	self.pLayBtn2:setVisible(true)
	self.pTxtName:setVisible(true)
	self.pTxtPos:setVisible(false)
	self.pTxtCd:setVisible(true)
	self.pLayCd:setVisible(true)
	self.pLayLocation:setVisible(true)
	self.pTxtTip:setVisible(false)
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(false)
	self.pLayCityIcon:setVisible(false)
	self.pLayHeadIcon:setVisible(false)
	self.pLayCollectHeroLock:setVisible(false)
end

--设置通用武将UI显示
function ItemWorldBattleDetail:setCommonHeroUisNoTask( )
	self.pImgArrow:setVisible(false)
	self.pTxtTask:setVisible(false)
	self.pLayBtn1:setVisible(false)
	self.pLayBtn2:setVisible(false)
	self.pTxtName:setVisible(false)
	self.pTxtPos:setVisible(false)
	self.pTxtCd:setVisible(false)
	self.pLayCd:setVisible(false)
	self.pLayLocation:setVisible(false)
	self.pTxtTip:setVisible(true)
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(false)
	self.pLayCityIcon:setVisible(false)
	self.pLayHeadIcon:setVisible(false)
	self.pLayCollectHeroLock:setVisible(false)
end

--设置武将收集
--设置采集
function ItemWorldBattleDetail:setCollectionStyle( tTask )
	--任务名
	self.pTxtTask:setString(getConvertedStr(3, 10079))
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_lvqian.png")
	--采集+等级
	if tTask then
		self.pTxtName:setString(tostring(tTask.sTargetName).." "..getLvString(tTask.nTargetLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--加速
		self:setBtnQuick(self.pBtn2)
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	--采集
	elseif self.nState == e_type_task_state.collection then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end
end

--设置乱军
function ItemWorldBattleDetail:setArmyStyle( tTask )
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_chengbiaoqian.png")
	--乱军名+等级
	if tTask then
		local sName = tTask.sTargetName or getConvertedStr(3, 10080)
		--任务名
		self.pTxtTask:setString(sName)
		self.pTxtName:setString(sName.." "..getLvString(tTask.nTargetLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--加速
		self:setBtnQuick(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	end
end

--设置城战
function ItemWorldBattleDetail:setCityWarStyle( tTask )
	--任务名
	self.pTxtTask:setString(getConvertedStr(3, 10081))
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
	--城战+等级
	if tTask then
		local sName = tTask.sTargetName or getConvertedStr(3, 10081)
		self.pTxtName:setString(sName.." "..getLvString(tTask.nTargetLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
			--目标
		self:setBtnTarget(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	--城战
	elseif self.nState == e_type_task_state.waitbattle then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end
	
end

--设置国战
function ItemWorldBattleDetail:setCountryWarStyle( tTask )
	--任务名
	self.pTxtTask:setString(getConvertedStr(3, 10082))
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_zibiaoqian.png")
	--国战+等级
	if tTask then
		local sName = tTask.sTargetName or getConvertedStr(3, 10082)
		self.pTxtName:setString(sName.." "..getLvString(tTask.nTargetLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	--国战
	elseif self.nState == e_type_task_state.waitbattle then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end
	
end

--设置驻防
function ItemWorldBattleDetail:setGarrisonStyle( tTask )
	self.pTxtTask:setString(getConvertedStr(3, 10083))
	self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
	--驻防+等级
	if tTask then
		local sName = tTask.sTargetName or getConvertedStr(3, 10083)
		self.pTxtName:setString(sName.." "..getLvString(tTask.nTargetLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	--城战
	elseif self.nState == e_type_task_state.garrison then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end
	
end

--设置Boss
function ItemWorldBattleDetail:setBossStyle( tTask )
	self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
	--纣王+等级
	if tTask then
		local sName = tTask.sTargetName or getConvertedStr(3, 10511)
		self.pTxtTask:setString(sName)
		self.pTxtName:setString(sName.." "..getLvString(tTask.nTargetLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	--驻战
	elseif self.nState == e_type_task_state.waitbattle then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end
		
end

function ItemWorldBattleDetail:setZhouwangStyle( tTask )
	-- body
	self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
	--纣王+等级
	if tTask then
		-- dump(tTask, "tTask", 100)
		local pData = WorldFunc.getKingZhouConfData()
		local sName = tTask.sTargetName or getConvertedStr(3, 10511)
		self.pTxtTask:setString(sName)
		if pData then
			self.pTxtName:setString(pData.sName..getSpaceStr(1)..getLvString(pData.nLevel, false))
		end
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	--驻战
	elseif self.nState == e_type_task_state.waitbattle then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end	
end

--设置限时Boss
function ItemWorldBattleDetail:setTLBossStyle( tTask )
	self.pImgArrow:setCurrentImage("#v1_img_hongqian.png")
	--限时Boss
	if tTask then
		local sName = tTask.sTargetName or getConvertedStr(3, 10800)
		self.pTxtTask:setString(sName)
		self.pTxtName:setString(sName)
		self.pTxtPos:setVisible(true)
		self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--加速
		self:setBtnQuick(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	--驻战
	elseif self.nState == e_type_task_state.waitbattle then
		--返回
		self:setBtnBack(self.pBtn1)
		--目标
		self:setBtnTarget(self.pBtn2)
	end
end

--设置幽魂
function ItemWorldBattleDetail:setGhostdomStyle( tTask )
	--箭头图片
	self.pImgArrow:setCurrentImage("#v1_img_chengbiaoqian.png")
	--乱军名+等级
	if tTask then
		local sName = tTask.sTargetName or getConvertedStr(3, 10080)
		--任务名
		self.pTxtTask:setString(sName)
		self.pTxtName:setString(sName)--.." "..getLvString(tTask.nTargetLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tTask.nTargetX, tTask.nTargetY))
	end
	--前往
	if self.nState == e_type_task_state.go then
		--召回
		self:setBtnCallBack(self.pBtn1)
		--加速
		self:setBtnQuick(self.pBtn2)
	--返回
	elseif self.nState == e_type_task_state.back then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	end
		
end


--设置皇城战显示
function ItemWorldBattleDetail:setImperWarStyle( tTask )
	self.pImgArrow:setCurrentImage("#v1_img_chengbiaoqian.png")
	--皇城战
	local bIsBot = false
	if tTask then
		local sName = tTask.sTargetName or tTask:getBoName()
		self.pTxtTask:setString(sName)
		self.pTxtName:setString(sName)
		bIsBot = tTask:getIsBot()
	end
	--是突围中
	if bIsBot and self.nState == e_type_task_state.go then
		--加速
		self:setBtnQuick(self.pBtn2)
		--目标
		self:setBtnTarget(self.pBtn1)
	else
		--前往
		if self.nState == e_type_task_state.go then
			--召回
			self:setBtnCallBack(self.pBtn1)
			--目标
			self:setBtnTarget(self.pBtn2)
		--返回
		elseif self.nState == e_type_task_state.back then
			--加速
			self:setBtnQuick(self.pBtn1)
			--目标
			self:setBtnTarget(self.pBtn2)
		--驻战
		elseif self.nState == e_type_task_state.waitbattle then
			--撤军
			self:setBtnArmyLeave(self.pBtn1)
			--目标
			self:setBtnTarget(self.pBtn2)
		end
	end
end

--设置空闲状态
function ItemWorldBattleDetail:setIdleSytle(  )
	self.pTxtTip:setString(getConvertedStr(3, 10078))
	-- self.pLayIcon:setPositionX(6 + 72)
	if self.tData then
		local nHeroId= self.tData.heroId
		local pHero = Player:getHeroInfo():getHero(nHeroId)
		if pHero then
			self:setHeroByData(pHero)
		end
	end
end

--设置未上阵状态
function ItemWorldBattleDetail:setNullSytle( )
	--特殊
	if self.nTabIndex == e_wolrdbattle_tab.collect_hero and Player:getHeroInfo():getCollectPosState(self.nItemIndex) == TypeIconHero.LOCK then
		self.pTxtTip:setVisible(false)
		self.pLayCollectHeroLock:setVisible(true)

		--那个上锁图标
		if not self.pLockIcon then
			self.pLockIcon = getIconHeroByType(self.pLayLockIcon,TypeIconHero.NORMAL,nil,TypeIconHeroSize.M)
			self.pLockIcon:setLockedState()
		end

		--花费
		self.nUnLockCost = nil
		--显示解锁按钮
		local bIsShowUnLockBtn = false
		--采集文字1
		local tDbData = getBuildParam("collectionFree")
		if tDbData then
			local tData2 = tDbData[self.nItemIndex]
			if tData2 then
				local nFreeLv = tData2.nLv
				self.pTxtUnLockTip1:setString(string.format(getConvertedStr(3, 10562), nFreeLv))
			end
		end
		--采集文字2
		local tDbData = getBuildParam("collectionCost")
		if tDbData then
			local tData2 = tDbData[self.nItemIndex]
			if tData2 then
				local nNeedLv = tData2.nLv
				local nCost = tData2.nCost
				self.pTxtUnLockTip2:setString(string.format(getConvertedStr(3, 10564), nNeedLv))
				self.nUnLockCost = nCost

				--已开启数量
				local nCq = Player:getHeroInfo():getCollectQueueNums()
				if self.nItemIndex == nCq + 1 then
					if Player:getPlayerInfo().nLv >= nNeedLv then
						bIsShowUnLockBtn = true
					end
				end
			end
		end
		if bIsShowUnLockBtn then
			if self.pBtnUnLock then
				self.pBtnUnLock:setExTextLbCnCr(1, self.nUnLockCost)
				self.pBtnUnLock:setExTextVisiable(true)
				self.pBtnUnLock:setVisible(true)
			else
				self.pBtnUnLock = getCommonButtonOfContainer(self.pLayBtnUnLock, TypeCommonBtn.O_YELLOW, getConvertedStr(3, 10563))	
				setMCommonBtnScale(self.pLayBtnUnLock, self.pBtnUnLock, 0.7)
				self.pBtnUnLock:onCommonBtnClicked(handler(self, self.onUnLockBtnClick))
				local tConTable = {}
				tConTable.img = getCostResImg(e_type_resdata.money)
				--文本
				local tLabel = {
				 {tostring(self.nUnLockCost),getC3B(_cc.white)},
				}
				tConTable.tLabel = tLabel
				local pBtnEx = self.pBtnUnLock:setBtnExText(tConTable)
				pBtnEx:addHeight(-10)
			end
		else
			if self.pBtnUnLock then
				self.pBtnUnLock:setVisible(false)
				self.pBtnUnLock:setExTextVisiable(false)
			end
		end

	else
		self.pTxtTip:setVisible(true)
		self.pTxtTip:setString(getConvertedStr(3, 10078))
	end
end

--设置多个或一个武将
function ItemWorldBattleDetail:setMulitHero( tArmy, bIsMe )
	if #tArmy == 1 then
		local nHeroId = tArmy[1]
		if nHeroId then
			if bIsMe then
				local pHero = Player:getHeroInfo():getHero(nHeroId)
				self:setHeroByData(pHero)
			else
				self:setHero(nHeroId)
			end
		end
	else
		self.pLayMuiltIcon:setVisible(true)
		self.pLayIcon:setVisible(false)
		for i=1,#self.pLayIcons do
			local pLayIcon = self.pLayIcons[i]
			local heroId = tArmy[i]
			if heroId then
				local pHero = nil
				if bIsMe then
					pHero =  Player:getHeroInfo():getHero(heroId)
				else
					pHero = getHeroDataById(heroId)
				end
				if pHero then
					if not pLayIcon.pHeroIcon then
						pLayIcon.pHeroIcon = getIconHeroByType(pLayIcon,TypeIconHero.NORMAL,pHero,TypeIconHeroSize.L)
						pLayIcon.pHeroIcon:setScale(0.34)
						pLayIcon.pHeroIcon:setIconIsCanTouched(false)
					else
						pLayIcon.pHeroIcon:setCurData(pHero)
					end
				end
				pLayIcon:setVisible(true)
			else
				pLayIcon:setVisible(false)
			end
		end
	end
end

-- --设置多个或一个武将
-- function ItemWorldBattleDetail:setMulitHeroByData( tArmy )
-- 	if not tArmy then
-- 		return
-- 	end

-- 	if #tArmy == 1 then
-- 		self:setHeroByData(tArmy[i])
-- 	else
-- 		self.pLayMuiltIcon:setVisible(true)
-- 		self.pLayIcon:setVisible(false)
-- 		for i=1,#self.pLayIcons do
-- 			local pLayIcon = self.pLayIcons[i]
-- 			local pHero = tArmy[i]
-- 			if pHero then
-- 				if not pLayIcon.pHeroIcon then
-- 					pLayIcon.pHeroIcon = getIconHeroByType(pLayIcon,TypeIconHero.NORMAL,pHero,TypeIconHeroSize.L)
-- 					pLayIcon.pHeroIcon:setScale(0.34)
-- 					pLayIcon.pHeroIcon:setIconIsCanTouched(false)
-- 				else
-- 					pLayIcon.pHeroIcon:setCurData(pHero)
-- 				end
-- 				pLayIcon:setVisible(true)
-- 			else
-- 				pLayIcon:setVisible(false)
-- 			end
-- 		end
-- 	end
-- end

--设置多个或一个武装将
function ItemWorldBattleDetail:setMulitHeroByHSVos( tHSVoList )
	if not tHSVoList then
		return
	end
	if #tHSVoList == 1 then
		local tHSVo = tHSVoList[1]
		if tHSVo then
			self:setHero(tHSVo:getHeroId(), tHSVo:getIg())
		end
	else
		self.pLayMuiltIcon:setVisible(true)
		self.pLayIcon:setVisible(false)
		for i=1,#self.pLayIcons do
			local pLayIcon = self.pLayIcons[i]
			local tHSVo = tHSVoList[i]
			if tHSVo then
				local pHero = getHeroDataById(tHSVo:getHeroId())
				if pHero then
					pHero = clone(pHero)
					pHero.nIg = tHSVo:getIg()
					if not pLayIcon.pHeroIcon then
						pLayIcon.pHeroIcon = getIconHeroByType(pLayIcon,TypeIconHero.NORMAL,pHero,TypeIconHeroSize.L)
						pLayIcon.pHeroIcon:setScale(0.34)
						pLayIcon.pHeroIcon:setIconIsCanTouched(false)
					else
						pLayIcon.pHeroIcon:setCurData(pHero)
					end
				end
				pLayIcon:setVisible(true)
			else
				pLayIcon:setVisible(false)
			end
		end
	end
end

--设置单个英雄
function ItemWorldBattleDetail:setHero( heroId, nIg)
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(true)
	local pHero = getHeroDataById(heroId)
	if pHero and nIg then
		pHero = clone(pHero)
		pHero.nIg = nIg
	end
	if pHero then
		if not self.pHeroIcon then
			self.pHeroIcon = getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL,pHero,TypeIconHeroSize.M)
			self.pHeroIcon:setIconIsCanTouched(false)
		else
			self.pHeroIcon:setCurData(pHero)
		end
	end
end

--设置单个英雄数据
function ItemWorldBattleDetail:setHeroByData( tHeroData )
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(true)
	if tHeroData then
		if not self.pHeroIcon then
			self.pHeroIcon = getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL,tHeroData,TypeIconHeroSize.M)
			self.pHeroIcon:setIconIsCanTouched(false)
		else
			self.pHeroIcon:setCurData(tHeroData)
		end
	end
end
-------------------------------------------------------
--来袭
function ItemWorldBattleDetail:setCityWarMsg( )
	self.pImgArrow:setVisible(true)
	self.pTxtTask:setVisible(true)
	self.pLayBtn1:setVisible(true)
	self.pLayBtn2:setVisible(true)
	self.pTxtName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayCd:setVisible(true)
	self.pLayLocation:setVisible(true)
	self.pTxtTip:setVisible(false)
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(false)
	self.pLayCityIcon:setVisible(false)
	self.pLayHeadIcon:setVisible(false)
	self.pLayCollectHeroLock:setVisible(false)
	self.pTxtPos:setVisible(false)
	
	self.pImgArrow:setCurrentImage("#v1_img_hongqian.png")
	self.pTxtTask:setString(getConvertedStr(3, 10421))
	local tCityWarMsg = self.tData
	if tCityWarMsg then
		--local sImgPath = self:getPlayerHeadImgPath(tCityWarMsg.sSenderHeadId)
		--self:setPlayerImg(sImgPath)
		self:setPlayerImg(tCityWarMsg.sSenderHeadId)
		self.pTxtName:setString(tCityWarMsg.sSenderName..getLvString(tCityWarMsg.nSenderCityLv))
		-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tCityWarMsg.nSenderX, tCityWarMsg.nSenderY))
	end
	self:setBtnTarget(self.pBtn1)
	self:setBtnHelp(self.pBtn2)
end

-- --获取玩家头像路径
-- function ItemWorldBattleDetail:getPlayerHeadImgPath( sId )
-- 	if not sId then
-- 		print("no sId")
-- 		return
-- 	end
-- 	local tAvatarIcon = getAvatarIcon(sId)
-- 	if tAvatarIcon then
-- 		return tAvatarIcon.sIcon
-- 	end
-- 	return nil
-- end

-------------------------------------------------------
--设置国战
function ItemWorldBattleDetail:setCountryWar( )
	self.pImgArrow:setVisible(true)
	self.pTxtTask:setVisible(true)
	self.pLayBtn1:setVisible(false)
	self.pLayBtn2:setVisible(true)
	self.pTxtName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayCd:setVisible(true)
	self.pLayLocation:setVisible(true)
	self.pTxtTip:setVisible(false)
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(false)
	self.pLayCityIcon:setVisible(true)
	self.pLayHeadIcon:setVisible(false)
	self.pLayCollectHeroLock:setVisible(false)
	self.pTxtPos:setVisible(true)
	if self.tData then
		--攻
		if self.tData.nAtkCountry == Player:getPlayerInfo().nInfluence then
			self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
			self.pTxtTask:setString(getConvertedStr(3, 10393))
			self.pTxtPos:setString(string.format(getConvertedStr(9,10147),self.tData.nAtkNum))
		else
			--防
			self.pImgArrow:setCurrentImage("#v1_img_hongqian.png")
			self.pTxtTask:setString(getConvertedStr(3, 10427))
			self.pTxtPos:setString(string.format(getConvertedStr(9,10148),self.tData.nDefNum))

		end
		--城池图标
		local tCityData = getWorldCityDataById(self.tData.nId)
		if tCityData then
			self.pTxtName:setString(tCityData.name.." "..getLvString(self.tData.nLv))
			-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tCityData.tCoordinate.x, tCityData.tCoordinate.y))
			WorldFunc.getSysCityIconOfContainer(self.pLayCityIcon, tCityData.id, self.tData.nDefCountry, true)
		end
	end
	self:setBtnTarget(self.pBtn2)
end

-------------------------------------------------------
--设置驻防信息（包括来的途中)
function ItemWorldBattleDetail:setHelpData( )
	self.pImgArrow:setVisible(true)
	self.pTxtTask:setVisible(true)
	self.pLayBtn1:setVisible(false)
	self.pLayBtn2:setVisible(true)
	self.pTxtName:setVisible(true)
	self.pTxtCd:setVisible(true)
	self.pLayCd:setVisible(true)
	self.pLayLocation:setVisible(true)
	self.pTxtTip:setVisible(false)
	self.pLayMuiltIcon:setVisible(false)
	self.pLayIcon:setVisible(false)
	self.pLayCityIcon:setVisible(false)
	self.pLayHeadIcon:setVisible(false)
	self.pLayCollectHeroLock:setVisible(false)
	self.pTxtPos:setVisible(false)
	if self.tData then
		--前来驻防
		local tComingHelpVO = self.tData.tComingHelpVO
		if tComingHelpVO then
			--前来驻防
			if tComingHelpVO.nType == e_type_coming_help.garrison then
				self.pTxtTask:setString(getConvertedStr(3, 10083))
				self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
				self.pTxtName:setString(tostring(tComingHelpVO.sName) .. " " .. getLvString(tComingHelpVO.nLv))
				--前来驻防只有一个武将
				local tHeroData =  tComingHelpVO:getHeroDataByIndex(1)
				if tHeroData then
					-- self.pTxtPos:setString(tHeroData.sName..getLvString(tComingHelpVO.nHeroLv).."("..tostring(tComingHelpVO.nTroops)..")")
					--武将头像
					self:setHeroByData(tHeroData)
				end
				self.pLayBtn2:setVisible(false)
			--前来协防
			elseif tComingHelpVO.nType == e_type_coming_help.help then
				self.pTxtTask:setString(getConvertedStr(3, 10429))
				self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
				self.pTxtName:setString(tostring(tComingHelpVO.sName) .. " " .. getLvString(tComingHelpVO.nLv))
				--是否等待开战中
				if tComingHelpVO:getIsWaitHelpCityWar() then
					self.pLayBtn2:setVisible(true)
					self:setBtnTarget(self.pBtn2)
				else
					self.pLayBtn2:setVisible(false)
				end
				--武将头像
				self:setMulitHeroByHSVos(tComingHelpVO.tHSVoList)
				--坐标
				-- self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(tComingHelpVO.nX, tComingHelpVO.nY))
				
			end
		end

		--已经驻防
		local tHelpMsg = self.tData.tHelpMsg
		if tHelpMsg then
			self.pTxtTask:setString(getConvertedStr(3, 10083))
			self.pImgArrow:setCurrentImage("#v1_img_lanbiaoqian.png")
			self.pTxtName:setString(tostring(tHelpMsg.sName) .. " " .. getLvString(tHelpMsg.nLv))
			local nHeroId = tHelpMsg.nHeroId
			if nHeroId then
				local tHeroData = tHelpMsg:getHeroData(nHeroId)
				if tHeroData then
					-- self.pTxtPos:setString(tostring(tHeroData.sName)..getLvString(tHelpMsg.nHeroLv).."("..tostring(tHelpMsg.nTroops)..")")
				end
				--武将头像
				self:setHeroByData(tHeroData)
			end
			self:setBtnReCall(self.pBtn2)
		end
	end
end

-------------------------------------------------------
--设置cd进度条
function ItemWorldBattleDetail:setCdBar( nCd, nCdMax )
	if not nCd or not nCdMax then
		return
	end
	if self.pCdBar then
		if nCdMax <= 0 then
			self.pCdBar:setSliderValue(100)
		else
			local fPercent = math.max(nCd/nCdMax, 0)
			local nValue = 100 - math.min(fPercent * 100, 100)
			self.pCdBar:setSliderValue(nValue)
		end
	end
end
--更新cd
function ItemWorldBattleDetail:updateCd( )
	--武奖更新cd
	if self.nTabIndex == e_wolrdbattle_tab.hero or self.nTabIndex == e_wolrdbattle_tab.collect_hero then
		--更换形态
		if self.sTaskId then
			--更新数据
			local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
			if tTask then
				--TLBoss特殊处理 已到达Boss处显示战斗中,进度条是满的
				if self.nTaskType == e_type_task.tlboss and self.nState == e_type_task_state.waitbattle then
					self.pTxtCd:setString(getConvertedStr(3, 10828))
					--进度
					self:setCdBar(0, 100)
				elseif self.nTaskType == e_type_task.imperwar and self.nState == e_type_task_state.waitbattle then
					self.pTxtCd:setString(getConvertedStr(3, 10828))
					--进度
					self:setCdBar(0, 100)
				else
					local nCd = tTask:getCd()
					if nCd then
						local sCdTitle = ""
						if self.nState == e_type_task_state.go then
							sCdTitle = getConvertedStr(3, 10133)
						elseif self.nState == e_type_task_state.back then
							sCdTitle = getConvertedStr(3, 10087)
						else
							if self.nTaskType == e_type_task.collection then
								sCdTitle = getConvertedStr(3, 10079)
							elseif self.nTaskType == e_type_task.countryWar then
								sCdTitle = getConvertedStr(3, 10082)
							elseif self.nTaskType == e_type_task.cityWar then
								sCdTitle = getConvertedStr(3, 10081)
							elseif self.nTaskType == e_type_task.garrison then
								sCdTitle = getConvertedStr(3, 10083)
							end
						end
						self.pTxtCd:setString(string.format("%s %s", sCdTitle, formatTimeToStr(nCd)))
						--进度
						self:setCdBar(nCd, tTask:getCdMax())
					end
				end
			end
		end
	elseif self.nTabIndex == e_wolrdbattle_tab.hit then
		local tCityWarMsg = self.tData
		if tCityWarMsg then
			local nCd = tCityWarMsg:getCd( )
			if nCd > 0 then
				self.pTxtCd:setString(getConvertedStr(3, 10424) .. formatTimeToStr(nCd))
			end
			self:setCdBar(nCd, tCityWarMsg:getCdMax())
		end
	elseif self.nTabIndex == e_wolrdbattle_tab.country_war then
		if self.tData then
			local nCd = self.tData:getCd( )
			if nCd > 0 then
				self.pTxtCd:setString(getConvertedStr(3, 10428) .. formatTimeToStr(nCd))
			end
			self:setCdBar(nCd, self.tData:getCdMax())
		end
	elseif self.nTabIndex == e_wolrdbattle_tab.support then
		--前来驻防
		local tComingHelpVO = self.tData.tComingHelpVO
		if tComingHelpVO then
			--前来驻防
			if tComingHelpVO.nType == e_type_coming_help.garrison then
				local nCd = tComingHelpVO:getCd()
				if nCd > 0 then
					self.pTxtCd:setString(getConvertedStr(3, 10424) .. formatTimeToStr(nCd))
				end
				self:setCdBar(nCd, tComingHelpVO:getCdMax())
			--前来协防
			elseif tComingHelpVO.nType == e_type_coming_help.help then
				if tComingHelpVO:getIsWaitHelpCityWar() then
					local nCd = tComingHelpVO:getCd()
					if nCd > 0 then
						self.pTxtCd:setString(getConvertedStr(3, 10428) .. formatTimeToStr(nCd))
					end
					self:setCdBar(nCd, tComingHelpVO:getCdMax())
					--目标按钮转换
					if not self.pLayBtn2:isVisible() then
						self.pLayBtn2:setVisible(true)
						self:setBtnTarget(self.pBtn2)
					end
				else
					local nCd = tComingHelpVO:getCd()
					if nCd > 0 then
						self.pTxtCd:setString(getConvertedStr(3, 10424) .. formatTimeToStr(nCd))
					end
					self:setCdBar(nCd, tComingHelpVO:getCdMax())
				end
			end
		end
		--已经驻防
		local tHelpMsg = self.tData.tHelpMsg
		if tHelpMsg then
			local nCd = tHelpMsg:getCd()
			if nCd > 0 then
				self.pTxtCd:setString(getConvertedStr(3, 10009) .. formatTimeToStr(nCd))
			end
			self:setCdBar(nCd, tHelpMsg:getCdMax())
		end
	end
end

--设置玩家头像
--设置玩家头像 sHeadId 头像ID 
function ItemWorldBattleDetail:setPlayerImg( sHeadId )
	self.pLayHeadIcon:setVisible(true)
	--设置玩家头像
	if sHeadId then	
		local pActorVo = ActorVo.new()
		pActorVo:initData(sHeadId, nil, nil)
		if not self.pHeadIcon then
			--背景框
			self.pHeadIcon = getIconGoodsByType(self.pLayHeadIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pActorVo, TypeIconHeroSize.M)			
		else
			self.pHeadIcon:setCurData(pActorVo)
		end
	end
end


------------------------------
--定位回调
function ItemWorldBattleDetail:onLocationClicked(  )
	if not self.tData then
		return
	end
	if not self.tData.tTask then
		return
	end
	local fX, fY = WorldFunc.getMyHeroPosByTask(self.tData.tTask)
	sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY})
	TOAST(getTipsByIndex(10074))
end


--目标定位
function ItemWorldBattleDetail:onLocationTarget(  )
	if (self.nTabIndex == e_wolrdbattle_tab.hero or self.nTabIndex == e_wolrdbattle_tab.collect_hero) and self.tData then
		if self.tData.tTask then
			local fX, fY = WorldFunc.getMapPosByDotPosEx(self.tData.tTask.nTargetX, self.tData.tTask.nTargetY)
			if self.nTabIndex == e_wolrdbattle_tab.hero then
				sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true, tOther = {bIsOpenCWar = true}})
			else
				sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
			end
			TOAST(getTipsByIndex(10074))
		end
	end

	if self.nTabIndex == e_wolrdbattle_tab.hit then
		local tCityWarMsg = self.tData
		if tCityWarMsg then
			local fX, fY = WorldFunc.getMapPosByDotPosEx(tCityWarMsg.nSenderX, tCityWarMsg.nSenderY)
			sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true, tOther = {bIsOpenCWar = true}})
			TOAST(getTipsByIndex(10074))
		end
	end

	if self.nTabIndex == e_wolrdbattle_tab.country_war and self.tData then
		local tCityData = getWorldCityDataById(self.tData.nId)
		if tCityData then
			local fX, fY = WorldFunc.getMapPosByDotPosEx(tCityData.tCoordinate.x, tCityData.tCoordinate.y)
			sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true, tOther = {bIsOpenCWar = true}})
			TOAST(getTipsByIndex(10074))
		end
	end
	--定位到我的城池
	if self.nTabIndex == e_wolrdbattle_tab.support and self.tData then
		local nX, nY = Player:getWorldData():getMyCityDotPos()
		local fX, fY = WorldFunc.getMapPosByDotPosEx(nX, nY)
		sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true, tOther = {bIsOpenCWar = true}})
		TOAST(getTipsByIndex(10074))
	end

	--隐藏出征列表
	sendMsg(ghd_show_world_battle_detail)
end

--加速回调
function ItemWorldBattleDetail:onQuickClicked(  )
	if self.sTaskId then
		local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
		if tTask then
			local tObject = {}
		    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
		    tObject.tItemList = {100030,100031}
		    tObject.tTaskCommend = { nOrder = e_type_task_input.quick, sTaskUuid = tTask.sUuid}
		    sendMsg(ghd_show_dlg_by_type,tObject)
		end
	end
end

--召回回调
function ItemWorldBattleDetail:onCallClicked(  )
	if self.sTaskId then
		local tTask = Player:getWorldData():getTaskMsgByUuid(self.sTaskId)
		if tTask then
			--前往的时候召回要弹出使用道具页面
			if tTask.nState == e_type_task_state.go then
				local tObject = {}
			    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
			    tObject.tItemList = {100032,100033}
			    tObject.tTaskCommend = { nOrder = e_type_task_input.call, sTaskUuid = tTask.sUuid}
			    sendMsg(ghd_show_dlg_by_type,tObject)
			else
				-- --驻防召回
				-- if tTask.nType == e_type_task.garrison and tTask.nState == e_type_task_state.garrison then
				-- 	SocketManager:sendMsg("reqWorldGarrisonBack", {tTask.sUuid})
				-- else
					--行军召回
					SocketManager:sendMsg("reqWorldTaskInput", {tTask.sUuid, e_type_task_input.call, nil})
				-- end
			end
		end
	end
end

--求援回调
function ItemWorldBattleDetail:onHelpClicked()
	if self.nTabIndex == e_wolrdbattle_tab.hit and self.tData then
		local tObject = {
		    nType = e_dlg_index.citywarhelp, --dlg类型
		    tViewDotMsg = Player:getWorldData():getMyViewDotMsg(),
		    tCityWarMsg = self.tData,
	    	nWarType = 1,

		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end
end

--撤回回调
function ItemWorldBattleDetail:onReCallClicked( )
	if self.nTabIndex == e_wolrdbattle_tab.support then
		local tHelpMsg = self.tData.tHelpMsg
		if tHelpMsg then
			--弹出
			local pDlg, bNew = getDlgByType(e_dlg_index.citygarrisoncall)
			if(not pDlg) then
				local DlgCityGarrisonCall = require("app.layer.world.DlgCityGarrisonCall")
			    pDlg = DlgCityGarrisonCall.new(e_dlg_index.citygarrisoncall)
			end
			pDlg:setTitle(getConvertedStr(3, 10070))
			pDlg:setData(tHelpMsg)
			pDlg:setRightHandler(function (  )
				SocketManager:sendMsg("reqWorldGarrisonBack", {tHelpMsg.sTid}, function( __msg, __oldMsg)
				    if  __msg.head.state == SocketErrorType.success then 
				        if __msg.head.type == MsgType.reqWorldTaskInput.id or __msg.head.type == MsgType.reqWorldGarrisonBack.id  then
				        	local sTid = __oldMsg[1]
				        	sendMsg(ghd_world_city_garrison_call_msg, sTid)
				        end
				    else
				        TOAST(SocketManager:getErrorStr(__msg.head.state))
				    end
				end)
				pDlg:closeDlg(false)
			end)
			pDlg:showDlg(bNew)
		end
	end
end

--撤军回调
function ItemWorldBattleDetail:onArmyLeaveClicked( )
	if self.nTabIndex == e_wolrdbattle_tab.hero then
		if self.nTaskType == e_type_task.imperwar then
			local DlgAlert = require("app.common.dialog.DlgAlert")
		    local pDlg = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		        pDlg = DlgAlert.new(e_dlg_index.alert)
		    end
		    pDlg:setTitle(getConvertedStr(3, 10936))
		    pDlg:setContent(getConvertedStr(3, 10937))
		    pDlg:setRightHandler(function (  )
		    	pDlg:closeDlg(false)
				local tTask = Player:getWorldData():getImperWarTask()
				if tTask then
					SocketManager:sendMsg("reqWorldTaskInput", {tTask.sUuid, e_type_task_input.call, nil}, function(__msg, __oldMsg)
			            if __msg.head.state == SocketErrorType.success then 
			                if __msg.head.type == MsgType.reqWorldTaskInput.id then
			               		TOAST(getConvertedStr(3, 10939))     
			                end
			            end
					end)
				end
		    end)
		    pDlg:showDlg(bNew)
		end
	end
end

--点击付费解锁
function ItemWorldBattleDetail:onUnLockBtnClick( )
	if self.pBtnUnLock and self.pBtnUnLock:isVisible() then
		local nCost = self.nUnLockCost
		local strTips = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10565)},--扩充招募队列
		}
		--展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
		    SocketManager:sendMsg("reqUnLockTcfPos", {1})
		end)
	end
end

--设置按钮返回
function ItemWorldBattleDetail:setBtnBack( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10087))
	pBtn:updateBtnType(TypeCommonBtn.O_YELLOW)
	pBtn:onCommonBtnClicked(handler(self, self.onCallClicked))
end

--设置按钮召回
function ItemWorldBattleDetail:setBtnCallBack( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10085))
	pBtn:updateBtnType(TypeCommonBtn.O_RED)
	pBtn:onCommonBtnClicked(handler(self, self.onCallClicked))
end

--设置按钮加速
function ItemWorldBattleDetail:setBtnQuick( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10084))
	pBtn:updateBtnType(TypeCommonBtn.O_YELLOW)
	pBtn:onCommonBtnClicked(handler(self, self.onQuickClicked))
end

--设置按钮目标
function ItemWorldBattleDetail:setBtnTarget( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10358))
	pBtn:updateBtnType(TypeCommonBtn.O_BLUE)
	pBtn:onCommonBtnClicked(handler(self, self.onLocationTarget))
end

--设置按钮求援
function ItemWorldBattleDetail:setBtnHelp( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10425))
	pBtn:updateBtnType(TypeCommonBtn.O_RED)
	pBtn:onCommonBtnClicked(handler(self, self.onHelpClicked))
end

--设置按钮撤回
function ItemWorldBattleDetail:setBtnReCall( pBtn )
	pBtn:updateBtnText(getConvertedStr(3, 10048))
	pBtn:updateBtnType(TypeCommonBtn.O_BLUE)
	pBtn:onCommonBtnClicked(handler(self, self.onReCallClicked))
end

--设置按钮撤军
function ItemWorldBattleDetail:setBtnArmyLeave( pBtn)
	pBtn:updateBtnText(getConvertedStr(3, 10906))
	pBtn:updateBtnType(TypeCommonBtn.O_RED)
	pBtn:onCommonBtnClicked(handler(self, self.onArmyLeaveClicked))
end



return ItemWorldBattleDetail


