-- LayRecommendTnoly.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-03-08 15:09:18 星期四
-- Description: 科技院列表底部科技推荐层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemTechnology = require("app.layer.technology.ItemTechnology")

local LayRecommendTnoly = class("LayRecommendTnoly", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
--_data：当前科技数据
function LayRecommendTnoly:ctor( _data )
	-- body
	self:myInit()
	self.tCurData = _data
	parseView("lay_recommend", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function LayRecommendTnoly:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
end

--解析布局回调事件
function LayRecommendTnoly:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("LayRecommendTnoly",handler(self, self.onLayRecommendTnolyDestroy))
end

--初始化控件
function LayRecommendTnoly:setupViews( )
	-- body
	--背景图片
	local pImgBg 		= self:findViewByName("img_bg")
	pImgBg:setFlippedY(true)
	local pImgL 		= self:findViewByName("img_l")
	pImgL:setFlippedX(true)
	--科技信息层
	self.pLayTnoly 		= self:findViewByName("lay_tnoly_info")
end


-- 修改控件内容或者是刷新控件数据
function LayRecommendTnoly:updateViews(  )
	-- body
	if self.tCurData then
		if not self.pItemTnoly then
			self.pItemTnoly = ItemTechnology.new(1)
			self.pLayTnoly:addView(self.pItemTnoly, 10)
		end
		self.pItemTnoly:setCurData(self.tCurData)
		self.pItemTnoly:setRecommendData()
	end
end


-- 析构方法
function LayRecommendTnoly:onLayRecommendTnolyDestroy(  )
	-- body
end

--设置当前数据
function LayRecommendTnoly:setRecommendData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end


return LayRecommendTnoly