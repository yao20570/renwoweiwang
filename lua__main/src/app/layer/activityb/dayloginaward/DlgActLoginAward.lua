--
-- Author: tanqian
-- Date: 2017-09-09 17:05:10
--活动每日收贡对话框
local DlgBase = require("app.common.dialog.DlgBase")
local IconGoods = require("app.common.iconview.IconGoods")
local DlgActLoginAward = class("DlgActLoginAward", function()
	return DlgBase.new(e_dlg_index.dlgactloginaward)
end)

function DlgActLoginAward:ctor(  )
	-- body
	self:myInit()
	
	parseView("dlg_act_login_award", handler(self, self.onParseViewCallback))

	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgActLoginAward",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgActLoginAward:myInit()
	self.tActData = nil
	self.tItemIcons = {} 
end

--解析布局回调事件
function DlgActLoginAward:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层

end

--初始化控件
function DlgActLoginAward:setupViews( )
	--ly
	self.pLyTitle     			= 		self.pView:findViewByName("all")
	self.pLyList     			= 		self.pView:findViewByName("lay_lists")

	--领取奖励提示标题
	--self.pTxtGetTips			=		self.pView:findViewByName("txt_tips")

	--礼包标题
	-- self.pTxtBtTitle			=		self.pView:findViewByName("txt_bottom_title")

	--刷新时间
	self.pTxtFresTime			=		self.pView:findViewByName("txt_refresh_time")
	setTextCCColor(self.pTxtFresTime, _cc.green)
	self.pTxtFresTime:setVisible(false)
	--充值按钮
	self.pImgBtnGet = self:findViewByName("img_btn_get")
	self.pImgBtnGet:setViewTouched(true)
	self.pImgBtnGet:setIsPressedNeedColor(false)
	self.pImgBtnGet:onMViewClicked(handler(self, self.onBtnClicked))
end

-- 修改控件内容或者是刷新控件数据
function DlgActLoginAward:updateViews()
	self.tActData = Player:getActById(e_id_activity.dayloginaward)
	if not self.tActData then
		self:closeDlg(false)
		return
	end

	  

    if self.tActData.sName then
		self:setTitle(self.tActData.sName)
    end

    if self.tActData.sDesc then
    	-- self.pTxtGetTips:setString(self.tActData.sDesc)
	
    end


	if not self.pActTime then
		--活动时间
		--self.pActTime = createActTime(self.pLyTitle,self.tActData,cc.p(28,1014))
	else
		--self.pActTime:setCurData(self.tActData)
	end
	
	if self.tActData.nRecevAward == 0 then  --奖励没有领取
		self.pImgBtnGet:setToGray(false)
		self.pImgBtnGet:setViewTouched(true)
		--self.pBtnGet:setBtnEnable(true)
		self.pTxtFresTime:setVisible(false)
	elseif self.tActData.nRecevAward == 1 then  --奖励已经领取
		--todo
		self.pTxtFresTime:setVisible(true)
		self.pImgBtnGet:setToGray(true)
		self.pImgBtnGet:setViewTouched(false)
		self:updateTime()
	end


	self.tItemIcons = {}
	local pListData = self.tActData:getAwdInfoByLv(Player.baseInfos.nLv)
	--刷新icon
	if pListData then
		--刷新位置
		local tGoodsData = getRewardItemsFromSever(pListData)
		local nItemCnt = #tGoodsData
		local nDis = (self.pLyList:getWidth() - nItemCnt*108)/(nItemCnt + 1)
		for i = 1, 4 do
			if not self.tItemIcons[i] then
				pIconGoods = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum) 
				pIconGoods:setPosition( nDis + (nDis + 108)*(i - 1),30)
				self.pLyList:addView(pIconGoods, 10)
				self.tItemIcons[i] = pIconGoods
			end
			if tGoodsData[i] then
				self.tItemIcons[i]:setVisible(true)
				self.tItemIcons[i]:setCurData(tGoodsData[i])
				
			else
				
				self.tItemIcons[i]:setVisible(false)
			end
		end	
	end

end

--去充值按钮点击事件
function DlgActLoginAward:onBtnClicked(pView)
	SocketManager:sendMsg("getActDayLoginReward", {}, function(__msg)
	
		if __msg.body and __msg.body.ob then
			--奖励动画展示
			showGetAllItems(__msg.body.ob, 1)
		end
		
	end)
end


function DlgActLoginAward:updateTime()
	--获取时间
	--
	if not self.tActData then
		return 
	end
	if  self.tActData.nRecevAward == 0 then
		return 
	end
	local nTime = self.tActData:getLeftTime()

	if nTime <= 0 then
		unregUpdateControl(self)
		self.pImgBtnGet:setViewTouched(true)
		self.pImgBtnGet:setToGray(false)
		self.pTxtFresTime:setVisible(false)
	else
		self.pTxtFresTime:setVisible(true)
		self.pTxtFresTime:setString(string.format(getConvertedStr(8, 10015),formatTimeToHms(nTime)))
	end
	
end

--继续方法
function DlgActLoginAward:onResume()
	-- body
	self:regMsgs()
	self:updateViews()
	
end

-- 注册消息
function DlgActLoginAward:regMsgs( )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

	--注册时间更新函数
	regUpdateControl(self, handler(self, self.updateTime))

end



-- 注销消息
function DlgActLoginAward:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

	--注销时间更新函数
	unregUpdateControl(self)
end


--暂停方法
function DlgActLoginAward:onPause( )
	-- body
	self:unregMsgs()
	
end

-- 析构方法
function DlgActLoginAward:onDestroy(  )
	-- body
	self:onPause()

	-- local pActData = Player:getActById(e_id_activity.updateplace)
	-- if pActData and pActData.bClose and pActData:bClose() then --已经领取
	-- 	Player:removeActById(e_id_activity.updateplace)
	-- end
end
return DlgActLoginAward
