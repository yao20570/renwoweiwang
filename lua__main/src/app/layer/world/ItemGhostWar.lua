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
local ItemGhostWar = class("ItemGhostWar", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemGhostWar:ctor( tViewDotMsg )
	self.tViewDotMsg = tViewDotMsg
	--解析文件
	parseView("item_city_war", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemGhostWar:onParseViewCallback( pView )
	local pSize = pView:getContentSize()
	pSize.width = pSize.width + 2
	pSize.height = pSize.height + 2
	self:setContentSize(pSize)
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	-- self:updateCityWarViews()
	-- self:updateGhostWarViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemGhostWar",handler(self, self.onItemGhostWarDestroy))
end

-- 析构方法
function ItemGhostWar:onItemGhostWarDestroy(  )
    self:onPause()
end

function ItemGhostWar:regMsgs(  )
end

function ItemGhostWar:unregMsgs(  )
end

function ItemGhostWar:onResume(  )
	self:regMsgs()
end

function ItemGhostWar:onPause(  )
	self:unregMsgs()
end

function ItemGhostWar:setupViews(  )

	--城战的按钮
	self.pLayCwBtns = self:findViewByName("lay_cw_btns")
	--冥王的按钮
	self.pLayGwBtns = self:findViewByName("lay_gw_btns")
	
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
	

	--冥王支援按钮
	self.pLayBtnSupportGw = self:findViewByName("lay_btn_support_gw")
	self.pBtnSupportGw = getCommonButtonOfContainer(self.pLayBtnSupportGw,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10043))
	self.pBtnSupportGw:onCommonBtnClicked(handler(self, self.onSupportGwClicked))
	setMCommonBtnScale(self.pLayBtnSupportGw, self.pBtnSupportGw, 0.8 )

	--冥王查看敌军按钮
	self.pLayBtnCheckGw = self:findViewByName("lay_btn_check")
	self.pBtnCheckGw = getCommonButtonOfContainer(self.pLayBtnCheckGw,TypeCommonBtn.M_BLUE, getConvertedStr(9, 10172))
	self.pBtnCheckGw:onCommonBtnClicked(handler(self, self.onCheckClicked))
	setMCommonBtnScale(self.pLayBtnCheckGw, self.pBtnCheckGw, 0.8 )

	--冥王不能求援提示
	self.pLbGwTip = self:findViewByName('lb_gw_tip')
	self.pLbGwTip:setVisible(false)
	self.pLbGwTip:setString(getConvertedStr(9,10173))

	local nX, nY = self.pLayBtnSupport:getPosition()
	table.insert(self.tBtnPos3, {x = nX, y = nY})

	--支援数最大
	self.nMaxHelp = getWorldInitData("helpMaxLimit")

end

function ItemGhostWar:setBtnSupportVisible( bIsShow)
	if bIsShow then
		self:udpateSupportTimes(1)
	end
	self.pLayBtnSupport:setVisible(bIsShow)
	self.pBtnSupport:setVisible(bIsShow)
	self.pBtnSupport:setBtnEnable(true)
end

function ItemGhostWar:setBtnAttackVisible( bIsShow)
	self.pLayBtnAttack:setVisible(bIsShow)
	self.pBtnAttack:setVisible(bIsShow)
end


function ItemGhostWar:updateCityWarViews(  )
	if not self.tData then
		return
	end

	if not self.tViewDotMsg then
		return
	end
	self.pLayCwBtns:setVisible(true)
	self.pLayGwBtns:setVisible(false)

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
			-- if self.tData.nWarType == e_citywar_type.short then  --短途战置灰求援
			-- 	self:setSupportBtnDisable()
			-- end
			--显示撤退
			self:setBtnAttackVisible(true)
			self:updateAttackBtn(getConvertedStr(3,10731),TypeCommonBtn.M_BLUE,handler(self,self.onMigrateClicked))
			
			--隐藏城战
			self:setBtnCityWarVisible(false)
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
				self:updateAttackBtn(getConvertedStr(3, 10298),TypeCommonBtn.M_YELLOW,handler(self,self.onAttackClicked))	
				--隐藏分享按钮
				self:setBtnShareVisible(false)
			else --参与防守 分享坐标
				--隐藏支援
				self:setBtnSupportVisible(false)
				--隐藏城战
				self:setBtnCityWarVisible(false)
				--显示防守按钮
				self:setBtnAttackVisible(true)
				self:updateAttackBtn(getConvertedStr(3, 10298),TypeCommonBtn.M_YELLOW,handler(self,self.onAttackClicked))
				--显示分享按钮
				self:setBtnShareVisible(true)				
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
				self:updateAttackBtn(getConvertedStr(3, 10044),TypeCommonBtn.M_BLUE,handler(self,self.onAttackClicked))
			end
			--显示城战层
			self:setBtnCityWarVisible(true)
			
			--显示分享按钮
			self:setBtnShareVisible(true)		
		else --同国(只能是同国，策划说的)	--参与进攻(短置灰)，发起城战，分享坐标
			 --隐藏求援
			self:setBtnSupportVisible(false)
			--显示参与进攻
			self:setBtnAttackVisible(true)	
			if self.tData.nWarType == e_citywar_type.short then  --短途战
				self:setAttackBtnDisable()
			else
				self:updateAttackBtn(getConvertedStr(3, 10044),TypeCommonBtn.M_BLUE,handler(self,self.onAttackClicked))
			end
			--显示城战层
			self:setBtnCityWarVisible(true)
			--显示分享按钮
			self:setBtnShareVisible(true)
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

function ItemGhostWar:updateViews(  )
	-- body
	if not self.tData then
		return
	end

	if not self.tViewDotMsg then
		return
	end

	self.pLayCwBtns:setVisible(false)
	self.pLayGwBtns:setVisible(true)

	self.pTxtAtkTroops:setString(getConvertedStr(3, 10051)..tostring(self.tData.tNpcData.nTroops))
	self.pTxtDefTroops:setString(getConvertedStr(3, 10052)..tostring(self.tData.nDefTroops))
	self.pTxtAtkName:setString(self.tData.tNpcData.sName .. getLvString(self.tData.tNpcData.nLevel))
	self.pTxtDefName:setString(self.tViewDotMsg:getDotName() .. getLvString(self.tViewDotMsg.nLevel))

	if Player:getPlayerInfo().nInfluence == self.tViewDotMsg.nDotCountry then
		--被打的是自己
		local tWallData = Player:getBuildData():getBuildByCell(e_build_cell.gate)

		if self.tViewDotMsg:getIsMe() then --求援，撤退
			if tWallData.nLv > 13 then   --x走配置？
				--显示支援
				self:setBtnGwSupportVisible(true)
				self.pLbGwTip:setVisible(false)
			else
				--隐藏支援
				self:setBtnGwSupportVisible(false)
				self.pLbGwTip:setVisible(true)
			end
		end
	end

end

--更新支援次数  
function ItemGhostWar:udpateSupportTimes( )
	local nCurr = math.max(self.nMaxHelp - self.tData.nSupport, 0)
	local sStr = string.format("%s（%s/%s）", getConvertedStr(3, 10425), nCurr, self.nMaxHelp)
	self.pBtnSupport:updateBtnText(sStr)
	
end

function ItemGhostWar:updateImgTitle(  )
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

--更新cd显示
function ItemGhostWar:updateCd(  )
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
function ItemGhostWar:getCityWarCd(  )
	if not self.tData then
		return 0
	end
	return self.tData:getCd()
end
--
--tData:  CityWarMsg类型
function ItemGhostWar:setData( tData)
	self.tWarData = tData 
	-- self.tData = tData
	self.tData = self.tWarData.tWarData

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
	if self.tWarData.nType == 1 then
		self:updateCityWarViews()
	else
		self:updateGhostWarViews()
	end
end

--发起城战求援
function ItemGhostWar:onSupportClicked( pView )
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citywarhelp, --dlg类型
	    tViewDotMsg = self.tViewDotMsg,
	    tCityWarMsg = self.tData,
	    nWarType = 1,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--参加城战(参与或防守)
function ItemGhostWar:onAttackClicked( pView )	
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
function ItemGhostWar:onCityWarClicked( pView )
	--容错
	if not self.tViewDotMsg then
		return
	end
	
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citydetail, --dlg类型
	    nIndex = 1,
	    tViewDotMsg = self.tViewDotMsg,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

----------------------------------冥王部分----------------------------------------
function ItemGhostWar:setBtnGwSupportVisible( bIsShow)
	if bIsShow then
		self:udpateSupportTimes(2)
	end
	self.pLayBtnSupport:setVisible(bIsShow)
	self.pBtnSupport:setVisible(bIsShow)
	self.pBtnSupport:setBtnEnable(true)
end

--发起冥王求援
function ItemGhostWar:onSupportGwClicked( pView )
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citywarhelp, --dlg类型
	    tViewDotMsg = self.tViewDotMsg,
	    tCityWarMsg = self.tData,
	    nWarType = 1,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function ItemGhostWar:onCheckClicked( _pView )
	-- body

	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citywarhelp, --dlg类型
	    tViewDotMsg = self.tViewDotMsg,
	    tCityWarMsg = self.tData,
	    nWarType = 1,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)


end


return ItemGhostWar


