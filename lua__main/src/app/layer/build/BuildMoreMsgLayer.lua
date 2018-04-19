-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-05 14:46:22 星期三
-- Description: 建造进度条详细内容展示层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")


local BuildMoreMsgLayer = class("BuildMoreMsgLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function BuildMoreMsgLayer:ctor(  )
	-- body
	self:myInit()
	parseView("layout_build_more_msg", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function BuildMoreMsgLayer:myInit(  )
	-- body
	self.tBuildInfo 		= 	nil --当前建造数据

	self.tCurTonly 			=   nil --当前研究中的科技

	self.tCurEquip          =   nil --当前打造中的装备
end

--解析布局回调事件
function BuildMoreMsgLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("BuildMoreMsgLayer",handler(self, self.onBuildMoreMsgLayerDestroy))
end

--初始化控件
function BuildMoreMsgLayer:setupViews( )
	-- body
	--进度层
	self.pLayBar 			= 	self:findViewByName("bar_bg")
	--升级进度
	self.pBarUp 			= 	MCommonProgressBar.new({bar = "v1_bar_blue_sc.png",barWidth = 124, barHeight = 16})
	self.pLayBar:addView(self.pBarUp)
	-- centerInView(self.pLayBar, self.pBarUp)
	self.pBarUp:setPosition(self.pLayBar:getWidth()/2 - 4, self.pLayBar:getHeight()/2)
	--时间
	self.pLbTime 			= 	self:findViewByName("lb_time")
	--图片
	self.pImgType 			= 	self:findViewByName("img")
end

-- 修改控件内容或者是刷新控件数据
function BuildMoreMsgLayer:updateViews(  )
	-- body
	if self.tBuildInfo then
		--科技院需要特殊处理，因为科技院允许又是升级又是生产的状态
		-- if self.tBuildInfo.sTid == e_build_ids.tnoly then
		-- 	if self.tBuildInfo.nState == e_build_state.free then  					--空闲
				
		-- 	elseif self.tBuildInfo.nState == e_build_state.uping then 				--升级中
		-- 		self.pImgType:setCurrentImage("#v1_img_shengjixiao.png")
		-- 		self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
		-- 		--设置进度和时间
		-- 		self:setBarAndTime()
		-- 		--开始倒计时
		-- 		self:startUpdateHandler()
		-- 	end
		if self.tBuildInfo.sTid == e_build_ids.tjp then 						--铁匠铺
			--是否有装备正在打造
			self.tCurEquip = Player:getEquipData():getMakeVo()
			if self.tCurEquip then
				self.pImgType:setCurrentImage("#v1_img_shengchanzhong.png")
				self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
				--设置装备打造的时间
				self:setEquipBuildBarAndTime()

				if self.tCurEquip:getCd() > 0 then
					--开始倒计时
					self:startUpdateHandler()
				end
			else
				--关闭倒计时
				self:stopUpdateHandler()
			end
		else
			if self.tBuildInfo.nState == e_build_state.free then  					--空闲
				--关闭倒计时
				self:stopUpdateHandler()
			elseif self.tBuildInfo.nState == e_build_state.uping then 				--升级中
				self.pImgType:setCurrentImage("#v1_img_shengjixiao.png")
				self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
				--设置进度和时间
				self:setBarAndTime()
				--开始倒计时
				self:startUpdateHandler()
			elseif self.tBuildInfo.nState == e_build_state.producing then 			--生产中
				if self.tBuildInfo.sTid == e_build_ids.infantry
					or self.tBuildInfo.sTid == e_build_ids.archer
					or self.tBuildInfo.sTid == e_build_ids.sowar then  --兵营
					self.pImgType:setCurrentImage("#v1_img_mubingxiao.png")								
					self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
					--设置进度和时间
					self:setBarAndTime()
					--开始倒计时
					self:startUpdateHandler()
				elseif self.tBuildInfo.sTid == e_build_ids.mbf then  --募兵府
					self.pImgType:setCurrentImage("#v1_img_mubingxiao.png")								
					self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
					--设置进度和时间
					self:setBarAndTime()
					--开始倒计时
					self:startUpdateHandler()
				elseif self.tBuildInfo.sTid == e_build_ids.atelier then  --工坊
					--生产
					local tProQueue = self.tBuildInfo.tProQueue
					local tFinshQueue = self.tBuildInfo.tFinshQueue
					--dump(self.tBuildInfo, "self.tBuildInfo", 100)
					if tProQueue and #tProQueue > 0 then
						self.pImgType:setCurrentImage("#v1_img_shengchanzhong.png")
						self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
						--设置进度和时间
						self:setBarAndTime()
						--开始倒计时
						self:startUpdateHandler()
					else
						--关闭倒计时
						self:stopUpdateHandler()
					end					
				end
			elseif self.tBuildInfo.nState == e_build_state.removing then --拆除中
				self.pImgType:setCurrentImage("#v1_img_caiqianxiao.png")
				self.pBarUp:setBarImage("ui/bar/v1_bar_yellow_5.png")
				--设置进度和时间
				self:setBarAndTime()
				--开始倒计时
				self:startUpdateHandler()
			elseif self.tBuildInfo.nState == e_build_state.creating then 	--改建中
				self.pImgType:setCurrentImage("#v1_img_shengjixiao.png")
				self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
				--设置进度和时间
				self:setBarAndTime()
				--开始倒计时
				self:startUpdateHandler()
			end
		end

		
	end

end

-- 析构方法
function BuildMoreMsgLayer:onBuildMoreMsgLayerDestroy(  )
	-- body
	self:onPause()
	--关闭倒计时
	self:stopUpdateHandler()
end

-- 注册消息
function BuildMoreMsgLayer:regMsgs( )
	-- body
end

-- 注销消息
function BuildMoreMsgLayer:unregMsgs(  )
	-- body
end


--暂停方法
function BuildMoreMsgLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function BuildMoreMsgLayer:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置当前数据
--_nBuildId: 如果传id过来说明是科技院的科技研究进度
function BuildMoreMsgLayer:setCurData( _tData, _nBuildId )
	-- body
	self.tBuildInfo = _tData
	self.nBuildId = _nBuildId
	if _nBuildId == e_build_ids.tnoly then
		--判断是否有研究中的科技
		self.tCurTonly = Player:getTnolyData():getUpingTnoly()
		if self.tCurTonly then --研究科技中
			self.pImgType:setCurrentImage("#v1_img_shengchanzhong.png")
			self.pBarUp:setBarImage("ui/bar/v1_bar_blue_sc.png")
			--设置科技研究的时间
			self:setTnolyBarAndTime()

			if self.tCurTonly:getUpingFinalLeftTime() > 0 then
				--开始倒计时
				self:startUpdateHandler()
			end
		else
			--关闭倒计时
			self:stopUpdateHandler()
		end
	else
		self:updateViews()
	end
end


--启动线程
function BuildMoreMsgLayer:startUpdateHandler(_hideSelf)
	-- body
	unregUpdateControl(self)
	regUpdateControl(self, handler(self, self.onUpdate))
	if not _hideSelf then
		self:setVisible(true)
	end
end

--关闭线程
function BuildMoreMsgLayer:stopUpdateHandler()
	-- body
	unregUpdateControl(self)
	self:setVisible(false)
end

--每秒刷新
function BuildMoreMsgLayer:onUpdate()
	-- body
	if self.tBuildInfo then
		if self.nBuildId == e_build_ids.tnoly and self.tCurTonly then --如果是科技研究
			self:setTnolyBarAndTime()
		elseif self.tBuildInfo.sTid == e_build_ids.tjp and self.tCurEquip then --如果是铁匠铺
			self:setEquipBuildBarAndTime()
		else
			self:setBarAndTime()
		end
	end
end

--设置研究中科技的时间
function BuildMoreMsgLayer:setTnolyBarAndTime(  )
	-- body
	if self.tCurTonly then --研究科技中
		local fAllTime = self.tCurTonly.fStudingAllTime
		--剩余时间
		local fLeftTime = self.tCurTonly:getUpingFinalLeftTime()
		if fLeftTime > 0 then
			local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
			self.pBarUp:setPercent(nPercet)
			self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
		else
			--关闭倒计时
			self:stopUpdateHandler()
			self.pBarUp:setPercent(100)
			self.pLbTime:setString(formatTimeToHms(0),false)
		end
	end
end

--设置装备打造的时间
function BuildMoreMsgLayer:setEquipBuildBarAndTime()
	-- body
	if self.tCurEquip then --研究科技中
		local equip = getBaseEquipDataByID( self.tCurEquip.nId )
		local fAllTime = equip.nMakeTimes
		--剩余时间
		local fLeftTime = self.tCurEquip:getCd()
		if fLeftTime > 0 then
			local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
			self.pBarUp:setPercent(nPercet)
			self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
		else
			--关闭倒计时
			self:stopUpdateHandler()
			self.pBarUp:setPercent(100)
			self.pLbTime:setString(formatTimeToHms(0),false)
		end
	end
end

--设置进度和时间
function BuildMoreMsgLayer:setBarAndTime(  )
	-- body

	if self.tBuildInfo.nState == e_build_state.uping then --升级中
		--总时间
		local fAllTime = self.tBuildInfo:getBuildUpLvTime()
		--剩余时间
		local fLeftTime = self.tBuildInfo:getBuildingFinalLeftTime()

		if fLeftTime > 0 then
			local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
			self.pBarUp:setPercent(nPercet)
			self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
		else
			self.pBarUp:setPercent(100)
			self.pLbTime:setString(formatTimeToHms(0),false)
			--关闭倒计时
			self:stopUpdateHandler()
		end
	elseif self.tBuildInfo.nState == e_build_state.producing then --生产中
		if self.tBuildInfo.sTid == e_build_ids.infantry
			or self.tBuildInfo.sTid == e_build_ids.archer
			or self.tBuildInfo.sTid == e_build_ids.sowar then --兵营
			local tRecruiting = self.tBuildInfo:getRecruitingQue()
			if tRecruiting then
				local fAllTime = tRecruiting.nSD
				local fLeftTime = tRecruiting:getRecruitLeftTime()
				if fLeftTime > 0 then
					self:setVisible(true)
					local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
					self.pBarUp:setPercent(nPercet)
					self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
				else
					self.pBarUp:setPercent(100)
					self.pLbTime:setString(formatTimeToHms(0),false)
					--关闭倒计时
					self:stopUpdateHandler()
				end
			else
				--关闭倒计时
				self:stopUpdateHandler()
			end
		elseif self.tBuildInfo.sTid == e_build_ids.mbf then --募兵府
			local tRecruiting = self.tBuildInfo:getRecruitingQue()
			if tRecruiting then
				local fAllTime = tRecruiting.nSD
				local fLeftTime = tRecruiting:getRecruitLeftTime()
				if fLeftTime > 0 then
					self:setVisible(true)
					local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
					self.pBarUp:setPercent(nPercet)
					self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
				else
					self.pBarUp:setPercent(100)
					self.pLbTime:setString(formatTimeToHms(0),false)
					--关闭倒计时
					self:stopUpdateHandler()
				end
			else
				--关闭倒计时
				self:stopUpdateHandler()
			end
		elseif self.tBuildInfo.sTid == e_build_ids.atelier then --作坊
			local tProQueue = self.tBuildInfo:getShortTimeProQueue()
			if tProQueue then
				local nPercet = tProQueue:getProducePercent()*100
				local fLeftTime = tProQueue:getProduceCD()
				if fLeftTime > 0 then
					self.pBarUp:setPercent(nPercet)
					self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
				else
					self.pBarUp:setPercent(100)
					self.pLbTime:setString(formatTimeToHms(0),false)
					--关闭倒计时
					self:stopUpdateHandler()
				end
			else
				--关闭倒计时
				self:stopUpdateHandler()
			end
		end
	elseif self.tBuildInfo.nState == e_build_state.creating or 
		self.tBuildInfo.nState == e_build_state.removing then --改建或拆除中
		--总时间
		local fAllTime = self.tBuildInfo:getBuildUpLvTime()
		--剩余时间
		local fLeftTime = self.tBuildInfo:getBuildingFinalLeftTime()

		if fLeftTime > 0 then
			local nPercet = math.floor((fAllTime - fLeftTime) / fAllTime * 100)
			self.pBarUp:setPercent(nPercet)
			self.pLbTime:setString(formatTimeToHms(fLeftTime),false)
		else
			self.pBarUp:setPercent(100)
			self.pLbTime:setString(formatTimeToHms(0),false)
			--关闭倒计时
			self:stopUpdateHandler()
		end
	end
	
end


return BuildMoreMsgLayer