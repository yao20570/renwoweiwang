--ScoreBox
local  ScoreBox = class("ScoreBox")

function ScoreBox:ctor(  )
	--body
	self:myInit()
end

function ScoreBox:myInit(  )
	-- body
	self.nTid  			= nil
	self.nTargetNum 	= nil
	self.nDropId 		= nil	
	
	self.bIsGetAward 	= false --是否已经领奖
end

function ScoreBox:refreshDataByDB( _data )
	-- body	
	self.nTid  			= _data[1] or self.sTid
	self.nTargetNum 	= _data[2] or self.nTargetNum
	self.nDropId 		= _data[3] or self.nDropId		
end

function ScoreBox:updateByService(_isget)
	-- body
	self.bIsGetAward = _isget or self.bIsGetAward	
end


function ScoreBox:release(  )

end
return ScoreBox

