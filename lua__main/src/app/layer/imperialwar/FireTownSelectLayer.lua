----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 10:54:00
-- Description: 烽火台选择
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local FireTownSelectLayer = class("FireTownSelectLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function FireTownSelectLayer:ctor(  )
	--解析文件
	self.nSelectIndex = 1
	parseView("layout_fire_town_select", handler(self, self.onParseViewCallback))
end

--解析界面回调
function FireTownSelectLayer:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("FireTownSelectLayer", handler(self, self.onFireTownSelectLayerDestroy))
end

-- 析构方法
function FireTownSelectLayer:onFireTownSelectLayerDestroy(  )
    self:onPause()
end

function FireTownSelectLayer:regMsgs(  )
end

function FireTownSelectLayer:unregMsgs(  )
end

function FireTownSelectLayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function FireTownSelectLayer:onPause(  )
	self:unregMsgs()
end

function FireTownSelectLayer:setupViews(  )
	local pTxtContent = self:findViewByName("txt_content")
	pTxtContent:setString(getConvertedStr(3, 10920))

	self.tCityId = {
		11182,
		11183,
		11184,
		11185,
	}	
	local pTxtTitle1 = self:findViewByName("txt_title1")
	local tSysCityData = getWorldCityDataById(self.tCityId[1])
	if tSysCityData then
		pTxtTitle1:setString(tSysCityData.name)
	end

	local pTxtTitle2 = self:findViewByName("txt_title2")
	local tSysCityData = getWorldCityDataById(self.tCityId[2])
	if tSysCityData then
		pTxtTitle2:setString(tSysCityData.name)
	end

	local pTxtTitle3 = self:findViewByName("txt_title3")
	local tSysCityData = getWorldCityDataById(self.tCityId[3])
	if tSysCityData then
		pTxtTitle3:setString(tSysCityData.name)
	end

	local pTxtTitle4 = self:findViewByName("txt_title4")
	local tSysCityData = getWorldCityDataById(self.tCityId[4])
	if tSysCityData then
		pTxtTitle4:setString(tSysCityData.name)
	end

	self.pImgSelect1 = self:findViewByName("img_select1")
	self.pImgSelect2 = self:findViewByName("img_select2")
	self.pImgSelect3 = self:findViewByName("img_select3")
	self.pImgSelect4 = self:findViewByName("img_select4")

	local pLaySelect1 = self:findViewByName("lay_select1")
	local pLaySelect2 = self:findViewByName("lay_select2")
	local pLaySelect3 = self:findViewByName("lay_select3")
	local pLaySelect4 = self:findViewByName("lay_select4")

	pLaySelect1:setViewTouched(true)
	pLaySelect1:setIsPressedNeedScale(false)
	pLaySelect1:setIsPressedNeedColor(false)
	pLaySelect1:onMViewClicked(function ( _pView )
	    self:setCurrSelectIndex(1)
	end)

	pLaySelect2:setViewTouched(true)
	pLaySelect2:setIsPressedNeedScale(false)
	pLaySelect2:setIsPressedNeedColor(false)
	pLaySelect2:onMViewClicked(function ( _pView )
	    self:setCurrSelectIndex(2)
	end)

	pLaySelect3:setViewTouched(true)
	pLaySelect3:setIsPressedNeedScale(false)
	pLaySelect3:setIsPressedNeedColor(false)
	pLaySelect3:onMViewClicked(function ( _pView )
	    self:setCurrSelectIndex(3)
	end)

	pLaySelect4:setViewTouched(true)
	pLaySelect4:setIsPressedNeedScale(false)
	pLaySelect4:setIsPressedNeedColor(false)
	pLaySelect4:onMViewClicked(function ( _pView )
	    self:setCurrSelectIndex(4)
	end)
end

function FireTownSelectLayer:updateViews(  )
	
end

function FireTownSelectLayer:setCurrSelectIndex( nIndex )
	self.nSelectIndex = nIndex

	local sImgSelected = "#v2_img_gouxuan.png"
	local sImgBorder = "#v2_img_gouxuankuang.png"
	if nIndex == 1 then
		self.pImgSelect1:setCurrentImage(sImgSelected)
	else
		self.pImgSelect1:setCurrentImage(sImgBorder)
	end
	if nIndex == 2 then
		self.pImgSelect2:setCurrentImage(sImgSelected)
	else
		self.pImgSelect2:setCurrentImage(sImgBorder)
	end
	if nIndex == 3 then
		self.pImgSelect3:setCurrentImage(sImgSelected)
	else
		self.pImgSelect3:setCurrentImage(sImgBorder)
	end
	if nIndex == 4 then
		self.pImgSelect4:setCurrentImage(sImgSelected)
	else
		self.pImgSelect4:setCurrentImage(sImgBorder)
	end
end

function FireTownSelectLayer:getCurrSelectCityId( )
	return self.tCityId[self.nSelectIndex]
end



return FireTownSelectLayer


