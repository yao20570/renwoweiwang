----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:01:30
-- Description: 城战国战 战役列表
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemCCWarMailBattle = require("app.layer.mail.ItemCCWarMailBattle")

local CCWarMailBattle = class("CCWarMailBattle", function( pSize )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setContentSize(pSize)
	return pView
end)

--tMailMsg 邮件数据
function CCWarMailBattle:ctor( pSize, tMailMsg )
	self.pSize = pSize
	self.tMailMsg = tMailMsg

	self:setupViews()
end

-- 析构方法
function CCWarMailBattle:onCCWarMailBattleDestroy(  )
    self:onPause()
end

function CCWarMailBattle:regMsgs(  )
end

function CCWarMailBattle:unregMsgs(  )
end

function CCWarMailBattle:onResume(  )
	self:regMsgs()
end

function CCWarMailBattle:onPause(  )
	self:unregMsgs()
end

function CCWarMailBattle:setupViews(  )
	local pSize = self.pSize
	
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
	    	pTempView   = ItemCCWarMailBattle.new()
		end
		pTempView:setData(self.tMailMsg, _index+1)			--第一个放到添加的界面特殊处理了
	    return pTempView
	end)

	--数量
	local nAtkHeroCount = 0
	if self.tMailMsg.tAtkHeros then
		nAtkHeroCount = #self.tMailMsg.tAtkHeros-1			--减掉第一个
	end
	local nDefHeroCount = 0
	if self.tMailMsg.tDefHeros then
		nDefHeroCount = #self.tMailMsg.tDefHeros-1
	end
	local nCount = math.max(nAtkHeroCount, nDefHeroCount) + 1
	if nCount<=0 then
		nCount=1
	end
	self.pListView:setItemCount(nCount)
	-- 载入所有展示的item
	self.pListView:reload()
end

function CCWarMailBattle:updateViews(  )
end

return CCWarMailBattle


