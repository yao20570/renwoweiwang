----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-01-31 15:23:00
-- Description: 行军战斗细节(来袭)
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local ItemWorldBattleDetailHit = class("ItemWorldBattleDetailHit", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWorldBattleDetailHit:ctor(  )
	--解析文件
	parseView("item_world_battle_detail_hit", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWorldBattleDetailHit:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWorldBattleDetailHit", handler(self, self.onItemWorldBattleDetailHitDestroy))
end

-- 析构方法
function ItemWorldBattleDetailHit:onItemWorldBattleDetailHitDestroy(  )
    self:onPause()
end

function ItemWorldBattleDetailHit:regMsgs(  )
end

function ItemWorldBattleDetailHit:unregMsgs(  )
end

function ItemWorldBattleDetailHit:onResume(  )
	self:regMsgs()
	--开启更新cd
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()

end

function ItemWorldBattleDetailHit:onPause(  )
	self:unregMsgs()
end

function ItemWorldBattleDetailHit:setupViews(  )
	self.pTxtTask = self:findViewByName("txt_task")
	self.pImgArrow = self:findViewByName("img_arrow")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayCd = self:findViewByName("lay_cd")
	self.pTxtCd = self:findViewByName("txt_cd")
	self.pLayBtn1 = self:findViewByName("lay_btn1")
	self.pLayBtn2 = self:findViewByName("lay_btn2")
	self.pLayBtn3 = self:findViewByName("lay_btn3")
	self.pLayBtn4 = self:findViewByName("lay_btn4")
	self.pImgCountry = self:findViewByName("img_country")
	self.pLayHeadIcon = self:findViewByName("lay_head_icon")

	self.pLayLocation = self:findViewByName("lay_location")
	self.pLayLocation:setViewTouched(true)
	self.pLayLocation:setIsPressedNeedScale(false)
	self.pLayLocation:onMViewClicked(handler(self, self.onLocationTarget))

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

	self.tBtnPosX = {}

	local pBtn1 = getCommonButtonOfContainer(self.pLayBtn1,TypeCommonBtn.O_BLUE, getConvertedStr(3, 10006))
	pBtn1:onCommonBtnClicked(handler(self, self.onDetailClicked))
	setMCommonBtnScale(self.pLayBtn1, pBtn1, 0.7)

	table.insert(self.tBtnPosX,self.pLayBtn1:getPositionX())

	local pBtn2 = getCommonButtonOfContainer(self.pLayBtn2,TypeCommonBtn.O_BLUE, getConvertedStr(3, 10731))
	pBtn2:onCommonBtnClicked(handler(self, self.onLeaveClicked))
	setMCommonBtnScale(self.pLayBtn2, pBtn2, 0.7)
	table.insert(self.tBtnPosX,self.pLayBtn2:getPositionX())


	local pBtn3 = getCommonButtonOfContainer(self.pLayBtn3,TypeCommonBtn.O_BLUE, getConvertedStr(3, 10732))
	pBtn3:onCommonBtnClicked(handler(self, self.onLocationTarget))
	setMCommonBtnScale(self.pLayBtn3, pBtn3, 0.7)	
	table.insert(self.tBtnPosX,self.pLayBtn3:getPositionX())


	local pBtn4 = getCommonButtonOfContainer(self.pLayBtn4,TypeCommonBtn.O_RED, getConvertedStr(3, 10425))
	pBtn4:onCommonBtnClicked(handler(self, self.onHelpClicked))
	setMCommonBtnScale(self.pLayBtn4, pBtn4, 0.7)
	table.insert(self.tBtnPosX,self.pLayBtn4:getPositionX())

end

function ItemWorldBattleDetailHit:updateViews(  )
	--更新数据
	self:setCityWarMsg()
end

--设置数据
function ItemWorldBattleDetailHit:setData( tData, nTabIndex, nItemIndex)
	self.tData = tData
	self.nTabIndex = nTabIndex
	self.nItemIndex = nItemIndex
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

--来袭
function ItemWorldBattleDetailHit:setCityWarMsg( )
	self.pImgArrow:setCurrentImage("#v1_img_hongqian.png")
	self.pTxtTask:setString(getConvertedStr(3, 10421))
	local tCityWarMsg = self.tData
	if tCityWarMsg then
		if tCityWarMsg.nType == e_type_task.cityWar then
			self.pImgCountry:setCurrentImage(getCountryNameImg(tCityWarMsg.nSenderCountry))
			self:setPlayerImg(tCityWarMsg.sSenderHeadId)
			self.pTxtName:setString(tCityWarMsg.sSenderName..getLvString(tCityWarMsg.nSenderCityLv))
			self.pLayBtn3:setVisible(true)
			self.pLayBtn2:setVisible(true)

			self.pLayBtn1:setPositionX(self.tBtnPosX[1])
			self.pLayBtn2:setPositionX(self.tBtnPosX[2])

		elseif tCityWarMsg.nType == e_type_task.ghostdom then
			self.pImgCountry:setCurrentImage(getCountryNameImg(tCityWarMsg.nSenderCountry))
			-- self:setPlayerImg(tCityWarMsg.sSenderHeadId)
			self:setGhostImg()
			self.pTxtName:setString(tCityWarMsg.sSenderName..getLvString(tCityWarMsg.nBossLv))

			self.pLayBtn3:setVisible(false)
			self.pLayBtn2:setVisible(false)
			self.pLayBtn1:setPositionX(self.tBtnPosX[3])
			-- self.pLayBtn2:setPositionX(self.tBtnPosX[3])
		end
	end
end

--设置cd进度条
function ItemWorldBattleDetailHit:setCdBar( nCd, nCdMax )
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
function ItemWorldBattleDetailHit:updateCd( )
	local tCityWarMsg = self.tData
	if tCityWarMsg then
		local nCd = tCityWarMsg:getCd( )
		if nCd > 0 then
			self.pTxtCd:setString(getConvertedStr(3, 10424) .. formatTimeToStr(nCd))
		end
		self:setCdBar(nCd, tCityWarMsg:getCdMax())
	end
end

--设置玩家头像
--设置玩家头像 sHeadId 头像ID 
function ItemWorldBattleDetailHit:setPlayerImg( sHeadId )
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
	self.pHeadIcon:setVisible(true)
	if self.pGhostIcon then
		self.pGhostIcon:setVisible(false)
	end
end

function ItemWorldBattleDetailHit:setGhostImg(  )
	-- body
	self.pLayHeadIcon:setVisible(true)
	if not self.pGhostIcon then
		self.pGhostIcon = MUI.MImage.new(self.tData.tNpcDetailData.sIcon)
		self.pLayHeadIcon:addView(self.pGhostIcon)
		centerInView(self.pLayHeadIcon,self.pGhostIcon)
	else
		self.pGhostIcon:setCurrentImage(self.tData.tNpcDetailData.sIcon)

	end
	self.pGhostIcon:setVisible(true)
	if self.pHeadIcon then
		self.pHeadIcon:setVisible(false)
	end
end


------------------------------
--详情回调
function ItemWorldBattleDetailHit:onDetailClicked(  )
	--定位置自己的城池
	sendMsg(ghd_world_locaction_my_city_msg, {bIsOpenWar = true})
	TOAST(getTipsByIndex(10074))
	sendMsg(ghd_show_world_battle_detail)
end

--撤离回调
function ItemWorldBattleDetailHit:onLeaveClicked(  )
	if Player:getWorldData():getIsCanMove() then
		local tObject = {}
	    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
	    tObject.tItemList = {100027,100028}
	    local nX, nY = Player:getWorldData():getMyCityDotPos()
	    tObject.tCityMove = {nX = nX, nY = nY}
	    tObject.bIsFromCityWar = true
	    sendMsg(ghd_show_dlg_by_type,tObject)
	else
		TOAST(getTipsByIndex(538))
	end
end

--目标定位
function ItemWorldBattleDetailHit:onLocationTarget(  )
	local tCityWarMsg = self.tData
	if tCityWarMsg and tCityWarMsg.nSenderX and tCityWarMsg.nSenderY then
		local fX, fY = WorldFunc.getMapPosByDotPosEx(tCityWarMsg.nSenderX, tCityWarMsg.nSenderY)
		sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true, tOther = {bIsOpenCWar = true}})
		TOAST(getTipsByIndex(10074))
		--隐藏出征列表
		sendMsg(ghd_show_world_battle_detail)
	end
end

--求援回调
function ItemWorldBattleDetailHit:onHelpClicked()
	if self.nTabIndex == e_wolrdbattle_tab.hit and self.tData then
		local tObject = {}
		if self.tData.nType == e_type_task.cityWar then
			tObject = {
			    nType = e_dlg_index.citywarhelp, --dlg类型
			    tViewDotMsg = Player:getWorldData():getMyViewDotMsg(),
			    tCityWarMsg = self.tData,
			    nWarType = 1,
			}
		elseif self.tData.nType == e_type_task.ghostdom then
			tObject = {
				nType = e_dlg_index.citywarhelp, --dlg类型
				tViewDotMsg = Player:getWorldData():getMyViewDotMsg(),
				tCityWarMsg = self.tData,
				nWarType = 3,
			}
		end
		sendMsg(ghd_show_dlg_by_type, tObject)
	end
end


return ItemWorldBattleDetailHit


