----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-13 11:37:12
-- Description: 聊天表情面板
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DlgChatEmo = class("DlgChatEmo", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
local nEmoCntInOnePage = 32 --一页的表情数量
local nEmoCol = 8
local nUpMarge = 14
local nLeftMarge = 22
local nImgWidth = 50
local nImgHeight = 50
function DlgChatEmo:ctor( )
	parseView("dlg_chat_emo", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgChatEmo:onParseViewCallback(pView)
	self:setupViews(pView)
	self:updateViews()
	self:onResume()
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	--注册析构方法
	self:setDestroyHandler("DlgChatEmo",handler(self, self.onDlgChatEmoDestroy))
end

-- 析构方法
function DlgChatEmo:onDlgChatEmoDestroy(  )
    self:onPause()
end

function DlgChatEmo:regMsgs(  )
end

function DlgChatEmo:unregMsgs(  )
end

function DlgChatEmo:onResume(  )
	self:regMsgs()
end

function DlgChatEmo:onPause(  )
	self:unregMsgs()
end

function DlgChatEmo:setupViews( pView )
	local pPageView = pView:findViewByName("lay_page_view")
	local nWidth = pPageView:getWidth()
	local nHeight = pPageView:getHeight()
	self.pPageView = MUI.MPageView.new {viewRect = cc.rect(0, 0, pPageView:getWidth(), pPageView:getHeight())}
	self.pPageView:setCirculatory(false)
	pPageView:addView(self.pPageView)

	--表情列表
	self.tChatEmoList = getChatEmoOrder()
	--页数
	self.nPageCnt = math.ceil(#self.tChatEmoList/nEmoCntInOnePage)
	--换页点
	self.tPageDot = {}
	local nOffsetX = 30
	local nBeginX = self:getContentSize().width/2 - (self.nPageCnt * nOffsetX)/2
	for i = 1, self.nPageCnt do
		local pImgDot = MUI.MImage.new("#v1_img_huanyedian1.png", {scale9=false})
		self:addView(pImgDot, 2)
		pImgDot:setPosition(nBeginX, 15)
		self.tPageDot[i] = pImgDot
		nBeginX = nBeginX + nOffsetX
	end

	--翻页
	self.pItemList = {}
	self.pPageView:loadDataAsync(self.nPageCnt, 1, function ( _pView, _index )
		if self.pItemList[_index] then
			return self.pItemList[_index]
		end
		local pItem = self.pPageView:newItem()
		self.pItemList[_index] = pItem
		local pLayContent = MUI.MLayer.new()
		pLayContent:setLayoutSize(nWidth, nHeight)
		pItem:addView(pLayContent)
		centerInView(pItem, pLayContent)

		--生成表情
		local nBeginX, nBeginY = nImgWidth/2 + 10, nHeight - nImgHeight/2 - 6
		local nOrginX = nBeginX
		local nIndex = (_index - 1) * nEmoCntInOnePage
		for i=1,nEmoCntInOnePage do
			local nIndex2 = nIndex + i
			local tEmoData = self.tChatEmoList[nIndex2]
			if tEmoData then
				local pImg = MUI.MImage.new(tEmoData.sImg)
				pImg:setViewTouched(true)
				-- pView:setIsPressedNeedScale(false)
				-- pView:setIsPressedNeedColor(false)
				pImg.nEmoIndex = nIndex2
				pImg:onMViewClicked(handler(self, self.inputEmo))
				pLayContent:addView(pImg)
				pImg:setPosition(nBeginX, nBeginY)
			else
				break
			end
			if i % nEmoCol == 0 then
				nBeginX = nOrginX
				nBeginY = nBeginY - nImgHeight - nUpMarge
			else
				nBeginX = nBeginX + nImgWidth + nLeftMarge
			end
		end

		return pItem
	end,function ( _pView )
		-- body
	end)
	--换页
	self.pPageView:onTouch(function ( event )
            --dump(event, "event=", 100)
            if event.name == "pageChange" then
            	self:updatePageDot(event.pageIdx)
           	end
        end)
end

function DlgChatEmo:updateViews(  )
end


function DlgChatEmo:updatePageDot( _index )
	for i = 1, #self.tPageDot do
		if i == _index then
			self.tPageDot[i]:setCurrentImage("#v1_img_huanyedian2.png")
		else
			self.tPageDot[i]:setCurrentImage("#v1_img_huanyedian1.png")
		end
	end
end

function DlgChatEmo:inputEmo( pView )
	if not pView then
		return
	end

	local nEmoIndex = pView.nEmoIndex
	if not nEmoIndex then
		return
	end

	local tEmoData = self.tChatEmoList[nEmoIndex]
	if tEmoData then
		sendMsg(ghd_input_chat_emo, string.format("@%s#", tEmoData.name_chi))
	end
end

return DlgChatEmo