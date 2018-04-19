----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-12-07 16:54:54
-- Description: 寻龙夺宝
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")

local nAllGoodsCnt = 12

--1：抽1次 10： 抽10次
local nOneTime = 1
local nTenTimes = 10

--12个物品层的位置
local tPos = 
{
	[1]  = 	{x = 260, y = 551},
	[2]  = 	{x = 335, y = 474},
	[3]  = 	{x = 412, y = 397},
	[4]  = 	{x = 492, y = 317},
	[5]  = 	{x = 412, y = 237},
	[6]  = 	{x = 336, y = 159},
	[7]  = 	{x = 260, y = 83},
	[8]  = 	{x = 183, y = 159},
	[9]  = 	{x = 106, y = 237},
	[10] =  {x = 26,  y = 317},
	[11] =  {x = 106, y = 397},
	[12] =  {x = 183, y = 474}
}


local DlgDragonTreasure = class("DlgDragonTreasure", function()
	return DlgBase.new(e_dlg_index.dragontreasure)
end)

function DlgDragonTreasure:ctor( )
	parseView("dlg_dragontreasure", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgDragonTreasure:onParseViewCallback( pView )
	self.pView = pView
	self.pParitcles = {}
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgDragonTreasure",handler(self, self.onDlgDragonTreasureDestroy))
end

-- 析构方法
function DlgDragonTreasure:onDlgDragonTreasureDestroy(  )
    self:onPause()
end

function DlgDragonTreasure:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function DlgDragonTreasure:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function DlgDragonTreasure:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgDragonTreasure:onPause(  )
	self:unregMsgs()
end

function DlgDragonTreasure:setupViews()
	self.pLayTime = self:findViewByName("lay_time")

	self.pLayTop = self:findViewByName("lay_top")

	--banner
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	local pMBanner = setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_xldb)
	pMBanner:setMBannerOpacity(255*0.4)

	--img,顶部字体图片
	self.pImgTopFont = self:findViewByName("img_xunlongzi")

	
	self.tLayTopItems = {}  --顶部3个物品层
	self.tLbTopItems = {} 	--顶部3个物品下面的文字描述
	for i = 1, 3 do
		local pLay = self:findViewByName("lay_item_"..i)
		table.insert(self.tLayTopItems, pLay)
		local pLb = self:findViewByName("lb_item_"..i)
		table.insert(self.tLbTopItems, pLb)
	end

	--中间层
	self.pLayCenter = self:findViewByName("lay_center")

	self.tCenterGoodsLays = {} --中间转盘的12个层
	self.tCenterGoodsImgs = {} --中间转盘的12个物品icon图片
	self.tCenterGoodsNums = {} --中间转盘的12个物品数量
	self.tCenterGoodsTips = {} --特殊物品提示

	--中间12个物品图标层
	for i = 1, nAllGoodsCnt do
		local pLay = MUI.MLayer.new()
		pLay:setLayoutSize(87, 87)
		pLay:setRotation(45)
		pLay:setPosition(tPos[i].x + 19, tPos[i].y - 87/2)
		self.pLayCenter:addView(pLay, 1)
		self.tCenterGoodsLays[i] = pLay
		self.tCenterGoodsLays[i]:setViewTouched(true)
		self.tCenterGoodsLays[i]:setIsPressedNeedScale(false)
		self.tCenterGoodsLays[i]:onMViewClicked(handler(self, self.onIconClicked))

		local pLayClipp = cc.ClippingNode:create() 
		local nX, nY, nW, nH = 0,0, 87, 87
		local tPoint = {
			{nX, nY}, 
			{nX + nW, nY}, 
			{nX + nW, nY + nH}, 
			{nX, nY + nH},
		}
		local tColor = {
			fillColor = cc.c4f(255, 0, 0, 255),
		    borderWidth  = 1,
		    borderColor  = cc.c4f(255, 0, 0, 255)
		} 
		stencil =  display.newPolygon(tPoint,tColor)
		pLayClipp:setStencil(stencil)
		pLay:addView(pLayClipp)

		local pImg = MUI.MImage.new("ui/daitu.png")
		pLayClipp:addChild(pImg)
		pImg:setScale(0.8)
		pImg:setRotation(-45)
		pImg:setPosition(42, 45)
		self.tCenterGoodsImgs[i] = pImg

		local pLb = MUI.MLabel.new({text = "", size = 20})
		pLayClipp:addChild(pLb)
		pLb:setRotation(-45)
		pLb:setPosition(71, 16)
		self.tCenterGoodsNums[i] = pLb

		local pLb2 = MUI.MLabel.new({text = "", size = 12})
		pLb2:setAnchorPoint(cc.p(0.5,0.5))
		pLayClipp:addChild(pLb2)
		pLb2:setRotation(-45)
		pLb2:setPosition(27, 67)
		self.tCenterGoodsTips[i] = pLb2
		self.tCenterGoodsTips[i]:setVisible(false)

	end

	--img
	self.pImgTouR = self:findViewByName("img_xou_r")
	self.pImgTouR:setFlippedX(true)
	
	--说明
	self.pLayShuoming = self:findViewByName("lay_shuoming")
	self.pLayShuoming:setViewTouched(true)
	self.pLayShuoming:setIsPressedNeedScale(false)
	self.pLayShuoming:onMViewClicked(handler(self, self.onShuomingClicked))

	--累计抽取次数
	self.pLbGetTimes = self:findViewByName("lb_getcnt")
	--右上角消耗物品小图标
	self.pImgCostIcon = self:findViewByName("img_icon")
	self.pImgCostIcon:setScale(0.5)
	--右上角加号
	self.pImgAdd = self:findViewByName("img_add")
	self.pImgAdd:setViewTouched(true)
	self.pImgAdd:setIsPressedNeedScale(false)
	self.pImgAdd:onMViewClicked(handler(self, self.onAddClicked))

	self.pLayCost = self:findViewByName("lay_cost")
	self.pLayCost:setViewTouched(true)
	self.pLayCost:setIsPressedNeedScale(false)
	self.pLayCost:onMViewClicked(handler(self, self.onAddClicked))
	--已拥有道具数量
	self.pLbCostCnt = self:findViewByName("lb_cost_cnt")

	--中间物品图片
	self.pLyCenterGood = self:findViewByName("lay_center_good")
	self.pLyCenterTx = self:findViewByName("lay_center_tx")
	self.pImgCenterGood = self:findViewByName("img_center_good")
	self.pImgCenterGood_1 = self:findViewByName("img_center_good_up")
	self.pImgCenterGood_shadow = self:findViewByName("img_center_good_shadow")
	self.pImgCenterGood_shadow:setOpacity(0)
	self.pImgCenterGood:setScale(1.3)
	self.pImgCenterGood_1:setScale(1.3)

	self.pImgCenterGood:setViewTouched(true)
	self.pImgCenterGood:setIsPressedNeedScale(false)
	self.pImgCenterGood:onMViewClicked(handler(self, self.onIconClicked))

	self.pLbCenterGoodTips =  MUI.MLabel.new({text = "", size = 20})
	self.pLyCenterTx:addView(self.pLbCenterGoodTips,1000)
	self.pLbCenterGoodTips:setPosition(12, 54)

	self:showImgAction()

	--中间物品数量
	self.pLbCenterGoodNum = self:findViewByName("lb_good_cnt")
	--今日再抽几次可得
	self.pLbTakeMore = self:findViewByName("lb_take")


	--左边按钮
	local pLayBtnLeft = self:findViewByName("lay_btn_left")
	local pBtnLeft = getCommonButtonOfContainer(pLayBtnLeft, TypeCommonBtn.L_BLUE, getConvertedStr(7, 10262))
	pBtnLeft:onCommonBtnClicked(handler(self, self.onBuyOneClicked))
	self.pBtnLeft = pBtnLeft
	--文本
	local tConTable = {}
	local tLabel = {
		{"x"..nOneTime, getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.fontSize = 20
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pLeftExText = self.pBtnLeft:setBtnExText(tConTable)

	--右边按钮
	local pLayBtnRight = self:findViewByName("lay_btn_right")
	local pBtnRight = getCommonButtonOfContainer(pLayBtnRight, TypeCommonBtn.L_YELLOW, getConvertedStr(7, 10263))
	pBtnRight:onCommonBtnClicked(handler(self, self.onBuyTenClicked))
	self.pBtnRight = pBtnRight
	--文本
	local tConTable = {}
	local tLabel = {
		{"x"..nTenTimes, getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.fontSize = 20
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pRightExText = self.pBtnRight:setBtnExText(tConTable)

	--发亮的边框
	self.pImgBorder =  MUI.MImage.new("#v1_img_truqrjfi.png")
	self.pLayCenter:addView(self.pImgBorder, 10)
	self.pImgBorder:setRotation(45)
	self.pImgBorder:setScale(0.85)
	self.pImgBorder:setVisible(false)
	self.pImgBorder:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

end

function DlgDragonTreasure:onIconClicked(_view)
	local good = getGoodsByTidFromDB(_view.nId)
	openIconInfoDlg(_view, good)
end

--显示活动说明
function DlgDragonTreasure:onShuomingClicked()
	-- body
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContentLetter(self.tData.sDesc)
    pDlg:setOnlyConfirm()
    pDlg:setRightHandler(function ()            
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew)
end

--购买消耗道具
function DlgDragonTreasure:onAddClicked()
    local tObject = {}
	tObject.nType = e_dlg_index.buystuff --dlg类型
	tObject.nItemId = self.tData.nCostItemId
	tObject.tCost = self.tData.tCost[1]
	sendMsg(ghd_show_dlg_by_type, tObject)
end


--控件刷新
function DlgDragonTreasure:updateViews()
	local tData = Player:getActById(e_id_activity.dragontreasure)
	self.tData = tData
	if not tData then
		self:closeDlg(false)
		return
	end
	--设置标题
	self:setTitle(tData.sName)

	--活动时间
	if not self.pActTime then
		self.pActTime = createActTime(self.pLayTime, tData, cc.p(0,0))
	else
		self.pActTime:setCurData(tData)
	end

	--不同的UI版本顶部艺术字图片不同
	if tData.nUiVer == 0 then --寻龙夺宝
		self.pImgTopFont:setCurrentImage("#v2_fonts_xunlongzi.png")
	else --圣诞狂欢
		self.pImgTopFont:setCurrentImage("#v2_fonts_shengdan02.png")
	end

	--转盘物品
	if tData.tTurnConfVo then
		local tConfVos = tData.tTurnConfVo.tTurnConfVos
		if tConfVos and #tConfVos > 0 then
			--设置数据
			for i = 1, #tConfVos do
				local tConfVo = tConfVos[i]
				local nGoodsId = tConfVo.tReward.k
				local nGoodsCnt = tConfVo.tReward.v

				local good = getGoodsByTidFromDB(nGoodsId)
				if good then
					self.tCenterGoodsImgs[i]:setCurrentImage(good.sIcon)
					self.tCenterGoodsLays[i].nId = nGoodsId
					self.tCenterGoodsNums[i]:setString("x"..nGoodsCnt)
					if good.sSideIcon then
						self.tCenterGoodsTips[i]:setString(good.sSideIcon)
						self.tCenterGoodsTips[i]:setVisible(true)
					else
						self.tCenterGoodsTips[i]:setVisible(false)
					end
				end
				
			end

		end
	end

	--更新数据
	self:updateDragonTurn()

end

--更新数据
function DlgDragonTreasure:updateDragonTurn( )

	if self.bIsStopSnatchturnUpdate then
		return
	end

	local tData = Player:getActById(e_id_activity.dragontreasure)
	if tData == nil then return end

	--已拥有道具数量
	self.nHasCostItemCnt = tData.nCostItemCnt

	if self.nHasCostItemCnt < nOneTime then
		self.pLeftExText:setLabelCnCr(1, nil, getC3B(_cc.red))
	else
		self.pLeftExText:setLabelCnCr(1, nil, getC3B(_cc.white))
	end
	if self.nHasCostItemCnt < nTenTimes then
		self.pRightExText:setLabelCnCr(1, nil, getC3B(_cc.red))
	else
		self.pRightExText:setLabelCnCr(1, nil, getC3B(_cc.white))
	end

	gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
		if(_index == 1) then
			--累计抽取次数
			self.nGetTimes = tData.nGetTimes
			self.pLbGetTimes:setString(string.format(getConvertedStr(7, 10264), self.nGetTimes))

			--已拥有道具数量
			self.pLbCostCnt:setString(self.nHasCostItemCnt)

			local tCostItem = getBaseItemDataByID(tData.nCostItemId)
			if tCostItem then
				local sIcon = tCostItem.sIcon
				self.pImgCostIcon:setCurrentImage(sIcon)
				self.pBtnLeft:setExTextImg(sIcon)
				self.pBtnRight:setExTextImg(sIcon)
			end

			self.tCostItem = tCostItem

			--顶部3个物品
			if tData.tTinfo and tData.tTinfo.tTurnConfVos and #tData.tTinfo.tTurnConfVos > 0 then
				--目标获得的物品
				local tTurnConfVos = tData.tTinfo.tTurnConfVos
				if not self.tTopItems then
					self.tTopItems = {}
					self.tTopItemsGetTimes = {}

					for i = 2, #tTurnConfVos do
						local tInfo = tTurnConfVos[i]
						table.insert(self.tTopItemsGetTimes, tInfo.nPos)
						local tItem = tInfo.tReward
						local itemdata = getGoodsByTidFromDB(tItem.k)
						itemdata.nCt = tItem.v or 1
						local pIcon = getIconGoodsByType(self.tLayTopItems[i-1],TypeIconGoods.NORMAL,type_icongoods_show.item, itemdata, TypeIconGoodsSize.M)
						pIcon:setNumber(itemdata.nCt, "x")
						table.insert(self.tTopItems, pIcon)
						local str = {
							{text = getConvertedStr(7, 10267), color = _cc.white}, --抽取
							{text = tInfo.nPos, color = _cc.yellow},
							{text = getConvertedStr(7, 10268), color = _cc.white}, --次可获
						}
						self.tLbTopItems[i-1]:setString(str)
					end
				end
				for k, v in pairs(self.tTopItems) do
					if self.nGetTimes >= self.tTopItemsGetTimes[k] then
						v:setIconToGray(true)
						self.tLbTopItems[k]:setString(getConvertedStr(7, 10087)) --已领取
					else
						v:setIconToGray(false)
					end
				end

				--中间物品
				local bFindShow = false
				local nNeedTimes = 0
				for k, v in pairs(tTurnConfVos) do
					if v.nPos > self.nGetTimes then
						local itemdata = getGoodsByTidFromDB(v.tReward.k)
						if itemdata then
							self.pImgCenterGood.nId = v.tReward.k
							self.pImgCenterGood:setCurrentImage(itemdata.sIcon)
							self.pImgCenterGood_1:setCurrentImage(itemdata.sIcon)
							self.pImgCenterGood_1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

							self.pImgCenterGood_shadow:setCurrentImage(itemdata.sIcon)
							self.pImgCenterGood_shadow:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
							self.pLbCenterGoodNum:setString(string.format(getConvertedStr(7, 10269), v.tReward.v))

							if itemdata.sSideIcon then
								self.pLbCenterGoodTips:setString(itemdata.sSideIcon)
								self.pLbCenterGoodTips:setVisible(true)
							else
								self.pLbCenterGoodTips:setVisible(false)
							end
						end
						bFindShow = true
						nNeedTimes = v.nPos
						break
					end
				end
				if bFindShow == false then
					local item = tTurnConfVos[#tTurnConfVos]
					local itemdata = getGoodsByTidFromDB(item.tReward.k)
					if itemdata then
						self.pImgCenterGood.nId = item.tReward.k
						self.pImgCenterGood:setCurrentImage(itemdata.sIcon)
						self.pImgCenterGood_1:setCurrentImage(itemdata.sIcon)
						self.pImgCenterGood_1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

						self.pImgCenterGood_shadow:setCurrentImage(itemdata.sIcon)
						self.pImgCenterGood_shadow:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
						self.pLbCenterGoodNum:setString(string.format(getConvertedStr(7, 10269), item.tReward.v))

						if itemdata.sSideIcon then
							self.pLbCenterGoodTips:setString(itemdata.sSideIcon)
							self.pLbCenterGoodTips:setVisible(true)
						else
							self.pLbCenterGoodTips:setVisible(false)
						end
					end
				end

				--再抽几次可获
				local nTakeMore = nNeedTimes - self.nGetTimes
				local str = ""
				if nTakeMore > 0 then
					str = {
						{text = getConvertedStr(7, 10270), color = _cc.pwhite},  --今日再抽
						{text = nNeedTimes - self.nGetTimes, color = _cc.green},
						{text = getConvertedStr(7, 10271), color = _cc.pwhite},  --次可得
					}
				else
					str = getConvertedStr(7, 10087)
				end

				self.pLbTakeMore:setString(str) --已领取
			end
		elseif(_index == 2) then
			
		end
	end)

end


--请求抽取
--_type:1:抽一次, 10:抽10次
function DlgDragonTreasure:reqTakeItems(_type)
	-- body
	--需要消耗个数
	local nCostNum = _type
	local nLeft = self.nHasCostItemCnt - nCostNum
	if nLeft >= 0 then
		--寻龙夺宝请求抽取
		self.bIsStopSnatchturnUpdate = true --停止刷新
		SocketManager:sendMsg("reqDragonTreasure",{_type}, function(__msg, __oldMsg)
			-- body
			--以防此类已删除
			if self and self.playCircleAnim then
				self:playCircleAnim(__msg, __oldMsg)
				self:showOpenTx()
			end
		end)
	else
		local nCostMoney = 0 --需要消耗的黄金
		if self.tData.tCost and self.tData.tCost[1].v then
			nCostMoney = self.tData.tCost[1].v*(-nLeft)
		end
		local strTips = {
		    {color=_cc.pwhite, text = string.format(getConvertedStr(7, 10273), self.tCostItem.sName)},
		    {color=_cc.yellow, text = nCostMoney..getConvertedStr(7, 10036)},
		    {color=_cc.pwhite, text = string.format(getConvertedStr(7, 10274), -nLeft, self.tCostItem.sName)},
		}
		--展示购买对话框
		showBuyDlg(strTips, nCostMoney,function (  )
		    SocketManager:sendMsg("reqBuyItem", {self.tData.nCostItemId, -nLeft}, function (__msg, __oldMsg)
		    	if __msg.head.state == SocketErrorType.success then
		    		self.bIsStopSnatchturnUpdate = true --停止刷新
		    		--购买成功后立即请求抽取
					SocketManager:sendMsg("reqDragonTreasure",{_type}, function ( __msg, __oldMsg)
						--以防此类已删除
						if self and self.playCircleAnim then
							self:playCircleAnim(__msg, __oldMsg)
							self:showOpenTx()
						end
					end)
				end
			end)
			
		end, 1, true)
	end
end

--抽1次
function DlgDragonTreasure:onBuyOneClicked( )
	self:reqTakeItems(nOneTime)
	closeDlgByType(e_dlg_index.showheromansion, false)
end

--抽10次
function DlgDragonTreasure:onBuyTenClicked( )
	self:reqTakeItems(nTenTimes)
	closeDlgByType(e_dlg_index.showheromansion, false)
end

--转圈特效
function DlgDragonTreasure:playCircleAnim( __msg, __oldMsg)
	if not __msg then
		--允许刷新
    	self.bIsStopSnatchturnUpdate = false
    	return
	end
	self.tTurnFruitVoList = nil --清空结果数据
	self.tGetTargetItem = nil --目标物品
	self.nPrevCtrl = __oldMsg[1] --上一次操作
	if  __msg.head.state == SocketErrorType.success then
    	if __msg.head.type == MsgType.reqDragonTreasure.id then
    		--关掉获得显示
    		closeDlgByType(e_dlg_index.showheromansion, false)

    		--结果
    		local tDataTfs = __msg.body.ob
    		--结果格子位置
    		local tGrids = __msg.body.grids
    		--播放特效
    		if tDataTfs and tGrids then
				--播放转圈
        		if #tDataTfs > 0 and #tGrids > 0 then
        			local nLoc = tGrids[#tGrids]
        			self.tTurnFruitVoList = tDataTfs
        			if __msg.body.tob then --Pair<Integer,Long>	获得的目标物品
        				self.tGetTargetItem = __msg.body.tob
        			end
					--播放动画
					self:startAnim(nLoc, handler(self, self.stopAndShowResult))
				end
			end
    	end
    else
    	--允许刷新
    	self.bIsStopSnatchturnUpdate = false
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--开始播放动画
function DlgDragonTreasure:startAnim(nTargetIndex, nUnableTouchFunc)
	-- body
	--开屏蔽
	if not self.bIsOpenUnableTouch then
		self.bIsOpenUnableTouch = true
		showUnableTouchDlg(nUnableTouchFunc)
	end
	

	--当前显示的下标
	self.nLightIndex = 0
	self.nEndLightIndex = nTargetIndex + nAllGoodsCnt * 3
	self:runAct(0)
end

function DlgDragonTreasure:runAct( nT )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
	--自增1
	self.nLightIndex = self.nLightIndex + 1
	if self.nLightIndex <= self.nEndLightIndex then
		--显示特效
		local nGoodsIndex = self.nLightIndex%nAllGoodsCnt
		if self.nLightIndex % nAllGoodsCnt == 0 then
			nGoodsIndex = nAllGoodsCnt
		end
		local bIsPlayParticle = self.nLightIndex <= nAllGoodsCnt
		self:showChangeEffect(nGoodsIndex, bIsPlayParticle)
	end

	--给多一帧结束时间
	if self.nLightIndex > self.nEndLightIndex then
		--显示动画
		self:stopAndShowResult()
	else
		--最后面倒数6(一圈)明显示减速
		local nNextT = 0
		if self.nLightIndex >= self.nEndLightIndex - 6 then
			nNextT = nT + self.nLightIndex * 0.006/3
			if nNextT > 1 then				
				nNextT = 1
			end
		else
			nNextT = nT +  self.nLightIndex * 0.0001/3
			if nNextT > 0.075/3 then				
				nNextT = 0.075/3
			end
		end
		--设置下一个时间循环
		self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(handler(self, self.runAct), nNextT)
	end
end

--设置切换的动画特效
function DlgDragonTreasure:showChangeEffect( nIndex, bIsPlayParticle)
	local pLayGoods = self.tCenterGoodsLays[nIndex]
	if pLayGoods then
		local nOffsetX, nOffsetY = 45, 40

		--边框动画
		local sName = createAnimationBackName("tx/exportjson/", "sg_htyl_sl_gks_001")
	    local pLightArm = ccs.Armature:create(sName)
	   	pLayGoods:addView(pLightArm)
	    pLightArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
			if (eventType == MovementEventType.COMPLETE) then
				pLightArm:removeSelf()
			end
		end)
		pLightArm:getAnimation():play("Animation1", 1)
		pLightArm:setPosition(nOffsetX, nOffsetY)
	    
	    --显示边框
	    local nX, nY = pLayGoods:getPosition()
		self.pImgBorder:setPosition(cc.p(nX + nOffsetX - 2, nY - 1 + 87/2))
		self.pImgBorder:setVisible(true)

		--播放粒子
		if bIsPlayParticle then
			local pParitcle =  createParitcle("tx/other/lizi_haotieyl_d_001.plist")
			pParitcle:setPosition(nX + nOffsetX + 12, nY + nOffsetY - 27)
			self.pLayCenter:addView(pParitcle, 11)
			table.insert(self.pParitcles, pParitcle)
		end

	end
end

--停止动画显示结果
function DlgDragonTreasure:stopAndShowResult()
	--停止动画
	self:stopCircleAnim()
	--恢复显示
	self.pImgBorder:setVisible(false)

	--抽奖结束回调
	self:playCircleAnimOver()
	self:shopOpenTx()
end

--停止圆形动画
function DlgDragonTreasure:stopCircleAnim( )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
	for i=1,#self.pParitcles do
		self.pParitcles[i]:removeFromParent(true)
	end
	self.pParitcles = {}

	--关闭不可点击
	if self.bIsOpenUnableTouch then
		self.bIsOpenUnableTouch = false
		hideUnableTouchDlg()
	end
end


--转圈特效结束
function DlgDragonTreasure:playCircleAnimOver( )
	--允许刷新
    self.bIsStopSnatchturnUpdate = false
    --刷新最新数据展示
    self:updateDragonTurn()
    --播放获取
    self:showGetHero(self.tTurnFruitVoList)
end

--展示获得英雄
function DlgDragonTreasure:showGetHero(_data)
	-- self.tData.tOb
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
		table.insert(tReward.d, copyTab(v))
		table.insert(tReward.g, copyTab(v))
		table.insert(tDataList,tReward)
	end

	--左边按钮数据
	local tLBtnData = {}
	--int	1：抽1次 10： 抽10次
	local tData = Player:getActById(e_id_activity.dragontreasure)
	if tData then
		if tData.tTurnConfVo then
			--设置按钮数据
			if self.nPrevCtrl == nOneTime then
				tLBtnData.nBtnType = TypeCommonBtn.L_BLUE
				tLBtnData.nCostNum = nOneTime
				tLBtnData.nClickedFunc = handler(self, self.onBuyOneClicked)
			else
				tLBtnData.nBtnType = TypeCommonBtn.L_YELLOW
				tLBtnData.nCostNum = nTenTimes
				tLBtnData.nClickedFunc = handler(self, self.onBuyTenClicked)
			end
			tLBtnData.nCostId = self.tData.nCostItemId
			tLBtnData.sBtnStr = string.format(getConvertedStr(7, 10272), self.nPrevCtrl)
			tLBtnData.nHasCostItemCnt = self.nHasCostItemCnt
		end
	end
	local pDlg = getDlgByType(e_dlg_index.gettargetgoodstip)
	if pDlg then
		closeDlgByType(e_dlg_index.gettargetgoodstip, false)
	end

	--打开招募展示英雄对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    tObject.tLBtnData = tLBtnData
    --弹窗获得的目标物品
    if self.tGetTargetItem then
    	tObject.tGetTargetGoods = self.tGetTargetItem[1]
    end
    tObject.nRHandler = function( )
   	end
    sendMsg(ghd_show_dlg_by_type,tObject)
end

--中心抽奖的图标上下浮动
function DlgDragonTreasure:showImgAction()
	local action1 = cc.MoveBy:create(1, cc.p(0,6))
	local action2 = cc.MoveBy:create(1, cc.p(0,-6))
	local sqe_1 = cc.Sequence:create(action1, action2, cc.CallFunc:create( function ()
		doDelayForSomething(self, function( )
			self:showImgShadow()
		end, 0.8)
	end	))
	self.pLyCenterTx:runAction(cc.RepeatForever:create(sqe_1))

	self.pImgCenterGood_1:setOpacity(0)
	self.pImgCenterGood_1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	local action7 = cc.FadeTo:create(1, 255*0.2)
	local action8 = cc.FadeTo:create(1, 255*0)
	local sqe_4 = cc.Sequence:create(action7, action8)
	self.pImgCenterGood_1:runAction(cc.RepeatForever:create(sqe_4))

	addTextureToCache("tx/other/sg_xldb_yw_x")

	local pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["49_2"],
		self.pLyCenterTx,
		15,
		cc.p(0,0),
		function ( _pArm )
		end, Scene_arm_type.normal)
	if pArm then
		pArm:play(-1)
	end

	local pArm_1 = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["49_1"],
		self.pLyCenterTx,
		10,
		cc.p(0,0),
		function ( pArm_1 )
		end, Scene_arm_type.normal)

	if pArm_1 then
		pArm_1:play(-1)
	end
	
	doDelayForSomething(self, function( )
		self:showImgShadow()
	end, 0.8)

	local pParitcle1 =  createParitcle("tx/other/lizi_xldb_b_o1_01.plist")
	pParitcle1:setPosition(cc.p(140,115))
	self.pLyCenterGood:addView(pParitcle1,9999)

end  

--图片的扩散效果
function DlgDragonTreasure:showImgShadow()
	self.pImgCenterGood_shadow:setScale(1.2)
	self.pImgCenterGood_shadow:setOpacity(0)
	self.pImgCenterGood_shadow:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

	local action1 = cc.ScaleTo:create(0.33, 1.37/1.2*1.3)
	local action2 = cc.ScaleTo:create(0.7, 1.59/1.2*1.3)
	local sqe_1 = cc.Sequence:create(action1, action2)
	local action3 = cc.FadeTo:create(0.33, 255*0.2)
	local action4 = cc.FadeTo:create(0.7, 255*0)
	local sqe_2 = cc.Sequence:create(action3, action4)

	-- cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(ndelay, moveVec), 

	self.pImgCenterGood_shadow:runAction(cc.Spawn:create(sqe_1, sqe_2))
end


--常态下特效 （流光加粒子）
function DlgDragonTreasure:showFluxay()
 	if not self.fluxayImg_1 then
 		self.fluxayImg_1 = MUI.MImage.new("#sg_xldb_a_001.png");
 		self.pLayCenter:addView(self.fluxayImg_1)
 		self.fluxayImg_1:setPosition(cc.p(11,386))
 		self.fluxayImg_1:setOpacity(0)
 	end
 	local action1 = cc.FadeIn:create(1.5)
 	local action2 = cc.FadeOut:create(1.5)
 	local sqe_1 = cc.Sequence:create(action1, action2)
 	local action3 = cc.MoveTo:create(1.5,cc.p(87,463))
 	local action4 = cc.MoveTo:create(1.5,cc.p(156,531))
 	local sqe_2 = cc.Sequence:create(action3, action4, cc.CallFunc:create(function() self.fluxayImg_1:setPosition(11,386) end))
 	self.fluxayImg_1:runAction(cc.RepeatForever:create(cc.Spawn:create(sqe_1, sqe_2)))
 	
 	if not self.fluxayImg_2 then
 		self.fluxayImg_2 = MUI.MImage.new("#sg_xldb_a_001.png");
 		self.pLayCenter:addView(self.fluxayImg_2)
 		self.fluxayImg_2:setPosition(cc.p(619,241))
 		self.fluxayImg_2:setOpacity(0)
 	end
 	local action5= cc.FadeIn:create(1.5)
 	local action6= cc.FadeOut:create(1.5)
 	local sqe_3 = cc.Sequence:create(action5, action6)

 	local action7 = cc.MoveTo:create(1.5,cc.p(543,164))
 	local action8 = cc.MoveTo:create(1.5,cc.p(474,96))
 	local sqe_4 = cc.Sequence:create(action7, action8, cc.CallFunc:create(function() self.fluxayImg_2:setPosition(619,241) end))
 	self.fluxayImg_2:runAction(cc.RepeatForever:create(cc.Spawn:create(sqe_3, sqe_4)))

 	if not self.fluxayImg_3 then
 		self.fluxayImg_3 = MUI.MImage.new("#sg_xldb_a_001.png");
 		self.pLayCenter:addView(self.fluxayImg_3)
 		self.fluxayImg_3:setPosition(cc.p(12,255))
 		self.fluxayImg_3:setOpacity(0)
 		self.fluxayImg_3:setFlippedX(true)
 	end
 	local action9= cc.FadeIn:create(1.5)
 	local action10= cc.FadeOut:create(1.5)
 	local sqe_5 = cc.Sequence:create(action9, action10)

 	local action11 = cc.MoveTo:create(1.5,cc.p(88,178))
 	local action12 = cc.MoveTo:create(1.5,cc.p(157,110))
 	local sqe_6 = cc.Sequence:create(action11, action12, cc.CallFunc:create(function() self.fluxayImg_3:setPosition(12,255) end))
 	self.fluxayImg_3:runAction(cc.RepeatForever:create(cc.Spawn:create(sqe_5, sqe_6)))


 	if not self.fluxayImg_4 then
 		self.fluxayImg_4 = MUI.MImage.new("#sg_xldb_a_001.png");
 		self.pLayCenter:addView(self.fluxayImg_4)
 		self.fluxayImg_4:setPosition(cc.p(619,393))
 		self.fluxayImg_4:setOpacity(0)
 		self.fluxayImg_4:setFlippedX(true)
 	end
 	local action13= cc.FadeIn:create(1.5)
 	local action14= cc.FadeOut:create(1.5)
 	local sqe_7 = cc.Sequence:create(action13, action14)

 	local action15 = cc.MoveTo:create(1.5,cc.p(543,470))
 	local action16 = cc.MoveTo:create(1.5,cc.p(474,538))
 	local sqe_8 = cc.Sequence:create(action15, action16, cc.CallFunc:create(function() self.fluxayImg_4:setPosition(619,393) end))
 	self.fluxayImg_4:runAction(cc.RepeatForever:create(cc.Spawn:create(sqe_7, sqe_8)))

	--第一层
	local pParitcle1 =  createParitcle("tx/other/lizi_xldb_a_o1_03.plist")
	pParitcle1:setPosition(cc.p(20,320))
	self.pLayCenter:addView(pParitcle1,1)
	
	--第二层
	local pParitcle2 =  createParitcle("tx/other/lizi_xldb_a_o1_04.plist")
	pParitcle2:setPosition(cc.p(620,320))
	self.pLayCenter:addView(pParitcle2,2)

end

--开启状态特效
function DlgDragonTreasure:showOpenTx()
	--左
	 if not self.pOpenImg_1 then
 		self.pOpenImg_1 = MUI.MImage.new("#sg_xldb_a_002.png");
 		self.pLayCenter:addView(self.pOpenImg_1)
 		self.pOpenImg_1:setPosition(cc.p(99,316))
 		self.pOpenImg_1:setScale(3)
 		self.pOpenImg_1:setOpacity(200)
 		self.pOpenImg_1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
 	else
 		self.pOpenImg_1:setVisible(true)
 	end
 	local action1 = cc.FadeTo:create(0.5, 100)
 	local action2 = cc.FadeTo:create(1, 200)
 	local sqe_1 = cc.Sequence:create(action1, action2)
 	self.pOpenImg_1:runAction(cc.RepeatForever:create(sqe_1))

	if not self.pOpenImg_2 then
 		self.pOpenImg_2 = MUI.MImage.new("#sg_xldb_a_002.png");
 		self.pLayCenter:addView(self.pOpenImg_2)
 		self.pOpenImg_2:setPosition(cc.p(541,315))
 		self.pOpenImg_2:setScale(3)
 		self.pOpenImg_2:setOpacity(200)
 		self.pOpenImg_2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
 		self.pOpenImg_2:setFlippedX(true)
 	else
 		self.pOpenImg_2:setVisible(true)
 	end
 	local action3 = cc.FadeTo:create(0.5, 100)
 	local action4 = cc.FadeTo:create(1, 200)
 	local sqe_2 = cc.Sequence:create(action3, action4)
 	self.pOpenImg_2:runAction(cc.RepeatForever:create(sqe_2)) 	

	if not self.pOpenImg_3 then
 		self.pOpenImg_3 = MUI.MImage.new("#sg_xldb_a_003.png");
 		self.pLayCenter:addView(self.pOpenImg_3)
 		self.pOpenImg_3:setPosition(cc.p(320,554))
 		self.pOpenImg_3:setScale(2)
 		self.pOpenImg_3:setOpacity(78)
 		self.pOpenImg_3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
 	else
 		self.pOpenImg_3:setVisible(true)
 	end
 	local action5 = cc.FadeTo:create(0.5, 178)
 	local action6 = cc.FadeTo:create(1, 78)
 	local sqe_3 = cc.Sequence:create(action5, action6)
 	self.pOpenImg_3:runAction(cc.RepeatForever:create(sqe_3)) 	

	if not self.pOpenImg_4 then
 		self.pOpenImg_4 = MUI.MImage.new("#sg_xldb_a_004.png");
 		self.pLayCenter:addView(self.pOpenImg_4)
 		self.pOpenImg_4:setPosition(cc.p(320,80))
 		self.pOpenImg_4:setScale(2)
 		self.pOpenImg_4:setOpacity(78)
 		self.pOpenImg_4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
 	else
 		self.pOpenImg_4:setVisible(true)
 	end
 	local action7 = cc.FadeTo:create(0.5, 178)
 	local action8 = cc.FadeTo:create(1, 78)
 	local sqe_4 = cc.Sequence:create(action7, action8)
 	self.pOpenImg_4:runAction(cc.RepeatForever:create(sqe_4))

end

function DlgDragonTreasure:shopOpenTx()
	for i = 1 , 4 do
		if self["pOpenImg_"..i] then
			self["pOpenImg_"..i]:stopAllActions()
			self["pOpenImg_"..i]:setVisible(false)
		end
	end
end

return DlgDragonTreasure