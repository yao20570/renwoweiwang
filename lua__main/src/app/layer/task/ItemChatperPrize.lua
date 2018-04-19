-----------------------------------------------------
-- author: xst
-- updatetime:  2017-12-29 16:05:40 
-- Description: 章节母包奖励
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")

local ItemChatperPrize = class("ItemChatperPrize", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemChatperPrize:ctor(  )
	-- body
	self:myInit()
	
	parseView("item_chatper_prize", handler(self, self.onParseViewCallback))
	
end

--初始化成员变量
function ItemChatperPrize:myInit( _bIsIndent )
	-- body
	self.tCurData 			= 	nil 				--当前数据
 
end

--解析布局回调事件
function ItemChatperPrize:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemChatperPrize",handler(self, self.onItemResPrizeDestroy))
end

--初始化控件
function ItemChatperPrize:setupViews( )
	-- body
	self.pLayCB = self:findViewByName("ly_cb")
	self.pLbTips = self:findViewByName("lb_tips")
	self.pLbTips:setString(getConvertedStr(3, 10486))

	self.pLbTitle = self:findViewByName("ly_title")
	self.pLayGoods = self:findViewByName("ly_list")

	self.pImgState = self:findViewByName("img_state")
	self.pImgState:setCurrentImage("#v2_fonts_yilingqu.png")

	self.pLyBtn = self:findViewByName("ly_btn")
	self.pBtnGet = getCommonButtonOfContainer(self.pLyBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(1, 10327), false)
	self.pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet:setBtnContentSize(100, 50)



	self.pLbTips = self:findViewByName("lb_tips")
	setTextCCColor(self.pLbTips, _cc.yellow)

	self.pImgGou =  MUI.MImage.new("#v2_img_jz_diana.png")	
	self.pLayCB:addView(self.pImgGou)
	centerInView(self.pLayCB, self.pImgGou)

	self.pImgMask = self:findViewByName("img_mask")
end

--领取奖励
function ItemChatperPrize:onGetClicked()
	--非完成状态
	if self.tCurData.nIsFinished ~= 1 then

		--跳转到任务界面		
		local tObject = {}
		tObject.nTaskID = self.tCurData.sTid --dlg类型
		tObject.chatper = true			
		sendMsg(ghd_task_goto_msg, tObject)
		return
	end
	SocketManager:sendMsg("getChapterTaskPrize", {self.tCurData.sTid}, function ( __msg )
			-- body
		-- dump(__msg, "getChapterPrize", 100)
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.getChapterTaskPrize.id then
				if __msg.body.o then
					--获取物品效果
					showGetAllItems(__msg.body.o)

				end	
			end
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
	end, -1)
end

-- 修改控件内容或者是刷新控件数据
function ItemChatperPrize:updateViews( )
	-- body
	local sDes =self.tCurData.sDes .. "(" .. self.tCurData.nCurNum.."/"..self.tCurData.nTargetNum .. ")"
	self.pLbTitle:setString(sDes)
	self:setGoodsListViewData(getDropById(self.tCurData.nDrop))

	--是否已经完成
	if self.tCurData.nIsFinished == 1 then
		self.pImgGou:setCurrentImage("#v2_img_jz_dianb.png")

		--是否已经领取奖励
		if self.tCurData.nGetPrizeState == 2 then
			self.pImgState:setVisible(true)
			self.pBtnGet:setVisible(false)
			self.pImgMask:setVisible(true)
		else
			self.pBtnGet:setVisible(true)
			self.pImgState:setVisible(false)
			self.pImgMask:setVisible(false)

			self.pBtnGet:updateBtnText(getConvertedStr(1, 10327))
			self.pBtnGet:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtnGet:setBtnContentSize(100, 50)
		end
	else
		self.pBtnGet:setVisible(true)
		self.pImgState:setVisible(false)
		self.pImgMask:setVisible(false)
		self.pBtnGet:updateBtnText(getConvertedStr(3, 10162))
		self.pBtnGet:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtnGet:setBtnContentSize(100, 50)
		
		self.pImgGou:setCurrentImage("#v2_img_jz_diana.png")
	end

	-- local icon = IconGoods.new(TypeIconGoods.NORMAL)
	-- icon:setCurData(self.tDropList[1])
	-- self.pLayGoods:addView(icon)
	-- self.pLayGoods:setScale(0.47)
end

--列表项回调
function ItemChatperPrize:onGoodsListViewCallBack( _index, _pView )
	-- body
	local tTempData = self.tDropList[_index]
    local pTempView = _pView
	if pTempView == nil then
		pTempView = IconGoods.new(TypeIconGoods.NORMAL)--HADMORE
		pTempView:setIconIsCanTouched(true)
		
	end
	pTempView:setCurData(tTempData) 

	pTempView:setMoreTextColor(getColorByQuality(tTempData.nQuality))
	pTempView:setNumber(tTempData.nCt)
	pTempView:setScale(0.47)
	pTempView:setContentSize(cc.size(108*0.47, 108*0.47))
    return pTempView
end

--设置数据
-- tDropList:List<Pair<Integer,Long>>
function ItemChatperPrize:setGoodsListViewData( tDropList )
	if not tDropList then
		return
	end
 	
	self.tDropList = tDropList
	local nCurrCount = #self.tDropList
	--容错
	if not self.pListView then
		local pLayGoods = self.pLayGoods
		self.pListView = MUI.MListView.new {
		     	viewRect   = cc.rect(0, 0, pLayGoods:getContentSize().width, pLayGoods:getContentSize().height),
		        direction  = MUI.MScrollView.DIRECTION_HORIZONTAL,
		        itemMargin = {left = 5,
		            right =  6,
		            top = 12,
		            bottom = 0},
		}
		pLayGoods:addView(self.pListView)
		centerInView(pLayGoods, self.pListView )
		self.pListView:setItemCallback(handler(self, self.onGoodsListViewCallBack))
		self.pListView:setItemCount(nCurrCount)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nCurrCount)
		local oldY = self.pListView.container:getPositionY()
		self.pListView:scrollTo(0, oldY, false)
	end

end

-- 析构方法
function ItemChatperPrize:onItemResPrizeDestroy(  )
	-- body
end

function ItemChatperPrize:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end
 
return ItemChatperPrize