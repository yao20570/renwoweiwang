----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-13 14:40:26
-- Description: 世界大地图右上角小地图
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local BlockMapLayer = require("app.layer.world.BlockMapLayer")

local nMapZorder = 1
local nCityZorder = 2
local nLocalZorder = 999

--世界地图界面
local WorldSmallMap = class("WorldSmallMap", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WorldSmallMap:ctor(  )
	--解析文件
	parseView("layout_world_small_map", handler(self, self.onParseViewCallback))
end

--解析界面回调
function WorldSmallMap:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldSmallMap",handler(self, self.onWorldSmallMapDestroy))
end

-- 析构方法
function WorldSmallMap:onWorldSmallMapDestroy(  )
    self:onPause()
end

function WorldSmallMap:regMsgs(  )
	-- 大地图视图移动
	regMsg(self, ghd_world_view_pos_msg, handler(self, self.onWorldViewPosMsg))

	-- 区域视图点刷新
	regMsg(self, gud_world_block_dots_msg, handler(self, self.updateBlockDots))

	-- 区域视图城池内占领发生变化
	regMsg(self, gud_block_city_occupy_change_push_msg, handler(self, self.updateBlockSysCitySCOI))

	-- 视图点更新
	regMsg(self, ghd_smallmap_search_around_msg, handler(self, self.onSearchAround))

	-- 迁城
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.onUpdateMyPos))

	-- 是否开启视图点数据刷新
	regMsg(self, ghd_world_block_dots_msg_switch, handler(self, self.onBlockDotsSwitch))

	-- 重连成功之后要强制更新当前视图点
	regMsg(self, gud_reconnect_success, handler(self, self.onReconnectSuccess))

	-- 回到前台超过一定时间要进行更新
	regMsg(self, ghd_world_war_line_req, handler(self, self.onWarLineReq))
end

function WorldSmallMap:unregMsgs(  )
	-- 大地图视图移动
	unregMsg(self, ghd_world_view_pos_msg)

	-- 区域视图点刷新
	unregMsg(self, gud_world_block_dots_msg)

	-- 区域视图城池内占领发生变化
	unregMsg(self, gud_block_city_occupy_change_push_msg)

	-- 视图点更新
	unregMsg(self, ghd_smallmap_search_around_msg)

	-- 迁城
	unregMsg(self, gud_world_my_city_pos_change_msg)

	-- 是否开启视图点数据刷新
	unregMsg(self, ghd_world_block_dots_msg_switch)

	-- 重连成功之后要强制更新当前视图点
	unregMsg(self, gud_reconnect_success)

	unregMsg(self, ghd_world_war_line_req)
end

function WorldSmallMap:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.checkReqBlockData))
end

function WorldSmallMap:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
	if self.nAddcheduler then
		MUI.scheduler.unscheduleGlobal(self.nAddcheduler)
		self.nAddcheduler = nil
	end
	if self.nAddcheduler2 then
		MUI.scheduler.unscheduleGlobal(self.nAddcheduler2)
		self.nAddcheduler2 = nil
	end
end

function WorldSmallMap:setupViews(  )
	--显示区域
	self.pLayWorld = self:findViewByName("lay_world")
	self.pLayWorld:setBackgroundImage("ui/daitu.png")


	--点击区域 
	local pTouchLayer = MUI.MLayer.new(true)
	pTouchLayer:setContentSize(self.pLayWorld:getContentSize())
	self.pLayWorld:addView(pTouchLayer)
	pTouchLayer:setViewTouched(true)
	pTouchLayer:onMViewClicked(handler(self, self.onBlockClicked))

	--显示区域位置
	self.pLbPos = self:findViewByName("lb_pos")
	self.pLbPos:enableOutline(cc.c4b(0, 0, 0, 255),2)

	--遮罩
	local pSize = self.pLayWorld:getContentSize()
	self.pClip = display.newClippingRegionNode(cc.rect(0,0,pSize.width,pSize.height))
	self.pLayWorld:addChild(self.pClip)
	self.fMiddleX, self.fMiddleY = pSize.width/2,pSize.height/2

	--内容层
	self.pLayWorldContent = MUI.MLayer.new()
	self.pClip:addChild(self.pLayWorldContent)

	--当前选中框位置
	local pImgViewLocal = MUI.MImage.new("#v1_img_quyukuang.png")
	pImgViewLocal:setAnchorPoint(0.5,0.5)
	local nX, nY = self.pLayWorld:getPosition()
	local pSize = self.pLayWorld:getContentSize()
	self:addView(pImgViewLocal, nLocalZorder)
	pImgViewLocal:setPosition(nX + pSize.width/2, nY + pSize.height/2)
end

function WorldSmallMap:updateViews(  )
	
end

--更新世界内容
function WorldSmallMap:updateWorldContent(  )
	--解锁状态
	local bIsUnLock = Player:getWorldData():getBlockIsCanSee(self.nBlockId)	
	--相同的根据情况不进行刷新
	if self.nBgMapBlockId == self.nBlockId then	
		--是否解锁状态相同
		if bIsUnLock == self.bIsBgMapBlockIdUnLock then	
			return
		end
	end

	--记录id，记录状态
	self.nBgMapBlockId = self.nBlockId
	self.bIsBgMapBlockIdUnLock = bIsUnLock
	
	--地图背景
	if not self.pBlockMap then
		self.pBlockMap = BlockMapLayer.new(1)
		self.pLayWorldContent:addView(self.pBlockMap)
	end
	self.pBlockMap:setData(self.nBlockId)

	--地图大小
	local pSize = self.pBlockMap:getContentSize()
	self.pLayWorldContent:setContentSize(pSize)

	--更新我的位置
	self:onUpdateMyPos()

	--区域数据请求检测
	self:blockDataReqCheck()
end

--世界视图坐标转化为区域视图坐标
-- fX:在世界视图x坐标
-- fY:在世界视图y坐标
--return fX,fY:在区域视图坐标
function WorldSmallMap:parseWorldToBlock( fX, fY)
	if self.pBlockMap then
		fX, fY = WorldFunc.parseWorldToBlock(self.pBlockMap:getContentSize(), fX, fY)
		if fX then
			return fX, fY
		end
	end
	return 0, 0
end

--大地图位置刷新
function WorldSmallMap:onWorldViewPosMsg( sMsgName, pMsgObj )
	if pMsgObj then
		--坐标点
		self.nDotX ,self.nDotY = pMsgObj.nDotX, pMsgObj.nDotY

		--区域id
		self.nBlockId = pMsgObj.nBlockId
		if not self.nBlockId then
			self.pLayWorldContent:setVisible(false)
			self.pLbPos:setString(getConvertedStr(3, 10441))
			return
		end
		
		--所在区域位置名称
		local strPos = ""
		-- local pWorldMapData =  getWorldMapDataById(self.nBlockId)
		-- if pWorldMapData and pWorldMapData.name then
		-- 	strPos = pWorldMapData.name
		-- end
		self.pLbPos:setString(getBlockShowName(self.nBlockId))

		--未解锁
		local bIsUnLock = Player:getWorldData():getBlockIsCanSee(self.nBlockId)
		if bIsUnLock then
			--更新内容
			self:updateWorldContent()
			self.pLayWorldContent:setVisible(true)
		else
			self.pLayWorldContent:setVisible(false)
		end

		--修正至显示窗口的中心点
		local fX,fY = self:parseWorldToBlock(pMsgObj.fViewCX, pMsgObj.fViewCY)
		self.pLayWorldContent:setPosition(fX * -1 + self.fMiddleX, fY * -1 + self.fMiddleY)
		self.fViewCX = pMsgObj.fViewCX
		self.fViewCY = pMsgObj.fViewCY
	end
end


--视图点发生变化立即刷新
function WorldSmallMap:onSearchAround( sMsgName, pMsgObj )
	if pMsgObj then
		local nBlockId = pMsgObj[1]
		local tNullGrid = pMsgObj[2]
		local tBlockCityDots = pMsgObj[3]
		local tBlockSysCityDots = pMsgObj[4]
		local tBlockBossDots = pMsgObj[5]
		local tBlockZhouDots = pMsgObj[6]
		--容错
		if not nBlockId then
			return
		end
		--不是当前地图不处理
		if self.nBlockId ~= nBlockId then
			return
		end

		--清空已存在点
		if tNullGrid then
			if self.pBlockMap then
				self.pBlockMap:hideGridBySearchAround(tNullGrid)
			end
		end

		--更新已存在玩家城池点
		if tBlockCityDots then
			if self.pBlockMap then
				self.pBlockMap:updateImgCityBySearchAround(tBlockCityDots)
			end
		end

		--更新已存在系统城池点
		if tBlockSysCityDots then
			if self.pBlockMap then
				self.pBlockMap:updateBlockSysCityDots(tBlockSysCityDots)
			end
		end

		--更新已存在Boss
		if tBlockBossDots then
			if self.pBlockMap then
				self.pBlockMap:updateImgBossBySearchAround(tBlockBossDots)
			end
		end
		--更新已存在的纣王
		if tBlockZhouDots then
			if self.pBlockMap then
				self.pBlockMap:updateImgZhouBySearchAround(tBlockZhouDots)
			end
		end
	end
end

--区域地图
function WorldSmallMap:onBlockClicked( pView )
	--保存数据
	local nBlockId = nil
	local tRangeData = WorldFunc.getBlockRangeData(self.nDotX, self.nDotY)
	if tRangeData then
		nBlockId = tRangeData.nBlockId
	end
	local fViewCX = self.fViewCX
	local fViewCY = self.fViewCY
	local tData = {
		nBlockId = nBlockId,
		fViewCX = fViewCX,
		fViewCY = fViewCY,
	}
	Player:getWorldData():saveSamllMapClickedData(tData)

	--打开区域界面
    local tObject = {
    	nType = e_dlg_index.blockmap, --dlg类型
	    nDotX = self.nDotX,
	    nDotY = self.nDotY,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end


--区域数据请求
function WorldSmallMap:blockDataReqCheck( bIsForce )
	--容错
	if not self.nBlockId then
		return
	end
	--没有选择国家就返回
	if not isSelectedCountry() then
		return
	end

	if bIsForce then
		--强制请求不拦接
	else
		--拦截上一次请求的区
		if self.nReqBlockId == self.nBlockId then
			return
		end
	end

	--记录当前请求的点
	self.nReqBlockId = self.nBlockId
	
	--清空除当前区域的其他行军推送线路
	Player:getWorldData():delTaskMovePushExcept(self.nBlockId)

	-- 新角色的话，延迟40帧执行刷新
	if(NEW_ROLE) then
		scheduleOnceCallback(self, function (  )
			SocketManager:sendMsg("reqWorldBlock", {self.nBlockId}, handler(self, self.onReqWorldBlock),-1)
		end, 40)
		NEW_ROLE = false
	else
		SocketManager:sendMsg("reqWorldBlock", {self.nBlockId}, handler(self, self.onReqWorldBlock) ,-1)
	end
end

--区域数据请求返回
function WorldSmallMap:onReqWorldBlock( __msg, __oldMsg )
	if  __msg.head.state == SocketErrorType.success then 
		--数据已经在WorldController层进行存储
    else
    	--出错时，置空上一次的线路
       	self.nReqBlockId = nil
    end
end

--区域数据城池占领发生变化
function WorldSmallMap:updateBlockSysCitySCOI( sMsgName, pMsgObj )
	-- print("updateBlockSysCitySCOI=============", pMsgObj)
	if pMsgObj then
		if self.pBlockMap then
			self.pBlockMap:updateBlockSysCitySCOI(pMsgObj)
		end
	end
end

--区域数据发生变化（请求数据回来）
function WorldSmallMap:updateBlockDots( sMsgName, pMsgObj )
	if not self.nBlockId then
		return
	end

	if self.bIsOpenBlockDotsUpdate == false then
		return
	end

	if self.nBlockId == pMsgObj then
		if self.pBlockMap then
			self.pBlockMap:updateBlockDots()
		end
	end
end

--更新我的位置
function WorldSmallMap:onUpdateMyPos( )
	if self.pBlockMap then
		self.pBlockMap:updateMyPos()
	end
end

--检测请求当前数据
function WorldSmallMap:checkReqBlockData( )
	--容错
	if not self.nBlockId then 
		return
	end
	--没有选择国家就返回
	if not isSelectedCountry() then
		return
	end
	--没有请求过就返回
	local nLoadBlockSecond = Player:getWorldData():getLoadBlockSecond()
	if not nLoadBlockSecond then
		return
	end

	--发送请求(当==0时候才请求)
	if nLoadBlockSecond == 0 then
		SocketManager:sendMsg("reqWorldBlock", {self.nBlockId}, nil,-1)
	end
	nLoadBlockSecond = nLoadBlockSecond - 1
	Player:getWorldData():setLoadBlockSecond(nLoadBlockSecond)
end

function WorldSmallMap:onBlockDotsSwitch( sMsgName, pMsgObj )
	self.bIsOpenBlockDotsUpdate = pMsgObj
end

function WorldSmallMap:onReconnectSuccess( sMsgName, pMsgObj )
	self:blockDataReqCheck(true)
end

function WorldSmallMap:onWarLineReq( )
	self:blockDataReqCheck(true)
end

return WorldSmallMap

