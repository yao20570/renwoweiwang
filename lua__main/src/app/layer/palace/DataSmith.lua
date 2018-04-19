--文官数据
local Goods = require("app.data.Goods")

local DataSmith = class("DataSmith", Goods)

function DataSmith:ctor(  )
	DataSmith.super.ctor(self,e_type_goods.type_smith)
	-- body
	self:myInit()
end

function DataSmith:myInit( )
	-- body
	self.nLimit = 0
	self.nRate = 0
	self.sCost = nil
	self.nTime = 0
end

function DataSmith:refreshDataByDB( tData )
	-- body
	self.sTid = tData.id or self.sTid	
	self.sName = tData.name or self.sName
	self.nQuality = tData.quality or self.nQuality
	self.nLv = tData.level or self.nLv
	self.sIcon = "#"..tData.icon..".png"

	self.nLimit = tData.palacelevel or self.nLimit
	self.nRate = tData.rate or self.nRate
	self.sCost = tData.cost or self.sCost
	self.nTime = tData.time or self.nTime	
	self.nGoldTime = tData.goldtime or self.nGoldTime	
end

return DataSmith