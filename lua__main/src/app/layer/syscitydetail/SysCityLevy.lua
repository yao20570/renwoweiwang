----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-04 17:19:00
-- Description: 系统城池资源征收
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")
local SysCityCollections = require("app.layer.world.SysCityCollections")

local nGoodsCol = 4

local SysCityLevy = class("SysCityLevy", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function SysCityLevy:ctor( nSysCityId )
	self.nSysCityId = nSysCityId
	parseView("layout_sys_city_levy", handler(self, self.onParseViewCallback))
end

--解析界面回调
function SysCityLevy:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("SysCityLevy",handler(self, self.onSysCityLevyDestroy))
end

-- 析构方法
function SysCityLevy:onSysCityLevyDestroy(  )
    self:onPause()
end

function SysCityLevy:regMsgs(  )
	--视图点发生变化 （倒计时结束）
	regMsg(self, gud_world_dot_change_msg, handler(self, self.onDotChange))

	--威望更新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updatePrestige))
end

function SysCityLevy:unregMsgs(  )
	--视图点发生变化 （倒计时结束）
	unregMsg(self, gud_world_dot_change_msg)

	--威望更新
	unregMsg(self, gud_refresh_playerinfo)
end

function SysCityLevy:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateViews()
end

function SysCityLevy:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function SysCityLevy:setupViews(  )
	local pLayInfo = self:findViewByName("lay_info")
	setGradientBackground(pLayInfo)

	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtProduceTip = self:findViewByName("txt_produce_tip")
	setTextCCColor(self.pTxtProduceTip, _cc.red)
	self.pTxtProduceTip:setString(getConvertedStr(3, 10396))
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	self.pImgFlag = self:findViewByName("img_flag")
	local pTxtOwnerTitle = self:findViewByName("txt_owner_title")
	pTxtOwnerTitle:setString(getConvertedStr(3, 10188))
	self.pTxtOwnerName = self:findViewByName("txt_owner_name")
	setTextCCColor(self.pTxtOwnerName, _cc.blue)
	self.pTxtFinishTip = self:findViewByName("txt_finish_tip")
	self.pTxtFinishCd = self:findViewByName("txt_finish_cd")
	setTextCCColor(self.pTxtFinishCd, _cc.red)
	local pTxtBannerTip = self:findViewByName("txt_banner_tip")
	-- pTxtBannerTip:setString(getConvertedStr(3, 10154))
	pTxtBannerTip:setString(string.format(getConvertedStr(3, 10138), getCostResName(e_type_resdata.prestige)))
	

	--中间文本提示
	local pTxtMiddleTip = self:findViewByName("txt_middle_tip")
	local tStr = getTextColorByConfigure(getTipsByIndex(10037))
	pTxtMiddleTip:setString(tStr)
	
	--生产提示
	self.pDbProduceTip=self:findViewByName("txt_db_produce_tip")
	

	local pLayBtnCollection = self:findViewByName("lay_btn_collection")
	self.pBtnCollection = getCommonButtonOfContainer(pLayBtnCollection,TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10157))
	self.pBtnCollection:onCommonBtnClicked(handler(self, self.onCollectionClicked))

	self.pBtnCollection:setBtnExText({tLabel = {{getConvertedStr(9, 10004)},{"",getC3B(_cc.white)},
												{getCostResName(e_type_resdata.prestige)},{"0", getC3B(_cc.green)},{"/0"}}})

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
	local nActivityId=getIsShowActivityBtn(e_dlg_index.syscitycollect)
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
function SysCityLevy:onListViewItemCallBack( _index, _pView)
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

function SysCityLevy:updateViews(  )
	if not self.nSysCityId then
		return
	end

	local tViewDotMsg = Player:getWorldData():getSysCityDot(self.nSysCityId)
	if not tViewDotMsg then
		return
	end

	--名字
	self.pTxtName:setString(string.format("%s %s",tViewDotMsg:getDotName(),getLvString(tViewDotMsg.nDotLv)))
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

function SysCityLevy:updateCd(  )
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
function SysCityLevy:updateCollectionBtn( )
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
function SysCityLevy:updatePrestige( )
	--威望显示
	self:updateCollectionBtn()
	--更新cd
	self:updateCd()
end

--获取强征令倍数
function SysCityLevy:getForceTokenRate( tCityData )
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

function SysCityLevy:onCollectionClicked( pView )
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
function SysCityLevy:onDotChange( sMsgName, pMsgObj )
	-- dump("hhhh",pMsgObj)
	local tViewDotMsg = pMsgObj
	if tViewDotMsg then
		if tViewDotMsg.nSystemCityId == self.nSysCityId then
			self:updateViews()
		end
	end
end

return SysCityLevy