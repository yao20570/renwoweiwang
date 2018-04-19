-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-13 17:38:40 星期三
-- Description: 小方阵
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local FightSecMatrix = class("FightSecMatrix", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nDir：上下方位
--_nPos：左中右位置
--_nFightType:战报类型
function FightSecMatrix:ctor( _nDir, _nPos, _nFightType )
	-- body
	self:myInit()
	--设置大小
	self:setLayoutSize(2, 2)
	self:setNeedCheckScreen(false)
	self.nDir = _nDir or self.nDir
	self.nPos = _nPos or self.nPos
	self.bIsTLBoss = _nFightType == e_fight_report.tlboss and self.nDir == e_matrix_dir.up

	self:setupViews()
	self:onResume()

	self:setDestroyHandler("FightSecMatrix",handler(self, self.onFightSecMatrixDestroy))

end

--初始化成员变量
function FightSecMatrix:myInit(  )
	-- body
	self.nDir 				= 			1 			--1：下方   2：上方
	self.nPos 				= 			1 			--1：左 2：中 3：右

	--攻击
	self.nArmType 			= 	 		nil 		--当前动作
	self.pArmAction 		= 			nil 		--表现的动作
	self.sArmKey 			= 			nil 		--动作索引值
	--受击
	self.pArmHurt 			= 			nil 		--受击动作
	--蓄力
	self.pArmGetReady 		= 			nil 		--武将蓄力

	self.nAttackCallBack 	= 			nil 		--攻击回调
	self.nDeathCallBack 	= 			nil 		--死亡回调
	self.nHurtCallBack 		= 			nil 		--对方受击回调
	self.nSkillCallBack 	= 			nil 		--蓄力完回调播放技能

end

--初始化控件
function FightSecMatrix:setupViews( )
	-- body
end

-- 修改控件内容或者是刷新控件数据
function FightSecMatrix:updateViews(  )
	-- body
end

-- 析构方法
function FightSecMatrix:onFightSecMatrixDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function FightSecMatrix:regMsgs( )
	-- body
end

-- 注销消息
function FightSecMatrix:unregMsgs(  )
	-- body
end


--暂停方法
function FightSecMatrix:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightSecMatrix:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置攻击回调
function FightSecMatrix:setAttackCallBack( _nHandler )
	-- body
	self.nAttackCallBack = _nHandler
end

--设置死亡回调
function FightSecMatrix:setDeathCallBack( _nHandler )
	-- body
	self.nDeathCallBack = _nHandler
end

--设置对方受击回调
function FightSecMatrix:setHurtCallBack( _nHandler )
	-- body
	self.nHurtCallBack = _nHandler
end

--设置蓄力回调
function FightSecMatrix:setGatherCallBack( _nHandler )
	-- body
	self.nSkillCallBack = _nHandler
end

--停止动作
function FightSecMatrix:stopArm(  )
	-- body
	if self.pArmAction then
		self.pArmAction:stop()
	end
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

-- _nKind：兵种类型
-- _nType：动作类型
-- _nIndexM：武将内第几队
function FightSecMatrix:playArm(_nKind,_nType,_nIndexM)

	-- if self.nArmType == _nType then
	-- 	print("当前为这种类型，返回==================")
	-- 	return
	-- end

	--构建出动作索引值
	local sTemp = nil
	local nArmX, nArmY = self:getWidth()/2, self:getHeight()/2
	if _nIndexM == 1 and self.nPos == 2 then
		--限时Boss
		if self.bIsTLBoss then
			sTemp = self.nDir .. "_" .. 5 .. "_" .. _nType .. "_1"
			nArmX = nArmX + 20
			nArmY = nArmY + 90
		else
			sTemp = self.nDir .. "_" .. 4 .. "_" .. _nType .. "_1"
			--如果是武将，那么需要光圈
			self:showCircleArm()
		end
	else
		sTemp = self.nDir .. "_" .. _nKind .. "_" .. _nType .. "_1"
		--隐藏光圈
		if self.nPos == 2 then
			self:hideCircleArm()
		end
	end
	self.nArmX, self.nArmY = nArmX, nArmY

	--保存动作类型
	self.nArmType = _nType 
	--保存动作索引值
	self.sArmKey = sTemp
	--保存兵种类型
	self.nKind = _nKind

	--动作action
	if self.pArmAction == nil then
		self.pArmAction = MArmatureUtils:createMArmature(
			tFightSecArmDatas[self.sArmKey], 
			self, 
			10, 
			cc.p(nArmX, nArmY),
		    function (  )
		    	if self.nArmType == e_type_fight_sec_action.death then --死亡回调
		    		if self.nDeathCallBack then
		    			self.nDeathCallBack()
		    		end
		    	elseif self.nArmType == e_type_fight_sec_action.attack then --普攻回调
		    		if self.nAttackCallBack then
		    			self.nAttackCallBack()
		    		end
		    	elseif self.nArmType == e_type_fight_sec_action.thump then --重击回调
		    		if self.nAttackCallBack then
		    			self.nAttackCallBack()
		    		end
		    	end
		    end, Scene_arm_type.fight)

		--注册帧事件
		self.pArmAction:setFrameEventCallFunc(function ( _nCur )
			if self.nArmType == e_type_fight_sec_action.attack and self.nPos == 2 then --普攻回调
				--限时Boss普通帧回调播放普击特效
				if self.bIsTLBoss and _nCur == 4 then
					self:playTLBossKnifeArm(1)
				end
				if self.nHurtCallBackIndex and self.nHurtCallBackIndex == _nCur then --回调受击掉血表现
					if self.nHurtCallBack then
						self.nHurtCallBack(self.nKind,1)
					end
				end
			elseif self.nArmType == e_type_fight_sec_action.thump then --暴击
				--限时Boss普通帧回调播放普击特效
				if self.bIsTLBoss and _nCur == 5 then
					self:playTLBossKnifeArm(2)
				end
				if self.nGetReadyIndex and self.nGetReadyIndex == _nCur then --回调受击掉血表现
					--播放蓄力
					self:playGetReady(self.nKind)
				end
			end
		end)
	else
		self.pArmAction:setData(tFightSecArmDatas[self.sArmKey])
	end

	if self.pArmAction then
		if self.nArmType == e_type_fight_sec_action.attack and self.nPos == 2 then --普攻
			--获得对方受击回调帧下标
			self.nHurtCallBackIndex = nil
			if self.sArmKey == "1_1_3_1" or self.sArmKey == "2_1_3_1" then --步兵（普攻）
				--播放音效
				if self.nPos == 2 then
					Sounds.playEffect(Sounds.Effect.tFight.bugong)
				end
				self.nHurtCallBackIndex = 6
			elseif self.sArmKey == "1_2_3_1" or self.sArmKey == "2_2_3_1" then --骑兵（普攻）
				--播放音效
				if self.nPos == 2 then
					Sounds.playEffect(Sounds.Effect.tFight.qigong)
				end
				self.nHurtCallBackIndex = 6
			elseif self.sArmKey == "1_3_3_1" or self.sArmKey == "2_3_3_1" then --弓兵（普攻）
				--播放音效
				if self.nPos == 2 then
					Sounds.playEffect(Sounds.Effect.tFight.gongong)
				end
				self.nHurtCallBackIndex = 6
			elseif self.sArmKey == "1_4_3_1" or self.sArmKey == "2_4_3_1" or self.bIsTLBoss then --武将攻击（普攻）
				--播放限时Boss重击
				if self.bIsTLBoss then
					Sounds.playEffect(Sounds.Effect.huiji)
				else
					--播放音效
				    Sounds.playEffect(Sounds.Effect.tFight.wugong)
				end
				if self.nKind == 1 then
					self.nHurtCallBackIndex = 6
				elseif self.nKind == 2 then
					self.nHurtCallBackIndex = 6
				elseif self.nKind == 3 then
					self.nHurtCallBackIndex = 6
				end
			end
		elseif _nType == e_type_fight_sec_action.thump then --暴击
			--获得蓄力回调帧下标
			self.nGetReadyIndex = nil
			if self.sArmKey == "1_1_4_1" or self.sArmKey == "2_1_4_1" then
				--播放音效
				if self.nPos == 2 then
					Sounds.playEffect(Sounds.Effect.tFight.baoji)
				end
				self.nGetReadyIndex = 2
			elseif self.sArmKey == "1_2_4_1" or self.sArmKey == "2_2_4_1" then
				--播放音效
				if self.nPos == 2 then
					Sounds.playEffect(Sounds.Effect.tFight.baoji)
				end
				self.nGetReadyIndex = 2
			elseif self.sArmKey == "1_3_4_1" or self.sArmKey == "2_3_4_1" then
				--播放音效
				if self.nPos == 2 then
					Sounds.playEffect(Sounds.Effect.tFight.baoji)
				end
				self.nGetReadyIndex = 2
			elseif self.sArmKey == "1_4_4_1" or self.sArmKey == "2_4_4_1" or self.bIsTLBoss then
				--播放限时Boss重击
				if self.bIsTLBoss then
					Sounds.playEffect(Sounds.Effect.zhendi)
				else
					--播放音效
				    Sounds.playEffect(Sounds.Effect.tFight.zhongji)
				end
				if self.nKind == 1 then
					self.nGetReadyIndex = 2
				elseif self.nKind == 2 then
					self.nGetReadyIndex = 2
				elseif self.nKind == 3 then
					self.nGetReadyIndex = 2
				end
			end
		end

		--分类型播放动作
		if _nType == e_type_fight_sec_action.stand then
			self.pArmAction:play(-1)
		elseif _nType == e_type_fight_sec_action.run then
			self.pArmAction:play(-1)
		elseif _nType == e_type_fight_sec_action.attack then
			self.pArmAction:play(1)
		elseif _nType == e_type_fight_sec_action.thump then
			self.pArmAction:play(1)
		elseif _nType == e_type_fight_sec_action.death then
			self.pArmAction:play(1)
		end
	end
end

--受击表现
--_nKind：标志受到某种兵种的攻击
--_nType：表示受到普攻或者攻击
function FightSecMatrix:playHurtArm( _nKind, _nType )
	-- body
	--构建出动作索引值
	local sTemp = nil
	if _nType == 1 then --普通受击
		sTemp = _nKind .. "_10"
	else 				--暴击受击
		sTemp = "4_10"
	end

	local tOffset = cc.p(0,0)
	if self.nDir == 1 then
		tOffset = cc.p(2,9)
	else
		tOffset = cc.p(-7,9)
	end

	if self.pArmHurt == nil then
		self.pArmHurt = MArmatureUtils:createMArmature(
			tFightSecArmDatas[sTemp], 
			self, 
			20, 
			cc.p(self:getWidth()/2 + tOffset.x, self:getHeight()/2 + tOffset.y),
		    function ( _pArm )
		    	_pArm:setVisible(false)
		    end, Scene_arm_type.fight)
	else
		self.pArmHurt:setData(tFightSecArmDatas[sTemp])
	end

	if self.pArmHurt then
		self.pArmHurt:setVisible(true)
		self.pArmHurt:play(1)
	end
end

--蓄力表现（暴击）
function FightSecMatrix:playGetReady( _nKind )
	-- body
	--所有的蓄力只有一种表现
	if self.pArmGetReady == nil then
		self.pArmGetReady = MArmatureUtils:createMArmature(
			tFightSecArmDatas["5_10"], 
			self, 
			30, 
			cc.p(self:getWidth()/2, self:getHeight()/2),
		    function ( _pArm )
		    	_pArm:setVisible(false)
		    	--回调对方受击表现
		    	if self.nHurtCallBack and self.nPos == 2 then --这里只有中间才有注册回调时间
		    		self.nHurtCallBack(_nKind,2)
		    	end
		    end, Scene_arm_type.fight)
	end

	if self.pArmGetReady then
		self.pArmGetReady:setVisible(true)
		self.pArmGetReady:play(1)
	end
end

--武将蓄力(技能)
function FightSecMatrix:gatherForSkill( _handler )
	-- body
	local sKey = "1_4_6_1"
	if self.nDir == 2 then
		sKey = "2_4_6_1"
	end
	if not self.pArmGather then
		self.pArmGather = MArmatureUtils:createMArmature(
			tFightSecArmDatas[sKey], 
			self, 
			10, 
			cc.p(self:getWidth()/2, self:getHeight()/2 + 50),
		    function ( pArm )
		    	self.pArmGather:setVisible(false)
		    end, Scene_arm_type.fight)
		--注册帧事件
		self.pArmGather:setFrameEventCallFunc(function ( _nCur )
			if _nCur == 10 then --回调播放特效
				if self.nSkillCallBack then
					self.nSkillCallBack()
				end
			end
		end)
	end
	if self.pArmGather then
		self.pArmGather:setVisible(true)
		self.pArmGather:play(1)
	end
end

--展示武将底部光圈
function FightSecMatrix:showCircleArm(  )
	-- body
	if self.tCircleArms == nil then
		self.tCircleArms = {}
		for i = 1, 3 do
			local pCircleArm = MArmatureUtils:createMArmature(
				tFightSecArmDatas[self.nDir .. "_" .. i], 
				self, 
				1, 
				cc.p(self:getWidth()/2, self:getHeight()/2 - 10),
				nil, Scene_arm_type.fight)
			pCircleArm:play(-1)
			self.tCircleArms[i] = pCircleArm
		end
	else
		for k, v in pairs (self.tCircleArms) do
			v:setVisible(true)
		end
	end
end

--隐藏武将底部光圈
function FightSecMatrix:hideCircleArm(  )
	-- body
	if self.tCircleArms then
		for k, v in pairs (self.tCircleArms) do
			v:setVisible(false)
		end
	end
end

--BOSS动作刀光
--1是普攻，2是重攻
function FightSecMatrix:playTLBossKnifeArm( nType )
	local tArmData1 = nil
	if nType == 1 then
		tArmData1  = 
		{
            sPlist = "tx/other/rwww_sjbs_xdg_bk",
            nImgType = 1,
			nFrame = 8, -- 总帧数
			pos = {-2, -59}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 3,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "rwww_sjbs_xdg_bk_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 8, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	elseif nType == 2 then
		tArmData1  = 
		{
            sPlist = "tx/other/rwww_sjbs_ddg_bk",
            nImgType = 1,
			nFrame = 8, -- 总帧数
			pos = {-8, 21}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 3,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "rwww_sjbs_ddg_bk_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 8, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}
	end
	if not tArmData1 then
		return
	end
	local pLayEffectArm = MUI.MLayer.new()
	self:addChild(pLayEffectArm, 33)
	pLayEffectArm:setPosition(self.nArmX, self.nArmY)

	local pArm = MArmatureUtils:createMArmature(
        tArmData1, 
        pLayEffectArm, 
        0, 
        cc.p(0, 0),
        function ( _pArm )
        	_pArm:removeSelf()
        	pLayEffectArm:removeFromParent()
        end, Scene_arm_type.fight)
    if pArm then
    	pArm:play(1)
    end
end

return FightSecMatrix