----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-12 20:28:29
-- Description: 城池点击弹出面板
-----------------------------------------------------
local DlgAlert = require("app.common.dialog.DlgAlert")
local MCommonView = require("app.common.MCommonView")
local e_conf_type = {
	myCity = 1,
	friendCity = 2,
	enemyCity = 3,
	sysCity = 4,
	null = 6,
	boss = 10,
	bossInBlock = 11,
	tlboss = 12,
	imperwar = 13,
}
local nTaiwei = 3 --太尉

local CityClickLayer = class("CityClickLayer",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView

end)

function CityClickLayer:ctor(  )
	--自己所属国家
	self.nMyCountry = Player:getPlayerInfo().nInfluence

	--修改成2秒，为了不在网络不好时一直请求，之前这个配表值好像删掉了，导致快速请求
	self.nRankTime = 2--tonumber(getBossInitData("rankTime"))/1000

	

	--解析文件
	parseView("layout_world_city_click", handler(self, self.onParseViewCallback))
end

function CityClickLayer:regMsgs(  )
	--行军任务更改，限时Boss按钮高亮
	regMsg(self, gud_world_task_change_msg, handler(self, self.onTaskChange))
	--状态发生更改，限时Boss按钮变化
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.onTLBossChange))
	--限时Boss攻击cd变化
	regMsg(self, ghd_tlboss_attack_cd, handler(self, self.onTLBossAttackCd))
	--限时Boss强击cd变化
	regMsg(self, ghd_tlboss_sattack_cd, handler(self, self.onTLBossSAttackCd))
	--开战期间，战场按钮出现高亮特效
	regMsg(self, ghd_imperialwar_open_state, handler(self, self.onImperialWarState))
end

function CityClickLayer:unregMsgs(  )
	unregMsg(self, gud_world_task_change_msg)

	unregMsg(self, gud_tlboss_data_refresh)

	unregMsg(self, ghd_tlboss_attack_cd)

	unregMsg(self, ghd_tlboss_sattack_cd)
	
	unregMsg(self, ghd_imperialwar_open_state)
end

function CityClickLayer:onPause(  )
	self:unregMsgs()
end

function CityClickLayer:setHide(  )
	sendMsg(ghd_world_hide_city_click_msg)
end

--解析界面回调
function CityClickLayer:onParseViewCallback( pView )
	self:regMsgs()

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self.pCCSView = pView

	self.pTxtPos = self:findViewByName("txt_pos")
	self.pImgNameBg = self:findViewByName("img_name_bg")
	self.pLayBtnBg = self:findViewByName("lay_btn_bg")
	self.pLayBtnBg:setPositionY(self.pLayBtnBg:getPositionY() - 80  + 30)
	self.pImgCircle = self:findViewByName("img_circle")
	self.pLayView = self:findViewByName("view")

	--基本配置
	--按钮位置poses
	self.pLayBtns = {}
	self.tBtnPoses = {
		[1] = {cc.p(189, -15)},
		[2] = {cc.p(69 + 27, 36 - 27), cc.p(313 - 27, 36 - 27)},
		[3] = {cc.p(69, 36), cc.p(191, -15), cc.p(313, 36)},
		[4] = {cc.p(25, 54), cc.p(124, -18), cc.p(251, -18), cc.p(351, 54)},
		[5] = {cc.p(-10, 70), cc.p(73, 0), cc.p(188, -28), cc.p(303, 0), cc.p(388, 70)},
	}
	self.tConfig = {
		--点击我的城池
		[e_conf_type.myCity] = {
			{nType = TypeCirleBtn.PROTECT, func = self.onProtectClicked},--保护
			{nType = TypeCirleBtn.ENTER, func = self.onEnterClicked},--进入
			{nType = TypeCirleBtn.SHARE, func = self.onShareClicked},--分享
		},
		--同势力玩家城池
		[e_conf_type.friendCity] = {
			{nType = TypeCirleBtn.CHAT, func = self.onChatClicked},
			{nType = TypeCirleBtn.GARRRISON, func = self.onGarrisonClicked},
			{nType = TypeCirleBtn.SHARE, func = self.onShareClicked},
		},
		--其他势力城池
		[e_conf_type.enemyCity] = {
			{nType = TypeCirleBtn.CHAT, func = self.onChatClicked},
			{nType = TypeCirleBtn.DETECT, func = self.onDetectClicked},
			{nType = TypeCirleBtn.CITYWAR, func = self.onCityWarClicked},
			{nType = TypeCirleBtn.SHARE, func = self.onShareClicked},
		},
		--系统城池
		[e_conf_type.sysCity] = {
			{nType = TypeCirleBtn.DETAIL, func = self.onDetailClicked}, --详情
			{nType = TypeCirleBtn.SHARE, func = self.onShareClicked}, --分享
		},
		--点击空地
		[e_conf_type.null] = {
			{nType = TypeCirleBtn.MOVECITY, func = self.onMoveCityClicked},
		},
		--点击Boss
		[e_conf_type.boss] = {
			{nType = TypeCirleBtn.DETAIL, func = self.onDetailClicked},
			{nType = TypeCirleBtn.BOSSWAR, func = self.onBossWarClicked},
			{nType = TypeCirleBtn.SHARE, func = self.onShareClicked},
		},
		-- 从背包或活动跳过来且有Boss活动且在同一区域，只显示召唤纣王
		[e_conf_type.bossInBlock] = {
			{nType = TypeCirleBtn.BOSS, func = self.onBossCallClicked},
		},
		--点击限时Boss
		[e_conf_type.tlboss] = {
			{nType = TypeCirleBtn.SHARE, func = self.onShareClicked},
		},
		--决战阿房宫
		[e_conf_type.imperwar] = {
			{nType = TypeCirleBtn.BATTLEFIELD, func = self.onDetailClicked}, --详情
			{nType = TypeCirleBtn.SHARE, func = self.onShareClicked}, --分享
		}
	}

	self.nJumpType=0

	self.nScale = 1

	self.pBtnEffects={}

	--注册析构方法
	self:setDestroyHandler("CityClickLayer", handler(self, self.onCityClickLayerDestroy))
end

function CityClickLayer:onCityClickLayerDestroy(  )
	unregUpdateControl(self)
	self:onPause()
end

--tData:tViewDotMsg
function CityClickLayer:setData( tData )
	self.tData = tData
	--限时Boss
	if self.tData.nType == e_type_builddot.tlboss then --TLBoss
		self.bIsTLBossAttacking = false --当前没有攻击
		self.bIsReqing = false
		--更新显示Cd时间
		regUpdateControl(self, handler(self, self.updateTLBossCd))
		--显示榜单
		if not b_open_ios_shenpi then
			sendMsg(ghd_show_tlboss_small_rank, true)
		end
		Player:getTLBossData():setIsShowedFinger(true)
	else
		--关Cd
		unregUpdateControl(self)
		--隐藏榜单
		sendMsg(ghd_show_tlboss_small_rank, false)
	end
	--更新视窗
	self:updateViews()
end

--获取按钮层
function CityClickLayer:getLayBtn( nIndex )
	if self.pLayBtns[nIndex] then
		self.pLayBtns[nIndex]:setVisible(false)
		return self.pLayBtns[nIndex]
	end

	local pLayBtn = MUI.MLayer.new()
	pLayBtn:setVisible(false)
	pLayBtn:setLayoutSize(100, 100)
	self.pLayBtnBg:addView(pLayBtn)
	self.pLayBtns[nIndex] = pLayBtn

	return pLayBtn
end

--设置配置
function CityClickLayer:setConfig( nId )
	--移除高亮效果
	self:removeEffect()

	--隐藏之前的
	self.pBtnTLBossAtk = nil
	self.pBtnTLBossSAtk = nil
	self.pBtnTLBossDispatch = nil
	self.pBtnEpwBattlefiled = nil
	for k,v in pairs(self.pLayBtns) do
		v:setVisible(false)
	end
	local pLayBtns = {}
	local tConf = self.tConfig[nId]
	if tConf then
		--复制
		tConf = clone(tConf)
		--更新配置
		if nId == e_conf_type.myCity then --我的城池
			if Player:getWorldData():getOtherIsAttackMe() then --被打的时候
				table.insert(tConf, 3, {nType = TypeCirleBtn.JOINWAR, func = self.onCityWarClicked})
			end			
			--官职开启
			if Player:getCountryData():getIsHasOfficial() then
				table.insert(tConf, 1, {nType = TypeCirleBtn.CALL, func = self.onCallPlayerClicked})
			end
		elseif nId == e_conf_type.imperwar then --决战阿房宫
			if Player:getImperWarData():getImperWarIsOpen() then
				local bIsCanUsed = false
				local tCountryDataVo = Player:getCountryData():getCountryDataVo()
				if tCountryDataVo then
					bIsCanUsed = tCountryDataVo:getIsOfficialEnough(nTaiwei)
				end
				if bIsCanUsed then
					table.insert(tConf, 2, {nType = TypeCirleBtn.TOGETHER, func = self.onTogetherClicked})
				end
			end
		elseif nId == e_conf_type.friendCity then --同势力玩家城池
			if self.tData.bIsHasCityWar then
				table.insert(tConf, 3, {nType = TypeCirleBtn.JOINWAR, func = self.onCityWarClicked})
			end
		elseif nId == e_conf_type.sysCity then --系统城池
			--是否我的国家
			if self.tData:getDotCountry() == Player:getPlayerInfo().nInfluence then
				--可以补城防
				if self.tData:getIsCanFillCityDef() then
					table.insert(tConf, 2, {nType = TypeCirleBtn.FILLCDEF, func = self.onSysCityFillCDef})		
				end
				--可以申请城主
				if WorldFunc.getIsSCityCanExclamation(self.tData.nSystemCityId) then
					table.insert(tConf, 2, {nType = TypeCirleBtn.ELECT, func = self.onSysCityElectClicked})		
				end
				--可以攻打的城池且有城战
				if self.tData:getIsCanCountryWar() and self.tData.bIsHasCountryWar then
					table.insert(tConf, 2, {nType = TypeCirleBtn.COUNTRYWAR, func = self.onCountryWarClicked})
				end
			else
				--国战
				table.insert(tConf, 2, {nType = TypeCirleBtn.COUNTRYWAR, func = self.onCountryWarClicked})
			end
		elseif nId == e_conf_type.null then --空地
			--武王活动期间
			local tData = Player:getActById(e_id_activity.wuwang)
			if tData then
				local nMyBlockId = Player:getWorldData():getMyCityBlockId()
				local nBlockId = WorldFunc.getBlockId(self.tData.nX, self.tData.nY)
				if nMyBlockId == nBlockId then
					if self.nJumpType == e_jumpto_world_type.activity or self.nJumpType==e_jumpto_world_type.bag then
						tConf = self.tConfig[e_conf_type.bossInBlock] --重置
					else
						table.insert(tConf, 2, {nType = TypeCirleBtn.BOSS, func = self.onBossCallClicked})
					end
				end
			end
		elseif nId == e_conf_type.tlboss then --限时Boss
			--准备期间若玩家部队已到达BOSS，则出现攻击和五连击按钮
			local nState = Player:getTLBossData():getCdState()
			self.nTLBossState = nState
			if nState == e_tlboss_time.ready or nState == e_tlboss_time.begin then
				local bIsIn = Player:getWorldData():getHasWaitBattleTask(e_type_task.tlboss, self.tData.nX, self.tData.nY)
				if bIsIn then
					table.insert(tConf, 1, {nType = TypeCirleBtn.FIVEHIT, func = self.onTLBossFiveHitClicked})
					table.insert(tConf, 1, {nType = TypeCirleBtn.ATTACK, func = self.onTLBossAttackClicked})
				end
			end

			--Boss死亡只显示榜单和分享
			if not Player:getTLBossData():getIsTLBossDeath() then
				table.insert(tConf, 1, {nType = TypeCirleBtn.DISPATCH, func = self.onTLBossDispatchClicked})
			end

			--默认显示(禁止时屏蔽)
			if not b_open_ios_shenpi then
				--榜单按钮
				table.insert(tConf, 1, {nType = TypeCirleBtn.RANK, func = self.onTLBossRankClicked})
			end
		end

		--设置按钮
		local tPoses = self.tBtnPoses[#tConf]
		for i=1,#tConf do
			local nBtnType = tConf[i].nType
			local pLayBtn = self:getLayBtn(i)
			local pBtnCircle = getCircleBtnOfContainer(pLayBtn, nBtnType, 0.8)
			pBtnCircle:setTouchCatchedInList(true)
			pBtnCircle:onCommonBtnClicked(handler(self, tConf[i].func))
			table.insert(pLayBtns, pLayBtn)
			--清容cd时间
			if nBtnType == TypeCirleBtn.ATTACK then
				self.pBtnTLBossAtk = pBtnCircle
				self.pBtnTLBossAtk:setGoldText(tonumber(getBossInitData("fightCost")))
				self:onTLBossAttackCd()
			elseif nBtnType == TypeCirleBtn.FIVEHIT then
				self.pBtnTLBossSAtk = pBtnCircle
				self.pBtnTLBossSAtk:setGoldText(tonumber(getBossInitData("stormCost")))
				self:onTLBossSAttackCd()
			else
				pBtnCircle:setCdText(nil)
				pBtnCircle:setGoldTxtVisible(false)
				pBtnCircle:stopCdBlack()

				if nBtnType == TypeCirleBtn.BATTLEFIELD then
					self.pBtnEpwBattlefiled = pBtnCircle
					self:onImperialWarState()
				elseif nBtnType == TypeCirleBtn.DISPATCH then
					self.pBtnTLBossDispatch = pBtnCircle
					self:onDispatchRing()
				end
			end
				
			if tPoses[i] then
				local nX, nY = tPoses[i].x, tPoses[i].y
				local nOffsetX, nOffsetY = 0, 0
				pLayBtn:setPosition(nX + nOffsetX, nY + nOffsetY)
			end
			-- showYellowRing(pLayBtn,2,nil,1,nil,Scene_arm_type.world)
			
			--按钮加特效
			local bIsLight = false
			if ((nBtnType == TypeCirleBtn.CITYWAR or nBtnType == TypeCirleBtn.JOINWAR) and self.tData.bIsHasCityWar) or 
				(nBtnType == TypeCirleBtn.COUNTRYWAR and self.tData.bIsHasCountryWar) or
				(nBtnType == TypeCirleBtn.BOSSWAR and self.tData.bIsHasBossWar) then
				bIsLight = true
			end
				--todo
			--高亮效果
			if bIsLight then
				local pRing=showYellowRing2(pBtnCircle,2,nil,1,nil,Scene_arm_type.world)
				table.insert(self.pBtnEffects,pRing)
			end
		end
		if #tConf == 4 then
			self.nScale = 1
		elseif #tConf == 5 then
			self.nScale = 1.1
		else
			self.nScale = 0.8
		end
		self.nShowConf = #tConf
		self.pImgCircle:setPositionY(170-(1-self.nScale)*85)
	end
	self:showTx()
	return pLayBtns
end

--显示特效
function CityClickLayer:showTx()
	self.pImgCircle:setOpacity(0)
	self.pImgCircle:setScale(0.7)
	local tAction_1 = cc.Spawn:create(cc.ScaleTo:create(0.15, self.nScale + self.nScale*0.02), cc.FadeIn:create(0.2))
	local tAction_2 = cc.ScaleTo:create(0.3,self.nScale)
	self.pImgCircle:runAction(cc.Sequence:create(tAction_1, tAction_2))

	local nNum = 0
	local function showCb()
		nNum = nNum + 1
		if self.nShowConf >= nNum then
			if self.pLayBtns[nNum] then
				local btn = self.pLayBtns[nNum]:findViewByTag(20170724)
				if btn then
					self.pLayBtns[nNum]:setVisible(true)
					btn:showTx()
					self:runAction(cc.Sequence:create(cc.DelayTime:create(0.04), cc.CallFunc:create(showCb)))
				end
			end
		end
	end
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(showCb)))
end

--按钮上转圈特效
function CityClickLayer:showCircleTx(_parent)
	-- body
	if _parent == nil then return end
	--转圈特效
	local pImgRing = MUI.MImage.new("#sg_zjm_rwtih_fk_sdx_xx1.png", {scale9=false})
	_parent:addView(pImgRing, 99)
	pImgRing:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgRing:setScale(_parent:getWidth()/pImgRing:getWidth())
	pImgRing:setPosition(_parent:getWidth()/2, _parent:getHeight()/2)
	pImgRing:setRotation(0)
	local action1 = cc.RotateTo:create(0.5, 180)
	local action2 = cc.RotateTo:create(0.5, 360)
	pImgRing:runAction(cc.RepeatForever:create(cc.Sequence:create(action1, action2)))
	return pImgRing
end

--更新视图
function CityClickLayer:updateViews()
	if not self.tData then
		return
	end
	local bIsShowPos = true
	if self.tData.nType == e_type_builddot.null then
		self:setConfig(e_conf_type.null)
		-- self.pTxtPos:setString(getConvertedStr(3, 10175))
		-- setTextCCColor(self.pTxtPos, _cc.white)
		self.pTxtPos:setString(string.format(getConvertedStr(3, 10174), self.tData.nX, self.tData.nY))
		setTextCCColor(self.pTxtPos, _cc.yellow)
	else
		self.pTxtPos:setString(string.format(getConvertedStr(3, 10174), self.tData.nX, self.tData.nY))
		setTextCCColor(self.pTxtPos, _cc.yellow)
	
		--判断是玩家城池还是系统城池
		if self.tData.nSystemCityId then --系统城池
			local tCityData = getWorldCityDataById(self.tData.nSystemCityId)
			if tCityData and tCityData.kind == e_kind_city.zhongxing or tCityData.kind == e_kind_city.firetown then
				self:setConfig(e_conf_type.imperwar)
			else
				self:setConfig(e_conf_type.sysCity)
			end
		elseif self.tData.nType == e_type_builddot.city then --城池
			local nCountry = self.tData:getDotCountry()
			if self.tData:getIsMe() then --我自己的城池
				self:setConfig(e_conf_type.myCity)
			elseif self.nMyCountry == nCountry then --同势力玩家城池
				self:setConfig(e_conf_type.friendCity)
			else --敌方城池
				self:setConfig(e_conf_type.enemyCity)
			end
		elseif self.tData.nType == e_type_builddot.boss then --Boss
			self:setConfig(e_conf_type.boss)

			self.pTxtPos:setString(string.format(getConvertedStr(3, 10174), self.tData.nX, self.tData.nY))
			setTextCCColor(self.pTxtPos, _cc.yellow)
		elseif self.tData.nType == e_type_builddot.tlboss then --TLBoss
			self:setConfig(e_conf_type.tlboss)
			self:updateTLBossCd()
			bIsShowPos = false
		end
	end
	self.pTxtPos:setVisible(bIsShowPos)
	self.pImgNameBg:setVisible(bIsShowPos)
end

--迁城点击
function CityClickLayer:onMoveCityClicked( pView)
	if Player:getWorldData():getIsCanMove() then
		local tObject = {}
	    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
	    tObject.tItemList = {100027,100028,100029}
	    tObject.tCityMove = {nX = self.tData.nX, nY = self.tData.nY}
	    sendMsg(ghd_show_dlg_by_type,tObject)
	else
		TOAST(getTipsByIndex(538))
	end
end

--召唤
function CityClickLayer:onCallPlayerClicked( pView)
	local tObject = {}
	tObject.nType = e_dlg_index.callplayer --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)

	self:setHide()
end

--保护点击
function CityClickLayer:onProtectClicked( pView )
	-- myprint("CityClickLayer:onProtectClicked")
	local tObject = {}
	tObject.nType = e_dlg_index.getcityprotect --dlg类型
	tObject.nIndex = 1
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--进入按钮
function CityClickLayer:onEnterClicked( pView )
	-- myprint("CityClickLayer:onEnterClicked")
	self:setHide()
	sendMsg(ghd_home_show_base_or_world, 1)
end

--分享按钮
function CityClickLayer:onShareClicked( pView )
	-- dump(self.tData)
	self:setHide()
	if self.tData.nType == e_type_builddot.boss then --纣王
		local tData = {
			dn = self.tData.sDotName,
			dx = self.tData.nX,
			dy = self.tData.nY,
			dl = self.tData.nBossLv,
			dt = e_share_type.boss
		}
		openShare(pView, e_share_id.boss, tData)
	elseif self.tData.nType == e_type_builddot.tlboss then --限时Boss
		local tData = {
			dn = self.tData.sDotName,
			dx = self.tData.nX,
			dy = self.tData.nY,
			dt = e_share_type.tlboss
		}
		openShare(pView, e_share_id.tlboss_pos, tData)
	elseif self.tData:getIsMe() then  --分享我的坐标
		local tData = {
			dc = self.tData.nDotCountry,
			dn = self.tData.sDotName,
			dl = self.tData.nLevel,
			dx = self.tData.nX,
			dy = self.tData.nY,
			dt = e_share_type.player
		}
		openShare(pView, e_share_id.role_pos, tData)
	elseif self.tData.nSystemCityId then --系统城池 --分享的是城池坐标  
		local tData = {
			bn = WorldFunc.getBlockId(self.tData.nX, self.tData.nY),
			dn = self.tData.sDotName,
			dx = self.tData.nX,
			dy = self.tData.nY,
			dt = e_share_type.syscity,
			dc = self.tData.nDotCountry,
			dl = self.tData.nLevel,
			did = self.tData.nSystemCityId
		}
		openShare(pView, e_share_id.city_pos, tData)
	else
		local tData = {
			bn = WorldFunc.getBlockId(self.tData.nX, self.tData.nY),
			dn = self.tData.sDotName,
			dx = self.tData.nX,
			dy = self.tData.nY,
			dt = e_share_type.city,
			dc = self.tData.nDotCountry,
			dl = self.tData.nLevel,
		}
		openShare(pView, e_share_id.role_pos, tData)
	end
end

--侦查按钮
function CityClickLayer:onDetectClicked( pView )
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citydetail, --dlg类型
	    nIndex = 2,
	    --
	    tViewDotMsg = self.tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)

	self:setHide()
end

--城战按钮
function CityClickLayer:onCityWarClicked( pView )
	sendMsg(ghd_send_city_war_req, self.tData)
	-- --如果是目标城池是自己且自己被打
	-- if self.tData:getIsMe() and Player:getWorldData():getOtherIsAttackMe() then
	-- 	--不拦截请求
	-- else
	-- 	--等级不足
	-- 	local nNeedLv = getWorldInitData("castkeWarOpen")
	-- 	if Player:getPlayerInfo().nLv < nNeedLv then
	-- 		TOAST(string.format(getConvertedStr(3, 10101), nNeedLv))
	-- 		return
	-- 	end
	-- end
	-- SocketManager:sendMsg("reqWorldCityWarInfo", {self.tData.nCityId}, handler(self, self.onWorldCityWarInfo))
	self:setHide()
end

--详情按钮
function CityClickLayer:onDetailClicked( pView )
	if self.tData.nType == e_type_builddot.boss then --详情
		--不存在了
		local tViewDotMsg = Player:getWorldData():getBossViewDotByPos(self.tData.nX, self.tData.nY)
		if not tViewDotMsg then
			TOAST(getConvertedStr(3, 10505))
			return
		end

		--离开了
		if self.tData:getBossLeaveCd() <= 0 then
			TOAST(getConvertedStr(3, 10505))
			return
		end

		--发送消息打开dlg
		local tObject = {
		    nType = e_dlg_index.zhouwangdetail, --dlg类型
		    tViewDotMsg = self.tData,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	elseif self.tData.nType == e_type_builddot.sysCity then --系统城池
		local tObject = {
		    nType = e_dlg_index.syscitydetail, --dlg类型
		    nSystemCityId = self.tData.nSystemCityId,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	end

	self:setHide()
end

--国战按钮
function CityClickLayer:onCountryWarClicked( pView )
	self:setHide()
	sendMsg(ghd_world_country_war_req_msg, self.tData.nSystemCityId)
end

--私聊按钮
function CityClickLayer:onChatClicked( pView )
	--myprint("CityClickLayer:onChatClicked")
	--dump(self.tData, "self.tData", 100)
	-- local tObject = {} 
	-- tObject.nType = e_dlg_index.dlgchat --dlg类型
	-- tObject.nChatType = e_lt_type.sl --聊天类型
	-- tObject.tPChatInfo = {
	-- 	nPlayerId = self.tData.nCityId,
	-- 	sPlayerName = self.tData.sName,
	-- }
	-- dump(self.tData, "self.tData", 100)
	-- sendMsg(ghd_show_dlg_by_type,tObject)

	local pMsgObj = {}
	pMsgObj.nplayerId =self.tData.nCityId
	pMsgObj.bToChat = true
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)	
end

--驻防按钮
function CityClickLayer:onGarrisonClicked( pView )
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citygarrison, --dlg类型
	    tViewDotMsg = self.tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)

	self:setHide()
end

--Boss召唤
function CityClickLayer:onBossCallClicked( pView )
	local tObject = {}
    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
    tObject.tItemList = {e_id_item.bossCallS, e_id_item.bossCallL, e_id_item.bossCallH}
    tObject.tBossPos = {nX = self.tData.nX, nY = self.tData.nY}
    sendMsg(ghd_show_dlg_by_type,tObject)
end

--Boss讨伐
function CityClickLayer:onBossWarClicked( pView )
	self:setHide()
	
	------------------------znftodo 可以统一代码
	--不存在了
	local tViewDotMsg = Player:getWorldData():getBossViewDotByPos(self.tData.nX, self.tData.nY)
	if not tViewDotMsg then
		TOAST(getConvertedStr(3, 10505))
		return
	end

	--离开了
	if self.tData:getBossLeaveCd() <= 0 then
		TOAST(getConvertedStr(3, 10505))
		return
	end

	--表数据
	local tAwakeBoss = getAwakeBossData(self.tData.nBossLv, Player:getWuWangDiff())
	if not tAwakeBoss then
		return
	end

	--等级限制
	local nLvNeed = getAwakeInitData("evilOpen")
	if nLvNeed and Player:getPlayerInfo().nLv < nLvNeed then
		TOAST(string.format(getTipsByIndex(20097),nLvNeed))
		return
	end

	local nX, nY = self.tData.nX, self.tData.nY
	--不可以跨区
	if not Player:getWorldData():getIsCanWarByPos(nX, nY, e_war_type.boss) then
		TOAST(getTipsByIndex(20032))
		return
	end
					
	--已经有战斗列表
	if self.tData.bIsHasBossWar then
		--获取Boss战列表
		SocketManager:sendMsg("reqWorldBossWarList",{nX, nY, tAwakeBoss})
	else
		--二次确认
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    local tStr = {
	        {color=_cc.white,text=getConvertedStr(3, 10506)},
	        {color=_cc.blue,text= string.format("%s", tAwakeBoss.name)},
	        {color=_cc.white,text=getConvertedStr(3, 10507)},
	    }
	    pDlg:setContent(tStr)
	    pDlg:setRightHandler(function (  )
	    	pDlg:closeDlg(false)

	    	--发起Boss战
	        SocketManager:sendMsg("reqWorldBossWar" ,{nX, nY})
	        closeDlgByType( e_dlg_index.zhouwangdetail, false)
		end)
	    pDlg:showDlg(bNew)
	end
end

--系统城池申请
function CityClickLayer:onSysCityElectClicked(  )
	self:setHide()
	
	-----------------------------znftodo 可以统一入口
	--是否满足级数
	local nNeedLv = getWorldInitData("leaderLvLimit")
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10447), nNeedLv))
		return
	end

	local nSysCityId = self.tData.nSystemCityId
	if not nSysCityId then
		return
	end
	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	if not tViewDotMsg then
		return
	end
	--有城的情况下直接返回
	local bIsBe = Player:getCountryData():isPlayerBeCityMaster()
	if bIsBe then
		TOAST(getTipsByIndex(568))
		return
	end
	--判断是否已经申请中
	-- if tViewDotMsg.bIsApplyCityOwner then
		--申请候选人命令
		SocketManager:sendMsg("reqWorldCityCandidate", {nSysCityId, 0})
	-- else

	-- 	--打开申请界面
	-- 	local tObject = {
	-- 	    nType = e_dlg_index.cityownerapply, --dlg类型
	-- 	    nSysCityId = nSysCityId,
	-- 	}
	-- 	sendMsg(ghd_show_dlg_by_type, tObject)
	-- end
end

--系统城池补充城防
function CityClickLayer:onSysCityFillCDef(  )
	self:setHide()

	local nSysCityId = self.tData.nSystemCityId
	if not nSysCityId then
		return
	end

	local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
	if not tViewDotMsg then
		return
	end

	if tViewDotMsg:getIsCanFillCityDef() then
		WorldFunc.fillSysCityTroops(nSysCityId)
	else
		TOAST(getConvertedStr(3, 10371))
	end
end

--限时Boss榜单
function CityClickLayer:onTLBossRankClicked( )
	sendMsg(ghd_show_tlboss_small_rank)
end

--限时Boss派遣
function CityClickLayer:onTLBossDispatchClicked(  )
	--等级
	local nNeedLv = tonumber(getBossInitData("openLevel"))
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10827), nNeedLv))
		return
	end

	--当前
    local nBlockId = WorldFunc.getBlockId(self.tData.nX, self.tData.nY)
    local nMyBlockId = Player:getWorldData():getMyCityBlockId()
    if nMyBlockId ~= nBlockId then
		--只能派遣到所在地图的魔神，是否前往派遣？
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(3, 10832))
	    pDlg:setRightHandler(function (  )
	    	--当前
	    	local tBLocatVo = Player:getTLBossData():getBLocatVo(nMyBlockId)
	    	if tBLocatVo then
	    		sendMsg(ghd_world_location_dotpos_msg, {nX = tBLocatVo:getX(), nY = tBLocatVo:getY(), isClick = true})
	    	end
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)
	    return
	end

	--隐藏
	self:setHide()
	
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.battlehero, --dlg类型
	    nIndex = 9,--参加Boss
	    tViewDotMsg = self.tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--限时Boss攻击
function CityClickLayer:onTLBossAttackClicked(  )
	local nNeedLv = tonumber(getBossInitData("openLevel"))
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10827), nNeedLv))
		return
	end

	--活动未开始或活动已结束
	local nState = Player:getTLBossData():getCdState()
	if nState == e_tlboss_time.ready then
		TOAST(getConvertedStr(3, 10839))
		return
	elseif nState == e_tlboss_time.no then
		TOAST(getConvertedStr(3, 10826))
		return
	end

	--是否在攻击中，是就反回
	if self.bIsTLBossAttacking then
		return
	end

	--快速点击拦截
	local function reqCallBack(__msg, __oldMsg)
        self.bIsTLBossAttacking = false
	end

	--是否免费
	local nCd = Player:getTLBossData():getAttackCd()
	if nCd <= 0 then
		self.bIsTLBossAttacking = true
	 	SocketManager:sendMsg("reqTLBossAttack", {0}, reqCallBack)
	 	-- self:setHide() --Boss攻击不关
	else
		--黄金攻击
		local nCost = tonumber(getBossInitData("fightCost"))
		if nCost then
			local strTips = {
			    {color=_cc.pwhite,text=getConvertedStr(3, 10823)},
			}
			--展示购买对话框
			showBuyDlg(strTips,nCost,function (  )
				self.bIsTLBossAttacking = true
			    SocketManager:sendMsg("reqTLBossAttack", {1}, reqCallBack)
			    -- self:setHide() --Boss攻击不关
			end)
		end
	end
end

--限时Boss五连击
function CityClickLayer:onTLBossFiveHitClicked(  )
	local nNeedLv = tonumber(getBossInitData("openLevel"))
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10827), nNeedLv))
		return
	end
	
	--活动未开始或活动已结束
	local nState = Player:getTLBossData():getCdState()
	if nState == e_tlboss_time.ready then
		TOAST(getConvertedStr(3, 10839))
		return
	elseif nState == e_tlboss_time.no then
		TOAST(getConvertedStr(3, 10826))
		return
	end

	--是否有cd时间，是就不可以5连击
	local nCd = Player:getTLBossData():getSAttackCd()
	if nCd > 0 then
		TOAST(getConvertedStr(3, 10825))
	 	return
	end
	--黄金攻击
	local nCost = tonumber(getBossInitData("stormCost"))
	if nCost then
		local strTips = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10824)},
		}
		--展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
		    SocketManager:sendMsg("reqTLBossSAttack", {})
		    -- self:setHide() --Boss攻击不关
		end)
	end
end

-- --发起城战返回
-- function CityClickLayer:onWorldCityWarInfo( __msg  )
-- 	--发起单个城战
-- 	local function showCityWarSingle()
-- 		--如果是同势力就不发起城战
--     	if Player:getPlayerInfo().nInfluence == self.tData.nDotCountry then
--     		TOAST(getConvertedStr(3, 10297))
--     	else
-- 			--发送消息打开dlg
-- 			local tObject = {
-- 			    nType = e_dlg_index.citydetail, --dlg类型
-- 			    nIndex = 1,
-- 			    --
-- 			    tViewDotMsg = self.tData,
-- 			}
-- 			sendMsg(ghd_show_dlg_by_type, tObject)
-- 		end
-- 	end

-- 	--dump(__msg.body)
--     if  __msg.head.state == SocketErrorType.success then 
--         if __msg.head.type == MsgType.reqWorldCityWarInfo.id then
--         	--多人战检测
--         	if __msg.body.wars and #__msg.body.wars > 0 then
        		
-- 				--转成本地数据
-- 				local tCityWarMsgs = {}
-- 				for i=1,#__msg.body.wars do
-- 					table.insert(tCityWarMsgs, CityWarMsg.new(__msg.body.wars[i]))
-- 				end
-- 				--倒计时排列
-- 				table.sort(tCityWarMsgs, function ( a , b )
-- 					return a:getCd() < b:getCd()
-- 				end)

-- 				--发送消息打开dlg
-- 				local tObject = {
-- 				    nType = e_dlg_index.citywar, --dlg类型
-- 				    --
-- 				    tCityWarMsgs = tCityWarMsgs,
-- 				    tViewDotMsg = self.tData
-- 				}
-- 				sendMsg(ghd_show_dlg_by_type, tObject)
-- 			else
-- 				--单人战
-- 				showCityWarSingle()
-- 			end
--         end
--     elseif __msg.head.state == SocketErrorType.no_citywar then 
--     	--单人战
--     	showCityWarSingle()
--     else
--         TOAST(SocketManager:getErrorStr(__msg.head.state))
--     end
-- end

function CityClickLayer:setVisibleEx( bIsShow )
	if bIsShow then
		--
		if self.tData.nSystemCityId then
			sendMsg(ghd_show_or_hide_syscity_dot_ui, {sysCityId = self.tData.nSystemCityId, bIsShow = false})
		elseif self.tData.nCityId  then
			sendMsg(ghd_show_or_hide_city_dot_ui, {cityId = self.tData.nCityId, bIsShow = false})
		end
		self:regMsgs()
	else
		if self.tData.nSystemCityId then
			sendMsg(ghd_show_or_hide_syscity_dot_ui, {sysCityId = self.tData.nSystemCityId, bIsShow = true})
		elseif self.tData.nCityId  then
			sendMsg(ghd_show_or_hide_city_dot_ui, {cityId = self.tData.nCityId, bIsShow = true})
		end
		--关闭定时器
		unregUpdateControl(self)
		self:unregMsgs()
	end
	self:setVisible(bIsShow)
end
--设置跳转过来的类型
function CityClickLayer:setJumpType( _nType)
	-- body

	self.nJumpType=_nType or self.nJumpType

end

function CityClickLayer:removeEffect( )
	if table.nums(self.pBtnEffects )>0 then
		for i, v in pairs(self.pBtnEffects) do 
			-- v:removeSelf()
			if v and table.nums(v) > 0 then
				local nSize = table.nums(v)
				for j = nSize, 1, -1 do
					v[j]:removeSelf()
					v[i] = nil
				end
			end
			v=nil
		end
		self.pBtnEffects={}
	end
	self:removeTLBossAtkEffect()
	self:removeEpwBFRing()
	self:removeDispatchRing()
end

function CityClickLayer:removeTLBossAtkEffect(  )
	if self.pBtnTLBossAtkEffect then
		for k,v in pairs(self.pBtnTLBossAtkEffect) do
			v:removeSelf()
		end
		self.pBtnTLBossAtkEffect = nil
	end
end

--限时Boss时间
function CityClickLayer:updateTLBossCd(  )
	--攻击按钮cd
	if self.pBtnTLBossAtk then
		local nCd = Player:getTLBossData():getAttackCd()
		if nCd > 0 then
			self.pBtnTLBossAtk:setCdText(nCd .. "S")
			self.pBtnTLBossAtk:setGoldTxtVisible(true)
		else
			self.pBtnTLBossAtk:setCdText(nil)
			self.pBtnTLBossAtk:setGoldTxtVisible(false)
		end
	end
	--5连击按钮cd
	if self.pBtnTLBossSAtk then
		local nCd = Player:getTLBossData():getSAttackCd()
		if nCd > 0 then
			self.pBtnTLBossSAtk:setCdText(nCd .. "S")
		else
			self.pBtnTLBossSAtk:setCdText(nil)
		end
	end

	--小排行数据
	local pHomeLayer = Player:getUIHomeLayer()
	if pHomeLayer and pHomeLayer:getIsTLBRankShow() then
		--两秒请求一次排名
		local nState = Player:getTLBossData():getCdState()
		if nState == e_tlboss_time.begin then
			if not self.bIsReqing then
				local bIsReq = false
				if self.nReqTLBossRankTime then
					local nTime = getSystemTime()
					if nTime - self.nReqTLBossRankTime >= self.nRankTime then
						bIsReq = true
					end
				else
					bIsReq = true
				end
				if bIsReq then
					self.bIsReqing = true
					SocketManager:sendMsg("reqTLBossRank", {}, function()
						self.bIsReqing = false
						self.nReqTLBossRankTime = getSystemTime()
					end)
				end
			end
		end
	end
	--TLBoss离场时关闭界面
	local bIsOver = Player:getTLBossData():getIsShowWorldTLBoss()
	if not bIsOver then
		self:setHide()
	end
end

--行军任务发生变化，限时Boss按钮发生变化
function CityClickLayer:onTaskChange(  )
	if not self.tData then
		return
	end

	if self.tData.nType == e_type_builddot.tlboss then
		self:updateViews()
	end
end

--限时Boss状态发生变化，限时Boss按钮发生变化
function CityClickLayer:onTLBossChange(  )
	if not self.tData then
		return
	end

	if self.tData.nType == e_type_builddot.tlboss then
		local nState = Player:getTLBossData():getCdState()
		if self.nTLBossState ~= nState then
			self.nTLBossState = nState
			self:updateViews()
		end
	end
end

----------------------------------------------------------限时Boss
--限时BossCd状态变化
function CityClickLayer:onTLBossAttackCd( )
	if self.pBtnTLBossAtk then
		local nCd = Player:getTLBossData():getAttackCd()
		if nCd > 0 then
			self.pBtnTLBossAtk:showCdBlack(nCd, tonumber(getBossInitData("fightCd")), handler(self, self.onTLBossAttackCd))
			self.pBtnTLBossAtk:setGoldTxtVisible(true)

			self:removeTLBossAtkEffect()
		else
			self.pBtnTLBossAtk:stopCdBlack()
			self.pBtnTLBossAtk:setGoldTxtVisible(false)
			if not self.pBtnTLBossAtkEffect then
				local pRing=showYellowRing2(self.pBtnTLBossAtk,2,nil,1,nil,Scene_arm_type.world)
				self.pBtnTLBossAtkEffect = pRing
			end
		end
	end   
end

--限时BossCd状态变化
function CityClickLayer:onTLBossSAttackCd( )
	if self.pBtnTLBossSAtk then
		local nCd = Player:getTLBossData():getSAttackCd()
		if nCd > 0 then
			self.pBtnTLBossSAtk:showCdBlack(nCd, tonumber(getBossInitData("stormCd")))
		else
			self.pBtnTLBossSAtk:stopCdBlack()
		end
	end
end

--限时按钮派遣特效
function CityClickLayer:onDispatchRing(  )
	if self.pBtnTLBossDispatch then
		--准备和开战期未派遣过武将到达BOSS时，派遣按钮出现高亮特效提醒
		local nState = Player:getTLBossData():getCdState()
		if nState == e_tlboss_time.ready or nState == e_tlboss_time.begin then
			local bIsJoin = Player:getWorldData():getHasJoinTLBoss(self.tData.nX, self.tData.nY)
			if bIsJoin then
				self:removeDispatchRing()
			else
				if not self.pBtnDispatchRing then
					local pRing=showYellowRing2(self.pBtnTLBossDispatch,2,nil,1,nil,Scene_arm_type.world)
					self.pBtnDispatchRing = pRing
				end
			end
		else
			self:removeDispatchRing()
		end
	end
end

function CityClickLayer:removeDispatchRing( )
	if self.pBtnDispatchRing then
		for k,v in pairs(self.pBtnDispatchRing) do
			v:removeSelf()
		end
		self.pBtnDispatchRing = nil
	end
end

----------------------------------------------------------皇城战
--开战期间，战场按钮高亮
function CityClickLayer:onImperialWarState( )
	if self.pBtnEpwBattlefiled then
		local bIsOpen = Player:getImperWarData():getImperWarIsOpen()
		if bIsOpen then
			if not self.pBtnEpwBFRing then
				local pRing=showYellowRing2(self.pBtnEpwBattlefiled,2,nil,1,nil,Scene_arm_type.world)
				self.pBtnEpwBFRing = pRing
			end
		else
			self:removeEpwBFRing()
		end
	end
end

function CityClickLayer:removeEpwBFRing(  )
	if self.pBtnEpwBFRing then
		for k,v in pairs(self.pBtnEpwBFRing) do
			v:removeSelf()
		end
		self.pBtnEpwBFRing = nil
	end
end

function CityClickLayer:onTogetherClicked(  )
 	SocketManager:sendMsg("reqTogetherData", {self.tData.nSystemCityId}, function(__msg, __oldMsg)
        if __msg.head.state == SocketErrorType.success then 
            if __msg.head.type == MsgType.reqTogetherData.id then
            	local nRamin = 0
            	local tData = getTechDataById(e_tech_type.together)
				if tData then
					nRamin = tData.nLimit - __msg.body.h
				end

				if nRamin <= 0 then
					TOAST(getConvertedStr(3, 10854))
					return
				end

            	local tData = {
            		nCityId = __msg.body.cid,
					nToCd = __msg.body.tuse,
					nRamin = nRamin,
            	}
                local DlgAlert = require("app.common.dialog.DlgAlert")
			    local pDlg = getDlgByType(e_dlg_index.alert)
			    if(not pDlg) then
			        pDlg = DlgAlert.new(e_dlg_index.alert)
			    end
			    pDlg:setTitle(getConvertedStr(3, 10933))
			    local TogetherUseLayer = require("app.layer.imperialwar.TogetherUseLayer")
			    local pTogetherLayer = TogetherUseLayer.new(tData)
			    pDlg:addContentView(pTogetherLayer)
			    pDlg:setBtnLayHeight(0)
			    local pBtn = pDlg:getRightButton()
			    pTogetherLayer:setSubmitBtn(pBtn)
			    pDlg:setRightHandler(function (  )
			        --先关闭当前框
			        pDlg:closeDlg(false)
			        SocketManager:sendMsg("reqImperWarTech", {e_tech_type.together, self.tData.nSystemCityId}, nil)

			    end)
			    pDlg:showDlg(bNew)
            end
        else
            TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
    end)
    self:setHide()
end

----------------------------------------------------------皇城战
return CityClickLayer