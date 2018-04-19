-- Author: maheng
-- Date: 2017-04-24 14:32:24
-- 使用物品对话框


local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgCommon = require("app.common.dialog.DlgCommon")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgUseStuff = class("DlgUseStuff", function ()
	return DlgAlert.new(e_dlg_index.useitems)
end)

--构造
function DlgUseStuff:ctor()
	-- body
	self:myInit()	
	parseView("dlg_usestuff", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgUseStuff:myInit()
	-- body
	self._nstuffs 	= 		2		--物品总量
	self._nselect 	=		1		--玩家当前选定的购买次数
	self.pItemData = nil
	self.pRichView = nil --	富文本显示
	self.bRedoneSV = true --是否重算滑动条变化
	self._sellHandler = handler(self, self.onSellBtnClicked)
	self._useHandler = handler(self, self.onUseBtnClicked)
end
  
--解析布局回调事件
function DlgUseStuff:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgUseStuff",handler(self, self.onDlgUseStuffDestroy))
end

--初始化控件
function DlgUseStuff:setupViews()
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6, 10113))
	--信息层
	self.pLayStuffInfo 				= 			self:findViewByName("lay_stuffinfo")
	--头像层
	self.pLayIcon = self:findViewByName("lay_icon")
	--物品名称标签
	self.pLbName = self:findViewByName("lb_name")
	--物品说明	
	self.pLbExpline = self:findViewByName("lb_expline")
	setTextCCColor(self.pLbExpline, _cc.white)
	--减少按钮	
	self.playMinusTimes 					= 			self:findViewByName("lay_btn_left")	
	self.pBtnMinus 					= 			getSepButtonOfContainer(self.playMinusTimes,TypeSepBtn.MINUS,TypeSepBtnDir.right)
	self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--增加按钮	
	self.playPlusTimes 					= 			self:findViewByName("lay_btn_right")
	self.pBtnPlus 					= 			getSepButtonOfContainer(self.playPlusTimes,TypeSepBtn.PLUS,TypeSepBtnDir.left)
		
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息

	--富文本显示层	
	self.pLbRichText = self:findViewByName("lb_rich_text")

	self.pLbUseBack = self:findViewByName("lb_useback")
	self.pLbUseBackValue = self:findViewByName("lb_useback_value")
	self.pLbUseBack:setVisible(false)
	self.pLbUseBackValue:setVisible(false)

	--拖动条
	self.playSliderBar				= 			self:findViewByName("lay_bar_bg")
	self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_3.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(248, 20)
	self.pSliderBar:setSliderValue(50)	--设置滑动条值默认为一半
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)
	-- self:refreshSelectedTip()
end

function DlgUseStuff:refreshSelectedTip(  )	
	local sStr = {
		{text=getConvertedStr(6, 10114),color=_cc.pwhite},
	 	{text=self._nselect,color=_cc.blue},
	 	{text="/"..self._nstuffs,color=_cc.pwhite}
	}
	self.pLbRichText:setString(sStr, false)

	if self.nResId  then
		if self.pItemData.sDropId then
			self.pLbUseBack:setVisible(true)
			self.pLbUseBack:setString(string.format(getConvertedStr(1,10414),getResStrById(self.nResId)))
			self.pLbUseBackValue:setVisible(true)
			
			local nValue = 0
			if self.nResId == e_resdata_ids.yb then
				nValue = Player:getPlayerInfo().nCoin
			elseif self.nResId == e_resdata_ids.mc then
				nValue = Player:getPlayerInfo().nWood
			elseif self.nResId == e_resdata_ids.lc then
				nValue = Player:getPlayerInfo().nFood
			elseif self.nResId == e_resdata_ids.bt then
				nValue = Player:getPlayerInfo().nIron
			end
			if getDropById(self.pItemData.sDropId) and getDropById(self.pItemData.sDropId)[1] then
				local num =  getDropById(self.pItemData.sDropId)[1].nCt
				nValue = num*self._nselect + nValue
				local sValueStr = ""
				if self.tNeedValue and self.tNeedValue[self.nResId] then
					local nNeedValue = self.tNeedValue[self.nResId]
					if nValue < nNeedValue then
						sValueStr = string.format(getConvertedStr(1, 10416),getResourcesStr(nValue))
					else
						sValueStr = string.format(getConvertedStr(1, 10415),getResourcesStr(nValue))
					end
					self.pLbUseBackValue:setString(sValueStr.."/"..getResourcesStr(nNeedValue))
				else
					sValueStr = string.format(getConvertedStr(1, 10415),getResourcesStr(nValue))
					self.pLbUseBackValue:setString(sValueStr)
				end
				
			end
		else
			self.pLbUseBack:setVisible(false)
			self.pLbUseBackValue:setVisible(false)	
		end
		
	else
		self.pLbUseBack:setVisible(false)
		self.pLbUseBackValue:setVisible(false)
	end

end

-- 修改控件内容或者是刷新控件数据
function DlgUseStuff:updateViews()

	-- body	
	--物品数据
	local itemdata = self.pItemData
	if not itemdata then
		return
	end
	--dump(itemdata, "itemdata", 100)	
	--设置icon
	if not self.pIcon then
		self.pIcon = getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.item, itemdata, TypeIconGoodsSize.L)
	else
		self.pIcon:setCurData(itemdata)
	end
	
	self.pLbName:setString(itemdata.sName)--刷新名字
	setLbTextColorByQuality(self.pLbName,itemdata.nQuality)
	self.pLbExpline:setString(itemdata.sDes)--物品说明
	if itemdata.nCt <= 0 then
		print("物品数据异常")
		return
	end

	self._nstuffs = itemdata.nCt
	if itemdata.nCt > itemdata.nBatchUseNum then
		self._nstuffs = itemdata.nBatchUseNum
		if itemdata.nDayUse ~= -1 then			
			self._nstuffs = itemdata.nDayUse - Player:getBagInfo():getItemHadUseNum(itemdata.sTid)
		end
	end

	--按钮显示刷新
	if (itemdata.nCanUse == 1) and (itemdata.sSell ~= nil) then --可以使用也可以出售
		--设置标题
		self:setTitle(getConvertedStr(6, 10113))		
		self:setLeftHandler(self._sellHandler)					
		self:setRightHandler(self._useHandler)			
	elseif (itemdata.nCanUse ~= 1) and (itemdata.sSell ~= nil) then--不可以使用，可以出售
		--设置标题
		self:setTitle(getConvertedStr(6, 10487))			
		self:getOnlyConfirmButton(TypeCommonBtn.L_YELLOW, getConvertedStr(6,10138))
		self:setRightHandler(self._sellHandler)
	elseif (itemdata.nCanUse == 1) and (itemdata.sSell == nil) then --可以使用不可以出售
		--设置标题
		self:setTitle(getConvertedStr(6, 10113))
		self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE, getConvertedStr(6,10128))
		self:setRightHandler(self._useHandler)				
	else

	end
	--更新进度条显示	
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)
	self:refreshSelectedTip()
end

--滑动条释放消息回调
function DlgUseStuff:onSliderBarRelease( pView )
	-- body
	self.bRedoneSV = true
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	self._nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
	if self._nselect <= 0 then
		self._nselect = 1
	end
	curvalue = self._nselect/self._nstuffs*100
	self.pSliderBar:setSliderValue(curvalue)		
end

--滑动滑动消息回调
function DlgUseStuff:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
		if nselect <= 0 then
			nselect = 1
		end
		self._nselect = nselect
	else
		self.bRedoneSV = true
	end
	self:refreshSelectedTip()
end

--minusBtn减少按钮点击回调事件
function DlgUseStuff:onMinusBtnClicked( pView )
	-- body	
	local nselect = self._nselect - 1
	if nselect < 1  then
		nselect = 1			
	end
	self._nselect = nselect
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--plusBtn增加按钮点击回调事件
function DlgUseStuff:onPlusBtnClicked( pView )
	-- body
	local nselect = self._nselect + 1
	if nselect > self._nstuffs then
		nselect = self._nstuffs		
	end
	self._nselect = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--析构方法
function DlgUseStuff:onDlgUseStuffDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgUseStuff:regMsgs( )
	-- body
end

-- 注销消息
function DlgUseStuff:unregMsgs(  )
	-- body
end


--暂停方法
function DlgUseStuff:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgUseStuff:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置物品数据 _itemid-物品配表id
function DlgUseStuff:setItemDataById( _itemid , _tNeedValue, _resId)
	--建筑升级所需可key值
	-- body
	local itemdata = Player:getBagInfo():getItemDataById(_itemid)--读取物品的配表数据
	self.tNeedValue = _tNeedValue
	self.nResId = _resId
	if itemdata then		
		self.pItemData = itemdata		
		self:updateViews()
	else
		print("设置物品使用对话框的物品数据错误...")
	end	
end


--出售按钮回调
function DlgUseStuff:onSellBtnClicked( pView )
	--body
	local tObject = {}
	tObject.useId = self.pItemData.sTid
	tObject.useNum = self._nselect
	tObject.type = 3--出售
	sendMsg(ghd_useItems_msg,tObject)	
end

--使用按钮回调
function DlgUseStuff:onUseBtnClicked( pView )	
	-- body	
	--发送使用物品消息
	local tObject = {}
	tObject.useId = self.pItemData.sTid
	tObject.useNum = self._nselect
	tObject.type = 1--正常使用
	sendMsg(ghd_useItems_msg,tObject)
end

return DlgUseStuff
