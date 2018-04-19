----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-08 14:50:46
-- Description: 采集资源没有占领
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemCollectResourceHero = require("app.layer.world.ItemCollectResourceHero")

local nItemWidth, nItemHeight = 290, 116

local CollectResourceNoOccupy = class("CollectResourceNoOccupy",function ( )
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function CollectResourceNoOccupy:ctor( pDlgCollectResource )
	self.pDlgCollectResource = pDlgCollectResource
	parseView("layout_collect_resource_no_occupy", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CollectResourceNoOccupy:onParseViewCallback( pView )
	self:addView(pView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CollectResourceNoOccupy",handler(self, self.onCollectResourceNoOccupyDestroy))
end

function CollectResourceNoOccupy:onCollectResourceNoOccupyDestroy(  )
	self:onPause()
end

function CollectResourceNoOccupy:onResume(  )
	self:regMsgs()
end

function CollectResourceNoOccupy:onPause(  )
	self:unregMsgs()
end

function CollectResourceNoOccupy:regMsgs( )
	-- 注册士兵兵力刷新消息
  	regMsg(self, gud_refresh_hero, handler(self, self.onRefershHero))
end

function CollectResourceNoOccupy:unregMsgs( )
	-- 注册士兵兵力刷新消息
	unregMsg(self, gud_refresh_hero)
end

function CollectResourceNoOccupy:setupViews(  )
	self.pLayContent = self:findViewByName("lay_content")

	local pLayBtnCancel = self:findViewByName("lay_btn_cancel")
	local pBtnCancel = getCommonButtonOfContainer(pLayBtnCancel,TypeCommonBtn.L_RED)
	pBtnCancel:onCommonBtnClicked(handler(self, self.onBtnCancelClicked))
	pBtnCancel:updateBtnText(getConvertedStr(3, 10015))

	local pLayBtnCollect = self:findViewByName("lay_btn_collect")
	self.pBtnCollect = getCommonButtonOfContainer(pLayBtnCollect,TypeCommonBtn.L_BLUE, getConvertedStr(3, 10057))
	self.pBtnCollect:onCommonBtnClicked(handler(self, self.onBtnCollectClicked))
end

--设置数据
function CollectResourceNoOccupy:setData( tData, tMine)
	self.tData = tData
	self.nX = self.tData.nX
	self.nY = self.tData.nY
	self.tMine = tMine
	self.nMoveTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)

	--设置默认文本
	if self.pBtnCollect and not self.pBtnCollect.pBtnExText then
	    local tLabel = {
			{getConvertedStr(3, 10066), getC3B(_cc.green)},
			{getResourcesStr(getMyGoodsCnt(e_type_resdata.food)).."/"},
			{"0"},
			
		}
		local tConTable = {}
		tConTable.tLabel = tLabel
	    self.pBtnCollect:setBtnExText(tConTable)
	end	

	--刷新武将数据
	self:refreshHeroData()
	--设置默认选中下标
	self:setDefaultSelected()
	--更新武将列表
	self:updateHeroListView()
	--更新选中英雄显示
	self:updateHero()
	--第一次滚动到可选的位置
	if self.nDefaultIndex then
		self.pListView:scrollToPosition(math.ceil(self.nDefaultIndex/2))
	end
end

--刷新数据
function CollectResourceNoOccupy:refreshHeroData( )
	self.tHeroList = {}
	--采集列表
	local tCollectHeroList = Player:getHeroInfo():getCollectHeroList()
	for i=1,#tCollectHeroList do
		table.insert(self.tHeroList, tCollectHeroList[i])
	end
	--上阵列表
	local tOnlineHeroList = Player:getHeroInfo():getOnlineHeroList()
	for i=1,#tOnlineHeroList do
		table.insert(self.tHeroList, tOnlineHeroList[i])
	end
end

--设置默认选中
function CollectResourceNoOccupy:setDefaultSelected(  )
	--默认选中第N个可选的
	local nDefaultIndex = nil
	for i=1,#self.tHeroList do
		local tHeroData = self.tHeroList[i]
		local nState =  Player:getWorldData():getHeroState(tHeroData.nId)
		--空闲
		if nState ==  e_type_task_state.idle then
			--兵力不足
			local nMaxTroops = tHeroData:getProperty(e_id_hero_att.bingli)
			local fTroopsRate = tHeroData.nLt/nMaxTroops
			if fTroopsRate <= 0.1 then
				--兵力不足不处理
			else
				nDefaultIndex = i
				break
			end
		else
			--出征中不处理
		end
	end
	self.nHeroIndex = self.nHeroIndex or nDefaultIndex

	--更前当前选中武将数据
	self.tHero = self.tHeroList[self.nHeroIndex]
end

--刷新武将ListView
function CollectResourceNoOccupy:updateHeroListView( )
	--刷新列表
	local nNum = math.ceil(#self.tHeroList/2)
	if not self.pListView then
	    self:createListView(nNum)
	else
	    self.pListView:notifyDataSetChange(true, nNum)
	end
end


--创建listView
function CollectResourceNoOccupy:createListView( _count )
	local pSize = self.pLayContent:getContentSize()
    self.pListView = MUI.MListView.new {
        viewRect   = cc.rect(0, 0, 600, pSize.height),
        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
    }
    
    self.pLayContent:addView(self.pListView)
    centerInView(self.pLayContent, self.pListView )

    --列表数据
    self.pListView:setItemCount(_count)
    self.pListView:setItemCallback(function ( _index, _pView ) 
        local pTempView = _pView
        local pHero1 = nil
        local pHero2 = nil
        if pTempView == nil then
        	pTempView = MUI.MLayer.new()
        	pTempView:setContentSize(640, 126)
        	--武将1
        	pHero1 = ItemCollectResourceHero.new(handler(self, self.onHeroClicked))
        	pTempView:addView(pHero1)
        	pTempView.pHero1 = pHero1
        	pHero1:setPosition(0, 0)
        	--武将2
        	pHero2 = ItemCollectResourceHero.new(handler(self, self.onHeroClicked))
        	pTempView:addView(pHero2)
        	pTempView.pHero2 = pHero2
        	pHero2:setPosition(nItemWidth + 20, 0)
        else
        	pHero1 = pTempView.pHero1
        	pHero2 = pTempView.pHero2
        end
        local nIndex1 = (_index - 1) * 2 + 1
        local nIndex2 = nIndex1 + 1
        local tHeroData1 = self.tHeroList[nIndex1]
        if tHeroData1 then
        	pHero1:setData(tHeroData1, nIndex1)
        	pHero1:setSelected(self.nHeroIndex == nIndex1)
        	pHero1:setVisible(true)
        else
        	pHero1:setVisible(false)
        end

        local tHeroData2 = self.tHeroList[nIndex2]
        if tHeroData2 then
        	pHero2:setData(tHeroData2, nIndex2)
        	pHero2:setSelected(self.nHeroIndex == nIndex2)
        	pHero2:setVisible(true)
        else
        	pHero2:setVisible(false)
        end

        return pTempView
    end)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)

    self.pListView:reload()
end

--更新选中英雄显示
function CollectResourceNoOccupy:updateHero(  )
	if not self.tData then
		return
	end
	if not self.tMine then
		return
	end
	--有选中的情况下
	if self.tHero then
		--采集时间
		local nCanTime = 0
		local pTxtCollectTime = self.pDlgCollectResource:getTxtCollectTime()
		if pTxtCollectTime then
			local tCollectTime = getWorldInitData("collectTime")
			local nTime = tCollectTime[self.tHero.nQuality] or 0 --秒 武将所能采集的最大时间
			local nRemainTime = self.tData.nRemainRes/self.tMine.crop * 3600 --秒 剩余资源的最大时间
			--剩余资源/采集速度最大值
			nCanTime = math.min(nRemainTime, nTime)
			local tStr = {
		    	{color=_cc.white,text=getConvertedStr(3, 10122)},
		    	{color=_cc.green,text=formatTimeToHms(nCanTime)},
		    }
			pTxtCollectTime:setString(tStr)
		end
		--预计收获
		local pTxtPreview = self.pDlgCollectResource:getTxtPreview()
		if pTxtPreview then
			
			-- local nPreview = WorldFunc.getCollectPreview(self.tHero.nT, self.tMine.id)
			--基础值
			local nPreview = WorldFunc.getCollectPreviewBase(self.tMine.id, nCanTime/3600)
			local nCanGet = math.min(self.tData.nRemainRes, nPreview)

			local tStr = {
		    	{color=_cc.white,text=getConvertedStr(3, 10123)},
		    	{color=_cc.blue,text=getResourcesStr(nCanGet)},
		    }

		    --额外加成
		    local nExtral = WorldFunc.getCollectPreviewEx(self.tMine.id, nCanGet)
		    if nExtral > 0 then
			 	local sExtralStr=string.format(getConvertedStr(9,10021),getResourcesStr(nExtral))
			    table.insert(tStr,{color=_cc.blue,text=sExtralStr})				
		    end
		    pTxtPreview:setString(tStr)
		end

		--如果武将等级不够
		if self.tHero.nLv < self.tMine.herolv then
			self.pBtnCollect:setExTextLbCnCr(1,string.format(getConvertedStr(3, 10402),self.tMine.herolv), getC3B(_cc.red))
		    self.pBtnCollect:setExTextLbCnCr(2,"")
		    self.pBtnCollect:setExTextLbCnCr(3,"")
		    self.pBtnCollect:setBtnEnable(false)
		else
			--消耗
			local nCostFood = WorldFunc.getCostFood(self.tHero.nLt, self.nMoveTime)
			local sColor = _cc.green
			if getMyGoodsCnt(e_type_resdata.food) < nCostFood then
				sColor = _cc.red
			end
			self.pBtnCollect:setExTextLbCnCr(1,getConvertedStr(3, 10066),getC3B(sColor))
		    self.pBtnCollect:setExTextLbCnCr(3,getResourcesStr(nCostFood), getC3B(_cc.pwhite))
		    self.pBtnCollect:setExTextLbCnCr(2,getResourcesStr(getMyGoodsCnt(e_type_resdata.food)).."/")
			self.pBtnCollect:setBtnEnable(true)
		end
	else --没有选中的情况下
		--采集时间
		local pTxtCollectTime = self.pDlgCollectResource:getTxtCollectTime()
		if pTxtCollectTime then
			local tStr = {
		    	{color=_cc.white,text=getConvertedStr(3, 10122)},
		    	{color=_cc.green,text=tostring(0)},
		    }
			pTxtCollectTime:setString(tStr)
		end
		--预计收获
		local pTxtPreview = self.pDlgCollectResource:getTxtPreview()
		if pTxtPreview then
			local tStr = {
		    	{color=_cc.white,text=getConvertedStr(3, 10123)},
		    	{color=_cc.blue,text=tostring(0)},
		    }
			pTxtPreview:setString(tStr)
		end
		self.pBtnCollect:setExTextLbCnCr(1,getConvertedStr(3, 10066),getC3B(_cc.pwhite))
	    self.pBtnCollect:setExTextLbCnCr(2,0)
	    self.pBtnCollect:setExTextLbCnCr(3,"/"..getResourcesStr(getMyGoodsCnt(e_type_resdata.food)))
		self.pBtnCollect:setBtnEnable(false)
	end
end

function CollectResourceNoOccupy:updateViews(  )	
end

function CollectResourceNoOccupy:onBtnCancelClicked(  )
	self.pDlgCollectResource:onCloseClicked()
end

function CollectResourceNoOccupy:onBtnCollectClicked(  )
	--不能跨区
	local nTargetBlockId = WorldFunc.getBlockId(self.nX, self.nY)
	if nTargetBlockId ~= Player:getWorldData():getMyCityBlockId() then
		TOAST(getTipsByIndex(572))
		return
	end

	--武将
	if not self.tHero then
		return
	end

	--判断是否已经有该地点有采集任务
	local tTaskMsgList = Player:getWorldData():getTaskMsgByTPos(e_type_task.collection, self.nX, self.nY)
	for i=1,#tTaskMsgList do
		local tTaskMsg = tTaskMsgList[i]
		if tTaskMsg.nType == e_type_task.collection then
			if tTaskMsg.nState == e_type_task_state.go or tTaskMsg.nState == e_type_task_state.collection then
				TOAST(getConvertedStr(3, 10360))
				return
			end
		end
	end

	--武将列表字符串
	local sHids = tostring(self.tHero.nId)
	-- --默认数据
	-- local sWarId = "0"
	-- local nAcker = 0
	-- local nWarType = 0
	SocketManager:sendMsg("reqWorldTask", {e_type_task.collection, self.nX,
			self.nY, sHids, nil, nil, nil})
	self:onBtnCancelClicked()
end

--选中英雄回调
function CollectResourceNoOccupy:onHeroClicked( nIndex )
	--更前当前选中武将数据
	self.nHeroIndex = nIndex
	self.tHero = self.tHeroList[nIndex]
	self:updateHero()

	--刷新是否选中显示
	self:updateHeroListView()
end

--更新兵力
function CollectResourceNoOccupy:onRefershHero(  )
	--更新数据
	self:refreshHeroData()
	--设置默认选中
	self:setDefaultSelected()
	--更新武将列表
	self:updateHeroListView()
	--更新选中英雄显示
	self:updateHero()
end

return CollectResourceNoOccupy