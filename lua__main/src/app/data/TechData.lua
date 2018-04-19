----------------------------------------------------- 
-- author: zhangnainfeng
-- updatetime: 2018-3-14 21:24:00
-- Description:皇城战科技图标
-----------------------------------------------------

local Goods = require("app.data.Goods")

local TechData = class("TechData", Goods)

function TechData:ctor(  )
	TechData.super.ctor(self,e_type_goods.type_tech)
	-- body
	self:myInit()

end

function TechData:myInit(  )
	self.nGtype 	= e_type_goods.type_tech -- 数据类型，默认是物品类型(enum)
	self.nCost = 0
	self.sName = ""
	self.sDesc = ""
	self.nQuality = 0
	self.nLimit = 0
end

-- 用配置表DB中的数据来重置基础数据
function TechData:initDatasByDB( _tData )
	if (not _tData) then
		return 
	end

	self.sTid       = _tData.id or self.sTid
	self.sName 		= _tData.name or self.sName
	if _tData.icon then
		self.sIcon = "#".._tData.icon..".png"
	end
	self.nCost      = _tData.cost or self.nCost
	self.nLimit = _tData.limit or self.nLimit
	self.sDesc = _tData.desc or self.sDesc
	self.sDes = self.sDesc --为了可以显示小窗口而已加
	self.nQuality = _tData.quality or self.nQuality
end

return TechData
