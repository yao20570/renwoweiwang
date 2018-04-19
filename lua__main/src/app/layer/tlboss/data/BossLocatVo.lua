local BossLocatVo = class("BossLocatVo")

function BossLocatVo:ctor( tData )
	self:udpate(tData)
end

function BossLocatVo:udpate( tData )
	if not tData then
		return
	end
	self.nX = tData.x or self.nX --	Integer	X
	self.nY = tData.y or self.nY --	Integer	Y
	self.nBlockId = tData.b or self.nBlockId -- Integer 区域id
	--9个格的格子数
	self.tDotKeys = {}
	local nMinX,nMinY,nMaxX,nMaxY = self.nX-1,self.nY-1,self.nX+1,self.nY+1
	for nGridX=nMinX,nMaxX do
		for nGridY=nMinY,nMaxY do
			table.insert(self.tDotKeys, string.format("%s_%s",nGridX,nGridY))
		end
	end
	self.fPosX, self.fPosY = WorldFunc.getMapPosByDotPos(self.nX, self.nY)
end

function BossLocatVo:getX(  )
	return self.nX
end

function BossLocatVo:getY(  )
	return self.nY
end

function BossLocatVo:getBlockId( )
	return self.nBlockId
end

function BossLocatVo:getDotKeys( )
	return self.tDotKeys
end

function BossLocatVo:getWorldMapPos( )
	return self.fPosX, self.fPosY
end

return BossLocatVo