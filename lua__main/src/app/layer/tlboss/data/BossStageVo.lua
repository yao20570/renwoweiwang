local BossStageVo = class("BossStageVo")

function BossStageVo:ctor( tData )
	self:update(tData)
end

function BossStageVo:update( tData )
	if not tData then
		return
	end
	self.nStage = tData.s or self.nStage	--Integer	boss阶段数
	self.nLifeTime = tData.l or self.nLiftTime -- Integer	boss生命时间(秒)
	if tData.r then --Integer	boss剩余时间(秒)
		self.nLifeCd = tData.r
		self:recordLifeTime()
	end
	self.nBrokeTime = tData.w or self.nBrokeTime--Integer	boss破坏时间(秒)
end

function BossStageVo:getLifeCd( )
    if self.nLifeCd and self.nLifeCd > 0 then
        local fCurTime = getSystemTime()
        local fLeft = self.nLifeCd - (fCurTime - self.nLifeCdSystemTime)
        if(fLeft < 0) then
            fLeft = 0
        end
        return fLeft
    end
    return 0
end

function BossStageVo:getLifeTime(  )
	return self.nLifeTime
end

function BossStageVo:getBrokeTime(  )
	return self.nBrokeTime
end

function BossStageVo:getBarTime(  )
	return self.nLifeTime - self.nBrokeTime
end


function BossStageVo:getStage(  )
	return self.nStage
end

function BossStageVo:recordLifeTime(  )
	self.nLifeCdSystemTime = getSystemTime()
end

--boss活动时间状态 0活动未开始 1活动准备中 2活动已开始
function BossStageVo:setTimeState( nTimeState )
	if self.nTimeStatePrev ~= nTimeState and nTimeState == e_tlboss_time.begin then
		self:recordLifeTime()
	end
	self.nTimeStatePrev = nTimeState
end

return BossStageVo