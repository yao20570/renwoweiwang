local FightHeroInfo = class("FightHeroInfo")

function FightHeroInfo:ctor( tData )
	self:update(tData)
end

function FightHeroInfo:update( tData )
	if not tData then
		return
	end

	self.bIsNpc = tData.npc == 1	--Integer	是否为NPC 0:否 1:是
	self.sPlayerName = tData.pn	--String	所属玩家名字
	self.nHeroLv = tData.hlv	--Integer	英雄等级
	self.nHeroId = tData.hid	--Integer	武将id
	self.nKill = tData.k	--Integer	杀敌数
	self.nPrestige = tData.p	--Integer	威望(战功)
	self.nQuality = tData.qa	--Integer	城墙军品质
	self.nHeroGetExp = tData.hh    --Integer 武将获得经验(攻击乱军进攻方特有)
	self.nPlayerLv=tData.lv
	if tData.hs then
		self.nTemplate=tData.hs.t
		self.nIg=tData.hs.ig
	end
end

return FightHeroInfo