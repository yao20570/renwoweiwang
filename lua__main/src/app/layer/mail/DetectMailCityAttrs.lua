----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-23 14:34:31
-- Description: 侦查界面 城池属性
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local DetectMailCityAttrs = class("DetectMailCityAttrs", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function DetectMailCityAttrs:ctor( tScoutResult )
	self.tScoutResult = tScoutResult
	--解析文件
	parseView("lay_detect_mail_city_attrs", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DetectMailCityAttrs:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DetectMailCityAttrs",handler(self, self.onDetectMailCityAttrsDestroy))
end

-- 析构方法
function DetectMailCityAttrs:onDetectMailCityAttrsDestroy(  )
    self:onPause()
end

function DetectMailCityAttrs:regMsgs(  )
end

function DetectMailCityAttrs:unregMsgs(  )
end

function DetectMailCityAttrs:onResume(  )
	self:regMsgs()
end

function DetectMailCityAttrs:onPause(  )
	self:unregMsgs()
end

function DetectMailCityAttrs:setupViews(  )
	local pTxtPowerTitle = self:findViewByName("txt_power_title")
	pTxtPowerTitle:setString(getConvertedStr(3, 10233))
	local pTxtPower = self:findViewByName("txt_power")
	setTextCCColor(pTxtPower, _cc.yellow) 
	pTxtPower:setString(self.tScoutResult.nPower)
	local pTxtWallLvTitle = self:findViewByName("txt_wall_lv_title")
	pTxtWallLvTitle:setString(getConvertedStr(3, 10234))
	local pTxtWallLv = self:findViewByName("txt_wall_lv")
	setTextCCColor(pTxtWallLv, _cc.blue)
	pTxtWallLv:setString(getLvString(self.tScoutResult.nWallLv))
	local pTxtInfantry = self:findViewByName("txt_infantry")
	pTxtInfantry:setString(self.tScoutResult.nInfantry)
	local pTxtCavalry = self:findViewByName("txt_cavalry")
	pTxtCavalry:setString(self.tScoutResult.nCavalry)
	local pTxtArcher = self:findViewByName("txt_archer")
	pTxtArcher:setString(self.tScoutResult.nArcher)
end

function DetectMailCityAttrs:updateViews(  )
end

return DetectMailCityAttrs


