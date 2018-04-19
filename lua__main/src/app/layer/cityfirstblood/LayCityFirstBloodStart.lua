----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-24 11:39:27
-- Description: 城池首杀 发起
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local LayCityFirstBloodStart = class("LayCityFirstBloodStart", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LayCityFirstBloodStart:ctor(  )
	--解析文件
	parseView("lay_city_first_blood_start", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LayCityFirstBloodStart:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayCityFirstBloodStart", handler(self, self.onLayCityFirstBloodStartDestroy))
end

-- 析构方法
function LayCityFirstBloodStart:onLayCityFirstBloodStartDestroy(  )
    self:onPause()
end

function LayCityFirstBloodStart:regMsgs(  )
end

function LayCityFirstBloodStart:unregMsgs(  )
end

function LayCityFirstBloodStart:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function LayCityFirstBloodStart:onPause(  )
	self:unregMsgs()
end

function LayCityFirstBloodStart:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	self.pImgAtkCountry = self:findViewByName("img_country")
	
end

function LayCityFirstBloodStart:updateViews(  )
	if not self.tFBer then
		return
	end
	local tActorVo = self.tFBer:getActorVo()
	if tActorVo then
		if not self.pIcon then
			self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.header, tActorVo, TypeIconHeroSize.L)
			centerInView(self.pLayIcon,self.pIcon)
			self.pIcon:setPosition(0, -35)
		else
			self.pIcon:setCurData(tActorVo)
		end
		self.pTxtName:setString(self.tFBer.sName)
	end
end
function LayCityFirstBloodStart:setAttkCountry( _nCountry )
	-- body
	if _nCountry then
		self.pImgAtkCountry:setCurrentImage(getCountryShortImg(_nCountry))
	else
		self.pImgAtkCountry:setVisible(false)
	end
end

--tFBer
function LayCityFirstBloodStart:setData( tFBer )
	self.tFBer = tFBer
	self:updateViews()
end


return LayCityFirstBloodStart


