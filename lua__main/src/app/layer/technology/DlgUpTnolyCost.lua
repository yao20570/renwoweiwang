-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-11 09:50:57 星期四
-- Description: 
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local MBtnExText = require("app.common.button.MBtnExText")
local MRichLabel = require("app.common.richview.MRichLabel")

local DlgUpTnolyCost = class("DlgUpTnolyCost", function()
	-- body
	return DlgCommon.new(e_dlg_index.uptnolycost)
end)

function DlgUpTnolyCost:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_uping_cost", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgUpTnolyCost:myInit(  )
	-- body
	self.tCurDatas 		= 		nil  		--当前数据
	self.nCanUp 		= 		0 		    --0可以升级  1缺铜币   2缺木头
end

--解析布局回调事件
function DlgUpTnolyCost:onParseViewCallback( pView )
	-- body
	self:addContentView(pView,true) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgUpTnolyCost",handler(self, self.onDlgUpTnolyCostDestroy))
end

--初始化控件
function DlgUpTnolyCost:setupViews( )
	-- body

	--设置标题
	self:setTitle(getConvertedStr(1,10179))

	--信息层
	self.pLayDetail 		= 		self:findViewByName("lay_detail")
	--icon
	self.pLayIcon 			= 		self:findViewByName("lay_icon")
	--名字
	self.pLbName 			= 		self:findViewByName("lb_name")
	setTextCCColor(self.pLbName,_cc.blue)
	--等级
	self.pLbLv  			= 		self:findViewByName("lb_lv")
	-- setTextCCColor(self.pLbLv,_cc.white)
	--参数1 2
	self.pLbP1 		    	= 		self:findViewByName("lb_p1")
	setTextCCColor(self.pLbP1,_cc.pwhite)
	self.pLbP2  			= 		self:findViewByName("lb_p2")
	setTextCCColor(self.pLbP2,_cc.green)
	--描述
	self.pLbDesc 			= 		self:findViewByName("lb_desc")
	-- setTextCCColor(self.pLbDesc,_cc.pwhite)
	--消耗层
	self.pLayCost 			= 		self:findViewByName("lay_cost")
	self.pLayc1 			= 		self:findViewByName("lay_cost_1")
	self.pLayc2 			= 		self:findViewByName("lay_cost_2")

    --消耗
	--富文本控件（消耗1  银币）
	local tCostTable1 = {}
	tCostTable1.parent = self.pLayc1
	tCostTable1.img = "#v1_img_tongqian.png"
	tCostTable1.awayH = -35
	--文本
	tCostTable1.tLabel = {
		{"0",getC3B(_cc.blue)},
		{"/",getC3B(_cc.pwhite)},
		{0,getC3B(_cc.pwhite)}
	}
	self.pCostExText1 = MBtnExText.new(tCostTable1)
	--富文本控件（消耗2 木头）
	local tCostTable2 = {}
	tCostTable2.parent = self.pLayc2
	tCostTable2.img = "#v1_img_mucai.png"
	tCostTable2.awayH = -35
	--文本
	tCostTable2.tLabel = {
		{"0",getC3B(_cc.blue)},
		{"/",getC3B(_cc.pwhite)},
		{0,getC3B(_cc.pwhite)}
	}
	self.pCostExText2 = MBtnExText.new(tCostTable2)

	--按钮上的时间提示
	local tBtnTable = {}
	tBtnTable.parent = self.pBtnRight
	tBtnTable.img = "#v1_img_shizhong.png"
	--文本
	tBtnTable.tLabel = {
		{"00:00:00",getC3B(_cc.pwhite)},
	}
	self.pBtnExText = MBtnExText.new(tBtnTable,false)

	--国际化文字
	local pLbText 			= 		self:findViewByName("lb_title_cost")
	setTextCCColor(pLbText,_cc.white)
	pLbText:setString(getConvertedStr(1, 10180))


	self.pUpingText = MUI.MLabel.new({text = getConvertedStr(7, 10059), color = getC3B(_cc.red), size = 20})
	self.pLayBottom:addView(self.pUpingText, 10)
	self.pUpingText:setPosition(self.pLayBottom:getWidth()/2, 115)


	--设置右键按钮点击事件
	self:setRightHandler(handler(self, self.onUpClicked))

end

--新手引导研究按钮特效
function DlgUpTnolyCost:__nShowHandler( )
	-- body
	local tTaskData = Player:getPlayerTaskInfo():getCurAgencyTask()
	if tTaskData then
		local tData = luaSplit(tTaskData.sLinked, ":")
		--如果当前研究的科技id任务等于这个界面的科技id就加按钮特效
		if self.tCurDatas.sTid == tonumber(tData[2]) and
			self.pBtnRight:getBtnText() == getConvertedStr(1, 10174) then
			self.pBtnRight:showLingTx()
			--新手引导
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtnRight, e_guide_finer.technology_btn)
		else
			self.pBtnRight:removeLingTx()
		end
	end
end


-- 修改控件内容或者是刷新控件数据
function DlgUpTnolyCost:updateViews(  )
	-- body
	if self.tCurDatas then
		--icon
		getIconGoodsByType(self.pLayIcon,TypeIconGoods.NORMAL,type_icongoods_show.item,self.tCurDatas)
		--名字
		self.pLbName:setString(self.tCurDatas.sName, false)
		--等级
		local tStr = {
			{text = getLvString(self.tCurDatas.nLv,true), color = _cc.white},
			{text = " →", color = _cc.white},
			{text = getLvString(self.tCurDatas.nLv+1,true), color = _cc.green},
		}
		self.pLbLv:setString(tStr)

		--动态设置位置
		self.pLbLv:setPositionX(self.pLbName:getPositionX() + self.pLbName:getWidth())

		--设置升级数值变化
		self:setUpValue()

		--按钮控制
		local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
		if tUpingTnoly then
			self.pBtnExText:setBtnExTextEnabled(false)
			self.pUpingText:setVisible(true)
			self:setRightBtnText(getConvertedStr(7, 10145)) --前往查看
			--设置右键按钮点击事件
			self:setRightHandler(handler(self, self.goToDlgTechnology))
		else
			self.pUpingText:setVisible(false)
			self:setRightBtnText(getConvertedStr(1, 10174))
		end
	end
end

--前往科技院界面
function DlgUpTnolyCost:goToDlgTechnology()
	-- body
	self:closeDlg()
	if getDlgByType(e_dlg_index.tnolytree) then
		closeDlgByType(e_dlg_index.tnolytree, false)
	end
	local pDlg = getDlgByType(e_dlg_index.technology)
	if pDlg then
		pDlg:onScrollToBegin()
	else
		local tObject = {}
		tObject.nType = e_dlg_index.technology --科技院
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

-- 析构方法
function DlgUpTnolyCost:onDlgUpTnolyCostDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgUpTnolyCost:regMsgs( )
	-- body
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.refreshCostMsg))
end

-- 注销消息
function DlgUpTnolyCost:unregMsgs(  )
	-- body
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
end


--暂停方法
function DlgUpTnolyCost:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgUpTnolyCost:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置当前数据
function DlgUpTnolyCost:setCurData( _data )
	-- body
	self.tCurDatas = _data
	self:updateViews()
end

--设置升级数值变化
function DlgUpTnolyCost:setUpValue(  )
	-- body
	--获得当前已经升级的数据
	local tCurLimitData = self.tCurDatas:getCurLimitData()
	--获得下一等级的数据
	local tNextLimitData = self.tCurDatas:getNextLimitData()
	if tNextLimitData then
		--神兵暴击
		if self.tCurDatas.sTid == 3014 then
			local tCritsData = getTnolyInintDataFromDB("artifactCrits")
			if not tCritsData then
				-- self.pLbP1:setString("0-",false)
				-- self.pLbP2:setString("0",false)
				local tStr = {
					{text = tCurLimitData.desc, color = _cc.pwhite},
					{text = " → ", color = _cc.pwhite},
					{text = "0", color = _cc.green}
				}
				self.pLbDesc:setString(tStr)
			else
				-- if tCritsData[self.tCurDatas.nLv] then  --当前等级
				-- 	self.pLbP1:setString(tCritsData[self.tCurDatas.nLv].."-",false)
				-- else
				-- 	self.pLbP1:setString("0-",false)
				-- end
				if tCritsData[self.tCurDatas.nLv+1] then  --下一等级
					-- self.pLbP2:setString(tCritsData[self.tCurDatas.nLv+1],false)
					local tStr = {
						{text = tCurLimitData.desc, color = _cc.pwhite},
						{text = " → ", color = _cc.pwhite},
						{text = tCritsData[self.tCurDatas.nLv+1], color = _cc.green}
					}
					self.pLbDesc:setString(tStr)
				-- else
				-- 	self.pLbP2:setString("0",false)
				end
			end
		else
			local tBuffData = getBuffDataByIdFromDB(tNextLimitData.buffid)
			local sValue,nType = Player:getTnolyData():getEffectsValue(tBuffData)

			-- self.pLbP2:setString(sValue, false)
			if nType == 0 then
				self.pLbP1:setString("")
				self.pLbDesc:setString(tCurLimitData.desc)
			else
				-- if tCurLimitData then
				-- 	local tBuff = getBuffDataByIdFromDB(tCurLimitData.buffid)
				-- 	local sValue = Player:getTnolyData():getEffectsValue(tBuff)
				-- 	self.pLbP1:setString(sValue .. " - ", false)
				-- else
				-- 	if nType == 1 then
				-- 		self.pLbP1:setString("0% - ", false)
				-- 	elseif nType == 2 then
				-- 		self.pLbP1:setString("0 - ", false)
				-- 	end
				-- end
				local tStr = {
					{text = tCurLimitData.desc, color = _cc.pwhite},
					{text = " → ", color = _cc.pwhite},
					{text = sValue, color = _cc.green}
				}
				self.pLbDesc:setString(tStr)
			end
		
		end


	--获得下一级升级数据
	-- local tNextLimitData = self.tCurDatas:getNextLimitData()
	-- if tNextLimitData then
	-- 	self.pLbDesc:setString(tNextLimitData.desc)
	-- 	--获得buff
	-- 	local tBuffData = getBuffDataByIdFromDB(tNextLimitData.buffid)
	-- 	local sValue, nType = Player:getTnolyData():getEffectsValue(tBuffData)
	-- 	self.pLbP2:setString(sValue, false)

	-- 	if nType == 0 then
	-- 		self.pLbP1:setString("")
	-- 	else
	-- 		if tCurLimitData == nil then
	-- 			if nType == 1 then
	-- 				self.pLbP1:setString("0% - ", false)
	-- 			elseif nType == 2 then
	-- 				self.pLbP1:setString("0 - ", false)
	-- 			end
	-- 		end
	-- 	end

		--动态设置位置
		-- self.pLbP1:setPositionX(self.pLbLv:getPositionX() + self.pLbLv:getWidth() + 15)
		-- self.pLbP2:setPositionX(self.pLbP1:getPositionX() + self.pLbP1:getWidth())

		--进度
		if not self.pProcessLb then
			self.pProcessLb = MUI.MLabel.new({text="", size=22})  
		    self.pLayDetail:addView(self.pProcessLb)
    		self.pProcessLb:setAnchorPoint(cc.p(0,0.5))
		    --设置位置
		    self.pProcessLb:setPosition(306, 90)
		end

		local strTips = {
			{color=_cc.pwhite,text=getConvertedStr(1, 10176)},--进度
			{color=_cc.green,text=self.tCurDatas.nCurIndex},
			{color=_cc.pwhite,text=getConvertedStr(6, 10115)},--"/"
			{color=_cc.pwhite,text=tNextLimitData.section},
		}

		--设置当前段数
		self.pProcessLb:setString(strTips)

		--时间
		local nUptime = self.tCurDatas:getUpTime()
		self.pBtnExText:setLabelCnCr(1, formatTimeToHms(nUptime))

		--材料消耗
		self:refreshCostMsg()
	end
end

--材料消耗
function DlgUpTnolyCost:refreshCostMsg(  )
	-- body
	--获得下一级升级数据
	local tNextLimitData = self.tCurDatas:getNextLimitData()
	if tNextLimitData then
		--木头
		self.tResList = {}
		self.tResList[e_resdata_ids.lc] = 0
		self.tResList[e_resdata_ids.bt] = 0
		self.tResList[e_resdata_ids.mc] = 0
		self.tResList[e_resdata_ids.yb] = 0
		local nWood = tonumber(tNextLimitData.woodcost)
		local nHasWood = Player:getPlayerInfo().nWood
		self.tResList[e_resdata_ids.mc] = nWood
		if nWood > nHasWood then
			self.nCanUp = 2
			self.pCostExText2:setLabelCnCr(3,getResourcesStr(nWood))
			self.pCostExText2:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nWood),getC3B(_cc.red))
		else
			self.pCostExText2:setLabelCnCr(3,getResourcesStr(nWood))
			self.pCostExText2:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nWood),getC3B(_cc.green))
			
		end
		--银币
		local nCoin = tonumber(tNextLimitData.coincost)
		local nHasCoin = Player:getPlayerInfo().nCoin
		self.tResList[e_resdata_ids.yb] = nCoin
		if nCoin > nHasCoin then
			self.nCanUp = 1
			self.pCostExText1:setLabelCnCr(3,getResourcesStr(nCoin))
			self.pCostExText1:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nCoin),getC3B(_cc.red))
		else
			self.pCostExText1:setLabelCnCr(3,getResourcesStr(nCoin))
			self.pCostExText1:setLabelCnCr(1,getResourcesStr(Player:getPlayerInfo().nCoin),getC3B(_cc.green))
		end
		
		
		--再判断一下是否满足研究消耗
		if nHasCoin >= nCoin and nHasWood >= nWood then
			self.nCanUp = 0
		end
		
	end
end

--对话框右键按钮点击事件
function DlgUpTnolyCost:onUpClicked( pView )
	-- body
	if self.pBtnRight:getBtnText() == getConvertedStr(1, 10174) then
		local nvip = getArmyVipLvLimit(e_id_item.kjky)
		local nBuildStatus = Player:getBuildData():getBuildById(e_build_ids.tnoly).nState
		if nBuildStatus == e_build_state.uping then
			--已经购买了vip5礼包
			if Player:getPlayerInfo():getIsBoughtVipGift(nvip) then
				--未雇佣紫色研究员
				if not getIsCanTnolyUpingWithTecnologying() then
					local tObject = {}
					tObject.nType = e_dlg_index.dlgemploytip --dlg类型
					tObject.nTipIdx = 10035
					sendMsg(ghd_show_dlg_by_type, tObject)
					self:closeDlg()
				else
					self:upTnoly()
				end
			--没购买vip5礼包
			else
				local tShopBase = {}
				tShopBase.id = e_id_item.kjky
		    	-- dump(tShopBase, "tShopBase", 100)
				local tObject = {
				    nType = e_dlg_index.vipgitfgoodtip, --dlg类型
				    tShopBase = tShopBase,
				    sTopTip = getTextColorByConfigure(getTipsByIndex(20025))
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
			end
		else
			self:upTnoly()
		end	
	else
		self:closeDlg()
	end
	
end

--研究科技
function DlgUpTnolyCost:upTnoly()
	-- body
	if self.nCanUp > 0 then --资源不足
		local tObject = {}
		tObject.nType = e_dlg_index.getresource --dlg类型
		tObject.nIndex = self.nCanUp
		tObject.tValue = self.tResList
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		local tObject = {}
		tObject.nId = self.tCurDatas.sTid
		sendMsg(ghd_uping_tnoly_msg, tObject)
		self:closeDlg()
		--新手引导已点
		Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.technology_btn)
	end
end

return DlgUpTnolyCost