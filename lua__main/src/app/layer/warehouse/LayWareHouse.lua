-- LayWareHouse.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-12 17:23:55 星期一
-- Description: 仓库层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemWareMaterial = require("app.layer.warehouse.ItemWareMaterial")

local LayWareHouse = class("LayWareHouse", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)
--_data：当前科技数据
function LayWareHouse:ctor( _tSize )
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_warehouse", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function LayWareHouse:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
end

--解析布局回调事件
function LayWareHouse:onParseViewCallback( pView )
	-- body
	-- self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("LayWareHouse",handler(self, self.onLayWareHouseDestroy))
end

--初始化控件
function LayWareHouse:setupViews( )
	-- body
	--资源信息层
	self.pLyResInfo = self:findViewByName("lay_resinfo")
	self.pLayIcon = self:findViewByName("lay_iconll")	
	local data = getBaseItemDataByID(e_item_ids.gjcj)
	--dump(data, "data=", 100)		
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, data, TypeIconGoodsSize.L)
	self.pIcon:setIconIsCanTouched(false)
	--物品名字
	self.pLbItemName = self:findViewByName("lb_item_name")
	setTextCCColor(self.pLbItemName, _cc.blue)
	self.pLbItemName:setString(getConvertedStr(6, 10121))
	--物品剩余数量
	self.pLbItemNum = self:findViewByName("lb_item_num")
	setTextCCColor(self.pLbItemNum, _cc.blue)
	self.pLbItemNum:setString(getConvertedStr(6, 10120))
	--物品说明
	self.pLbExplain	= self:findViewByName("lb_explain")
	setTextCCColor(self.pLbExplain, _cc.gray)
	self.pLbExplain:setString(getConvertedStr(6, 10119))
end


-- 修改控件内容或者是刷新控件数据
function LayWareHouse:updateViews(  )
	-- body
	--重建家园道具数量数显刷新
	self:updateRebuildItem()
	self.tItemMaterial = self.tItemMaterial or {}
	for i = 1, 4 do
		if(not self.tItemMaterial[i]) then
			local item = ItemWareMaterial.new(i)
			self.pLyResInfo:addView(item, 10)
			item:setPosition(0, 336 - 111*(i - 1))
			self.tItemMaterial[i] = item
			-- ActionIn(item, "top", 0.35)
		end
		self.tItemMaterial[i]:updateViews()
	end
end

--刷新高级城建刷新
function LayWareHouse:updateRebuildItem(  )
	-- body
	--重建家园道具数量数显刷新
	local hrebuilditem = Player:getBagInfo():getItemDataById(e_item_ids.gjcj) or getBaseItemDataByID(e_item_ids.gjcj)
	if hrebuilditem then
		--dump(hrebuilditem, "hrebuilditem=", 100)
		self.pLbItemName:setString(hrebuilditem.sName)--物品名称
		self.pLbItemNum:setString(getConvertedStr(6, 10174)..hrebuilditem.nCt..getConvertedStr(6, 10175)) --物品数量
		self.pLbExplain:setString(hrebuilditem.sDes)--物品描述
		self.pIcon:setCurData(hrebuilditem)
	end		
end


-- 析构方法
function LayWareHouse:onLayWareHouseDestroy(  )
	-- body
end

--设置当前数据
function LayWareHouse:setData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end


return LayWareHouse