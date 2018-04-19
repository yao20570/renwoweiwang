----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 城池详细界面 侦查子界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")

local ItemCountryCity = class("ItemCountryCity", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCountryCity:ctor(  )
	--解析文件
	parseView("item_country_city", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCountryCity:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCountryCity", handler(self, self.onItemCountryCityDestroy))
end

-- 析构方法
function ItemCountryCity:onItemCountryCityDestroy(  )
    self:onPause()
end

function ItemCountryCity:regMsgs(  )
end

function ItemCountryCity:unregMsgs(  )
end

function ItemCountryCity:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemCountryCity:onPause(  )
	self:unregMsgs()
end

function ItemCountryCity:setupViews(  )
	self.pLayCityIcon = self:findViewByName("lay_city_icon")
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtCity = self:findViewByName("txt_city")
	setTextCCColor(self.pTxtCity,_cc.blue)
	self.pTxtOwner = self:findViewByName("txt_owner")
	self.pTxtTroops = self:findViewByName("txt_troops")
	self.pLayBtn1 = self:findViewByName("lay_btn1")
	self.pLayBtn2 = self:findViewByName("lay_btn2")
	local pLayJump = self:findViewByName("lay_jump")
	pLayJump:setViewTouched(true)
	pLayJump:setIsPressedNeedScale(false)
	pLayJump:setIsPressedNeedColor(false)
	pLayJump:onMViewClicked(function ( _pView )
	    if not self.tData then
			return
		end
		local tCityData = getWorldCityDataById(self.tData:getId())
		if tCityData then
			closeAllDlg()
			local fX, fY = tCityData.tMapPos.x, tCityData.tMapPos.y
            sendMsg(ghd_world_location_mappos_msg, {fX = fX, fY = fY, isClick = true})
		end
	end)

	self.pBtn1 = getCommonButtonOfContainer(self.pLayBtn1,TypeCommonBtn.M_BLUE, "")
	self.pLayBtn1:setVisible(false)
	self.pBtn2 = getCommonButtonOfContainer(self.pLayBtn2,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10094))
	self.pBtn2:onCommonBtnClicked(handler(self, self.onSuppleCity))
	self.pLayBtn2:setVisible(false)
end

function ItemCountryCity:updateViews(  )
	if not self.tData then
		return
	end
	self.pImg = WorldFunc.getSysCityIconOfContainer(self.pLayCityIcon, self.tData:getId(), Player:getPlayerInfo().nInfluence ,true)
	local tSysCityData = getWorldCityDataById(self.tData:getId())
	if tSysCityData then
		local tBlockData = getWorldMapDataById(tSysCityData.map)
		if tBlockData then
			local tStr = {
				{color=_cc.white,text=tBlockData.name..":"},
			    {color=_cc.green,text=getWorldPosString(tSysCityData.tCoordinate.x, tSysCityData.tCoordinate.y)},
			}
			self.pTxtPos:setString(tStr)
		end

		self.pTxtCity:setString(tSysCityData.name..getLvString(self.tData:getCityLv()))

		local tStr = {
			{color=_cc.white,text=getConvertedStr(3, 10135)},
		}
		local tTroopsStr = {
			{color=_cc.white,text=getConvertedStr(3, 10136)},	
		}
		if self.tData:isCityEmpty() then
			table.insert(tStr, {color=_cc.blue,text=getConvertedStr(3, 10139)})
			table.insert(tTroopsStr, {color=_cc.blue,text="0"})
			table.insert(tTroopsStr, {color=_cc.white,text="/0"})
		else
			table.insert(tStr, {color=_cc.blue,text=tostring(self.tData:getMName())})
			table.insert(tTroopsStr, {color=_cc.blue,text=tostring(self.tData:getRemainTroops())})
			table.insert(tTroopsStr, {color=_cc.white,text="/"..tostring(self.tData:getTroopsMax())})
		end
		self.pTxtOwner:setString(tStr)
		self.pTxtTroops:setString(tTroopsStr)

		--按钮
		local middleY = 33
		if self.tData:isCityEmpty() then --可以申请
			self.pLayBtn1:setPositionY(middleY)
			self.pLayBtn1:setVisible(true)
			self.pLayBtn2:setVisible(false)

			self.pBtn1:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(3, 10088))
			self.pBtn1:onCommonBtnClicked(handler(self, self.onRebuildCity))
		elseif self.tData:isMineCity() then --自己是城主
			if self.tData:isCanSupply() then--可以补充城防
				self.pLayBtn1:setPositionY(73)
				self.pLayBtn1:setVisible(true)
				self.pLayBtn2:setVisible(true)
			else
				self.pLayBtn1:setPositionY(middleY)
				self.pLayBtn1:setVisible(true)
				self.pLayBtn2:setVisible(false)
			end
			self.pBtn1:setButton(TypeCommonBtn.M_RED, getConvertedStr(3, 10093))
			self.pBtn1:onCommonBtnClicked(handler(self, self.onRecallCityMaster))
		else
			if self.tData:isCanSupply() then--可以补充城防
				self.pLayBtn1:setPositionY(middleY)
				self.pLayBtn1:setVisible(true)
				self.pLayBtn2:setVisible(false)
				self.pBtn1:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10094))
				self.pBtn1:onCommonBtnClicked(handler(self, self.onSuppleCity))
			else
				self.pLayBtn1:setVisible(false)
				self.pLayBtn2:setVisible(false)
			end
		end
	end
	--显示征收特效
	self:showCollectTx(self.tData:getHasPaper())
end

--显示征收特效
function ItemCountryCity:showCollectTx( _bShow )
	--显示特效
	if not self.pImg then
		return
	end
	if _bShow then
		if not self.pLayCollectArm then
			self.pLayCollectArm = MUI.MLayer.new()
			self.pLayCollectArm:setLayoutSize(100, 100)
			self.pLayCollectArm:setAnchorPoint(0.5, 0.5)
			self.pLayCityIcon:addView(self.pLayCollectArm)
			local nX, nY = self.pImg:getPosition()
			self.pLayCollectArm:setPosition(nX, nY)-- + self.pImg:getHeight()/2 - 5)
		end
		if not self.pCollectArm then
			--创建精灵			
			local pCollectArm = MArmatureUtils:createMArmature(EffectWorldDatas["smallCollectCover"], 
			self.pLayCollectArm, 
			1, 
			cc.p(50, 50),
		    function (  )
			end, Scene_arm_type.normal)
			pCollectArm:play(-1)
			self.pCollectArm = pCollectArm
		else
			self.pCollectArm:play(-1)
			self.pCollectArm:setVisible(true)				
		end
		--粒子特效		
		if not self.pCollectLZ then
			self.pCollectLZ = createParitcle("tx/other/lizi_rwww_zslz_001.plist")
			self.pCollectLZ:setPosition(self.pLayCollectArm:getWidth() / 2 ,self.pLayCollectArm:getHeight() / 2)
			self.pLayCollectArm:addView(self.pCollectLZ)
			self.pCollectLZ:setScale(1.05)
			centerInView(self.pLayCollectArm,self.pCollectLZ)
		end
		self.pCollectLZ:setVisible(true)
	else--隐藏特效
		if self.pCollectArm then		
			self.pCollectArm:stop()
			self.pCollectArm:setVisible(false)		
		end
		if self.pCollectLZ then
			self.pCollectLZ:setVisible(false)
		end
	end
end

--tData: CountryCityVo
function ItemCountryCity:setData( tData )
	self.tData = tData
	self:updateViews()
end

--申请城主
function ItemCountryCity:onRebuildCity(  )
	if not self.tData then
		return
	end
	local nId = self.tData:getId()
	--是否满足级数
	local nNeedLv = getWorldInitData("leaderLvLimit")
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10447), nNeedLv))
		return
	end
	
	-- body
	local citydata = getWorldCityDataById(nId)
	if not citydata then
		return
	end
	--有城的情况下直接返回
	local bIsBe = Player:getCountryData():isPlayerBeCityMaster()
	if bIsBe then
		TOAST(getTipsByIndex(568))
		return
	end

	--申请候选人命令
	SocketManager:sendMsg("reqWorldCityCandidate", {nId, 0})
end

--被充城防点
function ItemCountryCity:onSuppleCity(  )
	if not self.tData then
		return
	end
	local nId = self.tData:getId()
	WorldFunc.fillSysCityTroops(nId)
end

--卸任城主点击(copy代码)
function ItemCountryCity:onRecallCityMaster(  )
	if not self.tData then
		return
	end
	local nId = self.tData:getId()
	local citydata = getWorldCityDataById(nId)
	if not citydata then
		return
	end

	local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))

    local tStr = {
    	{color=_cc.pwhite,text=getConvertedStr(3, 10196)},
	    {color=_cc.blue,text=citydata.name},
	    {color=_cc.pwhite,text=getConvertedStr(3, 10197)},
	}
	local pLabel = MUI.MLabel.new({
        text="",
        size=20,
        anchorpoint=cc.p(0.5, 0.5),
        dimensions = cc.size(380, 0),
        })
	pLabel:setString(tStr, false)
    pDlg:addContentView(pLabel)
    pDlg:setRightHandler(function (  )
        SocketManager:sendMsg("reqWorldAbandonCityOwner", {nId})
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(bNew)
end

return ItemCountryCity


