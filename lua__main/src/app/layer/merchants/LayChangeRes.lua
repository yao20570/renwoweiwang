-- LayChangeRes.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-9 17:28:55 星期五
-- Description: 商队兑换商层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemChangeRes = require("app.layer.merchants.ItemChangeRes")
-- local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local FCommonItemTab = require("app.common.tabhost.FCommonItemTab")


local nDistanceTime = 500 --按钮延时响应(单位毫秒)

local LayChangeRes = class("LayChangeRes", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)
--_data：当前科技数据
function LayChangeRes:ctor( _tSize )
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_change_res", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function LayChangeRes:myInit(  )
	-- body
	self.nCoinId            = e_resdata_ids.yb                         --银币id
	self.nWoodId            = e_resdata_ids.mc                         --木材id
	self.nFoodId            = e_resdata_ids.lc                         --粮草id
	self.nMaxLimitCD        = tonumber(getShopInitParam("maxLimitCD")) --CD上限时间
	self.nBuyOnceCD         = tonumber(getShopInitParam("buyOnceCD"))  --商队购买一次cd时间(秒)
	self.nMaxChangeCnt		= math.floor((self.nMaxLimitCD+self.nBuyOnceCD)/self.nBuyOnceCD)
	self.bCanExchange       = true                                     --当前是否可兑换
	self.tCoinExchange      = getShopInitParam("coinExchange")         --银币兑换比例
	self.tWoodExchange      = getShopInitParam("woodExchange")         --木材兑换比例
	self.tFoodExchange      = getShopInitParam("foodExchange")         --粮草兑换比例
	self.nCostId            = self.nCoinId                             --当前消耗资源的id
	self.tGetRes            = {}                                       --获得资源
	--左右两边的获得资源id
	self.tGetRes[self.nCoinId] = {nLeftId = self.nWoodId, nRightId = self.nFoodId}
	self.tGetRes[self.nWoodId] = {nLeftId = self.nCoinId, nRightId = self.nFoodId}
	self.tGetRes[self.nFoodId] = {nLeftId = self.nWoodId, nRightId = self.nCoinId}
end

--解析布局回调事件
function LayChangeRes:onParseViewCallback( pView )
	-- body
	-- self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayChangeRes",handler(self, self.onLayChangeResDestroy))
end

--初始化控件
function LayChangeRes:setupViews( )
	-- body
	self.pLayMain       		= self:findViewByName("lay_main")
	self.pLayBottomLeft         = self:findViewByName("lay_b_left")
	self.pLayBottomRight        = self:findViewByName("lay_b_right")
	self.pLayTitle              = self:findViewByName("lay_title")
	--底部文字
	self.pLbBotTip              = self:findViewByName("lb_bot_tip")


	self.pBtnLeft = getCommonButtonOfContainer(self.pLayBottomLeft,TypeCommonBtn.L_BLUE,getConvertedStr(7,10044))
	self.pBtnRight = getCommonButtonOfContainer(self.pLayBottomRight,TypeCommonBtn.L_BLUE,getConvertedStr(7,10044))

	--左边兑换按钮点击事件
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
    --右边兑换按钮点击事件
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))
	--无效状态下点击回调事件
	self.pBtnLeft:onCommonBtnDisabledClicked(handler(self, self.onDisabledClicked))
	self.pBtnRight:onCommonBtnDisabledClicked(handler(self, self.onDisabledClicked))

	--左边按钮上的文字
	self.pLbBtnLeft = MUI.MLabel.new({text = "", size = 20})
	self.pLayMain:addView(self.pLbBtnLeft, 10)
	local nPosX = self.pLayBottomLeft:getPositionX() + self.pLayBottomLeft:getWidth()/2
	local nPosY = self.pLayBottomLeft:getPositionY() + self.pLayBottomLeft:getHeight() + 6
	self.pLbBtnLeft:setPosition(nPosX, nPosY)
	--右边按钮上的文字
	self.pLbBtnRight = MUI.MLabel.new({text = "", size = 20})
	self.pLayMain:addView(self.pLbBtnRight, 10)
	local nPosX = self.pLayBottomRight:getPositionX() + self.pLayBottomRight:getWidth()/2
	self.pLbBtnRight:setPosition(nPosX, nPosY)
	
	self.tResItems = {}
	for i = 1, 3 do
		local pLayRes = self:findViewByName("lay_res"..i)
		local pResItem = ItemChangeRes.new()
		pLayRes:addView(pResItem, 10)
		self.tResItems[i] = pResItem
		self.tResItems[i]:setResData(nil)
	end

	--切换卡层
	self.tTitles = {
		getConvertedStr(7, 10048),
		getConvertedStr(7, 10049),
		getConvertedStr(7, 10050),
	}
	-- self.pTComTab = TCommonTabHost.new(self.pLayTitle,1,1,self.tTitles,handler(self, self.onResTabSelected))
	-- self.pLayTitle:addView(self.pTComTab)
	-- self.tTabItems = self.pTComTab:getTabItems()
	-- self.pTComTab:removeLayTmp1()
	-- --默认选中第一项
	-- self.pTComTab:setDefaultIndex(1)

	self.tTabItems = {}
	self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, self.pLayTitle:getContentSize().width, self.pLayTitle:getContentSize().height),
        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
        itemMargin = {left = 0,
            right =  0,
            top =  3,
            bottom =  0},
    }
    self.pLayTitle:addView(self.pListView)
    self.pListView:setIsCanScroll(false)
    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
    self.pListView:setItemCount(table.nums(self.tTitles))
    self.pListView:reload()
end

--列表项回调
function LayChangeRes:onListViewItemCallBack( _index, _pView )
	-- body
	local tTempData = self.tTitles[_index]
    local pTempView = _pView
    if pTempView == nil then
    	local pItemTab = FCommonItemTab.new(1, 1, 213)
        pTempView = pItemTab 
    end
    self.tTabItems[_index] = pTempView
    pTempView.nIndex = _index --下标标志
    if tTempData then
   		pTempView:setTabTitle(tTempData)
   		pTempView:setViewEnabled(true)
   		--隐藏上锁
		pTempView:hideTabLock()
   	end
    --设置点击事件
	pTempView:onMViewClicked(handler(self, self.onResTabSelected))
    return pTempView
end


-- 修改控件内容或者是刷新控件数据
function LayChangeRes:updateViews(  )
	-- body
	gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
		if(_index == 1) then
			self:setCDTime()
			unregUpdateControl(self)
			regUpdateControl(self, handler(self, self.setCDTime))
		elseif(_index == 2) then
			--刷新资源
			self:refreshResInfo()
		end
	end)
end

--设置CD倒计时
function LayChangeRes:setCDTime()
	-- body
	--累计CD剩余时间
	local fLeftTime = Player:getShopData():getShopTeamCDLeftTime()

	if fLeftTime > 0 then
		if fLeftTime > self.nMaxLimitCD then
			setTextCCColor(self.pLbBotTip, _cc.red)
			self.bCanExchange = false
		else
			if self.bCanExchange == false then
				self.bCanExchange = true
				--刷新资源
				self:refreshResInfo()
			end
			setTextCCColor(self.pLbBotTip, _cc.pwhite)
		end
		self.pLbBotTip:setString(getConvertedStr(7, 10051)..formatTimeToHms(fLeftTime))
	else
		if self.bCanExchange == false then
			self.bCanExchange = true
			--刷新资源
			self:refreshResInfo()
		end
		self.pLbBotTip:setString(getConvertedStr(7, 10043))
		setTextCCColor(self.pLbBotTip, _cc.gray)
	end
	local nLeftChangeCnt = math.floor((self.nMaxLimitCD+self.nBuyOnceCD-fLeftTime)/self.nBuyOnceCD)
	local sColor = _cc.red
	if nLeftChangeCnt > 0 then
		sColor = _cc.green
	end
	local tStr = {
		{text = getConvertedStr(7, 10401), color = _cc.white},
		{text = nLeftChangeCnt, color = sColor},
		{text = "/"..self.nMaxChangeCnt, color = _cc.white}
	}
	self.pLbBtnLeft:setString(tStr)
	self.pLbBtnRight:setString(tStr)
end

--刷新资源
function LayChangeRes:refreshResInfo()
	if self.nCurrTab and self.tTabItems[self.nCurrTab] then
		self:onResTabSelected(self.tTabItems[self.nCurrTab])
	else
		if self.tTabItems[1] then
			self:onResTabSelected(self.tTabItems[1])
		end
	end
end

--下标选择回调事件
function LayChangeRes:onResTabSelected( pView )
	local _index = pView.nIndex
	-- if self.nCurrTab == _index then
	-- 	return
	-- end
	--打包提示
	self.nCurrTab = _index --当前所选下标
	if self.nCurrTab == 1 then                                       --银币
		self:changeResInfo(self.nCoinId, "coin", self.tCoinExchange, self.nWoodId, self.nFoodId)
		self.nSeleId = self.nCoinId
	elseif self.nCurrTab == 2 then                                      --木材
		self:changeResInfo(self.nWoodId, "wood", self.tWoodExchange, self.nCoinId, self.nFoodId)
		self.nSeleId = self.nWoodId
	elseif self.nCurrTab == 3 then                                     --粮草
		self:changeResInfo(self.nFoodId, "food", self.tFoodExchange, self.nWoodId, self.nCoinId)
		self.nSeleId = self.nFoodId
	end
	
	for k, v in pairs(self.tTabItems) do
		if v.nIndex == self.nCurrTab then
			v:setChecked(true, "#v2_btn_selected_hkoyp.png")
		else
			v:setChecked(false, "#v2_btn_biaoqian_hkoyp.png")
		end
	end
	if self.bCanExchange then
		self.pBtnLeft:setBtnEnable(true)
		self.pBtnRight:setBtnEnable(true)
	else
		self.pBtnLeft:setBtnEnable(false)
		self.pBtnRight:setBtnEnable(false)
		self.pBtnLeft:updateBtnText(getConvertedStr(7,10367))  --冷却中
		self.pBtnRight:updateBtnText(getConvertedStr(7,10367)) --冷却中
	end
end

function LayChangeRes:changeResInfo(_costId, _costName, _tExchange, _leftId, _rightId)
	-- body
	local data = {}
	self.nCostId = _costId
	self.nCostName = _costName

	data        = self:getResDataById(_costId, _costName)
	local nBaseCnt = data.nCt
	self.tResItems[1]:setResData(data)
	local sColor = _cc.green
	-- self.pIcon1 = getIconGoodsByType(self.pLayRes1, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	if not self:isCanExchange() then
		sColor = _cc.red
	end
	local str = {
		{text = getConvertedStr(7,10365), color = _cc.white},
		{text = "X"..getResourcesStr(data.nCt), color = sColor}
	}
	self.tResItems[1]:setNumTx(str)

	data        = getItemResourceData(_leftId)
	data.nCt    = math.round(nBaseCnt * _tExchange[tostring(_leftId)])
	-- self.pIcon2 = getIconGoodsByType(self.pLayRes2, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	self.tResItems[2]:setResData(data)
	local str = {
		{text = getConvertedStr(7,10366), color = _cc.white},
		{text = "X"..getResourcesStr(data.nCt), color = _cc.green}
	}
	self.tResItems[2]:setNumTx(str)
	self.pBtnLeft:updateBtnText(getConvertedStr(7,10044)..data.sName)

	data        = getItemResourceData(_rightId)
	data.nCt    = math.round(nBaseCnt * _tExchange[tostring(_rightId)])
	-- self.pIcon3 = getIconGoodsByType(self.pLayRes3, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	self.tResItems[3]:setResData(data)
	local str = {
		{text = getConvertedStr(7,10366), color = _cc.white},
		{text = "X"..getResourcesStr(data.nCt), color = _cc.green}
	}
	self.tResItems[3]:setNumTx(str)
	self.pBtnRight:updateBtnText(getConvertedStr(7,10044)..data.sName)
end

--左边按钮点击事件
function LayChangeRes:onLeftClicked()
	-- body
	if self.nLastClickTime then
		local nCurTime = getSystemTime(false)
		if (nCurTime - self.nLastClickTime) < nDistanceTime then
			return
		end
	end
	self.nLastClickTime = getSystemTime(false)
	--不能兑换
	if self:cannotExchange() then
		return
	end
	--消耗id和兑换资源id
	SocketManager:sendMsg("reqResExchange", {self.nCostId, self.tGetRes[self.nCostId].nLeftId})
end

--右边按钮点击事件
function LayChangeRes:onRightClicked()
	-- body
	if self.nLastClickTime then
		local nCurTime = getSystemTime(false)
		if (nCurTime - self.nLastClickTime) < nDistanceTime then
			return
		end
	end
	self.nLastClickTime = getSystemTime(false)
	--不能兑换
	if self:cannotExchange() then
		return
	end
	--消耗id和兑换资源id
	SocketManager:sendMsg("reqResExchange", {self.nCostId, self.tGetRes[self.nCostId].nRightId})
end

--无效状态下点击回调事件
function LayChangeRes:onDisabledClicked()
	TOAST(getConvertedStr(7, 10052))
end

--判断是否满足兑换条件
function LayChangeRes:isCanExchange()
	-- body
	local nBaseCnt = self:getResDataById(self.nCostId, self.nCostName).nCt
	self.nBaseCnt = nBaseCnt
	if nBaseCnt == 0 then return false end
	if getMyGoodsCnt(self.nCostId) < nBaseCnt then
		return false
	end
	return true
end

--不能兑换
function LayChangeRes:cannotExchange()
	-- body
	--数量不足兑换
	if not self:isCanExchange() then
		--获取资源窗口
		local tResList = {}
		tResList[e_resdata_ids.lc] = 0
		tResList[e_resdata_ids.bt] = 0
		tResList[e_resdata_ids.mc] = 0
		tResList[e_resdata_ids.yb] = 0
		tResList[self.nSeleId] = self.nBaseCnt
		goToBuyRes(self.nSeleId, tResList)
		return true
	end
	--正在冷却中
	if not self.bCanExchange then
		TOAST(getConvertedStr(7, 10052))
		return true
	end
end

function LayChangeRes:getResDataById(_nId, _sName)
	-- body
	local data = getItemResourceData(_nId)
	data.nCt = Player:getResourceData():getOutput(_sName)
	return data
end


--设置当前数据
function LayChangeRes:setData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

-- 析构方法
function LayChangeRes:onLayChangeResDestroy(  )
	-- body
end

--注册消息
function LayChangeRes:regMsgs(  )
	-- body
	--刷新兑换CD
	regMsg(self, gud_refresh_merchants, handler(self, self.updateViews))
end
--注销消息
function LayChangeRes:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_merchants)
end

-- 暂停方法
function LayChangeRes:onPause()
	self:unregMsgs()	
end

--继续方法
function LayChangeRes:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return LayChangeRes