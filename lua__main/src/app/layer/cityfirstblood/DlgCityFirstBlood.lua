----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-24 11:35:35
-- Description: 城池首杀
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local LayCityFirstBloodKilled = require("app.layer.cityfirstblood.LayCityFirstBloodKilled")
local LayCityFirstBloodNull = require("app.layer.cityfirstblood.LayCityFirstBloodNull")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local DlgCityFirstBlood = class("DlgCityFirstBlood", function()
	return DlgBase.new(e_dlg_index.cityfirstblood)
end)

function DlgCityFirstBlood:ctor(  )
	parseView("dlg_city_first_blood", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityFirstBlood:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityFirstBlood",handler(self, self.onDlgCityFirstBloodDestroy))
end

-- 析构方法
function DlgCityFirstBlood:onDlgCityFirstBloodDestroy(  )
    self:onPause()
    Player:getWorldData():flushNewLocalCFBlood()
end

function DlgCityFirstBlood:regMsgs(  )
	--监听首杀记录
	regMsg(self, gud_city_first_blood_refresh, handler(self, self.onCFBloodRefresh))
	--监听首杀红点
	regMsg(self, gud_city_first_blood_red, handler(self, self.updateRedNum))
	
end

function DlgCityFirstBlood:unregMsgs(  )
	--监听首杀记录
	unregMsg(self, gud_city_first_blood_refresh)
	--监听首杀红点
	unregMsg(self, gud_city_first_blood_red)
end

function DlgCityFirstBlood:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgCityFirstBlood:onPause(  )
	self:unregMsgs()
end

function DlgCityFirstBlood:setupViews(  )
	self.pLayBtns = self:findViewByName("lay_btns")
	self.pLayContent = self:findViewByName("lay_content")

	local pLayInfo = self:findViewByName("lay_info_bg")
	pLayInfo:setBackgroundImage("ui/big_img_sep/v2_bg_caijibeijing.jpg",{scale9 = true,capInsets=cc.rect(640/2, 191*0.95, 1, 1)})
	pLayInfo:setOpacity(0.3* 255)

	-- local tBtnData = {
	-- 	{kind = 1, x = 10, y = 84, sStr = getConvertedStr(3, 10527)},
	-- 	{kind = 2, x = 10 + 150 + 7, y = 84, sStr = getConvertedStr(3, 10528)},
	-- 	{kind = 3, x = 10 + 150 + 7 + 150 + 6, y = 84, sStr = getConvertedStr(3, 10529)},
	-- 	{kind = 4, x = 10 + 150 + 7 + 150 + 6 + 150 + 7, y = 84, sStr = getConvertedStr(3, 10530)},

	-- 	{kind = 5, x = 10, y = 18, sStr = getConvertedStr(3, 10531)},
	-- 	{kind = 6, x = 10 + 150 + 7, y = 18, sStr = getConvertedStr(3, 10532)},
	-- 	{kind = 7, x = 10 + 150 + 7 + 150 + 6, y = 18, sStr = getConvertedStr(3, 10533)},		
	-- }
	-- self.tBtnDict = {}
	-- for i=1,#tBtnData do
	-- 	self:createTabBtn(tBtnData[i])
	-- end

	--切换表格
	local tTitles = {
		"1",
		"2",
		"3"
	}
	self.pTComTabHost = TCommonTabHost.new(self.pLayBtns,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pTabItems = self.pTComTabHost:getTabItems()
	for i=1,#self.pTabItems do
		self.pTabItems[i].nIndex = i
	end
	self.pLayBtns:addView(self.pTComTabHost)
	-- centerInView(self.pLayBtns, self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()
	self.pTComTabHost:removeLayTmp2()
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtCityKind = self:findViewByName("txt_city_kind")
	self.pTxtAtkCountry = self:findViewByName("txt_atk_country")
	self.pTxtInfoTip = self:findViewByName("txt_info_tip")
	-- self.pLayBtnAll = self:findViewByName("lay_btn_all")
	-- showRedTips(self.pLayBtnAll, 0, 0, 2)
	-- local pBtnAll = getCommonButtonOfContainer(self.pLayBtnAll,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10583))
	-- pBtnAll:onCommonBtnClicked(handler(self, self.onGoTotalClicked))
	-- self.pBtnAll = pBtnAll
end

function DlgCityFirstBlood:updateViews(  )
	if not self.nKind then
		return
	end

	--
	local tCFBloodVo = Player:getWorldData():getCityFirstBlood(self.nKind, self.nBlockId)
	if tCFBloodVo then
		--隐藏
		if self.pCFBloodNull then
			self.pCFBloodNull:setVisible(false)
		end
		--显示或加载
		if self.pCFBloodKilled then
			self.pCFBloodKilled:setVisible(true)
		else
			self.pCFBloodKilled = LayCityFirstBloodKilled.new()
			self.pLayContent:addView(self.pCFBloodKilled)
		end
		self.pCFBloodKilled:setData(tCFBloodVo)

		--主要信息
		local tCityData = getWorldCityDataById(tCFBloodVo.nSysCityId) 
		if tCityData then
			local tBlockData = getWorldMapDataById(tCityData.map)
			if tBlockData then
				self.pTxtCityKind:setString(tCityData.name.."  "..getConvertedStr(3, 10540)..tBlockData.name)
			end

			WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tCFBloodVo.nSysCityId, tCFBloodVo.nStartCountry, true)
		end
		self.pTxtAtkCountry:setString(getConvertedStr(3, 10535) .. getCountryShortName(tCFBloodVo.nStartCountry))
	else
		--隐藏
		if self.pCFBloodKilled then
			self.pCFBloodKilled:setVisible(false)
		end
		--显示或加载
		if self.pCFBloodNull then
			self.pCFBloodNull:setVisible(true)
		else
			self.pCFBloodNull = LayCityFirstBloodNull.new()
			self.pLayContent:addView(self.pCFBloodNull)
		end
		self.pCFBloodNull:setData(self.nKind, self.nBlockId, self.bIsFromTotal)
		--主要信息
		local tCityDataDict = getWorldCityData()
		for nSysCityId,tCityData in pairs(tCityDataDict) do
			if tCityData.kind == self.nKind then
				WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tCityData.id, e_type_country.qunxiong, true)
				break
			end
		end
		self.pTxtCityKind:setString(getCityKindStr(self.nKind))
		self.pTxtAtkCountry:setString(getConvertedStr(3, 10535) .. getConvertedStr(3, 10536))
	end

	--提示
	local tTip = {
		20067,
		20068,
		20069,
		20070,
		20071,
		20072,
		20073,
		20092,
	}
	local nTipId = tTip[self.nKind]
	if nTipId then
		self.pTxtInfoTip:setString(getTipsByIndex(nTipId))
		-- if self.bIsFromTotal then
		-- 	self.pTxtInfoTip:setDimensions(610, 66)
		-- else
		-- 	self.pTxtInfoTip:setDimensions(470, 66)
		-- end
	end
end

-- function DlgCityFirstBlood:createTabBtn( tData  )
-- 	local pLayBtn = MUI.MLayer.new()
-- 	self.pLayBtns:addView(pLayBtn)
-- 	local nKind = tData.kind
-- 	self.tBtnDict[nKind] = pLayBtn

-- 	local pLayRed = MUI.MLayer.new()
-- 	pLayBtn:addView(pLayRed)
-- 	pLayRed:setLayoutSize(20, 20)
-- 	pLayRed:setPosition(150 - 10, 46 - 10)
-- 	pLayBtn.pLayRed = pLayRed

-- 	pLayBtn:setLayoutSize(150, 46)
-- 	pLayBtn:setPosition(tData.x, tData.y)
-- 	pLayBtn:setViewTouched(true)
-- 	pLayBtn:onMViewClicked(function ( _pView )
-- 	    self:onChangeTab(nKind)
-- 	end)
-- 	local sStr = string.format(getConvertedStr(3, 10534), getCityKindStr(tData.kind))
-- 	local pLabel = MUI.MLabel.new({text = sStr, size = 20})
-- 	pLayBtn:addView(pLabel)
-- 	centerInView(pLayBtn, pLabel)
-- end

--nBlockId       --指定区域
function DlgCityFirstBlood:setData( nBlockId)
	self.bIsFromTotal = true --是否从总览过来
	if not nBlockId then
		nBlockId = Player:getWorldData():getMyCityBlockId()
		self.bIsFromTotal = false
	end
	self.nBlockId = nBlockId

	--区域表
	local tBlockData = getWorldMapDataById(self.nBlockId)
	--设置区域按钮
	local tBtnItem = {
		[e_type_block.jun] = {
			{sBtnStr = getConvertedStr(3, 10584), nKind = e_kind_city.junyin},
			{sBtnStr = getConvertedStr(3, 10585), nKind = e_kind_city.junxian},
			{sBtnStr = getConvertedStr(3, 10586), nKind = e_kind_city.juncheng},
		},
		[e_type_block.zhou] = {
			{sBtnStr = getConvertedStr(3, 10587), nKind = e_kind_city.zhouxian},
			{sBtnStr = getConvertedStr(3, 10588), nKind = e_kind_city.zhoufu},
			{sBtnStr = getConvertedStr(3, 10589), nKind = e_kind_city.zhoucheng},
		},
		[e_type_block.kind] = {
			{sBtnStr = getConvertedStr(3, 10590), nKind = e_kind_city.mingcheng},
			{sBtnStr = getConvertedStr(3, 10591), nKind = e_kind_city.ducheng},
		},
	}

	--标题
	self:setTitle(string.format(getConvertedStr(3, 10592), tBlockData.name))

	--更改按钮
	local tBtnList = tBtnItem[tBlockData.type]
	self.tBtnList = tBtnList
	if tBtnList then
		local nTabNums = #tBtnList
		if #self.pTabItems ~= nTabNums then
			local tTabTitles = {}
			for i=1,#tBtnList do
				table.insert(tTabTitles, tBtnList[i].sBtnStr)
			end
			self.pTComTabHost:resetTabTitles(tTabTitles)
			self.pTabItems = self.pTComTabHost:getTabItems()
		else
			for i=1,#self.pTabItems do
				self.pTabItems[i]:setTabTitle(tBtnList[i].sBtnStr)
			end
		end
		--附加nKind到按钮上
		for i=1,#self.pTabItems do
			local pTabItem = self.pTabItems[i]
			pTabItem.nKind = tBtnList[i].nKind
		end
	end

	--倒序遍历有数据而最高的城池首杀
	local nIndex = 1
	for i=#self.tBtnList, 1, -1 do
		local tCFBloodVo = Player:getWorldData():getCityFirstBlood(self.tBtnList[i].nKind, self.nBlockId)
		if tCFBloodVo then
			nIndex = i
			break
		end
	end
	--切换指定的分页
	self.pTComTabHost:setDefaultIndex(nIndex)

	--从总览过来
	-- if self.bIsFromTotal then
	-- 	self.pLayBtnAll:setVisible(false)
	-- else
	-- 	self.pLayBtnAll:setVisible(true)
	-- end

	--
	self:updateRedNum()
end

--标签切换
function DlgCityFirstBlood:onIndexSelected( nIndex )
	self.nKind = self.tBtnList[nIndex].nKind
	--更新已阅红点
	Player:getWorldData():addNewLocalCFBlood(self.nKind, self.nBlockId)
	self:updateViews()
end

--刷新数据
function DlgCityFirstBlood:onCFBloodRefresh( sMsgName, pMsgObj)
	if pMsgObj and pMsgObj.nKind == self.nKind then
		--更新已阅红点
		Player:getWorldData():addNewLocalCFBlood(self.nKind, self.nBlockId)
		self:updateViews()
	end
end

--更新红点
function DlgCityFirstBlood:updateRedNum( )
	for i=1,#self.pTabItems do
		local pTabItem = self.pTabItems[i]
		local pLayRed = pTabItem:getRedNumLayer()
		local nKind = pTabItem.nKind
		if nKind == self.nKind then
			showRedTips(pLayRed, 0, 0, 2)
		else
			if Player:getWorldData():getIsNewCFBlood(nKind, self.nBlockId) then
				showRedTips(pLayRed, 0, 1, 2)
			else
				showRedTips(pLayRed, 0, 0, 2)
			end
		end
	end
	--uk
	-- if Player:getWorldData():getFirstBloodRed() then
	-- 	showRedTips(self.pLayBtnAll, 0, 1, 2)
	-- else
	-- 	showRedTips(self.pLayBtnAll, 0, 0, 2)
	-- end
end

--前往总览
function DlgCityFirstBlood:onGoTotalClicked(  )
	local tObject = {
	    nType = e_dlg_index.worldmapfirstblood,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

return DlgCityFirstBlood