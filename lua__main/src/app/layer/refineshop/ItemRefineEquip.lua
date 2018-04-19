----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-02 09:42:53
-- Description: 洗炼铺 装备
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemRefineEquip = class("ItemRefineEquip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nKind 类型
function ItemRefineEquip:ctor( nKind )
	self.nKind = nKind
	--解析文件
	parseView("item_refine_equip", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemRefineEquip:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemRefineEquip", handler(self, self.onItemRefineEquipDestroy))
end

-- 析构方法
function ItemRefineEquip:onItemRefineEquipDestroy(  )
    self:onPause()
end

function ItemRefineEquip:regMsgs(  )
end

function ItemRefineEquip:unregMsgs(  )
end

function ItemRefineEquip:onResume(  )
	self:regMsgs()
end

function ItemRefineEquip:onPause(  )
	self:unregMsgs()
end

function ItemRefineEquip:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLayIcon:setPositionY(self.pLayIcon:getPositionY() - 20)

	self.pLayNull = self:findViewByName("lay_null")
	self.pLayNull:setViewTouched(true)
	self.pLayNull:setIsPressedNeedScale(false)
	self.pLayNull:onMViewClicked(function()
		if self.nIconClickedHandler then
			self.nIconClickedHandler(self.nKind)
		end
	end)

	local pTxtNull = self:findViewByName("txt_null")
	pTxtNull:setString(getConvertedStr(3, 10139))

	--选中光亮
	self.pImgSel = self:findViewByName("img_sel")
	self.pImgSel:setScale(0.7)
	self.pImgSel:setVisible(false)

	--可洗练图片
	self.pImgRefine = self:findViewByName("img_status")

	--强化等级层
	self.pLayStrengthLv = self:findViewByName("lay_stren_lv")
	--强化等级
	self.pLbStrengthLv = self:findViewByName("lb_stren_lv")
end

function ItemRefineEquip:updateViews(  )
	if self.tEquipVo then
		local tEquipData = getBaseEquipDataByID(self.tEquipVo.nId)
		local tDarkLights = self.tEquipVo:getStarDarkLights()
		local pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tEquipData, 0.8)
		if not self.pIcon then
			self.pIcon = pIcon
			pIcon:setIconClickedCallBack(function ()
				if self.nIconClickedHandler then
					self.nIconClickedHandler(self.nKind)
				end
			end)
			pIcon:setPositionY(20)
			pIcon:initStarLayer(#tDarkLights, 0, tDarkLights)
		else
			pIcon:refreshStarLayer(#tDarkLights, 0, tDarkLights)
		end
		self.pIcon = pIcon
		self.pLayIcon:setVisible(true)
		self.pLayNull:setVisible(false)

		if self.tEquipVo.nStrenthLv > 0 then
			self.pLayStrengthLv:setVisible(true)
			self.pLbStrengthLv:setString("+"..self.tEquipVo.nStrenthLv)
			self.pLayStrengthLv:setLayoutSize(self.pLbStrengthLv:getWidth() + 2, self.pLayStrengthLv:getHeight())
		else
			self.pLayStrengthLv:setVisible(false)
		end

		if self.nFuncIdx == n_smith_func_type.strengthen then
			self:setCanRefine(false)
			if Player:getEquipData():isCanStrengthen(self.tEquipVo) then
				self:setCanStrengthen(true)
			else
				self:setCanStrengthen(false)
			end
		elseif self.nFuncIdx == n_smith_func_type.train then
			self:setCanStrengthen(false)
			--可洗练装备的红点显示
			if Player:getEquipData():isCanRefine(self.tEquipVo) then
				-- showRedTips(self, 0, 1, 2)
				self:setCanRefine(true)
			else
				-- showRedTips(self, 0, 0, 2)
				self:setCanRefine(false)
			end
		end
	else
		self.pLayIcon:setVisible(false)
		self.pLayNull:setVisible(true)
		-- showRedTips(self, 0, 0, 2)
		self:setCanStrengthen(false)
		self:setCanRefine(false)
		self.pLayStrengthLv:setVisible(false)
	end
end

--设置已选中
function ItemRefineEquip:setEquipSelected(_bSelected)
	-- body
	-- if self.pIcon then
	-- 	self.pIcon:setIconSelected(_bSelected)
	-- end
	self.pImgSel:setVisible(_bSelected)
end

--设置是否可洗炼
function ItemRefineEquip:setCanRefine(bRefine)
	-- body
	if bRefine then
		self.pImgRefine:setCurrentImage("#v2_fonts_kexilian.png")
	end
	self.pImgRefine:setVisible(bRefine)
end

--设置是否可强化
function ItemRefineEquip:setCanStrengthen(bCanStren)
	-- body
	if bCanStren then
		self.pImgRefine:setCurrentImage("#v2_fonts_keqh.png")
	end
	self.pImgRefine:setVisible(bCanStren)
end

--tEquipVo：装备数据
function ItemRefineEquip:setData( tEquipVo, nFuncIdx )
	self.tEquipVo = tEquipVo
	self.nFuncIdx = nFuncIdx
	self:updateViews()
end

function ItemRefineEquip:getData()
	-- body
	return self.tEquipVo
end

--点击图标回调
function ItemRefineEquip:setIconClickedHandler( nHandler )
	self.nIconClickedHandler = nHandler
end


return ItemRefineEquip


