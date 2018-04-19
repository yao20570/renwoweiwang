----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-05 14:30:12
-- Description: 夺宝转盘
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local SnatchturnLayer = require("app.layer.activityb.snatchturn.SnatchturnLayer")

local e_type_tab = {
	lucky = 1, 
	king = 2,
}
local nAllGoodsCnt = 8
local nResetClock = 0

--1：1次免费幸运转盘 2： 1次付费幸运转盘 3：10次付费幸运转盘 4：1次王者转盘 5.10次王者转盘
local nFreeBuy = 1
local nOneLuckyCost = 2
local nTenLuckyCost = 3
local nOneKingCost = 4
local nTenKingCost = 5

local DlgSnatchturn = class("DlgSnatchturn", function()
	return DlgBase.new(e_dlg_index.snatchturn)
end)

function DlgSnatchturn:ctor(  )
	parseView("dlg_snatchturn", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgSnatchturn:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSnatchturn",handler(self, self.onDlgSnatchturnDestroy))
end

-- 析构方法
function DlgSnatchturn:onDlgSnatchturnDestroy(  )
    self:onPause()
end

function DlgSnatchturn:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function DlgSnatchturn:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function DlgSnatchturn:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgSnatchturn:onPause(  )
	self:unregMsgs()
end

function DlgSnatchturn:setupViews(  )
	self.pLayTime = self:findViewByName("lay_time")

	self.pLayTop = self:findViewByName("lay_top")

	--banner
	self.pLayBannerBg = self:findViewByName("lay_top")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_dbzp)

	self.pTxtDesc = self:findViewByName("txt_desc")

	self.pLayTabHost = self:findViewByName("lay_tab")
	--切换卡层
	self.tTitles = {
		getConvertedStr(3, 10406),
		getConvertedStr(3, 10407),
	}
	self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pTabItems = self.pTComTabHost:getTabItems()
	for i=1,#self.pTabItems do
		self.pTabItems[i].nIndex = i
	end
	self.pLayTabHost:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()

	--获取content
	self.pSnatchturnLayer = SnatchturnLayer.new()
	self.pTComTabHost:setContentLayer(self.pSnatchturnLayer)

	--左边按钮
	local pLayBtnLeft = self:findViewByName("lay_btn_left")
	local pBtnLeft = getCommonButtonOfContainer(pLayBtnLeft, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10261))
	pBtnLeft:onCommonBtnClicked(handler(self, self.onFreeClicked))
	pBtnLeft:onCommonBtnDisabledClicked(handler(self, self.onBtnDisableClicked))
	self.pBtnLeft = pBtnLeft
	--文本
	local tConTable = {}
	local tLabel = {
	 {"1",getC3B(_cc.pwhite)},
	 {"2",getC3B(_cc.pwhite)},
	 {"3",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pBtnLeft:setBtnExText(tConTable) 

	--右边按钮
	local pLayBtnRight = self:findViewByName("lay_btn_right")
	local pBtnRight = getCommonButtonOfContainer(pLayBtnRight, TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10409))
	pBtnRight:onCommonBtnClicked(handler(self, self.onBuyTenClicked))
	pBtnRight:onCommonBtnDisabledClicked(handler(self, self.onBtnDisableClicked))
	self.pBtnRight = pBtnRight
	--文本
	local tConTable = {}
	local tLabel = {
	 {"0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pBtnRight:setBtnExText(tConTable) 

	--默认选中第一项
	self.pTComTabHost:setDefaultIndex(1)
	--是否可以点击王者，前一种状态
	self.bIsCanBuyKindPrev = self:getIsCanBuyKind()
end


--控件刷新
function DlgSnatchturn:updateViews()
	local tData = Player:getActById(e_id_activity.snatchturn)
	if not tData then
		self:closeDlg(false)
		return
	end
	if tData then
		--设置标题
		self:setTitle(tData.sName)

		--活动时间
		if not self.pActTime then
			self.pActTime = createActTime(self.pLayTime, tData, cc.p(0,0))
		else
			self.pActTime:setCurData(tData)
		end

		--描述
		self.pTxtDesc:setString(tData.sDesc)
	end

	--更新转盘
	self:updateSnatchTurn()
	--更新按钮
	self:updateBottomBtns()
end

--下标选择回调事件
--nIndex --1是幸运，2是王者
function DlgSnatchturn:onIndexSelected( nIndex )
	self.nCurrTab = nIndex
	self:updateSnatchTurn()
	self:updateBottomBtns()

	--要全部亮才可以点击
	if self.nCurrTab == e_type_tab.king then
		local bIsCanBuy = self:getIsCanBuyKind()
		if not bIsCanBuy then
			TOAST(getConvertedStr(3, 10440))
		end
	end
end

--更新转盘
function DlgSnatchturn:updateSnatchTurn( )
	if self.bIsStopSnatchturnUpdate then
		return
	end
	local tData = Player:getActById(e_id_activity.snatchturn)
	if tData then
		if tData.tTurnConfVo then
			--设置所有图标不发光
			for i=1,nAllGoodsCnt do
				self.pSnatchturnLayer:setGoodsLight(i, false)
			end
			--设置数据
			if self.nCurrTab == e_type_tab.king then
				for i = 1, #tData.tTurnConfVo.tKingTurnConfVos do
					local tKingTurnConfVo = tData.tTurnConfVo.tKingTurnConfVos[i]
					local bIsGotHead = false
					local bIsGotEquip = false
					if tData.tSnatchTurnInfoVo then
						bIsGotHead = tData.tSnatchTurnInfoVo:isGotHead()
						bIsGotEquip = tData.tSnatchTurnInfoVo:isGotEquip()
					end
					local nGoodsId = tKingTurnConfVo.tReward.k
					local nGoodsCnt = tKingTurnConfVo.tReward.v
					if bIsGotHead and tKingTurnConfVo:isHeadReward() then
						nGoodsId = tKingTurnConfVo.tReplace.k
						nGoodsCnt = tKingTurnConfVo.tReplace.v
					end
					if bIsGotEquip and tKingTurnConfVo:isPieceReward() then
						nGoodsId = tKingTurnConfVo.tReplace.k
						nGoodsCnt = tKingTurnConfVo.tReplace.v
					end
					self.pSnatchturnLayer:setGoodsData(tKingTurnConfVo.nPos, nGoodsId, nGoodsCnt)
				end

				--文本
				local nGetPieceNum = 0
				if tData.tSnatchTurnInfoVo then
					nGetPieceNum = tData.tSnatchTurnInfoVo.nGetPieceNum
				end
				local tStr = {}
				local sFreeTime = ";"..tostring(nGetPieceNum)..":".._cc.green..";"
				local sFreeTimeMax = tData.tTurnConfVo.nPieceNum
				if nGetPieceNum < sFreeTimeMax then
					local sStr = string.format(getConvertedStr(3, 10412), sFreeTime,sFreeTimeMax)
					table.insert(tStr, getTextColorByConfigure(sStr))
				else
					local sStr = getConvertedStr(1,10420)..getConvertedStr(1,10419)
					table.insert(tStr, getTextColorByConfigure(sStr))
				end
				local sResetClock = ";"..tostring(nResetClock) .. getConvertedStr(3, 10416)..":".._cc.blue..";"
				local sStr = string.format(getConvertedStr(3, 10413), sResetClock)
				table.insert(tStr, getTextColorByConfigure(sStr))

				local sStr = string.format(";%s:%s",getConvertedStr(3, 10414), _cc.pwhite)
				table.insert(tStr, getTextColorByConfigure(sStr))

				local sStr = string.format(";%s:%s",getConvertedStr(3, 10415), _cc.pwhite)
				table.insert(tStr, getTextColorByConfigure(sStr))

				self.pSnatchturnLayer:setCenterTxt(tStr)

			else
				for i = 1, #tData.tTurnConfVo.tLuckyTurnConfVos do
					local tLuckyTurnConfVo = tData.tTurnConfVo.tLuckyTurnConfVos[i]
					self.pSnatchturnLayer:setGoodsData(tLuckyTurnConfVo.nPos, tLuckyTurnConfVo.tReward.k, tLuckyTurnConfVo.tReward.v)
				end

				--设置相对应图标发光
				local nFreeUsed = 0
				if tData.tSnatchTurnInfoVo then
					for k,v in pairs(tData.tSnatchTurnInfoVo.tLightPos) do
						self.pSnatchturnLayer:setGoodsLight(k, true)
					end
					nFreeUsed = tData.tSnatchTurnInfoVo.nFreeUsed
				end
				--文本
				local tStr = {}
				local nLeftFree = math.max(tData.tTurnConfVo:getFreeNumMax() - nFreeUsed, 0)
				local sFreeTime = ";"..tostring(nLeftFree)..":".._cc.green..";"
				local sFreeTimeMax = tData.tTurnConfVo:getFreeNumMax()
				local sStr = string.format(getConvertedStr(3, 10411), sFreeTime,sFreeTimeMax)
				table.insert(tStr, getTextColorByConfigure(sStr))
				local sResetClock = ";"..tostring(nResetClock) .. getConvertedStr(3, 10416)..":".._cc.blue..";"
				local sStr = string.format(getConvertedStr(3, 10413), sResetClock)
				table.insert(tStr, getTextColorByConfigure(sStr))

				local sStr = string.format(";%s:%s",getConvertedStr(3, 10414), _cc.pwhite)
				table.insert(tStr, getTextColorByConfigure(sStr))
				
				local sStr = string.format(";%s:%s",getConvertedStr(3, 10415), _cc.pwhite)
				table.insert(tStr, getTextColorByConfigure(sStr))

				self.pSnatchturnLayer:setCenterTxt(tStr)
			end
		end
	end
end

--更新低部按钮
function DlgSnatchturn:updateBottomBtns( )
	--是幸运还是王者，显示次数
	if self.nCurrTab == e_type_tab.king then
		local tData = Player:getActById(e_id_activity.snatchturn)
		if tData then
			if tData.tTurnConfVo then
				local bIsCanBuy = false
				if tData.tSnatchTurnInfoVo then
					if table.nums(tData.tSnatchTurnInfoVo.tLightPos) >= nAllGoodsCnt then
						bIsCanBuy = true
					end
				end

				--左边按钮变成转1次
				self.pBtnLeft:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10408))
				self.pBtnLeft:onCommonBtnClicked(handler(self, self.onBuyOneClicked))
				self.pBtnLeft:setExTextLbCnCr(1, tData.tTurnConfVo.nOneKindCost)
				self.pBtnLeft:setExTextLbCnCr(2, "")
				self.pBtnLeft:setExTextLbCnCr(3, "")
				self.pBtnLeft:setExTextImg(getCostResImg(e_type_resdata.money))
				self.pBtnLeft:setBtnEnable(bIsCanBuy)

				--右边按钮变成转10次
				self.pBtnRight:setExTextLbCnCr(1, tData.tTurnConfVo.nTenKindCost)
				self.pBtnRight:setBtnEnable(bIsCanBuy)
			end
		end
	else
		--幸运
		local tData = Player:getActById(e_id_activity.snatchturn)
		if tData then
			if tData.tTurnConfVo then
				--右边按钮变成转10次
				self.pBtnRight:setExTextLbCnCr(1, tData.tTurnConfVo.nTenLuckyCost)
				self.pBtnRight:setBtnEnable(true)

				if tData.tSnatchTurnInfoVo then
					local nFreeUsed = tData.tSnatchTurnInfoVo.nFreeUsed
					local nFreeNumMax = tData.tTurnConfVo:getFreeNumMax()
					local nFreeNum = math.max(nFreeNumMax - nFreeUsed, 0)
					if nFreeNum > 0 then
						--左边按钮变成免费
						self.pBtnLeft:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10261))
						self.pBtnLeft:onCommonBtnClicked(handler(self, self.onFreeClicked))

						self.pBtnLeft:setExTextLbCnCr(1, getConvertedStr(3, 10439), getC3B(_cc.white))
						self.pBtnLeft:setExTextLbCnCr(2, tostring(nFreeNum), getC3B(_cc.green))
						self.pBtnLeft:setExTextLbCnCr(3, "/"..tostring(nFreeNumMax), getC3B(_cc.white))
						self.pBtnLeft:setExTextImg(nil)
						self.pBtnLeft:setBtnEnable(true)
						return
					end
				end
				--左边按钮变成转1次
				self.pBtnLeft:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10408))
				self.pBtnLeft:onCommonBtnClicked(handler(self, self.onBuyOneClicked))

				self.pBtnLeft:setExTextLbCnCr(1, tData.tTurnConfVo.nOneLuckyCost)
				self.pBtnLeft:setExTextLbCnCr(2, "")
				self.pBtnLeft:setExTextLbCnCr(3, "")
				self.pBtnLeft:setExTextImg(getCostResImg(e_type_resdata.money))
				self.pBtnLeft:setBtnEnable(true)
			end
		end
	end
end

--免费购买
function DlgSnatchturn:onFreeClicked( )
	-- if true then
	-- 	self.pSnatchturnLayer:playCircleAnim(8)
	-- 	return
	-- end

	--发送请求
	self.bIsStopSnatchturnUpdate = true --停止刷新
	SocketManager:sendMsg("reqSnatchturn", {nFreeBuy}, function ( __msg, __oldMsg)
		--以防此类已删除
		if self and self.playCircleAnim then
			self:playCircleAnim(__msg, __oldMsg)
		end
	end)
end

--转圈特效
function DlgSnatchturn:playCircleAnim( __msg, __oldMsg)
	if not __msg then
		--允许刷新
    	self.bIsStopSnatchturnUpdate = false
    	return
	end
	self.tTurnFruitVoList = nil --清空结果数据
	self.tGetEquip = nil --合成的装备
	self.nPrevCtrl = __oldMsg[1] --上一次操作
	if  __msg.head.state == SocketErrorType.success then
    	if __msg.head.type == MsgType.reqSnatchturn.id then
    		--关掉获得显示
    		closeDlgByType(e_dlg_index.showheromansion, false)

    		--结果
    		local tDataTfs = __msg.body.tfs
    		--播放特效
    		if tDataTfs then
    			local tTurnFruitVoList = {}
    			local TurnFruitVo = require("app.layer.activityb.snatchturn.TurnFruitVo")
    			for i=1,#tDataTfs do
    				table.insert(tTurnFruitVoList, TurnFruitVo.new(tDataTfs[i]))
    			end
				--播放转圈
        		if self.pSnatchturnLayer then
        			if #tTurnFruitVoList > 0 then
        				local tTurnFruitVo = tTurnFruitVoList[#tTurnFruitVoList]
        				self.tTurnFruitVoList = tTurnFruitVoList
        				if __msg.body.equ then --Pair<Integer,Long>	获得的装备
        					self.tGetEquip = {__msg.body.equ}
        					for i=#self.tTurnFruitVoList, 1, -1 do
        						if self.tTurnFruitVoList[i] and self.tTurnFruitVoList[i]:isEquipFragment() then
        							self.tTurnFruitVoList[i]:setShowId(__msg.body.equ.k)
        							break
        						end
        					end
        				end
        				-- dump(__msg.body.equ, "__msg.body.equ", 100)
						--播放动画
						self.pSnatchturnLayer:playCircleAnim(tTurnFruitVo.nIndex, handler(self, self.playCircleAnimOver), handler(self, self.stopSnatchAndShowRes))
					end
				end
			end
    	end
    else
    	--允许刷新
    	self.bIsStopSnatchturnUpdate = false
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--转圈特效结束
function DlgSnatchturn:playCircleAnimOver( )
	--允许刷新
    self.bIsStopSnatchturnUpdate = false
    --刷新最新数据展示
    self:updateSnatchTurn()
    --播放获取
    self:showGetHero(self.tTurnFruitVoList)
end

--展示获得英雄
function DlgSnatchturn:showGetHero(_data)

	if not _data then
		return
	end

	if type(_data) ~= "table" then
		return
	end

	local tDataList = {}
	for k,v in pairs(_data) do
		local tReward = {}
		tReward.d = {}
		tReward.g = {}
		table.insert(tReward.d, copyTab(v.tOb))
		table.insert(tReward.g, copyTab(v.tOb))
		if v and v.getShowId and v:getShowId() then
			local id = v:getShowId()
			tReward.showId = id
			tReward.activityId = e_id_activity.snatchturn
			local tItemData = getBaseItemDataByID(v.tOb.k)
			if tItemData then
				local sParam = tItemData.sParam
				local tParam = luaSplitMuilt(sParam, ",",":")
				local nNum = tParam[1]
				local sColor = getColorByQuality(tItemData.nQuality)
				local sFragmentName = tItemData.sName
				local nEquipId = tParam[2][1]
				local tEquipData = getBaseEquipDataByID(nEquipId)
				local sEquipName = tEquipData.sName
				tReward.str = string.format(getConvertedStr(1, 10421), nNum, sColor, sFragmentName, sColor, sEquipName)
			end
		end
		table.insert(tDataList,tReward)
	end

	--左边按钮数据
	local tLBtnData = {}
	--int	1：1次免费幸运转盘 2： 1次付费幸运转盘 3：10次付费幸运转盘 4：1次王者转盘 5.10次王者转盘
	--是幸运还是王者，显示次数
	if self.nPrevCtrl == nOneKingCost or self.nPrevCtrl == nTenKingCost then
		local tData = Player:getActById(e_id_activity.snatchturn)
		if tData then
			if tData.tTurnConfVo then
				local bIsCanBuy = false
				if tData.tSnatchTurnInfoVo then
					if table.nums(tData.tSnatchTurnInfoVo.tLightPos) >= nAllGoodsCnt then
						bIsCanBuy = true
					end
				end
				--设置按钮数据
				tLBtnData.nBtnType = TypeCommonBtn.L_YELLOW
				if self.nPrevCtrl == nTenKingCost then
					tLBtnData.sBtnStr = getConvertedStr(3, 10419)
					tLBtnData.nPrice = tData.tTurnConfVo.nTenKindCost
					tLBtnData.nClickedFunc = handler(self, self.onBuyTenClicked)
				else
					tLBtnData.sBtnStr = getConvertedStr(3, 10418)
					tLBtnData.nPrice = tData.tTurnConfVo.nOneKindCost
					tLBtnData.nClickedFunc = handler(self, self.onBuyOneClicked)
				end
				tLBtnData.bIsEnable = bIsCanBuy
			end
		end
	else
		--幸运
		local tData = Player:getActById(e_id_activity.snatchturn)
		if tData then
			if tData.tTurnConfVo then
				local bIsFree = false 
				local nFreeNumMax = 0
				local nFreeNum = 0
				if tData.tSnatchTurnInfoVo then

					nFreeNum = tData.tTurnConfVo:getFreeNumMax() - tData.tSnatchTurnInfoVo.nFreeUsed
					nFreeNumMax=tData.tTurnConfVo:getFreeNumMax()
					if nFreeNum > 0 then
						bIsFree = true
					end
				end
				--设置按钮数据
				if self.nPrevCtrl == nFreeBuy and bIsFree then
					tLBtnData.nBtnType = TypeCommonBtn.L_BLUE
					tLBtnData.sBtnStr = getConvertedStr(3, 10261)
					tLBtnData.nPrice = 0
					tLBtnData.nClickedFunc = handler(self, self.onFreeClicked)
					tLBtnData.bIsEnable = true

					local tConTable={}
					local tLabel = {
						 {getConvertedStr(3, 10439), getC3B(_cc.white)},
						 {tostring(nFreeNum), getC3B(_cc.green)},
						 {"/"..tostring(nFreeNumMax), getC3B(_cc.white)},
						}

					tConTable.tLabel=tLabel
					tLBtnData.tConTable=tConTable
				else
					tLBtnData.nBtnType = TypeCommonBtn.L_YELLOW
					if self.nPrevCtrl == nTenLuckyCost then
						tLBtnData.sBtnStr = getConvertedStr(3, 10419)
						tLBtnData.nPrice = tData.tTurnConfVo.nTenLuckyCost
						tLBtnData.nClickedFunc = handler(self, self.onBuyTenClicked)
					else
						tLBtnData.sBtnStr = getConvertedStr(3, 10418)
						tLBtnData.nPrice = tData.tTurnConfVo.nOneLuckyCost
						tLBtnData.nClickedFunc = handler(self, self.onBuyOneClicked)
					end
					tLBtnData.bIsEnable = true
				end
			end
		end
	end

	--打开招募展示英雄对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    tObject.tLBtnData = tLBtnData
    tObject.tEndPopGoods = self.tGetEquip
    if tObject.tEndPopGoods then
    	tObject.bTipsDialog = true
    end
    tObject.nRHandler = function( )
    	--第一次达到8圈，（开启王者 从不能打开 到 可以打开)
		if not self.bIsCanBuyKindPrev then
			local bIsCanBuyKind = self:getIsCanBuyKind()
			if bIsCanBuyKind then
				self.bIsCanBuyKindPrev = bIsCanBuyKind 
				--提示框
				local DlgAlert = require("app.common.dialog.DlgAlert")
			    local pDlg = getDlgByType(e_dlg_index.alert)
			    if(not pDlg) then
			        pDlg = DlgAlert.new(e_dlg_index.alert)
			    end
			    pDlg:setTitle(getConvertedStr(3, 10091))
			    pDlg:setContent(getConvertedStr(3, 10542))
			    pDlg:setOnlyConfirm()
			    pDlg:showDlg(bNew)
			end
		end
   	end
    sendMsg(ghd_show_dlg_by_type,tObject)
end

--获取是否可以点击王者
function DlgSnatchturn:getIsCanBuyKind( )
	local tData = Player:getActById(e_id_activity.snatchturn)
	if tData then
		if tData.tSnatchTurnInfoVo then
			if table.nums(tData.tSnatchTurnInfoVo.tLightPos) >= nAllGoodsCnt then
				return true
			end
		end
	end
	return false
end

--转1次
function DlgSnatchturn:onBuyOneClicked( )
	--购买
	local nCost = 0
	local tData = Player:getActById(e_id_activity.snatchturn)
	if tData then
		if tData.tTurnConfVo then
			if self.nCurrTab == e_type_tab.king then
				nCost = tData.tTurnConfVo.nOneKindCost
			else
				nCost = tData.tTurnConfVo.nOneLuckyCost
			end
		end
	end
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10410)},
	    {color=_cc.blue,text=tostring(1)..getConvertedStr(3, 10324)},
	}
	--展示购买对话框
	showBuyDlg(strTips,nCost,function (  )
	    if self.nCurrTab == e_type_tab.king then
	    	local nHandler = function()
			    	self.bIsStopSnatchturnUpdate = true --停止刷新
			    	SocketManager:sendMsg("reqSnatchturn", {nOneKingCost}, function ( __msg, __oldMsg)
							--以防此类已删除
						if self and self.playCircleAnim then
							self:playCircleAnim(__msg, __oldMsg)
						end
				end)
			end
			local pDlg = getDlgByType(e_dlg_index.showheromansion)
  			if pDlg and pDlg.bTipsDialog and pDlg.pData then
				pDlg.bTipsDialog = false
				local id = nil
				for i=1, #pDlg.pData do
					if pDlg.pData[i].activityId == e_id_activity.snatchturn then
						id =pDlg.pData[i].showId
						local pRecommendData = {}
						pRecommendData.tCallback = function()
							nHandler()
						end
						local pInfoDlg = showItemInfoDlg(tonumber(id), 2, pRecommendData)
						if pInfoDlg and pInfoDlg.setTips and pDlg.pData[i].str then
							pInfoDlg:setTips(pDlg.pData[i].str)
						end
						closeDlgByType(e_dlg_index.showheromansion, false)
						break
					end
				end
  			else
  				nHandler()
  			end
		else
			self.bIsStopSnatchturnUpdate = true --停止刷新
			SocketManager:sendMsg("reqSnatchturn", {nOneLuckyCost}, function ( __msg, __oldMsg)
				--以防此类已删除
				if self and self.playCircleAnim then
					self:playCircleAnim(__msg, __oldMsg)
				end
			end)
		end
	end)
end

--转10次
function DlgSnatchturn:onBuyTenClicked( )
	--购买
	local nCost = 0
	local tData = Player:getActById(e_id_activity.snatchturn)
	if tData then
		if tData.tTurnConfVo then
			if self.nCurrTab == e_type_tab.king then
				nCost = tData.tTurnConfVo.nTenKindCost
			else
				nCost = tData.tTurnConfVo.nTenLuckyCost
			end
		end
	end
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10410)},
	    {color=_cc.blue,text=tostring(10)..getConvertedStr(3, 10324)},
	}
	--展示购买对话框
	showBuyDlg(strTips,nCost,function (  )
	    if self.nCurrTab == e_type_tab.king then
	    	local nHandler = function()
			    self.bIsStopSnatchturnUpdate = true --停止刷新
			    	SocketManager:sendMsg("reqSnatchturn", {nTenKingCost}, function ( __msg, __oldMsg)
							--以防此类已删除
						if self and self.playCircleAnim then
							self:playCircleAnim(__msg, __oldMsg)
						end
				end)
			end
			--判断是否有合成没有展示
			local pDlg = getDlgByType(e_dlg_index.showheromansion)
  			if pDlg and pDlg.bTipsDialog and pDlg.pData then
				pDlg.bTipsDialog = false
				local id = nil
				for i=1, #pDlg.pData do
					if pDlg.pData[i].activityId == e_id_activity.snatchturn then
						id =pDlg.pData[i].showId
						local pRecommendData = {}
						pRecommendData.tCallback = function()
							nHandler()
						end
						local pInfoDlg = showItemInfoDlg(tonumber(id), 2, pRecommendData)
						if pInfoDlg and pInfoDlg.setTips and pDlg.pData[i].str then
							pInfoDlg:setTips(pDlg.pData[i].str)
						end
						closeDlgByType(e_dlg_index.showheromansion, false)
						break
					end
				end
  			else
  				nHandler()
  			end
		else
			self.bIsStopSnatchturnUpdate = true --停止刷新
			SocketManager:sendMsg("reqSnatchturn", {nTenLuckyCost}, function ( __msg, __oldMsg)
				--以防此类已删除
				if self and self.playCircleAnim then
					self:playCircleAnim(__msg, __oldMsg)
				end
			end)
		end
	end)
end

--停止动画显示结果
function DlgSnatchturn:stopSnatchAndShowRes( )
	if self.pSnatchturnLayer then
		self.pSnatchturnLayer:stopAndShowResult( )
	end
end

--
function DlgSnatchturn:onBtnDisableClicked( )
	--要全部亮才可以点击
	if self.nCurrTab == e_type_tab.king then
		local bIsCanBuy = self:getIsCanBuyKind()
		if not bIsCanBuy then
			TOAST(getConvertedStr(3, 10440))
			return
		end
	end
end

return DlgSnatchturn