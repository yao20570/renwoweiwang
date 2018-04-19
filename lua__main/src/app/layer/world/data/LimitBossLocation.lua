local LimitBossLocation = class("LimitBossLocation")

function LimitBossLocation:ctor( tData, tViewDotMsg)
	self:udpate(tData)
	self:udpateByViewDotMsg(tViewDotMsg)
end

function LimitBossLocation:udpate( tData )
	if not tData then
		return
	end
	self.nX = tData.x or self.nX --	Integer	X
	self.nY = tData.y or self.nY --	Integer	Y
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

function LimitBossLocation:udpateByViewDotMsg( tViewDotMsg )
	if not tViewDotMsg then
		return
	end
	self.nX = tViewDotMsg.nX or self.nX
	self.nY = tViewDotMsg.nY or self.nY
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

return LimitBossLocation