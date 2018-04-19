-- ItemLevelPreview.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-1-29 17:14:23 星期一
-- Description: 等级预告每项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemBuild = require("app.layer.notice.ItemBuild")

local ItemLevelPreview = class("ItemLevelPreview", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemLevelPreview:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("item_level_preview", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemLevelPreview:myInit(_index)
	-- body
	self.nIndex = _index
	self.tCurData  = nil 				--当前数据
end

--解析布局回调事件
function ItemLevelPreview:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemLevelPreview",handler(self, self.onItemLevelPreviewDestroy))
end

--初始化控件
function ItemLevelPreview:setupViews()
	-- body
	self.pLayRoot    	= self:findViewByName("item_level_preview")
	--主公等级
	self.pLbLevel     	= self:findViewByName("lb_level")
	setTextCCColor(self.pLbLevel, _cc.white)
	local pTxtLevel    	= self:findViewByName("txt_level")
	pTxtLevel:setString(getConvertedStr(7, 10190))
	setTextCCColor(pTxtLevel, _cc.white)
	--设置描边
	pTxtLevel:enableOutline(getC4B("61101aff"), 1)
	--描述
	self.pLbDesc 		= self:findViewByName("lb_desc")

	self.pLbTitle1  	= self:findViewByName("lb_title_1")
	self.pLbTitle2  	= self:findViewByName("lb_title_2")
	--显示建筑层
	self.pLayBuild1 	= self:findViewByName("lay_build_1")
	self.pLayBuild2 	= self:findViewByName("lay_build_2")
	--箭头
	self.pImgArrow 		= self:findViewByName("img_arrow")
	if self.nIndex == 1 then
		self.pImgArrow:setVisible(false)
	else
		self.pImgArrow:setVisible(true)
	end
end

-- 修改控件内容或者是刷新控件数据
function ItemLevelPreview:updateViews()
	if not self.tCurData then return end

	self.pLbLevel:setString(self.tCurData.level)
	self.pLbDesc:setString(getTextColorByConfigure(self.tCurData.desc))
	self.pLbTitle1:setString(self.tCurData.title)
	self.pLbTitle2:setString(self.tCurData.palacetitle)
	
	if not self.pBuildListView1 then
		self.pBuildListView1 = createNewListView(self.pLayBuild1, MUI.MScrollView.DIRECTION_HORIZONTAL, nil, nil, 0, 0, 20, 0)
		self.pBuildListView1:setItemCount(table.nums(self.tCurData.tOpenId))
		self.pBuildListView1:setItemCallback(function ( _index, _pView ) 
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemBuild.new(_index)                        
		        pTempView:setViewTouched(false)   
		    end
		    local tData = self.tCurData.tOpenId[_index]
		    pTempView:setBuildData(tData)    	
		    return pTempView	
		end)
		self.pBuildListView1:reload(true)
	else
		self.pBuildListView1:notifyDataSetChange(false)
	end
	if not self.pBuildListView2 then
		self.pBuildListView2 = createNewListView(self.pLayBuild2, MUI.MScrollView.DIRECTION_HORIZONTAL, nil, nil, 0, 0, 20, 0)
		self.pBuildListView2:setItemCount(table.nums(self.tCurData.tPalaceId))
		self.pBuildListView2:setItemCallback(function ( _index, _pView ) 
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemBuild.new(_index)                        
		        pTempView:setViewTouched(false)   
		    end   
		    local tData = self.tCurData.tPalaceId[_index]
		    pTempView:setBuildData(tData)    	
		    return pTempView	
		end)
		self.pBuildListView2:reload(true)
	else
		self.pBuildListView2:notifyDataSetChange(false)
	end
end

-- 析构方法
function ItemLevelPreview:onItemLevelPreviewDestroy()
	-- body
end

-- 设置单项数据
function ItemLevelPreview:setItemData(_data)
	self.tCurData = _data
	self:updateViews()
end


return ItemLevelPreview
