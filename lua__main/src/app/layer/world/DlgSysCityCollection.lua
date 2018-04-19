----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-10 14:53:34
-- Description: 系统城池资源征收
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgAlert = require("app.common.dialog.DlgAlert")
local SysCityCollections = require("app.layer.world.SysCityCollections")

local nGoodsCol = 4

local DlgSysCityCollection = class("DlgSysCityCollection", function()
	return DlgCommon.new(e_dlg_index.syscitycollect, 800 - 60 - 130, 150)
end)

function DlgSysCityCollection:ctor(  )
	parseView("dlg_sys_city_collection", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgSysCityCollection:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10152))
	self.pView = pView
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSysCityCollection",handler(self, self.onDlgSysCityCollectionDestroy))
end

-- 析构方法
function DlgSysCityCollection:onDlgSysCityCollectionDestroy(  )
    self:onPause()
end

function DlgSysCityCollection:regMsgs(  )
	--视图点发生变化 （倒计时结束）
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))

	--威望更新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updatePrestige))
end

function DlgSysCityCollection:unregMsgs(  )
	--视图点发生变化 （倒计时结束）
	unregMsg(self, gud_world_dot_change_msg)

	--威望更新
	unregMsg(self, gud_refresh_playerinfo)
end

function DlgSysCityCollection:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function DlgSysCityCollection:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgSysCityCollection:setupViews(  )
	--ui位置更新
	local tUiPos = {
		{sUiName = "lay_info", nTopSpac = 12},
		{sUiName = "lay_banner", nTopSpac = 10},
		{sUiName = "lay_rewards", nTopSpac = 0},
		{sUiName = "lay_btn_collection", nBottomSpac = 40},
		{sUiName = "txt_produce_tip", nBottomSpac = 18},
	}
	restUiPosByData(tUiPos, self.pView)
	--ui位置更新

	local pLayInfo = self:findViewByName("lay_info")
	setGradientBackground(pLayInfo)

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtProduceTip = self:findViewByName("txt_produce_tip")
	setTextCCColor(self.pTxtProduceTip, _cc.red)
	self.pTxtProduceTip:setString(getConvertedStr(3, 10396))
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pImgFlag = self:findViewByName("img_flag")
	local pTxtPosTitle = self:findViewByName("txt_pos_title")
	pTxtPosTitle:setString(getConvertedStr(3, 10109))
	self.pTxtPos = self:findViewByName("txt_pos")
	setTextCCColor(self.pTxtPos, _cc.blue)
	local pTxtOwnerTitle = self:findViewByName("txt_owner_title")
	pTxtOwnerTitle:setString(getConvertedStr(3, 10188))
	self.pTxtOwnerName = self:findViewByName("txt_owner_name")
	setTextCCColor(self.pTxtOwnerName, _cc.blue)
	self.pTxtFinishTip = self:findViewByName("txt_finish_tip")
	self.pTxtFinishCd = self:findViewByName("txt_finish_cd")
	setTextCCColor(self.pTxtFinishCd, _cc.red)
	local pTxtBannerTip = self:findViewByName("txt_banner_tip")
	pTxtBannerTip:setString(getConvertedStr(3, 10154))

	--组合文本提示
	local pLayRichtextTip = self:findViewByName("lay_richtext_tip")
	local tStr = getTextColorByConfigure(getTipsByIndex(10037))
	getRichLabelOfContainer(pLayRichtextTip,tStr)

	self.pDbProduceTip=self:findViewByName("txt_db_produce_tip")
	-- self.pDbProduceTip:setPositionY(self.pDbProduceTip:getPositionY())
	

	local pLayBtnCollection = self:findViewByName("lay_btn_collection")
	-- pLayBtnCollection:setPositionY(pLayBtnCollection:getPositionY()+20)
	self.pBtnCollection = getCommonButtonOfContainer(pLayBtnCollection,TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10157))
	self.pBtnCollection:onCommonBtnClicked(handler(self, self.onCollectionClicked))

	self.pBtnCollection:setBtnExText({tLabel = {{getConvertedStr(9, 10004)},{"",getC3B(_cc.white)},
												{getCostResName(e_type_resdata.prestige)},{"0", getC3B(_cc.green)},{"/0"}}})
	-- self.pBtnCollection:setPositionY(self.pBtnCollection:getPositionY()+35)

	--征收物品
	--奖励滚动层
	self.pLayRewards = self:findViewByName("lay_rewards")
    self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, self.pLayRewards:getContentSize().width, self.pLayRewards:getContentSize().height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left =  0,
             right =  0,
             top =  5,
             bottom =  5},
    }
    self.pLayRewards:addView(self.pListView)
    self.pListView:setItemCount(0) 
    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))

    --显示活动便签
	local nActivityId=getIsShowActivityBtn(self.eDlgType)
    if nActivityId>0 then
    	self.pLayActBtn=self:findViewByName("lay_act_btn")
    	self.pActBtn = addActivityBtn(self.pLayActBtn,nActivityId)
    else
    	if self.pActBtn then
    		self.pActBtn:removeSelf()
    		self.pActBtn=nil
    	end
    end

end

--列表回调
function DlgSysCityCollection:onListViewItemCallBack( _index, _pView)
    local pTempView = _pView
    if pTempView == nil then
        pTempView = SysCityCollections.new()
    end
    local nBeginX, nBeginY, nOffsetX, nOffsetY = 40, 0, 160, 0
    local nIndex = (_index - 1) * nGoodsCol

    for i=1,nGoodsCol do
    	local tTempData = self.tDropList[nIndex + i]
    	if tTempData then
    		pTempView:setIcon(i, tTempData)
    	else
    		pTempView:setIcon(i, nil)
    	end
    end
    return pTempView
end

function DlgSysCityCollection:updateViews(  )
	if not self.nSysCityId then
		return
	end

	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	-- dump(tViewDotMsg)

	--名字
	self.pTxtName:setString(string.format("%s %s",tViewDotMsg:getDotName(),getLvString(tViewDotMsg.nDotLv)))
	--坐标
	self.pTxtPos:setString(getWorldPosString(tViewDotMsg.nX, tViewDotMsg.nY))
	--城主
	local sOwnerName = tViewDotMsg:getSysCityOwnerName()
	local nOwnerLv = tViewDotMsg:getSysCityOwnerLv()
	if sOwnerName and nOwnerLv then
		self.pTxtOwnerName:setString(string.format("%s %s", sOwnerName, getLvString(nOwnerLv)))
	else
		self.pTxtOwnerName:setString(getConvertedStr(3, 10139))
	end
	--旗
	WorldFunc.setImgCountryFlag(self.pImgFlag, tViewDotMsg.nDotCountry)

	--图标
	WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tViewDotMsg.nSystemCityId, tViewDotMsg.nDotCountry ,true)
		
	--奖励图纸
	local tCityData = getWorldCityDataById(tViewDotMsg.nSystemCityId)
	if tCityData then
		--掉落数据
		local tDropList = getDropById(tCityData.drop)
		local bIsReload = true
		if self.tDropList then
			if math.ceil(#self.tDropList/nGoodsCol) == math.ceil(#tDropList/nGoodsCol) then
				bIsReload = false
			end
		end
		self.tDropList = tDropList
		if bIsReload then
			if self.pListView:getItemCount() > 0 then
			    self.pListView:removeAllItems()
			end
			self.pListView:setItemCount(math.ceil(#self.tDropList/nGoodsCol))
		    self.pListView:reload()
		else
			self.pListView:notifyDataSetChange(true)
		end
	end
	--威望显示
	self:updateCollectionBtn()
	--更新cd
	self:updateCd()
end

function DlgSysCityCollection:updateCd(  )
	if not self.nSysCityId then
		return
	end

	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--可以征收
	if tViewDotMsg.bHasPaper then
		self.pTxtFinishCd:setVisible(false)
		setTextCCColor(self.pTxtFinishTip, _cc.green)
		self.pTxtFinishTip:setString(getConvertedStr(3, 10153))
		self.pBtnCollection:setBtnEnable(true)
		self.pBtnCollection:setExTextVisiable(true)
		self.pTxtProduceTip:setVisible(false)
	else
		self.pTxtFinishCd:setVisible(true)
		setTextCCColor(self.pTxtFinishTip, _cc.white)
		self.pTxtFinishTip:setString(getConvertedStr(3, 10193))
		self.pBtnCollection:setBtnEnable(false)
		self.pBtnCollection:setExTextVisiable(false)

		self.pBtnCollection:updateBtnText(getConvertedStr(3, 10157))
		self.pBtnCollection:removeLingTx()

		self.pTxtProduceTip:setVisible(true)

		local nCd = tViewDotMsg:getPaperCd()
		if nCd then
			self.pTxtFinishCd:setString(formatTimeToHms(nCd))
		end
	end
end

--更新采集按钮
function DlgSysCityCollection:updateCollectionBtn( )
	if not self.nSysCityId then
		return
	end

	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--奖励图纸
	local tCityData = getWorldCityDataById(tViewDotMsg.nSystemCityId)
	if tCityData then
		--消耗
		local nCurrPrestige = Player:getPlayerInfo().nPrestige
		
		local tData = luaSplit(tCityData.prestige, ":")
		if type(tData) == "table" then
			local nNeedPrestige = tonumber(tData[2])
			if nNeedPrestige then
				--倍率
				local nRate ,nGoodId,nCt= self:getForceTokenRate(tCityData)
				nNeedPrestige = nNeedPrestige * nRate
				if nRate==1 then 

					local sColor = ""
					if nCurrPrestige >= nNeedPrestige then
						sColor = _cc.green
						self.pBtnCollection:setBtnEnable(true)
					else
						sColor = _cc.red
						self.pBtnCollection:setBtnEnable(false)
					end
					self.pBtnCollection:setExTextLbCnCr(2,"",getC3B(_cc.white))

					self.pBtnCollection:setExTextLbCnCr(5,"/" .. getResourcesStr(nNeedPrestige))
					self.pBtnCollection:setExTextLbCnCr(4, getResourcesStr(nCurrPrestige), getC3B(sColor))

					self.pBtnCollection:updateBtnText(getConvertedStr(3, 10157))
					self.pBtnCollection:removeLingTx()
				elseif nRate==2 then
					if nCurrPrestige>=nNeedPrestige then
						local tGood=getGoodsByTidFromDB(nGoodId)

						self.pBtnCollection:setExTextLbCnCr(2,tGood.sName .. "*".. nCt.." ",getC3B(_cc.white))
						self.pBtnCollection:setExTextLbCnCr(5,"/"..getResourcesStr(nNeedPrestige))
						self.pBtnCollection:setExTextLbCnCr(4, getResourcesStr(nCurrPrestige), getC3B(_cc.green))
						-- self.pBtnCollection:setExTextLbCnCr(4,)

						self.pBtnCollection:updateBtnText(getConvertedStr(9,10006))
						self.pBtnCollection:showLingTx()
						self.pBtnCollection:setBtnEnable(true)
						local sSbStr=getTextColorByConfigure(getTipsByIndex(20060))
						self.pDbProduceTip:setString(sSbStr)
					else
						self.pBtnCollection:setExTextLbCnCr(5,"/".. getResourcesStr(nNeedPrestige))
						self.pBtnCollection:setExTextLbCnCr(4, getResourcesStr(nCurrPrestige), getC3B(_cc.red))
						self.pBtnCollection:setBtnEnable(false)
					end

				end
			end
		end
	end
end

--更新威望
function DlgSysCityCollection:updatePrestige( )
	--威望显示
	self:updateCollectionBtn()
	--更新cd
	self:updateCd()
end

--nSysCityId:系统城池id
function DlgSysCityCollection:setData( nSysCityId)
	self.nSysCityId = nSysCityId
	self:updateViews()
end

--获取强征令倍数
function DlgSysCityCollection:getForceTokenRate( tCityData )
	if tCityData then 
		if tCityData.kind then
			local tData = getWorldInitData("collectPaperdoubleCost")
			if tData then
				local tData2 = tData[tCityData.kind]
				if tData2 then
					if checkIsResourceEnough(tData2.nGoodsId, tData2.nCt) then
						return 2, tData2.nGoodsId,tData2.nCt
					end
				end
			end
		end
	end
	return 1
end

function DlgSysCityCollection:onCollectionClicked( pView )
	--容错
	if not self.nSysCityId then
		return
	end
	--容错
	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end
	--没有纸
	if not tViewDotMsg.bHasPaper then
		TOAST(getConvertedStr(3, 10158))
		return
	end
	--不是同一势力
	if Player:getPlayerInfo().nInfluence ~= tViewDotMsg.nDotCountry then
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(3, 10366))
	    pDlg:setOnlyConfirm()
	    pDlg:showDlg(bNew)
		return
	end
	--不能跨区域征收资源
	if WorldFunc.getIsCrossBlock(tViewDotMsg.nX, tViewDotMsg.nY) then
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(3, 10159))
	    pDlg:setOnlyConfirm()
	    pDlg:showDlg(bNew)
		return
	end

	local tCityData = getWorldCityDataById(tViewDotMsg.nSystemCityId)
	if tCityData then
		--倍率
		local nRate = self:getForceTokenRate(tCityData)
		--判断是否满足购买
		if checkIsResourceStrEnough(tCityData.prestige, false, nRate) then
			SocketManager:sendMsg("reqWorldLevyPaper", {self.nSysCityId}, function ( __msg )
				if  __msg.head.state == SocketErrorType.success then 
		            if __msg.head.type == MsgType.reqWorldLevyPaper.id then
		            	showGetAllItems(__msg.body.ob, 2)
		            end
		        else
		            TOAST(SocketManager:getErrorStr(__msg.head.state))
		        end
			end)
			-- self:closeDlg(false)
		else
			--弹出购买
			local tRes = parseGoodStrToTable(tCityData.prestige)
			for i=1,#tRes do
		        local nId = tRes[i].nId
		        local nNum = tRes[i].nNum * nRate
		        if not checkIsResourceEnough(nId, nNum) then
		            local data = getShopDataById(nId)	
					if not data then
						TOAST(getConvertedStr(6, 10438))
						return 
					end					
					local tObject = {
					    nType = e_dlg_index.shopbatchbuy, --dlg类型
					    tShopBase = data,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
		        end
		    end
		end
	end
end

--监听数据发生改变
function DlgSysCityCollection:onDotChange( sMsgName, pMsgObj )
	-- dump("hhhh",pMsgObj)
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		if tViewDotMsg.nSystemCityId == self.nSysCityId then
			self:updateViews()
		end
	end
end

return DlgSysCityCollection