-- CountryTnolyProgress.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-04-18 14:25:23 星期三
-- Description: 国家科技进度信息层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local CountryTnolyProgress = class("CountryTnolyProgress", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function CountryTnolyProgress:ctor()
	-- body	
	self:myInit()	
	parseView("lay_progress", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function CountryTnolyProgress:myInit()
	-- body		
	self.tCurData 			= 	nil 				--当前数据	
	self.tImgStars  		= {}
end

--解析布局回调事件
function CountryTnolyProgress:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("CountryTnolyProgress",handler(self, self.onCountryTnolyProgressDestroy))
end

--初始化控件
function CountryTnolyProgress:setupViews()
	-- body
	self.pLayMain = self:findViewByName("default")

	--等级
	local pLbTx = self:findViewByName("lb_lv_tx")
	pLbTx:setString(getConvertedStr(7, 10452))
	setTextCCColor(pLbTx, _cc.white)
	self.pLbLv = self:findViewByName("lb_lv")
	setTextCCColor(self.pLbLv, _cc.white)
	--进度层
	self.pLayBar = self:findViewByName("lay_bar")
	self.pBar = MCommonProgressBar.new({bar = "v2_blue_xin.png", barWidth = 252, barHeight = 20})
	self.pLayBar:addView(self.pBar)
	centerInView(self.pLayBar, self.pBar)
	self.pBar:setPercent(100)
	--进度条文本
	self.pLbProgress = self:findViewByName("lb_progress")

	--指示箭头
	self.pImgZhishi = self:findViewByName("img_zhishi")
end

-- 修改控件内容或者是刷新控件数据
function CountryTnolyProgress:updateViews()
	if self.tCurData == nil then
		return
	end
	--点亮图标层
	local nMaxLvSection = self.tCurData:getMaxSection()
	for i = 1, nMaxLvSection do
		if not self.tImgStars[i] then
			self.tImgStars[i] = MUI.MImage.new("#v2_img_qxsld2.png")
			self.tImgStars[i]:setScale(0.9)
			self.pLayMain:addView(self.tImgStars[i])
			self.tImgStars[i]:setAnchorPoint(cc.p(0, 0.5))
			self.tImgStars[i]:setPosition(80+(i-1)*35, 65)
		end
		if i > self.tCurData.nSection then
			self.tImgStars[i]:setCurrentImage("#v2_img_qxsld2.png")
		else
			self.tImgStars[i]:setCurrentImage("#v2_img_qxsld.png")
		end
	end
	
	--等级
	self.pLbLv:setString(self.tCurData.nLevel)

	--进度
	if self.tCurData:getIsMaxLv() then
		self.pLbProgress:setString(getConvertedStr(7, 10349))
		setTextCCColor(self.pLbProgress, _cc.white)
		self.pBar:setPercent(100)
		if self.pImgHalfStar then
			self.pImgHalfStar:setVisible(false)
		end
		self.pImgZhishi:setVisible(false)
	else
		local nTotalExp = self.tCurData:getNextLvNeedExp()
		local str = {
			{text = self.tCurData.nExp, color = _cc.yellow},
			{text = "/"..nTotalExp, color = _cc.white}
		}
		self.pLbProgress:setString(str)
		local fPercent = (self.tCurData.nExp/nTotalExp)*100
		self.pBar:setPercent(fPercent)
		--当前正在升级该小段显示半亮图标
		-- if fPercent > 0 then
			if not self.pImgHalfStar then
				self.pImgHalfStar = MUI.MImage.new("#v2_img_qxsldv.png")
				self.pLayMain:addView(self.pImgHalfStar, 10)
				self.pImgHalfStar:setAnchorPoint(cc.p(0, 0.5))
			end
			self.pImgHalfStar:setPosition(self.tImgStars[self.tCurData.nSection+1]:getPosition())
			self.pImgHalfStar:setVisible(true)
		-- else
		-- 	if self.pImgHalfStar then
		-- 		self.pImgHalfStar:setVisible(false)
		-- 	end
		-- end
		self.pImgZhishi:setPositionX(self.tImgStars[self.tCurData.nSection+1]:getPositionX()+
			self.tImgStars[self.tCurData.nSection+1]:getWidth()/2 - 2)
		self.pImgZhishi:setVisible(true)
	end
end

-- 析构方法
function CountryTnolyProgress:onCountryTnolyProgressDestroy()
	-- body
end

function CountryTnolyProgress:updateData(_data)
	self.tCurData = _data
	self:updateViews()
end



return CountryTnolyProgress
