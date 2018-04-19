-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-02-08 17:34:59 星期三
-- Description: 对战方阵
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconHero = require("app.common.iconview.IconHero")
local FightUnitGeneral = require("app.layer.fight.FightUnitGeneral")
local FightUnitSoldier = require("app.layer.fight.FightUnitSoldier")

local FightMatrix = class("FightMatrix", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nDir：方向 
--_nType：武将或者小兵
function FightMatrix:ctor( _nDir, _nType )
	-- body
	self:myInit()

	if not _nDir then
		print("FightMatrix.方阵未指明方向")
		return
	end
	self.nDirection = _nDir
	self.nType = _nType or 1
	self:setLayoutSize(MATRIX_WIDTH, MATRIX_HEIGHT)

	self.pLayContent 	= 	MUI.MLayer.new(false,{scale9=true})
	self.pLayContent:setLayoutSize(MATRIX_WIDTH_INSIDE, MATRIX_HEIGHT_INSIDE)
	self:addView(self.pLayContent)
	-- self.pLayContent:setBackgroundImage("#v1_bg_1.png")
	centerInView(self, self.pLayContent)
	
	if self.nType == 1 then --武将才有血量层
		parseView("layout_fight_unit_hero", handler(self, self.onParseViewCallback))
	elseif self.nType == 2 then
		self:setupViews()
		self:onResume()
		--注册析构方法
		self:setDestroyHandler("FightMatrix",handler(self, self.onFightMatrixDestroy))
	end

end

--初始化成员变量
function FightMatrix:myInit(  )
	-- body

	self.nDirection 		= 		1 	 --1：下方   2：上方
	self.nType 				= 		1 	 --1：武将   2：小兵
	self.tCurDatas 			= 		nil  --当前数据
	self.pLayHeroSep 		= 		nil  --武将头上血量
	self.tCircleArms 		= 		{} 	 --武将底部圈特效表

	self.pUnitHero 			= 		nil  --武将单元
	self.tUnitSoldiers 		= 		{}   --9个士兵

	self.tSoldierDatas 		= 		nil  --方阵的数据（士兵特有的数据字段）

	self.nDefaultFmt 		= 		e_matrix_formation.fangzhen  --默认阵型
	self.nCurShowFmt 		= 		e_matrix_formation.fangzhen  --当前需要展示的阵型

end

--解析布局回调事件
function FightMatrix:onParseViewCallback( pView )
	-- body
	self.pLayHeroSep = pView
	self:addView(self.pLayHeroSep, 20)

	--设置血量层位置
	if self.nDirection == 1 then
		self.pLayHeroSep:setPosition(-10, 1.65 * MATRIX_HEIGHT)
	elseif self.nDirection == 2 then
		self.pLayHeroSep:setPosition(-10, 1.75 * MATRIX_HEIGHT)
	end

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FightMatrix",handler(self, self.onFightMatrixDestroy))
end


--初始化控件
function FightMatrix:setupViews( )
	-- body
	if self.pLayHeroSep then --存在血量层
		-- self.pLbBlood 			= 			self.pLayHeroSep:findViewByName("lb_blood")
		self.pBarBlood 			= 			self.pLayHeroSep:findViewByName("bar_blood")
		self.pLbHName 			= 			self.pLayHeroSep:findViewByName("lb_name")
		self.pImgType 			= 			self.pLayHeroSep:findViewByName("img_t")
		self.pLayHIcon 			= 			self.pLayHeroSep:findViewByName("lay_icon")
	end
end

--移出武将特殊层
function FightMatrix:removeSpeLayer(  )
	-- body
	if self.pLayHeroSep then --存在血量层
		self.pLayHeroSep:removeSelf()
		self.pLayHeroSep = nil
	end

	--移除武将底部圈
	self:removeCircleArm()
end

--设置血量显示
function FightMatrix:setbloodMsg()
	-- body
	if self.pLayHeroSep then --存在血量层
		--设置血量展示
		-- self.pLbBlood:setString(tostring(math.ceil(self.tCurDatas.nCurBlood)))
		--设置血量进度
		self.pBarBlood:setPercent(self.tCurDatas.nCurBlood / self.tCurDatas.trp * 100)
	end
end

-- 修改控件内容或者是刷新控件数据
function FightMatrix:updateViews()
	-- body
	if self.tCurDatas then
		if self.nType == 1 then   --武将
			if not self.pUnitHero then
				self.pUnitHero = FightUnitGeneral.new(self.nDirection)
				self:addView(self.pUnitHero,20)
				self.pUnitHero:setPosition((self:getWidth() - self.pUnitHero:getWidth()) / 2,
					(self:getHeight() - self.pUnitHero:getHeight()) / 2 + 10)
				--底部转圈
				self:createCircleArm()
			end
			--设置武将的数据
			self.pUnitHero:setCurData(self.tCurDatas)
			--设置武将阵容（不变阵）
			self.nDefaultFmt = e_matrix_formation.normal
			--设置武将名字
			if self.pLbHName and self.tCurDatas.tHeroInfo then
				self.pLbHName:setString(self.tCurDatas.tHeroInfo.sName)
			end
			--设置血条样式
			if self.pBarBlood then
				if self.nDirection == 1 then --下方
					self.pBarBlood:setBarImage("ui/bar/v1_bar_blue_9.png")
				elseif self.nDirection == 2 then --上方
					self.pBarBlood:setBarImage("ui/bar/v1_bar_yellow_14.png")
				end
			end
			--设置兵种
			if self.pImgType and self.tCurDatas.tHeroInfo then
				self.pImgType:setCurrentImage(getSoldierTypeImg(self.tCurDatas.tHeroInfo.nKind))
			end

			--设置头像
			if self.pLayHIcon then
				self.pIconHero = IconHero.new(TypeIconHero.NORMAL)
				self.pLayHIcon:addView(self.pIconHero)
				self.pIconHero:setCurData(self.tCurDatas.tHeroInfo)
				self.pIconHero:setScale(0.3)
			end
			--设置血量展示
			self:setbloodMsg()
		elseif self.nType == 2 then --士兵
			--设置士兵的数据
			self:setSoldierData(self.tCurDatas.phxs[self.nIndex])
			--获得默认阵型
			self.nDefaultFmt = __getDefaultMatrixFmt(self.tCurDatas.nSId)
			--初始化当前需要展示的阵型
			self.nCurShowFmt = __getDefaultMatrixFmt(self.tCurDatas.nSId)

			--九个士兵 
			if table.nums(self.tUnitSoldiers) == 0 then
				for i = 1, 9 do
					local pUnitSoldier = FightUnitSoldier.new(self.nDirection)
					pUnitSoldier:setPosition(self:getSoldierPos(i,pUnitSoldier)) 
					pUnitSoldier:setPTarget(self)
					pUnitSoldier.nPos = i
					self.pLayContent:addView(pUnitSoldier,10)
					table.insert(self.tUnitSoldiers, pUnitSoldier)

				end
			end
		end
	end
end

--（战斗中）变换阵型
-- _nShowFmtT：需要展示的阵容类型
-- _handler：完整散开的回调
function FightMatrix:moveAwayInFighting( _nShowFmtT, _handler )
	-- body

end

-- 散开阵型（士兵）
-- _nShowFmtT：需要展示的阵容类型
-- _handler：完整散开的回调
function FightMatrix:moveAway( _nShowFmtT, _handler )
	-- body
	if _nShowFmtT == nil then
		print("当前需要散开的阵型类型无法确定....")
		return
	end
	--方位标志
	local nSideType = 1 --1：中间 2：两侧
	if self.nSide ~= e_matrix_side.center then --不是中间
		nSideType = 2
	end
	local nRandomId = 1 --随机id，现在由于没有多个坐标组，先写死
	if _nShowFmtT == e_matrix_formation.fangzhen then --方阵
		self.nCurShowFmt = _nShowFmtT
		local sKeyPos = "1_" .. self.nDirection .. "_" .. nSideType .. "_" ..  nRandomId
		--散开阵型
		self:moveAwayForNormal(sKeyPos,_handler)
	elseif _nShowFmtT == e_matrix_formation.xiexian then --斜线
		--判断是否需要三段变阵
		--说明：如果本身的阵型等于需要展示的阵型，那么就需要三段变阵，反之为不需要
		local bChange = true
		if _nShowFmtT ~= self.nDefaultFmt then
			bChange = false
		else
		    --说明：如果当前正在展示的阵型不等于接下来需要展示的阵型，那么不需要三段变阵
		    if _nShowFmtT ~= self.nCurShowFmt then
		    	bChange = false
		    end
		end
		self.nCurShowFmt = _nShowFmtT
		if bChange then
			--骑兵特殊散开方式
			--拼接坐标key值
			local sKeyPos = "3_" .. self.nDirection .. "_" .. nSideType .. "_" ..  nRandomId 
			local nCount = 0
			for k, v in pairs (self.tUnitSoldiers) do
				self:moveAwayForQb(v,sKeyPos,function (  )
					-- body
					nCount = nCount + 1
					if nCount == table.nums(self.tUnitSoldiers) then
						if _handler then
							_handler()
						end
					end
				end,1,k)
			end
		else
			local sKeyPos = "3_" .. self.nDirection .. "_" .. nSideType .. "_" ..  nRandomId .. "_3"
			--散开阵型
			self:moveAwayForNormal(sKeyPos,_handler)
		end
	elseif _nShowFmtT == e_matrix_formation.gongxing then --弓形
		--判断是进攻还是遭遇
		--说明：如果本身的阵型等于需要展示的阵型，那么就为进攻，反之为遭遇
		local nMatrixT = 1
		if _nShowFmtT ~= self.nDefaultFmt then
			nMatrixT = 2
		end
		self.nCurShowFmt = _nShowFmtT
		local sKeyPos = "2_" .. self.nDirection .. "_" .. nSideType .. "_" ..  nRandomId .. "_" .. nMatrixT
		--散开阵型
		self:moveAwayForNormal(sKeyPos,_handler)
	end
end

--普通的变阵（一个位置移动到另一个位置）
--目前适应的变阵类型为（方阵，弓形，遭遇骑兵）
--_sKey:坐标key
--_handler：动作完成回调
function FightMatrix:moveAwayForNormal(_sKey, _handler )
	-- body
	local tPos = tMatrixPos[_sKey]
	local nCount = 0
	for k, v in pairs (self.tUnitSoldiers) do
		--计算移动到那个位置
		--强制设置动作为跑步
		v:playArm(e_type_fight_action.run)
		local tTmpPos = cc.p(tPos["pos" .. k].x - v:getWidth(),tPos["pos" .. k].y - v:getHeight())
		__moveToPos(v,tTmpPos,function (  )
			-- body
			nCount = nCount + 1
			v:playArm(e_type_fight_action.attack)
			if nCount == table.nums(self.tUnitSoldiers) then
				if _handler then
					_handler()
				end
			end
		end)
	end
end

--骑兵特殊散开阵型
--_pView：执行动作的view
--_sKey:坐标key
--_handler：动作完成回调
--_nIndex：第几个步骤
--_nPos：当前view在方阵中的位置
function FightMatrix:moveAwayForQb(_pView, _sKey, _handler, _nIndex, _nPos)
	-- body
	local tPos = tMatrixPos[_sKey .. "_" .. _nIndex]
	--计算移动到那个位置
	local tTmpPos = cc.p(tPos["pos" .. _nPos].x - _pView:getWidth(),
		                 tPos["pos" .. _nPos].y - _pView:getHeight())
	--强制设置动作为跑步
	_pView:playArm(e_type_fight_action.run)
	__moveToPos(_pView,tTmpPos,function (  )
		-- body
		if _nIndex == 3 then --3个步骤已经执行好了
			_pView:playArm(e_type_fight_action.attack)
			if _handler then
				_handler()
			end
		else
			_nIndex = _nIndex + 1
			self:moveAwayForQb(_pView, _sKey, _handler, _nIndex, _nPos)
		end
	end)
end

-- 析构方法
function FightMatrix:onFightMatrixDestroy(  )
	-- body
	self:onPause()

	--移除武将底部圈
	self:removeCircleArm()
end

-- 注册消息
function FightMatrix:regMsgs( )
	-- body
end

-- 注销消息
function FightMatrix:unregMsgs(  )
	-- body
end


--暂停方法
function FightMatrix:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function FightMatrix:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置当前数据
--_tData：数据
function FightMatrix:setCurData( _tData )
	-- body
	if not _tData then
		print("FightMatrix.方阵数据为nil")
		return
	end
	self.tCurDatas = _tData
	self:updateViews()
end

--获得当前数据
function FightMatrix:getCurData(  )
	-- body
	return self.tCurDatas
end

--设置士兵方阵数据
function FightMatrix:setSoldierData( _tData )
	-- body
	if not _tData then
		print("FightMatrix.士兵方阵数据为nil")
		return
	end
	self.tSoldierDatas = _tData
end

--获得士兵方阵数据
function FightMatrix:getSoldierData(  )
	-- body
	return self.tSoldierDatas
end

--播放特效
-- e_type_fight_action = {         -- 战斗动作
--     stand                   = 1,         -- 待命
--     run 					   = 2, 		-- 跑步
--     attack 				   = 3, 		-- 攻击
--     death 				   = 4, 		-- 死亡
-- }
--_nType：待机，攻击，跑步，死亡
function FightMatrix:playArm( _nType )
	-- body
	if self.nType == 1 then   --武将
		if self.pUnitHero then
			 self.pUnitHero:playArm(_nType)
		end
	elseif self.nType == 2 then --士兵
		self.nActionType = _nType
		if self.tUnitSoldiers and table.nums(self.tUnitSoldiers) > 0 then
			for k, v in pairs (self.tUnitSoldiers) do
				v:playArm(_nType)
			end
		end
	end
end

--停止所有士兵的表现
function FightMatrix:stopAllSoldiers(  )
	-- body
	if self.tUnitSoldiers and table.nums(self.tUnitSoldiers) > 0 then
		for k, v in pairs (self.tUnitSoldiers) do
			if v.pArmAction then
				v.pArmAction:stop()
			end
		end
	end
end

--蓄力
function FightMatrix:gatherForSkill( _handler )
	-- body
	if self.nType == 1 then   --武将
		--强行提高层级
		self:setLocalZOrder(self:getLocalZOrder() + 100)
		if self.pUnitHero then
			 self.pUnitHero:gatherForSkill(function (  )
			 	-- body
			 	self:setLocalZOrder(self:getLocalZOrder() - 100)
			 	_handler()
			 end)
		end
	end
end

--设置是否需要播放动作
function FightMatrix:setNeedShowState( _bEnable )
	-- body
	if self.nType == 2 then --士兵
		if self.tUnitSoldiers and table.nums(self.tUnitSoldiers) > 0 then
			for k, v in pairs (self.tUnitSoldiers) do
				v:setNeedShowState(_bEnable)
			end
		end
	end
end

--播放单个士兵死亡
--_fDelayTime：延迟时间
--_handler：死亡后的回调事件
function FightMatrix:playSoldierDead( _fDelayTime, _handler )
	-- body
	if self.tUnitSoldiers and table.nums(self.tUnitSoldiers) > 0 then
		local nSize = table.nums(self.tUnitSoldiers)
		if nSize == 1 then
			self.tUnitSoldiers[1]:playArm(e_type_fight_action.death)
			table.remove(self.tUnitSoldiers,1)
			self.tUnitSoldiers[1] = nil
		else
			--获得一个死亡随机下标
			local nRandomIndex = math.random(nSize)
			--死亡单元
			local pUnitRandom = self.tUnitSoldiers[nRandomIndex]
			if pUnitRandom then
				--先从表中删除掉
				table.remove(self.tUnitSoldiers,nRandomIndex)
				doDelayForSomething( pUnitRandom, function (  )
					-- body
					--死亡
					pUnitRandom:playArm(e_type_fight_action.death)
					if _handler then
						_handler()
					end
				end, _fDelayTime )
			end
		end
	end
end

--获得当前方阵中士兵的单位数据
function FightMatrix:getUnitSoldierLists( )
	-- body
	return self.tUnitSoldiers
end

--获得9个士兵的位置
--_pView:士兵布局
function FightMatrix:getSoldierPos( _nIndex, _pView )
	-- body
	if not _nIndex then
		print("FightMatrix._nIndex不能为nil")
		return
	end
	if _nIndex <= 0 or _nIndex > 9 then
		print("FightMatrix._nIndex越界")
		return
	end

	if not _pView then
		print("FightMatrix._pView不能为nil")
		return 
	end

	local tPos = cc.p(0,0)
	local nWidth = self.pLayContent:getWidth()
	local nHeight = self.pLayContent:getHeight()

	if _nIndex == 1 then
		tPos.x = nWidth / 2
		tPos.y = nHeight / 6 * 5
	elseif _nIndex == 2 then
		tPos.x = nWidth / 3
		tPos.y = nHeight / 6 * 4
	elseif _nIndex == 3 then
		tPos.x = nWidth / 6 * 4
		tPos.y = nHeight / 6 * 4
	elseif _nIndex == 4 then
		tPos.x = nWidth / 6 
		tPos.y = nHeight / 2
	elseif _nIndex == 5 then
		tPos.x = nWidth / 2 
		tPos.y = nHeight / 2
	elseif _nIndex == 6 then
		tPos.x = nWidth / 6 * 5 
		tPos.y = nHeight / 2
	elseif _nIndex == 7 then
		tPos.x = nWidth / 3 
		tPos.y = nHeight / 3
	elseif _nIndex == 8 then
		tPos.x = nWidth / 6 * 4
		tPos.y = nHeight / 3
	elseif _nIndex == 9 then
		tPos.x = nWidth / 2
		tPos.y = nHeight / 6
	end
	--居中显示
	tPos.x = tPos.x - _pView:getWidth() / 2
	tPos.y = tPos.y - _pView:getHeight() / 2
	return tPos

end

--创建武将底部圈
function FightMatrix:createCircleArm(  )
	-- body
	for i = 1, 3 do
		local pCircleArm = MArmatureUtils:createMArmature(
			tFightArmDatas[self.nDirection .. "_" .. i], 
			self, 
			1, 
			cc.p(self:getWidth()/2, self:getHeight()/2 - 10),
			nil, Scene_arm_type.fight)
		pCircleArm:play(-1)
		self.tCircleArms[i] = pCircleArm
	end
end

--移除武将底部圈
function FightMatrix:removeCircleArm(  )
	-- body
	if self.tCircleArms and table.nums(self.tCircleArms) > 0 then
		local nSize = table.nums(self.tCircleArms)
		for i = nSize, 1, -1 do
			self.tCircleArms[i]:removeSelf()
			self.tCircleArms[i] = nil
		end
	end
end

return FightMatrix

