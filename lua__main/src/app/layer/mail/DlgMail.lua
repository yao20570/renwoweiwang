-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-15 19:41:44 星期一
-- Description: 邮件
-----------------------------------------------------
local DlgBase = require("app.common.dialog.DlgBase")
local MBtnExText = require("app.common.button.MBtnExText")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local LoadMoreMail = require("app.layer.mail.LoadMoreMail")
local ItemMail = require("app.layer.mail.ItemMail")
local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgMail = class("DlgMail", function()
	-- body
	return DlgBase.new(e_dlg_index.mail)
end)

function DlgMail:ctor(  )
	--测试
	--Player:getMailData():initTestData()
	-- body
	self:myInit()
	parseView("dlg_mail", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgMail:myInit(  )
	-- body
end

--解析布局回调事件
function DlgMail:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(3)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgMail",handler(self, self.onDlgMailDestroy))
end

--初始化控件
function DlgMail:setupViews( )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(1, 10194))

	--底部层1
	self.pLayBottomA 			= 		self:findViewByName("lay_m_b_type1")
	--底部层2
	self.pLayBottomB 			= 		self:findViewByName("lay_m_b_type2")

	--底部层1 三个按钮
	self.pLayLeft 				= 	self:findViewByName("lay_m_btn_l")
	self.pLayCenter 			= 	self:findViewByName("lay_m_btn_c") 
	self.pLayRight 				= 	self:findViewByName("lay_m_btn_r") 
	self.pBtnLeft = getCommonButtonOfContainer(self.pLayLeft,TypeCommonBtn.L_RED,getConvertedStr(1,10195))
	self.pBtnCenter = getCommonButtonOfContainer(self.pLayCenter,TypeCommonBtn.L_YELLOW,getConvertedStr(1,10197))
	self.pBtnRight = getCommonButtonOfContainer(self.pLayRight,TypeCommonBtn.L_BLUE,getConvertedStr(1,10196))
	--左边按钮点击事件
	self.pBtnLeft:onCommonBtnClicked(handler(self, self.onLeftClicked))
    self.pBtnLeft:onCommonBtnDisabledClicked(handler(self, self.onLeftDisabledClicked))
	--中间按钮点击事件
	self.pBtnCenter:onCommonBtnClicked(handler(self, self.onCenterClicked))
    self.pBtnCenter:onCommonBtnDisabledClicked(handler(self, self.onCenterDisabledClicked))
    --右边按钮点击事件
	self.pBtnRight:onCommonBtnClicked(handler(self, self.onRightClicked))
    self.pBtnRight:onCommonBtnDisabledClicked(handler(self, self.onRightDisabledClicked))

    --底部层2 一个按钮
    self.pLayDel 				= 	self:findViewByName("lay_m_btn_d")
    self.pBtnDel = getCommonButtonOfContainer(self.pLayDel,TypeCommonBtn.L_RED,getConvertedStr(1,10195))
    self.pBtnDel:onCommonBtnClicked(handler(self, self.onDelClicked))
    self.pBtnDel:onCommonBtnDisabledClicked(handler(self, self.onDelDisabledClicked))
    --提示语
    self.pLbTipA 			 	= 	self:findViewByName("lb_m_tips1")
    -- setTextCCColor(self.pLbTipA,_cc.pwhite)
    -- self.pLbTipA:setString(getConvertedStr(1, 10198), false)
    self.pLbTipB 			 	= 	self:findViewByName("lb_m_tips2")
    setTextCCColor(self.pLbTipB,_cc.gray)
    self.pLbTipB:setString(string.format(getConvertedStr(1, 10199), getTimeLongStr(getMailInitData("retentionTime"), true, true)))
    --上限个数
    local tBtnTableMax = {}
	-- tBtnTableMax.parent = self.pLayBottomB
	-- tBtnTableMax.awayH = 5
	--文本
	tBtnTableMax.tLabel = {
		{getConvertedStr(1, 10198), getC3B(_cc.pwhite)},
	 	{0,getC3B(_cc.blue)},
	 	{"/",getC3B(_cc.pwhite)},
	 	{getMailInitData("retentionNum"),getC3B(_cc.pwhite)}
	}
	tBtnTableMax.fontSize = 20
	self.pBtnExText = createGroupText(tBtnTableMax)
	self.pBtnExText:setAnchorPoint(cc.p(0, 0.5))
	self.pLayBottomB:addView(self.pBtnExText, 10)
	self.pBtnExText:setPosition(30, 80)

	--切换卡层
	self.tMailMsgList = {}
	self.tTitles = {
		getConvertedStr(3, 10207),
		getConvertedStr(3, 10208),
		getConvertedStr(3, 10209),
		getConvertedStr(1, 10240),
		getConvertedStr(3, 10210),
	}

	self.pLayTabHost 			= 		self:findViewByName("lay_m_tabhost")

	self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onIndexSelected))
	self.pLayTabHost:addView(self.pTComTabHost)
	self.pTComTabHost:removeLayTmp1()

	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(3, 10220),
	}
	local pNullUi = getLayNullUiImgAndTxt(tLabel)
	pNullUi:setIgnoreOtherHeight(true)
	self.pLayTabHost:addView(pNullUi)
	centerInView(self.pLayTabHost, pNullUi)
	self.pNullUi = pNullUi
	self.pNullUi:setVisible(false)


	--按钮集
	self.pTabItems =  self.pTComTabHost:getTabItems()
end

--进入界面后才刷新数据
function DlgMail:__nShowHandler(  )
	-- body
	--没有数据提示
	-- local tLabel = {
	--     str = getConvertedStr(3, 10220),
	-- }
	-- local pNullUi = getLayNullUiImgAndTxt(tLabel)
	-- self.pLayTabHost 			= 		self:findViewByName("lay_m_tabhost")
	-- self.pLayTabHost:addView(pNullUi)
	-- centerInView(self.pLayTabHost, pNullUi)
	-- self.pNullUi = pNullUi
	-- self.pNullUi:setVisible(false)

	-- self.pTComTabHost = TCommonTabHost.new(self.pLayTabHost,1,1,self.tTitles,handler(self, self.onIndexSelected))
	-- self.pLayTabHost:addView(self.pTComTabHost)
	-- self.pTComTabHost:removeLayTmp1()
	-- self:createListView()
	-- --默认选中第一项
	-- self.pTComTabHost:setDefaultIndex(1)
end

-- 修改控件内容或者是刷新控件数据
function DlgMail:updateViews(  )
	self:updateRedNum()

	--默认选中有未读的邮件标签页
	local isHasRed = false
	for k, v in pairs(self.tRedTipNum) do
		if v > 0 then
			self.pTComTabHost:setDefaultIndex(k)
			isHasRed = true
			break
		end
	end
	local nEnterCategory = Player:getMailData().nLastEnterCategory
	if not isHasRed then
		if nEnterCategory then
			self.pTComTabHost:setDefaultIndex(nEnterCategory)
		else
			self.pTComTabHost:setDefaultIndex(1)
		end
	end
end

-- 析构方法
function DlgMail:onDlgMailDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgMail:regMsgs( )
	--邮件发生变化
	regMsg(self, gud_mail_change_msg, handler(self, self.onMailListRefresh))
	--邮件保存
	regMsg(self, gud_mail_save_success_msg, handler(self, self.onMailSaveSuccess))
	--邮件取消保存
	regMsg(self, gud_mail_save_cancel_success_msg, handler(self, self.onMailSaveCancelSuccess))
	--邮件请求加载
	regMsg(self, gud_mail_load_req_msg, handler(self, self.onMailLoadReq))
	--邮件数红点发生改变
	regMsg(self, gud_mail_not_read_nums_msg, handler(self, self.updateRedNum))
end

-- 注销消息
function DlgMail:unregMsgs(  )
	--邮件发生变化
	unregMsg(self, gud_mail_change_msg)
	--邮件保存
	unregMsg(self, gud_mail_save_success_msg)
	--邮件取消保存
	unregMsg(self, gud_mail_save_cancel_success_msg)
	--邮件请求加载
	unregMsg(self, gud_mail_load_req_msg)
	--邮件数红点发生改变
	unregMsg(self, gud_mail_not_read_nums_msg)
end


--暂停方法
function DlgMail:onPause( )
	-- body
	self:unregMsgs()
	Player:getMailData().nLastEnterCategory = self.nCategory
end

--继续方法
function DlgMail:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--已保存 删除按钮点击事件
function DlgMail:onDelClicked( pView )
	-- body
	-- print("已保存 全部删除点击")
    self:openDlgDelMail()
end

--已保存 删除按钮无效点击事件
function DlgMail:onDelDisabledClicked( pView )
	-- body
	-- print("已保存 全部删除无效")
end

--全部删除按钮点击事件
function DlgMail:onLeftClicked( pView )
    self:openDlgDelMail()
end

--打开是否全部删除邮件对话框
function DlgMail:openDlgDelMail()
	if not self:isHasMail() then
		return
	end
	local pDlg = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContent(getConvertedStr(3, 10222))
    pDlg:setRightHandler(function (  )
        SocketManager:sendMsg("reqMailDel", {self.nCategory})
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(true)
end

--该标签页是否有邮件
function DlgMail:isHasMail()
	-- body
	local tMailList = Player:getMailData():getMailMsgList(self.nCategory)
	if tMailList and #tMailList > 0 then
		return true
	else
		TOAST(getConvertedStr(6, 10466))
		return false
	end
end

--全部删除按钮无效点击事件
function DlgMail:onLeftDisabledClicked( pView )
	-- body
	print("全部删除无效")
end

--一键领取按钮点击事件
function DlgMail:onCenterClicked( pView )
	if self.pListView:getItemCount() == 0 then
		TOAST(getConvertedStr(6, 10466))
		return
	end
	SocketManager:sendMsg("reqMailGet", {self.nCategory})
end

--全部已读按钮无效点击事件
function DlgMail:onCenterDisabledClicked( pView )
	-- body
	print("一键领取无效")
end

--全部已读按钮点击事件
function DlgMail:onRightClicked( pView )
	-- body
	if not self:isHasMail() then
		return
	end
	local pDlg = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setContent(getConvertedStr(3, 10223))
    pDlg:setRightHandler(function (  )
        SocketManager:sendMsg("reqMailReaded", {self.nCategory})
        pDlg:closeDlg(false)
    end)
    pDlg:showDlg(true)
end

--一键领取按钮无效点击事件
function DlgMail:onRightDisabledClicked( pView )
	-- body
	print("全部已读无效")
end

--展示底部层
function DlgMail:showBottomLayer( _nType )
	-- body
	if _nType == 1 then
		self.pLayBottomA:setVisible(true)
		self.pLayBottomB:setVisible(false)
	elseif _nType == 2 then
		self.pLayBottomA:setVisible(false)
		self.pLayBottomB:setVisible(true)
	end
end

function DlgMail:showCenterBtn(_bIsShow )
	-- body
	self.pLayCenter:setVisible(_bIsShow)
end

--下标选择回调事件
function DlgMail:onIndexSelected( _index )
	if _index == 1 then --报告
		self:showBottomLayer(1)
		self:showCenterBtn(false)
	elseif _index == 2 then --查看
		self:showBottomLayer(1)
		self:showCenterBtn(false)
	elseif _index == 3 then --系统
		self:showBottomLayer(1)
		self:showCenterBtn(true)
	elseif _index == 4 then --活动
		self:showBottomLayer(1)	
		self:showCenterBtn(true)	
	elseif _index == 5 then --保存
		self:showBottomLayer(2)
		self:showCenterBtn(false)
		self:updateMailSaveCnt()
	end
	--记录当前类型
	if _index == 4 then
		self.nCategory = e_type_mail.activity--活动
	elseif _index == 5 then
		self.nCategory = e_type_mail.saved--已保存
	else
		self.nCategory = _index
	end
	self:refreshMailList()
end

--创建listView
function DlgMail:createListView(_count, bIsLoadMore)
	self.pListView = createNewListView(self.pTComTabHost:getContentLayer(),nil,nil,nil,nil,nil,20)
	-- self.pListView = createNewListView(self.pLayTabHost)
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
	self.pListView:setItemCount(_count)
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pView = _pView
		if not pView then
			if self.tMailMsgList[_index] then
				pView = ItemMail.new(_index,self.tMailMsgList[_index])
			end
		end
		if _index and self.tMailMsgList[_index] then
			pView:setData(self.nCategory, self.tMailMsgList[_index])	
		end
		return pView
	end)
	--创建显示加载更多
	if bIsLoadMore then
		self.pFooterView = LoadMoreMail.new()
		self.pListView:addFooterView(self.pFooterView)
		self.pFooterView:setViewTouched(true)
		self.pFooterView:setIsPressedNeedScale(false)
		self.pFooterView:onMViewClicked(handler(self, self.reqLoadMoreMail))
	end
	self.pListView:reload()
end

--刷新邮件列表
function DlgMail:refreshMailList()
	if not self.nCategory then
		return
	end
	--判断是否请求服务器加载数据
	local bIsHasReq = Player:getMailData():getIsHasReqLoaded(self.nCategory)
	if bIsHasReq then
		--加载尾巴
		local bIsLoadMore = Player:getMailData():getIsHasLoadMore(self.nCategory)
		--刷新列表
		self.tMailMsgList = Player:getMailData():getMailMsgList(self.nCategory)
		local nMailCnt = #self.tMailMsgList
		if not self.pListView then
			self:createListView(nMailCnt, bIsLoadMore)
		else
			--移除尾巴
			if self.pFooterView then
				self.pListView:removeFooterView()
				self.pFooterView = nil
			end
			if bIsLoadMore then
				--创建显示加载更多
				self.pFooterView = LoadMoreMail.new()
				self.pListView:addFooterView(self.pFooterView)
				self.pFooterView:setViewTouched(true)
				self.pFooterView:setIsPressedNeedScale(false)
				self.pFooterView:onMViewClicked(handler(self, self.reqLoadMoreMail))
			end
			self.pListView:notifyDataSetChange(true, nMailCnt)
		end

		--隐藏或显示没有数据层
		self.pNullUi:setVisible(nMailCnt == 0)
		self.pListView:setVisible(nMailCnt ~= 0)
	else
		--请求列表数据
		self:reqLoadFirstMail()
	end
end

--更新保存邮件上下限
function DlgMail:updateMailSaveCnt(  )
	local nPageItemMax = Player:getMailData():getMailPageItemMax(e_type_mail.saved) or 0
	self.pBtnExText:setLabelCnCr(2, nPageItemMax)
end

--首次加载邮件
function DlgMail:reqLoadFirstMail(  )
	if not self.nCategory then
		return
	end
	SocketManager:sendMsg("reqMailLoad", {self.nCategory, 0})
end


--请求加载更多邮件
function DlgMail:reqLoadMoreMail(  )
	if not self.nCategory then
		return
	end
	local nCount = Player:getMailData():getCurrMailCount(self.nCategory)
	SocketManager:sendMsg("reqMailLoad", {self.nCategory, nCount})
end

--加载邮件返回
function DlgMail:onMailLoadReq( )
	self:updateMailSaveCnt()
end

--保存邮件成功
function DlgMail:onMailSaveSuccess(  )
	self:updateMailSaveCnt()
end

--取消保存邮件
function DlgMail:onMailSaveCancelSuccess(  )
	self:updateMailSaveCnt()
end

--更新红点
function DlgMail:updateRedNum(  )
	if not self.tNotReadNum then
		self.tRedTipNum = {}
	end
	--未读邮件个数
	local nNotReadNum
	local pTabItem = self.pTabItems[1]
	if pTabItem then --报告
		nNotReadNum = Player:getMailData():getNotReadNums(e_type_mail.report)
		showRedTips(pTabItem:getRedNumLayer(), 1, nNotReadNum, 2)
		self.tRedTipNum[1] = nNotReadNum
	end

	local pTabItem = self.pTabItems[2]
	if pTabItem then --侦查
		nNotReadNum = Player:getMailData():getNotReadNums(e_type_mail.detect)
		showRedTips(pTabItem:getRedNumLayer(), 1, nNotReadNum, 2)
		self.tRedTipNum[2] = nNotReadNum
	end

	local pTabItem = self.pTabItems[3]
	if pTabItem then --系统
		nNotReadNum = Player:getMailData():getNotReadNums(e_type_mail.system)
		showRedTips(pTabItem:getRedNumLayer(), 1, nNotReadNum, 2)
		self.tRedTipNum[3] = nNotReadNum
	end
	local pTabItem = self.pTabItems[4]
	if pTabItem then --活动
		nNotReadNum = Player:getMailData():getNotReadNums(e_type_mail.activity)
		showRedTips(pTabItem:getRedNumLayer(), 1, nNotReadNum, 2)
		self.tRedTipNum[4] = nNotReadNum
	end	
end

function DlgMail:onMailListRefresh( sMsgName, pMsgObj )
	if pMsgObj then
		--有改变的类别列表
		local tCategory = pMsgObj
		for i=1,#tCategory do
			local nCategory = tCategory[i]
			if nCategory == self.nCategory then
				self:refreshMailList()
				break
			end
		end
	else
		self:refreshMailList()
	end
end

return DlgMail