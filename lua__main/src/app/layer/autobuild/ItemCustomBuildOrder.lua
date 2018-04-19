----------------------------------------------------- 
-- author: maheng
-- updatetime:  2018-03-07 20:04:23 星期三
-- Description: 自定建造项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemCustomBuildOrder = class("ItemCustomBuildOrder", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCustomBuildOrder:ctor(  )

	self:myinit()
	--解析文件
	parseView("item_custom_build_order", handler(self, self.onParseViewCallback))
end

function ItemCustomBuildOrder:myinit(  )
	-- body
	self.nItemHandler = nil
	self.nIndex = nil
	self.nSelect = nil
	self.pData = nil
end

--解析界面回调
function ItemCustomBuildOrder:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemCustomBuildOrder", handler(self, self.onDestroy))
end

function ItemCustomBuildOrder:setupViews(  )
	self.pLayRoot = self:findViewByName("lay_root")
	self.pLbOrder = self:findViewByName("lb_order")
	self.pLbBuild = self:findViewByName("lb_build")
	self.pImgFlag = self:findViewByName("img_flag")

	self.pLbBuild:setVisible(false)
	self.pImgFlag:setVisible(false)
	--响应
	self.pLayRoot:setViewTouched(true)
	self.pLayRoot:setIsPressedNeedScale(false)
	self.pLayRoot:onMViewClicked(handler(self, self.onItemClicked))	
end

function ItemCustomBuildOrder:updateViews()
	-- body
	if not self.nIndex or not self.nSelect or not self.pData then
		return
	end
	local bShow = self.nIndex == self.nSelect
	self.pLbBuild:setVisible(bShow)
	self.pImgFlag:setVisible(bShow)
	local pBuildData = Player:getBuildData()
	local pData = self.pData
	if pData.nCellIndex and pData.nCellIndex > 0 and pData.nCellIndex <= 1000 then--城内建筑
		local pCurData = pBuildData:getBuildById(pData.sTid, true)
		local nLv = 0
		if pCurData then
			nLv = pCurData.nLv			
		end
		self.pLbBuild:setString(pData.sName..getLvString(nLv, false))
	else
		--郊外建筑
		self.pLbBuild:setString(pData.sName, false)
	end	

	self.pLbOrder:setString(getConvertedStr(6, 10780)..self.nIndex, false)
end

function ItemCustomBuildOrder:onItemClicked(  )
	-- body
	if self.nItemHandler then
		self.nItemHandler(self.nIndex)
	end
end

function ItemCustomBuildOrder:setItemClickedHandler(_nHandler)
	-- body
	self.nItemHandler = _nHandler
end

-- 析构方法
function ItemCustomBuildOrder:onDestroy(  )

end

function ItemCustomBuildOrder:setData( _nIndex, _nSelect, pBuild )
	-- body
	if not _nIndex or not _nSelect or not pBuild then
		return
	end
	self.nIndex = _nIndex
	self.nSelect = _nSelect
	self.pData = pBuild
	self:updateViews()
end

return ItemCustomBuildOrder


