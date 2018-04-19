local BossLocation = class("BossLocation")

function BossLocation:ctor( tData, tViewDotMsg)
	self:udpate(tData)
	self:udpateByViewDotMsg(tViewDotMsg)
end

function BossLocation:udpate( tData )
	if not tData then
		return
	end
	self.nX = tData.x or self.nX --	Integer	X
	self.nY = tData.y or self.nY --	Integer	Y
	self.bIsAtk = tData.s == 1 --	Integer	是否有人发起 0:否 1:是
	self.nLv = tData.lv or self.nLv -- Integer 等级
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

function BossLocation:udpateByViewDotMsg( tViewDotMsg )
	if not tViewDotMsg then
		return
	end
	self.nX = tViewDotMsg.nX or self.nX
	self.nY = tViewDotMsg.nY or self.nY
	self.bIsAtk = tViewDotMsg.bIsHasBossWar
	self.nLv = tViewDotMsg.nBossLv or self.nLv -- Integer 等级
	self.sDotKey = string.format("%s_%s",self.nX, self.nY)
end

return BossLocation