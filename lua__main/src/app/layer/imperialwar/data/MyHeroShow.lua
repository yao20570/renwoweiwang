local MyHeroShow = class("MyHeroShow")

function MyHeroShow:ctor( tData )
	self.nHeroLv = 0
	self.nTroopsMax = 0
	self:update(tData)
end

function MyHeroShow:update( tData )
	if tData.hs then --	HeroShowVo	英雄展示
		local HeroShowVo = require("app.layer.world.data.HeroShowVo")
		self.tHero = HeroShowVo.new(tData.hs)
	end
	self.nHeroLv = tData.hlv or self.nHeroLv --	Integer	英雄等级
	self.nTroopsMax = tData.ttrp or self.nTroopsMax	-- Long	总兵力
	self.nTroopsCurr = tData.ctrp or self.nTroopsCurr --	Long	当前兵力
end

function MyHeroShow:getHeroVo(  )
	return self.tHero
end

function MyHeroShow:getHeroLv()
	return self.nHeroLv
end

function MyHeroShow:getTroopsMax()
	return self.nTroopsMax
end

function MyHeroShow:getTroopsCurr()
	return self.nTroopsCurr
end

return MyHeroShow