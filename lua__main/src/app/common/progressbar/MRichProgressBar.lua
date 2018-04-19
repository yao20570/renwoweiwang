-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-02-06 10:52:10 星期二
-- Description: 复合进度条
-----------------------------------------------------

--[[
进度条参数说明
_param = {
 	name：		（string）进度条名字 例如："barName"
	barL：		（string）进度条图片名字 例如："v1_bar_a.png" （必传）
	barR：		（string）进度条图片名字 例如："v1_bar_a.png" （选传）
	bg：		（string）背景图片名字 例如："v1_bar_b.png"   
    barWidth：	（int）   进度条宽度 例如：209 				  （必传）
    barHeight：	（int）   进度条高度 例如：16    			  （必传）
    dir：	 			  进度条方向 MUI.MLoadingBar.DIRECTION_LEFT_TO_RIGHT， MLoadingBar.DIRECTION_RIGHT_TO_LEFT
	stroke 		 (int)    是否需要描边    0 or nil ：不需要     1：需要描边
}
]]
local MCommonView = require("app.common.MCommonView")
local MRichProgressBar = class("MRichProgressBar", function( _param)
	-- body
	--参数校验
	if not _param or not _param.barL or not _param.barWidth or not _param.barHeight then
		print("error===>进度条参数有问题")
		return
	end
	local pProgressBar = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pProgressBar:setContentSize(cc.size(_param.barWidth, _param.barHeight))
	if _param.bg then
		local pImg = MUI.MImage.new("ui/bar/" .. _param.bg)
		pProgressBar:setBackgroundImage("ui/bar/" .. _param.bg, {scale9 = true,capInsets=cc.rect(pImg:getWidth()/2,pImg:getHeight()/2, 1, 1)})
	end	
	return pProgressBar 
end)

--_param：（table）进度条参数
function MRichProgressBar:ctor( _param )
	-- body
	self:myInit()
	self.tParams = _param
	self:setupViews()
	self:updateViews()
	self:setDestroyCallback(handler(self, self.onMCommonProgressBarDestroy))
end

--初始化成员变量
function MRichProgressBar:myInit(  )
	-- body
	self.tParams 			= 		nil 			--进度条参数
	self.pLbText 			= 		nil 			--进度条上的文字显示
	self.bIsStroke 			= 		false 			--是否需要描边
end

--初始化控件
function MRichProgressBar:setupViews( )
	-- body
	self.bIsStroke = self.tParams.stroke == 1 or false

	-- 创建进度条	
	self.pBarLeft = MUI.MLoadingBar.new({
	    image = "ui/bar/" .. self.tParams.barL,
	    direction = MUI.MLoadingBar.DIRECTION_LEFT_TO_RIGHT,
	    viewRect = cc.rect(0, 0, self.tParams.barWidth, self.tParams.barHeight)})
	self:addView(self.pBarLeft, 2)
	centerInView(self, self.pBarLeft)
	if self.tParams and self.tParams.barR then
		self.pBarRight = MUI.MLoadingBar.new({
		    image = "ui/bar/" .. self.tParams.barR,
		    direction = MUI.MLoadingBar.DIRECTION_RIGHT_TO_LEFT,
		    viewRect = cc.rect(0, 0, self.tParams.barWidth, self.tParams.barHeight)})	
		self:addView(self.pBarRight, 1)	
		centerInView(self, self.pBarRight)
	end
end

-- 修改控件内容或者是刷新控件数据
function MRichProgressBar:updateViews(  )
	-- body
end

-- 析构方法
function MRichProgressBar:onMCommonProgressBarDestroy(  )
	-- body
end

--设置进度条上的文字
--_sText：文字内容
function MRichProgressBar:setProgressBarText( _sText )
	-- body
	if not _sText then
		print("error=====> _sText is nil")
		return
	end
	--初始化label
	if not self.pLbText then
		self:initLabel()
	end
	self.pLbText:setString(_sText)
end

--初始化进度条上的lable
function MRichProgressBar:initLabel(  )
	-- body
	if not self.tParams then
		print("error=====> self.tParams is nil")
		return
	end
	--计算字体大小（根据进度条的高度）
	local nFontSize = self:getProgressBarFontSzie()
	self.pLbText = MUI.MLabel.new({text = "",size = nFontSize})
	self:addChild(self.pLbText, 3)
	centerInView(self, self.pLbText)
	--设置label的各种属性
	self:setLabelAttrs()
end

--获得字体大小
--具体判断以后需要不断补充
function MRichProgressBar:getProgressBarFontSzie(  )
	-- body
	local nFontSize = 20
	if self.tParams.barHeight < 15 then
		nFontSize = 20
	elseif self.tParams.barHeight >= 15 then
		nFontSize = 22
	end
	--战斗血条特殊处理
	if self.tParams.name == "fight_bar_blood" then
		nFontSize = 15
	end
	return nFontSize
end

--设置字体颜色和描边等属性
function MRichProgressBar:setLabelAttrs(  )
	-- body
	--解析进度条名字，获取各种信息
	local tMsgs = luaSplitMuilt(self.tParams.bar,".","_")
	if tMsgs and tMsgs[1] and table.nums(tMsgs[1]) >= 3 then
		local sKey = tMsgs[1][3]
		if sKey and tProgressBarAttrs[sKey] then
			local tAttrs = tProgressBarAttrs[sKey]
			self.pLbText:setTextColor(getC3B(tAttrs.fontColor))
			if self.bIsStroke and tAttrs.fontStrokeSize >= 1 then --需要描边
				self.pLbText:enableOutline(getC4B(tAttrs.fontStrokeColor), tAttrs.fontStrokeSize)
			end
		else
			-- print("没有该类型的属性文件")
		end
	end
end

--获得进度条上的文字控件
function MRichProgressBar:getProgressBarLabel(  )
	-- body
	return self.pLbText
end

function MRichProgressBar:setPercent( nPercLeft,  nPercRight)
	-- body
	if nPercLeft then
		self.pBarLeft:setPercent(nPercLeft)
	end
	if nPercRight then
		self.pBarRight:setPercent(nPercRight)
	end	
end

return MRichProgressBar