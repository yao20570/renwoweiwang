-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-21 13:45:06 星期二
-- Description: 一个武将+N个方阵 （team）
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local FightMatrix = require("app.layer.fight.FightMatrix")


local FightTeamLayer = class("FightTeamLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function FightTeamLayer:ctor( _targer, _nType ,_tData, _nIndex)
	-- body
	self:myInit()
	if not _targer then
		print("FightTeamLayer._targer is nil")
		return
	end
	if not _nType then
		print("FightTeamLayer.方向没设置")
		return
	end

	if not _tData then
		print("FightTeamLayer.数据为nil")
		return
	end

	if not _nIndex then
		print("FightTeamLayer._nIndex不能为nil")
		return
	end

	self.pTarget = _targer
	self.nType = _nType 
	self.tCurTeam = _tData
	self.nIndex = _nIndex
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FightTeamLayer",handler(self, self.onFightTeamLayerDestroy))
end

--初始化成员变量
function FightTeamLayer:myInit(  )
	-- body
	self.pTarget 				= 			nil 			--父层级
	self.nType 					= 			1 				--1：下方   2：上方
	self.tCurTeam 				= 			nil 			--当前数据
	self.pTeamLayer 			= 			nil 			--team展示层
	self.pMHeroLayer 			= 			nil 			--武将方阵
	self.tMSoldierLayers 		= 			{} 				--小兵方阵集合
	self.nIndex 				= 			0 				--teamLayer的下标

	self.tCurFightSoldiers 		= 			{} 				--当前正在战斗的士兵方阵集合
	self.fAllCurBlood 			= 			0 				--当前在混战区域的总血量 
	self.nCurFindSoldierIndex 	= 			1 				--查找死亡小兵的当前下标

	self.nMaxZorder 			= 			10086 			--定义最上层的Zorder值
	self.nSpace 				= 			20				--方阵间隔(中间偏移量)
	self.nCurRow 				= 			1               --当前方阵执行动画的排下标
	self.moveVecHero 			= 			nil 			--当前正式战斗区 偏移量(武将)
	self.moveVecSC 		        =			nil 
	self.moveVecSC2 		    =     		nil 

	--下方team特有的字段（B）
	self.moveVecBHero 			= 			cc.p(142,82)   --正式战斗区 偏移量(武将)
	self.moveVecBSC 		    = 			cc.p(MATRIX_WIDTH_INSIDE / 2, MATRIX_HEIGHT_INSIDE / 2)
	--正式战斗区 偏移量(士兵中间)
	self.moveVecBSC2 		    = 			cc.p(MATRIX_WIDTH / 2, MATRIX_HEIGHT / 2)    --正式战斗区 偏移量(士兵中间)

	--上方team特有的字段（T）
	self.moveVecTHero 			= 			cc.p(-142,-82)   --正式战斗区 偏移量(武将)
	self.moveVecTSC 		    = 			cc.p(-MATRIX_WIDTH_INSIDE / 2, -MATRIX_HEIGHT_INSIDE / 2)
	--正式战斗区 偏移量(士兵中间)
	self.moveVecTSC2 		    = 			cc.p(-MATRIX_WIDTH / 2, -MATRIX_HEIGHT / 2)    --正式战斗区 偏移量(士兵中间)
end

--初始化控件
function FightTeamLayer:setupViews( )
	-- body

	if self.tCurTeam then
		if not self.pTeamLayer then
			--计算该显示层的大小
			local nRealM = self.tCurTeam.nMatrix + 1 --真实的方阵个数（武将+小兵）
			local nCeilCt = 2
			if nRealM <= 6 then
				if nRealM == 3 then --因为三个方阵的话 是形成一排（特殊处理）
					nCeilCt = 1
				elseif nRealM == 5 then
					nCeilCt = 3
				end
			else
				--判断是否是左边
				local nTt = nRealM % 3
				if nTt == 2 then
					nCeilCt = math.ceil(nRealM / 3) + 1
				else
					nCeilCt = math.ceil(nRealM / 3)
				end
			end
			local nTeamLayerW = (2 * MATRIX_WIDTH + (nCeilCt - 1) * MATRIX_WIDTH / 2 )
			local nTeamLayerH = (2 * MATRIX_HEIGHT + (nCeilCt - 1) * MATRIX_HEIGHT / 2 )
			self:setLayoutSize(nTeamLayerW, nTeamLayerH)
			self.pTeamLayer =  MUI.MLayer.new(false, {scale9=true}) 
			self.pTeamLayer:setViewTouched(false)
			-- self.pTeamLayer:setBackgroundImage("#v1_bg_1.png")
			self.pTeamLayer:setLayoutSize(nTeamLayerW, nTeamLayerH)
			self:addView(self.pTeamLayer)
			centerInView(self, self.pTeamLayer)
		end

		--武将方块
		if not self.pMHeroLayer then
			self.pMHeroLayer 	= FightMatrix.new(self.nType,1)
			self.pTeamLayer:addView(self.pMHeroLayer,self.nMaxZorder)
		end

		if self.nType == 1 then  --下方
			--武将设置位置
			self.pMHeroLayer:setPosition(self:getSoldierMatrixPos(0) or cc.p(0,0))
			self.pMHeroLayer:setCurData(self.tCurTeam)
			--设置士兵方阵
			-- for i = 1, self.tCurTeam.nMatrix do
			-- 	local pMSoldierLayer = FightMatrix.new(self.nType,2)
			-- 	local tPos, nSide = self:getSoldierMatrixPos(i) 
			-- 	pMSoldierLayer:setPosition(tPos)
			-- 	pMSoldierLayer.nIndex = i
			-- 	self.pTeamLayer:addView(pMSoldierLayer, self.nMaxZorder + i)
			-- 	pMSoldierLayer:setCurData(self.tCurTeam)
			-- 	pMSoldierLayer.nSide = nSide
			-- 	self.tMSoldierLayers[i] = pMSoldierLayer
			-- end

			--分帧设置加载士兵方阵
			self:scheduleOnceAddMatrix(self.tCurTeam.nMatrix)
		elseif self.nType == 2 then --上方
			--武将设置位置
			self.pMHeroLayer:setPosition(self:getSoldierMatrixPos(0) or cc.p(0,0))
			self.pMHeroLayer:setCurData(self.tCurTeam)

			--设置士兵方阵
			-- for i = 1, self.tCurTeam.nMatrix do
			-- 	local pMSoldierLayer = FightMatrix.new(self.nType,2)
			-- 	local tPos, nSide = self:getSoldierMatrixPos(i) 
			-- 	pMSoldierLayer:setPosition(tPos)
			-- 	pMSoldierLayer.nIndex = i
			-- 	self.pTeamLayer:addView(pMSoldierLayer, self.nMaxZorder + i)
			-- 	pMSoldierLayer:setCurData(self.tCurTeam)
			-- 	pMSoldierLayer.nSide = nSide
			-- 	self.tMSoldierLayers[i] = pMSoldierLayer
			-- end

			--分帧设置加载士兵方阵
			self:scheduleOnceAddMatrix(self.tCurTeam.nMatrix)
		end

		--偏移量赋值
		if self.nType == 1 then
			self.moveVecHero = cc.p(self.pMHeroLayer:getPositionX() + 142,self.pMHeroLayer:getPositionY() + 82)
			self.moveVecSC = self.moveVecBSC
			self.moveVecSC2 = self.moveVecBSC2
		elseif self.nType == 2 then
			self.moveVecHero = cc.p(self.pMHeroLayer:getPositionX() - 142,self.pMHeroLayer:getPositionY() - 82)
			self.moveVecSC = self.moveVecTSC
			self.moveVecSC2 = self.moveVecTSC2
		end

	end
end

-- 每帧加载方阵
function FightTeamLayer:scheduleOnceAddMatrix( nMax)
    local nIndex = 1
    self.nAddUnitScheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
    	local pMSoldierLayer = FightMatrix.new(self.nType,2)
    	local tPos, nSide = self:getSoldierMatrixPos(nIndex) 
    	pMSoldierLayer:setPosition(tPos)
    	pMSoldierLayer.nIndex = nIndex
    	self.pTeamLayer:addView(pMSoldierLayer, self.nMaxZorder + nIndex)
    	pMSoldierLayer:setCurData(self.tCurTeam)
    	pMSoldierLayer.nSide = nSide
    	self.tMSoldierLayers[nIndex] = pMSoldierLayer
    	nIndex = nIndex + 1

    	local tRstPos = __convertToGetRstPos(pMSoldierLayer)
    	if tRstPos then
    		if self.nType == 1 then
    			if tRstPos.x >= __nLimitBottom then
    				pMSoldierLayer:setNeedShowState(true)
    			else
    				pMSoldierLayer:setNeedShowState(false)
    				--插入检查集合中
    				table.insert(self.pTarget.tCheckShowLists, pMSoldierLayer)
    			end
    		elseif self.nType == 2 then
    			if tRstPos.x <= __nLimitTop then
    				pMSoldierLayer:setNeedShowState(true)
    			else
    				pMSoldierLayer:setNeedShowState(false)
    				--插入检查集合中
    				table.insert(self.pTarget.tCheckShowLists, pMSoldierLayer)
    			end
    		end
    	end
    	pMSoldierLayer:playArm(e_type_fight_action.run)
    	if self ~= nil and self.nAddUnitScheduler ~= nil and nIndex > nMax then
            MUI.scheduler.unscheduleGlobal(self.nAddUnitScheduler)
            self.nAddUnitScheduler = nil
            --判断是否需要开始（是否加载完）
            local sCurLoadKey = self.nType .. "_" .. self.nIndex
            if sCurLoadKey == self.pTarget.sEndLoadKey then
            	self.pTarget:start()
            end
            
    	end
    end)
end

-- 修改控件内容或者是刷新控件数据
function FightTeamLayer:updateViews(  )
	-- body
	if self.tCurTeam then


	end
end

-- 析构方法
function FightTeamLayer:onFightTeamLayerDestroy(  )
	-- body
	self:onPause()
	if self.nAddUnitScheduler then
        MUI.scheduler.unscheduleGlobal(self.nAddUnitScheduler)
        self.nAddUnitScheduler = nil
	end
end

-- 注册消息
function FightTeamLayer:regMsgs( )
	-- body
end

-- 注销消息
function FightTeamLayer:unregMsgs(  )
	-- body
end


--暂停方法
function FightTeamLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightTeamLayer:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

--获得士兵方阵位置
--return：tPos位置
--        nSide：对应e_matrix_side类型
function FightTeamLayer:getSoldierMatrixPos( _nIndex )
	-- body
	if not self.tCurTeam or not _nIndex then
		return
	end
	local nSide = e_matrix_side.center
	if self.tCurTeam.nMatrix < 6 then
		--如果武将所带方阵数量为2,第1个方阵需要修改到第3个方阵的位置
		if self.tCurTeam.nMatrix == 2 and _nIndex == 1  then
			_nIndex = 3
		end
		--如果武将所带方阵数量为4,第4个方阵需要修改到第6个方阵的位置
		if self.tCurTeam.nMatrix == 4 and _nIndex == 4  then
			_nIndex = 6
		end
	else
		--判断是否是左边
		local nTt = self.tCurTeam.nMatrix % 3
		if nTt == 1 and self.tCurTeam.nMatrix == _nIndex then
			_nIndex = _nIndex + 2
		end
	end
	
	local tPos = cc.p(0,0)
	if _nIndex < 6 then
		if self.nType == 1 then    --下方
			if _nIndex == 0 then --武将
				nSide = e_matrix_side.center
				tPos.x = self:getWidth() - 3 / 2 * MATRIX_WIDTH + self.nSpace
				tPos.y = self:getHeight() - 3 / 2 * MATRIX_HEIGHT + math.sqrt(self.nSpace * self.nSpace / 3) 
			elseif _nIndex == 1 then
				nSide = e_matrix_side.center
				tPos.x = self:getWidth() - 2 * MATRIX_WIDTH + self.nSpace
				tPos.y = self:getHeight() - 2 * MATRIX_HEIGHT +  math.sqrt(self.nSpace * self.nSpace / 3) 
			elseif  _nIndex == 2 then
				nSide = e_matrix_side.left
				tPos.x = self:getWidth() - 2 * MATRIX_WIDTH 
				tPos.y = self:getHeight() - MATRIX_HEIGHT 
			elseif  _nIndex == 3 then
				nSide = e_matrix_side.right
				tPos.x = self:getWidth() - MATRIX_WIDTH 
				tPos.y = self:getHeight() - 2 * MATRIX_HEIGHT 
			elseif  _nIndex == 4 then
				nSide =  e_matrix_side.left
				tPos.x = self:getWidth() - 5 / 2 * MATRIX_WIDTH 
				tPos.y = self:getHeight() - 3 / 2 * MATRIX_HEIGHT 
			elseif  _nIndex == 5 then
				nSide = e_matrix_side.right
				tPos.x = self:getWidth() - 3 / 2 * MATRIX_WIDTH 
				tPos.y = self:getHeight() - 5 / 2 * MATRIX_HEIGHT 
			end
		elseif self.nType == 2 then --上方
			if _nIndex == 0 then --武将
				nSide = e_matrix_side.center
				tPos.x = 1 / 2 * MATRIX_WIDTH - self.nSpace
				tPos.y = 1 / 2 * MATRIX_HEIGHT - math.sqrt(self.nSpace * self.nSpace / 3) 
			elseif _nIndex == 1 then
				nSide = e_matrix_side.center
				tPos.x = MATRIX_WIDTH - self.nSpace
				tPos.y = MATRIX_HEIGHT -  math.sqrt(self.nSpace * self.nSpace / 3) 
			elseif  _nIndex == 2 then
				nSide = e_matrix_side.left
				tPos.x = MATRIX_WIDTH 
				tPos.y = 0 
			elseif  _nIndex == 3 then
				nSide = e_matrix_side.right
				tPos.x = 0
				tPos.y = MATRIX_HEIGHT 
			elseif  _nIndex == 4 then
				nSide = e_matrix_side.left
				tPos.x = 3 / 2 * MATRIX_WIDTH 
				tPos.y = 1 / 2 * MATRIX_HEIGHT 
			elseif  _nIndex == 5 then
				nSide = e_matrix_side.right
				tPos.x = 1 / 2 * MATRIX_WIDTH 
				tPos.y = 3 / 2 * MATRIX_HEIGHT 
			end
		end

	else
		if self.nType == 1 then    --下方
			local nM = math.floor(_nIndex / 3)
			local nN = _nIndex % 3
			if nN == 0 then --中间
				nSide = e_matrix_side.center
				tPos.x = self:getWidth() - 2 * MATRIX_WIDTH - (nM - 1) / 2 * MATRIX_WIDTH + self.nSpace
				tPos.y = self:getHeight() - 2 * MATRIX_HEIGHT - (nM - 1) / 2 * MATRIX_HEIGHT +  math.sqrt(self.nSpace * self.nSpace / 3) 
			elseif nN == 1 then --左边
				nSide =  e_matrix_side.left
				tPos.x = self:getWidth() - 3 * MATRIX_WIDTH - (nM - 2) / 2 * MATRIX_WIDTH
				tPos.y = self:getHeight() - 2 * MATRIX_HEIGHT - (nM - 2) / 2 * MATRIX_HEIGHT
			elseif nN == 2 then --右边
				nSide = e_matrix_side.right
				tPos.x = self:getWidth() - 2 * MATRIX_WIDTH - (nM - 2) / 2 * MATRIX_WIDTH
				tPos.y = self:getHeight() - 3 * MATRIX_HEIGHT - (nM - 2) / 2 * MATRIX_HEIGHT
			end
		elseif self.nType == 2 then --上方
			local nM = math.floor(_nIndex / 3)
			local nN = _nIndex % 3
			if nN == 0 then --中间
				nSide = e_matrix_side.center
				tPos.x = MATRIX_WIDTH + (nM - 1) / 2 * MATRIX_WIDTH - self.nSpace
				tPos.y = MATRIX_HEIGHT + (nM - 1) / 2 * MATRIX_HEIGHT -  math.sqrt(self.nSpace * self.nSpace / 3) 
			elseif nN == 1 then --左边
				nSide = e_matrix_side.left
				tPos.x = 3 / 2 * MATRIX_WIDTH + (nM - 1) / 2 * MATRIX_WIDTH
				tPos.y = MATRIX_HEIGHT + (nM - 2) / 2 * MATRIX_HEIGHT
			elseif nN == 2 then --右边
				nSide = e_matrix_side.right
				tPos.x = MATRIX_WIDTH + (nM - 2) / 2 * MATRIX_WIDTH
				tPos.y = 3 / 2 * MATRIX_HEIGHT + (nM - 1) / 2 * MATRIX_HEIGHT
			end
		end
	end

	return tPos, nSide

end

--获得武将方阵
function FightTeamLayer:getHeroMatrix(  )
	-- body
	return self.pMHeroLayer
end

--获得所有的士兵方阵
function FightTeamLayer:getAllSoldiersMatrix(  )
	-- body
	return self.tMSoldierLayers
end

--开始战斗（前四个方阵进入战斗，剩余的属于待命状态）
function FightTeamLayer:startFight(  )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end 
	if self.pMHeroLayer then
		self:moveToPos(self.pMHeroLayer,self.moveVecHero, function (  )
			-- body
			if self.nType == 1 and self.nIndex == 1 then --只需要一方验证就行，播放战斗背景音乐
				-- 播放音乐
				Sounds.playMusic(Sounds.Music.battle,true)  
			end
			self.pMHeroLayer:playArm(e_type_fight_action.attack)
		end)
	end
	self:playSoldierAction()
end

--播放士兵方阵动画
function FightTeamLayer:playSoldierAction(  )
	-- body
	--下标数量
	local nSize = table.nums(self.tMSoldierLayers)
	if self.nCurRow <= math.ceil(nSize / 3) then
		local nCurIndexMoveAway = 0 --第几个方阵完整散开
		local nCurMax = 3 --当前排有多少个方阵
		if self.nCurRow * 3 > nSize then
			local nN = nSize % 3
			nCurMax = nN
		end
		local nCurI = (self.nCurRow) * 3 - 2
		local nCurNI = nCurI + nCurMax - 1
		--进入混战区
		for i = nCurI, nCurNI do
			local pMLayer = self.tMSoldierLayers[i]
			if pMLayer then
				if pMLayer.nSide == e_matrix_side.center then --中间
					local tPos = self.moveVecSC2
					if self.nCurRow == 1 then --第一排
						tPos = self.moveVecSC
					end
					self:moveByPos(pMLayer,tPos, function (  )
						-- body
						pMLayer:moveAway(self:getCurMatrixFmtByOrder(pMLayer, self.pTarget:getCurOrder()),
							function (  )
							-- body
							nCurIndexMoveAway = nCurIndexMoveAway + 1
							--把方阵添加到混战列表中
							self:addMatrixToFight(pMLayer)
							if nCurMax == nCurIndexMoveAway then
								self:arrivedFightZone()
							end
						end)
					end)
				else
					if self.nCurRow == 1 then --第一排
						pMLayer:moveAway(self:getCurMatrixFmtByOrder(pMLayer, self.pTarget:getCurOrder()),
							function (  )
							-- body
							nCurIndexMoveAway = nCurIndexMoveAway + 1
							--把方阵添加到混战列表中
							self:addMatrixToFight(pMLayer)
							if nCurMax == nCurIndexMoveAway then
								self:arrivedFightZone()
							end
						end)
					else
						self:moveByPos(pMLayer,self.moveVecSC2, function (  )
							-- body
							pMLayer:moveAway(self:getCurMatrixFmtByOrder(pMLayer, self.pTarget:getCurOrder()),
								function (  )
								-- body
								nCurIndexMoveAway = nCurIndexMoveAway + 1
								--把方阵添加到混战列表中
								self:addMatrixToFight(pMLayer)
								if nCurMax == nCurIndexMoveAway then
									self:arrivedFightZone()
								end
							end)
						end)
					end
				end
			end
		end
		
		--暂停其他方阵（待命）
		local nCurMI = nCurMax + nCurI
		local bFirstHadSides = false
		if nCurMI <= nSize then
			for i = nCurMI, nSize do
				local pMLayer = self.tMSoldierLayers[i]
				if pMLayer then
					if pMLayer.nSide == e_matrix_side.center then --中间
						local tPos = self.moveVecSC2
						if self.nCurRow == 1 then --第一排
							tPos = self.moveVecSC
						end
						self:moveByPos(pMLayer,tPos, function (  )
							-- body
							pMLayer:playArm(e_type_fight_action.stand)
							--停止下一个武将所带的teamlayer
							self:stopNextTeamLayer()
						end)
					else
						if self.nCurRow == 1 then --第一排
							bFirstHadSides = true
							pMLayer:playArm(e_type_fight_action.stand)
							--停止下一个武将所带的teamlayer
							self:stopNextTeamLayer()
						else
							self:moveByPos(pMLayer,self.moveVecSC2, function (  )
								-- body
								pMLayer:playArm(e_type_fight_action.stand)
								--停止下一个武将所带的teamlayer
								self:stopNextTeamLayer()
							end)
						end
						
					end
					
				end
			end 
			if self.nCurRow ~= 1 then --非第一排
				self.pTarget:showAction(self.nType,self.nIndex + 1,1)
			else
				if bFirstHadSides == false then
					self.pTarget:showAction(self.nType,self.nIndex + 1,1)
				end
			end
			-- print("后面还有方阵")
		else
			-- print("后面没有方阵")
			self.pTarget:showAction(self.nType,self.nIndex + 1,1)
		end
		self.nCurRow = self.nCurRow + 1
	else
		doDelayForSomething(self,function (  )
			-- body
			print("*****************************下一个武将上阵")
			self.pTarget:showAction(self.nType,self.nIndex + 1,2)
		end, e_delay_time_hero.normal )
	end
	
end

--跟当前指令获得需要展示的阵容
--_pCurLayer：当前方阵
--_pOrder：需要判断的指令
function FightTeamLayer:getCurMatrixFmtByOrder( _pCurLayer, _pOrder )
	-- body
	local nFmtType = nil
	--获得当前指令
	local nCurOrder = _pOrder 
	--指令存在的情况下
	if nCurOrder and nCurOrder ~= -1 and self.pTarget.tBothSidesDatas then
		--判断上下方
		local nOtherSId = nil
		local nHPos = nil
		local nDir = 1 --方向相反
		if self.nType == 1 then --下方
			nHPos = nCurOrder.dp
			nDir = 2
		elseif self.nType == 2 then --上方
			nHPos = nCurOrder.op
			nDir = 1
		end
		if nHPos and self.pTarget.tBothSidesDatas[nDir] then
			nOtherSId = self.pTarget.tBothSidesDatas[nDir][nHPos].nSId
		end
		if nOtherSId then
			--如果该方阵的默认阵型与当前判断指令另一方的默认阵型相等
			if _pCurLayer.nDefaultFmt == __getDefaultMatrixFmt(nOtherSId) then
				--这个时候如果当前阵型需要变为默认阵型（不然一出现最高变阵类型，则永远不改变了）
				nFmtType = _pCurLayer.nDefaultFmt
			else
				nFmtType = __getCurShowMatrixFmt(__getDefaultMatrixFmt(nOtherSId),_pCurLayer.nDefaultFmt)
			end
			
		end
	end
	return nFmtType

end

--停止下一个武将所带的teamlayer
function FightTeamLayer:stopNextTeamLayer(  )
	-- body
	local tLayerLists = nil
	if self.nType == 1 then
		tLayerLists = self.pTarget:getBottomLayer()
	elseif self.nType == 2 then
		tLayerLists = self.pTarget:getTopLayer()
	end
	self.pTarget:stopActions(tLayerLists, self.nIndex + 1)
end

--添加方阵到混战区域中
function FightTeamLayer:addMatrixToFight( _pMLayer )
	-- body
	--血量叠加
	self.fAllCurBlood = self.fAllCurBlood + _pMLayer:getSoldierData().fBlood
	table.insert(self.tCurFightSoldiers, _pMLayer)
	table.sort(self.tCurFightSoldiers, handler(self, self.mySort))
end

--自定义排序规则(两边取数据)
function FightTeamLayer:mySort( _pMLayer1, _pMLayer2)
	-- body
	if _pMLayer1.nSide == _pMLayer2.nSide then
		return _pMLayer1.nIndex < _pMLayer2.nIndex
	else
		return _pMLayer1.nSide < _pMLayer2.nSide
	end
end


-- 移动到某个位置__moveToPos
-- _tPos：目的地坐标
-- _handler：回调方法
function FightTeamLayer:moveToPos( _pView, _tPos, _handler )
	-- body
	_pView:stopAllActions()
	local bNeedMove = __moveToPos(_pView,_tPos,_handler)
	if bNeedMove then
		_pView:playArm(e_type_fight_action.run)
	end
end

-- 移动到某个位置__moveByPos
-- _tPos：目的地坐标
-- _handler：回调方法
function FightTeamLayer:moveByPos( _pView, _tPos, _handler )
	-- body
	__moveByPos(_pView,_tPos,_handler)
	_pView:playArm(e_type_fight_action.run)
end

--部队已经全部达到混战区域
function FightTeamLayer:arrivedFightZone(  )
	-- body
	--发送到达混战区的消息
	local tObject = {}
	tObject.nDirection = self.nType --方向
	tObject.nIndex = self.nIndex --下标（对应武将的位置）
	sendMsg(ghd_fight_arrived_fzone,tObject)
end

--设置所有的单元动作
function FightTeamLayer:setAllUnitsState( _actionType )
	-- body
	--士兵变为待命动作
	if self.tCurFightSoldiers and table.nums(self.tCurFightSoldiers) > 0 then
		for k, v in pairs (self.tCurFightSoldiers) do
			if v then
				v:playArm(_actionType)
			end
		end
	end
	if self.pMHeroLayer then
		self.pMHeroLayer:playArm(_actionType)
	end
end

--战斗具体表现（调用到该方法表示“需要参战的”士兵已经到达了混战区域了）
function FightTeamLayer:showDetailsFight(  )
	-- body
	--获得当前指令
	local nCurOrder = self.pTarget:getCurOrder()
	if nCurOrder and nCurOrder ~= -1 then
		--判断是否有技能表现
		if nCurOrder.t == 1 then
			--士兵变为待命动作
			self:setAllUnitsState(e_type_fight_action.stand)
			--展示武将技能表现
			self:showHeroSkillFight()
		else
			--士兵变为待命动作
			self:setAllUnitsState(e_type_fight_action.attack)
			--普通战斗表现
			self:showNormalFight(true,false)
		end
	end
end

--展示武将技能表现
function FightTeamLayer:showHeroSkillFight(  )
	-- body
	--获得当前指令
	local nCurOrder = self.pTarget:getCurOrder()
	if nCurOrder and nCurOrder ~= -1 then
		--优先上方技能
		if self.nType == 2 then
			--准备开始播放武将技能
			self:readyForShowSkill(nCurOrder.ds)
		elseif self.nType == 1 then --下方
			--准备开始播放武将技能
			self:readyForShowSkill(nCurOrder.os)
		end
	end
end

--准备播放技能相关
--_nSkillId：技能id
function FightTeamLayer:readyForShowSkill( _nSkillId )
	-- body
	if _nSkillId ~= 0 then --上方有技能
		--背景 变灰
		self.pTarget:tintToFightBg(1)
		--武将蓄力
		if self.pMHeroLayer then
			self.pMHeroLayer:gatherForSkill(function (  )
				-- body
				--武将报招
				self.pTarget:playCallSkillArm(_nSkillId,self.tCurTeam.tHeroInfo, function (  )
					-- body
					--技能表现
					--同时执行相关的普通战斗表现
					self:showNormalFight(false,true)
					self.pTarget:playSkillArm(_nSkillId, self.nType,function (  )
						-- body
						--士兵变为攻击动作
						self:setAllUnitsState(e_type_fight_action.attack)
						--发送播放下一条指令的消息
						local tObject = {}
						tObject.nDirection = self.nType --方向
						tObject.nCurOrderIndex = self.pTarget.nCurOrderIndex --当前指令下标
						sendMsg(ghd_fight_play_next_order,tObject)
					end)
				end)
			end)
		end
	else
		--普通战斗表现
		self:showNormalFight(true,true)
	end
end

--展示普通战斗表现
--_bNeedPlayNextOrder：是否需要表现下一条指令
--_bNeedDelayShowMsg：是否延迟展示飘字
function FightTeamLayer:showNormalFight( _bNeedPlayNextOrder, _bNeedDelayShowMsg )
	-- body
	if _bNeedPlayNextOrder == nil then
		_bNeedPlayNextOrder = true
	end
	if _bNeedDelayShowMsg == nil then
		_bNeedDelayShowMsg = false
	end
	-- self:printControll("需要参战的士兵全部达到战场了===================>")
	local fDelayTimeShow = 0 --延迟飘字展示时间
	if _bNeedDelayShowMsg then
		fDelayTimeShow = 2.5 --这个时间目前先在这里写实，以后有用需求在做修改
	end
	doDelayForSomething(self, function (  )
		-- body
		if not tolua.isnull(self.pMHeroLayer) then
			local tCurData = self.pMHeroLayer:getCurData()
			--发送飘字特效表现消息
			local tObject = {}
			tObject.nDirection = self.nType --方向
			if tCurData then
				tObject.nAll = tCurData.trp or 0
			end
			sendMsg(ghd_fight_show_msg,tObject)
			--发送消息给界面上层扣血（整扣）
		end
	end,fDelayTimeShow)
	-- self:printControll("当前总血量：" .. self.fAllCurBlood)
	--理论上当前回合表现是不需要判断是否需要补兵的
	
	--获得当前指令
	local nCurOrder = self.pTarget:getCurOrder()
	--获得下一条指令
	local nNextOrder = self.pTarget:getNextOrder()

	if nCurOrder and nCurOrder ~= -1 then
		--扣掉当前回合的血量
		local nDropBlood = 0 --当前要扣点的血量
		if self.nType == 1 then --下方（攻击方）
			nDropBlood = nCurOrder.oh
		elseif self.nType == 2 then --上方（防守方）
			nDropBlood = nCurOrder.dh
		end
		self.fAllCurBlood = self.fAllCurBlood - nDropBlood
		-- self:printControll("扣掉血量nDropBlood:" .. nDropBlood)
		-- self:printControll("剩余血量：" .. self.fAllCurBlood)
		--判断是否需要补兵（这里要分两种情况（1：武将中补兵，2：武将外补兵（下一个武将进场）））
		local nNextHeroIndex = 1 --下一条指令武将下标
		if nNextOrder and nNextOrder ~= -1 then  --存在下一条指令
			local nNextDropBlood = 0 --下一个回合要扣掉的血量
			if self.nType == 1 then --下方（攻击方）
				nNextDropBlood = nNextOrder.oh
				nNextHeroIndex = nNextOrder.op
			elseif self.nType == 2 then --上方（防守方）
				nNextDropBlood = nNextOrder.dh
				nNextHeroIndex = nNextOrder.dp
			end
			--再次跟进当前的血量进行判断
			--1.（血量小于或者等于的情况下需要补兵）
			--2.（血量等于0，下一轮是武将进场）
			if self.fAllCurBlood <= nNextDropBlood and self.nIndex == nNextHeroIndex then
				self:playSoldierAction()
			end
		end

		--延迟回合时间，准备下一个回合表现
		doDelayForSomething(self,function (  )
			-- body
			-- self:printControll("下一条指令准备播放===")
			--剩余血量为0的时候表示当前team的武将必需死亡，所带的士兵也要全部死掉
			if self.fAllCurBlood == 0 then
				--剩下的士兵全部死掉
				if self.tCurFightSoldiers and table.nums(self.tCurFightSoldiers) > 0 then
					local nSize = table.nums(self.tCurFightSoldiers)
					for i = nSize, 1, -1 do
						local pLayer = self.tCurFightSoldiers[i]
						if pLayer then
							pLayer:playArm(e_type_fight_action.death)
						end
						table.remove(self.tCurFightSoldiers,i)
					end
				end
				--延迟一点点时间 武将才死亡
				doDelayForSomething(self,function (  )
					-- body
					--武将死亡
					if self.pMHeroLayer then
						self.pMHeroLayer:playArm(e_type_fight_action.death)
						self.tCurTeam.nCurBlood = 0
						--刷新血量
						self.pMHeroLayer:setbloodMsg()
						--主界面刷新血量
						-- local tCurData = self.pMHeroLayer:getCurData()
						-- if tCurData then
							local tOb = {}
							tOb.nDir = self.pMHeroLayer.nDirection
							tOb.nCur = self.tCurTeam.nCurBlood
							tOb.nAll = self.tCurTeam.trp
							tOb.bDeath = true --武将不死亡
							sendMsg(ghd_fight_show_blood_onmain, tOb)
						-- end
						--移除武将特殊层
						self.pMHeroLayer:removeSpeLayer()
						self.pMHeroLayer = nil
					end
				end,1.3)
			else
				--判断剩下的方阵判断是否需要变阵(根据下一条指令来判断)
				if self.tCurFightSoldiers and table.nums(self.tCurFightSoldiers) > 0 then
					--存在下一条指令
					if nNextOrder and nNextOrder ~= -1 then
						for k, v in pairs (self.tCurFightSoldiers) do
							if v then
								--获得下一条指令需要散开的阵型类型
								local nNeedShowFmt = self:getCurMatrixFmtByOrder(v, nNextOrder)
								-- local nNeedShowFmt = self:getCurMatrixFmtByOrder(v, self.pTarget:getCurOrder())
								if nNeedShowFmt then
									--如果下一条指令需要散开的阵型与当前正在展示的阵型相对应
									if nNeedShowFmt == v.nCurShowFmt then
										-- self:printControll("阵型不变")
									else
										--对下一次需要展示的阵型赋值（准备变阵）
										v:moveAway(nNeedShowFmt, function (  )
											-- body
											self:printControll("变阵结束=====")
										end)
									end
								end
								
							end
							
						end
					end
					
				end
			end
			if _bNeedPlayNextOrder then --需要播放下一条指令
				--发送播放下一条指令的消息
				local tObject = {}
				tObject.nDirection = self.nType --方向
				tObject.nCurOrderIndex = self.pTarget.nCurOrderIndex --当前指令下标
				sendMsg(ghd_fight_play_next_order,tObject)
			end
			
		end, __nShowFightTime )
		--没有掉血 直接返回
		if nDropBlood == 0 then
			-- self:printControll("没有掉血=============")
			return
		end
		--士兵开始死亡
		--先计算需要死掉多少兵
		-- self:printControll("每一个士兵的血量为：" .. self.tCurTeam.fUnitBlood)
		local nDeadCount = math.floor(nDropBlood / self.tCurTeam.fUnitBlood)
		-- self:printControll("该回合死亡数量：" .. nDeadCount )
		--剩余的血量
		local fLeftBlood = nDropBlood - (nDeadCount * self.tCurTeam.fUnitBlood)

		for i = 1, nDeadCount do
			local pLayer = self:getMatrixLayerForDeath(1)
			if pLayer then
				--延迟时间的计算
				local fDelayTime = (i - 1) * __nShowFightTime / nDeadCount
				pLayer:playSoldierDead(fDelayTime, function (  )
					-- body
					--血量变化
					self:showBloodChanged(self.tCurTeam.fUnitBlood)
				end)
			else
				self:printControll("没得死亡了===================")
				--没得死亡了，也需要表现掉血
				self:showBloodChanged(self.tCurTeam.fUnitBlood)
			end
		end
		--如果血量大于0，士兵分了剩余的，也需要做掉血表现
		if fLeftBlood > 0 then
			self:showBloodChanged(fLeftBlood)
		end

	else
		self:printControll("没有指令了============" .. self.pTarget.nCurOrderIndex)
	end
end

--计算血量变化和展示血量变化
function FightTeamLayer:showBloodChanged( _fChangeBlood )
	-- body
	if _fChangeBlood == nil or _fChangeBlood <= 0 then
		return
	end
	self.tCurTeam.nCurBlood = self.tCurTeam.nCurBlood - _fChangeBlood
	--刷新血量
	if self.pMHeroLayer then
		self.pMHeroLayer:setbloodMsg()
		--主界面刷新血量
		-- local tCurData = self.pMHeroLayer:getCurData()
		-- if tCurData then
			local tOb = {}
			tOb.nDir = self.pMHeroLayer.nDirection
			tOb.nCur = self.tCurTeam.nCurBlood
			tOb.nAll = self.tCurTeam.trp
			tOb.bDeath = false --武将不死亡
			sendMsg(ghd_fight_show_blood_onmain, tOb)
		-- end
	end
end

--获得表现死亡一个士兵的层
--_nIndex：查找次数
function FightTeamLayer:getMatrixLayerForDeath( _nIndex )
	-- body
	if not self.tCurFightSoldiers or table.nums(self.tCurFightSoldiers) == 0 then
		return nil
	end

	if self.nCurFindSoldierIndex > 3 then --超过3那么就要重新开始
		self.nCurFindSoldierIndex = 1
	end

	local nSide = e_matrix_side.left
	if self.nCurFindSoldierIndex == 1 then
		nSide = e_matrix_side.left
	elseif self.nCurFindSoldierIndex == 2 then
		nSide = e_matrix_side.right
	elseif self.nCurFindSoldierIndex == 3 then
		nSide = e_matrix_side.center
	end
	--查找死亡士兵的方阵
	local pCurLayer = self:getMatrixLayerBySide(nSide)
	_nIndex = _nIndex + 1 --查找次数+1
	self.nCurFindSoldierIndex = self.nCurFindSoldierIndex + 1 --方位修改

	if pCurLayer then
		local tSoldierUnits = pCurLayer:getUnitSoldierLists()
		if not tSoldierUnits or table.nums(tSoldierUnits) == 0 then --如果当前层的兵已经死光了，那么移除掉当前层
			local nSize = table.nums(self.tCurFightSoldiers)
			for i = nSize, 1, -1 do
				if self.tCurFightSoldiers[i].nIndex == pCurLayer.nIndex then --找到没有士兵的层，然后删除掉
					table.remove(self.tCurFightSoldiers,i) 
					break
				end
			end
			if _nIndex > 3 then --超过3次，认为已经没有了
				return nil
			else
				return self:getMatrixLayerForDeath(_nIndex) --因为要死亡的士兵还没找到对应的方阵，多以需要再找一次
			end
		else
			return pCurLayer
		end
	else
		if _nIndex > 3 then --超过3次，认为已经没有了
			return nil
		else
			return self:getMatrixLayerForDeath(_nIndex) --如果次数小于3，需要继续查找
		end
		
	end
end


--根据方位获得Matrix层
function FightTeamLayer:getMatrixLayerBySide( _nSide )
	-- body
	if not self.tCurFightSoldiers or table.nums(self.tCurFightSoldiers) == 0 then
		return nil
	end
	if _nSide == e_matrix_side.center then --中间
		local pLayer = nil
		for k, v in pairs (self.tCurFightSoldiers) do
			if v.nSide == _nSide then
				pLayer = v
				break
			end
		end
		--中间再找不到，那就是没有了
		return pLayer
	elseif _nSide == e_matrix_side.left then --左边
		local pLayer = nil
		for k, v in pairs (self.tCurFightSoldiers) do
			if v.nSide == _nSide then
				pLayer = v
				break
			end
		end
		return pLayer
	elseif _nSide == e_matrix_side.right then --右边
		local pLayer = nil
		for k, v in pairs (self.tCurFightSoldiers) do
			if v.nSide == _nSide then
				pLayer = v
				break
			end
		end
		return pLayer
	end


end

--获得当前正在混战区的方阵
function FightTeamLayer:getCurFightMatrix(  )
	-- body
	return self.tCurFightSoldiers
end

--战斗打印信息控制方法
function FightTeamLayer:printControll( _str )
	-- body
	local sLog = nil
	if self.nType == 1 then
		sLog = "1下方，指令下标"..self.pTarget.nCurOrderIndex  .. "===>"
		return
	elseif self.nType == 2 then
		sLog = "2上方，指令下标"..self.pTarget.nCurOrderIndex  .. "===>"
		return
	end
	print(sLog .. _str)
end

return FightTeamLayer
