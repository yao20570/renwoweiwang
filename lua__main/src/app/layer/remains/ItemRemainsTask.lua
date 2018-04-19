----------------------------------------------------- 
-- author: maheng
-- updatetime:  2018-3-2 11:55:23 星期五
-- Description: 韬光养晦任务
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemRemainsTask = class("ItemRemainsTask", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemRemainsTask:ctor(  )
	--解析文件
	parseView("item_remains_task", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemRemainsTask:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemRemainsTask", handler(self, self.onDestroy))
end

-- 析构方法
function ItemRemainsTask:onDestroy(  )
end

function ItemRemainsTask:setupViews(  )
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLayRewards = self:findViewByName("lay_rewards")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pImgFlag = self:findViewByName("img_flag")

	self.pGetBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10189))
	self.pGetBtn:onCommonBtnClicked(handler(self, self.onGetRewards))	

	local tBtnTable = {}
	--文本
	tBtnTable.tLabel = {
		{getConvertedStr(6, 10655),getC3B(_cc.pwhite)},
		{"0",getC3B(_cc.green)},
		{"/",getC3B(_cc.pwhite)},
		{"0",getC3B(_cc.pwhite)},
	}
	self.pBtnExText = self.pGetBtn:setBtnExText(tBtnTable)
end

function ItemRemainsTask:updateViews()
	-- body
	--gRefreshHorizontalList()
	local pData = self.pData	
	self.pLbTitle:setString(pData.sTitle, false)

	self.pBtnExText:setLabelCnCr(2, pData.nNum)
	self.pBtnExText:setLabelCnCr(4, pData.nTargetNum)

	local tDrops = getDropById(pData.nDropID)
	if tDrops and #tDrops > 0 then
		table.sort(tDrops, function(a, b)
			return a.nQuality > b.nQuality
		end)
	end
	gRefreshHorizontalList(self.pLayRewards, tDrops)
	if pData.bGet then--已领取
		self.pImgFlag:setVisible(true)
		self.pGetBtn:setVisible(false)
		self.pBtnExText:setVisible(false)
	else		
		self.pImgFlag:setVisible(false)
		self.pGetBtn:setVisible(true)
		self.pBtnExText:setVisible(true)
		if pData.bFinished then --已完成 
			self.pGetBtn:setButton(TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10189))  --领取
		else
			self.pGetBtn:setButton(TypeCommonBtn.M_BLUE, getConvertedStr(6, 10216))     --前往
		end
	end

end
--领取奖励
function ItemRemainsTask:onGetRewards(  )
	-- body
	if not self.pData then
		return
	end
	local pData = self.pData	
	if pData.bFinished then
		SocketManager:sendMsg("reqTGYHReward", {pData.nId}, function(__msg, __oldMsg)
			if __msg.body then
				--奖励动画展示
				showGetAllItems(__msg.body.ob, 1)
			end
		end)
	else
		--切换世界地图
		sendMsg(ghd_home_show_base_or_world, 2)
    	--关闭活动a界面
    	closeDlgByType( e_dlg_index.dlgremains, false)
	end
end

function ItemRemainsTask:setData( _tData )
	-- body
	if not _tData then
		return
	end
	self.pData = _tData
	self:updateViews()
end
return ItemRemainsTask


