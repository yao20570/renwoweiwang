----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-09-05 21:18:26
-- Description: 耗铁有礼
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local SnatchturnLayer = require("app.layer.activityb.snatchturn.SnatchturnLayer")

local nAllGoodsCnt = 8

local nOneBuy = 1
local nTenBuy = 10
local nFreeType = 0
local nPriceType = 1

local DlgConsumeiron = class("DlgConsumeiron", function()
	return DlgBase.new(e_dlg_index.consumeiron)
end)

function DlgConsumeiron:ctor(  )
	parseView("dlg_consumeiron", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgConsumeiron:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgConsumeiron",handler(self, self.onDlgConsumeironDestroy))
end

-- 析构方法
function DlgConsumeiron:onDlgConsumeironDestroy(  )
    self:onPause()
end

function DlgConsumeiron:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function DlgConsumeiron:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function DlgConsumeiron:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgConsumeiron:onPause(  )
	self:unregMsgs()
end

function DlgConsumeiron:setupViews(  )
	self.pLayTime = self:findViewByName("lay_time")

	self.pLayTop = self:findViewByName("lay_top")

	--banner
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_htyl)

	self.pTxtDesc = self:findViewByName("txt_desc")

	self.pLayTabHost = self:findViewByName("lay_tab")

	--获取content
	self.pSnatchturnLayer = SnatchturnLayer.new()
	self.pLayTabHost:addView(self.pSnatchturnLayer)
	centerInView(self.pLayTabHost, self.pSnatchturnLayer)

	--左边按钮
	local pLayBtnLeft = self:findViewByName("lay_btn_left")
	local pBtnLeft = getCommonButtonOfContainer(pLayBtnLeft, TypeCommonBtn.L_BLUE, getConvertedStr(3, 10261))
	pBtnLeft:onCommonBtnClicked(handler(self, self.onFreeClicked))
	self.pBtnLeft = pBtnLeft
	--文本
	local tConTable = {}
	local tLabel = {
	 {"0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pBtnLeft:setBtnExText(tConTable) 

	--右边按钮
	local pLayBtnRight = self:findViewByName("lay_btn_right")
	local pBtnRight = getCommonButtonOfContainer(pLayBtnRight, TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10409))
	pBtnRight:onCommonBtnClicked(handler(self, self.onBuyTenClicked))
	self.pBtnRight = pBtnRight
	--文本
	local tConTable = {}
	local tLabel = {
	 {"0",getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	tConTable.img = getCostResImg(e_type_resdata.money)
	self.pBtnRight:setBtnExText(tConTable) 
end


--控件刷新
function DlgConsumeiron:updateViews()
	local tData = Player:getActById(e_id_activity.consumeiron)
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


--更新转盘
function DlgConsumeiron:updateSnatchTurn( )
	if self.bIsStopSnatchturnUpdate then
		return
	end
	local tData = Player:getActById(e_id_activity.consumeiron)
	if tData then
		--设置数据
		local tGridVos = tData:getGirdVos()
		for i = 1, #tGridVos do
			local tGirdVo = tGridVos[i]
			self.pSnatchturnLayer:setGoodsData(tGirdVo.nGrid, tGirdVo.nGoodsId, tGirdVo.nGoodsCnt)
		end
	end
	--中间显示上次面板
	if self.nLastGrid then
		self.pSnatchturnLayer:showCenterGoods(self.nLastGrid)
	end
end

--更新低部按钮
function DlgConsumeiron:updateBottomBtns( )
	local tData = Player:getActById(e_id_activity.consumeiron)
	if tData then
		--右边按钮变成转10次
		self.pBtnRight:setExTextLbCnCr(1, tData:getBuyTenPrice())

		--免费还是显示一次
		local nFreeNum = tData:getFreeTurn()
		if nFreeNum > 0 then
			--左边按钮变成免费
			self.pBtnLeft:setButton(TypeCommonBtn.L_BLUE, getConvertedStr(3, 10261))
			self.pBtnLeft:onCommonBtnClicked(handler(self, self.onFreeClicked))
			self.pBtnLeft:setExTextVisiable(false)
			self.pBtnLeft:setBtnEnable(true)
		else
			--左边按钮变成转1次
			self.pBtnLeft:setButton(TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10408))
			self.pBtnLeft:onCommonBtnClicked(handler(self, self.onBuyOneClicked))
			self.pBtnLeft:setExTextVisiable(true)
			self.pBtnLeft:setExTextLbCnCr(1, tData:getBuyPrice())
			self.pBtnLeft:setBtnEnable(true)
		end
	end
end

--免费购买
function DlgConsumeiron:onFreeClicked( )
	--发送请求
	self.bIsStopSnatchturnUpdate = true --停止刷新
	SocketManager:sendMsg("reqConsumeironTurn", {nOneBuy, nFreeType}, function ( __msg, __oldMsg) --time	int	传1次或10次 type	int	0免费 1花费
		--以防此类已删除
		if self and self.playCircleAnim then
			self:playCircleAnim(__msg, __oldMsg)
		end
	end)
end

--转圈特效
function DlgConsumeiron:playCircleAnim( __msg, __oldMsg)
	-- dump(__msg, "DlgConsumeiron:playCircleAnim", 100)
	if not __msg then
		--允许刷新
    	self.bIsStopSnatchturnUpdate = false
    	return
	end
	self.tGotGoods = nil --清空结果数据
	self.nLastGrid = nil
	self.nPrevCtrl = __oldMsg[1] --上一次操作
	if  __msg.head.state == SocketErrorType.success then
    	if __msg.head.type == MsgType.reqConsumeironTurn.id then
    		--关掉获得显示
    		closeDlgByType(e_dlg_index.showheromansion, false)

    		--结果
    		local tGotGrids = __msg.body.as
    		--播放特效
    		if tGotGrids and #tGotGrids > 0 then

    			--填充展示数据
    			self.tGotGoods = {}
    			local tData = Player:getActById(e_id_activity.consumeiron)
				if tData then
					local tGridVos = tData:getGirdVos()
					for i=1,#tGotGrids do
						local nGrid = tGotGrids[i]
						for k,tGridVo in pairs(tGridVos) do
							if tGridVo.nGrid == nGrid then
								table.insert(self.tGotGoods, {k = tGridVo.nGoodsId, v = tGridVo.nGoodsCnt})
							end
						end
					end
				end

				--播放转圈
        		if self.pSnatchturnLayer then
    				local nGrid = tGotGrids[#tGotGrids] --物品下标
    				self.nLastGrid = nGrid --记录上一次得到东西
					self.pSnatchturnLayer:playCircleAnim(nGrid, handler(self, self.playCircleAnimOver), handler(self, self.stopSnatchAndShowRes))
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
function DlgConsumeiron:playCircleAnimOver( )
	--允许刷新
    self.bIsStopSnatchturnUpdate = false
    --刷新最新数据展示
    self:updateSnatchTurn()
    --播放获取
    self:showGetHero(self.tGotGoods)
end

--展示获得英雄
function DlgConsumeiron:showGetHero(_data)

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
	local tData = Player:getActById(e_id_activity.consumeiron)
	if tData then
		local bIsFree = false
		if tData.tSnatchTurnInfoVo then
			local nFreeNum = tData.tTurnConfVo:getFreeNumMax() - tData.tSnatchTurnInfoVo.nFreeUsed
			if nFreeNum > 0 then
				bIsFree = true
			end
		end

		--设置按钮数据
		local nFreeNum = tData:getFreeTurn()
		--免费
		if self.nPrevCtrl == nOneBuy and nFreeNum > 0  then
			tLBtnData.nBtnType = TypeCommonBtn.L_BLUE
			tLBtnData.sBtnStr = getConvertedStr(3, 10261)
			tLBtnData.nPrice = 0
			tLBtnData.nClickedFunc = handler(self, self.onFreeClicked)
			tLBtnData.bIsEnable = true
		else
			tLBtnData.nBtnType = TypeCommonBtn.L_YELLOW
			if self.nPrevCtrl == nTenBuy then
				tLBtnData.sBtnStr = getConvertedStr(3, 10419)
				tLBtnData.nPrice = tData:getBuyTenPrice()
				tLBtnData.nClickedFunc = handler(self, self.onBuyTenClicked)
			else
				tLBtnData.sBtnStr = getConvertedStr(3, 10418)
				tLBtnData.nPrice = tData:getBuyPrice()
				tLBtnData.nClickedFunc = handler(self, self.onBuyOneClicked)
			end
			tLBtnData.bIsEnable = true
		end
	end

	--打开招募展示英雄对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    tObject.tLBtnData = tLBtnData
    sendMsg(ghd_show_dlg_by_type,tObject)
end


--转1次
function DlgConsumeiron:onBuyOneClicked( )
	--购买
	local nCost = 0
	local tData = Player:getActById(e_id_activity.consumeiron)
	if tData then
		nCost = tData:getBuyPrice()
	end
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10410)},
	    {color=_cc.blue,text=tostring(1)..getConvertedStr(3, 10324)},
	}
	--展示购买对话框
	showBuyDlg(strTips,nCost,function (  )			
		--发送请求
		self.bIsStopSnatchturnUpdate = true --停止刷新
		SocketManager:sendMsg("reqConsumeironTurn", {nOneBuy, nPriceType}, function ( __msg, __oldMsg) --time	int	传1次或10次 type	int	0免费 1花费
			--以防此类已删除
			if self and self.playCircleAnim then
				self:playCircleAnim(__msg, __oldMsg)
			end
		end)
	end)
end

--转10次
function DlgConsumeiron:onBuyTenClicked( )
	--购买
	local nCost = 0
	local tData = Player:getActById(e_id_activity.consumeiron)
	if tData then
		nCost = tData:getBuyTenPrice()
	end
	local strTips = {
	    {color=_cc.pwhite,text=getConvertedStr(3, 10410)},
	    {color=_cc.blue,text=tostring(10)..getConvertedStr(3, 10324)},
	}
	--展示购买对话框
	showBuyDlg(strTips,nCost,function (  )
	   	--发送请求
		self.bIsStopSnatchturnUpdate = true --停止刷新
		SocketManager:sendMsg("reqConsumeironTurn", {nTenBuy, nPriceType}, function ( __msg, __oldMsg) --time	int	传1次或10次 type	int	0免费 1花费
			--以防此类已删除
			if self and self.playCircleAnim then
				self:playCircleAnim(__msg, __oldMsg)
			end
		end)
	end)
end

--停止动画显示结果
function DlgConsumeiron:stopSnatchAndShowRes( )
	if self.pSnatchturnLayer then
		self.pSnatchturnLayer:stopAndShowResult( )
	end
end

return DlgConsumeiron