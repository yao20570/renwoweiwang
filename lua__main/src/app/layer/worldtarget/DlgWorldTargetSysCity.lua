----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-10 15:07:17
-- Description: 世界目标打群系统城池
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local nRandemMoveCityId = 100027 --随机移城id
local DlgWorldTargetSysCity = class("DlgWorldTargetSysCity", function()
	return DlgCommon.new(e_dlg_index.worldtargetcity,750-130 , 130)  		--680+130-130-60
end)

function DlgWorldTargetSysCity:ctor(  )
	parseView("dlg_world_target_syscity", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldTargetSysCity:onParseViewCallback( pView )
	self:addContentView(pView, false) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldTargetSysCity",handler(self, self.onDlgWorldTargetSysCityDestroy))
end

-- 析构方法
function DlgWorldTargetSysCity:onDlgWorldTargetSysCityDestroy(  )
    self:onPause()
end

function DlgWorldTargetSysCity:regMsgs(  )
	regMsg(self, gud_world_target_top_refresh, handler(self, self.udpateBottomBtn))
end

function DlgWorldTargetSysCity:unregMsgs(  )
	unregMsg(self, gud_world_target_top_refresh)
end

function DlgWorldTargetSysCity:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgWorldTargetSysCity:onPause(  )
	self:unregMsgs()
end

function DlgWorldTargetSysCity:setupViews(  )
	print("worldtarget")
	local pLayView = self:findViewByName("view")
	local pLayBorder = self:findViewByName("lay_border")
	local pTxtBanner = self:findViewByName("txt_banner")
	pTxtBanner:setString(getConvertedStr(3, 10385))
	self.pLayGoods = self:findViewByName("lay_goods")
	self.pTxtTip = self:findViewByName("txt_tip")
	-- self.pTxtTip:setString(getTipsByIndex(10039))

	self.pTxtTip2 = self:findViewByName("txt_tip2")

	local pLayBtn = self:findViewByName("lay_btn")
	self.pLayBtn = pLayBtn
	self.pBottomBtn = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10162))
	self.pBottomBtn:onCommonBtnClicked(handler(self, self.onBottomClicked))

	-- --布局中默认的按钮隐藏
	-- local pBtn = self:getOnlyConfirmButton()
	-- pBtn:setVisible(false)
	-- if self.pLayContent then
	-- 	self.pLayContent:setZOrder(10)
	-- end
	--背景
	local pImgBg = MUI.MImage.new("ui/bg_world/v1_bg_vtku.jpg")
	pLayView:addView(pImgBg)
	local nX, nY = pLayBorder:getPosition()
	pImgBg:setPosition(nX + pImgBg:getContentSize().width/2, nY + pImgBg:getContentSize().height/2)
end

function DlgWorldTargetSysCity:updateViews(  )
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end
	self.nTargetId = tWorldTargetData.id 

	--介绍
	self.pTxtTip:setString(tWorldTargetData.info)

	--标题
	self:setTitle(tWorldTargetData.desc)

	--奖励物品
	if tWorldTargetData.award then
		local tGoodsList = getDropById(tWorldTargetData.award)
		gRefreshHorizontalList(self.pLayGoods, tGoodsList,17/2)
	end
	--更新底部按钮
	self:udpateBottomBtn()
end

--更新底部按钮
function DlgWorldTargetSysCity:udpateBottomBtn( )
	--前往或领奖按钮
	local nNoTipY = 30
	local nHasTipY = 48
	self.bIsGet = Player:getWorldData():getIsCanGetWTSysCityReward()
	if self.bIsGet then
		self.pBottomBtn:updateBtnText(getConvertedStr(3, 10386)) 
		self.pBottomBtn:updateBtnType(TypeCommonBtn.L_YELLOW)
		self.pLayBtn:setPositionY(nNoTipY)
		self.pTxtTip2:setVisible(false)
	else
		--self.pBottomBtn:updateBtnText(getConvertedStr(3, 10162)) 
		self.pBottomBtn:updateBtnType(TypeCommonBtn.L_BLUE) 
		--底部描述（小朋友策划说写死）
		if self.nTargetId == 6 or self.nTargetId == 7 or self.nTargetId == 8 then
			--自己的城池当前是否在州
			local bIsShowFree = false
			local nMyBlockId = Player:getWorldData():getMyCityBlockId()
			local tBlockData = getWorldMapDataById(nMyBlockId)
			if tBlockData and tBlockData.type ~= e_type_block.zhou then
				--是否可以免费迁城
				local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
				local tWorldTargetData = getWorldTargetData(nMyTargetId)
				if tWorldTargetData and tWorldTargetData.migratetype and tWorldTargetData.migratetype > 0 then
					--dump(Player:getWorldData():getUsedMoveCity())
					if Player:getWorldData():getIsUsedMoveCity(nMyTargetId) then
						bIsShowFree = false
					else
						bIsShowFree = true
					end
				end
			end
			if bIsShowFree then
				self.pTxtTip2:setString(getTipsByIndex(10040))
				self.pTxtTip2:setVisible(true)
				self.pTxtTip2:setPositionY(nHasTipY+8)

				self.pBottomBtn:updateBtnText(getConvertedStr(6, 10640))
				self.pLayBtn:setPositionY(nHasTipY)
			else
				self.pTxtTip2:setVisible(false)
				self.pBottomBtn:updateBtnText(getConvertedStr(3, 10162)) 
				self.pLayBtn:setPositionY(nNoTipY)
			end
		else
			self.pBottomBtn:updateBtnText(getConvertedStr(3, 10162)) 
			self.pLayBtn:setPositionY(nNoTipY)
			self.pTxtTip2:setVisible(false)
		end
	end
end

function DlgWorldTargetSysCity:onBottomClicked( pView )
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
		closeDlgByType(e_dlg_index.worldtargetcity, false)
	else
		local tCityData = getRandomSysCityByKind(tWorldTargetData.nTargetValue)
		if not tCityData then
			TOAST("随机系统城市出错")
			return
		end

		--直接定位
		local function locationToTarget(  )
    		sendMsg(ghd_world_dot_near_my_city,{nDotType = e_type_builddot.sysCity, nSysCityId = tCityData.id})
    		closeDlgByType(e_dlg_index.worldtargetcity, false)
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

		--2,判断是否已经使用迁城道具
		if tWorldTargetData.migratetype and tWorldTargetData.migratetype > 0 then
			--是否有使用过迁城道具(第一次免费)
			local bIsUsedMoveCity = Player:getWorldData():getIsUsedMoveCity(nMyTargetId)
			if not bIsUsedMoveCity then
				--不够45级就
				if tTargetBlockData then
					if tTargetBlockData.type == e_type_block.zhou then
						local nNeedLv = getWorldInitData("stateMinLimit")
						if Player:getPlayerInfo().nLv < nNeedLv then
							TOAST(string.format(getTipsByIndex(20088), nNeedLv))
							return
						end
					elseif tTargetBlockData.type == e_type_block.kind then
						local nNeedLv = getWorldInitData("centerMinLimit")
						if Player:getPlayerInfo().nLv < nNeedLv then
							TOAST(string.format(getTipsByIndex(20088), nNeedLv))
							return
						end
					end
				end

				SocketManager:sendMsg("reqWorldTargetUsedMoveCity", {0})
				closeDlgByType(e_dlg_index.worldtargetcity, false)
				--如果从聊天界面跳过去的要关掉聊天界面
				closeDlgByType(e_dlg_index.dlgchat)
				return
			
				-- --消耗迁城道具
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
				-- 		{color=_cc.pwhite,	text=getConvertedStr(3, 10390)},
				-- 	}
				--     pDlg:setContent(tColorStr)
				--     pDlg:setRightHandler(function (  )
				-- 		SocketManager:sendMsg("reqWorldTargetUsedMoveCity", {tCityData.map, 0})
				-- 		--关闭本框
				--         pDlg:closeDlg(false)
				--         --关闭自己
				--         closeDlgByType(e_dlg_index.worldtargetcity, false)
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
				-- 		closeDlgByType(e_dlg_index.worldtargetcity, false)
				-- 	end)
				-- end
				-- return
			end
		end
		
		--直接定位
		locationToTarget()
	end
end



return DlgWorldTargetSysCity