-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-7 15:41:23 星期三
-- Description: 国家官员
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemOfficial = require("app.layer.country.ItemOfficial")
local ItemVoteLayer = require("app.layer.country.ItemVoteLayer")


local DlgCountryOfficials = class("DlgCountryOfficials", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgcountryofficials)
end)

function DlgCountryOfficials:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_country_officials", handler(self, self.onParseViewCallback))
end

function DlgCountryOfficials:myInit(  )
	-- body
	self.tLbTitles = {}
	self.tStitles = {}
	self.tPostGroup = {}
	self.tCurData = nil
	self.bShowBtn = false --官员列表后面是否显示按钮
	self.nItemBtnType = TypeCommonBtn.M_BLUE
end

--解析布局回调事件
function DlgCountryOfficials:onParseViewCallback( pView )
	-- body
	self:setTitle(getConvertedStr(6,10321))
	self:addContentView(pView) --加入内容层
	--self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgCountryOfficials",handler(self, self.onDlgCountryOfficialsDestroy))
end

--初始化控件
function DlgCountryOfficials:setupViews(  )
	-- body		
end

--控件刷新
function DlgCountryOfficials:updateViews(  )
	-- body	
	local tCountryDatavo = Player:getCountryData():getCountryDataVo()
	local tofficial = getNationTransport(tCountryDatavo.nOfficial)
	gRefreshViewsAsync(self, 4, function ( _bEnd, _index )	
		if(_index == 1) then
			--当前玩家官职
			if not self.pLbGuanzhi then
				self.pLbGuanzhi = self:findViewByName("lb_guanzhi")
			end
			local sGuanzhi = getConvertedStr(6, 10338)
			if tofficial then
				sGuanzhi = {
					{color = _cc.pwhite, text=getConvertedStr(6, 10338)},
					{color = _cc.yellow, text=tofficial.name},
				}								
			else
				sGuanzhi = {
					{color = _cc.pwhite, text=getConvertedStr(6, 10338)},
					{color = _cc.pwhite, text=getConvertedStr(3, 10139)},
				}				
			end
			self.pLbGuanzhi:setString(sGuanzhi, false)
			--官员任免按钮		
			if not self.pBtnRenmian then
				self.pLayBtnRenmian = self:findViewByName("lay_btn_renmian")				
				self.pBtnRenmian = getCommonButtonOfContainer(self.pLayBtnRenmian, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10339))
				self.pBtnRenmian:onCommonBtnClicked(handler(self, self.onRenmianBtnClicked))
				setMCommonBtnScale(self.pLayBtnRenmian, self.pBtnRenmian, 0.8)
			end		
			if tCountryDatavo:isKing() == true then--我是国王
				self.pBtnRenmian:setVisible(true)
			else
				self.pBtnRenmian:setVisible(false)
			end	
			--官职特权按钮
			if not self.pBtnLiberty then
				--职权按钮
				self.pLayBtnLiberty = self:findViewByName("lay_btn_liberty")
				self.pBtnLiberty = getCommonButtonOfContainer(self.pLayBtnLiberty, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10340))
				self.pBtnLiberty:onCommonBtnClicked(handler(self, self.onLibertyBtnClicked))
				setMCommonBtnScale(self.pLayBtnLiberty, self.pBtnLiberty, 0.8)
			end				
		elseif (_index == 2) then
			self.bShowBtn = false
			if not self.pLbTip1 then 
				self.pLbTip1 = self:findViewByName("lb_tip_1")						
			end
			if not self.pLbTip2 then
				self.pLbTip2 = self:findViewByName("lb_tip_2")
			end
			--倒计时
			if not self.pLbTimer then				
				self.pLbTimer = self:findViewByName("lb_timer")
				setTextCCColor(self.pLbTimer, _cc.red)
			end			
			local nstatus = Player:getCountryData():getCurOfficialStatus()--当前官员状态
			--关闭倒计时
			unregUpdateControl(self)--停止计时刷新
			if nstatus == 0 then--不需要官员选举
				self.pLbTip2:setVisible(false)	
				local nlefttime = Player:getCountryData():getLeftCampaignTime()
				if nlefttime > 0 then--已经攻克州府
					regUpdateControl(self, handler(self, self.onUpdateTime))--刷新倒计时
				else			--未攻克州府
					self.pLbTimer:setString(getConvertedStr(6, 10390), false)
				end
				self.tStitles = {getConvertedStr(6, 10391), getConvertedStr(6, 10244), 
				getConvertedStr(6, 10254), getConvertedStr(6, 10344), getConvertedStr(6, 10392)}
				self.tCurData = Player:getCountryData():getOfficialsData()
				self.pLbTip1:setString(getConvertedStr(6, 10332), false)
			elseif nstatus == 1 then--选举中
				local sStr = nil
				self.pLbTip2:setVisible(true)	
				--已经投票次数	
				if tCountryDatavo.nT == 0 then
					self.nItemBtnType = TypeCommonBtn.M_BLUE
					local tvotes = luaSplit(getCountryParam("vip2Votes"), ";") 			
					sStr = {
						{color=_cc.pwhite,text=getConvertedStr(6, 10398)},
						{color=_cc.blue,text=(tvotes[Player:getPlayerInfo().nVip + 1] or 0)},
					}			
				else
					local sSupport = Player:getCountryData().sSupport
					self.nItemBtnType = TypeCommonBtn.M_YELLOW
					sStr = {
						{color=_cc.pwhite,text=getConvertedStr(6, 10333)},
						{color=_cc.blue,text=(sSupport or "")},
					}			
				end		
				self.pLbTip2:setString(sStr, false)
				self.tStitles = {getConvertedStr(6, 10244), getConvertedStr(6, 10254), 
				getConvertedStr(6, 10344), getConvertedStr(6, 10393), getConvertedStr(6, 10394)}
				self.tCurData = Player:getCountryData():getCandidateData()
				self.bShowBtn = true
				self.pLbTip1:setString(getConvertedStr(6, 10512), false)
				regUpdateControl(self, handler(self, self.onUpdateTime))--刷新选举倒计时
			elseif nstatus == 2 then--官员任职中
				self.pLbTip1:setString(getConvertedStr(6, 10332), false)
				self.pLbTip2:setVisible(false)
				self.tStitles = {getConvertedStr(6, 10391), getConvertedStr(6, 10244), 
				getConvertedStr(6, 10254), getConvertedStr(6, 10344), getConvertedStr(6, 10392)}
				self.tCurData = Player:getCountryData():getOfficialsData()
				regUpdateControl(self, handler(self, self.onUpdateTime))--刷新任职倒计时
			end	
			self.pLbTimer:setPositionX(self.pLbTip1:getPositionX() + self.pLbTip1:getWidth())	
		elseif (_index == 3) then
			--刷新管管海报
			self:updatePostGroup()
			--刷新列表标题
			self:updateTitles()
		elseif (_index == 4) then	
			--官员列表刷新
			local nItemCnt = 0
			if self.tCurData then
				nItemCnt = #self.tCurData
			end
			if not self.pListView then
				self.pLayList = self:findViewByName("lay_list")
				self.pListView = MUI.MListView.new {
			        bgColor = cc.c4b(255, 255, 255, 250),
			        viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
			        direction = MUI.MScrollView.DIRECTION_VERTICAL,
			        itemMargin = {left =  0,
			         right =  0,
			         top =  0,
			         bottom =  0}}
				self.pLayList:addView(self.pListView, 10)   
				self.pListView:setBounceable(true)
			    self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
				self.pListView:setItemCount(nItemCnt)      		    
			    self.pListView:reload(true)	
			else				
				self.pListView:notifyDataSetChange(true, nItemCnt)			
			end
		end
	end)
end

--析构方法
function DlgCountryOfficials:onDlgCountryOfficialsDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgCountryOfficials:regMsgs(  )
	-- body
	--注册国家任务界面刷新消息
	regMsg(self, gud_refresh_country_official_msg, handler(self, self.updateViews))	
	--注册国家官员数据户撒新
	regMsg(self, gud_refresh_generalrenmian_msg, handler(self, self.updateViews))
	--注册国家信息刷新消息
	regMsg(self, gud_refresh_country_msg, handler(self, self.updateViews))
end
--注销消息
function DlgCountryOfficials:unregMsgs(  )
	-- body
	--注销国家任务界面刷新消息
	unregMsg(self, gud_refresh_country_official_msg)
	--注销国家官员数据户撒新
	unregMsg(self, gud_refresh_generalrenmian_msg)	
	--注销国家信息刷新消息
	unregMsg(self, gud_refresh_country_msg)	
end

--暂停方法
function DlgCountryOfficials:onPause( )
	-- body	
	self:unregMsgs()	
	unregUpdateControl(self)
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgCountryOfficials:onResume( _bReshow )
	-- body	
	if _bReshow and self.pListView then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
end

function DlgCountryOfficials:updatePostGroup( )
	-- body	
	if not self.pLayRoot then
		self.pLayRoot = self:findViewByName("root")
		self.pLayTop = self:findViewByName("lay_top")
	end
	local tposter = Player:getCountryData():getPoliticiansPoster()	
	for i = 1, 3 do 
		local pItemOfficial = self.tPostGroup[i]
		if not pItemOfficial then
			pItemOfficial = ItemOfficial.new()			
			self.pLayTop:addView(pItemOfficial, 10)
			self.tPostGroup[i] = pItemOfficial
			if i == 1 then
				pItemOfficial:setPosition(47.5 + (2 - 1)*197.5, 14)
				pItemOfficial:setImg("#v1_img_guowang.png", 0.8)
				pItemOfficial:setImgBg("#v2_img_jinq.png")
			elseif i== 2 then
				pItemOfficial:setPosition(47.5 + (1 - 1)*197.5, 14)
				pItemOfficial:setImg("#v1_img_chengxiang.png", 0.8)
				pItemOfficial:setImgBg("#v2_img_yinq.png")
			else  
				pItemOfficial:setPosition(47.5 + (3 - 1)*197.5, 14)
				pItemOfficial:setImg("#v1_img_taiwei.png", 0.8)
				pItemOfficial:setImgBg("#v2_img_tongq.png")
			end
		end
		pItemOfficial:setCurData(tposter[i],i)
	end	
end

--刷新标题
function DlgCountryOfficials:updateTitles(  )
	-- body
	if not self.pLayTitle then
		self.pLayTitle = self:findViewByName("lay_title")	
	end
	local ncnt = table.nums(self.tStitles)
	local wid = self.pLayTitle:getWidth()/ncnt
	for i = 1, 5 do
		if not self.tLbTitles[i] then
			self.tLbTitles[i] = self:findViewByName("lb_title_"..i)
			setTextCCColor(self.tLbTitles[i], _cc.pwhite)
		end
		if i <= ncnt then
			self.tLbTitles[i]:setPositionX(wid/2 + (i-1)*wid)
			self.tLbTitles[i]:setVisible(true)
			self.tLbTitles[i]:setString(self.tStitles[i])
		else
			self.tLbTitles[i]:setVisible(false)
		end
	end	
end
function DlgCountryOfficials:onUpdateTime( )
	-- body
	local nlefttime = Player:getCountryData():getLeftCampaignTime()
	if nlefttime > 0 then
		self.pLbTimer:setString(formatTimeToHms(nlefttime, true, true)) 
	else
		self.pLbTimer:setString("")
		unregUpdateControl(self)
	end	
end
--列表项回调
function DlgCountryOfficials:onListViewItemCallBack(_index, _pView)
	-- body	
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemVoteLayer.new()                        
        pTempView:setViewTouched(false) 
        pTempView:setOperateHandler(handler(self, self.operateCandidate))       
    end    
    if self.bShowBtn == false then    	
    	pTempView:showOfficialsInfo(self.tCurData[_index])
    else
    	pTempView:showCandidateInfo(self.tCurData[_index])
    end
    pTempView:getBtn():updateBtnType(self.nItemBtnType)
    pTempView:setBtnVisible(self.bShowBtn)    
    if self.nItemBtnType == TypeCommonBtn.M_BLUE then
    	pTempView:getBtn():updateBtnText(getConvertedStr(6, 10394))
    else
		pTempView:getBtn():updateBtnText(getConvertedStr(6, 10395))
    end
    return pTempView
end

--任免将军按钮回调
function DlgCountryOfficials:onRenmianBtnClicked( pview )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlggeneralrenmian --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end
--特权按钮回调
function DlgCountryOfficials:onLibertyBtnClicked(pview)
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.dlgofficialprivilege --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)	
end

--候选人操作
function DlgCountryOfficials:operateCandidate( _candidate )
	-- body
	if _candidate then
		local cId = _candidate.nID
		local  tCountryDatavo = Player:getCountryData():getCountryDataVo()
		local isfree = 0		
	    if tCountryDatavo.nT == 0 then--免费
	    	isfree = 1		    
		end
		if isfree == 0 then
			local tvote = getCountryVote()
			local tcost = nil
			if tCountryDatavo.nT > #tvote then
				tcost = luaSplit(tvote[#tvote], ":")
			else
				tcost = luaSplit(tvote[tCountryDatavo.nT], ":")
			end
			if not tcost then
				return
			end
			local resid = tonumber(tcost[1])
			local ncost = tonumber(tcost[2])
			if resid == e_resdata_ids.ybao then
				local strTips = {
	    			{color=_cc.white,text=getConvertedStr(6, 10481)},--扩充容量到
	    			{color=_cc.blue,text=_candidate.sName},
	    			{color=_cc.blue,text=getConvertedStr(6, 10482)},
	    		}
				showBuyDlg(strTips, ncost, function ( )
					-- body
					self:sendOfficialVote(_candidate.nID, isfree)
				end, 0, true)
			else
				self:sendOfficialVote(_candidate.nID, isfree)
			end
		else
			--免费
			local pDlg, bNew = getDlgByType(e_dlg_index.alert)
		    if(not pDlg) then
		        pDlg = DlgAlert.new(e_dlg_index.alert)
		    end
		    pDlg:setTitle(getConvertedStr(3, 10091))
		    local nVip = Player:getPlayerInfo().nVip
		    local tvotes = luaSplit(getCountryParam("vip2Votes"), ";")
		    --print("nVip"..nVip) 
		    --dump(tvotes, "tvotes", 10)	
		    local nvotes = tvotes[nVip+1] or 0					
		    local tStr = {
		    	{color=_cc.white,text=getConvertedStr(6, 10403)..nvotes..getConvertedStr(6, 10404)},
			    {color=_cc.blue,text=_candidate.sName},
			    {color=_cc.white,text="?"},
			    {color=_cc.yellow,text=getConvertedStr(6, 10405)}			    
			}
			local plabel = MUI.MLabel.new({
		        text="",
		        size=20,
		       	align = cc.ui.TEXT_ALIGN_CENTER,
    			valign = cc.ui.TEXT_ALIGN_CENTER,
		        anchorpoint=cc.p(0.5, 0.5),
		        dimensions = cc.size(380, 0),
		        })
			plabel:setString(tStr, false)			
		    pDlg:addContentView(plabel)
		    pDlg:setRightHandler(function (  )
		        self:sendOfficialVote(_candidate.nID, isfree)
		        pDlg:closeDlg(false)
		    end)
		    pDlg:showDlg(bNew)
		end

	end	
end
--投票
function DlgCountryOfficials:sendOfficialVote( _id, isfree )
	-- body
	SocketManager:sendMsg("officialVote", {_id, isfree}, handler(self, self.onReqOfficialVote))	
end

function DlgCountryOfficials:onReqOfficialVote( __msg )
	-- body
	--dump(__msg, "__msg", 100)
	if __msg.head.state == SocketErrorType.success	then
		if __msg.head.type == MsgType.officialVote.id then
			TOAST(getTipsByIndex(10066))
		end
	end	
end

return DlgCountryOfficials