-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-27 15:20:52 星期四
-- Description: 道具加速
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemInfo = require("app.module.ItemInfo")
local MBtnExText = require("app.common.button.MBtnExText")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemPropGood = require("app.layer.build.ItemPropGood")
local DlgBuildProp = class("DlgBuildProp", function()
	-- body
	return DlgCommon.new(e_dlg_index.buildprop)
end)

--_nBuildCell：建筑格子下标 
--_nLoc --用来区分是在建筑加速还是在科技院里面加速 1.表示建筑加速 2.表示科技院里面加速或则在建筑外收取科技
function DlgBuildProp:ctor( _nType, _nBuildCell, _nLoc )
	-- body
	self:myInit()
	self.nType = _nType or self.nType
	self.nLoc = _nLoc or 2
	if self.nType == 1 or self.nType == 2 or self.nType == 5 then
		if not _nBuildCell then
			print("建筑cellindex 不能为 nil")
		end
		if _nBuildCell > n_start_suburb_cell then
			self.tInfo = Player:getBuildData():getSuburbByCell(_nBuildCell)
		else
			self.tInfo = Player:getBuildData():getBuildByCell(_nBuildCell)
		end
		if not self.tInfo then
			print("建筑数据为 nil")
			return
		end
	end

	--金币值
	if self.nType == 1 then --建筑加速
		self.tCurFinishValue = self.tInfo:getBuildCurrentFinishValue()
	elseif self.nType == 2 then --募兵加速
		--获得募兵中的队列
		self.tRecruitingQue = self.tInfo:getRecruitingQue()
		if self.tRecruitingQue then
			self.tCurFinishValue = self.tRecruitingQue:getRecruitCurrentFinishValue()
		else
			print("募兵中的队列不能为 nil")
			return 
		end
	elseif self.nType == 3 then --科技加速
		self.tUpingTnoly = Player:getTnolyData():getUpingTnoly()
		if self.tUpingTnoly then
			self.tCurFinishValue = self.tUpingTnoly:getTnolyCurrentFinishValue()
		else
			print("研究中的科技不能为 nil")
			return 
		end
	elseif self.nType == 4 then --装备打造加速
		self.tMakeVo = Player:getEquipData():getMakeVo()
		if self.tMakeVo then
			self.tCurFinishValue = self.tMakeVo:getEquipMakeCost()
		else
			print("正在打造装备不能为空")
			return 
		end
	elseif self.nType == 5 then --建筑改建
		self.tCurFinishValue = self.tInfo:getBuildCurrentFinishValue()
	end
	parseView("dlg_build_prop", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgBuildProp:myInit(  )
	-- body
	self.nType 				= 		1 			--1:建筑加速 2:募兵加速
	self.tInfo 				= 		nil 		--对应数据
	self.tRecruitingQue 	= 		nil 		--募兵中的队列（对应募兵加速）
	self.tProps 			= 		{} 			--道具列表
	self.tCurFinishValue 	= 		0 			--当前加速金币值
	self.tShowData 			= 		nil 		--建筑展示相关数据
	self.tCoinFastData		=		nil         --金币加速的数据

	self.pBtnExTextGold		=       nil         --立即完成按钮上的金币提示


	self._nstuffs 		= 		2		--物品总量
	self._nselect 		=		1		--玩家当前选定的购买次数
	self.bRedoneSV 		= 		true --是否重算滑动条变化	

	self.bUse 			= 		false --是否使用
	self.nCurItemId 	=       nil
end

--解析布局回调事件
function DlgBuildProp:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView, true) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBuildProp",handler(self, self.onDlgBuildPropDestroy))
	--刷新进程
	regUpdateControl(self, handler(self, self.onUpdate))
end

--初始化控件
function DlgBuildProp:setupViews( )
	-- body
	--设置title
	if self.nType == 1 then --建筑加速
		self:setTitle(getConvertedStr(1, 10112))
	elseif self.nType == 2 then --募兵加速
		self:setTitle(getConvertedStr(1, 10147))
	elseif self.nType == 3 then --科技加速
		self:setTitle(getConvertedStr(6, 10758))
	elseif self.nType == 4 then --装备打造加速
		self:setTitle(getConvertedStr(6, 10759))
	elseif self.nType == 5 then --建筑改建
		self:setTitle(getConvertedStr(7, 10443))
	end
		
	self.pLayRoot 			= 		self:findViewByName("default")		

	--top层
	self.pLayTop 			= 		self:findViewByName("lay_top")

	--名字
	self.pLbName 			= 		self:findViewByName("lb_name")	
	--等级
	self.pLbLv 				= 		self:findViewByName("lb_lv")
	--时间
	self.pLbTime 			= 		self:findViewByName("lb_time")
	self.pLayBar			=       self:findViewByName("ly_bar")

	--加速 物品
	self.pLayGoods 			= 		self:findViewByName("lay_goods_list")

	--当前选择的物品数量
	self.pLbItemNum 		= 		self:findViewByName("lb_item_num")

	-- 
	self.pLayTarget 		= 		self:findViewByName("lay_tar_icon")
	--数值层
	self.pLaySelectNum 		= 		self:findViewByName("lay_num")
	self.pLaySelectNum:setViewTouched(true)
	self.pLaySelectNum:setIsPressedNeedScale(true)
	self.pLaySelectNum:onMViewClicked(handler(self, self.onOpenSetNum))
	--金币加速按钮
	self:setLeftBtnText(getConvertedStr(6, 10740))	
	self:setLeftBtnType(TypeCommonBtn.L_YELLOW)
	self:setLeftHandler(handler(self, self.onLeftBtnClicked))

	self:setRightBtnText(getConvertedStr(6, 10739))
	self:setRightBtnType(TypeCommonBtn.L_BLUE)
	self:setRightHandler(handler(self, self.onRightBtnClicked))

	--数量选择进度条
	self.playSliderBar				= 			self:findViewByName("lay_bar_select")
	self.pSliderBar 				= 			MUI.MSlider.new(display.LEFT_TO_RIGHT, 
        {bar="ui/bar/v1_bar_b1.png",
        button="ui/bar/v2_btn_tuodong.png",
        barfg="ui/bar/v1_bar_yellow_3.png"}, 
        {scale9 = true, touchInButton=false})
	self.pSliderBar:onSliderRelease(handler(self, self.onSliderBarRelease))	--触摸抬起的回调（按下和移动均可设置回调）
	self.pSliderBar:onSliderValueChanged(handler(self, self.onSliderBarChange)) --滑动改变回调
	self.pSliderBar:setSliderSize(300, 18)
	self.pSliderBar:setSliderValue(50)	--设置滑动条值默认为一半
	self.pSliderBar:align(display.LEFT_BOTTOM)
	self.playSliderBar:addView(self.pSliderBar)

	--减少按钮
	self.playMinusTimes 					= 			self:findViewByName("lay_reduce")	
	self.playMinusTimes:setViewTouched(true)
	self.playMinusTimes:setIsPressedNeedScale(true)		
	self.playMinusTimes:onMViewClicked(handler(self, self.onMinusBtnClicked))--按钮点击消息
	--增加按钮
	self.playPlusTimes 					= 			self:findViewByName("lay_increase")	
	self.playPlusTimes:setViewTouched(true)
	self.playPlusTimes:setIsPressedNeedScale(true)		
	self.playPlusTimes:onMViewClicked(handler(self, self.onPlusBtnClicked))--按钮点击消息

	--初始化建筑图片或者兵营类型
	if self.nType == 1 then --建筑加速
		--建筑图片
		self:initBuildImg()
	elseif self.nType == 2 then --募兵加速
		--兵营募兵类型
		self:initCampImg()
	elseif self.nType == 3 then --科技加速
		self:initTnoly()
	elseif self.nType == 4 then --装备打造加速
		self:initMakeVo()
	elseif self.nType == 5 then --建筑改建
		--建筑图片
		self:initBuildImg()	
	end

	--初始化加速道具
	self:initPropLists(true)

	self:initCoinStr()
end

-- 修改控件内容或者是刷新控件数据
function DlgBuildProp:updateViews(  )
	-- body
	local sStr = ""
	if self.nType == 1 then --建筑加速
		--名字
		sStr = sStr .. self.tInfo.sName  --名字
		sStr = sStr .. getLvString(self.tInfo.nLv , true) --升级前等级
		sStr = sStr .. " - " 
		sStr = sStr .. getLvString(self.tInfo.nLv + 1,false) --升级后等级
		self.pLbName:setString(sStr, false)
		setTextCCColor( self.pLbName, _cc.white)
	elseif self.nType == 2 then --募兵加速
		--募兵数
		sStr = sStr .. getConvertedStr(1, 10148)  --名字
		sStr = sStr .. self.tRecruitingQue.nNum --升级前等
		self.pLbName:setString(sStr, false)
		setTextCCColor( self.pLbName, _cc.white)
	elseif self.nType == 3 then --科技加速	
		sStr = sStr .. self.tUpingTnoly.sName  --名字		
		self.pLbName:setString(sStr, false)
		setTextCCColor( self.pLbName, _cc.white)
	elseif self.nType == 4 then --装备打造加速
		local tEquip = self.tMakeVo:getConfigData()
		if tEquip then			
			sStr = sStr .. tEquip.sName  --名字 			
			self.pLbName:setString(sStr, false)
			setTextCCColor( self.pLbName, getColorByQuality(tEquip.nQuality))			
		end	
	elseif self.nType == 5 then --建筑改建
		-- local tUpings = Player:getBuildData():getBuildUpdingLists()
		sStr = sStr .. self.tInfo.sName  --名字		
		sStr = sStr .. getLvString(self.tInfo.nLv , false) --建筑等级
		sStr = sStr .. " → " 
		if self.tInfo.nState == e_build_state.creating then --在创建中
			if self.tInfo.nCellIndex == e_build_cell.mbf then
				local sToName = "" --改建成目的募兵府类型兵营的名字
				if self.tInfo.nBuildTo == 1 then
					sToName = getConvertedStr(7, 10436) --募兵府-步
				elseif self.tInfo.nBuildTo == 2 then
					sToName = getConvertedStr(7, 10437) --募兵府-骑
				elseif self.tInfo.nBuildTo == 3 then
					sToName = getConvertedStr(7, 10438) --募兵府-弓
				end
				sStr = sStr .. sToName
			else
				local pSuburb = Player:getBuildData():getSuburbById(self.tInfo.nSurBuildTo)
				if pSuburb then
					sStr = sStr .. pSuburb.sName  --名字
				end
			end
			sStr = sStr .. getLvString(self.tInfo.nLv , false) --建筑等级
		end
		self.pLbName:setString(sStr, false)
		setTextCCColor( self.pLbName, _cc.white)
	end
	
	-- --进度条
	if not self.pLoadingBar then
		self.pLoadingBar = MCommonProgressBar.new({bar = "v1_bar_blue_3a.png",barWidth = 216, barHeight = 18})
		self.pLayBar:addView(self.pLoadingBar)
		centerInView(self.pLayBar,self.pLoadingBar)
	end
	self.pLoadingBar:setVisible(true)
	
	--设置时间
	self:setUpingTime()
end

-- 析构方法
function DlgBuildProp:onDlgBuildPropDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgBuildProp:regMsgs( )
	-- body
	--注册背包数据刷新消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.refreshBagInfo))
	-- 注册兵营士兵招募队列刷新消息
	regMsg(self, ghd_refresh_camp_recruit_msg, handler(self, self.refreshRecruit))
	-- 注册建筑状态刷新消息
	regMsg(self, gud_build_state_change_msg, handler(self, self.refreshBuildLvUp))
	-- 注册数字编辑数字消息
	regMsg(self, ghd_inputnum_setting_num_msg, handler(self, self.onSettingSelectNum))
	-- 注册装备刷新消息
	regMsg(self, gud_equip_makevo_change_msg, handler(self, self.refreshMakeVo))
	-- 注册科技院数据刷新消息
	regMsg(self, gud_refresh_tnoly_lists_msg, handler(self, self.refreshTnoly))	
end

-- 注销消息
function DlgBuildProp:unregMsgs(  )
	-- body
	--销毁背包数据刷新消息
	unregMsg(self, gud_refresh_baginfo)
	-- 销毁兵营士兵招募队列刷新消息
	unregMsg(self, ghd_refresh_camp_recruit_msg)
	-- 注销建筑状态刷新消息
	unregMsg(self, gud_build_state_change_msg)	
	-- 注销数字编辑数字消息
	unregMsg(self, ghd_inputnum_setting_num_msg)
	-- 注销装备刷新消息
	unregMsg(self, gud_equip_makevo_change_msg)
	-- 注销科技院数据刷新消息
	unregMsg(self, gud_refresh_tnoly_lists_msg)		
end


--暂停方法
function DlgBuildProp:onPause( )
	-- body
	self:unregMsgs()
	unregUpdateControl(self)
end

--继续方法
function DlgBuildProp:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置时间
function DlgBuildProp:setUpingTime(  )
	-- body
	--剩余时间
	local fLeftTime = 0
	local fTotalTime=0
	--计算加速金币值
	local nCurLeftValue = 0
	if self.nType == 1 then --建筑加速
		if self.tInfo then
			fLeftTime = self.tInfo:getBuildingFinalLeftTime()
			fTotalTime=self.tInfo.fUpingAllTime or fTotalTime
			nCurLeftValue = self.tInfo:getBuildCurrentFinishValue()
		end
	elseif self.nType == 2 then --募兵加速
		if self.tRecruitingQue then
			fLeftTime = self.tRecruitingQue:getRecruitLeftTime()
			fTotalTime=self.tRecruitingQue.nSD or fTotalTime
			nCurLeftValue = self.tRecruitingQue:getRecruitCurrentFinishValue()
		end
	elseif self.nType == 3 then --科技加速
		if self.tUpingTnoly then
			fTotalTime = self.tUpingTnoly.fStudingAllTime	
			fLeftTime = self.tUpingTnoly:getUpingFinalLeftTime()
			nCurLeftValue = self.tUpingTnoly:getTnolyCurrentFinishValue()
		end
	elseif self.nType == 4 then --装备打造加速
		if self.tMakeVo then 
			local tData = self.tMakeVo:getConfigData()		
			fLeftTime = self.tMakeVo:getCd()
			fTotalTime= tData.nMakeTimes or fTotalTime
			nCurLeftValue = self.tMakeVo:getEquipMakeCost()
		end
	elseif self.nType == 5 then --建筑改建
		if self.tInfo then
			fLeftTime = self.tInfo:getBuildingFinalLeftTime()
			fTotalTime=self.tInfo.fUpingAllTime or fTotalTime
			nCurLeftValue = self.tInfo:getBuildCurrentFinishValue()
		end
	end

	if self.tCurFinishValue ~= nCurLeftValue then
		self.tCurFinishValue = nCurLeftValue	
		self:refreshExCoin()
	end
	self:refreshBar(fLeftTime,fTotalTime)
	if fLeftTime > 0 then
		local sStr = {
			{color=_cc.white,text=getConvertedStr(6, 10738)},
			{color=_cc.red,text=formatTimeToHms(fLeftTime)},
		}		
		self.pLbTime:setString(sStr, false)
	else		
		local sStr = {
			{color=_cc.white,text=getConvertedStr(6, 10738)},
			{color=_cc.red,text=formatTimeToHms(0)},
		}		
		self.pLbTime:setString(sStr, false)		
		unregUpdateControl(self)
		self:closeCommonDlg()
	end	
end

function DlgBuildProp:getLeftTime()
	-- body
	local fLeftTime = 0
	--计算加速金币值
	local nCurLeftValue = 0
	if self.nType == 1 then --建筑加速
		if self.tInfo then
			fLeftTime = self.tInfo:getBuildingFinalLeftTime()
		end
	elseif self.nType == 2 then --募兵加速
		if self.tRecruitingQue then
			fLeftTime = self.tRecruitingQue:getRecruitLeftTime()
		end
	elseif self.nType == 3 then --科技加速
		if self.tUpingTnoly then			
			fLeftTime = self.tUpingTnoly:getUpingFinalLeftTime()			
		end
	elseif self.nType == 4 then --装备打造加速
		if self.tMakeVo then			
			fLeftTime = self.tMakeVo:getCd()
		end
	elseif self.nType == 5 then --建筑改建
		if self.tInfo then
			fLeftTime = self.tInfo:getBuildingFinalLeftTime()
		end
	end
	return fLeftTime	
end

--初始化加速道具
function DlgBuildProp:initPropLists( _bSetup )
	-- body
	if self.tProps and table.nums(self.tProps) > 0 then
		self.tProps = nil
	end
	self.tProps = {}
	local tFastItems = {}
	if self.nType == 1 then--建筑加速道具
		--luaSplit(getDisplayParam("buildingSpeedUpItem") or "", ";")
		tFastItems = getBuildSpeedItems()
	elseif self.nType == 2 then--募兵加速道具
		--luaSplit(getDisplayParam("recruitSpeedUpItem") or "", ";")
		tFastItems = getRecruitSpeedItems()
	elseif self.nType == 3 then--科研加速道具
		tFastItems = luaSplit(getDisplayParam("scienceSpeedUpItem") or "", ";")
	elseif self.nType == 4 then--打造装备加速道具		
		tFastItems = luaSplit(getDisplayParam("makeSpeedUpItem") or "", ";")
	elseif self.nType == 5 then--建筑改建加速道具
		tFastItems = getBuildSpeedItems()
	end
	if tFastItems and table.nums(tFastItems) > 0 then
		for k, v in pairs (tFastItems) do
			local pItem = nil
			if tonumber(v) == e_item_ids.jbjs then --金币加速
				self.tCoinFastData=getBaseItemDataByID(e_item_ids.jbjs)
				-- pItem = getBaseItemDataByID(e_item_ids.jbjs)
			else
				--先从玩家身上查找
				pItem = Player:getBagInfo():getItemDataById(tonumber(v))
				if not pItem then --如果没有，那么从配表中查找
					pItem = getBaseItemDataByID(tonumber(v))
				end
			end
			if pItem then
				table.insert(self.tProps, pItem)
			end
		end
	end
	-- if not self.tItemIcons then
	-- 	self.tItemIcons = {}
	-- end
	-- for i = 1, 3 do
	-- 	local pItem = self.tItemIcons[i]
	-- 	if not pItem then
	-- 		pItem = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum)
	-- 		pItem:setIconClickedCallBack(handler(self, self.onItemIconClick))
	-- 		pItem:setPosition(226 + (i-2)*185, 90)
	-- 		self.pLayRoot:addView(pItem, 10)
	-- 		self.tItemIcons[i] = pItem
	-- 	end
	-- 	local tData = self.tProps[i]
	-- 	if tData then
	-- 		pItem:setCurData(tData)
	-- 	end
	-- 	pItem:setIsShowBgQualityTx(false)
	-- 	pItem:setNumber(tData.nCt, false, true)
	-- 	pItem:setVisible(tData ~= nil)
	-- end
	--初始化当前道具
	if _bSetup then
		for k, v in pairs(self.tProps) do
			if v.nCt > 0 then
				self.nCurItemId = v.sTid
				break
			end			
		end
		if not self.nCurItemId then
			self.nCurItemId = self.tProps[1].sTid	
		end
	end	
	--有删除旧道具的时候充值选中状态	
	local bInList = false
	for k, v in pairs(self.tProps) do
		if self.nCurItemId == v.sTid then
			bInList = true					
		end		
	end
	if not bInList then
		self.nCurItemId = nil
		for k, v in pairs(self.tProps) do
			if v.nCt > 0 then
				self.nCurItemId = v.sTid
				break
			end			
		end
		if not self.nCurItemId then
			self.nCurItemId = self.tProps[1].sTid	
		end
	end	
	local pListView = self:createListView(self.pLayGoods, self.tProps)
	if not self.pListView then
		self.pListView = pListView
	end	
	self:updateIconSelected()
end

function DlgBuildProp:createListView(_pLay, _tGoods)
	-- body
	if not _pLay then
		return
	end
	if not _tGoods then
		return
	end
	local iconHeight = 148
	local pListView = _pLay:findViewByName("horizontallist")
	if not pListView then
		local scale = 1
        local width = _pLay:getWidth() / scale
        local height = _pLay:getHeight() / scale
	 	pListView = MUI.MListView.new {
            viewRect   = cc.rect(0, 0, width, height),
            direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
            itemMargin = {left = 0,
                 right = 0,
                 top = 0 ,
                 bottom =  0},
        }
        -- 设置缩放比例
        pListView:setScale(scale)
        pListView:setAsyncDisTime(0.03)
		--上下箭头
		local pLeftArrow, pRightArrow = getLeftAndRightArrow()
		pListView:setLeftAndRightArrow(pLeftArrow, pRightArrow)	
    	pListView:setItemCallback(function ( _index, _pView )
	        local tTempData = self.tProps[_index]
	        if(not _pView) then
	            _pView = ItemPropGood.new()
	            _pView:setActionHandler(handler(self, self.onItemIconClick))
	        end
	        -- 刷新内容
	        if(tTempData) then
	        	_pView:setCurData(tTempData)
				local bSelected = self.nCurItemId == tTempData.sTid
				_pView:setSelected(bSelected)
	        end
	        return _pView
	    end)         
        -- 设置控件名称
        pListView:setName("horizontallist")
        pListView:setItemCount(#self.tProps)
        -- 创建的时候，可以添加这个处理
        pListView:reload(false)
        _pLay:addView(pListView)   

    else
        pListView:setItemCount(#self.tProps)
	    -- 刷新实际数据
	    pListView:notifyDataSetChange( false )	    
	end


    return pListView   
end

function DlgBuildProp:onItemIconClick( _tData )
	-- body
	if not _tData then
		return
	end
	if self.nCurItemId ~= _tData.sTid then
		self.nCurItemId = _tData.sTid

		self:updateIconSelected()
	end
end

function DlgBuildProp:updateIconSelected(  )
	-- body	
	if not self.tProps or #self.tProps <= 0 then
		return
	end
	--刷新当前显示选中
	self.pListView:notifyDataSetChange( false )
	-- for k, v in pairs(self.tItemIcons) do
	-- 	local pCurData = self.tProps[k]
	-- 	local bSelected = pCurData.sTid == self.nCurItemId
	-- 	v:setIconSelected(bSelected,bSelected)
	-- end	
	--当前选中的物品
	local pData = self:getSelectedItem()
	if not pData then
		return
	end
	local nLeftTime = self:getLeftTime()
	local nNeed = math.ceil(self:getLeftTime()/tonumber(pData.sParam or 0))
	
	if pData.nCt > 0 then		
		self._nstuffs = math.min(pData.nCt,nNeed,100)
		self.bUse = true
	else
		self._nstuffs = math.min(nNeed,100)
		self.bUse = false
	end
	if self._nstuffs <= 0 then--容错处理
		self._nstuffs = 1
	end
	if self.bUse then--大于0时候默认选择最大值
		self._nselect = self._nstuffs
	else
		self._nselect = 1
	end
		
	--更新进度条显示	
	self.bRedoneSV = true
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
	self:refreshSelected()
	--使用道具
	if self.bUse then
		self:setRightBtnText(getConvertedStr(6, 10739))
		-- self:setRightBtnType(TypeCommonBtn.L_BLUE)
		self:setRightHandler(handler(self, self.onRightBtnClicked))
	else
		self:setRightBtnText(getConvertedStr(7, 10265))
		-- self:setRightBtnType(TypeCommonBtn.L_YELLOW)
		self:setRightHandler(handler(self, self.onRightBtnClicked))
	end	
end

function DlgBuildProp:onLeftBtnClicked( )
	-- body
	self:onActionClicked(self.tCoinFastData)
end

function DlgBuildProp:onRightBtnClicked( )
	-- body
	local pData = self:getSelectedItem()
	if pData then
		self:onActionClicked(pData)
	end
end

--获取选择的物品
function DlgBuildProp:getSelectedItem( )
	-- body
	if not self.nCurItemId then
		return nil
	end
	for k, v in pairs(self.tProps) do
		if self.nCurItemId == v.sTid then
			return v
		end
	end
end

--操作按钮点击回调
function DlgBuildProp:onActionClicked( _tItemInfo )
	-- body
	if _tItemInfo then
		if _tItemInfo.sTid == e_item_ids.jbjs then
		    -- if self.nType == 1 then --建筑加速
		    -- 	local nCost = self.tInfo:getBuildCurrentFinishValue()
			   --  local strTips = {
			   --  	{color=_cc.pwhite,text=getConvertedStr(1, 10111)},--立即完成建筑升级？
			   --  }
		    --     --展示购买对话框
		    -- 	showBuyDlg(strTips,nCost,function (  )
		    -- 		-- body
		    -- 		local tObject = {}
		    -- 		tObject.nType = 3 --金币完成
		    -- 		tObject.nBuildId = self.tInfo.sTid --建筑id
		    -- 		tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
		    -- 		sendMsg(ghd_up_build_msg,tObject)
		    -- 	end)
		    -- elseif self.nType == 2 then --募兵加速
    	 --    	local nCost = self.tRecruitingQue:getRecruitCurrentFinishValue()
    		--     local strTips = {
    		--     	{color=_cc.pwhite,text=getConvertedStr(1, 10149)},--立即完成本次招募？
    		--     }
    	 --        --展示购买对话框
    	 --    	showBuyDlg(strTips,nCost,function (  )
    	 --    		-- body
    	 --    		--发送消息募兵操作
    	 --    		local tObject = {}
    	 --    		tObject.nBuildId = self.tInfo.sTid
    	 --    		tObject.nType = 3
    	 --    		tObject.sId = self.tRecruitingQue.nId
    	 --    		sendMsg(ghd_recruit_action_msg,tObject)
    	 --    	end)
		    -- end
		    self:doFinishImmediate()
		else
			-- if _tItemInfo.nCt == 0 then
			-- 	local nCost = _tItemInfo.nPrice*self._nselect
			--     local strTips = {
			--     	{color=_cc.pwhite,text=getConvertedStr(1, 10146)},--购买并使用
			--     	{color=_cc.blue,text=self._nselect},--购买并使用
			--     	{color=_cc.pwhite,text="*"},--购买并使用
			--     	{color=_cc.yellow,text=_tItemInfo.sName},--名字
			--     	{color=_cc.pwhite,text="?"},
			--     }
			--     --展示购买对话框
			-- 	showBuyDlg(strTips,nCost,function (  )
			-- 		-- body
			-- 		if self.nType == 1 then --建筑加速
			-- 			local tObject = {}
			-- 			tObject.nType = 4 --购买并且使用
			-- 			tObject.nBuildId = self.tInfo.sTid --建筑id
			-- 			tObject.nItemId = _tItemInfo.sTid --道具id
			-- 			tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
			-- 			tObject.nNum = self._nselect
			-- 			sendMsg(ghd_up_build_msg,tObject)
			-- 		elseif self.nType == 2 then --募兵加速
			-- 			--发送消息募兵操作
			-- 			local tObject = {}
			-- 			tObject.nBuildId = self.tInfo.sTid
			-- 			tObject.nType = 2
			-- 			tObject.sId = self.tRecruitingQue.nId
			-- 			tObject.nItemId = _tItemInfo.sTid --道具id
			-- 			tObject.nNum = self._nselect
			-- 			sendMsg(ghd_recruit_action_msg,tObject)
			-- 		end
			-- 	end)
			-- else
			-- 	if self.nType == 1 then --建筑加速
			-- 		local tObject = {}
			-- 		tObject.nType = 2 --道具加速
			-- 		tObject.nBuildId = self.tInfo.sTid --建筑id
			-- 		tObject.nItemId = _tItemInfo.sTid --道具id
			-- 		tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
			-- 		tObject.nNum = self._nselect
			-- 		sendMsg(ghd_up_build_msg,tObject)
			-- 	elseif self.nType == 2 then --募兵加速
			-- 		--发送消息募兵操作
			-- 		local tObject = {}
			-- 		tObject.nBuildId = self.tInfo.sTid
			-- 		tObject.nType = 1
			-- 		tObject.sId = self.tRecruitingQue.nId
			-- 		tObject.nItemId = _tItemInfo.sTid --道具id
			-- 		tObject.nNum = self._nselect
			-- 		sendMsg(ghd_recruit_action_msg,tObject)
			-- 	end
			-- end
			self:doFinishByItem(_tItemInfo)
		end
	end
end
--立即完成
function DlgBuildProp:doFinishImmediate( ... )
	-- body
	if self.nType == 1 then --建筑加速
    	local nCost = self.tInfo:getBuildCurrentFinishValue()
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(1, 10111)},--立即完成建筑升级？
	    }
        --展示购买对话框
    	showBuyDlg(strTips,nCost,function (  )
    		-- body
    		local tObject = {}
    		tObject.nType = 3 --金币完成
    		tObject.nBuildId = self.tInfo.sTid --建筑id
    		tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
    		sendMsg(ghd_up_build_msg,tObject)
    	end)
    elseif self.nType == 2 then --募兵加速
    	local nCost = self.tRecruitingQue:getRecruitCurrentFinishValue()
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(1, 10149)},--立即完成本次招募？
	    }
        --展示购买对话框
    	showBuyDlg(strTips,nCost,function (  )
    		-- body
    		--发送消息募兵操作
    		local tObject = {}
    		tObject.nBuildId = self.tInfo.sTid
    		tObject.nType = 3
    		tObject.sId = self.tRecruitingQue.nId
    		sendMsg(ghd_recruit_action_msg,tObject)
    	end)
    elseif self.nType == 3 then --科技加速
		local nCost = self.tUpingTnoly:getTnolyCurrentFinishValue()
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(1, 10182)},--立即完成研究？
	    }
	    --展示购买对话框
		showBuyDlg(strTips,nCost,function (  )
			-- body
			local tObject = {}
			tObject.nType = 2
			tObject.nLoc = self.nLoc
			sendMsg(ghd_action_tnoly_msg, tObject)
		end)    	
    elseif self.nType == 4 then --装备打造加速
		local nCost =  self.tMakeVo:getEquipMakeCost()
		local function sendReq( )
			local tObject = {}
			tObject.nType = 2--立即完成
			sendMsg(ghd_speed_make_equip_msg,tObject) 			
		end
		local tStr = {
	    	{color = _cc.pwhite, text = getConvertedStr(3, 10296)},
	    }
		showBuyDlg(tStr, nCost, sendReq)
	elseif self.nType == 5 then --建筑改建
    	local nCost = self.tInfo:getBuildCurrentFinishValue()
	    local strTips = {
	    	{color=_cc.pwhite,text=getConvertedStr(7, 10442)},--立即完成建筑改建？
	    }
        --展示购买对话框
    	showBuyDlg(strTips,nCost,function (  )
    		-- body
    		local tObject = {}
    		tObject.nType = 3 --金币完成
    		tObject.nBuildId = self.tInfo.sTid --建筑id
    		tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
    		sendMsg(ghd_up_build_msg,tObject)
    	end)
    end	
end
--物品加速
function DlgBuildProp:doFinishByItem( _tItemInfo )
	-- body
	if _tItemInfo.nCt == 0 then
		-- local nCost = _tItemInfo.nPrice*self._nselect
	 --    local strTips = {
	 --    	{color=_cc.pwhite,text=getConvertedStr(1, 10146)},--购买并使用
	 --    	{color=_cc.blue,text=self._nselect},--购买并使用
	 --    	{color=_cc.pwhite,text="*"},--购买并使用
	 --    	{color=_cc.yellow,text=_tItemInfo.sName},--名字
	 --    	{color=_cc.pwhite,text="?"},
	 --    }
	 --    --展示购买对话框
		-- showBuyDlg(strTips,nCost,function (  )
		-- 	-- body
		-- 	if self.nType == 1 then --建筑加速
		-- 		local tObject = {}
		-- 		tObject.nType = 4 --购买并且使用
		-- 		tObject.nBuildId = self.tInfo.sTid --建筑id
		-- 		tObject.nItemId = _tItemInfo.sTid --道具id
		-- 		tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
		-- 		tObject.nNum = self._nselect
		-- 		sendMsg(ghd_up_build_msg,tObject)
		-- 	elseif self.nType == 2 then --募兵加速
		-- 		--发送消息募兵操作
		-- 		local tObject = {}
		-- 		tObject.nBuildId = self.tInfo.sTid
		-- 		tObject.nType = 2
		-- 		tObject.sId = self.tRecruitingQue.nId
		-- 		tObject.nItemId = _tItemInfo.sTid --道具id
		-- 		tObject.nNum = self._nselect
		-- 		sendMsg(ghd_recruit_action_msg,tObject)
		-- 	end
		-- end)
		self:buyItemToFinish(_tItemInfo)
	else
		-- if self.nType == 1 then --建筑加速
		-- 	local tObject = {}
		-- 	tObject.nType = 2 --道具加速
		-- 	tObject.nBuildId = self.tInfo.sTid --建筑id
		-- 	tObject.nItemId = _tItemInfo.sTid --道具id
		-- 	tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
		-- 	tObject.nNum = self._nselect
		-- 	sendMsg(ghd_up_build_msg,tObject)
		-- elseif self.nType == 2 then --募兵加速
		-- 	--发送消息募兵操作
		-- 	local tObject = {}
		-- 	tObject.nBuildId = self.tInfo.sTid
		-- 	tObject.nType = 1
		-- 	tObject.sId = self.tRecruitingQue.nId
		-- 	tObject.nItemId = _tItemInfo.sTid --道具id
		-- 	tObject.nNum = self._nselect
		-- 	sendMsg(ghd_recruit_action_msg,tObject)
		-- end
		self:useItemToFinish(_tItemInfo)
	end
	
end	
--购买并使用道具加速
function DlgBuildProp:buyItemToFinish( _tItemInfo )
	-- body
	if not _tItemInfo then
		return
	end
	local nCost = _tItemInfo.nPrice*self._nselect
    local strTips = {
    	{color=_cc.pwhite,text=getConvertedStr(1, 10146)},--购买并使用
    	{color=_cc.blue,text=self._nselect},
    	{color=_cc.pwhite,text=getConvertedStr(1, 10370)},--购买并使用
    	{color=_cc.yellow,text=_tItemInfo.sName},--名字
    	{color=_cc.pwhite,text="?"},
    }
    --展示购买对话框
	showBuyDlg(strTips,nCost,function (  )
		-- body
		if self.nType == 1 then --建筑加速
			local tObject = {}
			tObject.nType = 4 --购买并且使用
			tObject.nBuildId = self.tInfo.sTid --建筑id
			tObject.nItemId = _tItemInfo.sTid --道具id
			tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
			tObject.nNum = self._nselect
			sendMsg(ghd_up_build_msg,tObject)
		elseif self.nType == 2 then --募兵加速
			--发送消息募兵操作
			local tObject = {}
			tObject.nBuildId = self.tInfo.sTid
			tObject.nType = 2
			tObject.sId = self.tRecruitingQue.nId
			tObject.nItemId = _tItemInfo.sTid --道具id
			tObject.nNum = self._nselect
			sendMsg(ghd_recruit_action_msg,tObject)
	    elseif self.nType == 3 then --科技加速
	    	local tObject = {}
			tObject.nType = 6--道具购买并使用
			tObject.nItemId = _tItemInfo.sTid --道具id
			tObject.nNum = self._nselect	
			tObject.nLoc =  self.nLoc		
			sendMsg(ghd_action_tnoly_msg, tObject)
	    elseif self.nType == 4 then --装备打造加速	
			local tObject = {}
			tObject.nType = 1--道具加速
			tObject.nOpt = 2--购买并使用道具
			tObject.nItemId = _tItemInfo.sTid --道具id
			tObject.nNum = self._nselect
			sendMsg(ghd_speed_make_equip_msg,tObject)
		elseif self.nType == 5 then --建筑改建
			local tObject = {}
			tObject.nType = 4 --购买并且使用
			tObject.nBuildId = self.tInfo.sTid --建筑id
			tObject.nItemId = _tItemInfo.sTid --道具id
			tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
			tObject.nNum = self._nselect
			sendMsg(ghd_up_build_msg,tObject)   		
		end
	end)	
end
--使用道具加速
function DlgBuildProp:useItemToFinish( _tItemInfo )
	-- body
	if not _tItemInfo then
		return
	end
	if self.nType == 1 then --建筑加速
		local tObject = {}
		tObject.nType = 2 --道具加速
		tObject.nBuildId = self.tInfo.sTid --建筑id
		tObject.nItemId = _tItemInfo.sTid --道具id
		tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
		tObject.nNum = self._nselect
		sendMsg(ghd_up_build_msg,tObject)
	elseif self.nType == 2 then --募兵加速
		--发送消息募兵操作
		local tObject = {}
		tObject.nBuildId = self.tInfo.sTid
		tObject.nType = 1
		tObject.sId = self.tRecruitingQue.nId
		tObject.nItemId = _tItemInfo.sTid --道具id
		tObject.nNum = self._nselect
		sendMsg(ghd_recruit_action_msg,tObject)
    elseif self.nType == 3 then --科技加速
    	local tObject = {}
		tObject.nType = 5--道具使用加速
		tObject.nItemId = _tItemInfo.sTid --道具id
		tObject.nNum = self._nselect	
		tObject.nLoc =  self.nLoc		
		sendMsg(ghd_action_tnoly_msg, tObject)    	
    elseif self.nType == 4 then --装备打造加速
		local tObject = {}
		tObject.nType = 1--道具加速
		tObject.nOpt = 1--使用道具
		tObject.nItemId = _tItemInfo.sTid --道具id
		tObject.nNum = self._nselect
		sendMsg(ghd_speed_make_equip_msg,tObject)
	elseif self.nType == 5 then --建筑改建
		local tObject = {}
		tObject.nType = 2 --道具加速
		tObject.nBuildId = self.tInfo.sTid --建筑id
		tObject.nItemId = _tItemInfo.sTid --道具id
		tObject.nCell = self.tInfo.nCellIndex --建筑格子下标
		tObject.nNum = self._nselect
		sendMsg(ghd_up_build_msg,tObject)  	    	
	end	
end

--每秒刷新
function DlgBuildProp:onUpdate( )
	-- body
	self:updateItemMaxNum()	
	self:setUpingTime()

end

--物品最大数量刷新
function DlgBuildProp:updateItemMaxNum( ... )
	-- body
	local pData = self:getSelectedItem()
	if not pData then
		return
	end	
	local nLeftTime = self:getLeftTime()
	local nNeed = math.ceil(self:getLeftTime()/tonumber(pData.sParam or 0))
	local nStuffs = 0
	if pData.nCt > 0 then		
		nStuffs = math.min(pData.nCt,nNeed,100)
	else
		nStuffs = math.min(nNeed,100)		
	end
	if nStuffs <= 0 then--容错处理
		nStuffs = 1
	end
	if nStuffs ~= self._nstuffs then
		-- self:updateIconSelected()
		self._nstuffs = nStuffs
		if self._nselect > self._nstuffs then
			self._nselect = self._nstuffs
		end
		--更新进度条显示	
		self.bRedoneSV = true
		self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
		self:refreshSelected()		
	end
end

--背包数据刷新回调
function DlgBuildProp:refreshBagInfo(  )
	-- body
	self:initPropLists(false)
	self:refreshExCoin()
end

--募兵队列发生变化
function DlgBuildProp:refreshRecruit( sMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nBuildId = pMsgObj.nBuildId
		if nBuildId and self.tInfo and self.tInfo.sTid == nBuildId then
			if self.nType == 2 then --募兵操作
				self.tRecruitingQue = self.tInfo:getRecruitingQue()
				if self.tRecruitingQue then
					self.tCurFinishValue = self.tRecruitingQue:getRecruitCurrentFinishValue()
					self:updateViews()
					self:refreshExCoin()
				else
					self:closeDlg()
				end
			end
			
		end
	end
end
--当前正在打造装备信息刷新
function DlgBuildProp:refreshMakeVo( ... )
	-- body
	if self.nType == 4 then --装备
		self.tMakeVo = Player:getEquipData():getMakeVo()
		if self.tMakeVo then
			self.tCurFinishValue = self.tMakeVo:getEquipMakeCost()
			self:refreshExCoin()
			self:updateViews()			
		else
			self:closeDlg()
		end
	end	
end

function DlgBuildProp:refreshTnoly(  )
	-- body
	if self.nType == 3 then --科技
		self.tUpingTnoly = Player:getTnolyData():getUpingTnoly()
		if self.tUpingTnoly then
			self.tCurFinishValue = self.tUpingTnoly:getTnolyCurrentFinishValue()
			self:refreshExCoin()	
			self:updateViews()					
		else
			self:closeDlg()
		end		
	end		
end

function DlgBuildProp:refreshBuildLvUp( sMsgName, pMsgObj )
	-- body
	self.tCurFinishValue = self.tInfo:getBuildCurrentFinishValue()
	self:initPropLists(false)
	self:refreshExCoin()
	self:updateViews()		
end

--初始化建筑图片
function DlgBuildProp:initBuildImg( )
	-- body
	if self.tInfo then
		self.tShowData = getBuildGroupShowDataByCell(self.tInfo.nCellIndex,self.tInfo.sTid)

		if self.tShowData then
			local fScale = 1
			local tPos = cc.p(100,100)
			if self.tInfo.sTid == e_build_ids.house
				or self.tInfo.sTid == e_build_ids.farm
				or self.tInfo.sTid == e_build_ids.iron
				or self.tInfo.sTid == e_build_ids.wood then --资源田
				fScale = 0.75
				tPos = cc.p(self.tShowData.w * self.tShowData.fDzRw + 5,self.pLayTop:getHeight() / 2)
			elseif self.tInfo.sTid == e_build_ids.store then --仓库
				fScale = 0.56
				tPos = cc.p(self.tShowData.w * self.tShowData.fDzRw - 75 ,self.tShowData.h * self.tShowData.fDzRh )
			elseif self.tInfo.sTid == e_build_ids.tnoly then --科技院
				fScale = 0.4
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 190),(self.tShowData.h * self.tShowData.fDzRh + 18))
			elseif self.tInfo.sTid == e_build_ids.infantry then --步兵营
				fScale = 0.55
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 125),(self.tShowData.h * self.tShowData.fDzRh + 7))
			elseif self.tInfo.sTid == e_build_ids.sowar then --骑兵营
				fScale = 0.5
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 150),(self.tShowData.h * self.tShowData.fDzRh + 5))
			elseif self.tInfo.sTid == e_build_ids.archer then --弓兵营
				fScale = 0.5
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 160),(self.tShowData.h * self.tShowData.fDzRh + 8))
			elseif self.tInfo.sTid == e_build_ids.gate then --城墙
				fScale = 0.35
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 70),(self.tShowData.h * self.tShowData.fDzRh - 95))
			elseif self.tInfo.sTid == e_build_ids.atelier then --作坊
				fScale = 0.43
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 115),(self.tShowData.h * self.tShowData.fDzRh + 8))
			elseif self.tInfo.sTid == e_build_ids.tjp then --铁匠铺
				fScale = 0.45
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 155),(self.tShowData.h * self.tShowData.fDzRh + 3))
			elseif self.tInfo.sTid == e_build_ids.ylp then --冶炼铺
				fScale = 0.45
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 95),(self.tShowData.h * self.tShowData.fDzRh + 5))
			elseif self.tInfo.sTid == e_build_ids.jxg then --将军府
				fScale = 0.6
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 70),(self.tShowData.h * self.tShowData.fDzRh + 4))
			elseif self.tInfo.sTid == e_build_ids.jbp then --珍宝阁
				fScale = 0.6
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 70),(self.tShowData.h * self.tShowData.fDzRh + 4))
			elseif self.tInfo.sTid == e_build_ids.bjt then --拜将台
				fScale = 0.45
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 115),(self.tShowData.h * self.tShowData.fDzRh + 9))
			elseif self.tInfo.sTid == e_build_ids.palace then --王宫
				fScale = 0.17
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 340),(self.tShowData.h * self.tShowData.fDzRh - 120))
			elseif self.tInfo.sTid == e_build_ids.tcf then --统帅府
				fScale = 0.6
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 70),(self.tShowData.h * self.tShowData.fDzRh + 4))
			elseif self.tInfo.sTid == e_build_ids.arena then --竞技场
				fScale = 0.6
				tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 70),(self.tShowData.h * self.tShowData.fDzRh + 4))
			elseif self.tInfo.sTid == e_build_ids.mbf then --募兵府
				if self.tInfo.nRecruitTp == e_mbf_camp_type.infantry then
					fScale = 0.55
					tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 125),(self.tShowData.h * self.tShowData.fDzRh + 7))
				elseif self.tInfo.nRecruitTp == e_mbf_camp_type.sowar then
					fScale = 0.5
					tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 150),(self.tShowData.h * self.tShowData.fDzRh + 5))
				elseif self.tInfo.nRecruitTp == e_mbf_camp_type.archer then
					fScale = 0.5
					tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 160),(self.tShowData.h * self.tShowData.fDzRh + 8))
				end
			end

			local pBuildImg = MUI.MImage.new(self.tShowData.img) --这里先临时全部统一用这个图片
			pBuildImg:setPosition(tPos)
			pBuildImg:setScale(fScale)
			self.pLayTop:addView(pBuildImg,50)
		end
	end

end



--初始化兵营招募兵种类型图片
function DlgBuildProp:initCampImg(  )
	-- body
	if self.tInfo then
		local sImgName = ""
		local fScale = 1.0
		local tPos = cc.p(0,0)
		if self.tInfo.sTid == e_build_ids.infantry then --步兵营
			sImgName = "#v1_img_bubingqs.png" 
			fScale = 0.58
			tPos = cc.p(25+15,10)
		elseif self.tInfo.sTid == e_build_ids.sowar then --骑兵营
			sImgName = "#v1_img_qibingqs.png" 
			fScale = 0.5
			tPos = cc.p(25+15,10)
		elseif self.tInfo.sTid == e_build_ids.archer then --弓兵营
			sImgName = "#v1_img_gongbingqs.png" 
			fScale = 0.58
			tPos = cc.p(45+15,10)
		elseif self.tInfo.sTid == e_build_ids.mbf then --募兵府
			if self.tInfo.nRecruitTp == e_mbf_camp_type.infantry then
				sImgName = "#v1_img_bubingqs.png" 
				fScale = 0.58
				tPos = cc.p(25+15,10)
			elseif self.tInfo.nRecruitTp == e_mbf_camp_type.sowar then
				sImgName = "#v1_img_qibingqs.png" 
				fScale = 0.5
				tPos = cc.p(25+15,10)
			elseif self.tInfo.nRecruitTp == e_mbf_camp_type.archer then
				sImgName = "#v1_img_gongbingqs.png" 
				fScale = 0.58
				tPos = cc.p(45+15,10)
			end
		end
		local pBuildImg = MUI.MImage.new(sImgName) --这里先临时全部统一用这个图片
		pBuildImg:setScale(fScale)
		pBuildImg:setPosition(cc.p(pBuildImg:getWidth() / 2 * pBuildImg:getScale() + tPos.x,pBuildImg:getHeight() / 2 * pBuildImg:getScale() + tPos.y))
		self.pLayTop:addView(pBuildImg,50)
	end
end

function DlgBuildProp:initMakeVo(  )
	-- body
	if self.tMakeVo then
		local tData = self.tMakeVo:getConfigData()
		if tData then
			getIconGoodsByType(self.pLayTarget, TypeIconGoods.NORMAL, type_icongoods_show.item, tData, TypeIconGoodsSize.L) 		
		end		
	end
end

function DlgBuildProp:initTnoly(  )
	-- body
	if self.tUpingTnoly then		
		getIconGoodsByType(self.pLayTarget,TypeIconGoods.NORMAL,type_icongoods_show.item,self.tUpingTnoly)
	end		
end

function DlgBuildProp:initCoinStr( )
	-- body
	if self.tCoinFastData then
		if not self.pBtnExTextGold then
			local tBtnTable = {}
			tBtnTable.parent = self:getLeftButton()
			tBtnTable.img = "#v1_img_qianbi.png"
			--文本
			tBtnTable.tLabel = {
				{"0",getC3B(_cc.blue)},
				{"/",getC3B(_cc.white)},
				{0,getC3B(_cc.white)},
			}			
			tBtnTable.awayH = 5			
			self.pBtnExTextGold = MBtnExText.new(tBtnTable)
		end
		-- self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
		-- self.pBtn:updateBtnText(getConvertedStr(1,10113))

		self.pBtnExTextGold:setBtnExTextEnabled(true)
		local sColor = getC3B(_cc.blue)
		if self.tCurFinishValue > Player:getPlayerInfo().nMoney then
			sColor = getC3B(_cc.red)
		end
		self.pBtnExTextGold:setLabelCnCr(3,self.tCurFinishValue)
		self.pBtnExTextGold:setLabelCnCr(1,Player:getPlayerInfo().nMoney, sColor)
	end
end

--刷新金币需求
function DlgBuildProp:refreshExCoin( )
	-- body
	if self.pBtnExTextGold then
		local sColor = getC3B(_cc.blue)
		if self.tCurFinishValue > Player:getPlayerInfo().nMoney then
			sColor = getC3B(_cc.red)
		end
		self.pBtnExTextGold:setLabelCnCr(3,self.tCurFinishValue)
		self.pBtnExTextGold:setLabelCnCr(1,Player:getPlayerInfo().nMoney, sColor)
	end
end

--更新进度条
function DlgBuildProp:refreshBar(_fLeftTime,_fTotalTime)
	-- body
	if _fLeftTime > 0 then
		local nPercent = math.floor((_fTotalTime - _fLeftTime) / _fTotalTime * 100)
		self.pLoadingBar:setPercent(nPercent)
	else
		self.pLoadingBar:setPercent(100)
	end
end

--滑动条释放消息回调
function DlgBuildProp:onSliderBarRelease( pView )
	-- body
	self.bRedoneSV = true
	local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
	self._nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
	if self._nselect <= 0 then
		self._nselect = 1
	end
	curvalue = self._nselect/self._nstuffs*100
	self.pSliderBar:setSliderValue(curvalue)		
end

--滑动滑动消息回调
function DlgBuildProp:onSliderBarChange( pView )
	-- body
	if self.bRedoneSV == true then
		local curvalue = self.pSliderBar:getSliderValue() --滑动条当前值
		local nselect = roundOff(self._nstuffs*curvalue/100, 1) --获取当前次数
		if nselect <= 0 then
			nselect = 1
		end
		self._nselect = nselect
	else
		self.bRedoneSV = true
	end
	self:refreshSelected()
end

--minusBtn减少按钮点击回调事件
function DlgBuildProp:onMinusBtnClicked( pView )
	-- body	
	local nselect = self._nselect - 1
	if nselect < 1  then
		nselect = 1			
	end
	self._nselect = nselect
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

--plusBtn增加按钮点击回调事件
function DlgBuildProp:onPlusBtnClicked( pView )
	-- body
	local nselect = self._nselect + 1
	if nselect > self._nstuffs then
		nselect = self._nstuffs		
	end
	self._nselect = nselect	
	self.bRedoneSV = false
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
end

function DlgBuildProp:refreshSelected(  )
	-- body
	self.pLbItemNum:setString(self._nselect)
	local pData = self:getSelectedItem()
	if not pData then
		return
	end
	local nTime = tonumber(pData.sParam or 0) * self._nselect
	local nPrize = pData.nPrice * self._nselect
	if not self.pBtnRightExTop then
		local tBtnTable = {}
		tBtnTable.parent = self:getRightButton()		
		--文本
		tBtnTable.tLabel = {
			{0,getC3B(_cc.blue)},
			{"/",getC3B(_cc.white)},
			{"0",getC3B(_cc.white)}
		}
		tBtnTable.awayH = 5
		self.pBtnRightExTop = MBtnExText.new(tBtnTable)
	end	

	if not self.pBtnRightExBot then
		local tBtnTable = {}
		tBtnTable.parent = self:getRightButton()
		--文本
		tBtnTable.tLabel = {
			{getConvertedStr(6, 10741),getC3B(_cc.white)},
			{formatTimeToHms(nTime),getC3B(_cc.blue)}
		}
		tBtnTable.awayH = -90
		self.pBtnRightExBot = MBtnExText.new(tBtnTable)
	else
		self.pBtnRightExBot:setLabelCnCr(2, formatTimeToHms(nTime))
	end
	--使用道具
	if self.bUse then
		self.pBtnRightExTop:setImg()
		self.pBtnRightExTop:setLabelCnCr(1, getConvertedStr(6, 10741), getC3B(_cc.white))
		self.pBtnRightExTop:setLabelCnCr(2, formatTimeToHms(nTime), getC3B(_cc.blue))
		self.pBtnRightExTop:setLabelCnCr(3, "")
	else
		local sColor = _cc.blue
		local nMyMoney = getMyGoodsCnt(e_type_resdata.money)
		if nPrize > nMyMoney then
			sColor = _cc.red
		end
		self.pBtnRightExTop:setImg("#v1_img_qianbi.png")
		self.pBtnRightExTop:setLabelCnCr(1, nMyMoney, getC3B(sColor))
		self.pBtnRightExTop:setLabelCnCr(2, "/", getC3B(_cc.white))
		self.pBtnRightExTop:setLabelCnCr(3, nPrize, getC3B(_cc.white))		
	end
	self.pBtnRightExBot:setVisible(not self.bUse)
end

--打开数字键盘
function DlgBuildProp:onOpenSetNum( pView )
	-- body
	print("打开数字键盘")
	showNumInputBoard(self._nselect ,self._nstuffs)
end

function DlgBuildProp:onSettingSelectNum( sMsgName, pMsgObj )
	-- body
	--dump(pMsgObj, "pMsgObj--------------------", 100)
	local nNum = pMsgObj or 1
	--更新进度条显示	
	self.bRedoneSV = true
	self._nselect = nNum
	self.pSliderBar:setSliderValue(self._nselect/self._nstuffs*100)	
	self:refreshSelected()
end
return DlgBuildProp