local Replay = class("Replay")

function Replay:ctor( tData )
	self:update(tData)
end

function Replay:update( tData )
	if not tData then
		return
	end
	local FighterVO = require("app.layer.imperialwar.data.FighterVO")
	self.tAck = FighterVO.new(tData.ack) --FighterVO	进攻方
	self.tDef = FighterVO.new(tData.def) --FighterVO	防守方
	self.sFightRid = tData.fid	--String	战报ID
	self.nWinner = tData.ow --1,进攻方赢，2，是防守方赢
	self.nCityId = tData.cid
	self.nSendTime = tData.ts
end

function Replay:getAtk(  )
	return self.tAck
end

function Replay:getDef(  )
	return self.tDef
end

function Replay:getFightRid(  )
	return self.sFightRid
end

function Replay:getIsAtkWin()
	return self.nWinner == 1
end

function Replay:getCityId( )
	return self.nCityId
end

function Replay:getSendTime(  )
	return self.nSendTime
end


return Replay