-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-11 18:06:14 星期四
-- Description: 科技树item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemTreeTnoly = class("ItemTreeTnoly", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
--_data：当前科技数据
function ItemTreeTnoly:ctor( _data )
	-- body
	self:myInit()
	self.tCurData = _data
	parseView("item_tnoly_tree", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemTreeTnoly:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
end

--解析布局回调事件
function ItemTreeTnoly:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemTreeTnoly",handler(self, self.onItemTreeTnolyDestroy))
end

--初始化控件
function ItemTreeTnoly:setupViews( )
	-- body
	--选中表示层
	self.pLaySel 		= self:findViewByName("lay_sel")
	--设置默认状态
	self:setSelectedState(false)

	--科技图标
	self.pImgTnoly 		= self:findViewByName("img_tnoly")
	--科技名称
	self.pLbName 		= self:findViewByName("lb_name")
	--科技等级层
	self.pLayLv 		= self:findViewByName("lay_lv")
	--科技等级
	self.pLbLevel 		= self:findViewByName("lb_lv")


	--标志满
	self.pLayMan 		= self:findViewByName("lay_man")
	-- self.pLbMan 		= self:findViewByName("lb_man")
	-- setTextCCColor(self.pLbMan,_cc.white)
	-- self.pLbMan:setString(getConvertedStr(1, 10185))
	--默认隐藏
	self.pLayMan:setVisible(false)

	--线
	self.pLayLine 		= self:findViewByName("lay_line")
	--icon
	self.pLayIcon 		= self:findViewByName("lay_icon")
	self.pLayIcon:setViewTouched(true)
	--锁
	self.pImgLocked 	= self:findViewByName("img_locked")
	self.pImgLocked:setVisible(false)

end

--设置选中科技项回调事件
function ItemTreeTnoly:setTnolyClickCallBack( _handler )
	-- body
	self.nHandlerCallBack = _handler
end

-- 修改控件内容或者是刷新控件数据
function ItemTreeTnoly:updateViews(  )
	-- body
	if self.tCurData then
		self.pImgTnoly:setCurrentImage(self.tCurData.sSmallIcon)
		self.pLbLevel:setString(getLvString(self.tCurData.nLv , false))
		--设置icon
		-- if not self.pTnolyIcon then
			--设置icon
			-- self.pTnolyIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.HADMORE,type_icongoods_show.tnolyTree,nil)
			--设置点击事件
			self.pLayIcon:onMViewClicked(function (  )
				-- body
				if self.nHandlerCallBack then
					self.nHandlerCallBack(self)
				end
			end)
			--获得底部层
			-- local pLayMore = self.pTnolyIcon:getMoreLayer()
			-- if pLayMore then
			-- 	pLayMore:setBackgroundImage("#v1_img_jianbian3.png")
			-- end
		-- end
		--设置ICon数据
		-- self.pTnolyIcon:setCurData(self.tCurData)
		--判断是否有前置科技
		if self.tCurData:isHadPreTonly() then
			self.pLayLine:setVisible(true)
		else
			self.pLayLine:setVisible(false)
		end
		--判断是否锁住
		self:setLockedState()

		local sStrNum = self:getProgressStr()
		self.pLbName:setString(self.tCurData.sName.." "..sStrNum)
		
		--判断是否满级
		if self.tCurData:isMaxLv() then
			self.pLayMan:setVisible(true)
			--移除等级展示
			-- self.pTnolyIcon:removeLeftTopLayer()
			--隐藏进度显示
			-- self.pTnolyIcon:setIsShowNumber(false)
			self.pLbName:setString(self.tCurData.sName)
		else
			self.pLayMan:setVisible(false)
			if self.tCurData:checkisLocked() then
				self.pLbName:setString(self.tCurData.sName)
			end
		end
	end
end

--获取进度字符串
function ItemTreeTnoly:getProgressStr()
	local sStrNum = ""
	local tNextLimitData = self.tCurData:getNextLimitData()	
	if tNextLimitData then
		sStrNum = self.tCurData.nCurIndex .. "/" .. tNextLimitData.section		
	else
		sStrNum = self.tCurData.nCurIndex .. "/" .. self.tCurData.nCurIndex
	end
	return sStrNum
end

-- 析构方法
function ItemTreeTnoly:onItemTreeTnolyDestroy(  )
	-- body
end

--设置当前数据
function ItemTreeTnoly:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

--获得当前数据
function ItemTreeTnoly:getCurData(  )
	-- body
	return self.tCurData
end

--设置选择状态
function ItemTreeTnoly:setSelectedState( _bState )
	-- body
	self.pLaySel:setVisible(_bState)
end

--是否锁住
function ItemTreeTnoly:setLockedState( )
	-- body
	--判断是否锁住
	if self.tCurData:checkisLocked() then
		self.pLayLine:setBackgroundImage("#v1_line_red.png")
		self.pImgLocked:setVisible(true)
		-- self.pTnolyIcon:setIsShowNumber(false)
		if self.tCurData.nLv == 0 then
			self.pLayLv:setVisible(false)
		end
	else
		self.pLayLine:setBackgroundImage("#v1_line_green.png")
		self.pImgLocked:setVisible(false)
		-- self.pTnolyIcon:setIsShowNumber(true)
		self.pLayLv:setVisible(true)
	end
end

return ItemTreeTnoly