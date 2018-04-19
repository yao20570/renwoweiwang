----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-01-23 17:05:46
-- Description: 竞技场战斗双方
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemArenaBattler = require("app.layer.arena.ItemArenaBattler")
local ItemArenaBattlers = class("ItemArenaBattlers", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemArenaBattlers:ctor(  )
	--解析文件
	parseView("item_mines_mail_battle", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemArenaBattlers:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemArenaBattlers",handler(self, self.onItemCCWarMailBattleDestroy))
end

-- 析构方法
function ItemArenaBattlers:onItemCCWarMailBattleDestroy(  )
    self:onPause()
end

function ItemArenaBattlers:regMsgs(  )
end

function ItemArenaBattlers:unregMsgs(  )
end

function ItemArenaBattlers:onResume(  )
	self:regMsgs()
end

function ItemArenaBattlers:onPause(  )
	self:unregMsgs()
end

function ItemArenaBattlers:setupViews(  )
	self.pLayAtk = self:findViewByName("lay_atk")
	self.pLayDef = self:findViewByName("lay_def")
	self.pLayBg	 = self:findViewByName("lay_bg")
	self.pLayReplayerBtn=self:findViewByName("lay_replay_btn")
	self.pLayLine=self:findViewByName("lay_line")

	self.pLayReplayerBtn:setViewTouched(true)
	self.pLayReplayerBtn:setIsPressedNeedScale(false)
	self.pLayReplayerBtn:onMViewClicked(handler(self, self.onReplayClicked))

	self.pLayBg:setVisible(false)
	local pItemMailBattler = ItemArenaBattler.new(1)
	self.pLayAtk:addView(pItemMailBattler, 10)
	self.pItemBattlerLeft = pItemMailBattler

	local pItemMailBattler = ItemArenaBattler.new(2)
	self.pLayDef:addView(pItemMailBattler, 10)
	self.pItemBattlerRight = pItemMailBattler
end

function ItemArenaBattlers:updateViews(  )

end

--tFightDetail
function ItemArenaBattlers:setData( tFightDetail, nIndex, bIconTouch )
	
	local nType = 1
	if nIndex > 1 then
		nType = 2
	end
	self.pItemBattlerLeft:setCurData(tFightDetail, nIndex, nType, bIconTouch)	
	self.pItemBattlerRight:setCurData(tFightDetail, nIndex, nType, bIconTouch)
	
	self:resetItemBg(nIndex)
	self:updateViews()
end

--重新设置背景样式 因为第一个是特殊的 
function ItemArenaBattlers:resetItemBg( _nIndex)
	-- body
	if _nIndex==1 then 
		self.pLayBg:setVisible(true)
		self.pLayReplayerBtn:setVisible(true)
		self.pLayLine:setVisible(false)
	else
		self.pLayBg:setVisible(false)
		self.pLayReplayerBtn:setVisible(false)
		self.pLayLine:setVisible(true)
	end

end

function ItemArenaBattlers:hideReplayBtn()
	-- body
	self.pLayReplayerBtn:setVisible(false)
end

function ItemArenaBattlers:showReplayBtn( )
	-- body
	self.pLayReplayerBtn:setVisible(true)
end
function ItemArenaBattlers:setReplayHandler(_handler )
	-- body
	if _handler then
		self.replayHandler=_handler
	end
end

function ItemArenaBattlers:onReplayClicked( )
	-- body
	if self.replayHandler then
		self.replayHandler()
	end

end

return ItemArenaBattlers


