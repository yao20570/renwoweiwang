-- Author: liangzhaowei
-- Date: 2017-05-02 14:27:56
-- 守城武将item
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroSate = require("app.layer.wall.ItemHeroSate")


local ItemWallHero = class("ItemWallHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index 下标 _type 类型
function ItemWallHero:ctor(_pos,_target, _teamtype)
	-- body
	self:myInit()

	self.nPos = _pos or 1
	self.target = _target
	self.nTeamType = _teamtype or 1

	parseView("item_wall_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemWallHero",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemWallHero:myInit()
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



	self.nNowLv = nil --当前等级
	self.pItemHeroState  = nil --英雄状态
end

--解析布局回调事件
function ItemWallHero:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	
	self.pLyIcon = self:findViewByName("ly_hero")
	self.pLyBar = self:findViewByName("ly_bar")
	self.pLyBar:setVisible(true)


	self.pBarLv = 	nil
	self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_blue_1.png",barWidth = 106, barHeight = 14})
	self.pLyBar:addView(self.pBarLv,100)
	centerInView(self.pLyBar,self.pBarLv)


	self.pLbLv = self:findViewByName("lb_lv")
	setTextCCColor(self.pLbLv, _cc.blue)

	--img
	self.pSelImg = self:findViewByName("img_sel")
	self.pSelImg:setVisible(false)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemWallHero:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemWallHero:updateViews(  )
	self:stopAllActions()
end

--析构方法
function ItemWallHero:onDestroy(  )
	-- body
end


-- 是否点击在自身上
-- x (float): 当前手指的x值
-- y（float）：当前手指的y值
function ItemWallHero:isPointInItem( x, y )
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
function ItemWallHero:setSelected( _bSelected )
	if (_bSelected == true) then
		self:setZOrder(self.nZorder + 5)
	else
		self:setZOrder(self.nZorder)
	end
end

-- 显示可被交换的效果
function ItemWallHero:showCanChange( _bCanChange )
	if (_bCanChange == true) then
		self:setZOrder(self.nZorder + 1)
		self.pSelImg:setVisible(true)
	else
		self:setZOrder(self.nZorder)
		self.pSelImg:setVisible(false)
	end
end


-- 判断被选中的item是否移动到当前item的交换范围内
function ItemWallHero:isCanChange( _pItem )

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
function ItemWallHero:changeToIndex( nIndex, bNeedAction )
	-- 先记录旧值
	self.nOldIndex = self.nPos
	self.fOldPosX = self.fCurPosX -- 旧的x值
	self.fOldPosY = self.fCurPosY -- 旧的y值
	-- 重置新值
	self.nPos = nIndex	

	self:showCanChange(false)

	self.fCurPosX , self.fCurPosY = self:getItemPosition(self.nPos, self.nTeamType) -- 当前y值

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
function ItemWallHero:getItemPosition( _nIndex ) 
	if (not self.target or not self.target.getItemPosition) then
		return 0, 0
	end
	local tPos = self.target:getItemPosition(_nIndex)
	return tPos.x, tPos.y
end

-- 播放交换后的动画
function ItemWallHero:showChangedArm(  )
	local action1 = cc.ScaleTo:create(0.1, 0.95, 0.95) 
	local action2 =  cc.ScaleTo:create(0.1, 1.02, 1.02) 
	local action3 =  cc.ScaleTo:create(0.1, 1.0, 1.0)
	self:runAction(cc.Sequence:create(action1,action2,action3))
end

--获取当前item类型
function ItemWallHero:getViewType()
	return self.nType
end


--设置数据 _data
function ItemWallHero:setCurData(_tData)
	if not _tData then
		return
	end



	self.pData = _tData or {}

	if type(self.pData) == "table" then
		self.pLyBar:setVisible(true)
		self.nType = en_army_state.online
		if self.pData then
			if not self.pIcon then
				self.pIcon = getIconHeroByType(self.pLyIcon, TypeIconHero.NORMAL, self.pData, TypeIconHeroSize.L)
			else
				self.pIcon:setIconHeroType(TypeIconHero.NORMAL)
				self.pIcon:setCurData(self.pData)
			end
			self.pIcon:setIconClickedCallBack(handler(self, self.onViewClick))



			--武将状态
			if not self.pItemHeroState then
				self.pItemHeroState = ItemHeroSate.new()
				self.pIcon:addView(self.pItemHeroState)
			end


			self.pItemHeroState:setCurData(self.pData)
			local nPercent = 0
			if self.nTeamType == e_hero_team_type.normal then
				nPercent = self.pData.nLt/self.pData:getMaxBingLi()	
			elseif self.nTeamType == e_hero_team_type.walldef then
				local nS = self.pData:getWalldefStamina()
				local nSMax = self.pData:getProperty(e_id_hero_att.bingli)
				nPercent = nS / nSMax
				-- dump(self.pData, "self.pData", 100)
				-- print("nS=",nS)
				-- print("nSMax=",nSMax)		
			end		

			if self.pData.nW == 0 then --出征中
				if self.nTeamType == e_hero_team_type.normal then--上阵武将
					--统领兵数小于百分之十也置灰
					if nPercent < 0.1 then
						self.pIcon:setIconBgToGray(true)
					else
						self.pIcon:setIconBgToGray(false)
					end					
				elseif self.nTeamType == e_hero_team_type.walldef then--城防武将
					--耐力值
					if nPercent < 1 then
						self.pIcon:setIconBgToGray(true)
					else
						self.pIcon:setIconBgToGray(false)
					end								
				end					
			else
				self.pIcon:setIconBgToGray(true)
			end

			self.pBarLv:setPercent(nPercent *100)
			if nPercent <= 0.1 then
				self.pBarLv:setBarImage("ui/bar/v1_bar_red1.png")
			elseif nPercent >= 1 then
				self.pBarLv:setBarImage("ui/bar/v1_bar_blue_3.png")
			else
				self.pBarLv:setBarImage("ui/bar/v1_bar_yellow_8.png")
			end

			self.pLbLv:setString(self.pData.sName.."Lv."..self.pData.nLv)
		end
	else
		self.pLyBar:setVisible(false)
		self.nType = en_army_state.free
		self.pIcon = getIconHeroByType(self.pLyIcon,self.pData, nil, TypeIconHeroSize.L)
		if self.pData and self.pData == 3 then
			self.pIcon:setIconClickedCallBack(handler(self, self.onAddHero))
			--如果没有可上阵武将.将加号变灰
			if not Player:getHeroInfo():bHaveHeroUp() then 
				self.pIcon:stopAddImgAction()
			end
		end
	end

end

function ItemWallHero:getData( ... )
	-- body
	return self.pData
end

--点击回调
function ItemWallHero:onViewClick(pData)
	if pData then
	    local tObject = {}
	    tObject.nType = e_dlg_index.dlgherolineup --dlg类型
	    tObject.nTeamType = self.nTeamType
	    sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--添加英雄
function ItemWallHero:onAddHero()
    local tObject = {}
    tObject.nType = e_dlg_index.selecthero --dlg类型
    tObject.nTeamType = self.nTeamType
    sendMsg(ghd_show_dlg_by_type,tObject)	
end

return ItemWallHero