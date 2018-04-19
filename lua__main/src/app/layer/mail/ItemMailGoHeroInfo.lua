----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-23 14:48:37
-- Description: 武将出征 武将列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemMailGoHeroInfo = class("ItemMailGoHeroInfo", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMailGoHeroInfo:ctor(  )
	--解析文件
	parseView("item_mail_go_hero_info", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemMailGoHeroInfo:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemMailGoHeroInfo", handler(self, self.onItemMailGoHeroInfoDestroy))
end

-- 析构方法
function ItemMailGoHeroInfo:onItemMailGoHeroInfoDestroy(  )
    self:onPause()
end

function ItemMailGoHeroInfo:regMsgs(  )
end

function ItemMailGoHeroInfo:unregMsgs(  )
end

function ItemMailGoHeroInfo:onResume(  )
	self:regMsgs()
end

function ItemMailGoHeroInfo:onPause(  )
	self:unregMsgs()
end

function ItemMailGoHeroInfo:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.blue)
	local pTroopsTitle = self:findViewByName("txt_troops_title")
	pTroopsTitle:setString(getConvertedStr(3, 10124))
	self.pTxtTroops = self:findViewByName("txt_troops")
	setTextCCColor(self.pTxtTroops, _cc.blue)
end

function ItemMailGoHeroInfo:updateViews(  )
	if not self.tGoHero then
		return
	end

	local tHeroData = getHeroDataById(self.tGoHero.tHs.t)
	--设置武将图标
	if tHeroData then
		getIconHeroByType(self.pLayIcon, TypeIconHero.NORMAL, tHeroData, TypeIconHeroSize.L)

		self.pTxtName:setString(string.format("%s %s", tHeroData.sName, getLvString(self.tGoHero.nHeroLv)))
	end

	self.pTxtTroops:setString(self.tGoHero.nTroops)
end

--tGoHero
function ItemMailGoHeroInfo:setData( tGoHero )
	self.tGoHero = tGoHero
	self:updateViews()
end

return ItemMailGoHeroInfo


