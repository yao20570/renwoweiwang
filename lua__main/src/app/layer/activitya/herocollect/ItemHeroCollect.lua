----------------------------------------
-- Author: luwenjing
-- Date: 2018-02-28 17:24:50
--武将收集界面
----------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemHeroCollectReward =  require("app.layer.activitya.herocollect.ItemHeroCollectReward")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemHeroCollect = class("ItemHeroCollect", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemHeroCollect:ctor()
	self.tAllAwdInfo = {}
	self:setupViews()
	self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemHeroCollect",handler(self, self.onDestroy))	
end

--初始化控件
function ItemHeroCollect:setupViews( )

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
function ItemHeroCollect:updateViews( )
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

	self.tRewardList = self.pData.tTs

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
		    	pTempView   = ItemHeroCollectReward.new()
			end
			pTempView:setData(self.tRewardList[_index],1)
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
function ItemHeroCollect:onDestroy(  )
end

-- 注册消息
function ItemHeroCollect:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateData))
end

-- 注销消息
function ItemHeroCollect:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemHeroCollect:onResume(  )
	self:regMsgs()
end

function ItemHeroCollect:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemHeroCollect:setData(_tData)
	if not _tData then
		return
	end
	self:setCurData(_tData)
	self:updateViews()
end

function ItemHeroCollect:updateData(  )
	-- body
	local tActData = Player:getActById(e_id_activity.herocollect)
	if tActData then
		self:setData(tActData)

	end

end

return ItemHeroCollect