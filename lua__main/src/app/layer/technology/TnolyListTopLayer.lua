-----------------------------------------------------
-- author: wangxs
-- updatetime:  
-- Description: 
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local MBtnExText = require("app.common.button.MBtnExText")

local TnolyListTopLayer = class("TnolyListTopLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TnolyListTopLayer:ctor(  )
	-- body
	self:myInit()
	parseView("layout_techlist_top", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function TnolyListTopLayer:myInit(  )
	-- body
	self.tCurDatas 			=		nil --当前数据
end

--解析布局回调事件
function TnolyListTopLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TnolyListTopLayer",handler(self, self.onTnolyListTopLayerDestroy))
end

--初始化控件
function TnolyListTopLayer:setupViews( )
	-- body
	--升级中的控件
	self.pLayUping 				= 	self:findViewByName("lay_studing")
	self.pLbUpingName 			= 	self.pLayUping:findViewByName("lb_name") --名字
	setTextCCColor(self.pLbUpingName, _cc.blue)
	self.pLbUpingLv 			= 	self.pLayUping:findViewByName("lb_lv") --等级
	setTextCCColor(self.pLbUpingLv, _cc.white)
	self.pLbUpingP1 			= 	self.pLayUping:findViewByName("lb_p1") --参数1
	setTextCCColor(self.pLbUpingP1, _cc.white)
	self.pLbUpingP2 			= 	self.pLayUping:findViewByName("lb_p2") --参数2
	setTextCCColor(self.pLbUpingP2, _cc.green)
	self.pLbUpingDes 			= 	self.pLayUping:findViewByName("lb_desc") --描述
	setTextCCColor(self.pLbUpingDes, _cc.pwhite)
	self.pLayUpingIcon 			= 	self.pLayUping:findViewByName("lay_icon") --icon
	self.pLbUpingTime 			= 	self.pLayUping:findViewByName("lb_time") --时间
	setTextCCColor(self.pLbUpingTime, _cc.red)
	self.pLbUpingCost 			= 	self.pLayUping:findViewByName("lb_cost") --消耗
	setTextCCColor(self.pLbUpingCost, _cc.pwhite)
	self.pLbUpingCost:setString(getConvertedStr(1, 10181))
	self.pLayBtn  	 			= 	self.pLayUping:findViewByName("lay_btn") --按钮
	self.pBtnUping = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_BLUE,getConvertedStr(1,10177), false)
	self.pBtnUping:onCommonBtnClicked(handler(self, self.onUpingClicked))
	
	self.pLayUpingBar 			= 	self.pLayUping:findViewByName("lay_bar") --升级进度条
	-- self.pBarUping  			= 	MCommonProgressBar.new({bar = "v1_bar_blue_5.png",barWidth = 418, barHeight = 14})
	-- self.pLayUpingBar:addView(self.pBarUping)
	-- centerInView(self.pLayUpingBar, self.pBarUping)	

	local pSize = self.pLayUpingBar:getContentSize()
	self.nSliderW = pSize.width
	self.pSlider = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/daitu.png",
        button="ui/daitu.png",
        barfg="ui/bar/v1_bar_blue_5.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSlider:setViewTouched(false)
	self.pSlider:setSliderSize(pSize.width, pSize.height)
	self.pLayUpingBar:addView(self.pSlider)
	centerInView(self.pLayUpingBar, self.pSlider)
	self.pTx = createSliderTx(self.pSlider:getSliderBarBall())
	self:onRefreshSlider(0)

	--富文本控件（金币加速）
	local tCostTable = {}
	tCostTable.parent = self.pBtnUping
	tCostTable.img = "#v1_img_qianbi.png"
	--文本
	tCostTable.tLabel = {
		{0,getC3B(_cc.yellow)},
	}
	self.pCostExText = MBtnExText.new(tCostTable)
end

--是否有活动加速buff(参加乱军加速活动掉落的加速buff)
--_type:加速类型
function TnolyListTopLayer:isHasActSpeedBuff(_itemid, _type)
	-- body
	local pGood = Player:getBagInfo():getItemDataById(_itemid)
	if pGood == nil then return false end 
	if pGood.nEffectType == _type and pGood.nCt > 0 then
		if _type == e_speed_effect_type.tnoly_speed then --科研加速
			local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
			if tUpingTnoly and tUpingTnoly:getUpingFinalLeftTime() > 0 then
				return true
			end
		end
	end
	return false
end

--求助
function TnolyListTopLayer:isCanAskHelp()
	if not getIsReachOpenCon(3, false) then
		return false
	end
	local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
	if tUpingTnoly and tUpingTnoly.nHelp == 0 then
		return true
	end
	return false
end

-- 修改控件内容或者是刷新控件数据
function TnolyListTopLayer:updateViews(  )
	-- body
	if self.tCurDatas then
		--头像
		getIconGoodsByType(self.pLayUpingIcon,TypeIconGoods.NORMAL,type_icongoods_show.item,self.tCurDatas)
		--名字
		self.pLbUpingName:setString(self.tCurDatas.sName,false)
		--等级
		self.pLbUpingLv:setString(getLvString( self.tCurDatas.nLv , true), false )
		--动态设置位置
		self.pLbUpingLv:setPositionX(self.pLbUpingName:getPositionX() + self.pLbUpingName:getWidth())
		--设置按钮状态
		if Player:getTnolyData():isCanFreeUp() then --可以研究员加速
			self.pBtnUping:updateBtnText(getConvertedStr(1,10177))
			self.pLbUpingCost:setVisible(true)
			self.pCostExText:setVisible(false)
			showRedTips(self.pLayBtn, 0, 0, 3)	
		elseif self:isHasActSpeedBuff(e_item_ids.kyjs, e_speed_effect_type.tnoly_speed) then
			self.pBtnUping:updateBtnText(getConvertedStr(7, 10243)) --活动加速
			self.pLbUpingCost:setVisible(true)
			self.pCostExText:setVisible(false)
			showRedTips(self.pLayBtn, 0, 0, 3)
		elseif self:isCanAskHelp() then
			self.pBtnUping:updateBtnText(getConvertedStr(1, 10425)) --活动加速
			self.pLbUpingCost:setVisible(false)
			self.pCostExText:setVisible(false)
			showRedTips(self.pLayBtn, 0, 0, 3)
		else
			--todo
			self.pBtnUping:updateBtnText(getConvertedStr(6,10760))--研究加速			
			self.pLbUpingCost:setVisible(false)
			self.pCostExText:setVisible(false)
			showRedTips(self.pLayBtn, 0, isCanUseItemSpeed(3), 3)	
		end
		self.pBtnUping:updateBtnType(TypeCommonBtn.M_YELLOW)

		--设置升级数值变化
		self:setUpValue()

		unregUpdateControl(self)
		regUpdateControl(self, handler(self, self.onUpdate))

	end
end

-- 析构方法
function TnolyListTopLayer:onTnolyListTopLayerDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function TnolyListTopLayer:regMsgs( )
	-- body
		--物品变化刷新
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateViews))
end

-- 注销消息
function TnolyListTopLayer:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_baginfo)
end


--暂停方法
function TnolyListTopLayer:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)
end

--继续方法
function TnolyListTopLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置当前数据
function TnolyListTopLayer:setCurData( tData )
	-- body
	self.tCurDatas = tData
	self:updateViews()
end

--正在升级中的科技按钮点击事件
function TnolyListTopLayer:onUpingClicked( _pView )
	-- body
	if self.pBtnUping:getBtnText() == getConvertedStr(1,10178) then --研究完成
		local tObject = {}
		tObject.nType = 3
		sendMsg(ghd_action_tnoly_msg, tObject)
	elseif self.pBtnUping:getBtnText() == getConvertedStr(6,10760) then --研究加速
		local tObject = {}
		tObject.nFunType = 3
		tObject.nType = e_dlg_index.buildprop --dlg类型	
		sendMsg(ghd_show_dlg_by_type,tObject)		
	elseif self.pBtnUping:getBtnText() == getConvertedStr(1,10177) then --学者加速
		local tObject = {}
		tObject.nType = 1
		sendMsg(ghd_action_tnoly_msg, tObject)
	elseif self.pBtnUping:getBtnText() == getConvertedStr(7, 10243) then --活动加速
		--请求活动加速
		SocketManager:sendMsg("reqEnemySpeed", {e_item_ids.kyjs}, function()
			-- body
			self:updateViews()
		end)
	elseif self.pBtnUping:getBtnText() == getConvertedStr(1, 10425) then --求助
		SocketManager:sendMsg("scienceupinghelp", {}, function()
			if self and self.updateViews then
				self:updateViews()
			end
		end)
	end
end

--设置升级数值变化
function TnolyListTopLayer:setUpValue(  )
	-- body
	--获得当前已经升级的数据
	local tCurLimitData = self.tCurDatas:getCurLimitData()
	-- if tCurLimitData then
	-- 	self.pLbUpingDes:setString(tCurLimitData.desc)
	-- 	if self.tCurDatas.sTid == 3014 then
	-- 		local tCritsData = getTnolyInintDataFromDB("artifactCrits")
	-- 		if not tCritsData then
	-- 			self.pLbUpingP1:setString("0 - ", false)
	-- 			self.pLbUpingP2:setString("0", false)
	-- 		else
	-- 			if tCritsData[self.tCurDatas.nLv - 1] then  --上一等级
	-- 				self.pLbUpingP1:setString(tCritsData[self.tCurDatas.nLv - 1] .. " - ", false)
	-- 			else
	-- 				self.pLbUpingP1:setString("0 - ", false)
	-- 			end
	-- 			if tCritsData[self.tCurDatas.nLv] then  --当前等级
	-- 				self.pLbUpingP2:setString(tCritsData[self.tCurDatas.nLv], false)
	-- 			else
	-- 				self.pLbUpingP2:setString("0", false)

	-- 			end
	-- 		end
	-- 	else
	-- 		--获取上一等级的数据
	-- 		local tPreLimitData = self.tCurDatas:getPreLimitData()
	-- 		if  tPreLimitData then
	-- 			local tPreBuffData = getBuffDataByIdFromDB(tPreLimitData.buffid)
	-- 			local sPreValue = Player:getTnolyData():getEffectsValue(tPreBuffData)
	-- 			self.pLbUpingP1:setString(sPreValue .. " - ", false)
	-- 		end
	-- 		local tBuffData = getBuffDataByIdFromDB(tCurLimitData.buffid)
	-- 		local sValue,nType = Player:getTnolyData():getEffectsValue(tBuffData)
	-- 		self.pLbUpingP2:setString(sValue, false)
	-- 		if nType == 0  then
	-- 			self.pLbUpingP1:setString("")
	-- 		else
	-- 			if not tPreLimitData then
	-- 				-- if nType == 1 then
	-- 				-- 	self.pLbUpingP1:setString("0% - ", false)
	-- 				-- elseif nType == 2  then
	-- 				-- 	self.pLbUpingP1:setString("0 - ", false)
	-- 				-- end
	-- 				self.pLbUpingP1:setString("0 - ", false)
	-- 			end
	-- 		end
				
			
	-- 	end
	-- end

	--获得下一级升级数据
	local tNextLimitData = self.tCurDatas:getNextLimitData()

	if tNextLimitData then
		self.pLbUpingDes:setString(tNextLimitData.desc)
		--神兵暴击
		if self.tCurDatas.sTid == 3014 then
			local tCritsData = getTnolyInintDataFromDB("artifactCrits")
			if not tCritsData then
				self.pLbUpingP1:setString("0 - ", false)
				self.pLbUpingP2:setString("0", false)
			else
				if tCritsData[self.tCurDatas.nLv] then  --当前等级
					self.pLbUpingP1:setString(tCritsData[self.tCurDatas.nLv] .. " - ", false)
				else
					self.pLbUpingP1:setString("0 - ", false)
				end
				if tCritsData[self.tCurDatas.nLv+1] then  --下一等级
					self.pLbUpingP2:setString(tCritsData[self.tCurDatas.nLv+1], false)
				else
					self.pLbUpingP2:setString("0", false)

				end
			end
		end
	end

	if self.tCurDatas.sTid ~= 3014 then
		if tCurLimitData then
			local tBuffData = getBuffDataByIdFromDB(tCurLimitData.buffid)
			local sValue = Player:getTnolyData():getEffectsValue(tBuffData)
			self.pLbUpingP1:setString(sValue .. " - ", false)
		end
		if tNextLimitData then
			self.pLbUpingDes:setString(tNextLimitData.desc)
			--获得buff
			local tBuffData = getBuffDataByIdFromDB(tNextLimitData.buffid)
			local sValue, nType = Player:getTnolyData():getEffectsValue(tBuffData)
			self.pLbUpingP2:setString(sValue, false)

			if nType == 0 then
				self.pLbUpingP1:setString("")
			else
				if tCurLimitData == nil then
					if nType == 1 then
						self.pLbUpingP1:setString("0% - ", false)
					elseif nType == 2 then
						self.pLbUpingP1:setString("0 - ", false)
					end
				end
			end
		end
	end


	--动态设置位置
	self.pLbUpingP1:setPositionX(self.pLbUpingLv:getPositionX() + self.pLbUpingLv:getWidth() + 15)
	self.pLbUpingP2:setPositionX(self.pLbUpingP1:getPositionX() + self.pLbUpingP1:getWidth())

end

--每秒刷新
function TnolyListTopLayer:onUpdate(  )
	-- body
	if self.tCurDatas then
		self:setBarAndTime()
	end
end

function TnolyListTopLayer:onRefreshSlider( nPercet )
	-- body
	if not nPercet then
		return
	end
	local nDisX = self.nSliderW*nPercet/100
	if self.pTx and nDisX > self.pTx.width then
		setSliderTxVisible(self.pTx, true)
	else
	 	setSliderTxVisible(self.pTx, false)
	end
end

--设置时间和进度
function TnolyListTopLayer:setBarAndTime(  )
	-- body
	--总时间
	local fAllTime = self.tCurDatas.fStudingAllTime
	--剩余时间
	local fLeftTime = self.tCurDatas:getUpingFinalLeftTime()
	if fLeftTime > 0 then
		local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
		--self.pBarUping:setPercent(nPercet)
		self.pSlider:setSliderValue(nPercet)
		self:onRefreshSlider(nPercet)
		self.pLbUpingTime:setString(formatTimeToHms(fLeftTime), false)
		--黄金
		self.pCostExText:setLabelCnCr(1,self.tCurDatas:getTnolyCurrentFinishValue())		
	else
		local pDlg, bNew = getDlgByType(e_dlg_index.technology)
		if pDlg then
			local tObject = {}
			tObject.nType = 3
			sendMsg(ghd_action_tnoly_msg, tObject)
		else
			-- self.pBarUping:setPercent(100)
			-- self.pBarUping:setBarImage("ui/bar/v1_bar_yellow_10.png")
			self.pSlider:setSliderImage("ui/bar/v1_bar_yellow_10.png")
			self.pSlider:setSliderValue(100)			
			setSliderTxVisible(self.pTx, false)

			self.pLbUpingTime:setString("--:--:--",false)
			self.pBtnUping:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtnUping:updateBtnText(getConvertedStr(1,10178))
			self.pLbUpingCost:setVisible(false)
			self.pCostExText:setVisible(false)
		end
		unregUpdateControl(self)
	end

end

return TnolyListTopLayer