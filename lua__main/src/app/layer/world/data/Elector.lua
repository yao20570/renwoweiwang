local Elector = class("Elector")
--城主竞选者
function Elector:ctor( tData )
	self.nLv = 0
	self:update(tData)
end

function Elector:update( tData )
	if not tData then
		return
	end
	self.sName  = tData.n --String	玩家名字
	self.nTitle = tData.j --Integer	玩家爵位
	self.nLv = tData.l or self.nLv --Integer	玩家等级 
end

return Elector

