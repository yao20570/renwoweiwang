-- DlgNewGrowFound.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-1-5 14:37:33 星期五
-- Description: 新版成长基金窗口
-----------------------------------------------------


local DlgBase = require("app.common.dialog.DlgBase")
local NewItemGrowFound = require("app.layer.activityb.growthfound.NewItemGrowFound")
local DlgAlert = require("app.common.dialog.DlgAlert")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")

local DlgNewGrowFound = class("DlgNewGrowFound", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgnewgrowfound)
end)

function DlgNewGrowFound:ctor(  )
	-- body
	self:myInit()
	self:refreshData()
	parseView("dlg_new_grow_funds", handler(self, self.onParseViewCallback))
end

function DlgNewGrowFound:myInit(  )
	-- body
	self.tActData  = nil --活动数据
	self.tTitles = {
		string.format(getConvertedStr(7,10289), e_vip_type[1]),
		string.format(getConvertedStr(7,10289), e_vip_type[2])
	}
	self.nSelect = nil 	--当前选中下标
end

function DlgNewGrowFound:refreshData()
	self.tActData = Player:getActById(e_id_activity.newgrowthfound)
end

--解析布局回调事件
function DlgNewGrowFound:onParseViewCallback( pView )
	self:addContentTopSpace()
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	self:updateTabHost()

	--注册析构方法
	self:setDestroyHandler("DlgNewGrowFound",handler(self, self.onDlgNewGrowFoundDestroy))
end

--初始化控件
function DlgNewGrowFound:setupViews()
	--设置标题
	self:setTitle(getConvertedStr(7,10078))

	self.pLayRoot = self:findViewByName("default")
	self.pLyBlack = self:findViewByName("lay_black")

	--说明
	self.pLayShuoming = self:findViewByName("lay_shuoming")
	self.pLayShuoming:setViewTouched(true)
	self.pLayShuoming:onMViewClicked(handler(self, self.onShuomingClicked))

	self.pLayBuyBtn = self:findViewByName("lay_btn_buy")
	--购买按钮
	self.pBuyBtn = getCommonButtonOfContainer(self.pLayBuyBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10079))
	self.pBuyBtn:onCommonBtnClicked(handler(self, self.onBuyBtnClicked))

	--按钮上的文字
	local tBtnTable = {}
	--文本
	local tLabel = {
		{getConvertedStr(7,10293), getC3B(_cc.yellow)},
		{"4", getC3B(_cc.yellow)},
		{getConvertedStr(7,10294), getC3B(_cc.white)}
	}

	tBtnTable.tLabel = tLabel
	tBtnTable.fontSize = 18
	self.pBtnExText = self.pBuyBtn:setBtnExText(tBtnTable)

	--设置banner图
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	local pMBanner = setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_czjj)
	pMBanner:setMBannerOpacity(255*0.5)

	--升级可领取黄金
	self.pLbMoney = self:findViewByName("lb_money")
	setTextCCColor(self.pLbMoney, _cc.yellow)

	self.pLayList = self:findViewByName("lay_list")
	--提示文本图
	self.pImgTip = self:findViewByName("img_tip")



end

--更新切换卡
function DlgNewGrowFound:updateTabHost()
	if not self.pTComTabHost then
		self.pLyTab   = self:findViewByName("lay_tab")
		self.pTComTabHost = TCommonTabHost.new(self.pLyTab,1,1,self.tTitles,handler(self, self.onIndexSelected))
		self.pTabItems = self.pTComTabHost:getTabItems()
		self.pLyTab:addView(self.pTComTabHost,10)
		self.pTComTabHost:removeLayTmp1()
		--默认选中V4基金
		self.pTComTabHost:setDefaultIndex(2)
	end
	self:updateViews()
end

--下标选择回调事件
function DlgNewGrowFound:onIndexSelected( _index )
	if _index == self.nSelect then return end
	self.nSelect = _index --当前所选标签页

	self:updateTabHost()
end

--弹出说明
function DlgNewGrowFound:onShuomingClicked()
	-- body
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(7, 10291))
    pDlg:setContentLetter(self.tActData.sDesc)
    pDlg:setOnlyConfirm()
    pDlg:setRightHandler(function ()            
        closeDlgByType(e_dlg_index.alert, false)  
    end)
    pDlg:showDlg(bNew)
end

--控件刷新
function DlgNewGrowFound:updateViews()
	if not self.tActData then
		self:closeDlg(false)
		return
	end
	--红点刷新
	self:refreshRedNum()

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLyBlack,self.tActData,cc.p(0,0))
	else
		self.pActTime:setCurData(self.tActData)
	end
	--是否在限购时间内
	local bInCd = self.tActData:getIsDuringCd()
	if not bInCd then
		self.pActTime:setVisible(false)
		--限购时间已过, 不可购买了
		self.pBuyBtn:setBtnEnable(false)
		self.pBtnExText:setLabelCnCr(1, "")
		self.pBtnExText:setLabelCnCr(2, "")
		self.pBtnExText:setLabelCnCr(3, getConvertedStr(7, 10290), getC3B(_cc.red)) --限购时间已过
	else
		self.pBtnExText:setLabelCnCr(2, tostring(e_vip_type[self.nSelect]))
	end

	--获取是否已购买该Vip基金
	self.bOpen = self.tActData:getIsOpenByVip(e_vip_type[self.nSelect])
	--如果已购买
	if self.bOpen then
		self.pBuyBtn:updateBtnText(getConvertedStr(7, 10090))
		self.pBuyBtn:setBtnEnable(false)
		self.pBuyBtn:removeLingTx()
	else
		if bInCd then
			self.pBuyBtn:setBtnEnable(true)
			--加按钮特效
			self.pBuyBtn:showLingTx()
		else
			self.pBuyBtn:removeLingTx()
		end
	end

	if self.nSelect == 1 then
		-- self.pLbMoney:setString(4500)
		self.pImgTip:setCurrentImage("#v2_fonts_dengji.png")
	else
		self.pImgTip:setCurrentImage("#v1_fonts_dengji0.png")
		
		-- self.pLbMoney:setString(10200)
	end

	--奖励信息
	self.tAwardsInfo = self.tActData.tVipAwards[e_vip_type[self.nSelect]]
	if self.tAwardsInfo == nil then return end

	if not self.bOpen then
		local pid = self.tAwardsInfo.pid
		local tRechargeData = getRechargeDataByKey(pid)
		--购买价格
		local nPrice = tRechargeData.price
		if nPrice then
			self.pBuyBtn:updateBtnText(string.format(getConvertedStr(7, 10292), nPrice), 22, true) --￥%s
		end
	end

	--奖励显示
	self.tAwardsList = self.tAwardsInfo.rewards

	local nItemCnt = table.nums(self.tAwardsList)
	if nItemCnt <= 0 then return end
	if(not self.pListView) then
		--列表层
		self.pListView = MUI.MListView.new{
	        viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {
	        	left =  0,
	        	right =  0,
	        	top =  0,
	        	bottom =  10
	        },
		}
		self.pLayList:addView(self.pListView)
		self.pListView:setBounceable(true)

	    local nItemCnt = table.nums(self.tAwardsList)
	    self.pListView:setItemCount(nItemCnt)      
	    self.pListView:setItemCallback(function ( _index, _pView )
	        local pTempView = _pView
	    	if pTempView == nil then
	        	pTempView = NewItemGrowFound.new()                        
	        end
	        pTempView:setItemData(self.tAwardsList[_index], self.bOpen, e_vip_type[self.nSelect])
	        return pTempView
	    end)
	    --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	    self.pListView:reload(true)
	else
		self.pListView:scrollToBegin(false)
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end

end

--刷新红点
function DlgNewGrowFound:refreshRedNum()
	-- body
	if not self.pTabItems then return end
	local nCnt = table.nums(self.pTabItems)
	for i = 1, nCnt do
		local nRedNums = self.tActData:getRedNumsByVip(e_vip_type[i])
		showRedTips(self.pTabItems[i]:getRedNumLayer(), 0, nRedNums, 2)
	end
end


--刷新界面
function DlgNewGrowFound:updateLayer()
	self:refreshData()
	self:updateViews()	
end

--购买按钮点击事件
function DlgNewGrowFound:onBuyBtnClicked(pView)
	if self.tActData == nil then return end

	local nLimitVip = e_vip_type[self.nSelect]
	if self.nSelect == 1 then
	else
	end

	local nMyVip = Player:getPlayerInfo().nVip
	if nMyVip >= nLimitVip then			--vip等级达到要求才显示购买界面
		--请求充值
		if self.tAwardsInfo then
			local pid = self.tAwardsInfo.pid
			local tData = getRechargeDataByKey(pid)
			if tData then
				reqRecharge(tData)
			end
		end
	else
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))		
	    pDlg:setContent(getConvertedStr(6, 10513), _cc.white, 20, 400)
	    pDlg:setRightHandler(function ()
	        local tObject = {}
	        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	        sendMsg(ghd_show_dlg_by_type,tObject)  
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)	
	end
end

--析构方法
function DlgNewGrowFound:onDlgNewGrowFoundDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgNewGrowFound:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateLayer))
	--限购时间结束刷新消息
	regMsg(self, gud_refresh_growthfound, handler(self, self.updateLayer))

end
--注销消息
function DlgNewGrowFound:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)
	--销毁限购时间结束刷新消息
	unregMsg(self, gud_refresh_growthfound)

end
--暂停方法
function DlgNewGrowFound:onPause( )
	-- body
	self:unregMsgs()
	local pActData = Player:getActById(e_id_activity.newgrowthfound)
	if pActData and pActData:hasGotAllAwards() then --已经领取全部奖励, 移除该活动
		Player:removeActById(e_id_activity.newgrowthfound)
	end
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgNewGrowFound:onResume(_bReshow)
	-- body
	if(_bReshow and self.pListView) then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
end


return DlgNewGrowFound