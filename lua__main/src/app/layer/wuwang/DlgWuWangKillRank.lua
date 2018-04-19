----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 15:17:21
-- Description: 武王击杀排行榜
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemWuWangKillRank = require("app.layer.wuwang.ItemWuWangKillRank")
local DlgWuWangKillRank = class("DlgWuWangKillRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function DlgWuWangKillRank:ctor( _tSize )
    self:setContentSize(_tSize)
	parseView("dlg_wuwangkillrank", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgWuWangKillRank:onParseViewCallback( pView )
	--self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgWuWangKillRank",handler(self, self.onDlgWuWangKillRankDestroy))

	--请求积分信息
	SocketManager:sendMsg("reqWuWangCountryScore", {}, handler(self, self.onRspWuWangCountryScore))
end

-- 析构方法
function DlgWuWangKillRank:onDlgWuWangKillRankDestroy(  )
    self:onPause()
    --清容列表数据
    sendMsg(ghd_clear_rankinfo_msg)
end

function DlgWuWangKillRank:regMsgs(  )
	regMsg(self, gud_refresh_rankinfo, handler(self, self.updateRankListView))
end

function DlgWuWangKillRank:unregMsgs(  )
	unregMsg(self, gud_refresh_rankinfo)
end

function DlgWuWangKillRank:onResume(  )
	self:regMsgs()

	
	self:updateViews()
end

function DlgWuWangKillRank:onPause(  )
	self:unregMsgs()
end

function DlgWuWangKillRank:setupViews(  )
	--国家图标
	self.pImgCountry1 = self:findViewByName("img_country1")
	self.pImgCountry2 = self:findViewByName("img_country2")
	self.pImgCountry3 = self:findViewByName("img_country3")

	--国家积分
	self.pTxtScore1 = self:findViewByName("txt_score1")
	self.pTxtScore2 = self:findViewByName("txt_score2")
	self.pTxtScore3 = self:findViewByName("txt_score3")

	local pTxtTip1 = self:findViewByName("txt_tip1")
	pTxtTip1:setString(getTipsByIndex(20037))

	--截取字符串
	-- local function SubUTF8String( s,n )
	-- 	-- body
	-- 	local dropping = string.byte(s, n+1)    
	-- 	if not dropping then return s end    
	-- 	if dropping >= 128 and dropping < 192 then    
	-- 	    return SubUTF8String(s, n-1)    
	-- 	end    
	-- 	return string.sub(s, 1, n)    
	-- end
	local str=getTipsByIndex(20038)
	-- local str1 = SubUTF8String(str,80)
	-- local str2=string.sub(str,string.len(str1)+1)

	local pTxtTip2 = self:findViewByName("txt_tip2")
	pTxtTip2:setString(str)

	-- local pTxtTip2_2=self:findViewByName("txt_tip2_1")
	-- pTxtTip2_2:setString(str2) 

	
	local pTxtMyCountry = self:findViewByName("txt_my_country")
	pTxtMyCountry:setString(getCountryShortName(Player:getPlayerInfo().nInfluence,true) .. getConvertedStr(3, 10482))

	self.pTxtMyRank = self:findViewByName("txt_my_rank")
	self.pTxtMyPoint = self:findViewByName("txt_my_point")

	local pTxtSubTilte1 = self:findViewByName("txt_sub_tilte1")
	pTxtSubTilte1:setString(getConvertedStr(3, 10483))
	local pTxtSubTilte2 = self:findViewByName("txt_sub_tilte2")
	pTxtSubTilte2:setString(getConvertedStr(3, 10484))
	local pTxtSubTilte3 = self:findViewByName("txt_sub_tilte3")
	pTxtSubTilte3:setString(getConvertedStr(3, 10485))
	local pTxtSubTilte4 = self:findViewByName("txt_sub_tilte4")
	pTxtSubTilte4:setString(getConvertedStr(3, 10486))

	self.pLayListView = self:findViewByName("lay_listview")
end


--控件刷新
function DlgWuWangKillRank:updateViews( )
end

--更新列表
function DlgWuWangKillRank:updateRankListView( )
	local tRank = Player:getRankInfo():getRankDataList()
	if not tRank then
		return 
	end
	self.tRank = tRank
	--
	--我的排名
	local nMyRank = nil
	local nMyPoint = nil
	for i=1,#self.tRank do
		if self.tRank[i].i == Player:getPlayerInfo().pid then
			nMyRank = self.tRank[i].x
			nMyPoint = self.tRank[i].qa
			break
		end
	end
	if nMyRank then
		local tStr = {
		    {color=_cc.pwhite,text= getConvertedStr(3, 10495) },
		    {color=_cc.white,text=tostring(nMyRank)},
		}
		self.pTxtMyRank:setString(tStr)
	else
		local tStr = {
		    {color=_cc.pwhite,text= getConvertedStr(3, 10495) },
		    {color=_cc.red,text=getConvertedStr(3, 10303)},
		}
		self.pTxtMyRank:setString(tStr)
	end
	

	--
	self:createListView(#self.tRank)
end

--创建列表
function DlgWuWangKillRank:createListView( _count )
	local pContentLayer = self.pLayListView
	local pSize = pContentLayer:getContentSize()
	if not self.pListView then
	    self.pListView = MUI.MListView.new {
	        viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
	        direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	    }
	    
	    pContentLayer:addView(self.pListView)
	    centerInView(pContentLayer, self.pListView )
	end
    --列表数据
    self.pListView:setItemCount(_count)
    self.pListView:setItemCallback(function ( _index, _pView ) 
        local pItemData = self.tRank[_index]
        local pTempView = _pView
        if pTempView == nil then
            pTempView   = ItemWuWangKillRank.new()
        end
        pTempView:setData(pItemData)
        return pTempView
    end)
    self.pListView:reload()
end

--设置积分信息
--tData --List<Pair<Integer,Integer>>	k:国家ID V:积分
function DlgWuWangKillRank:setScores( tData ,nPoint)
	if not tData then
		return
	end

	-- --排序
	-- table.sort(tData, function ( a, b)
	-- 	return a.v > b.v
	-- end) 
	local tFontImg = {
		[e_type_country.shuguo] = "#v2_fonts_han.png",
		[e_type_country.weiguo] = "#v2_fonts_qin.png",
		[e_type_country.wuguo] = "#v2_fonts_chu.png",
	}
	if tData[1] then
		local nCountry, nScore = tData[1].k, tData[1].v
		local tStr = {
		    {color=_cc.pwhite,text=getConvertedStr(3, 10494)},
		    {color=_cc.white,text=nScore}, 
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
		    {color=_cc.white,text=nScore}, 
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
		    {color=_cc.white,text=nScore}, 
		}
		self.pTxtScore3:setString(tStr)

		local sImgStr = tFontImg[nCountry]
		if sImgStr then
			self.pImgCountry3:setCurrentImage(sImgStr)
		end
	end
	if nPoint then
		local tStr = {
			{color=_cc.pwhite,text= getConvertedStr(9, 10089) },
			{color=_cc.white,text=tostring(nPoint)},
		}
		self.pTxtMyPoint:setString(tStr)
	end
end

--国家积分请求回调
function DlgWuWangKillRank:onRspWuWangCountryScore( __msg )
	if __msg.head.type == MsgType.reqWuWangCountryScore.id then
		if __msg.body.ps then
			if self and self.setScores then
				self:setScores(__msg.body.ps,__msg.body.p)
			end
		end
	else
		TOAST(SocketManager:getErrorStr(__msg.head.state))
	end
end



return DlgWuWangKillRank