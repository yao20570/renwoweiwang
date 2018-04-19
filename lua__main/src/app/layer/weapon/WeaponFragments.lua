-- WeaponFragments.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-01 20:76:16 星期四
-- Description: 碎片图片和数量层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local WeaponUpgrade = require("app.layer.weapon.WeaponUpgrade")
local MImgLabel = require("app.common.button.MImgLabel")

local WeaponFragments = class("WeaponFragments", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WeaponFragments:ctor(_nId)
	-- body	
	self:myInit(_nId)	
	parseView("weapon_fragments", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function WeaponFragments:myInit(_nId)
	-- body		
	self.nWeaponId = _nId
end

--解析布局回调事件
function WeaponFragments:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("WeaponFragments",handler(self, self.onWeaponFragmentsDestroy))
end

--初始化控件
function WeaponFragments:setupViews()
	-- body
	self.pLayRoot = self:findViewByName("default")
	self.pLayBottom = self:findViewByName("lay_root")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayClock = self:findViewByName("lay_clock")
	self.pLayLeft = self:findViewByName("lay_left")
	self.pLayRight = self:findViewByName("lay_right")
	self.pLayPrice = self:findViewByName("lay_price")
	self.pLayCenter = self:findViewByName("lay_center")
	self.pTxtRequire = self:findViewByName("lb_require")
	self.pLayClock:setVisible(false)

	--神兵基础信息
	local tBaseData = Player:getWeaponInfo():getWeaponInfoById(self.nWeaponId)
	local data = {}
	--材料图标
	data.sIcon = tBaseData.sFraIcon
	data.sDes = tBaseData.sFragDesc
	data.sName = tBaseData.sName..getConvertedStr(7,10011)
	data.nQuality = tBaseData.nQuality
	data.nGtype = e_type_goods.type_item
	local tfragmentIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, data, TypeIconGoodsSize.M)
	self.tBaseData = tBaseData
end

--材料组合文本(消耗和拥有数)
function WeaponFragments:createMaterialGroupText(_parent, _img, _needNum, _hasNum, _anchor, pos)
	local tConTable = {}
	local pColor = _cc.blue
	if _needNum > _hasNum then
		pColor = _cc.red
	end
	local tLb= {
		{getResourcesStr(_hasNum) , getC3B(pColor)},
		{ "/".._needNum , getC3B(_cc.white)}
	}
	tConTable.tLabel = tLb
	tConTable.img = _img
	local pText =  createGroupText(tConTable)
	pText:setAnchorPoint(_anchor)
	_parent:addView(pText, 10)
	pText:setPosition(pos)
	pText:setViewTouched(true)
	return pText
end

--显示解锁条件
function WeaponFragments:showTxtRequire(_text)
	-- body
	self.pTxtRequire:setVisible(true)
	self.pTxtRequire:setString(_text)
	setTextCCColor(self.pTxtRequire, _cc.red)
end

--获取碎片和购买碎片按钮层
function WeaponFragments:buyFragmentsBtnLay(_nFragments, _nId)
	-- body
	self.nWeaponId = _nId
	local tBaseData = getBaseDataById(_nId)
	--神兵碎片列表(如果对应副本没有通关则不存在对应碎片)
	local tFragmentsList = Player:getWeaponInfo():getFragmentsList()
	if not tFragmentsList[_nId] then
		--副本关卡数据
		local tFbLvData = Player:getFuben():getLevelById(tBaseData.nOpenFb)
		--关卡名称
		local sLevelName = tFbLvData.sName
		--额外开启关卡数据
		local tFbExtraData = Player:getFuben():getLevelById(tFbLvData.nExtra)
		--副本章节数据
		local tFbChapterData = Player:getFuben():getSectionById(tFbLvData.nChapterid)
		--章节名称
		local sChapterName = tFbChapterData.sName
		self:showTxtRequire(getConvertedStr(7,10053)..sChapterName..sLevelName..getConvertedStr(7,10054)..tFbExtraData.sName)
		return
	end
	self.pTxtRequire:setVisible(false)
	if _nFragments > 0 then

		self.pBtnLeft = getCommonButtonOfContainer(self.pLayLeft, TypeCommonBtn.L_YELLOW, getConvertedStr(7,10013))
		self.pBtnRight = getCommonButtonOfContainer(self.pLayRight, TypeCommonBtn.L_BLUE, getConvertedStr(7,10012))

		self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
		self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))

		local nMoney = 0
		for nid, count in pairs(tBaseData.tCosts) do
			nMoney = count
		end
		--文本
		local tLb= {
			{nMoney, getC3B(_cc.white)},
		}
		--保存碎片单价
		self.nMoney = nMoney

		local tConTable = {}
		tConTable.tLabel = tLb
		tConTable.img = "#v1_img_qianbi.png"

		self.pBtnLeft:setBtnExText(tConTable)

	else
		self.pLayRight:setPosition(self.pLayCenter:getPosition())
		self.pBtnRight = getCommonButtonOfContainer(self.pLayRight, TypeCommonBtn.L_BLUE, getConvertedStr(7,10012))
		self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))
	end
	self.nJumpFbId = tBaseData.nJumpFb
end

--显示打造时间
function WeaponFragments:showCreateWeaponTime(_maketime)
	self.pLayClock:setVisible(true)
	self.pTxtTime = self:findViewByName("lb_time")
	self.pTxtTime:setString(formatTimeToHms(_maketime))
	setTextCCColor(self.pTxtTime, _cc.red)
end

--打造神兵按钮
function WeaponFragments:createWeaponBtn(_nWeaponId)
	-- body
	self.nWeaponId = _nWeaponId
	self.pBtnCenter = getCommonButtonOfContainer(self.pLayCenter, TypeCommonBtn.L_BLUE, getConvertedStr(7,10014))
	self.pBtnCenter:onCommonBtnClicked(handler(self, self.onCenterClicked))
end

-- 购买碎片按钮点击事件
function WeaponFragments:onLeftClicked(_pView)
	-- body
	-- local strTips = {
 --    	{color=_cc.pwhite,text=getConvertedStr(7, 10013)},--购买碎片
 --    }
	-- showBuyDlg( strTips, self.nMoney, handler(self, self.reqBuyFragments), 0, true)

	local tBaseData = Player:getWeaponInfo():getWeaponInfoById(self.nWeaponId)
	local data = {}
	--材料图标
	data.sIcon = tBaseData.sFraIcon
	data.sDes = tBaseData.sFragDesc
	data.sName = tBaseData.sName..getConvertedStr(7,10011)
	data.nQuality = tBaseData.nQuality
	data.nGtype = e_type_goods.type_item
	data.sTid = self.nWeaponId
	--购买消耗
	local tCost = {}
	tCost.k = e_resdata_ids.ybao    --黄金
	tCost.v = self.nMoney   		--单价

	local tObject = {}
	tObject.nType = e_dlg_index.buystuff --dlg类型
	tObject.tItemData = data
	tObject.tCost = tCost
	tObject.nMaxCnt = self.nNeedBuy
	tObject.sMsgType = "reqBuyFragments"
	sendMsg(ghd_show_dlg_by_type, tObject)
end
-- 获取碎片按钮点击事件
function WeaponFragments:onRightClicked(_pView)
	-- local tObject = {}
	-- tObject.tData = self.nJumpFbId --跳到副本章节id
	-- tObject.nType = e_dlg_index.fubenmap --dlg类型
	-- sendMsg(ghd_show_dlg_by_type,tObject)
	
	--跳到对应关卡战斗界面
	jumpToSpecialArmyLayer(self.nJumpFbId)
end
-- 打造神兵按钮点击事件
function WeaponFragments:onCenterClicked(pView)
	-- TOAST("打造神兵按钮")

	--发送打造请求
	SocketManager:sendMsg("reqBuildWeapon", {self.nWeaponId})

end

--请求购买神兵碎片
-- function WeaponFragments:reqBuyFragments()
-- 	-- body
-- 	--发送购买请求
-- 	SocketManager:sendMsg("reqBuyFragments", {self.nWeaponId})
-- end

-- 修改控件内容或者是刷新控件数据
function WeaponFragments:updateViews()
	
end

--打造所需材料
function WeaponFragments:onWeaponBuildMaterials(_nHasNum, _nTotalNum)
	-- body
	self.nNeedBuy = _nTotalNum - _nHasNum
	--材料数量组合文本
	local tConTable = {}
	local sColor = _cc.blue
	if _nHasNum < _nTotalNum then
		sColor = _cc.red
	end
	-- tConTable.tLabel = {
	-- 	{self.tBaseData.sName..getConvertedStr(7,10011), getC3B(_cc.white)},
	-- 	{_nHasNum, getC3B(sColor)},
	-- 	{"/".._nTotalNum, getC3B(_cc.white)},
	-- }
	-- local pText =  createGroupText(tConTable)
	-- pText:setAnchorPoint(0.5, 0.5)
	-- self.pLayBottom:addView(pText, 10)
	-- pText:setPosition(161, 148)

	if not self.lbFragments then
		self.lbFragments = MUI.MLabel.new({text = "", size = 20})
		self.pLayBottom:addView(self.lbFragments, 10)
		self.lbFragments:setPosition(154, 148)
	end
	local tStr = {
		{text = self.tBaseData.sName..getConvertedStr(7,10011), color = getC3B(_cc.pwhite)},
		{text = _nHasNum, color = getC3B(sColor)},
		{text = "/".._nTotalNum, color = getC3B(_cc.pwhite)}
	}
	self.lbFragments:setString(tStr)

	local tCost, tCostIcon, tGoods = {}, {}, {}
	local n = 0
	local tInitData = getWeaponInitData()
	for nId, value in pairs(tInitData.makeCosts) do
		local pGood = getGoodsByTidFromDB(nId)
		if pGood then
			table.insert(tCost, value, getMyGoodsCnt(nId))
			n = n + 1
			tGoods[n] = pGood
		end
		table.insert(tCostIcon, getItemResourceData(nId).sIcon)
	end
	local i = 0
	for need, has in pairs(tCost) do
		i = i + 1
		if i == 1 then
			local pLayCost1 = self:createMaterialGroupText(self.pLayBottom, tCostIcon[i], need, has,
				cc.p(0,0.5), cc.p(360,235))
			--点击打开物品提示
			pLayCost1:onMViewClicked(function()
				openIconInfoDlg(pLayCost1, tGoods[1])
			end)
		elseif i == 2 then
			local pLayCost2 = self:createMaterialGroupText(self.pLayBottom, tCostIcon[i], need, has,
				cc.p(0,0.5), cc.p(360,178))
			pLayCost2:onMViewClicked(function()
				openIconInfoDlg(pLayCost2, tGoods[2])
			end)
		end
	end
end

-- 析构方法
function WeaponFragments:onWeaponFragmentsDestroy()
	-- body
end

function WeaponFragments:setItemIndex(_index)
	self.nIndex = _index
	self:updateViews()
end


return WeaponFragments
