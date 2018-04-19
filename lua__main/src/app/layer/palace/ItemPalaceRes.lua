-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-04-18 15:12:23 星期二
-- Description: 王宫界面资源项 王宫界面 
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local DlgResOutput = require("app.module.DlgResOutput")

local ItemPalaceRes = class("ItemPalaceRes", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_buildid 资源建筑ID
function ItemPalaceRes:ctor(_buildid)
	-- body
	self:myInit(_buildid)

	parseView("item_respanel", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemPalaceRes",handler(self, self.onItemPalaceResDestroy))
	
end

--初始化参数
function ItemPalaceRes:myInit(index)
	-- body
	local tIdx = {e_resdata_ids.yb,e_resdata_ids.mc,e_resdata_ids.lc, e_resdata_ids.bt}
	self.nResId = tIdx[index] or nil
	self.nIdx = index
	self.pData = {} --资源数据
end

--解析布局回调事件
function ItemPalaceRes:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemPalaceRes:setupViews( )

	--ly
	self.pLyKuang=  self:findViewByName("lay_kuang")--头像层                  	
	self.pLyRules =  self:findViewByName("img_rules")--规则按钮层 
	self.pLyPlus =  self:findViewByName("img_plus")--添加按钮层
	--lb
	self.pLbName = self:findViewByName("lb_name")--资源名称
	self.pLbName:setString(getConvertedStr(6, 10107))
	setTextCCColor(self.pLbName, _cc.blue)

	self.pLbValue = self:findViewByName("lb_value")	
	-- --小时产量
	-- self.pLbHourlyOutput = self:findViewByName("lb_hourly_output")
	-- self.pLbHourlyOutput:setString(getConvertedStr(6, 10089))
	-- setTextCCColor(self.pLbHourlyOutput, _cc.pwhite)

	-- --固产量
	-- self.pLbOutputValue = self:findViewByName("lb_output_value")
	-- self.pLbOutputValue:setString("", false)
	-- setTextCCColor(self.pLbOutputValue, _cc.blue)

	-- --增益值
	-- self.pLbValuePlus = self:findViewByName("lb_value_plus")
	-- self.pLbValuePlus:setString("", false)
	-- setTextCCColor(self.pLbValuePlus, _cc.green)

	--touxiang
	self.pIconRes = getIconGoodsByType(self.pLyKuang, TypeIconGoods.NORMAL, type_icongoods_show.item, data, TypeIconGoodsSize.M)
	self.pIconRes:setIconIsCanTouched(false)
	
	--按钮
	self.pLyRules:onMViewClicked(handler(self, self.onRulesBtnClicked))
	self.pLyRules:setViewTouched(true)
	self.pLyPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))
	self.pLyPlus:setViewTouched(true)
end

-- 修改控件内容或者是刷新控件数据
function ItemPalaceRes:updateViews(  )
	-- body	
	local resourceData = Player:getResourceData()
	if resourceData then
		local nbaseoutput = 0 --基础产量
		local nalloutput = 0 --总产量
		local nplusoutput = 0 --加成产量
		local nresId = nil
		if self.nResId == e_resdata_ids.yb then--房子崔颖资源coin
			self.pLbName:setString(getConvertedStr(6, 10107))
			tbaseoutput = resourceData.tBase.coin or 0
			nalloutput = resourceData.tAll.coin or 0 
		elseif self.nResId == e_resdata_ids.mc then --木材
			self.pLbName:setString(getConvertedStr(6, 10153))
			tbaseoutput = resourceData.tBase.wood or 0
			nalloutput = resourceData.tAll.wood or 0
		elseif self.nResId == e_resdata_ids.lc then --粮食
			self.pLbName:setString(getConvertedStr(6, 10154))
			tbaseoutput = resourceData.tBase.food or 0
			nalloutput = resourceData.tAll.food or 0
		elseif self.nResId == e_resdata_ids.bt then --铁矿
			self.pLbName:setString(getConvertedStr(6, 10155))
			tbaseoutput = resourceData.tBase.iron or 0
			nalloutput = resourceData.tAll.iron or 0
		end
		nplusoutput = nalloutput - tbaseoutput
		local sbase = ""
		if tbaseoutput > 0 then
			sbase = tbaseoutput
		end
		local splus = ""
		if nplusoutput > 0 then
			splus = "+"..getResourcesStr(nplusoutput)
		end
		local str = {
			{color=_cc.pwhite, text= getConvertedStr(6, 10089)},
			{color=_cc.blue, text=getResourcesStr(tbaseoutput or "")},
			{color=_cc.green,text=splus}			
		}
		self.pLbValue:setString(str, false)
		-- self.pLbOutputValue:setString(tbaseoutput, false)
		-- self.pLbOutputValue:setVisible(tbaseoutput ~= 0)
		-- self.pLbValuePlus:setString("+"..nplusoutput, false)
		-- self.pLbValuePlus:setVisible(nplusoutput ~= 0)

		local tresdata = getItemResourceData(self.nResId)
		if tresdata then
			self.pIconRes:setCurData(tresdata)
			setLbTextColorByQuality(self.pLbName, tresdata.nQuality)
			setBgQuality(self.pIconRes.pLayBgQuality, tresdata.nQuality)	
		end
	end

end

--析构方法
function ItemPalaceRes:onItemPalaceResDestroy(  )
	-- body	
end

--设置规则按钮回调事件
function ItemPalaceRes:onRulesBtnClicked( pView )
	-- body
	local pDlg, bNew = getDlgByType(e_dlg_index.resoutput)
    if not pDlg then
    	pDlg = DlgResOutput.new(self.nResId)        
    end 
    pDlg:showDlg(bNew)
end

--设置获取资源按钮回调事件
function ItemPalaceRes:onPlusBtnClicked( pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.getresource --dlg类型
	tObject.nIndex = self.nIdx
	sendMsg(ghd_show_dlg_by_type,tObject)
end

return ItemPalaceRes