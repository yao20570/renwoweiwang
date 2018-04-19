----------------------------------------------------- 
-- author: luwenjing
-- updatetime: 2018-01-26 10:34:57
-- Description: 福星高照（排行榜）
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemLuckyStarRank = require("app.layer.activityb.luckystar.ItemLuckyStarRank")

local LuckyStarRank = class("LuckyStarRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function LuckyStarRank:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("lucky_star_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LuckyStarRank:onParseViewCallback( pView )
	-- self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LuckyStarRank", handler(self, self.onLuckyStarRankDestroy))

end

function LuckyStarRank:myInit(  )
	-- body
	self.tRankList = {}
	self.bIsAskingData=false
end

-- 析构方法
function LuckyStarRank:onLuckyStarRankDestroy(  )
    self:onPause()
    sendMsg(ghd_clear_rankinfo_msg)
end

function LuckyStarRank:regMsgs(  )
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateViews))
end

function LuckyStarRank:unregMsgs(  )
	unregMsg(self, gud_refresh_rankinfo)
end

function LuckyStarRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function LuckyStarRank:onPause(  )
	self:unregMsgs()
end

function LuckyStarRank:setupViews(  )
	self.pTxtDesc= self:findViewByName("txt_desc")
	self.pTxtDesc:setString(getConvertedStr(9,10145))
	-- self.pImgBx:setViewTouched(true)
	-- self.pImgBx:setIsPressedNeedColor(false)
	-- self.pImgBx:onMViewClicked(handler(self, self.onGetDailyReward))

	self.pTxtRank= self:findViewByName("txt_rank")
	self.pTxtCountry= self:findViewByName("txt_country")
	self.pTxtName= self:findViewByName("txt_name")
	self.pTxtPoint= self:findViewByName("txt_point")

	self.pTxtRank:setString(getConvertedStr(9,10135))
	self.pTxtCountry:setString(getConvertedStr(9,10136))
	self.pTxtName:setString(getConvertedStr(9,10137))
	self.pTxtPoint:setString(getConvertedStr(9,10138))
	
	self.pLayList= self:findViewByName("lay_list")

	self.pTxtMyPoint = self:findViewByName("txt_my_point")
	self.pTxtMyRank = self:findViewByName("txt_my_rank")
	self.pTxtTip = self:findViewByName("txt_tip")
	self.pTxtTip:setString(getConvertedStr(3,10727))

end

function LuckyStarRank:updateViews(  )
	

	local tActData=Player:getActById(e_id_activity.luckystar)
	if not tActData then
		return
	end
	
	self.pTxtMyPoint:setString(string.format(getConvertedStr(9,10132) ,tActData.nF))

	self.tRankList = Player:getRankInfo():getRankDataList()
	if not self.tRankList then
		return 
	end
	-- --更新列表数据
	if not self.pListView then
		--列表
		local pSize = self.pLayList:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {
				left   = 20,
	            right  = 0,
	            top    = 0, 
	            bottom = 10}
	    }
	    self.pLayList:addView(self.pListView)
		local nCount = table.nums(self.tRankList)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemLuckyStarRank.new()
			end
			pTempView:setData(self.tRankList[_index])
		    return pTempView
		end)

		self.pListView:onScroll(function ( event )
	    	-- body
	    	if event.name == "scrollToFooter" then--当列表滑动到底部的时候启动申请请求
	    		self:onLoadRank()
	    	end
	    end)
	    local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)

		self.pListView:reload()
	else
		self.pListView:notifyDataSetChange(true,table.nums(self.tRankList))
	end
	--
	-- --我的排名
	local tMyRank = Player:getRankInfo():getMyRankInfo()
	if tMyRank then
		if tMyRank.x == 0 then  --未上榜
			local tStr = {
			    {color=_cc.pwhite,text= getConvertedStr(3, 10495) },
			    {color=_cc.white,text=getConvertedStr(3, 10303)},
			}
			self.pTxtMyRank:setString(tStr)
			
		else
			local tStr = {
			    {color=_cc.pwhite,text= getConvertedStr(3, 10495) },
			    {color=_cc.white,text=tostring(tMyRank.x)},
			}
			self.pTxtMyRank:setString(tStr)
		end
	end
end

function LuckyStarRank:onLoadRank(  )
	-- body
	local nnextPage = Player:getRankInfo().nCurrPage + 1
    self:sendGetRankDataRequest(nnextPage)	
end

function LuckyStarRank:sendGetRankDataRequest( npage )
	-- body
	local nCurtype = getRankTypeByActType(e_id_activity.luckystar)
	if not nCurtype then
		return 
	end	
	local npag = npage or 1
	local iscanask = Player:getRankInfo():isCanAskForNextPag(nCurtype)
	if self.bIsAskingData == true or iscanask == false then--判断是否正在请求数据
		return
	end
	self.bIsAskingData = true
	SocketManager:sendMsg("getRankData", {nCurtype, npag, 15}, handler(self, self.getRankRequestCakkBack))
end

--网络请求回到
function LuckyStarRank:getRankRequestCakkBack(__msg)
	-- body
	--dump(__msg.body, "__msg.body",10)
	self.bIsAskingData = false--请求返回，结束正在请求的状态
	if __msg.head.state == SocketErrorType.success	then				
		--请求成功
	else		
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end


return LuckyStarRank



