-- DlgMerchants.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-13 15:14:55 星期二
-- Description: 商队界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")

local DlgMerchants = class("DlgMerchants", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgmerchants)
end)

function DlgMerchants:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_merchants", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgMerchants:myInit(  )
	-- body
	self.nCoinId           = 3                                        --银币id
	self.nWoodId           = 4                                        --木材id
	self.nFoodId           = 2                                        --粮草id
	self.nMaxLimitCD       = tonumber(getShopInitParam("maxLimitCD")) --CD上限时间
	self.bCanExchange      = true                                     --当前是否可兑换
	self.tCoinExchange     = getShopInitParam("coinExchange")         --银币兑换比例
	self.tWoodExchange     = getShopInitParam("woodExchange")         --木材兑换比例
	self.tFoodExchange     = getShopInitParam("foodExchange")         --粮草兑换比例
	self.nCostId           = self.nCoinId                             --当前消耗资源的id
	self.tGetRes           = {}                                       --获得资源
	--左右两边的获得资源id
	self.tGetRes[self.nCoinId] = {nLeftId = self.nWoodId, nRightId = self.nFoodId}
	self.tGetRes[self.nWoodId] = {nLeftId = self.nCoinId, nRightId = self.nFoodId}
	self.tGetRes[self.nFoodId] = {nLeftId = self.nWoodId, nRightId = self.nCoinId}
end

--解析布局回调事件
function DlgMerchants:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgMerchants",handler(self, self.onDlgMerchantsDestroy))
end

--初始化控件
function DlgMerchants:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7, 10042))

	self.pLayRoot              = self:findViewByName("default")
	self.pLbTopTip              = self:findViewByName("lb_toptip")
	self.pLayRes1               = self:findViewByName("lay_res1")
	self.pLayRes2               = self:findViewByName("lay_res2")
	self.pLayRes3               = self:findViewByName("lay_res3")
	self.pLayBottomLeft         = self:findViewByName("lay_b_left")
	self.pLayBottomRight        = self:findViewByName("lay_b_right")
	self.pLayExchange           = self:findViewByName("lay_exchange")
	self.pLayTitle              = self:findViewByName("lay_title")

	--上方提示
	self.pLbTopTip:setString(getConvertedStr(7, 10043))

	self.pBtnLeft = getCommonButtonOfContainer(self.pLayBottomLeft,TypeCommonBtn.R_BLUE,getConvertedStr(7,10044))
	self.pBtnRight = getCommonButtonOfContainer(self.pLayBottomRight,TypeCommonBtn.R_BLUE,getConvertedStr(7,10044))

	--左边兑换按钮点击事件
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
    --右边兑换按钮点击事件
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))

	--创建资源图片和数量文本
	self.tGroupTextCoin = self:createImgTextGroup("#v1_img_tongqian.png", 0, _cc.yellow, cc.p(120, 730))  --银币
	self.tGroupTextWood = self:createImgTextGroup("#v1_img_mucai.png", 0, _cc.yellow, cc.p(300, 730))     --木材
	self.tGroupTextFood = self:createImgTextGroup("#v1_img_liangshi.png", 0, _cc.yellow, cc.p(480, 730))  --粮食

	--资源图片
	local data = {}
	data = self:getResDataById(self.nCoinId)
	self.pIcon1 = getIconGoodsByType(self.pLayRes1, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	data = self:getResDataById(self.nWoodId)
	self.pIcon2 = getIconGoodsByType(self.pLayRes2, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	data = self:getResDataById(self.nFoodId)
	self.pIcon3 = getIconGoodsByType(self.pLayRes3, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	self.pIcon1:setMoreTextColor(_cc.blue)
	self.pIcon2:setMoreTextColor(_cc.blue)
	self.pIcon3:setMoreTextColor(_cc.blue)

	local tConTable = {}
	tConTable.tLabel = {
		{getConvertedStr(7, 10051), getC3B(_cc.pwhite)},
		{"01:55:20", getC3B(_cc.pwhite)},
	}
	self.pTimeText =  createGroupText(tConTable)
	self.pTimeText:setAnchorPoint(0.5, 0.5)
	self.pLayRoot:addView(self.pTimeText, 10)
	self.pTimeText:setPosition(self.pLbTopTip:getPosition())
	self.pTimeText:setVisible(false)

	--切换卡层
	self.tTitleList = {}
	self.tTitles = {
		getConvertedStr(7, 10048),
		getConvertedStr(7, 10049),
		getConvertedStr(7, 10050),
	}
	self.pTComTabHost = TCommonTabHost.new(self.pLayTitle,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pLayTitle:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()
	--默认选中第一项
	self.pTComTabHost:setDefaultIndex(1)

end

function DlgMerchants:updateViews()
	-- body
	self:setCDTime()
	unregUpdateControl(self)
	regUpdateControl(self, handler(self, self.setCDTime))
	--重置资源数量
	local nCoinCnt, nWoodCnt, nFoodCnt = 0, 0, 0
	--银币
	nCoinCnt = getMyGoodsCnt(self.nCoinId)
	
	--木材
	nWoodCnt = getMyGoodsCnt(self.nWoodId)

	--粮草
	nFoodCnt = getMyGoodsCnt(self.nFoodId)

	self.tGroupTextCoin:setLabelCnCr(1, getResourcesStr(nCoinCnt))
	self.tGroupTextWood:setLabelCnCr(1, getResourcesStr(nWoodCnt))
	self.tGroupTextFood:setLabelCnCr(1, getResourcesStr(nFoodCnt))
end

--设置CD倒计时
function DlgMerchants:setCDTime()
	-- body
	--累计CD时间和剩余时间
	local fAllTime = Player:getShopData():getExchangeCD()
	local fLeftTime = Player:getShopData():getShopTeamCDLeftTime()

	if fLeftTime > 0 then
		self.pLbTopTip:setVisible(false)
		self.pTimeText:setVisible(true)
		if fLeftTime > self.nMaxLimitCD then
			self.pTimeText:setLabelCnCr(1, getConvertedStr(7, 10051), getC3B(_cc.red))
			self.pTimeText:setLabelCnCr(2, formatTimeToHms(fLeftTime), getC3B(_cc.red))
			self.bCanExchange = false
		else
			self.pTimeText:setLabelCnCr(1, getConvertedStr(7, 10051), getC3B(_cc.pwhite))
			self.pTimeText:setLabelCnCr(2, formatTimeToHms(fLeftTime),getC3B(_cc.pwhite))
			self.bCanExchange = true
		end
	else
		self.pLbTopTip:setVisible(true)
		self.bCanExchange = true
	end
end

--下标选择回调事件
function DlgMerchants:onIndexSelected(_index)
	local data = {}
	if _index == 1 then                                           --银币
		self:changeResInfo(self.nCoinId, "coin", self.tCoinExchange, self.nWoodId, self.nFoodId)
	elseif _index == 2 then                                      --木材
		self:changeResInfo(self.nWoodId, "wood", self.tWoodExchange, self.nCoinId, self.nFoodId)
	elseif _index == 3 then                                     --粮草
		self:changeResInfo(self.nFoodId, "food", self.tFoodExchange, self.nWoodId, self.nCoinId)
	end
	--记录当前状态
	self.nSeleType = _index
	if _index == 3 then
		self.nSeleType = self.nSeleType + 1
	end
end

function DlgMerchants:changeResInfo(_costId, _costName, _tExchange, _leftId, _rightId)
	-- body
	self.nCostId = _costId
	data        = self:getResDataById(_costId, _costName)
	local nBaseCnt = data.nCt
	self.pIcon1 = getIconGoodsByType(self.pLayRes1, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	if not self:isCanExchange() then
		self.pIcon1:setNumberColor(_cc.red)
	end
	data        = getItemResourceData(_leftId)
	data.nCt    = math.round(nBaseCnt * _tExchange[tostring(_leftId)])
	self.pIcon2 = getIconGoodsByType(self.pLayRes2, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
	data        = getItemResourceData(_rightId)
	data.nCt    = math.round(nBaseCnt * _tExchange[tostring(_rightId)])
	self.pIcon3 = getIconGoodsByType(self.pLayRes3, TypeIconGoods.HADMORE, type_icongoods_show.itemnum, data, TypeIconEquipSize.L)
end

--判断是否满足兑换条件
function DlgMerchants:isCanExchange()
	-- body
	local nBaseCnt = self:getResDataById(self.nCoinId, "coin").nCt
	if nBaseCnt == 0 then return false end
	if getMyGoodsCnt(self.nCostId) < nBaseCnt then
		return false
	end
	return true
end

function DlgMerchants:getResDataById(_nId, _sName)
	-- body
	local data = getItemResourceData(_nId)
	-- data.nCt   = getItemResourceData(_nId):getCnt()      -- 数量
	data.nCt = Player:getResourceData():getOutput(_sName)
	return data
end

--创建资源图片和数量文本
function DlgMerchants:createImgTextGroup(_img, _text, _color, pos)
	-- body
	local tConTable = {}
	tConTable.tLabel = {
		{_text, getC3B(_color)},
	}
	tConTable.img = _img
	local pText =  createGroupText(tConTable)
	pText:setAnchorPoint(0.5, 0.5)
	self.pLayExchange:addView(pText, 10)
	pText:setPosition(pos)
	return pText
end

--左边按钮点击事件
function DlgMerchants:onLeftClicked()
	-- body
	--不能兑换
	if self:cannotExchange() then
		return
	end
	--消耗id和兑换资源id
	SocketManager:sendMsg("reqResExchange", {self.nCostId, self.tGetRes[self.nCostId].nLeftId})
end

--右边按钮点击事件
function DlgMerchants:onRightClicked()
	-- body
	--不能兑换
	if self:cannotExchange() then
		return
	end
	--消耗id和兑换资源id
	SocketManager:sendMsg("reqResExchange", {self.nCostId, self.tGetRes[self.nCostId].nRightId})
end

--不能兑换
function DlgMerchants:cannotExchange()
	-- body
	--数量不足兑换
	if not self:isCanExchange() then
		--获取资源窗口
		local tObject = {}
		tObject.nType = e_dlg_index.getresource --dlg类型
		tObject.nIndex = self.nSeleType
		sendMsg(ghd_show_dlg_by_type,tObject)
		return true
	end
	--正在冷却中
	if not self.bCanExchange then
		TOAST(getConvertedStr(7, 10052))
		return true
	end
end

-- 析构方法
function DlgMerchants:onDlgMerchantsDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgMerchants:regMsgs(  )
	-- body
	--刷新兑换CD
	regMsg(self, gud_refresh_merchants, handler(self, self.updateViews))
end
--注销消息
function DlgMerchants:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_merchants)
end

-- 暂停方法
function DlgMerchants:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgMerchants:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgMerchants