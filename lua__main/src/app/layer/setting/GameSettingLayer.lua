-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-25 10:28:40 星期四
-- Description: 游戏设置层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local GameSettingLayer = class("GameSettingLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function GameSettingLayer:ctor( _param )
	-- body
	self:myInit(_param)
	parseView("layer_game_setting", handler(self, self.onParseViewCallback))	
end

--初始化成员变量
function GameSettingLayer:myInit( _param )
	-- body
	self.tItemSize = {width = 600, height = 70}

	self.tItemGroup = {}
end

--解析布局回调事件
function GameSettingLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("GameSettingLayer",handler(self, self.onGameSettingLayerDestroy))
end

--初始化控件
function GameSettingLayer:setupViews( )
	-- body
	self.pLbRoot = self:findViewByName("root")
	--title
	self.pLayTitle = self:findViewByName("lay_title")
	self.pLbTitle = self:findViewByName("lb_title")	--标题
	--lay_content
	self.pLayContent = self:findViewByName("lay_content")
end

-- 修改控件内容或者是刷新控件数据
function GameSettingLayer:updateViews( )
	-- body
	if self.tItemGroup and #self.tItemGroup > 0 then
		for k, v in pairs(self.tItemGroup) do
			v:updateSetting()
		end
	end
end

-- 析构方法
function GameSettingLayer:onGameSettingLayerDestroy(  )
	-- body
end

--设置标题
function GameSettingLayer:setTitle(_sStr)
	-- body
    if not _sStr then
    	return
    end
    self.pLbTitle:setString(_sStr)
end

--添加设置项
function GameSettingLayer:addSettingItem(_pview)
	-- body
	if not _pview then
		return
	end
	--添加到内容层
	self.pLayContent:addView(_pview)
	table.insert(self.tItemGroup, _pview)
	--重新布局
	local nitemcnt = table.nums(self.tItemGroup)

	local nwidth = self.pLayTitle:getWidth()	
	local nheight = self.pLayTitle:getHeight()
	if nitemcnt > 0 then
		nheight = nheight + self.tItemSize.height*nitemcnt		
		self.pLayContent:setLayoutSize(nwidth,self.tItemSize.height*nitemcnt)
		self.pLayContent:setPosition(0, 0)		
		self.pLayTitle:setPosition(0, self.pLayContent:getHeight())
		self:setLayoutSize(nwidth, nheight)	
		self.pLbRoot:setLayoutSize(nwidth, nheight)	
		local ncurheight = nheight - self.pLayTitle:getHeight()
		for i, v in pairs(self.tItemGroup) do 
			if v then 	
				ncurheight = ncurheight - self.tItemSize.height
				v:setPosition(0, ncurheight)
			end
			if i == nitemcnt then
				v:showUnderLine(false)
			else
				v:showUnderLine(true)
			end
		end
	end	
end
return GameSettingLayer