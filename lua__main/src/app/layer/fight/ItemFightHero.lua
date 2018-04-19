-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-19 13:57:56 星期五
-- Description: 战斗 武将头像
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconHero = require("app.common.iconview.IconHero")

local ItemFightHero = class("ItemFightHero", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemFightHero:ctor(  )
	-- body
	self:myInit()
	parseView("item_fight_hero", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemFightHero:myInit(  )
	-- body
	self.tCurData 		= 		nil 		--当前数据
end

--解析布局回调事件
function ItemFightHero:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemFightHero",handler(self, self.onItemFightHeroDestroy))
end

--初始化控件
function ItemFightHero:setupViews( )
	-- body
	--icon
	self.pLayIcon 			= 		self:findViewByName("lay_icon")
	--名字
	self.pLbName 			= 		self:findViewByName("lb_name")
	
	--icon初始化
	self.pIconHero = IconHero.new(TypeIconHero.NORMAL)
	self.pLayIcon:addView(self.pIconHero)
end

-- 修改控件内容或者是刷新控件数据
function ItemFightHero:updateViews(  )
	-- body
	if self.tCurData then
		--设置名字
		self.pLbName:setString(self.tCurData.sName)
		setLbTextColorByQuality(self.pLbName,self.tCurData.nQuality)
		--设置icon
		self.pIconHero:setCurData(self.tCurData)
		self.pIconHero:setHeroType()
	end
end

-- 析构方法
function ItemFightHero:onItemFightHeroDestroy(  )
	-- body
end

--设置名字是否展示
function ItemFightHero:setNameVisible( _bEnbaled )
	-- body
	self.pLbName:setVisible(_bEnbaled)
end

--设置当前数据
function ItemFightHero:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end

--获得武将数据
function ItemFightHero:getCurData(  )
	-- body
	return self.tCurData
end

return ItemFightHero
