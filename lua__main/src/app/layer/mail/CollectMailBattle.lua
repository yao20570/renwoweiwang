----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:00:24
-- Description: 邮件采集 战役列表
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemCollectMailBattle = require("app.layer.mail.ItemCollectMailBattle")

local CollectMailBattle = class("CollectMailBattle", function( pSize )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setContentSize(pSize)
	return pView
end)

--tMailMsg 邮件数据
function CollectMailBattle:ctor( pSize, tMailMsg )
	self.tMailMsg = tMailMsg
	self.pSize = pSize
	self:setupViews()
	self:onResume()
end

-- 析构方法
function CollectMailBattle:onCollectMailBattleDestroy(  )
    self:onPause()
end

function CollectMailBattle:regMsgs(  )
end

function CollectMailBattle:unregMsgs(  )
end

function CollectMailBattle:onResume(  )
	self:regMsgs()
end

function CollectMailBattle:onPause(  )
	self:unregMsgs()
end

function CollectMailBattle:setupViews(  )
	self.pListView = MUI.MListView.new {
		viewRect   = cc.rect(0, 0, self.pSize.width, self.pSize.height - 10),
		direction  = MUI.MScrollView.DIRECTION_VERTICAL,
		itemMargin = {left =  0,
             right =  0,
             top =  0,
             bottom =  10},
    }
    self:addView(self.pListView)
	self.pListView:setItemCallback(function ( _index, _pView ) 
		local pItemData = self.tMailMsg.tFightDetails[_index]
	    local pTempView = _pView
	    if pTempView == nil then
	    	pTempView   = ItemCollectMailBattle.new()
		end
		pTempView:setData(pItemData)
	    return pTempView
	end)
	--数量
	self.pListView:setItemCount(#self.tMailMsg.tFightDetails)
	-- 载入所有展示的item
	self.pListView:reload()
end

function CollectMailBattle:updateViews(  )
end

return CollectMailBattle


