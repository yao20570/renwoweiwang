-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-04 15:47:16 星期四
-- Description: 兵营队列item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local MBtnExText = require("app.common.button.MBtnExText")


local ItemCamp = class("ItemCamp", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCamp:ctor(  )
	-- body
	self:myInit()
	parseView("item_camp", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemCamp:myInit(  )
	-- body
	self.tCurData 			= 		nil --当前数据
end

--解析布局回调事件
function ItemCamp:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemCamp",handler(self, self.onItemCampDestroy))
end

--初始化控件
function ItemCamp:setupViews( )
	-- body
	--顶部控件
	self.pBg 					=		self:findViewByName("lay_bg")
	self.pLayTop 				= 		self:findViewByName("lay_top")
	self.pLayBottom 			= 		self:findViewByName("lay_bottom")
	self.pLbParam1 				= 		self:findViewByName("lb_1")
	self.pLbParam2 				= 		self:findViewByName("lb_2")
	self.pLbParam3 				= 		self:findViewByName("lb_3")
	self.pLbParam4 				= 		self:findViewByName("lb_4")
	self.pLbParam5 				= 		self:findViewByName("lb_5")
	--底部控件
	self.pLayBar 				= 		self:findViewByName("lay_bar")
	self.pLayTips 				= 		self:findViewByName("lay_b_tips")
	self.pLbBTips1 				= 		self:findViewByName("lb_b_tips") 	
	setTextCCColor(self.pLbBTips1,_cc.pwhite)
	self.pLbBTips1:setString(getConvertedStr(1, 10140),false)
	self.pLbBTips2 				= 		self:findViewByName("lb_b_tips_v") 
	setTextCCColor(self.pLbBTips2,_cc.blue)
	self.pLayAction 			= 		self:findViewByName("lay_action")
	self.pBtnAction = getCommonButtonOfContainer(self.pLayAction,TypeCommonBtn.M_YELLOW,getConvertedStr(1,10088), false)
	--按钮点击事件
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onActionClicked))
	self.pBtnAction:onCommonBtnDisabledClicked(handler(self, self.onActionDisabledClicked))
	--默认提示
	self.pLbDef 				= 		self:findViewByName("lb_def")
	self.pLbDef:setString(getConvertedStr(6, 10534))
end

--是否有活动加速buff(参加乱军加速活动掉落的加速buff)
--_type:加速类型
function ItemCamp:isHasActSpeedBuff(_itemid, _type)
	-- body
	local pGood = Player:getBagInfo():getItemDataById(_itemid)
	if pGood == nil then return false end 
	if pGood.nEffectType == _type and pGood.nCt > 0 then
		if _type == e_speed_effect_type.camp_speed then   --募兵加速
			--获取兵营正在募兵中队列需要时间最短的兵营
			local pBuild = Player:getBuildData():getShortestCampBuild()
			if pBuild then
				if self.tBuildInfo.nCellIndex == pBuild.nCellIndex then
					return true
				end
			end
		end
	end
	return false
end

-- 修改控件内容或者是刷新控件数据
function ItemCamp:updateViews(  )
	-- body
	if self.tCurData then
		unregUpdateControl(self)
		if self.tCurData.nType == e_camp_item.ing then        		--募兵中
			--文字
			self.pLbParam1:setVisible(true)
			setTextCCColor(self.pLbParam1,_cc.pwhite)
			self.pLbParam1:setString(getConvertedStr(1, 10133))
			self.pLbParam2:setVisible(true)
			setTextCCColor(self.pLbParam2,_cc.blue)
			self.pLbParam3:setVisible(true)
			setTextCCColor(self.pLbParam3,_cc.pwhite)
			self.pLbParam3:setString(getConvertedStr(1, 10134))
			self.pLbParam4:setVisible(true)
			-- setTextCCColor(self.pLbParam4,_cc.blue)
			setTextCCColor(self.pLbParam4,_ccq.red)
			self.pLbParam5:setVisible(false)
			--按钮
			self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
			if self.tCurData.nFree == 1 then
				self.pBtnAction:updateBtnText(getConvertedStr(1, 10230)) --免费加速
				showRedTips(self.pLayAction, 0, 0, 3)	
			elseif self:isHasActSpeedBuff(e_item_ids.mbjs, e_speed_effect_type.camp_speed) then
				self.pBtnAction:updateBtnText(getConvertedStr(7, 10243)) --活动加速
				showRedTips(self.pLayAction, 0, 0, 3)	
			else
				self.pBtnAction:updateBtnText(getConvertedStr(1, 10099)) --加速
				showRedTips(self.pLayAction, 0, isCanUseItemSpeed(2), 3)	
			end
			self.pBtnAction:setBtnEnable(true)
			--底部提示层
			self.pLayTips:setVisible(false)
			--进度条层
			self.pLayBar:setVisible(true)
			--进度条
			if not self.pLoadingBar then
				self.pLoadingBar = MCommonProgressBar.new({bar = "v1_bar_blue_2.png",barWidth = 388, barHeight = 14})
				self.pLayBar:addView(self.pLoadingBar)
				centerInView(self.pLayBar,self.pLoadingBar)
			end
			self.pLoadingBar:setVisible(true)
			self.pLoadingBar:setBarImage("ui/bar/v1_bar_blue_2.png")
			self.pLoadingBar:setViewEnabled(true)
			--粮草消耗
			if self.pFoodCost then
				self.pFoodCost:setBtnExTextEnabled(false)
			end
			--滑动条
			if self.pSliderBar then
				self.pSliderBar:setVisible(false)
			end

			--设置兵量
			self.pLbParam2:setString(self.tCurData.nNum)
			
			regUpdateControl(self, handler(self, self.onUpdate))
			--设置相关数据
			self:setIngMsg()
		elseif self.tCurData.nType == e_camp_item.free then 		--可募兵
			--文字
			self.pLbParam1:setVisible(true)
			setTextCCColor(self.pLbParam1,_cc.pwhite)
			self.pLbParam1:setString(getConvertedStr(1, 10133))
			self.pLbParam2:setVisible(true)
			setTextCCColor(self.pLbParam2,_cc.blue)
			self.pLbParam3:setVisible(true)
			setTextCCColor(self.pLbParam3,_cc.pwhite)
			self.pLbParam3:setString(getConvertedStr(1, 10134))
			self.pLbParam4:setVisible(true)
			setTextCCColor(self.pLbParam4,_cc.blue)
			self.pLbParam5:setVisible(false)
			--按钮
			self.pBtnAction:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtnAction:updateBtnText(getConvertedStr(1, 10136))

			self.pBtnAction:setBtnEnable(true)

			--新手引导募兵
			if self.tCurData == self.tFirstData then
				self.pBtnAction:showLingTx()
				--新手引导
				Player:getNewGuideMgr():setNewGuideFinger(self.pBtnAction, e_guide_finer.camp_recruit_btn)
			else
				self.pBtnAction:removeLingTx()
			end

			--底部提示层
			self.pLayTips:setVisible(false)
			--进度条层
			self.pLayBar:setVisible(true)
			--进度条
			if self.pLoadingBar then
				self.pLoadingBar:setVisible(false)
			end
			--粮草消耗
			if not self.pFoodCost then
				--按钮上的金币提示
				local tBtnTable = {}
				tBtnTable.parent = self.pLbParam5
				-- tBtnTable.awayH = -15
				tBtnTable.img = "#v1_img_liangshi.png"
				--文本
				tBtnTable.tLabel = {
					{"0",getC3B(_cc.green)},
					{"/",getC3B(_cc.pwhite)},
					{0,getC3B(_cc.pwhite)}
					
				}
				self.pFoodCost = MBtnExText.new(tBtnTable)
				-- self.pFoodCost:setAnchorPoint(0.5,0)
			end
			self.pFoodCost:setVisible(true)
			--滑动条
			if not self.pSliderBar then
				self.pSliderBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
			        {
			        	bar="ui/daitu.png",
			        	button="ui/bar/v1_btn_tuodong.png",
			        	barfg="ui/bar/v1_bar_blue_2.png"
			        }, 
			        {
			        	scale9 = false, 
			        	touchInButton=false
			        })
				self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
				self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange))	--触摸抬起的回调（按下和移动均可设置回调）
				self.pSliderBar:setSliderSize(388, 14)
				self.pSliderBar:align(display.LEFT_BOTTOM)
				self.pLayBar:addView(self.pSliderBar)
				self.pSliderBar:setPosition(2, 2)
			end
			self.pSliderBar:setVisible(true)
			self.pSliderBar:setViewEnabled(true)

			--初始状态为满
			self.pSliderBar:setSliderValue(100)	--设置滑动条值默认满
			--设置相关数据
			self:setFreeMsg()
		elseif self.tCurData.nType == e_camp_item.wait then 		--等待中
			--文字
			self.pLbParam1:setVisible(true)
			setTextCCColor(self.pLbParam1,_cc.pwhite)
			self.pLbParam1:setString(getConvertedStr(1, 10133))
			self.pLbParam2:setVisible(true)
			setTextCCColor(self.pLbParam2,_cc.blue)
			self.pLbParam3:setVisible(true)
			setTextCCColor(self.pLbParam3,_cc.pwhite)
			self.pLbParam3:setString(getConvertedStr(1, 10134))
			self.pLbParam4:setVisible(true)
			setTextCCColor(self.pLbParam4,_cc.blue)
			self.pLbParam5:setVisible(true)
			setTextCCColor(self.pLbParam5,_cc.pwhite)
			self.pLbParam5:setString(getConvertedStr(1, 10135))
			--按钮
			self.pBtnAction:updateBtnType(TypeCommonBtn.M_RED)
			self.pBtnAction:updateBtnText(getConvertedStr(1, 10058))

			self.pBtnAction:setBtnEnable(true)
			--底部提示层
			self.pLayTips:setVisible(false)
			--进度条层
			self.pLayBar:setVisible(true)
			--进度条
			if not self.pLoadingBar then
				self.pLoadingBar = MCommonProgressBar.new({bar = "v1_bar_blue_2.png",barWidth = 388, barHeight = 14})
				self.pLayBar:addView(self.pLoadingBar)
				centerInView(self.pLayBar,self.pLoadingBar)
			end
			self.pLoadingBar:setVisible(true)
			self.pLoadingBar:setBarImage("ui/bar/v1_bar_blue_2.png")
			self.pLoadingBar:setViewEnabled(false)
			--粮草消耗
			if self.pFoodCost then
				self.pFoodCost:setBtnExTextEnabled(false)
			end
			--滑动条
			if self.pSliderBar then
				self.pSliderBar:setVisible(false)
			end

			--设置数据
			self.pLbParam2:setString(self.tCurData.nNum)
			self.pLbParam4:setString(formatTimeToHms(self.tCurData.nSD))
			self.pLoadingBar:setPercent(100)
			

		elseif self.tCurData.nType == e_camp_item.fill then 		--兵力满
			--文字
			self.pLbParam1:setVisible(true)
			setTextCCColor(self.pLbParam1,_cc.pwhite)
			self.pLbParam1:setString(getConvertedStr(1, 10133))
			self.pLbParam2:setVisible(true)
			setTextCCColor(self.pLbParam2,_cc.blue)
			self.pLbParam3:setVisible(true)
			setTextCCColor(self.pLbParam3,_cc.pwhite)
			self.pLbParam3:setString(getConvertedStr(1, 10134))
			self.pLbParam4:setVisible(true)
			setTextCCColor(self.pLbParam4,_cc.blue)
			self.pLbParam5:setVisible(false)
			--按钮
			self.pBtnAction:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtnAction:updateBtnText(getConvertedStr(1, 10136))
			self.pBtnAction:setBtnEnable(false)
			--底部提示层
			self.pLayTips:setVisible(false)
			--进度条层
			self.pLayBar:setVisible(true)
			--进度条
			if self.pLoadingBar then
				self.pLoadingBar:setVisible(false)
			end
			--粮草消耗
			if not self.pFoodCost then
				--按钮上的金币提示
				local tBtnTable = {}
				tBtnTable.parent = self.pLbParam5
				tBtnTable.awayH = -15
				tBtnTable.img = "#v1_img_liangshi.png"
				--文本
				tBtnTable.tLabel = {
					{0,getC3B(_cc.green)},
					{"/",getC3B(_cc.pwhite)},
					{"0",getC3B(_cc.pwhite)}
				}
				self.pFoodCost = MBtnExText.new(tBtnTable)
			end
			self.pFoodCost:setVisible(true)
			--滑动条
			if not self.pSliderBar then
				self.pSliderBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
			        {
			        	bar="ui/daitu.png",
			        	button="ui/bar/v1_btn_tuodong.png",
			        	barfg="ui/bar/v1_bar_blue_2.png"
			        }, 
			        {
			        	scale9 = false, 
			        	touchInButton=false
			        })
				self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
				self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange))	--触摸抬起的回调（按下和移动均可设置回调）
				self.pSliderBar:setSliderSize(388, 14)
				self.pSliderBar:align(display.LEFT_BOTTOM)
				self.pLayBar:addView(self.pSliderBar)
				self.pSliderBar:setPosition(2, 2)
			end
			self.pSliderBar:setVisible(true)
			self.pSliderBar:setViewEnabled(false)

			--初始状态为0
			self.pSliderBar:setSliderValue(0)	--设置滑动条值默认满
			--设置相关数据
			self.pLbParam2:setString(getConvertedStr(5, 10099))
			setTextCCColor(self.pLbParam2, _cc.red)

			self.pLbParam4:setString(formatTimeToHms(0))
			self.pFoodCost:setLabelCnCr(3,0)
			--self.pFoodCost:setLabelCnCr(3,getResourcesStr(Player:getPlayerInfo().nFood),getC3B(_cc.red))
			self.pFoodCost:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nFood))
			self.pFoodCost:setPosition(self.pLbParam5:getPositionX() - self.pFoodCost:getWidth() / 2,
				self.pLbParam5:getPositionY() - self.pFoodCost:getHeight() / 2)
		elseif self.tCurData.nType == e_camp_item.finish then 		--募兵完成
			-- --文字
			self.pLbParam1:setVisible(true)
			setTextCCColor(self.pLbParam1,_cc.pwhite)
			self.pLbParam1:setString(getConvertedStr(1, 10133))
			self.pLbParam2:setVisible(true)
			setTextCCColor(self.pLbParam2,_cc.blue)
			self.pLbParam3:setVisible(true)
			setTextCCColor(self.pLbParam3,_cc.green)
			self.pLbParam3:setString(getConvertedStr(1, 10137))
			self.pLbParam4:setVisible(false)
			self.pLbParam5:setVisible(false)
			--按钮
			self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtnAction:updateBtnText(getConvertedStr(1, 10137))
			self.pBtnAction:setBtnEnable(true)
			--底部提示层
			self.pLayTips:setVisible(false)
			--进度条层
			self.pLayBar:setVisible(true)
			--进度条
			if not self.pLoadingBar then
				self.pLoadingBar = MCommonProgressBar.new({bar = "v1_bar_green_2.png",barWidth = 388, barHeight = 14})
				self.pLayBar:addView(self.pLoadingBar)
				centerInView(self.pLayBar,self.pLoadingBar)
			end
			self.pLoadingBar:setVisible(true)
			self.pLoadingBar:setBarImage("ui/bar/v1_bar_yellow_7.png")
			self.pLoadingBar:setViewEnabled(true)
			--粮草消耗
			if self.pFoodCost then
				self.pFoodCost:setBtnExTextEnabled(false)
			end
			--滑动条
			if self.pSliderBar then
				self.pSliderBar:setVisible(false)
			end

			--设置募兵数和进度
			self.pLbParam2:setString(self.tCurData.nNum)
			self.pLoadingBar:setPercent(100)
		elseif self.tCurData.nType == e_camp_item.more then 		--扩充
			--文字
			self.pLbParam1:setVisible(true)
			setTextCCColor(self.pLbParam1,_cc.white)
			self.pLbParam1:setString(getConvertedStr(1, 10138))
			-- self.pLbParam1:setPositionY(self.pLbParam1:getPositionY()-20)
			self.pLbParam2:setVisible(false)
			self.pLbParam3:setVisible(false)
			self.pLbParam4:setVisible(false)
			self.pLbParam5:setVisible(false)
			--按钮
			self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtnAction:updateBtnText(getConvertedStr(1, 10139))
			self.pBtnAction:setBtnEnable(true)
			--底部提示层
			self.pLayTips:setVisible(true)
			--进度条层
			self.pLayBar:setVisible(false)
			--进度条
			if self.pLoadingBar then
				self.pLoadingBar:setVisible(false)
			end
			--粮草消耗
			if self.pFoodCost then
				self.pFoodCost:setBtnExTextEnabled(false)
			end
			--滑动条
			if self.pSliderBar then
				self.pSliderBar:setVisible(false)
			end

			--下个队列增加兵容量
			self.pLbBTips2:setString(self.tCurData.nNextAddCpy)
			self.pLbBTips2:setPositionX(self.pLbBTips1:getPositionX() + self.pLbBTips1:getWidth() + 5)
		end
	end
	self:resetBtnPosY()
end

--拖动条释放监听事件
function ItemCamp:onSliderBarRelease(  )
	-- body
	local nEvery = getBuildParam("recruitInterval")
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	local nAllCt = self.tCurData.nSD / 60 / nEvery --转化分钟，再转化次数
	local nCurCt = math.ceil(nAllCt * curvalue / 100) --获取当前次数
	curvalue = nCurCt / nAllCt * 100
	self.pSliderBar:setSliderValue(curvalue)
	--重置空闲队列相关数据
	local nNum = nCurCt * tonumber(getBuildParam("baseRecruitSpeed")) * nEvery
	self.tCurData.nCurNum = self.tBuildInfo:getRefreshNumByBuffPush(nNum)
	self.tCurData.nCurSD = nCurCt * 60 * nEvery
	--设置相关数据
	self:setFreeMsg()
end

--监听滑动事件回调
function ItemCamp:onSliderBarChange(  )
	-- body
	local nEvery = getBuildParam("recruitInterval")
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	local nAllCt = self.tCurData.nSD / 60 / nEvery --转化分钟，再转化次数
	local nCurCt = math.ceil(nAllCt * curvalue / 100) --获取当前次数
	--重置空闲队列相关数据
	local nNum = nCurCt * tonumber(getBuildParam("baseRecruitSpeed")) * nEvery
	self.tCurData.nCurNum = self.tBuildInfo:getRefreshNumByBuffPush(nNum)
	self.tCurData.nCurSD = nCurCt * 60 * nEvery
	--设置相关数据
	self:setFreeMsg()
end

--设置可募兵状态下相关数据
function ItemCamp:setFreeMsg(  )
	-- body
	--初始状态为满
	self.pLbParam2:setString(self.tCurData.nCurNum)
	self.pLbParam4:setString(formatTimeToHms(self.tCurData.nCurSD))
	--粮草消耗
	local nCost = self.tBuildInfo:getNeedCostFood(self.tBuildInfo.sTid, self.tCurData.nCurNum)

	if nCost > Player:getPlayerInfo().nFood then
		self.pFoodCost:setLabelCnCr(3,getResourcesStr(nCost),getC3B(_cc.pwhite))
		self.pFoodCost:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nFood),getC3B(_cc.red))
	else
		self.pFoodCost:setLabelCnCr(3,getResourcesStr(nCost),getC3B(_cc.pwhite))
		self.pFoodCost:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nFood),getC3B(_cc.green))
		
	end
	
	self.pFoodCost:setPosition(self.pLbParam5:getPositionX() - self.pFoodCost:getWidth() / 2,
		self.pLbParam5:getPositionY() - self.pFoodCost:getHeight() / 2)
	if self.tCurData.nCurNum <= 0 then
		self.pBtnAction:setBtnEnable(false)
	else
		self.pBtnAction:setBtnEnable(true)
	end
	--刷新募兵需要消耗的粮草
	local tObject = {}
	tObject.nFoodCost = nCost		
	sendMsg(ghd_refresh_camp_recruit, tObject)
end

--设置募兵状态中相关数据
function ItemCamp:setIngMsg( )
	-- body
	local nAllTime = self.tCurData.nSD
	local nLeftTime = self.tCurData:getRecruitLeftTime()
	if nLeftTime > 0 then
		self.pLbParam4:setString(formatTimeToHms(nLeftTime))
		local nPercent = math.floor((nAllTime - nLeftTime) / nAllTime * 100)
		self.pLoadingBar:setPercent(nPercent)
	else
		unregUpdateControl(self)
		self.pLbParam4:setString(formatTimeToHms(0))
		self.pLoadingBar:setPercent(100)
	end
end

--每秒刷新
function ItemCamp:onUpdate(  )
	-- body
	if self.tCurData.nType == e_camp_item.ing then --招募中
		--设置相关数据
		self:setIngMsg()
	else
		unregUpdateControl(self)
	end
end

-- 析构方法
function ItemCamp:onItemCampDestroy(  )
	-- body
	unregUpdateControl(self)
end


--设置当前数据
function ItemCamp:setCurData( _data, _tBuildInfo, _tFirstData )
	-- body
	self.tCurData = _data
	self.tBuildInfo = _tBuildInfo
	self.tFirstData = _tFirstData
	self:updateViews()
end

--设置点击事件回到
function ItemCamp:setClickCallBack( _handler)
	-- body
	self.nHandler = _handler
end

--操作按钮点击回调
function ItemCamp:onActionClicked( pView )
	-- body
	if self.pBtnAction:getBtnText() == getConvertedStr(7, 10243) then --活动加速
		--请求活动加速
		SocketManager:sendMsg("reqEnemySpeed", {e_item_ids.mbjs,  self.tBuildInfo.nCellIndex}, function()
			-- body
			self:updateViews()
		end)
		return
	end
	if self.nHandler then
		self.nHandler(self.tCurData)
		--新手引导已点
		if self.tFirstData and self.pBtnAction:getBtnText() == getConvertedStr(1, 10136) then
			Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtnAction)
		end
	end	
end

--操作按钮无效点击回调事件
function ItemCamp:onActionDisabledClicked( pView )
	-- body
	if self.tCurData.nType == e_camp_item.fill then 		--兵力满
		TOAST(getConvertedStr(1, 10165))
	end
end

function ItemCamp:showFreeStatus( bshow )
	-- body
	if bshow and self.tCurData and 
		(self.tCurData.nType == e_camp_item.free or self.tCurData.nType == e_camp_item.fill) then
		self.pLbDef:setVisible(true)
		self.pLayTop:setVisible(false)
		self.pLayBottom:setVisible(false)
	else
		self.pLbDef:setVisible(false)
		self.pLayTop:setVisible(true)
		self.pLayBottom:setVisible(true)
	end
end

function ItemCamp:resetBtnPosY( )
	-- body
	if self.pFoodCost then
	 	if self.pFoodCost:isVisible() or self.pLbParam5:isVisible() then

			self.pLayAction:setPositionY((self:getHeight()-self.pLayAction:getHeight())/2-15)
		else
			self.pLayAction:setPositionY((self:getHeight()-self.pLayAction:getHeight())/2)

		end
	elseif self.pLbParam5:isVisible() then
		self.pLayAction:setPositionY((self:getHeight()-self.pLayAction:getHeight())/2-15)
	else
		self.pLayAction:setPositionY((self:getHeight()-self.pLayAction:getHeight())/2)
	end
end
--重置招募中的背景
function ItemCamp:resetRecuitingBg( )
	-- body
	self.pBg:removeBackground()
	self.pBg:setBackgroundImage("#v2_img_jinduyanjiudi.png",{scale9 = true,capInsets=cc.rect(2,37, 1, 1)})
	local nPosX=self:getPositionX()
	self.pBg:setPositionX(nPosX+20)
	-- if not self.pLine then
	-- 	self.pLine=self:findViewByName("lay_line")
	-- end
	-- self.pLine:setVisible(false)
end
return ItemCamp