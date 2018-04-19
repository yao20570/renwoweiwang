----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-22 18:05:46
-- Description: 城战国战 战斗玩家列表子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemMailBattler = require("app.layer.mail.ItemMailBattler")
local ItemCCWarMailBattle = class("ItemCCWarMailBattle", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCCWarMailBattle:ctor(  )
	--解析文件
	parseView("item_mines_mail_battle", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCCWarMailBattle:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCCWarMailBattle",handler(self, self.onItemCCWarMailBattleDestroy))
end

-- 析构方法
function ItemCCWarMailBattle:onItemCCWarMailBattleDestroy(  )
    self:onPause()
end

function ItemCCWarMailBattle:regMsgs(  )
end

function ItemCCWarMailBattle:unregMsgs(  )
end

function ItemCCWarMailBattle:onResume(  )
	self:regMsgs()
end

function ItemCCWarMailBattle:onPause(  )
	self:unregMsgs()
end

function ItemCCWarMailBattle:setupViews(  )
	self.pLayAtk = self:findViewByName("lay_atk")
	self.pLayDef = self:findViewByName("lay_def")
	self.pLayBg	 = self:findViewByName("lay_bg")
	self.pLayReplayerBtn=self:findViewByName("lay_replay_btn")
	self.pLayLine=self:findViewByName("lay_line")

	self.pLayReplayerBtn:setViewTouched(true)
	self.pLayReplayerBtn:setIsPressedNeedScale(false)
	self.pLayReplayerBtn:onMViewClicked(handler(self, self.onReplayClicked))

	self.pLayBg:setVisible(false)
	local pItemMailBattler = ItemMailBattler.new(1)
	self.pLayAtk:addView(pItemMailBattler)
	self.pItemMailBattlerLeft = pItemMailBattler

	local pItemMailBattler = ItemMailBattler.new(2)
	self.pLayDef:addView(pItemMailBattler)
	self.pItemMailBattlerRight = pItemMailBattler
end

function ItemCCWarMailBattle:updateViews(  )
end

--tMailMsg
function ItemCCWarMailBattle:setData( tMailMsg, nIndex )
	if nIndex == 1 then
		
		self.pItemMailBattlerLeft:setAtkPlayer(tMailMsg)
		self.pItemMailBattlerLeft:setPlayPos(tMailMsg,1)
		self.pLayAtk:setVisible(true)
		self.pItemMailBattlerRight:setDefPlayer(tMailMsg)
		self.pItemMailBattlerRight:setPlayPos(tMailMsg,2)
		self.pLayDef:setVisible(true)


	else
		local nHeroIndex = nIndex - 1
		if tMailMsg.tAtkHeros then
			local tFightHero = tMailMsg.tAtkHeros[nHeroIndex]
			if tFightHero then
				self.pLayAtk:setVisible(true)
				self.pItemMailBattlerLeft:setHeroData(tFightHero, tMailMsg.nAtkCountry )
				-- self.pItemMailBattlerLeft:setMyPlayerName(tMailMsg,1)
			else
				self.pItemMailBattlerLeft:showTip(1)
				-- self.pLayAtk:setVisible(false)
			end
		else
			self.pItemMailBattlerLeft:showTip(1)
		end
		
		if tMailMsg.tDefHeros then
			local tFirstFightHero=tMailMsg.tDefHeros[1]

			local tFightHero = tMailMsg.tDefHeros[nHeroIndex]
			if tFightHero then
				self.pLayDef:setVisible(true)
				self.pItemMailBattlerRight:setHeroData(tFightHero, tMailMsg.nDefCountry)
				-- self.pItemMailBattlerRight:setMyPlayerName(tMailMsg,2)
				
			else
				self.pItemMailBattlerRight:showTip(2)

				-- self.pLayDef:setVisible(false)
			end
		else
			self.pItemMailBattlerRight:showTip(2)
		end
	end

	-- dump(tMailMsg)
	self:resetItemBg(nIndex)

	--无产生战斗时不显示播放按钮
	if (not tMailMsg.tAtkHeros or not tMailMsg.tDefHeros or #tMailMsg.tAtkHeros<=0 or #tMailMsg.tDefHeros<=0) and nIndex==1 then
		self:hideReplayBtn()
	end
	self:updateViews()
end

function ItemCCWarMailBattle:setData2( tAtkHeros, tDefHeros, nAtkCountry, nDefCountry, nHeroIndex )
	local nHeroIndex = nHeroIndex
	if tAtkHeros then
		local tFightHero = tAtkHeros[nHeroIndex]
		if tFightHero then
			self.pLayAtk:setVisible(true)
			self.pItemMailBattlerLeft:setHeroData(tFightHero, nAtkCountry )
		else
			self.pItemMailBattlerLeft:showTip(1)
		end
	else
		self.pItemMailBattlerLeft:showTip(1)
	end
	
	if tDefHeros then
		local tFightHero = tDefHeros[nHeroIndex]
		if tFightHero then
			self.pLayDef:setVisible(true)
			self.pItemMailBattlerRight:setHeroData(tFightHero, nDefCountry)
		else
			self.pItemMailBattlerRight:showTip(2)
		end
	else
		self.pItemMailBattlerRight:showTip(2)
	end

	self:resetItemBg(0)
	self:hideReplayBtn()
	self:updateViews()
end

--重新设置背景样式 因为第一个是特殊的 
function ItemCCWarMailBattle:resetItemBg( _nIndex)
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

function ItemCCWarMailBattle:hideReplayBtn()
	-- body
	self.pLayReplayerBtn:setVisible(false)
end

function ItemCCWarMailBattle:showReplayBtn( )
	-- body
	self.pLayReplayerBtn:setVisible(true)
end
function ItemCCWarMailBattle:setReplayHandler(_handler )
	-- body
	if _handler then
		self.replayHandler=_handler
	end
end

function ItemCCWarMailBattle:onReplayClicked( )
	-- body
	if self.replayHandler then
		self.replayHandler()
	end

end

return ItemCCWarMailBattle


