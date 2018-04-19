----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-24 11:39:27
-- Description: 城池首杀 已杀
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local nJoinPlayerHeight = 128
local LayCityFirstBloodStart = require("app.layer.cityfirstblood.LayCityFirstBloodStart")
local LayCityFirstBloodReward = require("app.layer.cityfirstblood.LayCityFirstBloodReward")
local LayCityFirstBloodKilled = class("LayCityFirstBloodKilled", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LayCityFirstBloodKilled:ctor(  )
	--解析文件
	parseView("lay_city_first_blood_killed", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LayCityFirstBloodKilled:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayCityFirstBloodKilled", handler(self, self.onLayCityFirstBloodKilledDestroy))
end

-- 析构方法
function LayCityFirstBloodKilled:onLayCityFirstBloodKilledDestroy(  )
    self:onPause()
end

function LayCityFirstBloodKilled:regMsgs(  )
end

function LayCityFirstBloodKilled:unregMsgs(  )
end

function LayCityFirstBloodKilled:onResume(  )
	self:regMsgs()
	-- self:updateViews()
end

function LayCityFirstBloodKilled:onPause(  )
	self:unregMsgs()
end

function LayCityFirstBloodKilled:setupViews(  )
	local pLayReward = self:findViewByName("lay_reward")
	self.pReward = LayCityFirstBloodReward.new()
	pLayReward:addView(self.pReward)
	centerInView(pLayReward, self.pReward)
	self.pLayScrollView = self:findViewByName("lay_scrollview")

	--滑动层
	self.pSv = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, self.pLayScrollView:getWidth(), self.pLayScrollView:getHeight()),
		        touchOnContent = false,
		        direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
	self.pLayScrollView:addView(self.pSv)

	--滑动层
	self.pSv:onScroll(function ( event )
		local sEvent = event.name
    	if sEvent == "moved" then
    		if not self.nUpdateScheduler then
	    		--更新地表
				self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(function ()
					local nY = self.pSv.scrollNode:getPositionY()
					if self.nPrevY ~= nY then
						self.nPrevY = nY
						self:refreshVisibleJoinLine()
					end
				end,0.02)
			end
    	elseif sEvent == "scrollEnd" then
    		if self.nUpdateScheduler then
			    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
			    self.nUpdateScheduler = nil
			end
			self:refreshVisibleJoinLine()
    	end
    end)

	-- --发起玩家
	local pLayStart = self:findViewByName("lay_start")
	self.pCFBloodStart = LayCityFirstBloodStart.new()
	pLayStart:addView(self.pCFBloodStart)

	-- self.pTxtName = self:findViewByName("txt_name")
	-- self.pLayIcon = self:findViewByName("lay_icon")

	--滚动层显示的行数及起始位置
    self.nShowJoinFBerLine = math.ceil((self.pSv:getHeight() - self.pCFBloodStart:getContentSize().height)/nJoinPlayerHeight) + 1
	self.tFBerLine = {}
	self.tFBerLineIdle = {}

    --上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pSv:setUpAndDownArrow(pUpArrow, pDownArrow)
end

function LayCityFirstBloodKilled:updateViews(  )

	self:updateStartView()

end

function LayCityFirstBloodKilled:updateStartView(  )
	-- body
	-- local tActorVo = self.tCityFirstBloodVO.tStartFBer:getActorVo()
	-- if tActorVo then
	-- 	if not self.pIcon then
	-- 		self.pIcon = getIconGoodsByType(self.tCityFirstBloodVO.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.header, tActorVo, TypeIconHeroSize.L)
	-- 		-- centerInView(self.pLayIcon,self.pIcon)
	-- 		self.pIcon:setPosition(0, 0)
	-- 	else
	-- 		self.pIcon:setCurData(tActorVo)
	-- 	end
	-- 	-- if pIcon then
	-- 	-- 	pIcon:setMoreText(self.tCityFirstBloodVO.tStartFBer.sName)
	-- 	-- end
	-- 	self.pTxtName:setString(self.tCityFirstBloodVO.tStartFBer.sName)
	-- end
	self.pCFBloodStart:setData(self.tCityFirstBloodVO.tStartFBer)
	self.pCFBloodStart:setAttkCountry(self.tCityFirstBloodVO.nStartCountry)
end

--初始化
function LayCityFirstBloodKilled:initJoinFBerLayer( )
	if not self.tCityFirstBloodVO then
		return
	end

	--重置空闲
	self:pushToIdleFBerLine()
	self.nPrevY = nil

	--删除层
	if self.pLayJoinFBer then
		self.pSv:removeView(self.pLayJoinFBer)
		self.pLayJoinFBer = nil
	end

	--创建层	
	local tJoinFBerList = self.tCityFirstBloodVO.tJoinFBerList
	self.tJoinFBerList = tJoinFBerList
	self.nJoinFBerLine = math.ceil(#tJoinFBerList/4) --大最行数
	local nHeight = math.max(self.nJoinFBerLine * nJoinPlayerHeight, self.pSv:getHeight() - self.pCFBloodStart:getContentSize().height)
	self.pLayJoinFBer = MUI.MLayer.new()
	self.pLayJoinFBer:setContentSize(self.pLayScrollView:getWidth(), self.pLayScrollView:getHeight())
	self.pSv:addView(self.pLayJoinFBer)

	--如果没有参与的玩家
	if #tJoinFBerList == 0 then
	 	local pTxtNoJoinTip = MUI.MLabel.new({text = getConvertedStr(3, 10541), size = 20})
	 	self.pLayJoinFBer:addView(pTxtNoJoinTip)
	 	centerInView(self.pLayJoinFBer, pTxtNoJoinTip)	
	end

	--应该放在里面
	self.pSv:scrollToBegin(false)

	--刷新参与者行
	self:refreshVisibleJoinLine()
end

--tCityFirstBloodVO
function LayCityFirstBloodKilled:setData( tCityFirstBloodVO )
	self.tCityFirstBloodVO = tCityFirstBloodVO
	if self.tCityFirstBloodVO then
		self.pReward:setData(self.tCityFirstBloodVO.nCityType)
		-- self.pCFBloodStart:setData(self.tCityFirstBloodVO.tStartFBer)
		-- self.pCFBloodStart:setCountry(self.)
	end
	self:initJoinFBerLayer()
	self:updateViews()

end

--
function LayCityFirstBloodKilled:refreshVisibleJoinLine( )
	--算起始下标
	local nTopY = self.pSv.scrollNode:getPositionY() + self.pLayJoinFBer:getPositionY() + self.pLayJoinFBer:getHeight()
	local nCanTopY = self.pLayScrollView:getHeight()
	-- print("nTopY, nCanTopY = ", nTopY, nCanTopY, (nTopY - nCanTopY))
	--显示的起始下标值
	local nBeginIdex = math.floor((nTopY - nCanTopY)/nJoinPlayerHeight) + 1
	-- print("nBeginIdex========",nBeginIdex)
	if nBeginIdex < 1 then
		nBeginIdex = 1
	end
	--显示的终点下标值
	-- print("nBeginIdex + self.nShowJoinFBerLine==========",nBeginIdex , self.nShowJoinFBerLine,nBeginIdex + self.nShowJoinFBerLine)
	local nEndIndex = nBeginIdex + self.nShowJoinFBerLine
	if nEndIndex > self.nJoinFBerLine then
		nEndIndex = self.nJoinFBerLine
	end
	--收集回闲置列表
	self:pushToIdleFBerLineByIndex(nBeginIdex, nEndIndex)
	--添加到当前列表中
	local tCurrDict = {}
	for i=1,#self.tFBerLine do
		if self.tFBerLine[i] then
			local nIndex = self.tFBerLine[i].nIndex
			tCurrDict[nIndex] = true
		end
	end
	-- print("nBeginIdex, nEndIndex======",nBeginIdex, nEndIndex)
	local nTopH = self.pLayJoinFBer:getHeight()
	for i=nBeginIdex, nEndIndex do
		if not tCurrDict[i] then
			local pFBerLine = self:getFBerLineFromIdle()
			self:setFBerLine(pFBerLine, i)
			self.pLayJoinFBer:addView(pFBerLine)
			pFBerLine:setPosition(0, nTopH - (i * nJoinPlayerHeight))
		end
	end
end

--将当前有用到的参与玩家行推回闲置
function LayCityFirstBloodKilled:pushToIdleFBerLine(  )
	for i=1,#self.tFBerLine do
		local pFBerLine = self.tFBerLine[i]
		table.insert(self.tFBerLineIdle, pFBerLine)
		pFBerLine:removeFromParent()
	end
	self.tFBerLine = {}
end

--
function LayCityFirstBloodKilled:pushToIdleFBerLineByIndex( nBeginIdex, nEndIndex )
	--倒序
	for i = #self.tFBerLine, 1, -1 do
		local pFBerLine = self.tFBerLine[i]
		local nIndex = pFBerLine.nIndex
		if nIndex < nBeginIdex or nIndex > nEndIndex then
			pFBerLine:removeFromParent()
			table.remove(self.tFBerLine, i)
			table.insert(self.tFBerLineIdle, pFBerLine)
		end
	end
end

function LayCityFirstBloodKilled:getFBerLineFromIdle( )
	--从空闲列表获取队像
	local pFBerLine = nil
	local nCount = #self.tFBerLineIdle
	if nCount > 0 then
		pFBerLine = self.tFBerLineIdle[nCount]
		table.remove(self.tFBerLineIdle, nCount)
	end
	if not pFBerLine then
		pFBerLine = MUI.MLayer.new()	
		pFBerLine:retain()
		pFBerLine:setContentSize(640, nJoinPlayerHeight)
		--
		-- print("create line")
		local nX, nY = 45, 0
		local nOffsetX = 86 + 68
		for i=1,4 do
			local pLayIcon = MUI.MLayer.new()
			pLayIcon:setContentSize(86, 86)
			pLayIcon:setPosition(nX, nY)
			pFBerLine["pLayIcon"..i] = pLayIcon
			pFBerLine:addView(pLayIcon)
			nX = nX + nOffsetX
		end
	end
	table.insert(self.tFBerLine, pFBerLine)
	return pFBerLine
end

function LayCityFirstBloodKilled:setFBerLine( pFBerLine, nLineIndex)
	if not pFBerLine or not nLineIndex then
		return
	end
	pFBerLine.nIndex = nLineIndex
	local nBeginIndex = (nLineIndex - 1) * 4
	for i=1,4 do
		local nIndex = nBeginIndex + i
		local tFBer = self.tJoinFBerList[nIndex]
		local pLayIcon = pFBerLine["pLayIcon"..i]
		if tFBer then
			local tActorVo = tFBer:getActorVo()
			if tActorVo then
				local pIcon = getIconGoodsByType(pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.header, tActorVo, TypeIconHeroSize.M)
				if pIcon then
					pIcon:setMoreText(tFBer.sName)
					if tFBer.nAid == Player:getPlayerInfo().pid then
						pIcon:setIconSelected(true)
					else
						pIcon:setIconSelected(false)
					end
				end
			end
			pLayIcon:setVisible(true)
		else
			pLayIcon:setVisible(false)
		end
	end	
end

return LayCityFirstBloodKilled


