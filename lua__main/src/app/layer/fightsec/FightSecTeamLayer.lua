-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-13 16:35:28 星期三
-- Description: 战斗方阵
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local FightSecMatrix = require("app.layer.fightsec.FightSecMatrix")

local FightSecTeamLayer = class("FightSecTeamLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nDir：方向（1：下方   2：上方）
--战报类型：nFightType
function FightSecTeamLayer:ctor( _nDir, _nFightType)
	-- body
	self:myInit()
	--设置大小
	self:setLayoutSize(2, 2)
	self:setNeedCheckScreen(false)
	-- self:setBackgroundImage("#v1_bg_1.png",{scale9 = true})

	self.nDir = _nDir or self.nDir
	self.nFightType = _nFightType
	self.bIsTLBoss = _nFightType == e_fight_report.tlboss and self.nDir == e_matrix_dir.up

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FightSecTeamLayer",handler(self, self.onFightSecTeamLayerDestroy))
end

--初始化成员变量
function FightSecTeamLayer:myInit(  )
	-- body
	self.nHeroPos 			= 			1 			--第几个武将
	self.nIndexM 			= 			1 			--第几个方阵
	self.nKind 				= 			1 			--士兵类型
	self.nDir 				= 			1 			--1：下方   2：上方

	self.pMatrixL 			= 			nil 		--左边士兵
	self.pMatrixC 			= 			nil 		--中间士兵
	self.pMatrixR 			= 			nil 		--右边士兵
	self.bShowFrame			= 			false 		--标记是否已经显示过底框
	self.sWho				=			""
end

--初始化控件
function FightSecTeamLayer:setupViews( )
	-- body
end

-- 修改控件内容或者是刷新控件数据
function FightSecTeamLayer:updateViews(  )
	-- body
end

--获得队伍相关数据
function FightSecTeamLayer:getCurData(  )
	-- body
	local tT = {}
	tT.nHeroPos = self.nHeroPos
	tT.nIndexM = self.nIndexM
	tT.nKind = self.nKind
	tT.nDir = self.nDir
	tT.sWho = self.sWho
	return tT
end

--获得当前队伍类型
function FightSecTeamLayer:getCurKind(  )
	-- body
	return self.nKind
end

--设置当前数据
--_nHeroPos：第几个武将
--_nIndexM：方阵下标
--_nKind：士兵类型
function FightSecTeamLayer:setCurDatas( _nHeroPos, _nIndexM, _nKind, _who)
	-- body
	
	if not _nHeroPos or not _nKind or not _nIndexM then return end

	self.nHeroPos = _nHeroPos
	self.nIndexM = _nIndexM
	self.nKind = _nKind
	self.sWho = _who
	--播放动作
	self:playArm(e_type_fight_sec_action.stand) --默认待机
end

--播放特效
-- e_type_fight_sec_action = {         -- 战斗动作
--     stand                   = 1,        -- 待命
--     run 					= 2, 		-- 跑步
--     attack 					= 3, 		-- 攻击
--     thump 					= 4, 		-- 重击
--     death 					= 5, 		-- 死亡
--     blood 					= 6, 		-- 飙血
--     gather 					= 7, 		-- 蓄力
-- }
function FightSecTeamLayer:playArm( _nType )
	if self.nIndexM and self.nKind then 
		if self.pMatrixC == nil then
			self.pMatrixC = FightSecMatrix.new(self.nDir,2, self.nFightType)
			self.pMatrixC:setPosition(self:getWidth() / 2, self:getHeight() / 2)
			self:addView(self.pMatrixC,10)
			--设置攻击回调
			self.pMatrixC:setAttackCallBack(handler(self, self.onAttackHandler))
			--设置死亡回调
			self.pMatrixC:setDeathCallBack(handler(self, self.onDeathHandler))
			--设置对方受击回调
			self.pMatrixC:setHurtCallBack(handler(self, self.onHurtHandler))
			--设置蓄力回调播放技能
			self.pMatrixC:setGatherCallBack(handler(self, self.onGatherHandler))
		end
		self.pMatrixC:playArm(self.nKind,_nType,self.nIndexM)

		--限时Boss上方不显示小兵
		if self.bIsTLBoss then
		else
			if self.pMatrixL == nil then
				self.pMatrixL = FightSecMatrix.new(self.nDir,1)
				self.pMatrixL:setPosition(self:getWidth() / 2 - 93, self:getHeight() / 2 + 40)
				self:addView(self.pMatrixL,10)
			end
			self.pMatrixL:playArm(self.nKind,_nType,self.nIndexM)

			if self.pMatrixR == nil then
				self.pMatrixR = FightSecMatrix.new(self.nDir,3)
				self.pMatrixR:setPosition(self:getWidth() / 2 + 93, self:getHeight() / 2 - 40)
				self:addView(self.pMatrixR,10)
			end
			self.pMatrixR:playArm(self.nKind,_nType,self.nIndexM)
		end
	end
end

--停止表现
--_nKind：标志受到某种兵种的攻击
--_nType：表示受到普攻或者攻击
function FightSecTeamLayer:stopArm(  )
	-- body
	if self.pMatrixC then
		self.pMatrixC:stopArm()
	end
	if self.pMatrixL then
		self.pMatrixL:stopArm()
	end
	if self.pMatrixR then
		self.pMatrixR:stopArm()
	end
end

--受击表现
--_nKind：标志受到某种兵种的攻击
--_nType：表示受到普攻或者攻击
function FightSecTeamLayer:playHurtArm( _nKind, _nType )
	-- body
	if self.pMatrixC then
		self.pMatrixC:playHurtArm(_nKind,_nType)
	end
	if self.pMatrixL then
		self.pMatrixL:playHurtArm(_nKind,_nType)
	end
	if self.pMatrixR then
		self.pMatrixR:playHurtArm(_nKind,_nType)
	end
end

--受到技能攻击表现
--handler：技能回调可播放下一条指令
--handler2：掉血表现相关回调
function FightSecTeamLayer:playSkillHurtArm( handler,handler2 )
	-- body
	self.nCount = 0
	--（执行两次）
	self:showAttackBackAndRed(handler,handler2)
end

--击退效果和变红
function FightSecTeamLayer:showAttackBackAndRed( handler, handler2 )
	-- body
	self.nCount = self.nCount + 1
	if self.nCount > 1 then
		doDelayForSomething(self,function (  )
			-- body
			if handler then
				handler()
			end
		end,0.5)
		
		return
	elseif self.nCount == 1 then
		if handler2 then
			handler2()
		end
	end
	--第一步骤
	local tPos = cc.p(0,0)
	if self.nDir == 1 then
		tPos = cc.p(-14,-9)
	elseif self.nDir == 2 then
		tPos = cc.p(14,9)
	end
	local ac1_moveby = cc.MoveBy:create(0.27, cc.p(tPos.x,tPos.y)) 
	local ac1_Tinto1 = cc.TintTo:create(0.01, 255, 0, 15)
	local ac1_Tinto2 = cc.TintTo:create(0.26, 255, 255, 255)
	local acTinto = cc.Sequence:create(ac1_Tinto1,ac1_Tinto2)
	local acSpawn1  = cc.Spawn:create(ac1_moveby,acTinto)
	local ac1_callBack = cc.CallFunc:create(function (  )
		-- body
		self:playArm(e_type_fight_sec_action.run)
	end)

	--第二步骤
	local ac2_moveby = cc.MoveBy:create(0.45, cc.p(-tPos.x,-tPos.y))
	local ac2_callBack = cc.CallFunc:create(function (  )
		-- body
		self:playArm(e_type_fight_sec_action.stand)
		--再次受击
		self:showAttackBackAndRed(handler,handler2)
	end)

	local allAcs = cc.Sequence:create(acSpawn1,ac1_callBack,ac2_moveby,ac2_callBack)
	self:runAction(allAcs)
end

--显示底部特效,_isEnd是否最后一排
function FightSecTeamLayer:showBottomEff(_callBack, _isEnd)
	-- body
	if self.bShowFrame then
		if _callBack then
			_callBack()
		end
		return
	end
	--限时Boss不显示底框
	if self.bIsTLBoss then
		if _callBack then
			_callBack()
		end
		return
	end

	self.bShowFrame = true;
	local pImg = nil
	if self.nDir == 1 then
		pImg = MUI.MImage.new("#sg_zd_dmxt_sa_001.png")
	else
		pImg = MUI.MImage.new("#sg_zd_dmxt_sa_002.png")
	end

	if pImg then
		self.pBottomImg = pImg
		self:addView(pImg, -1)
		pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg:setOpacity(255*0.2)
		local acFadeTo_1 = cc.FadeTo:create(0.2, 255)
		local acDelay_1 = cc.DelayTime:create(0.4)
		local allAcs = nil
		if _callBack then
			if _isEnd then
				allAcs = cc.Sequence:create(acFadeTo_1,cc.CallFunc:create(_callBack))
			else
				allAcs = cc.Sequence:create(acFadeTo_1,acDelay_1,cc.CallFunc:create(_callBack))
			end
		else
			allAcs = cc.Sequence:create(acFadeTo_1)
		end
		if allAcs then
			pImg:runAction(allAcs)
			pImg:setRotation(1)
			if self.nDir == 1 then
				pImg:setPosition(0,-10)
			elseif self.nDir == 2 then
				pImg:setPosition(0,-10)
			end
		end
	end
end

--隐藏底部特效
function FightSecTeamLayer:hideBottomEff()
	if self.pBottomImg then
		local acFadeTo = cc.FadeTo:create(0.7, 0)
		self.pBottomImg:runAction(acFadeTo)
	end
end

--武将蓄力
function FightSecTeamLayer:gatherForSkill(  )
	-- body
	if self.pMatrixC then
		self.pMatrixC:gatherForSkill()
	end
end

--注册攻击回调
function FightSecTeamLayer:setAttackHandler( _nHandler )
	-- body
	self.nHandlerAttack = _nHandler
end

--攻击回调
function FightSecTeamLayer:onAttackHandler( )
	-- body
	if self.nHandlerAttack then
		self.nHandlerAttack(self,self.nDir)
	end
end

--注册死亡回调
function FightSecTeamLayer:setDeathHandler( _nHandler )
	-- body
	self.nHandlerDeath = _nHandler
end

--死亡回调
function FightSecTeamLayer:onDeathHandler( )
	-- body
	if self.nHandlerDeath then
		self.nHandlerDeath(self,self.nDir)
	end
end

--注册对方受击回调
function FightSecTeamLayer:setHurtHandler( _nHandler )
	-- body
	self.nHandlerHurt = _nHandler
end

--对方受击回调
--_nKind：受击到哪种兵种的攻击
--_nType：1：普攻  2：暴击
function FightSecTeamLayer:onHurtHandler( _nKind, _nType )
	-- body
	if self.nHandlerHurt then
		self.nHandlerHurt(self,self.nDir,_nKind,_nType)
	end
end

--注册蓄力回调播放技能
function FightSecTeamLayer:setGatherHandler( _nHandler )
	-- body
	self.nHandlerGather = _nHandler
end

--蓄力回调播放技能
function FightSecTeamLayer:onGatherHandler( )
	-- body
	if self.nHandlerGather then
		self.nHandlerGather(self,self.nDir)
	end
end

-- 析构方法
function FightSecTeamLayer:onFightSecTeamLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function FightSecTeamLayer:regMsgs( )
	-- body
end

-- 注销消息
function FightSecTeamLayer:unregMsgs(  )
	-- body
end


--暂停方法
function FightSecTeamLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightSecTeamLayer:onResume( )
	-- body
	self:regMsgs()
end



return FightSecTeamLayer