-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-04 19:53:37 星期二
-- Description: 建筑操作按钮
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemBuildAction = class("ItemBuildAction", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemBuildAction:ctor(  )
	-- body
	self:myInit()
	parseView("item_build_action", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemBuildAction:myInit(  )
	-- body
	self.nType 			= 		nil 			--按钮类型
	self.tBuildInfo 	= 		nil 			--建筑数据
end

--解析布局回调事件
function ItemBuildAction:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemBuildAction",handler(self, self.onItemBuildActionDestroy))
end

--初始化控件
function ItemBuildAction:setupViews( )
	-- body
	--设置点击事件吞噬
	self:setTouchCatchedInList(true)
	--设置item可点击
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onThisItemClicked))

	--名字
	self.pLbName 		= 		self:findViewByName("lb_action")
	self.pLbName:enableOutline(cc.c4b(5, 8, 10, 255),2)
	setTextCCColor(self.pLbName,_cc.lyellow)
	--图片
	self.pImg 			= 		self:findViewByName("img_action")
	--item层
	self.pDefaultLay 	= 		self:findViewByName("default")
	--消耗
	self.pLbCost 		= 		self:findViewByName("lb_cost")

	self.pView = self:findViewByName("view")--底框
	self.pImgBtnB = self:findViewByName("img_btn_b") --高亮辅助 
	self.pImgBtnB:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

	self.pImgTx = self:findViewByName("img_tx")
	self.pImgTx:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)


end

-- 修改控件内容或者是刷新控件数据
function ItemBuildAction:updateViews(  )
	-- body
	if self.nType and self.tBuildInfo then
		self.pImg:setScale(1)
		self.pImgBtnB:setScale(1)
		--居中
		self.pImg:setPositionY(self.pDefaultLay:getHeight() / 2)
		self.pLbCost:setVisible(false)
		if self.nType == 1 then 			--升级
			self.pLbName:setString(getConvertedStr(1, 10100))
			self.pImg:setCurrentImage("#v1_ing_zjm_shengji.png")
			self.pImgBtnB:setCurrentImage("#v1_ing_zjm_shengji.png")
		elseif self.nType == 2 then 		--进入
			self.pLbName:setString(getConvertedStr(1, 10107))
			self.pImg:setCurrentImage("#v1_btn_jinru.png")
			self.pImgBtnB:setCurrentImage("#v1_btn_jinru.png")
			self.pImgBtnB:setScale(1.2)
			self.pImg:setScale(1.2)
		elseif self.nType == 3 then 		--加速
			self.pLbName:setString(getConvertedStr(1, 10099))
			self.pImg:setCurrentImage("#v1_ing_zjm_jiasu.png")
			self.pImgBtnB:setCurrentImage("#v1_ing_zjm_jiasu.png")
		elseif self.nType == 4 then 		--立即完成
			self.pLbName:setString(getConvertedStr(1, 10108))
			self.pImg:setCurrentImage("#i10.png")
			self.pImgBtnB:setCurrentImage("#i10.png")
			self.pImgBtnB:setScale(0.8)
			self.pImg:setScale(0.8)
			--偏下
			self.pImgBtnB:setPositionY(self.pDefaultLay:getHeight() / 2 - 10)
			self.pImg:setPositionY(self.pDefaultLay:getHeight() / 2 - 10)
			--设置消耗值
			self:setCostValue()
		elseif self.nType == 5 then 		--募兵
			self.pLbName:setString(getConvertedStr(1, 10109))
			self.pImg:setCurrentImage("#v1_img_mubing.png")
			self.pImgBtnB:setCurrentImage("#v1_img_mubing.png")
		elseif self.nType == 6 then 		--拆除
			self.pLbName:setString(getConvertedStr(7, 10253))
			self.pImg:setCurrentImage("#v1_img_zjm_gaijian.png")
			self.pImgBtnB:setCurrentImage("#v1_img_zjm_gaijian.png")
		end
	end
end

-- 析构方法
function ItemBuildAction:onItemBuildActionDestroy(  )
	-- body
end

--设置按钮相关数据
function ItemBuildAction:setBtnMsg( _nType, _tBuildInfo )
	-- body
	if not _nType then
		return
	end
	self.nType = tonumber(_nType)
	self.tBuildInfo = _tBuildInfo
	self:updateViews()
end

--设置点击回调事件
function ItemBuildAction:setItemClickedCallBack( _handler )
	-- body
	self._nClickedHandler = _handler
end

--点击事件回调
function ItemBuildAction:onThisItemClicked( pView )
	if self._nClickedHandler then
		self._nClickedHandler(self.nType)
	end
end

--设置消耗值
function ItemBuildAction:setCostValue(  )
	-- body
	self.pLbCost:setVisible(true)
	local bClose = false
	if self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
		local nCost = self.tBuildInfo:getSpeedProQueueCost()
		self.pLbCost:setString(nCost or "")
		if tonumber(nCost) <= 0 then
			bClose = true
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tnoly then --科技院
		local tCurTonly = Player:getTnolyData():getUpingTnoly()
		if tCurTonly then
			local nCost = tCurTonly:getTnolyCurrentFinishValue()
		    self.pLbCost:setString(nCost or "")
		    if tonumber(nCost) <= 0 then
		    	bClose = true
		    end
		end
	elseif self.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
		local tMakeVo = Player:getEquipData():getMakeVo()
		--正在打造装备
		if tMakeVo then
			--如果可以免费加速
			if Player:getEquipData():getIsCanSpeed() then
				self.pLbCost:setString(getConvertedStr(1, 10181))
			--立即完成
			else
				--打造cd
				local nCd = tMakeVo:getCd()
				--立即完成黄金扣除
				local nCost =  math.ceil(nCd/60) * tonumber(getBuildParam("makeTimeSpeed"))
				self.pLbCost:setString(nCost or "")
				if tonumber(nCost) <= 0 then
					bClose = true
				end
			end
		end
	end
	return bClose
end

-- 按钮特效
function ItemBuildAction:showTx()
	local imgScale = self.pImgBtnB:getScale()
	self.pView:setOpacity(0)
	self.pView:setScale(0.5)
	self.pImgBtnB:setOpacity(0)
	self.pImgBtnB:setScale(imgScale*0.5)
	self.pImgTx:setOpacity(0)


	local tAction_1 = cc.Spawn:create(cc.ScaleTo:create(0.14, 1.05), cc.FadeIn:create(0.14))
	local tAction_2 = cc.ScaleTo:create(0.1, 0.98)
	local tAction_3 = cc.ScaleTo:create(0.06, 1)
	self.pView:runAction(cc.Sequence:create(tAction_1, tAction_2, tAction_3))

	local tAction_4 = cc.Spawn:create(cc.ScaleTo:create(0.14, 1.05*imgScale), cc.FadeTo:create(0.14,255*0.3))
	local tAction_5 = cc.Spawn:create(cc.ScaleTo:create(0.1, 0.98*imgScale), cc.FadeTo:create(0.14,255*0.23))
	local tAction_6 = cc.Spawn:create(cc.ScaleTo:create(0.06, 1*imgScale), cc.FadeTo:create(0.14,255*0.18))
	local tAction_7 = cc.FadeOut:create(0.28)
	self.pImgBtnB:runAction(cc.Sequence:create(tAction_4, tAction_5, tAction_6, tAction_7))

	local tAction_8 = cc.FadeIn:create(0.14)
	local tAction_9 = cc.FadeOut:create(0.29)
 	self.pImgTx:runAction(cc.Sequence:create(tAction_8, tAction_9))
end


return ItemBuildAction