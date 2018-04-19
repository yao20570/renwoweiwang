-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-21 17:09:23 星期三
-- Description: 竞技场 奖励分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local MImgLabel = require("app.common.button.MImgLabel")

local ArenaScoreReward = require("app.layer.arena.ArenaScoreReward")
local ArenaRankReward = require("app.layer.arena.ArenaRankReward")
local ArenaLuckyReward = require("app.layer.arena.ArenaLuckyReward")


local ArenaRewardLayer = class("ArenaRewardLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaRewardLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_arena_reward", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaRewardLayer:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaRewardLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaRewardLayer:myInit()
	-- body
	self.nCurIdx = 1
	self.tTabBtns = nil
	self.tTabPages = {}
end

--初始化控件
function ArenaRewardLayer:setupViews( )
	-- body		
	self.pLayTab = self:findViewByName("lay_tab")
	self.pLayCont = self:findViewByName("lay_main")

	self.tTitles = {
		getConvertedStr(6, 10800),
		getConvertedStr(6, 10696),
		getConvertedStr(6, 10687),
	}
	if not self.tTabBtns then
		self.tTabBtns = {}
		for i = 1, 3 do
			local pLayBtn = self:findViewByName("lay_tab_btn_"..i)
			pLayBtn:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})	
			local pLabel = MUI.MLabel.new({
		        text="",
		        size=20,
		        anchorpoint=cc.p(0.5, 0.5)
	    	})
			pLabel:setString(self.tTitles[i])
			pLabel:setPosition(pLayBtn:getWidth()/2, pLayBtn:getHeight()/2)
			pLayBtn:addView(pLabel)

			pLayBtn:setViewTouched(true)
			pLayBtn:setIsPressedNeedScale(false)
			pLayBtn:onMViewClicked(function ()
				self:onIndexSelected(i)
			end)

			self.tTabBtns[i] = pLayBtn
		end
		self:onIndexSelected(1)
	end
end

-- 修改控件内容或者是刷新控件数据
function ArenaRewardLayer:updateViews(  )
	-- body
	local pArena = Player:getArenaData()	
	if pArena then				
		showRedTips(self.tTabBtns[1],0,pArena:getScroeRedNum(),2)
		showRedTips(self.tTabBtns[2],0,pArena:getRankRedNum(),2)
		showRedTips(self.tTabBtns[3],0,pArena:getLuckyRedNum(),2)
	end	
end

function ArenaRewardLayer:enterArenaRank( _nIdxPag )
	-- body
	if _nIdxPag and (_nIdxPag == 1 or _nIdxPag == 2 or _nIdxPag == 3) then
		self.nCurIdx = _nIdxPag
	end
	self:onIndexSelected(self.nCurIdx)--
end

function ArenaRewardLayer:onIndexSelected( _index )
	-- body
	self.nCurIdx = _index
	for k, v in pairs(self.tTabBtns) do		
		local pPage = self.tTabPages[k]
		if pPage then
			pPage:setVisible(k == self.nCurIdx)
		end
		if k == self.nCurIdx then			
			v:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		else			
			v:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		end
	end	
	if self.nCurIdx == 1 then
		if not self.tTabPages[1] then
			local pTabItemLayer = ArenaScoreReward.new()	
			self.pLayCont:addView(pTabItemLayer)
			self.tTabPages[1] = pTabItemLayer
		else
			self.tTabPages[1]:updateViews()					
		end		
	elseif self.nCurIdx == 2 then
		if not self.tTabPages[2] then
			local pTabItemLayer = ArenaRankReward.new()	
			self.pLayCont:addView(pTabItemLayer)
			self.tTabPages[2] = pTabItemLayer
		else
			self.tTabPages[2]:updateViews()					
		end				
	elseif self.nCurIdx == 3 then
		if not self.tTabPages[3] then
			local pTabItemLayer = ArenaLuckyReward.new()	
			self.pLayCont:addView(pTabItemLayer)
			self.tTabPages[3] = pTabItemLayer
		else
			self.tTabPages[3]:updateViews()					
		end			
	end	
end

--析构方法
function ArenaRewardLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaRewardLayer:regMsgs( )
	-- body
	--注册竞技场视图数据刷新消息
	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))	
end

-- 注销消息
function ArenaRewardLayer:unregMsgs(  )
	-- body
	--注销竞技场视图数据刷新消息
	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaRewardLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaRewardLayer:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaRewardLayer
