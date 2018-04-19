-- Author: maheng
-- Date: 2018-03-13 10:01:18
-- Description: 战地争霸排名上升效果展示界面

local MCommonView = require("app.common.MCommonView")
local ArenaRankUpItem = require("app.layer.arena.ArenaRankUpItem")

local ArenaRankUpView = class("ArenaRankUpView", function ()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ArenaRankUpView:ctor(  )
	-- 初始化数据
	self:myInit()

	-- 初始化界面
	self:doInit()
end

--数据初始化回调
function ArenaRankUpView:doInit(  )
	-- body

	self:setContentSize(cc.size(display.width, display.height))
	self:setPosition(cc.p(0, 0))
	self.pColorGourp = cc.LayerColor:create(GLOBAL_DIALOG_BG_COLOR_DEFAULT, display.width, display.height)	
	self.pColorGourp:setTouchCaptureEnabled(false);
	self.pColorGourp:setTouchEnabled(false);
	self.pColorGourp:setColor(cc.c4b(0,0,0,150))
	self.pColorGourp:setZOrder(-1)	
	self:addChild(self.pColorGourp)
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onClickClose))

	self:setupViews()

	local nZorder = 0x00FFFFFF - 1
	self:setZOrder(nZorder + 1)

	--注册析构方法
	self:setDestroyHandler("ArenaRankUpView",handler(self, self.onFightItemDestroy))

end

-- 消耗控件
function ArenaRankUpView:onFightItemDestroy()

end

--初始化成员变量
function ArenaRankUpView:myInit()
	self.nCallbackHandler = nil -- 回调

	self.nDiv = 300 -- 上下两个item的y轴间距
	self.nMoveTime = 0.5 -- 移动时间
end

--读入控件
function ArenaRankUpView:setupViews()

	-- 创建2个item
	self.pUpItem = ArenaRankUpItem.new(self.nMoveTime)
	self.pDownItem = ArenaRankUpItem.new(self.nMoveTime)

	self.pUpItem:setZOrder(1)
	self.pUpItem:setVisible(false)
	self.pDownItem:setVisible(false)

	self.pUpItem:setPosition(
		cc.p((self:getWidth() - self.pUpItem:getWidth()) / 2, self:getHeight() * 0.2 + 88))
	self:addView(self.pUpItem)

	self.pDownItem:setPosition(cc.p((self:getWidth() - self.pDownItem:getWidth()) / 2, 
		self.pUpItem:getPositionY() + self.nDiv))
	self:addView(self.pDownItem)
end

-- 刷新控件
function ArenaRankUpView:updateViews(  )
	if (not self.pPlayer1 or not self.pPlayer2) then
		return 
	end

	-- 设置数据
	self.pUpItem:setData(self.pPlayer1, self.nChangeRank, self.pPlayer2.ar)
	self.pDownItem:setData(self.pPlayer2, -self.nChangeRank, self.pPlayer1.ar)

	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function (  )
			-- 开始播放特效
			self:play()
		end)}))
end 
-- 播放特效
function ArenaRankUpView:play(  )
	self.pUpItem:setVisible(true)
	self.pDownItem:setVisible(true)

	-- 上移
	self:move(self.pUpItem, self.nDiv, self.nMoveTime)
	-- 下移
	self:move(self.pDownItem, -self.nDiv, self.nMoveTime)

	-- 播放排名提升动画
	self.pUpItem:doUpArm(function (  )
			-- 播放排名变化特效
			self.pUpItem:doRankChangeArm()
			self.pDownItem:doRankChangeArm()
		end, 
		function (  )
			-- 播放结束
			self.pDownItem:doDownArmPart2(function (  )
				-- 播放结束
				-- print("播放结束")
				self:playEnd()
			end)
		end)
	-- 播放排名下降动画
	self.pDownItem:doDownArm()
	
end

-- 上下移动
function ArenaRankUpView:move( _pView, _nDist, _nTime, _nCallback )
	if (not _pView) then
		return 
	end

	_pView:runAction(cc.Sequence:create({
		cc.MoveBy:create(_nTime or 0, cc.p(0, _nDist or 0)),
		cc.CallFunc:create(function (  )
			if (_nCallback) then
				_nCallback()
			end
		end)}))
end

-------------------------------------------------------
-- 播放结束
function ArenaRankUpView:playEnd(  )	
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(0.5), 
		cc.FadeOut:create(0.5), 
		cc.CallFunc:create(function (  )
			self:setVisible(false)
			self:onCallback()
			self:removViewFromAndCleanup()
		end)}))	
end

function ArenaRankUpView:removViewFromAndCleanup(  )
	-- body
	self:removeSelf()
end

-------------------------------------------------------
-- 点击关闭
function ArenaRankUpView:onClickClose(  )

end
-- 回调
function ArenaRankUpView:onCallback(  )
	if (self.nCallbackHandler) then
		self.nCallbackHandler()
		self.nCallbackHandler = nil
	end
end

-- _pPlayer1: 玩家1信息 （排名上升）{sName, sHeadIcon, sOrnIcon, nOriginal}
-- _pPlayer2：玩家2信息（排名下降）
-- _nChangeRank: 变化的排名
function ArenaRankUpView:showUp( _pPlayer1, _pPlayer2, _nChangeRank )
	self.pPlayer1 = _pPlayer1
	self.pPlayer2 = _pPlayer2
	self.nChangeRank = _nChangeRank or 0
	self:updateViews()
end

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
-- _pPlayer1: 玩家1信息 （排名上升）{sName, sHeadIcon, sOrnIcon, nOriginal}
-- _pPlayer2：玩家2信息（排名下降）
-- _nChangeRank: 变化的排名
function ArenaRankUpView.show( _pPlayer1, _pPlayer2, _nChangeRank, _nBackFunc )
	if (not _pPlayer1 or not _pPlayer2) then
		if _nBackFunc then
			_nBackFunc()
		end
		return 
	end
	local pShowGetView = ArenaRankUpView.new()
	local pParView = getRealShowLayer(RootLayerHelper:getCurRootLayer(),
			 e_layer_order_type.toastlayer)
	pShowGetView.nCallbackHandler = _nBackFunc
	pParView:addView(pShowGetView , 0)
	pShowGetView:showUp(_pPlayer1, _pPlayer2, _nChangeRank)
end


return ArenaRankUpView
