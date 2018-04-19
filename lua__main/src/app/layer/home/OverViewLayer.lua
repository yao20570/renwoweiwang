-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-10-20 16:07:40 星期六
-- Description: 总览里的每层
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local OverViewLayer = class("OverViewLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function OverViewLayer:ctor(_index)
	-- body
	self:myInit(_index)
	parseView("lay_overview", handler(self, self.onParseViewCallback))	
end

--初始化成员变量
function OverViewLayer:myInit(_index)
	-- body
	self.nIndex = _index
	self.tItemSize = {width = 480, height = 60}

	self.tItemGroup = {}
end

--解析布局回调事件
function OverViewLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("OverViewLayer",handler(self, self.onOverViewLayerDestroy))
end

--初始化控件
function OverViewLayer:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("lay_overview")
	--title
	self.pLayTitle = self:findViewByName("lay_title")
	self.pImgTitle = self:findViewByName("img_title")
	self.pLbTitle = self:findViewByName("lb_title")	--标题
	--lay_content
	self.pLayContent = self:findViewByName("lay_content")

	if self.nIndex == 1 then 				--建筑升级
		self.pImgTitle:setCurrentImage("#v1_img_jzsj.png")
		self.pImgTitle:setScale(0.4)
		self.pLbTitle:setString(getConvertedStr(7, 10153))
	elseif self.nIndex == 2 then 			--科技研究
		self.pImgTitle:setCurrentImage("#v1_img_kjyj.png")
		self.pImgTitle:setScale(0.4)
		self.pLbTitle:setString(getConvertedStr(7, 10154))
	elseif self.nIndex == 3 then 			--招募士兵
		self.pImgTitle:setCurrentImage("#v1_img_zmsb.png")
		self.pImgTitle:setScale(0.4) 
		self.pLbTitle:setString(getConvertedStr(7, 10155))
	elseif self.nIndex == 4 then 			--打造装备
		self.pImgTitle:setCurrentImage("#v1_img_dzzb.png")
		self.pImgTitle:setScale(0.4)
		self.pLbTitle:setString(getConvertedStr(7, 10156))
	elseif self.nIndex == 5 then 			--生产材料
		self.pImgTitle:setCurrentImage("#v1_img_sccl.png")
		self.pImgTitle:setScale(0.4)
		self.pLbTitle:setString(getConvertedStr(7, 10157))
	elseif self.nIndex == 6 then 			--武将队列
		self.pImgTitle:setCurrentImage("#v1_img_wjdl.png")
		self.pImgTitle:setScale(0.4)
		self.pLbTitle:setString(getConvertedStr(7, 10158))
	elseif self.nIndex == 7 then 			--武将推演
		self.pImgTitle:setCurrentImage("#v1_img_wjty.png")
		self.pImgTitle:setScale(0.4)
		self.pLbTitle:setString(getConvertedStr(7, 10159))
	end
end

-- 修改控件内容或者是刷新控件数据
function OverViewLayer:updateViews()
	-- body
	if self.tItemGroup and #self.tItemGroup > 0 then
		for k, v in pairs(self.tItemGroup) do
			v:setItemData(self.nIndex, k)
		end
	end
end

--每秒刷新
function OverViewLayer:onUpdateCd()
	-- body
	if self.tItemGroup and #self.tItemGroup > 0 then
		for k, v in pairs(self.tItemGroup) do
			if v and v.onUpdate then
				v:onUpdate()
			end
		end
	end
end

function OverViewLayer:regMsgs(  )
	if self.nIndex == 2 then
		--注册科技数据变化消息
		regMsg(self, gud_refresh_tnoly_lists_msg, handler(self, self.updateViews))
		--注册vip礼包购买消息
		regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.updateViews))
		--注册雇用研究员信息刷新
		regMsg(self, ghd_refresh_researcher_msg, handler(self, self.updateViews))
	elseif self.nIndex == 3 then
		-- 注册兵营士兵招募队列刷新消息
		regMsg(self, ghd_refresh_camp_recruit_msg, handler(self, self.updateViews))
	elseif self.nIndex == 4 then
		-- 注册打造装备刷新的消息
		regMsg(self, gud_equip_makevo_refresh_msg, handler(self, self.updateViews))
		-- 注册打造装备发生变化的消息
		regMsg(self, gud_equip_makevo_change_msg, handler(self, self.updateViews))
	elseif self.nIndex == 5 then
		-- 注册工坊队列刷新消息
		regMsg(self, ghd_refresh_atelier_msg, handler(self, self.updateViews))
	elseif self.nIndex == 6 then
		-- 注册英雄刷新消息
		regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
		--注册出征数据刷新消息
		regMsg(self, gud_world_task_change_msg, handler(self, self.updateViews))
	elseif self.nIndex == 7 then
		-- 注册拜将台免费招募消息
		regMsg(self, gud_refresh_buy_hero, handler(self, self.updateViews))
	end
end

function OverViewLayer:unregMsgs(  )
	if self.nIndex == 2 then
		--销毁科技数据变化消息
		unregMsg(self, gud_refresh_tnoly_lists_msg)
		--销毁vip礼包购买消息
		unregMsg(self, gud_vip_gift_bought_update_msg)
		--销毁雇用研究员信息刷新
		unregMsg(self, ghd_refresh_researcher_msg)
	elseif self.nIndex == 3 then
		--销毁兵营士兵招募队列刷新消息
		unregMsg(self, ghd_refresh_camp_recruit_msg)
	elseif self.nIndex == 4 then
		--销毁打造装备刷新的消息
		unregMsg(self, gud_equip_makevo_refresh_msg)
		--销毁打造装备发生变化的消息
		unregMsg(self, gud_equip_makevo_change_msg)
	elseif self.nIndex == 5 then
		--销毁工坊队列刷新消息
		unregMsg(self, ghd_refresh_atelier_msg)
	elseif self.nIndex == 6 then
		--销毁英雄刷新消息
		unregMsg(self, gud_refresh_hero)
		--销毁出征数据刷新消息
		unregMsg(self, gud_world_task_change_msg)
	elseif self.nIndex == 7 then
		-- 销毁拜将台免费招募消息
		unregMsg(self, gud_refresh_buy_hero)	
	end
end

function OverViewLayer:onResume()
	self:regMsgs()
end

function OverViewLayer:onPause()
	self:unregMsgs()
end

-- 析构方法
function OverViewLayer:onOverViewLayerDestroy(  )
	-- body
    self:onPause()
end

--设置标题
function OverViewLayer:setTitle(_sStr)
	-- body
    if not _sStr then
    	return
    end
    self.pLbTitle:setString(_sStr)
end

--添加设置项
function OverViewLayer:addItemView(_pView)
	-- body
	if not _pView then
		return
	end
	--添加到内容层
	self.pLayContent:addView(_pView)
	table.insert(self.tItemGroup, _pView)
	--重新布局
	local nCount = table.nums(self.tItemGroup)
	local nWidth = self.pLayTitle:getWidth()	
	local nHeight = self.pLayTitle:getHeight()
	--内容层的高度
	local nContentHeight = self.tItemSize.height * nCount
	nHeight = nHeight + nContentHeight	
	self.pLayContent:setLayoutSize(nWidth, nContentHeight)
	self.pLayTitle:setPosition(0, nContentHeight)
	self:setLayoutSize(nWidth, nHeight)	
	self.pLayRoot:setLayoutSize(nWidth, nHeight)	
	local nCurheight = nContentHeight
	for i, v in pairs(self.tItemGroup) do 
		if v then 	
			nCurheight = nCurheight - self.tItemSize.height
			v:setPosition(0, nCurheight)
		end
	end

	self:updateViews()
end
return OverViewLayer