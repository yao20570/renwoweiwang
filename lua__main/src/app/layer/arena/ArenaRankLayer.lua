-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-15 15:00:23 星期一
-- Description: 竞技场 排行分页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ArenaAthleticsRank = require("app.layer.arena.ArenaAthleticsRank")
local ArenaLuckyRank = require("app.layer.arena.ArenaLuckyRank")


local ArenaRankLayer = class("ArenaRankLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function ArenaRankLayer:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("lay_arena_rank", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ArenaRankLayer:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ArenaRankLayer",handler(self, self.onDestroy))
end

-- --初始化参数
function ArenaRankLayer:myInit()
	-- body
	self.nCurIdx = 1
	self.tTabBtns = nil
	self.tTabPages = {}
end

--初始化控件
function ArenaRankLayer:setupViews( )
	-- body		
	self.pLayTab = self:findViewByName("lay_tab")
	self.pLayCont = self:findViewByName("lay_main")

	self.tTitles = {
		getConvertedStr(6, 10798),
		getConvertedStr(6, 10799),
	}
	if not self.tTabBtns then
		self.tTabBtns = {}
		for i = 1, 2 do
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
function ArenaRankLayer:updateViews(  )
	-- body
end

function ArenaRankLayer:enterArenaRank( _nIdxPag )
	-- body
	if _nIdxPag and (_nIdxPag == 1 or _nIdxPag == 2) then
		self.nCurIdx = _nIdxPag
	end
	self:onIndexSelected(self.nCurIdx)--
end

function ArenaRankLayer:onIndexSelected( _index )
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
			local pTabItemLayer = ArenaAthleticsRank.new()	
			self.pLayCont:addView(pTabItemLayer)
			self.tTabPages[1] = pTabItemLayer			
		end
		self.tTabPages[1]:checkArenaRank(1)
	elseif self.nCurIdx == 2 then
		if not self.tTabPages[2] then
			local pTabItemLayer = ArenaLuckyRank.new()			
			pTabItemLayer:setPosition(0, 0)		
			self.pLayCont:addView(pTabItemLayer)
			centerInView(self.pLayCont, pTabItemLayer)
			self.tTabPages[2] = pTabItemLayer			
		end
		self.tTabPages[2]:refreshLuckyData()
	end	
end

--析构方法
function ArenaRankLayer:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ArenaRankLayer:regMsgs( )
	-- body
	--注册竞技场视图数据刷新消息
	regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))	
end

-- 注销消息
function ArenaRankLayer:unregMsgs(  )
	-- body
	--注销竞技场视图数据刷新消息
	unregMsg(self, gud_refresh_arena_msg)	
end
--暂停方法
function ArenaRankLayer:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ArenaRankLayer:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ArenaRankLayer
