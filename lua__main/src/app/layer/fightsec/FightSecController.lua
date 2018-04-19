-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-12 17:21:13 星期二
-- Description: 战斗控制管理类
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local FightSecTeamLayer = require("app.layer.fightsec.FightSecTeamLayer")

local FightSecController = class("FightSecController")

-- _fightLayer：FightLayer
-- _pLayFight：战斗显示层
function FightSecController:ctor( _fightLayer, _pLayFight )
	-- body
	self:myInit()

	if not _fightLayer then
		return
	end
	if not _pLayFight then
		return
	end

	self.pFightLayer = _fightLayer
	self.pLayFight = _pLayFight

	self.tReport = self.pFightLayer:getReport()
	if not self.tReport then
		return
	end
	-- dump(self.tReport, "self.tReport")
	--战斗指令集合
	self.tFightOrders = self.tReport.acts 
	-- dump(self.tFightOrders,"self.tFightOrders=",100)
	self.nFightType = self.tReport.t --战报类型
	self.bIsTLBoss = self.nFightType == e_fight_report.tlboss

	self:setupViews()
	self:onResume()

end

--初始化成员变量
function FightSecController:myInit(  )
	-- body
	self.pFightLayer 		= 			nil 		--FightLayer
	self.pLayFight 			= 			nil 		--战斗显示层（战斗详情表现）
	self.tReport 			= 			nil 		--战报数据
	self.tFightOrders 		= 			nil 		--战斗回合标志指令集合

	self.tBLastShowMark 	= 			{}  		--最后加载展示的队伍相关数据（下方）
	self.tBTeamLayers 		= 			{} 			--队列teamlayer集合，做循环利用（下方）
	self.pBCurTeamlayer 	= 			nil 		--当前处于混战区的队伍（下方）
	self.pBFreeTeamlayer 	= 			nil 		--当前处理空闲状态下的队伍（下方）
	self.nBPreTeamKind 		= 			1 			--上一支武将带队的类型（下方）

	self.tTLastShowMark 	= 			{}  		--最后加载展示的队伍相关数据（上方）
	self.tTTeamLayers 		= 			{} 			--队列teamlayer集合，做循环利用（上方）
	self.pTCurTeamlayer 	= 			nil 		--当前处于混战区的队伍（上方）
	self.pTFreeTeamlayer 	= 			nil 		--当前处理空闲状态下的队伍（上方）
	self.nTPreTeamKind 		= 			1 			--上一支武将带队的类型（上方）


	self.nCurOrderIndex 	= 			1 			--当前播放的指令下标
	self.nCurBOrderIndex 	= 			0 			--当前下标播放到第几条指令（下方）
	self.nCurTOrderIndex 	= 			0 			--当前下标播放到第几条指令（上方）

	self.nCheckCount 		= 			0 			--指令校验计数器（2：表现校验成功，可以播放当前指令了）

	self.nZorderTeamLayer 	= 			20 			--teamlayer的zorder值
	self.nZorderBloodLayer 	= 			4000 		--飘字层的zorder值
end

--初始化控件
function FightSecController:setupViews( )
	-- body
end

-- 修改控件内容或者是刷新控件数据
function FightSecController:updateViews(  )
	-- body
	--先解析下方对战阵容
	if self.tReport.ous and table.nums(self.tReport.ous) > 0 then
		local nCurIndex = 1
		local tPrePos = cc.p(0,0) --上一只队伍的坐标
		for k, heroteam in pairs (self.tReport.ous) do --按武将解析
			if heroteam.tHeroInfo and heroteam.tHeroInfo.nKind and heroteam.phxs and table.nums(heroteam.phxs) > 0 then
				for n, matrix in pairs (heroteam.phxs) do --按方阵解析
					local pTeamLayer = FightSecTeamLayer.new(1)
					local nX = 0
					local nY = 0
					if nCurIndex == 1 then
						--计算位置(中点位置-偏移量-teamlayer的大小)
						nX = __fightCenterX - __fStartOffsetX - pTeamLayer:getWidth() / 2 
						    - tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].x * (nCurIndex  -1)
						nY = __fightCenterY - __fStartOffsetY - pTeamLayer:getHeight() / 2
						    - tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].y * (nCurIndex  -1)
						--保存位置值
						tPrePos.x = nX
						tPrePos.y = nY
						--保存当前该武将带队的类型
						self.nBPreTeamKind = heroteam.tHeroInfo.nKind
					else
						--计算位置(中点位置-偏移量-teamlayer的大小)
						if n == 1 then --如果是第一条队列 则则需要使用武将外的间隔
							nX = tPrePos.x - tTeamOutSpaceOffset[tostring(self.nBPreTeamKind .. "_" .. heroteam.tHeroInfo.nKind)].x 
							nY = tPrePos.y - tTeamOutSpaceOffset[tostring(self.nBPreTeamKind .. "_" .. heroteam.tHeroInfo.nKind)].y 
							--保存当前该武将带队的类型
							self.nBPreTeamKind = heroteam.tHeroInfo.nKind
						else
							nX = tPrePos.x - tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].x 
							nY = tPrePos.y - tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].y 
						end
					    --保存位置值
					    tPrePos.x = nX
					    tPrePos.y = nY
					end
					
					--设置位置
					pTeamLayer:setPosition(nX, nY)
					--赋值操作
					pTeamLayer:setCurDatas(k,n,heroteam.tHeroInfo.nKind,heroteam.who)
					--注册攻击回调
					pTeamLayer:setAttackHandler(handler(self, self.onAttackCallBack))
					--注册死亡回调
					pTeamLayer:setDeathHandler(handler(self, self.onDeathCallBack))
					--注册对方受击回调
					pTeamLayer:setHurtHandler(handler(self, self.onHurtHandler))
					--注册蓄力回调播放技能
					pTeamLayer:setGatherHandler(handler(self, self.onGatherHandler))

					self.pLayFight:addView(pTeamLayer,self.nZorderTeamLayer + nCurIndex)
					--保存在列表中(每次都插入到第一)
					table.insert(self.tBTeamLayers, 1, pTeamLayer)
					nCurIndex = nCurIndex + 1
					--记录最后加载的下标索引值
					self.tBLastShowMark.nTeam = k
					self.tBLastShowMark.nMatrix = n
					if nCurIndex > __nMaxShowCt then 
						-- print("下--->跳出将内=====================================================")
						break
					end
				end
			end
			if nCurIndex > __nMaxShowCt then 
				-- print("下--->跳出将外-------------------------------------------")
				break
			end
		end
	end

	--解析上方对战阵容
	if self.tReport.dus and table.nums(self.tReport.dus) > 0 then
		local nCurIndex = 1
		local tPrePos = cc.p(0,0) --上一只队伍的坐标
		for k, heroteam in pairs (self.tReport.dus) do --按武将解析
			if heroteam.tHeroInfo and heroteam.tHeroInfo.nKind and heroteam.phxs and table.nums(heroteam.phxs) > 0 then
				for n, matrix in pairs (heroteam.phxs) do --按方阵解析
					local pTeamLayer = FightSecTeamLayer.new(2, self.nFightType)
					local nX = 0
					local nY = 0
					if nCurIndex == 1 then
						--计算位置(中点位置+偏移量+teamlayer的大小)
						nX = __fightCenterX + __fStartOffsetX + pTeamLayer:getWidth() / 2 
						    + tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].x * (nCurIndex  -1)
						nY = __fightCenterY + __fStartOffsetY + pTeamLayer:getHeight() / 2
						    + tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].y * (nCurIndex  -1)
						--保存位置值
						tPrePos.x = nX
						tPrePos.y = nY
						--保存当前该武将带队的类型
						self.nTPreTeamKind = heroteam.tHeroInfo.nKind
					else
						--计算位置(中点位置-偏移量-teamlayer的大小)
						if n == 1 then --如果是第一条队列 则则需要使用武将外的间隔
							nX = tPrePos.x + tTeamOutSpaceOffset[tostring(self.nTPreTeamKind .. "_" .. heroteam.tHeroInfo.nKind)].x 
							nY = tPrePos.y + tTeamOutSpaceOffset[tostring(self.nTPreTeamKind .. "_" .. heroteam.tHeroInfo.nKind)].y 
							--保存当前该武将带队的类型
							self.nTPreTeamKind = heroteam.tHeroInfo.nKind
						else
							--计算位置(中点位置-偏移量-teamlayer的大小)
							nX = tPrePos.x + tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].x 
							nY = tPrePos.y + tTeamInSpaceOffset[tostring(heroteam.tHeroInfo.nKind)].y 
						end
					    --保存位置值
					    tPrePos.x = nX
					    tPrePos.y = nY
					end
					
					--设置位置
					pTeamLayer:setPosition(nX, nY)
					--赋值操作
					pTeamLayer:setCurDatas(k,n,heroteam.tHeroInfo.nKind,heroteam.who)
					--注册攻击回调
					pTeamLayer:setAttackHandler(handler(self, self.onAttackCallBack))
					--注册死亡回调
					pTeamLayer:setDeathHandler(handler(self, self.onDeathCallBack))
					--注册对方受击回调
					pTeamLayer:setHurtHandler(handler(self, self.onHurtHandler))
					--注册蓄力回调播放技能
					pTeamLayer:setGatherHandler(handler(self, self.onGatherHandler))
					--TLBoss一开始是隐藏的
					if self.bIsTLBoss then
						pTeamLayer:setVisible(false)
					end


					self.pLayFight:addView(pTeamLayer,self.nZorderTeamLayer - nCurIndex)
					--保存在列表中(每次都插入到第一)
					table.insert(self.tTTeamLayers, 1, pTeamLayer)
					nCurIndex = nCurIndex + 1
					--记录最后加载的下标索引值
					self.tTLastShowMark.nTeam = k
					self.tTLastShowMark.nMatrix = n
					if nCurIndex > __nMaxShowCt then 
						-- print("上--->跳出将内=====================================================")
						break
					end
				end
			end
			if nCurIndex > __nMaxShowCt then 
				-- print("上--->跳出将外-------------------------------------------")
				break
			end
		end
	end

	--开始战斗
	self:start()
end

--更新队伍(补上最后一排)
function FightSecController:updateTeamLayers( _nDir )
	-- body
	if _nDir == 1 then --下方
		if self.tBLastShowMark and self.pBFreeTeamlayer then --存在标准和空闲的队伍layer层
			--判断武将内是否还有队伍
			local nTeam = self.tBLastShowMark.nTeam
			local nMatrix = self.tBLastShowMark.nMatrix + 1

			if self.tBTeamLayers[1] then --至少存在一队
				local bFind = false
				if self.tReport.ous[nTeam] 
					and self.tReport.ous[nTeam].phxs 
					and self.tReport.ous[nTeam].phxs[nMatrix] then --存在队伍
					--计算位置(中点位置-偏移量-teamlayer的大小)
					local nX = self.tBTeamLayers[1]:getPositionX() - self.pBFreeTeamlayer:getWidth() / 2 
					    - tTeamInSpaceOffset[tostring(self.tReport.ous[nTeam].tHeroInfo.nKind)].x 
					local nY = self.tBTeamLayers[1]:getPositionY() - self.pBFreeTeamlayer:getHeight() / 2
					    - tTeamInSpaceOffset[tostring(self.tReport.ous[nTeam].tHeroInfo.nKind)].y 
					--设置位置
					self.pBFreeTeamlayer:setPosition(nX, nY)
					--赋值操作
					self.pBFreeTeamlayer:setCurDatas(nTeam,nMatrix,self.tReport.ous[nTeam].tHeroInfo.nKind,self.tReport.ous[nTeam].who)
					--展示
					self.pBFreeTeamlayer:setVisible(true)
					--插入到第一项
					table.insert(self.tBTeamLayers, 1, self.pBFreeTeamlayer)
					--保存索引值
					self.tBLastShowMark.nTeam = nTeam
					self.tBLastShowMark.nMatrix = nMatrix
					--标志找到了
					bFind = true 
				end

				if not bFind then --武将内已经没有队伍了
					local nNextTeam = nTeam + 1
					if self.tReport.ous[nNextTeam] 
						and self.tReport.ous[nNextTeam].phxs 
						and self.tReport.ous[nNextTeam].phxs[1] then --存在队伍
						
						--计算位置(中点位置-偏移量-teamlayer的大小)
						local nX = self.tBTeamLayers[1]:getPositionX() - self.pBFreeTeamlayer:getWidth() / 2 
						    - tTeamOutSpaceOffset[tostring(self.nBPreTeamKind .. "_" .. self.tReport.ous[nNextTeam].tHeroInfo.nKind)].x 
						local nY = self.tBTeamLayers[1]:getPositionY() - self.pBFreeTeamlayer:getHeight() / 2
						    - tTeamOutSpaceOffset[tostring(self.nBPreTeamKind .. "_" .. self.tReport.ous[nNextTeam].tHeroInfo.nKind)].y 
						--设置位置
						self.pBFreeTeamlayer:setPosition(nX, nY)
						--赋值操作
						self.pBFreeTeamlayer:setCurDatas(nNextTeam,1,self.tReport.ous[nNextTeam].tHeroInfo.nKind,self.tReport.ous[nNextTeam].who)
						--展示
						self.pBFreeTeamlayer:setVisible(true)
						--插入到第一项
						table.insert(self.tBTeamLayers, 1, self.pBFreeTeamlayer)
						--保存索引值
						self.tBLastShowMark.nTeam = nNextTeam
						self.tBLastShowMark.nMatrix = 1
						--标志找到了
						bFind = true 
						--保存当前该武将带队的类型
						self.nBPreTeamKind = self.tReport.ous[nNextTeam].tHeroInfo.nKind
					end
				end
			end
		end
	elseif _nDir == 2 then --上方
		if self.tTLastShowMark and self.pTFreeTeamlayer then --存在标准和空闲的队伍layer层
			--判断武将内是否还有队伍
			local nTeam = self.tTLastShowMark.nTeam
			local nMatrix = self.tTLastShowMark.nMatrix + 1
			if self.tTTeamLayers[1] then --至少存在一队
				local bFind = false
				if self.tReport.dus[nTeam] 
					and self.tReport.dus[nTeam].phxs 
					and self.tReport.dus[nTeam].phxs[nMatrix] then --存在队伍
					--计算位置(中点位置-偏移量-teamlayer的大小)
					local nX = self.tTTeamLayers[1]:getPositionX() + self.pTFreeTeamlayer:getWidth() / 2 
					    + tTeamInSpaceOffset[tostring(self.tReport.dus[nTeam].tHeroInfo.nKind)].x 
					local nY = self.tTTeamLayers[1]:getPositionY() + self.pTFreeTeamlayer:getHeight() / 2
					    + tTeamInSpaceOffset[tostring(self.tReport.dus[nTeam].tHeroInfo.nKind)].y 
					--设置位置
					self.pTFreeTeamlayer:setPosition(nX, nY)
					--赋值操作
					self.pTFreeTeamlayer:setCurDatas(nTeam,nMatrix,self.tReport.dus[nTeam].tHeroInfo.nKind)
					--展示
					self.pTFreeTeamlayer:setVisible(true)
					--插入到第一项
					table.insert(self.tTTeamLayers, 1, self.pTFreeTeamlayer)
					--保存索引值
					self.tTLastShowMark.nTeam = nTeam
					self.tTLastShowMark.nMatrix = nMatrix
					--标志找到了
					bFind = true 
				end
				if not bFind then --武将内已经没有队伍了
					local nNextTeam = nTeam + 1
					if self.tReport.dus[nNextTeam] 
						and self.tReport.dus[nNextTeam].phxs 
						and self.tReport.dus[nNextTeam].phxs[1] then --存在队伍
						
						--计算位置(中点位置-偏移量-teamlayer的大小)
						local nX = self.tTTeamLayers[1]:getPositionX() + self.pTFreeTeamlayer:getWidth() / 2 
						    + tTeamOutSpaceOffset[tostring(self.nTPreTeamKind .. "_" .. self.tReport.dus[nTeam].tHeroInfo.nKind)].x 
						local nY = self.tTTeamLayers[1]:getPositionY() + self.pTFreeTeamlayer:getHeight() / 2
						    + tTeamOutSpaceOffset[tostring(self.nTPreTeamKind .. "_" .. self.tReport.dus[nTeam].tHeroInfo.nKind)].y 
						--设置位置
						self.pTFreeTeamlayer:setPosition(nX, nY)
						--赋值操作
						self.pTFreeTeamlayer:setCurDatas(nNextTeam,1,self.tReport.dus[nNextTeam].tHeroInfo.nKind)
						--展示
						self.pTFreeTeamlayer:setVisible(true)
						--插入到第一项
						table.insert(self.tTTeamLayers, 1, self.pTFreeTeamlayer)
						--保存索引值
						self.tTLastShowMark.nTeam = nNextTeam
						self.tTLastShowMark.nMatrix = 1
						--标志找到了
						bFind = true 
						--保存当前该武将带队的类型
						self.nTPreTeamKind = self.tReport.dus[nNextTeam].tHeroInfo.nKind
					end
				end
			end
		end
	end
	
end

-- 注册消息
function FightSecController:regMsgs( )
	-- body
end

-- 注销消息
function FightSecController:unregMsgs(  )
	-- body
end


--暂停方法
function FightSecController:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightSecController:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

--开始播放战斗
function FightSecController:start(  )
	-- body

	--战斗开始前动画
	local sName = createAnimationBackName("tx/fight_normal/", "sg_zd_zdks_001")
    local pArm = ccs.Armature:create(sName)
    pArm:getAnimation():play("Animation1", -1, -1)
    pArm:setPosition(self.pFightLayer:getContentSize().width/2,self.pFightLayer:getContentSize().height/2)
    self.pFightLayer:addChild(pArm,10)
    pArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
		if (eventType == MovementEventType.COMPLETE) then
			-- 播放战斗呐喊音效
			Sounds.playEffect(Sounds.Effect.tFight.huanjing)

			--展示跳过战斗按钮
			self.pFightLayer:setBtnFastVisible(true)
			-- 执行动画效果
			local actionScaleTo = cc.ScaleTo:create(3.2, __fEScale)
			local actionEnd = cc.CallFunc:create(function (  )
				-- body
			end)
			local startActions = cc.Sequence:create(actionScaleTo,actionEnd)
			self.pLayFight:runAction(startActions)
			--下方部队进场
			self:showEnterFight(1)
			--上方部队进场
			self:showEnterFight(2)
		end
	end)
	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.opening)

end

--展示进场过程
--_nDir: 1：下方 2：上方
function FightSecController:showEnterFight( _nDir )
	-- body
	if _nDir == 1 and self.tBTeamLayers and table.nums(self.tBTeamLayers) > 0 then
		local nSize = table.nums(self.tBTeamLayers)
		local tPos = nil --最终的位置
		local tOffset = cc.p(0,0) --第一排后面队伍移动的偏移值
		local fDelayTime = 0
		local nIndex = 1
		for i = nSize, 1, -1 do
			local pTeamLayer = self.tBTeamLayers[i]
			if pTeamLayer then
				--计算位置
				if i == nSize then           --要进去混战区的
					tPos = cc.p(__fightCenterX - __fFightOffsetX, __fightCenterY - __fFightOffsetY)
					self:moveToPos(1,pTeamLayer,0,tPos,1)
					
					local tData = pTeamLayer:getCurData()
					if tData then
						local tMsgName = {}
						tMsgName.nDir = _nDir
						tMsgName.sWho = tData.sWho
						sendMsg(ghd_fight_sec_king_msg, tMsgName)
					end
				else
					if i == (nSize - 1) then   --要到达待命区
						tPos = cc.p(__fightCenterX - __fStandOffsetX, __fightCenterY - __fStandOffsetY)
						tOffset = cc.p(tPos.x - pTeamLayer:getPositionX(),tPos.y - pTeamLayer:getPositionY())
						self:moveToPos(1,pTeamLayer,0.38,tPos,2)
					elseif i == 1 then          --最后一队
						fDelayTime = 0.38 + (nIndex - 2) * 0.17
						tPos = cc.p(pTeamLayer:getPositionX() + tOffset.x, pTeamLayer:getPositionY() + tOffset.y)
						self:moveToPos(1,pTeamLayer,fDelayTime,tPos,4)
					else 						--后面的队伍
						fDelayTime = 0.38 + (nIndex - 2) * 0.17
						tPos = cc.p(pTeamLayer:getPositionX() + tOffset.x, pTeamLayer:getPositionY() + tOffset.y)
						self:moveToPos(1,pTeamLayer,fDelayTime,tPos,3)
					end
				end 
				nIndex = nIndex + 1
			end
		end
	elseif _nDir == 2 and self.tTTeamLayers and table.nums(self.tTTeamLayers) > 0 then 
		local nSize = table.nums(self.tTTeamLayers)
		local tPos = nil --最终的位置
		local tOffset = cc.p(0,0) --第一排后面队伍移动的偏移值
		local fDelayTime = 0
		local nIndex = 1
		for i = nSize, 1, -1 do
			local pTeamLayer = self.tTTeamLayers[i]
			if pTeamLayer then
				--计算位置
				if i == nSize then           --要进去混战区的
					tPos = cc.p(__fightCenterX + __fFightOffsetX, __fightCenterY + __fFightOffsetY)
					self:moveToPos(2,pTeamLayer,0,tPos,1)
				else
					if i == (nSize - 1) then   --要到达待命区
						tPos = cc.p(__fightCenterX + __fStandOffsetX, __fightCenterY + __fStandOffsetY)
						tOffset = cc.p(pTeamLayer:getPositionX() - tPos.x, pTeamLayer:getPositionY() - tPos.y)
						self:moveToPos(2,pTeamLayer,0.38,tPos,2)
					elseif i == 1 then          --最后一队
						fDelayTime = 0.38 + (nIndex - 2) * 0.17
						tPos = cc.p(pTeamLayer:getPositionX() - tOffset.x, pTeamLayer:getPositionY() - tOffset.y)
						self:moveToPos(2,pTeamLayer,fDelayTime,tPos,4)
					else 						--后面的队伍
						fDelayTime = 0.38 + (nIndex - 2) * 0.17
						tPos = cc.p(pTeamLayer:getPositionX() - tOffset.x, pTeamLayer:getPositionY() - tOffset.y)
						self:moveToPos(2,pTeamLayer,fDelayTime,tPos,3)
					end
				end 
				nIndex = nIndex + 1
			end
		end
	else
		--发送消息通知战斗结束
		sendMsg(ghd_fight_play_end)
	end
end

--播放或者暂停音效
function FightSecController:playSoundByKind(_nKind, _nPlayOrStop )
	-- body
	if _nKind == 1 then
		if _nPlayOrStop == 1 then
			Sounds.playEffect(Sounds.Effect.tFight.xingjun01)
		else
			Sounds.stopEffect(Sounds.Effect.tFight.xingjun01)
		end

	elseif _nKind == 2 then
		if _nPlayOrStop == 1 then
			Sounds.playEffect(Sounds.Effect.tFight.xingjun02)
		else
			Sounds.stopEffect(Sounds.Effect.tFight.xingjun02)
		end
	end
end

--移动到某个位置
--_nType：1：表示进入到混战区队列 2：表示到达待命区的第一条队列 3：表示第二条队列后面的队列 4：表示最后一条队列
function FightSecController:moveToPos( _nDir, _pLayer, _fDelayTime, _tPos, _nType)
	-- body
	if _fDelayTime == 0 then
		--播放音效
		local nKind = _pLayer:getCurKind()

		local nSoundKind = 1 --1：表示xingjun01 2：表示xingjun02
		if nKind == 2 then
			nSoundKind = 2
		end

		if self.ncurSoundKind ~= nSoundKind then 
			self:playSoundByKind(self.ncurSoundKind,0)
			self.ncurSoundKind = nSoundKind
			self:playSoundByKind(nSoundKind,1)
		end
		
		--跑起来
		_pLayer:playArm(e_type_fight_sec_action.run)
		local func = __moveToPos
		if _nDir == 2 and self.bIsTLBoss then --是限时Boss就从上到下
			Sounds.playEffect(Sounds.Effect.jianglin)
			func = __tlBossUpAndDownToPos
		end
		func(_pLayer,_tPos,function (  )
			-- body
			-- 先显示方框
			_pLayer:playArm(e_type_fight_sec_action.stand)
			if _nDir == 1 then
				--标志处于混战区的队伍
				local cbFunc = function()
					self.pBCurTeamlayer = _pLayer
					--从列表中移除
					self.tBTeamLayers[table.nums(self.tBTeamLayers)] = nil
					-- print("到达混战区====")
					self.nCurBOrderIndex = self.nCurBOrderIndex + 1
					--根据指令播放战斗表现
					self:playActionByOrder(self.nCurBOrderIndex)
					--暂停音效
					if self.ncurSoundKind ~= 0 then
						self:playSoundByKind(self.ncurSoundKind,0)
						self.ncurSoundKind = 0
					end
						
					--发送消息展示顶部信息层
					local tMsgObj = self.pBCurTeamlayer:getCurData()
					tMsgObj.nState = 1
					sendMsg(ghd_fight_sec_show_msg_state, tMsgObj)
				end
				_pLayer:showBottomEff(cbFunc)
			elseif _nDir == 2 then
				--标志处于混战区的队伍
				local cbFunc = function()
					self.pTCurTeamlayer = _pLayer
					--从列表中移除
					self.tTTeamLayers[table.nums(self.tTTeamLayers)] = nil
					-- print("到达混战区====")
					self.nCurTOrderIndex = self.nCurTOrderIndex + 1
					--根据指令播放战斗表现
					self:playActionByOrder(self.nCurTOrderIndex)
					--暂停音效
					if self.ncurSoundKind ~= 0 then
						self:playSoundByKind(self.ncurSoundKind,0)
						self.ncurSoundKind = 0
					end

					--发送消息展示顶部信息层
					local tMsgObj = self.pTCurTeamlayer:getCurData()
					tMsgObj.nState = 1
					sendMsg(ghd_fight_sec_show_msg_state, tMsgObj)
				end
				_pLayer:showBottomEff(cbFunc)
			end
			
		end)
	else
		doDelayForSomething(_pLayer,function (  )
			-- body
		    --跑起来
			_pLayer:playArm(e_type_fight_sec_action.run)
			__moveToPos(_pLayer,_tPos,function (  )
				-- body
				if _nType == 2 then
					--可能只有两队兵就进入不到_nType == 4，在这里控制隐藏底框
				 	if (_pLayer.nDir == 1 and #self.tBTeamLayers <= 2) 
				 		or (_pLayer.nDir == 2 and #self.tTTeamLayers <= 2) then
				 		local abFunc = function()
							local tLyaer = nil
							if _pLayer.nDir == 1 then
								tLyaer = self.tBTeamLayers
								if self.pBCurTeamlayer then
									self.pBCurTeamlayer:hideBottomEff()
								end
							elseif _pLayer.nDir == 2 then
								tLyaer = self.tTTeamLayers
								if self.pTCurTeamlayer then
									self.pTCurTeamlayer:hideBottomEff()
								end
							end

							if tLyaer then
								for k, v in ipairs(tLyaer) do
									v:hideBottomEff()
								end
							end
						end
						_pLayer:showBottomEff(abFunc, true)
				 	else
				 		_pLayer:showBottomEff()
				 	end
				 	_pLayer:playArm(e_type_fight_sec_action.stand)
					-- print("第二队到达待命区====")
				elseif _nType == 4 then
					local abFunc = function()
						--最后一个到达底框开始隐藏横排底框
						local tLyaer = nil
						if _pLayer.nDir == 1 then
							tLyaer = self.tBTeamLayers
							if self.pBCurTeamlayer then
								self.pBCurTeamlayer:hideBottomEff()
							end
						elseif _pLayer.nDir == 2 then
							tLyaer = self.tTTeamLayers
							if self.pTCurTeamlayer then
								self.pTCurTeamlayer:hideBottomEff()
							end
						end

						if tLyaer then
							for k, v in ipairs(tLyaer) do
								v:hideBottomEff()
							end
						end
					end
					_pLayer:showBottomEff(abFunc, true)
					_pLayer:playArm(e_type_fight_sec_action.stand)
					-- print("最后一队到达待命区区====")
				else
					_pLayer:showBottomEff()
					_pLayer:playArm(e_type_fight_sec_action.stand)
					-- print("到其他待命区====")
				end
			end)
		end,_fDelayTime)
	end
	
	
end

--根据指令播放动作
--_nShowOrderIndex：需要表现的指令下标
function FightSecController:playActionByOrder( _nShowOrderIndex )
	-- body
	if _nShowOrderIndex == self.nCurOrderIndex then
		self.nCheckCount = self.nCheckCount + 1
		if self.nCheckCount == 2 then --2表示校验成功了，可以做表现
			self.nCheckCount = 0 --重置为0
			--获取当前指令数据
			local tOrderData = self:getCurOrder()
			if tOrderData then
				-- dump(tOrderData,"tOrderData=",100)
				if tOrderData == -1 then --表示战斗指令已经结束了
					print("战斗结束了---------------------end-----------------------")
				else
					--判断是否有技能
					if tOrderData.t == 1 then --有技能
						--优先判断上方技能（虽然战报里面双方都有技能的话是分开指令）
						if tOrderData.ds ~= 0 then --上方释放技能
							-- print("有技能--shang")
							--报招（技能名字）
							self.pFightLayer:callSkillName(2,tOrderData.ds)
							--释放技能方播放蓄力动作
							self.pTCurTeamlayer:gatherForSkill()
							--释放技能方表现普攻动作(跟蓄力同时播放)
							self.pTCurTeamlayer:playArm(e_type_fight_sec_action.attack)
							--受击方表现待机动作
							self.pBCurTeamlayer:playArm(e_type_fight_sec_action.stand)
						elseif tOrderData.os ~= 0 then --下方释放技能
							-- print("有技能--xia")
							--报招（技能名字）
							self.pFightLayer:callSkillName(1,tOrderData.os)
							--释放技能方播放蓄力动作
							self.pBCurTeamlayer:gatherForSkill()
							--释放技能方表现普攻动作
							self.pBCurTeamlayer:playArm(e_type_fight_sec_action.attack)
							--受击方表现待机动作
							self.pTCurTeamlayer:playArm(e_type_fight_sec_action.stand)
						end
					else 					--没有技能（双方各自执行一次攻击动作（普攻 or 强攻））
						--判断是否有暴击
						if tOrderData.dc == 1 then --受到暴击（下方）
							self.pTCurTeamlayer:playArm(e_type_fight_sec_action.thump)
						elseif tOrderData.om == 1 then --下方miss掉了
							self.pTCurTeamlayer:playArm(e_type_fight_sec_action.attack)
						else 					   --受到普攻（下方）
							self.pTCurTeamlayer:playArm(e_type_fight_sec_action.attack)
						end
						if tOrderData.oc == 1 then --受到暴击（上方）
							self.pBCurTeamlayer:playArm(e_type_fight_sec_action.thump)
						elseif tOrderData.dm == 1  then --上方miss掉了
							self.pBCurTeamlayer:playArm(e_type_fight_sec_action.attack)
						else                       --受到普攻（上方）
							self.pBCurTeamlayer:playArm(e_type_fight_sec_action.attack)

						end
					end
				end
			else
				print("战斗结束---------------------------")
			end
		end
	end

end

--动作表现回调
function FightSecController:onAttackCallBack( _pLayer, _nDir )
	-- body

	--获得当前指令数据
	local tCurOrderData = self:getCurOrder()
	if tCurOrderData and tCurOrderData ~= -1 then
		if _nDir == 1 then
			self.bBCallBacked = true --标志下方表现已经完成
			if tCurOrderData.t == 1 then --如果有技能，需要切换为待机动作
				self.pBCurTeamlayer:playArm(e_type_fight_sec_action.stand)
			end
		elseif _nDir == 2 then
			self.bTCallBacked = true --标志上方表现已经完成
			if tCurOrderData.t == 1 then --如果有技能，需要切换为待机动作
				self.pTCurTeamlayer:playArm(e_type_fight_sec_action.stand)
			end
		end

		--检测是否可以播放下一条指令
		self:checkIfCanNextOrder()
	end
end

--检测是否可以播放下一条指令
--_nForce：是否强制播放下一条指令
function FightSecController:checkIfCanNextOrder( _nForce )
	-- body
	if _nForce then
		self.bBCallBacked = true
		self.bTCallBacked = true
	end
	if self.bBCallBacked and self.bTCallBacked then
		self.bBCallBacked = false
		self.bTCallBacked = false

		local tCurOrderData = self:getCurOrder()
		if tCurOrderData and tCurOrderData ~= -1 then
			--可以认为当前指令已经播放完 自加1
			self:addSelfCurOrderIndex()

			--判断下方当前方阵是否死亡
			if tCurOrderData.ot == tCurOrderData.oh then --死亡
				self.pBFreeTeamlayer = self.pBCurTeamlayer --把队伍付给空闲
				self.pBFreeTeamlayer:playArm(e_type_fight_sec_action.death)
			else
				--播放待命动作
				self.pBCurTeamlayer:playArm(e_type_fight_sec_action.stand)
				--播放下一条指令
				self.nCurBOrderIndex = self.nCurBOrderIndex + 1
				self:playActionByOrder(self.nCurBOrderIndex)
			end
			--判断上方当前方阵是否死亡
			if tCurOrderData.dt == tCurOrderData.dh then --死亡
				self.pTFreeTeamlayer = self.pTCurTeamlayer --把队伍付给空闲
				self.pTFreeTeamlayer:playArm(e_type_fight_sec_action.death)
			else
				--播放待命动作
				self.pTCurTeamlayer:playArm(e_type_fight_sec_action.stand)
				--播放下一条指令
				self.nCurTOrderIndex = self.nCurTOrderIndex + 1
				self:playActionByOrder(self.nCurTOrderIndex)
			end
		end

		
	end
end

--死亡回调事件
function FightSecController:onDeathCallBack( _pLayer, _nDir )
	-- body
	if _nDir == 1 then
		--隐藏起来
		self.pBFreeTeamlayer:setVisible(false)
		self:updateTeamLayers(1)
		--下一个方阵进入混战区
		self:showEnterFight(1)

		--发送消息隐藏顶部信息层
		local tMsgObj = {}
		tMsgObj.nState = 2
		tMsgObj.nDir = _nDir
		sendMsg(ghd_fight_sec_show_msg_state, tMsgObj)
	elseif _nDir == 2 then
		--隐藏起来
		self.pTFreeTeamlayer:setVisible(false)
		self:updateTeamLayers(2)
		--下一个方阵进入混战区
		self:showEnterFight(2)
		--发送消息展示顶部信息层
		--发送消息隐藏顶部信息层
		local tMsgObj = {}
		tMsgObj.nState = 2
		tMsgObj.nDir = _nDir
		sendMsg(ghd_fight_sec_show_msg_state, tMsgObj)
	end
end

--受击回调事件（注意：这里的受击是指对方）会回调到这里都是普通受击
function FightSecController:onHurtHandler( _pLayer, _nDir, _nKind, _nType )
	--获取当前指令数据
	local tOrderData = self:getCurOrder()
	if tOrderData and tCurOrderData ~= -1  then
		if _nDir == 1 then
			
			--下方回调给上方做受击表现
			if tOrderData.t == 1 then --当前如果有技能，是需要播放技能受击表现的
			else
				self.bShowTipsT = true
				if tOrderData.dm ~= 1 then --没有miss
					self.pTCurTeamlayer:playHurtArm(_nKind,_nType)
				end
			end
			
		elseif _nDir == 2 then
			
			--上方回调给下方做受击表现
			if tOrderData.t == 1 then --当前如果有技能，是需要播放技能受击表现的
			else
				self.bShowTipsB = true
				if tOrderData.om ~= 1 then --没有miss
					self.pBCurTeamlayer:playHurtArm(_nKind,_nType)
				end
			end
			
		end
		if self.bShowTipsB and self.bShowTipsT then
			self.bShowTipsB = false
			self.bShowTipsT = false
			--展示飘血 暴击 miss 相关提示
			self:showMoreTips()
		end
	end
	
end

--蓄力回调播放技能
function FightSecController:onGatherHandler( _pLayer, _nDir )
	-- body
	if _nDir == 1 then
		--获得当前指令数据
		local tCurOrderData = self:getCurOrder()
		if tCurOrderData and tCurOrderData ~= -1 then
			--播放技能
			self:playSkillArm(tCurOrderData.os,_nDir,function (  )
				-- body
				-- print("下技能播放回调，可以执行下一条指令了....")
				--强制播放下一条指令
				self:checkIfCanNextOrder(true)
			end)
		end
		-- print("下方蓄力回调了，准备播放技能....")
	elseif _nDir == 2 then
		--获得当前指令数据
		local tCurOrderData = self:getCurOrder()
		if tCurOrderData and tCurOrderData ~= -1 then
			--播放技能
			self:playSkillArm(tCurOrderData.ds,_nDir,function (  )
				-- body
				--强制播放下一条指令
				self:checkIfCanNextOrder(true)
				-- print("上技能播放回调，可以执行下一条指令了....")
			end)
		end
		-- print("上方蓄力回调了，准备播放技能....")
	end
end

--技能表现
--nType:1：兵将技能 2：弓将技能 3：骑将技能
--nDir：1：下方 2：上方
--handler：技能结束回调事件
function FightSecController:playSkillArm( nType, nDir, handler )
	-- body
	if __bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end

	self.__nHandlerSkillEnd = handler
	--移除所有的技能
	self:removeAllSkillArms()
	if self.tAllSkillArms == nil then
		self.tAllSkillArms = {}
	end
	if nType == 1 then --兵将
		--展示兵将技能
		self:showBJSkill(nDir)
	elseif nType == 3 then --弓将
		--展示弓将技能
		self:showGJSkill(nDir)
	elseif nType == 2 then --骑将
		self:showQJSkill(nDir)
	end
end

--移除所有的技能表现
function FightSecController:removeAllSkillArms(  )
	-- body
	if self.tAllSkillArms and table.nums(self.tAllSkillArms) > 0 then
		local nSize = table.nums(self.tAllSkillArms)
		for i = nSize, 1, -1 do
			local pArm = self.tAllSkillArms[i]
			if pArm then
				if pArm.stopAllActions then
					pArm:stopAllActions()
				end
				if pArm.stop then --存在暂停方法
					pArm:stop()
				end
				pArm:setVisible(false)
				pArm:removeSelf()
				pArm = nil
				self.tAllSkillArms[i] = nil
			end
		end
		self.tAllSkillArms = nil
	end
end

--技能表现结束回调
function FightSecController:callBackForEndSkillShow( nArmType )
	-- body
	--回调结束事件
	if self.__nHandlerSkillEnd then
		self.__nHandlerSkillEnd()
	end
end

--步将技能
--nDir：上下方向
function FightSecController:showBJSkill( nDir )
	-- body
	--引入纹理
	addFightTextureByPlistName("tx/fight/p1_fight_skill_bj_001")

	self.nAllCountBaoJian = 5 --一共5把宝剑

	--配置五把剑的表现参数
	for i = 1, self.nAllCountBaoJian do
		local tParam = {}
		if i == 1 then
			tParam.fTime = 0
			if nDir == 1 then
				tParam.tPos = cc.p(__fightCenterX - 34 ,__fightCenterY + 39 )
			else
				tParam.tPos = cc.p(__fightCenterX + 34 ,__fightCenterY - 39 )
			end
			tParam.fScale = 0.7
		elseif i == 2 then
			tParam.fTime = 0.33
			if nDir == 1 then
				tParam.tPos = cc.p(__fightCenterX + 149 ,__fightCenterY - 16 )
			else
				tParam.tPos = cc.p(__fightCenterX - 149 ,__fightCenterY + 16 )
			end
			tParam.fScale = 0.6
		elseif i == 3 then
			tParam.fTime = 0.42
			if nDir == 1 then
				tParam.tPos = cc.p(__fightCenterX + 34 ,__fightCenterY + 24 )
			else
				tParam.tPos = cc.p(__fightCenterX - 34 ,__fightCenterY - 24 )
			end
			tParam.fScale = 0.8
		elseif i == 4 then
			tParam.fTime = 0.5
			if nDir == 1 then
				tParam.tPos = cc.p(__fightCenterX - 52 ,__fightCenterY + 76 )
			else
				tParam.tPos = cc.p(__fightCenterX + 52 ,__fightCenterY - 76 )
			end
			tParam.fScale = 0.6
		elseif i == 5 then
			tParam.fTime = 0.67
			if nDir == 1 then
				tParam.tPos = cc.p(__fightCenterX + 90 ,__fightCenterY - 16 )
			else
				tParam.tPos = cc.p(__fightCenterX - 90 ,__fightCenterY + 16 )
			end
			tParam.fScale = 0.9
		end
		tParam.nIndex = i --标志着第几把剑
		self:showBJOneJian(tParam,nDir)
	end 
	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.saber)
end

--一把剑技能表现
--_tParams：表现参数 以下为参数字段
--_fDelayTime：延迟多长时间
--_tPos：位置
--_fScale：缩放值

--_nDir：上下方向
function FightSecController:showBJOneJian( _tParams, _nDir )
	-- body
	if __bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	if not _tParams then
		print("五把剑的参数有错误.....")
		return
	end
	local fDelayTime = _tParams.fTime or 0
	local tPos = _tParams.tPos or cc.p(self.pLayFight:getWidth()/2, self.pLayFight:getHeight()/2)
	local fScale = _tParams.fScale or 1.0
	local nWhich = _tParams.nIndex or 1 --第几把剑
	--存放剑的层
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(2, 2)
	pLay:setPosition(tPos.x - pLay:getWidth() / 2, tPos.y - pLay:getHeight() / 2)
	self.pLayFight:addView(pLay, 100)
	--添加到列表中
	table.insert(self.tAllSkillArms, pLay)

	--播放一把剑
	doDelayForSomething(pLay, function (  )
		-- body
		for i = 1, 5 do
			local pArm = MArmatureUtils:createMArmature(
				tFightSecArmDatas["100_" .. i], 
				pLay, 
				10, 
				cc.p(pLay:getWidth() / 2, pLay:getHeight() / 2),
			    function ( _pArm )
			    	_pArm:setVisible(false)
			    	if _pArm.nIndex and _pArm.nIndex == 1 then
			    		--替换无效帧
			    		_pArm:stopForImg("ui/daitu.png")
			    	elseif _pArm.nIndex and _pArm.nIndex == 4 then
			    		-- _pArm:removeSelf()
			    		-- _pArm = nil

			    		-- if nWhich == self.nAllCountBaoJian then
			    			--表示已经结束了技能特效
			    			--回调结束事件(事件被受击还短，目前不采用这种方式)
			    			-- self:callBackForEndSkillShow(1)
			    		-- end
			    	end
			    	
			    end, Scene_arm_type.fight)
			if pArm then
				if i == 2 then --注册帧回调时间
					pArm:setFrameEventCallFunc(function ( nCurFrame )
						-- body
						if nCurFrame == 4 then
							self:shockFloorByType(1)
							if nWhich == 1 then --第一把剑
								if _nDir == 1 then --下方攻击  上方受击
									self.pTCurTeamlayer:playSkillHurtArm(function (  )
										-- body
										--回调结束事件
										self:callBackForEndSkillShow(1)
									end,function (  )
										-- body
										--展示飘血 暴击 miss 相关提示
										self:showMoreTips()
									end)
								elseif _nDir == 2 then --上方攻击 下方受击
									self.pBCurTeamlayer:playSkillHurtArm(function (  )
										-- body
										--回调结束事件
										self:callBackForEndSkillShow(1)
									end,function (  )
										-- body
										--展示飘血 暴击 miss 相关提示
										self:showMoreTips()
									end)
								end
							end
						end
					end)
				end
				pArm.nIndex = i 
				pLay:setScale(fScale)
				pArm:play(1)
			end
		end
	end,fDelayTime)
	
end


--弓将技能
--_nDir：1：下方 2：上方
function FightSecController:showGJSkill( _nDir )
	-- body
	self.nFinishCountJianShow = 0 --有多少支箭表现了
	self.nAllCountGongJian = 19 --总共有19支箭
	--引入纹理
	addFightTextureByPlistName("tx/fight/p1_fight_skill_gj_001")
	--随机19条箭
	for i = 1, self.nAllCountGongJian do
		local tPos = cc.p(0,0)
		if i >= 1 and i < 3 then --位置1
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 158 ,__fightCenterY + 19 )
			else
				tPos = cc.p(__fightCenterX + 158 ,__fightCenterY - 19 )
			end
		elseif i >= 3 and i < 6 then --位置2
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 16 ,__fightCenterY - 41 )
			else
				tPos = cc.p(__fightCenterX + 16 ,__fightCenterY + 41 )
			end
		elseif i >= 6 and i < 8 then --位置3
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 49 ,__fightCenterY - 2 )
			else
				tPos = cc.p(__fightCenterX + 49 ,__fightCenterY + 2 )
			end
		elseif i >= 8 and i < 10 then --位置4
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX + 59 ,__fightCenterY - 69 )
			else
				tPos = cc.p(__fightCenterX - 59 ,__fightCenterY + 69 )
			end
		elseif i >= 10 and i < 13 then --位置5
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 10 ,__fightCenterY - 4 )
			else
				tPos = cc.p(__fightCenterX + 10 ,__fightCenterY + 4 )
			end
		elseif i >= 13 and i < 16 then --位置6
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX + 29 ,__fightCenterY - 34 )
			else
				tPos = cc.p(__fightCenterX - 29 ,__fightCenterY + 34 )
			end
		elseif i >= 16 and i < 18 then --位置7
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 85 ,__fightCenterY + 3 )
			else
				tPos = cc.p(__fightCenterX + 85 ,__fightCenterY - 3 )
			end
		elseif i >= 18 and i < 20 then --位置8
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 125 ,__fightCenterY + 37 )
			else
				tPos = cc.p(__fightCenterX + 125 ,__fightCenterY - 37 )
			end
		end

		--x,y坐标在做-15至15的随机偏移值
		tPos.x = tPos.x + math.random(-15,15)
		tPos.y = tPos.y + math.random(-15,15)
		
		if _nDir == 1 then
			tPos.x = tPos.x + 15
			tPos.y = tPos.y + 218
		else
			tPos.x = tPos.x - 15
			tPos.y = tPos.y + 133
		end

		--参数
		local tParams = {}
		--随机坐标
		tParams.tPos = tPos
		--随机延迟时间
		tParams.fDelayTime = 1 * (math.random(1,10)) * 0.1
		--随机缩放值
		tParams.fScale = math.random(7,10) * 0.1
		--方向
		tParams.nDir = _nDir

		--播放特效
		self:showGJOneJian(tParams)
	end
	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.archer)
end

--射一箭技能表现
--_tParams：表现参数
function FightSecController:showGJOneJian( _tParams )
	-- body
	if __bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	if not _tParams then
		return
	end

	--参数初始化
	local fDelayTime = _tParams.fDelayTime or 0
	local tPos = _tParams.tPos or cc.p(self.pLayFight:getWidth()/2, self.pLayFight:getHeight()/2)
	local fScale = _tParams.fScale or 1.0
	local nDir = _tParams.nDir or 1
	--随机一个角度偏移量,然后计算角度
	local fRandomAngle = math.random(-2,2)
	local nDefaultAngle = -17 --默认下方偏移17度
	if nDir == 2 then
		nDefaultAngle = 15 --上方偏移15度
	end
	local fCurAngle = nDefaultAngle + fRandomAngle
	--存放箭的层
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(2, 2)
	pLay:setPosition(tPos.x - pLay:getWidth() / 2, tPos.y - pLay:getHeight() / 2)
	self.pLayFight:addView(pLay, 100)

	--添加到列表中
	table.insert(self.tAllSkillArms, pLay)

	doDelayForSomething(pLay,function (  )
		-- body
		local pArm = MArmatureUtils:createMArmature(
			tFightSecArmDatas["101_1"], 
			pLay, 
			10, 
			cc.p(pLay:getWidth() / 2, pLay:getHeight() / 2),
		    function ( _pArm )
		    	_pArm:setVisible(false)
		    	-- _pArm:removeSelf()
		    	-- _pArm = nil
		    end, Scene_arm_type.fight)
		if pArm then
			--注册帧回调事件
			pArm:setFrameEventCallFunc(function ( nCurFrame )
				-- body
				if nCurFrame == 5 then
					--播放地面爆炸
					self:showGJOneBombFloor(nDir, pLay, fCurAngle, fScale)
					--地面震动
					self:shockFloorByType(2)
					self.nFinishCountJianShow = self.nFinishCountJianShow + 1

					if self.nFinishCountJianShow == 1 then --第一支箭射下来
						if nDir == 1 then --下方攻击  上方受击
							self.pTCurTeamlayer:playSkillHurtArm(function (  )
								-- body
								--回调结束事件
								self:callBackForEndSkillShow(2)
							end,function (  )
								-- body
								--展示飘血 暴击 miss 相关提示
								self:showMoreTips()
							end)
						elseif nDir == 2 then --上方攻击 下方受击
							self.pBCurTeamlayer:playSkillHurtArm(function (  )
								-- body
								--回调结束事件
								self:callBackForEndSkillShow(2)
							end,function (  )
								-- body
								--展示飘血 暴击 miss 相关提示
								self:showMoreTips()
							end)
						end
					end

					if self.nFinishCountJianShow == self.nAllCountGongJian then
						self.nFinishCountJianShow = 0 --有多少支箭表现了
						--回调结束事件
						-- self:callBackForEndSkillShow(2)
					end
				end
			end)
			--角度旋转
			pArm:setRotation(fCurAngle)
			--设置缩放值
			pArm:setScale(fScale)
			pArm:play(1)
		end
	end,fDelayTime)
end

--射箭后地面爆炸特效
--_nDir：1：下方 2：上方
--_pLay：播放特效的层
--_fCurAngle：角度偏移量
--_fScale：缩放值
function FightSecController:showGJOneBombFloor( _nDir, _pLay, _fCurAngle, _fScale )
	-- body
	--根据旋转角度计算位置
	local fOffsetX = math.sin(math.rad(_fCurAngle)) * 198  --198为特效射箭的高度一半
	local fOffsetY = (1 - math.sin(math.rad(90 - _fCurAngle))) * 198 
	--计算位置
	local nPosX = _pLay:getWidth() / 2 - fOffsetX --默认下方 （-）
	if _nDir == 2 then --上方
		local nPosX = _pLay:getWidth() / 2 + fOffsetX --上方（+）
	end
	local nPosY = _pLay:getHeight() / 2 + fOffsetY
	local pArm = MArmatureUtils:createMArmature(
		tFightSecArmDatas["101_2"], 
		_pLay, 
		10, 
		cc.p(nPosX, nPosY),
	    function ( _pArm )
	    	_pArm:setVisible(false)
	    	-- _pArm:removeSelf()
	    	-- _pArm = nil
	    end, Scene_arm_type.fight)
	if pArm then
		_pLay:setScale(_fScale)
		pArm:play(1)
	end
end

--骑将技能
--_nDir：1：下方 2：上方
function FightSecController:showQJSkill( _nDir )
	-- body
	--引入纹理
	addFightTextureByPlistName("tx/fight/p1_fight_skill_qj_001")
	self.nAllCountMa = 7 --一共7只马
	for i = 1, self.nAllCountMa do
		--参数集合
		local tParams = {}
		if i == 1 then
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX + 9 ,__fightCenterY - 2 )
			else
				tPos = cc.p(__fightCenterX - 9 ,__fightCenterY + 2 )
			end
			tParams.fDelayTime = 0
		elseif i == 2 then
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 99 ,__fightCenterY + 45 )
			else
				tPos = cc.p(__fightCenterX + 99 ,__fightCenterY - 45 )
			end
			tParams.fDelayTime = 0.04
		elseif i == 3 then
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX + 35 ,__fightCenterY - 16 )
			else
				tPos = cc.p(__fightCenterX - 35 ,__fightCenterY + 16 )
			end
			tParams.fDelayTime = 0.15
		elseif i == 4 then
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX + 96 ,__fightCenterY - 47 )
			else
				tPos = cc.p(__fightCenterX - 96 ,__fightCenterY + 47 )
			end
			tParams.fDelayTime = 0.35
		elseif i == 5 then
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 8 ,__fightCenterY + 16 )
			else
				tPos = cc.p(__fightCenterX + 8 ,__fightCenterY - 16 )
			end
			tParams.fDelayTime = 0.45
		elseif i == 6 then
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX - 61 ,__fightCenterY + 23 )
			else
				tPos = cc.p(__fightCenterX + 61 ,__fightCenterY - 23 )
			end
			tParams.fDelayTime = 0.48
		elseif i == 7 then
			if _nDir == 1 then
				tPos = cc.p(__fightCenterX + 127 ,__fightCenterY - 49 )
			else
				tPos = cc.p(__fightCenterX - 127 ,__fightCenterY + 49 )
			end
			tParams.fDelayTime = 0.70
		end
		--标志第几只马
		tParams.nWhich = i
		tParams.fScale = math.random(70, 100) * 0.01
		if _nDir == 1 then
			tParams.tPos = cc.p(tPos.x - 20, tPos.y + 20)
		elseif _nDir == 2 then
			tParams.tPos = cc.p(tPos.x + 5, tPos.y + 10)
		end
		
		self:showQJOneMa(tParams,_nDir)
	end

	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.rider)

	--地面震动
	self:shockFloorByType(3)
	if _nDir == 1 then --下方攻击  上方受击
		self.pTCurTeamlayer:playSkillHurtArm(function (  )
			-- body
			--回调结束事件
			self:callBackForEndSkillShow(3)
		end,function (  )
			-- body
			--展示飘血 暴击 miss 相关提示
			self:showMoreTips()
		end)
	elseif _nDir == 2 then --上方攻击 下方受击
		self.pBCurTeamlayer:playSkillHurtArm(function (  )
			-- body
			--回调结束事件
			self:callBackForEndSkillShow(3)
		end,function (  )
			-- body
			--展示飘血 暴击 miss 相关提示
			self:showMoreTips()
		end)
	end
	
end

--一只马特效
--_tParams：参数集合
--_nDir：1：下方 2：上方
function FightSecController:showQJOneMa( _tParams, _nDir )
	-- body
	if __bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	if not _tParams then return end
	--初始化参数
	local tPos = _tParams.tPos or cc.p(self.pLayFight:getWidth()/2, self.pLayFight:getHeight()/2)
	local fScale = _tParams.fScale or 1
	local fDelayTime = _tParams.fDelayTime or 0
	local nWhich = _tParams.nWhich or 1 --第几只马

	--存放马的层
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(2, 2)
	pLay:setPosition(tPos.x - pLay:getWidth() / 2, tPos.y - pLay:getHeight() / 2)
	self.pLayFight:addView(pLay, 1000 - tPos.y + 100)

	--添加到列表中
	table.insert(self.tAllSkillArms, pLay)

	local sKey = "103_1"--下冲上
	local tEndPos = cc.p(200,100)
	if _nDir == 2 then --上冲下
		sKey = "102_1"
		tEndPos = cc.p(-200,-100)
	end

	doDelayForSomething(pLay,function (  )
		-- body
		local pArm = MArmatureUtils:createMArmature(
			tFightSecArmDatas[sKey], 
			pLay, 
			10, 
			cc.p(pLay:getWidth() / 2, pLay:getHeight() / 2),
		    function ( _pArm )
		    	_pArm:setVisible(false)
		    	-- _pArm:removeSelf()
		    	-- _pArm = nil
		    end, Scene_arm_type.fight)
		if pArm then
			--注册帧回调事件
			pArm:setFrameEventCallFunc(function ( nCurFrame )
				-- body
				if nCurFrame == 1 or nCurFrame == 4 or nCurFrame == 9 then --1,4,9帧回调光圈
					self:showLightRing(pLay,fScale)
				end
			end)
			--设置缩放值
			pLay:setScale(fScale)
			pArm:play(-1)

			--奔跑...
			local actionMoveBy = cc.MoveBy:create(0.7, tEndPos)
			--回调
			local fCallback = cc.CallFunc:create(function (  )
				-- body
				if pArm then
					pArm:setVisible(false)
					pArm:stop()
					-- pArm:removeSelf()
					-- pArm = nil

					--处理在受击回调的时候 回调下一条指令
					-- if nWhich == self.nAllCountMa then
					-- 	--回调结束事件
					-- 	self:callBackForEndSkillShow(3)
					-- end
				end
			end)
			--奔跑动作
			local actions = cc.Sequence:create(actionMoveBy,fCallback)
			--延迟时间干事情
			local doDelayThings = function ( fTime )
				-- body
				--1/5回调时间
				local fDelayAction = cc.DelayTime:create(fTime)
				local fCallBack = cc.CallFunc:create(function (  )
					-- body
					--火焰
					self:showFire(pLay,fScale)
					--地面烧焦
					self:showBurningFloor(pLay,fScale)
					
				end)
				local action = cc.Sequence:create(fDelayAction,fCallBack)
				return action
			end
			--延迟时间干事情  集合
			local actionsDo = cc.Sequence:create(doDelayThings(0.1),doDelayThings(0.7/4),doDelayThings(0.7/4),doDelayThings(0.7/4))
			--所有的动作
			local allActions = cc.Spawn:create(actions,actionsDo)
			pLay:runAction(allActions)
		end
	end,fDelayTime)

end


--马蹄光圈
function FightSecController:showLightRing( _pLay, _fScale )
	-- body
	if _bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	local pArm = MArmatureUtils:createMArmature(
		tFightSecArmDatas["103_2"], 
		self.pLayFight, 
		40, 
		cc.p(_pLay:getPositionX() + 29,_pLay:getPositionY()),
	    function ( _pArm )
	    	_pArm:setVisible(false)
	    	-- _pArm:removeSelf()
	    	-- _pArm = nil
	    end, Scene_arm_type.fight)
	if pArm then
		--添加到列表中
		table.insert(self.tAllSkillArms, pArm)
		pArm:setScale(_fScale or 1)
		pArm:play(1)
	end
end

--马蹄火焰
function FightSecController:showFire( _pLay, _fScale )
	-- body
	if _bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	local pArm = MArmatureUtils:createMArmature(
		tFightSecArmDatas["103_3"], 
		self.pLayFight, 
		30, 
		cc.p(_pLay:getPositionX(),_pLay:getPositionY()),
	    function ( _pArm )
	    	_pArm:setVisible(false)
	    	-- _pArm:removeSelf()
	    	-- _pArm = nil
	    end, Scene_arm_type.fight)
	if pArm then
		--添加到列表中
		table.insert(self.tAllSkillArms, pArm)
		pArm:setScale(_fScale or 1)
		pArm:play(1)
	end
end

--地面烧焦
function FightSecController:showBurningFloor( _pLay, _fScale )
	-- body
	if _bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	local pArm = MArmatureUtils:createMArmature(
		tFightSecArmDatas["103_4"], 
		self.pLayFight, 
		1, 
		cc.p(_pLay:getPositionX(),_pLay:getPositionY() - 15),
	    function ( _pArm )
	    	_pArm:setVisible(false)
	    	-- _pArm:removeSelf()
	    	-- _pArm = nil
	    end, Scene_arm_type.fight)
	if pArm then
		--添加到列表中
		table.insert(self.tAllSkillArms, pArm)
		pArm:setScale(_fScale or 1)
		pArm:play(1)
	end
end

--（地面震动）
--_nType:1：兵将技能 2：弓将技能 3：骑将技能
function FightSecController:shockFloorByType( _nType )
	-- body
	if not self.bShockFloor then
		self.bShockFloor = true --标志是否地面正在震动
		if _nType == 1 then
			local action1 = cc.MoveTo:create(0.04, cc.p(0, -3))
			local action2 = cc.MoveTo:create(0.04, cc.p(0, 2))
			local action3 = cc.MoveTo:create(0.05, cc.p(0, -2))
			local action4 = cc.MoveTo:create(0.04, cc.p(0, 0))
			local actionEnd = cc.CallFunc:create(function (  )
				-- body
				self.bShockFloor = false
			end)
			local actions = cc.Sequence:create(action1,action2,action3,action4,actionEnd)
			self.pLayFight:runAction(actions)
		elseif _nType == 2 then
			local action1 = cc.MoveTo:create(0.04, cc.p(0, -3))
			local action2 = cc.MoveTo:create(0.04, cc.p(0, 2))
			local action3 = cc.MoveTo:create(0.05, cc.p(0, -2))
			local action4 = cc.MoveTo:create(0.04, cc.p(0, 0))
			local actionEnd = cc.CallFunc:create(function (  )
				-- body
				self.bShockFloor = false
			end)
			local actions = cc.Sequence:create(action1,action2,action3,action4,actionEnd)
			self.pLayFight:runAction(actions)
		elseif _nType == 3 then
			local shockFloor = function (  )
				-- body
				local action1 = cc.MoveTo:create(0.083, cc.p(1, -4))
				local action2 = cc.MoveTo:create(0.087, cc.p(0, 0))
				local action3 = cc.MoveTo:create(0.08, cc.p(1, -4))
				local action4 = cc.MoveTo:create(0.08, cc.p(0, -1))
				local action5 = cc.MoveTo:create(0.08, cc.p(3, -4))
				local action6 = cc.MoveTo:create(0.09, cc.p(-1, 1))
				local action7 = cc.MoveTo:create(0.08, cc.p(2, -2))
				local action8 = cc.MoveTo:create(0.09, cc.p(1, -1))
				local action9 = cc.MoveTo:create(0.08, cc.p(1, -4))
				local action10 = cc.MoveTo:create(0.08, cc.p(1, -2))
				local action11 = cc.MoveTo:create(0.08, cc.p(0, 0))
				local actions = cc.Sequence:create(action1,action2,action3,action4,action5,action6,action7,action8,action9,action10,action11)
				return actions
			end
			local fCallBack = cc.CallFunc:create(function (  )
				-- body
				self.bShockFloor = false
			end)
			local allActions = cc.Sequence:create(shockFloor(),shockFloor(),fCallBack)
			self.pLayFight:runAction(allActions)
		end
		
	end
end

--展示飘血 暴击 miss 相关提示
function FightSecController:showMoreTips(  )
	-- body
	--获得当前指令数据
	local tCurOrderData = self:getCurOrder()
	if tCurOrderData and tCurOrderData ~= -1 then
		--发送消息掉血(下)
		if tCurOrderData.oh > 0 then --血量大于0，才发送消息
			local tObj = {}
			tObj.nDir = 1
			tObj.nDropBlood = tCurOrderData.oh
			sendMsg(ghd_fight_sec_blood_msg, tObj)
		end
		--发送消息掉血（上）
		if tCurOrderData.dh > 0 then --血量大于0，才发送消息
			local tObj = {}
			tObj.nDir = 2
			tObj.nDropBlood = tCurOrderData.dh
			sendMsg(ghd_fight_sec_blood_msg, tObj)
		end
		----------------------------------------------------------------------下方表现-------------------------------------------------------
		--飘字内容层
		if not self.pLayShowMsgB then
			self.pLayShowMsgB = MUI.MLayer.new()
			self.pLayFight:addView(self.pLayShowMsgB,self.nZorderBloodLayer)
		end
		local bShowB = true --是否需要展示
		--判断是否有闪避
		if tCurOrderData.om == 1 then --闪避
			if not self.pImgSbB then
				self.pImgSbB = self:getShowActionImage(1)
				self.pLayShowMsgB:addView(self.pImgSbB)
			end
			self.pImgSbB:setVisible(true)
			--暴击是否存在
			if self.pImgBJB and self.pImgBJB:isVisible() then
				self.pImgBJB:setVisible(false)
			end
			--掉血label是否存在
			if self.pLbBloodB and self.pLbBloodB:isVisible() then
				self.pLbBloodB:setVisible(false)
			end
			--设置大小和位置
			self.pImgSbB:setPosition(self.pImgSbB:getWidth() / 2, self.pImgSbB:getHeight() / 2)
			self.pLayShowMsgB:setLayoutSize(self.pImgSbB:getLayoutSize())
		elseif tCurOrderData.dc == 1 then    --暴击
			--判断是否有掉血
			if tCurOrderData.oh <= 0 then
				bShowB = false
			else
				if not self.pImgBJB then
					self.pImgBJB = self:getShowActionImage(2)
					self.pLayShowMsgB:addView(self.pImgBJB)
				end
				self.pImgBJB:setVisible(true)
				--掉血label是否存在
				if not self.pLbBloodB then
					self.pLbBloodB = self:getShowActionLabelAtlas()
					self.pLayShowMsgB:addView(self.pLbBloodB)
				end
				--闪避是否存在
				if self.pImgSbB and self.pImgSbB:isVisible() then
					self.pImgSbB:setVisible(false)
				end
				self.pLbBloodB:setVisible(true)
				--设置大小和位置
				self.pImgBJB:setPosition(self.pImgBJB:getWidth() / 2, self.pImgBJB:getHeight() / 2)
				--设置掉血值和位置
				self.pLbBloodB:setString(":" .. tCurOrderData.oh,false)
				self.pLbBloodB:setPosition(self.pImgBJB:getWidth() + self.pLbBloodB:getContentSize().width/2, 
					self.pImgBJB:getHeight() / 2)
				--设置大小
				self.pLayShowMsgB:setLayoutSize(self.pLbBloodB:getWidth() + self.pImgBJB:getWidth(), 
					self.pImgBJB:getHeight())
			end
			
		else 								--普通掉血
			--判断是否有掉血
			if tCurOrderData.oh <= 0 then
				bShowB = false
			else
				--是否存在闪避
				if self.pImgSbB then
					self.pImgSbB:setVisible(false)
				end
				--是否存在暴击
				if self.pImgBJB then
					self.pImgBJB:setVisible(false)
				end
				if not self.pLbBloodB then
					self.pLbBloodB = self:getShowActionLabelAtlas()
					self.pLayShowMsgB:addView(self.pLbBloodB)
				end
				self.pLbBloodB:setVisible(true)
				self.pLayShowMsgB:setLayoutSize(self.pLbBloodB:getLayoutSize())
				--设置掉血值和位置
				self.pLbBloodB:setString(":" .. tCurOrderData.oh)
				self.pLbBloodB:setPosition(self.pLbBloodB:getWidth() / 2, self.pLbBloodB:getHeight() / 2)
			end
			
		end

		if bShowB then
			--设置位置
			self.pLayShowMsgB:setPosition(__fightCenterX - self.pLayShowMsgB:getWidth() / 2 - 70,__fightCenterY ) 
			--展示飘字特效
			self:showMsgAction(self.pLayShowMsgB,1)
		end
		
		
		

		----------------------------------------------------------------------上方表现-------------------------------------------------------
		--飘字内容层
		if not self.pLayShowMsgT then
			self.pLayShowMsgT = MUI.MLayer.new() 
			self.pLayFight:addView(self.pLayShowMsgT,self.nZorderBloodLayer)
		end
		local bShowT = true --是否需要展示
		--判断是否有闪避
		if tCurOrderData.dm == 1 then --闪避
			if not self.pImgSbT then
				self.pImgSbT = self:getShowActionImage(1)
				self.pLayShowMsgT:addView(self.pImgSbT)
			end
			self.pImgSbT:setVisible(true)
			--暴击是否存在
			if self.pImgBJT and self.pImgBJT:isVisible() then
				self.pImgBJT:setVisible(false)
			end
			--掉血label是否存在
			if self.pLbBloodT and self.pLbBloodT:isVisible() then
				self.pLbBloodT:setVisible(false)
			end
			--设置大小和位置
			self.pImgSbT:setPosition(self.pImgSbT:getWidth() / 2, self.pImgSbT:getHeight() / 2)
			self.pLayShowMsgT:setLayoutSize(self.pImgSbT:getLayoutSize())
		elseif tCurOrderData.oc == 1 then    --暴击
			--判断是否有掉血
			if tCurOrderData.dh <= 0 then
				bShowT = false
			else
				if not self.pImgBJT then
					self.pImgBJT = self:getShowActionImage(2)
					self.pLayShowMsgT:addView(self.pImgBJT)
				end
				self.pImgBJT:setVisible(true)
				--掉血label是否存在
				if not self.pLbBloodT then
					self.pLbBloodT = self:getShowActionLabelAtlas()
					self.pLayShowMsgT:addView(self.pLbBloodT)
				end
				--闪避是否存在
				if self.pImgSbT and self.pImgSbT:isVisible() then
					self.pImgSbT:setVisible(false)
				end
				self.pLbBloodT:setVisible(true)
				--设置大小和位置
				self.pImgBJT:setPosition(self.pImgBJT:getWidth() / 2, self.pImgBJT:getHeight() / 2)
				--设置掉血值和位置
				self.pLbBloodT:setString(":" .. tCurOrderData.dh,false)
				self.pLbBloodT:setPosition(self.pImgBJT:getWidth() + self.pLbBloodT:getContentSize().width/2, 
					self.pImgBJT:getHeight() / 2)
				--设置大小
				self.pLayShowMsgT:setLayoutSize(self.pLbBloodT:getWidth() + self.pImgBJT:getWidth(), 
					self.pImgBJT:getHeight())
			end
			
		else 								--普通掉血
			--判断是否有掉血
			if tCurOrderData.dh <= 0 then
				bShowT = false
			else
				--是否存在闪避
				if self.pImgSbT then
					self.pImgSbT:setVisible(false)
				end
				--是否存在暴击
				if self.pImgBJT then
					self.pImgBJT:setVisible(false)
				end
				if not self.pLbBloodT then
					self.pLbBloodT = self:getShowActionLabelAtlas()
					self.pLayShowMsgT:addView(self.pLbBloodT)
				end
				self.pLbBloodT:setVisible(true)
				self.pLayShowMsgT:setLayoutSize(self.pLbBloodT:getLayoutSize())
				--设置掉血值和位置
				self.pLbBloodT:setString(":" .. tCurOrderData.dh)
				self.pLbBloodT:setPosition(self.pLbBloodT:getWidth() / 2, self.pLbBloodT:getHeight() / 2)
			end
			
		end
		if bShowT then
			--设置位置
			self.pLayShowMsgT:setPosition(__fightCenterX , __fightCenterY)
			--展示飘字特效
			self:showMsgAction(self.pLayShowMsgT,2)
		end
		
	end
end

--展示飘字特效方法
function FightSecController:showMsgAction( _pLayer, _nType )
	-- body
	_pLayer:stopAllActions()
	--设置初始缩放值和透明度
	_pLayer:setOpacity(255)
	_pLayer:setScale(0.33)
	_pLayer:setVisible(true)

	local nPosX1 = 76.5
	local nPosX2 = 1.3
	local nPosX3 = 9.4

	if _nType == 1 then
		nPosX1 = nPosX1 * -1 
		nPosX2 = nPosX2 * -1 
		nPosX3 = nPosX3 * -1 
	end
	--第一阶段
	local moveBy1  = cc.MoveBy:create(0.3, cc.p(nPosX1,17))
	local scaleTo1  = cc.ScaleTo:create(0.3, 1)
	local action1 = cc.Spawn:create(moveBy1,scaleTo1)
	--第二阶段
	local moveBy2  = cc.MoveBy:create(0.25, cc.p(nPosX2,3))
	--第三阶段
	local moveBy3  = cc.MoveBy:create(0.6, cc.p(nPosX3,12.7))
	local fadeOut3  = cc.FadeOut:create(0.6)
	local action3 = cc.Spawn:create(moveBy3,fadeOut3)

	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		_pLayer:setVisible(false)
	end)
	--执行actions
	local actions = cc.Sequence:create(action1, moveBy2,action3,actionEnd)
	_pLayer:runAction(actions)
end

--获得一张图片
--nType :1闪避 2：暴击
function FightSecController:getShowActionImage( nType)
	-- body
	local sNameImg = "#v1_font_fight_sb.png"
	if nType == 2 then
		sNameImg = "#v1_font_fight_bj.png"
	end
	local pImg = MUI.MImage.new(sNameImg)
	return pImg
end

--获得一个数字标签
function FightSecController:getShowActionLabelAtlas(  )
	-- body
	local pLabelAtlas = MUI.MLabelAtlas.new({text=":100", 
		png="ui/atlas/p1_atlas_fight_blood_t.png", pngw=20, pngh=32, scm=48})
	return pLabelAtlas
end


--获得当前的指令
function FightSecController:getCurOrder(  )
	-- body
	-- print("self.nCurOrderIndex=" .. self.nCurOrderIndex)
	if self.nCurOrderIndex > table.nums(self.tFightOrders) then
		print("当前战斗指令全部已经结束了")
		return -1
	end
	return self.tFightOrders[self.nCurOrderIndex] 
end

--指令下标自加
function FightSecController:addSelfCurOrderIndex(  )
	-- body
	self.nCurOrderIndex = self.nCurOrderIndex + 1
end

--停止战斗中所有的表现
function FightSecController:stopAllFightActions(  )
	-- body

	if self.tBTeamLayers then
		for k, v in pairs (self.tBTeamLayers) do
			v:stopAllActions()
			v:stopArm()
		end
	end
	if self.tTTeamLayers then
		for k, v in pairs (self.tTTeamLayers) do
			v:stopAllActions()
			v:stopArm()
		end
	end
	if self.pBCurTeamlayer then
		self.pBCurTeamlayer:stopAllActions()
		self.pBCurTeamlayer:stopArm()
	end
	if self.pTCurTeamlayer then
		self.pTCurTeamlayer:stopAllActions()
		self.pTCurTeamlayer:stopArm()
	end
	--停止所有的音效
	Sounds.stopAllFightEffect()
	if self.pFightLayer then
		self.pFightLayer:stopAllActions()
	end
end

return FightSecController
