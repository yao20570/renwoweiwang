-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-10-20 16:07:40 星期六
-- Description: 总览层的每项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local OverViewItem = class("OverViewItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function OverViewItem:ctor()
	-- body
	self:myInit()
	parseView("item_overview", handler(self, self.onParseViewCallback))	
end

--初始化成员变量
function OverViewItem:myInit()
	-- body
	self.tBuildInfo = nil
	self.nBtnSize = 26
end

--解析布局回调事件
function OverViewItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("OverViewItem",handler(self, self.onOverViewItemDestroy))
end

--初始化控件
function OverViewItem:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("item_overview")
	--建筑图片
	self.pImgBuild = self:findViewByName("img_build")
	--建筑名称
	self.pLbBuild = self:findViewByName("lb_build")
	--进度条层
	self.pLyBar = self:findViewByName("lay_bar")
	--进度条时间
	self.pLbTime = self:findViewByName("lb_time")
	--按钮层
	self.pLayBtn = self:findViewByName("lay_btn")
	--建筑本身状态
	self.pLbBuildState = self:findViewByName("lb_build_state")
	--建筑工作状态
	self.pLbWorkState = self:findViewByName("lb_work_state")

	self.nPosY = self.pLbBuildState:getPositionY()
end

-- 修改控件内容或者是刷新控件数据
function OverViewItem:updateViews( )
	-- body
	if not self.pProgressBar then
		self.pProgressBar = MCommonProgressBar.new({
			bg = "v1_bar_b1.png",
			bar = "v2_bar_blue_11.png",
			barWidth = 164,
			barHeight = 14
			})
		self.pLyBar:addView(self.pProgressBar)
		centerInView(self.pLyBar, self.pProgressBar)
	end
	self.pLyBar:setVisible(false)
	if not self.pBtn then
		self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(7,10079))
		self.pBtn:updateBtnTextSize(self.nBtnSize)
		setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.7)
		self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
		self.pBtn:setVisible(false)
	end
	if self.pIndex == 1 then 					--建筑升级
		local nState, pCurBuild = Player:getBuildData():getBuildingQueStateByType(self.nItemIdx)
		self.tBuildInfo = pCurBuild
		if self.nItemIdx == 1 then --默认队列
			self.pImgBuild:setCurrentImage("#v1_img_dl1.png")
			if nState == 0 then --空闲
				self.pBtn:setVisible(true)
				self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
				self.pLbWorkState:setString("")
			else
				if pCurBuild then
					--设置进度和时间
					self:setBarAndTime()
					self.pLbWorkState:setString(getConvertedStr(7, 10172)) --升级中
					self.pBtn:setVisible(false)
				end
			end
		else --购买队列
			self.pImgBuild:setCurrentImage("#v1_img_dl2.png")
			local nLeftTime = Player:getBuildData():getBuildBuyFinalLeftTime()
			if nLeftTime > 0 then --雇佣中
				--开始倒计时
				self:setTime()
				if nState == 1 then --升级中
					--设置进度和时间
					self:setBarAndTime()
					self.pLbBuildState:setPositionY(11)
					self.pLbWorkState:setString(getConvertedStr(7, 10172)) --升级中
					self.pBtn:setVisible(false)
				else
					self.pLbBuildState:setPositionY(self.nPosY)
					self.pBtn:setVisible(true)
					self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
					self.pLbWorkState:setString("")
				end
			else
				self.pLbBuildState:setString(getConvertedStr(7, 10178)) --未激活
				self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtn:updateBtnText(getConvertedStr(7, 10079), self.nBtnSize)  --购买
				self.pBtn:setVisible(true)
				self.pLbWorkState:setString("")
				if nState == 1 then --升级中
					self.pLbBuildState:setPositionY(11)
				else
					self.pLbBuildState:setPositionY(self.nPosY)
				end
			end
			self.pLbBuildState:setVisible(true)
			setTextCCColor(self.pLbBuildState, _cc.red)
		end
		self.pImgBuild:setScale(0.3)
		self.pLbBuild:setString(string.format(getConvertedStr(7, 10160), self.nItemIdx))

	elseif self.pIndex == 2 then 				--科技研究
		self.pImgBuild:setCurrentImage("#v1_img_kjy.png")
		self.pImgBuild:setScale(0.3)
		self.pLbBuild:setString(getConvertedStr(7, 10161))

		self.nCell = e_build_cell.tnoly
		self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCell)
		if self:isLocked() then
			return
		end
		
		self.pLbBuildState:setVisible(false)

		--科技院状态显示
		self:onTnolyState()

	elseif self.pIndex == 3 then 				--招募士兵
		self.pImgBuild:setScale(0.3)
		if self.nItemIdx == 1 then     --步兵
			self.pImgBuild:setCurrentImage("#v1_img_bby.png")
			self.pLbBuild:setString(getConvertedStr(7, 10162))

			self.nCell = e_build_cell.infantry
			self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCell)
			if self:isLocked() then
				return
			end
			
		elseif self.nItemIdx == 2 then --骑兵
			self.pImgBuild:setCurrentImage("#v1_img_qby.png")
			self.pLbBuild:setString(getConvertedStr(7, 10163))

			self.nCell = e_build_cell.sowar
			self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCell)
			if self:isLocked() then
				return
			end
			
		elseif self.nItemIdx == 3 then --弓兵
			self.pImgBuild:setCurrentImage("#v1_img_gby.png")
			self.pLbBuild:setString(getConvertedStr(7, 10164))

			self.nCell = e_build_cell.archer
			self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCell)
			if self:isLocked() then
				return
			end
		end

		self.pLbBuildState:setVisible(false)

		--兵营状态显示
		self:onCampState()

	elseif self.pIndex == 4 then 				--打造装备
		self.pImgBuild:setCurrentImage("#v1_img_tjp.png")
		self.pImgBuild:setScale(0.3)
		self.pLbBuild:setString(getConvertedStr(7, 10165))

		self.nCell = e_build_cell.tjp
		self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCell)
		if self:isLocked() then
			return
		end
		
		self.pLbBuildState:setVisible(false)

		--铁匠铺状态显示
		self:onSmithShopState()

	elseif self.pIndex == 5 then 				--生产材料
		self.pImgBuild:setCurrentImage("#v1_img_gf.png")
		self.pImgBuild:setScale(0.3)
		self.pLbBuild:setString(getConvertedStr(7, 10166))

		self.nCell = e_build_cell.atelier
		self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCell)
		if self:isLocked() then
			return
		end
		
		self.pLbBuildState:setVisible(false)

		--工坊状态显示
		self:onAtelierState()

	elseif self.pIndex == 6 then 				--武将队列
		self.pImgBuild:setCurrentImage("#v1_img_mrdl.png")
		self.pImgBuild:setScale(0.3)
		self.pLbBuild:setString(getConvertedStr(7, 10167))

		--武将状态显示
		self:onHeroState()

	elseif self.pIndex == 7 then 				--武将推演
		if self.nItemIdx == 1 then    --良将推演
			self.pImgBuild:setCurrentImage("#v1_img_ljty.png")
			self.pLbBuild:setString(getConvertedStr(7, 10168))
		else 							--神将推演
			self.pImgBuild:setCurrentImage("#v1_img_sjty.png")
			self.pLbBuild:setString(getConvertedStr(7, 10169))
		end
		self.pImgBuild:setScale(0.3)

		self.nCell = e_build_cell.bjt
		self.tBuildInfo = Player:getBuildData():getBuildByCell(self.nCell)
		if self:isLocked() then
			return
		end
		if self.nItemIdx == 1 then
			self.pBtn:setVisible(true)
			self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
		else
			local pData = Player:getHeroInfo():getBuyHeroData()
			if pData.gop == 1 or pData.prg >= 100 then --已开启
				self.pBtn:setVisible(true)
				self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
				self:setShenHeroCd()
				self.pLbBuildState:setVisible(true)
				setTextCCColor(self.pLbBuildState, _cc.red)
			else
				self.pBtn:setVisible(false)
				self.pProgressBar:setPercent(pData.prg)
				self.pLbTime:setString(pData.prg.."%")
				self.pLyBar:setVisible(true)
			end
		end
	end
end

--科技院状态显示
function OverViewItem:onTnolyState()
	--是否可以在升级科技的时候同时研究科技
	local bUpingWithTecnologying = getIsCanTnolyUpingWithTecnologying()
	if self.tBuildInfo.nState == e_build_state.uping then --升级中
		--设置进度和时间
		self:setBarAndTime()
		--如果购买了vip5礼包并雇佣了紫色研究员仍然显示前往按钮(除正在研究外)
		if bUpingWithTecnologying and not Player:getTnolyData():getUpingTnoly() then
			self.pBtn:setVisible(true)
			self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
		else
			self.pBtn:setVisible(false)
			self.pLbWorkState:setString(getConvertedStr(7, 10172)) --升级中
		end
	else
		--正在研究中的科技
		self.tCurTonly = Player:getTnolyData():getUpingTnoly()
		if self.tCurTonly then
			self:setTnolyBarAndTime()
			if self.tCurTonly:getUpingFinalLeftTime() > 0 then
				if bUpingWithTecnologying then
					self.pBtn:setVisible(true)
					self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
				else
					self.pBtn:setVisible(false)
					self.pLbWorkState:setString(getConvertedStr(7, 10173)) --研究中
				end
			else
				self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtn:updateBtnText(getConvertedStr(7, 10171), self.nBtnSize) --收获
				self.pBtn:setVisible(true)
			end
		else
			self.pLyBar:setVisible(false)
			self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize)
			self.pBtn:setVisible(true)
			self.pLbWorkState:setString("")
		end
	end
end

--兵营状态显示
function OverViewItem:onCampState()
	local tDatasFree = self.tBuildInfo:getFreeTeams()
	local nLeftFree = #tDatasFree
	--显示剩余空闲队列
	local function showLeftFreeNum()
		-- body
		self.pBtn:setVisible(true)
		self.pLbWorkState:setString("")
		self.pLbBuildState:setVisible(true)
		self.pLbBuildState:setString(string.format(getConvertedStr(7, 10175), nLeftFree)) --剩余空闲队列
	end
	if self.tBuildInfo.nState == e_build_state.uping then --升级中
		--设置进度和时间
		self:setBarAndTime()
		self.pLbWorkState:setString(getConvertedStr(7, 10172)) --升级中
		self.pBtn:setVisible(false)
	elseif self.tBuildInfo.nState == e_build_state.producing then --募兵中
		if nLeftFree > 0 then
			self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
			showLeftFreeNum()
		elseif nLeftFree == 0 then
			--设置进度和时间
			self:setBarAndTime()
			self.pLbWorkState:setString(getConvertedStr(7, 10174)) --募兵中
			self.pBtn:setVisible(false)
		end
	else
		local tRecuitOk = self.tBuildInfo:getRecruitedQue()
		--募兵完成
		if tRecuitOk then
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:updateBtnText(getConvertedStr(7, 10171), self.nBtnSize) --收获
		else
			self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
		end
		showLeftFreeNum()
		-- self.pBtn:setVisible(true)
		-- self.pLbWorkState:setString("")
		-- self.pLbBuildState:setVisible(true)
		-- self.pLbBuildState:setString(string.format(getConvertedStr(7, 10175), nLeftFree)) --剩余空闲队列
	end
end

--铁匠铺状态显示
function OverViewItem:onSmithShopState()
	-- body
	--正在打造的装备
	self.tCurEquip = Player:getEquipData():getMakeVo()
	if self.tCurEquip then
		--设置装备打造的时间
		self:setEquipBuildBarAndTime()
		if self.tCurEquip:getCd() > 0 then
			self.pBtn:setVisible(false)
			self.pLbWorkState:setString(getConvertedStr(7, 10137)) --打造中
		else
			self.pBtn:setVisible(true)
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:updateBtnText(getConvertedStr(7, 10171), self.nBtnSize) --收获
		end
	else
		self.pLyBar:setVisible(false)
		--是否有装备可领取
		local bHasEquip = Player:getEquipData():getIsFinishMakeEquip()
		self.pBtn:setVisible(true)
		self.pLbWorkState:setString("")
		if bHasEquip then
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:updateBtnText(getConvertedStr(7, 10171), self.nBtnSize) --收获
		else
			self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
		end
	end
end

--工坊状态显示
function OverViewItem:onAtelierState()
	-- body
	--生产队列长度
	local nProducing = self.tBuildInfo:getProQueueNum()
	--剩余空闲队列
	local nLeftFree = self.tBuildInfo.nQueue - nProducing
	self.nAtelierLeftFree = nLeftFree
	if self.tBuildInfo.nState == e_build_state.uping then --升级中
		--设置进度和时间
		self:setBarAndTime()
		self.pLbWorkState:setString(getConvertedStr(7, 10172)) --升级中
		self.pBtn:setVisible(false)
	elseif self.tBuildInfo.nState == e_build_state.producing then --生产中
		
		local tAtelierOK = self.tBuildInfo:getFirstFinshQueueItem()
		--生产完成
		if tAtelierOK then
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:updateBtnText(getConvertedStr(7, 10171), self.nBtnSize) --收获
			self.pBtn:setVisible(true)
			self.pLbWorkState:setString("")
			self.pLbBuildState:setVisible(true)
			self.pLbBuildState:setString(string.format(getConvertedStr(7, 10175), nLeftFree)) --剩余空闲队列
			return
		end
		
		--所有已开启队列都在生产，显示最快完成的那个队列的倒计时
		if nLeftFree == 0 then
			--设置进度和时间
			self:setBarAndTime()
			self.pLbWorkState:setString(getConvertedStr(7, 10176)) --生产中
			self.pBtn:setVisible(false)
		elseif nLeftFree > 0 then --有空闲队列还没有使用，提示剩余空闲队列数
			self.pLbBuildState:setVisible(true)
			self.pLbBuildState:setString(string.format(getConvertedStr(7, 10175), nLeftFree)) --剩余空闲队列
			self.pBtn:setVisible(true)
			self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
			self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
		end
	else
		self.pLbBuildState:setVisible(true)
		self.pLbBuildState:setString(string.format(getConvertedStr(7, 10175), nLeftFree)) --剩余空闲队列
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
		self.pBtn:setVisible(true)
	end
end

--武将状态显示
function OverViewItem:onHeroState()
	-- body
	--上阵队列
	local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroList()
	--可上阵数量
	local nAllHeroNums = table.nums(tHeroOnlineList)
	local nBattling = 0
	for k, v in pairs(tHeroOnlineList) do
		if v.nW == 1 then
			nBattling = nBattling + 1
		end
	end
	local nLeftFree = nAllHeroNums - nBattling
	self.nHeroLeftFree = nLeftFree
	--如果全部武将都已派出, 显示最近返回的队列倒计时
	if nLeftFree == 0 then
		self.pLbBuildState:setVisible(false)
		self.pBtn:setVisible(false)
		self.pLbWorkState:setString(getConvertedStr(7, 10177)) --行军中
		self.tTaskMsgs = Player:getWorldData():getShortestCdTask()
		--设置进度和时间
		self:setBarAndTime()
	elseif nLeftFree > 0 then
		self.pLbBuildState:setVisible(true)
		self.pLbBuildState:setString(string.format(getConvertedStr(7, 10175), nLeftFree)) --剩余空闲队列
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(getConvertedStr(7, 10170), self.nBtnSize) --前往
		self.pBtn:setVisible(true)
	end
end

--建筑是否锁住
function OverViewItem:isLocked()
	-- body
	if self.tBuildInfo:getIsLocked() then
		local tBuildData = getBuildDatasByTid(self.tBuildInfo.sTid)
		if tBuildData then
			self.pLbBuildState:setString(tBuildData.notopen)
			self.pLbBuildState:setVisible(true)
			return true
		end
	else
		return false
	end
end


--设置研究中科技的时间
function OverViewItem:setTnolyBarAndTime()
	-- body
	local fAllTime = self.tCurTonly.fStudingAllTime
	--剩余时间
	local fLeftTime = self.tCurTonly:getUpingFinalLeftTime()
	if fLeftTime > 0 then
		local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
		self.pProgressBar:setPercent(nPercet)
		self.pLbTime:setString(formatTimeToHms(fLeftTime), false)
		self.pLyBar:setVisible(true)
	else
		self.pLyBar:setVisible(false)
		self.pProgressBar:setPercent(100)
		self.pLbTime:setString(formatTimeToHms(0),false)
	end
end

--设置装备打造的时间
function OverViewItem:setEquipBuildBarAndTime()
	-- body
	local equip = getBaseEquipDataByID(self.tCurEquip.nId)
	local fAllTime = equip.nMakeTimes
	--剩余时间
	local fLeftTime = self.tCurEquip:getCd()
	if fLeftTime > 0 then
		local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
		self.pProgressBar:setPercent(nPercet)
		self.pLbTime:setString(formatTimeToHms(fLeftTime), false)
		self.pLyBar:setVisible(true)
	else
		self.pLyBar:setVisible(false)
		self.pProgressBar:setPercent(100)
		self.pLbTime:setString(formatTimeToHms(0), false)
	end
end

--设置进度和时间
function OverViewItem:setBarAndTime()
	-- body
	if self.tBuildInfo then
		if self.tBuildInfo.nState == e_build_state.uping then --升级中
			--总时间
			local fAllTime = self.tBuildInfo:getBuildUpLvTime()
			--剩余时间
			local fLeftTime = self.tBuildInfo:getBuildingFinalLeftTime()

			if fLeftTime > 0 then
				local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
				self.pProgressBar:setPercent(nPercet)
				self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
				self.pLyBar:setVisible(true)
			else
				self.pProgressBar:setPercent(100)
				self.pLbTime:setString(formatTimeToHms(0),false)
				self.pLyBar:setVisible(false)
			end
		elseif self.tBuildInfo.nState == e_build_state.creating then --改建中
			--总时间
			local fAllTime = self.tBuildInfo:getBuildUpLvTime()
			--剩余时间
			local fLeftTime = self.tBuildInfo:getBuildingFinalLeftTime()

			if fLeftTime > 0 then
				local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
				self.pProgressBar:setPercent(nPercet)
				self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
				self.pLyBar:setVisible(true)
			else
				self.pProgressBar:setPercent(100)
				self.pLbTime:setString(formatTimeToHms(0),false)
				self.pLyBar:setVisible(false)
			end
		elseif self.tBuildInfo.nState == e_build_state.producing then --生产中
			if self.tBuildInfo.sTid == e_build_ids.infantry
				or self.tBuildInfo.sTid == e_build_ids.archer
				or self.tBuildInfo.sTid == e_build_ids.sowar then --兵营
				local tDatasFree = self.tBuildInfo:getFreeTeams()
				if #tDatasFree == 0 then
					local tRecruiting = self.tBuildInfo:getRecruitingQue()
					if tRecruiting then
						local fAllTime = tRecruiting.nSD
						local fLeftTime = tRecruiting:getRecruitLeftTime()
						if fLeftTime > 0 then
							local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
							self.pProgressBar:setPercent(nPercet)
							self.pLbTime:setString(formatTimeToHms(fLeftTime), false)
							self.pLyBar:setVisible(true)
						else
							self.pProgressBar:setPercent(100)
							self.pLbTime:setString(formatTimeToHms(0), false)
							self.pLyBar:setVisible(false)
						end
					else
						self.pLyBar:setVisible(false)
					end
				else
					self.pLyBar:setVisible(false)
				end
			elseif self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
				local tProQueue = self.tBuildInfo:getShortTimeProQueue()
				if tProQueue then
					local fLeftTime = tProQueue:getProduceCD()
					if fLeftTime > 0 then
						if self.nAtelierLeftFree == 0 then
							local nPercet = tProQueue:getProducePercent()*100
							self.pProgressBar:setPercent(nPercet)
							self.pLbTime:setString(formatTimeToHms(fLeftTime), false)
							self.pLyBar:setVisible(true)
						end
					else
						self.pProgressBar:setPercent(100)
						self.pLbTime:setString(formatTimeToHms(0), false)
						self.pLyBar:setVisible(false)
					end
				else
					self.pLyBar:setVisible(false)
				end
			end
		end

	elseif self.pIndex == 6 then --武将出征倒计时
		if self.tTaskMsgs then
			local fAllTime = self.tTaskMsgs.nCdMax
			local fLeftTime = self.tTaskMsgs:getCd()
			if fLeftTime > 0 then
				if self.nHeroLeftFree == 0 then
					local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
					self.pProgressBar:setPercent(nPercet)
					self.pLbTime:setString(formatTimeToHms(fLeftTime), false)
					self.pLyBar:setVisible(true)
				end
			else
				self.pProgressBar:setPercent(100)
				self.pLbTime:setString(formatTimeToHms(0), false)

				self.pLyBar:setVisible(false)
			end
		else
			self.pLyBar:setVisible(false)
		end
	end
end


--每秒刷新
function OverViewItem:onUpdate()
	-- body
	if self.tCurTonly then
		self:setTnolyBarAndTime()
	elseif self.tCurEquip then
		self:setEquipBuildBarAndTime()
	else
		self:setBarAndTime()
	end
	if self.pIndex == 1 then
		self:setTime()
	elseif self.pIndex == 7 and self.nItemIdx == 2 then
		self:setShenHeroCd()
	end
end

--神将关闭剩余cd
function OverViewItem:setShenHeroCd()
	-- body
	local nLeftTime = Player:getHeroInfo():getLeftCloseLiangCd()
	if nLeftTime > 0 then
		self.pLbBuildState:setString(getConvertedStr(7, 10244)..formatTimeToHms(nLeftTime))
	else
		if self.pLbBuildState:isVisible() then
			self.pLbBuildState:setVisible(false)
		end
	end
end

--建筑升级(购买队列剩余生效时间)
function OverViewItem:setTime()
	-- body
	local nLeftTime = Player:getBuildData():getBuildBuyFinalLeftTime()
	if nLeftTime > 0 then
		self.pLbBuildState:setString(getConvertedStr(7, 10179)..formatTimeToHms(nLeftTime))
	end
end


-- 析构方法
function OverViewItem:onOverViewItemDestroy(  )
	-- body
end


--按钮消息回调
function OverViewItem:onBtnClicked( pview )
	--关闭总览
	sendMsg(ghd_showorhide_overview_menu)

	--建筑升级的前往按钮需要模拟点击建筑一次,其他只需定位到建筑位置
	if self.pBtn:getBtnText() == getConvertedStr(7, 10170) or
		self.pBtn:getBtnText() == getConvertedStr(7, 10171) then --前往或收获
		if self.pIndex == 1 then
			local tAllBuilds = Player:getBuildData():getCanUpBuildLists()
			if tAllBuilds and table.nums(tAllBuilds) > 0 then
				local tChoiceBuild = tAllBuilds[1] --选取第一个为目标建筑
				if tChoiceBuild then
					--移动到屏幕中点
					local tOb = {}
					tOb.nCell = tChoiceBuild.nCellIndex
					tOb.nFunc = function (  )
						-- body
						--模拟执行一次点击行为
						--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
						local tObject = {}
						tObject.nCell = tChoiceBuild.nCellIndex
						tObject.nFromWhat = _nType --标志从左对联进来的
						sendMsg(ghd_show_build_actionbtn_msg,tObject)
					end
					sendMsg(ghd_move_to_build_dlg_msg, tOb)
				end
			else
				TOAST(getConvertedStr(1, 10263)) --没有满足条件的建筑
			end
		elseif self.pIndex == 6 then  --前往世界
			sendMsg(ghd_home_show_base_or_world, 2)
		else
			local tObject = {}
			tObject.nCell = self.nCell
			tObject.bShowFinger = true --移动完后添加手指光圈指引
			sendMsg(ghd_move_to_build_dlg_msg, tObject)
		end
	elseif self.pBtn:getBtnText() == getConvertedStr(7, 10079) then --购买
		local tObject = {}
		tObject.nType = e_dlg_index.buildbuyteam --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end


--_pIndex:父类的下标
--_itemIdx:当前item在父类的下标
function OverViewItem:setItemData(_pIndex, _itemIdx)
	-- body
	self.pIndex = _pIndex
	self.nItemIdx = _itemIdx
	
	self:updateViews()
end


return OverViewItem