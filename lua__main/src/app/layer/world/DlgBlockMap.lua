----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-14 17:08:51
-- Description: 区域地图对话框
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local BlockMapLayer = require("app.layer.world.BlockMapLayer")

--区域地图对话框
local DlgBlockMap = class("DlgBlockMap", function()
	return DlgBase.new(e_dlg_index.blockmap)
end)

function DlgBlockMap:ctor(  )
	parseView("dlg_world_block_map", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgBlockMap:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10012))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBlockMap",handler(self, self.onDlgBlockMapDestroy))
end

-- 析构方法
function DlgBlockMap:onDlgBlockMapDestroy(  )
    self:onPause()

    --允许小地图刷新
    sendMsg(ghd_world_block_dots_msg_switch, true)
end

function DlgBlockMap:regMsgs(  )
	regMsg(self, gud_world_center_city_capture_msg, handler(self, self.onUpdateFlag))
	-- regMsg(self, gud_world_block_dots_msg, handler(self, self.updateBlockDots))
	regMsg(self, gud_block_city_occupy_change_push_msg, handler(self, self.updateBlockSysCitySCOI))
	regMsg(self, gud_block_city_war_change_push_msg, handler(self, self.updateBlockSysCityCWOV))
end

function DlgBlockMap:unregMsgs(  )
	unregMsg(self, gud_world_center_city_capture_msg)
	-- unregMsg(self, gud_world_block_dots_msg)
	unregMsg(self, gud_block_city_occupy_change_push_msg)
	unregMsg(self, gud_block_city_war_change_push_msg)
end

function DlgBlockMap:onResume(  )
	self:regMsgs()
end

function DlgBlockMap:onPause(  )
	self:unregMsgs()
end

function DlgBlockMap:setupViews(  )
	--是否隐藏玩家
	self.bIsHidePlayer = false

	self.pImgFlag = self:findViewByName("img_flag")

	--文本设置
	self.pTxtName = self:findViewByName("txt_name")
	local pTxtCountryName = self:findViewByName("txt_country_name")
	local pTxtCountryName2 = self:findViewByName("txt_country_name2")
	local pTxtCountryName3 = self:findViewByName("txt_country_name3")
	local pTxtCountryName4 = self:findViewByName("txt_country_name4")
	pTxtCountryName:setString(getCountryShortName(e_type_country.shuguo))
	pTxtCountryName2:setString(getCountryShortName(e_type_country.weiguo))
	pTxtCountryName3:setString(getCountryShortName(e_type_country.wuguo))
	pTxtCountryName4:setString(getCountryShortName(e_type_country.qunxiong))

	--隐藏玩家
	local pImgHidePlayer = self:findViewByName("img_hide_player")
	pImgHidePlayer:setViewTouched(true)
	pImgHidePlayer:onMViewClicked(handler(self, self.onHidePlayerClicked))
	--按钮
	local pLayBtnWorld = self:findViewByName("lay_btn_world")
	local pBtnWorld = getCommonButtonOfContainer(pLayBtnWorld,TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10115))
	pBtnWorld:onCommonBtnClicked(handler(self, self.onBtnWorldClicked))

	--滚动地图
	self.pLayWorldContent = self:findViewByName("lay_map")

	local pLayBg = self:findViewByName("lay_top")
	--我的位置
	local MImgLabel = require("app.common.button.MImgLabel")
	local pImgLabel = MImgLabel.new({text="", size=20, parent=pLayBg})
	pImgLabel:setImg("#v1_img_weizhi.png", 1)
	pImgLabel:followPos("center", pLayBg:getContentSize().width/2, pLayBg:getContentSize().height/2)
	self.pImgLabel = pImgLabel
end

function DlgBlockMap:updateViews(  )
	--旗子
	self:onUpdateFlag()

	--地图名字
	self.pTxtName:setString(getConvertedStr(3, 10441))
	if self.nBlockId then
		self.pTxtName:setString(getBlockShowName(self.nBlockId))
		-- local tBlockData = getWorldMapDataById(self.nBlockId)
		-- if tBlockData then
		-- 	--获得所属州
		-- 	local tCity=getWorldMapDataById(tBlockData.subordinate)
		-- 	if tCity then 
		-- 		self.pTxtName:setString(tCity.abridge .. "·".. tBlockData.name)
		-- 	else
		-- 		self.pTxtName:setString(tBlockData.name)
		-- 	end
			
		-- end
	end

	--我的信息
	local nX, nY = Player:getWorldData():getMyCityDotPos()
	local nBlockId = WorldFunc.getBlockId(nX, nY)
	if nBlockId then
		local tBlockData = getWorldMapDataById(nBlockId)
		if tBlockData then
			local tStr = {
				{color=_cc.pwhite, text= getConvertedStr(3, 10108)},
    			{color=_cc.blue, text= tBlockData.name.." "},
    			{color=_cc.pwhite, text= getConvertedStr(3, 10109)},
    			{color=_cc.blue, text= string.format(getConvertedStr(3, 10114), nX, nY)},
			}
			self.pImgLabel:setString(tStr)
		end
	end	
end

--视图坐标点
--nDotX:视图点坐标x
--nDotY:视图点坐标y
function DlgBlockMap:setData( nDotX, nDotY)
	self.nBlockId = nil

	--区域数据
	local tRangeData = WorldFunc.getBlockRangeData(nDotX, nDotY)
	if tRangeData then
		self.tRangeData = tRangeData
		self.nBlockId = tRangeData.nBlockId
		self.nDotX =  nDotX
		self.nDotY =  nDotY

		--显示框数据
		local tClickedData  = Player:getWorldData():getSamllMapClickedData()
		if tClickedData then
			if self.nBlockId == tClickedData.nBlockId then
				self.fViewCX = tClickedData.fViewCX
				self.fViewCY = tClickedData.fViewCY
			end
		end
	end



	--滚动地图
	if not self.pBlockMap then
		self.pBlockMap = BlockMapLayer.new(2)

		--创建scrollView
		local pSize = self.pLayWorldContent:getContentSize()
		local pBothSize = self.pBlockMap:getContentSize()
	    self.pSView = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, pSize.width, pSize.height),
		    touchOnContent = false,
	    	direction=MUI.MScrollLayer.DIRECTION_BOTH,
		    bothSize= cc.size(pBothSize.width, pBothSize.height), --znftodo 不知为毛要加偏移量
		    speed = {x = 0.01, y = 0.01},
		    })
	    self.pLayWorldContent:addView(self.pSView)
		self.pSView:addView(self.pBlockMap)
		self.pSView:setBounceable(false) --是否开启回弹功能
		self.pSView:onScroll(function ( event )
			local sEvent = event.name
			local fX = event.x
			local fY = event.y
			if sEvent == "clicked" then
				--滚动面板坐标系不是BlockMapLayer里面的pLayContent的坐标系，所以要进行转换
				local fX2, fY2 = self.pBlockMap:getPosition()
				local fX3, fY3 = self.pBlockMap.pLayContent:getPosition()
				local fPosX, fPosY = fX - fX2 - fX3, fY - fY2 - fY3
				--第二次转为是为了容易点击到玩家城池或系统城池
				local _fPosX, _fPosY = self.pBlockMap:getClickedCityDot(fPosX, fPosY)
				if _fPosX and _fPosY then
					fPosX = _fPosX
					fPosY = _fPosY
					sendMsg(ghd_world_location_mappos_msg, {fX = fPosX, fY = fPosY, isClick = true})
					self:closeDlg(false)
				else
					local fPosX, fPosY = self.pBlockMap:parseBlockToWorld(fPosX, fPosY)
					sendMsg(ghd_world_location_mappos_msg, {fX = fPosX, fY = fPosY, isClick = true})
					self:closeDlg(false)
				end
			end
		end)
		--移动中心位置
		local bIsMoveDefault = true
		if self.fViewCX and self.fViewCY then
			local fX1, fY1 = self.pBlockMap:parseWorldToBlock(self.fViewCX, self.fViewCY)
			if fX1 and fY1 then
				local fX2, fY2 = self.pBlockMap:getPosition()
				local fX3, fY3 = self.pBlockMap.pLayContent:getPosition()
				local fX, fY = fX1 + fX2 + fX3, fY1 + fY2 + fY3
				local fScrollX, fScrollY = self:getSViewScrollToPos(self.pSView, fX, fY)
				self.pSView:scrollTo(fScrollX, fScrollY, false)
				bIsMoveDefault = false
			end
		end
		if bIsMoveDefault then
			local fScrollX, fScrollY = self:getSViewScrollToPos(self.pSView)
			self.pSView:scrollTo(fScrollX, fScrollY, false)
		end
	end

	--更新公共信息
	self:updateViews()

	--请求数据
	if self.nBlockId then
		SocketManager:sendMsg("reqWorldBlock", {self.nBlockId}, function()
			if self.pBlockMap then
				self.pBlockMap:setData(self.nBlockId, self.fViewCX, self.fViewCY)
			end
		end)
	else
		self.pBlockMap:setData(nil)
	end
end

--获取移动到中心的点
function DlgBlockMap:getSViewScrollToPos( pScrollView, nCurPosX, nCurPosY )
	local pRect = pScrollView:getViewRect()
	local nCanSeeWidth = pRect.width
	local nCanSeeHeight = pRect.height
	local nInnerWidth = pScrollView:getScrollNode():getContentSize().width
	local nInnerHeight = pScrollView:getScrollNode():getContentSize().height

	if not nCurPosX or not nCurPosY then
		return (nCanSeeWidth - nInnerWidth)/2, 0
	end

	nCurPosX = nCurPosX - nCanSeeWidth/2
	nCurPosY = nCurPosY - nCanSeeHeight/2

	if nCurPosX < 0 then
		nCurPosX = 0
	end
	if nCurPosX > nInnerWidth - nCanSeeWidth then
		nCurPosX = nInnerWidth - nCanSeeWidth
	end
	if nCurPosY < 0 then
		nCurPosY = 0
	end
	if nCurPosY > nInnerHeight - nCanSeeHeight then
		nCurPosY = nInnerHeight - nCanSeeHeight
	end
	return -nCurPosX, -nCurPosY
end



----------------------------------------------------按钮事件
--点击世界地图
function DlgBlockMap:onBtnWorldClicked( pView )
	local tObject = {
	    nType = e_dlg_index.worldmap, --dlg类型
	    nDotX = self.nDotX,
	    nDotY = self.nDotY,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)

	self:closeDlg(false)
end

--隐藏玩家
function DlgBlockMap:onHidePlayerClicked( pView )
	self.bIsHidePlayer = not self.bIsHidePlayer
	if self.pBlockMap then
		self.pBlockMap:setHidePlayer(self.bIsHidePlayer)
	end
	if self.bIsHidePlayer then
		pView:setCurrentImage("#v1_img_pingbi.png")
	else
		pView:setCurrentImage("#v1_img_bupingbi.png")
	end
end

--更新国旗
function DlgBlockMap:onUpdateFlag(  )
	self.pImgFlag:setVisible(false)
	if self.nBlockId then
		local tBlockData = getWorldMapDataById(self.nBlockId)
		if tBlockData then
			--旗子
			WorldFunc.setImgCountryFlag(self.pImgFlag, Player:getWorldData():getMainCityCaptureCountry(tBlockData.maincity))
			self.pImgFlag:setVisible(true)
		end
	end
end

--区域数据发生变化
function DlgBlockMap:updateBlockDots( )
	if self.pBlockMap then
		self.pBlockMap:updateBlockDots()
	end
end

--区域数据城池占领发生变化
function DlgBlockMap:updateBlockSysCitySCOI( sMsgName, pMsgObj )
	if pMsgObj then
		if self.pBlockMap then
			self.pBlockMap:updateBlockSysCitySCOI(pMsgObj)
		end
	end
end

--区域数据城池进攻发生变化
function DlgBlockMap:updateBlockSysCityCWOV( sMsgName, pMsgObj )
	if pMsgObj then
		if self.nBlockId == pMsgObj then
			if self.pBlockMap then
				self.pBlockMap:updateBlockSysCityCWOV()
			end
		end
	end
end


return DlgBlockMap