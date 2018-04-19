----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-10 15:07:17
-- Description: 世界目标打群系统城池
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local nRandemMoveCityId = 100027 --随机移城id
local DlgWorldTargetCapital = class("DlgWorldTargetCapital", function()
	return DlgCommon.new(e_dlg_index.worldtargetcapital,750-130,130)
end)

function DlgWorldTargetCapital:ctor(  )
	parseView("dlg_world_target_capital", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldTargetCapital:onParseViewCallback( pView )
	self:addContentView(pView, true) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldTargetCapital",handler(self, self.onDlgWorldTargetCapitalDestroy))
end

-- 析构方法
function DlgWorldTargetCapital:onDlgWorldTargetCapitalDestroy(  )
    self:onPause()
end

function DlgWorldTargetCapital:regMsgs(  )
	regMsg(self, gud_world_target_top_refresh, handler(self, self.udpateBottomBtn))
	regMsg(self, gud_world_target_capital_refresh, handler(self, self.updateCapital))
end

function DlgWorldTargetCapital:unregMsgs(  )
	unregMsg(self, gud_world_target_top_refresh)
	unregMsg(self, gud_world_target_capital_refresh)
end

function DlgWorldTargetCapital:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgWorldTargetCapital:onPause(  )
	self:unregMsgs()
end

function DlgWorldTargetCapital:setupViews(  )
	local pLayView = self:findViewByName("view")
	local pLayBorder = self:findViewByName("lay_border")
	local pTxtBanner = self:findViewByName("txt_banner")
	pTxtBanner:setString(getConvertedStr(3, 10385))
	self.pLayGoods = self:findViewByName("lay_goods")
	self.pTxtTip = self:findViewByName("txt_tip")

	self.pTxtTip2 = self:findViewByName("txt_tip2")
	self.pTxtTip2:setString(getTipsByIndex(10047))

	local pLayBtn = self:findViewByName("lay_btn")
	self.pBottomBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10162))
	self.pBottomBtn:onCommonBtnClicked(handler(self, self.onBottomClicked))

	local pImgCountry1 = self:findViewByName("img_country1")
	local pImgCountry2 = self:findViewByName("img_country2")
	local pImgCountry3 = self:findViewByName("img_country3")
	local pTxtCountry1 = self:findViewByName("txt_country1")
	local pTxtCountry2 = self:findViewByName("txt_country2")
	local pTxtCountry3 = self:findViewByName("txt_country3")
	self.pCountryUis = {
		[e_type_country.weiguo] = {pImgCountry = pImgCountry1, pTxtCountry = pTxtCountry1},
		[e_type_country.shuguo] = {pImgCountry = pImgCountry2, pTxtCountry = pTxtCountry2},
		[e_type_country.wuguo] = {pImgCountry = pImgCountry3, pTxtCountry = pTxtCountry3},
	}
	for k,v in pairs(self.pCountryUis) do
		WorldFunc.setImgCountryFlag(v.pImgCountry, k)
	end

	--背景
	local pImgBg = MUI.MImage.new("ui/bg_world/v1_bg_fdft01.jpg")
	pLayView:addView(pImgBg)
	local nX, nY = pLayBorder:getPosition()
	pImgBg:setPosition(nX + pImgBg:getContentSize().width/2, nY + pImgBg:getContentSize().height/2)


	--布局中默认的按钮隐藏
	local pBtn = self:getOnlyConfirmButton()
	pBtn:setVisible(false)
	if self.pLayContent then
		self.pLayContent:setZOrder(10)
	end
end

function DlgWorldTargetCapital:updateViews(  )
	--我当前的状态
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end

	--标题
	self:setTitle(tWorldTargetData.desc)

	--介绍
	self.pTxtTip:setString(tWorldTargetData.info)

	--奖励物品
	if tWorldTargetData.award then
		local tGoodsList = getDropById(tWorldTargetData.award)
		gRefreshHorizontalList(self.pLayGoods, tGoodsList)
	end

	--更新城池占领
	self:updateCapital()
	--更新底部按钮
	self:udpateBottomBtn()
end

--更新城池占领
function DlgWorldTargetCapital:updateCapital( )
	--城池占领信息
	local tCapitalInfo = Player:getWorldData():getCapitalInfo()
	if tCapitalInfo then
		for k,v in pairs(self.pCountryUis) do
			if tCapitalInfo[k] then
				v.pTxtCountry:setString(getConvertedStr(3, 10398))
				setTextCCColor(v.pTxtCountry, _cc.green) 
			else
				v.pTxtCountry:setString(getConvertedStr(3, 10397))
				setTextCCColor(v.pTxtCountry, _cc.red) 
			end
		end
	end
end

--更新底部按钮
function DlgWorldTargetCapital:udpateBottomBtn( )
	--前往或领奖按钮
	self.bIsGet = Player:getWorldData():getIsCanGetWTCapitalReward()
	if self.bIsGet then
		self.pBottomBtn:updateBtnText(getConvertedStr(3, 10386)) 
		self.pBottomBtn:updateBtnType(TypeCommonBtn.L_YELLOW)
		self.pBottomBtn:setVisible(true)
		self.pTxtTip2:setVisible(false)
	else
		--自己的城池当前是否在王宫
		-- local bIsShowFree = false
		-- local nMyBlockId = Player:getWorldData():getMyCityBlockId()
		-- local tBlockData = getWorldMapDataById(nMyBlockId)
		-- if tBlockData and tBlockData.type ~= e_type_block.kind then
		-- 	--是否可以免费迁城
		-- 	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
		-- 	local tWorldTargetData = getWorldTargetData(nMyTargetId)
		-- 	if tWorldTargetData and tWorldTargetData.migratetype and tWorldTargetData.migratetype > 0 then
		-- 		--dump(Player:getWorldData():getUsedMoveCity())
		-- 		if Player:getWorldData():getIsUsedMoveCity(nMyTargetId) then
		-- 			bIsShowFree = false
		-- 		else
		-- 			bIsShowFree = true
		-- 		end
		-- 	end
		-- end
		self.pBottomBtn:updateBtnText(getConvertedStr(3, 10162)) 
		self.pBottomBtn:updateBtnType(TypeCommonBtn.L_BLUE) 
		local tCapitalInfo = Player:getWorldData():getCapitalInfo() 
		if tCapitalInfo[Player:getPlayerInfo().nInfluence] then
			self.pBottomBtn:setVisible(false)
			self.pTxtTip2:setVisible(true)
		else
			self.pBottomBtn:setVisible(true)
			self.pTxtTip2:setVisible(false)
		end
	end
end

function DlgWorldTargetCapital:onBottomClicked( pView )
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end
	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end

	--是否获得
	if self.bIsGet then
		--领取奖励
		SocketManager:sendMsg("regWorldTargetReward",{nMyTargetId})
		closeDlgByType(e_dlg_index.worldtargetcapital, false)
	else
		local tCapitalInfo = Player:getWorldData():getCapitalInfo()
		local tOutIdDict = {}
		for k,v in pairs(tCapitalInfo) do
			tOutIdDict[v] = true
		end
		local tCityData = getRandomSysCityByKind(e_kind_city.ducheng, tOutIdDict)
		if not tCityData then
			myprint("随机系统城市出错")
			return
		end

		--直接定位
		local function locationToTarget(  )
    		sendMsg(ghd_world_dot_near_my_city,{nDotType = e_type_builddot.sysCity, nSysCityId = tCityData.id})
    		closeDlgByType(e_dlg_index.worldtargetcapital, false)
    		--如果从聊天界面跳过去的要关掉聊天界面
			closeDlgByType(e_dlg_index.dlgchat)
		end

		--1，如果玩家当位置在州，
		local nMyBlockId = Player:getWorldData():getMyCityBlockId()
		local tBlockData = getWorldMapDataById(nMyBlockId)
		local tTargetBlockData = getWorldMapDataById(tCityData.map)
		if tBlockData and tTargetBlockData then
			if tBlockData.type >= tTargetBlockData.type then
				--直接定位
				locationToTarget()
				return
			end
		end

		--2,判断是否可以使用迁城道具
		-- if tWorldTargetData.migratetype and tWorldTargetData.migratetype > 0 then
		-- 	--是否有使用过迁城道具
		-- 	local bIsUsedMoveCity = Player:getWorldData():getIsUsedMoveCity(nMyTargetId)
		-- 	if not bIsUsedMoveCity then
		-- 		SocketManager:sendMsg("reqWorldTargetUsedMoveCity", {0})
		-- 		return
				-- local sName = ""
				-- local nCost = 0
			 --    local pGood = getGoodsByTidFromDB(nRandemMoveCityId)
			 --    if pGood then
			 --        sName = pGood.sName.."*1"
			 --        nCost = pGood.nPrice
			 --    end

				-- --弹出迁城道具使用
				-- if getIsResourceEnough(nRandemMoveCityId, 1) then--判断有迁城道具使用
				-- 	local DlgAlert = require("app.common.dialog.DlgAlert")
				--     local pDlg = getDlgByType(e_dlg_index.alert)
				--     if(not pDlg) then
				--         pDlg = DlgAlert.new(e_dlg_index.alert)
				--     end
				--     pDlg:setTitle(getConvertedStr(3, 10091))
				--     local tColorStr = {
				--     	{color=_cc.pwhite,	text=getConvertedStr(3, 10389)},
				-- 		{color=_cc.blue,	text=sName},
				-- 		{color=_cc.pwhite,	text=getConvertedStr(3, 10436)},
				-- 	}
				--     pDlg:setContent(tColorStr)
				--     pDlg:setRightHandler(function (  )
				-- 		SocketManager:sendMsg("reqWorldTargetUsedMoveCity", {tCityData.map, 0})
				-- 		--关闭本框
				--         pDlg:closeDlg(false)
				--         --关闭自己
				--         closeDlgByType(e_dlg_index.worldtargetcapital, false)
				--     end)
				--     pDlg:showDlg(bNew)
				-- else
				-- 	--弹出道具购买
				-- 	local strTips = {
				-- 		{color=_cc.pwhite, text = getConvertedStr(3, 10172)},
				-- 		{color=_cc.blue, text = sName},
				-- 	}
				-- 	--展示购买对话框
				-- 	showBuyDlg(strTips,nCost,function (  )
				-- 		SocketManager:sendMsg("reqWorldTargetUsedMoveCity", {tCityData.map, 1})
				-- 		closeDlgByType(e_dlg_index.worldtargetcapital, false)
				-- 	end)
				-- end
				-- return
			-- end
		-- end
		
		--直接定位
		locationToTarget()
	end
end



return DlgWorldTargetCapital