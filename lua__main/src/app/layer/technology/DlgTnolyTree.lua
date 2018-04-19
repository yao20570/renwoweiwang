-----------------------------------------------------
-- author: wangxs
-- updatetime:   2017-05-11 18:07:02 星期四
-- Description: 科技树
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemTreeTnoly = require("app.layer.technology.ItemTreeTnoly")
local ItemTechnology = require("app.layer.technology.ItemTechnology")



local DlgTnolyTree = class("DlgTnolyTree", function()
	-- body
	return DlgBase.new(e_dlg_index.tnolytree)
end)

function DlgTnolyTree:ctor(_tData)
	-- body
	self:myInit(_tData)

	self:setupViews()
	self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("DlgTnolyTree",handler(self, self.onDlgTnolyTreeDestroy))

end

--初始化成员变量
function DlgTnolyTree:myInit(_tData)
	-- body
	self.nSelRow 			= 		-1   		--选中的行 -1表示没选择
	self.tSelItemTnoly 		= 		nil 		--选中的科技项
	self.tAllItemTree 		= 		{} 			--科技树item集合
	self.tSelectData        =       _tData      --选中的科技


	--科技树张啥样（策划青山说这里写死就好，他也不知道热3为啥这样排，以后改打死他）
	-- s：表示开始位置
	-- c：表示数量
	self.tTreePos 			= 		{
										{s = 2,c = 3},
										{s = 1,c = 3},
										{s = 2,c = 3},
										{s = 1,c = 4},
										{s = 2,c = 3},
										{s = 2,c = 3},
										{s = 4,c = 1},
										{s = 4,c = 1},
										{s = 3,c = 2},
										{s = 1,c = 4},
										{s = 4,c = 1}
									}

	self.tStartPos 			= 		cc.p(0,0) 	--开始触摸位置

end

function DlgTnolyTree:setCurSelectTnoly(_tData)
	-- body
	self.tSelectData        =       _tData      --选中的科技
end

--初始化控件
function DlgTnolyTree:setupViews( )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(1, 10171))
	self:setBgImg("ui/v2_bg_kejizonglan.jpg")

	--新建一个SCrollLayer
	self.pScrollLayer = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, 640, 2266),
	    touchOnContent = false,
	    direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
	self:addContentView(self.pScrollLayer,false)
	self.pScrollLayer:setBounceable(true)
	--注册监听事件
	self.pScrollLayer:onScroll(handler(self, self.onScrollLayerEvent))

	--分帧加载
	self:scheduleOnceAddTnoly(table.nums(self.tTreePos))
end


-- 修改控件内容或者是刷新控件数据
function DlgTnolyTree:updateViews(  )
	-- body
	--刷新数据
	self:refreshSvItem()
	
	--移除特殊项
	self:removeSepItem()

	self:clickCurSelected()
end

function DlgTnolyTree:clickCurSelected()
	-- body
	--如果有选中的科技则触发点击
	if self.tSelectData then

		for k, v in pairs(self.tAllItemTree) do
			local tData = v:getCurData()
			if tData.sTid == self.tSelectData.sTid then
				self.tSelItemTnoly = v
				--移动到某行
				self.pScrollLayer:scrollToPosition(v.nRow, false)
				self:onTnolyClicked(v, true)
			end
		end
	else
		self.pScrollLayer:scrollToBegin(false)
	end
end

-- 析构方法
function DlgTnolyTree:onDlgTnolyTreeDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgTnolyTree:regMsgs( )
	-- body
	-- 注册建筑状态变化的消息
	regMsg(self, gud_build_state_change_msg, handler(self, self.changeBuildState))
	-- 注册玩家等级变化的消息
	regMsg(self, ghd_refresh_playerlv_msg, handler(self, self.onPlayerLvChange))
	-- 注册科技数据变化消息
	regMsg(self, gud_refresh_tnoly_lists_msg, handler(self, self.onRefresh))
end

-- 注销消息
function DlgTnolyTree:unregMsgs(  )
	-- body
	-- 销毁建筑状态变化的消息
	unregMsg(self, gud_build_state_change_msg)
	-- 销毁玩家等级变化的消息
	unregMsg(self, ghd_refresh_playerlv_msg)
	-- 销毁科技数据变化消息
	unregMsg(self, gud_refresh_tnoly_lists_msg)
end


--暂停方法
function DlgTnolyTree:onPause( )
	-- body
	self:unregMsgs()

	if self.nAddScheduler then
        MUI.scheduler.unscheduleGlobal(self.nAddScheduler)
        self.nAddScheduler = nil
	end
	self:unscheduleOnceRefreshTnoly()
	self.tSelectData        =       nil      --选中的科技

end

--继续方法
function DlgTnolyTree:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

-- 每帧加载
function DlgTnolyTree:scheduleOnceAddTnoly( nMax)
    local nIndex = 1
    self.nAddScheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
    	local tT = self.tTreePos[nIndex]
    	--每一行内容层
    	local pLayContent = MUI.MLayer.new()
    	pLayContent:setLayoutSize(640, 206)
    	self.pScrollLayer:addView(pLayContent, 10)
    	--结束位置
    	local nEnd = tT.c + tT.s - 1
    	for i = tT.s, nEnd do
    		if nIndex == 5 and i == 4 then
    			self.pLineSpe = MUI.MLayer.new()
    			self.pLineSpe:setLayoutSize(4, 206)
    			self.pLineSpe:setBackgroundImage("#v1_line_green.png",{scale9 = true,capInsets=cc.rect(2,3, 1, 1)})
    			--设置位置
    			self.pLineSpe:setPositionX((i - 1) * 160 + (160 - self.pLineSpe:getWidth()) / 2)
    			pLayContent:addView(self.pLineSpe)
    		else
    			local pItem = ItemTreeTnoly.new()
    			--设置点击事件不可穿透
    			pItem:setTouchCatchedInList(true)
    			pItem.nRow = nIndex  --第几行
    			pItem.sKey = nIndex .. "_" .. i --key关键字
    			pItem:setPositionX((i - 1) * pItem:getWidth())
    			pLayContent:addView(pItem)
    			--设置数据
    			pItem:setCurData(Player:getTnolyData():getTnolyByKeyFromAll(nIndex .. "_" .. i))
    			pItem:setTnolyClickCallBack(handler(self, self.onTnolyClicked))
    			--添加到集合列表中
    			self.tAllItemTree[pItem.sKey] = pItem

    			--处理特殊项
    			if nIndex == 6 and i == 4 then 
    				if pItem:getCurData():checkisLocked() then
    					self.pLineSpe:setBackgroundImage("#v1_line_red.png",{scale9 = true,capInsets=cc.rect(2,3, 1, 1)})
    				else
    					self.pLineSpe:setBackgroundImage("#v1_line_green.png",{scale9 = true,capInsets=cc.rect(2,3, 1, 1)})
    				end
    			end
    		end
    	end
    	nIndex = nIndex + 1
    	if self ~= nil and self.nAddScheduler ~= nil and nIndex > nMax then
            MUI.scheduler.unscheduleGlobal(self.nAddScheduler)
            self.nAddScheduler = nil
            self:clickCurSelected()
    	end
    end)
end

--刷新列表数据
function DlgTnolyTree:refreshSvItem( )
	-- body
	local nSize = table.nums(self.tAllItemTree)
	for k, v in pairs (self.tAllItemTree) do
		v:setCurData(Player:getTnolyData():getTnolyByKeyFromAll(v.sKey))
		if v.sKey == "6_4" then
			if v:getCurData():checkisLocked() then
    			self.pLineSpe:setBackgroundImage("#v1_line_red.png",{scale9 = true,capInsets=cc.rect(2,3, 1, 1)})
    		else
    			self.pLineSpe:setBackgroundImage("#v1_line_green.png",{scale9 = true,capInsets=cc.rect(2,3, 1, 1)})
    		end
		end
	end
end

--科技项点击事件回调
function DlgTnolyTree:onTnolyClicked( pView, bJustShow )
	if bJustShow then
		bJustShow = false
	else
		--如果该项重复选择，那么不需要重复移除和生成
		if self.tSelItemTnoly and self.tSelItemTnoly.sKey == pView.sKey then
			print("直接返回")
			return
		end
	end
	--存在选择行
	if self.nSelRow ~= -1 then
		--移除特殊项
		self.pScrollLayer:removeView(self.nSelRow)
		self.pSepItem = nil
	end
	--存在选中项
	if self.tSelItemTnoly then
		self.tSelItemTnoly:setSelectedState(false)
		self.tSelItemTnoly = nil
	end
	--记录行
	self.nSelRow = pView.nRow + 1
	--记录选中项
	self.tSelItemTnoly = self.tAllItemTree[pView.sKey]
	self.tSelItemTnoly:setSelectedState(true)

	local tCurData = pView:getCurData()
	local nType = 2
	if tCurData and tCurData:checkisLocked() then
		nType = 3
	end
	--生产详情item
	self.pSepItem = ItemTechnology.new(nType)
	--设置点击事件不可穿透
	self.pSepItem:setTouchCatchedInList(true)
	--设置数据
	self.pSepItem:setCurData(self.tSelItemTnoly:getCurData())
	--插入对应位置
	if self.nSelRow > table.nums(self.tTreePos) then
		self.pScrollLayer:addView(self.pSepItem)
		self.pScrollLayer:scrollToEnd(true)
	else
		self.pScrollLayer:insertView(self.pSepItem,self.nSelRow)
	end
end

--科技消息回调刷新
function DlgTnolyTree:onRefresh()
	-- body
	--如果有正在打开的科技项就刷新一下
	if self.pSepItem then
		self.pSepItem:setCurData(self.tSelItemTnoly:getCurData())
	end
end

--注册scrolllayer监听事件
function DlgTnolyTree:onScrollLayerEvent( event )
	-- body
	if event.name == "began" then
		--记录开始位置
		self.tStartPos.x = event.x
		self.tStartPos.y = event.y
	elseif event.name == "ended" then
		local nDis =  math.sqrt((self.tStartPos.x - event.x)
								* (self.tStartPos.x - event.x) 
								+ (self.tStartPos.y - event.y) 
								* (self.tStartPos.y - event.y))
		if nDis > 0 then
			self:removeSepItem()
		end
	elseif event.name == "clicked" then
		self:removeSepItem()
	end
end

--移除特殊项
function DlgTnolyTree:removeSepItem(  )
	-- body
	--存在选中项
	if self.tSelItemTnoly then
		self.tSelItemTnoly:setSelectedState(false)
		self.tSelItemTnoly = nil
	end
	if self.nSelRow ~= -1 then
		--移除特殊项
		self.pScrollLayer:removeView(self.nSelRow)
		self.nSelRow = -1
		self.pSepItem = nil
	end
end

--建筑状态发生变化
function DlgTnolyTree:changeBuildState( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nCell = pMsgObj.nCell
		if nCell == e_build_ids.tnoly then --科技院
			self:unscheduleOnceRefreshTnoly()
			self:scheduleOnceRefreshTnoly(table.nums(self.tAllItemTree))
		end
	end
end

--玩家等级变化
function DlgTnolyTree:onPlayerLvChange( sMsgName, pMsgObj )
	-- body
	self:unscheduleOnceRefreshTnoly()
	self:scheduleOnceRefreshTnoly(table.nums(self.tAllItemTree))
end

-- 每帧刷新数据
function DlgTnolyTree:scheduleOnceRefreshTnoly( nMax)
    local nIndex = 1
    self.nRefreshScheduler = MUI.scheduler.scheduleUpdateGlobal(function (  )
    	local tKeys = table.keys(self.tAllItemTree)
    	local pItemTnoly = self.tAllItemTree[tKeys[nIndex]]
    	if pItemTnoly then
    		--设置锁住状态
    		pItemTnoly:setLockedState()
    	end
    	nIndex = nIndex + 1
    	if self ~= nil and self.nRefreshScheduler ~= nil and nIndex > nMax then
            self:unscheduleOnceRefreshTnoly()
    	end
    end)
end

--取消每帧刷新
function DlgTnolyTree:unscheduleOnceRefreshTnoly(  )
	-- body
	if self.nRefreshScheduler then
        MUI.scheduler.unscheduleGlobal(self.nRefreshScheduler)
        self.nRefreshScheduler = nil
	end
end

return DlgTnolyTree