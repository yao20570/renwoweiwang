----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-12-05 13:44:38
-- Description: 世界搜索面板
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local DlgWorldSearch = class("DlgWorldSearch", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function DlgWorldSearch:ctor(  )
	--解析文件
	self.bIsCanTouch = true
	parseView("dlg_world_search", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWorldSearch:onParseViewCallback( pView )
	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWorldSearch", handler(self, self.onDlgWorldSearchDestroy))
end

-- 析构方法
function DlgWorldSearch:onDlgWorldSearchDestroy(  )
    self:onPause()
end

function DlgWorldSearch:regMsgs(  )
	--我的城池坐标发生改变
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.onChangePos))
end

function DlgWorldSearch:unregMsgs(  )
	--我的城池坐标发生改变
	unregMsg(self, gud_world_my_city_pos_change_msg)
end

function DlgWorldSearch:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgWorldSearch:onPause(  )
	self:unregMsgs()
end

function DlgWorldSearch:setupViews(  )
	--空白层
	self.pLayDefault				= 		self:findViewByName("lay_close")
	self.pLayDefault:setViewTouched(true)
	self.pLayDefault:setIsPressedNeedScale(false)
	self.pLayDefault:setIsPressedNeedColor(false)

	self.pLayDefault:onMViewClicked(handler(self, self.onClosed))

	self.pTxtTitle = self:findViewByName("txt_title")
	self.pTxtLv = self:findViewByName("txt_lv")
	self.pLayBar = self:findViewByName("lay_bar")

	self.pSliderBar = MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_9.png"}, 
        {scale9 = true, touchInButton=false})
        :onSliderValueChanged(function(event) -- 进度值发生变化的回调
        	if not self.tLvPercent then
        		return
        	end
			for nLv,v in pairs(self.tLvPercent) do
				local fPercent1 = v.fPercent1
				local fPercent3 = v.fPercent3
				if event.percent >= fPercent1 and event.percent <= fPercent3 then
					if self.nSearchLv ~= nLv then
	        			self:setSearchLv(nLv, true)
	        		end
	        		break
				end
			end
        end)
    self.pSliderBar:setSliderSize(300, 18)
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.pLayBar:addView(self.pSliderBar)

    --减少按钮
	local pLayBtnSub = self:findViewByName("lay_btn_sub")
	self.pBtnMinus 					= 			getSepButtonOfContainer(pLayBtnSub,TypeSepBtn.MINUS,TypeSepBtnDir.right)
	self.pBtnMinus:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息

	--增加按钮
	local pLayBtnAdd = self:findViewByName("lay_btn_add")
	self.pBtnPlus 					= 			getSepButtonOfContainer(pLayBtnAdd,TypeSepBtn.PLUS,TypeSepBtnDir.left)
	self.pBtnPlus:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息

	--前往按钮
	local pLayBtnGo = self:findViewByName("lay_btn_go")
	local pBtnGo = getCommonButtonOfContainer(pLayBtnGo,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10549))
	pBtnGo:onCommonBtnClicked(handler(self, self.onGoBtnClicked))
	self.pBtnGo = pBtnGo

	--生成5个目标按钮
	local tTargetBtnData = {
		{id = e_type_search.wildArmy , img = "#v1_img_luanjun_lv5_7.png", scale = 0.5, name = getConvertedStr(3, 10080)},
		{id = e_type_search.inn , img = "#11008_img_hd.png", scale = 0.4, name = getConvertedStr(3, 10544)},
		{id = e_type_search.mill , img = "#11009_img_hd.png", scale = 0.4, name = getConvertedStr(3, 10545)},
		{id = e_type_search.farm , img = "#11010_img_hd.png", scale = 0.43, name = getConvertedStr(3, 10546)},
		{id = e_type_search.iron , img = "#11011_img_hd.png", scale = 0.44, name = getConvertedStr(3, 10547)},
		{id = e_type_search.gold , img = "#v1_img_jin.png", scale = 0.7, name = getConvertedStr(3, 10548)},
	}
	self.tTargetBtn = {}
	local nX, nY, nOffsetX = 32, 210, 99
	for i=1,#tTargetBtnData do
		local v = tTargetBtnData[i]
		local k = tTargetBtnData[i].id
		local pImgBg = MUI.MImage.new("#v2_img_zhangjiejianglidi_fb_b.png")
		local pLayBg = MUI.MLayer.new()
		local pSize = pImgBg:getContentSize()
		pLayBg:setPosition(nX, nY)
		nX = nX + nOffsetX
		pLayBg:setContentSize(pSize)
		pLayBg:addView(pImgBg)
		centerInView(pLayBg, pImgBg)
		self.pView:addView(pLayBg, 1)
		self.tTargetBtn[k] = pLayBg

		local pImgIcon = MUI.MImage.new(v.img)
		pLayBg:addView(pImgIcon)
		centerInView(pLayBg, pImgIcon)
		pImgIcon:setScale(v.scale)

		local pTxtName = MUI.MLabel.new({text = v.name, size = 20})
		pLayBg:addView(pTxtName)
		pTxtName:setPosition(pSize.width/2, - 20)

		pLayBg:setViewTouched(true)
		pLayBg:setIsPressedNeedScale(false)
		pLayBg:setIsPressedNeedColor(false)
		pLayBg:onMViewClicked(function( )
			self:setSelectedType(k)
		end)
	end

	--选中框
	self.pImgSelected = MUI.MImage.new("#v2_img_xuanzhon.png")
	self.pView:addView(self.pImgSelected, 0)
end

function DlgWorldSearch:updateViews(  )
	--把未开启的置灰
	for nSearchType, pLayBtn in pairs(self.tTargetBtn) do
		local tLvRange = Player:getWorldData():getWorldSearchLvRange(nSearchType)
		if tLvRange then
			pLayBtn:setToGray(false)
		else
			pLayBtn:setToGray(true)
		end
	end
end

--设置搜索等级
--bIsSilder 是否进度条
function DlgWorldSearch:setSearchLv( nLv, bIsSilder )
	self.nSearchLv = nLv

	--等级范围
	setTextCCColor(self.pTxtLv, _cc.blue)
	self.pBtnGo:setBtnEnable(true)
	local tLvRange = Player:getWorldData():getWorldSearchLvRange(self.nSearchType)
	if tLvRange then
		local nLvMin = tLvRange[1]
		local nLvMax = tLvRange[2]
		if self.nSearchLv < nLvMin then
			self.nSearchLv = nLvMin
		end
		if self.nSearchLv > nLvMax then
			self.nSearchLv = nLvMax
		end

		--设置
		Player:getWorldData():setWorldSearchLv(self.nSearchType, self.nSearchLv)

		if not bIsSilder then
			local tPercentData = self.tLvPercent[self.nSearchLv]
			if tPercentData then
				self.pSliderBar:setSliderValue(tPercentData.fPercent2)
			else
				print("度表不存在")
			end
		end


		--设置标签
		local sTitleStr = ""
		local nSearchLv = self.nSearchLv 
		if self.nSearchType == e_type_search.wildArmy then --乱军
			local tData = getWorldEnemyDataByLv(nSearchLv)
			if tData then
				if Player:getWorldData():getCanAtkWildArmyLv() < self.nSearchLv then--不够等级更改颜色
					sTitleStr = getConvertedStr(3, 10550)
					setTextCCColor(self.pTxtLv, _cc.red)
					self.pBtnGo:setBtnEnable(false)
				else
					sTitleStr = tData.searchdesc
				end
			end
		elseif self.nSearchType == e_type_search.inn then --客栈
			local tData = getWorldMineDataByTypeAndLv(e_type_mines.inn, nSearchLv)
			if tData then
				sTitleStr = tData.searchdesc
			end
		elseif self.nSearchType == e_type_search.mill then --木厂
			local tData = getWorldMineDataByTypeAndLv(e_type_mines.mill, nSearchLv)
			if tData then
				sTitleStr = tData.searchdesc
			end
		elseif self.nSearchType == e_type_search.farm then --农场
			local tData = getWorldMineDataByTypeAndLv(e_type_mines.farm, nSearchLv)
			if tData then
				sTitleStr = tData.searchdesc
			end
		elseif self.nSearchType == e_type_search.iron then --铁矿
			local tData = getWorldMineDataByTypeAndLv(e_type_mines.iron, nSearchLv)
			if tData then
				sTitleStr = tData.searchdesc
			end
		elseif self.nSearchType == e_type_search.gold then --金矿
			local tData = getWorldMineDataByTypeAndLv(e_type_mines.gold, nSearchLv)
			if tData then
				sTitleStr = tData.searchdesc
			end
		end
		self.pTxtTitle:setString(sTitleStr)
	end

	--上一次搜索等级
	self.pTxtLv:setString(getLvString(self.nSearchLv)) 
end

--设置目标选据
function DlgWorldSearch:setSelectedType( nType, bIsFirst )
	if not bIsFirst then
		if self.nSearchType == nType then
			return
		end
	end
	self.nSearchType = nType

	--类型范围
	local tLvRange = Player:getWorldData():getWorldSearchLvRange(self.nSearchType)
	if not tLvRange then
		TOAST(getTipsByIndex(20078))
		return
	end

	--生成度表
	local nLvMin = tLvRange[1]
	local nLvMax = tLvRange[2]
	local nRange = nLvMax - nLvMin
	local nSub = 100/(nRange + 1)
	self.tLvPercent = {}
	for i=nLvMin,nLvMax do
		local fPercent1 = (i - nLvMin) * nSub
		local fPercent3 = (i - nLvMin + 1) * nSub
		local fPercent2 = fPercent1 + (fPercent3 - fPercent1)/2
		if i == nLvMin then
			fPercent2 = fPercent1
		end
		if i == nLvMax then
			fPercent3 = 100
			fPercent2 = fPercent3
		end
		self.tLvPercent[i] = {fPercent1 = fPercent1, fPercent2 = fPercent2, fPercent3 = fPercent3}
	end

	--记录
	Player:getWorldData():setWorldSearchType(self.nSearchType)

	--选框
	local pLayBtn = self.tTargetBtn[nType]
	if pLayBtn then
		local nX, nY = pLayBtn:getPosition()
		local pSize = pLayBtn:getContentSize()
		self.pImgSelected:setPosition(nX + pSize.width/2, nY + pSize.height/2)
	end

	--设置等级
	local nSearchLv = Player:getWorldData():getWorldSearchLvPrev(self.nSearchType)
	self:setSearchLv(nSearchLv)	
end

function DlgWorldSearch:refreshData(  )
	self.nSearchType = Player:getWorldData():getWorldSearchTypePrev()
	--如果之前选择的在该区哉不 在该区域里不显示的话重置为第1个
	local tLvRange = Player:getWorldData():getWorldSearchLvRange(self.nSearchType)
	if not tLvRange then
		self.nSearchType = e_type_search.wildArmy
		--记录
		Player:getWorldData():setWorldSearchType(self.nSearchType)
	end

	self:setSelectedType(self.nSearchType, true)
	self:updateViews()
end

--minusBtn减少按钮点击回调事件
function DlgWorldSearch:onMinusBtnClicked( pView )
	if not self.nSearchType then
		return
	end

	local nLv = Player:getWorldData():getWorldSearchLvPrev(self.nSearchType)
	nLv = nLv - 1

	--等级范围
	local tLvRange = Player:getWorldData():getWorldSearchLvRange(self.nSearchType)
	if tLvRange then
		local nLvMin = tLvRange[1]
		local nLvMax = tLvRange[2]
		if nLv < nLvMin then
			return
		end

		if nLv > nLvMax then
			return
		end
		self:setSearchLv(nLv)
	end
end

--plusBtn增加按钮点击回调事件
function DlgWorldSearch:onPlusBtnClicked( pView )
	if not self.nSearchType then
		return
	end

	local nLv = Player:getWorldData():getWorldSearchLvPrev(self.nSearchType)
	nLv = nLv + 1

	--等级范围
	local tLvRange = Player:getWorldData():getWorldSearchLvRange(self.nSearchType)
	if tLvRange then
		local nLvMin = tLvRange[1]
		local nLvMax = tLvRange[2]
		if nLv < nLvMin then
			return
		end

		if nLv > nLvMax then
			return
		end
		self:setSearchLv(nLv)
	end	
end

function DlgWorldSearch:onGoBtnClicked( )
	--不可点击
	if not self.bIsCanTouch then
		TOAST(getTipsByIndex(20079), true)
		return
	end

	if not self.nSearchType then
		return
	end

	local nSearchLv = Player:getWorldData():getWorldSearchLvPrev(self.nSearchType)
	if not nSearchLv then
		return
	end

	local nId = nil
	if self.nSearchType == e_type_search.wildArmy then --乱军
		local tData = getWorldEnemyDataByLv(nSearchLv)
		local nMyBlockType = Player:getWorldData():getMyCityBlockType()
		if nSearchLv >= 11 and nMyBlockType and nMyBlockType <= e_type_block.jun then--目标乱军等级大于等于11
			TOAST(getTipsByIndex(20108))
			return
		end
		if tData then
			nId = tData.id
		end
	elseif self.nSearchType == e_type_search.inn then --客栈
		local tData = getWorldMineDataByTypeAndLv(e_type_mines.inn, nSearchLv)
		if tData then
			nId = tData.id
		end
	elseif self.nSearchType == e_type_search.mill then --木厂
		local tData = getWorldMineDataByTypeAndLv(e_type_mines.mill, nSearchLv)
		if tData then
			nId = tData.id
		end
	elseif self.nSearchType == e_type_search.farm then --农场
		local tData = getWorldMineDataByTypeAndLv(e_type_mines.farm, nSearchLv)
		if tData then
			nId = tData.id
		end
	elseif self.nSearchType == e_type_search.iron then --铁矿
		local tData = getWorldMineDataByTypeAndLv(e_type_mines.iron, nSearchLv)
		if tData then
			nId = tData.id
		end
	elseif self.nSearchType == e_type_search.gold then --金矿
		local tData = getWorldMineDataByTypeAndLv(e_type_mines.gold, nSearchLv)
		if tData then
			nId = tData.id
		end
	end

	if nId then
		self.bIsCanTouch = false
		SocketManager:sendMsg("reqWorldSearch", {nId}, function( __msg )
			if  __msg.head.state == SocketErrorType.success then
		        if __msg.head.type == MsgType.reqWorldSearch.id then
		        	sendMsg(ghd_world_location_dotpos_msg, {nX = __msg.body.x, nY = __msg.body.y, isClick = true})
		        	-- closeDlgByType(e_dlg_index.worldsearch, false)
		        end
		    else
		        TOAST(SocketManager:getErrorStr(__msg.head.state))
		    end

		    if not tolua.isnull(self) then --设置可以点击
		    	self:performWithDelay(function ()
		 			self.bIsCanTouch = true
		 		end, 1)
		    end
		end)
	else
		print("没有找到该id")
	end
end

function DlgWorldSearch:onChangePos( )
	self:refreshData()
end

function DlgWorldSearch:onClosed( )
	-- body
	closeDlgByType(e_dlg_index.worldsearch)
end

return DlgWorldSearch


