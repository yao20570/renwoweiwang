-- Author: liangzhaowei
-- Date: 2017-04-06 09:57:57
-- 副本中我的部队信息

local MCommonView = require("app.common.MCommonView")
local ItemFubenMyArmy = class("ItemFubenMyArmy", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_pos 位置 _target父层
function ItemFubenMyArmy:ctor(_pos,_target,_armyType)
	-- body
	self:myInit()

	self.nPos = _pos or 1
	self.target = _target
	self.nArmyType = _armyType

	parseView("item_fuben_army", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemFubenMyArmy",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenMyArmy:myInit()

	self.tCurData  			= 	nil 						-- 当前数据
	self.nPos 				= 	1 							-- 1,2,3；位置
	self.target 			= 	nil 						-- 父层控件

	--拖拽相关参数
	self.fCurPosX 			= 	0 							-- 当前x值
	self.fCurPosY 			= 	0 							-- 当前y值
	self.fOldPosX 			= 	0 							-- 旧的x值
	self.fOldPosY 			= 	0 							-- 旧的y值
	self.fPointX 			= 	0 							-- 当前手指的x值
	self.fPointY 			= 	0 							-- 当前手指的y值
	self.bIsMoving 			= 	false 						-- 是否正在执行移动

	self.nZorder 			= 	0 							-- 层级， -- 被选中时+5，可交换时层级+1


	self.nType              = en_army_state.free            -- 类型
end

--解析布局回调事件
function ItemFubenMyArmy:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemFubenMyArmy:setupViews( )
	--ly
	self.pLyIcon = self:findViewByName("ly_icon")
	self.pLyRelation = self:findViewByName("ly_relation") --克制关系
	self.pLyRelation:setZOrder(10)

	--ly
	self.pLyMain = self:findViewByName("ly_main")

	

	--lb
	self.pLbName = self:findViewByName("lb_name") --武将名字
	setTextCCColor(self.pLbName,_cc.blue)
	self.pLbDetail = self:findViewByName("lb_detail") --详情
	setTextCCColor(self.pLbDetail,_cc.blue)
	self.pLbArrow = self:findViewByName("lb_arrow") --箭头上的文字(克制关系文字)
	self.pLbLv = self:findViewByName("lb_lv") --等级
	self.pLbNum = self:findViewByName("lb_num") --兵力
	self.pLbArrow:setZOrder(3)

	self.pLbDetail:setString(getConvertedStr(5, 10027)) --兵力

	--img
	self.pSelImg = self:findViewByName("img_sel") --可交换状态的图
	self.pImgHeroType = self:findViewByName("img_hero_type") --兵种
	self.pImgArrow = self:findViewByName("img_arrow") --箭头

	self.pImgArrow:setZOrder(2)

	--解锁条件
	local tConTable = {}
	--文本
	tConTable.tLabel= {
		{getConvertedStr(5, 10212),getC3B(_cc.blue)},
		{"",getC3B(_cc.white)},
		{getConvertedStr(5, 10213),getC3B(_cc.blue)},
	}
	self.pText =  createGroupText(tConTable)
	self.pLyMain:addView(self.pText,10)
	self.pText:setPosition(205,83)
	self.pText:setAnchorPoint(cc.p(0.5,0.5))
	self.pText:setVisible(false)


end

-- 修改控件内容或者是刷新控件数据
function ItemFubenMyArmy:updateViews()
	if not self.tData then
		return 
	end

	if type(self.tData) == "table"  then --有武将的状态
		self.nType = en_army_state.online
		if not self.pIcon then
			self.pIcon = getIconHeroByType(self.pLyIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.M)
		else
			--如果创建的时候item的icon类型是空闲状态,后来上阵部队后,需要设置类型
			self.pIcon:setIconHeroType(TypeIconHero.NORMAL)
			self.pIcon:setCurData(self.tData)
		end

		--部队与敌方部队的关系
		self.pLyRelation:setVisible(true)

		if self.tData.nKind == self.nEnemyKind then
			self.pLbArrow:setString("")
			self.pImgArrow:setCurrentImage("#v1_img_bukezhi.png")
		else
			--todo
			local nRelation = 0
			if self.tData.nKind == en_soldier_type.infantry then --步将
				--todo
				if self.nEnemyKind == en_soldier_type.archer then --克 弓兵
					nRelation = 1
				else --被克
					nRelation = 2
				end
			elseif self.tData.nKind == en_soldier_type.sowar then --骑将
				if self.nEnemyKind == en_soldier_type.infantry then --克 步将
					nRelation = 1
				else --被克
					nRelation = 2
				end
			elseif self.tData.nKind == en_soldier_type.archer then --弓将
				if self.nEnemyKind == en_soldier_type.sowar then --克 骑将
					nRelation = 1
				else --被克
					nRelation = 2
				end	
			end

			if  nRelation == 1 then -- 克制
				self.pImgArrow:setCurrentImage("#v1_img_lanjiantou.png")
				self.pLbArrow:setString(getConvertedStr(5, 10038))
			elseif nRelation == 2 then --被克制
				self.pImgArrow:setCurrentImage("#v1_img_hongjiantou.png")
				self.pLbArrow:setString(getConvertedStr(5, 10038))
			end

			--不存在被克关系
			if self.nEnemyKind ==  0 then
				self.pLyRelation:setVisible(false)
			end
		end
		--如果血量为0, 不存在被克关系
		if self.nBlood == 0 then
			self.pLyRelation:setVisible(false)
		end


		--显示兵种
		self.pImgHeroType:setCurrentImage(getSoldierTypeImg(self.tData.nKind))


	else
		self.pLyRelation:setVisible(false)
		if self.tData == en_army_state.free then --如果为空闲状态
			self.nType = en_army_state.free
			if not self.pIcon then
				self.pIcon = getIconHeroByType(self.pLyIcon,TypeIconHero.ADD,nil,TypeIconHeroSize.M)
			end

			--如果没有可上阵武将.将加号变灰
			if self.nArmyType == en_army_type.killherofight then --过关斩将类型
				self.pIcon:setIconHeroType(TypeIconHero.ADD)
				setTextCCColor(self.pLbName, _cc.blue)
				if not Player:getPassKillHeroData():bHaveHeroUp() then
					self.pIcon:setRedTipState()
				end
			else
				if not Player:getHeroInfo():bHaveHeroUp() then 
					self.pIcon:stopAddImgAction()
				end
			end
		elseif self.tData == en_army_state.lock then --如果为锁住状态
			self.nType = en_army_state.lock
			if not self.pIcon then
				self.pIcon = getIconHeroByType(self.pLyIcon,TypeIconHero.LOCK,nil,TypeIconHeroSize.M)
			end
		end
	end

	if self.nArmyType == en_army_type.killherofight then --过关斩将类型
		if self.tData == en_army_state.lock then --如果为锁住状态
		else
			self.pIcon:setIconClickedCallBack(function()
				local tObject = {}
				tObject.nType = e_dlg_index.killheroselhero --dlg类型
				tObject.tData = self.tData
				tObject.nPos = self.nPos
				sendMsg(ghd_show_dlg_by_type,tObject)
			end)
		end
	end




	if self.nType ==  en_army_state.online then --如果是有武将状态
		if self.tData.sName then
           self.pLbName:setString(self.tData.sName,false)
           setTextCCColor(self.pLbName,getColorByQuality(self.tData.nQuality))
		end
		setTextCCColor(self.pLbLv,getColorByQuality(self.tData.nQuality))
		self.pLbLv:setPositionX(self.pLbName:getWidth() + self.pLbName:getPositionX() + 15)
		self.pLbLv:setString("Lv."..self.tData.nLv) --等级
		if self.nArmyType == en_army_type.killherofight then --过关斩将类型
			local fPer = Player:getPassKillHeroData():getHeroProById(self.tData.nId)
			-- local tHeroList = Player:getHeroInfo():getHeroOnlineQueueByTeam(e_hero_team_type.normal)
			-- local tEquipVos = Player:getEquipData():getEquipVosByPos(tHeroList, self.nPos)
			-- local nBingli = self.tData:getTroopsLuo()
			-- for k, v in pairs(tEquipVos) do
			-- 	local nEquipBingli = v:getEquipBingliValue()
			-- 	nBingli = nBingli + nEquipBingli
			-- end
			-- --最终兵力 = 现在兵力 / 4 * 方阵数
			-- nBingli = nBingli / 4 * self.tData.nPh
			-- self.pLbNum:setString(math.ceil(nBingli*fPer)) --血量
			self.pLbNum:setString(math.ceil(self.tData.nLt * fPer)) --兵力
		else
			self.pLbNum:setString(self.tData:getProperty(e_id_hero_att.bingli)) --兵力
		end
		self.pImgHeroType:setVisible(true)
		self.pLbDetail:setString(getConvertedStr(5, 10027)) --兵力


	else
		self.pImgHeroType:setVisible(false)
		self.pLbName:setString("")--名字
		self.pLbLv:setString("") --等级
		self.pLbNum:setString("") --兵力
		self.pLbDetail:setString("") --兵力 说明
		if self.nType ==  en_army_state.free then
			self.pLbName:setString(getConvertedStr(5, 10037))--
		else
			self.pLbName:setString("")--名字
			if self.nPos then
				local nTnStr = "" 
				local nTnId = 1
				if self.nPos == 3 then
					nTnId   =  3010 --初级科技id
				elseif self.nPos == 4 then
					nTnId   =  3020 --中级科技id
				end
				if getGoodsByTidFromDB(nTnId) then
					nTnStr = getGoodsByTidFromDB(nTnId).sName
				end 
				if nTnStr and (nTnStr~= "") then
					self.pText:setVisible(true)
					--显示解锁条件
					self.pText:setLabelCnCr(2, "“"..nTnStr.."”")
				end
			end
		end

	end
end

-- 是否点击在自身上
-- x (float): 当前手指的x值
-- y（float）：当前手指的y值
function ItemFubenMyArmy:isPointInItem( x, y )
	local fItemX = self:getPositionX() 
	local fItemY = self:getPositionY()
	local fItemW = self:getWidth()
	local fItemH = self:getHeight()

	if(x >= fItemX and x <= fItemX + fItemW
		and y >= fItemY and y <= fItemY + fItemH) then
		return true
	else
		return false
	end
end

-- 设置被选中的状态
function ItemFubenMyArmy:setSelected( _bSelected )
	if (_bSelected == true) then
		self:setZOrder(self.nZorder + 5)
	else
		self:setZOrder(self.nZorder)
	end
end

-- 显示可被交换的效果
function ItemFubenMyArmy:showCanChange( _bCanChange )
	if (_bCanChange == true) then
		self:setZOrder(self.nZorder + 1)
		-- self.pSelImg:setVisible(true)
	else
		self:setZOrder(self.nZorder)
		-- self.pSelImg:setVisible(false)
	end
end


-- 判断被选中的item是否移动到当前item的交换范围内
function ItemFubenMyArmy:isCanChange( _pItem )

	--如果不是英雄的话就无法选中
	if (not _pItem ) or (self.nType ~= en_army_state.online) then
		return false
	end


	return self:isPointInItem(_pItem:getPositionX() + _pItem:getWidth() / 2, 
		_pItem:getPositionY() + _pItem:getHeight() / 2)
end



-- 根据下标获取当前位置
-- nIndex（int）：当前下标
-- bNeedAction(bool): 是否需要动画过程
function ItemFubenMyArmy:changeToIndex( nIndex, bNeedAction )
	-- 先记录旧值
	self.nOldIndex = self.nPos
	self.fOldPosX = self.fCurPosX -- 旧的x值
	self.fOldPosY = self.fCurPosY -- 旧的y值
	-- 重置新值
	self.nPos = nIndex	

	self:showCanChange(false)

	self.fCurPosX , self.fCurPosY = self:getItemPosition(self.nPos) -- 当前y值

	if(bNeedAction == nil) then
		bNeedAction = true
	end
	if(bNeedAction) then
		-- 如果不再同个位置，执行移动动画
		if(self.fOldPosX ~= self.fCurPosX or self.fOldPosY ~= self.fCurPosY) then
			local pMt = cc.MoveTo:create(0.1, cc.p(self.fCurPosX, self.fCurPosY))
			self:runAction(cc.Sequence:create(
				pMt,cc.CallFunc:create(function (  )
					self.bIsMoving = false
				end)))
			self.bIsMoving = true
		else
			self:setPosition(self.fCurPosX, self.fCurPosY)
		end
	else
		self:setPosition(self.fCurPosX, self.fCurPosY)
	end
end


-- 根据下标获取当前位置
-- nIndex（int）：当前下标
function ItemFubenMyArmy:getItemPosition( _nIndex ) 
	if (not self.target or not self.target.getItemPosition) then
		return 0, 0
	end
	local tPos = self.target:getItemPosition(_nIndex)
	return tPos.x, tPos.y
end

-- 播放交换后的动画
function ItemFubenMyArmy:showChangedArm(  )
	local action1 = cc.ScaleTo:create(0.1, 0.95, 0.95) 
	local action2 =  cc.ScaleTo:create(0.1, 1.02, 1.02) 
	local action3 =  cc.ScaleTo:create(0.1, 1.0, 1.0)
	self:runAction(cc.Sequence:create(action1,action2,action3))
end


--析构方法
function ItemFubenMyArmy:onDestroy(  )
	-- body
end

--设置数据 _tData _nEnemyKind 敌方兵种
function ItemFubenMyArmy:setCurData(_data,_nEnemyKind, nBlood)
	if not _data then
		return
	end

	self.tData = _data

	self.nEnemyKind = _nEnemyKind or 0
	self.nBlood = nBlood
	
	self:updateViews()


end

--获取当前item类型
function ItemFubenMyArmy:getViewType()
	return self.nType
end


return ItemFubenMyArmy