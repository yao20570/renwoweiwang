----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-26 15:59:19
-- Description: 世界Boss战 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemBossWar = class("ItemBossWar", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemBossWar:ctor( tBossWarVO, tViewDotMsg ,nIsMyCountryJoin)
	self.tBossWarVO = tBossWarVO
	self.tViewDotMsg = tViewDotMsg
	self.nIsMyCountryJoin = nIsMyCountryJoin
	self.bIsMineCountry = self.tBossWarVO:getIsMineCountry()
	self.bIsMeSender = self.tBossWarVO:getIsMeSender()
	if self.bIsMeSender then
		--解析文件
		parseView("item_zhouwang_war_big", handler(self, self.onParseViewCallback))
	else
		--解析文件
		parseView("item_zhouwang_war", handler(self, self.onParseViewCallback))
	end
end

--解析界面回调
function ItemBossWar:onParseViewCallback( pView )
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
	self:setDestroyHandler("ItemBossWar",handler(self, self.onItemBossWarDestroy))
end

-- 析构方法
function ItemBossWar:onItemBossWarDestroy(  )
    self:onPause()
end

function ItemBossWar:regMsgs(  )
end

function ItemBossWar:unregMsgs(  )
end

function ItemBossWar:onResume(  )
	self:regMsgs()
end

function ItemBossWar:onPause(  )
	self:unregMsgs()
end

function ItemBossWar:setupViews(  )

	--分享按钮
	self.pLayBtnShare = self:findViewByName("lay_btn_share")
	
	self.pBtnShare = getCommonButtonOfContainer(self.pLayBtnShare,TypeCommonBtn.M_BLUE, getConvertedStr(9, 10034))
	self.pBtnShare:onCommonBtnClicked(handler(self, self.onShareClicked))
	setMCommonBtnScale(self.pLayBtnShare, self.pBtnShare, 0.8 )
	self.pLayBtnShare:setVisible(true)


	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.green)

	-- self.pTxtCityInfo = self:findViewByName("txt_city_info")
	self.pImgAtkFlag = self:findViewByName("img_atk_flag")
	self.pTxtAtkTroops = self:findViewByName("txt_atk_troops")
	self.pLayAtkCity = self:findViewByName("lay_atk_city")
	self.pImgDefFlag = self:findViewByName("img_def_flag")

	self.pTxtDefTroops = self:findViewByName("txt_def_troops")
		
	self.pTxtAtkName = self:findViewByName("txt_atk_name")
	self.pTxtDefName = self:findViewByName("txt_def_name")

	local pTxtAtkTitle = self:findViewByName("txt_atk_title")
	pTxtAtkTitle:setString(getConvertedStr(3, 10249))
	local pTxtDefTitle = self:findViewByName("txt_def_title")
	pTxtDefTitle:setString(getConvertedStr(3, 10250))

	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	
	--城池定位
	local pLayCityLocation = self:findViewByName("lay_city_location")
	pLayCityLocation:setViewTouched(true)
	pLayCityLocation:setIsPressedNeedScale(false)
	pLayCityLocation:setIsPressedNeedColor(false)
	pLayCityLocation:onMViewClicked(handler(self, self.onLocationCityClicked))

	--区别
	if self.bIsMeSender then
		local pLayBtnSupport = self:findViewByName("lay_btn_support")
		self.pLayBtnSupport = pLayBtnSupport
		local pBtnSupport = getCommonButtonOfContainer(pLayBtnSupport,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10043))
		pBtnSupport:onCommonBtnClicked(handler(self, self.onSupportClicked))
		setMCommonBtnScale(self.pLayBtnSupport, pBtnSupport, 0.8 )
		self.pBtnSupport = pBtnSupport

		local pLayBtnJoin = self:findViewByName("lay_btn_join")
		self.pLayBtnJoin = pLayBtnJoin
		local pBtnJoin = getCommonButtonOfContainer(pLayBtnJoin,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10508))
		pBtnJoin:onCommonBtnClicked(handler(self, self.onJoinClicked))
		setMCommonBtnScale(self.pLayBtnJoin, pBtnJoin, 0.8 )

	else
		self.pTxtTip = self:findViewByName("txt_tip")

		local pLayBtnJoin = self:findViewByName("lay_btn_join")
		self.pLayBtnJoin = pLayBtnJoin

		self.pLayBtnJoin:setVisible(false)
		if not self.pBtnJoin then
			self.pBtnJoin = getCommonButtonOfContainer(pLayBtnJoin,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10508))
			self.pBtnJoin:onCommonBtnClicked(handler(self, self.onJoinClicked))
			setMCommonBtnScale(self.pLayBtnJoin, self.pBtnJoin, 0.8 )
		end
		
		self.pBtnJoin:setVisible(false)

		if self.bIsMineCountry then
			self.pLayBtnJoin:setVisible(true)
			self.pBtnJoin:setVisible(true)
		else
			if not self.nIsMyCountryJoin then		--当前不是我国数据 且我国没人发起进攻
				self.pLayBtnJoin:setVisible(true)
				self.pBtnJoin:setVisible(true)
				self.pBtnJoin:updateBtnText(getConvertedStr(9, 10031))
				self.pBtnJoin:onCommonBtnClicked(handler(self, self.onClickRobed))
			else
				self.pLayBtnJoin:setVisible(false)
				self.pBtnJoin:setVisible(false)
			end
		end
	end
end

function ItemBossWar:updateViews(  )
	if not self.tBossWarVO then
		return
	end

	if not self.tViewDotMsg then
		return
	end

	--最大求救值
	if not self.nMaxHelp then
		local tAwakeBoss = getAwakeBossData(self.tViewDotMsg.nBossLv, Player:getWuWangDiff())
		if tAwakeBoss then
			self.nMaxHelp = tAwakeBoss.sostime
		end
	end

	--兵力
	self.pTxtAtkTroops:setString(getConvertedStr(3, 10051)..tostring(self.tBossWarVO.nAtkTroops))
	self.pTxtDefTroops:setString(getConvertedStr(3, 10052)..tostring(self.tBossWarVO.nDefTroops))
	local sStr1=string.format(getConvertedStr(9,10038), self.tBossWarVO:getSenderName(), getLvString(self.tBossWarVO:getSenderLv()))
	self.pTxtAtkName:setString(sStr1)

	--旗子
	WorldFunc.setImgCountryFlag(self.pImgAtkFlag, self.tBossWarVO.nSenderCountry)
	WorldFunc.setWorldBossFlag(self.pImgDefFlag, self.tViewDotMsg.nBossLv)

	--中间图片
	local pImg = WorldFunc.getBossIconOfContainer(self.pLayAtkCity, self.tViewDotMsg.nBossLv)
	if pImg then
		pImg:setScale(0.8)
	end

	local tAwakeBoss = getAwakeBossData(self.tViewDotMsg.nBossLv, Player:getWuWangDiff())
	if tAwakeBoss then
		self.pTxtDefName:setString(tAwakeBoss.name)--string.format("%s X%s Y%s", tAwakeBoss.name, self.tViewDotMsg.nX, self.tViewDotMsg.nY))
	end

	--更新次数
	self:udpateSupportTimes()

	--重新计算行军时间
	self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.tViewDotMsg.nX, self.tViewDotMsg.nY, self.tViewDotMsg.nBossLv)
	self.pTxtMoveTime:setString(getConvertedStr(3, 10729) .. formatTimeToMs(self.nMoveTime))

	--更新cd
	self:updateCd()

end

--更新支援次数
function ItemBossWar:udpateSupportTimes(  )
	if not self.pBtnSupport then
		return
	end

	if not self.tBossWarVO then
		return
	end

	if not self.tViewDotMsg then
		return
	end

	-- --最大求救值
	-- if not self.nMaxHelp then
	-- 	local tAwakeBoss = getAwakeBossData(self.tViewDotMsg.nBossLv, Player:getWuWangDiff())
	-- 	if tAwakeBoss then
	-- 		self.nMaxHelp = tAwakeBoss.sostime
	-- 	end
	-- 	--文字上面的文本
	-- 	local tConTable = {}
	-- 	local tLabel = {
	-- 		{getConvertedStr(3, 10130), getC3B(_cc.pwhite)},
	-- 		{"1",getC3B(_cc.white)},
	-- 		{"/"..tostring(self.nMaxHelp),getC3B(_cc.white)},
	-- 	}
	-- 	tConTable.tLabel = tLabel
	-- 	self.pBtnSupport:setBtnExText(tConTable)
	-- end

	if self.nMaxHelp then
		
	end
	local nCurr = math.max(self.nMaxHelp - self.tBossWarVO.nSupport, 0)
	-- if nCurr <= 0 then
	-- 	self.pBtnSupport:setExTextLbCnCr(2, tostring(nCurr) ,getC3B(_cc.red))
	-- else
	-- 	self.pBtnSupport:setExTextLbCnCr(2, tostring(nCurr) ,getC3B(_cc.white))
	-- end
	local sStr = string.format("%s（%s/%s）", getConvertedStr(3, 10425), nCurr, self.nMaxHelp)
	self.pBtnSupport:updateBtnText(sStr)

end

--更新cd显示
function ItemBossWar:updateCd(  )
	if not self.tBossWarVO then
		return
	end
	local nCd = self.tBossWarVO:getCd()
	self.pTxtCd:setString(getConvertedStr(3, 10728) .. formatTimeToMs(nCd))

	--行动时间
	if self.nMoveTime then
		if self.nMoveTime <= nCd then
			setTextCCColor(self.pTxtMoveTime, _cc.green)
		else
			setTextCCColor(self.pTxtMoveTime, _cc.red)
		end
	end
end

--获取开战时间
function ItemBossWar:getBeginFightCd( )
	if not self.tBossWarVO then
		return 0
	end
	return self.tBossWarVO:getCd()
end

--发起城战求援
function ItemBossWar:onSupportClicked( pView )
	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.bosswarhelp, --dlg类型
	    tViewDotMsg = self.tViewDotMsg,
	    tBossWarVO = self.tBossWarVO,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--参加城战
function ItemBossWar:onJoinClicked( pView )	
	--容错
	if not self.tViewDotMsg then
		return
	end

	--行军时间较长
	-- local nMoveTime = WorldFunc.getMyArmyMoveTime(self.tViewDotMsg.nX, self.tViewDotMsg.nY)
	-- if nMoveTime > self.tData:getCd() then
	-- 	TOAST(getTipsByIndex(20031))
	-- 	return
	-- end

	--等级限制
	local nLvNeed = getAwakeInitData("evilOpen")
	if nLvNeed and Player:getPlayerInfo().nLv < nLvNeed then
		TOAST(string.format(getTipsByIndex(20097),nLvNeed))

		-- TOAST(string.format(getConvertedStr(3, 10517), nLvNeed))
		return
	end

	--不可以跨区
	if not Player:getWorldData():getIsCanWarByPos(self.tViewDotMsg.nX, self.tViewDotMsg.nY, e_war_type.boss) then
		TOAST(getTipsByIndex(20032))
		return
	end

	--发送消息打开dlg
	local tObject = {
	    nType = e_dlg_index.battlehero, --dlg类型
	    nIndex = 6,--参加Boss
	    tViewDotMsg = self.tViewDotMsg,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--发送定位
function ItemBossWar:onLocationCityClicked( )
	if not self.tViewDotMsg then
		return
	end
	sendMsg(ghd_world_location_dotpos_msg, {nX = self.tViewDotMsg.nX, nY = self.tViewDotMsg.nY, isClick = true})
end

--求援次数扣1
function ItemBossWar:setUsedSupport( )
	if self.bIsMeSender then
		if self.tBossWarVO then
			self.tBossWarVO.nSupport = math.min(self.tBossWarVO.nSupport + 1, self.nMaxHelp)
			self:udpateSupportTimes()
		end
	end
end
--抢纣王
function ItemBossWar:onClickRobed( )
	-- body
	local tAwakeBoss=nil
	if self.tViewDotMsg then
		tAwakeBoss = getAwakeBossData(self.tViewDotMsg.nBossLv, Player:getWuWangDiff())
	end
	if not tAwakeBoss then
		return
	end
	
	--等级限制
	local nLvNeed = getAwakeInitData("evilOpen")
	if nLvNeed and Player:getPlayerInfo().nLv < nLvNeed then
		TOAST(string.format(getTipsByIndex(20097),nLvNeed))

		-- TOAST(string.format(getConvertedStr(3, 10517), nLvNeed))
		return
	end
	local nX, nY = self.tViewDotMsg.nX, self.tViewDotMsg.nY
	--不可以跨区
	if not Player:getWorldData():getIsCanWarByPos(nX, nY, e_war_type.boss) then
		TOAST(getTipsByIndex(20032))
		return
	end
	--二次确认
		local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    local tStr = {
	        {color=_cc.white,text=getConvertedStr(3, 10506)},
	        {color=_cc.blue,text= string.format("%s",tAwakeBoss.name)},
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

--分享按钮
function ItemBossWar:onShareClicked( pView )
	-- dump(self.tData)
	if not self.tViewDotMsg then
		return
	end
	local tData = {
		dn = self.tViewDotMsg.sDotName,
		dx = self.tViewDotMsg.nX,
		dy = self.tViewDotMsg.nY,
		dl = self.tViewDotMsg.nBossLv,
		dt = e_share_type.boss
	}
	openShare(pView, e_share_id.boss, tData)
	-- elseif self.tData:getIsMe() then  --分享我的坐标
	-- 	local tData = {
	-- 		dc = self.tData.nDotCountry,
	-- 		dn = self.tData.sDotName,
	-- 		dl = self.tData.nLevel,
	-- 		dx = self.tData.nX,
	-- 		dy = self.tData.nY,
	-- 		dt = e_share_type.player
	-- 	}
	-- 	openShare(pView, e_share_id.role_pos, tData)
	-- elseif self.tData.nSystemCityId then --系统城池 --分享的是城池坐标  
	-- 	local tData = {
	-- 		bn = WorldFunc.getBlockId(self.tData.nX, self.tData.nY),
	-- 		dn = self.tData.sDotName,
	-- 		dx = self.tData.nX,
	-- 		dy = self.tData.nY,
	-- 		dt = e_share_type.syscity,
	-- 		dc = self.tData.nDotCountry,
	-- 		dl = self.tData.nLevel,
	-- 		did = self.tData.nSystemCityId
	-- 	}
	-- 	openShare(pView, e_share_id.city_pos, tData)
	-- else
	-- 	local tData = {
	-- 		bn = WorldFunc.getBlockId(self.tData.nX, self.tData.nY),
	-- 		dn = self.tData.sDotName,
	-- 		dx = self.tData.nX,
	-- 		dy = self.tData.nY,
	-- 		dt = e_share_type.city,
	-- 		dc = self.tData.nDotCountry,
	-- 		dl = self.tData.nLevel,
	-- 	}
	-- 	openShare(pView, e_share_id.role_pos, tData)
	-- end
end


return ItemBossWar


