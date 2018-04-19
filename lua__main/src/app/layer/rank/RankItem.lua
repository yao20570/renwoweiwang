-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-17 15:05:40 星期三
-- Description: 排行单项层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local RankItem = class("RankItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function RankItem:ctor()
	-- body	
	self:myInit()	
	parseView("rank_item", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function RankItem:myInit()
	-- body		
	self.nIndex 			= 	nIndex or 1      --
	self.tCurData 			= 	nil 				--当前数据	
	self.tLabels 			= 	nil
end

--解析布局回调事件
function RankItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("RankItem",handler(self, self.onRankItemDestroy))
end

--初始化控件
function RankItem:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	self.pLayContent = self:findViewByName("lay_content")
	self.pLayLight = self:findViewByName("lay_ligth")
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:createLabels()
end

-- 修改控件内容或者是刷新控件数据
function RankItem:updateViews( )
	-- body
	local nranktype = Player:getRankInfo().nRankType
	if self.tCurData then
		--排名
		local nrank = self.tCurData.x
		self.tLabels[1]:setString(nrank)		
		if nrank == 1 then
			setTextCCColor(self.tLabels[1], _ccq.red)		
		elseif nrank == 2 then
			setTextCCColor(self.tLabels[1], _ccq.orange)		
		elseif nrank == 3 then
			setTextCCColor(self.tLabels[1], _ccq.purple)		
		else
			setTextCCColor(self.tLabels[1], _cc.pwhite)	
		end		

		--等级和战力
		if nranktype == e_rank_type.country or nranktype == e_rank_type.world then			
			setTextCCColor(self.tLabels[4], _cc.green)			
			setTextCCColor(self.tLabels[5], _cc.blue)
		end
		--位置更新		
		local tpos = getRankSetTypePos(nranktype)
		local bwidth = self.pLayRoot:getWidth()
		local rankdata = getRankData( nranktype )
		local ttypes = luaSplit(rankdata.sort, ";")
		for i = 1, 5 do
			if tpos[i] and ttypes[i] then				
				self.tLabels[i]:setVisible(true)
				self.tLabels[i]:setPositionX(tpos[i]*bwidth)
				self.tLabels[i]:setString(self.tCurData[ttypes[i]])
				if ttypes[i] == "c" then--国家
					setTextCCColor(self.tLabels[i], getColorByCountry(self.tCurData[ttypes[i]]))
					self.tLabels[i]:setString(getCountryName(self.tCurData[ttypes[i]]))
				end
			else
				self.tLabels[i]:setVisible(false)
			end	    
		end	 

	end
end

-- 析构方法
function RankItem:onRankItemDestroy( )
	-- body
end

function RankItem:setCurData( _data )
	-- body	
	self.tCurData = _data
	self:updateViews()
end

--是否设置为高亮北京
function RankItem:setListItemHightlight( _bhightlight )
	-- body
	if _bhightlight == true then
		self.pLayLight:setVisible(true)
		self.pLayContent:setVisible(false)
	else
		self.pLayLight:setVisible(false)
		self.pLayContent:setVisible(true)
	end
end

function RankItem:createLabels(  )
	-- body
	self.tLabels = {}
	for i = 1, 5 do
		local pLabel = MUI.MLabel.new({
        text="",
        size=20,
        anchorpoint=cc.p(0.5, 0.5)})
        pLabel:setPosition(self.pLayRoot:getWidth()/10*(i*2-1), self.pLayRoot:getHeight()/2)
        setTextCCColor(pLabel, _cc.pwhite)
        self.pLayRoot:addView(pLabel, 10)    
        self.tLabels[i] = pLabel
	end
end
return RankItem