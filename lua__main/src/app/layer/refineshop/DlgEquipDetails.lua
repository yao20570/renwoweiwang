-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-10-10 14:07:23 星期三
-- Description: 装备分享界面	
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemRefineAttr = require("app.layer.refineshop.ItemRefineAttr")
local DlgEquipDetails = class("DlgEquipDetails", function()
	-- body
	return DlgCommon.new(e_dlg_index.equipdetails)
end)

function DlgEquipDetails:ctor(_EquipData)
	-- body
	self:myInit(_EquipData)
	parseView("dlg_equip_details", handler(self, self.onParseViewCallback))
end

function DlgEquipDetails:myInit( _EquipData )
	-- body
	self.pEquipData = _EquipData
end

--解析布局回调事件
function DlgEquipDetails:onParseViewCallback( pView )
	-- body
	self:setTitle(getConvertedStr(7, 10062))
	self:addContentView(pView) --加入内容层
	--self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgEquipDetails",handler(self, self.onDlgEquipDetailsDestroy))
end

--控件刷新
function DlgEquipDetails:updateViews(  )
	-- body	
	if not self.pLayDef then
		self.pLayDef = self:findViewByName("lay_default")
		self.pLayEquip = self:findViewByName("lay_equip")
		self.pLayAttrs = self:findViewByName("lay_attrs")
		self.tIconAttr = {}
	end
	-- dump(self.pEquipData, "self.pEquipData", 199)
	local tEquipData = getBaseEquipDataByID(self.pEquipData.nId)
	local pIcon = getIconGoodsByType(self.pLayEquip, TypeIconGoods.HADMORE, type_icongoods_show.item, tEquipData)
	if pIcon then
		local sAttrs = tEquipData.sAttrs
		local tAttrs = luaSplit(sAttrs, ":")
		local nAttrId = tonumber(tAttrs[1])
		local nAttrValue = self.pEquipData:getAttrValue() --tonumber(tAttrs[2])
		if nAttrId and nAttrValue then
			local tAttData = getBaseAttData(nAttrId)
			if tAttData then
				local tLb = {
					{text = tAttData.sName, color = getC3B(_cc.pwhite)},
					{text = "+"..nAttrValue, color = getC3B(_cc.blue)},
				}
				pIcon:setBottomRichText(tLb)
			end
		end
		local nStrenthLv = self.pEquipData:getEquipStrenthLv()
		if nStrenthLv > 0 then
			pIcon:showLeftTopLayer("+"..nStrenthLv)
		else
			pIcon:removeLeftTopLayer()
		end
	end
	local tTrainAtbVos = self.pEquipData:getTrainAtbVos()
	-- local tTrainAtbVos = self.pEquipData.tTrainAtbVos
	local nDis = 40
	local nAttr = #tTrainAtbVos
	local nStart = (self.pLayAttrs:getWidth() - (nAttr - 1)*nDis - nAttr*90)/2
	for i = 1, nAttr do
		local pItemRefineAttr = ItemRefineAttr.new(i)
		pItemRefineAttr:setPosition(nStart + (i - 1)*(nDis + 90), 60)
		self.pLayAttrs:addView(pItemRefineAttr)
		pItemRefineAttr:setData(tTrainAtbVos[i], false)
	end
end

--析构方法
function DlgEquipDetails:onDlgEquipDetailsDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgEquipDetails:regMsgs(  )
	-- body
end
--注销消息
function DlgEquipDetails:unregMsgs(  )
	-- body
end

--暂停方法
function DlgEquipDetails:onPause( )
	-- body		
	self:unregMsgs()
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgEquipDetails:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end



return DlgEquipDetails