-- Author: liangzhaowei
-- Date: 2017-08-10 13:54:41
-- 活动标题模板第一种类型(600*264)

local MCommonView = require("app.common.MCommonView")
local ItemActivityPackTitleA = class("ItemActivityPackTitleA", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数 _data活动数据
function ItemActivityPackTitleA:ctor(_data)
	-- body
	self:myInit()


	parseView("item_activity_pack_title_a", handler(self, self.onParseViewCallback))

	if _data then
		self:setCurData(_data)
	end

	--注册析构方法
	self:setDestroyHandler("ItemActivityPackTitleA",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActivityPackTitleA:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemActivityPackTitleA:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())

	self.pLyView = pView
	self:addView(pView)
	centerInView(self, pView)


	

end


-- 修改控件内容或者是刷新控件数据
function ItemActivityPackTitleA:updateViews(  )

	if not self.pLyTop then
		self.pLyTop = self.pLyView:findViewByName("lay_top")

		--设置banner图
		self.pLayBannerBg = self.pLyView:findViewByName("la_banner_bg")
	end

	-- body
	--设置banner图
	if self.pData.nId == 2007 then --副本掉落
		self:setBannerImg(TypeBannerUsed.fl_dtbj)
	end
end

--设置banner图片 
function ItemActivityPackTitleA:setBannerImg(nType)
	if self.pLayBannerBg and nType then
		setMBannerImage(self.pLayBannerBg,nType)
	end
end

--析构方法
function ItemActivityPackTitleA:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemActivityPackTitleA:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:updateViews()

end

--获取添加neo内容层
function ItemActivityPackTitleA:getContent()

	if not self.pLyTopInner then
		self.pLyTopInner = self:findViewByName("lay_top_inner")
	end

	if self.pLyTopInner then
		return self.pLyTopInner
	end
end


return ItemActivityPackTitleA