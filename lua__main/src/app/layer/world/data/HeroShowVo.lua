local HeroShowVo = class("HeroShowVo")

--英雄展示VO
function HeroShowVo:ctor( tData )
	self:update(tData)
end

function HeroShowVo:update( tData )
	if not tData then
		return
	end
	self.nHeroId = tData.t or self.nHeroId --英雄模板Id
	self.nIg  = tData.ig or self.nIg --Integer	武将是否神级进阶 0否 1是
end

function HeroShowVo:getHeroId(  )
	return self.nHeroId
end

function HeroShowVo:getIg(  )
	return self.nIg
end

return HeroShowVo