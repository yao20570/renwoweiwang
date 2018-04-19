-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-09 10:39:23 星期二
-- Description: 工坊生产线
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemProductLine = class("ItemProductLine", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
 
--_idx 生产队列序号 _bisPro是否是生产队列项
function ItemProductLine:ctor(_idx, _bisPro)
	-- body
	self:myInit(_idx, _bisPro)
	sendMsg(ghd_guide_finger_show_or_hide, true)
	parseView("item_production", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemProductLine",handler(self, self.onItemProductLineDestroy))
	
end

--初始化参数
function ItemProductLine:myInit(_idx, _bisPro)
	-- body
	self._Idx = _idx or 0
	self._nShowType = nil
	self._bIsPro = _bisPro or false
	self.pCurData = nil --队列数据
end

--解析布局回调事件
function ItemProductLine:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemProductLine:setupViews( )
	-- body
	--icon
	self.pLayIcon = self:findViewByName("lay_icon")
	--状态层1
	self.pLayStatus1 = self:findViewByName("lay_status_1")
	--提示标签1
	self.pLbTip1 = self:findViewByName("lb_tip_1")
	setTextCCColor(self.pLbTip1, _cc.pwhite)
	--生产/预约生产/扩充产线按钮
	self.pLayRightBtn = self:findViewByName("lay_right_btn")
	self.pBtnRight = getCommonButtonOfContainer(self.pLayRightBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10177))
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightBtnClicked))	

	--状态层2
	self.pLayStatus2 = self:findViewByName("lay_status_2")
	--名称
	self.pLbName = self:findViewByName("lb_name")
	self.pLbName:setString(getConvertedStr(6, 10191))

	self.pLbNum = self:findViewByName("lb_num_p")--数字
	self.pLbTimer = self:findViewByName("lb_timer")
	--层 生产中状态显示
	self.pLayInproduction = self:findViewByName("lay_in_production")
	--进度条层
	self.pLayBar = self:findViewByName("lay_bar")
	self.pProgressBar = MCommonProgressBar.new({bar = "v1_bar_yellow_2.png",barWidth = 120, barHeight = 14})
	self.pLayBar:addView(self.pProgressBar, 10)
	centerInView(self.pLayBar, self.pProgressBar)	
	--进度百分数
	self.pLbPercent = self:findViewByName("lb_percent")
	setTextCCColor(self.pLbPercent, _cc.green)
	--提示标签4
	self.pLbTip4 = self:findViewByName("lb_tip_4")
	self.pLbTip4:setString(getConvertedStr(6, 10188))
	setTextCCColor(self.pLbTip4, _cc.pwhite)
	--生产数量
	self.pLbProductNum = self:findViewByName("lb_num")
	self.pLbProductNum:setString("0")
	setTextCCColor(self.pLbProductNum, _cc.yellow)
	--层 已完成显示
	self.pLayOverProduct = self:findViewByName("lay_over")
	--获取按钮
	self.pLayBtnGet = self:findViewByName("lay_get_btn")
	self.pBtnGet = getCommonButtonOfContainer(self.pLayBtnGet, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10189))
	self.pBtnGet:onCommonBtnClicked(handler(self, self.onGetBtnClicked))	
	--提示标签
	self.pLbTip5 = self:findViewByName("lb_tip_5")
	self.pLbTip5:setString(getConvertedStr(6, 10190))
	setTextCCColor(self.pLbTip5, _cc.green)

	self.pIcon = getIconHeroByType(self.pLayIcon, TypeIconHero.LOCK, nil, TypeIconHeroSize.L)			
	self.pIcon:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function ItemProductLine:updateViews(  )
	-- body
	if self._Idx <= 0 then
		return
	end
	local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
	if atelierData then
		if atelierData.nQueue < self._Idx then		
			self:updateItemType(ItemProductLine_Type.expand)--扩充队列
			return
		else			
			local tdata = nil
			if self._bIsPro then--生产项
				tdata = atelierData:getProQueueItemByIdx(self._Idx)
				if tdata then					
					self:updateItemType(ItemProductLine_Type.produce, tdata)
					return
				end
			else				--预生产项	
				tdata = atelierData:getWaitQueueItemByIdx(self._Idx)
				if tdata then					
					self:updateItemType(ItemProductLine_Type.wait, tdata)
					return
				end
			end
			self:updateItemType(ItemProductLine_Type.free)
		end
	end
end

--析构方法
function ItemProductLine:onItemProductLineDestroy(  )
	-- body
	unregUpdateControl(self)--停止计时刷新
end

--右侧按钮点击事件回调
function ItemProductLine:onRightBtnClicked( pView )
	-- body
	if self._nShowType == ItemProductLine_Type.expand then
		--向服务端发送扩展生产队列请求
		local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
		local ncost = getNextProductLineCost(atelierData.nBuyQueue)
		local strTips = {
			{color=_cc.pwhite,text=getConvertedStr(6, 10196)}--永久扩充生产线
	    }
		showBuyDlg(strTips, tonumber(ncost), function (  )
			-- body		
			SocketManager:sendMsg("buyProduceQueue", {}, handler(self, self.buyProduceQueueCallBack))
		end, 0, true)
	else
		local tObject = {}			
		tObject.nType = e_dlg_index.atelierproduce --dlg类型
		if self._bIsPro then
			tObject.nflag = 1 --生产
		else
			tObject.nflag = 2 --预约生产
		end
		tObject.nQueueIdx = self._Idx
		sendMsg(ghd_show_dlg_by_type,tObject)	

		--新手教程
		if self._bIsPro then
			Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.atelier_produce_btn)
		end
	end
end
--获取材料按钮点击事件回调
function ItemProductLine:onGetBtnClicked( pView )
	-- body
	--SocketManager:sendMsg("getProduction", {}, handler(self, self.getProductionCallBack))
end
--刷新队列项显示
function ItemProductLine:updateItemType( _type, _data )
	-- body
	local titemdata = nil
	if _data then		
		titemdata = getBaseItemDataByID(tonumber(_data.tGs.k))			
		--dump(titemdata, "titemdata", 100)
		self.pIcon:setIconHeroType(TypeIconHero.NORMAL)
		self.pIcon:setIconClickedCallBack(nil)
		self.pIcon:setCurData(titemdata)	
		self.pIcon:setVisible(true)				
	end
	self._nShowType = _type
	if _type == ItemProductLine_Type.expand then--扩展					
		self.pIcon:setIconHeroType(TypeIconHero.LOCK)
		self.pIcon:setIconClickedCallBack(nil)		
		self.pIcon:setCurData(nil)
		self.pIcon:setVisible(false)				
		self.pLayStatus1:setVisible(true)
		self.pLayStatus2:setVisible(false)
		self.pLbTip1:setString(getConvertedStr(6, 10196))	
		self.pBtnRight:updateBtnType(TypeCommonBtn.M_YELLOW)	
		self.pBtnRight:updateBtnText(getConvertedStr(6, 10197))	
	elseif _type == ItemProductLine_Type.free then--空闲队列		
		self.pIcon:setCurData(nil)
		self.pIcon:setIconHeroType(TypeIconHero.ADD)
		self.pIcon:setIconClickedCallBack(handler(self, self.onRightBtnClicked))			
		self.pIcon:setVisible(false)				
		self.pLayStatus1:setVisible(true)
		self.pLayStatus2:setVisible(false)
		self.pLbTip1:setString(getConvertedStr(6, 10198))
		self.pBtnRight:updateBtnType(TypeCommonBtn.M_BLUE)	
		if self._bIsPro then
			self.pBtnRight:updateBtnText(getConvertedStr(6, 10177))	
		else
			self.pBtnRight:updateBtnText(getConvertedStr(6, 10178))		
		end
	elseif _type == ItemProductLine_Type.wait then --等待生产
		self.pLayStatus1:setVisible(false)
		self.pLayStatus2:setVisible(true)	
		self.pLayInproduction:setVisible(true)
		self.pLayOverProduct:setVisible(false)
		self.pLbProductNum:setVisible(false)
		self.pLayBar:setVisible(false)
		self.pLbName:setString(titemdata.sName..getConvertedStr(6, 10199).._data.tGs.v)
		setLbTextColorByQuality(self.pLbName, titemdata.nQuality)
		self.pLbNum:setString("", false)
		local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
		local nproduceCD = atelierData:getProQueueCDByIdx(self._Idx)
		local sStr= {
			{color=_cc.pwhite, text=getConvertedStr(6, 10163)},
			{color=_cc.red, text=formatTimeToHms(nproduceCD)},
		}
		self.pLbTimer:setString(sStr, false)
		self.pLbTip4:setVisible(true)
		self.pLbProductNum:setVisible(true)
		self.pLbProductNum:setString(_data.tGs.v)
		self.pLayBar:setVisible(false)
		self.pLbPercent:setVisible(false)
		unregUpdateControl(self)--停止计时刷新
		regUpdateControl(self, handler(self, self.onUpdateTime))--注册计时器刷新
		return
	elseif _type == ItemProductLine_Type.produce then--正在生产
		self.pLayStatus1:setVisible(false)
		self.pLayStatus2:setVisible(true)
		self.pLayInproduction:setVisible(true)
		self.pLayOverProduct:setVisible(false)
		local personCt = Player:getBuildData():getBuildById(e_build_ids.palace).nPersonCt--王宫数据
		local nCountryPCnt = Player:getBuildData():getBuildById(e_build_ids.palace):getCountryPeopleCnt()
		local proQueueNum = Player:getBuildData():getBuildById(e_build_ids.atelier):getProQueueNum()		
		self.pLbName:setString(titemdata.sName..getConvertedStr(6, 10199).._data.tGs.v)	
		setLbTextColorByQuality(self.pLbName, titemdata.nQuality)	
		local nCityP = math.ceil(personCt/proQueueNum)
		local sStr = nil
		if nCountryPCnt>0 then 
			sStr = {
				{color=_cc.pwhite,text=getConvertedStr(6, 10186)},
				{color=_cc.blue,text=nCountryPCnt},
				{color=_cc.green,text="+"..nCityP}
			}				
		else
			sStr = {
				{color=_cc.pwhite,text=getConvertedStr(6, 10186)},				
				{color=_cc.green,text=nCityP}
			}
		end
		self.pLbNum:setString(sStr, false)
		local sStr1= {
			{color=_cc.pwhite, text=getConvertedStr(6, 10187)},
			{color=_cc.red, text=formatTimeToHms(_data:getProduceCD())},
		}
		self.pLbTimer:setString(sStr1, false)
		self.pLbTip4:setVisible(true)
		self.pLbProductNum:setVisible(true)
		self.pLbProductNum:setString(_data.tGs.v)
		self.pLayBar:setVisible(true)
		self.pLbPercent:setVisible(true)		
		unregUpdateControl(self)--停止计时刷新
		regUpdateControl(self, handler(self, self.onUpdateTime))--注册计时器刷新
		return
	end
	unregUpdateControl(self)--停止计时刷新

	--新手教程
	if self._Idx == 1 then
		if _type == ItemProductLine_Type.free then
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnRight, e_guide_finer.atelier_produce_btn)
		else
			Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.atelier_produce_btn)
		end
	end
end
function ItemProductLine:setIndex(nidx)
	-- body
	self._Idx = nidx
	self:updateViews()
end
function ItemProductLine:onUpdateTime(  )
	-- body
	local atelierData = Player:getBuildData():getBuildById(e_build_ids.atelier)
	--dump(atelierData, "atelierData", 100)
	local nproduceCD = atelierData:getProQueueCDByIdx(self._Idx)
	if nproduceCD > 0 then
		if self._nShowType == ItemProductLine_Type.wait then
			local sStr= {
				{color=_cc.pwhite, text=getConvertedStr(6, 10163)},
				{color=_cc.red, text=formatTimeToHms(nproduceCD)},
			}
			self.pLbTimer:setString(sStr, false)			
		elseif self._nShowType == ItemProductLine_Type.produce then
			local sStr= {
				{color=_cc.pwhite, text=getConvertedStr(6, 10187)},
				{color=_cc.red, text=formatTimeToHms(nproduceCD)},
			}
			self.pLbTimer:setString(sStr, false)
		end
		local npercent = atelierData:getProQueueItemByIdx(self._Idx):getProducePercent()*100
		self.pLbPercent:setString(npercent..getConvertedStr(6, 10170))
		self.pProgressBar:setPercent(npercent)
	else
		self:checkProQueueCD(self._Idx)
		unregUpdateControl(self)
	end
end
--建筑队列CD校对
function ItemProductLine:checkProQueueCD( idx)
	-- body
	if idx then
		doDelayForSomething(self, function (  )
			-- body
			SocketManager:sendMsg("checkProQueueCD", {idx})
		end, 3)		
	end	
end

--永久购买生产队列
function ItemProductLine:buyProduceQueueCallBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then				
		if __msg.body then

		end			
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end
end
--领取材料
function ItemProductLine:getProductionCallBack( __msg )
	-- body
	if __msg.head.state == SocketErrorType.success	then				
		if __msg.body then
			
		end			
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))		
	end
end

return ItemProductLine