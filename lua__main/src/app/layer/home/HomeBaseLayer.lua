-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-10 16:52:38 星期二
-- Description:  主界面基地层
-----------------------------------------------------

BASE_BG_TH = 2600 -- 基地总高度
BASE_BG_TW = 4200 -- 基地总宽度

XLB_WIDTH = 45 
XLB_HEIGHT = 65

local BuildGroup = require("app.layer.build.BuildGroup")
local BuildActionLayer = require("app.layer.build.BuildActionLayer")
local HeroTravel = require("app.layer.herotravel.HeroTravel")

local HomeBaseLayer = class("HomeBaseLayer", function( _nH )
	-- body
	local pScrollLayer = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, display.width, _nH),
    touchOnContent = false,
    direction=MUI.MScrollLayer.DIRECTION_BOTH,
    bothSize=cc.size(BASE_BG_TW, BASE_BG_TH),
    })
    pScrollLayer:setBounceable(false)
    --开启多点触摸
    pScrollLayer:setMultiTouch(true)
    return pScrollLayer
end)

function HomeBaseLayer:ctor(   )
	-- body
	self:myInit()
	self:setupViews()
	self:onResume()
	self:setDestroyCallback(handler(self, self.onHomeBaseLayerDestroy))
end

function HomeBaseLayer:myInit(  )
	-- body
	self.tAllBuildGroups  		= 		{} 		--基地所有建筑
	self.tAllSuburbGroups 		= 		{} 		--资源田建筑
	self.pBuildActionLayer 		= 		nil 	--建筑操作按钮层

	self.fMinScale 				= 		0.6      --基地最小缩放值
	self.fMaxScale 				= 		1        --基地最大缩放值
	self.nMaxBuildZorder 		= 		8888 	--建筑最大的层级值

	self.tWhiteClouds 			= 		{}      --白色的云
end

function HomeBaseLayer:setupViews( )
	-- body

	--设置最大，最小缩放比例
	self:setMinScale(self.fMinScale)
	self:setMaxScale(self.fMaxScale)
	-- 不要点击音效了
	-- self:setNeedClickSound(true)
	--设置移动速度
	self:setScrollSpeed(2500)

	self.pBaseContent 		= 		MUI.MLayer.new() 
	self.pBaseContent:setLayoutSize(BASE_BG_TW, BASE_BG_TH)
	self:addView(self.pBaseContent)

	-- 添加左边的地皮
	self.pImgLeft = MUI.MImage.new("ui/bg_base/bg_base_1.jpg")
	self.pImgLeft:setPosition(self.pImgLeft:getWidth() / 2, self.pImgLeft:getHeight() / 2)
	self.pBaseContent:addView(self.pImgLeft)
	-- -- 添加右边的地皮
	-- local pImgRight = MUI.MImage.new("ui/bg_base/bg_base_2.jpg")
	-- pImgRight:setPosition(self.pImgLeft:getWidth() + pImgRight:getWidth() / 2, pImgRight:getHeight() / 2)
	-- self.pBaseContent:addView(pImgRight)

	-- pImgRight:setCameraMask(3,true)


	--初始化基地建筑(原因是：世界相机问题)
	-- self:initBuildGroups()
	doDelayForSomething(self,function (  )
		-- body
		-- --初始化基地建筑(原因是：世界相机问题)
		self:initBuildGroups()
		self:addHeroTravel()
		--展示火焰特效
		self:showFireTx()
		--展示瀑布特效
		self:showWaterfallTx()
		--展示水龙头
		self:showSltTx()
		--展示水车
		self:showWaterCarTx()
		--展示水特效
		-- self:showWaterTx()
		--展示旗帜
		self:showFlagTx()
		--展示丹顶鹤
		self:showDDH()
		--展示白鹭
		self:showBaiLu()
		--展示乌云
		-- self:showBlackCloud()
		--展示巡逻兵
		self:showXLB()
		--展示鱼
		self:showFish()

		--展示瀑布5
		-- self:showWaterfallFive()

		--展示城门守卫
		self:showGuardTx(3)

		--展示白云动画
		self:showWhiteCloudTx()

		--巡逻兵提示语
		self:showXLBAutoTips()

	end,0.1)

	-- self:scrollTo(-450,-900,false)
	--设置基地场景的默认值
	local fDefaultScale = tonumber(getLocalInfo(Player:getPlayerInfo().pid .. "_homebasescale" ,self.fMinScale))
	
	self:setScrollBothScale(fDefaultScale,display.width / 2,(self:getHeight() / 2 + 800) , false)
	--设置ScrollLayer的初始缩放值
	self:setScale(1.4)



	--监听事件
	self:onScroll(function ( event )
		if event.name == "clicked" then
			local pointX = event.x
			local pointY = event.y
			local bIsHad = false
			if(self.tAllBuildGroups) then 
				for i, v in pairs(self.tAllBuildGroups) do
					local isTrue = v:hasClicked(pointX/self:getScrollBothScale(),
						pointY/self:getScrollBothScale())
					if(isTrue) then
						bIsHad = true
						break
					end
				end
			end
			--如果没有找到，资源田遍历
			if bIsHad == false then
				for i, v in pairs(self.tAllSuburbGroups) do
					local isTrue = v:hasClicked(pointX/self:getScrollBothScale(),
						pointY/self:getScrollBothScale())
					if(isTrue) then
						bIsHad = true
						break
					end
				end
			end

			if bIsHad == false then --没选到
				--隐藏操作按钮
				self:onHideActionBtn()
			end
			
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()

		elseif event.name == "moved" then
--			self:showSuburbNameState(true)
			--隐藏操作按钮
			self:onHideActionBtn()
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()

			if not self.bIsMoving then
				--发送消息隐藏冒泡
				local tObj = {}
				tObj.bHideBubble = true
				sendMsg(ghd_base_moving, tObj)
				self.bIsMoving = true 		 --记录一下正在移动的状态
			end
		elseif event.name == "began" then --开始
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()
		elseif event.name == "ended" then --结束
--			self:showSuburbNameState(false)
			--重置引导时间
			N_LAST_CLICK_TIME = getSystemTime()

			--发送消息把隐藏的冒泡显示出来
			local tObj = {}
			tObj.bHideBubble = false
			sendMsg(ghd_base_moving, tObj)
			self.bIsMoving = false 		 --移动结束
		end
    end)


	

	
end






function HomeBaseLayer:updateViews(  )
	-- body
end

function HomeBaseLayer:onHomeBaseLayerDestroy(  )
	-- body
	self:onPause()
	if self.nAddcheduler then
		MUI.scheduler.unscheduleGlobal(self.nAddcheduler)
		self.nAddcheduler = nil
	end
	if self.nAddcheduler2 then
		MUI.scheduler.unscheduleGlobal(self.nAddcheduler2)
		self.nAddcheduler2 = nil
	end

	self:stopBGSCheduler()
end

function HomeBaseLayer:regMsgs( )
	-- body
	-- 注册打开基地建筑操作按钮消息
	regMsg(self, ghd_show_build_actionbtn_msg, handler(self, self.onShowActionBtn))	
	-- 注册关闭基地建筑操作按钮消息
	regMsg(self,ghd_close_build_actionbtn_msg,handler(self, self.onHideActionBtn))
	-- 注册展示建筑解锁特效消息
	regMsg(self,ghd_show_tx_unlock_build_msg,handler(self, self.showUnLockBuildDownTx))
	-- 注册展示建筑解锁的消息（后台解锁）
	regMsg(self,ghd_show_unlock_build_background_msg,handler(self, self.showUnlockBuildBackgroud))
	-- 注册建筑解锁消息
	regMsg(self, ghd_unlock_build_msg, handler(self, self.showUnlockBuild))
	-- 注册基地缩放消息
	regMsg(self, ghd_scale_for_buildup_dlg_msg, handler(self, self.scaleActions))
	-- 注册移动到基地的消息
	regMsg(self, ghd_move_to_build_dlg_msg, handler(self, self.moveToBuild))
	-- 注册每日登录奖励领取的消息
	regMsg(self, gud_refresh_dayloginawards, handler(self, self.refreshDayLoginAwards))
	-- 注册建筑状态变化的消息
	regMsg(self, gud_build_state_change_msg, handler(self, self.refreshActionBtn))
	-- 注册资源田征收状态变化的消息
	regMsg(self, ghd_refresh_suburb_state_msg, handler(self, self.refreshActionBtn))
	-- 一键征收
	regMsg(self, ghd_refresh_suburb_state_mulit_msg, handler(self, self.refreshSubColState))	
	-- 注册消息移除一个buildgroup
	regMsg(self, ghd_remove_one_buildgroup_msg, handler(self, self.removeOnrBuildGroup))
	-- 注册Npc任务消息
	regMsg(self, gud_refresh_task_msg, handler(self, self.refreshOpenNpcTask))
	--对建筑升级任务引导
	regMsg(self, ghd_builds_task_guide_msg, handler(self, self.onBuildsTaskGuide))
	--位置引导
	regMsg(self, ghd_move_to_point_dlg_msg, handler(self, self.moveToPoint))
	--征收任务引导
	regMsg(self, ghd_collect_task_guide_msg, handler(self, self.moveToCollectedSuburb))
	--注册任务引导按钮引导操作
	regMsg(self, ghd_task_build_actionbtn_msg, handler(self, self.onTaskShowActionBtn))

	--注册刷新巡逻兵提示消息，当配表任务完成时候刷新
	
	regMsg(self, ghd_refresh_homebase_xlb_tips, handler(self, self.showXLBAutoTips))

end

function HomeBaseLayer:unregMsgs(  )

    unregMsg(self, ghd_refresh_homebase_xlb_tips)

	-- body
    unregMsg(self, ghd_show_build_actionbtn_msg)
    unregMsg(self, ghd_close_build_actionbtn_msg)
    unregMsg(self, ghd_show_tx_unlock_build_msg)
    unregMsg(self, ghd_show_unlock_build_background_msg)
    unregMsg(self, ghd_unlock_build_msg)
    unregMsg(self, ghd_scale_for_buildup_dlg_msg)
    unregMsg(self, ghd_move_to_build_dlg_msg)
    unregMsg(self, gud_refresh_dayloginawards)
    unregMsg(self, gud_build_state_change_msg)
    unregMsg(self, ghd_refresh_suburb_state_msg)
    unregMsg(self, ghd_remove_one_buildgroup_msg)    	
	unregMsg(self, gud_refresh_task_msg)
	unregMsg(self, ghd_builds_task_guide_msg)
	unregMsg(self, ghd_move_to_point_dlg_msg)
	unregMsg(self, ghd_collect_task_guide_msg)
	unregMsg(self, ghd_task_build_actionbtn_msg)
	unregMsg(self, ghd_refresh_suburb_state_mulit_msg)
end

--开启某些消息监听
function HomeBaseLayer:onResumePart( )
	if not self.nBGSCheduler then
		self.nResumeFrameIndex = 1

		self.nBGSCheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
			local pBuildGroup = nil
			if self.nResumeFrameIndex <= #self.tAllBuildGroups then
				pBuildGroup = self.tAllBuildGroups[self.nResumeFrameIndex]
			else
				local nIndex = self.nResumeFrameIndex - #self.tAllBuildGroups
				pBuildGroup = self.tAllSuburbGroups[nIndex]
			end
			self.nResumeFrameIndex = self.nResumeFrameIndex + 1
			if pBuildGroup then
				pBuildGroup:onResume()
			else
	            self:stopBGSCheduler()
	    	end
	    end, 1)
    end
end

--暂停某些消息监听
function HomeBaseLayer:onPausePart( )
	self:stopBGSCheduler()

	for k,v in pairs(self.tAllBuildGroups) do
		v:onPause()
	end
	for k,v in pairs(self.tAllSuburbGroups) do
		v:onPause()
	end
end

function HomeBaseLayer:stopBGSCheduler( )
	if self.nBGSCheduler then
		MUI.scheduler.unscheduleGlobal(self.nBGSCheduler)
	    self.nBGSCheduler = nil
	end
end


function HomeBaseLayer:onPause( )
	-- body
	
	self:unregMsgs()

	-- unregUpdateControl(self)
end

function HomeBaseLayer:onResume( )
	

	-- body
	self:updateViews()
	self:regMsgs()
end

--首次进基地基地缩放
function HomeBaseLayer:showScaleAtFirst(  )
	-- body
	--缩放基地
	self:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.2),
		cc.ScaleTo:create(0.68, 1.0),
		cc.CallFunc:create(function (  )
			self:setAnchorPoint(cc.p(0, 0))
			--执行登陆逻辑
			if Player:getPlayerInfo():getIsCountrySelected() then
				sendMsg(ghd_do_logined_logic)
			end
			Player.bRealyShowHome = true --标志已经完全展示homelayer了
		end)))
end

--初始化基地建
function HomeBaseLayer:initBuildGroups(  )
	-- body
	--加载基地建筑
	self:scheduleOnceAddBuildGroup(1,function (  )
		-- body
		--缩放基地
		-- self:showScaleAtFirst()
		-- sendMsg(ghd_open_yu_onhome_msg)

		-- 添加右边的地皮
		local pImgRight = MUI.MImage.new("ui/bg_base/bg_base_2.jpg")
		pImgRight:setPosition(self.pImgLeft:getWidth() + pImgRight:getWidth() / 2, pImgRight:getHeight() / 2)
		self.pBaseContent:addView(pImgRight)

		--更新loginlayer进度条
		updateLoginSlider(2,true)

		--没有资源田就马上执行
		local tDatas = Player:getBuildData():getSuburbBuilds() or {}
		if table.nums(tDatas) <= 0 then
			print("first end for add buildgrou!")
			-- self:runAction(cc.Sequence:create(
			-- 	cc.ScaleTo:create(0.68, 1.0),
			-- 	cc.CallFunc:create(function (  )
			-- 		self:setAnchorPoint(cc.p(0, 0))
			-- 	end)))
			--更新loginlayer进度条
			updateLoginSlider(3,true)
		else
			self:scheduleOnceAddBuildGroup(2,function (  )
				print("second end for add buildgrou!")
				--重置引导时间
				N_LAST_CLICK_TIME = getSystemTime()
				--更新loginlayer进度条
				updateLoginSlider(3,true)
			end)
		end
	end)
	-- 获得所有的建筑数据(基地建筑)
	-- local tAllBuilds = Player:getBuildData():getAllBuilds()
	-- if tAllBuilds and table.nums(tAllBuilds) > 0 then
	-- 	for k, v in pairs (tAllBuilds) do
	-- 		local pBuildGroup = BuildGroup.new(v)
	-- 		pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY())
	-- 		self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
	-- 		table.insert(self.tAllBuildGroups,pBuildGroup)
	-- 	end
	-- end

	--更新loginlayer进度条
	-- updateLoginSlider(2,true)

	-- --获得所有的郊外建筑数据（资源田）
	-- local tSuburbs = Player:getBuildData():getSuburbBuilds()
	-- if tSuburbs and table.nums(tSuburbs) > 0 then
	-- 	for k, v in pairs (tSuburbs) do
	-- 		local pBuildGroup = BuildGroup.new(v)
	-- 		pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY())
	-- 		self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
	-- 		table.insert(self.tAllSuburbGroups,pBuildGroup)
	-- 	end
	-- end
end


--_nType：1：城内建筑 2：资源田
--_handler：回调方法
function HomeBaseLayer:scheduleOnceAddBuildGroup(_nType, _handler)
    local nIndex = 1
    local tDatas = nil
    if _nType == 1 then
    	tDatas = Player:getBuildData():getAllBuilds() --城内建筑
    elseif _nType == 2 then
    	tDatas = Player:getBuildData():getSuburbBuilds() --资源田
    end
    if not tDatas or table.nums(tDatas) <= 0 then return end
    if _nType == 1 then
    	local nMax = table.nums(tDatas)
	    gRefreshViewsAsync(self, nMax, function (  _bEnd, _index  )
	    	if(not _bEnd) then
		    	local tKeys = table.keys(tDatas)
		    	local tBuildData = tDatas[tKeys[_index]]
		    	if tBuildData then
		    		local pBuildGroup = BuildGroup.new(tBuildData)
		    		if tBuildData.sTid == e_build_ids.gate  then --城门位置特殊处理
		    			
		    			pBuildGroup:setPosition(pBuildGroup:getPosX() - 18,pBuildGroup:getPosY() - 6)	
		    			
		    		else
		    			pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY())
		    		end
		    	
		    		self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
		    		-- ActionIn(pBuildGroup, "top", 0.10)
		    		table.insert(self.tAllBuildGroups,pBuildGroup)
		    		if (_index) % 3 == 0 then
		    			--更新loginlayer进度条
		    			updateLoginSlider(2,false)
		    		end
		    	end
		    else
		    	if _handler then
	            	_handler()
	            end
		    end
	    end, 2)
    else
	    gRefreshViewsAsync(self.pBaseContent, SUBBUILD_TOTAL_COUNT, function (  _bEnd, _index  )
	    	if(not _bEnd) then
		    	local tBuildData = tDatas[SUBBUILD_MINID+(_index-1)]
		    	if tBuildData then
		    		local pBuildGroup = BuildGroup.new(tBuildData)
		    		pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY())
		    		self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
		    		-- ActionIn(pBuildGroup, "top", 0.10)
		    		table.insert(self.tAllSuburbGroups,pBuildGroup)
		    	end
		    	if (_index) % 3 == 0 then
		    		--更新loginlayer进度条
		    		updateLoginSlider(3,false)
		    	end
		    else
		    	if _handler then
	            	_handler()
	            end
		    end
	    end, 2)
    end
    
end

--刷新建筑
function HomeBaseLayer:refreshBuildGroups(  )
	-- body
	if self.tAllBuildGroups and table.nums(self.tAllBuildGroups) > 0 then
		for k, v in pairs (self.tAllBuildGroups) do
			if v.refreshCurDatas then
				v:refreshCurDatas()
			end
		end
	end
	if self.tAllSuburbGroups and table.nums(self.tAllSuburbGroups) > 0 then
		for k, v in pairs (self.tAllSuburbGroups) do
			if v.refreshCurDatas then
				v:refreshCurDatas()
			end
		end
	end
	
end

--展示资源田名字状态
function HomeBaseLayer:showSuburbNameState( _bState )
	-- body
	if not b_open_scroll_hide_suburb then --不开启，直接返回
		return
	end
	if self.bSuburbState == _bState then
		return
	end
	self.bSuburbState = _bState
	if self.tAllSuburbGroups and table.nums(self.tAllSuburbGroups) > 0 then
		for k, v in pairs (self.tAllSuburbGroups) do
			v:setTopLayVisible(_bState)
		end
	end
end

--展示建筑解锁
function HomeBaseLayer:showUnlockBuild( sMsgName, pMsgObj )
	-- body
	if pMsgObj then

		local tData = pMsgObj.tData
		if tData and tData.tLists then
			local tObject = {} 
			tObject.nType = e_dlg_index.unlockbuild --dlg类型
			tObject.tBuildInfo = tData
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
	end
end

--后台解锁建筑
function HomeBaseLayer:showUnlockBuildBackgroud( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local tData = pMsgObj.tData
		if tData and tData.tLists then
			for k, v in pairs (tData.tLists) do
				local pBuildGroup = self:getBuildGroupByCell(v.nCellIndex)
				if not pBuildGroup then
					pBuildGroup = BuildGroup.new(v)
					pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY())
					self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
					--格子判断
					if v.nCellIndex > n_start_suburb_cell then --资源田
						table.insert(self.tAllSuburbGroups,pBuildGroup)
					else
						table.insert(self.tAllBuildGroups,pBuildGroup)
					end
				end
			end
		end
	end
end

--建筑解锁降落表现
function HomeBaseLayer:showUnLockBuildDownTx( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local tData = pMsgObj.tData
		if tData and tData.tLists then
			if table.nums(tData.tLists) > 1 then
				--解析数据
				local tNeedShow = {}
				for k, v in pairs (tData.tLists) do
					local pBuildGroup = self:getBuildGroupByCell(v.nCellIndex)
					if not pBuildGroup then
						pBuildGroup = BuildGroup.new(v)
						pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY() + 100)
						pBuildGroup:setOpacity(0)
						self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
						--格子判断
						if v.nCellIndex > n_start_suburb_cell then --资源田
							table.insert(self.tAllSuburbGroups,pBuildGroup)
						else
							table.insert(self.tAllBuildGroups,pBuildGroup)
						end
					end
					table.insert(tNeedShow, pBuildGroup)
				end
				--先移动
				local tPos = self:getPositionByCellForScale(tData.tLists[1].nCellIndex)
				if tPos then
					local tScreenPoint = self:adjustMovePoint(tPos)
					self:movePointToScreenPoint(tPos,tScreenPoint,true,function (  )
						-- body
						--展示表现
						self:showMulBuildTx(tNeedShow,1)
					end)
				end
			else
				local tBuildData = tData.tLists[1]
				if tBuildData then
					local pBuildGroup = self:getBuildGroupByCell(tBuildData.nCellIndex)
					if not pBuildGroup then 
						-- print("---------------------33333--------------")
						pBuildGroup = BuildGroup.new(tBuildData)	
						if tBuildData.bActivated == true then		--一般情况获取的资源建筑			
							pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY() + 100)
							pBuildGroup:setOpacity(0)
						else--资源建筑图纸关卡开启显示的未激活资源建筑
							pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY())
						end
						
						self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
						--格子判断
						if tBuildData.nCellIndex > n_start_suburb_cell then --资源田
							table.insert(self.tAllSuburbGroups,pBuildGroup)
						else
							table.insert(self.tAllBuildGroups,pBuildGroup)
						end
					else
						-- print("---------------------44444--------------")
						if tBuildData.nCellIndex > n_start_suburb_cell and tBuildData.bActivated == true then --资源田图纸激活的资源建筑
							pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY() + 100)
							pBuildGroup:setOpacity(0)
						end
					end
					--移动建筑到屏幕
					local tPos = self:getPositionByCellForScale(tBuildData.nCellIndex)
					if tPos then
						local tScreenPoint = self:adjustMovePoint(tPos)
						self:movePointToScreenPoint(tPos,tScreenPoint,true,function (  )
							-- body
							--展示表现
							self:showSingleBuildTx(pBuildGroup,function (  )
								-- body
								--单个表现结束,修改全局控制标志
								bShowingUnLockBuild = false
								--继续判断是否需要展示
								showUnlockBuildDlg()
							end)
						end)
					end
				end
			end
		end
	end
end

--展示单一的特效降落表现
--_pBuildGroup：表现的建筑
--_handler：回调事件
function HomeBaseLayer:showSingleBuildTx( _pBuildGroup, _handler )
	--城内建筑改为不降落表现，只出现升级表现
	local bIsShowUpTxOnly = false
	local tBuildInfo = _pBuildGroup:getCurData()
	if tBuildInfo then
		if tBuildInfo.sTid then
			local tNoBuildDict = {
				[e_build_ids.house] = true,
				[e_build_ids.wood] = true,
				[e_build_ids.farm] = true,
				[e_build_ids.iron] = true,
				[e_build_ids.shop] = true,
				[e_build_ids.jbp] = true,
				[e_build_ids.mbf] = true,
				[e_build_ids.jxg] = true,
			}
			if not tNoBuildDict[tBuildInfo.sTid] then
				bIsShowUpTxOnly = true								
			else
				if tBuildInfo.nCellIndex > n_start_suburb_cell and tBuildInfo.bActivated then --资源田已经激活则显示获取建筑的特效
					bIsShowUpTxOnly = false	
				else						
					bIsShowUpTxOnly = true
				end				
			end
		end
	end
	--只出现升级表现
	if bIsShowUpTxOnly then
		--播放升级特效
		_pBuildGroup:showBuildUpingTx()
		if _handler then
			_handler(_pBuildGroup)
		end
	else
		-- body
		local action1 = cc.FadeTo:create(0.17, 255)
		local action2 = cc.MoveBy:create(0.17, cc.p(0,-100))
		local actions = cc.Spawn:create(action1,action2)
		local actionEnd = cc.CallFunc:create(function (  )
			-- body
			--播放升级特效
			_pBuildGroup:showBuildUpingTx()
			if _handler then
				_handler(_pBuildGroup)
			end
		end)
		local allActions = cc.Sequence:create(actions,actionEnd)
		_pBuildGroup:runAction(allActions)
	end
end

--展示多个特效
--_pBuildGroups：需要解锁的建筑集合
--_nIndex：解锁建筑的顺序
function HomeBaseLayer:showMulBuildTx( _pBuildGroups, _nIndex )
	-- body
	local nSize = table.nums(_pBuildGroups)
	if _nIndex > nSize then
		--多个表现结束,修改全局控制标志
		bShowingUnLockBuild = false
		--继续判断是否需要展示
		showUnlockBuildDlg()
	else
		self:showSingleBuildTx(_pBuildGroups[_nIndex],function (  )
			-- body
			_nIndex = _nIndex + 1
			self:showMulBuildTx(_pBuildGroups,_nIndex)
		end)
	end
end

--展示建筑的操作按钮
function HomeBaseLayer:onShowActionBtn( sMsgName, pMsgObj  )
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell --建筑格子下标
		local nFromWhat = pMsgObj.nFromWhat or 0 --是否从左边对联点击
		local bHadChecked = pMsgObj.bHadChecked --是否已经校验了所有状态
		local bRefresh = pMsgObj.bHadChecked --是否是刷新按钮层（建筑数据或者状态发生变化）
		if bHadChecked then
			--获得建造buildgroup
			local pBuildGroup = self:getBuildGroupByCell(nCell)
			if pBuildGroup then
				self:showBuildActionLayer(pBuildGroup, nFromWhat)
			end
		else			
			local bAction = true
			
			if self.pBuildActionLayer 
				and self.pBuildActionLayer:getVisibleState() == true
				and self.pBuildActionLayer.nWhichCell 
				and self.pBuildActionLayer.nWhichCell == nCell then --在同一个建筑下
				bAction = false
			end
			if bRefresh then --如果是强制刷新按钮状态（建筑数据或者状态变化了）
				bAction = true --强制赋值为需要刷新
			end

			if bAction then
				--获得基地上的建筑buildgroup，然后模拟点击一下
				local pBuildGroup = self:getBuildGroupByCell(nCell)
				if pBuildGroup and pBuildGroup.onBuildClicked then
					pBuildGroup:onBuildClicked()
				end				
			else				
				self.pBuildActionLayer:bingNewGuideFinger(false)
				--隐藏手指
				-- sendMsg(ghd_guide_finger_show_or_hide, false)
				-- --不允许定位
				-- Player:getNewGuideMgr():setIsStopLocalUi(true)

				--显示手指
				sendMsg(ghd_guide_finger_show_or_hide, true)
				--允许定位
				Player:getNewGuideMgr():setIsStopLocalUi(false)
				--绑定手指Ui
				self.pBuildActionLayer:bingNewGuideFinger(true)
				
			end
		end
	end
end

--任务引导显示建筑按钮
function HomeBaseLayer:onTaskShowActionBtn( sMsgName, pMsgObj )
	-- body
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell --建筑格子下标
		local nEffBtnType = pMsgObj.nBtnType
		local pBuildGroup = self:getBuildGroupByCell(nCell)
		if pBuildGroup then
			if pBuildGroup.pBubbleLayer and pBuildGroup.pBubbleLayer:isVisible() then
				pBuildGroup:onBuildClicked()
				if pBuildGroup.tBuildInfo and pBuildGroup.tBuildInfo.nState == e_build_state.uping then
					return		
				end				
			end

			if self.pBuildActionLayer 
				and self.pBuildActionLayer:getVisibleState() == true
				and self.pBuildActionLayer.nWhichCell 
				and self.pBuildActionLayer.nWhichCell == nCell then --在同一个建筑下
				self.pBuildActionLayer:showBtnEffect(nEffBtnType)
				return
			end

			self:showBuildActionLayer(pBuildGroup, 0)
			if self.pBuildActionLayer then
				self.pBuildActionLayer:showBtnEffect(nEffBtnType)
			end
		end			
	end	
end

--隐藏操作按钮层
function HomeBaseLayer:onHideActionBtn( sMsgName, pMsgObj )
	-- body
	if self.pBuildActionLayer then
		self.pBuildActionLayer:setVisibleState(false)
		self.pBuildActionLayer:bingNewGuideFinger(false)
	end
end

--刷新按钮层
function HomeBaseLayer:refreshActionBtn( sMsgName, pMsgObj )
	-- body
	if self.pBuildActionLayer and self.pBuildActionLayer:getVisibleState() then --存在并且展示中
		local tBuildData = self.pBuildActionLayer:getCurData()
		if tBuildData then
			--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
			local tObject = {}
			tObject.bRefresh = true
			tObject.nCell = tBuildData.nCellIndex
			print("ghd_show_build_actionbtn_msg  33333333333333333333")
			sendMsg(ghd_show_build_actionbtn_msg,tObject)
		end
		-- self:onHideActionBtn()
	end
end

--刷新按钮层且播放征收资源
function HomeBaseLayer:refreshSubColState( sMsgName, pMsgObj )
	--刷新按钮层
	self:refreshActionBtn()

	if pMsgObj then
		--字典快速搜索
		local pBuildGroups = {}
		for k,pBuildGroup in pairs(self.tAllSuburbGroups) do
			if pBuildGroup.tBuildInfo and pBuildGroup.tBuildInfo.nCellIndex then
				pBuildGroups[pBuildGroup.tBuildInfo.nCellIndex] = pBuildGroup
			end
		end
		--分侦播放征收资源
		self.tLevyDatas = pMsgObj
		self.nLevyDataIndex = 1
		self.tPlayedMusic = {}
		local nAddCount = 4
		self.nAddcheduler2 = MUI.scheduler.scheduleUpdateGlobal(function (  )
			for i=1,nAddCount do
				local tData = self.tLevyDatas[self.nLevyDataIndex]
				if tData then
					local nCell = tData.nCell
					local pBuildGroup = pBuildGroups[nCell]
					if pBuildGroup then
						--记录播放过的音乐，达到每一个种只播放一次
						local bIsPlayMusic = false
						local tBuildInfo = pBuildGroup:getBuildInfo()
						if tBuildInfo then
							local nResId = tBuildInfo:getLevyResType()
							if not self.tPlayedMusic[nResId] then
								self.tPlayedMusic[nResId] = true
								bIsPlayMusic = true
							end
						end
						--播放效果
						pBuildGroup:refreshSubColState(sMsgName, tData, bIsPlayMusic)
					end
				else
					break
				end
				self.nLevyDataIndex = self.nLevyDataIndex + 1
			end
	    	if self ~= nil and self.nAddcheduler2 ~= nil and self.nLevyDataIndex > #self.tLevyDatas then
	            MUI.scheduler.unscheduleGlobal(self.nAddcheduler2)
	            self.nAddcheduler2 = nil
	    	end
	    end)
	end
end


--展示操作按钮层
--_nFromWhat：是否从左边对联点击
function HomeBaseLayer:showBuildActionLayer( _pBuildGroup, _nFromWhat )
	-- body
	if _pBuildGroup and _pBuildGroup.tBuildInfo and _pBuildGroup.tBuildInfo.bLocked == false then
		--获得按钮集合
		--科技院要特殊处理（科技院可以升级的同时研究科技）
		local tButtons = nil
		local bTnolyingUp = true
		if _pBuildGroup.tBuildInfo.sTid == e_build_ids.tnoly then
			if _pBuildGroup.tBuildInfo.nState == e_build_state.free then --空闲状态
				--先判断是否有研究中的科技
				local tCurTonly = Player:getTnolyData():getUpingTnoly()
				if tCurTonly then
					if tCurTonly:getUpingFinalLeftTime() > 0 then --生产状态中
						tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(e_build_state.producing)
						--判断是否有购买VIP5礼包和紫色研究学者正在雇佣中，那么保存升级按钮，否则的话，剥除升级按钮
						-- if not getIsCanTnolyUpingWithTecnologying() then
						--改成只需判断是否购买VIP5礼包
						local nvip = getArmyVipLvLimit(e_id_item.kjky)
						if not Player:getPlayerInfo():getIsBoughtVipGift(nvip) then
							bTnolyingUp = false
						end
					elseif tCurTonly:getUpingFinalLeftTime() <= 0 then --有科技研究结果
						tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(e_build_state.free)
					end
				else
					tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(_pBuildGroup.tBuildInfo.nState)
				end
			else
				tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(_pBuildGroup.tBuildInfo.nState)
			end
		elseif (_pBuildGroup.tBuildInfo.sTid == e_build_ids.infantry  --兵营
			or _pBuildGroup.tBuildInfo.sTid == e_build_ids.sowar  
			or _pBuildGroup.tBuildInfo.sTid == e_build_ids.archer) then

		    local tRecuitOk = _pBuildGroup.tBuildInfo:getRecruitedQue()
			if tRecuitOk and _pBuildGroup.tBuildInfo.nState == e_build_state.free then --募兵完成状态下不显示操作按钮
				tButtons = nil
			else
				tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(_pBuildGroup.tBuildInfo.nState)	
			end
		else
			tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(_pBuildGroup.tBuildInfo.nState)
		end
		if _pBuildGroup.tBuildInfo.sTid == e_build_ids.tjp then
			if _pBuildGroup.tBuildInfo.nState == e_build_state.free then --空闲状态
				--先判断铁匠铺有没有正在打造的装备
				local tMakeVo = Player:getEquipData():getMakeVo()
				if tMakeVo then
					tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(e_build_state.producing)
				end
			else
				tButtons = _pBuildGroup.tBuildInfo:getBuildActionBtnsByState(_pBuildGroup.tBuildInfo.nState)
			end
		end
		-- dump(tButtons, "tButtons ==")
		if tButtons then
			local nSize = table.nums(tButtons)
			--如果只有一个进入按钮，那么直接进入界面
			if nSize == 1 and tonumber(tButtons[1]) == 2 then
				_pBuildGroup:onEnterClicked()
				--隐藏操作按钮
				self:onHideActionBtn()
				return
			end
			--因为要处理满级情况，所以判断处理一下
			local tRealBtns = {}
			--判断是否满级
			if _pBuildGroup.tBuildInfo:isBuildMaxLv() then --满级了
				for k, v in pairs (tButtons) do
					if tonumber(v) ~= 1 then
						table.insert(tRealBtns, v)
					end
				end
			elseif bTnolyingUp == false then --不能有升级按钮（科技院特殊）
				for k, v in pairs (tButtons) do
					if tonumber(v) ~= 1 then
						table.insert(tRealBtns, v)
					end
				end
			else
				tRealBtns = tButtons
			end

			local nRealSize = table.nums(tRealBtns)
			--如果只有一个进入按钮，那么直接进入界面
			if nRealSize == 1 and tonumber(tRealBtns[1]) == 2 then
				_pBuildGroup:onEnterClicked()
				--隐藏操作按钮
				self:onHideActionBtn()
				return
			end


			--判断是否有拆除按钮
			if _pBuildGroup.tBuildInfo.nCellIndex > n_start_suburb_cell then --是资源田（有拆除按钮才需要判断，募兵府不需要判断）
				local nCell = _pBuildGroup.tBuildInfo.nCellIndex
				local tDBData = getSubBDatasFromDBByCell(nCell)
				local bCanRemoved = true
				if tDBData and tDBData.rebuild == 0 then --不能拆除
					bCanRemoved = false
				end

				if bCanRemoved then --如果可以拆除，判断科技“土地重建”是否解锁
					local tTnoly = Player:getTnolyData():getTnolyByIdFromAll(e_tnoly_ids.tdcj)
					if tTnoly then
						local bIsMaxLv = tTnoly:isMaxLv()
						bCanRemoved = bIsMaxLv
					end
				end
				if bCanRemoved == false then
					for i = nRealSize, 1, -1 do
						if tonumber(tRealBtns[i]) == 6 then
							tRealBtns[i] = nil
							break
						end
					end
				end

			end
			if tRealBtns == nil or table.nums(tRealBtns) <= 0 then
				print("没有多余按钮了")
				--隐藏操作按钮
				self:onHideActionBtn()
				return
			end

			--如果是募兵府先判断一下有没有改建成某种兵营募兵府, 没有就不弹二级菜单
			if _pBuildGroup.tBuildInfo.nCellIndex == e_build_cell.mbf and _pBuildGroup.tBuildInfo.nRecruitTp == nil then
				local tObject = {}
				tObject.nType = e_dlg_index.restructrecruit --dlg类型
				tObject.nRecruitTp = _pBuildGroup.tBuildInfo.nRecruitTp
				sendMsg(ghd_show_dlg_by_type, tObject)
				return
			end

			--超过两个按钮或者一个并且不是进入按钮（需要展示按钮操作层）
			if not self.pBuildActionLayer then
				self.pBuildActionLayer = BuildActionLayer.new()
				self.pBaseContent:addView(self.pBuildActionLayer,self.nMaxBuildZorder)
			end
			
			--标志位于哪个建筑的格子下标
			self.pBuildActionLayer.nWhichCell = _pBuildGroup.tBuildInfo.nCellIndex
			--获得宽高
			local nWidth = self.pBuildActionLayer:getWidth()
			local nHeight = self.pBuildActionLayer:getHeight()
			--设置位置
			local nPosX = _pBuildGroup:getPosX() + _pBuildGroup:getWidth() * _pBuildGroup.tShowData.fDzRw - nWidth / 2
			local nPosY = _pBuildGroup:getPosY() + _pBuildGroup:getHeight() * _pBuildGroup.tShowData.fDzRh - nHeight / 2
			if  _pBuildGroup.tBuildInfo.sTid == e_build_ids.palace then --王宫
				nPosX = nPosX - 100
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.store then --仓库
				nPosX = nPosX - 20
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.tnoly then --科学院
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.infantry then --步兵营
				nPosX = nPosX - 40
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.sowar then --骑兵营
				nPosX = nPosX - 14
				nPosY = nPosY - 10
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.archer then --弓兵营
				nPosX = nPosX - 30
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.mbf then --募兵府
				if _pBuildGroup.tBuildInfo.nRecruitTp == e_mbf_camp_type.infantry then
					nPosX = nPosX - 40
				elseif _pBuildGroup.tBuildInfo.nRecruitTp == e_mbf_camp_type.sowar then
					nPosX = nPosX - 40
					nPosY = nPosY - 10
				elseif _pBuildGroup.tBuildInfo.nRecruitTp == e_mbf_camp_type.archer then
					nPosX = nPosX - 30
				end
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.atelier then --作坊
				nPosX = nPosX - 10
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.tjp then --铁匠铺
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.ylp then --冶炼铺
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.jxg then --将军府
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.tcf then --统帅府
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.jbp then --珍宝阁
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.bjt then --拜将台
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.house then --民居
				nPosX = nPosX - 10
				nPosY = nPosY - 20
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.wood then --木场
				nPosY = nPosY - 20
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.farm then --农田
				nPosX = nPosX - 10
				nPosY = nPosY - 20
			elseif  _pBuildGroup.tBuildInfo.sTid == e_build_ids.iron then --铁矿
				nPosY = nPosY - 20
			elseif _pBuildGroup.tBuildInfo.sTid == e_build_ids.gate then --如果是城门，需要再低一点
				nPosY = nPosY - 75
			end

			self.pBuildActionLayer:setPosition(nPosX, nPosY)
			--先隐藏起来（一定要先隐藏在设置数据）
			self.pBuildActionLayer:setVisibleState(false)
			--设置数据
			self.pBuildActionLayer:setCurData( _pBuildGroup.tBuildInfo,tRealBtns, _nFromWhat)
			
			self.pBuildActionLayer:bingNewGuideFinger(false)

			--坐标转化（判断是否需要移动）
			local tCurPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(
				self.pBuildActionLayer:convertToWorldSpace(cc.p(0, 0)))
			local tRetPos = RootLayerHelper:getCurRootLayer():convertToNodeSpace(
				self:convertToWorldSpace(cc.p(0, 0)))
			local tRstPos = cc.p((tCurPos.x - tRetPos.x), (tCurPos.y - tRetPos.y))

			--计算是否被屏幕挡住
			local gOrX = self.scrollNode:getPositionX() --当前屏幕左下角坐标
			local gOrY = self.scrollNode:getPositionY() --当前屏幕左下角坐标
			local fXDis = 0 --x方向需要移动的距离
			local fYDis = 0 --y方向需要移动的距离
			local bNeedMove = false --是否需要移动

			--圆环超出底图的一半宽度
			local fWidthMore = self.pBuildActionLayer:getYHImg():getWidth() * self.pBuildActionLayer:getYHImg():getScale() * self:getScrollBothScale() / 2
			 - self.pBuildActionLayer:getWidth() *  self:getScrollBothScale() / 2
			--底图宽度 
			local fWidthBg = self.pBuildActionLayer:getWidth() *  self:getScrollBothScale()
			--x轴判断
			if tRstPos.x - fWidthMore < 0 then
				bNeedMove = true --需要移动
				fXDis = math.abs(tRstPos.x - fWidthMore) 
			elseif (tRstPos.x + fWidthBg + fWidthMore > 600) then
				bNeedMove = true --需要移动
				fXDis = math.abs(tRstPos.x + fWidthBg + fWidthMore - 600) * -1
			end
			--y轴判断
			if tRstPos.y - 150 < 0  then
				bNeedMove = true --需要移动
				fYDis = math.abs(tRstPos.y - 150) 
			end

			if bNeedMove then
				--边界判断
				local fScrollX = gOrX + fXDis
				local fScrollY = gOrY + fYDis
				if fScrollX > 0 then
					fScrollX = 0
				end
				if fScrollY > 0 then
					fScrollY = 0
				end
				--最小值
				local nMinX = display.width - self.pBaseContent:getWidth() * self:getScrollBothScale()
				if fScrollX < nMinX then
					fScrollX = nMinX 
				end
				--隐藏手指
				sendMsg(ghd_guide_finger_show_or_hide, false)
				--不允许定位
				Player:getNewGuideMgr():setIsStopLocalUi(true)
				--地图移动
				self:scrollTo( fScrollX, fScrollY,true,function (  )
					self.pBuildActionLayer:setVisibleState(true)
					ActionIn(self.pBuildActionLayer,"pop",0.15, function (  )
						--显示手指
						sendMsg(ghd_guide_finger_show_or_hide, true)
						--允许定位
						Player:getNewGuideMgr():setIsStopLocalUi(false)
						--绑定手指Ui
						self.pBuildActionLayer:bingNewGuideFinger(true)
					end)
				end)
			else
				--隐藏手指
				sendMsg(ghd_guide_finger_show_or_hide, false)
				--不允许定位
				Player:getNewGuideMgr():setIsStopLocalUi(true)
				self.pBuildActionLayer:setVisibleState(true)
				--地图移动
				ActionIn(self.pBuildActionLayer,"pop",0.15, function()
					--显示手指
					sendMsg(ghd_guide_finger_show_or_hide, true)
					--允许定位
					Player:getNewGuideMgr():setIsStopLocalUi(false)
					--绑定手指Ui
					 self.pBuildActionLayer:bingNewGuideFinger(true)
				end)
			end
			
		end

	end
end

--通过建筑格子下标获得buildgroup
function HomeBaseLayer:getBuildGroupByCell( _nCell )
	if not _nCell then
		print("HomeBaseLayer:getBuildGroupByCell _nCell = nil")
		return
	end
	-- body
	local pBuildGroup = nil
	if _nCell > n_start_suburb_cell then --郊外资源
		if self.tAllSuburbGroups and table.nums(self.tAllSuburbGroups) > 0 then
			for k, v in pairs (self.tAllSuburbGroups) do
				if v.tBuildInfo and v.tBuildInfo.nCellIndex == _nCell then
					pBuildGroup = v
					break
				end
			end
		end
	else
		if self.tAllBuildGroups and table.nums(self.tAllBuildGroups) > 0 then
			for k, v in pairs (self.tAllBuildGroups) do
				if v.tBuildInfo and v.tBuildInfo.nCellIndex == _nCell then
					pBuildGroup = v
					break
				end
			end
		end
	end
	return pBuildGroup
end

--获得移动建筑的坐标
function HomeBaseLayer:getPositionByCellForScale( _nCell )
	-- body
	local tPos = nil
	if _nCell > n_start_suburb_cell then --郊外资源
		if self.tAllSuburbGroups and table.nums(self.tAllSuburbGroups) > 0 then
			for k, v in pairs (self.tAllSuburbGroups) do
				if v.tBuildInfo and v.tBuildInfo.nCellIndex == _nCell then
					local nX = (v:getPositionX() + v:getWidth() / 2) * self:getScrollBothScale()
					local nY = (v:getPositionY() + v:getHeight() / 2) * self:getScrollBothScale()
					tPos = cc.p(nX,nY)
					break
				end
			end
		end
	else
		if self.tAllBuildGroups and table.nums(self.tAllBuildGroups) > 0 then
			for k, v in pairs (self.tAllBuildGroups) do
				if v.tBuildInfo and v.tBuildInfo.nCellIndex == _nCell then
					local nX = (v:getPositionX() + v:getWidth() / 2) * self:getScrollBothScale()
					local nY = (v:getPositionY() + v:getHeight() / 2) * self:getScrollBothScale()
					tPos = cc.p(nX,nY)
					break
				end
			end
		end
	end
	
	return tPos
end

--基地缩放消息回调
function HomeBaseLayer:scaleActions( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nType = pMsgObj.nType
		
		if nType == 1 then --放大
			local nCell = pMsgObj.nCell
			if nCell then
				local tPos = self:getPositionByCellForScale(nCell)
				--当前做下角坐标
				local tLBPos = self:getOriginPoision()
				if tPos and tLBPos then
					--保存旧的坐标
					self.tOld = cc.p(tLBPos.x,tLBPos.y)
					--保存旧的缩放值
					self.fOldScale = self:getScrollBothScale()
					if self.tOld then
						local tScreenPoint = cc.p(display.width / 4,display.height / 5 * 4)
						self:movePointToScreenPoint(tPos,tScreenPoint,nil,nil,false) --不判断边界
						-- self:setScrollBothScale(self.fMaxScale,display.width / 4,display.height / 5 * 4)
						self:setAnchorPoint(cc.p(1 / 4, 4 / 5))
						self:ignoreAnchorPointForPosition(true)
						self:runAction(cc.Sequence:create(
							cc.ScaleTo:create(0.3, 1.4),
							cc.CallFunc:create(function (  )
								--self:setAnchorPoint(cc.p(0, 0))
							end)))
					end
				end
			end
		elseif nType == 2 then --缩小
			if pMsgObj.nChildType == 1 then --正常情况下
				if self.tOld then
					--隐藏手指
					sendMsg(ghd_guide_finger_show_or_hide, false)
					--不允许定位
					Player:getNewGuideMgr():setIsStopLocalUi(true)

					self.fOldScale = self.fOldScale or 1
					self:scrollTo(self.tOld.x,self.tOld.y,false, function (  )
						self:setAnchorPoint(cc.p(1 / 4, 4 / 5))
						self:ignoreAnchorPointForPosition(true)
						self:runAction(cc.Sequence:create(
							--cc.DelayTime:create(0.2),
							cc.ScaleTo:create(0.3, 1.0),
							cc.CallFunc:create(function (  )
								self:setAnchorPoint(cc.p(0, 0))

								--显示手指
								sendMsg(ghd_guide_finger_show_or_hide, true)
								--允许定位
								Player:getNewGuideMgr():setIsStopLocalUi(false)
							end)))
					end)
					self.tOld = nil

					-- self:setScrollBothScale(self.fOldScale,display.width / 4,display.height / 5 * 4,false)
					-- self:scrollTo(self.tOld.x,self.tOld.y,true, function (  )
					-- 	--继续新手
					-- 	Player:getNewGuideMgr():showNewGuideAgain()
					-- end)
					-- self.tOld = nil
				end
			elseif pMsgObj.nChildType == 2 then --跳转到王宫界面
				self.tOld = nil
				self.fOldScale = self.fOldScale or 1
				-- self:setScrollBothScale(self.fOldScale,display.width / 4,display.height / 5 * 4,false)
				self:setAnchorPoint(cc.p(1 / 4, 4 / 5))
				self:ignoreAnchorPointForPosition(true)
				self:runAction(cc.Sequence:create(
					--cc.DelayTime:create(0.2),
					cc.ScaleTo:create(0.3, 1.0),
					cc.CallFunc:create(function (  )
						self:setAnchorPoint(cc.p(0, 0))
						
					end)))

				--移动到屏幕中点
				local tOb = {}
				tOb.nCell = e_build_cell.palace
				tOb.nFunc = function (  )
					-- body
					--模拟执行一次点击行为
					--发送消息关闭除了自身以外有打开的操作按钮，并且打开自身
					local tObject = {}
					tObject.nCell = e_build_cell.palace
					print("ghd_show_build_actionbtn_msg  4444444444444444444444")
					sendMsg(ghd_show_build_actionbtn_msg,tObject)
				end
				sendMsg(ghd_move_to_build_dlg_msg, tOb)
				
			end
			
			
		end
	end
end

--强制创建一个建筑出来（为了防止主线建筑解锁流程出现异常，不能成功展示建筑出来，新手引导走不下去）
--_nCell：建筑下标
function HomeBaseLayer:forceToShowABuild( _nCell )
	-- body
	if not _nCell then return end
	--格子判断
	local tBuildInfo = nil
	if _nCell > n_start_suburb_cell then --资源田
		tBuildInfo = Player:getBuildData():getSuburbByCell(_nCell)
	else
		tBuildInfo = Player:getBuildData():getBuildByCell(_nCell)
	end

	if tBuildInfo then --如果存在建筑数据了，需要建造出来.....
		local pBuildGroup = self:getBuildGroupByCell(tBuildInfo.nCellIndex)
		if not pBuildGroup then
			pBuildGroup = BuildGroup.new(tBuildInfo)
			pBuildGroup:setPosition(pBuildGroup:getPosX(),pBuildGroup:getPosY())
			self.pBaseContent:addView(pBuildGroup,self.nMaxBuildZorder - pBuildGroup:getPosY())
			--格子判断
			if tBuildInfo.nCellIndex > n_start_suburb_cell then --资源田
				table.insert(self.tAllSuburbGroups,pBuildGroup)
			else
				table.insert(self.tAllBuildGroups,pBuildGroup)
			end
		end
	end
end

---移动到基地
function HomeBaseLayer:moveToBuild( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell
		local nEndScrollCallBack = pMsgObj.nFunc
		if nCell then
			local tPos = self:getPositionByCellForScale(nCell)
			if tPos then
				local tScreenPoint = self:adjustMovePoint(tPos)
				if nCell == e_build_cell.palace then
					tScreenPoint.y = tScreenPoint.y + 100
				end
				if nEndScrollCallBack then
					self:movePointToScreenPoint(tPos,tScreenPoint,true,function (  )
						-- body
						nEndScrollCallBack()
					end,true)
				else
					if pMsgObj.bShowFinger then
						local pBuild
						for k, v in pairs (self.tAllBuildGroups) do
							if v.tBuildInfo and v.tBuildInfo.nCellIndex == nCell then
								pBuild = v
							end
						end
						if pBuild then
							self:movePointToScreenPoint(tPos,tScreenPoint,true,function (  )
								-- body
								local pos
								if nCell == e_build_cell.tnoly then
									pos = cc.p(-pBuild:getWidth()/13, -pBuild:getHeight()/5)
								else
									pos = cc.p(-pBuild:getWidth()/10, -pBuild:getHeight()/5)
								end
								showTaskFinger(pBuild, 1, pos)
							end,true)
							self:performWithDelay(function ()
								closeDlgByType(e_dlg_index.dlgtaskfinger)
							end, 2)
						end
					else
						self:movePointToScreenPoint(tPos,tScreenPoint)
					end
				end
			else
				--再次判断一下是否存在建筑本地的数据（如果出现异常，建筑有可能没有建造出来）
				self:forceToShowABuild(nCell)
			end
		end
	end
end

--移动到指定位置
function HomeBaseLayer:moveToPoint( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell
		local nBuildId = pMsgObj.nBuildId
		if nCell then
			local tShowData = getBuildGroupShowDataByCell(nCell, nBuildId)
			local nX = (tShowData.x + tShowData.w/2) * self:getScrollBothScale()
			local nY = (tShowData.y + tShowData.h/2) * self:getScrollBothScale()
			local tPos = cc.p(nX,nY)			
			if tPos then
				local tScreenPoint = self:adjustMovePoint(tPos)
				self:movePointToScreenPoint(tPos,tScreenPoint)
			end
		end
	end
end
--适配移动位置
function HomeBaseLayer:adjustMovePoint( tpos )
	-- body
	local nWidth = self:getWidth()
	local nHeight = self:getHeight()
	local nX = nWidth / 2
	local nY = nHeight / 2 	
	local screenpos = cc.p(nX, nY)
	return screenpos
end

--刷新每日登录奖励显示与否
function HomeBaseLayer:refreshDayLoginAwards()
	local bIsShow = Player:getDayLoginData():isHasDayLoginAwards()
	--如果有奖励可领取,则显示领取图标
	if bIsShow then
		if not self.pLayDayLogAwd then
			self.pLayDayLogAwd = MUI.MLayer.new()
			self.pLayDayLogAwd:setLayoutSize(80, 88)
			self.pBaseContent:addView(self.pLayDayLogAwd, 999)
			local nX = 1270 - 40
			local nY = 1222 - 44
			self.pLayDayLogAwd:setPosition(cc.p(nX, nY))

			local nX = self.pLayDayLogAwd:getWidth() / 2
			local nY = self.pLayDayLogAwd:getHeight() / 2

			local pImgDi = MUI.MImage.new("#v1_img_zjm_wzqph.png")
			self.pLayDayLogAwd:addView(pImgDi)
			pImgDi:setPosition(cc.p(nX, nY))

			local pImgDayLogAwd = MUI.MImage.new("#v1_img_guojia_renwubaoxiang1.png")
			pImgDayLogAwd:setScale(0.8)
			self.pLayDayLogAwd:addView(pImgDayLogAwd)
			pImgDayLogAwd:setPosition(cc.p(nX, nY))
		end
		self.pLayDayLogAwd:setVisible(true)
		self.pLayDayLogAwd:setViewTouched(true)
		self.pLayDayLogAwd:onMViewClicked(function()
			local tObject = {}
			tObject.nType = e_dlg_index.dayloginawards 
			sendMsg(ghd_show_dlg_by_type,tObject)
		end)
		self.pLayDayLogAwd:setScale(1)
		--缩放效果
		showScaleQiPao(self.pLayDayLogAwd)
		--黄色光圈特效
		showYellowRing(self.pLayDayLogAwd)
	else
		if self.pLayDayLogAwd then
			self.pLayDayLogAwd:setVisible(false)
			self.pLayDayLogAwd:stopAllActions()
			self.pLayDayLogAwd:setScale(1)
		end
	end
end
--刷新Npc任务
function HomeBaseLayer:refreshOpenNpcTask()
	-- body
	local tNTaskData = Player:getPlayerTaskInfo():getOpenedNpcTask()	
	if tNTaskData then
		local tparam = luaSplit(tNTaskData.sLinked, ":")		
		if not tparam[2] then
			return
		end		
		local tshowData = getBuildGroupShowDataByCell(tonumber(tparam[2]), e_build_ids.house)
		if not tshowData  then
			return
		end	
		if not self.pLayTaskLayer then
			local TaskNpcLayer = require("app.layer.task.TaskNpcLayer")
			self.pLayTaskLayer = TaskNpcLayer.new()
			self.pBaseContent:addView(self.pLayTaskLayer, self.nMaxBuildZorder + 1)
			local nX = tshowData.x + tshowData.w/2 - self.pLayTaskLayer:getWidth()/2
			local nY = tshowData.y + tshowData.h/2 - self.pLayTaskLayer:getHeight()/2
			self.pLayTaskLayer:setPosition(cc.p(nX, nY))	
			if not self.pTx then
				self.pTx = getCircleWhirl(0.4)
			    self.pBaseContent:addView(self.pTx, self.nMaxBuildZorder)
			    --self.pTx:setPosition(cc.p(nX + self.pLayTaskLayer:getWidth()/2, nY + self.pLayTaskLayer:getHeight()/2))
			    self.pTx:setPosition(cc.p(nX + self.pLayTaskLayer:getWidth()/2, nY))
			end
			self.pTx:setVisible(true)
		end
		self.pLayTaskLayer:setVisible(true)
		self.pLayTaskLayer:setViewTouched(true)		
		--self.pLayTaskLayer:setScale(1.5)
		self.pLayTaskLayer:setTaskId(tNTaskData.sTid)
		showScaleQiPao(self.pLayTaskLayer)


		--新手引导
		Player:getNewGuideMgr():setNewGuideFinger(self.pLayTaskLayer, e_guide_finer.house3_army_btn)
	else
		if self.pLayTaskLayer then
			self.pLayTaskLayer:setVisible(false)
			self.pLayTaskLayer:stopAllActions()
			if self.pTx then
				self.pTx:setVisible(false)
			end
			--新手引导
			-- Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.house3_army_btn)
		end
	end
end
function HomeBaseLayer:onUpdateCloud( )
	self.nCloudIndex = self.nCloudIndex + 1

	if self.nCloudIndex >= 60 then
		self.nCloudIndex = 1
		self:showTopCloud()
		-- self:showBottomCloud()
		-- self:showMiddleCloud()
	end
end

--主界面白云动画
function HomeBaseLayer:showWhiteCloudTx(  )

	--白云动画分三层，一共七朵，最上面的三朵，中间三朵，下面一朵 最上面的云不需要影子，其余的都需要影子

	local tImg = {{"sg_zjm_yun_x_l_03","sg_zjm_yun_x_l_04","sg_zjm_yun_x_l_05"},
				  {"sg_zjm_yun_x_l_01","sg_zjm_yun_x_l_02","sg_zjm_yun_x_l_05"},
				  {"sg_zjm_yun_x_l_02","sg_zjm_yun_x_l_02","sg_zjm_yun_x_l_02"}
				}

	self:showTopCloud()
	-- self:showBottomCloud()
	-- self:showMiddleCloud()
	-- self.nCloudIndex = 1

	-- regUpdateControl(self, handler(self, self.onUpdateCloud))


end


function HomeBaseLayer:showOneCloud(_nType)
	_nType = _nType or 1
	local pCloud = self:createOneCloud(1,"46_".._nType)
	local nTime = math.random(0,30)
	local nPosX = math.random(-200,3000)
	local nPosY = 0
	if _nType == 1 then
		nPosY = math.random(2000,2400)
	elseif _nType == 2 or _nType == 3 then
		nPosY = math.random(2120,2500)
	-- elseif i ==3 then
	-- 	nPosY = math.random(2120,2500)
	end
	

	if self.tTopCloud[_nType] == nil  then
		self.tTopCloud[_nType] = 1
		
	else
		
		self.tTopCloud[_nType] = self.tTopCloud[_nType] + 1
		if self.tTopCloud[_nType] % 2 == 1  then
			self.tTopCloud[_nType] = 1
		end
	end
	if self.tTopCloud[_nType] % 2 == 0  then
		pCloud:setFlippedX(true)
	elseif self.tTopCloud[_nType] % 2 == 1 then
		pCloud:setFlippedX(false)
	end
	pCloud:setPosition(cc.p(nPosX,nPosY))
	pCloud:performWithDelay(function ()
			local nShowTime = math.random(40,70)
			pCloud:setFrameEventCallFunc(function ( _ncur )
				if _ncur == 24*nShowTime then
					self:showOneCloud(_nType)
				end
			end)
		pCloud:play(1)
	end,nTime)


end



--显示最上面白云
function HomeBaseLayer:showTopCloud()
	--[[
		图片"sg_zjm_yun_x_l_03","sg_zjm_yun_x_l_04","sg_zjm_yun_x_l_05". 
		需要在Y轴(1800，2500）X轴（-200，3000）区间随机，每块云45秒出现一次。
		第一次出现正面。第二次出现需要将图片Y水平翻转。
	]]--
	local tImg = {"sg_zjm_yun_x_l_03","sg_zjm_yun_x_l_04","sg_zjm_yun_x_l_05"}
	
	for i=1,3 do
		
	
		local nRandom = math.random(1,3)
		local nTopTime = math.random(0,30)
		if self.tTopCloud == nil then
			self.tTopCloud = {}
		end
		local nPosX = math.random(-500,2500)
		local nPosY = 0
		if i == 1 then
			nPosY = math.random(2000,2400)
		elseif i == 2 or i == 3 then
			nPosY = math.random(2120,2500)
		-- elseif i ==3 then
		-- 	nPosY = math.random(2120,2500)
		end
		
		
		if self.tTopCloud[i] == nil  then
			self.tTopCloud[i] = 1
			
		else
			
			self.tTopCloud[i] = self.tTopCloud[i] + 1
			if self.tTopCloud[i] % 2 == 1  then
				self.tTopCloud[i] = 1
			end
		end
		
		local pTopCloud = self:createOneCloud(1,"46_"..i)
		
		if self.tTopCloud[i] % 2 == 0  then
			pTopCloud:setFlippedX(true)
		elseif self.tTopCloud[i] % 2 == 1 then
			pTopCloud:setFlippedX(false)
		end
		
		pTopCloud:setPosition(cc.p(nPosX,nPosY))
		pTopCloud:performWithDelay(function ()
			local nShowTime = math.random(40,70)  -- 45加减15s
				
			pTopCloud:setFrameEventCallFunc(function ( _ncur )
				
				if _ncur == 24*nShowTime then
					
					self:showOneCloud(i)
				end
			end)
			pTopCloud:play(1)
				
		
			
		end,nTopTime)
			
	end

	
end


--显示中间白云 
function HomeBaseLayer:showMiddleCloud()
	--[[
		图片"sg_zjm_yun_x_l_01","sg_zjm_yun_x_l_02","sg_zjm_yun_x_l_05". 
		需要在Y轴(1300，2100）X轴（-200，3000）区间随机，每块云45秒出现一次。
		第一次出现正面。第二次出现需要将图片Y水平翻转。
	]]--
	local tImg = {"sg_zjm_yun_x_l_01","sg_zjm_yun_x_l_02","sg_zjm_yun_x_l_05"}
	
	for i=1,3 do
		local nRandom = math.random(1,3)
		local nMiddleTime = math.random(0,45)
		local nPosX = math.random(-200,3000)
		local nPosY = math.random(1300,2100)
		if self.tMidCloud == nil then
			self.tMidCloud = {}
		end
		if self.tMidCloud[tImg[nRandom]] == nil  then
			self.tMidCloud[tImg[nRandom]] = 1
		else
			self.tMidCloud[tImg[nRandom]] = self.tMidCloud[tImg[nRandom]] + 1
			if self.tMidCloud[tImg[nRandom]] % 2 == 1  then
				self.tMidCloud[tImg[nRandom]] = 1
			end
		end
		local pCloud = self:createOneCloud(1,tImg[nRandom])
		local pShadow = self:createOneCloud(2,tImg[nRandom])
		pShadow:runAction(cc.TintTo:create(1, 1, 1, 1))
		pCloud:performWithDelay(function (  )
		
			if pCloud then
				pCloud:setPosition(cc.p(nPosX,nPosY))
			
				if self.tMidCloud[tImg[nRandom]]  % 2 == 1 then
				
					pCloud:setFlippedX(false)
					pShadow:setFlippedX(false)
				elseif self.tMidCloud[tImg[nRandom]]  % 2 == 0 then
				
					pCloud:setFlippedX(true)
					pShadow:setFlippedX(true)
				end
				
				pCloud:play(1)
				pShadow:play(1)
			end
			
		end,nMiddleTime)
	end

end

--显示底层白云 
function HomeBaseLayer:showBottomCloud()
	--[[
		图片"sg_zjm_yun_x_l_02". 
		需要在Y轴(500，1300）X轴（-200，3000）区间随机，每块云45秒出现一次。
		第一次出现正面。第二次出现需要将图片Y水平翻转。
	]]--
	local sBtm = "sg_zjm_yun_x_l_02"
	
	
	local nPosX = math.random(-200,3000)
	local nPosY = math.random(500,1300)
	local nTime = math.random(0,45)

	if self.pBtmCloud == nil then
		self.pBtmCloud = {}
	end
	if self.pBtmCloud[sBtm] == nil then
		self.pBtmCloud[sBtm] = 1

	else
		self.pBtmCloud[sBtm] =  self.pBtmCloud[sBtm]  + 1
		if self.pBtmCloud[sBtm] % 2 == 1 then
			self.pBtmCloud[sBtm] = 1
		end

	end
	-- if self.tDownCloud and table.nums(self.tDownCloud) > 0
	local pCloud = self:createOneCloud(1,sBtm)
	local pShadow = self:createOneCloud(2,sBtm)
	pShadow:runAction(cc.TintTo:create(0.01, 1, 0, 0))
	-- pCloud:runAction(cc.TintTo:create(0.01, 1, 0, 0))
	-- print("---nTime---bottom----",nTime,self.pBtmCloud[sBtm] )
	pCloud:performWithDelay(function (  )
		
		if pCloud then
			
			pCloud:setPosition(cc.p(nPosX,nPosY))
		
			if self.pBtmCloud[sBtm]  % 2 == 1 then
				pShadow:setFlippedX(false)
				pCloud:setFlippedX(false)
			elseif self.pBtmCloud[sBtm]  % 2 == 0 then
				
				pShadow:setFlippedX(true)
				pCloud:setFlippedX(true)
			end
			
			pCloud:play(1)
			pShadow:play(1)
		end
		
	end,1)

	
end

--创建一块云
--_nType 1.白云 2.黑云
function HomeBaseLayer:createOneCloud(_nType,sName)
	local pArm = nil 
	if _nType == 1 then
		if self.tWhiteClouds and table.nums(self.tWhiteClouds) > 0 then
			local nSize = table.nums(self.tWhiteClouds)
			pArm = self.tWhiteClouds[nSize]
			self.tWhiteClouds[nSize] = nil
		else
			pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas[sName],
			self.pBaseContent,
			9992,
			cc.p(self.pBaseContent:getWidth() / 2,self.pBaseContent:getHeight() / 2),
			function ( _pArm )
				-- _pArm = nil 
				--保存下来
				table.insert(self.tWhiteClouds, 1, _pArm)
			end, Scene_arm_type.base)
		end
	elseif _nType == 2 then
		pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["46_2"],
			self.pBaseContent,
			9992,
			cc.p(self.pBaseContent:getWidth() / 2,self.pBaseContent:getHeight() / 2),
			function ( _pArm )
				_pArm = nil 
			end, Scene_arm_type.base)

	end
	
	-- if pArm then
	-- 	print("11111111111111cloud")
	-- 	pArm:play(1)
	-- end
	return pArm
end

--主界面火焰
function HomeBaseLayer:showFireTx(  )
	-- body
	local tT = {}
	tT["1"] = cc.p(1788, 845)
	tT["2"] = cc.p(2063, 981)
	tT["3"] = cc.p(0, 0)
	tT["4"] = cc.p(1024, 1455)

	--第4个旗帜
	local pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["9"], 
		self.pBaseContent, 
		10, 
		tT["4"],
	    function ( _pArm )

	    end, Scene_arm_type.base)
	if pArm then
		pArm:play(-1)
	end

	--第3个旗帜
	for i = 1, 3 do
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["9_"..i], 
			self.pBaseContent, 
			100,    --层级比旗帜高
			tT["3"],
		    function ( _pArm )

		    end, Scene_arm_type.base)
		if pArm then
			pArm:play(-1)
		end
	end
end

--瀑布特效
function HomeBaseLayer:showWaterfallTx(  )
	-- body
	for i = 1, 4 do
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["10_" .. i], 
			self.pBaseContent, 
			10, 
			cc.p(0,0),
		    function ( _pArm )

		    end, Scene_arm_type.base)
		if pArm then
			pArm:play(-1)
		end
	end
end

--瀑布特效5
function HomeBaseLayer:showWaterfallFive()
    
    if(b_close_paritcle_of_android == true) then
        return
    end

	self.pLayWaterFive = MUI.MLayer.new()
	self.pLayWaterFive:setLayoutSize(700, 200)

	self.pLayWaterFive:setPosition(400,0)
	self.pBaseContent:addView(self.pLayWaterFive,10)

	local tWateFallPos = {cc.p(532,150),cc.p(531,163),cc.p(551,172),
						cc.p(476,158),cc.p(416,124),cc.p(258,73),
						cc.p(264,99),cc.p(272,101),cc.p(260,76),cc.p(116,112)} 
	
	--第一层
	local pParitcle1 =  createParitcle("tx/other/lizi_pubu5_5000.plist")
	pParitcle1:setPosition(tWateFallPos[1])
	self.pLayWaterFive:addView(pParitcle1,1)
	
	--第二层
	local pParitcle2 =  createParitcle("tx/other/lizi_pubu5_5002.plist")
	pParitcle2:setPosition(tWateFallPos[2])
	self.pLayWaterFive:addView(pParitcle2,2)

	--第三层
	local pParitcle3 =  createParitcle("tx/other/lizi_pubu5_5001.plist")
	pParitcle3:setPosition(tWateFallPos[3])
	self.pLayWaterFive:addView(pParitcle3,3)

	--第四层
	local pParitcle4 =  createParitcle("tx/other/lizi_pubu5_5003.plist")
	pParitcle4:setPosition(tWateFallPos[4])
	self.pLayWaterFive:addView(pParitcle4,4)

	--第5层
	-- local pParitcle5 =  MUI.MImage.new("#sg_pbgd_x_zb_02.png")
	-- pParitcle5:setPosition(tWateFallPos[5])
	-- self.pLayWaterFive:addView(pParitcle5,5)

	--第6层
	local pParitcle6 =  createParitcle("tx/other/lizi_pubu5_5000.plist")
	pParitcle6:setPosition(tWateFallPos[6])
	self.pLayWaterFive:addView(pParitcle6,6)

	--第7层
	local pParitcle7 =  createParitcle("tx/other/lizi_pubu5_5001.plist")
	pParitcle7:setPosition(tWateFallPos[7])
	self.pLayWaterFive:addView(pParitcle7,7)

	--第8层
	local pParitcle8 =  createParitcle("tx/other/lizi_pubu5_5002.plist")
	pParitcle8:setPosition(tWateFallPos[8])
	self.pLayWaterFive:addView(pParitcle8,8)

	--第9层
	local pParitcle9 =  createParitcle("tx/other/lizi_pubu5_5003.plist")
	pParitcle9:setPosition(tWateFallPos[9])
	self.pLayWaterFive:addView(pParitcle9,9)

	--第10层
	-- local pParitcle10 =  MUI.MImage.new("#sg_pbgd_x_zb_01.png")
	-- pParitcle10:setPosition(tWateFallPos[10])
	-- self.pLayWaterFive:addView(pParitcle10,10)

	-- self.pLayWaterFive:setNeedCheckScreen(false)

end

--水龙头特效
function HomeBaseLayer:showSltTx(  )
	-- body
	for i = 1, 3 do
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["28_" .. i], 
			self.pBaseContent, 
			10, 
			cc.p(0,0),
		    function ( _pArm )

		    end, Scene_arm_type.base)
		if pArm then
			pArm:play(-1)
		end
	end
end


--展示水车
function HomeBaseLayer:showWaterCarTx(  )
	-- body
	local pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["24"], 
		self.pBaseContent, 
		10, 
		cc.p(0,0),
	    function ( _pArm )

	    end, Scene_arm_type.base)
	if pArm then
		pArm:play(-1)
	end
end

--展示旗帜
function HomeBaseLayer:showFlagTx(  )
	local nIndex = 1
	self.nFlagcheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["25_" .. nIndex], 
			self.pBaseContent, 
			10, 
			cc.p(0,0),
		    function ( _pArm )

		    end, Scene_arm_type.base)
		if pArm then
			pArm:play(-1)
		end
		-- print("index----------",nIndex)
		nIndex = nIndex + 1
		if self ~= nil and self.nFlagcheduler ~= nil and nIndex > 6 then
	        MUI.scheduler.unscheduleGlobal(self.nFlagcheduler)
	        self.nFlagcheduler = nil
		end
	end)
end

--丹顶鹤
function HomeBaseLayer:showDDH(  )
	-- body
	--创建第一只丹顶鹤
	self:DDHFlyXtoS(self:createOneDDH(1))
	--创建第二只丹顶鹤
	doDelayForSomething(self,function (  )
		-- body
		self:DDHFlyStoX(self:createOneDDH(2))
	end,20)
	--创建第三只丹顶鹤
	doDelayForSomething(self,function (  )
		-- body
		self:DDHFlyXtoS(self:createOneDDH(1))
	end,40)
	--创建第四只丹顶鹤
	doDelayForSomething(self,function (  )
		-- body
		self:DDHFlyStoX(self:createOneDDH(2))
	end,60)
end

--丹顶鹤 下飞到上
function HomeBaseLayer:DDHFlyXtoS( _pArm )

	-- body
	if not _pArm then
		return
	end

	--左下到右上，鸟可飞行的Y轴区间（-2000，25）+（1250,2000）
	--用1表示区间（-2000，25） 2代表区间 （1250,2000）
	--先随机一个数来确定在哪个区间去随机数
	local fOffsetY = 0
	local nIndex = math.random(1,2)
	
	if nIndex == 1 then
		fOffsetY = math.random(-2000,25)
	elseif nIndex == 2 then
		fOffsetY = math.random(1250,2000)
	end
	_pArm:setPosition(cc.p(-50, fOffsetY))
	--轨迹
	--终点位置随机
	local nOffsetX = math.random(-10, 10) * 10
	local nOffsetY = math.random(-10, 10) * 10

	--随机时间
	local fTime = math.random(56, 76)

	local actionMoveTo = cc.MoveTo:create(fTime, cc.p(4652 + nOffsetX, 2258 + nOffsetY + fOffsetY))
	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		self:DDHFlyXtoS(_pArm)
	end)
	local allActions = cc.Sequence:create(actionMoveTo,actionEnd)
	_pArm:runAction(allActions)
end

--丹顶鹤 上飞到下
function HomeBaseLayer:DDHFlyStoX( _pArm )
	-- body
	if not _pArm then
		return
	end
	--初始化位置设置
	--随机初始化位置
	--起点位置随机
	local nOffsetX = math.random(-10, 10) * 10
	local nOffsetY = math.random(-10, 10) * 10
	--轨迹偏移值

	--右上到左下，鸟可飞行的Y轴区间（0，2000）+（3166，4000）
	--用1表示区间（0，2000） 2代表区间 （3166,4000）
	--先随机一个数来确定在哪个区间去随机数
	local fOffsetY = 0
	local nIndex = math.random(1,2)
	-- print("nIndex------2222222-----",nIndex)
	if nIndex == 1 then
		fOffsetY = math.random(0,2000)
	elseif nIndex == 2 then
		fOffsetY = math.random(3166,4000)
	end


	_pArm:setPosition(cc.p(4200 + nOffsetX, 2258 + nOffsetY + fOffsetY))
	--轨迹
	
	--随机时间
	local fTime = math.random(56, 76)
	local actionMoveTo = cc.MoveTo:create(fTime, cc.p(-50, fOffsetY))
	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		self:DDHFlyStoX(_pArm)
	end)
	local allActions = cc.Sequence:create(actionMoveTo,actionEnd)
	_pArm:runAction(allActions)
end

--创建一只丹顶鹤
--_nType：1：下到上  2：上到下
function HomeBaseLayer:createOneDDH( _nType )
	-- body
	local pLayDDH = MUI.MLayer.new()
	pLayDDH:setLayoutSize(1, 1)

	local pArmDDH = nil
	local sName = nil
	local tArmData1 = nil 
	if _nType == 1 then
		pArmDDH = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["41_1"], 
				pLayDDH, 
				10, 
				cc.p(pLayDDH:getWidth() / 2,pLayDDH:getHeight() / 2),
			    function ( _pArm )
		
			    end, Scene_arm_type.base)
	elseif _nType == 2 then

		pArmDDH = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["41_2"], 
				pLayDDH, 
				10, 
				cc.p(pLayDDH:getWidth() / 2,pLayDDH:getHeight() / 2),
			    function ( _pArm )
			    	
			    end, Scene_arm_type.base)
	end
	if pArmDDH then
		pArmDDH:play(-1)
	end
	--添加到基地层上
	self.pBaseContent:addView(pLayDDH,9990)
	return pLayDDH
end

--展示白鹭
function HomeBaseLayer:showBaiLu(  )
	-- body
	--第一群白鹭
	self.tBailu1s = {}
	for i = 1, 5 do
		table.insert(self.tBailu1s, self:createOneBaiLu(1))
	end
	self:flyBailuFiveXToS(self.tBailu1s)
	--第二群白鹭
	doDelayForSomething(self,function (  )
		-- body
		self.tBailu2s = {}
		for i = 1, 5 do
			table.insert(self.tBailu2s, self:createOneBaiLu(2))
		end
		self:flyBailuFiveSToX(self.tBailu2s)
	end,20)
	--第三群白鹭
	doDelayForSomething(self,function (  )
		-- body
		self.tBailu3s = {}
		for i = 1, 3 do
			table.insert(self.tBailu3s, self:createOneBaiLu(1))
		end
		self:flyBailuFiveXToS(self.tBailu3s)
	end,40)
	--第四群白鹭
	doDelayForSomething(self,function (  )
		-- body
		self.tBailu4s = {}
		for i = 1, 3 do
			table.insert(self.tBailu4s, self:createOneBaiLu(2))
		end
		self:flyBailuFiveSToX(self.tBailu4s)
	end,60)
	
	
end

--白鹭下飞到上
function HomeBaseLayer:flyBailuFiveXToS( _tTs )
	-- body
	-- local tStartPos = {cc.p(-41,-31),cc.p(-60,-26),cc.p(-36,-50),cc.p(-85,-26),cc.p(-36,-69)}
	-- local tEndPos = {cc.p(4191,2279),cc.p(4169,2281),cc.p(4195,2260),cc.p(4147,2283),cc.p(4197,2240)}

	local tStartPos = {cc.p(-27,-21),cc.p(-62,-26),cc.p(-31,-46),cc.p(-101,-30),cc.p(-37,-73)}
	local tEndPos = {cc.p(4202,2286),cc.p(4167,2280),cc.p(4200,2264),cc.p(4103,2260),cc.p(4195,2236)}

	--随机轨迹偏移量
	--左下到右上，鸟可飞行的Y轴区间（-2000，25）+（1250,2000）
	--用1表示区间（-2000，25） 2代表区间 （1250,2000）
	--先随机一个数来确定在哪个区间去随机数
	local fOffsetY = 0
	local nIndex = math.random(1,2)
	
	if nIndex == 1 then
		fOffsetY = math.random(-2000,25)
	elseif nIndex == 2 then
		fOffsetY = math.random(1250,2000)
	end

	-- local fOffsetY = math.random(-20,20) * 100



	--随机时间
	local fTime = math.random(55, 65)
	--初始化位置
	if _tTs and table.nums(_tTs) > 0 then
		for k, v in pairs (_tTs) do
			--起点位置
			local tPosStart = cc.p(tStartPos[k].x , tStartPos[k].y + fOffsetY)
			v:setPosition(tPosStart)
			--终点位置
			local tPosEnd = cc.p(tEndPos[k].x, tEndPos[k].y + fOffsetY)
			--轨迹
			local actionMoveTo = cc.MoveTo:create(fTime, tPosEnd)
			local actionEnd = cc.CallFunc:create(function (  )
				if k == table.nums(_tTs) then
					self:flyBailuFiveXToS(_tTs)
				end
			end)
			local allActions = cc.Sequence:create(actionMoveTo,actionEnd)
			v:runAction(allActions)
		end
	end
end

--白鹭上飞到下
function HomeBaseLayer:flyBailuFiveSToX( _tTs )
	-- -- body
	-- local tStartPos = {cc.p(4169,2261),cc.p(4169,2281),cc.p(4194,2260),cc.p(4172,2301),cc.p(5220,2261)}
	-- local tEndPos = {cc.p(-352,-73),cc.p(-352,-52),cc.p(-327,-74),cc.p(-349,-32),cc.p(-301,-72)}

	local tStartPos = {cc.p(4169,2261),cc.p(4180,2321),cc.p(4240,2261),cc.p(4170,2377),cc.p(4435,2340)}
	local tEndPos = {cc.p(-352,-73),cc.p(-341,-12),cc.p(-281,-73),cc.p(-351,40),cc.p(-100,8)}


	--随机轨迹偏移量
	--右上到左下，鸟可飞行的Y轴区间（0，2000）+（3166，4000）
	--用1表示区间（0，2000） 2代表区间 （3166,4000）
	--先随机一个数来确定在哪个区间去随机数
	local fOffsetY = 0
	local nIndex = math.random(1,2)
	if nIndex == 1 then
		fOffsetY = math.random(0,2000)
	elseif nIndex == 2 then
		fOffsetY = math.random(3166,4000)
	end

	-- local fOffsetY = math.random(0,40) * 100
	--随机时间
	local fTime = math.random(55, 65)
	--初始化位置
	if _tTs and table.nums(_tTs) > 0 then
		for k, v in pairs (_tTs) do
			--起点位置
			local tPosStart = cc.p(tStartPos[k].x, tStartPos[k].y + fOffsetY)
			v:setPosition(tPosStart)
			--终点位置
			local tPosEnd = cc.p(tEndPos[k].x, tEndPos[k].y + fOffsetY)
			--轨迹
			local actionMoveTo = cc.MoveTo:create(fTime, tPosEnd)
			local actionEnd = cc.CallFunc:create(function (  )
			
				if k == table.nums(_tTs) then
					self:flyBailuFiveSToX(_tTs)
				end
			end)
			local allActions = cc.Sequence:create(actionMoveTo,actionEnd)
			v:runAction(allActions)
		end
	end
end

--创建一只白鹭
--_nType：1：下到上  2：上到下
function HomeBaseLayer:createOneBaiLu( _nType )

	local pLayBaiLu = MUI.MLayer.new()
	pLayBaiLu:setLayoutSize(1,1)
	-- body
	local pArmBailu = nil
	local sName = nil
	if _nType == 1 then
		-- sName = createAnimationBackName("tx/exportjson/", "sg_blsqt_jyy_xfs_001")
		pArmBailu = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["42_1"], 
				pLayBaiLu, 
				10, 
				cc.p(pLayBaiLu:getWidth() / 2,pLayBaiLu:getHeight() / 2),
			    function ( _pArm )
		
			    end, Scene_arm_type.base)
	elseif _nType == 2 then
		pArmBailu = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["42_2"], 
				pLayBaiLu, 
				10, 
				cc.p(pLayBaiLu:getWidth() / 2,pLayBaiLu:getHeight() / 2),
			    function ( _pArm )
			    	
			    end, Scene_arm_type.base)
		-- sName = createAnimationBackName("tx/exportjson/", "sg_blsqt_jyy_sfx_001")
	end
	-- if sName then
	-- 	pArmBailu = ccs.Armature:create(sName)
	-- 	pArmBailu:setPosition(self.pBaseContent:getWidth() / 2,self.pBaseContent:getHeight() / 2)
	-- 	self.pBaseContent:addChild(pArmBailu,9991)
	-- 	pArmBailu:getAnimation():play("Animation1", 1)
	-- end
	if pArmBailu then
		pArmBailu:play(-1)
	end
	--添加到基地层上
	self.pBaseContent:addView(pLayBaiLu,9991)
	return pLayBaiLu
end

--城门守卫
-- _sKey _nIndex 要播放的资源下表
function HomeBaseLayer:showGuardTx()

	-- if self.tGuard == nil then
	-- 	self.tGuard = {}
	-- end
	-- if self.tGuard[_sKey.._nIndex] == nil then
	-- 	local pArm = MArmatureUtils:createMArmature(
	-- 		tNormalCusArmDatas[_sKey .. _nIndex], 
	-- 		self.pBaseContent, 
	-- 		9991, 
	-- 		cc.p(0,0),
	-- 	    function ( _pArm )
	-- 	    	_nIndex = _nIndex + 1
	-- 	    	if _nIndex > 8 then
	-- 	    		_nIndex = 3
	-- 	    	end
	-- 	    	self:showGuard(_sKey,_nIndex)
	-- 	    end, Scene_arm_type.base)
	-- 	self.tGuard[_sKey.._nIndex] = pArm
	-- else
	-- 	self.tGuard[_sKey.._nIndex]:setData(tNormalCusArmDatas[_sKey .. _nIndex])
	-- end
	-- if self.tGuard[_sKey.._nIndex] then
	-- 	self.tGuard[_sKey.._nIndex]:setFrameEventCallFunc(function ( _nCur )
	-- 		if _nCur == 2 then
	-- 			if _nIndex > 8 then
	-- 	    		_nIndex = 3
	-- 	    	end
	-- 			self:showGuard("29_",_nIndex + 1)
	-- 		end
	-- 	end)
	-- 	self.tGuard[_sKey.._nIndex]:play(1)
	-- end

	--创建第一个巡逻兵
	self:createOneGrard(3)
	doDelayForSomething(self,function (  )
		-- body
		self:createOneGrard(6)
	end,0.7)
	--创建第一个巡逻兵
	self:createOneGrard(4) 
	doDelayForSomething(self,function (  )
		-- body
		self:createOneGrard(7)
	end,0.7)

	--创建第一个巡逻兵
	self:createOneGrard(5)
	doDelayForSomething(self,function (  )
		-- body
		self:createOneGrard(8)
	end,0.7)



end

function HomeBaseLayer:createOneGrard( _nIndex )
	if not _nIndex then
		return 
	end
	local pArm = nil 
	if _nIndex == 3 then
		pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["29_" .. _nIndex], 
			self.pBaseContent, 
			8059, 
			cc.p(0,0),
		    function ( _pArm )

		    end, Scene_arm_type.base)
	else
		pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["29_" .. _nIndex], 
			self.pBaseContent, 
			9, 
			cc.p(0,0),
		    function ( _pArm )

		    end, Scene_arm_type.base)
	end
	if pArm then
		pArm:play(-1)
	end

end
local HomeXLBTipsLayer = require("app.layer.home.HomeXLBTipsLayer")

function HomeBaseLayer:showXLBBubbleLayer(_pView,sTips)
	if not _pView then
		return 
	end

	if self.pXLBBubleLayer then
		self.pXLBBubleLayer:stopAllActions()
		self.pXLBBubleLayer:removeSelf()
	end



	self.pXLBBubleLayer = HomeXLBTipsLayer.new()
	_pView:addView(self.pXLBBubleLayer,100)


	
	self.pXLBBubleLayer:setTips(sTips)
	 _pView.nTag  = _pView.nTag or 3.1
	
	if  _pView.nTag == 3.1 then
		self.pXLBBubleLayer:setPosition(cc.p(_pView:getWidth() / 2 - self.pXLBBubleLayer:getWidth() / 2 - 20, 40 ))
		-- self.pXLBBubleLayer:setPosition(cc.p(_pView:getPositionX() - self.pXLBBubleLayer:getWidth() / 2 ,_pView:getPositionY() + 28))
	elseif  _pView.nTag == 12 then
		self.pXLBBubleLayer:setPosition(cc.p(_pView:getWidth() / 2 - self.pXLBBubleLayer:getWidth() / 2 - 10, 53))
		
		-- self.pXLBBubleLayer:setPosition(cc.p(_pView:getPositionX() - self.pXLBBubleLayer:getWidth() / 2  + 10 ,_pView:getPositionY() + self.pXLBBubleLayer:getHeight() / 2 + 15 ))
	elseif _pView.nTag == 2.1 then
		self.pXLBBubleLayer:setPosition(cc.p(_pView:getWidth() / 2 - self.pXLBBubleLayer:getWidth() / 2 - 38, 20))

		-- self.pXLBBubleLayer:setPosition(cc.p(_pView:getPositionX() - self.pXLBBubleLayer:getWidth() / 2 - 12,_pView:getPositionY() + 25 ))
	elseif  _pView.nTag == 5.1 then
		self.pXLBBubleLayer:setPosition(cc.p(_pView:getWidth() / 2 - self.pXLBBubleLayer:getWidth() / 2 - 20 , 30))
		-- self.pXLBBubleLayer:setPosition(cc.p(_pView:getPositionX() - self.pXLBBubleLayer:getWidth() / 2 - 2,_pView:getPositionY() + 28 ))
	elseif  _pView.nTag == 6.1 then  
		self.pXLBBubleLayer:setPosition(cc.p(_pView:getWidth() / 2 - self.pXLBBubleLayer:getWidth() / 2  - 20, 30))

		-- self.pXLBBubleLayer:setPosition(cc.p(_pView:getPositionX() - self.pXLBBubleLayer:getWidth() / 2 ,_pView:getPositionY() + 28 ))
	elseif  _pView.nTag == 4.1 then  
		-- self.pXLBBubleLayer:setPosition(cc.p(_pView:getPositionX() - self.pXLBBubleLayer:getWidth() / 2 ,_pView:getPositionY() + 28 ))
		self.pXLBBubleLayer:setPosition(cc.p(_pView:getWidth() / 2 - self.pXLBBubleLayer:getWidth() / 2 - 20, 40 ))
		
	end
	
	doDelayForSomething(self.pXLBBubleLayer,function (  )
		self.nCurTipsIndex = self.nCurTipsIndex  + 1
		self.bShowxLBBuble = false
		self.pXLBBubleLayer:setVisible(false)
		doDelayForSomething(self,function ( )

			if self.nCurTipsIndex > table.nums(self.tXLBTips or {}) then
				self.nCurTipsIndex = 1
			end
			self:showXLBBubbleLayer(self.pLayXlbST,self.tXLBTips[self.nCurTipsIndex])
		end,self.nTipsCDTime)
			
	end,self.nExistTime)


end
function HomeBaseLayer:onXLBClicked( _pview)
	if not _pview then
		return 
	end
	--根据任务id，判断是否达到开启条件 该条件由服务器推送
	if  Player:getPlayerInfo().nOpenXLBTips == 0 then
		return 
	end

	if not self.tXLBTips then

		self.tXLBTips = getTipSoldierByLv(Player.baseInfos.nLv)
		--获取提示框存在时间
		self.nExistTime = getDisplayParam("tipsTime")  or 15

	    --获取CD时间
		self.nTipsCDTime = getDisplayParam("tipsCd") or 5
		self.nCurTipsIndex = 1
	
	end
	self.nCurTipsIndex = self.nCurTipsIndex  + 1
	
	
	if self.nCurTipsIndex > table.nums(self.tXLBTips) then 
		self.nCurTipsIndex = 1
	

	end
	self:showXLBBubbleLayer(_pview:getParent(),self.tXLBTips[self.nCurTipsIndex])
end

--城门巡逻兵3.1 - 3.2播放自动提示语
function HomeBaseLayer:showXLBAutoTips()
	
	--判断玩家等级是否已经达到关闭条件
	local nCloseLv = getDisplayParam("soldierTipsOff") 
	if nCloseLv and Player.baseInfos.nLv >= tonumber(nCloseLv)   then  --达到关闭等级
		return 
	end
	--根据任务id，判断是否达到开启条件 该条件由服务器推送
	if Player:getPlayerInfo().nOpenXLBTips == 0  then
		return 
	end
	if not self.nExistTime then
		--获取提示框存在时间
		self.nExistTime = getDisplayParam("tipsTime")  or 15

	    --获取CD时间
		self.nTipsCDTime = getDisplayParam("tipsCd") or 5

		self.tXLBTips = getTipSoldierByLv(Player.baseInfos.nLv)
		self.nCurTipsIndex = 1
	else
		self.nCurTipsIndex = self.nCurTipsIndex  + 1
	end
	if self.nCurTipsIndex > table.nums(self.tXLBTips) then
		self.nCurTipsIndex = 1
	end
	

	doDelayForSomething(self,function ()		
		self:showXLBBubbleLayer(self.pLayXlbST,self.tXLBTips[self.nCurTipsIndex])
		--self:showXLBBubbleLayer(self.pLayXlbC,self.tXLBTips[self.nCurTipsIndex])
	end,5)
	
	
end

function HomeBaseLayer:showXLBBubbleTips()
	
end

--巡逻兵展示
function HomeBaseLayer:showXLB(  )
	--巡逻兵 1 - 12

	self.tXlbTop = {}
	
	
	if self.pLayXlbTop == nil   then
		self.pLayXlbTop = MUI.MLayer.new()
		self.pLayXlbTop:setLayoutSize(XLB_WIDTH, XLB_HEIGHT)
		self.pLayXlbTop:setPosition(277, 944 )

		self.pBaseContent:addView(self.pLayXlbTop, 7900)

		self.pLayXlbTop.nCt = 1

		self.pLayXlbTop.nTag = 12
		self.pLayXlbTop:setViewTouched(true)
		self.pLayXlbTop:setIsPressedNeedScale(false)
	
		self.pLayXlbTop:onMViewClicked(handler(self, self.onXLBClicked))


		self.pLayClick12 = MUI.MImage.new("ui/daitu.png",{scale9=true})
		self.pLayClick12:setContentSize(cc.size(XLB_WIDTH,XLB_HEIGHT - 20))
		self.pLayClick12:setAnchorPoint(cc.p(0,0))
		self.pLayClick12:setPosition(cc.p(self.pLayXlbTop:getWidth()/ 2 - 30 ,self.pLayXlbTop:getHeight() / 2 - 25))
		self.pLayXlbTop:addView(self.pLayClick12,11)



		self.pLayClick12:setViewTouched(true)
		self.pLayClick12:setIsPressedNeedScale(false)
		self.pLayClick12:onMViewClicked(handler(self, self.onXLBClicked))

	end

	for i=1,2 do
		local pXLB = self:createOneXLB(self.pLayXlbTop,1)
		local tPos = nil
		if i == 1 then
			tPos = cc.p(self.pLayXlbTop:getWidth()/ 2 ,self.pLayXlbTop:getHeight() / 2)
		elseif i == 2 then
			tPos = cc.p(self.pLayXlbTop:getWidth() / 2 - 20,self.pLayXlbTop:getHeight() / 2 - 10)
		end
		pXLB:setPosition(tPos)
		pXLB:setFlippedX(true)
		-- pXLB:play(-1)
		table.insert(self.tXlbTop,pXLB)
	end

	-- doDelayForSomething(self,function (  )
		self:showTXLTop()
	-- end,5)
	-- doDelayForSomething(self,function (  )
	-- 	-- self:showTXLTCircle2()
	-- end,6)

	--巡逻兵2.1 - 2.2
	self.tXlbT2 = {}
	if self.pLayXlbT2 == nil then
		self.pLayXlbT2 = MUI.MLayer.new()
		self.pLayXlbT2:setLayoutSize(XLB_WIDTH, XLB_HEIGHT)
		self.pLayXlbT2:setPosition(1194,1116)
		self.pBaseContent:addView(self.pLayXlbT2,self.nMaxBuildZorder)
		self.pLayXlbT2.nCt = 1

		self.pLayXlbT2.nTag = 2.1
		self.pLayXlbT2:setViewTouched(true)
		self.pLayXlbT2:setIsPressedNeedScale(false)
		
		self.pLayXlbT2:onMViewClicked(handler(self, self.onXLBClicked))


		-- 
		self.pLayClick2 = MUI.MImage.new("ui/daitu.png",{scale9=true})
		self.pLayClick2:setContentSize(cc.size(XLB_WIDTH*2 - 40,XLB_HEIGHT - 20))
		self.pLayClick2:setAnchorPoint(cc.p(0,0))
		self.pLayClick2:setPosition(cc.p(self.pLayXlbTop:getWidth()/ 2 - 50 ,self.pLayXlbTop:getHeight() / 2 - 55))

		self.pLayXlbT2:addView(self.pLayClick2,11)



		self.pLayClick2:setViewTouched(true)
		self.pLayClick2:setIsPressedNeedScale(false)
		self.pLayClick2:onMViewClicked(handler(self, self.onXLBClicked))
	end
	for i=1,2 do
		local pXLB = self:createOneXLB(self.pLayXlbT2,2)
		local tPos = nil
		if i == 1 then
			tPos = cc.p(1/ 2 ,1/ 2)
		elseif i == 2 then
			tPos = cc.p(1 / 2 - 20,1 / 2 - 10)
		end
		pXLB:setPosition(tPos)
		pXLB:setFlippedX(true)
		-- pXLB:play(-1)
		table.insert(self.tXlbT2,pXLB)
	end
	self:showTXLT2()
	--城门上面的6人阵型 3.2 - 3.1
	self.tXlbST = {}
	if self.pLayXlbST == nil then
		self.pLayXlbST = MUI.MLayer.new()
		self.pLayXlbST:setLayoutSize(XLB_WIDTH , XLB_HEIGHT)
		self.pLayXlbST:setPosition(2001 ,1208)
		self.pBaseContent:addView(self.pLayXlbST,823)  --823 城门的zorder是824.5
		self.pLayXlbST.nCt = 1
		self.pLayXlbST.nTag = 3.1
		-- self.pLayXlbST:setViewTouched(true)
		-- self.pLayXlbST:setIsPressedNeedScale(false)
		-- self.pLayXlbST:setIsPressedNeedColor(false)
		
		-- setBgQuality(self.pLayXlbST,2)
-- #v1_img_touxiangkuanghui.png
		self.pLayClick3 = MUI.MImage.new("ui/daitu.png",{scale9=true})
		self.pLayClick3:setContentSize(cc.size(XLB_WIDTH*2 - 10,XLB_HEIGHT))
		self.pLayClick3:setAnchorPoint(cc.p(0,0))
		self.pLayClick3:setPosition(cc.p(-43,-30))
		self.pLayXlbST:addView(self.pLayClick3,11)



		self.pLayClick3:setViewTouched(true)
		self.pLayClick3:setIsPressedNeedScale(false)
		self.pLayClick3:onMViewClicked(handler(self, self.onXLBClicked))
	end

	

	for i = 1, 6 do
		local pXLB = self:createOneXLB(self.pLayXlbST,2)
		local tPos = nil 		
		if i == 1 then
			tPos = cc.p(8,15)
		elseif i == 2 then
			tPos = cc.p(31,5)
		elseif i == 3 then
			tPos = cc.p(-13,2)
		elseif i == 4 then
			tPos = cc.p(9,-7)
			
		elseif i == 5 then
			tPos = cc.p(-36,-8)
			
		elseif i == 6 then
			tPos = cc.p(-15,-18)
			
		end
		
		pXLB:setPosition(tPos)
		pXLB:setFlippedX(true)

		table.insert(self.tXlbST,pXLB) 
		-- pXLB:play(-1)
	end
	self:showTXLST()

	--竖向上 6.1 - 6.2
	self.tXlbT = {}
	if self.pLayXlbT == nil then
		self.pLayXlbT = MUI.MLayer.new()
		self.pLayXlbT:setLayoutSize(XLB_WIDTH, XLB_HEIGHT)
		self.pLayXlbT:setPosition(cc.p(2318, 1287 ))
		self.pBaseContent:addView(self.pLayXlbT,10)
		self.pLayXlbT.nCt = 1

		self.pLayXlbT.nTag = 6.1
		
		self.pLayClick6 = MUI.MImage.new("ui/daitu.png",{scale9=true})
		self.pLayClick6:setContentSize(cc.size(XLB_WIDTH -10,XLB_HEIGHT - 20))
		self.pLayClick6:setAnchorPoint(cc.p(0,0))
		
		self.pLayClick6:setPosition(cc.p(self.pLayXlbT:getWidth() / 2 - XLB_WIDTH / 2 - 12,self.pLayXlbT:getHeight() / 2  - XLB_HEIGHT/2 - 20))

		self.pLayXlbT:addView(self.pLayClick6,11)



		self.pLayClick6:setViewTouched(true)
		self.pLayClick6:setIsPressedNeedScale(false)
		self.pLayClick6:onMViewClicked(handler(self, self.onXLBClicked))
	end
	local pXLB = self:createOneXLB(self.pLayXlbT,2)
	
	pXLB:setPosition(cc.p(self.pLayXlbT:getWidth() / 2 - XLB_WIDTH / 2,self.pLayXlbT:getHeight() / 2  - XLB_HEIGHT/2))
	pXLB:setFlippedX(true)
	-- pXLB:play(-1)
	table.insert(self.tXlbT,pXLB)
	
	
	--开始巡逻(上)
	self:showTXLT()

	--竖向下 5.1 - 5.2
	self.tXlbB = {}
	if self.pLayXlbB == nil then
		self.pLayXlbB = MUI.MLayer.new()
		self.pLayXlbB:setLayoutSize(XLB_WIDTH , XLB_HEIGHT)
		self.pLayXlbB:setPosition(1004,626)
		self.pBaseContent:addView(self.pLayXlbB,self.nMaxBuildZorder - 10)
		self.pLayXlbB.nCt = 1

		self.pLayXlbB.nTag = 5.1
		


		self.pLayClick5 = MUI.MImage.new("ui/daitu.png",{scale9=true})
		self.pLayClick5:setContentSize(cc.size(XLB_WIDTH - 10,XLB_HEIGHT - 20))
		self.pLayClick5:setAnchorPoint(cc.p(0,0))
		self.pLayClick5:setPosition(cc.p(self.pLayXlbB:getWidth()/ 2 - XLB_WIDTH / 2 - 15 ,self.pLayXlbB:getHeight() / 2 - XLB_HEIGHT/2 - 20))
		self.pLayXlbB:addView(self.pLayClick5,11)



		self.pLayClick5:setViewTouched(true)
		self.pLayClick5:setIsPressedNeedScale(false)
		self.pLayClick5:onMViewClicked(handler(self, self.onXLBClicked))
	end
	local pXLB = self:createOneXLB(self.pLayXlbB,1)
	pXLB:setFlippedX(true)
	-- pXLB:play(-1)
	pXLB:setPosition(cc.p(self.pLayXlbB:getWidth() / 2 - XLB_WIDTH / 2,self.pLayXlbB:getHeight() / 2 - XLB_HEIGHT/2))
	table.insert(self.tXlbB,pXLB)
	
	--开始巡逻(下)
	self:showTXLB()

	--中间 4.1 - 4.2
	self.tXlbC = {}
	if self.pLayXlbC == nil then
		self.pLayXlbC = MUI.MLayer.new()
		self.pLayXlbC:setLayoutSize(XLB_WIDTH, XLB_HEIGHT)
		self.pLayXlbC:setPosition(1869,868)
		self.pBaseContent:addView(self.pLayXlbC,8058)
		self.pLayXlbC.nCt = 1

		self.pLayXlbC.nTag = 4.1
	
		self.pLayClick4 = MUI.MImage.new("ui/daitu.png",{scale9=true})
		self.pLayClick4:setContentSize(cc.size(XLB_WIDTH*2 - 10,XLB_HEIGHT ))
		self.pLayClick4:setAnchorPoint(cc.p(0,0))
		self.pLayClick4:setPosition(cc.p(self.pLayXlbB:getWidth()/ 2 - XLB_WIDTH / 2 - 40 ,self.pLayXlbB:getHeight() / 2 - XLB_HEIGHT/2 - 30))
		self.pLayXlbC:addView(self.pLayClick4,11)



		self.pLayClick4:setViewTouched(true)
		self.pLayClick4:setIsPressedNeedScale(false)
		self.pLayClick4:onMViewClicked(handler(self, self.onXLBClicked))
	end
	for i = 1, 6 do
		local pXLB = self:createOneXLB(self.pLayXlbC,2)
		local tPos = nil
		if i == 1 then
			tPos = cc.p(-11,14)
		elseif i == 2 then
			tPos = cc.p(-34,3)
		elseif i == 3 then
			tPos = cc.p(12,2)
		elseif i == 4 then
			tPos = cc.p(-10,-8)
		elseif i == 5 then
			tPos = cc.p(33,-10)
		elseif i == 6 then
			tPos = cc.p(10,-20)
		end
		pXLB:setPosition(tPos)
		pXLB:play(-1)
		-- pXLB:setFlippedX(true)
		table.insert(self.tXlbC,pXLB)
	end
	--开始巡逻(中)
	self:showTXLC()

	
end


--巡逻兵城门上的 1 - 12
function HomeBaseLayer:showTXLTop(  )
	-- body
	if self.pLayXlbTop and self.pLayXlbTop.nCt then
		local nIndex = self.pLayXlbTop.nCt
		local nTag = nIndex % 2
		local fTime = 32 --时间32秒
		local tPosEnd = nil
		local sKey = "29_1"
		if nTag == 0 then
			tPosEnd = cc.p(317 ,965 )
			-- fTime = 30
			-- fTime = 6
			sKey = "29_2"
		elseif nTag == 1 then
			tPosEnd = cc.p(936 ,1266 )
			sKey = "29_1"
		end
		
		--设置数据
		if self.tXlbTop and table.nums(self.tXlbTop) > 0 then
			for k, v in pairs (self.tXlbTop) do
				v:stop()
				v:setData(tNormalCusArmDatas[sKey])
				v:play(-1)
			end
		end
		self.pLayXlbTop:setName("xlb")
		self:showXLBMoveActions(self.pLayXlbTop,fTime,tPosEnd,function (  )
			-- body
			self:showTXLTop()
		end )
		--计数器加1
		self.pLayXlbTop.nCt = self.pLayXlbTop.nCt + 1
		-- if self.pLayXlbCircle1.nCt >= 13 then
		-- 	self.pLayXlbCircle1.nCt = 1
		-- end
	end
end
--巡逻兵城门上的 1 - 12
function HomeBaseLayer:showTXLTCircle2(  )
	-- body
	if self.pLayXlbCircle2 and self.pLayXlbCircle2.nCt then
		local nIndex = self.pLayXlbCircle2.nCt
		local nTag = nIndex % 2
		local fTime = 32 --时间32秒
		local tPosEnd = nil
		local sKey = "29_1"
		local tPos = nil 
		if nTag == 0 then
			tPosEnd  = cc.p(277 - XLB_WIDTH / 2,944 - XLB_HEIGHT / 2)
			-- fTime = 30
			
			-- fTime = 6
			sKey = "29_2"
		elseif nTag == 1 then
			tPosEnd = cc.p(965 - XLB_WIDTH / 2,1277 - XLB_HEIGHT / 2)
			sKey = "29_1"
			-- fTime = 10
		-- elseif nIndex == 3 then
		-- 	tPosEnd = cc.p(615, 1274)
		-- 	sKey = "29_2"
		-- 	fTime = 7.6
		-- elseif nIndex == 4 then
		-- 	tPosEnd = cc.p(525, 1395)
		-- 	sKey = "29_1"
		-- 	fTime = 5.8
	
		-- elseif nIndex == 5 then
		-- 	tPosEnd = cc.p(658, 1456)
		-- 	sKey = "29_1"
		-- 	fTime = 6
		-- elseif nIndex == 6 then
		-- 	tPosEnd = cc.p(429, 1568)
		-- 	sKey = "29_1"
		-- 	fTime = 9.8
			
		-- elseif nIndex == 7 then
		-- 	tPosEnd = cc.p(123, 1420)
		-- 	sKey = "29_2"
		-- 	fTime = 13
		-- elseif nIndex == 8 then
		-- 	tPosEnd = cc.p(349, 1309)
		-- 	sKey = "29_2"
		-- 	fTime = 9.7
		-- elseif nIndex == 9 then
		-- 	tPosEnd = cc.p(526, 1393)
		-- 	sKey = "29_1"
		-- 	fTime = 7.5
		-- elseif nIndex == 10 then
		-- 	tPosEnd = cc.p(604 - 5, 1277 + 20)
		-- 	fTime = 5.8
		-- 	sKey = "29_2"
		-- elseif nIndex == 11 then
		-- 	tPosEnd = cc.p(141, 1049)
		-- 	fTime = 22
		-- 	sKey = "29_2"
		-- elseif nIndex == 12 then
		-- 	tPosEnd = cc.p(299, 975)
		-- 	sKey = "29_2"
		-- 	fTime = 7
		end
		--设置数据
		if self.tXlbCircle2 and table.nums(self.tXlbCircle2) > 0 then
			for k, v in pairs (self.tXlbCircle2) do
				v:stop()
				local tPos = nil 
				-- if nTag == 0 then
				-- 	v:setFlippedX(false)
				-- 	-- v:setPosition(cc.p(self.pLayXlbCircle2:getWidth() / 2 + 15 ,self.pLayXlbCircle2:getHeight() / 2 ))
	
				-- elseif nTag == 1 then

					
				-- 	-- v:setPosition(cc.p(self.pLayXlbCircle2:getWidth() / 2 - 20 ,self.pLayXlbCircle2:getHeight() / 2 - 10 ))
				-- 	v:setFlippedX(true)
					
				-- end
				
				v:setData(tNormalCusArmDatas[sKey])
				v:play(-1)
			end
		end
		self:showXLBMoveActions(self.pLayXlbCircle2,fTime,tPosEnd,function (  )
			-- body
			self:showTXLTCircle2()
		end )
		--计数器加1
		self.pLayXlbCircle2.nCt = self.pLayXlbCircle2.nCt + 1
		-- if self.pLayXlbCircle2.nCt >= 13 then
		-- 	self.pLayXlbCircle2.nCt = 1
		-- end
	end
end
--巡逻兵城门上的 2.1 - 2.2
function HomeBaseLayer:showTXLT2(  )
	-- body
	if self.pLayXlbT2 and self.pLayXlbT2.nCt then
		local nIndex = self.pLayXlbT2.nCt % 2
		local fTime = 32 --时间32秒
		local tPosEnd = nil
		local sKey = "29_1"
		if nIndex == 1 then
			tPosEnd = cc.p(447, 752)
			sKey = "29_2"
		elseif nIndex == 0 then
			tPosEnd = cc.p(1194, 1116)
			sKey = "29_1"
		end
		--设置数据
		if self.tXlbT2 and table.nums(self.tXlbT2) > 0 then
			for k, v in pairs (self.tXlbT2) do
				v:stop()
				v:setData(tNormalCusArmDatas[sKey])
				v:play(-1)
			end
		end
		self:showXLBMoveActions(self.pLayXlbT2,fTime,tPosEnd,function (  )
			-- body
			self:showTXLT2()
		end )
		--计数器加1
		self.pLayXlbT2.nCt = self.pLayXlbT2.nCt + 1
	end
end
--巡逻兵城门上的 3.1 - 3.2
function HomeBaseLayer:showTXLST(  )
	-- body
	if self.pLayXlbST and self.pLayXlbST.nCt then
		local nIndex = self.pLayXlbST.nCt % 2
		local fTime = 41 --时间41秒
		local tPosEnd = nil
		local sKey = "29_1"
		if nIndex == 1 then
			tPosEnd = cc.p(1041, 744)
			sKey = "29_2"
		elseif nIndex == 0 then
			tPosEnd = cc.p(2001, 1208)
			sKey = "29_1"
		end
		--设置数据
		if self.tXlbST and table.nums(self.tXlbST) > 0 then
			for k, v in pairs (self.tXlbST) do
				v:stop()
				v:setData(tNormalCusArmDatas[sKey])
				v:play(-1)
			end
		end
		self:showXLBMoveActions(self.pLayXlbST,fTime,tPosEnd,function (  )
			-- body
			self:showTXLST()
		end )
		--计数器加1
		self.pLayXlbST.nCt = self.pLayXlbST.nCt + 1
	end
end

--巡逻兵上 6.1 - 6.2
function HomeBaseLayer:showTXLT(  )
	-- body
	if self.pLayXlbT and self.pLayXlbT.nCt then
		local nIndex = self.pLayXlbT.nCt % 2
		local fTime = 19 --时间19秒
		local tPosEnd = nil
		local sKey = "29_1"
		if nIndex == 1 then
			tPosEnd = cc.p(1891 , 1077)
			sKey = "29_2"
		elseif nIndex == 0 then
			tPosEnd = cc.p(2318, 1287 )
			sKey = "29_1"
		end
		--设置数据
		if self.tXlbT and table.nums(self.tXlbT) > 0 then
			for k, v in pairs (self.tXlbT) do
				v:stop()
				v:setData(tNormalCusArmDatas[sKey])
				v:play(-1)
			end
		end
		self:showXLBMoveActions(self.pLayXlbT,fTime,tPosEnd,function (  )
			-- body
			self:showTXLT()
		end )
		--计数器加1
		self.pLayXlbT.nCt = self.pLayXlbT.nCt + 1
	end
end

--巡逻兵下   5.1 - 5.2
function HomeBaseLayer:showTXLB(  )
	-- body
	if self.pLayXlbB and self.pLayXlbB.nCt then
		local nIndex = self.pLayXlbB.nCt % 2
		local fTime = 22 --时间22秒
		local tPosEnd = nil
		local sKey = "29_1"
		if nIndex == 0 then
			tPosEnd = cc.p(1004, 626 + 15)
			sKey = "29_2"
		elseif nIndex == 1 then
			tPosEnd = cc.p(1619, 928 + 15)
			sKey = "29_1"
		end
		--设置数据
		if self.tXlbB and table.nums(self.tXlbB) > 0 then
			for k, v in pairs (self.tXlbB) do
				v:stop()
				v:setData(tNormalCusArmDatas[sKey])
				v:play(-1)
			end
		end
		self:showXLBMoveActions(self.pLayXlbB,fTime,tPosEnd,function (  )
			-- body
			self:showTXLB()
		end )
		--计数器加1
		self.pLayXlbB.nCt = self.pLayXlbB.nCt + 1
	end
end

--巡逻兵中 4.1 - 4.2
function HomeBaseLayer:showTXLC(  )
	-- body
	if self.pLayXlbC and self.pLayXlbC.nCt then
		local nIndex = self.pLayXlbC.nCt % 2
		local fTime = 25 --时间25秒
		local tPosEnd = nil
		local sKey = "29_2"
		
		if nIndex == 1 then
			tPosEnd = cc.p(2400,624 )
			sKey = "29_2"
		elseif nIndex == 0 then
			tPosEnd = cc.p(1869, 868)
			sKey = "29_1"
		end
		--设置数据
		if self.tXlbC and table.nums(self.tXlbC) > 0 then
			for k, v in pairs (self.tXlbC) do
				v:stop()
				v:setData(tNormalCusArmDatas[sKey])
				v:play(-1)
			end
		end
		self:showXLBMoveActions(self.pLayXlbC,fTime,tPosEnd,function (  )
			-- body
			self:showTXLC()
		end )
		--计数器加1
		self.pLayXlbC.nCt = self.pLayXlbC.nCt + 1
	end
end

--巡逻兵走动动作
function HomeBaseLayer:showXLBMoveActions( _pLay, _fTime, _tPos, _handler)
	-- body
	if not _pLay or not _fTime or not _tPos then
		return
	end
	local actionMoveTo = cc.MoveTo:create(_fTime, _tPos)
	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		if _handler then
			_handler()
		end
	end)

	local allActions = cc.Sequence:create(actionMoveTo,actionEnd)
	_pLay:runAction(allActions)
	
end

--创建一个巡逻兵
--_nType 巡逻兵类  1：右下到左上  y++ 2：左上到右下  y--
function HomeBaseLayer:createOneXLB( _pLay,_nType )
	local pArmXLB = nil 
	if _nType == 1 then
	
		pArmXLB = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["29_1"], 
			_pLay, 
			10, 
			cc.p(0,0),
		    function ( _pArm )
		    	
		    end, Scene_arm_type.base)
	elseif _nType == 2 then
		pArmXLB = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["29_2"], 
			_pLay, 
			10, 
			cc.p(0,0),
		    function ( _pArm )
		    	
		    end, Scene_arm_type.base)
	end
	
	return pArmXLB
end

--乌云展示
function HomeBaseLayer:showBlackCloud(  )
	-- body
	if self.pArmBlackCloudA == nil then
		self.pArmBlackCloudA = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["30_1"], 
			self.pBaseContent, 
			9992, 
			cc.p(self.pBaseContent:getWidth() / 2,self.pBaseContent:getHeight() / 2),
		    function ( _pArm )
		    	_pArm.bFree = true
		    end, Scene_arm_type.base)
		self.pArmBlackCloudA.bFree = true
	end

	if self.pArmBlackCloudB == nil then
		self.pArmBlackCloudB = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["30_2"], 
			self.pBaseContent, 
			9992, 
			cc.p(self.pBaseContent:getWidth() / 2,self.pBaseContent:getHeight() / 2),
		    function ( _pArm )
		    	_pArm.bFree = true
		    end, Scene_arm_type.base)
		self.pArmBlackCloudB.bFree = true
	end

	local actionDelay = cc.DelayTime:create(5)
	local actionEnd = cc.CallFunc:create(function (  )
		-- body
		self:showOneBlackCloud()
	end)
	local allActions = cc.RepeatForever:create(cc.Sequence:create(actionDelay,actionEnd))
	self:runAction(allActions)

	self:showOneBlackCloud()

	--第一版
	-- if self.pImgBlackCloud == nil then
	-- 	self.pImgBlackCloud = MUI.MImage.new("ui/sg_heiyun_sa_zjm_001.png")
	-- 	self.pBaseContent:addView(self.pImgBlackCloud,9991)
	-- 	self.pImgBlackCloud:setOpacity(0.2 * 255) --设置透明度
	-- end
	-- --随机缩放值
	-- local fScale = (20 + math.random(-6, 6)) / 10
	-- self.pImgBlackCloud:setScale(fScale)
	-- -- 初始化位置
	-- self.pImgBlackCloud:setPosition(-self.pImgBlackCloud:getWidth() * fScale / 2, -self.pImgBlackCloud:getHeight() * fScale / 2)

	-- --随机时间
	-- local fTime = (200) + math.random(-5, 5) * 10
	-- --终点位置
	-- local fEndOffset = math.random(-10, 10) * 10
	-- local tEndPos = cc.p(4652 + self.pImgBlackCloud:getWidth() * fScale / 2 + fEndOffset,2258 + self.pImgBlackCloud:getHeight() * fScale / 2 + fEndOffset)
	-- --轨迹
	-- local actionMoveTo = cc.MoveTo:create(fTime, tEndPos)
	-- local actionEnd = cc.CallFunc:create(function (  )
	-- 	-- body
	-- 	self:showBlackCloud()
	-- end)
	-- local allActions = cc.Sequence:create(actionMoveTo,actionEnd)
	-- self.pImgBlackCloud:runAction(allActions)
end

--展示一个乌云
function HomeBaseLayer:showOneBlackCloud(  )
	-- body
	local pFreeArm = nil
	if self.pArmBlackCloudA and self.pArmBlackCloudA.bFree then
		pFreeArm = self.pArmBlackCloudA
	end

	if pFreeArm == nil then
		if self.pArmBlackCloudB and self.pArmBlackCloudB.bFree then
			pFreeArm = self.pArmBlackCloudB
		end
	end

	if pFreeArm then
		--随机位置
		local nPx = math.random(-16,16) * 100 + self.pBaseContent:getWidth() / 2
		local nPy = math.random(-45,45) * 10 + self.pBaseContent:getHeight() / 2
		pFreeArm:setPosition(cc.p(nPx,nPy))
		local nType = math.random(1,2)
		pFreeArm:setData(tNormalCusArmDatas["30_" .. nType])
		pFreeArm.bFree = false
		pFreeArm:play(1)
	end
end

--水特效
function HomeBaseLayer:showWaterTx(  )
	-- body
	for i = 1, 7 do
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["11_" .. i], 
			self.pBaseContent, 
			10, 
			cc.p(0,0),
		    function ( _pArm )

		    end, Scene_arm_type.base)
		if pArm then
			pArm:play(-1)
		end
	end
end

--鱼特效
function HomeBaseLayer:showFish(  )
	
	--跳鱼
	self:showJumpFish()

	--游鱼
	self:showSwimFish()
	
end

--跳鱼动画
function HomeBaseLayer:showJumpFish()

	self:showFirstPosFish()

	self:showSecPosFish()

	self:showThreePosFish()

	self:showFourPosFish()

end

--游鱼动画
function HomeBaseLayer:showSwimFish()

	
	self.tSwimFish = {}
	self.tLaySwimFish = {}
	if self.pLaySwimFish == nil  then
		self.pLaySwimFish = MUI.MLayer.new()
		self.pLaySwimFish:setLayoutSize(1, 1)
		self.pBaseContent:addView(self.pLaySwimFish,100)
	end
	
	for i=1,23 do
		local pLayFish  = MUI.MLayer.new()
		pLayFish:setLayoutSize(1, 1)
		self.pBaseContent:addView(pLayFish,100)
	
			local pFish = self:createOneFish(3,pLayFish)
			table.insert(self.tSwimFish,pFish)
			table.insert(self.tLaySwimFish,pLayFish)
		-- end
		
	end
	
	
	self:setSwimFishShowTime()
	

end

--设置游鱼的出现时间
function HomeBaseLayer:setSwimFishShowTime(  )
	-- local tPos = {
	-- 	cc.p(298,234 + 100),cc.p(279,251 + 100),cc.p(894,194+ 100),cc.p(921,182+ 100),cc.p(750,195+ 100),cc.p(1788,614+ 100),cc.p(1847,590+ 100),
	-- 	cc.p(1788,585+ 100),cc.p(1734,582+ 100),cc.p(2226,820+ 100),cc.p(2267,827+ 100),cc.p(2169,795+ 100),cc.p(2186,751+ 100),cc.p(2691,1146+ 100),
	-- 	cc.p(2733,1128+ 100),cc.p(2803,1115+ 100),cc.p(2734,1096+ 100),cc.p(2155,1551+ 100),cc.p(2279,1547+ 100),cc.p(2054,1615+ 100),cc.p(2124,1586+ 100),
	-- 	cc.p(3651,683+ 100),cc.p(3668,392+ 100),cc.p(3999,523+ 100),cc.p(3969,500),cc.p(3927,501+ 100),
	-- }
	-- 	local tPos = {
	-- 	cc.p(298,234 + 100),cc.p(279,251 + 100),cc.p(894,194+ 100),cc.p(921,182+ 100),cc.p(750,195+ 100),cc.p(1788,614+ 100),cc.p(1847,590+ 100),
	-- 	cc.p(1788,585+ 100),cc.p(1734,582+ 100),cc.p(2226,820+ 100),cc.p(2267,827+ 100),cc.p(2169,795+ 100),cc.p(2186,751+ 100),
	-- 	cc.p(2733,1128+ 100),cc.p(2734,1096+ 100),cc.p(2155,1551+ 100),cc.p(2279,1547+ 100),cc.p(2124,1586+ 100),
	-- 	cc.p(3651,683+ 100),cc.p(3668,392+ 100),cc.p(3999,500+ 100),cc.p(3969,500),cc.p(3927,501+ 100),
	-- }
	local tPos = {
		cc.p(298,234 + 100),cc.p(279,251 + 100),cc.p(894,194+ 100),cc.p(921,182+ 100),cc.p(750,195+ 100),cc.p(1788,614+ 100),cc.p(1847,590+ 100),
		cc.p(1788,585+ 100),cc.p(1734,582+ 100),cc.p(2226,820+ 100),cc.p(2267,827+ 100),cc.p(2169,795+ 100),cc.p(2186,751+ 100),
		cc.p(2679,1136+ 100),cc.p(2733,1128+ 100),cc.p(2803,1115+ 100),cc.p(2734,1096+ 100),cc.p(2155,1551+ 100),
		cc.p(2279,1547+ 100),cc.p(2054,1615+ 100),cc.p(2124,1586+ 100),cc.p(3651,683),cc.p(3668,392+ 100),
	}
	local tRotation = {0,0,-24,-24,0,0,-15,0,0,0,0,0,0,0,-31,37,0,0,-17,17,0,0,-11,142,142,142}

	local tScale = {
		{ x = 1,	y = 1},  --1
		{ x = 0.6, 	y = 0.6},  --2
		{ x = 1,	y = 1},  --3
		{ x = 0.7, 	y = 0.7},  --4
		{ x = 1, 	y = -1},  --5
		{ x = 1, 	y = -1},  --6
		{ x = -0.7, y = 0.7},  --7
		{ x = -1, 	y = 1},  --8
		{ x = 0.8,	y = -0.8},  --9
		{ x = 1, 	y = -1},  --10
		{ x = -0.7, y = 0.7},  --11
		{ x = -1, 	y = 1},  --12
		{ x = 0.8, 	y = -0.8},  --13
		{ x = 1, 	y = -1},  --14
		{ x = -0.7, y = 0.7},  --15
		{ x = -1, 	y = 1},  --16
		{ x = 0.8, 	y = -0.8},  --17
		{ x = 1, 	y = 1},  --18
		{ x = -1, 	y = -1},  --19
		{ x = -1, 	y = -1},  --20
		{ x = 0.6, 	y = 0.6},  --21
		{ x = -0.8, y = -0.8},  --22
		{ x = 0.8, 	y = -0.8},  --23
		{ x = 1, 	y = 1},  --24
		{ x = 0.6, 	y = 0.6},  --25
		{ x = 0.6, 	y = -0.6},  --26

	}	

	if self.tSwimFish and table.nums(self.tSwimFish) > 0 then
		for i=1,table.nums(self.tSwimFish) do
			
			if self.tSwimFish[i] then
				self.tSwimFish[i]:setScaleX(tScale[i].x)
				self.tSwimFish[i]:setScaleY(tScale[i].y)
				self.tSwimFish[i]:setRotation(tRotation[i])
		
		
				self.tLaySwimFish[i]:setPosition(tPos[i])
				
				
				--[[
				所有的游鱼动画中，需要将1/3的鱼改成黑色。   
				可以挑选鱼文件中的3,6,9,12,15,18,21,24,25.位置的鱼改成黑色。
				]]--
				if (i % 3) == 0 or (i == 25 ) then 
					self.tSwimFish[i]:runAction(cc.TintTo:create(1, 1, 1, 1))
				end
				local nTime = math.random(1,15)
				
				self:performWithDelay(function(  )
					self:setOneFishTime(self.tSwimFish[i])
				end,nTime)
			end
			
			
		end
		
	end
end

--设置每一条鱼的出现时间，每一条鱼的出现时间间隔（1,15）秒这个随机时间里面
function HomeBaseLayer:setOneFishTime(_pFish)
	if not _pFish then
		return 
	end
	
	_pFish:play(1)
	_pFish:setMovementEventCallFunc(function (  )
		local nTime = math.random(1,15)
		self:performWithDelay(function (  )
			self:setOneFishTime(_pFish)
		end,nTime)
	end)
end

--第一个位置跳鱼
function HomeBaseLayer:showFirstPosFish()

    self:performWithDelay( function()
        local nScale = math.random(0.85, 1.10)
        local nOffset = math.random(-40, 40)
        if self.pLayFirstFish == nil then
            local pLayFirstFish = MUI.MLayer.new()
            pLayFirstFish:setLayoutSize(1, 1)
            local pFish = self:createOneFish(1, pLayFirstFish) 
            pFish:stop()  
            pFish:setVisible(false)
            pFish:setScale(nScale)
            pFish:setMovementEventCallFunc( function(_pArm)
                _pArm:setVisible(false)
                self:showFirstPosFish()
            end )
            pLayFirstFish.pFishArm = pFish

            self.pBaseContent:addView(pLayFirstFish, 100)
            self.pLayFirstFish = pLayFirstFish
        end
        self.pLayFirstFish:setPosition(2176 + nOffset, 778 + 100+ nOffset)
        self.pLayFirstFish.pFishArm:setVisible(true)
        self.pLayFirstFish.pFishArm:play(1)

    end , 10)

end

--第二个位置跳鱼
function HomeBaseLayer:showSecPosFish()

    self:performWithDelay( function()
        local nScale = math.random(0.7, 1.1)
        local nOffset = math.random(-25, 25)
        local nRandom = math.random(1, 2)

        if self.pLaySecFish == nil then
            local pLaySecFish = MUI.MLayer.new()
            pLaySecFish:setLayoutSize(1, 1)
            pLaySecFish.tFishArm = { }
            for i = 1, 2 do
                local pFish = self:createOneFish(i, pLaySecFish)
                pFish:stop()
                pFish:setVisible(false)
                pFish:setScale(nScale)
                pFish:setMovementEventCallFunc( function(_pArm)
                    _pArm:setVisible(false)
                    self:showSecPosFish()
                end )
                pLaySecFish.tFishArm[i] = pFish
            end
            self.pBaseContent:addView(pLaySecFish, 100)
            self.pLaySecFish = pLaySecFish
        end

        self.pLaySecFish:setPosition(2711 + nOffset, 1125 + 100 + nOffset) 
        self.pLaySecFish.tFishArm[nRandom]:setVisible(true)       
        self.pLaySecFish.tFishArm[nRandom]:play(1)
    end , 13)

end

--第3个位置跳鱼
function HomeBaseLayer:showThreePosFish()

    self:performWithDelay( function()
        local nScale = math.random(0.6, 1)
        local nOffset = math.random(-40, 40)
        local nRandom = math.random(1, 2)
        if self.pLayThreeFish == nil then
            local pLayThreeFish = MUI.MLayer.new()
            pLayThreeFish:setLayoutSize(1, 1)
            pLayThreeFish.tFishArm = { }
            for i = 1, 2 do
                local pFish = self:createOneFish(i, pLayThreeFish)
                pFish:stop()
                pFish:setVisible(false)
                pFish:setScale(nScale)
                pFish:setMovementEventCallFunc( function(_pArm)
                    _pArm:setVisible(false)
                    self:showThreePosFish()
                end )
                pLayThreeFish.tFishArm[i] = pFish
            end
            
            self.pBaseContent:addView(pLayThreeFish, 100)
            self.pLayThreeFish = pLayThreeFish
        end

        self.pLayThreeFish:setPosition(2289 + nOffset, 1524 + 100 + nOffset)
        self.pLayThreeFish.tFishArm[nRandom]:setVisible(true)
        self.pLayThreeFish.tFishArm[nRandom]:play(1)
        --print("=====================showThreePosFish()")
    end , 8)

end

--第4个位置跳鱼
function HomeBaseLayer:showFourPosFish()

    self:performWithDelay( function()
        local nScale = math.random(0.8, 1)
        local nOffset = math.random(-20, 20)
        local nRandom = math.random(1, 2)
        if self.pLayFourFish == nil then
            local pLayFourFish = MUI.MLayer.new()
            pLayFourFish:setLayoutSize(1, 1)
            pLayFourFish.tFishArm = { }
            for i = 1, 2 do
                local pFish = self:createOneFish(i, pLayFourFish)
                pFish:stop()
                pFish:setVisible(false)
                pFish:setScale(nScale)
                pFish:setMovementEventCallFunc( function(_pArm)
                    _pArm:stop()
                    _pArm:setVisible(false)
                    self:showFourPosFish()
                end )
                pLayFourFish.tFishArm[i] = pFish
            end

            self.pBaseContent:addView(pLayFourFish, 100)
            self.pLayFourFish = pLayFourFish
        end

        self.pLayFourFish:setPosition(3897 + nOffset, 457 + 100 + nOffset)
        self.pLayFourFish.tFishArm[nRandom]:setVisible(true)
        self.pLayFourFish.tFishArm[nRandom]:play(1)
    end , 15)

end


--创建鱼
--_nType 1.白色跳鱼 2.红色跳鱼 3.白色游鱼
function HomeBaseLayer:createOneFish( _nType,_pLay )	
	_nType = _nType or 0
	local pFish = nil 
	if _nType == 1  then
		pFish = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["45_1"], 
				_pLay, 
				10, 
				cc.p(0, 0),
                nil, 
                Scene_arm_type.base)
		
	elseif _nType == 2 then
		
		pFish = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["45_2"], 
				_pLay, 
				10, 
				cc.p(0, 0),
			    nil, 
                Scene_arm_type.base)
	elseif _nType == 3 then
		
		pFish = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["45_3"], 
				_pLay, 
				10, 
				cc.p(0, 0),
                nil, 
                Scene_arm_type.base)
	
	end
	-- if pFish then
	-- 	pFish:play(-1)
	-- end
	
	return pFish

	
end

--移除一个建筑
function HomeBaseLayer:removeOnrBuildGroup(  sMsgName, pMsgObj )
	-- body
	if pMsgObj then
	 	local nCell = pMsgObj.nCell
	 	if nCell then
	 		if nCell > n_start_suburb_cell then --资源田
	 			if self.tAllSuburbGroups and table.nums(self.tAllSuburbGroups) > 0 then
	 				local nSize = table.nums(self.tAllSuburbGroups)
	 				for i = nSize, 1, -1 do
	 					--获得当前建筑数据
	 					local tBuildData = self.tAllSuburbGroups[i]:getCurData()
	 					if tBuildData and tBuildData.nCellIndex == nCell then
	 						self.tAllSuburbGroups[i]:removeSelf()
	 						table.remove(self.tAllSuburbGroups, i)
	 						break
	 					end
	 				end
	 			end
	 		else 								--城内建筑
	 			if self.tAllBuildGroups and table.nums(self.tAllBuildGroups) > 0 then
	 				local nSize = table.nums(self.tAllBuildGroups)
	 				for i = nSize, 1, -1 do
	 					--获得当前建筑数据
	 					local tBuildData = self.tAllBuildGroups[i]:getCurData()
	 					if tBuildData and tBuildData.nCellIndex == nCell then
	 						self.tAllBuildGroups[i]:removeSelf()
	 						table.remove(self.tAllBuildGroups, i)
	 						break
	 					end
	 				end
	 			end
	 		end
	 	end
	end
end

function HomeBaseLayer:onBuildsTaskGuide( sMsgName, pMsgObj )
	-- body
	local nTaskID = pMsgObj.nTaskID
	local pTaskData = Player:getPlayerTaskInfo():getTaskDataById(nTaskID)
	local tParam1 = luaSplit(pTaskData.sTarget, ":") 
	local nLV = tonumber(tParam1[2])--多建筑升级的等级目标
	local tParam2 = luaSplit(pTaskData.sLinked, ":")
	local tPos = luaSplit(tParam2[2], "|")
	if #tPos <= 0 then
		return
	end	
	local nPos = nil
	for k, v in pairs(tPos) do
		nPos = tonumber(v)
		local tBuildGroup = self:getBuildGroupByCell(nPos)	
		if tBuildGroup then
			local tBuildInfo = tBuildGroup.tBuildInfo
			if tBuildInfo and nLV > tBuildInfo.nLv then
				break
			end
		end		
	end
	if nPos then
		local pObj = {}
		pObj.nCell = nPos
		pObj.nFunc = function (  )
			-- body
			pObj.nBtnType = 1	--任务引导升级按钮	
			sendMsg(ghd_task_build_actionbtn_msg, pObj)
		end
		sendMsg(ghd_move_to_build_dlg_msg, pObj)
		print("ghd_task_build_actionbtn_msg  55555555555555555555")
		
	end
end

function HomeBaseLayer:moveToCollectedSuburb(  )
	-- body
	local tSuburb = nil
	--获取可征收资源的资源建筑
	if self.tAllSuburbGroups and table.nums(self.tAllSuburbGroups) > 0 then
		table.sort( self.tAllSuburbGroups, function ( a, b )
			-- body
			return a.tBuildInfo.nCellIndex < b.tBuildInfo.nCellIndex
		end )
		for k, v in pairs (self.tAllSuburbGroups) do
			if v.tBuildInfo and v.tBuildInfo.nColState ~= 0 then
				tSuburb = v
				break
			end
		end 
	end
	if tSuburb then		
		local nCell = tSuburb.tBuildInfo.nCellIndex
		local tPos = self:getPositionByCellForScale(nCell)
		if tPos then
			local tScreenPoint = self:adjustMovePoint(tPos)
			self:movePointToScreenPoint(tPos,tScreenPoint)
		end			
		if tSuburb.pBubbleLayer and tSuburb.pBubbleLayer:isVisible() then
			--任务手指特效
			showTaskFinger(tSuburb.pBubbleLayer, 0.8)
		end
	else
		TOAST(getTipsByIndex(20010))
	end
end

function HomeBaseLayer:addHeroTravel( )
	-- body
	--这里要获得数据
	if not self.pHeroTravel then 
		
		self.pHeroTravel = HeroTravel.new()
		self.pHeroTravel:setPosition(548,350)
		self.pBaseContent:addView(self.pHeroTravel,self.nMaxBuildZorder - self.pHeroTravel:getPositionY())
	end
end

return HomeBaseLayer