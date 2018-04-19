----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-19 14:57:36
-- Description: 世界大地图左边 国战列表 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemWorldLeftCountryWar = class("ItemWorldLeftCountryWar", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWorldLeftCountryWar:ctor(  )
	--解析文件
	parseView("item_world_left_country_war", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWorldLeftCountryWar:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWorldLeftCountryWar",handler(self, self.onItemWorldLeftCountryWarDestroy))
end

-- 析构方法
function ItemWorldLeftCountryWar:onItemWorldLeftCountryWarDestroy(  )
    self:onPause()
end

function ItemWorldLeftCountryWar:regMsgs(  )
end

function ItemWorldLeftCountryWar:unregMsgs(  )
end

function ItemWorldLeftCountryWar:onResume(  )
	self:regMsgs()
	--更新
	regUpdateControl(self, handler(self, self.updateCd))
end

function ItemWorldLeftCountryWar:onPause(  )
	self:unregMsgs()

	unregUpdateControl(self)
end

function ItemWorldLeftCountryWar:setupViews(  )
	self.pTxtAtkOrDef = self:findViewByName("txt_atk_or_def")
	self.pImgArrow = self:findViewByName("img_arrow")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtCd = self:findViewByName("txt_cd")
	setTextCCColor(self.pTxtCd, _cc.green)
	self.pLayIcon = self:findViewByName("lay_icon")

	self.pLayIcon:setViewTouched(true)
	self.pLayIcon:setIsPressedNeedScale(false)
	self.pLayIcon:onMViewClicked(handler(self, self.onLocationClicked))
end

function ItemWorldLeftCountryWar:updateViews(  )
	if not self.tData then
		return
	end

	if self.tData.nDefCountry == Player:getPlayerInfo().nInfluence then
		self.pTxtAtkOrDef:setString(getConvertedStr(3, 10098))
		self.pImgArrow:setCurrentImage("#v1_img_lvqian.png")
	else
		self.pTxtAtkOrDef:setString(getConvertedStr(3, 10097))
		self.pImgArrow:setCurrentImage("#v1_img_hongqian.png")
	end
	local tCityData = getWorldCityDataById(self.tData.nId)
	if tCityData then
		self.pTxtName:setString(tCityData.name)
		WorldFunc.getSysCityIconOfContainer(self.pLayIcon, tCityData.id, self.tData.nDefCountry, true)
	end
	self:updateCd()
end

function ItemWorldLeftCountryWar:updateCd()
	if not self.tData then
		return
	end
	local tCountryWarMsg = Player:getWorldData():getMyCountryWar(self.tData.sId)
	if tCountryWarMsg then
		self.pTxtCd:setString(formatTimeToHms(tCountryWarMsg:getCd()))
	end
end

--tData:  tCountryMsg类型
function ItemWorldLeftCountryWar:setData( tData)
	self.tData = tData
	self:updateViews()
end

--定位回调
function ItemWorldLeftCountryWar:onLocationClicked(  )
	if not self.tData then
		return
	end
	local tCityData = getWorldCityDataById(self.tData.nId)
	if tCityData then
		sendMsg(ghd_world_location_mappos_msg, {fX = tCityData.tMapPos.x, fY = tCityData.tMapPos.y, isClick = true})
	end
end

return ItemWorldLeftCountryWar