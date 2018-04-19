-- ItemSevenKing.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-10-30 15:39:24
-- 七日为王
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemKingAward = require("app.layer.activitya.sevenking.ItemKingAward")
local ActivityRankTops = require("app.layer.activitya.ActivityRankTops")
local ItemSevenKing = class("ItemSevenKing", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

--创建函数
function ItemSevenKing:ctor()
	self:myInit()
	parseView("dlg_seven_king", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function ItemSevenKing:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:regMsgs()
	--注册析构方法
	self:setDestroyHandler("ItemSevenKing",handler(self, self.onItemSevenKingDestroy))
end

--初始化参数
function ItemSevenKing:myInit()
	self.pData = {} --数据
	self.pItemTime = nil  --时间Item
	self.pDayBtns = nil   --七天的七个按钮
	self.nDayIdx  = -1    --天数,第几天
	self.nDefaultIndex = 1
	self.nActIdx = 1      --活动下标
end

--初始化控件
function ItemSevenKing:setupViews( )
	self.pLyTitle 			= self:findViewByName("lay_title")
	self.pLyTime 			= self:findViewByName("lay_time")
	self.pLyTitleTab 		= self:findViewByName("lay_title_tab")
	self.pLayContent 		= self:findViewByName("lay_content")
	self.pImgShuoming 		= self:findViewByName("img_shuoming")
	self.pImgShuoming:setViewTouched(true)
	self.pImgShuoming:onMViewClicked(handler(self, self.showActInstruction))
	self.pLayBannerBg 		= self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.ac_qrww)

end


--更新
function ItemSevenKing:updateViews( )
	-- dump(self.pData, " 七日登基 self.pData ==")
	if not self.pData then
		return
	end
	self.tAct = Player:getActById(e_id_activity.sevenking)

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTime,self.pData,cc.p(0,0))
	else
		self.pItemTime:setCurData(self.pData)
	end

	--七天按钮
	if not self.pDayBtns then
		self.pDayBtns = {}
		self.pDayBtnReds = {}
		for i = 1, 7 do
			local pLayBtn = self:findViewByName("lay_btn_"..i)

			local sImg, nPosY
			local nPosX = 55
			if i == 7 then
				sImg = "#v2_btn_bluehuodong.png"
				nPosY = 23
			else
				sImg = "#v2_btn_blue6.png"
				nPosY = pLayBtn:getHeight()/2
			end
			pLayBtn:setBackgroundImage(sImg)

			local pImgLabel = MImgLabel.new({text="", size = 18, parent = pLayBtn})
			pImgLabel:setImg("#v2_img_lock_tjp.png", 1, "left")
			pImgLabel:setName("pImgLb")
			pImgLabel:followPos("center", nPosX, nPosY, 2)
			pImgLabel:setString(string.format(getConvertedStr(7, 10187), i))

			pLayBtn:setViewTouched(true)
			pLayBtn:setIsPressedNeedScale(false)
			pLayBtn:onMViewClicked(function ()
				self:onDayBtnClicked(i)
			end)

			self.pDayBtns[i] = pLayBtn

			local pLayRed = MUI.MLayer.new()
			pLayRed:setLayoutSize(20, 20)
			local x = pLayBtn:getPositionX() + pLayBtn:getWidth() - 10
			local y = pLayBtn:getPositionY() + pLayBtn:getHeight() - pLayRed:getHeight()/2
			pLayRed:setPosition(x, y)
			self.pLyTitle:addView(pLayRed, 10)
			self.pDayBtnReds[i] = pLayRed
		end
		self:onDayBtnClicked(1)
	end
	self.nLoginDays = self.tAct:getLoginDays()
	for k, v in pairs(self.pDayBtns) do
		local pImageLabel = v:findViewByName("pImgLb")
		if k > self.nLoginDays then
			pImageLabel:showImg()
		else
			pImageLabel:hideImg()
		end
	end

	if not self.pTabHost then 
		self.pTabHost = TCommonTabHost.new(self.pLyTitleTab,1,1,e_sevenking_name[1],handler(self, self.onIndexSelected))
		self.pLyTitleTab:addView(self.pTabHost)
		self.pTabHost:removeLayTmp1()

		--默认选中第一项
		self.pTabHost:setDefaultIndex(self.nDefaultIndex)
	end

	if self.pListView and self.pListView:isVisible() then
		self.tConfLogList = self.tAct:getAwardsCofByIdx(self.nActIdx)
		self.pListView:notifyDataSetChange(false, table.nums(self.tConfLogList))
	end
	--界面刷新
	if self.pRankTops and self.pRankTops:isVisible() then
		local tActData = self.pData.tDataList[self.nActIdx]
		if tActData and tActData.nRankType then
			self:refreshRankData(tActData.nRankType, handler(self, self.updateRankInfo))
		end		
	end
	
	--刷新按钮红点
	self:updateBtnRedNum()

	--刷新标签红点
	self:updateTabItemRedNum()
end

--刷新按钮和标签的红点显示
function ItemSevenKing:updateBtnRedNum(  )
	-- body
	--print("#self.pDayBtnReds=", #self.pDayBtnReds)
	if self.pDayBtnReds and #self.pDayBtnReds > 0 then
		for k, v in pairs(self.pDayBtnReds) do 
			showRedTips(v, 0, self.pData:getRedNumsByDay(k))
		end 
	end		
		
end

--刷新标签红点
function ItemSevenKing:updateTabItemRedNum(  )
	-- body
	if self.pTabHost then
		--刷新标签红点
		local nCurDay = self.nDayIdx
		local tTabItems = self.pTabHost:getTabItems()
		for k, v in pairs(tTabItems) do
			local nIndex = k + (nCurDay-1)*3
			showRedTips(v:getRedNumLayer(), 0, self.pData:getRedNumsByIndex(nIndex))
		end			
	end
end

--七天按钮点击事件
function ItemSevenKing:onDayBtnClicked(_nDay)
	-- body
	if self.nLoginDays and _nDay > self.nLoginDays then
		TOAST(getConvertedStr(7, 10188))
		return
	end
	if self.pDayBtns[self.nDayIdx] then
		if self.nDayIdx == 7 then
			self.pDayBtns[self.nDayIdx]:setBackgroundImage("#v2_btn_bluehuodong.png")
		else
			self.pDayBtns[self.nDayIdx]:setBackgroundImage("#v2_btn_blue6.png")
		end
	end
	if self.nDayIdx ~= _nDay then--切换新的天数
		self.nDayIdx = _nDay		
	end
	if self.nDayIdx == 7 then
		self.pDayBtns[self.nDayIdx]:setBackgroundImage("#v2_btn_yellowhuodong.png")
	else
		self.pDayBtns[self.nDayIdx]:setBackgroundImage("#v2_btn_yellow6.png")
	end
	--重置分页标题
	if self.pTabHost then
		self.pTabHost:resetTabTitles(e_sevenking_name[self.nDayIdx])
		--默认选中第一项
		self.pTabHost:setDefaultIndex(self.nDefaultIndex)			
	end	

	self:updateTabItemRedNum()
end

--标签页
function ItemSevenKing:onIndexSelected(_nIndex)
	-- body
	local nActIdx = (self.nDayIdx-1)*3 + _nIndex
	self.nActIdx = nActIdx
	local tActData = self.pData.tDataList[nActIdx]
	--dump(tActData)
	--排行类
	if tActData.nRankType then
		if self.pListView then
			self.pListView:setVisible(false)
		end
		if not self.pRankTops then
			self.pRankTops = ActivityRankTops.new()
			self.pLayContent:addView(self.pRankTops, 3)
		end
		self.pRankTops:setVisible(true)
		self:refreshRankData(tActData.nRankType, handler(self, self.updateRankInfo))
	else
		if self.pRankTops then
			self.pRankTops:setVisible(false)
		end
		self.tConfLogList = self.tAct:getAwardsCofByIdx(nActIdx)
		local nCount = table.nums(self.tConfLogList)
		--列表数据
		if not self.pListView then
			--列表
			local pSize = self.pLayContent:getContentSize()
			self.pListView = MUI.MListView.new {
				viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
				direction  = MUI.MScrollView.DIRECTION_VERTICAL,
				itemMargin = {left =  0,
		            right =  0,
		            top =  0, 
		            bottom =  0},
		    }
		    self.pLayContent:addView(self.pListView)
			self.pListView:setItemCount(table.nums(self.tConfLogList))
			self.pListView:setItemCallback(function ( _index, _pView ) 
			    local pTempView = _pView
			    if pTempView == nil then
			    	pTempView = ItemKingAward.new(_index)
				end
				pTempView:setCurData(self.tConfLogList[_index], self.nActIdx, self.tAct)
			    return pTempView
			end)
			--上下箭头
			local pUpArrow, pDownArrow = getUpAndDownArrow()
			self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
			self.pListView:reload(false)
		else
			self.pListView:scrollToBegin()
			self.pListView:notifyDataSetChange(false, table.nums(self.tConfLogList))
		end
		self.pListView:setVisible(true)
	end
end

--刷新排行榜数据
function ItemSevenKing:refreshRankData( _nType, handler )
 	-- body
 	local nCurRank = Player:getRankInfo().nRankType
 	if nCurRank == _nType then
 		if handler then
 			handler()
 		end
 		return
 	else
 		local nPage = 1
		SocketManager:sendMsg("getRankData", {_nType, nPage}, function ( __msg )
			-- body
			if handler then
				handler()
			end		
		end)
 	end
end 
function ItemSevenKing:updateRankInfo()
 	-- body
 	--刷新排行榜显示
 	local tRankData = {}
	tRankData.tListData = copyTab(Player:getRankInfo():getRankDataList())
	tRankData.tMyData = copyTab(Player:getRankInfo():getMyRankInfo())
	tRankData.nRankType = Player:getRankInfo().nRankType
 	self.pRankTops:setCurData(tRankData)
end 

--析构方法
function ItemSevenKing:onItemSevenKingDestroy(  )
end

-- 注册消息
function ItemSevenKing:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function ItemSevenKing:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end


function ItemSevenKing:onResume(  )
	self:regMsgs()
end

function ItemSevenKing:onPause(  )
	self:unregMsgs()
	sendMsg(ghd_clear_rankinfo_msg)
end

--设置数据 _data
function ItemSevenKing:setData(_tData)
	if not _tData then
		return
	end
	self.pData = _tData or {}
	self:updateViews()
end
--显示活动说明
function ItemSevenKing:showActInstruction(  )
	-- body
	--dump(self.pData.sDesc, "self.pData.sDesc", 100)
	if not self.pData then
		return
	end
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContentLetter(self.pData.sDesc)
    pDlg:setRightHandler(function ()            
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew)
end

return ItemSevenKing