----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2018-01-19 17:10:45
-- Description: 特惠礼包界面(送审)
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemActNanBeiWarContent = require("app.layer.activitya.ItemActNanBeiWarContent")
local ItemPacketGiftGetReward =  require("app.layer.activitya.packetgift.ItemPacketGiftGetReward")
local ItemPacketGiftAct = class("ItemPacketGiftAct", function()
	return ItemActNanBeiWarContent.new()
end)

--创建函数
function ItemPacketGiftAct:ctor()
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemPacketGiftAct",handler(self, self.onItemPacketGiftActDestroy))	
end

--初始化控件
function ItemPacketGiftAct:setupViews( )
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
function ItemPacketGiftAct:updateViews( )
	if not self.pData then
		return
	end

	--时间
	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle, self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	self.tPacketsList = self.pData.tAllPackets
	if self.tPacketsList and table.nums(self.tPacketsList) > 0 then

		if not self.pListView then
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
			    	pTempView   = ItemPacketGiftGetReward.new()
				end
				pTempView:setData(self.tPacketsList[_index])
			    return pTempView
			end)
			self.pListView:setItemCount(table.nums(self.tPacketsList))
			--上下箭头
			local pUpArrow, pDownArrow = getUpAndDownArrow()
			self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
			self.pListView:reload()
		else
			--更新列表数据
			self.pListView:notifyDataSetChange(true)
		end
	end

end

--析构方法
function ItemPacketGiftAct:onItemPacketGiftActDestroy(  )
	self:onPause()
end

-- 注册消息
function ItemPacketGiftAct:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.refreshPackets))
end

-- 注销消息
function ItemPacketGiftAct:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemPacketGiftAct:onResume(  )
	self:regMsgs()
end

function ItemPacketGiftAct:onPause(  )
	self:unregMsgs()
end

--设置数据 _data
function ItemPacketGiftAct:setData(_tData)

	self.pData = _tData or {}
	self:updateViews()
end

--刷新数据
function ItemPacketGiftAct:refreshPackets()
	self.pData = Player:getActById(e_id_activity.packetgift)
	self:updateViews()
end



return ItemPacketGiftAct