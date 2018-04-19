----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-26 10:35:42
-- Description: 铁匠铺界面
-----------------------------------------------------
local ItemPalaceCivil = require("app.layer.palace.ItemPalaceCivil")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemSmithEquip = require("app.layer.smithshop.ItemSmithEquip")
local ItemSmithMaterial = require("app.layer.smithshop.ItemSmithMaterial")


-- 铁匠铺界面
-- local DlgBase = require("app.common.dialog.DlgBase")
local MCommonView = require("app.common.MCommonView")
local LaySmithShop = class("LaySmithShop", function()
	-- return DlgBase.new(e_dlg_index.smithshop)
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LaySmithShop:ctor( _tSize )
	self:setContentSize(_tSize)
	parseView("dlg_smith_shop", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LaySmithShop:onParseViewCallback( pView )
	self:addView(pView)
	-- self:addContentView(pView) --加入内容层
	-- self:addContentTopSpace()
	
	-- self:setTitle(getConvertedStr(3, 10265))
	self:setupViews()
	--分帧
	self.bIsFrame = true
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LaySmithShop",handler(self, self.onLaySmithShopDestroy))
end

-- 析构方法
function LaySmithShop:onLaySmithShopDestroy(  )
	nCollectCnt = 2
    self:onPause()
end

function LaySmithShop:regMsgs(  )
	--打造装备发生变化
	regMsg(self, gud_equip_makevo_change_msg, handler(self, self.onMakeEquipChange))
	--雇用成功
	regMsg(self, gud_equip_smith_hire_msg, handler(self, self.onSmithHireMsg))
	--背包物品数量发生变化
	regMsg(self, gud_refresh_playerinfo, handler(self, self.onMakeEquipChange))
	--购买物品刷新消息
	regMsg(self, ghd_shop_buy_success_msg, handler(self, self.onMakeEquipChange))
	--物品变化刷新
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateRedNum))

end

function LaySmithShop:unregMsgs(  )
	--打造装备发生变化
	unregMsg(self, gud_equip_makevo_change_msg)
	--雇用成功
	unregMsg(self, gud_equip_smith_hire_msg)
	--注销背包物品数量发生变化消息
	unregMsg(self, gud_refresh_playerinfo)
	--注销购买物品刷新消息
	unregMsg(self, ghd_shop_buy_success_msg)
	unregMsg(self, gud_refresh_baginfo)
end

function LaySmithShop:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function LaySmithShop:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
	self.nEnterSelKind = nil
	--本地记录最后选中的装备id
	saveLocalInfo("Smithshop_Sel_Equip"..Player:getPlayerInfo().pid, self.nSelEquipId)
end

function LaySmithShop:setupViews()

	self.tMaterialsPos = {}
	self.tMaterialsPos[2] = {{0, 210, 305}, {180, 430, 305}}
	self.tMaterialsPos[3] = {{90, 314, 441}, {330, 220, 209}, {210, 420, 209}}
	self.tMaterialsPos[5] = {{90, 314, 441}, {18, 192, 349}, {306, 220, 209}, {234, 420, 209}, {162, 448, 349}}
	self.tMaterialsPos[6] = {{60, 220, 401}, {0, 220, 305}, {300, 220, 209}, {240, 420, 209}, {180, 420, 305}, {120, 420, 401}}
	self.tItemMaterials = {}

    self.pLaySmithHire = self:findViewByName("lay_smith_hire")
    self.pLayContent = self:findViewByName("lay_content")
	local pLayTab = self:findViewByName("lay_tab")
	local pLayEquip1 = self:findViewByName("lay_equip1")
	local pLayEquip2 = self:findViewByName("lay_equip2")
	local pLayEquip3 = self:findViewByName("lay_equip3")
	local pLayEquip4 = self:findViewByName("lay_equip4")
	local pLayEquip5 = self:findViewByName("lay_equip5")
	local pLayEquip6 = self:findViewByName("lay_equip6")
	self.pLayEquips = {
		[e_type_equip.weapon] = pLayEquip1,
		[e_type_equip.horse] = pLayEquip2,
		[e_type_equip.clothes] = pLayEquip3,
		[e_type_equip.helmet] = pLayEquip4,
		[e_type_equip.yin] = pLayEquip5,
		[e_type_equip.fu] = pLayEquip6,
	}
	self.pLbCurEqInfo = self:findViewByName("lb_cureq_info")
	self.pLbCurEqImg = self:findViewByName("img_curequip")
	self.pLayBottom1 = self:findViewByName("lay_bottom1")
	self.pLayBottom1:setVisible(false)

	self.pLayTabHost = self:findViewByName("lay_tab")

	-- local pTxtBottom1Banner = self:findViewByName("txt_bottom1_banner")
	-- pTxtBottom1Banner:setString(getConvertedStr(3, 10289))

	local pLayBtnSmiths = self:findViewByName("lay_btn_smiths")
	local pBtnSmiths = getCommonButtonOfContainer(pLayBtnSmiths, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10262))
	pBtnSmiths:onCommonBtnClicked(handler(self, self.onSmithsClicked))
	local tBtnTable = {}
	local tLabel = {
	 {"0",getC3B(_cc.pwhite)},
	}
	tBtnTable.tLabel = tLabel
	tBtnTable.img = "#v1_img_shizhong.png"
	pBtnSmiths:setBtnExText(tBtnTable,false)
	self.pBtnSmiths = pBtnSmiths

	-- local pLayMaterial1 = self:findViewByName("lay_material1")
	-- local pLayMaterial2 = self:findViewByName("lay_material2")
	-- local pLayMaterial3 = self:findViewByName("lay_material3")
	-- local pLayMaterial4 = self:findViewByName("lay_material4")
	-- local pLayMaterial5 = self:findViewByName("lay_material5")
	-- local pLayMaterial6 = self:findViewByName("lay_material6")
	-- self.pLayMaterials = {
	-- 	pLayMaterial1,
	-- 	pLayMaterial2,
	-- 	pLayMaterial3,
	-- 	pLayMaterial4,
	-- 	pLayMaterial5,
	-- 	pLayMaterial6,
	-- }
	-- for i=1,#self.pLayMaterials do
	-- 	self.pLayMaterials[i]:setPositionY(self.pLayMaterials[i]:getPositionY() - 20)
	-- end
	--self.nMaterialWidth = pLayMaterial1:getContentSize().width - 5

	self.pLayBottom2 = self:findViewByName("lay_bottom2")
	self.pLayBottom2:setVisible(false)

	--打造中的cd时间
	self.pTxtClock = self:findViewByName("txt_clock")
	setTextCCColor(self.pTxtClock, _cc.pwhite)
	self.pLayBtnFinish = self:findViewByName("lay_btn_finish")

	--头顶横条(banner)
	local pBannerImage = self:findViewByName("lay_banner_bg")
	local pMBanner = setMBannerImage(pBannerImage,TypeBannerUsed.tjp)
	-- pMBanner:setMBannerOpacity(100)	
end

--分侦加载
function LaySmithShop:updateViews(  )
    gRefreshViewsAsync(self, 6, function ( _bEnd, _index )
        if(_index == 1) then
        	if not self.pItemPalaceCivil then
        		self.pItemPalaceCivil = ItemPalaceCivil.new(e_hire_type.smith, true) --文官信息Item	
				self.pLaySmithHire:addView(self.pItemPalaceCivil, 10)		
				self.pItemPalaceCivil:hideDiBg()
				centerInView(self.pLaySmithHire, self.pItemPalaceCivil)					
				--手指
				self.pItemPalaceCivil:setGuideFinger()
			else
				self.pItemPalaceCivil:updateViews()
        	end
        elseif(_index == 2) then
        	--切换卡层
        	if not self.pTComTabHost then
				local tTitles = {
					getConvertedStr(3, 10253),
					getConvertedStr(3, 10254),
					getConvertedStr(3, 10255),
					getConvertedStr(3, 10256),
					getConvertedStr(3, 10257),
					-- getConvertedStr(3, 10258), --屏蔽红装
				}
				self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,tTitles,handler(self, self.onIndexSelected))
				local tColor = {
					_ccq.white ,
					_ccq.green ,
					_ccq.blue  ,
					_ccq.purple,
					_ccq.orange,
					-- _ccq.red   ,  --屏蔽红装
				}
				self.pTabItems = self.pTComTabHost:getTabItems()
				for i=1,#self.pTabItems do
					self.pTabItems[i]:onMViewDisabledClicked(handler(self, self.onDisabledClicked))
					self.pTabItems[i].nIndex = i
				end
				self.pTComTabHost:setTabLabelColors(tColor)
				self.pLayTabHost:addView(self.pTComTabHost)
				self.pTComTabHost:removeLayTmp1()
			end
			self:updateTabLocks()
        elseif(_index == 3) then
        	--装备
        	if not self.pEquips then
				self.pEquips = {}
				for nKind,pLayEquip in pairs(self.pLayEquips) do
					local pItemSmithEquip = ItemSmithEquip.new(nKind)
					pItemSmithEquip:setIconClickedHandler(handler(self, self.onEquipIconClicked))
					pLayEquip:addView(pItemSmithEquip)
					pItemSmithEquip:setVisible(false)
					self.pEquips[nKind] = pItemSmithEquip
				end
				--装备集和选中框
				self:setDefaultEquipShowInFrame(1)
			end
		elseif(_index == 4) then
			--显示当前装备
			self:setDefaultEquipShowInFrame(2)
        elseif(_index == 5) then
        	--立即完成按钮上面的字
        	if not self.pBtnFinish then
				local pBtnFinish = getCommonButtonOfContainer(self.pLayBtnFinish,TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10259), false)
				pBtnFinish:onCommonBtnClicked(handler(self, self.onFinishClicked))
				self.pBtnFinish = pBtnFinish
			end

			showRedTips(self.pLayBtnFinish, 0, isCanUseItemSpeed(4), 3)	
			--加速按钮
			if not self.pLayBtnQuick then
				self.pLayBtnQuick = self:findViewByName("lay_btn_quick")
				local pBtnQuick = getCommonButtonOfContainer(self.pLayBtnQuick,TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10260))
				pBtnQuick:onCommonBtnClicked(handler(self, self.onQuickClicked))
				self.pBtnQuick = pBtnQuick
				local tBtnTable = {}
				local tLabel = {
					{getConvertedStr(3, 10261),getC3B(_cc.pwhite)},
				}
				tBtnTable.tLabel = tLabel
				pBtnQuick:setBtnExText(tBtnTable)
			end
			--打造中的进度条
			if not self.pSlider then
				local pLayBarTroops = self:findViewByName("lay_bar_cd")
				local pSize = pLayBarTroops:getContentSize()
				self.nSliderW = pSize.width
				self.pSlider = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
			        {bar="ui/daitu.png",
			        button="ui/daitu.png",
			        barfg="ui/bar/v1_bar_blue_2.png"}, 
			        {scale9 = true, touchInButton=false})
				self.pSlider:setViewTouched(false)
				self.pSlider:setSliderSize(pSize.width, pSize.height)
				pLayBarTroops:addView(self.pSlider, 10)
				centerInView(pLayBarTroops, self.pSlider)
				self.pTx = createSliderTx(self.pSlider:getSliderBarBall())
			end

			--显示下方按钮
			self:updateBottom()
        elseif(_index == 6) then
        	--新手引导加速
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnQuick, e_guide_finer.tjp_equip_speed)

        	local function showFingerGuide()
				-- body
				sendMsg(ghd_guide_finger_show_or_hide, true)
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnSmiths, e_guide_finer.build_equip_btn)
			end
			--新手引导打造
			doDelayForSomething(self, showFingerGuide, 0.01)

			--分帧结束
			self.bIsFrame = false
        end
    end)
end

--铁匠铺每次打开的显示装备, add by shulan
function LaySmithShop:setDefaultEquipShow( nEquipID)
	self.nDefaultEquipId = nEquipID
	--不分侦时可以用
	if not self.bIsFrame then
		local tEquipData = getBaseEquipDataByID(self.nDefaultEquipId)
		if tEquipData then
			self.nQuality = tEquipData.nQuality
			self.pTComTabHost:setDefaultIndex(self.nQuality)
		end
	end
end

--铁匠铺显示对应种类的最高品质的装备
function LaySmithShop:setDefaultKindShow( nKind )
	-- body
	self.nEnterSelKind = nKind
	if not nKind then
		return
	end
	self.nQuality = self:getFirstLockTabIndex() - 1
	local tEquipDatas = getEquipsInSmith(self.nQuality)
	for j=1,#tEquipDatas do
		if nKind == tEquipDatas[j].nKind then
			self.nDefaultEquipId = tEquipDatas[j].sTid
			break
		end
	end
end
--分帧设置装备信息
--nShowType :显示类型（1：品质对应的装备集，2，当前选中的装备)
--强制显示设置
function LaySmithShop:setDefaultEquipShowInFrame( nShowType )
	--有指定打造id时
	if self.nDefaultEquipId then
		self:showEquip(self.nDefaultEquipId, nShowType)
	else
		--显示正在打造的装备
		local tMakeVo = Player:getEquipData():getMakeVo()
		if tMakeVo then
			local tEquipData = getBaseEquipDataByID(tMakeVo.nId)
			if tEquipData then
				self.nQuality = tEquipData.nQuality
				if nShowType == 1 then
					self.pTComTabHost:setDefaultIndex(self.nQuality)
					self:updateEquips()
					self:setEquipSelectBorder(tEquipData.nKind)
				elseif nShowType == 2 then
					self:setEquipSelect(tEquipData.nKind)
				end
			end
		else
			--上次离开时选中的装备
			local nEquipId = tonumber(getLocalInfo("Smithshop_Sel_Equip"..Player:getPlayerInfo().pid, "0"))
			if nEquipId and nEquipId > 0 then
				self:showEquip(nEquipId, nShowType)
				return
			end
			--没有正在打造的装备时，进入选中的是已解锁最高品质的第一件装备
			if nShowType == 1 then
				self.nQuality = self:getFirstLockTabIndex() - 1
				self.pTComTabHost:setDefaultIndex(self.nQuality)
				self:updateEquips()
				self:setEquipSelectBorder(1)
			elseif nShowType == 2 then
				self:setEquipSelect(1)
			end
		end
	end
end

--显示装备
--_equipId:装备id, _showTp:显示类型
function LaySmithShop:showEquip(_equipId, _showTp)
	-- body
	local tEquipData = getBaseEquipDataByID(_equipId)
	if tEquipData then
		self.nQuality = tEquipData.nQuality
		if _showTp == 1 then
			self.pTComTabHost:setDefaultIndex(self.nQuality)
			self:updateEquips()
			self:setEquipSelectBorder(tEquipData.nKind)
		elseif _showTp == 2 then
			self:setEquipSelect(tEquipData.nKind)
		end
	end
end

--下标选择回调事件(分帧后才真正有效)
function LaySmithShop:onIndexSelected( nIndex )
	--如果当前分帧中就返回
	if self.bIsFrame then
		return
	end
	self.nQuality = nIndex
	self:updateEquips()
	--设置选中框
	self:setEquipSelectBorder(1)
	self:setEquipSelect(1)
	self:updateBottom()
end

--获取当前第一个上锁的切换卡
function LaySmithShop:getFirstLockTabIndex(  )
	local nQualityMax = getEquipQualityMax()
	for i=1, nQualityMax do
		local bIsLock = true
		local tEquipDatas = getEquipsInSmith(i)
		for j=1,#tEquipDatas do
			if Player:getPlayerInfo().nLv >= tEquipDatas[j].nMakeLv then
				bIsLock = false
				break
			end
		end
		if bIsLock then
			return i
		end
	end
	return nil
end

--更新装备
function LaySmithShop:updateEquips(  )
	--容错
	if not self.pEquips then
		return
	end
	--装备集
	local tEquipDatas = getEquipsInSmith(self.nQuality)
	for i=1,#tEquipDatas do
		local tEquipData = tEquipDatas[i]
		local pEquips = self.pEquips[tEquipData.nKind]
		if pEquips then
			pEquips:setData(tEquipData)
			pEquips:setVisible(true)
		end
	end
	--如果有正在打造的装备
	local tMakeVo = Player:getEquipData():getMakeVo()
	if tMakeVo then
		local tEquipData = getBaseEquipDataByID(tMakeVo.nId)
		if tEquipData then
			local nQuality = tEquipData.nQuality
			for i=1,#self.pTabItems do
				if i == nQuality then
					self.pTabItems[i]:showIsMaking()
				else
					self.pTabItems[i]:hideIsMaking()
				end
			end
		end
	end
end

--更新切换图标
function LaySmithShop:updateTabLocks(  )
	if not self.pTabItems then
		return
	end
	--切换按钮上的上锁标识
	local nLockIndex = self:getFirstLockTabIndex()
	for i=1,#self.pTabItems do
		if i < nLockIndex then
			self.pTabItems[i]:hideTabLock()
			self.pTabItems[i]:setViewEnabled(true)
		else
			self.pTabItems[i]:showTabLock()
			self.pTabItems[i]:setViewEnabled(false)
		end
	end
end

--设置禁示点击方法
function LaySmithShop:onDisabledClicked( pView )
	local tEquipDatas = getEquipsInSmith(pView.nIndex)
	table.sort(tEquipDatas, function(a, b)
		return a.nMakeLv < b.nMakeLv
	end)
	local tEquipData = tEquipDatas[1]
	TOAST(string.format(getConvertedStr(3, 10263), tEquipData.nMakeLv))
end

--设置选中框显示(为了显示好看，抽出来，显示品质装备集时显示选中)
function LaySmithShop:setEquipSelectBorder( nIndex )
	if not nIndex  then
		return
	end
	for k, v in pairs(self.pEquips) do
		v:setSelected(k == nIndex)
		if k == nIndex then
			local tEquip = v:getData()
			if tEquip then
				self.nSelEquipId = tEquip.sTid
			end
		end
	end
end

--设置当前的装备
function LaySmithShop:setEquipSelect( nIndex )
	--当前选中的装备
	local tEquipDatas = getEquipsInSmith(self.nQuality)
	if tEquipDatas then
		local tEquipData = tEquipDatas[nIndex]
		if tEquipData then
			self.tEquipData = tEquipData
			self.pLbCurEqImg:setCurrentImage(tEquipData.sIcon)
			--dump(self.tEquipData, "self.tEquipData", 100)
			if self.pLbCurEqInfo then
				local sAttrs = tEquipData.sAttrs
				local tAttrs = luaSplit(sAttrs, ":")
				local nAttrId = tonumber(tAttrs[1])
				local nAttrValue = tonumber(tAttrs[2])
				if nAttrId and nAttrValue then
					local tAttData = getBaseAttData(nAttrId)
					if tAttData then
						local tLb = {
							{text = tEquipData.sName, color = getC3B(getColorByQuality(tEquipData.nQuality))},--玩家名字
							{text = " "..tAttData.sName, color = getC3B(_cc.pwhite)},--主要属性名字
							{text = "+"..nAttrValue, color = getC3B(_cc.blue)},--属性值
						}
						self.pLbCurEqInfo:setString(tLb, false)
					end
				end
			end
		end
	end
end

--设置选中的装备
--nIndex 装备集选中的装备下标
function LaySmithShop:onEquipIconClicked( nIndex)
	--在分侦就返回
	if self.bIsFrame then
		return
	end
	--设置选中框
	self:setEquipSelectBorder(nIndex)
	--当前选中的装备
	self:setEquipSelect(nIndex)
	--更新下方
	self:updateBottom()
end

--更新打造消耗
function LaySmithShop:updateCost(  )
	if not self.tEquipData then
		return
	end
	local sMaterials = self.tEquipData.sMakeCosts
	local tMaterials = parseGoodStrToTable(sMaterials)
	-- dump(tMaterials, "tMaterials", 100)
	self.tMaterials = tMaterials
	local tPosParams = self.tMaterialsPos[#tMaterials]
	-- dump(tPosParams, "tPosParams", 100)
	for i = 1, 6 do
		if not self.tItemMaterials[i] then
			self.tItemMaterials[i] = ItemSmithMaterial.new()
			self.tItemMaterials[i]:setVisible(false)
			self.pLayContent:addView(self.tItemMaterials[i], 10)
		end
		local pItemMaterials = self.tItemMaterials[i]
		if tPosParams and tPosParams[i] then --显示			
			pItemMaterials:setPosParam(tPosParams[i])
			pItemMaterials:setData(tMaterials[i])
			pItemMaterials:setVisible(true)
		else--不显示
			pItemMaterials:setVisible(false)
		end
	end
end

function LaySmithShop:updateCd( )
	if self.bIsFrame then
		return
	end
	
	local tMakeVo = Player:getEquipData():getMakeVo()
	if not tMakeVo then
		return
	end
	--打造cd
	local nCd = tMakeVo:getCd()
	if nCd == 0 then --打造完成后关闭本界面
		if self.nEnterSelKind then
			--从装备背包跳转过来的关掉武将相关界面
			closeDlgByType(e_dlg_index.equipbag, false)
			closeDlgByType(e_dlg_index.heromain, false)
			closeDlgByType(e_dlg_index.dlgherolineup, false)
		end
		
		closeDlgByType(e_dlg_index.smithshop, false)
		return
	end

	--显示打造数据
	local tEquipData = self.tEquipData
	if not tEquipData then
		return
	end
	--打造中装备
	if tMakeVo.nId == tEquipData.sTid then
		--进度条
		self.pTxtClock:setString(formatTimeToHms(nCd))
		self.pSlider:setSliderValue((1 - nCd/tEquipData.nMakeTimes) *100)
		--立即完成黄金扣除
		-- local nCost =  math.ceil(nCd/60) * tonumber(getBuildParam("makeTimeSpeed"))
		-- self.pBtnFinish:setExTextLbCnCr(1,nCost)
	end
	local nDisX = self.nSliderW*(1 - nCd/tEquipData.nMakeTimes)
	if self.pTx and nDisX > self.pTx.width then
		setSliderTxVisible(self.pTx, true)
	else
	 	setSliderTxVisible(self.pTx, false)
	end
end

--更新下方部分
function LaySmithShop:updateBottom()
	local tEquipData = self.tEquipData
	if not tEquipData then
		return
	end

	--更新消耗
	self:updateCost()

	--打造中装备
	if Player:getEquipData():getCurrMakingId() == tEquipData.sTid then
		self.pLayBottom2:setVisible(true)
		self.pLayBottom1:setVisible(false)
		if Player:getEquipData():getIsCanSpeed() then
			--铁匠加速
			self.pLayBtnQuick:setVisible(true)
			self.pBtnQuick:setExTextVisiable(true)
			--立即完成
			self.pLayBtnFinish:setVisible(false)
			-- self.pBtnFinish:setExTextVisiable(false)
		else
			--铁匠加速
			self.pLayBtnQuick:setVisible(false)
			self.pBtnQuick:setExTextVisiable(false)

			local tMakeVo = Player:getEquipData():getMakeVo()
			if tMakeVo and tMakeVo.nHelp == 0 and getIsReachOpenCon(3, false) then
				self.pBtnFinish:updateBtnText(getConvertedStr(1, 10425)) 
			else
				self.pBtnFinish:updateBtnText(getConvertedStr(3, 10259))
			end
			--立即完成
			self.pLayBtnFinish:setVisible(true)
			-- self.pBtnFinish:setExTextVisiable(true)
			
		end
		--更新cd
		self:updateCd()
	else
		self.pLayBottom1:setVisible(true)
		self.pLayBottom2:setVisible(false)

		--未解锁
		if Player:getPlayerInfo().nLv < tEquipData.nMakeLv then
			self.pBtnSmiths:setExTextImg()
			self.pBtnSmiths:setExTextLbCnCr(1, string.format(getConvertedStr(3, 10263), tEquipData.nMakeLv),getC3B(_cc.red))
			self.pBtnSmiths:setBtnEnable(false)
		else
			--已有装备打造中
			if Player:getEquipData():getCurrMakingId() then
				self.pBtnSmiths:setExTextImg()
				self.pBtnSmiths:setExTextLbCnCr(1,getConvertedStr(3, 10264),getC3B(_cc.red))
				self.pBtnSmiths:setBtnEnable(false)
			else
				self.pBtnSmiths:setExTextImg("#v1_img_shizhong.png",false)
				self.pBtnSmiths:setExTextLbCnCr(1,formatTimeToHms(tEquipData.nMakeTimes),getC3B(_cc.pwhite))
				self.pBtnSmiths:setBtnEnable(true)
			end
		end
	end
end

--立即完成回调
function LaySmithShop:onFinishClicked( pView )

	if self.pBtnFinish:getBtnText() == getConvertedStr(1, 10425) then
		SocketManager:sendMsg("makevoupinghelp", {})

	else
		local tMakeVo = Player:getEquipData():getMakeVo()
		if not tMakeVo then
			return
		end
		--打造cd
		local nCd = tMakeVo:getCd()


		--显示打造数据
		local tEquipData = self.tEquipData
		if not tEquipData then
			return
		end
			
		--立即完成黄金扣除
		-- local nCost =  math.ceil(nCd/60) * tonumber(getBuildParam("makeTimeSpeed"))

		-- local function sendReq( )
		-- 	SocketManager:sendMsg("reqMakeQuickByCoin")
		-- end
		-- local tStr = {
	 --    	{color = _cc.pwhite, text = getConvertedStr(3, 10296)},
	 --    }
		-- showBuyDlg(tStr, nCost, sendReq)

		local tObject = {}
		tObject.nFunType = 4
		tObject.nType = e_dlg_index.buildprop --dlg类型	
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--免费加速
function LaySmithShop:onQuickClicked( pView )
	 
	SocketManager:sendMsg("reqMakeQuick", {}, function(__msg)
		-- body
		if __msg.head.state == SocketErrorType.success then
			TOAST(getConvertedStr(7, 10122))
		end
		--新手引导加速点后
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.tjp_equip_speed)
	end)

end 

--装备打造
function LaySmithShop:onSmithsClicked( pView )
	local tEquipData = self.tEquipData
	if not tEquipData then
		return
	end

	self.tResList = {}
	self.tResList[e_resdata_ids.lc] = 0
	self.tResList[e_resdata_ids.bt] = 0
	self.tResList[e_resdata_ids.mc] = 0
	self.tResList[e_resdata_ids.yb] = 0
	if self.tMaterials then
		for k, v in pairs(self.tMaterials) do
			if v.nId>=e_type_resdata.food and v.nId<=e_type_resdata.iron then		--缺少的是基础资源的时候 弹出购买资源对话框
				self.tResList[v.nId] = v.nNum
			end
		end
	end
	--先判断打造消耗的材料是否足够
	for k, v in pairs(self.tMaterials) do
		local pGood = getGoodsByTidFromDB(v.nId)
		if pGood then
			local nHasNum = getMyGoodsCnt(v.nId)
			if nHasNum < v.nNum then
				if v.nId>=e_type_resdata.food and v.nId<=e_type_resdata.iron then		--缺少的是基础资源的时候 弹出购买资源对话框
					goToBuyRes(v.nId, self.tResList)
					return
				else
					local data = getShopDataById(v.nId)
					--如果该物品不能在商店购买, 直接弹不足提示
					if not data then
						TOAST(pGood.sName..getConvertedStr(7, 10118))
						return 
					end					
					local tObject = {
					    nType = e_dlg_index.shopbatchbuy, --dlg类型
					    tShopBase = data,
					}
					sendMsg(ghd_show_dlg_by_type, tObject)
					return
				end
			end
		end
	end
	SocketManager:sendMsg("reqEquipMake", {tEquipData.sTid},function ( __msg )
		-- body
		if __msg.head.state == SocketErrorType.success then
			--播放音效
			Sounds.playEffect(Sounds.Effect.make)
			TOAST(string.format(getConvertedStr(7, 10334), tEquipData.sName))
		end
		--新手引导打造已点击
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnSmiths)
	end)

end

--装备打造发生变化
function LaySmithShop:onMakeEquipChange()
	self:updateEquips()
	self:updateBottom()
end


--雇佣发生改变
function LaySmithShop:onSmithHireMsg( )
	if self.pItemPalaceCivil then
		self.pItemPalaceCivil:updateViews()
	end
	self:updateBottom()
end

--更新物品红点
function LaySmithShop:updateRedNum( ... )
	if self.pLayBtnFinish then
		showRedTips(self.pLayBtnFinish, 0, isCanUseItemSpeed(4), 3)	
	end
end

return LaySmithShop