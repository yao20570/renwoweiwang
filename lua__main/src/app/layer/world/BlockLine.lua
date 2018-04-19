----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-22 13:46:21
-- Description: 区域行军线
-----------------------------------------------------

local LINE_NUM = 10
local LINE_SIDE2 = 4/(LINE_NUM)

local BlockLine = class("BlockLine")
--
-- local tData = {
-- 	nId = ,
-- 	nStartX = ,
-- 	nStartY = ,
-- 	nEndX = ,
-- 	nEndY = ,
-- 	fStartX = ,
-- 	fStartY = ,
-- }
function BlockLine:ctor( tData )
	self.nId = tData.nId
	self.nStartX 	= tData.nStartX 
	self.nStartY 	= tData.nStartY 
	self.nEndX 		= tData.nEndX 	
	self.nEndY 		= tData.nEndY 	

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
	else
		self.fEndX 	= tData.fEndX 	
		self.fEndY 	= tData.fEndY 
	end

	self.pFStartP = cc.p(self.fStartX, self.fStartY)
	self.pFEndP = cc.p(self.fEndX, self.fEndY)

	self.nState = self:getState() 

	self.pLine = nil
end

--释放
function BlockLine:releaseLine()
	if self.pLine then
		self.pLine:removeFromParent(true)
		self.pLine = nil
	end
end

function BlockLine:getState( )
	local tTaskMsg = Player:getWorldData():getTaskMsgByUuid(self.nId)
	if tTaskMsg then
		return tTaskMsg.nState
	end
	return nil
end

--线路是否发生改变
function BlockLine:checkIsChanged( )
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
	return false
end


--设置线路
function BlockLine:setLine( pBloclWarLine, nBlockId, pSize)
	local pFStartP, pFEndP = self.pFStartP, self.pFEndP
	local nLength = nil --长度
	local pFBlockP = nil --起始点
	local nAngle = nil --角度
	--不同点就显示终点
	local nStartPBlockId = WorldFunc.getBlockIdByMapPos(pFStartP.x, pFStartP.y)
	local nEndPBlockId = WorldFunc.getBlockIdByMapPos(pFEndP.x, pFEndP.y)
	if nBlockId == nStartPBlockId and nBlockId == nEndPBlockId then
		--同区域点
		local fX1, fY1 = WorldFunc.parseWorldToBlock(pSize, pFStartP.x, pFStartP.y)
		local fX2, fY2 = WorldFunc.parseWorldToBlock(pSize, pFEndP.x, pFEndP.y)
		nLength = cc.pGetDistance(cc.p(fX1, fY1), cc.p(fX2, fY2))
		pFBlockP = cc.p(fX1, fY1)
		nAngle = getAngle(fX1, fY1, fX2, fY2)
	else
		nLength = cc.pGetDistance(self.pFStartP, self.pFEndP) * (pSize.width/BLOCK_BG_WIDTH)
		if nBlockId == nStartPBlockId then
			local fX1, fY1 = WorldFunc.parseWorldToBlock(pSize, pFStartP.x, pFStartP.y)
			pFBlockP = cc.p(fX1, fY1)
			nAngle = getAngle(pFStartP.x, pFStartP.y, pFEndP.x, pFEndP.y)
		elseif nBlockId == nEndPBlockId then
			local fX1, fY1 = WorldFunc.parseWorldToBlock(pSize, pFEndP.x, pFEndP.y)
			pFBlockP = cc.p(fX1, fY1)
			nAngle = getAngle(pFEndP.x, pFEndP.y, pFStartP.x, pFStartP.y)
		end
	end
	if nLength == nil or pFBlockP == nil or nAngle == nil then
		return
	end

	--设置线路
	local pLine = pBloclWarLine:getAAirline(nLength)
	pLine:setRotation(nAngle)
	pLine:setPosition(pFBlockP)
	self.pLine = pLine
end


return BlockLine