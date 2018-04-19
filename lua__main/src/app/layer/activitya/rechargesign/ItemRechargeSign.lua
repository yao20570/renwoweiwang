--
-- Author: luwenjing
-- Date: 2017-12-22 12:57:50
--充值签到

local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemRebateReward =  require("app.layer.activitya.dayrebate.ItemRebateReward")
local ItemRechargeSignReward =  require("app.layer.activitya.rechargesign.ItemRechargeSignReward")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemRechargeSign = class("ItemRechargeSign", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemRechargeSign:ctor()
	self.tAllAwdInfo = {}
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemRechargeSign",handler(self, self.onDestroy))	
end

--初始化控件
function ItemRechargeSign:setupViews( )

	-- --去充值按钮
	-- local pLayBtn = self:findViewByName("lay_btn")
	-- self.pBtnConsume = getCommonButtonOfContainer(pLayBtn,TypeCommonBtn.L_YELLOW, getConvertedStr(8, 10001))
	-- self.pBtnConsume:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBottom})
	self.pImgLabel:setImg("#v1_img_qianbi.png", 1, "right")
	self.pImgLabel:followPos("center", 251, 140, 10)
	self.pLayDesc:setVisible(true)
	
	self.tRewardList={}
end

--更新
function ItemRechargeSign:updateViews( )
	if not self.pData then
		return
	end
	-- -- self:setBannerImg("#")
	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	else
		self.pItemTime:setCurData(self.pData)
	end

	self:setDesc(self.pData.sDesc)
	--if self.pData.sDesc then
	--	self.pLbDescCn:setString(self.pData.sDesc)
	--end
	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end

	local tTempList = {}
	self.pData:resetSort()		--重新排序
	if self.pData.nF == 0 then  --免费奖励未领 免费的放前面
		table.insert(tTempList,self.pData)
		for i=1,#self.pData.tSis do
			local v=self.pData.tSis[i]
			table.insert(tTempList,v)
		end
	else
		for i=1,#self.pData.tSis do
			local v=self.pData.tSis[i]

			table.insert(tTempList,v)
		end
		table.insert(tTempList,self.pData)
	end
	self.tRewardList = tTempList or self.tRewardList

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
	    -- self.tRewardList=self.pData.tSis
	    self.pLayContent:addView(self.pListView)
		local nCount = #self.tRewardList
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 

		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemRechargeSignReward.new()
			end
			if self.pData.nF == 0 then  --免费奖励未领取
				if _index == 1 then
					pTempView:setData(self.tRewardList[_index],1)
				else
					pTempView:setData(self.tRewardList[_index],2)
				end
			else
				if _index == nCount then
					pTempView:setData(self.tRewardList[_index],1)
				else
					pTempView:setData(self.tRewardList[_index],2)
				end
			end
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
function ItemRechargeSign:onDestroy(  )
end

-- 注册消息
function ItemRechargeSign:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateData))
end

-- 注销消息
function ItemRechargeSign:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemRechargeSign:onResume(  )
	self:regMsgs()
end

function ItemRechargeSign:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemRechargeSign:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end

function ItemRechargeSign:updateData(  )
	-- body
	local tActData = Player:getActById(e_id_activity.rechargesign)
	if tActData then
		self:setData(tActData)

	end

end

return ItemRechargeSign