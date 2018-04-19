
-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-10 14:31:23 星期三
-- Description: 选择项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemSelect = class("ItemSelect", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

 
--_type 选中方式
function ItemSelect:ctor(_type)
	-- body
	self:myInit(_type)

	parseView("item_select", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemSelect",handler(self, self.onItemSelectDestroy))
	--
end

--初始化参数
function ItemSelect:myInit(_type)
	-- body
	self.nSelectedType = _type or ItemSelect_Select_Type.Bg
	self._isSelected = false
	self._defimgbg = "#v1_img_selected.png"
	self.tCurData = nil
end

--解析布局回调事件
function ItemSelect:onParseViewCallback( pView )	
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemSelect:setupViews( )
	-- body
	--root
	self.pLayRoot = self:findViewByName("root")
	self:setViewTouched(true)--可以点击
	--icon
	self.pLayIcon = self:findViewByName("lay_icon")

	--提示标签
	self.pLbTip = self:findViewByName("lb_tip")
	setTextCCColor(self.pLbTip, _cc.red)
	--name
	self.pLbName = self:findViewByName("lb_name")	
	--img框
	self.pImgGXK = self:findViewByName("img_gxk")
	if self.nSelectedType == ItemSelect_Select_Type.Bg then
		self.pIcon = getIconHeroByType(self.pLayIcon, TypeIconGoods.NORMAL, nil)
	elseif  self.nSelectedType ==  ItemSelect_Select_Type.Gou then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, nil)
	end
		-- self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, nil)
	
	
	self.pIcon:setIconIsCanTouched(false)
	self:unselected()
end

-- 修改控件内容或者是刷新控件数据
function ItemSelect:updateViews(  )
	-- body
	if self.tCurData then
		self.pIcon:setCurData(self.tCurData)
		if self.nSelectedType ==  ItemSelect_Select_Type.Gou then
			if self.tCurData.nCt > 0 then
				self.pIcon:setNumberColor(_cc.white)
			else
				self.pIcon:setNumberColor(_cc.red)
			end
		end
		self.pLbName:setString(self.tCurData.sName)
		setTextCCColor(self.pLbName, getColorByQuality(self.tCurData.nQuality))				
		local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
		if self.tCurData.nLimitLv then
			if atelierData.nLv >= self.tCurData.nLimitLv then
				self:setIsLocked(false)
			else
				self:setIsLocked(true)
				self.pLbTip:setString(getConvertedStr(6, 10176)..self.tCurData.nLimitLv..getConvertedStr(6, 10434))
			end
		else
			self:setIsLocked(false)
		end
	end
end

--析构方法
function ItemSelect:onItemSelectDestroy(  )
	-- body
end
--选中
function ItemSelect:selected( )	
	-- body
	if self.nSelectedType == ItemSelect_Select_Type.Bg then
		self.pIcon:setIconSelected(true,true)
		self.pImgGXK:setVisible(false)
	elseif self.nSelectedType == ItemSelect_Select_Type.Gou then
		self.pImgGXK:setVisible(true)
		self.pImgGXK:setCurrentImage("#v2_img_gouxuan.png")
	end		
	self._isSelected = true	
end
--取消选中
function ItemSelect:unselected( )
	-- body

	if self.nSelectedType == ItemSelect_Select_Type.Bg then
		self.pIcon:setIconSelected(false)		
		self.pImgGXK:setVisible(false)
	elseif self.nSelectedType == ItemSelect_Select_Type.Gou then
		self.pImgGXK:setVisible(true)
		self.pImgGXK:setCurrentImage("#v2_img_gouxuankuang.png")
	end		
	self._isSelected = false	
end
--判断是否选中
function ItemSelect:isSelected( )
	-- body
	return self._isSelected
end

--设置物品数据
function ItemSelect:setCurData( _data )
	-- body
	if _data then
		self.tCurData = _data		
		self:updateViews()
	end
end

--设置为锁定状态
function ItemSelect:setIsLocked(_blocked)
	-- body
	if self.nSelectedType == ItemSelect_Select_Type.Bg then
		if _blocked == true then
			self.pIcon:setLockedState()
			self.pLbTip:setVisible(true)
			self:setViewTouched(false)
		else
			self.pIcon:setNormalState()
			self.pLbTip:setVisible(false)
			self:setViewTouched(true)
		end
	end

end
return ItemSelect