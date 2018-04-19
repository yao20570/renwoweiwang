-- ItemRegress.lua
---------------------------------------------
-- Author: xiesite
-- Date: 2017-04-09 15:19:00
-- 回归有礼
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemRegressGetReward =  require("app.layer.activitya.regress.ItemRegressGetReward")
local ItemRegress = class("ItemRegress", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemRegress:ctor()
	self:setupViews()
	-- self:addAccountImg("#v2_img_huiguiyouli.png")
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemRegress",handler(self, self.onDestroy))	
end

--初始化控件
function ItemRegress:setupViews( )
	self.pLayDesc:setVisible(true)
end

--更新
function ItemRegress:updateViews( )
	if not self.pData then
		return
	end

	if not self.pImageFont then
		local pImage = MUI.MImage.new("#v2_img_huiguiyouli.png")
		pImage:setAnchorPoint(cc.p(0.5,0.5))
		self.pLayDesc:addView(pImage)
		local tSize = self.pLayDesc:getContentSize() 
		pImage:setPosition(cc.p(tSize.width/2, tSize.height/2))
		self.pImageFont = pImage
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	if self.pData.sDesc and self.pData.sDesc[1] and self.pData.sDesc[1].text ~= "nil" then
		self.pLbSecTitle:setString(self.pData.sDesc)
	end
	self.pData:resetSort()
	self.tConfLogList = self.pData.tConfLogList or self.tConfLogList

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
		local nCount = table.nums(self.tConfLogList)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemRegressGetReward.new()
			end
			pTempView:setCurData(self.tConfLogList[_index])
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
function ItemRegress:onDestroy(  )
end

-- 注册消息
function ItemRegress:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemRegress:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemRegress:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemRegress:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemRegress:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end


return ItemRegress