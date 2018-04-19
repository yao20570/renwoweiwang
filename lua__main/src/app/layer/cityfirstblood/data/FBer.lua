local ActorVo = require("app.layer.playerinfo.ActorVo")
local FBer = class("FBer")

function FBer:ctor( tData )
	self:update(tData)
end

function FBer:update( tData )
	if not tData then
		return
	end

	if tData.npc then
		self.bIsNpc = tData.npc == 1
	end
	self.nAid = tData.aid or self.nAid --	Long	角色id
	self.sName = tData.n or self.sName --	String	名字
	self.sIcon = tData.ic or self.sIcon --	String	icon

	if self.bIsNpc then --npc情况读配表
		local tNpcGroup = getNpcGropById(self.nAid)
		if tNpcGroup then
			local tNpc = tNpcGroup[1]
			if tNpc then
				self.sName = tNpc.sName
				self.sIcon = tNpc.sIcon
			end
		end
		self.tActorVo = ActorVo.new()
		self.tActorVo:setIcon(self.sIcon)
	else
		self.tActorVo = ActorVo.new()
		self.tActorVo:initData(self.sIcon)
	end
end

function FBer:getActorVo( )
	return self.tActorVo
end

function FBer:getName( )
	return self.sName
end

return FBer