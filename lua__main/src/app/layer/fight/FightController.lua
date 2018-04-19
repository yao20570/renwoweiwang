-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-08 17:35:27 星期三
-- Description: 战斗控制管理类
-----------------------------------------------------
local FightTeamLayer = require("app.layer.fight.FightTeamLayer")

MATRIX_WIDTH 				=		130  --方阵的宽
MATRIX_HEIGHT				= 		math.sqrt(MATRIX_WIDTH * MATRIX_WIDTH / 3)  --方阵的高

MATRIX_WIDTH_INSIDE 		=		100  --方阵的宽
MATRIX_HEIGHT_INSIDE		= 		math.sqrt(MATRIX_WIDTH_INSIDE * MATRIX_WIDTH_INSIDE / 3)  --方阵的高

e_fight_report = {
	tlboss = 9,
}

e_matrix_dir = {
	down = 1,
	up = 2,
}


local FightController = class("FightController")

-- _fightLayer：FightLayer
-- _pLayFight：战斗显示层
-- _tReport：战报
function FightController:ctor( _fightLayer, _pLayFight, _tReport )
	-- body
	self:myInit()

	if not _fightLayer then
		return
	end
	if not _pLayFight then
		return
	end
	if not _tReport then
		print("战报数据为 nil")
		return
	end
	self.pFightLayer = _fightLayer
	self.pLayFight = _pLayFight
	--初始化数据
	self:initDatas(_tReport)
	--初始化UI布局
	self:setupViews()
	self:onResume()
end

--初始化成员变量
function FightController:myInit(  )
	-- body
	self.pFightLayer 		= 			nil 		--FightLayer
	self.pLayFight 			= 			nil 		--战斗显示层（战斗详情表现）
	self.tBothSidesDatas 	= 			{} 			--所有数据
	self.tFightOrders 		= 			{} 			--战斗回合标志指令集合

	self.tReport 			= 			nil 		--战报数据

	self.nCurOrderIndex 	= 			1 			--当前执行到哪条指令
	self.nCheckCount 		= 			0 			--是否成功播放指令计数器（2:表示成功）

	self.pCurBTeamLayer 	= 			nil 		--当前在战斗中的层（下方）
	self.pCurTTeamLayer 	= 			nil 		--当前在战斗中的层（上方）
	self.bCanBShowOrder  	= 			true 		--是否可以播放战斗表现（下方）
	self.bCanTShowOrder  	= 			true 		--是否可以播放战斗表现（上方）
	self.bHadBChangeTeam 	= 			true 		--是否已经选择好表现的teamLayer（下方）
	self.bHadTChangeTeam 	= 			true 		--是否已经选择好表现的teamLayer（上方）
	self.nHeroBIndex 		= 			1 			--当前表现战斗的武将下标（下方）
	self.nHeroTIndex 		= 			1 			--当前表现战斗的武将下标（上方）


	self.sEndLoadKey 		= 			nil 		--初始化加载加速标志
	self.tCheckShowLists 	= 			{} 			--检查是否需要展示的Maritx层集合

	self.pTopLayers 		= 			{} 			--上方FightTeamlayer集合
	self.pBottomLayers 	    = 			{} 			--下方FightTeamlayer集合
	--参数配置
	--待命区 点坐标（美术确定的点）
	self.tPosStandB 		= 			cc.p(__fightCenterX - 216 + MATRIX_WIDTH, 
										__fightCenterY - 124.5 + MATRIX_HEIGHT)    
	self.tPosFightB 		= 			cc.p(self.tPosStandB.x + 46,self.tPosStandB.y + 26)    --混战区 点坐标

	self.tPosStandT 		= 			cc.p(__fightCenterX + 216 - MATRIX_WIDTH_INSIDE, 
										__fightCenterY + 124.5 - MATRIX_HEIGHT_INSIDE) 
	self.tPosFightT 		= 			cc.p(self.tPosStandT.x - 46,self.tPosStandT.y - 26)    --混战区 点坐标


	--层次变量
	self.nZorderTeamLayer 	= 			20 			--teamlayer的zorder值
	self.nZorderBloodLayer 	= 			200 		--飘字层的zorder值
	self.nZorderActionLayer = 			100 		--动作表现层

	--士兵动作表现保存集合
	self.tSoliderActions    = 			{} 			--士兵动作保存列表
	self.fDisArrow 			= 			30 	        --射箭距离


	--武将技能存放列表
	self.pCallSkillArm 		= 			nil 		--报招技能特效
	self.tAllSkillArms		= 			nil 		--所有技能存放列表

	--战斗结束标志设置次数
	self.nOverFightCt 		= 			0 			--战斗结束设置标志次数（由于战斗存在同归于尽的情况，如果次数大于1次，说明同归于尽了）


end

--获得当前下方teamlayer
function FightController:getBottomLayer(  )
	-- body
	return self.pBottomLayers
end

--获得当前上方teamlayer
function FightController:getTopLayer(  )
	-- body
	return self.pTopLayers
end

--获得需求的teamlayer层
function FightController:getTeamLayer( _nDir, _nIndex )
	-- body
	local tTmp = nil
	if _nDir == 1 then
		tTmp = self.pBottomLayers
	elseif _nDir == 2 then
		tTmp = self.pTopLayers
	end
	local pLayer = nil
	if tTmp then
		for k, v in pairs (tTmp) do
			if v.nIndex == _nIndex then
				pLayer = v
				break
			end
		end
	end
	return pLayer
end

--初始化数据
--_tReport：战报数据
function FightController:initDatas( _tReport )
	-- body
	self.tReport = _tReport 

	--解析下方阵容列表
	local tBottomDatas = nil
	if _tReport.ous and table.nums(_tReport.ous) > 0 then
		tBottomDatas = {}
		for k, v in pairs (_tReport.ous) do
			--当前血量赋值
			v.nCurBlood = v.trp
			if v.phxs and table.nums(v.phxs) > 0 then
			    --计算该武将所带的方阵数
				v.nMatrix = table.nums(v.phxs or {}) or 0
				--平均血量到每一个方阵中
				for m, n in pairs (v.phxs) do
					n.fBlood = v.trp / v.nMatrix
				end
				--计算每个武将所带的部队中一个兵的血量值
				v.fUnitBlood = v.trp / v.nMatrix / 9
			end
			--初始化相关数据
			v.tHeroInfo = __getHeroInfoForFightById(v.hid)
			if v.tHeroInfo then
				v.nSId = __getSoldierKey(1,v.tHeroInfo.nKind)
			else
				v.nSId = 30001
			end
			--容错判断（如果没有兵的将领是不能参战的）
			if v.nMatrix and v.nMatrix > 0 then
				tBottomDatas[v.pos] = v
			end
		end
	end
	--解析上方阵容列表
	local tTopDatas = nil
	if _tReport.dus and table.nums(_tReport.dus) > 0 then
		tTopDatas = {}
		for k, v in pairs (_tReport.dus) do
			--当前血量赋值
			v.nCurBlood = v.trp
			if v.phxs and table.nums(v.phxs) > 0 then
			     --计算该武将所带的方阵数
				v.nMatrix = table.nums(v.phxs or {}) or 0
				--平均血量到每一个方阵中
				for m, n in pairs (v.phxs) do
					n.fBlood = v.trp / v.nMatrix
				end
				--计算每个武将所带的部队中一个兵的血量值
				v.fUnitBlood = v.trp / v.nMatrix / 9
			end
			--初始化相关数据
			v.tHeroInfo = __getHeroInfoForFightById(v.hid)
			if v.tHeroInfo then
				v.nSId = __getSoldierKey(2,v.tHeroInfo.nKind)
			else
				v.nSId = 30002
			end
			--容错判断（如果没有兵的将领是不能参战的）
			if v.nMatrix and v.nMatrix > 0 then
				tTopDatas[v.pos] = v
			end
		end
	end 

	--判空操作
	if not tBottomDatas or not tTopDatas 
		or table.nums(tBottomDatas) == 0 
		or table.nums(tTopDatas) == 0 then
		--直接调出战斗结果界面
		doDelayForSomething(self.pFightLayer,function (  )
			-- body
			--发送消息通知战斗结束
			sendMsg(ghd_fight_play_end)
		end,0.2)
		
		print("warning ==> tBottomDatas or tTopDatas is nil ")
		return
	end

	self.tBothSidesDatas[1] = tBottomDatas
	self.tBothSidesDatas[2] = tTopDatas

	--对初始化加载结束标志赋值
	if table.nums(tBottomDatas) > table.nums(tTopDatas) then
		self.sEndLoadKey = "1_" .. table.nums(tBottomDatas)
	else
		self.sEndLoadKey = "2_" .. table.nums(tTopDatas)
	end

	--解析回合表现指令
	if not _tReport.acts then
		print("战斗标志指令为nil")
		return
	end

	self.tFightOrders = _tReport.acts

    -- dump(self.tFightOrders,"指令集合=",100)
    --设置所有的武将信息
    self:initAllHeros()

end

-- 注册消息
function FightController:regMsgs( )
	-- body
	-- 注册战斗飘字特效消息
	regMsg(self, ghd_fight_show_msg, handler(self, self.showMsgCallBack))
	-- 注册士兵到达混战区消息
	regMsg(self, ghd_fight_arrived_fzone, handler(self, self.arrivedFZoneCallBack))
	-- 注册可以播放下一条战斗指令消息
	regMsg(self, ghd_fight_play_next_order, handler(self, self.playNextOrder))
	-- 注册士兵动作表现消息
	regMsg(self, ghd_fight_play_soldier_action, handler(self, self.playSoldierAction))
	-- 注册血量变化消息
	regMsg(self, ghd_fight_show_blood_onmain, handler(self, self.onBloodChange))
	-- 注册武将攻击动作结束（战斗即将结束）
	regMsg(self, ghd_fight_play_hero_attack_end, handler(self, self.onHeroAttackEnd))

	
	
end

-- 注销消息
function FightController:unregMsgs(  )
	-- body
	-- 注销战斗飘字特效消息
	unregMsg(self, ghd_fight_show_msg)
	-- 注销士兵到达混战区消息
	unregMsg(self, ghd_fight_arrived_fzone)
	-- 注销可以播放下一条战斗指令消息
	unregMsg(self, ghd_fight_play_next_order)
	-- 注销士兵动作表现消息
	unregMsg(self, ghd_fight_play_soldier_action)
	-- 注销血量变化消息
	unregMsg(self, ghd_fight_show_blood_onmain)
	-- 注销武将攻击动作结束（战斗即将结束）
	unregMsg(self, ghd_fight_play_hero_attack_end)

end

--暂停方法
function FightController:onPause( )
	-- body
	self:unregMsgs()

	--释放资源
	if self.tSoliderActions then
		local nSize = table.nums(self.tSoliderActions)
		for i = nSize, 1, -1 do
			local pNode = self.tSoliderActions[i]
			if pNode then
				pNode:removeSelf()
			end
		end
	end

	if self.nCheckScheduler ~= nil then
        MUI.scheduler.unscheduleGlobal(self.nCheckScheduler)
        self.nCheckScheduler = nil
        self.tCheckShowLists = nil
	end

end

--继续方法
function FightController:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

--初始化布局UI                                                                                                                                                                                                                                         
function FightController:setupViews( )
	-- body
	-- --初始化缩放，旋转，位移值
	-- self.pLayFight:setScale(__fSScale)
	-- self.pLayFight:setRotation(-2)
	-- self.pLayFight:setPositionY(100)
end


--设置布局UI
function FightController:updateViews( )
	-- body
	--存在对战数据
	if self.tBothSidesDatas then
		--下方有数据
		if self.tBothSidesDatas[1] and table.nums(self.tBothSidesDatas[1]) > 0 then
			--解析每个武将带领的N个方阵为一个team
			for k, v in pairs ( self.tBothSidesDatas[1]) do
				local pTeamLayer = FightTeamLayer.new(self, 1, v, k)
				if k == 1 then
					-- 184.5的值是通过30度角算出来，这里可以写死184.5
					pTeamLayer:setPosition(-pTeamLayer:getWidth() , __fightCenterY - 184.5 - pTeamLayer:getHeight())
				else
					--获得上一个的位置
					if self.pBottomLayers[k - 1] then
						local x =  self.pBottomLayers[k - 1]:getPositionX() - pTeamLayer:getWidth() + 1.3 *  MATRIX_WIDTH
						local y =  self.pBottomLayers[k - 1]:getPositionY() - pTeamLayer:getHeight() + 1.3 *  MATRIX_HEIGHT
						pTeamLayer:setPosition(x, y)
					end
				end
				self.pLayFight:addView(pTeamLayer,self.nZorderTeamLayer + k)
				self.pBottomLayers[k] = pTeamLayer
			end
		end
		--上方有数据
		if self.tBothSidesDatas[2] and table.nums(self.tBothSidesDatas[2]) > 0 then
			--解析每个武将带领的N个方阵为一个team
			for k, v in pairs ( self.tBothSidesDatas[2]) do
				local pTeamLayer = FightTeamLayer.new(self, 2, v, k)
				if k == 1 then
					-- 184.5的值是通过30度角算出来，这里可以写死184.5
					pTeamLayer:setPosition(display.width,
						__fightCenterY + 184.5)
				else
					--获得上一个的位置
					local pTmpLayer = self.pTopLayers[k - 1]
					if pTmpLayer then
						local x =  pTmpLayer:getPositionX() + pTmpLayer:getWidth() - 1.3 *  MATRIX_WIDTH
						local y =  pTmpLayer:getPositionY() + pTmpLayer:getHeight() - 1.3 *  MATRIX_HEIGHT
						pTeamLayer:setPosition(x, y)
					end
				end
				local nZorder = 10
				self.pLayFight:addView(pTeamLayer,self.nZorderTeamLayer / 2 - k)
				self.pTopLayers[k] = pTeamLayer
			end
		end

	end

end

--初始化武将信息
function FightController:initAllHeros(  )
	-- body
	self.pFightLayer:initAllHeroMsgs(self.tBothSidesDatas)
	--默认武将第一个开始
	self.nHeroBIndex = 1
	self.nHeroTIndex = 1
end

--获得当前的指令
function FightController:getCurOrder(  )
	-- body
	if self.nCurOrderIndex > table.nums(self.tFightOrders) then
		-- print("当前战斗指令全部已经结束了")
		return -1
	end
	return self.tFightOrders[self.nCurOrderIndex] 
end

--获得下一条指令
function FightController:getNextOrder(  )
	-- body
	local nNextOrderIndex = self.nCurOrderIndex + 1
	if nNextOrderIndex > table.nums(self.tFightOrders) then
		print("没有下一条战斗指令了")
		return -1
	end
	return self.tFightOrders[nNextOrderIndex] 
end

--指令下标自加
function FightController:addSelfCurOrderIndex(  )
	-- body
	self.nCurOrderIndex = self.nCurOrderIndex + 1
end

--战斗飘字特效回调（掉血，闪避，暴击）
function FightController:showMsgCallBack( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		--获得指令(不为空并且不为-1)
		local tCurOrderData =  self:getCurOrder()
		if tCurOrderData and tCurOrderData ~= -1 then
			local nAll = pMsgObj.nAll or 0
			local nDrop = 0
			if pMsgObj.nDirection == 1 then --下方
				--飘字内容层
				if not self.pLayShowMsgB then
					self.pLayShowMsgB = MUI.MLayer.new()
					self.pLayFight:addView(self.pLayShowMsgB,self.nZorderBloodLayer)
				end
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
				elseif tCurOrderData.oc == 1 then    --暴击
					--判断是否有掉血
					if tCurOrderData.oh <= 0 then
						return
					end
					--掉血
					nDrop = tCurOrderData.oh
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
					self.pLbBloodB:setPosition(self.pImgBJB:getWidth() + 25, 
						self.pImgBJB:getHeight() / 2)
					--设置大小
					self.pLayShowMsgB:setLayoutSize(self.pLbBloodB:getWidth() + self.pImgBJB:getWidth(), 
						self.pImgBJB:getHeight())
				else 								--普通掉血
					--判断是否有掉血
					if tCurOrderData.oh <= 0 then
						return
					end
					--掉血
					nDrop = tCurOrderData.oh
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
				--设置位置
				self.pLayShowMsgB:setPosition(__fightCenterX - self.pLayShowMsgB:getWidth() / 2,
					__fightCenterY ) 
				--展示飘字特效
				self:showMsgAction(self.pLayShowMsgB,1)
			elseif pMsgObj.nDirection == 2 then --上方
				--飘字内容层
				if not self.pLayShowMsgT then
					self.pLayShowMsgT = MUI.MLayer.new() 
					self.pLayFight:addView(self.pLayShowMsgT,self.nZorderBloodLayer)
				end
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
				elseif tCurOrderData.dc == 1 then    --暴击
					--判断是否有掉血
					if tCurOrderData.dh <= 0 then
						return
					end
					--掉血
					nDrop = tCurOrderData.dh
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
					self.pLbBloodT:setPosition(self.pImgBJT:getWidth() + 25, 
						self.pImgBJT:getHeight() / 2)
					--设置大小
					self.pLayShowMsgT:setLayoutSize(self.pLbBloodT:getWidth() + self.pImgBJT:getWidth(), 
						self.pImgBJT:getHeight())
				else 								--普通掉血
					--判断是否有掉血
					if tCurOrderData.dh <= 0 then
						return
					end
					--掉血
					nDrop = tCurOrderData.dh
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
				--设置位置
				self.pLayShowMsgT:setPosition(__fightCenterX , __fightCenterY)
				--展示飘字特效
				self:showMsgAction(self.pLayShowMsgT,2)
			end
			--整块掉血
			-- local tOB = {}
			-- tOB.nAll = nAll
			-- tOB.nDrop = nDrop
			-- tOB.nDir = pMsgObj.nDirection
			-- sendMsg(ghd_fight_show_blood_onmain_block, tOB)
		end
	end
	
end 

--获得一张图片
--nType :1闪避 2：暴击
function FightController:getShowActionImage( nType)
	-- body
	local sNameImg = "#v1_font_fight_sb.png"
	if nType == 2 then
		sNameImg = "#v1_font_fight_bj.png"
	end
	local pImg = MUI.MImage.new(sNameImg)
	return pImg
end

--获得一个数字标签
function FightController:getShowActionLabelAtlas(  )
	-- body
	local pLabelAtlas = MUI.MLabelAtlas.new({text=":100", 
		png="ui/atlas/p1_atlas_fight_blood_t.png", pngw=20, pngh=32, scm=48})
	return pLabelAtlas
end

--展示飘字特效方法
function FightController:showMsgAction( _pLayer, _nType )
	-- body
	--设置初始缩放值和透明度
	_pLayer:setVisible(true)
	_pLayer:setOpacity(255)
	_pLayer:setScale(0.33)

	local nPosX1 = 76.5
	local nPosX2 = 1.3
	local nPosX3 = 9.4

	if _nType == 1 then
		nPosX1 = nPosX1 * -1
		nPosX2 = nPosX2 * -1
		nPosX3 = nPosX3 * -1
	end
	--第一阶段
	local moveBy1  = cc.MoveBy:create(0.25, cc.p(nPosX1,17))
	local scaleTo1  = cc.ScaleTo:create(0.25, 1)
	local action1 = cc.Spawn:create(moveBy1,scaleTo1)
	--第二阶段
	local moveBy2  = cc.MoveBy:create(0.1, cc.p(nPosX2,3))
	--第三阶段
	local moveBy3  = cc.MoveBy:create(0.45, cc.p(nPosX3,12.7))
	local fadeOut3  = cc.FadeOut:create(0.45)
	local action3 = cc.Spawn:create(moveBy3,fadeOut3)

	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		_pLayer:setVisible(false)
	end)
	--执行actions
	local actions = cc.Sequence:create(action1, moveBy2,action3,actionEnd)
	_pLayer:runAction(actions)
end

--开始播放战斗
function FightController:start(  )
	-- body
	--先停止待命
	self:stopActions(self.pBottomLayers,1)
	self:stopActions(self.pTopLayers,1)

	--战斗开始前动画
	local sName = createAnimationBackName("tx/fight_normal/", "sg_zd_zdks_001")
    local pArm = ccs.Armature:create(sName)
    pArm:getAnimation():play("Animation1", -1, -1)
    pArm:setPosition(self.pFightLayer:getContentSize().width/2,self.pFightLayer:getContentSize().height/2)
    self.pFightLayer:addChild(pArm,10)
    pArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
		if (eventType == MovementEventType.COMPLETE) then
			--展示跳过战斗按钮
			self.pFightLayer:setBtnFastVisible(true)
			--每帧检查位置
			self:scheduleOnceCheck()
			--播放进场动画
			self:showAction(1,1,2)
			self:showAction(2,1,2)
				-- 执行动画效果
			local actionScaleTo = cc.ScaleTo:create(4, __fEScale)
			local actionRotateTo = cc.RotateTo:create(4, 0)
			local actionMoveTo = cc.MoveTo:create(4, cc.p(0, 0))
			self.pLayFight:runAction(cc.Spawn:create(actionScaleTo,actionRotateTo,actionMoveTo))
		end
	end)
	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.opening)
end

--_nType：1变灰  2恢复
function FightController:tintToFightBg( _nType )
	-- body
	if self.pFightLayer.pImgBg and self.pFightLayer.pImgGate then
		if _nType == 1 then
			self.pFightLayer.pImgBg:runAction(cc.TintTo:create(0.4, 92, 92, 92))
			self.pFightLayer.pImgGate:runAction(cc.TintTo:create(0.4, 92, 92, 92))
		elseif _nType == 2 then
			self.pFightLayer.pImgBg:runAction(cc.TintTo:create(0.4, 255, 255, 255))
			self.pFightLayer.pImgGate:runAction(cc.TintTo:create(0.4, 255, 255, 255))

		end
	end
end

-- 每帧检查位置
function FightController:scheduleOnceCheck( )
    self.nCheckScheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
    	if self.tCheckShowLists and table.nums(self.tCheckShowLists) > 0 then
    		local nSize = table.nums(self.tCheckShowLists)
    		for i = nSize, 1, -1 do
    			local pMatrix = self.tCheckShowLists[i]
    			if pMatrix then
    				local tRstPos = __convertToGetRstPos(pMatrix)
    				if pMatrix.nDirection == 1 then
    					if tRstPos.x >= __nLimitBottom then
    						pMatrix:setNeedShowState(true)
    						table.remove(self.tCheckShowLists,i)
    						pMatrix:playArm(pMatrix.nActionType)
    					end
    				elseif pMatrix.nDirection == 2 then
    					if tRstPos.x <= __nLimitTop then
    						pMatrix:setNeedShowState(true)
    						table.remove(self.tCheckShowLists,i)
    						pMatrix:playArm(pMatrix.nActionType)
    					end
    				end
    			end
    		end
    	else
			if self ~= nil and self.nCheckScheduler ~= nil then
		        MUI.scheduler.unscheduleGlobal(self.nCheckScheduler)
		        self.nCheckScheduler = nil
			end
    	end
    	
    	
    end)
end

--播放进场动画
-- _nType：1:下方 2：上方
-- _nIndex：表现teamlayer的下标（也就是第几个teamlayer在移动）
-- _nActionType：1:表示当前teamlayer移动到待命区  2：表示当前teamlayer移动到混战区
function FightController:showAction(_nType, _nIndex, _nActionType )
	-- body

	if _nType == 1 then --下方
		--下方
		if self.pBottomLayers 
			and table.nums(self.pBottomLayers) > 0 then
			    local pCurLayer = self.pBottomLayers[_nIndex]
				--需要移动的情况下，才需要执行以下逻辑代码
				local tMPos = cc.p(0,0)
				if _nActionType == 1 then
					tMPos = self.tPosStandB
				elseif _nActionType == 2 then
					tMPos = self.tPosFightB
				end
				if pCurLayer and self:isNeedMove(pCurLayer, tMPos) then

					--直接移动到混战区或者待命区
					local tPos = cc.p(tMPos.x - pCurLayer:getWidth(),tMPos.y - pCurLayer:getHeight())
					self:moveToPos(pCurLayer,tPos,function (  )
						-- body
						--暂停其他team层的动作
						self:stopActions(self.pBottomLayers,(_nIndex + 1))
						if _nActionType == 2 then 
							self:playFightAction(pCurLayer)
						else
							--如果是移动到待命区 自身也要待机动作
							self:playTeamArm(pCurLayer,e_type_fight_action.stand,e_type_fight_action.stand)
						end
					end)
					for i = (_nIndex + 1), table.nums(self.pBottomLayers) do
						local pLayer = self.pBottomLayers[i]
						if pLayer and self:isNeedMove(pLayer, self.tPosStandB) then
							--移动到待命区
							local tPos = cc.p(self.tPosStandB.x - pLayer:getWidth(),self.tPosStandB.y - pLayer:getHeight())
							self:moveToPos(pLayer,tPos,function (  )
								-- body
								--播放动作
								self:playTeamArm(pLayer,e_type_fight_action.stand,e_type_fight_action.stand)
								--暂停其他team层的动作
								self:stopActions(self.pBottomLayers,(pLayer.nIndex + 1))
								
							end)
						else
							--如果有一个已经到达待命区，其他不能再移动
							break
						end
					end
				end
		end
	elseif _nType == 2 then --上方
		--上方
		if self.pTopLayers 
			and table.nums(self.pTopLayers) > 0 then
			    local pCurLayer = self.pTopLayers[_nIndex]
				--需要移动的情况下，才需要执行以下逻辑代码
				local tMPos = cc.p(0,0)
				if _nActionType == 1 then
					tMPos = self.tPosStandT
				elseif _nActionType == 2 then
					tMPos = self.tPosFightT
				end
				if pCurLayer and self:isNeedMove(pCurLayer, tMPos) then

					--直接移动到混战区或者待命区
					self:moveToPos(pCurLayer,tMPos,function (  )
						-- body

						--暂停其他team层的动作
						self:stopActions(self.pTopLayers,(_nIndex + 1))
						if _nActionType == 2 then 
							self:playFightAction(pCurLayer)
						else
							--如果是移动到待命区 自身也要待机动作
							self:playTeamArm(pCurLayer,e_type_fight_action.stand,e_type_fight_action.stand)
						end
					end)
					for i = (_nIndex + 1), table.nums(self.pTopLayers) do
						local pLayer = self.pTopLayers[i]
						if pLayer and self:isNeedMove(pLayer, self.tPosStandT) then
							--移动到待命区
							self:moveToPos(pLayer,self.tPosStandT,function (  )
								-- body
								--播放动作
								self:playTeamArm(pLayer,e_type_fight_action.stand,e_type_fight_action.stand)
								--暂停其他team层的动作
								self:stopActions(self.pTopLayers,(pLayer.nIndex + 1))
								
							end)
						else
							--如果有一个已经到达待命区，其他不能再移动
							break
						end
					end
				end
		end
	end


	
end

--播放战斗动画
function FightController:playFightAction( _pLayer )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
	 	return
	end
	--teamlayer中的前四个方阵进入战斗，剩余的属于待命状态
	if _pLayer then
		_pLayer:startFight()
	end
end

--士兵到达混战区消息回调
function FightController:arrivedFZoneCallBack( sMsgName, pMsgObj )
	if pMsgObj then
		if pMsgObj.nDirection == 1 then --下方
			self.bHadBChangeTeam = false --收到消息，设置为还未选择好
			if self.bCanBShowOrder then --可以展示表现
				self.bHadBChangeTeam = true --设置为选择好了
				if not self.pCurBTeamLayer then --不存在战斗层了
					self.pCurBTeamLayer = self:getTeamLayer(pMsgObj.nDirection, pMsgObj.nIndex)
				else
					if self.pCurBTeamLayer.nIndex ~= pMsgObj.nIndex then --当前层不是需求层（重新获取）
						self.pCurBTeamLayer = self:getTeamLayer(pMsgObj.nDirection, pMsgObj.nIndex)
					end
				end
				if self.pCurBTeamLayer then
					self.pCurBTeamLayer:showDetailsFight()
					--已经在播放战斗表现的标志
					self.bCanBShowOrder = false
				end
			end
		elseif pMsgObj.nDirection == 2 then --上方
			self.bHadTChangeTeam = false --收到消息，设置为还未选择好
			if self.bCanTShowOrder then --可以展示表现
				self.bHadTChangeTeam = true --设置为选择好了
				if not self.pCurTTeamLayer then --不存在战斗层了
					self.pCurTTeamLayer = self:getTeamLayer(pMsgObj.nDirection, pMsgObj.nIndex)
				else
					if self.pCurTTeamLayer.nIndex ~= pMsgObj.nIndex then --当前层不是需求层（重新获取）
						self.pCurTTeamLayer = self:getTeamLayer(pMsgObj.nDirection, pMsgObj.nIndex)
					end
				end
				if self.pCurTTeamLayer then
					self.pCurTTeamLayer:showDetailsFight()
					--已经在播放战斗表现的标志
					self.bCanTShowOrder = false
				end
			end
		end
	end
end


--播放下一条指令回调方法
function FightController:playNextOrder( sMsgName, pMsgObj )
	if pMsgObj then
		-- dump(pMsgObj,"准备下一条指令=",100)
		if self.nCurOrderIndex == pMsgObj.nCurOrderIndex then --校验播放结束的指令是否正确
			--计数器+1
			self.nCheckCount = self.nCheckCount + 1
			if self.nCheckCount == 2 then --收到两次表现校验成功
				--重置计数器
				self.nCheckCount = 0
				--指令自加1
				self:addSelfCurOrderIndex()
				--设置状态为可以播放战斗
				self.bCanBShowOrder = true 
				self.bCanTShowOrder = true 

				--获得当前需要播放的指令
				local tCurOrderData = self:getCurOrder()
				if tCurOrderData and tCurOrderData ~= -1 then
					------------------------------下方--------------------------
					--检查需要播放表现的层是否满足条件
					local bCanB = false
					--(如果当前的层为nil)
					if not self.pCurBTeamLayer then
						--表示未到混战区
					else
						--验证是否已经切换好teamLayer
						if not self.bHadBChangeTeam and self.pCurBTeamLayer.nIndex ~= tCurOrderData.op then
							self.pCurBTeamLayer = self:getTeamLayer(1, tCurOrderData.op)
							self.bHadBChangeTeam = true --设置为选择好了
						end
						--如果当前的层就是指令上需要表现的层
						if self.pCurBTeamLayer.nIndex == tCurOrderData.op then
							--判断层上的血量是否满足扣血
							if self.pCurBTeamLayer.fAllCurBlood >= tCurOrderData.oh then
								bCanB = true
							end
						end
					end

					if bCanB then
						self.pCurBTeamLayer:showDetailsFight()
						--已经在播放战斗表现的标志
						self.bCanBShowOrder = false
					end

					------------------------------上方--------------------------
					--检查需要播放表现的层是否满足条件
					local bCanT = false
					--(如果当前的层为nil)
					if not self.pCurTTeamLayer then
						--表示未到混战区
					else
						--验证是否已经切换好teamLayer
						if not self.bHadTChangeTeam and self.pCurTTeamLayer.nIndex ~= tCurOrderData.dp then
							self.pCurTTeamLayer = self:getTeamLayer(2, tCurOrderData.dp)
							self.bHadTChangeTeam = true --设置为选择好了
						end
						--如果当前的层就是指令上需要表现的层
						if self.pCurTTeamLayer.nIndex == tCurOrderData.dp then
							--判断层上的血量是否满足扣血
							if self.pCurTTeamLayer.fAllCurBlood >= tCurOrderData.dh then
								bCanT = true
							end
						end
					end

					if bCanT then
						self.pCurTTeamLayer:showDetailsFight()
						--已经在播放战斗表现的标志
						self.bCanTShowOrder = false
					end
				end
			end
		end
	end
end

--战斗准备结束
function FightController:beReadyFightOver(  )
	-- body
	__isFightOver = true
	self.nOverFightCt = self.nOverFightCt + 1
	if self.nOverFightCt >= 2 then
		--发送消息武将攻击动作完成（战斗即将结束）
		local tObj = {}
		tObj.bAllDeath = true
		sendMsg(ghd_fight_play_hero_attack_end,tObj)
	end
end

--武将攻击动作结束，即将结束战斗
--bAllDeath : 是否同归于尽
function FightController:onHeroAttackEnd( sMsgName, pMsgObj )
	-- body
	local bAllDeath = false
	if pMsgObj then
		bAllDeath = pMsgObj.bAllDeath
	end

	if not bAllDeath then --不是同归于尽的情况下需要设置为待命状态
		--剩下的士兵全部设置为待命状态
		local tSoldierLists = nil
		local pHeroMatrix = nil
		if self.tReport.w == 1 then --下方胜利
			if self.pCurBTeamLayer then
				tSoldierLists = self.pCurBTeamLayer:getCurFightMatrix()
				pHeroMatrix = self.pCurBTeamLayer:getHeroMatrix()
			end
		elseif self.tReport.w == 2 then --上方胜利
			if self.pCurTTeamLayer then
				tSoldierLists = self.pCurTTeamLayer:getCurFightMatrix()
				pHeroMatrix = self.pCurTTeamLayer:getHeroMatrix()
			end
		end
		--武将设置为待命
		if pHeroMatrix then
			pHeroMatrix:playArm(e_type_fight_action.stand)
		end
		--士兵设置为待命
		if tSoldierLists and table.nums(tSoldierLists) > 0 then
			for k, v in pairs (tSoldierLists) do
				if v then
					v:playArm(e_type_fight_action.stand)
				end
			end
		end
	end
	
	--延迟一点时间 才播放战斗结束界面
	doDelayForSomething(self.pFightLayer,function (  )
		-- body
		--发送消息通知战斗结束
		sendMsg(ghd_fight_play_end)
	end,1)
end


--判断当前是否需要移动
function FightController:isNeedMove( _pView, _tPos )
	-- body
	if not _pView or not _tPos  then
		print("FightController:isNeedMove is nil")
		return
	end
	--计算移动到那个位置
	local tPosEnd = cc.p(_tPos.x - _pView:getWidth(),_tPos.y - _pView:getHeight())
	--计算距离
	local nDis =  math.sqrt((tPosEnd.x - _pView:getPositionX())
							* (tPosEnd.x - _pView:getPositionX()) 
							+ (tPosEnd.y - _pView:getPositionY()) 
							* (tPosEnd.y - _pView:getPositionY()))
	if nDis == 0 then
		return false
	else
		return true
	end
end

-- 移动到某个位置
-- _tPos：目的地坐标
-- _handler：回调方法
function FightController:moveToPos( _pView, _tPos, _handler )
	-- body
	__moveToPos(_pView,_tPos,_handler)
	self:playTeamArm(_pView,e_type_fight_action.run,e_type_fight_action.run)
end


--播放每个team的动画
--_pTeamLayer：执行动画的层
--_actionHType：武将动画类型
--_actionSType：士兵动画类型
function FightController:playTeamArm( _pTeamLayer, _actionHType, _actionSType )
	-- body
	if not _pTeamLayer then
		print("FightController.playTeamArm:_pTeamLayer is nil")
		return
	end
	if not _actionHType then
		print("FightController.playTeamArm:_actionHType is nil")
		return
	end
	if not _actionSType then
		print("FightController.playTeamArm:_actionSType is nil")
		return
	end

	--武将
	local pHeroMLayer = _pTeamLayer:getHeroMatrix()
	if pHeroMLayer then
		pHeroMLayer:playArm(_actionHType)
	end
	--士兵
	local tSoldierLayers = _pTeamLayer:getAllSoldiersMatrix()
	if tSoldierLayers and table.nums(tSoldierLayers) > 0 then
		for k, v in pairs (tSoldierLayers) do
			v:playArm(_actionSType)
		end
	end

end

--暂停所有动作
--_list：拥有动作的集合表
--_nIndex：从哪个下标开始
function FightController:pauseActions( _list, _nIndex )
	-- body
	if not _list or not _nIndex then
		print(" FightController:pauseAction()==>_list or _nIndex is nil")
		return
	end
	for i = _nIndex, table.nums(_list) do
		local pLayer = _list[i]
		if pLayer then
			local  pDirector = cc.Director:getInstance()
			pDirector:getActionManager():pauseTarget(pLayer)
			self:playTeamArm(pLayer,e_type_fight_action.stand,e_type_fight_action.stand)

		end
	end
end

--停止所有动作
--_list：拥有动作的集合表
--_nIndex：从哪个下标开始
function FightController:stopActions( _list, _nIndex )
	-- body
	if not _list or not _nIndex then
		print(" FightController:stopActions()==>_list or _nIndex is nil")
		return
	end
	for i = _nIndex, table.nums(_list) do
		local pLayer = _list[i]
		if pLayer then
			pLayer:stopAllActions()
			self:playTeamArm(pLayer,e_type_fight_action.stand,e_type_fight_action.stand)
		end
	end
end

--已经弹出结束对话框，停止所有的动作表现
function FightController:stopAllFightActions(  )
	-- body
		if self.nCheckScheduler ~= nil then
	        MUI.scheduler.unscheduleGlobal(self.nCheckScheduler)
	        self.nCheckScheduler = nil
	        self.tCheckShowLists = nil
		end
	if self.pBottomLayers then
		if table.nums(self.pBottomLayers) > 0 then
			for k, v in pairs (self.pBottomLayers) do
				if(not tolua.isnull(v)) then
					v:stopAllActions()
					-- if v.pMHeroLayer and v.pMHeroLayer.pArmAction then --存在武将
					-- 	v.pMHeroLayer.pArmAction:stop()
					-- end
					-- if v.tMSoldierLayers and table.nums(v.tMSoldierLayers) > 0 then
					-- 	for n, m in pairs (v.tMSoldierLayers) do
					-- 		m:stopAllSoldiers()
					-- 	end
					-- end
					v:removeSelf()
					v = nil
				end
			end
		end
	end
	if self.pTopLayers then
		if table.nums(self.pTopLayers) > 0 then
			for k, v in pairs (self.pTopLayers) do
				if(not tolua.isnull(v)) then
					v:stopAllActions()
					-- if v.pMHeroLayer and v.pMHeroLayer.pArmAction then --存在武将
					-- 	v.pMHeroLayer.pArmAction:stop()
					-- end
					-- if v.tMSoldierLayers and table.nums(v.tMSoldierLayers) > 0 then
					-- 	for n, m in pairs (v.tMSoldierLayers) do
					-- 		m:stopAllSoldiers()
					-- 	end
					-- end
					v:removeSelf()
					v = nil
				end
			end
		end
	end
end

--播放士兵动作回调方法
function FightController:playSoldierAction( sMsgName, pMsgObj )
	if pMsgObj then
		--士兵相对于rootlayer的坐标
		local tSoldierPos = pMsgObj.tPos or cc.p(0,0)
		--方向（上方，下方）
		local nDir = pMsgObj.nDir or 1
		--动作类型
		local nActionType = pMsgObj.nAcionType or 1
		--当前该士兵的占位位置下标
		local nPos = pMsgObj.nPos or 1
		--播放动作的key值
		local sActionKey = pMsgObj.sActionKey or ""

		--战斗表现层相对于rootlayer的坐标
		local tFightLayerPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(
			self.pLayFight:convertToWorldSpace(cc.p(0, 0)))

		--计算坐标转化后士兵在fightlayer的位置
		local tRstPos = cc.p((tSoldierPos.x - tFightLayerPos.x) / __fEScale, 
			(tSoldierPos.y - tFightLayerPos.y) / __fEScale)

		--测试用的
		-- local pLabel = MUI.MLabel.new({
		--     UILabelType=2,
		--     text="" .. nPos,
		--     size=20,
		--     align = MUI.TEXT_ALIGN_CENTER,
		--     valign = MUI.TEXT_VALIGN_CENTER,
		--     })
	 --    pLabel:setName(tRstPos.x .. "_" .. tRstPos.y)
		-- pLabel:setPosition(tRstPos.x, tRstPos.y)
		-- self.pLayFight:addView(pLabel, self.nZorderActionLayer)
	    
		if nActionType == 1 then --射箭
			local pImgArrow = self.tSoliderActions[tRstPos.x .. "_" .. tRstPos.y .. "_" .. nActionType]
			if not pImgArrow then
				pImgArrow = MUI.MImage.new("tx/fight/p1_fight_arrow.png")
				pImgArrow:setViewTouched(false)
				self.pLayFight:addView(pImgArrow, self.nZorderActionLayer)
				self.tSoliderActions[tRstPos.x .. "_" .. tRstPos.y .. "_" .. nActionType] = pImgArrow
			end
			pImgArrow:setVisible(true)
			--加亮
   			-- pImgArrow:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

			local tTmp = luaSplit(sActionKey, "_")
			if tTmp and table.nums(tTmp) == 5 then --必需满足该条件
				--计算初始位置
				local tStartPos = cc.p(0,0)
				--计算终点位置
				local tEndPos = cc.p(0,0)
				--计算旋转角度
				local nRotate = 0
				if tonumber(tTmp[5]) == 1 then --攻击1
					if nDir == 1 then --下方
						--设置旋转角度
						nRotate = 60
						tStartPos = cc.p(tRstPos.x + 26,
							tRstPos.y + 20)
						tEndPos = cc.p(math.sqrt(self.fDisArrow * self.fDisArrow 
							- self.fDisArrow / 2 * self.fDisArrow / 2), self.fDisArrow / 2)
					elseif nDir == 2 then --上方
						--设置旋转角度
						nRotate = -120
						tStartPos = cc.p(tRstPos.x - 26,
							tRstPos.y - 5)
						tEndPos = cc.p(-math.sqrt(self.fDisArrow * self.fDisArrow 
							- self.fDisArrow / 2 * self.fDisArrow / 2), -self.fDisArrow / 2)
					end
				elseif tonumber(tTmp[5]) == 2 then --攻击2
					if nDir == 1 then --下方
						nRotate = 0
						tStartPos = cc.p(tRstPos.x + 3,
							tRstPos.y + pImgArrow:getHeight()  / 2)
						tEndPos = cc.p(0,self.fDisArrow)
						
					elseif nDir == 2 then --上方
						--设置旋转角度
						nRotate = 0
						tStartPos = cc.p(tRstPos.x - 3,
							tRstPos.y - pImgArrow:getHeight()  / 2)
						tEndPos = cc.p(0,-self.fDisArrow)
					end
				elseif tonumber(tTmp[5]) == 3 then --攻击3
					if nDir == 1 then --下方
						--设置旋转角度
						nRotate = 85
						tStartPos = cc.p(tRstPos.x + 30,
							tRstPos.y + 10)
						tEndPos = cc.p(self.fDisArrow, 0)
					elseif nDir == 2 then --上方
						--设置旋转角度
						nRotate = -90
						tStartPos = cc.p(tRstPos.x - 30,
							tRstPos.y + 8)
						tEndPos = cc.p(-self.fDisArrow, 0)
					end
				end
				--设置旋转角度
				pImgArrow:setRotation(nRotate)
				--设置初始位置
				pImgArrow:setPosition(tStartPos)
				--开始射箭
				__moveByPos(pImgArrow,tEndPos,function (  )
					-- body
					pImgArrow:setPosition(tStartPos)
					pImgArrow:setVisible(false)
				end)
			end
		    
		end

	end
end

--血量变化(战斗界面顶部信息)
function FightController:onBloodChange( sMsgName, pMsgObj  )
	-- body
	local tD = pMsgObj
	if tD then
		if tD.bDeath then --表示死亡了
			if tD.nDir == 1 then --下方
				local tNextHero = self.tBothSidesDatas[1][self.nHeroBIndex + 1]
				if tNextHero then
					self.nHeroBIndex = self.nHeroBIndex + 1
					tD.nCur = tNextHero.nCurBlood
					tD.nAll = tNextHero.trp
					--刷新等级名字
					self.pFightLayer:setCurHeroInfo(1,tNextHero,self.nHeroBIndex)

				else --武将消失
					self.pFightLayer:fadeOutItemHeroByDir(1,true)
					self:beReadyFightOver()
				end
			elseif tD.nDir == 2 then --上方
				local tNextHero = self.tBothSidesDatas[2][self.nHeroTIndex + 1]
				if tNextHero then
					self.nHeroTIndex = self.nHeroTIndex + 1
					tD.nCur = tNextHero.nCurBlood
					tD.nAll = tNextHero.trp
					--刷新等级名字
					self.pFightLayer:setCurHeroInfo(2,tNextHero,self.nHeroTIndex)
				else --武将消失
					self.pFightLayer:fadeOutItemHeroByDir(2,true)
					self:beReadyFightOver()
				end
			end
		end
		self.pFightLayer:onBloodChangeOnTop(tD)
	end
end

--报招特效
--_nType：技能类型
--_tHeroDatas：播放技能武将的数据
--_handler：报招完成回调时间
function FightController:playCallSkillArm( _nType, _tHeroDatas, _handler )
	-- body
	if _tHeroDatas then
		if bHasEndCallback then --如果已经回调结果了，那么不需要表现
			return
		end
		--先移除报招动画
		self:removeCallSkillArm()
		--报招动画
		local sName = createAnimationBackName("tx/fight_normal/", "sg_jndz_bz_001")
	    self.pCallSkillArm = ccs.Armature:create(sName)

	    --替换骨骼（技能名字）
	    local sSkillName = "#v1_fight_skill_name" .. _nType .. ".png"
	    changeBoneWithPngName(self.pCallSkillArm,"jnmz_01",sSkillName) 
	    changeBoneWithPngName(self.pCallSkillArm,"jnmz_02",sSkillName,true) 
	    changeBoneWithPngName(self.pCallSkillArm,"jnmz_03",sSkillName,true) 
	    --替换骨骼（相框）
	    changeBoneWithImage(self.pCallSkillArm,"xk01","ui/v1_img_callfight_bg.png",true) 
	    changeBoneWithImage(self.pCallSkillArm,"xk02","ui/v1_img_callfight_bg.png") 
	    --替换骨骼（武将全身像）
	    local pLyHeroBg = creatHeroView(_tHeroDatas.sImg)
	    changeBoneWithNode(self.pCallSkillArm,"wjtp01",pLyHeroBg)
	    pLyHeroBg:setPosition(-pLyHeroBg:getWidth() / 2 , -pLyHeroBg:getHeight() / 2 )
	    -- changeBoneWithImage(self.pCallSkillArm,"wjtp01",_tHeroDatas.sImg) 
	    --替换骨骼（武将名字层）
	    local pLayName = MUI.MLayer.new()
	    pLayName:setBackgroundImage("#v1_img_fight_name_bg.png")
	    pLayName:setLayoutSize(189, 49)
	    local pLbName = MUI.MLabel.new({text = _tHeroDatas.sName or "",size = 20})
	    pLbName:setPosition(pLayName:getWidth() / 2, pLayName:getHeight() / 2)
	    pLayName:addView(pLbName)
	    --设置名字层位置
	    pLayName:setPosition(-pLayName:getWidth() / 2, -pLayName:getHeight() / 2)
	    changeBoneWithNode(self.pCallSkillArm,"wjmz01",pLayName)

	    --设置位置
	    self.pCallSkillArm:setPosition(self.pFightLayer:getContentSize().width/2,self.pFightLayer:getContentSize().height/2)
	    -- 播放特效
	    self.pCallSkillArm:getAnimation():play("Animation1", -1, -1)
	    self.pFightLayer:addChild(self.pCallSkillArm,10)
	    --播放音效
	    Sounds.playEffect(Sounds.Effect.tFight.skill)

	    --结束事件回调
	    self.pCallSkillArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
			if (eventType == MovementEventType.COMPLETE) then
				--移除武将纹理
				--removeHeroUnuserPvr()
				if _handler then
					_handler()
				end
			end
		end)
	    --帧事件回调
		self.pCallSkillArm:getAnimation():setFrameEventCallFunc(function ( pBone, frameEventName, originFrameIndex, currentFrameIndex ) 
			if frameEventName == "dhychd001" then
				local action = cc.MoveTo:create(0.21, cc.p(-700, self.pFightLayer:getContentSize().height/2))
				local actionEnd = cc.CallFunc:create(function (  )
					
				end)
				local allActions = cc.Sequence:create(action,actionEnd)
				self.pCallSkillArm:runAction(allActions)
			end
		end) 
	else
		--移除武将纹理
		--removeHeroUnuserPvr()
		if _handler then
			_handler()
		end
	end
	
end

--移除报招技能特效
function FightController:removeCallSkillArm( )
	-- body
	if self.pCallSkillArm then
		self.pCallSkillArm:stopAllActions()
		self.pCallSkillArm:removeSelf()
		self.pCallSkillArm = nil
	end
end

--技能表现
--nType:1：兵将技能 2：弓将技能 3：骑将技能
--nDir：1：下方 2：上方
--handler：技能结束回调事件
function FightController:playSkillArm( nType, nDir, handler )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
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
		self:showBJSkill()
	elseif nType == 3 then --弓将
		--展示弓将技能
		self:showGJSkill(nDir)
	elseif nType == 2 then --骑将
		self:showQJSkill(nDir)
	end
end

--移除所有的技能表现
function FightController:removeAllSkillArms(  )
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

--兵将技能
function FightController:showBJSkill(  )
	-- body
	--引入纹理
	addFightTextureByPlistName("tx/fight/p1_fight_skill_bj_001")

	self.nAllCountBaoJian = 5 --一共5把宝剑

	--配置五把剑的表现参数
	for i = 1, self.nAllCountBaoJian do
		local tParam = {}
		if i == 1 then
			tParam.fTime = 0
			tParam.tPos = cc.p(214,557)
			tParam.fScale = 1.0
		elseif i == 2 then
			tParam.fTime = 0.33
			tParam.tPos = cc.p(383,440)
			tParam.fScale = 0.8
		elseif i == 3 then
			tParam.fTime = 0.42
			tParam.tPos = cc.p(535,430)
			tParam.fScale = 1.1
		elseif i == 4 then
			tParam.fTime = 0.5
			tParam.tPos = cc.p(141,575)
			tParam.fScale = 0.8
		elseif i == 5 then
			tParam.fTime = 0.67
			tParam.tPos = cc.p(329,517)
			tParam.fScale = 1.2
		end
		tParam.nIndex = i --标志着第几把剑
		--屏幕设配重置位置
		tParam.tPos = resetPosByTarget(tParam.tPos)
		self:showBJOneJian(tParam)
	end 
	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.saber)
	
end

--一把剑技能表现
--_tParams：表现参数 以下为参数字段
--_fDelayTime：延迟多长时间
--_tPos：位置
--_fScale：缩放值
function FightController:showBJOneJian( _tParams )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	if not _tParams then
		print("五把剑的参数有错误.....")
		return
	end
	local fDelayTime = _tParams.fTime or 0
	local tPos = _tParams.tPos or cc.p(self.pFightLayer:getWidth()/2, self.pFightLayer:getHeight()/2)
	local fScale = _tParams.fScale or 1.0
	local nWhich = _tParams.nIndex or 1 --第几把剑
	--存放剑的层
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(2, 2)
	pLay:setPosition(tPos.x - pLay:getWidth() / 2, tPos.y - pLay:getHeight() / 2)
	self.pFightLayer:addView(pLay, 100)
	--添加到列表中
	table.insert(self.tAllSkillArms, pLay)

	--播放一把剑
	doDelayForSomething(pLay, function (  )
		-- body
		for i = 1, 5 do
			local pArm = MArmatureUtils:createMArmature(
				tFightArmDatas["100_" .. i], 
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
			    		if nWhich == self.nAllCountBaoJian then
			    			--表示已经结束了技能特效
			    			--背景变亮
			    			self:tintToFightBg(2)
			    			--回调结束事件
			    			self:callBackForEndSkillShow(1)
			    		end
			    	end
			    	
			    end, Scene_arm_type.fight)
			if pArm then
				if i == 2 then --注册帧回调时间
					pArm:setFrameEventCallFunc(function ( nCurFrame )
						-- body
						if nCurFrame == 4 then
							self:shockFloorByType(1)
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
function FightController:showGJSkill( _nDir )
	-- body
	self.nFinishCountJianShow = 0 --有多少支箭表现了
	self.nAllCountGongJian = 19 --总共有19支箭
	--引入纹理
	addFightTextureByPlistName("tx/fight/p1_fight_skill_gj_001")
	--随机19条箭
	for i = 1, self.nAllCountGongJian do
		local tPos = cc.p(0,0)
		if i >= 1 and i < 3 then --位置1
			tPos = cc.p(185,556)
		elseif i >= 3 and i < 6 then --位置2
			tPos = cc.p(273,543)
		elseif i >= 6 and i < 8 then --位置3
			tPos = cc.p(223,494)
		elseif i >= 8 and i < 10 then --位置4
			tPos = cc.p(337,501)
		elseif i >= 10 and i < 13 then --位置5
			tPos = cc.p(293,454)
		elseif i >= 13 and i < 16 then --位置6
			tPos = cc.p(406,462)
		elseif i >= 16 and i < 18 then --位置7
			tPos = cc.p(355,412)
		elseif i >= 18 and i < 20 then --位置8
			tPos = cc.p(441,394)
		end

		if _nDir == 2 then
			tPos.x = tPos.x + 100 * getScreenScaleForFight()
			tPos.y = tPos.y - 40 * getScreenScaleForFight()
		end
		

		tPos.y = tPos.y + 198 --因为需要计算的弓箭图片的中点，所以要加速198
		--x,y坐标在做-45至45的随机偏移值
		tPos.x = tPos.x + math.random(-45,45)
		tPos.y = tPos.y + math.random(-45,45)
		--参数
		local tParams = {}
		--随机坐标
		tParams.tPos = tPos
		--随机延迟时间
		tParams.fDelayTime = 1 * (math.random(1,10)) * 0.1
		--随机缩放值
		tParams.fScale = math.random(7,12) * 0.1
		--方向
		tParams.nDir = _nDir

		--屏幕设配重置位置
		tParams.tPos = resetPosByTarget(tParams.tPos)

		--播放特效
		self:showGJOneJian(tParams)

	end
	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.archer)
end

--射一箭技能表现
--_tParams：表现参数
function FightController:showGJOneJian( _tParams )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	if not _tParams then
		return
	end

	--参数初始化
	local fDelayTime = _tParams.fDelayTime or 0
	local tPos = _tParams.tPos or cc.p(self.pFightLayer:getWidth()/2, self.pFightLayer:getHeight()/2)
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
	self.pFightLayer:addView(pLay, 100)

	--添加到列表中
	table.insert(self.tAllSkillArms, pLay)

	doDelayForSomething(pLay,function (  )
		-- body
		local pArm = MArmatureUtils:createMArmature(
			tFightArmDatas["101_1"], 
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
					if self.nFinishCountJianShow == self.nAllCountGongJian then
						self.nFinishCountJianShow = 0 --有多少支箭表现了
						--背景变亮
						self:tintToFightBg(2)
						--回调结束事件
						self:callBackForEndSkillShow(2)
					end
				end
			end)
			--角度旋转
			pArm:setRotation(fCurAngle)
			--设置缩放值
			pLay:setScale(fScale)
			pArm:play(1)
		end
	end,fDelayTime)
end

--射箭后地面爆炸特效
--_nDir：1：下方 2：上方
--_pLay：播放特效的层
--_fCurAngle：角度偏移量
--_fScale：缩放值
function FightController:showGJOneBombFloor( _nDir, _pLay, _fCurAngle, _fScale )
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
		tFightArmDatas["101_2"], 
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
function FightController:showQJSkill( _nDir )
	-- body
	--引入纹理
	addFightTextureByPlistName("tx/fight/p1_fight_skill_qj_001")
	self.nAllCountMa = 12 --一共12只马
	for i = 1, self.nAllCountMa do
		--参数集合
		local tParams = {}
		if i == 1 then
			tParams.tPos = cc.p(226,338)
			tParams.fDelayTime = 0
		elseif i == 2 then
			tParams.tPos = cc.p(22,486)
			tParams.fDelayTime = 0.04
		elseif i == 3 then
			tParams.tPos = cc.p(113,359)
			tParams.fDelayTime = 0.09
		elseif i == 4 then
			tParams.tPos = cc.p(0,494)
			tParams.fDelayTime = 0.29
		elseif i == 5 then
			tParams.tPos = cc.p(205,332)
			tParams.fDelayTime = 0.33
		elseif i == 6 then
			tParams.tPos = cc.p(144,462)
			tParams.fDelayTime = 0.58
		elseif i == 7 then
			tParams.tPos = cc.p(111,361)
			tParams.fDelayTime = 0.50
		elseif i == 8 then
			tParams.tPos = cc.p(24,596)
			tParams.fDelayTime = 0.54
		elseif i == 9 then
			tParams.tPos = cc.p(383,347)
			tParams.fDelayTime = 0.58
		elseif i == 10 then
			tParams.tPos = cc.p(145,467)
			tParams.fDelayTime = 0.93
		elseif i == 11 then
			tParams.tPos = cc.p(25,597)
			tParams.fDelayTime = 0.92
		elseif i == 12 then
			tParams.tPos = cc.p(397,347)
			tParams.fDelayTime = 0.96
		end
		--标志第几只马
		tParams.nWhich = i
		tParams.fScale = math.random(85, 110) * 0.01
		--如果是上冲下,重新计算一下坐标
		if _nDir == 2 then
			--屏幕设配重置位置
			tParams.tPos.x = display.width - (tParams.tPos.x + 50) * getScreenScaleForFight()
			tParams.tPos.y = display.height - (tParams.tPos.y + 150) * getScreenScaleForFight() 
		else
			--屏幕设配重置位置
			tParams.tPos = resetPosByTarget(tParams.tPos)
		end
		self:showQJOneMa(tParams,_nDir)
	end

	--播放音效
    Sounds.playEffect(Sounds.Effect.tFight.rider)

	--地面震动
	self:shockFloorByType(3)

	
end

--一只马特效
--_tParams：参数集合
--_nDir：1：下方 2：上方
function FightController:showQJOneMa( _tParams, _nDir )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	if not _tParams then return end
	--初始化参数
	local tPos = _tParams.tPos or cc.p(self.pFightLayer:getWidth()/2, self.pFightLayer:getHeight()/2)
	local fScale = _tParams.fScale or 1
	local fDelayTime = _tParams.fDelayTime or 0
	local nWhich = _tParams.nWhich or 1 --第几只马

	--存放马的层
	local pLay = MUI.MLayer.new()
	pLay:setLayoutSize(2, 2)
	pLay:setPosition(tPos.x - pLay:getWidth() / 2, tPos.y - pLay:getHeight() / 2)
	self.pFightLayer:addView(pLay, 1000 - tPos.y + 100)
	--添加到列表中
	table.insert(self.tAllSkillArms, pLay)

	local sKey = "103_1"--下冲上
	local tEndPos = cc.p(317,170)
	if _nDir == 2 then --上冲下
		sKey = "102_1"
		tEndPos = cc.p(-317,-170)
	end

	doDelayForSomething(pLay,function (  )
		-- body
		local pArm = MArmatureUtils:createMArmature(
			tFightArmDatas[sKey], 
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
			local actionMoveBy = cc.MoveBy:create(1, tEndPos)
			--回调
			local fCallback = cc.CallFunc:create(function (  )
				-- body
				if pArm then
					pArm:setVisible(false)
					pArm:stop()
					-- pArm:removeSelf()
					-- pArm = nil
					if nWhich == self.nAllCountMa then
						--背景变亮
						self:tintToFightBg(2)
						--回调结束事件
						self:callBackForEndSkillShow(3)
					end
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
			local actionsDo = cc.Sequence:create(doDelayThings(0.1),doDelayThings(1/5),doDelayThings(1/5),doDelayThings(1/5),doDelayThings(1/5))
			--所有的动作
			local allActions = cc.Spawn:create(actions,actionsDo)
			pLay:runAction(allActions)
		end
	end,fDelayTime)

end

--马蹄光圈
function FightController:showLightRing( _pLay, _fScale )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	local pArm = MArmatureUtils:createMArmature(
		tFightArmDatas["103_2"], 
		self.pFightLayer, 
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
function FightController:showFire( _pLay, _fScale )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	local pArm = MArmatureUtils:createMArmature(
		tFightArmDatas["103_3"], 
		self.pFightLayer, 
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
function FightController:showBurningFloor( _pLay, _fScale )
	-- body
	if bHasEndCallback then --如果已经回调结果了，那么不需要表现
		return
	end
	local pArm = MArmatureUtils:createMArmature(
		tFightArmDatas["103_4"], 
		self.pFightLayer, 
		20, 
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
function FightController:shockFloorByType( _nType )
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

--技能表现结束回调
function FightController:callBackForEndSkillShow( nArmType )
	-- body
	--回调结束事件
	if self.__nHandlerSkillEnd then
		self.__nHandlerSkillEnd()
	end
end


return FightController