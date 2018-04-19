local SnatchTurnInfoVo = class("SnatchTurnInfoVo")

function SnatchTurnInfoVo:ctor( tData )
	self.nGetHead = 0
	self.nGetEquip = 0
	self.tLightPos = {}
	self.nGetPieceNum = 0
	self.nFreeUsed = 0
	self:update(tData)
end

function SnatchTurnInfoVo:update( tData )
	if not tData then
		return
	end

	self.nGetHead = tData.gh or self.nGetHead --Integer	获得主公头像 1.获得 0.未获得
	self.nGetEquip = tData.ge or self.nGetEquip --Integer	获得完整装备 1.获得 0.未获得
	if tData.ls then	--Set<Integer>	被点亮位置	
		self.tLightPos = {}
		for i=1,#tData.ls do
			self.tLightPos[tData.ls[i]] = true
		end
	end
	self.nGetPieceNum = tData.cm or self.nGetPieceNum --Integer	获得装备碎片数量
	self.nFreeUsed = tData.tm or self.nFreeUsed --	Integer	已免费转盘次数
end

function SnatchTurnInfoVo:isGotHead( )
	return self.nGetHead == 1
end

function SnatchTurnInfoVo:isGotEquip( )
	return self.nGetEquip == 1
end

return SnatchTurnInfoVo