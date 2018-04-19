-- Author: liangzhaowei
-- Date: 2017-05-02 14:27:56
-- 英雄经验升级item

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroWipeExp = class("ItemHeroWipeExp", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local ADDTIME = 2/0.01 --目前是两秒

--_index 下标 _type 类型
function ItemHeroWipeExp:ctor()
	-- body
	self:myInit()

	parseView("item_fuben_result_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemHeroWipeExp",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroWipeExp:myInit()
	self.tClickHandler = nil
end

--解析布局回调事件
function ItemHeroWipeExp:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemHeroWipeExp:setupViews( )
	--ly         	
	self.pLyIcon = self:findViewByName("ly_hero")
	self.pLyBar = self:findViewByName("ly_bar")


	self.pBarLv = 	nil
	self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_blue_1.png",barWidth = 106, barHeight = 14})
	self.pLyBar:addView(self.pBarLv,100)
	centerInView(self.pLyBar,self.pBarLv)


	self.pLbN = self:findViewByName("lb_name")
	-- self.pLbN:setPositionX(self.pLbN:getPositionX() - 4)

	setTextCCColor(self.pLbN, _cc.blue)
	self.pLbLv = self:findViewByName("lb_lv")
	-- self.pLbLv:setPositionX(self.pLbLv:getPositionX() + 10)


	self.pLayBottomBg = self:findViewByName("lay_bottom_bg")

	self.pLbN:setVisible(false)
	self.pLbLv:setVisible(false)
	self.pLayBottomBg:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function ItemHeroWipeExp:updateViews(  )

	if not self.pData then
		return
	end

	--加号类型
	if self.pData == TypeIconHero.ADD then
		self.pIcon = getIconHeroByType(self.pLyIcon,TypeIconHero.ADD,nil,TypeIconHeroSize.L)
		self.pLbN:setVisible(false)
		self.pLbLv:setVisible(false)
		self.pLyBar:setVisible(false)

	elseif self.pData == TypeIconHero.LOCK then
		self.pIcon = getIconHeroByType(self.pLyIcon,TypeIconHero.LOCK,nil,TypeIconHeroSize.L)
		self.pLbN:setVisible(false)
		self.pLbLv:setVisible(false)
		self.pLyBar:setVisible(false)

	else
		self.pIcon = getIconHeroByType(self.pLyIcon, TypeIconHero.NORMAL, self.pData, TypeIconHeroSize.L)
		self.pIcon:setHeroType()
		--lb
		self.pLbN:setVisible(true)
		self.pLbLv:setVisible(true)
		self.pLyBar:setVisible(true)
		self.pLbN:setString(self.pData.sName or "")
		self.pLbLv:setString("Lv."..self.pData.nLv)
		setTextCCColor(self.pLbN,getColorByQuality(self.pData.nQuality)) --取英雄品质显示名字
		self:updateBar(self.pData)
	end
	-- if not self.pIcon._nHandlerClicked then
	self.pIcon:setIconClickedCallBack(handler(self, self.onIconClicked))
	-- end
end

--析构方法
function ItemHeroWipeExp:onDestroy(  )
	self:stopAllActions()
	self.bHasPlayUp = false
	-- body
end

--设置数据 _data
function ItemHeroWipeExp:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:updateViews()
end

function ItemHeroWipeExp:setIconClickedCallBack(_handler)
	self.tClickHandler = _handler
end

function ItemHeroWipeExp:onIconClicked()
	if self.pData == TypeIconHero.ADD then
		if self.tClickHandler then
			self.tClickHandler()
		end
	end
end

--设置icon类型 _nType 英雄类型
function ItemHeroWipeExp:setIConType(_nType)
	if _nType then
		local pIcon =  getIconHeroByType(self.pLyIcon, _nType, nil, TypeIconHeroSize.L)
			if _nType == TypeIconHero.ADD then
				--如果没有可上阵武将.将加号变灰
				if not Player:getHeroInfo():bHaveHeroUp() then 
					pIcon:stopAddImgAction()
				end
			end
		pIcon:setIconClickedCallBack(function ()
			--应策划要求不做跳转
		end)
	end
end

--刷新进度条
function ItemHeroWipeExp:updateBar(_tData)
	if not _tData then
		return
	end
	local denominator = _tData:getLvExpByLv( _tData.nLv )
	local nPer = 0
	if denominator > 0 then
		nPer = math.floor(_tData.nE/denominator*100)
	end
	self.pBarLv:setPercent(nPer) --当前经验比例

end


return ItemHeroWipeExp