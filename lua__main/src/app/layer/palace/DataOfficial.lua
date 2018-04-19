--文官数据
local Goods = require("app.data.Goods")

local DataOfficial = class("DataOfficial", Goods)

function DataOfficial:ctor(  )
	DataOfficial.super.ctor(self,e_type_goods.type_official)
	-- body
	self:myInit()
end

function DataOfficial:myInit( )
	-- body
	-- self.sName 		= nil   -- 名字（string）
	-- self.sDes 		= nil   -- 描述语（string）
	-- self.sTid 		= 0     -- 配表id（int）
	-- self.sPid 		= nil   -- 玩家身上对应id（string）
	-- self.nLv 		= 0     -- 当前等级(int)
	-- self.nCt 		= 0     -- 当前数量(int)
	-- self.nGtype 	= e_type_goods.type_item -- 数据类型，默认是物品类型(enum)
	-- self.sIcon 		= nil   -- 对应的icon资源(string)
	-- self.nQuality 	= 0     -- 品质（int）
	self.nLimit = 0
	self.nRate = 0
	self.sCost = nil
	self.nTime = 0
	self.nCanChange = 0
end

function DataOfficial:refreshDataByDB( tData )
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
	self.nCanChange = tData.canchange or self.nCanChange
end

return DataOfficial