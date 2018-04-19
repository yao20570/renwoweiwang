-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-08-05 17:34:12
-- Description: 登坛拜将
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemHeroMansion = require("app.layer.activityb.heromansion.ItemHeroMansion")

local DlgHeroMansion = class("DlgHeroMansion", function()
	-- body
	return DlgBase.new(e_dlg_index.heromansion)
end)

function DlgHeroMansion:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_hero_mansion", handler(self, self.onParseViewCallback))

	
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroMansion",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgHeroMansion:myInit()
	-- body
	--购买item
	self.tBuyItem = {}
	self.nSelect = 0 --当前选择
end

--更新数据
function DlgHeroMansion:refreshData()
	-- body
	self.tActData = Player:getActById(e_id_activity.heromansion)
end

--解析布局回调事件
function DlgHeroMansion:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()

end


-- 修改控件内容或者是刷新控件数据
function DlgHeroMansion:updateViews(  )
	self:refreshData()
	if not self.tActData then
		self:closeDlg(false)
		return
	end

	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then

		  if not self.pLyTitle then

		  	  --创建标题
			  self.pLyTitle     			= 		self.pView:findViewByName("ly_title")
			  local pTitle = getActivityTitleA(self.tActData)--创建title
			  local pTitleContent = pTitle:getContent()
			  local pDesLayer = getActivityTitleDes(self.tActData)--创建描述层
			  if pDesLayer and pTitleContent then
			  	pTitleContent:addView(pDesLayer,1) 
			  end
			  if pTitle then
			  	self.pLyTitle:addView(pTitle,1)
			  end

			  local pGetReward = getActivityTitleReward()--获得物品层
			  if pTitleContent and pGetReward then
			  	pTitleContent:addView(pGetReward,1)
			  	pGetReward:setPosition(435, 0)
			  end




			  self.pLyRewardBtn  = pGetReward:getLyBtn()--reward 中的按钮
  			  --英雄icon
  			  self.pLyRewardIcon = pGetReward:getLyIcon()--reward 的Icon

			  self.pRewardBtn    =  getCommonButtonOfContainer(self.pLyRewardBtn,TypeCommonBtn.O_YELLOW,getConvertedStr(5,10264))
			  self.pRewardBtn:onCommonBtnClicked(handler(self, self.onBtnRewardClicked))



			  self.pMain                    =       self.pView:findViewByName("dlg_hero_mansion")

			  --活动时间
			  self.pActTime = createActTime(self.pLyTitle, self.tActData, cc.p(0, 240))

		  	  --武将信息
			  self.pLyHeroInfo =self.pView:findViewByName("ly_hero_info")
			  self.pLyHeroInfo:setVisible(true)
			  self.pLbHeroInfo =self.pView:findViewByName("lb_info")

  			  self.pHeroData = getGoodsByTidFromDB(self.tActData.nHid) 
  			  if self.pHeroData then
	  			  	local tText = {
	  			  	{text =self.pHeroData:getHeroTypeName().." ",color = _cc.pwhite },
	  			  	{text =self.pHeroData:getHeroQualityText().." ",color =getColorByQuality(self.pHeroData.nQuality) },
	  			  	{text = getConvertedStr(5, 10265).." ",color = _cc.pwhite},
	  			  	{text =self.pHeroData.nBaseTalentSum,color = _cc.blue },
	  			  }
				  	self.pLbHeroInfo:setString(tText)
				  	--英雄icon
				  	local pHeroIcon = getIconHeroByType(self.pLyRewardIcon,TypeIconHero.NORMAL,self.pHeroData,TypeIconHeroSize.M)	
				  	pHeroIcon:setIconClickedCallBack(handler(self,self.checkHeroInfo))
  			  end
			  --界面名称
		   	  if self.tActData.sName then
				self:setTitle(self.tActData.sName)
	  		  end

	  		  --按钮
			  self.pLyBtn     			= 		self.pView:findViewByName("ly_bot_btn")
			  self.pBtn                 =  getCommonButtonOfContainer(self.pLyBtn,TypeCommonBtn.L_YELLOW,getConvertedStr(5,10258))
			  self.pBtn:onCommonBtnClicked(handler(self, self.onBtnLClicked))			  

	  		  --文本
			  self.pLbShowTime     		= 		self.pView:findViewByName("lb_show_time")--恢复时间
			  setTextCCColor(self.pLbShowTime,_cc.red)
			  self.pLbCostCoin     		= 		self.pView:findViewByName("lb_cost_coin")--花费金币

		  end

			local tReLabel = {}
			tReLabel.tLabel = {
				{self.pHeroData.sName},
				{self.tActData.np,getC3B(_cc.green)},
				{"/"..self.tActData.nSp,getC3B(_cc.white)},
			}

		  --招募武将
		  if not self.pRewardEx then
		  	self.pRewardEx =   self.pRewardBtn:setBtnExText(tReLabel)
		  else
		  	self.pRewardEx:setLabelCnCr(2,self.tActData.np)--设置领取数目
		  end


		  if self.tActData.ns and self.tActData.ns == 0 then
		  	 self.pRewardBtn:updateBtnText(getConvertedStr(5, 10264))
		  else
		  	 self.pRewardBtn:updateBtnText(getConvertedStr(5, 10279))
		  	 self.pRewardBtn:setBtnEnable(false)
		  end

		   -- self.pRewardBtn




		  --刷新按钮
		  if self.tActData.nF1 > 0 then
		  	self.pBtn:updateBtnType(TypeCommonBtn.L_BLUE)
		  else
		  	self.pBtn:updateBtnType(TypeCommonBtn.L_YELLOW)
		  end

		  if not self.pLayRed then
		  	self.pLayRed = self:findViewByName("lay_red")		  	
		  end
		  showRedTips(self.pLayRed, 0, self.tActData.nFRed)	

		  	if not self.pLbHaveTime then
			  self.pLbHaveTime     		= 		self.pView:findViewByName("lb_have_time")--免费次数
		  	end

 		    local tHaveTimeLb = {
			   	{text= getConvertedStr(5, 10259),color = _cc.pwhite},
			   	{text= self.tActData.nF1,color = _cc.blue},
			   	{text= "/"..self.tActData.nF2,color = _cc.pwhite},
			   }
		    self.pLbHaveTime:setString(tHaveTimeLb)

		    --花费提示
		    if not self.pLbCostTip then
			  self.pLbCostTip     		= 		self.pView:findViewByName("lb_cost_tip")--花费提示
		    end
			local str = getConvertedStr(5, 10261)
			if self.tActData.nF1 > 0 then
				str = getConvertedStr(5, 10262)
			end
			self.pLbCostTip:setString(str,false)

			local nImgX = self.pLbCostTip:getPositionX()+self.pLbCostTip:getWidth() + 10
			local nImgY = self.pLbCostTip:getPositionY()

			if self.tActData.nF1 > 0 then
				if self.pImgLabel then
					self.pImgLabel:setVisible(false)
				end
			else
				if not self.pImgLabel then
					self.pImgLabel = MImgLabel.new({text=self.tActData.nRg, size = 20, parent = self.pMain})
					self.pImgLabel:setAnchorPoint(0,0.5)
					self.pImgLabel:setImg("#v1_img_qianbi.png")
					self.pImgLabel:followPos("left",nImgX,nImgY,10)
				end
				self.pImgLabel:setVisible(true)
			end

			-- self.pImgLabel:P


			-- self.pImgLabel = MImgLabel.new({text="1845", size = 20, parent = self.pMain})
			-- self.pImgLabel:setImg("#v1_img_qianbi.png")
			-- self.pImgLabel:setPosition(,
			--  )
		elseif _index == 3 then
			if not self.pLyList then
				self.pLyList     			= 		self.pView:findViewByName("ly_list")
			end

			--buyItem
			for i=1,6 do
				if not self.tBuyItem[i] then
					local nFlewX = 0
					local nFlewY = 0
					self.tBuyItem[i] = ItemHeroMansion.new(i)
					if i%2 == 0 then
						nFlewX = self.tBuyItem[i]:getWidth()
					end
					local nPosY = (3 - math.floor((i+1)/2))
					nFlewY =  self.tBuyItem[i]:getHeight() * nPosY
					self.tBuyItem[i]:setPosition(nFlewX, nFlewY+15*(nPosY+1))
					self.tBuyItem[i]:setViewHandler(handler(self, self.onViewClick))
					self.pLyList:addView( self.tBuyItem[i], i )
				end
				if self.tActData.tCs and self.tActData.tCs[i] then
					self.tBuyItem[i]:setCurData(self.tActData.tCs[i],self.nSelect)
				end
			end
		end
	end)
end

--按钮回调
function DlgHeroMansion:onBtnLClicked()
	if not self.tActData then
		return
	end
	-- dump("click...")
-- type	int	0免费 1花费
-- [4011][登坛拜将2007]刷新物品
-- MsgType.freshHeroMansion = {id=-4011, keys = {"type"}}

	local nType = 0
	local nDs=self.tActData:getSale() * 100

	if self.tActData.nF1 and self.tActData.nF1 > 0 then
		nType = 0
		local strTips = getTextColorByConfigure(string.format(getConvertedStr(9,10053),nDs)) 
		showBuyDlg(strTips,0,function ()
			SocketManager:sendMsg("freshHeroMansion", {nType},handler(self, self.onGetDataFunc))
		end, 1, true)				
	else
		nType = 1
		local strTips = getTextColorByConfigure(string.format(getConvertedStr(9, 10054),nDs, self.tActData.nRg)) 
		showBuyDlg(strTips,self.tActData.nRg,function ()
			SocketManager:sendMsg("freshHeroMansion", {nType},handler(self, self.onGetDataFunc))	
		end, 1, false)
	end
end

--item点击回调
function DlgHeroMansion:onViewClick(_pData)
	if _pData then
       self.nSelect = _pData
	end
	self:updateViews()
end

--招募回调
function DlgHeroMansion:onBtnRewardClicked(pView)


	-- self:showGetHero()

	if self.tActData and self.tActData.np and self.tActData.nSp then
		if self.tActData.np < self.tActData.nSp then
			if self.pHeroData and self.pHeroData.sName then
				TOAST(string.format(getConvertedStr(5, 10277),self.tActData.nSp,self.pHeroData.sName) )
			end
		else
			if self.tActData.ns and self.tActData.ns == 0 then
				SocketManager:sendMsg("recruitHeroMansion", {},handler(self, self.onGetDataFunc))
			else
				--todo
			end
		end
	end



end

--接收服务端发回的登录回调
function DlgHeroMansion:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.freshHeroMansion.id then

        elseif  __msg.head.type == MsgType.recruitHeroMansion.id then
        	self:showGetHero()
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end

--展示获得英雄
function DlgHeroMansion:showGetHero()
	local tDataList = {}
	local tKvData = {}
	tKvData.k = self.tActData.nHid
	tKvData.v = 1
	local tReward = {}
	tReward.d = {}
	tReward.g = {}
	table.insert(tReward.d, copyTab(tKvData))
	table.insert(tReward.g, copyTab(tKvData))
	table.insert(tDataList, tReward)

	--dump(tDataList, "tDataList", 100)
	--打开招募展示英雄对话框
    local tObject = {}
    tObject.nType = e_dlg_index.showheromansion --dlg类型
    tObject.tReward = tDataList
    sendMsg(ghd_show_dlg_by_type,tObject)
end


--时间更新函数
function DlgHeroMansion:updateCd()
	if self.tActData:getRecoverCD() and self.pLbShowTime then
		if self.tActData:getRecoverCD() > 0 then
			self.pLbShowTime:setVisible(true)
			self.pLbShowTime:setString(string.format(getConvertedStr(5, 10260),formatTimeToHms(self.tActData:getRecoverCD())))
		else
			self.pLbShowTime:setVisible(false)
		end
	end
end

function DlgHeroMansion:checkHeroInfo( tData )
	-- body	
	local tObject = {}
	tObject.nType = e_dlg_index.heroinfo --dlg类型
	tObject.tData = tData
	sendMsg(ghd_show_dlg_by_type,tObject)
end

-- 析构方法
function DlgHeroMansion:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroMansion:regMsgs( )
	regUpdateControl(self, handler(self, self.updateCd))
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end

-- 注销消息
function DlgHeroMansion:unregMsgs(  )
	unregUpdateControl(self)
	unregMsg(self, gud_refresh_activity)
end


--暂停方法
function DlgHeroMansion:onPause( )
	-- body
	self:unregMsgs()
	local pActData = Player:getActById(e_id_activity.heromansion)
	if pActData then
		pActData:resetRecoverRed()		
	end
end

--继续方法
function DlgHeroMansion:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgHeroMansion