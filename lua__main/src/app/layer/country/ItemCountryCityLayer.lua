----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-06 19:48:14
-- Description: 国家城池
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local DlgAlert = require("app.common.dialog.DlgAlert")

local ItemCountryCityLayer = class("ItemCountryCityLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemCountryCityLayer:ctor(  )
	-- body
	self:myInit()
	parseView("item_country_city_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemCountryCityLayer:myInit(  )
	-- body
	--卸任
	self._recallHandler = handler(self, self.onRecallCityMaster)
	--补充城防handler
	self._suppleHandler = handler(self, self.onSuppleCity)
	--补充城防handler
	self._rebuildHandler = handler(self, self.onRebuildCity)	
end

--解析布局回调事件
function ItemCountryCityLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemCountryCityLayer",handler(self, self.onItemCountryCityLayerDestroy))
end

--初始化控件
function ItemCountryCityLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	self.pLayIcon = self:findViewByName("lay_city_icon")
	self.pLayFlag = self:findViewByName("lay_flag")
	self.pLbTip = self:findViewByName("lb_tip")
	setTextCCColor(self.pLbTip, _cc.pwhite)
	self.pLbTip:setString(getConvertedStr(6, 10480), false)

	self.pLbPar1 = self:findViewByName("lb_par1")
	self.pLbPar2 = self:findViewByName("lb_par2")
	self.pLbPar3 = self:findViewByName("lb_par3")

	self.pLayBtnTop = self:findViewByName("lay_btn_top")
	self.pBtnTop = getCommonButtonOfContainer(self.pLayBtnTop, TypeCommonBtn.O_RED, getConvertedStr(6, 10409), false)
	self.pBtnTop:onCommonBtnClicked(handler(self, self.onRecallCityMaster))
	self.pLayBtnBot = self:findViewByName("lay_btn_bot")	
	self.pBtnBot = getCommonButtonOfContainer(self.pLayBtnBot, TypeCommonBtn.O_BLUE, getConvertedStr(6, 10410), false)
	self.pLayBtnCenter = self:findViewByName("lay_btn_center")	
	self.pBtnCenter = getCommonButtonOfContainer(self.pLayBtnCenter, TypeCommonBtn.O_BLUE, getConvertedStr(6, 10410), false)
	self.pImgLine = self:findViewByName("img_line")

end

-- 修改控件内容或者是刷新控件数据
function ItemCountryCityLayer:updateViews( )
	-- body
	-- local CountryCityVo = require("app.layer.country.data.CountryCityVo")
	-- self.pCurData = CountryCityVo.new()
	-- dump(self.pCurData, "self.pCurData", 100)
	self:updateCollectTx()	--刷新征收特效
	if not self.pCurData then
		return		
	end
	--城池名称
	local citydata = getWorldCityDataById(self.pCurData.nID)
	--dump(citydata, "citydata", 100)
	-- local coord = citydata.tCoordinate	
	self.pImg = WorldFunc.getSysCityIconOfContainer(self.pLayIcon, self.pCurData.nID, Player:getPlayerInfo().nInfluence, true)		
	-- img:setPosition(img:getWidth()/2, self.pLayRoot:getHeight()/2)
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function (  )
		-- body
		local tCityData = getWorldCityDataById(self.pCurData.nID)
		if tCityData then
			closeAllDlg()
			sendMsg(ghd_world_location_mappos_msg, {fX = tCityData.tMapPos.x, fY = tCityData.tMapPos.y, isClick = true})
		end		    	
		closeDlgByType(e_dlg_index.dlgcountrycity, false)		
	end)		
	
	local tPar1Str = {
		{color=_cc.pwhite, text= citydata.name or ""},
		{color=_cc.blue, text=getLvString(self.pCurData.nCityLV, false)},
	}
	self.pLbPar1:setString(tPar1Str, false)

	local tPar2Str = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10362)},
		{color=_cc.blue,text=self.pCurData.sMName or ""},
		{color=_cc.blue,text= getLvString(self.pCurData.nMLv, false)},
	}
	if self.pCurData:isCityEmpty() == true then
		tPar2Str = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10362)},
			{color=_cc.blue,text=getConvertedStr(3, 10139)},
		}
	end
	self.pLbPar2:setString(tPar2Str, false)

	local tPar3Str = nil
	if self.pCurData.nMax and self.pCurData.nMax <= 0 then
		tPar3Str = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10363)},
			{color=_cc.pwhite,text="0"},
		}
	else
		tPar3Str = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10363)},
			{color=_cc.green,text=formatCountToStr(self.pCurData.nLeft)},
			{color=_cc.pwhite,text="/"..formatCountToStr(self.pCurData.nMax)},
		}
	end
	self.pLbPar3:setString(tPar3Str, false)

	--城主信息以及按钮显示
	if self.pCurData:isCityEmpty() == false then--
		if self.pCurData:isMineCity() == true then--当前玩家是城主
			if self.pCurData:isCanSupply() == true then
				self.pBtnCenter:setVisible(false)
				self.pBtnTop:setVisible(true)
				self.pBtnTop:updateBtnType(TypeCommonBtn.O_RED)
				self.pBtnTop:updateBtnText(getConvertedStr(6, 10409))
				self.pBtnTop:onCommonBtnClicked(self._recallHandler)
				self.pBtnBot:setVisible(true)
				self.pBtnBot:updateBtnType(TypeCommonBtn.O_BLUE)
				self.pBtnBot:updateBtnText(getConvertedStr(6, 10410))
				self.pBtnBot:onCommonBtnClicked(self._suppleHandler)
			else
				self.pBtnCenter:setVisible(true)
				self.pBtnCenter:updateBtnType(TypeCommonBtn.O_RED)
				self.pBtnCenter:updateBtnText(getConvertedStr(6, 10409))
				self.pBtnCenter:onCommonBtnClicked(self._recallHandler)
				self.pBtnTop:setVisible(false)
				self.pBtnBot:setVisible(false)
			end
		else
			if self.pCurData:isCanSupply() == true then
				self.pBtnCenter:setVisible(true)
				self.pBtnCenter:updateBtnType(TypeCommonBtn.O_BLUE)
				self.pBtnCenter:updateBtnText(getConvertedStr(6, 10410))
				self.pBtnCenter:onCommonBtnClicked(self._suppleHandler)
				self.pBtnTop:setVisible(false)
				self.pBtnBot:setVisible(false)
			else
				self.pBtnCenter:setVisible(false)
				self.pBtnTop:setVisible(false)
				self.pBtnBot:setVisible(false)
			end
		end				
	else--城池为空
		self.pBtnCenter:setVisible(true)--显示重建按钮
		self.pBtnCenter:updateBtnType(TypeCommonBtn.O_YELLOW)
		self.pBtnCenter:updateBtnText(getConvertedStr(6, 10411))
		self.pBtnCenter:onCommonBtnClicked(self._rebuildHandler)
		self.pBtnTop:setVisible(false)
		self.pBtnBot:setVisible(false)
	end
	self.pLayFlag:setVisible(self.pCurData:isMineCity())
	--处理按钮层叠之后对点击范围的影响	
	self.pLayBtnBot:setVisible(self.pBtnBot:isVisible())
	self.pLayBtnTop:setVisible(self.pBtnTop:isVisible())
	self.pLayBtnCenter:setVisible(self.pBtnCenter:isVisible())
end

--刷新征收特效 
function ItemCountryCityLayer:updateCollectTx(  )
	-- body
	local bCollect = false
	if self.pCurData and self.pCurData.nID then
		local tSysCitys = Player:getWorldData():getBlockSCOI(Player:getWorldData():getMyCityBlockId())
		local tSystemcityOcpyInfo = tSysCitys[self.pCurData.nID]
		if tSystemcityOcpyInfo then
			bCollect = tSystemcityOcpyInfo.bCanCollect
		end
	end	
	self:showCollectTx(bCollect)
end

--显示征收特效
function ItemCountryCityLayer:showCollectTx( _bShow )
	-- body
	-- self.pLayCollectArm
	--显示特效
	if not self.pImg then
		return
	end
	if _bShow then
		if not self.pLayCollectArm then
			self.pLayCollectArm = MUI.MLayer.new()
			self.pLayCollectArm:setLayoutSize(100, 100)
			self.pLayCollectArm:setAnchorPoint(0.5, 0.5)
			self.pLayIcon:addView(self.pLayCollectArm, 10)
			local nX, nY = self.pImg:getPosition()
			self.pLayCollectArm:setPosition(nX, nY + 25)
		end
		if not self.pCollectArm then
			--创建精灵			
			local pCollectArm = MArmatureUtils:createMArmature(EffectWorldDatas["smallCollectCover"], 
			self.pLayCollectArm, 
			1, 
			cc.p(50, 50),
		    function (  )
			end, self.nSceneArmType)
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

-- 析构方法
function ItemCountryCityLayer:onItemCountryCityLayerDestroy(  )
	-- body
end

--设置数据
function ItemCountryCityLayer:setCurData( _data )
	-- body
	self.pCurData = _data or self.pCurData
	self:updateViews()
end
--卸任城主
function ItemCountryCityLayer:onRecallCityMaster(  )
	-- body
	local citydata = getWorldCityDataById(self.pCurData.nID)
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
        SocketManager:sendMsg("reqWorldAbandonCityOwner", {self.pCurData.nID})
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(bNew)
end
--补充城防
function ItemCountryCityLayer:onSuppleCity(  )
	WorldFunc.fillSysCityTroops(self.pCurData.nID)
end
--重建申请城主
function ItemCountryCityLayer:onRebuildCity(  )
	--是否满足级数
	local nNeedLv = getWorldInitData("leaderLvLimit")
	if Player:getPlayerInfo().nLv < nNeedLv then
		TOAST(string.format(getConvertedStr(3, 10447), nNeedLv))
		return
	end
	
	-- body
	local citydata = getWorldCityDataById(self.pCurData.nID)
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
	SocketManager:sendMsg("reqWorldCityCandidate", {self.pCurData.nID, 0})

end
return ItemCountryCityLayer

 
