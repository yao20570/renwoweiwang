-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-1-18 10:05:40 星期四
-- Description: 竞技场列表单项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemArenaRank = class("ItemArenaRank", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
--_nType 1 奖励列表项 2 竞技场排行列表项 3 幸运奖励列表 4 幸运排名列表
function ItemArenaRank:ctor(_nType, _nWidth, _nHeight, _tPos)
	-- body	
	self:myInit()	
	self.nShowType = _nType or 1
	self.nItemWidth = _nWidth or 560
	self.nItemHeight = _nHeight or 56
	self.tPos = _tPos or {60, 140}
	parseView("item_arena_rank", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemArenaRank:myInit()
	-- body		
	self.tCurData 			= 	nil 				--当前数据	
	self.tLabels 			= 	nil
	self.pImgFlag 			= 	nil 

	self.nItemClickHandler  =  nil
end

--解析布局回调事件
function ItemArenaRank:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemArenaRank",handler(self, self.onDestroy))
end

--初始化控件
function ItemArenaRank:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("item_arena_rank")
	self.pImgLine = self:findViewByName("img_line")	
	self.pImgLine:setPositionX(self.nItemWidth/2)
	self.pImgLine:setLayoutSize(self.nItemWidth - 56, self.pImgLine:getHeight())
	self:setLayoutSize(self.nItemWidth, self.nItemHeight)
	self.pLayRoot:setLayoutSize(self.nItemWidth, self.nItemHeight)	
	self:onMViewClicked(handler(self, self.onItemClicked))
	self:setIsPressedNeedScale(false)
	self:createLabels()	
end

-- 修改控件内容或者是刷新控件数据
function ItemArenaRank:updateViews( )
	-- body
	if self.nShowType == 1 then
		self:updateArenaReward()
	elseif self.nShowType == 2 then
	 	self:updateAthleticsRank()
	elseif self.nShowType == 3 then	 	
		self:updateLuckyReward()
	elseif self.nShowType == 4 then	 	
		self:updateLuckyRank()		
	end 	
end

--竞技排行奖励刷新
function ItemArenaRank:updateArenaReward( )
	-- body
	if not self.tCurData then		
		return
	end
	local pData = self.tCurData
	local sStr = ""
	if pData.startrk and pData.endrk then
		if pData.startrk == pData.endrk then
			sStr = pData.endrk
		else
			sStr = string.format("%s-%s", pData.startrk, pData.endrk)	
		end	
	elseif pData.startrk and not pData.endrk then
		sStr = string.format(getConvertedStr(6, 10823), pData.startrk)	
	end
	self.tLabels[1]:setString(sStr, false)
	setTextCCColor(self.tLabels[1], _cc.pwhite)	

	local tAwards = pData.tAwards
	if tAwards and #tAwards > 0 then
		sortGoodsList(tAwards)
		local tDatas = {}
		for k, v in pairs(tAwards) do
			local pItem = getGoodsByTidFromDB(v.k)
			if pItem then
				pItem.nCt = v.v	
				table.insert(tDatas, pItem)			
			end
		end
		gRefreshHorizontalList(self.pLayRewards, tDatas)
	end
end

--竞技排行刷新
function ItemArenaRank:updateAthleticsRank( )
	-- body
	if self.tCurData then
		--排名
		self.tLabels[1]:setString(self.tCurData.rank, false)
		setTextCCColor(self.tLabels[1], _cc.pwhite)
		--国家
		self.tLabels[2]:setString(getCountryShortName(self.tCurData.country, false), false)
		setTextCCColor(self.tLabels[2], getColorByCountry(self.tCurData.country))

		--名字
		self.tLabels[3]:setString(self.tCurData.name, false)
		setTextCCColor(self.tLabels[3], _cc.pwhite)
		--等级
		self.tLabels[4]:setString(self.tCurData.level, false)
		setTextCCColor(self.tLabels[4], _cc.pwhite)

		--战力
		self.tLabels[5]:setString(self.tCurData.score, false)
		setTextCCColor(self.tLabels[5], _cc.pwhite)		
	end
end

function ItemArenaRank:updateLuckyReward(  )
	-- body
	--排名
	if not self.tCurData then
		return
	end
	--排名
	self.tLabels[1]:setString(self.tCurData.lr, false)
	setTextCCColor(self.tLabels[1], _cc.pwhite)	
	--名称
	self.tLabels[2]:setString(self.tCurData.ln, false)
	setTextCCColor(self.tLabels[2], _cc.pwhite)			
	--奖励
	local tAwards = getArenaLuckyPrizeById(self.tCurData.li)	
	if tAwards and #tAwards > 0 then
		sortGoodsList(tAwards)
		local tDatas = {}
		for k, v in pairs(tAwards) do
			local pItem = getGoodsByTidFromDB(v.k)
			if pItem then
				pItem.nCt = v.v	
				table.insert(tDatas, pItem)			
			end
		end
		gRefreshHorizontalList(self.pLayRewards, tDatas)
	end
end

function ItemArenaRank:updateLuckyRank()
	if not self.tCurData then
		return
	end
	--排名
	self.tLabels[1]:setString(self.tCurData.rank, false)
	setTextCCColor(self.tLabels[1], _cc.pwhite)		
	--奖励
	local tAwards = getArenaLuckyPrizeByRank(self.tCurData.rank)	
	if tAwards and #tAwards > 0 then
		sortGoodsList(tAwards)
		local tDatas = {}
		for k, v in pairs(tAwards) do
			local pItem = getGoodsByTidFromDB(v.k)
			if pItem then
				pItem.nCt = v.v	
				table.insert(tDatas, pItem)			
			end
		end
		gRefreshHorizontalList(self.pLayRewards, tDatas)
	end
end

-- 析构方法
function ItemArenaRank:onDestroy( )
	-- body
end

function ItemArenaRank:createLabels(  )
	-- body
	local nX = self.tPos[2]
	if self.nShowType == 1 then
		self.tLabels = {}
		local pLabel = MUI.MLabel.new({
	        text="",
	        size=20,
	        anchorpoint=cc.p(0.5, 0.5)
    	})
		pLabel:setPosition(self.tPos[1], self.nItemHeight/2)
		self.pLayRoot:addView(pLabel)
		self.tLabels[1] = pLabel	

		self.pLayRewards = MUI.MLayer.new()
		self.pLayRewards:setContentSize(cc.size(400, self.nItemHeight - 10))
		self.pLayRewards:setPosition(self.tPos[2], 2)
		self.pLayRoot:addView(self.pLayRewards, 10)
		self.pImgLine:setLayoutSize(self.nItemWidth, self.pImgLine:getHeight())		
	elseif self.nShowType == 2 then--只显示文字
		self.tLabels = {}
		for i = 1, 5 do
			local pLabel = self.tLabels[i]
			if not pLabel then
				local pLabel = MUI.MLabel.new({
			        text="",
			        size=20,
			        anchorpoint=cc.p(0.5, 0.5)
		    	})
				pLabel:setPosition(self.tPos[i], self.nItemHeight/2)
				self.pLayRoot:addView(pLabel)
				self.tLabels[i] = pLabel	
			end	
		end
	elseif self.nShowType == 3 then
		self.tLabels = {}
		for i = 1, 2 do
			local pLabel = self.tLabels[i]
			if not pLabel then
				local pLabel = MUI.MLabel.new({
			        text="",
			        size=20,
			        anchorpoint=cc.p(0.5, 0.5)
		    	})
				pLabel:setPosition(self.tPos[i], self.nItemHeight/2)
				self.pLayRoot:addView(pLabel)
				self.tLabels[i] = pLabel	
			end	
		end
		local nWidth = 176--按显示两个物品的标准计算
		self.pLayRewards = MUI.MLayer.new()
		self.pLayRewards:setContentSize(cc.size(nWidth, self.nItemHeight - 10))
		self.pLayRewards:setPosition(self.tPos[3] - nWidth/2, 2)
		self.pLayRoot:addView(self.pLayRewards, 10)
		self.pImgLine:setLayoutSize(self.nItemWidth, self.pImgLine:getHeight())	
	elseif self.nShowType == 4 then
		self.tLabels = {}
		local pLabel = MUI.MLabel.new({
	        text="",
	        size=20,
	        anchorpoint=cc.p(0.5, 0.5)
    	})
		pLabel:setPosition(self.tPos[1], self.nItemHeight/2)
		self.pLayRoot:addView(pLabel)
		self.tLabels[1] = pLabel	

		local nWidth = 176--按显示两个物品的标准计算
		self.pLayRewards = MUI.MLayer.new()
		self.pLayRewards:setContentSize(cc.size(nWidth, self.nItemHeight - 10))
		self.pLayRewards:setPosition(self.tPos[2] - nWidth/2, 2)
		self.pLayRoot:addView(self.pLayRewards, 10)
		self.pImgLine:setLayoutSize(self.nItemWidth, self.pImgLine:getHeight())			
	end 	
	
end

function ItemArenaRank:setCurData( _data )
	-- body	
	self.tCurData = _data
	self:updateViews()
end

function ItemArenaRank:setItemClickedHandler( _nHandler )
	-- body
	self.nItemClickHandler = _nHandler
	if self.nItemClickHandler then
		self:setViewTouched(true)		
	else
		self:setViewTouched(false)		
	end
	
end

function ItemArenaRank:onItemClicked(  )
	-- body
	if self.nItemClickHandler then
		self.nItemClickHandler(self.tCurData)
	end
end
return ItemArenaRank