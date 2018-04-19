-- WeaponRow.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-31 15:30:30 星期三
-- Description: 神兵列表每行层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local WeaponItem = require("app.layer.weapon.WeaponItem")

local WeaponRow = class("WeaponRow", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WeaponRow:ctor()
	-- body	
	self:myInit()	
	parseView("weapon_row", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function WeaponRow:myInit()
	-- body		
	self.nIndex 			= 	nIndex or 1
	self.tCurData 			= 	nil 				--当前数据
end

--解析布局回调事件
function WeaponRow:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("WeaponRow",handler(self, self.onWeaponRowDestroy))
end

--初始化控件
function WeaponRow:setupViews()
	-- body
	self.pLayRoot = self:findViewByName("default")
	self.pLayleft = self:findViewByName("lay_left")
	self.pLayRight = self:findViewByName("lay_right")
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
end

-- 修改控件内容或者是刷新控件数据
function WeaponRow:updateViews()
	if not self.leftItem then
    	self.leftItem = self:createWeaponItem(self.nIndex * 2 - 1)
		self.pLayleft:addView(self.leftItem)
    end
    if not self.rightItem then
		self.rightItem = self:createWeaponItem(self.nIndex * 2)
		self.pLayRight:addView(self.rightItem)
	end
    self.leftItem:setItemIndex(self.nIndex * 2 - 1)
    self.rightItem:setItemIndex(self.nIndex * 2)
end

-- 析构方法
function WeaponRow:onWeaponRowDestroy()
	-- body
end

function WeaponRow:setRowIndex(_index)
	self.nIndex = _index
	self:updateViews()
end

-- 创建左右两个单项
function WeaponRow:createWeaponItem(_index)
	-- body
	local pTempView = WeaponItem.new()               
    pTempView:setViewTouched(true)
	pTempView:onMViewClicked(function ()
	    local tObject = {}
		tObject.nType = e_dlg_index.dlgweaponinfo --dlg类型
		tObject.nIndex = _index
		sendMsg(ghd_show_dlg_by_type,tObject)
		--新手教程点击
		Player:getNewGuideMgr():onClickedNewGuideFinger(pTempView)
    end)
    return pTempView
end

return WeaponRow
