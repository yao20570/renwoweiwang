----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-03-28 11:44:17
-- Description: 行军路线层
-----------------------------------------------------
local Line = require("app.layer.world.Line")

--路线状态 
local e_type_line = {
	green = 1, --我方
	yellow = 2,--友方
	red = 3, --其他
}

--层次
local MCommonView = require("app.common.MCommonView")
local WarLine = class("WarLine",function ( )
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--
function WarLine:ctor( pSize, pWorldLayer )
    --设置大小
    self:setContentSize(pSize)
    --世界层
	self.pWorldLayer = pWorldLayer
	--我的初始化
    self:myInit()
end

--初始化
function WarLine:myInit(  )
	self:setupViews()
	self:onResume()
	self:updateViews()
	--注册析构方法
	self:setDestroyHandler("WarLine",handler(self, self.onWarLineDestroy))
end

function WarLine:onWarLineDestroy()
	self:onPause()
end

function WarLine:setupViews()
	--线路列表
	self.pSpriteLines = {}
	--路线数据
	self.tLines = {}
	-- --批处理纹理 （盟友协防 使用）
	-- if self.batchNodeYellowLine == nil then
	-- 	self.batchNodeYellowLine = display.newBatchNode("ui/world/v1_img_xjlxhuang.png", 1000)
	-- 	self.batchNodeYellowLine:setPosition(0,0)
	-- 	self:addChild(self.batchNodeYellowLine, -1)
	-- end
	-- --批处理纹理（遭受攻击 使用）
	-- if self.batchNodeRedLine == nil then
	-- 	self.batchNodeRedLine = display.newBatchNode("ui/world/v1_img_xjlxhong.png", 1000)
	-- 	self.batchNodeRedLine:setPosition(0,0)
	-- 	self:addChild(self.batchNodeRedLine, -1)
	-- end
	-- --批处理纹理（攻击矿点或基地 使用）
	-- if self.batchNodeGreenLine == nil then
	-- 	self.batchNodeGreenLine = display.newBatchNode("ui/world/v1_img_xjlxlv.png", 1000)
	-- 	self.batchNodeGreenLine:setPosition(0,0)
	-- 	self:addChild(self.batchNodeGreenLine, -1)
	-- end

	
	self.tFightArmDict = {}--战斗动画标识

	--分帧创建线路
	self.tRCreateIds = {}
end

function WarLine:onResume()
	--注册监听
	self:regMsgs()
	--刷新监听
	self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
		self:warLineMove()
		self:createLineOnFrame()
	end,0.2)

	--刷新监听
	regUpdateControl(self, handler(self, self.updateViews))
end

function WarLine:onPause()
	--去掉监听
	self:unregMsgs()
	--去掉监听刷新
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end

	unregUpdateControl(self)
end

function WarLine:regMsgs( )
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.updateViews))
	regMsg(self, gud_world_task_move_push_msg, handler(self, self.updateViews))
	regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews))
	regMsg(self, ghd_tlboss_line_change, handler(self, self.updateViews))
	regMsg(self, ghd_hide_wild_army_line, handler(self, self.hideWildArmyLine))
	regMsg(self, ghd_show_wild_army_line, handler(self, self.showWildArmyLine))
end

function WarLine:unregMsgs( )
	unregMsg(self, gud_world_my_city_pos_change_msg)
	unregMsg(self, gud_world_task_move_push_msg)
	unregMsg(self, gud_world_task_change_msg)
	unregMsg(self, ghd_hide_wild_army_line)
	unregMsg(self, ghd_show_wild_army_line)
	unregMsg(self, ghd_tlboss_line_change)
end

--新增行路
--tTaskMsg
function WarLine:addLineByTaskMsg( tTaskMsg )
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	if tTaskMsg:getIsBotAnGo() then
		nX = tTaskMsg:getBoX()
		nY = tTaskMsg:getBoY()
	end
	self:addLine(tTaskMsg.sUuid, nX, nY, tTaskMsg.nTargetX, tTaskMsg.nTargetY, e_type_line.green, 1, tTaskMsg.nType)
end

--新增世界移动数据
--tTaskMovePush
function WarLine:addLineByTaskMovePush( tTaskMovePush )
	local nLineType = e_type_line.red
	if tTaskMovePush.nCountry == Player:getPlayerInfo().nInfluence then
		nLineType = e_type_line.yellow
	end
	self:addLine(tTaskMovePush.sUuid, tTaskMovePush.nStartX, tTaskMovePush.nStartY, tTaskMovePush.nEndX, tTaskMovePush.nEndY, nLineType, nil, tTaskMovePush.nMt)
end

--新增TLBoss移动数据
function WarLine:addLineByPointVo( tPointVo, tBLocatVo)
	--屏蔽自己那条
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	if tPointVo:getX() == nX and tPointVo:getY() == nY then
		return
	end
	local nLineType = e_type_line.red
	if tPointVo:getCountry() == Player:getPlayerInfo().nInfluence then
		nLineType = e_type_line.yellow
	end
	self:addLine(tPointVo:getDotKey(), tPointVo:getX(), tPointVo:getY(), tBLocatVo:getX(), tBLocatVo:getY(), nLineType, 3)
end

--新增皇城战移动数据
function WarLine:addLineByEpangLineVo( tEpangLineVo )
	--屏蔽自己那条
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	if tEpangLineVo:getX() == nX and tEpangLineVo:getY() == nY then
		return
	end
	local nLineType = e_type_line.red
	if tEpangLineVo:getCountry() == Player:getPlayerInfo().nInfluence then
		nLineType = e_type_line.yellow
	end
	local tCityData = getWorldCityDataById(tEpangLineVo:getCityId())
	if tCityData then
		if tCityData.tCoordinate then
			local nEndX = tCityData.tCoordinate.x 
			local nEndY = tCityData.tCoordinate.y
			if nEndX and nEndY then
				self:addLine(tEpangLineVo:getId(), tEpangLineVo:getX(), tEpangLineVo:getY(), nEndX, nEndY, nLineType, 4)
			end
		end
	end
end


--增加线路
--nId:唯一值
--nRow1: 起始x坐标
--nCol: 起始Y坐标
--nRow2: 结束x坐标
--nCol2: 结束Y坐标
--nLineType：线颜色
--nFrom：1:我自己，2：其他人，3：tlboss行军路线, 4：决战皇城线路
--nTaskType: 任务类型
function WarLine:addLine( nId, nRow1 ,nCol1, nRow2, nCol2, nLineType, nFrom, nType)
	local fStartX,fStartY = self.pWorldLayer:getMapPosByDotPos(nRow1, nCol1)
	if not fStartX then
		return
	end
	local fEndX,fEndY = self.pWorldLayer:getMapPosByDotPos(nRow2, nCol2)
	if not fEndX then
		return
	end
	--防止重复加入
	if self.tLines[nId] then
		self:delLine(nId)
	end

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
		nLineType = nLineType,
		nFrom = nFrom,
		nTaskType = nType,
	}
	self.tLines[nId] = Line.new(tData)
end

--删除行路
function WarLine:delLine( nId )
	local tLine = self.tLines[nId]
	if tLine then
		tLine:releaseLine()
		self.tLines[nId] = nil
		self.tRCreateIds[nId] = nil
	end
end

--更新视图
function WarLine:updateViews(  )
	self:updateLine()
	self:createLineCheck()
end

--更新线
function WarLine:updateLine()
	--将要消除的键
	local tDelKeys = {}
	for sUuid,tLine in pairs(self.tLines) do
		local nState = tLine:getState()
		if WorldFunc.getIsShowLine(nState) then
			--起始位置或终点位置不同或方向不同就删除线路
			if tLine:checkIsChanged() then
				myprint("起始位置或终点位置不同或方向不同就删除线路")
				table.insert(tDelKeys, sUuid)
			end
		else
			myprint("不是前往或返回或者停留状态就删除线路")
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
			local pLine = self.tLines[sUuid]
			if not pLine then
				self:addLineByTaskMsg(tTaskMsg)
			else
				-- print("tTaskMsg:getIsQuick()=======",tTaskMsg:getIsQuick())
				if tTaskMsg:getIsQuick() then
					pLine:updateHeros() --更新武将
					tTaskMsg:setIsQuick(false)
				end
			end
		end
	end
	
	--创建新的任务推送线路
	local tTaskMovePushs = Player:getWorldData():getTaskMovePushs()
	-- dump(tTaskMovePushs,"warline 244")
	for sUuid,tTaskMovePush in pairs(tTaskMovePushs) do
		if tTaskMovePush.nPlayerId ~= Player:getPlayerInfo().pid then --( 除自己外的)
			if WorldFunc.getIsShowLineTask(tTaskMovePush) then
				local pLine = self.tLines[sUuid]
				if not pLine then
					self:addLineByTaskMovePush(tTaskMovePush)
				else
					-- print("tTaskMovePush:getIsQuick()=======",tTaskMovePush:getIsQuick())
					if tTaskMovePush:getIsQuick() then
						pLine:updateHeros() --更新武将
						tTaskMovePush:setIsQuick(false)
					end
				end
			end
		end
	end

	--创建新的Boss推送线路
	local nMyBlockId = Player:getWorldData():getMyCityBlockId()
	local tBLocatVo = Player:getTLBossData():getBLocatVo(nMyBlockId)
	if tBLocatVo then
		local tBossLineVo = Player:getTLBossData():getTLBossLines(nMyBlockId)
		if tBossLineVo then
			local tPointDict = tBossLineVo:getPoints()
			for sDotKey,tPointVo in pairs(tPointDict) do
				local pLine = self.tLines[sDotKey]
				if not pLine then
					self:addLineByPointVo(tPointVo, tBLocatVo)
				end
			end
		end
	end

	--创建新的皇城战推送线路
	local tPointDict = Player:getImperWarData():getLines()
	for sDotKey,tEpangLineVo in pairs(tPointDict) do
		local pLine = self.tLines[sDotKey]
		if not pLine then
			self:addLineByEpangLineVo(tEpangLineVo)
		end
	end
end

--路线进行移动
function WarLine:warLineMove(  )
	--每一帧改变位置
	for k,tLine in pairs(self.tLines) do
		tLine:updateLine()
	end
end

--创建线路检测
function WarLine:createLineCheck(  )
	local _pViewRect = self.pWorldLayer:getShowViewRect()
	local pViewRect = nil
	--为了远景地图视角加大显示，数字是手动测试出来的。。。
	if b_open_far_and_near_view_forworld then
		nX = _pViewRect.x - 100
		nY = _pViewRect.y - 100
		nW = _pViewRect.width + 200
		nH = _pViewRect.height + 200
		pViewRect = cc.rect(nX, nY, nW, nH)
	else
		pViewRect = _pViewRect
	end
	local pViewLines = {
		{cc.p(pViewRect.x, pViewRect.y), cc.p(pViewRect.x + pViewRect.width, pViewRect.y)},
		{cc.p(pViewRect.x + pViewRect.width, pViewRect.y), cc.p(pViewRect.x + pViewRect.width, pViewRect.y + pViewRect.height)},
		{cc.p(pViewRect.x + pViewRect.width, pViewRect.y + pViewRect.height), cc.p(pViewRect.x, pViewRect.y + pViewRect.height)},
		{cc.p(pViewRect.x, pViewRect.y), cc.p(pViewRect.x, pViewRect.y + pViewRect.height)},
	}
	--遍历线数据
	for k,tLine in pairs(self.tLines) do
		--我自己没有创建的才检测
		if tLine.bIsMine then
			if not tLine:getLine() then
				local pFStartP, pFEndP = tLine:getFStartP(), tLine:getFEndP()
				--是否在显示范围内
				local bIsIn = false
				for i=1,#pViewLines do
					local bIsTrue = pIsSegmentIntersectEx(pFStartP, pFEndP, pViewLines[i][1], pViewLines[i][2])
					if bIsTrue then
						bIsIn = true
						break
					end
				end
				if bIsIn == false then
					--判断是否都在视图矩形里
					if cc.rectContainsPoint(pViewRect, pFStartP) and
						cc.rectContainsPoint(pViewRect, pFEndP) then
						bIsIn = true
					end
				end
				if bIsIn then
					self:addReadyLine(tLine)
				end
			end
		else
			--如果有初始化的,但是不在范围内的就册掉线路显示，下次进来再创建
			if tLine:getLine() then
				local pFStartP, pFEndP = tLine:getFStartP(), tLine:getFEndP()
				--是否在显示范围外
				local bIsOut = true
				for i=1,#pViewLines do
					local bIsTrue = pIsSegmentIntersectEx(pFStartP, pFEndP, pViewLines[i][1], pViewLines[i][2])
					if bIsTrue then
						bIsOut = false
						break
					end
				end
				if bIsOut then
					--判断是否都在视图矩形里
					if cc.rectContainsPoint(pViewRect, pFStartP) and
						cc.rectContainsPoint(pViewRect, pFEndP) then
						bIsOut = false
					end
				end
				if bIsOut then
					tLine:releaseLine()
				end
			else--没有创建的才检测
				local pFStartP, pFEndP = tLine:getFStartP(), tLine:getFEndP()
				--是否在显示范围内
				local bIsIn = false
				for i=1,#pViewLines do
					local bIsTrue = pIsSegmentIntersectEx(pFStartP, pFEndP, pViewLines[i][1], pViewLines[i][2])
					if bIsTrue then
						bIsIn = true
						break
					end
				end
				if bIsIn == false then
					--判断是否都在视图矩形里
					if cc.rectContainsPoint(pViewRect, pFStartP) and
						cc.rectContainsPoint(pViewRect, pFEndP) then
						bIsIn = true
					end
				end
				if bIsIn then
					self:addReadyLine(tLine)
				end
			end
		end
	end
end

--分侦加载数据
function WarLine:addReadyLine( tLine )
	local nId = tLine:getId()
	if not self.tRCreateIds[nId] then
		self.tRCreateIds[nId] = true
	end
end

--分侦创建线路
function WarLine:createLineOnFrame( )
	--存在
	-- --当前已创建别人显示的线路数
	-- local nOtherLine = 0
	-- for k,tLine in pairs(self.tLines) do
	-- 	if not tLine.bIsMine and tLine:getLine() then
	-- 		nOtherLine = nOtherLine + 1
	-- 	end
	-- end
	-- local bIsOtherEnough = nOtherLine >= 100 --最大数
	-- --遍历
	-- for nId,v in pairs(self.tRCreateIds) do
	-- 	local tLine = self.tLines[nId]
	-- 	if tLine then
	-- 		if tLine.bIsMine then
	-- 			--每侦创建一条
	-- 			self:createLine(tLine)
	-- 			self.tRCreateIds[nId] = nil
	-- 			break
	-- 		else
	-- 			--超过数量不创建
	-- 			if not bIsOtherEnough then
	-- 				--每侦创建一条
	-- 				self:createLine(tLine)
	-- 				self.tRCreateIds[nId] = nil
	-- 				break
	-- 			end
	-- 		end
	-- 	else--不存在就删除
	-- 		self.tRCreateIds[nId] = nil
	-- 	end
	-- end

	--遍历,每侦创建一条
	for nId,_ in pairs(self.tRCreateIds) do
		local tLine = self.tLines[nId]
		if tLine then
			self:createLine(tLine)
			self.tRCreateIds[nId] = nil
			break
		else--不存在就删除
			self.tRCreateIds[nId] = nil
		end
	end
end



--检路创建
function WarLine:createLine( tLine )
	--创建线
	local fLength = tLine:getLength()
	local nId = tLine:getId()
	local nLineType = tLine:getLineType()
	local pLine = self:getAAirline(fLength, nId, nLineType)

	--创建武将
	local tHeroNames = tLine:getArmyNames()
	local pHeros = {}
	--武将测试
	for i=1,#tHeroNames do
		local WarLineHero = require("app.layer.world.WarLineHero")
		local pWarLineHero = WarLineHero.new(self)
		pWarLineHero:setName(tHeroNames[i])
		table.insert(pHeros, pWarLineHero)
	end
	--billBoard测试
	-- for i=1,#tHeroNames do
	-- 	local pBbNameBg = createCCBillBorad("#v1_img_namebg30.png",cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
	-- 	self:addChild(pBbNameBg)
	-- 	table.insert(pHeros, pBbNameBg)
	-- end

	tLine:setLine(pLine, pHeros)

	--返回的乱军动画线路在动画中不显示
	if tLine:getState() == e_type_task_state.back then
		local sEndKey = tLine:getEndKey()
		if self.tFightArmDict[sEndKey] then
			self:__hideWildArmyLine(tLine)
		end
	end
end

--隐藏行军线路
function WarLine:__hideWildArmyLine( tLine )
	if not tLine then
		return
	end

	local pLine = tLine:getLine()
	if pLine then
		--隐藏线路
		pLine:setVisible(false)
	end
	--涉及到武将本身需要逐个显示，就用透明来代替隐藏
	local pHeros = tLine:getHeros()
	if pHeros then
		for i=1,#pHeros do
			pHeros[i]:setOpacity(0)
		end
	end
end

--获取路线
--nLength 长度
--nTag 图片精灵的tag,这里更指是线路的id
--nType 线路的类型，决定了用哪个图片
function WarLine:getAAirline( nLength, nTag, nType)
	local sLineImg = nil
	if nType == e_type_line.green then
		sLineImg = "ui/world/v1_img_xjlxlv.png"
	elseif nType == e_type_line.red then
		sLineImg = "ui/world/v1_img_xjlxhong.png"
	elseif nType == e_type_line.yellow then
		sLineImg = "ui/world/v1_img_xjlxhuang.png"
	else
		sLineImg = "ui/world/v1_img_xjlxlv.png"
	end
	local pBatchNode = display.newTilesSprite(sLineImg, cc.rect(0, 0, nLength, 32))
	pBatchNode:setAnchorPoint(0, 0.5)
	self:addView(pBatchNode)
	WorldFunc.setCameraMaskForView(pBatchNode)

	return pBatchNode
end

-- --获取路线
-- --nLength 长度
-- --nTag 图片精灵的tag,这里更指是线路的id
-- --nType 线路的类型，决定了用哪个图片
-- function WarLine:getAAirline(nLength, nTag,nType)
-- 		--创建裁剪区域
-- 	local pLayLine = cc.ClippingNode:create() 
-- 	local nX, nY, nW, nH = 0,0, nLength, 32
-- 	local tPoint = {
-- 		{nX, nY}, 
-- 		{nX + nW, nY}, 
-- 		{nX + nW, nY + nH}, 
-- 		{nX, nY + nH},
-- 	}
-- 	local tColor = {
-- 		fillColor = cc.c4f(255, 0, 0, 255),
-- 	    borderWidth  = 1,
-- 	    borderColor  = cc.c4f(255, 0, 0, 255)
-- 	} 
-- 	stencil =  display.newPolygon(tPoint,tColor)
-- 	pLayLine:setStencil(stencil)
-- 	self:addView(pLayLine)
-- 	WorldFunc.setCameraMaskForView(pLayLine)

-- 	local sLineImg = nil
-- 	if nType == e_type_line.green then
-- 		sLineImg = "ui/world/v1_img_xjlxlv.png"
-- 	elseif nType == e_type_line.red then
-- 		sLineImg = "ui/world/v1_img_xjlxhong.png"
-- 	elseif nType == e_type_line.yellow then
-- 		sLineImg = "ui/world/v1_img_xjlxhuang.png"
-- 	else
-- 		sLineImg = "ui/world/v1_img_xjlxlv.png"
-- 	end
-- 	local pBatchNode = display.newTilesSprite(sLineImg, cc.rect(0, 0, nLength, 32))
-- 	pBatchNode:setAnchorPoint(cc.p(0,0))

-- 	if pLayLine.addView then
-- 		pLayLine:addView(pBatchNode)
-- 	else
-- 		pLayLine:addChild(pBatchNode)
-- 	end
-- 	pLayLine.pBatchNode = pBatchNode
-- 	WorldFunc.setCameraMaskForView(pBatchNode)

-- 	return pLayLine
-- end

--[[
--获取路线
--nLength 长度
--nTag 图片精灵的tag,这里更指是线路的id
--nType 线路的类型，决定了用哪个图片
function WarLine:getAAirline( nLength, nTag, nType)
	local sLineImg = nil
	if nType == e_type_line.green then
		sLineImg = "#v1_img_xjlxlv.png"
	elseif nType == e_type_line.red then
		sLineImg = "#v1_img_xjlxhong.png"
	elseif nType == e_type_line.yellow then
		sLineImg = "#v1_img_xjlxhuang.png"
	else
		sLineImg = "#v1_img_xjlxlv.png"
	end

	--创建裁剪区域
	local pLayLine = cc.ClippingNode:create() 
	local nX, nY, nW, nH = 0,0, nLength, 18
	local tPoint = {
		{nX, nY}, 
		{nX + nW, nY}, 
		{nX + nW, nY + nH}, 
		{nX, nY + nH},
	}
	local tColor = {
		fillColor = cc.c4f(255, 0, 0, 255),
	    borderWidth  = 1,
	    borderColor  = cc.c4f(255, 0, 0, 255)
	} 
	stencil =  display.newPolygon(tPoint,tColor)
	pLayLine:setStencil(stencil)
	self:addView(pLayLine)
	WorldFunc.setCameraMaskForView(pLayLine)

	--长度要取图片长度的倍数，不然平铺时最后面会截断
	nLength = math.ceil(nLength/LINE_LENGTH) * LINE_LENGTH

	--批处理
	local pBatchNode = display.newTiledBatchNode(sLineImg, "ui/p1_commonse3.png", cc.size(nLength,18), -LINE_MARGIN)
	pBatchNode:setAnchorPoint(cc.p(0,0))
	if pLayLine.addView then
		pLayLine:addView(pBatchNode)
	else
		pLayLine:addChild(pBatchNode)
	end
	pLayLine.pBatchNode = pBatchNode
	WorldFunc.setCameraMaskForView(pBatchNode)

	return pLayLine
end
]]--

--标记乱军行军线路隐藏
function WarLine:hideWildArmyLine( sMsgName, pMsgObj )
	if not pMsgObj then
		return
	end
	local sEndKey = pMsgObj
	self.tFightArmDict[sEndKey] = true

	--检测所有
	local tLastLine = nil --创建cd时间最新的一条line
	for k,tLine in pairs(self.tLines) do
		if tLine:getEndKey() == sEndKey then
			if tLine:getState() == e_type_task_state.back then
				if tLastLine then
					if tLastLine:getCreateTime() < tLine:getCreateTime() then
						tLastLine = tLine
					end
				else
					tLastLine = tLine
				end
			end
		end
	end
	if tLastLine then
		self:__hideWildArmyLine(tLastLine)
	end
end

--显示乱军行军线咱
function WarLine:showWildArmyLine( sMsgName, pMsgObj)
	if not pMsgObj then
		return
	end
	local sEndKey = pMsgObj
	--去掉标记
	self.tFightArmDict[sEndKey] = nil
	
	for k,tLine in pairs(self.tLines) do
		if tLine:getEndKey() == sEndKey then
			if tLine:getState() == e_type_task_state.back then
				local pLine = tLine:getLine()
				if not tolua.isnull(pLine) then
					--如果之前隐藏了就
					if not pLine:isVisible() then
						--显示线路
						pLine:setVisible(true)
						--设置武将透明度
						local pHeros = tLine:getHeros()
						if pHeros then
							for j=1,#pHeros do
								if not tolua.isnull(pHeros[j]) then
									pHeros[j]:setOpacity(255)
								end
							end
						end
						break
					end
				end
			end
		end
	end
end

return WarLine