--官员
local HonorTask = class("HonorTask")

function HonorTask:ctor(  )
	--body
	self:myInit()
end

function HonorTask:myInit(  )
	-- body
	self.sTid  			= nil
	self.nCastleFight 	= 0
	self.nCountryFight 	= 0 
	-- self.nDevelop		= 0
	self.nScience 		= 0
	self.nAward 		= nil
	
	self.nCityFightTime 		= 0--Integer	城战完成次数
	self.nCountryFightTime 		= 0--Integer	国战完成次数
	self.nSd 					= 0--Integer	捐献完成次数 
	-- self.nCountryDevelopTime 	= 0--Integer	开发完成次数
	self.bIsGetAward 			= false
	self.bIsFinished 			= false
end

function HonorTask:refreshDataByDB( tData )
	-- body	
	self.sTid  			= 	tData.id or self.sTid
	self.nCastleFight 	= 	tData.castlefight or self.nCastleFight
	self.nCountryFight 	= 	tData.countryfight or self.nCountryFight
	-- self.nDevelop		= 	tData.develop or self.nDevelop
	self.nScience 		=   tData.science or self.nScience
	self.nAward 		=	tData.award or self.nAward
end

function HonorTask:updateByService(tData)
	-- body
	-- dump(tData, "tData", 100)
	self.nCityFightTime = tData.ca or self.nCityFightTime--Integer	城战完成次数
	self.nCountryFightTime = tData.co or self.nCountryFightTime--Integer	国战完成次数
	-- self.nCountryDevelopTime = tData.de or self.nCountryDevelopTime--Integer	开发完成次数
	self.nSd = tData.sd or self.nSd --Integer	捐献完成次数 
	if (self.nCityFightTime >= self.nCastleFight) 
		and (self.nCountryFightTime >= self.nCountryFight) 
		and (self.nSd >= self.nScience) then
		self.bIsFinished = true
	else
		self.bIsFinished = false
	end

	if tData.rs and #tData.rs > 0 then
		self.bIsGetAward = false		
		for k, v in pairs(tData.rs) do
			if v == self.sTid then
				self.bIsGetAward = true
			end
		end
	end
end
--是否已经领奖
function HonorTask:isHaveGetAward(  )
	-- body
	return self.bIsGetAward
end

function HonorTask:isShowRed(  )
	-- body
	if self.bIsGetAward == false and self.bIsFinished == true then
		return true
	else
		return false
	end
end

function HonorTask:release(  )

end
return HonorTask

