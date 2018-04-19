----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-21 09:50:32
-- Description: 线路
-----------------------------------------------------
--武将延迟出现时间
local nHeroMoveDelay = 10--8

--路线状态 
local e_type_line = {
	green = 1, --我方
	yellow = 2,--友方
	red = 3, --其他
}

local Line = class("Line")
-- local tData = {
-- 	nId = ,
-- 	nStartX = ,
-- 	nStartY = ,
-- 	nEndX = ,
-- 	nEndY = ,
-- 	fStartX = ,
-- 	fStartY = ,
-- 	nLineType = ,
-- 	nFrom = ,
--  nTaskType = ,
-- }
function Line:ctor(tData)
	self.nId 		= tData.nId 	
	self.nStartX 	= tData.nStartX 
	self.nStartY 	= tData.nStartY 
	self.nEndX 		= tData.nEndX 	
	self.nEndY 		= tData.nEndY 	
	self.nTaskType  = tData.nTaskType
	local tSysCityData = getWorldCityDataByPos(self.nStartX, self.nStartY)
	if tSysCityData then
		self.fStartX 	= tSysCityData.tMapPos.x
		self.fStartY 	= tSysCityData.tMapPos.y
	else
		self.fStartX 	= tData.fStartX 
		self.fStartY 	= tData.fStartY 
	end
	
	local tSysCityData = getWorldCityDataByPos(self.nEndX, self.nEndY)
	if tSysCityData then
		self.fEndX 	= tSysCityData.tMapPos.x
		self.fEndY 	= tSysCityData.tMapPos.y
	elseif self.nTaskType and self.nTaskType == e_type_task.zhouwang then
		local fPosX, fPosY = WorldFunc.getMapPosByDotPos(self.nEndX, self.nEndY)			
		self.fEndX 		= (fPosX + UNIT_WIDTH/2) 	
		self.fEndY 		= fPosY	
	else
		self.fEndX 	= tData.fEndX 	
		self.fEndY 	= tData.fEndY 
	end


	self.nLineType 	= tData.nLineType
	self.bIsMine 	= tData.nFrom == 1 
	self.bIsTLBoss  = tData.nFrom == 3
	self.bIsEpw = tData.nFrom == 4

	self.pFStartP = cc.p(self.fStartX, self.fStartY)
	self.pFEndP = cc.p(self.fEndX, self.fEndY)

	self.fLength = cc.pGetDistance(self.pFStartP, self.pFEndP)
	self.nState = self:getState() 

	self.pPosIndex = 0
	self.pLine = nil
	self.pHeros = {}
	self.isCreated = false
	self.nBlockId = WorldFunc.getBlockId(self.nStartX, self.nStartY)
	self.sStartKey = string.format("%s_%s",self.nStartX, self.nStartY) 
	self.sEndKey = string.format("%s_%s",self.nEndX, self.nEndY)
	self.nCreateTime = getSystemTime()
end

--释放
function Line:releaseLine()
	if self.pLine then
		self.pLine:removeFromParent(true)
		self.pLine = nil
	end
	local pHeros = self.pHeros
	if pHeros then
		for k,v in pairs(pHeros) do
			v:removeFromParent(true)
		end
		self.pHeros = nil
	end
end

--线路是否发生改变
function Line:checkIsChanged( )
	if self.bIsMine then
		local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.nId)
		if tTaskMsg then
			local nX, nY = Player:getWorldData():getMyCityDotPos()
			if tTaskMsg:getIsBotAnGo() then
				nX = tTaskMsg:getBoX()
				nY = tTaskMsg:getBoY()
			end
			if nX ~= self.nStartX or
				nY ~= self.nStartY or 
				tTaskMsg.nTargetX ~= self.nEndX or 
				tTaskMsg.nTargetY ~= self.nEndY or 
				tTaskMsg.nState ~= self.nState	then
				return true
			end
		end
	elseif self.bIsTLBoss then
		local bIsIn = Player:getTLBossData():getIsTLBossPoint(self.nBlockId, self.sStartKey)
		if bIsIn then
			--TLBoss行军路线不会改变
			return false
		else
			return true
		end
	elseif self.bIsEpw then
		local bIsIn = Player:getImperWarData():getIsInLine(self.nId)
		if bIsIn then
			--皇城战行军路线不会改变
			return false
		else
			return true
		end
	else
		local tTaskMovePush = Player:getWorldData():getTaskMovePushByUuid(self.nId)
		if tTaskMovePush then
			if tTaskMovePush.nStartX ~= self.nStartX or 
				tTaskMovePush.nStartY ~= self.nStartY or 
				tTaskMovePush.nEndX ~= self.nEndX or 
				tTaskMovePush.nEndY ~= self.nEndY or 
				tTaskMovePush.nState ~= self.nState	then
				return true
			end
		end
	end

	return false
end

--更新线路
function Line:updateLine(  )
	local pLine = self.pLine
	local pPosList = self.pPosList
	local pPosIndex = self.pPosIndex
	if pLine and pPosList and pPosIndex then
		pPosIndex = pPosIndex + 1
		if pPosIndex > #pPosList then
			pPosIndex = 1
		end
		
		--更新位置
		self.pPosIndex = pPosIndex
		local pPos = pPosList[pPosIndex]
		local pBatchNode = pLine --pLine.pBatchNode
		if pBatchNode then
			pBatchNode:setPosition(pPos)
			pBatchNode:setTextureRect(cc.rect(0, 0, self.nLineWidth - (self.pPosIndex - 1), self.nLineHeight))
		end
	end
end

--设置线路
function Line:setLine( pLine ,pHeros)
	--设置行路
	local pFStartP, pFEndP = self.pFStartP, self.pFEndP
	if self.nState == e_type_task_state.back then
		local pTempP = pFStartP
		pFStartP = pFEndP
		pFEndP = pTempP
	end
	--显示线
	local nAngle = getAngle(pFStartP.x, pFStartP.y, pFEndP.x, pFEndP.y)
	pLine:setRotation(nAngle)

	local pPosList = {}
	if false then
		--由于pLine是一个ClippingNode,设置锚点无效，所以只能位置进向偏移，前进方向+90度移9像素
		local nOffsetRadian = (nAngle + 90) * math.pi / 180;
		local nX, nY = pFStartP.x + 9 * math.cos(nOffsetRadian), pFStartP.y - 9 * math.sin(nOffsetRadian)
		pLine:setPosition(nX, nY)

		--线图片每一帧更改的位置
		for i=1,32 do
			local fX, fY = (i - 1) * 1, 0
			table.insert(pPosList, cc.p(fX, fY))
		end
	else
		--由于pLine是一个ClippingNode,设置锚点无效，所以只能位置进向偏移，前进方向+90度移9像素
		-- local nOffsetRadian90 = (nAngle + 90) * math.pi / 180;
		-- local nX, nY = pFStartP.x + 8 * math.cos(nOffsetRadian90), pFStartP.y - 8 * math.sin(nOffsetRadian90)
		local nX, nY = pFStartP.x , pFStartP.y
		--线图片每一帧更改的位置
		local nOffsetRadian = nAngle * math.pi / 180;
		for i=1,32 do
			local fX, fY = nX + (i - 1) * math.cos(nOffsetRadian), nY - (i - 1) * math.sin(nOffsetRadian)
			table.insert(pPosList, cc.p(fX, fY))
		end
	end
	
	self.pLine = pLine
	self.pPosList = pPosList
	self.pPosIndex = 0
	
	local pSize = pLine:getContentSize()
	self.nLineWidth = pSize.width
	self.nLineHeight = pSize.height
	--设置武将
	self.nRadian = nAngle * math.pi / 180;
	self.pHeros = pHeros
	--更新武将
	self:updateHeros()
end

--更新移动中的武将
function Line:updateHeros( )
	--容错
	if not self.pHeros then
		return
	end
	--容错
	if #self.pHeros == 0 then
		return
	end

	--如果状态是注战就不显示 znftodo优化
	if self.nState == e_type_task_state.waitbattle then
		return
	end

	--设置行路
	local pFStartP, pFEndP = self.pFStartP, self.pFEndP
	if self.nState == e_type_task_state.back then
		local pTempP = pFStartP
		pFStartP = pFEndP
		pFEndP = pTempP
	end
	--设置动作
	local nMoveCd = self:getCd()
	local fMoveTime = self:getTotalCd()
	-- print("nMoveCd,fMoveTime===",nMoveCd,fMoveTime)
	local fMoved = math.max(fMoveTime - nMoveCd,0)/fMoveTime * self.fLength
	local fHeroX = pFStartP.x + fMoved * math.cos(self.nRadian)
	local fHeroY = pFStartP.y - fMoved * math.sin(self.nRadian)
	for i=1,#self.pHeros do
		local pHero = self.pHeros[i]
		--容错
		if not tolua.isnull(pHero) then
			--行军颜色
			local nColorType = 1
			if self:getLineType() == 3 then
				nColorType = 2
			end
			if pHero.setColorAndDir then
				local bIsGhost = self:getIsGhost()
				pHero:setColorAndDir(nColorType, fHeroX, fHeroY, pFEndP.x, pFEndP.y,bIsGhost)
			end
			pHero:setPosition(cc.p(fHeroX, fHeroY))
			local nDelay = (i - 1) * nHeroMoveDelay
			local pActList = {}
			if nDelay > 0 then
				pHero:setVisible(false)
				table.insert(pActList,cc.DelayTime:create(nDelay))
				table.insert(pActList,cc.Show:create())
			end
			--动画帧需要更改终点值
			local nEndX, nEndY = pFEndP.x, pFEndP.y
			local nOffsetX, nOffsetY = pHero:getArmOffsetPos()
			if nOffsetX and nOffsetY then
				nEndX = nEndX + nOffsetX
				nEndY = nEndY + nOffsetY
			end
			table.insert(pActList,cc.MoveTo:create(nMoveCd, cc.p(nEndX, nEndY)))
			table.insert(pActList,cc.Hide:create())
			-- if i == #self.pHeros then
			-- 	table.insert(pActList,cc.CallFunc:create(function (  )
	  -- 				self.pLine:setVisible(false)
	  --  			end))
			-- end
			-- if self:getIsShowEffect() then
				-- pHero:setGhostEffect()
			-- end
			pHero:stopAllActions()
			pHero:runAction(cc.Sequence:create(pActList))
		end
	end
end

--获取唯一id
function Line:getId()
	return self.nId
end

--获取样式类型
function Line:getLineType()
	return self.nLineType
end

--获取长度
function Line:getLength()
	return self.fLength
end

--获取地图起始点ccp
function Line:getFStartP(  )
	return self.pFStartP
end

--获取地图结束点ccp
function Line:getFEndP(  )
	return self.pFEndP
end

--获取移动中的英雄数据
function Line:getArmyNames()
	local tRes = {}
	if self.bIsMine then
		local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.nId)
		if tTaskMsg then
			--按顺序队伍
			for i=1,#tTaskMsg.tArmy do
				local pHeroData = getHeroDataById(tTaskMsg.tArmy[i])
				if pHeroData then
					table.insert(tRes, pHeroData.sName)
				end
			end
		end
	elseif self.bIsTLBoss or self.bIsEpw then
		--TLBoss行军路线没有英雄
	else
		local tTaskMovePush = Player:getWorldData():getTaskMovePushByUuid(self.nId)
		if tTaskMovePush then
			--npc显示或非友军显示名字
			if tTaskMovePush:getIsNpc() or self.nLineType ~= e_type_line.yellow then
				table.insert(tRes, tTaskMovePush.sName)
			else
				--友军显示武将名字
				for i=1,#tTaskMovePush.tHeroId do
					local nHeroId = tTaskMovePush.tHeroId[i]
					local tHero = getHeroDataById(nHeroId)
					if tHero then
						table.insert(tRes, tHero.sName)
					end
				end
			end
		end
	end
	return tRes
end
--判断是否是冥王
function Line:getIsGhost(  )
	-- body
	if self.bIsMine then

	elseif self.bIsTLBoss or self.bIsEpw then
		
	else
		--目前只有冥界入侵的冥王需要特效
		local tTaskMovePush = Player:getWorldData():getTaskMovePushByUuid(self.nId)
		if tTaskMovePush then
			return tTaskMovePush.nMt == 1 
		end
	end
end

--获取pLine
function Line:getLine( )
	return self.pLine
end

--获取线上的武将
function Line:getHeros( )
	return self.pHeros
end

--获取线路状态
function Line:getState(  )
	if self.bIsMine then
		local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.nId)
		if tTaskMsg then
			return tTaskMsg.nState
		end
	elseif self.bIsTLBoss or self.bIsEpw then

		--TLBoss行军路线为驻战
		return e_type_task_state.waitbattle
	else
		local tTaskMovePush = Player:getWorldData():getTaskMovePushByUuid(self.nId)
		if tTaskMovePush then
			return tTaskMovePush.nState
		end
	end
	return nil
end

--获取线路剩余移动cd
function Line:getCd(  )
	if self.bIsMine then
		local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.nId)
		if tTaskMsg then
			return tTaskMsg:getCd()
		end
	elseif self.bIsTLBoss or self.bIsEpw then
		--TLBoss行军路线驻战时间不定，暂为0
		return 0
	else
		local tTaskMovePush = Player:getWorldData():getTaskMovePushByUuid(self.nId)
		if tTaskMovePush then
			return tTaskMovePush:getCd()
		end
	end
	return 0
end

--获取线咱总共移动时间
function Line:getTotalCd(  )
	if self.bIsMine then
		local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.nId)
		if tTaskMsg then
			return tTaskMsg:getCdMax()
		end
	elseif self.bIsTLBoss or self.bIsEpw then
		--TLBoss行军路线驻战时间不定，暂为1
		return 1
	else
		local tTaskMovePush = Player:getWorldData():getTaskMovePushByUuid(self.nId)
		if tTaskMovePush then
			return tTaskMovePush:getCdMax()
		end
	end
	return 1
end

function Line:getEndKey( )
	return self.sEndKey
end

function Line:getCreateTime( )
	return self.nCreateTime
end

return Line