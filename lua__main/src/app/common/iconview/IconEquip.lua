-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-20 09:31:52 星期四
-- Description: 装备icon （圆形）
-----------------------------------------------------

-------------------------------------------------------------------------------------------
--例子：
	-- self.pLayIcon = self:findViewByName("lay_icon")
	-- local pIconEquip = getIconEquipByType(self.pLayIcon, TypeIconEquip.NORMAL, e_type_equip.weapon, data, TypeIconEquipSize.M)
	-- pIconEquip:setIconIsCanTouched(false)
	-- pIconEquip:setIconClickedCallBack(function (  )
	-- 	-- body
	-- 	print("回调=====")
	-- end)
-------------------------------------------------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local IconEquip = class("IconEquip", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- _nType：类型（TypeIconEquip）
-- _nEquipType:种类(e_type_equip)
function IconEquip:ctor( _nType,  _nEquipType, _nAddImgType)
	-- body
	self:myInit()
	self.nType = _nType
	self.nEquipType = _nEquipType
	self.nAddImgType = _nAddImgType or 0
	parseView("icon_equip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function IconEquip:myInit(  )
	-- body
	self.nType 				= nil 		--icon类型
	self.nEquipType 		= nil 		--装备种类
	self.tCurData 			= nil 		--当前数据
	self._nHandlerClicked 	= nil 		--icon点击回调
end

--解析布局回调事件
function IconEquip:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	self:setupViews()

	self:updateViews()
end

--初始化控件
function IconEquip:setupViews( )
	-- body
	--底部背景品质框
	self.pLayBgQuality 		= 	self:findViewByName("default")
	self.pLayBgQuality:setViewTouched(true)
	self.pLayBgQuality:setIsPressedNeedScale(false)
	self.pLayBgQuality:onMViewClicked(handler(self, self.onIconClicked))

	--icon
	self.pLayIcon 			= 	self:findViewByName("lay_equip")
	self.pImgIcon 			= 	self:findViewByName("img")

	--星星层
	self.pLayStar 			= 	self:findViewByName("lay_star")

	--红点层
	self.pLayRedTip         =   self:findViewByName("lay_redtip")
	self.pLbDesc			=   self:findViewByName("lb_decs")   
	self:setIconType(self.nType)

	--强化等级层
	self.pLayStrengthLv 	=	self:findViewByName("lay_strenthlv")
	self.pLayStrengthLv:setVisible(false)
	self.pLbStrenghLv		=	self:findViewByName("lb_strengthlv")
	setTextCCColor(self.pLbStrenghLv, _cc.white)
end

-- 修改控件内容或者是刷新控件数据
function IconEquip:updateViews(  )
	-- body
	if self.tCurData then
		--设置icon
		-- self.pImgIcon:setCurrentImage("#" .. self.tCurData.sIcon .. ".png")
		-- self.pImgIcon:setPositionY(self.pImgIcon:getHeight() / 2)
		--设置品质
		-- if self.nType == TypeIconEquip.NORMAL then
			-- setEquipBgQuality(self.pLayBgQuality,self.tCurData.nQuality)

		-- end
	end

end

--设置数据
function IconEquip:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end

--设置为加号状态
function IconEquip:setAddState(  )
	-- body
	self.pLayStar:removeAllChildren()
	-- self.pImgIcon:setCurrentImage(getEquipBgShadowPath(self.nEquipType))
	--设置位置
	-- self.pImgIcon:setPosition(self.pLayIcon:getWidth() / 2, self.pLayIcon:getHeight() / 2)
	setEquipBgQuality(self.pLayBgQuality,1)
	if self.nAddImgType ~= 1 then
		self.pLayBgQuality:setBackgroundImage(getEquipBgShadowPath(self.nEquipType))
	end
end

--展示星星层
--_nAll：总星星数
--_nCur：当前星星数
--_tDarkLight:暗亮列表(可以不传) {true,false,true,false}, true表示光，false表示暗
function IconEquip:initStarLayer( _nAll, _nCur, _tDarkLight)
	-- body
	if not _nAll or not _nCur then
		return
	end
	showEquipStarLayer(self.pLayStar, _nAll, _nCur, _tDarkLight)
end

--刷新星星层
--_nAll：总星星数
--_nCur：当前星星数
--_tDarkLight:暗亮列表(可以不传) {true,false,true,false}, true表示光，false表示暗
function IconEquip:refreshStarLayer( _nAll, _nCur, _tDarkLight)
	-- body
	showEquipStarLayer(self.pLayStar, _nAll, _nCur, _tDarkLight)
end

--设置icon点击回调
function IconEquip:setIconClickedCallBack( _handler )
	-- body
	self._nHandlerClicked = _handler
end

--点击事件
function IconEquip:onIconClicked( pView )
	-- body
	if self._nHandlerClicked then
		self._nHandlerClicked(pView, self._tCallBackParam)
	else
		-- print("装备icon点击事件")
		if self.tCurData and pView then
			openIconInfoDlg(pView,self.tCurData)
		end
	end
end

--设置是否可以点击icon
function IconEquip:setIconIsCanTouched( _bEnbaled )
	-- body
	self.pLayBgQuality:setViewTouched(_bEnbaled)
end


--设置icon类型
function IconEquip:setIconType(_nType)
	if _nType then
		self.nType= _nType
	else
		return
	end

	if self.nType == TypeIconEquip.NORMAL then --正常类型
		self.pImgIcon:setVisible(true)
		self.pImgIcon:stopAllActions()
		self:setNormalState()
	elseif self.nType == TypeIconEquip.ADD then  --加号
		if self.nAddImgType == 1 then
			self.pImgIcon:setVisible(true)
		else
			self.pImgIcon:setVisible(false)
		end
		self:setAddState()
		--没有装备就隐藏强化等级
		if self.pLayStrengthLv then
			self.pLayStrengthLv:setVisible(false)
		end
	end
end

--设置为正常状态
function IconEquip:setNormalState(  )

	if self.tCurData then
		setEquipBgQuality(self.pLayBgQuality,self.tCurData.nQuality)
		self.pImgIcon:setScale(1)

		self.pImgIcon:setCurrentImage(self.tCurData.sIcon)
	end
end

--设置按钮回调时候的参数
function IconEquip:setCallBackParam( param )
	self._tCallBackParam = param
end

-- addImgAction 添加按钮图片动作
function IconEquip:addImgAction(  )
	self:setRedTipState(1)
	if self.nType == TypeIconEquip.ADD and self.nAddImgType == 1 then  --加号
		-- self.pImgIcon:setToGray(false)
		-- self.pLayBgQuality:setToGray(true)
		-- if not self.bIsAddImgAction then
			self.pImgIcon:setVisible(true)
			self.pImgIcon:setCurrentImage("#v1_btn_tianjia.png")
			self.pImgIcon:setScale(0.6)
			-- local pScaleTo1 = cc.ScaleTo:create(0.5, 0.6)
			-- local pFadeTo1 = cc.FadeTo:create(0.5, 255*0.85)
			-- local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1)

			-- local pScaleTo2 = cc.ScaleTo:create(0.5,0.8)
			-- local pFadeTo2 = cc.FadeTo:create(0.5, 255)
			-- local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)
			-- -- setBgQuality(self.pLayBgQuality,2)
			-- self.pImgIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(action1,action2)))
			--self.bIsAddImgAction = true
		-- end
	end
end

function IconEquip:stopAddImgAction( )
	self:setRedTipState(0)
	if self.nType == TypeIconEquip.ADD and self.nAddImgType == 1 then
		-- if self.bIsAddImgAction then
			self.pImgIcon:stopAllActions()
			self.pImgIcon:setScale(1)
			self.pImgIcon:setVisible(false)
			-- self.pLayBgQuality:setBackgroundImage(getEquipBgShadowPath(self.nEquipType))
			-- self.pImgIcon:setCurrentImage(getEquipBgShadowPath(self.nEquipType))
			--self.bIsAddImgAction = false
		-- end
	end
end
	
--添加红点状态:1显示红点, 0隐藏红点
function IconEquip:setRedTipState(_state)
	-- body
	showRedTips(self.pLayRedTip, 0, _state)
end

--设置是否显示加号图片状态:1当没装备时显示加号图片, 0当没装备时不显示加号图片
function IconEquip:setAddImg(_state)
	-- body
end

--添加底部描述
function IconEquip:showDesc(_desc)
	self.pLbDesc:setVisible(true)
	self.pLbDesc:setString(_desc)
end

--设置描述框x轴位置
function IconEquip:setDescPosX(_x)
	self.pLbDesc:setPositionX(_x)
end

--设置描述框Y轴位置
function IconEquip:setDescPosY(_y)
	self.pLbDesc:setPositionY(_y)
end

--隐藏底部描述
function IconEquip:hideDesc(_desc)
	self.pLbDesc:setVisible(false)
end

--设置底部描述框的颜色
function IconEquip:setDescColor(_strColor)
	setTextCCColor(self.pLbDesc, _strColor)
end

--设置强化等级
function IconEquip:setStrengthLv(_lv)
	if _lv > 0 then
		self.pLbStrenghLv:setString("+".._lv)
		self.pLayStrengthLv:setVisible(true)
	else
		self.pLayStrengthLv:setVisible(false)
	end
end

return IconEquip