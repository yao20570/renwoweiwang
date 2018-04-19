----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 系统城池 征收
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local SysCityCollections = class("SysCityCollections", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function SysCityCollections:ctor(  )
	--解析文件
	parseView("lay_sys_city_collections", handler(self, self.onParseViewCallback))
end

--解析界面回调
function SysCityCollections:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	self:setDestroyHandler("SysCityCollections", handler(self, self.onSysCityCollectionsDestroy))
end

-- 析构方法
function SysCityCollections:onSysCityCollectionsDestroy(  )
    self:onPause()
end

function SysCityCollections:regMsgs(  )
end

function SysCityCollections:unregMsgs(  )
end

function SysCityCollections:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function SysCityCollections:onPause(  )
	self:unregMsgs()
end

function SysCityCollections:setupViews(  )
	local pLayIcon1 = self:findViewByName("lay_icon1")
	local pLayIcon2 = self:findViewByName("lay_icon2")
	local pLayIcon3 = self:findViewByName("lay_icon3")
	local pLayIcon4 = self:findViewByName("lay_icon4")
	self.pLayIcons = {
		pLayIcon1,
		pLayIcon2,
		pLayIcon3,
		pLayIcon4,
	}
	self.pIcons = {}
end

function SysCityCollections:updateViews(  )
end

function SysCityCollections:setIcon( nIndex, tData)

	local pIcon = self.pIcons[nIndex]
	if tData then
		if not pIcon then
			if self.pLayIcons[nIndex] then
				pIcon = getIconGoodsByType(self.pLayIcons[nIndex], TypeIconGoods.HADMORE, type_icongoods_show.itemnum,tData, TypeIconGoodsSize.M)
				self.pIcons[nIndex] = pIcon
				pIcon:setIconIsCanTouched(true)
				centerInView(self.pLayIcons[nIndex], pIcon)
			end
		else
			pIcon:setVisible(true)
		end
		pIcon:setCurData(tData)
        pIcon:setMoreText(tData.sName)
		pIcon:setMoreTextColor(getColorByQuality(tData.nQuality))
	else
		if pIcon then
			pIcon:setVisible(false)
		end
	end
end

return SysCityCollections


