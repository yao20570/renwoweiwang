-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-06-19 17:52:23 星期一
-- Description: 首充活动界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local IconGoods = require("app.common.iconview.IconGoods")

local DlgFirstRecharge = class("DlgFirstRecharge", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgfirstrecharge)
end)

function DlgFirstRecharge:ctor(  )
	-- body
	self:myInit()
	--self:refreshData()
	parseView("dlg_first_recharge", handler(self, self.onParseViewCallback))
end

function DlgFirstRecharge:myInit(  )
	-- body
	self.tItemIcons = {}
	self.tActData  = nil --活动数据
end

function DlgFirstRecharge:refreshData()
	self.tActData = Player:getActById(e_id_activity.firstrecharge)
end

--解析布局回调事件
function DlgFirstRecharge:onParseViewCallback( pView )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10431))
	self:addContentView(pView) --加入内容层
	--self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgFirstRecharge",handler(self, self.onDlgFirstRechargeDestroy))
end

--初始化控件
function DlgFirstRecharge:setupViews(  )
	-- body
	--设置标题

	--ly
	self.pLyMain = self:findViewByName("root")


	self:setTitle(getConvertedStr(6,10431))
	self.pImgBg = self:findViewByName("img_bg")
	self.pImgBgKuang = self:findViewByName("img_bg_kuang")
	self.pImgBaoxiang = self:findViewByName("img_baoxiang")
	
	self.pLayTip1 = self:findViewByName("lay_tip_1")
	self.pLbDesc = self:findViewByName("lb_desc")
	self.pLayTip2 = self:findViewByName("lay_tip_2")	


	self.pLayTitle = self:findViewByName("lay_title")
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTitle:setString(getConvertedStr(6, 10433))

	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10217), false)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))


	self.pLayItems = self:findViewByName("lay_items")

	--说明组合文字
	local tConTable = {}
	--文本
	tConTable.tLabel= {
		{getConvertedStr(5, 10204),getC3B(_cc.white)},
		{getConvertedStr(5, 10205),getC3B(_cc.yellow)},
		{getConvertedStr(5, 10206),getC3B(_cc.white)},
		{getConvertedStr(5, 10207),getC3B(_cc.yellow)},
	}
	self.pText =  createGroupText(tConTable)
	self.pText:setAnchorPoint(cc.p(1,0.5))
	self.pLyMain:addView(self.pText,10)
	self.pText:setPosition(585, 975)

	--活动描述文字
	if self.tActData and self.tActData.sRule then
		local tStr = getTextColorByConfigure(self.tActData.sRule)
		self.pLbDesc:setString(tStr, false)
		-- self.pLbDesc:setAnchorPoint(cc.p(0,1))
		-- self.pLbDesc:setPosition(15, 85)
	end



end

--控件刷新
function DlgFirstRecharge:updateViews()
	if not self.tActData then
		self:closeDlg(false)
		return
	end

	if not self.pLyMain then
		self.pLyMain = self:findViewByName("root")	
		self.pImgBg = self:findViewByName("img_bg")
		self.pImgBgKuang = self:findViewByName("img_bg_kuang")
		self.pImgBaoxiang = self:findViewByName("img_baoxiang")
		
		self.pLayTip1 = self:findViewByName("lay_tip_1")
		self.pLbDesc = self:findViewByName("lb_desc")
		self.pLayTip2 = self:findViewByName("lay_tip_2")	


		self.pLayTitle = self:findViewByName("lay_title")
		self.pLbTitle = self:findViewByName("lb_title")
		self.pLbTitle:setString(getConvertedStr(6, 10433))

		self.pLayBtn = self:findViewByName("lay_btn")
		self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10217), false)
		self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))


		self.pLayItems = self:findViewByName("lay_items")

		--说明组合文字
		local tConTable = {}
		--文本
		tConTable.tLabel= {
			{getConvertedStr(5, 10204),getC3B(_cc.white)},
			{getConvertedStr(5, 10205),getC3B(_cc.yellow)},
			{getConvertedStr(5, 10206),getC3B(_cc.white)},
			{getConvertedStr(5, 10207),getC3B(_cc.yellow)},
		}
		self.pText =  createGroupText(tConTable)
		self.pText:setAnchorPoint(cc.p(1,0.5))
		self.pLyMain:addView(self.pText,10)
		self.pText:setPosition(585, 975)
	end


	--活动描述文字
	if self.tActData and self.tActData.sRule then
		local tStr = getTextColorByConfigure(self.tActData.sRule)
		self.pLbDesc:setString(tStr, false)
		-- self.pLbDesc:setAnchorPoint(cc.p(0,1))
		-- self.pLbDesc:setPosition(15, 85)
	end



	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLyMain,self.tActData,cc.p(25,1020))
	end
	self.pActTime:setCurData(self.tActData)

	if self.tActData.nT  then
		if self.tActData.nT == 0 then --不可领取
			self.pBtn:updateBtnText(getConvertedStr(5, 10204))
			self.pBtn:setBtnEnable(true)
		elseif self.tActData.nT == 1 then --可领取
			self.pBtn:updateBtnText(getConvertedStr(5, 10208))
			self.pBtn:setBtnEnable(true)
		elseif self.tActData.nT == 2 then --已领取
			self.pBtn:updateBtnText(getConvertedStr(5, 10209))
			self.pBtn:setBtnEnable(false)
		end
	end

	--刷新icon
	if self.tActData.tGs then
		--刷新位置
		local tGoodsData = getRewardItemsFromSever(self.tActData.tGs)
		local nItemCnt = #tGoodsData
		local nDis = (self.pLayItems:getWidth() - nItemCnt*108)/(nItemCnt + 1)
		for i = 1, 4 do
			if not self.tItemIcons[i] then
				pIconGoods = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum) 
				pIconGoods:setPosition( nDis + (nDis + 108)*(i - 1),30)
				self.pLayItems:addView(pIconGoods, 10)
				self.tItemIcons[i] = pIconGoods
			end
			if tGoodsData[i] then
				self.tItemIcons[i]:setVisible(true)
				self.tItemIcons[i]:setCurData(tGoodsData[i])
				addBgQualityTx(self.tItemIcons[i].pLayBgQuality, tGoodsData[i].nQuality)
			else
				removeBgQualityTx(self.tItemIcons[i].pLayBgQuality)
				self.tItemIcons[i]:setVisible(false)
			end
		end	
	end

end


--刷新界面
function DlgFirstRecharge:updateLayer()
	self:refreshData()
	self:updateViews()	
end

--按钮回调
function DlgFirstRecharge:onBtnClicked()	
	if self.tActData.nT  then
		if self.tActData.nT == 0 then --不可领取			
	        local tObject = {}
	        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	        sendMsg(ghd_show_dlg_by_type,tObject)   
		elseif self.tActData.nT == 1 then --可领取
			SocketManager:sendMsg("getFirstRecharge", {},handler(self, self.onGetDataFunc))	
		elseif self.tActData.nT == 2 then --已领取

		end
	end
end

--接收服务端发回的登录回调
function DlgFirstRecharge:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.getFirstRecharge.id then
       		-- self:updateViews()
       		if __msg.body.o then
				--获取物品效果
				showGetAllItems(__msg.body.o)
       		end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end



--析构方法
function DlgFirstRecharge:onDlgFirstRechargeDestroy(  )
	-- body
	self:onPause()
	local pActData = Player:getActById(e_id_activity.firstrecharge)
	if pActData and pActData.nT and pActData.nT== 2 then --已经领取
		Player:removeActById(e_id_activity.firstrecharge)
	end
	
end

--注册消息
function DlgFirstRecharge:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateLayer))


end
--注销消息
function DlgFirstRecharge:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end
--暂停方法
function DlgFirstRecharge:onPause( )
	-- body	
	self:unregMsgs()
	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgFirstRecharge:onResume( _bReshow )
	-- body	
	self:updateLayer()
	self:regMsgs()
end


return DlgFirstRecharge