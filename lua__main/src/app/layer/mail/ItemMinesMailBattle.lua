----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:05:46
-- Description: 矿点占领 战斗玩家列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemMailBattler = require("app.layer.mail.ItemMailBattler")
local ItemMinesMailBattle = class("ItemMinesMailBattle", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMinesMailBattle:ctor(  )
	--解析文件
	parseView("item_mines_mail_battle", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemMinesMailBattle:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemMinesMailBattle",handler(self, self.onItemMinesMailBattleDestroy))
end

-- 析构方法
function ItemMinesMailBattle:onItemMinesMailBattleDestroy(  )
    self:onPause()
end

function ItemMinesMailBattle:regMsgs(  )
end

function ItemMinesMailBattle:unregMsgs(  )
end

function ItemMinesMailBattle:onResume(  )
	self:regMsgs()
end

function ItemMinesMailBattle:onPause(  )
	self:unregMsgs()
end

function ItemMinesMailBattle:setupViews(  )
	self.pLayAtk = self:findViewByName("lay_atk")
	self.pLayDef = self:findViewByName("lay_def")
	local pItemMailBattler = ItemMailBattler.new()
	self.pLayAtk:addView(pItemMailBattler)
	self.pItemMailBattlerLeft = pItemMailBattler

	local pItemMailBattler = ItemMailBattler.new()
	self.pLayDef:addView(pItemMailBattler)
	self.pItemMailBattlerRight = pItemMailBattler
end

function ItemMinesMailBattle:updateViews(  )
end

--tFightDetail
function ItemMinesMailBattle:setData( tFightDetail, nIndex )
	if nIndex == 1 then
		self.pItemMailBattlerLeft:setAtkFightDetail(tFightDetail)
		self.pLayAtk:setVisible(true)
		self.pItemMailBattlerRight:setDefFightDetail(tFightDetail)
		self.pLayDef:setVisible(true)
	else
		local tFightHero = tFightDetail.tAtkHeros[nIndex - 1]
		if tFightHero then
			self.pLayAtk:setVisible(true)
			self.pItemMailBattlerLeft:setHeroData(tFightHero, tFightDetail.nAtkCountry)
		else
			self.pLayAtk:setVisible(false)
		end
		local tFightHero = tFightDetail.tDefHeros[nIndex - 1]
		if tFightHero then
			self.pLayDef:setVisible(true)
			self.pItemMailBattlerRight:setHeroData(tFightHero, tFightDetail.nDefCountry)
		else
			self.pLayDef:setVisible(false)
		end
	end
	self:updateViews()
end

return ItemMinesMailBattle


