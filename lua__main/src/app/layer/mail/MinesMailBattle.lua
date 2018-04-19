----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:01:30
-- Description: 邮件矿点占领 战役列表
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemMinesMailBattle = require("app.layer.mail.ItemMinesMailBattle")

local MinesMailBattle = class("MinesMailBattle", function( pSize )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setContentSize(pSize)
	return pView
end)

--tFightDetail
function MinesMailBattle:ctor( pSize, tFightDetail )
	self.tFightDetail = tFightDetail

	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 10),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		itemMargin = {left =  0,
             right =  0,
             top =  0,
             bottom =  10},
    }
    self:addView(self.pListView)

	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pTempView = _pView
	    if pTempView == nil then
	    	pTempView   = ItemMinesMailBattle.new()
		end
		pTempView:setData(self.tFightDetail, _index)
	    return pTempView
	end)

	--数量
	local nAtkHero = 0
	if self.tFightDetail.tAtkHeros then
		nAtkHero = #self.tFightDetail.tAtkHeros
	end
	local nDefHero = 0
	if self.tFightDetail.tDefHeros then
		nDefHero = #self.tFightDetail.tDefHeros
	end
	local nCount = math.max(nAtkHero, nDefHero) + 1
	self.pListView:setItemCount(nCount)
	-- 载入所有展示的item
	self.pListView:reload()
end

-- 析构方法
function MinesMailBattle:onMinesMailBattleDestroy(  )
    self:onPause()
end

function MinesMailBattle:regMsgs(  )
end

function MinesMailBattle:unregMsgs(  )
end

function MinesMailBattle:onResume(  )
	self:regMsgs()
end

function MinesMailBattle:onPause(  )
	self:unregMsgs()
end

function MinesMailBattle:setupViews(  )
end

function MinesMailBattle:updateViews(  )
end

return MinesMailBattle


