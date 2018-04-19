-- OverView.lua
----------------------------------------------------- 
-- author: dshulan
-- updatetime: 2017-10-20 18:11:10 星期五
-- Description: 总览
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local OverViewLayer = require("app.layer.home.OverViewLayer")
local OverViewItem = require("app.layer.home.OverViewItem")
local OverView = class("OverView", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function OverView:ctor()
	--解析文件
	parseView("overview", handler(self, self.onParseViewCallback))
end

--解析界面回调
function OverView:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("OverView", handler(self, self.onOverViewDestroy))

end

-- 析构方法
function OverView:onOverViewDestroy(  )
    self:onPause()
end

function OverView:regMsgs(  )
	--注册建筑状态变化的消息
	regMsg(self, gud_build_state_change_msg, handler(self, self.updateViews))
	-- 注册建筑解锁状态
	regMsg(self, ghd_build_group_unlock_msg, handler(self, self.updateViews))
	--注册购买建筑队列刷新消息
	regMsg(self, gud_build_data_refresh_msg, handler(self, self.updateViews))
end

function OverView:unregMsgs(  )
	--销毁建筑状态变化的消息
	unregMsg(self, gud_build_state_change_msg)
	--销毁建筑解锁状态
	unregMsg(self, ghd_build_group_unlock_msg)
	--销毁购买建筑队列刷新消息
	unregMsg(self, gud_build_data_refresh_msg)
end

function OverView:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function OverView:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function OverView:setupViews(  )
	--拦截点击
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onBackClicked))

	--拦截点击
	self.pLayBgView = self:findViewByName("overview")
	self.pLayBgView:setViewTouched(true)
	self.pLayBgView:setIsPressedNeedScale(false)
	self.pLayBgView:setIsPressedNeedColor(false)

	local pImgLeft = self:findViewByName("img_t_left")
	pImgLeft:setFlippedX(true)

	--lb
	local pLbTitle = self:findViewByName("lb_title")
	pLbTitle:setString(getConvertedStr(7, 10152))

	--总览返回层
	local pLayBack = self:findViewByName("lay_back")
	pLayBack:setViewTouched(true)
	pLayBack:setIsPressedNeedScale(false)
	pLayBack:onMViewClicked(handler(self, self.onBackClicked))

	self.pLayScroll = self:findViewByName("lay_scroll")

	--层列表
	self.tOverViewLayers = {}

	regUpdateControl(self, handler(self, self.onUpdateCd))

	--初始化底部向下箭头
	self:initDownArrow()
end

function OverView:updateViews(  )
	if not self.pScrollView then
		local tSize = self.pLayScroll:getContentSize()
		self.pScrollView = MUI.MScrollLayer.new({
			viewRect = cc.rect(0, 0, tSize.width, tSize.height),
	        touchOnContent = true,
		    direction = MUI.MScrollLayer.DIRECTION_VERTICAL
		})
		self.pScrollView:setBounceable(true)
		self.pLayScroll:addView(self.pScrollView, 10)

		--创建7个总览层(以后如果有新的再加)
		for i = 1, 7 do
			local pTempView = OverViewLayer.new(i)
			if i == 1 then 					--建筑升级队列
				-- local pItemView = OverViewItem.new()
				-- pItemView:setName(overview_item[i.."_"..k])
				-- pTempView:addItemView(pItemView)
				self:createItemView(pTempView, 2)
			elseif i == 2 then 				--科技研究
				self:createItemView(pTempView, 1)
			elseif i == 3 then 				--招募士兵
				self:createItemView(pTempView, 3)
			elseif i == 4 then 				--打造装备
				self:createItemView(pTempView, 1)
			elseif i == 5 then 				--生产材料
				self:createItemView(pTempView, 1)
			elseif i == 6 then 				--武将队列
				self:createItemView(pTempView, 1)
			elseif i == 7 then 				--武将推演(神将现在屏蔽,现在先只显示良将)
				self:createItemView(pTempView, 2)
			end
			self.tOverViewLayers[i] = pTempView
		end
		self.pScrollView:onScroll(function(event)
		    if event.name == "scrollToHeader" then     --最上面回调
		    elseif event.name == "scrollToFooter" then --最下面回调
		    elseif event.name == "scrollEnd" then
		    	--检测底部箭头显示情况
		    	self:checkShowDownArrow()
		    end
		end)
	else
		for k, v in pairs(self.tOverViewLayers) do
			v:updateViews()
		end
	end
end

--初始化底部向下箭头
function OverView:initDownArrow()
	self.pImgDownArrow = MUI.MImage.new("#v1_btn_left.png")
	self.pLayBgView:addView(self.pImgDownArrow, 2)
	local nX, nY = self.pLayScroll:getPosition()
	local pSize = self.pLayScroll:getContentSize()
	local nX1, nY1 = pSize.width/2, nY
	self.pImgDownArrow:setPosition(nX1, nY1)

	local pAct = cc.RepeatForever:create(cc.Sequence:create(
		cc.FadeTo:create(1,120),
		cc.FadeTo:create(1,255)))
	self.pImgDownArrow:runAction(pAct)

	self.pImgDownArrow:setVisible(true)
end

--检测底部箭头显示情况
function OverView:checkShowDownArrow()
	-- body
	local pScrollNode = self.pScrollView:getScrollNode()
	if pScrollNode then
		local pInnerSize = pScrollNode:getContentSize()
		local nX, nY = pScrollNode:getPosition()
		local pSViewSize = self.pScrollView:getContentSize()

		self.pImgDownArrow:setVisible(nY < 0)
	end
end

function OverView:onScrollToBegin()
	-- body
	if self.pScrollView then
		self.pScrollView:scrollToBegin(false)
		--检测箭头显示
		self:checkShowDownArrow()
	end
end

function OverView:onUpdateCd()
	if table.nums(self.tOverViewLayers) > 0 then
		for k, v in pairs(self.tOverViewLayers) do
			v:onUpdateCd()
		end
	end
end

function OverView:createItemView(_tempView, _count)
	-- body
	for i = 1, _count do
		local pItemView = OverViewItem.new()
		_tempView:addItemView(pItemView)
	end
	self.pScrollView:addView(_tempView)
end


--关闭总览
function OverView:onBackClicked( )
	sendMsg(ghd_showorhide_overview_menu)
end


return OverView


