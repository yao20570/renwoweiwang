-- Author: maheng
-- Date: 2017-04-24 14:32:24
-- 使用物品对话框


local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgCommon = require("app.common.dialog.DlgCommon")
local MBtnExText = require("app.common.button.MBtnExText")

local DlgUseArenatToken = class("DlgUseArenatToken", function ()
	return DlgAlert.new(e_dlg_index.usearenatoken)
end)

--构造
function DlgUseArenatToken:ctor()
	-- body
	self:myInit()	
	parseView("dlg_usestuff", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgUseArenatToken:myInit()
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
function DlgUseArenatToken:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgUseArenatToken",handler(self, self.onDlgUseStuffDestroy))
end

--初始化控件
function DlgUseArenatToken:setupViews()
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
	self:refreshSelectedTip()
end

function DlgUseArenatToken:refreshSelectedTip(  )	
	local sStr = {
		{text=getConvertedStr(6, 10114),color=_cc.pwhite},
	 	{text=self._nselect,color=_cc.blue},
	 	{text="/"..self._nstuffs,color=_cc.pwhite}
	}
	self.pLbRichText:setString(sStr, false)
end

-- 修改控件内容或者是刷新控件数据
function DlgUseArenatToken:updateViews()
	-- body	
	--物品数据
	local itemdata = self.pItemData
	if not itemdata then
		return
	end
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
end

--滑动条释放消息回调
function DlgUseArenatToken:onSliderBarRelease( pView )
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
function DlgUseArenatToken:onSliderBarChange( pView )
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
function DlgUseArenatToken:onMinusBtnClicked( pView )
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
function DlgUseArenatToken:onPlusBtnClicked( pView )
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
function DlgUseArenatToken:onDlgUseStuffDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgUseArenatToken:regMsgs( )
	-- body
end

-- 注销消息
function DlgUseArenatToken:unregMsgs(  )
	-- body
end


--暂停方法
function DlgUseArenatToken:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgUseArenatToken:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置物品数据 _itemid-物品配表id
function DlgUseArenatToken:setItemDataById( _itemid )
	-- body
	local itemdata = Player:getBagInfo():getItemDataById(_itemid)--读取物品的配表数据
	if itemdata then		
		self.pItemData = itemdata		
		self:updateViews()
	else
		print("设置物品使用对话框的物品数据错误...")
	end	
end


--使用按钮回调
function DlgUseArenatToken:onUseBtnClicked( pView )	
	-- body	
	--发送使用物品消息
	if self._useHandler and self.pItemData then
		self._useHandler(self.pItemData.sTid, self._nselect)
	end
end

function DlgUseArenatToken:setUseHander( _func )
	-- body
	if not _func then
		return
	end
	self._useHandler = _func
end

return DlgUseArenatToken
