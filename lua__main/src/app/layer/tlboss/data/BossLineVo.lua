local PointVO = require("app.layer.tlboss.data.PointVO")
local BossLineVo = class("BossLineVo")

function BossLineVo:ctor( tData )
	self.tPointDict = {}
	self:update(tData)
end

function BossLineVo:update( tData )
	if not tData then
		return
	end
	self.nBlockId = tData.b or self.nBlockId --区域Id
	if tData.ps then
		--行军坐标点
		self.tPointDict = {}
		for i=1,#tData.ps do
			local tPointVo = PointVO.new(tData.ps[i])
			local sDotKey = tPointVo:getDotKey()
			self.tPointDict[sDotKey] = tPointVo
		end
	end
end

function BossLineVo:getBlockId(  )
	return self.nBlockId
end

function BossLineVo:getPoints(  )
	return self.tPointDict
end

function BossLineVo:addPoint( tPointVo)
	local sDotKey = tPointVo:getDotKey()
	self.tPointDict[sDotKey] = tPointVo
end

function BossLineVo:delPoint( tPointVo)
	local sDotKey = tPointVo:getDotKey()
	self.tPointDict[sDotKey] = nil
end

return BossLineVo