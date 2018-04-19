-- Author: liangzhaowei
-- Date: 2017-05-16 11:29:16
-- 城墙守卫操作花费


local DlgAlert = require("app.common.dialog.DlgAlert")
local MRichLabel = require("app.common.richview.MRichLabel")
local MBtnExText = require("app.common.button.MBtnExText")
local ItemWallNpcInfo = require("app.layer.wall.ItemWallNpcInfo")

local DlgOperateWallDefCost = class("DlgOperateWallDefCost", function ()
	return DlgAlert.new(e_dlg_index.operatewalldefcost)
end)

--构造
function DlgOperateWallDefCost:ctor()
	-- body
	self:myInit()
	parseView("dlg_operate_wall_def", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgOperateWallDefCost:myInit()
	-- body
	self.nNeedCost = 0   --需求金币
	self._nHandler = nil --回到事件
	self.pItemWallDef = nil --守卫信息item 
	self.nType =  1 --类型 (1提升界面,2治疗界面)
end
  
--解析布局回调事件
function DlgOperateWallDefCost:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgOperateWallDefCost",handler(self, self.onDlgOperateWallDefCostDestroy))
end

--初始化控件
function DlgOperateWallDefCost:setupViews()
	-- body

end

--设置数据
-- _nType 类型 (1.提升,2治疗) _nCost --花费 _pData 守卫数据
function DlgOperateWallDefCost:setCurdata(_nType,_nCost,_pData)


	--类型
	if _nType then
		if not _nType  then
			--todo
			self.nType = 1
		else
			self.nType = _nType
		end
		
	end



	--守卫数据
	if _pData then
       self.pData = _pData
	end

	self:updateViews()

	--花费金币
	if _nCost then
		self.nCost = _nCost
	end

end

-- 修改控件内容或者是刷新控件数据
function DlgOperateWallDefCost:updateViews()


	if not self.pData then
		return
	end


	gRefreshViewsAsync(self, 6, function ( _bEnd, _index )
		if _index == 1 then
			if not self.pLayTip then
				--设置右边按钮样式
				self:setRightBtnType(TypeCommonBtn.L_YELLOW)

				--提示内容层
				self.pLayTip = self:findViewByName("lay_tip")
				--设置右键按钮点击事件
				self:setRightHandler(handler(self, self.onCostClicked))
				--默认背景隐藏
				self:setContentBgTransparent()


			end
			
			--提示文本
			if not self.pLbTip then
				self.pLbTip  = self:findViewByName("lb_tip")
			end
			local strTitle = ""
			local strTips = ""
		    if self.nType == 1 then
		    	strTitle = getConvertedStr(5, 10077)
		    	strTips  = getConvertedStr(5, 10079)
		    elseif self.nType == 2 then
		    	strTitle = getConvertedStr(5, 10078)
		    	strTips  = getConvertedStr(5, 10080)
		    end

		    --设置提示文本
		    self.pLbTip:setString(strTips)

		    --守卫npc
		    if not self.pLyWallDef then
				self.pLyWallDef = self:findViewByName("ly_hero")
		    end

		   if not self.pItemWallDef then
		      self.pItemWallDef = ItemWallNpcInfo.new()
		      self.pLyWallDef:addView(self.pItemWallDef)
		   end
		   self.pItemWallDef:setCurData(self.pData,2) --只显示信息

			--复选框层
			if not self.pLayCheck then
				self.pLayCheck = self:findViewByName("lay_check")
			end
		   
			-- 提示到最高等级时 
			if self.nType == 1 and self.pData and self.pData.nCt == 0 then
				--移除底部
				self:removeBottom()
				self.pLbTip:setString(getConvertedStr(5, 10081))
				self.pLbTip:setPositionY(-50)
				self.pLayCheck:setVisible(false)
				return
			end

			--复选按钮层
			if not self.pLayCheckBox then
				self.pLayCheckBox = self:findViewByName("lay_checkbox")
				self.pCheckBox = MUI.MCheckBoxButton.new(
			        {on="#v1_img_gouxuan.png", off="#v1_img_gouxuankuang.png"})
				self.pLayCheckBox:addView(self.pCheckBox)
				centerInView(self.pLayCheckBox, self.pCheckBox)
			end

			--复选说明
			if not self.pLbCheckText then
				self.pLbCheckText = self:findViewByName("lb_checktext")
				self.pLbCheckText:setString(getConvertedStr(6, 10104))
				setTextCCColor(self.pLbCheckText, _cc.gray)
			end

			--按钮上的金币提示
			if not self.pBtnExText then
				local tBtnTable = {}
				tBtnTable.parent = self.pBtnRight
				tBtnTable.img = "#v1_img_qianbi.png"
				--文本
				tBtnTable.tLabel = {
					{self.nNeedCost,getC3B(_cc.blue)},
					{"/",getC3B(_cc.pwhite)},
					{"0",getC3B(_cc.pwhite)}
				}
				self.pBtnExText = MBtnExText.new(tBtnTable)
			end

			--设置标题
			self:setTitle(strTitle)

			--花费金币
			self:setNeedCost(self.nCost)

		end
	end)



end

--析构方法
function DlgOperateWallDefCost:onDlgOperateWallDefCostDestroy()
	self:onPause()
end

-- 注册消息
function DlgOperateWallDefCost:regMsgs( )
	-- body
end

-- 注销消息
function DlgOperateWallDefCost:unregMsgs(  )
	-- body
end


--暂停方法
function DlgOperateWallDefCost:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgOperateWallDefCost:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置当前需求值
function DlgOperateWallDefCost:setNeedCost(_nCost)
	-- body
	--设置拥有量
	self.pBtnExText:setLabelCnCr(3,Player:getPlayerInfo().nMoney)
	self.nNeedCost = _nCost or self.nNeedCost	
	--设置当前需求值
	self.pBtnExText:setLabelCnCr(1,self.nNeedCost)	
end

--设置回调事件
function DlgOperateWallDefCost:setCostHandler( _handler )
	-- body
	self._nHandler = _handler
end


--接收服务端发回的登录回调
function DlgOperateWallDefCost:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.wallDefChangeState.id then
        	if __msg.body then
        		-- dump(__msg.body)
        		if __msg.body.dt and __msg.body.dt[1] then
	        		local pServerData = __msg.body.dt[1]
	        		if pServerData then
	        			self.pData:refreshDatasByService(pServerData)
	        		end
        		end
	        	--刷新当前界面数据
	        	local nCost = 0
	        	if self.nType == 1 then
	        		if self.pData.nCt > 0 then
	        			nCost =  tonumber(getWallInitParam("trainCost"))
	        		end
        			self:setCurdata(self.nType,nCost,self.pData)
					self:updateViews()
					if self.pItemWallDef:getIcon() then
						playUpDefenseArm(self.pItemWallDef:getIcon())
					end
	        		--通知刷新城墙
	        		sendMsg(gud_refresh_wall)
	        	elseif self.nType == 2 then
	        		--通知刷新城墙
        			sendMsg(gud_refresh_wall)
	        		closeDlgByType(e_dlg_index.operatewalldefcost, fasle)
	        	end
        	end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end





--消费按钮点击事件回调
function DlgOperateWallDefCost:onCostClicked( pView )
	-- body
	if Player:getPlayerInfo().nMoney >= self.nNeedCost  then
		if self._nHandler then
			self._nHandler()
		end

		if self.pData and self.pData.sCodeId then
			if self.nType == 1 then --提升
				SocketManager:sendMsg("wallDefChangeState", {self.pData.sCodeId,2}, handler(self, self.onGetDataFunc))
				
			elseif self.nType == 2 then --治疗
				SocketManager:sendMsg("wallDefChangeState", {self.pData.sCodeId,1}, handler(self, self.onGetDataFunc))
			end
		end

	else
		local tObject = {}
		tObject.nType = e_dlg_index.dlgrechargetip --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)   
		self:closeAlertDlg()
	end
end
return DlgOperateWallDefCost
