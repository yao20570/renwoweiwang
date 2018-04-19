-- Author: liangzhaowei
-- Date: 2017-05-16 14:07:42
-- 守城npc武将信息
local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemWallNpcState = require("app.layer.wall.ItemWallNpcState")
local ItemWallNpcInfo = class("ItemWallNpcInfo", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWallNpcInfo:ctor()
	-- body
	self:myInit()


	parseView("item_wall_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemWallNpcInfo",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemWallNpcInfo:myInit()
	self.tCurData  			= 	nil 						-- 当前数据
	self.pItemNpcState      =   nil                         -- npc状态
	self.nType              =   1                           -- 类型

end

--解析布局回调事件
function ItemWallNpcInfo:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly         	
	self.pLyIcon = self:findViewByName("ly_hero")
	self.pLyBar = self:findViewByName("ly_bar")
	self.pLyBar:setVisible(true)


	self.pBarLv = 	nil
	self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_blue_1.png",barWidth = 106, barHeight = 14})
	self.pLyBar:addView(self.pBarLv,100)
	centerInView(self.pLyBar,self.pBarLv)


	self.pLbLv = self:findViewByName("lb_lv")
	setTextCCColor(self.pLbLv, _cc.blue)

	--img
	self.pSelImg = self:findViewByName("img_sel")
	self.pSelImg:setVisible(false)
	-- self.pLbLv:setVisible(false)


	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemWallNpcInfo:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemWallNpcInfo:updateViews(  )
	self:stopAllActions()
end

--析构方法
function ItemWallNpcInfo:onDestroy(  )
	-- body
end




--设置数据 _data 
function ItemWallNpcInfo:setCurData(_tData)
	if not _tData then
		return
	end

	if not _nType then
		self.nType = 1
	else
		self.nType = _nType
	end

	-- dump(self.pData,"_tData",2)

	self.pData = _tData or {}

	if type(self.pData) == "table" then
		self.pLyBar:setVisible(true)
		if self.pData then
			if not self.pIcon then
				self.pIcon = getIconHeroByType(self.pLyIcon, TypeIconHero.NORMAL, self.pData, TypeIconHeroSize.L)
				-- self.pIcon:setIconClickedCallBack(handler(self, self.onViewClick))
			else
				self.pIcon:setIconHeroType(TypeIconHero.NORMAL)
				self.pIcon:setCurData(self.pData)
			end

			if not self.pItemNpcState then
				self.pItemNpcState = ItemWallNpcState.new()
				self.pIcon:addView(self.pItemNpcState,10)
			end
			self.pItemNpcState:setCurData(self.pData)

			self.pBarLv:setPercent(self.pData.nTp/self.pData.nTroops *100)

			self.pLbLv:setString(self.pData.sName.."Lv."..self.pData.nLevel)
		end
	end
	
end

--点击回调
function ItemWallNpcInfo:onViewClick(pView)

end

--获取icon
function ItemWallNpcInfo:getIcon()
	if self.pIcon then
		return self.pIcon
	end
end

return ItemWallNpcInfo