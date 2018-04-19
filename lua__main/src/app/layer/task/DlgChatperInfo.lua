-----------------------------------------------------
-- author: xiesite
-- Date: 2018-1-05 16:24:47
-- Description: 选择上阵武将界面
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemChatperPrize = require("app.layer.task.ItemChatperPrize")

local DlgChatperInfo = class("DlgChatperInfo", function()
	return DlgCommon.new(e_dlg_index.chatperInfo)
end)

function DlgChatperInfo:ctor(_tData)
	-- body
	self:myInit()
	self.tData = _tData

	self:setImgTitle()
	-- self:setTitle(self.tData.sName)
	parseView("dlg_chatper_info", handler(self, self.onParseViewCallback))

end

--初始化成员变量
function DlgChatperInfo:myInit(  )
	-- body
	self.tData = {} --章节数据
	-- self.tTitles 		=	
end

--解析布局回调事件
function DlgChatperInfo:onParseViewCallback( pView )
	-- body
	--ipad的暂时的特殊处理
	if getIsTargetPad() then
		pView:setContentSize(cc.size( pView:getContentSize().width, 568))
	end
	self.pSelectView = pView
	self:addContentView(pView,false) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgChatperInfo",handler(self, self.onDestroy))
end

 

--对显示的章节进行排位
function DlgChatperInfo:sortHeroList(_heroList)
 
end


--初始化控件
function DlgChatperInfo:setupViews( )
	self.pImgTitle = self:findViewByName("img_title")
	self.pLbDes = self:findViewByName("lb_des")
	self.pLbPrizeTitle = self:findViewByName("lb_prize_title")
	self.pLbPrizeTitle:setString(getConvertedStr(1,10326))

	self.pLyTop =  self:findViewByName("ly_top")
	self.pLayContent = self:findViewByName("ly_center")
	if getIsTargetPad() then
		self.pLayContent:setContentSize(cc.size(self.pLayContent:getContentSize().width, self.pLayContent:getContentSize().height - 192))
		self.pLyTop:setPositionY(self.pLyTop:getPositionY() - 192)
	end

	self.pImg1 = self:findViewByName("img_1")
	self.pImg1:setFlippedX(true)

	self.pLayGoods = self:findViewByName("ly_itemList")
	self.pLyBtn = self:findViewByName("ly_btn")
	self.pLyBtn:setPositionX(self.pLyBtn:getPositionX() - 17)
	self.pBtnGet = getCommonButtonOfContainer(self.pLyBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(1, 10327))
	self.pBtnGet:onCommonBtnClicked(handler(self, self.onGetClicked))
	self.pBtnGet:setBtnContentSize(100, 50)

	self.pImgTop = self:findViewByName("img_top")
	self.pImgTop:setScale(1.5)
end

function DlgChatperInfo:onGetClicked()
	if not self.tData:canGetReward() then
		if self.tData.nIsGetPrize == 1 then
			TOAST(getConvertedStr(1, 10329))
		elseif self.tData.nIsGetPrize == 0 then
			TOAST(getConvertedStr(1, 10328))
		end
		return
	end
	-- getChapterPrize
	SocketManager:sendMsg("getChapterPrize", {}, function ( __msg )
			-- body
		-- dump(__msg, "getChapterPrize", 100)
		if  __msg.head.state == SocketErrorType.success then 
			if __msg.head.type == MsgType.getChapterPrize.id then
				if __msg.body.o then
					--获取物品效果
					-- local tDataList = {}
					-- for k,v in pairs(__msg.body.o) do
					-- 	local tReward = {}
					-- 	tReward.d = {}
					-- 	tReward.g = {}
					-- 	table.insert(tReward.d, copyTab(v))
					-- 	table.insert(tReward.g, copyTab(v))
					-- 	table.insert(tDataList,tReward)
					-- end
					
					--打开招募展示英雄对话框
				    -- local tObject = {handler(self, self.onItemTabClicked)}
				    -- tObject.nType = e_dlg_index.showheromansion --dlg类型
				    -- tObject.nRHandler = function()
				    -- 	local oldChatper = Player:getPlayerTaskInfo():getOldChatperTask()
				    -- 	oldChatper:showDialog(2)
				    -- end
				    -- tObject.tReward = tDataList
				    -- tObject.bHideGo = true
				    -- sendMsg(ghd_show_dlg_by_type,tObject)
				    showGetAllItems(__msg.body.o)

			        doDelayForSomething(RootLayerHelper:getCurRootLayer(), function (  )
						local oldChatper = Player:getPlayerTaskInfo():getOldChatperTask()
						if oldChatper then
							oldChatper:showDialog(2)
						end
			        end, 0.2 )
				    closeDlgByType(e_dlg_index.chatperInfo, false)
				end	
			end
		else
		    TOAST(SocketManager:getErrorStr(__msg.head.state))
		end
	end, -1)
end
 
 
--接收服务端发回的登录回调
function DlgChatperInfo:onGetDataFunc( __msg )
 
end

-- 修改控件内容或者是刷新控件数据
function DlgChatperInfo:updateViews(  )
	-- self.pLbTitle:setString(self.tData.sName)
	self.pLbNum:setString(self.tData.sTid - 1)
	self.pImgTitle:setCurrentImage("#v2_fonts_zjt_"..self.tData.sTid ..".png")
	self.pLbDes:setString(self.tData.sDes)

	self:setGoodsListViewData(getDropById(self.tData.nDrop))
	--更新列表数据
	if not self.pItemListView then
		--列表
		local pSize = self.pLayContent:getContentSize()
		self.pItemListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  0, 
	            bottom =  0},
	    }
	    self.pLayContent:addView(self.pItemListView)
		local nCount = table.nums(self.tData:getTargets())

		self.pItemListView:setItemCount(nCount)
		self.pItemListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemChatperPrize.new()
			end
			pTempView:setCurData(self.tData:getTargets()[_index])
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pItemListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pItemListView:reload()
	else
		self.pItemListView:notifyDataSetChange(true)
	end

	--是否可以领取奖励
	if self.tData:canGetReward() then
		self.pBtnGet:setToGray(false)
	else
		self.pBtnGet:setToGray(true)
	end
end


--列表项回调
function DlgChatperInfo:onGoodsListViewCallBack( _index, _pView )
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
	pTempView:setScale(0.62)

    return pTempView
end

--设置数据
-- tDropList:List<Pair<Integer,Long>>
function DlgChatperInfo:setGoodsListViewData( tDropList )
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
		            right =  -28,
		            top = 22,
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
function DlgChatperInfo:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgChatperInfo:regMsgs( )
	-- body
	regMsg(self, gud_refresh_task_msg, handler(self, self.setCurData))	
end

function DlgChatperInfo:setCurData( )
	self.tData = Player:getPlayerTaskInfo():getChatperTask()
	self:updateViews()
end


-- 注销消息
function DlgChatperInfo:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_task_msg)
end


--暂停方法
function DlgChatperInfo:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgChatperInfo:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--标题重设
function DlgChatperInfo:setImgTitle( )
	self.pLbTitle:setVisible(false)
	local pImgTitle = MUI.MImage.new("#v2_fonts_djz_2.png")
	pImgTitle:setScale(0.5)
	self.pLayTop:addView(pImgTitle, 10)
	pImgTitle:setPosition(cc.p(280,30))

	self.pLbNum = MUI.MLabelAtlas.new({text="0", 
	png="ui/atlas/v2_fonts_djz_1z6.png", pngw=66, pngh=66, scm=48})
	self.pLbNum:setScale(0.5)
 	self.pLbNum:setPosition(cc.p(280,30))
 	self.pLayTop:addView(self.pLbNum)
end

return DlgChatperInfo