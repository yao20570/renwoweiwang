----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 16:16:00
-- Description: 攻防部队数据
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local ItemImperialWarArmy = require("app.layer.imperialwar.ItemImperialWarArmy")
local DlgImperialWarArmy = class("DlgImperialWarArmy", function()
	return MDialog.new(e_dlg_index.imperialwararmy)
end)

function DlgImperialWarArmy:ctor(  )
	self.nReqTime = 2 --2秒请求一次
	parseView("dlg_imperial_war_army", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgImperialWarArmy:onParseViewCallback( pView )
	self:setContentView(pView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgImperialWarArmy",handler(self, self.onDlgImperialWarArmyDestroy))
end

-- 析构方法
function DlgImperialWarArmy:onDlgImperialWarArmyDestroy(  )
    self:onPause()
end

function DlgImperialWarArmy:regMsgs(  )
	-- -- 大地图视图移动
	-- regMsg(self, ghd_world_view_pos_msg, handler(self, self.onWorldViewPosMsg))

	-- -- 区域视图点刷新
	-- regMsg(self, gud_world_block_dots_msg, handler(self, self.onWorldBlockDotsMsg))
end

function DlgImperialWarArmy:unregMsgs(  )
end

function DlgImperialWarArmy:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateCd))
end

function DlgImperialWarArmy:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgImperialWarArmy:setData( tAtkTroops, nDefTroops, tAckList, tDefList, nDefCountry )
	self.tAtkTroops = tAtkTroops
	self.nDefTroops = nDefTroops
	self.tAckList = tAckList
	self.tDefList = tDefList
	self.nDefCountry = nDefCountry
	self:updateViews()
end

function DlgImperialWarArmy:setupViews(  )
	local pTxtTitle = self:findViewByName("txt_title")
	pTxtTitle:setString(getConvertedStr(3, 10905))
	local pImgClose = self:findViewByName("img_close")
	--层点击
	pImgClose:setViewTouched(true)
	pImgClose:setIsPressedNeedScale(false)
	pImgClose:setIsPressedNeedColor(true)
	pImgClose:onMViewClicked(function ( _pView )
	    self:closeDlg(false)
	end)
	
	local pTxtAtkCountry1 = self:findViewByName("txt_atk_country1")
	local pTxtAtkCountry2 = self:findViewByName("txt_atk_country2")
	local pTxtAtkCountry3 = self:findViewByName("txt_atk_country3")
	local pTxtAtkTroops1 = self:findViewByName("txt_atk_troops1")
	local pTxtAtkTroops2 = self:findViewByName("txt_atk_troops2")
	local pTxtAtkTroops3 = self:findViewByName("txt_atk_troops3")
	self.tTroopsUi = {
		{pTxtAtkCountry = pTxtAtkCountry1, pTxtAtkTroops = pTxtAtkTroops1},
		{pTxtAtkCountry = pTxtAtkCountry2, pTxtAtkTroops = pTxtAtkTroops2},
		{pTxtAtkCountry = pTxtAtkCountry3, pTxtAtkTroops = pTxtAtkTroops3},
	}
	self.pTxtDefCountry = self:findViewByName("txt_def_country")
	self.pTxtDefTroops = self:findViewByName("txt_def_troops")

	self.pLayListViewLeft = self:findViewByName("lay_listview_left")
	self.pLayListViewRight = self:findViewByName("lay_listview_right")
	self.pTxtNone = self:findViewByName("txt_none")
	self.pTxtNone:setString(getConvertedStr(3, 10957))
	
end

function DlgImperialWarArmy:updateViews(  )
	self:updateTroopsUi()
	self:updateLeftView()
	self:updateRightView()
	self:updateCd()
end

function DlgImperialWarArmy:updateTroopsUi(  )
	if self.tAtkTroops then
		--五个文字点位置
		local tPosList = {
			{39 , 13},
			{39 + (100 - 39)/2, 13},
			{100, 13},
			{100 + (156 - 100)/2, 13},
			{156, 13},
		}

		local nAddY = 21

		local tPosList2 = {}
		local nCount = #self.tAtkTroops
		if nCount == 1 then
			tPosList2 = {tPosList[3]}
		elseif nCount == 2 then
			tPosList2 = {tPosList[2],tPosList[4]}
		elseif nCount == 3 then
			tPosList2 = {tPosList[1],tPosList[3],tPosList[5]}
		end
		
		for i=1,#self.tAtkTroops do
			local pTxtAtkCountry = nil
			local pTxtAtkTroops = nil
			if self.tTroopsUi[i] then
				pTxtAtkCountry = self.tTroopsUi[i].pTxtAtkCountry
				pTxtAtkTroops = self.tTroopsUi[i].pTxtAtkTroops
			end
			local tPos = tPosList2[i]
			if tPos and pTxtAtkCountry and pTxtAtkTroops then
				local nCountry = self.tAtkTroops[i].k
				local nTroops = self.tAtkTroops[i].v
				pTxtAtkCountry:setString(getCountryShortName(nCountry))
				setTextCCColor(pTxtAtkCountry, getColorByCountry(nCountry)) 
				pTxtAtkTroops:setString(nTroops)
				pTxtAtkTroops:setPosition(tPos[1], tPos[2])
				pTxtAtkCountry:setPosition(tPos[1], tPos[2] + nAddY)
				pTxtAtkCountry:setVisible(true)
				pTxtAtkTroops:setVisible(true)
			else
				if pTxtAtkCountry and pTxtAtkTroops then
					pTxtAtkCountry:setVisible(false)
					pTxtAtkTroops:setVisible(false)
				end
			end
		end
		self.pTxtNone:setVisible(nCount == 0)
	end

	if self.nDefTroops then
		local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
		local tViewDotMsg = Player:getWorldData():getSysCityDot(nSysCityId)
		if tViewDotMsg then
			local nCountry = tViewDotMsg:getDotCountry()
			self.pTxtDefCountry:setString(getCountryShortName(nCountry))
			setTextCCColor(self.pTxtDefCountry, getColorByCountry(nCountry))
		end
		self.pTxtDefTroops:setString(self.nDefTroops)
	end
end

function DlgImperialWarArmy:updateLeftView(  )
	if not self.tAckList then
		return
	end
	if not self.pListViewLeft then
	    self:createListViewLeft(#self.tAckList)
	else
	    self.pListViewLeft:notifyDataSetChange(true, #self.tAckList)
	end
end

--创建listView
function DlgImperialWarArmy:createListViewLeft(_count)
	local pSize = self.pLayListViewLeft:getContentSize()
    self.pListViewLeft = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left = _disLeft or 0,
            right = _disRight or 0,
            top = 5 ,
            bottom = 5 },
    }
    --上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListViewLeft:setUpAndDownArrow(pUpArrow, pDownArrow)

    local pContentLayer = self.pLayListViewLeft
    pContentLayer:addView(self.pListViewLeft)
    centerInView(pContentLayer, self.pListViewLeft )

    --列表数据
    self.pListViewLeft:setItemCount(_count)
    self.pListViewLeft:setItemCallback(function ( _index, _pView ) 
        local pItemData = self.tAckList[_index]
        local pTempView = _pView
        if pTempView == nil then
            pTempView   = ItemImperialWarArmy.new()
        end
        pTempView:setData(pItemData)
        return pTempView
    end)
    self.pListViewLeft:reload()
end

function DlgImperialWarArmy:updateRightView(  )
	if not self.tDefList then
		return
	end
	if not self.pListViewRight then
	    self:createListViewRight(#self.tDefList)
	else
	    self.pListViewRight:notifyDataSetChange(true, #self.tDefList)
	end
end

--创建listView
function DlgImperialWarArmy:createListViewRight(_count)
	local pSize = self.pLayListViewRight:getContentSize()
    self.pListViewRight = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
        itemMargin = {left = _disLeft or 0,
            right = _disRight or 0,
            top = 5,
            bottom = 5 },
    }
    --上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListViewRight:setUpAndDownArrow(pUpArrow, pDownArrow)
    
    local pContentLayer = self.pLayListViewRight
    pContentLayer:addView(self.pListViewRight)
    centerInView(pContentLayer, self.pListViewRight )

    --列表数据
    self.pListViewRight:setItemCount(_count)
    self.pListViewRight:setItemCallback(function ( _index, _pView ) 
        local pItemData = self.tDefList[_index]
        local pTempView = _pView
        if pTempView == nil then
            pTempView   = ItemImperialWarArmy.new()
        end
        pTempView:setData(pItemData)
        return pTempView
    end)
    self.pListViewRight:reload()
end

function DlgImperialWarArmy:onSubmitClicked( )
	closeDlgByType(e_dlg_index.imperialwarhero, false)
end

function DlgImperialWarArmy:reqNewData(  )
	SocketManager:sendMsg("reqImperWarArmy", {},function (__msg)
		self.bIsReqing = false
		self.nReqNewDataTime = getSystemTime()

		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.reqImperWarArmy.id then
				--进攻方兵力
				local tAtkTroops = __msg.body.ackTrps or {}
				if tAtkTroops then
			        for i=#tAtkTroops,1,-1 do
			            if tAtkTroops[i].v <= 0 then
			                table.remove(tAtkTroops, i)
			            end
			        end
			    end
				--防守方兵力
				local nDefTroops = __msg.body.defTrps or 0
				--进攻方队列
				local tAckList = {}
				if __msg.body.ackAV and #__msg.body.ackAV > 0 then
					local ArmyVO = require("app.layer.imperialwar.data.ArmyVO")
					for i=1,#__msg.body.ackAV do
						table.insert(tAckList, ArmyVO.new(__msg.body.ackAV[i]))
					end
				end
				--防守方队列
				local tDefList = {}
				if __msg.body.defAV and #__msg.body.defAV > 0 then
					local ArmyVO = require("app.layer.imperialwar.data.ArmyVO")
					for i=1,#__msg.body.defAV do
						table.insert(tDefList, ArmyVO.new(__msg.body.defAV[i]))
					end
				end

				--界面刷新
				if self.setData then 
					self:setData(tAtkTroops, nDefTroops, tAckList, tDefList)
				end
			end
		else
	        TOAST(SocketManager:getErrorStr(__msg.head.state))
	    end
	end)
end

function DlgImperialWarArmy:updateCd(  )
	if not self.bIsReqing then
		local bIsReq = false
		if self.nReqNewDataTime then
			local nTime = getSystemTime()
			if nTime - self.nReqNewDataTime >= self.nReqTime then
				bIsReq = true
			end
		else
			bIsReq = true
		end
		if bIsReq then
			self.bIsReqing = true
			self:reqNewData()
		end
	end
end

return DlgImperialWarArmy