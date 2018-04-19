----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 18:24:43
-- Description: 城池详细界面
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")

local TabManager = require("app.common.TabManager")
local CityDetailDetect = require("app.layer.world.CityDetailDetect")
local CityDetailAttack = require("app.layer.world.CityDetailAttack")

local nImperialCityMapId = 1013 --皇城mapId

local DlgCityDetail = class("DlgCityDetail", function()
	return DlgCommon.new(e_dlg_index.citydetail, 800 - 60 - 70, 70)
end)

function DlgCityDetail:ctor(  )
	parseView("dlg_city_detail", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgCityDetail:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, false) --加入内容层

	self:setTitle(getConvertedStr(3, 10021))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgCityDetail",handler(self, self.onDlgCityDetailDestroy))
end

-- 析构方法
function DlgCityDetail:onDlgCityDetailDestroy(  )
    self:onPause()
end

function DlgCityDetail:regMsgs(  )
end

function DlgCityDetail:unregMsgs(  )
end

function DlgCityDetail:onResume(  )
	self:regMsgs()
end

function DlgCityDetail:onPause(  )
	self:unregMsgs()
end

function DlgCityDetail:setupViews(  )
	--ui位置更新
	local tUiPos = {
		{sUiName = "lay_info", nTopSpac = 12},
		{sUiName = "lay_content", nTopSpac = 10},
	}
	restUiPosByData(tUiPos, self.pView)
	--ui位置更新

	--默认显示
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtPos = self:findViewByName("txt_pos")
	self.pTxtMoveTime = self:findViewByName("txt_move_time")
	setTextCCColor(self.pTxtMoveTime, _cc.green)
	self.pImgFlag = self:findViewByName("img_flag")
	self.pLayIcon = self:findViewByName("lay_icon")

	--切换卡
	--内容层
	self.tTitles = {
		getConvertedStr(3, 10023),
		getConvertedStr(3, 10022),
	}
	self.pLyContent 	  = 		self:findViewByName("lay_content")
	self.pTabHost = FCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.getLayerByKey))
	self.pTabHost:setLayoutSize(self.pLyContent:getLayoutSize())
	self.pTabHost:removeLayTmp1()
	self.pTabHost:removeLayTmp2()
	self.pLyContent:addView(self.pTabHost,10)
	self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))
end

--通过key值获取内容层的layer
function DlgCityDetail:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil
	local pdata = {}
	if( _sKey == _tKeyTabLt[1] ) then
		pLayer = CityDetailAttack.new()	
		self.pCityDetailAttack = pLayer
	elseif (_sKey == _tKeyTabLt[2] ) then
		pLayer = CityDetailDetect.new()
		self.pCityDetailDetect = pLayer
	end
	return pLayer
end

function DlgCityDetail:onTabChanged( skey, nType)
	if nType == 0 then
		if self.pCityDetailAttack then
			self.pCityDetailAttack:setData(self.tData)
		end
	elseif nType == 1 then
		if self.pCityDetailDetect then
			self.pCityDetailDetect:setData(self.tData)
		end
	end
end

function DlgCityDetail:updateViews(  )
	if not self.tData then
		return
	end

	self.pTxtName:setString(string.format("%s %s", self.tData:getDotName(), getLvString(self.tData.nDotLv)))
	self.pTxtPos:setString(getConvertedStr(3, 10109) .. getWorldPosString(self.tData.nX, self.tData.nY))
	--预计行军时间
	local nMoveTime = 0
	if self.bIsMarchTimes then
		local tTimes = getWorldInitData("marchTimes")
		nMoveTime = tostring(tTimes[1]) or 0
	else
		nMoveTime = WorldFunc.getMyArmyMoveTime(self.tData.nX, self.tData.nY)
	end

	self.pTxtMoveTime:setString(getConvertedStr(3, 10019) .. formatTimeToMs(nMoveTime))
	WorldFunc.setImgCountryFlag(self.pImgFlag, self.tData.nDotCountry)

	--图标
	WorldFunc.getCityIconOfContainer(self.pLayIcon, self.tData.nDotCountry, self.tData.nDotLv, true)
end

--tData: ViewDotMsg
--nIndex: 界面页数 1，2
function DlgCityDetail:setData( tData, nIndex)
	self.tData = tData

	--阿房宫时间
	local nMyBlockId = Player:getWorldData():getMyCityBlockId()
	local nTargetBlockId = WorldFunc.getBlockId(self.tData.nX, self.tData.nY)
	self.bIsMarchTimes = false
	if nMyBlockId ~= nTargetBlockId then
		if nMyBlockId == nImperialCityMapId then
			self.bIsMarchTimes = true
		end
	end

	--侦查或城战
	self.pTabHost:setDefaultIndex(nIndex)

	--更新视图
	self:updateViews()

	--设置子面板数据
	if self.pCityDetailAttack then
		self.pCityDetailAttack:setData(self.tData)
	end
	if self.pCityDetailDetect then
		self.pCityDetailDetect:setData(self.tData)
	end
end

function DlgCityDetail:onBtnCancelClicked(  )
	self:closeDlg(false)
end

function DlgCityDetail:onBtnAttackClicked(  )
	-- body
end

return DlgCityDetail