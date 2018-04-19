-- Author: maheng
-- Date: 2017-12-29 14:14:05
-- 城墙武将
local MCommonView = require("app.common.MCommonView")
local ItemListWallNpc = require("app.layer.wall.ItemListWallNpc")
local nDisTop = 20
local nItemH = 170
local nTitleToTop = 75

local LayWallNpcs = class("LayWallNpcs", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LayWallNpcs:ctor(_nTeamType)
	-- body
	self:myInit()

	self.nTeamType = _nTeamType or 1
	parseView("lay_wall_npc", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("LayWallNpcs",handler(self, self.onDestroy))
	
end

--初始化参数
function LayWallNpcs:myInit()
	self.tShowWallNpcList = {} --城防npc队列

	self.tItemNpcs = {}
end

--解析布局回调事件
function LayWallNpcs:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
end

--初始化控件
function LayWallNpcs:setupViews( )
	self.pLayRoot = self:findViewByName("lay_wall_npc")
	self.pLayHeros 	= 	self:findViewByName("ly_heros")
	self.pImgTitle = self:findViewByName("img_title")
end


-- 修改控件内容或者是刷新控件数据
function LayWallNpcs:updateViews(  )
	self:refreshData()
	local nItemCnt = #self.tShowWallNpcList
	if nItemCnt ~= #self.tItemNpcs then
		self:removeAllItems()
	end

	for k, v in pairs(self.tShowWallNpcList) do
		pItem = self.tItemNpcs[k]
		if not pItem then
			pItem =  ItemListWallNpc.new()
			pItem:setPosition(10, (nItemCnt-k)*nItemH)
			self.pLayHeros:addView(pItem)
			self.tItemNpcs[k] = pItem
		end
		pItem:setCurData(self.tShowWallNpcList[k])
	end
	local nHeight = nItemH*nItemCnt + nDisTop
	self.pLayRoot:setContentSize(cc.size(self.pLayRoot:getWidth(), nHeight))
	self:setContentSize(cc.size(self.pLayRoot:getWidth(), nHeight))
	self.pLayHeros:setContentSize(cc.size(self.pLayRoot:getWidth(), nHeight - nTitleToTop))
	self.pImgTitle:setPositionY(nHeight - nTitleToTop)
end

function LayWallNpcs:removeAllItems()
	-- body
	if self.tItemNpcs and #self.tItemNpcs > 0 then
		for k, v in pairs(self.tItemNpcs) do
			v:removeSelf()
		end
	end	
	self.tItemNpcs = {}
end

function LayWallNpcs:refreshData(  )
	-- body
	self.pData = Player:getBuildData():getBuildById(e_build_ids.gate) --城墙数据
	self.tShowWallNpcList = self.pData:getshowDefWallArmy()	

end
--析构方法
function LayWallNpcs:onDestroy(  )
	-- body

end


return LayWallNpcs