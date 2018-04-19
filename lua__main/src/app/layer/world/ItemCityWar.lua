----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 17:31:20
-- Description: 城战面板 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgCityDetail = require("app.layer.world.DlgCityDetail")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local tBtnsPos ={
	{nBeginPos= 240 ,nSpace= 0 },
	{nBeginPos= 80 ,nSpace= 160 },
	{nBeginPos= 50 ,nSpace= 30 },
	{nBeginPos= 0 ,nSpace= 0 }
}
local nImperialCityMapId = 1013 --皇城mapId
local nBtnWidth=160
local ItemCityWar = class("ItemCityWar", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCityWar:ctor( tViewDotMsg )
	self.tViewDotMsg = tViewDotMsg
	--解析文件
	parseView("item_city_war", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCityWar:onParseViewCallback( pView )
	local pSize = pView:getContentSize()
	pSize.width = pSize.width + 2
	pSize.height = pSize.height + 2
	self:setContentSize(pSize)
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCityWar",handler(self, self.onItemCityWarDestroy))
end

-- 析构方法
function ItemCityWar:onItemCityWarDestroy(  )
    self:onPause()
end

function ItemCityWar:regMsgs(  )
end

function ItemCityWar:unregMsgs(  )
end

function ItemCityWar:onResume(  )
	self:regMsgs()
end

function ItemCityWar:onPause(  )
	self:unregMsgs()
end

function ItemCityWar:setupViews(  )

	self.pLayCwBtns = self:findViewByName("lay_cw_btns")
	self.pLayGwBtns = self:findViewByName("lay_gw_btns")
	--分享按钮
	self.pLayBtnShare = self:findViewByName("lay_btn_share")
	
	self.pBtnShare = getCommonButtonOfContainer(self.pLayBtnShare,TypeCommonBtn.M_BLUE, getConvertedStr(9, 10034))
	self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(self.pLayBtnShare, self.pBtnShare, 0.8 )
	self.pLayBtnShare:setVisible(true)

	local pTxtAtkTroops = self:findViewByName("txt_atk_title")
	pTxtAtkTroops:setString(getConvertedStr(3, 10249))

	self.pImgCdBg = self:findViewByName("img_cd_bg")
	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.green)
	self.pTxtMoveTime = self:findViewByName("txt_move_time")

	self.pTxtAtkTroops = self:findViewByName("txt_atk_troops")
	self.pTxtDefTroops = self:findViewByName("txt_def_troops")

	local pTxtDefTitle = self:findViewByName("txt_def_title")
	pTxtDefTitle:setString(getConvertedStr(3, 10250))

	local pLayAtkLocation = self:findViewByName("lay_atk_location")
	pLayAtkLocation:setViewTouched(true)
	pLayAtkLocation:setIsPressedNeedScale(false)
	pLayAtkLocation:setIsPressedNeedColor(false)
	pLayAtkLocation:onMViewClicked(handler(self, self.onLocationAtkClicked))

	self.pImgAtkFlag = self:findViewByName("img_atk_flag")
	self.pTxtAtkName = self:findViewByName("txt_atk_name")
	setTextCCColor(self.pTxtAtkName, _cc.blue)
	-- self.pTxtAtkPos = self:findViewByName("txt_atk_pos")

	self.pLayAtkCity = self:findViewByName("lay_atk_city")
	self.pLayDefCity = self:findViewByName("lay_def_city")

	local pLayDefLocation = self:findViewByName("lay_def_location")
	pLayDefLocation:setViewTouched(true)
	pLayDefLocation:setIsPressedNeedScale(false)
	pLayDefLocation:setIsPressedNeedColor(false)
	pLayDefLocation:onMViewClicked(handler(self, self.onLocationDefClicked))

	self.pImgDefFlag = self:findViewByName("img_def_flag")
	self.pTxtDefName = self:findViewByName("txt_def_name")
	setTextCCColor(self.pTxtDefName, _cc.blue)
	-- self.pTxtDefPos = self:findViewByName("txt_def_pos")

	self.pLbShortWarTip = self:findViewByName("lb_short_war_tip")
	self.pLbShortWarTip:setString(getConvertedStr(6, 10675))	
	setTextCCColor(self.pLbShortWarTip, _cc.pwhite)

	--图片标题
	self.pImgTitle = self:findViewByName("img_tilte")

	self.tBtnPos3 = {}

	--支援按钮
	self.pLayBtnSupport = self:findViewByName("lay_btn_support")
	self.pBtnSupport = getCommonButtonOfContainer(self.pLayBtnSupport,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10043))
	self.pBtnSupport:onCommonBtnClicked(handler(self, self.onSupportClicked))
	self.pBtnSupport:onCommonBtnDisabledClicked(handler(self, self.onSupportDisableClicked))
	setMCommonBtnScale(self.pLayBtnSupport, self.pBtnSupport, 0.8 )

	local nX, nY = self.pLayBtnSupport:getPosition()
	table.insert(self.tBtnPos3, {x = nX, y = nY})

	--支援数最大
	self.nMaxHelp = getWorldInitData("helpMaxLimit")

	--攻击按钮层
	self.pLayBtnAttack = self:findViewByName("lay_btn_attack")
	self.pBtnAttack = getCommonButtonOfContainer(self.pLayBtnAttack,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10044))
	self.pBtnAttack:onCommonBtnClicked(handler(self, self.onAttackClicked))
	self.pBtnAttack:onCommonBtnDisabledClicked(handler(self, self.onAttackDisableClicked))
	setMCommonBtnScale(self.pLayBtnAttack, self.pBtnAttack, 0.8 )

	local nX, nY = self.pLayBtnAttack:getPosition()
	table.insert(self.tBtnPos3, {x = nX, y = nY})

	--发起城战按钮层
	self.pLayBtnCityWar = self:findViewByName("lay_btn_citywar")
	self.pBtnCityWar = getCommonButtonOfContainer(self.pLayBtnCityWar,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10045))
	self.pBtnCityWar:onCommonBtnClicked(handler(self, self.onCityWarClicked))
	setMCommonBtnScale(self.pLayBtnCityWar, self.pBtnCityWar, 0.8 )

	local nX, nY = self.pLayBtnCityWar:getPosition()
	table.insert(self.tBtnPos3, {x = nX, y = nY})

	self.tBtnPos2 = {}
	table.insert(self.tBtnPos2, {x = 137, y = nY})
	table.insert(self.tBtnPos2, {x = 338, y = nY})

	--冥王入侵查看敌军按钮
	self.pLayBtnCheck = self:findViewByName("lay_btn_check")
	
	self.pBtnCheck = getCommonButtonOfContainer(self.pLayBtnCheck,TypeCommonBtn.M_BLUE, getConvertedStr(9, 10175))
	self.pBtnCheck:onCommonBtnClicked(handler(self, self.onCheckClicked))
	setMCommonBtnScale(self.pLayBtnCheck, self.pBtnCheck, 0.8 )
	self.pLayBtnCheck:setVisible(true)

	--冥王入侵求援按钮
	self.pLayBtnSupportGw = self:findViewByName("lay_btn_support_gw")
	
	self.pBtnSupportGw = getCommonButtonOfContainer(self.pLayBtnSupportGw,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10425))
	self.pBtnSupportGw:onCommonBtnClicked(handler(self, self.onSupportClicked))
	self.pBtnSupportGw:onCommonBtnDisabledClicked(handler(self, self.onSupportDisableClicked))
	setMCommonBtnScale(self.pLayBtnCheck, self.pBtnSupportGw, 0.8 )
	self.pLayBtnSupportGw:setVisible(false)

	--冥王入侵提示
	self.pLbGwTip = self:findViewByName("lb_gw_tip")
	setTextCCColor(self.pLbGwTip,_cc.gray)


	-- --坐标横线
	-- self.pAtkPosLine = cc.DrawNode:create()
	-- local pParent = self.pTxtAtkPos:getParent()
	-- pParent:addView(self.pAtkPosLine)
	-- self.pDefPosLine = cc.DrawNode:create()
	-- local pParent = self.pTxtDefPos:getParent()
	-- pParent:addView(self.pDefPosLine)
end

function ItemCityWar:setBtnSupportVisible( bIsShow)
	if bIsShow then
		self:udpateSupportTimes()
	end
	self.pLayBtnSupport:setVisible(bIsShow)
	self.pBtnSupport:setVisible(bIsShow)
	self.pBtnSupport:setBtnEnable(true)
end

function ItemCityWar:setBtnAttackVisible( bIsShow)
	self.pLayBtnAttack:setVisible(bIsShow)
	self.pBtnAttack:setVisible(bIsShow)
end

function ItemCityWar:setBtnCityWarVisible( bIsShow)
	self.pLayBtnCityWar:setVisible(bIsShow)
	self.pBtnCityWar:setVisible(bIsShow)
end
function ItemCityWar:setBtnShareVisible( bIsShow )
	-- body
	self.pLayBtnShare:setVisible(bIsShow)
	self.pBtnShare:setVisible(bIsShow)
end

--显示3个可见按钮居中
function ItemCityWar:setVisisbleBtnCenter()
	local tBtns = {
		self.pLayBtnSupport,
		self.pLayBtnAttack,
		self.pLayBtnCityWar,
		self.pLayBtnShare,
	}
	local tVisibleBtns = {}
	for i=1,#tBtns do
		if tBtns[i]:isVisible() then
			table.insert(tVisibleBtns, tBtns[i])
		end
	end
	-- dump(tVisibleBtns)
	local nNum=#tVisibleBtns
	-- print("num--",nNum)
	if nNum > 0 then
		tVisibleBtns[1]:setPositionX(tBtnsPos[nNum].nBeginPos)
		for i = 2, #tVisibleBtns do 
			local nPrePos=tVisibleBtns[i-1]:getPositionX() + nBtnWidth
			tVisibleBtns[i]:setPositionX(nPrePos +tBtnsPos[nNum].nSpace )
		end
	end

	-- if #tVisibleBtns == 1 then
	-- 	local nX, nY = self.tBtnPos3[2]
	-- 	tVisibleBtns[1]:setPosition(nX, nY)
	-- elseif #tVisibleBtns == 2 then
	-- 	local nX, nY = self.tBtnPos2[1]
	-- 	tVisibleBtns[1]:setPosition(nX, nY)
	-- 	local nX, nY = self.tBtnPos2[2]
	-- 	tVisibleBtns[2]:setPosition(nX, nY)
	-- else
	-- 	local nX, nY = self.tBtnPos3[1]
	-- 	tVisibleBtns[1]:setPosition(nX, nY)
	-- 	local nX, nY = self.tBtnPos3[2]
	-- 	tVisibleBtns[2]:setPosition(nX, nY)
	-- 	local nX, nY = self.tBtnPos3[3]
	-- 	tVisibleBtns[3]:setPosition(nX, nY)
	-- end
end

function ItemCityWar:updateViews(  )
	if not self.tData then
		return
	end

	if not self.tViewDotMsg then
		return
	end
	if self.tCityWarData.nType == 1 then
		self.pLayCwBtns:setVisible(true)
		self.pLayGwBtns:setVisible(false)
		self:updateCityWar()
	elseif self.tCityWarData.nType == 2 then 
		self.pLayCwBtns:setVisible(false)
		self.pLayGwBtns:setVisible(true)
		self:updateGhostWar()
	end
	
end

function ItemCityWar:updateCityWar(  )
	-- body

	self.pTxtAtkTroops:setString(getConvertedStr(3, 10051)..tostring(self.tData.nAtkTroops))
	self.pTxtDefTroops:setString(getConvertedStr(3, 10052)..tostring(self.tData.nDefTroops))
	self.pTxtAtkName:setString(self.tData.sSenderName .. getLvString(self.tData.nSenderCityLv))
	self.pTxtDefName:setString(self.tViewDotMsg:getDotName() .. getLvString(self.tViewDotMsg.nLevel))
	WorldFunc.setImgCountryFlag(self.pImgAtkFlag, self.tData.nSenderCountry)
	WorldFunc.setImgCountryFlag(self.pImgDefFlag, self.tViewDotMsg.nDotCountry)

	--攻击方头像
	local tActor = ActorVo.new()
	tActor:initData(self.tData:getSenderHead(), self.tData:getSenderBox(), nil)
	local pIconHero = getIconGoodsByType(self.pLayAtkCity, TypeIconHero.NORMAL,type_icongoods_show.header, tActor, 0.6)
	pIconHero:setIconIsCanTouched(false)
	-- WorldFunc.getCityIconOfContainer(self.pLayAtkCity, self.tData.nSenderCountry, self.tData.nSenderCityLv, true)
	
	--防守方头像
	local tActor = ActorVo.new()
	tActor:initData(self.tData:getDeferHead(), self.tData:getDeferBox(), nil)
	local pIconHero = getIconGoodsByType(self.pLayDefCity, TypeIconHero.NORMAL,type_icongoods_show.header, tActor, 0.6)
	pIconHero:setIconIsCanTouched(false)
	-- WorldFunc.getCityIconOfContainer(self.pLayDefCity, self.tViewDotMsg.nDotCountry, self.tViewDotMsg.nLevel, true)

	--被打的城池是否是同势力的
	self.pLbShortWarTip:setVisible(false)
	if Player:getPlayerInfo().nInfluence == self.tViewDotMsg.nDotCountry then
		--被打的是自己
		if self.tViewDotMsg:getIsMe() then --求援，撤退

			--显示支援
			self:setBtnSupportVisible(true)
			self:updateBtn(self.pBtnSupport,getConvertedStr(3,10043),TypeCommonBtn.M_BLUE,handler(self,self.onSupportClicked))

			-- if self.tData.nWarType == e_citywar_type.short then  --短途战置灰求援
			-- 	self:setSupportBtnDisable()
			-- end
			
			--显示反击
			self:setBtnAttackVisible(true)
			self:updateBtn(self.pBtnAttack,getConvertedStr(3,10732),TypeCommonBtn.M_BLUE,handler(self,self.onHitBack))
			
			--显示撤退
			self:setBtnCityWarVisible(true)
			self:updateBtn(self.pBtnCityWar,getConvertedStr(3,10731),TypeCommonBtn.M_BLUE,handler(self,self.onMigrateClicked))

			--隐藏分享
			self:setBtnShareVisible(false)
		else
			if self.tData.nWarType == e_citywar_type.short then -- 隐藏所有按钮 显示标签
				--隐藏支援
				self:setBtnSupportVisible(false)
				--隐藏城战
				self:setBtnCityWarVisible(false)
				--显示防守按钮
				self:setBtnAttackVisible(true)
				self:updateBtn(self.pBtnAttack,getConvertedStr(3, 10298),TypeCommonBtn.M_YELLOW,handler(self,self.onAttackClicked))	
				--隐藏分享按钮
				self:setBtnShareVisible(false)
			else --参与防守 分享坐标
				--隐藏支援
				self:setBtnSupportVisible(false)
				--隐藏城战
				self:setBtnCityWarVisible(false)
				--显示防守按钮
				self:setBtnAttackVisible(true)
				self:updateBtn(self.pBtnAttack,getConvertedStr(3, 10298),TypeCommonBtn.M_YELLOW,handler(self,self.onAttackClicked))
				--显示分享按钮
				self:setBtnShareVisible(true)				
				self:updateBtn(self.pBtnShare,getConvertedStr(9, 10034),TypeCommonBtn.M_BLUE,handler(self,self.onShareClicked))

			end
		end
	else
		--城战发起者是自己显示支援数量
		if self.tData.sSenderName == Player:getPlayerInfo().sName then --求援(短置灰)，参与进攻(短不显示），发起城战，分享坐标
		    --显示求援
			self:setBtnSupportVisible(true)
			if self.tData.nWarType == e_citywar_type.short then
				self:setSupportBtnDisable()
				self:setBtnAttackVisible(false)
			else
				--显示参与进攻
				self:setBtnAttackVisible(true)	
				self:updateBtn(self.pBtnAttack,getConvertedStr(3, 10044),TypeCommonBtn.M_BLUE,handler(self,self.onAttackClicked))
			end
			--显示城战层
			self:setBtnCityWarVisible(true)
			self:updateBtn(self.pBtnCityWar,getConvertedStr(3, 10045),TypeCommonBtn.M_YELLOW,handler(self,self.onCityWarClicked))
			
			--显示分享按钮
			self:setBtnShareVisible(true)
			self:updateBtn(self.pBtnShare,getConvertedStr(9, 10034),TypeCommonBtn.M_BLUE,handler(self,self.onShareClicked))

		else --同国(只能是同国，策划说的)	--参与进攻(短置灰)，发起城战，分享坐标
			 --隐藏求援
			self:setBtnSupportVisible(false)
			--显示参与进攻
			self:setBtnAttackVisible(true)
			self:updateBtn(self.pBtnAttack,getConvertedStr(3, 10044),TypeCommonBtn.M_BLUE,handler(self,self.onAttackClicked))

			if self.tData.nWarType == e_citywar_type.short then  --短途战
				self:setAttackBtnDisable()
			-- else
			-- 	self:updateBtn(self.pBtnAttack,getConvertedStr(3, 10044),TypeCommonBtn.M_BLUE,handler(self,self.onAttackClicked))
			end
			--显示城战层
			self:setBtnCityWarVisible(true)
			--显示分享按钮
			self:setBtnShareVisible(true)
			self:updateBtn(self.pBtnShare,getConvertedStr(9, 10034),TypeCommonBtn.M_BLUE,handler(self,self.onShareClicked))
			
		end
	end
	self:setVisisbleBtnCenter()

	self:updateImgTitle()

	--被打的是自己
	if self.tViewDotMsg:getIsMe() then
		self.nMoveTime = 0
		self.pImgCdBg:setLayoutSize(112, 28)
		self.pTxtCd:setPosition(320, 89)
		self.pTxtMoveTime:setVisible(false)
	else
		self.nMoveTime = 0
		if self.bIsMarchTimes then
			local tTimes = getWorldInitData("marchTimes")
			if self.tData.nWarType == 1 then --短途
				self.nMoveTime = tTimes[1]
			elseif self.tData.nWarType == 2 then --合围
				self.nMoveTime = tTimes[2]
			elseif self.tData.nWarType == 3 then --奔
				self.nMoveTime = tTimes[3]
			end
		else
			self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.tViewDotMsg.nX, self.tViewDotMsg.nY)
		end
		self.pImgCdBg:setLayoutSize(112, 46)
		self.pTxtCd:setPosition(320, 100)
		self.pTxtMoveTime:setVisible(true)
		self.pTxtMoveTime:setString(getConvertedStr(3, 10729) .. formatTimeToMs(self.nMoveTime))
	end
	self:updateCd()
end

function ItemCityWar:updateGhostWar(  )
	-- body
	self.nMaxHelp = getGhostInitData("sosTime")

	self.pTxtAtkTroops:setString(getConvertedStr(3, 10051)..tostring(self.tData.nAtkTroops))
	self.pTxtDefTroops:setString(getConvertedStr(3, 10052)..tostring(self.tData.nDefTroops))
	self.pTxtAtkName:setString(self.tData.sSenderName .. getLvString(self.tData.nBossLv))
	self.pTxtDefName:setString(self.tViewDotMsg:getDotName() .. getLvString(self.tViewDotMsg.nLevel))
	self.pImgAtkFlag:setCurrentImage("#v2_img_emobiaozhi.png")
	WorldFunc.setImgCountryFlag(self.pImgDefFlag, self.tViewDotMsg.nDotCountry)

	--防守方头像
	local tActor = ActorVo.new()
	tActor:initData(self.tData:getDeferHead(), self.tData:getDeferBox(), nil)
	local pIconHero = getIconGoodsByType(self.pLayDefCity, TypeIconHero.NORMAL,type_icongoods_show.header, tActor, 0.6)
	pIconHero:setIconIsCanTouched(false)

	--冥王形象
	if not self.pImgBoss then
		self.pImgBoss = MUI.MImage.new("#"..self.tData.tNpcDetailData.icon..".png")
		self.pImgBoss:setScale(0.7)
		self.pLayAtkCity:addChild(self.pImgBoss)
		centerInView(self.pLayAtkCity,self.pImgBoss)
	else
		self.pImgBoss:setCurrentImage("#"..self.tData.tNpcDetailData.icon..".png")
	end
	if Player:getPlayerInfo().nInfluence == self.tViewDotMsg.nDotCountry then  --同势力
		if self.tData.bCanSupport then

			self.pLayBtnSupportGw:setVisible(true)
		else
			self.pLayBtnSupportGw:setVisible(false)
		end

		if not self.tData.bCanSupport then
			self.pLbGwTip:setVisible(true)
			if self.tData:checkTargetIsMe() then        --是否是自己被进攻
				self.pLbGwTip:setString(getConvertedStr(9,10173))
			else
				self.pLbGwTip:setString(getConvertedStr(9,10177))
			end
		else
			self.pLbGwTip:setVisible(false)

			if self.tData:checkTargetIsMe() then        --是否是自己被进攻
				self:udpateSupportTimes(2)
				local nCurr = math.max(self.nMaxHelp - self.tData.nSupport, 0)
				if nCurr <= 0 then
					self.pBtnSupportGw:setBtnEnable(false)
				else
					self.pBtnSupportGw:setBtnEnable(true)
				end
			else
				self.pBtnSupportGw:updateBtnText(getConvertedStr(9,10182))
			end
		end
	else
		self.pLayBtnSupportGw:setVisible(false)
		self.pLbGwTip:setVisible(false)
		self.pLayBtnCheck:setPositionX((self.pLayGwBtns:getWidth() - self.pLayBtnCheck:getWidth())/2)
	end

	self:updateGhostWarSeq()
end

--更新支援次数
function ItemCityWar:udpateSupportTimes( _nType )
	local nType = _nType or 1
	local nCurr = math.max(self.nMaxHelp - self.tData.nSupport, 0)
	local sStr = string.format("%s（%s/%s）", getConvertedStr(3, 10425), nCurr, self.nMaxHelp)
	if nType == 1 then
		self.pBtnSupport:updateBtnText(sStr)
	elseif nType == 2 then
		self.pBtnSupportGw:updateBtnText(sStr)
	end
end

function ItemCityWar:updateImgTitle(  )
	if self.pImgTitle and self.tData and self.tData.nWarType then
		if self.tData.nWarType == 1 then --短途
			self.pImgTitle:setCurrentImage("#v2_fonts_duantu.png")

		elseif self.tData.nWarType == 2 then --合围
			self.pImgTitle:setCurrentImage("#v2_fonts_hewei.png")

		elseif self.tData.nWarType == 3 then --奔
			self.pImgTitle:setCurrentImage("#v2_fonts_benxi.png")

		end
	end
end

function ItemCityWar:updateGhostWarSeq(  )
	-- body
	self.pImgTitle:setCurrentImage("#v2_img_dijibo.png")
	--获得一个数字标签
	if not self.pLabelAtlas then
		self.pLabelAtlas = MUI.MLabelAtlas.new({text="1", 
		png="ui/atlas/v1_img_zhanlishuzi.png", pngw=13, pngh=19, scm=48})
		self.pLabelAtlas:setPosition(self.pImgTitle:getWidth()/2, self.pImgTitle:getHeight()/2)
		self.pImgTitle:addChild(self.pLabelAtlas,111)
	end
	self.pLabelAtlas:setString(self.tData.nSeq)
	

end

--更新cd显示
function ItemCityWar:updateCd(  )
	if not self.tData then
		return
	end
	local nCd = self.tData:getCd()
	self.pTxtCd:setString(getConvertedStr(3, 10728) .. formatTimeToMs(nCd))
	--行动时间
	if self.pTxtMoveTime:isVisible() then
		if self.nMoveTime then
			if self.nMoveTime <= nCd then
				setTextCCColor(self.pTxtMoveTime, _cc.green)
			else
				setTextCCColor(self.pTxtMoveTime, _cc.red)
			end
		end
	end
end

--获取城战cd，用于关闭父界面
function ItemCityWar:getCityWarCd(  )
	if not self.tData then
		return 0
	end
	return self.tData:getCd()
end
--
--tData:  CityWarMsg类型
function ItemCityWar:setData( tData)
	self.tCityWarData = tData
	self.tData =self.tCityWarData.tWarData

	--发起地方区域
	local nBlockId = WorldFunc.getBlockId(self.tViewDotMsg.nX, self.tViewDotMsg.nY)
	--阿房宫时间
	local nMyBlockId = Player:getWorldData():getMyCityBlockId()
	self.bIsMarchTimes = false
	if nMyBlockId ~= nBlockId then
		if nMyBlockId == nImperialCityMapId then
			self.bIsMarchTimes = true
		end
	end

	self:updateViews()
end

--发起城战求援
function ItemCityWar:onSupportClicked( pView )
	local tObject ={}
	if self.tCityWarData.nType == 1 then
		tObject = {
		    nType = e_dlg_index.citywarhelp, --dlg类型
		    tViewDotMsg = self.tViewDotMsg,
		    tCityWarMsg = self.tData,
		    nWarType = 1,
		}
	elseif self.tCityWarData.nType == 2 then
		if self.tData:checkTargetIsMe() then  --自己被打就求援
			tObject = {
			    nType = e_dlg_index.citywarhelp, --dlg类型
			    tViewDotMsg = self.tViewDotMsg,
			    tCityWarMsg = self.tData,
			    nWarType = 3,
			}
		else
			--发送消息打开dlg
			tObject = {
			    nType = e_dlg_index.battlehero, --dlg类型
			    nIndex = 2,--前往驻军
			    tViewDotMsg = self.tViewDotMsg
			}
		end
	end
	-- --发送消息打开dlg
	-- local tObject = {
	--     nType = e_dlg_index.citywarhelp, --dlg类型
	--     tViewDotMsg = self.tViewDotMsg,
	--     tCityWarMsg = self.tData,
	--     nWarType = 1,
	-- }
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--参加城战(参与或防守)
function ItemCityWar:onAttackClicked( pView )	
	--容错
	if not self.tData then
		return
	end
	if not self.tViewDotMsg then
		return
	end

	--不可以跨区
	if not Player:getWorldData():getIsCanWarByPos(self.tViewDotMsg.nX, self.tViewDotMsg.nY, e_war_type.city) then
		local nOpenState = Player:getWorldData():getWorldOpenState()
		--目标区域id
		local nTargetBlockId = WorldFunc.getBlockId(self.tViewDotMsg.nX, self.tViewDotMsg.nY)
		if nTargetBlockId then
			--目标区域数据
			local tTargetBlock = getWorldMapDataById(nTargetBlockId)
			if tTargetBlock then
				local nBlockType = tTargetBlock.type
				--当前开启状态,
				if nOpenState == e_world_open_state.zhou then --当前开州状态
					if nBlockType == e_type_block.jun then --发生在郡城
						TOAST(getTipsByIndex(20076))
						return
					elseif nBlockType == e_type_block.zhou then --发生在州
						TOAST(getTipsByIndex(20095))
						return
					end
				elseif nOpenState == e_world_open_state.kind then --当前开阿房宫状态
					if nBlockType == e_type_block.jun then --发生在郡城
						TOAST(getTipsByIndex(20076))
						return
					elseif nBlockType == e_type_block.zhou then --发生在州
						TOAST(getTipsByIndex(20095))
						return
					elseif nBlockType == e_type_block.kind then --发生在阿房宫
						TOAST(getTipsByIndex(20105))
						return
					end
				end
			end
		end
		--以防策划漏了
		if nOpenState == e_world_open_state.kind then 		--阿房宫开启
			TOAST(getTipsByIndex(20075))
		else
			TOAST(getTipsByIndex(20076))
		end
		return
	end

	--行军时间较长
	local nMoveTime = self.nMoveTime
	if nMoveTime > self.tData:getCd() then
		TOAST(getTipsByIndex(20031))
		return
	end

	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.battlehero, --dlg类型
	    nIndex = 4,--参加城战
	    tViewDotMsg = self.tViewDotMsg,
	    sWarId = self.tData.sWarId,
	    tCityWarMsg = self.tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--点击城战
function ItemCityWar:onCityWarClicked( pView )
	--容错
	if not self.tViewDotMsg then
		return
	end

	-- if not self.tData then
	-- 	return
	-- end
	-- --不可以跨区
	-- if not Player:getWorldData():getIsCanWarByPos(self.tViewDotMsg.nX, self.tViewDotMsg.nY, e_war_type.city) then
	-- 	TOAST(getTipsByIndex(20032))
	-- 	return
	-- end
	-- --行军时间较长
	-- local nMoveTime = WorldFunc.getMyArmyMoveTime(self.tViewDotMsg.nX, self.tViewDotMsg.nY)
	-- if nMoveTime > self.tData:getCd() then
	-- 	TOAST(getTipsByIndex(20031))
	-- 	return
	-- end
	
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citydetail, --dlg类型
	    nIndex = 1,
	    tViewDotMsg = self.tViewDotMsg,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--发送定位
function ItemCityWar:onLocationAtkClicked( )
	if not self.tData then
		return
	end
	sendMsg(ghd_world_location_dotpos_msg, {nX = self.tData.nSenderX, nY = self.tData.nSenderY, isClick = true})
end

--发送定位
function ItemCityWar:onLocationDefClicked( )
	if not self.tViewDotMsg then
		return
	end
	sendMsg(ghd_world_location_dotpos_msg, {nX = self.tViewDotMsg.nX, nY = self.tViewDotMsg.nY, isClick = true})
end
--撤退按钮
function ItemCityWar:onMigrateClicked()
	if Player:getWorldData():getIsCanMove() then
		local tObject = {}
	    tObject.nType = e_dlg_index.worlduseresitem --dlg类型
	    tObject.tItemList = {100027,100028}
	    tObject.tCityMove = {nX = self.tViewDotMsg.nX, nY = self.tViewDotMsg.nY}
	    tObject.bIsFromCityWar = true
	    sendMsg(ghd_show_dlg_by_type,tObject)
	else
		TOAST(getTipsByIndex(538))
	end
end
--反击
function ItemCityWar:onHitBack(  )
	-- body
	local tCityWarMsg = self.tData
	if tCityWarMsg then
		local fX, fY = WorldFunc.getMapPosByDotPosEx(tCityWarMsg.nSenderX, tCityWarMsg.nSenderY)
		sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true, tOther = {bIsOpenCWar = true}})
		TOAST(getTipsByIndex(10074))
		closeDlgByType(e_dlg_index.citywar)
	end
end

--获取战场id
function ItemCityWar:getWarId( )
	if not self.tData then
		return
	end
	return self.tData.sWarId
end
--获取战斗类型
function ItemCityWar:getWarType( )
	if not self.tCityWarData then
		return
	end
	return self.tCityWarData.nType
end

--分享按钮
function ItemCityWar:onShareClicked( pView )
	-- dump(self.tData)
	if not self.tViewDotMsg then
		return
	end
	local tData = {
			bn = WorldFunc.getBlockId(self.tViewDotMsg.nX, self.tViewDotMsg.nY),
			dn = self.tViewDotMsg.sDotName,
			dx = self.tViewDotMsg.nX,
			dy = self.tViewDotMsg.nY,
			dt = e_share_type.city,
			dc = self.tViewDotMsg.nDotCountry,
			dl = self.tViewDotMsg.nLevel,
	}
	openShare(pView, e_share_id.role_pos, tData)

end

--更新按钮样式和响应
function ItemCityWar:updateBtn( _pBtn,_sText,_nBtnType,_handler )
	if not _pBtn then
		return
	end

	-- body
	_pBtn:setBtnEnable(true)
	if _sText then
		_pBtn:updateBtnText(_sText)
	end
	if _nBtnType then
		_pBtn:updateBtnType(_nBtnType)
	end
	if _handler then
		_pBtn:onCommonBtnClicked(_handler)
	end
end

--设置参与城战不可点击
function ItemCityWar:setAttackBtnDisable(  )
	self.pBtnAttack:updateBtnText(getConvertedStr(3, 10044))
	self.pBtnAttack:setBtnEnable(false)
end

--短途战不可点击
function ItemCityWar:onAttackDisableClicked(  )
	TOAST(getConvertedStr(6, 10675))
end

--设置求援不可点击
function ItemCityWar:setSupportBtnDisable(  )
	self.pBtnSupport:setBtnEnable(false)
end

--短途战不可以点击
function ItemCityWar:onSupportDisableClicked(  )
	if self.tCityWarData.nType == 1 then

		TOAST(getConvertedStr(6, 10675))
	elseif self.tCityWarData.nType == 2 then
		TOAST(getConvertedStr(9, 10181))
	end
end

function ItemCityWar:onCheckClicked(  )
	-- body

	--打开敌军详情界面
	local tObject = {
		nType = e_dlg_index.ghostdomAtkDetail, --dlg类型
		tData = self.tData.tNpcData,
		}
	sendMsg(ghd_show_dlg_by_type, tObject)

end

return ItemCityWar


