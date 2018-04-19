-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-08 17:38:27 星期三
-- Description: 作战单位 （将领）
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local FightUnitGeneral = class("FightUnitGeneral", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nDir：方向 
function FightUnitGeneral:ctor( _nDir )
	-- body
	self:myInit()

	if not _nDir then
		print("FightUnitGeneral.未指明方向")
		return
	end
	self.nDirection = _nDir

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FightUnitGeneral",handler(self, self.onFightUnitGeneralDestroy))
end

--初始化成员变量
function FightUnitGeneral:myInit(  )
	-- body
	self.tCurDatas			= 		nil  --武将数据
	self.nDirection 		= 		1 	 --1：下方   2：上方
	self.pArmAction 		= 		nil  --动作
	self.nActionType 		= 		nil  --当前动作类型


end

--初始化控件
function FightUnitGeneral:setupViews( )
	-- body
	self:setLayoutSize(1, 1)

end

-- 修改控件内容或者是刷新控件数据
function FightUnitGeneral:updateViews(  )
	-- body
	if self.tCurDatas then
		-- self:playArm(e_type_fight_action.run)
	end
end

-- 析构方法
function FightUnitGeneral:onFightUnitGeneralDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function FightUnitGeneral:regMsgs( )
	-- body
end

-- 注销消息
function FightUnitGeneral:unregMsgs(  )
	-- body
end


--暂停方法
function FightUnitGeneral:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightUnitGeneral:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--_tData：武将数据
function FightUnitGeneral:setCurData( _tData)
	-- body
	if not _tData then
		print("武将数据不能为nil")
		return 
	end

	self.tCurDatas = _tData
	self:updateViews()

end

--播放特效
-- e_type_fight_action = {         -- 战斗动作
--     stand                   = 1,         -- 待命
--     run 					   = 2, 		-- 跑步
--     attack 				   = 3, 		-- 攻击
--     death 				   = 4, 		-- 死亡
-- }
--_nType：待机，攻击，跑步，死亡
function FightUnitGeneral:playArm( _nType )
	-- body

	if not self.tCurDatas then
		print("FightUnitGeneral.数据不能为 nil")
		return
	end

	if not _nType then
		print("FightUnitGeneral.当前动作类型为 nil")
		return
	end

	if not self.nActionType and self.nActionType == _nType then
		print("当前为这种类型，返回武将")
		return
	end
	self.nActionType = _nType

	local nHeroType = 10001
	if self.nDirection == 1 then
		nHeroType = 10001
	else
		nHeroType = 10002
	end
	--动作类型
	local nArType = __getRandomForArmByType(1,_nType) or 1
	--动作表现key值
	self.sArmKey = nHeroType .. "_" .. self.nDirection .. "_" .. _nType .. "_" .. nArType

	--替换当前动作
	if self.pArmAction then
		-- self.pArmAction:stop()
		-- MArmatureUtils:removeMArmature(self.pArmAction)
		-- self.pArmAction = nil
		self.pArmAction:setData(tFightArmDatas[self.sArmKey])
	else
		self.pArmAction = MArmatureUtils:createMArmature(
			tFightArmDatas[self.sArmKey], 
			self, 
			10, 
			cc.p(self:getWidth()/2, self:getHeight()/2),
		    function (  )
		    	--下一次播放的动作类型
		    	local nNextArType = __getRandomForArmByType(1,self.nActionType) or 1
		        if self.nActionType == e_type_fight_action.death then
		        	self:removeSelf()
		        	--如果存在重击
		        	-- if self.pArmThump then
		        	-- 	self.pArmThump:stop()
		        	-- 	MArmatureUtils:removeMArmature(self.pArmThump)
		        	-- 	self.pArmThump = nil
		        	-- end
		        elseif self.nActionType == e_type_fight_action.stand then
		        	self.sArmKey = nHeroType .. "_" .. self.nDirection .. "_" .. e_type_fight_action.stand .. "_" .. nNextArType
		        	self.pArmAction:setData(tFightArmDatas[self.sArmKey])
		        	self.pArmAction:play(1)
		        elseif self.nActionType == e_type_fight_action.attack then
		        	if __isFightOver then --已经战斗结束了
		        		self.sArmKey = nHeroType .. "_" .. self.nDirection .. "_" .. e_type_fight_action.stand .. "_" .. nNextArType
		        		--发送消息武将攻击动作完成（战斗即将结束）
		        		local tObj = {}
		        		tObj.bAllDeath = false
		        		sendMsg(ghd_fight_play_hero_attack_end,tObj)
		        	else
		        		self.sArmKey = nHeroType .. "_" .. self.nDirection .. "_" .. e_type_fight_action.attack .. "_" .. nNextArType
		        		--重击
		        		if nNextArType == 2 then 
		        			self:showThumpTx(nHeroType .. "_" .. self.nDirection .. "_" .. e_type_fight_action.thump .. "_1")
		        		end
		        	end
		        	self.pArmAction:setData(tFightArmDatas[self.sArmKey])
		        	self.pArmAction:play(1)
		        end
		    end, Scene_arm_type.fight)
	end
	
	if self.pArmAction then
		if _nType == e_type_fight_action.stand then
			self.pArmAction:play(1)
		elseif _nType == e_type_fight_action.run then
			self.pArmAction:play(-1)
		elseif _nType == e_type_fight_action.attack then
			self.pArmAction:play(1)
			--重击
			if nArType == 2 then 
				self:showThumpTx(nHeroType .. "_" .. self.nDirection .. "_" .. e_type_fight_action.thump .. "_1")
			end
		elseif _nType == e_type_fight_action.death then
			self.pArmAction:play(1)
		end
	end
	
end

--重击表现
--_sKey：key值
function FightUnitGeneral:showThumpTx( _sKey )
	-- body
	if not self.pArmThump then
		self.pArmThump = MArmatureUtils:createMArmature(
			tFightArmDatas[_sKey], 
			self, 
			10, 
			cc.p(self:getWidth()/2, self:getHeight()/2),
		    function (  )
		    	self.pArmThump:stopForImg("ui/daitu.png")
		    end, Scene_arm_type.fight)
	end
	if self.pArmThump then
		self.pArmThump:play(1)
	end
	--飙血
	self:showBloodTx()
end

--飙血
function FightUnitGeneral:showBloodTx( )
	-- body
	local nHeroType = 10001
	if self.nDirection == 1 then
		nHeroType = 10001
	else
		nHeroType = 10002
	end
	local sKey = nHeroType .. "_" .. self.nDirection .. "_" .. e_type_fight_action.blood .. "_1"
	if not self.pArmBlood then
		self.pArmBlood = MArmatureUtils:createMArmature(
			tFightArmDatas[sKey], 
			self, 
			10, 
			cc.p(self:getWidth()/2, self:getHeight()/2),
		    function (  )
		    	self.pArmBlood:stopForImg("ui/daitu.png")
		    end, Scene_arm_type.fight)
	end
	if self.pArmBlood then
		self.pArmBlood:play(1)
	end
end

--蓄力
function FightUnitGeneral:gatherForSkill( _handler )
	-- body
	local sKey = "10001_1_7_1"
	if self.nDirection == 2 then
		sKey = "10002_2_7_1"
	end
	if not self.pArmGather then
		self.pArmGather = MArmatureUtils:createMArmature(
			tFightArmDatas[sKey], 
			self, 
			10, 
			cc.p(self:getWidth()/2, self:getHeight()/2 + 20),
		    function ( pArm )
		    	self.pArmGather:removeSelf()
		    	self.pArmGather = nil
		    	--回调
		    	if _handler then
		    		_handler()
		    	end
		    end, Scene_arm_type.fight)
	end
	if self.pArmGather then
		self.pArmGather:play(1)
	end
end

return FightUnitGeneral