-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-11-17 17:37:15 星期五
-- Description: 新版首充活动
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")

local DlgNewFirstRecharge = class("DlgNewFirstRecharge", function()
	-- body
	return MDialog.new()
end)

function DlgNewFirstRecharge:ctor( _eDlgType )
	-- body
	self.eDlgType = _eDlgType or e_dlg_index.dlgnewfirstrecharge
	self:myInit()
	parseView("dlg_new_first_recharge", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgNewFirstRecharge:myInit(  )
	-- body
	self.tItemIcons = {}
	self.tActData  = nil --活动数据
end


--解析布局回调事件
function DlgNewFirstRecharge:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgNewFirstRecharge",handler(self, self.onDlgNewFirstRechargeDestroy))
end

--初始化控件
function DlgNewFirstRecharge:setupViews(  )
	-- body
	--设置标题

	--ly
	self.pLyMain = self:findViewByName("default")

	--背景图
	self.pImgBg = self:findViewByName("lay_bg")

	--底部按钮
	self.pImgBtnBuy = self:findViewByName("img_btn_buy")
	self.pImgBtnBuy:setViewTouched(true)
	self.pImgBtnBuy:setIsPressedNeedColor(false)
	self.pImgBtnBuy:onMViewClicked(handler(self, self.onGoRecharge))

	--右上角关闭按钮
	local pLayBtnClose = self:findViewByName("lay_btn_close")
	pLayBtnClose:setViewTouched(true)
	pLayBtnClose:setIsPressedNeedScale(false)
	pLayBtnClose:setIsPressedNeedColor(false)
	pLayBtnClose:onMViewClicked(handler(self, self.onClickClose))

end

--控件刷新
function DlgNewFirstRecharge:updateViews()
	self.tActData = Player:getActById(e_id_activity.newfirstrecharge)
	if not self.tActData then
		self:closeDlg(false)
		return
	end
	-- dump(self.tActData,"DlgNewFirstRecharge")
	if self.tActData.nT then
		if self.tActData.nT == 0 then --不可领取
			self.pImgBtnBuy:setCurrentImage("#v2_btn_chongzhi.png")
			self.pImgBtnBuy:setToGray(false)
		elseif self.tActData.nT == 1 then --可领取
			self.pImgBtnBuy:setCurrentImage("#v2_btn_lingqu.png")
			self.pImgBtnBuy:setToGray(false)
		elseif self.tActData.nT == 2 then --已领取
			self.pImgBtnBuy:setCurrentImage("#v2_btn_lingqu.png")
			self.pImgBtnBuy:setToGray(true)
			self.pImgBtnBuy:setViewTouched(false)
		end
	end

end

--关闭界面
function DlgNewFirstRecharge:onClickClose( )
	self:closeDlg(false)
end


--底部按钮回调
function DlgNewFirstRecharge:onGoRecharge()	
	if self.tActData.nT  then
		if self.tActData.nT == 0 then --不可领取			
	        local tObject = {}
	        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	        sendMsg(ghd_show_dlg_by_type,tObject)   
		elseif self.tActData.nT == 1 then --可领取
			SocketManager:sendMsg("getNewFirstRechargeAwards", {},handler(self, self.onGetDataFunc))	
		elseif self.tActData.nT == 2 then --已领取

		end
	end
end

--接收服务端发回的登录回调
function DlgNewFirstRecharge:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.getNewFirstRechargeAwards.id then
       		if __msg.body.o then
				--获取物品效果
				showGetItemsAction(__msg.body.o)
				
       		end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end



--析构方法
function DlgNewFirstRecharge:onDlgNewFirstRechargeDestroy(  )
	-- body
	self:onPause()
	local pActData = Player:getActById(e_id_activity.newfirstrecharge)
	if pActData and pActData.nT == 2 then --已经领取
		Player:removeActById(e_id_activity.newfirstrecharge)
		
		-- local tActData2= Player:getActById(e_id_activity.severalrecharge) 		--多次充值	
		-- if tActData2  and tActData2:isCanGetRecharge() ~= 2 then
		-- local tObject = {} 
		-- 	tObject.nType = e_dlg_index.dlgseveralrecharge --dlg类型

		-- 	sendMsg(ghd_show_dlg_by_type,tObject)
		-- end
	end
	
end

--注册消息
function DlgNewFirstRecharge:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))


end
--注销消息
function DlgNewFirstRecharge:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end
--暂停方法
function DlgNewFirstRecharge:onPause( )
	-- body	
	self:unregMsgs()
	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgNewFirstRecharge:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end


return DlgNewFirstRecharge