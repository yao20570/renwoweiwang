--文官数据
local Goods = require("app.data.Goods")

local DataResearcher = class("DataResearcher", Goods)

function DataResearcher:ctor(  )
	DataResearcher.super.ctor(self,e_type_goods.type_researcher)
	-- body
	self:myInit()
end

function DataResearcher:myInit( )
	-- body
	self.nLimit = 0
	self.nDuration = 0
	self.sCost = nil
	self.nTime = 0
	self.nCanChange = 0
end

function DataResearcher:refreshDataByDB( tData )
	-- body
	self.sTid = tData.id or self.sTid	
	self.sName = tData.name or self.sName
	self.nQuality = tData.quality or self.nQuality
	self.nLv = tData.level or self.nLv
	self.sIcon = "#"..tData.icon..".png"

	self.nLimit = tData.institute or self.nLimit
	self.nDuration = tData.duration or self.nDuration
	self.sCost = tData.cost or self.sCost
	self.nTime = tData.time or self.nTime
	self.nCanChange = tData.canchange or self.nCanChange
end

return DataResearcher