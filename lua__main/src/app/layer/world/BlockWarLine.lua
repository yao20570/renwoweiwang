----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-22 11:32:02
-- Description: 
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

-- local LINE_LENGTH2 = 4
-- local LINE_WIDTH2 = 4

local BlockLine = require("app.layer.world.BlockLine")
local BlockWarLine = class("BlockWarLine",function ( )
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--
function BlockWarLine:ctor( pSize )
	self:setContentSizeEx(pSize)
	--我的初始化
    self:myInit()
end

--设置大小扩展
function BlockWarLine:setContentSizeEx(pSize)
	self.pSize = pSize
    --设置大小
    self:setContentSize(pSize)
end
--初始化
function BlockWarLine:myInit(  )
	self:setupViews()
	self:onResume()
	self:updateViews()
	--注册析构方法
	self:setDestroyHandler("BlockWarLine",handler(self, self.onBlockWarLineDestroy))
end

function BlockWarLine:onBlockWarLineDestroy()
	self:onPause()
end

function BlockWarLine:setupViews()
	--路线数据
	self.tLines = {}
	-- self.batchNodeGreenLine = display.newBatchNode("ui/world/v1_img_xjlxziji.png", 1000)
	-- self.batchNodeGreenLine:setPosition(0,0)
	-- self:addView(self.batchNodeGreenLine, 99)
	--设置相机渲染高于远近视角
	-- WorldFunc.setHighCameraMaskForView(self.batchNodeGreenLine)
end

function BlockWarLine:onResume()
	--注册监听
	self:regMsgs()

	-- --快速移动
	-- self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
	-- 	self:warLineMove()
	-- end,0.5)
	--刷新监听
	regUpdateControl(self, handler(self, self.updateViews))
end

function BlockWarLine:onPause()
	--去掉监听
	self:unregMsgs()

	-- --去掉监听刷新
	-- if self.nUpdateScheduler then
	--     MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	--     self.nUpdateScheduler = nil
	-- end

	unregUpdateControl(self)
end

function BlockWarLine:regMsgs( )
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.updateViews))
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews))
end

function BlockWarLine:unregMsgs( )
	unregMsg(self, gud_world_my_city_pos_change_msg)
	unregMsg(self, gud_world_task_change_msg)
end

function BlockWarLine:updateViews()
	self:updateTasks()
	-- self:warLineMove()
end

--删除行路
function BlockWarLine:delLine( nId )
	local tLine = self.tLines[nId]
	if tLine then
		tLine:releaseLine()
		self.tLines[nId] = nil
	end
end

--路线进行移动
function BlockWarLine:warLineMove(  )
	--每一帧改变位置
	for k,tLine in pairs(self.tLines) do
		tLine:updateLine()
	end
end

function BlockWarLine:updateTasks(  )
	if not self.nBlockId then
		return
	end

	--将要消除的键
	local tDelKeys = {}
	for sUuid,tLine in pairs(self.tLines) do
		local nState = tLine:getState()
		if WorldFunc.getIsShowLine(nState) then
			if tLine:checkIsChanged() then
				myprint("BlockWarLine 起始位置或终点位置不同或方向不同就删除线路")
				table.insert(tDelKeys, sUuid)
			end
		else
			myprint("BlockWarLine 不是前往或返回状态就删除线路")
			table.insert(tDelKeys, sUuid)
		end
	end

	--删除不存在的任务线路
	for i=1,#tDelKeys do
		self:delLine(tDelKeys[i])
	end

	--创建新的任务线路
	local tTaskMsgs = Player:getWorldData():getTaskMsgs()
	for sUuid,tTaskMsg in pairs(tTaskMsgs) do
		if WorldFunc.getIsShowLineTask(tTaskMsg) then
			if not self.tLines[sUuid] then
				local nX, nY = Player:getWorldData():getMyCityDotPos()
				if tTaskMsg:getIsBotAnGo() then
					nX = tTaskMsg:getBoX()
					nY = tTaskMsg:getBoY()
				end
				self:addLine(sUuid, nX, nY, tTaskMsg.nTargetX, tTaskMsg.nTargetY)
			end
		end
	end
end

-- --获取路线
-- --nLength 长度
-- function BlockWarLine:getAAirline( nLength)
-- 	local pBatchNode = self.batchNodeGreenLine 

-- 	--获取纹理
-- 	local texture = pBatchNode:getTexture()
-- 	--设置平铺纹理
-- 	texture:setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)--( 0x2601, 0x2601, 0x2901, 0x2901)

-- 	--长度要取图片长度的倍数，不然平铺时最后面会截断
-- 	nLength = math.ceil(nLength/LINE_LENGTH2) * LINE_LENGTH2

-- 	local pSprite = nil
-- 	--测试时分割长度最大值，如果实际长度超过这个值，不分割的话会出现奇怪的问题
-- 	local nSubLenght = 300 * LINE_LENGTH2
-- 	if nLength <= nSubLenght then
-- 		pSprite = cc.Sprite:createWithTexture(texture, cc.rect(0, 0, nLength, LINE_WIDTH2))
-- 	else
-- 		local nCount = math.floor(nLength/nSubLenght)
-- 		local nLastLenght = nLength - nSubLenght * nCount
-- 		-- dump({nCount, nLastLenght})
-- 		--生成第一条
-- 		pSprite = cc.Sprite:createWithTexture(texture, cc.rect(0, 0, nSubLenght, LINE_WIDTH2))
-- 		--生成n条
-- 		local nBeginX = nSubLenght
-- 		for i=1,nCount - 1 do
-- 			local pSprite2 = cc.Sprite:createWithTexture(texture, cc.rect(0, 0, nSubLenght, LINE_WIDTH2))
-- 			pSprite2:setAnchorPoint(cc.p(0,0))
-- 			pSprite2:setPositionX(nBeginX)	
-- 			pSprite:addChild(pSprite2)
-- 			nBeginX = nBeginX + nSubLenght
-- 		end
-- 		--生成最后一条
-- 		if nLastLenght > 0 then
-- 			local pSprite2 = cc.Sprite:createWithTexture(texture, cc.rect(0, 0, nLastLenght, LINE_WIDTH2))
-- 			pSprite2:setAnchorPoint(cc.p(0,0))
-- 			pSprite2:setPositionX(nBeginX)
-- 			pSprite:addChild(pSprite2)
-- 		end
-- 	end
-- 	pSprite:setAnchorPoint(cc.p(0,0.5))
-- 	pBatchNode:addChild(pSprite)
-- 	return pSprite
-- end

--获取路线
--nLength 长度
function BlockWarLine:getAAirline( nLength)	
	local pImgLine =  MUI.MImage.new("ui/world/v1_line_jglx.png") 
	pImgLine:setScaleX(nLength/pImgLine:getContentSize().width)
	self:addView(pImgLine)
	pImgLine:setAnchorPoint(cc.p(0,0.5))
	return pImgLine
end

--增加线路
function BlockWarLine:addLine( nId, nRow1 ,nCol1, nRow2, nCol2)
	if not self.nBlockId then
		return
	end

	local fStartX,fStartY = WorldFunc.getMapPosByDotPos(nRow1, nCol1)
	if not fStartX then
		return
	end
	local fEndX,fEndY = WorldFunc.getMapPosByDotPos(nRow2, nCol2)
	if not fEndX then
		return
	end

	local fBlockSX, fBlockSY = WorldFunc.parseWorldToBlock(self.pSize, fStartX, fStartY)
	if not fBlockSX then
		return
	end
	local fBlockEX, fBlockEY = WorldFunc.parseWorldToBlock(self.pSize, fEndX, fEndY)
	if not fBlockEX then
		return
	end

	--防止重复加入
	if self.tLines[nId] then
		self:delLine(nId)
	end

	local nBlockId = WorldFunc.getBlockId(nRow1 ,nCol1)
	local nBlockId2 = WorldFunc.getBlockId(nRow2 ,nCol2)
	local bIsInBlock1 = self.nBlockId == nBlockId
	local bIsInBlock2 = self.nBlockId == nBlockId2
	if bIsInBlock1 or bIsInBlock2 then
		--加入
		local tData = {
			nId = nId,
			nStartX = nRow1,
			nStartY = nCol1,
			nEndX = nRow2,
			nEndY = nCol2,
			fStartX = fStartX,
			fStartY = fStartY,
			fEndX = fEndX,
			fEndY = fEndY,
		}
		local tLine = BlockLine.new(tData)
		tLine:setLine(self, self.nBlockId, self.pSize)
		self.tLines[nId] = tLine
	end
end


--线路根据变化而变化
function BlockWarLine:setBlockId( nBlockId )
	if self.nBlockId ~= nBlockId then
		self.nBlockId = nBlockId
		--清空所有
		for sUuid,tLine in pairs(self.tLines) do
			tLine:releaseLine()
		end
		self.tLines = nil
		--重新生成
		self.tLines = {}
		self:updateViews()
	end
end

return BlockWarLine