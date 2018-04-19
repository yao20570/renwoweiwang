-----------------------------------------------------
-- author: wangxs
-- updatetime:  建筑等级相关
-- Description: 
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local BuildLv = class("BuildLv", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function BuildLv:ctor(  )
	-- body
	self:myInit()
	parseView("build_lv", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function BuildLv:myInit(  )
	-- body
end

--解析布局回调事件
function BuildLv:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("BuildLv",handler(self, self.onBuildLvDestroy))
end

--初始化控件
function BuildLv:setupViews( )
	-- body
	--升级提示
	self.pImgUp 			= 		self:findViewByName("img_up")
	--默认隐藏
	self:setUpImgVisible(false)
	--等级层
	self.pLayLevel 			= 		self:findViewByName("lay_lv_bg")
	--等级
	self.pLabelAtlas1 = MUI.MLabelAtlas.new({text="0", 
		png="ui/atlas/v1_fonts_djsz.png", pngw=9, pngh=16, scm=48})
	self.pLabelAtlas2 = MUI.MLabelAtlas.new({text="0", 
		png="ui/atlas/v1_fonts_djsz.png", pngw=9, pngh=16, scm=48})
	self.pLayLevel:addView(self.pLabelAtlas1)
	self.pLayLevel:addView(self.pLabelAtlas2)
end

-- 修改控件内容或者是刷新控件数据
function BuildLv:updateViews(  )
	-- body
end

-- 析构方法
function BuildLv:onBuildLvDestroy(  )
	-- body
end

--设置是否展示
function BuildLv:setUpImgVisible( bState)
	-- body
	self.pImgUp:setVisible(bState)
end

--设置等级层是否展示
function BuildLv:setLayLvVisible( bState)
	-- body
	self.pLayLevel:setVisible(bState)
end

--设置等级
function BuildLv:setLvValue( _nLv )
	-- body
	if not _nLv then return end
	if _nLv >= 10 then
		self.pLabelAtlas2:setVisible(true)
		local nN = math.floor(_nLv / 10)
		local nM = _nLv % 10
		self.pLabelAtlas1:setString(nN)
		self.pLabelAtlas1:setPosition(29, 17)
		self.pLabelAtlas2:setString(nM)
		self.pLabelAtlas2:setPosition(37, 19)
	else
		self.pLabelAtlas1:setString(_nLv)
		self.pLabelAtlas1:setPosition(33, 18)
		self.pLabelAtlas2:setVisible(false)
	end
end

return BuildLv