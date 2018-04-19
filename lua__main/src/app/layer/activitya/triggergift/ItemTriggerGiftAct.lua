----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-12-28 20:53:00
-- Description: 触发式礼包界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemTriggerGiftGetReward =  require("app.layer.activitya.triggergift.ItemTriggerGiftGetReward")
local ItemTriggerGiftAct = class("ItemTriggerGiftAct", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemTriggerGiftAct:ctor()
	--cd2的数据
	self.tTriGiftList = Player:getTriggerGiftData():getTpackListInCd2()
	self.tCurrTGiftData = self.tTriGiftList[1]

	self:setupViews()
	--self:updateViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemTriggerGiftAct",handler(self, self.onItemTriggerGiftActDestroy))	
end

--初始化控件
function ItemTriggerGiftAct:setupViews( )
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
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pTempView = _pView
	    if pTempView == nil then
	    	pTempView   = ItemTriggerGiftGetReward.new()
		end
		pTempView:setData(self.tTriGiftList[_index])
	    return pTempView
	end)
	self.pListView:setItemCount(0)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	self.pListView:reload() 

	self.pLbSecTitle:setString(getConvertedStr(3, 10576))

	self.pLbSecTitle:setAnchorPoint(0.5, 0.5)
	self.pLbSecTitle:setPositionX(self.pLySecTitle:getContentSize().width/2)

	--
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.thlb)	

	local pLayDesc = MUI.MLayer.new()
	pLayDesc:setBackgroundImage("#v1_img_black50.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})
	pLayDesc:setLayoutSize(524, 60)
	self.pLayBannerBg:addView(pLayDesc,11)

	--创建多行文本
	local pTxtDesc = MUI.MLabel.new({
	            text = getTipsByIndex(20089),
	            size = 20,
	            anchorpoint = cc.p(0.5, 0.5),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            valign = cc.ui.TEXT_VALIGN_TOP,
	            color = cc.c3b(255, 255, 255),
	            dimensions = cc.size(600, 0),
	        })
	pTxtDesc:setPosition(524/2,60/2)
	pLayDesc:addView(pTxtDesc)
end

--更新
function ItemTriggerGiftAct:updateViews( )
	if not self.tTriGiftList then
		return
	end

	--剩余时间按最晚消失的礼包取
	--时间
	if self.tCurrTGiftData then
		if not self.pItemTime then
			self.pItemTime = createActTime(self.pLyTitle,self.tCurrTGiftData,cc.p(0,170))
		else
			self.pItemTime:setCurData(self.tCurrTGiftData)
		end
	end

	--更新列表数据
	self.pListView:notifyDataSetChange(true, #self.tTriGiftList)
end

--析构方法
function ItemTriggerGiftAct:onItemTriggerGiftActDestroy(  )
end

-- 注册消息
function ItemTriggerGiftAct:regMsgs( )
	regMsg(self, gud_trigger_gift_list_refresh, handler(self, self.setData))
end

-- 注销消息
function ItemTriggerGiftAct:unregMsgs(  )
	unregMsg(self, gud_trigger_gift_list_refresh)
end


function ItemTriggerGiftAct:onResume(  )
	self:regMsgs()
end

function ItemTriggerGiftAct:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemTriggerGiftAct:setData( )
	--保存已买的
	local tBoughtList = {}
	for i=1,#self.tTriGiftList do
		if self.tTriGiftList[i].bIsTake then
			table.insert(tBoughtList, self.tTriGiftList[i])
		end
	end

	--添加新的列表
	self.tTriGiftList = {}
	local tTriGiftListNew = Player:getTriggerGiftData():getTpackListInCd2()
	if tTriGiftListNew then
		self.tTriGiftList = tTriGiftListNew
	end

	for i=1,#tBoughtList do
		table.insert(self.tTriGiftList, tBoughtList[i])
	end

	self.tCurrTGiftData = self.tTriGiftList[1]

	--
	self:updateViews()
end



return ItemTriggerGiftAct