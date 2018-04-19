------------------------------------------------
-- Author: dengshulan
-- Date: 2017-09-01 18:16:53
-- 副本章节列表
------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemFubenSigleChapter = require("app.layer.fuben.ItemFubenSigleChapter")
local ItemFubenChapterList = class("ItemFubenChapterList", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemFubenChapterList:ctor()
	-- body
	self:myInit()

	parseView("item_fuben_chapter_list", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemFubenChapterList",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenChapterList:myInit()
	self.pData = {} --数据
	self.tListItem = {} --item列表
end

--解析布局回调事件
function ItemFubenChapterList:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemFubenChapterList:setupViews( )
	self.pLayList = self:findViewByName("lay_list")
end

-- 修改控件内容或者是刷新控件数据
function ItemFubenChapterList:updateViews(  )
	-- body
end

--析构方法
function ItemFubenChapterList:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemFubenChapterList:setCurData(_tData)
	if not _tData then
		return
	end


	self.pData = _tData or {}


	for i=1,2 do
		local pView = self.tListItem[i]
		if self.pData[i] then
			if not pView then
				pView = ItemFubenSigleChapter.new()
				self.pLayList:addView(pView,i)
				pView:setPositionX((i-1)*28 + pView:getWidth()*(i-1))
				self.tListItem[i] = pView
			end
			pView:setVisible(true)
			pView:setCurData(self.pData[i])
		else
			if pView then
				pView:setVisible(false)
			end
		end
	end
	

end


return ItemFubenChapterList