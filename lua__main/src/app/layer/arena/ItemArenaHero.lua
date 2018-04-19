-- Author: liangzhaowei
-- Date: 2017-05-02 14:27:56
-- 守城武将item
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroSate = require("app.layer.wall.ItemHeroSate")


local ItemArenaHero = class("ItemArenaHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index 下标 _type 类型
function ItemArenaHero:ctor(_pos,_target)
	-- body
	self:myInit()

	self.nPos = _pos or 1
	self.target = _target
	self.nTeamType = e_hero_team_type.normal

	parseView("item_arena_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemArenaHero",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemArenaHero:myInit()
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
function ItemArenaHero:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemArenaHero:setupViews( )
	--ly         	
	self.pLyIcon = self:findViewByName("lay_icon")
	self.pLbName = self:findViewByName("lb_name")
	self.pLbAptitude = self:findViewByName("lb_aptitude")
end

-- 修改控件内容或者是刷新控件数据
function ItemArenaHero:updateViews(  )
	self:stopAllActions()
end

--析构方法
function ItemArenaHero:onDestroy(  )
	-- body
end


-- 是否点击在自身上
-- x (float): 当前手指的x值
-- y（float）：当前手指的y值
function ItemArenaHero:isPointInItem( x, y )
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
function ItemArenaHero:setSelected( _bSelected )
	if (_bSelected == true) then
		self:setZOrder(self.nZorder + 5)
	else
		self:setZOrder(self.nZorder)
	end
end

-- 显示可被交换的效果
function ItemArenaHero:showCanChange( _bCanChange )
	if (_bCanChange == true) then
		self:setZOrder(self.nZorder + 1)
	else
		self:setZOrder(self.nZorder)
	end
end


-- 判断被选中的item是否移动到当前item的交换范围内
function ItemArenaHero:isCanChange( _pItem )

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
function ItemArenaHero:changeToIndex( nIndex, bNeedAction )
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
function ItemArenaHero:getItemPosition( _nIndex ) 
	if (not self.target or not self.target.getItemPosition) then
		return 0, 0
	end
	local tPos = self.target:getItemPosition(_nIndex)
	return tPos.x, tPos.y
end

-- 播放交换后的动画
function ItemArenaHero:showChangedArm(  )
	local action1 = cc.ScaleTo:create(0.1, 0.95, 0.95) 
	local action2 =  cc.ScaleTo:create(0.1, 1.02, 1.02) 
	local action3 =  cc.ScaleTo:create(0.1, 1.0, 1.0)
	self:runAction(cc.Sequence:create(action1,action2,action3))
end

--获取当前item类型
function ItemArenaHero:getViewType()
	return self.nType
end


--设置数据 _data
function ItemArenaHero:setCurData(_tData)
	if not _tData then
		return
	end



	self.pData = _tData or {}

	if type(self.pData) == "table" then
		self.nType = en_army_state.online
		if self.pData then
			if not self.pIcon then
				self.pIcon = getIconHeroByType(self.pLyIcon, TypeIconHero.NORMAL, self.pData, TypeIconHeroSize.M)
			else
				self.pIcon:setIconHeroType(TypeIconHero.NORMAL)
				self.pIcon:setCurData(self.pData)
			end
			self.pIcon:setIconClickedCallBack(handler(self, self.onViewClick))
			self.pIcon:setHeroType()
			--武将状态
			-- if not self.pItemHeroState then
			-- 	self.pItemHeroState = ItemHeroSate.new()
			-- 	self.pIcon:addView(self.pItemHeroState)
			-- end


			-- self.pItemHeroState:setCurData(self.pData)

			-- local nPercent = 0
			-- if self.nTeamType == e_hero_team_type.normal then
			-- 	nPercent = self.pData.nLt/self.pData:getMaxBingLi()	
			-- elseif self.nTeamType == e_hero_team_type.walldef then
			-- 	local nS = self.pData:getWalldefStamina()
			-- 	local nSMax = self.pData:getProperty(e_id_hero_att.bingli)
			-- 	nPercent = nS / nSMax		
			-- end		
			self.pLbName:setString(self.pData.sName..getLvString(self.pData.nLv))
			setTextCCColor(self.pLbName, getColorByQuality(self.pData.nQuality))
			local sStr = {
				{color=_cc.pwhite, text=getConvertedStr(6, 10249)},
				{color=_cc.white, text=self.pData:getNowTotalTalent()}
			}
			self.pLbAptitude:setString(sStr, false)			
			self.pIcon:setIconBgToGray(false)
	

		end
	else
		self.nType = en_army_state.free
		self.pIcon = getIconHeroByType(self.pLyIcon,self.pData, nil, TypeIconHeroSize.M)
		if self.pData and self.pData == 3 then
			self.pIcon:setIconClickedCallBack(handler(self, self.onAddHero))
			--如果没有可上阵武将.将加号变灰
			if not Player:getHeroInfo():bHaveHeroUp() then 
				self.pIcon:stopAddImgAction()
			end
		end
	end

end

--点击回调
function ItemArenaHero:onViewClick(pData)
	if pData then
	    local tObject = {}
	    tObject.nType = e_dlg_index.dlgherolineup --dlg类型
	    tObject.nTeamType = self.nTeamType
	    sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--添加英雄
function ItemArenaHero:onAddHero()
    local tObject = {}
    tObject.nType = e_dlg_index.selecthero --dlg类型
    tObject.nTeamType = self.nTeamType
    sendMsg(ghd_show_dlg_by_type,tObject)	
end

return ItemArenaHero