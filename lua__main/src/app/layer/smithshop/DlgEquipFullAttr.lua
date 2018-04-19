-- DlgEquipFullAttr.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-23 17:01:23 星期五
-- Description: 满属性装备信息
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemRefineAttr = require("app.layer.refineshop.ItemRefineAttr")

local DlgEquipFullAttr = class("DlgEquipFullAttr", function ()
	return DlgCommon.new(e_dlg_index.dlgequipfullattr)
end)

--构造
function DlgEquipFullAttr:ctor(_uuid)
	-- body
	self:myInit(_uuid)
	parseView("dlg_equip_fullattr", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgEquipFullAttr:myInit(_uuid)
	-- body
	self.sUuid = _uuid               -- 装备的uuid
end

--解析布局回调事件
function DlgEquipFullAttr:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, false) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgEquipFullAttr",handler(self, self.onDlgEquipFullAttrDestroy))
end

--初始化控件
function DlgEquipFullAttr:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(7,10062))

	self.pLayRoot                  =         self:findViewByName("default")

	--装备图标层
	self.pLayEquipIcon             =         self:findViewByName("lay_equipicon")

	--隐藏属性图标层
	self.pLayAttrIcon1             =         self:findViewByName("lay_attricon1")
	self.pLayAttrIcon2             =         self:findViewByName("lay_attricon2")
	self.pLayAttrIcon3             =         self:findViewByName("lay_attricon3")
	self.pLayAttrIcon4             =         self:findViewByName("lay_attricon4")
end

function DlgEquipFullAttr:updateViews()
	-- body
	local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
	local tCfgData = tEquipVo:getConfigData()
	local pEquipIcon = getIconGoodsByType(self.pLayEquipIcon,TypeIconGoods.HADMORE,type_icongoods_show.item, tCfgData, TypeIconGoodsSize.L)
	local sAttrs = tCfgData.sAttrs
	local tAttrs = luaSplit(sAttrs, ":")
	local nAttrId = tonumber(tAttrs[1])
	local nAttrValue = tonumber(tAttrs[2])
	if nAttrId and nAttrValue then
		local tAttData = getBaseAttData(nAttrId)
		if tAttData then
			-- local tConTable = self:createTextTableTip(tAttData.sName, nAttrValue, _cc.blue)
			local tLb = {
				{text = tAttData.sName, color = getC3B(_cc.pwhite)},
				{text = nAttrValue, color = getC3B(_cc.blue)},
			}
			pEquipIcon:setBottomRichText(tLb)
		end
	end

	local tAttrsList = tEquipVo:getTrainAtbVos()

	--装备属性框
	self.pAttrIcon1 = ItemRefineAttr.new(1)
	self.pAttrIcon1:setPosition(60, 92)
	self.pLayRoot:addView(self.pAttrIcon1)

	self.pAttrIcon2 = ItemRefineAttr.new(2)
	self.pAttrIcon2:setPosition(180, 92)
	self.pLayRoot:addView(self.pAttrIcon2)

	self.pAttrIcon3 = ItemRefineAttr.new(3)
	self.pAttrIcon3:setPosition(300, 92)
	self.pLayRoot:addView(self.pAttrIcon3)

	self.pAttrIcon4 = ItemRefineAttr.new(4)
	self.pAttrIcon4:setPosition(420, 92)
	self.pLayRoot:addView(self.pAttrIcon4)

	if #tAttrsList == 1 then
		self.pAttrIcon4:setPosition(240, 92)
		self.pAttrIcon4:setData(tAttrsList[1])
		self.pAttrIcon1:setVisible(false)
		self.pAttrIcon2:setVisible(false)
		self.pAttrIcon3:setVisible(false)
	elseif #tAttrsList == 2 then
		self.pAttrIcon2:setVisible(false)
		self.pAttrIcon3:setVisible(false)
		self.pAttrIcon1:setPosition(180, 92)
		self.pAttrIcon1:setData(tAttrsList[1])
		self.pAttrIcon4:setPosition(300, 92)
		self.pAttrIcon4:setData(tAttrsList[2])
	elseif #tAttrsList == 3 then
		self.pAttrIcon3:setVisible(false)
		self.pAttrIcon1:setPosition(120, 92)
		self.pAttrIcon1:setData(tAttrsList[1])
		self.pAttrIcon2:setPosition(240, 92)
		self.pAttrIcon2:setData(tAttrsList[2])
		self.pAttrIcon4:setPosition(360, 92)
		self.pAttrIcon4:setData(tAttrsList[3])
	elseif #tAttrsList == 4 then
		self.pAttrIcon1:setData(tAttrsList[1])
		self.pAttrIcon2:setData(tAttrsList[2])
		self.pAttrIcon3:setData(tAttrsList[3])
		self.pAttrIcon4:setData(tAttrsList[4])
	end
	
end

--属性和属性值组合文本
function DlgEquipFullAttr:createTextTableTip(_content1, _content2, _color)
	-- body
	-- local tConTableTip = {}
	-- tConTableTip.tLabel = {
	-- 	{_content1, getC3B(_cc.white)},
	-- 	{_content2, getC3B(_color)},
	-- }
	-- local pTextAttr = createGroupText(tConTableTip)
	-- pTextAttr:setAnchorPoint(0.5, 0.5)
	-- self.pLayRoot:addView(pTextAttr, 10)
	-- pTextAttr:setPosition(_pos)
	-- return pTextAttr

	local tConTable = {}
	local tLb = {
		{_content1, getC3B(_cc.pwhite)},
		{_content2, getC3B(_color)},
	}
	tConTable.tLabel = tLb
	return tConTable
end

--星星和文字组合文本
-- function DlgEquipFullAttr:createImgGroupText(_img, _text, _color, pos)
-- 	local tConTable = {}

-- 	local tLb = {
-- 		{_text, getC3B(_color)},
-- 	}
-- 	tConTable.tLabel = tLb
-- 	tConTable.img = _img
-- 	local pText =  createGroupText(tConTable)
-- 	pText:setAnchorPoint(cc.p(0.5, 0.5))
-- 	self.pLayRoot:addView(pText, 10)
-- 	pText:setPosition(pos)
-- 	return pText
-- end

-- 析构方法
function DlgEquipFullAttr:onDlgEquipFullAttrDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgEquipFullAttr:regMsgs(  )
	-- body
end
--注销消息
function DlgEquipFullAttr:unregMsgs(  )
	-- body	
end

-- 暂停方法
function DlgEquipFullAttr:onPause()
	self:unregMsgs()	
end

--继续方法
function DlgEquipFullAttr:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgEquipFullAttr