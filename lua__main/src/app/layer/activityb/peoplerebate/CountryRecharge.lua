----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-05 09:30:47
-- Description: 国家累积充值
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local CountryRecharge = class("CountryRecharge", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nIndex --排名
function CountryRecharge:ctor( nIndex )
	self.nIndex = nIndex
	--解析文件
	parseView("lay_country_recharge", handler(self, self.onParseViewCallback))
end

--解析界面回调
function CountryRecharge:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("CountryRecharge", handler(self, self.onCountryRechargeDestroy))
end

-- 析构方法
function CountryRecharge:onCountryRechargeDestroy(  )
    self:onPause()
end

function CountryRecharge:regMsgs(  )
end

function CountryRecharge:unregMsgs(  )
end

function CountryRecharge:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function CountryRecharge:onPause(  )
	self:unregMsgs()
end

function CountryRecharge:setupViews(  )
	self.pImgRank = self:findViewByName("img_rank")
	self.pImgFlag = self:findViewByName("img_flag")
	self.pTxtRecharge = self:findViewByName("txt_recharge")
	setTextCCColor(self.pTxtRecharge, _cc.yellow)

	--排名名字
	local sImgRank = nil
	if self.nIndex == 1 then
		sImgRank = "#v1_img_paixingbang1.png"
	elseif self.nIndex == 2 then
		sImgRank = "#v1_img_paixingbang2.png"
	elseif self.nIndex == 3 then
		sImgRank = "#v1_img_paixingbang3.png"
	end
	if sImgRank then
		self.pImgRank:setCurrentImage(sImgRank)
	end
end

function CountryRecharge:updateViews(  )
	if not self.tPeopleRecBackCountryVo then
		return
	end
	--国家旗
	WorldFunc.setImgCountryFlag(self.pImgFlag, self.tPeopleRecBackCountryVo.nId)
	--文本
	local sStr = string.format(getConvertedStr(3, 10374), getCostResName(e_type_resdata.money), getResourcesStr(self.tPeopleRecBackCountryVo.nGold))
	self.pTxtRecharge:setString(sStr)
end

--tPeopleRecBackCountryVo: PeopleRecBackCountryVo
function CountryRecharge:setData( tPeopleRecBackCountryVo )
	self.tPeopleRecBackCountryVo = tPeopleRecBackCountryVo
	self:updateViews()
end

return CountryRecharge


