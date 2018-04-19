local TaskMovePush = class("TaskMovePush")

--	区域内行军任务
function TaskMovePush:ctor( tData, sYlzUuid )
	self.tHeroId = {}
	self:update(tData)
end

function TaskMovePush:update( tData )
	if not tData then
		return
	end
	--加速判断定前置条件
	local nPrevState = self.nState
	local nPrevCd = self:getCd()

	--赋值
	self.nPlayerId  = tData.i or self.nPlayerId --long 玩家id
	self.sUuid = tData.u or self.sUuid	--String	任务UUID (御林军没有这个值)
	self.sName = tData.n or self.sName	--String	玩家名
	self.nState = tData.s or self.nState	--Integer	任务状态 1:前往 4:返回
	self.nCountry = tData.c	or self.nCountry--Integer	玩家国家
	self.nStartX = tData.sx	or self.nStartX --Integer	起点X
	self.nStartY = tData.sy or self.nStartY	--Integer	起点y
	self.nEndX = tData.ex or self.nEndX	--Integer	终点X
	self.nEndY = tData.ey or self.nEndY	--Integer	终点Y
	self.nCdMax = tData.tcd or self.nCdMax
	self.bIsNpc = tData.npc == 1 --是否是npc 0：否，1：是

	self.nMt = tData.mt or self.nMt    --起点类型 ---1为冥王
	--print("tData.cd,tData.tcd===============================",tData.cd, tData.tcd)
	if tData.cd then
		self.nCd = tData.cd	--Long	任务结束时间/秒
		self.nCdSystemTime = getSystemTime()

		--加速判断定
		if nPrevState == self.nState and math.abs(nPrevCd -self:getCd()) > 1 then
			self:setIsQuick(true)
		end
	end
	self.nMarchSpeed = tData.ms	--Integer	行军速度
	if tData.hids then
		self.tHeroId = tData.hids
	end

	--起点区域id
	if not self.nStartPBlockId then
		if self.nStartX and self.nStartY then
			self.nStartPBlockId = WorldFunc.getBlockId(self.nStartX, self.nStartY)
		end
	end
	--终点区域id
	if not self.nEndPBlockId then
		if self.nEndX and self.nEndY then
			self.nEndPBlockId = WorldFunc.getBlockId(self.nEndX, self.nEndY)
		end
	end
end

function TaskMovePush:getCd( )
	if self.nCd and self.nCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd - (fCurTime - self.nCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

function TaskMovePush:getIsQuick(  )
	return self.bIsQuick or false
end

function TaskMovePush:setIsQuick( bIsQuick )
	self.bIsQuick = bIsQuick
end

function TaskMovePush:getIsNpc(  )
	return self.bIsNpc
end

function TaskMovePush:getIsInBlockId( nBlockId )
	return self.nStartPBlockId == nBlockId or self.nEndPBlockId == nBlockId
end

function TaskMovePush:getCdMax(  )
	if self.nCdMax == nil or self.nCdMax <= 0 then --兼容热更前已经记录的行军数据
		local nDest = math.abs(self.nStartX - self.nEndX) + math.abs(self.nStartY - self.nEndY)
		local nTime = math.ceil(nDest*self.nMarchSpeed)
		if nTime <= 0 then --容错
			nTime = 1
		end
		return nTime
	end
	return self.nCdMax
end

return TaskMovePush

