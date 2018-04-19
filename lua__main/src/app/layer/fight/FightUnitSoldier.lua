-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-08 17:39:49 星期三
-- Description: 作战单位（士兵）
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local FightUnitSoldier = class("FightUnitSoldier", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nDir：方向 
function FightUnitSoldier:ctor( _nDir )
	-- body
	self:myInit()
	if not _nDir then
		print("FightUnitSoldier.未指明方向")
		return
	end

	self.nDirection = _nDir

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FightUnitSoldier",handler(self, self.onFightUnitSoldierDestroy))

end

--初始化成员变量
function FightUnitSoldier:myInit(  )
	-- body
	self.pTarget 			= 		nil 	-- 父层级
	self.nDirection 		= 		1 	    --1：下方   2：上方
	self.nActionType 		= 		nil     --当前动作类型
	self.bNeedShow 			= 		false   --是否需要播放动作
end

--初始化控件
function FightUnitSoldier:setupViews( )
	-- body
	self:setLayoutSize(1, 1)
end

-- 修改控件内容或者是刷新控件数据
function FightUnitSoldier:updateViews(  )
	-- body
	-- self:playArm(e_type_fight_action.run)
end

-- 析构方法
function FightUnitSoldier:onFightUnitSoldierDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function FightUnitSoldier:regMsgs( )
	-- body
end

-- 注销消息
function FightUnitSoldier:unregMsgs(  )
	-- body
end


--暂停方法
function FightUnitSoldier:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightUnitSoldier:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置父控件层
function FightUnitSoldier:setPTarget( _target )
	-- body
	if not _target then
		print("FightUnitSoldier.父层级不能为nil")
		return 
	end
	self.pTarget = _target
end

--设置是否需要播放动作
function FightUnitSoldier:setNeedShowState( _bEnable )
	-- body
	self.bNeedShow = _bEnable 
end

--播放特效
-- e_type_fight_action = {         -- 战斗动作
--     stand                   = 1,         -- 待命
--     run 					   = 2, 		-- 跑步
--     attack 				   = 3, 		-- 攻击
--     death 				   = 4, 		-- 死亡
-- }
--_nType：待机，攻击，跑步，死亡
function FightUnitSoldier:playArm( _nType )
	-- body

	if not self.pTarget or not self.pTarget.tCurDatas then
		print("FightUnitSoldier.数据不能为 nil")
		return
	end

	if not _nType then
		print("FightUnitGeneral.当前动作类型为 nil")
		return
	end

	if not self.nActionType and self.nActionType == _nType then
		print("当前为这种类型，返回士兵")
		return
	end
	--如果当前正在死亡，那么久不执行其他行为了
	if self.nActionType == e_type_fight_action.death then
		return
	end
	--先赋值
	self.nActionType = _nType
	--再判断是否需要播放动作
	if self.bNeedShow == false then
		return
	end
	--动作类型
	local nArType = __getRandomForArmByType(2,_nType) or 1
	--动作表现key值
	self.sArmKey = self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_" .. nArType
	--攻击类型需要对弓兵做特殊处理
	if self.nActionType == e_type_fight_action.attack then

		if self.pTarget.tCurDatas.nSId == 30003 or self.pTarget.tCurDatas.nSId == 30004 then --弓兵
			self.bThump = false --是否重击
			local nIndex = math.random(3)
			self.sArmKey =  self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_" .. nArType .. "_" .. nIndex
			if nIndex == 2 then
				self.bThump = true
				self:showThumpTxForGb(self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. e_type_fight_action.thump .. "_" .. nArType .. "_" .. nIndex,nIndex)
			end
		end
		--以下代码只是临时做备份，以后美术有可能要求这种表现
		-- if self.pTarget.tCurDatas.nSId == 30003 then --弓兵(下)
		-- 	if self.nPos == 1 or self.nPos == 2 or self.nPos == 4 then      --攻击动作3
		-- 		self.sArmKey =  self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_3"
		-- 	elseif self.nPos == 6 or self.nPos == 8 or self.nPos == 9 then  --攻击动作1
		-- 		self.sArmKey =  self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_1"
		-- 	else                                                           	--攻击动作2
		-- 		self.sArmKey =  self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_2"
		-- 	end
		-- elseif self.pTarget.tCurDatas.nSId == 30004 then --弓兵(上)
		-- 	if self.nPos == 1 or self.nPos == 2 or self.nPos == 4 then      --攻击动作3
		-- 		self.sArmKey =  self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_1"
		-- 	elseif self.nPos == 6 or self.nPos == 8 or self.nPos == 9 then  --攻击动作1
		-- 		self.sArmKey =  self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_3"
		-- 	else                                                           	--攻击动作2
		-- 		self.sArmKey =  self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. _nType .. "_2"
		-- 	end
		-- end
	end

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
		        local nNextArType = __getRandomForArmByType(2,self.nActionType) or 1
		        if self.nActionType == e_type_fight_action.death then   --死亡
		        	self:removeSelf() 
		        elseif self.nActionType == e_type_fight_action.attack then --攻击
		        	if __isFightOver then --已经战斗结束了
		        		self.sArmKey = self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. e_type_fight_action.stand .. "_" .. nNextArType
		        		self.pArmAction:setData(tFightArmDatas[self.sArmKey])
		        		self.pArmAction:play(1)
		        	else
		        		--如果是弓兵的话 需要再三套动作里面做随机切换
		        		if self.pTarget.tCurDatas.nSId == 30003 or self.pTarget.tCurDatas.nSId == 30004 then --弓兵
		        			self.bThump = false
		        			--判断是否需要集中式射箭表现
		        			if false then
		        				if self.pTarget.tCurDatas.nSId == 30003 then --下方
		        					local nNextIndex = 1
		        					if self.pTarget.nSide == e_matrix_side.center then
		        						if self.nPos == 1 or self.nPos == 2 or self.nPos == 4 then
		        							nNextIndex = 3
		        						elseif self.nPos == 6 or self.nPos == 8 or self.nPos == 9 then
		        							nNextIndex = 1
		        						else
		        							nNextIndex = 2
		        						end
		        					elseif self.pTarget.nSide == e_matrix_side.right then
		        						nNextIndex = 1
		        					elseif self.pTarget.nSide == e_matrix_side.left then
		        						nNextIndex = 3
		        					end
		        				elseif self.pTarget.tCurDatas.nSId == 30004 then  --上方
		        					local nNextIndex = 1
		        					if self.pTarget.nSide == e_matrix_side.center then
		        						if self.nPos == 1 or self.nPos == 2 or self.nPos == 4 then
		        							nNextIndex = 1
		        						elseif self.nPos == 6 or self.nPos == 8 or self.nPos == 9 then
		        							nNextIndex = 3
		        						else
		        							nNextIndex = 2
		        						end
		        					elseif self.pTarget.nSide == e_matrix_side.right then
		        						nNextIndex = 1
		        					elseif self.pTarget.nSide == e_matrix_side.left then
		        						nNextIndex = 3
		        					end
		        				end
		        				self.sArmKey = self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection 
		        					 	.. "_" .. e_type_fight_action.attack .. "_" .. nNextArType .. "_" .. nNextIndex
		        			else
		        				local nNextIndex = math.random(3)
		        				self.sArmKey = self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection 
		        				 	.. "_" .. e_type_fight_action.attack .. "_" .. nNextArType .. "_" .. nNextIndex
		        				--弓兵重击
		        				if nNextArType == 2 then
		        					self.bThump = true
		        					self:showThumpTxForGb(self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. e_type_fight_action.thump .. "_" .. nNextArType .. "_" .. nNextIndex,nNextIndex)
		        				end
		        			end
		        			self.pArmAction:setData(tFightArmDatas[self.sArmKey])
		        			self.pArmAction:play(1)
		        		else --步兵  骑兵
		        			self.sArmKey = self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. e_type_fight_action.attack .. "_" .. nNextArType
		        			--重击
		        			if nNextArType == 2 then 
		        				self:showThumpTx(self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. e_type_fight_action.thump .. "_1")
		        			end
		        			self.pArmAction:setData(tFightArmDatas[self.sArmKey])
		        			self.pArmAction:play(1)
		        		end
		        	end
		        elseif self.nActionType == e_type_fight_action.stand then --待命
		        	self.sArmKey = self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. e_type_fight_action.stand .. "_" .. nNextArType
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
			--弓兵的攻击需要做类型处理
			if self.pTarget.tCurDatas.nSId == 30003 or self.pTarget.tCurDatas.nSId == 30004 then --弓兵
				self.pArmAction:setFrameEventCallFunc(function ( _nCur )
					if _nCur == 6 then --第6帧回调，表现射箭效果
						--非重击的情况下才需要发箭
						if self.bThump == false then
							--发送播放士兵动作的消息
							local tObject = {}
							tObject.nDir = self.nDirection --方向
							tObject.nAcionType = 1
							tObject.nPos = self.nPos
							tObject.sActionKey = self.sArmKey
							tObject.tPos = RootLayerHelper:getCurRootLayer():convertToNodeSpaceAR(
								self:convertToWorldSpace(cc.p(0, 0)))
							--发送表现士兵动作的消息
							sendMsg(ghd_fight_play_soldier_action,tObject)
						end
						
					end
				end)
				self.pArmAction:play(1)
			else
				--重击
				if nArType == 2 then 
					self:showThumpTx(self.pTarget.tCurDatas.nSId .. "_" .. self.nDirection .. "_" .. e_type_fight_action.thump .. "_1")
				end
				self.pArmAction:play(1)
			end
		elseif _nType == e_type_fight_action.death then
			self.pArmAction:play(1)
		end
	end
	
end

--重击表现
--_sKey：key值
function FightUnitSoldier:showThumpTx( _sKey )
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
end

--弓兵重击
function FightUnitSoldier:showThumpTxForGb( _sKey, _nIndex )
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
	else
		self.pArmThump:setData(tFightArmDatas[_sKey])
	end
	
	if self.pArmThump then
		if self.nDirection == 1 then
			if _nIndex == 1 then
				self.pArmThump:setRotation(-30)
			elseif _nIndex == 2 then
				self.pArmThump:setRotation(-90)
			elseif _nIndex == 3 then
				self.pArmThump:setRotation(0)
			end
			
		elseif self.nDirection == 2 then
			if _nIndex == 1 then
				self.pArmThump:setRotation(153)
			elseif _nIndex == 2 then
				self.pArmThump:setRotation(90)
			elseif _nIndex == 3 then
				self.pArmThump:setRotation(180)
			end
		end
		self.pArmThump:play(1)
	end
end

return FightUnitSoldier