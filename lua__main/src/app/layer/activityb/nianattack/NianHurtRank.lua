----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-01-26 19:10:21
-- Description: 年兽来袭 排行榜
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemNianHurtRank = require("app.layer.activityb.nianattack.ItemNianHurtRank")

local NianHurtRank = class("NianHurtRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function NianHurtRank:ctor( _tSize )
	--解析文件
	self:setContentSize(_tSize)
	parseView("lay_nian_rank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NianHurtRank:onParseViewCallback( pView )
	-- self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NianHurtRank", handler(self, self.onNianHurtRankDestroy))

end

-- 析构方法
function NianHurtRank:onNianHurtRankDestroy(  )
    self:onPause()
    sendMsg(ghd_clear_rankinfo_msg)
end

function NianHurtRank:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

function NianHurtRank:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

function NianHurtRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function NianHurtRank:onPause(  )
	self:unregMsgs()
end

function NianHurtRank:setupViews(  )
	self.pLayList = self:findViewByName("lay_listview")

	--国家图标
	self.pImgCountry1 = self:findViewByName("img_country1")
	self.pImgCountry2 = self:findViewByName("img_country2")
	self.pImgCountry3 = self:findViewByName("img_country3")

	--国家积分
	self.pTxtScore1 = self:findViewByName("txt_score1")
	self.pTxtScore2 = self:findViewByName("txt_score2")
	self.pTxtScore3 = self:findViewByName("txt_score3")

	self.pTxtMyRank = self:findViewByName("txt_my_rank")
	self.pTxtMyHurt = self:findViewByName("txt_my_hurt")

	local pTxtSubTilte1 = self:findViewByName("txt_sub_tilte1")
	pTxtSubTilte1:setString(getConvertedStr(3, 10719))
	local pTxtSubTilte2 = self:findViewByName("txt_sub_tilte2")
	pTxtSubTilte2:setString(getConvertedStr(3, 10720))
	local pTxtSubTilte3 = self:findViewByName("txt_sub_tilte3")
	pTxtSubTilte3:setString(getConvertedStr(3, 10484))
	local pTxtSubTilte4 = self:findViewByName("txt_sub_tilte4")
	pTxtSubTilte4:setString(getConvertedStr(3, 10721))

	local pTxtRewardTip = self:findViewByName("txt_reward_tip")
	pTxtRewardTip:setString(getConvertedStr(3, 10722))

	local pTxtBottomTip = self:findViewByName("txt_bottom_tip")
	pTxtBottomTip:setString(getConvertedStr(3, 10727))
end

function NianHurtRank:reqPlayerHurtRank(  )
	--刷新排行榜
	self:refreshRankData(e_rank_type.ac_nian, 1, handler(self, self.updateRankInfo))
end

function NianHurtRank:reqCountryHurtRank(  )
	SocketManager:sendMsg("reqCountryNianHurt", {}, function ( __msg )
		if  __msg.head.state == SocketErrorType.success then 
            if __msg.head.type == MsgType.reqCountryNianHurt.id then
            	if self.updateCountryRank then
            		self:updateCountryRank(__msg.body.cr)
            	end
            end
        else
            TOAST(SocketManager:getErrorStr(__msg.head.state))
        end
	end)
end

function NianHurtRank:updateViews(  )
    --我的伤害
	local pActData = Player:getActById(e_id_activity.nianattack)
	if pActData then
		local nHarm = pActData:getMyHarm()
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10718)},
		    {color=_cc.white,text=getResourcesStr(nHarm)}, 
		}
		self.pTxtMyHurt:setString(tStr)
	end
end

function NianHurtRank:updateCountryRank( tRank )
	local tData = {
		{k = 1, v = 0},
		{k = 2, v = 0},
		{k = 3, v = 0},
	}
	if tRank then
		for i=1,#tRank do
			for j=1,#tData do
				if tData[j].k == tRank[i].k then
					tData[j].v = tRank[i].v
					break
				end
			end
		end
	end
	table.sort(tData, function(a, b)
		return a.v > b.v
	end)
	local tFontImg = {
		[e_type_country.shuguo] = "#v2_fonts_han.png",
		[e_type_country.weiguo] = "#v2_fonts_qin.png",
		[e_type_country.wuguo] = "#v2_fonts_chu.png",
	}
	if tData[1] then
		local nCountry, nScore = tData[1].k, tData[1].v
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10494)},
		    {color=_cc.white,text=getResourcesStr(nScore)}, 
		}
		self.pTxtScore1:setString(tStr)

		local sImgStr = tFontImg[nCountry]
		if sImgStr then
			self.pImgCountry1:setCurrentImage(sImgStr)
		end
	end

	if tData[2] then
		local nCountry, nScore = tData[2].k, tData[2].v
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10494)},
		    {color=_cc.white,text=getResourcesStr(nScore)}, 
		}
		self.pTxtScore2:setString(tStr)

		local sImgStr = tFontImg[nCountry]
		if sImgStr then
			self.pImgCountry2:setCurrentImage(sImgStr)
		end
	end

	if tData[3] then
		local nCountry, nScore = tData[3].k, tData[3].v
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10494)},
		    {color=_cc.white,text=getResourcesStr(nScore)}, 
		}
		self.pTxtScore3:setString(tStr)

		local sImgStr = tFontImg[nCountry]
		if sImgStr then
			self.pImgCountry3:setCurrentImage(sImgStr)
		end
	end
end

function NianHurtRank:updateListView(  )
	if not self.tListData then
		return
	end
	local nCnt = #self.tListData
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  0},
            direction = MUI.MScrollView.DIRECTION_VERTICAL or _direction ,--listView方向            
        }
        self.pLayList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemNianHurtRank.new()  
		        pTempView:setHandler(handler(self, self.onRankItemClick))
		    end
		    pTempView:setCurData(self.tListData[_index])
		    return pTempView
		end)	
		self.pListView:onScroll(function ( event )
	    	-- body
	    	if event.name == "scrollToFooter" then--当列表滑动到底部的时候启动申请请求
	    		local nnextPage = Player:getRankInfo().nCurrPage + 1
		    	self:refreshRankData(e_rank_type.ac_nian, nnextPage, handler(self, self.updateRankInfo))
	    	end
	    end)		
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(nCnt)
		self.pListView:reload(false)		
	else
		self.pListView:notifyDataSetChange(false, nCnt)		
	end
end

function NianHurtRank:refreshRankData( _nType, _npag, handler )
	-- body
 	local nCurRank = Player:getRankInfo().nRankType
	local iscanask = Player:getRankInfo():isCanAskForNextPag(_nType)
	local nPage = _npag or 1
	if self.bIsAskingData == true or iscanask == false then--判断是否正在请求数据
		if nPage == 1 and nCurRank == _nType and handler then--当前已有数据且不翻页的情况下直接刷新数据
			handler()
		end
		return
	end
	-- dump({_nType, nPage, 20}, "_nType, nPage, 20=", 100)
	self.bIsAskingData = true
	SocketManager:sendMsg("getRankData", {_nType, nPage, 20}, function ( __msg )
		if handler then
			handler()
		end		
		self.bIsAskingData = false
	end)
	-- end
end

function NianHurtRank:updateRankInfo( )
	self.tListData = Player:getRankInfo():getRankDataList()
	local tRankInfo = Player:getRankInfo()
	if tRankInfo then
		local nMyRank = tRankInfo.nMyRank
		if nMyRank then
			local sScore = ""
			if nMyRank <= 0 then --未上榜
				sScore = getConvertedStr(3, 10303)
			else
				sScore = tostring(nMyRank)
			end
			local tStr = {
			    {color=_cc.pwhite,text=getConvertedStr(3, 10495)},
			    {color=_cc.white,text=sScore}, 
			}
			self.pTxtMyRank:setString(tStr)
		end
	end
	self:updateListView()
end

function NianHurtRank:onRankItemClick( _tData )
	if not _tData then
		return
	end
	local pMsgObj = {}
	pMsgObj.nplayerId = _tData["i"]
	pMsgObj.bToChat = false
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)
end

return NianHurtRank


