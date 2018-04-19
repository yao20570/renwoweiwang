-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-7 15:41:23 星期三
-- Description: 将军任免对话框
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemCountryGlory = require("app.layer.country.ItemCountryGlory")
local CountryGloryRankLayer = require("app.layer.country.CountryGloryRankLayer")
local MCommonView = require("app.common.MCommonView")

local DlgCountryGlory = class("DlgCountryGlory", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgcountryglory)
end)

function DlgCountryGlory:ctor(  )
	-- body
	self:myInit()

	--设置标题
	self:setTitle(getConvertedStr(6,10322))

	self.pLayContent = MUI.MFillLayer.new()
	self.pLayContent:setViewTouched(false)
	--self.pLayContent:setLayoutSize(640, 1066)
	self:addContentView(self.pLayContent) --加入内容层	

	--self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgCountryGlory",handler(self, self.onDlgCountryGloryDestroy))	
end

function DlgCountryGlory:myInit(  )
	-- body
	self.tLbTitles = {}
	self.tCurData = nil
	self.pLayHonorTask = nil
	self.tItemGroup = nil
end


--初始化控件
function DlgCountryGlory:setupViews(  )
	-- body	

end	

--控件刷新
function DlgCountryGlory:updateViews( )
	-- body	
	local nItemHeight = 130
	local nItemRankHeight = 626
	local nInnerWidth = 640
	--local nLbHeight = 70
	local offY = 10	
	local nInnerHeight = nItemHeight*3 + offY*4
	local y = nInnerHeight
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if (_index == 1) then
			-- if not self.pScrollLayer then
			-- 	self.pScrollLayer = MUI.MScrollLayer.new({viewRect=cc.rect(0, 0, self.pLayContent:getWidth(), self.pLayContent:getHeight()),
			--         touchOnContent = true,
			--         direction=MUI.MScrollLayer.DIRECTION_VERTICAL})
			-- 	self.pLayScrollInner = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
			-- 	self.pLayScrollInner:setLayoutSize(nInnerWidth, nInnerHeight)
			-- 	self.pScrollLayer:addView(self.pLayScrollInner, 10)
			-- 	self.pLayContent:addView(self.pScrollLayer, 10)	
			-- end
		elseif (_index == 2) then
			local thonortask = Player:getCountryData():getCountryGloryTask()
			if not self.tItemGroup then
				self.tItemGroup = {}
			end		
            	
            if self.pLayCountryGlory == nil then
                self.pLayCountryGlory = MUI.MLayer.new()
                self.pLayCountryGlory:setContentSize(640, nInnerHeight)
                self.pLayCountryGlory:setPositionY(nItemRankHeight)
                self.pLayContent:addView(self.pLayCountryGlory, 5)
            end

			for i, v in pairs(thonortask) do
				if (not self.tItemGroup[v.sTid]) then
					local pItemHonorTask = ItemCountryGlory.new()
					y = nInnerHeight - (nItemHeight + offY)*i
					pItemHonorTask:setPosition(20, y)
					self.tItemGroup[v.sTid] = pItemHonorTask
					--self.tItemGroup[v.sTid]:setCurData(v)
					self.pLayCountryGlory:addView(pItemHonorTask, 5)
				end		
				self.tItemGroup[v.sTid]:setCurData(v)
			end	
		elseif (_index == 3) then
			-- y = y - nLbHeight/2

			-- local str1 = {
			-- 	{color=_cc.pwhite,text=getConvertedStr(6, 10236)},
			-- 	{color=_cc.pwhite,text=numTranformToWeek(getCountryParam("resetRankDay"))},
			-- 	{color=_cc.red,text=getCountryParam("resetRankTime")},
			-- 	{color=_cc.pwhite,text=getConvertedStr(6, 10503)},		
			-- }
			-- if not self.pLbPar1 then
			-- 	self.pLbPar1 = MUI.MLabel.new({
			--         text="",
			--         size=20,
			--         anchorpoint=cc.p(0, 0.5),
			--         dimensions = cc.size(500, 0),
			--         })	
			-- 	self.pLbPar1:setPosition(15, y + 12)
			-- 	self.pLayScrollInner:addView(self.pLbPar1, 10)
			-- end
			-- self.pLbPar1:setString(str1, false)
			
			-- if not self.pLbPar2 then
			-- 	self.pLbPar2 = MUI.MLabel.new({
			--         text="",
			--         size=20,
			--         anchorpoint=cc.p(1, 0.5),
			--         dimensions = cc.size(500, 0),
			--         })	
			-- 	self.pLbPar2:setPosition(590, y + 12)
			-- 	self.pLayScrollInner:addView(self.pLbPar2, 10)
			-- end
			-- local nVotes = Player:getCountryData():getCountryDataVo().nVotes
			-- local Str2 = {
			-- 	{color=_cc.pwhite, text=getConvertedStr(6, 10504)},
			-- 	{color=_cc.blue, text=nVotes or 0},
			-- }
			-- self.pLbPar2:setString(Str2)

			-- if not self.pLbPar3 then
			-- 	self.pLbPar3 = MUI.MLabel.new({
			--         text="",
			--         size=20,
			--         anchorpoint=cc.p(0, 0.5),
			--         dimensions = cc.size(500, 0),
			--         })	
			-- 	self.pLbPar3:setPosition(15, y - 12)
			-- 	self.pLbPar3:setString(getTextColorByConfigure(getTipsByIndex(10054)), false)
			-- 	self.pLayScrollInner:addView(self.pLbPar3, 10)	
			-- end
			if not self.pGloryRankLayer then
				self.pGloryRankLayer = CountryGloryRankLayer.new()
				self.pGloryRankLayer:setPosition(0, 0)
				self.pLayContent:addView(self.pGloryRankLayer, 5)
			end
		-- elseif (_index == 4 ) then
		-- 	if not self.pGloryRankLayer1 then
		-- 		y = y - nLbHeight/2 - nItemRankHeight
		-- 		self.pGloryRankLayer1 = CountryGloryRankLayer.new(e_rank_type.cityfight)
		-- 		self.pGloryRankLayer1:setTitle(getConvertedStr(6, 10358))
		-- 		self.pGloryRankLayer1:setPosition(0, y)
		-- 		self.pLayScrollInner:addView(self.pGloryRankLayer1, 5)
		-- 	end
		-- 	--self.pGloryRankLayer1:updateViews()
		-- 	if not self.pGloryRankLayer2 then
		-- 		y = y - nItemRankHeight
		-- 		self.pGloryRankLayer2 = CountryGloryRankLayer.new(e_rank_type.countryfight)
		-- 		self.pGloryRankLayer2:setTitle(getConvertedStr(6, 10407))
		-- 		self.pGloryRankLayer2:setPosition(0, y)
		-- 		self.pLayScrollInner:addView(self.pGloryRankLayer2, 5)
		-- 	end
		-- 	--self.pGloryRankLayer2:updateViews()
		-- 	if not self.pGloryRankLayer3 then
		-- 		y = y - nItemRankHeight
		-- 		self.pGloryRankLayer3 = CountryGloryRankLayer.new(e_rank_type.countrybuild)
		-- 		self.pGloryRankLayer3:setTitle(getConvertedStr(6, 10408))
		-- 		self.pGloryRankLayer3:setPosition(0, y)
		-- 		self.pLayScrollInner:addView(self.pGloryRankLayer3, 5)
		-- 	end
		-- 	--self.pGloryRankLayer3:updateViews()
		end
	end)

end

--析构方法
function DlgCountryGlory:onDlgCountryGloryDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgCountryGlory:regMsgs(  )
	-- body
	--注册国家任务界面刷新消息
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateViews))
	regMsg(self, gud_refresh_country_honor_msg, handler(self, self.updateViews))	
	--国家数据玩家进入排行榜奖励票数刷新
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))
end
--注销消息
function DlgCountryGlory:unregMsgs(  )
	-- body
	--注销国家任务界面刷新消息
	unregMsg(self, gud_refresh_rankinfo)
	--国家荣誉数据变化
	unregMsg(self, gud_refresh_country_honor_msg)
	--国家数据玩家进入排行榜奖励票数刷新
	unregMsg(self, gud_refresh_country_msg)
end

--暂停方法
function DlgCountryGlory:onPause( )
	-- body	
	self:unregMsgs()	
	sendMsg(ghd_clear_rankinfo_msg)	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgCountryGlory:onResume( _bReshow )
	-- body		
	self:updateViews()
	self:regMsgs()
	-- if self.pGloryRankLayer1 then
	-- 	self.pGloryRankLayer1:onResume(_bReshow)
	-- end
	-- if self.pGloryRankLayer2 then
	-- 	self.pGloryRankLayer2:onResume(_bReshow)
	-- end
	-- if self.pGloryRankLayer3 then
	-- 	self.pGloryRankLayer3:onResume(_bReshow)
	-- end

end

return DlgCountryGlory