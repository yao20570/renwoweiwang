----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 17:31:20
-- Description: 国战面板 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local tBtnsPos ={
	{nBeginPos= 270 ,nSpace= 0 },
	{nBeginPos= 80 ,nSpace= 160 },
	{nBeginPos= 50 ,nSpace= 30 },
	{nBeginPos= 0 ,nSpace= 0 }
}

local nBtnWidth=160

local ItemCountryWar = class("ItemCountryWar", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemCountryWar:ctor( tViewDotMsg )
	self.tViewDotMsg = tViewDotMsg
	--解析文件
	parseView("item_country_war", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCountryWar:onParseViewCallback( pView )
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
	self:setDestroyHandler("ItemCountryWar",handler(self, self.onItemCountryWarDestroy))
end

-- 析构方法
function ItemCountryWar:onItemCountryWarDestroy(  )
    self:onPause()
end

function ItemCountryWar:regMsgs(  )
end

function ItemCountryWar:unregMsgs(  )
end

function ItemCountryWar:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function ItemCountryWar:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function ItemCountryWar:setupViews(  )
	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.green)

	-- self.pTxtCityInfo = self:findViewByName("txt_city_info")
	self.pImgAtkFlag = self:findViewByName("img_atk_flag")
	self.pTxtAtkTroops = self:findViewByName("txt_atk_troops")
	self.pLayAtkCity = self:findViewByName("lay_atk_city")
	self.pImgDefFlag = self:findViewByName("img_def_flag")
	self.pTxtDefTroops = self:findViewByName("txt_def_troops")
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
		
	local pTxtAtkName = self:findViewByName("txt_atk_name")
	pTxtAtkName:setString(getConvertedStr(3, 10249))
	local pTxtDefName = self:findViewByName("txt_def_name")
	-- pTxtDefName:setString(getConvertedStr(3, 10250))
	self.pTxtDefName = pTxtDefName

	--参与按钮
	self.pLayBtnJoin = self:findViewByName("lay_btn_join")
	self.pBtnJoin = getCommonButtonOfContainer(self.pLayBtnJoin,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10357))
	self.pBtnJoin:onCommonBtnClicked(handler(self, self.onJoinClicked))
	setMCommonBtnScale(self.pLayBtnJoin, self.pBtnJoin, 0.8 )
	--求援按钮
	self.pLayBtnSupport = self:findViewByName("lay_btn_support")
	self.pBtnSupport = getCommonButtonOfContainer(self.pLayBtnSupport,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10425))
	self.pBtnSupport:onCommonBtnClicked(handler(self, self.onSupportClicked))
	setMCommonBtnScale(self.pLayBtnSupport, self.pBtnSupport, 0.8 )
	--分享按钮
	self.pLayBtnShare = self:findViewByName("lay_btn_share")
	self.pBtnShare = getCommonButtonOfContainer(self.pLayBtnShare,TypeCommonBtn.M_BLUE, getConvertedStr(9, 10034))
	self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(self.pLayBtnShare, self.pBtnShare, 0.8 )

	self.pTxtAtkCaller =self:findViewByName("txt_atk_caller")
	self.pTxtDefOwner =self:findViewByName("txt_def_owner")


	--城池定位
	local pLayCityLocation = self:findViewByName("lay_city_location")
	pLayCityLocation:setViewTouched(true)
	pLayCityLocation:setIsPressedNeedScale(false)
	pLayCityLocation:setIsPressedNeedColor(false)
	pLayCityLocation:onMViewClicked(handler(self, self.onLocationCityClicked))
end

function ItemCountryWar:updateViews(  )
	--容错
	if not self.tViewDotMsg then
		return
	end
	--支援数最大
	self.nMaxHelp = getWorldInitData("countryHelpLimit")

	--城池信息
	-- local tStr = {
	-- 	{color= getColorByCountry(self.tViewDotMsg.nDotCountry) ,text= getCountryShortName(self.tViewDotMsg.nDotCountry, true)},
	-- 	{color= _cc.pwhite, text=string.format("%s X%s Y%s", self.tViewDotMsg:getDotName(), self.tViewDotMsg.nX, self.tViewDotMsg.nY)},
	-- }
	-- self.pTxtCityInfo:setString(tStr)
	self.pTxtDefName:setString(self.tViewDotMsg:getDotName()..getLvString(self.tViewDotMsg:getDotLv()))

	--城池图片
	WorldFunc.getSysCityIconOfContainer(self.pLayAtkCity, self.tViewDotMsg.nSystemCityId, self.tViewDotMsg.nDotCountry, true)

	--重新计算行军时间
	self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.tViewDotMsg.nX, self.tViewDotMsg.nY)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10729) .. formatTimeToMs(self.nMoveTime))

	--容错
	if not self.tData then
		return
	end
	--攻击方
	WorldFunc.setImgCountryFlag(self.pImgAtkFlag, self.tData.nAtkCountry)
	
	self.pTxtAtkTroops:setString(getConvertedStr(3, 10051)..tostring(self.tData.nAtkTroops))

	--防守方
	WorldFunc.setImgCountryFlag(self.pImgDefFlag, self.tData.nDefCountry)
	
	self.pTxtDefTroops:setString(getConvertedStr(3, 10052)..tostring(self.tData.nDefTroops))

	--是进攻方或被攻方才可显示
	if self.tData.nAtkCountry == Player.getPlayerInfo().nInfluence then		--进攻方

		if Player.getPlayerInfo().sName == self.tData.nAtkName then 		--我发起的 可以显示求援
			--最大求救值
		
		if self.nMaxHelp  and self.tData.nSupport then
			local nCurr = math.max(self.nMaxHelp - self.tData.nSupport, 0)
			if nCurr <= 0 then
				self.pBtnSupport:setExTextLbCnCr(2, tostring(nCurr) ,getC3B(_cc.red))
			else
				self.pBtnSupport:setExTextLbCnCr(2, tostring(nCurr) ,getC3B(_cc.white))
			end
			self:setBtnSupportVisible(true)
		end
			
		else
			self:setBtnSupportVisible(false)
		end

	elseif self.tViewDotMsg.nDotCountry == Player.getPlayerInfo().nInfluence then 		--防守方
		self:setBtnSupportVisible(false)
		self:setBtnJoinVisible(true)
		self.pBtnJoin:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtnJoin:updateBtnText(getConvertedStr(9,10035))
		-- self.pLayBtnJoin:setVisible(true)
	else
		self:setBtnSupportVisible(false)
		self:setBtnJoinVisible(false)
		-- self.pLayBtnJoin:setVisible(false)
	end
	--添加发起人和城主的信息
	local sStr1=string.format(getConvertedStr(9,10038),self.tData.nAtkName,getLvString(self.tData.nAtkLv))

	self.pTxtAtkCaller:setString(sStr1)
	local sStr2=""
	if self.tData.nDefName then
		sStr2=string.format(getConvertedStr(9,10039),self.tData.nDefName,getLvString(self.tData.nDefLv))
	else
		sStr2=getConvertedStr(9,10040)
	end
	self.pTxtDefOwner:setString(sStr2)

	self:setVisisbleBtnCenter()

	--倒计时
	self:updateCd()
end

--更新cd显示时间
function ItemCountryWar:updateCd(  )
	if not self.tData then
		return
	end

	local nCd = self.tData:getCd()
	self.pTxtCd:setString(getConvertedStr(3, 10728) .. formatTimeToMs(nCd))

	--行动时间
	if self.nMoveTime then

		if self.nMoveTime <= nCd then
			setTextCCColor(self.pTxtMoveTime, _cc.green)
		else
			setTextCCColor(self.pTxtMoveTime, _cc.red)
		end
	end
	if nCd <= 0 then
		sendMsg(ghd_dlg_country_war_close)
		unregUpdateControl(self)
	end
end

--获取国战cd,用于关闭父层
function ItemCountryWar:getCountryWarCd(  )
	if not self.tData then
		return 0
	end
	return self.tData:getCd()
end
--
--tData:  CountryWarMsg类型
function ItemCountryWar:setData( tData)
	if not tData then
		return
	end
	self.tData = tData

	self:updateViews()
end

function ItemCountryWar:onJoinClicked( pView )
	--容错
	if not self.tData then
		return
	end
	if not self.tViewDotMsg then
		return
	end
 
	--不可以跨区
	if not Player:getWorldData():getIsCanWarByPos(self.tViewDotMsg.nX, self.tViewDotMsg.nY, e_war_type.country) then
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
		if nOpenState > e_world_open_state.jun then 		--开州以上
			if nOpenState == e_world_open_state.kind then   --阿房宫开启
				TOAST(getTipsByIndex(20075))
			else
				TOAST(getTipsByIndex(20095))
			end
		else
			TOAST(getTipsByIndex(20076))
		end
		return
	end

	--行军时间较长
	local nMoveTime = WorldFunc.getMyArmyMoveTime(self.tViewDotMsg.nX, self.tViewDotMsg.nY)
	if nMoveTime > self.tData:getCd() then
		TOAST(getTipsByIndex(20031))
		return
	end

	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.battlehero, --dlg类型
	    nIndex = 5,--参加城战
	    tViewDotMsg = self.tViewDotMsg,
	    nAtkCountry = self.tData.nAtkCountry,
	    tCountryWarMsg = self.tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end


function ItemCountryWar:onLocationCityClicked( )
	if not self.tData then
		return
	end
	local tCityData = getWorldCityDataById(self.tData.nId)
	if tCityData then
		local fX, fY = WorldFunc.getMapPosByDotPosEx(tCityData.tCoordinate.x, tCityData.tCoordinate.y)
		sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
	end
end

--显示3个可见按钮居中
function ItemCountryWar:setVisisbleBtnCenter()
	local tBtns = {
		self.pLayBtnSupport,
		self.pLayBtnJoin,
		self.pLayBtnShare,
	}
	local tVisibleBtns = {}
	for i=1,#tBtns do
		if tBtns[i]:isVisible() then
			table.insert(tVisibleBtns, tBtns[i])
		end
	end

	local nNum=#tVisibleBtns
	-- print("num--",nNum)
	tVisibleBtns[1]:setPositionX(tBtnsPos[nNum].nBeginPos)
	for i = 2, #tVisibleBtns do 
		local nPrePos=tVisibleBtns[i-1]:getPositionX() + nBtnWidth
		tVisibleBtns[i]:setPositionX(nPrePos +tBtnsPos[nNum].nSpace )
	end

end

function ItemCountryWar:setBtnJoinVisible( bIsShow)
	self.pLayBtnJoin:setVisible(bIsShow)
	self.pBtnJoin:setVisible(bIsShow)
end
function ItemCountryWar:setBtnSupportVisible( bIsShow)
	if bIsShow then
		self:udpateSupportTimes()
	end
	self.pLayBtnSupport:setVisible(bIsShow)
	self.pBtnSupport:setVisible(bIsShow)
end
function ItemCountryWar:setBtnShareVisible( bIsShow)
	self.pLayBtnShare:setVisible(bIsShow)
	self.pBtnShare:setVisible(bIsShow)
end

--更新支援次数
function ItemCountryWar:udpateSupportTimes(  )
	local nCurr = math.max(self.nMaxHelp - self.tData.nSupport, 0)
	local sStr = string.format("%s（%s/%s）", getConvertedStr(3, 10425), nCurr, self.nMaxHelp)
	self.pBtnSupport:updateBtnText(sStr)
end

--分享按钮
function ItemCountryWar:onShareClicked( pView )
	-- dump(self.tData)
	if not self.tViewDotMsg then
		return
	end
	
	local tData = {
		bn = WorldFunc.getBlockId(self.tViewDotMsg.nX, self.tViewDotMsg.nY),
		dn = self.tViewDotMsg.sDotName,
		dx = self.tViewDotMsg.nX,
		dy = self.tViewDotMsg.nY,
		dt = e_share_type.syscity,
		dc = self.tViewDotMsg.nDotCountry,
		dl = self.tViewDotMsg.nLevel,
		did = self.tViewDotMsg.nSystemCityId
	}
	openShare(pView, e_share_id.city_pos, tData)
	
end
--发起城战求援
function ItemCountryWar:onSupportClicked( pView )
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.citywarhelp, --dlg类型
	    tViewDotMsg = self.tViewDotMsg,
	    tCityWarMsg = self.tData,
	    nWarType = 2,

	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function ItemCountryWar:getCityId( )
	-- body
	if self.tData then
		return self.tData.nId
	end
end

return ItemCountryWar


