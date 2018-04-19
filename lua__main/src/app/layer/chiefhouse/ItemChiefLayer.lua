-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-25 11:01:40 星期一
-- Description: 高级御兵术
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemChiefLayer = class("ItemChiefLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemChiefLayer:ctor( )
	-- body
	self:myInit()
	parseView("item_chief_layer", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemChiefLayer:myInit(  )
	-- body	 
	self.tCurData 			= 	nil 				--当前数据	
	self.nHandler 			= 	nil 				--回调事件
end

--解析布局回调事件
function ItemChiefLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemChiefLayer",handler(self, self.onDestroy))
end

--初始化控件
function ItemChiefLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("item_chief_layer") 
	self.pLayRoot:setViewTouched(true)
	self.pLayRoot:setIsPressedNeedScale(false)
	self.pLayRoot:onMViewClicked(handler(self, self.onItemClicked))

	self.pImgLock = self:findViewByName("img_lock")
	self.pLbName  = self:findViewByName("lb_name")
	self.pImgIcon = self:findViewByName("img_icon")
	self.pImgSelect = self:findViewByName("img_select")
	self.pImgIcon:setScale(0.5)
	self.pImgIcon:setVisible(true)
end

-- 修改控件内容或者是刷新控件数据
function ItemChiefLayer:updateViews( )
	-- body
	local pBChiefData 		= 		Player:getBuildData():getBuildById(e_build_ids.tcf)
	if self.tCurData and pBChiefData then
		--dump(self.tCurData, "self.tCurData", 100)
		local pTroopVo = pBChiefData:getCurTroopVo(self.tCurData.type)
		local nLv = 0
		if pTroopVo then
			nLv = pTroopVo.nLv
		end		
		self.pLbName:setString(self.tCurData.name..getLvString(nLv, false))
		self.pImgIcon:setCurrentImage("#"..self.tCurData.icon..".png")

		local nLimitLv = tonumber(self.tCurData.lvlimit or 0)

		local nStage = pBChiefData.nStage
		local bLocked = false
		if nStage < self.tCurData.id then
			bLocked = true
		elseif pTroopVo.nStage <= 0 and pTroopVo.nSec <= 0 and Player:getPlayerInfo().nLv < nLimitLv then--未升级且在限制等级之内
			bLocked = true
		end
		self.pImgLock:setVisible(bLocked)
	end
end

-- 析构方法
function ItemChiefLayer:onDestroy(  )
	-- body
end

function ItemChiefLayer:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

function ItemChiefLayer:getData(  )
	-- body
	return self.tCurData
end

function ItemChiefLayer:getIsLocked(  )
	-- body
	return self.pImgIcon:isVisible()
end

function ItemChiefLayer:setClickHandler( _nHandler )
	-- body
	self.nHandler = _nHandler
end

function ItemChiefLayer:onItemClicked(  )
	-- body
	if self.nHandler then
		self.nHandler(self.tCurData)
	end
end

function ItemChiefLayer:setItemSelected( _bselected )
	-- body
	local bSelected = _bselected or false
	if self.pImgSelect then
		self.pImgSelect:setVisible(bSelected)
	end
end
return ItemChiefLayer