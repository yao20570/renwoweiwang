----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-02 09:42:53
-- Description: 铁匠铺 装备
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemSmithEquip = class("ItemSmithEquip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nKind 类型
function ItemSmithEquip:ctor( nKind )
	self.nKind = nKind
	--解析文件
	parseView("item_smith_equip", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemSmithEquip:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemSmithEquip", handler(self, self.onItemSmithEquipDestroy))
end

-- 析构方法
function ItemSmithEquip:onItemSmithEquipDestroy(  )
    self:onPause()
end

function ItemSmithEquip:regMsgs(  )
end

function ItemSmithEquip:unregMsgs(  )
end

function ItemSmithEquip:onResume(  )
	self:regMsgs()
end

function ItemSmithEquip:onPause(  )
	self:unregMsgs()
end

function ItemSmithEquip:setupViews(  )
	self.pLayDef = self:findViewByName("default")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pImgSelect = self:findViewByName("img_select")
	self.pImgSelect:setVisible(false)	
	--self.pLayIcon:setPositionY(self.pLayIcon:getPositionY() - 20)

	--self.pImgCanMake = self:findViewByName("img_hammer")
	-- self.pLayMaking = self:findViewByName("lay_hammer2")
	-- self.pImgMaking = self:findViewByName("img_hammer2")
	self.pImgLock = self:findViewByName("img_lock")
	-- local rotate1 = cc.RotateTo:create(0.4, 10)
	-- local rotate2 = cc.RotateTo:create(0.8, -10)
	-- self.pImgMaking:runAction(cc.RepeatForever:create(cc.Sequence:create(rotate1, rotate2)))

	self.pImgStatus = self:findViewByName("img_making")
end

function ItemSmithEquip:updateViews(  )
	if not self.tEquipData then
		return
	end

	local pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, self.tEquipData, 0.8)
	if not self.pIcon then
		self.pIcon = pIcon
		self.pIcon:setIsShowBgQualityTx(false)
		pIcon:setIconClickedCallBack(function ()
			if self.nIconClickedHandler then
				self.nIconClickedHandler(self.nKind)
			end
		end)
	end
	pIcon:setNumber(Player:getEquipData():getCntByEquipId(self.tEquipData.sTid))


	--显示是否右上角上锁
	if Player:getPlayerInfo().nLv < self.tEquipData.nMakeLv then
		self.pImgLock:setVisible(true)
		--self.pImgCanMake:setVisible(false)
		-- self.pLayMaking:setVisible(false)
		self.pImgStatus:setVisible(false)
		self.pIcon:setIconToGray(true)
	else
		self.pIcon:setIconToGray(false)
		self.pImgLock:setVisible(false)
		--获取是否打造中
		if Player:getEquipData():getCurrMakingId() == self.tEquipData.sTid then
			--self.pImgCanMake:setVisible(false)
			-- self.pLayMaking:setVisible(true)
			self.pImgStatus:setCurrentImage("#v2_fonts_dazaozhong.png")
			self.pImgStatus:setVisible(true)
		else
			-- self.pLayMaking:setVisible(false)
			--self.pImgStatus:setVisible(false)
			
			--显示是否满足打造条件
			if checkIsResourceStrEnough(self.tEquipData.sMakeCosts) then
				self.pImgStatus:setCurrentImage("#v2_fonts_kedazao.png")
				self.pImgStatus:setVisible(true)
			else
				self.pImgStatus:setVisible(false)
			end
		end
	end
end

--tEquipData：装备数据
function ItemSmithEquip:setData( tEquipData )
	self.tEquipData = tEquipData
	self:updateViews()
end

function ItemSmithEquip:setIconClickedHandler( nHandler )
	self.nIconClickedHandler = nHandler
end

function ItemSmithEquip:setSelected( bSelect )
	-- body
	if self.pImgSelect then
		self.pImgSelect:setVisible(bSelect)
	end
end

function ItemSmithEquip:getData()
	-- body
	return self.tEquipData
end

return ItemSmithEquip


