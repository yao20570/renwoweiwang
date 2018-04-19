-- ItemConsumeGift.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-08-05 10:46:32
-- 消费好礼
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemConsumeReward =  require("app.layer.activitya.consumegift.ItemConsumeReward")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemConsumeGift = class("ItemConsumeGift", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemConsumeGift:ctor()
	self.tAllAwdInfo = {}
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemConsumeGift",handler(self, self.onItemConsumeGiftDestroy))	
end

--初始化控件
function ItemConsumeGift:setupViews( )
	self.pLayConBg:setLayoutSize(self.pLayConBg:getWidth(), self.pLayConBg:getHeight() - 123)
	self.pLayConBg:setPositionY(self.pLayConBg:getPositionY() + 123)
	self.pLayContent:setLayoutSize(self.pLayContent:getWidth(), self.pLayContent:getHeight() - 123)
	local pSize = self.pLayContent:getContentSize()
	self.pLySecTitle:setPositionY(self.pLySecTitle:getPositionY() - 123)

	--底层
	self.pLayBottom:setVisible(true)
	--隐藏内容层下的间隔
	self.pLaySpace:setVisible(false)

	--去消费按钮
	local pLayBtn = self:findViewByName("lay_btn")
	self.pBtnConsume = getCommonButtonOfContainer(pLayBtn,TypeCommonBtn.L_YELLOW, getConvertedStr(7, 10128))
	self.pBtnConsume:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBottom})
	self.pImgLabel:setImg("#v1_img_qianbi.png", 1, "right")
	self.pImgLabel:followPos("center", 251, 140, 10)
end

--去消费按钮点击事件
function ItemConsumeGift:onBtnClicked(pView)
	-- body
	--跳转到商店
	local tObject = {}
	tObject.nType = e_dlg_index.shop --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--更新
function ItemConsumeGift:updateViews( )
	if not self.pData then
		return
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	else
		self.pItemTime:setCurData(self.pData)
	end

	
	self:setDesc(self.pData.sDesc)
	--if self.pData.sDesc then
	--	self.pLbDescCn:setString(self.pData.sDesc)
	--end

	--按钮上的提示
	local tLabel = {
		{text = getConvertedStr(7, 10130), color = getC3B(_cc.pwhite)},
		{text = self.pData.nConGoldNum, color = getC3B(_cc.yellow)}
	}
	self.pImgLabel:setString(tLabel)

	self.tAllAwdInfo = self.pData.tAllAwdInfo or self.tAllAwdInfo

	--更新列表数据
	if not self.pListView then
		--列表
		local pSize = self.pLayContent:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height - 20),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }
	    self.pLayContent:addView(self.pListView)
		local nCount = table.nums(self.tAllAwdInfo)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemConsumeReward.new()
			end
			pTempView:setItemAwdInfo(self.tAllAwdInfo[_index])
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:reload()
	else
		self.pListView:notifyDataSetChange(true)
	end
end

--析构方法
function ItemConsumeGift:onItemConsumeGiftDestroy(  )
end

-- 注册消息
function ItemConsumeGift:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemConsumeGift:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemConsumeGift:onResume(  )
	self:regMsgs()
end

function ItemConsumeGift:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemConsumeGift:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end


return ItemConsumeGift