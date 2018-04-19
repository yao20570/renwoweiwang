-- Author: maheng
-- Date: 2017-04-21 11:56:24
-- 资源产量


local DlgCommon = require("app.common.dialog.DlgCommon")

local DlgResOutput = class("DlgResOutput", function ()
	return DlgCommon.new(e_dlg_index.resoutput)
end)

--构造
function DlgResOutput:ctor(_ResId)
	-- body
	self:myInit(_ResId)	
	parseView("dlg_resoutput", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgResOutput:myInit(_ResId)
	-- body
	self.nResId = _ResId or e_resdata_ids.yb--对应资源建筑ID
	self._pdata = {} --资源数据	
end
  
--解析布局回调事件
function DlgResOutput:onParseViewCallback( pView )
	-- body
	self:addContentView(pView,true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgResOutput",handler(self, self.onDlgResOutputDestroy))
end

--初始化控件
function DlgResOutput:setupViews()
	-- body

	-- 资源项层
	self.pLayresitem = self:findViewByName("lay_resitem")
	--头像框
	self.pLayIcon = self:findViewByName("lay_icon")	
	--名字
	self.pLbResName = self:findViewByName("lb_res_name")
	self.pLbResName:setString(getConvertedStr(6, 10107))
	setTextCCColor(self.pLbResName, _cc.yellow)

	--小时产出标签
	self.pLbhourlyoutput = self:findViewByName("lb_hourly_output")
	self.pLbhourlyoutput:setString(getConvertedStr(6, 10089))
	setTextCCColor(self.pLbhourlyoutput, _cc.pwhite)
	--产值
	self.pLbValue = self:findViewByName("lb_value")
	setTextCCColor(self.pLbValue, _cc.blue)
	self.pLbValue:setString(getConvertedStr(6, 10162), false)
	--增益值
	self.pLbPlusValue = self:findViewByName("lb_plusvalue")
	setTextCCColor(self.pLbPlusValue, _cc.green)
	self.pLbPlusValue:setString(getConvertedStr(6, 10162), false)
	--添加按钮层
	self.pLayBtnPlus = self:findViewByName("lay_btn_plus")
	self.pBtnPlus = getSepButtonOfContainer(self.pLayBtnPlus, TypeSepBtn.PLUS_VIEW)
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))
	--资源详细数据标题层
	self.pLayItemTitle = self:findViewByName("ly_item_title")
	--标题
	self.pLbItemTitle = self:findViewByName("lb_itemtitle")
	self.pLbItemTitle:setString(getConvertedStr(6, 10519))
	--详细数据层
	self.pLayItemInfo = self:findViewByName("lay_item_info")
	--按钮层
	self.pLayBtn = self:findViewByName("lay_btn")
	--确定按钮
	self.pBtnBottom = self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(6, 10106))
	-- self.pBtnBottom = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10106))
	self.pBtnBottom:onCommonBtnClicked(handler(self, self.onSureBtnClicked))
	--
	local defstr = getConvertedStr(6, 10162)
	local itemdatas = { --标签信息
		{getConvertedStr(6, 10156),defstr},--基础产量：
		{getConvertedStr(6, 10157),defstr},--科技加成：
		{getConvertedStr(6, 10158),defstr},--季节加成：
		{getConvertedStr(6, 10159),defstr},--活动加成：
		{getConvertedStr(6, 10160),defstr},--内政官加成：
		{getConvertedStr(6, 10161),defstr} --总产量：
	}
	--详细产量数据标签组
	self.pItems = {}
	local x = 0
	local y = 0
	for i = 1, 6 do
		local label1 = MUI.MLabel.new({
			text = itemdatas[i][1],
			size = 20,
			anchorpoint=cc.p(1, 0.5)
		})
		
		local label2 = MUI.MLabel.new({
			text = itemdatas[i][2],
			size = 20,
			anchorpoint=cc.p(0, 0.5)
		})			

		if i%2 == 1 then
			x = 155
		else
			x = 421
		end
		local cul = math.ceil(i/2)
		y = 117 - (cul - 1)*40
		label1:setPosition(x, y)
		setTextCCColor(label1, _cc.pwhite)
		label2:setPosition(x, y)
		setTextCCColor(label2, _cc.green)
		self.pLayItemInfo:addView(label1, 10)
		self.pLayItemInfo:addView(label2, 10)
		self.pItems[i] = {label1, label2}
	end
	setTextCCColor(self.pItems[1][2], _cc.blue)
	setTextCCColor(self.pItems[6][2], _cc.blue)
end

-- 修改控件内容或者是刷新控件数据
function DlgResOutput:updateViews()
	-- body	
	local resourceData = Player:getResourceData()
	if not resourceData then
		return
	end
	local nbaseoutput = 0 --基础产量
	local nalloutput = 0 --总产量
	local nplusoutput = 0 --加成产量
	if self.nResId == e_resdata_ids.yb then--房子崔颖资源coin
		self.pLbResName:setString(getConvertedStr(6, 10107))
		--设置标题
		self:setTitle(getConvertedStr(6, 10107)..getConvertedStr(6,10478))
		tbaseoutput = resourceData.tBase.coin or 0
		nalloutput = resourceData.tAll.coin or 0
		self:setLabelValue(self.pItems[1][2], resourceData.tBase.coin)
		self:setLabelValue(self.pItems[2][2], resourceData.tScience.coin)
		self:setLabelValue(self.pItems[3][2], resourceData.tSeason.coin)
		self:setLabelValue(self.pItems[4][2], resourceData.tAcitvity.coin)
		self:setLabelValue(self.pItems[5][2], resourceData.tOfficer.coin)
		self:setLabelValue(self.pItems[6][2], resourceData.tAll.coin)
	elseif self.nResId == e_resdata_ids.mc then --木材
		self.pLbResName:setString(getConvertedStr(6, 10153))
		self:setTitle(getConvertedStr(6, 10153)..getConvertedStr(6,10478))
		tbaseoutput = resourceData.tBase.wood or 0
		nalloutput = resourceData.tAll.wood or 0	
		self:setLabelValue(self.pItems[1][2], resourceData.tBase.wood)
		self:setLabelValue(self.pItems[2][2], resourceData.tScience.wood)
		self:setLabelValue(self.pItems[3][2], resourceData.tSeason.wood)
		self:setLabelValue(self.pItems[4][2], resourceData.tAcitvity.wood)
		self:setLabelValue(self.pItems[5][2], resourceData.tOfficer.wood)
		self:setLabelValue(self.pItems[6][2], resourceData.tAll.wood)	
	elseif self.nResId == e_resdata_ids.lc then --粮食
		self.pLbResName:setString(getConvertedStr(6, 10154))
		self:setTitle(getConvertedStr(6, 10154)..getConvertedStr(6,10478))
		tbaseoutput = resourceData.tBase.food or 0
		nalloutput = resourceData.tAll.food or 0
		self:setLabelValue(self.pItems[1][2], resourceData.tBase.food)
		self:setLabelValue(self.pItems[2][2], resourceData.tScience.food)
		self:setLabelValue(self.pItems[3][2], resourceData.tSeason.food)
		self:setLabelValue(self.pItems[4][2], resourceData.tAcitvity.food)
		self:setLabelValue(self.pItems[5][2], resourceData.tOfficer.food)
		self:setLabelValue(self.pItems[6][2], resourceData.tAll.food)	
	elseif self.nResId == e_resdata_ids.bt then --铁矿
		self.pLbResName:setString(getConvertedStr(6, 10155))
		self:setTitle(getConvertedStr(6, 10155)..getConvertedStr(6,10478))
		tbaseoutput = resourceData.tBase.iron or 0
		nalloutput = resourceData.tAll.iron or 0
		self:setLabelValue(self.pItems[1][2], resourceData.tBase.iron)
		self:setLabelValue(self.pItems[2][2], resourceData.tScience.iron)
		self:setLabelValue(self.pItems[3][2], resourceData.tSeason.iron)
		self:setLabelValue(self.pItems[4][2], resourceData.tAcitvity.iron)
		self:setLabelValue(self.pItems[5][2], resourceData.tOfficer.iron)
		self:setLabelValue(self.pItems[6][2], resourceData.tAll.iron)	
	end
	nplusoutput = nalloutput - tbaseoutput
	self.pLbValue:setVisible(tbaseoutput ~= 0)
	self.pLbValue:setString(getResourcesStr(tbaseoutput), false)
	self.pLbPlusValue:setVisible(nplusoutput ~= 0)
	self.pLbPlusValue:setString("+"..getResourcesStr(nplusoutput), false)		
	self.pLbPlusValue:setPositionX(self.pLbValue:getPositionX() + self.pLbValue:getWidth() + self.pLbPlusValue:getWidth()/2)
	local tresdata = getItemResourceData(self.nResId)	
	if tresdata then
		getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tresdata, TypeIconGoodsSize.L)		
		setLbTextColorByQuality(self.pLbResName, tresdata.nQuality)
	end		
end

--析构方法
function DlgResOutput:onDlgResOutputDestroy()
	self:onPause()
end

-- 注册消息
function DlgResOutput:regMsgs( )
	-- body
	regMsg(self, gud_refresh_palace_resource, handler(self, self.updateViews))
end

-- 注销消息
function DlgResOutput:unregMsgs(  )
	-- body
	--注销王宫界面资源数据刷新	
	unregMsg(self, gud_refresh_palace_resource)	
end


--暂停方法
function DlgResOutput:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgResOutput:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--增加按钮回调
function DlgResOutput:onPlusBtnClicked( pView )
	-- body	
	local tObject = {}
	tObject.nType = e_dlg_index.getresource --dlg类型
	tObject.nIndex = 1
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--确定按钮回调
function  DlgResOutput:onSureBtnClicked( pView )
	-- body
	self:closeCommonDlg()
end

--设置数值标签的数值 仅仅本类中的item组的数值标签
function DlgResOutput:setLabelValue( _plabel, _svalue )
	-- body
	if not _plabel then
		return
	end
	local svalur = tonumber(_svalue)
	if svalur and svalur > 0 then--数值小于等于0 的时候设置为默认 "_"
		_plabel:setString(getResourcesStr(svalur))
	else				
		_plabel:setString(getConvertedStr(6, 10162))
	end
end
return DlgResOutput
