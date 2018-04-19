-- Author: liangzhaowei
-- Date: 2017-06-06 21:06:54
--聊天item

local MCommonView = require("app.common.MCommonView")
local MailData = require("app.layer.mail.data.MailData")
local ItemChatCard = class("ItemChatCard", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemChatCard:ctor( _data)
	-- body
	self:myInit()
	self.pData = _data
	if self.pData.nSid ~= Player.baseInfos.pid then--不是我发的
		parseView("item_chat_card1",handler(self, self.onParseViewCallback))
		self.bOwn=false
		self.nType = 1
	else
		parseView("item_chat_card2",handler(self, self.onParseViewCallback))
		self.bOwn=true
		self.nType = 2
	end	
	--注册析构方法
	self:setDestroyHandler("ItemChatCard",handler(self, self.onDestroy))
	
end

function ItemChatCard:regMsgs(  )
	regMsg(self, gud_world_my_callinfo_refresh, handler(self, self.updateViews))
end
function ItemChatCard:unregMsgs(  )
	unregMsg(self, gud_world_my_callinfo_refresh)
	
end

--初始化参数
function ItemChatCard:myInit()
	self.pData = {} --数据
	self.pView = nil --item
	self.nType = 1 --聊天类型
	self.bIsUseRichText = false
	self.bOwn=false
end

--解析布局回调事件
function ItemChatCard:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self.pView = pView
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemChatCard:setupViews( )
	if not self.pData then
		return
	end
	local pView = self.pView

	self.pLayCon=pView:findViewByName("lay_content")
	self.pLayIcon = pView:findViewByName("lay_icon")
	self.pLayN = pView:findViewByName("lay_name")  --名字的框

	self.pImgTitle=pView:findViewByName("img_title")

	self.pImgBg=pView:findViewByName("img_bg")

	self.pImgCountry=pView:findViewByName("img_country")


	self.pLbDetail=pView:findViewByName("lb_detail")


	self.pLbTargetTitle=pView:findViewByName("lb_target_title")
	self.pLbTargetTitle:setString(getConvertedStr(9,10026))
	self.pLbPosTitle=pView:findViewByName("lb_pos_title")
	self.pLbPosTitle:setString(getConvertedStr(9,10027))

	self.pLbTarget=pView:findViewByName("lb_target")
	self.pLbTargetPos=pView:findViewByName("lb_target_pos")

	self.pLayBuildIcon=pView:findViewByName("lay_build_icon")		--建筑图片
	self.pImgLaba = pView:findViewByName("img_laba") --喇叭图片(只有item_chat1有)


	self:addIcon()
	self:addMsg()
end
--添加头像
function ItemChatCard:addIcon(  )
	-- body
	--头像
	-- v1_img_headlaba.png
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL,
	type_icongoods_show.header, nil,0.8)
	self.pIcon:setPosition(self.pLayIcon:getWidth()*(0.8-1),self.pLayIcon:getHeight()*(0.8-1))
	self.pIcon:setIconClickedCallBack(handler(self, self.onItemClicked))

end
--添加发送者的信息
function ItemChatCard:addMsg( )
	-- body
	-- --信息栏
	if not self.pText then
		self.pText = MUI.MLabel.new({text = "",size = 18,color = getC3B(_cc.white)})
		self.pText:setAnchorPoint(cc.p(0,0))
		self.pLayN:addView(self.pText,10)
	else
		self.pText:setString("")
	end
	

	-- vip图片文本
	local MImgLabel = require("app.common.button.MImgLabel")
	self.pVipText = MImgLabel.new({text="", size=18, parent=self.pLayN})
	self.pVipText:setImg("#v1_img_v_chat.png", 1, "left")
end

function ItemChatCard:setHandler(_handler )
	-- body
	if _handler then
		self.pHandler = _handler
	end
end


-- 修改控件内容或者是刷新控件数据
function ItemChatCard:updateViews()
	-- body
	local pData = self.pData
	self:updatePlayerIcon()
	if pData.nSid ~= Player.baseInfos.pid  then
		self.bOwn = false
		--self.pIcon:setCurData(Player:getChatAvatorById(pData.nSid))		
	else
		self.bOwn = true
		--self.pIcon:setCurData(Player:getPlayerInfo():getActorVo())		
	end
	-- if self.pData.tPoint then
	-- 	local sPoint=tostring(self.pData.tPoint.x) .."," ..tostring(self.pData.tPoint.y)
	-- 	self.pLbTargetPos:setString(sPoint)
	-- end

	if self.pData.sShareContent then 
		self.pLbTarget:setString(self.pData.sShareContent)
	end
	--print(self.pData.sShareContent2)
	if self.pData.sShareContent2 then 
		self.pLbTargetPos:setString(self.pData.sShareContent2)
	end
	self.pImgCountry:setVisible(true)
	self.pImgCountry:setCurrentImage(WorldFunc.getCountryFlagImg(self.pData.nDc))

	-- if self.pData.nDc then
		
	-- else
	-- 	self.pImgCountry:setVisible(false)
	-- end
	self:updatePlayerMsg()

	--内容点击操作
	self.pLayCon:setViewTouched(true)
	self.pLayCon:setIsPressedNeedScale(false)
    self.pLayCon:onMViewClicked(handler(self,self.onConClick))

    -- 如果是系统消息
	-- if(self.pData.nTmsg == 2) then
	-- 	self.pIcon:setIconImg("#v1_img_headlaba.png")
	-- end
	-- if(self.pData.nTmsg == 2 or self.pData.nSid == Player.baseInfos.pid) then
	-- 	self.pIcon:setViewTouched(false)
	-- else
	-- 	self.pIcon:setViewTouched(true)
	-- end

	local sStr=getTextColorByConfigure(self.pData.sChatCardDetail)
	self.pLbDetail:setString(sStr)

	self.pImgBg:setCurrentImage(self.pData.sChatCardBg)
	
	self.pImgTitle:setCurrentImage(self.pData.sChatCardTitle)

    self:updateBuildIcon()
    self:updateLaba()
end

-- 时间错转时分
function ItemChatCard:formatTimeHm( fTime)
	local tData = os.date("*t", fTime/1000)
	return string.format("%02d:%02d",tData.hour,tData.min )
end

-- 格式化时间显示
function ItemChatCard:formatShowTime( fTime )
	local sStr = ""
	local tData = os.date("*t", fTime/1000)
	local fCurTime = getSystemTime()
	local tCurData = os.date("*t", fCurTime)
	local fDisTime = fTime/1000 - fCurTime
	if(tCurData.year == tData.year and tData.yday == tCurData.yday) then -- 同一天
		if(tData.hour <= 9) then
			tData.hour = "0" .. tData.hour
		end
		if(tData.min <= 9) then
			tData.min = "0" .. tData.min
		end
		sStr = getConvertedStr(5, 10134) .. tData.hour .. ":" .. tData.min
	elseif(tCurData.year == tData.year and tCurData.yday-tData.yday == 1) then -- 昨天
		if(tData.hour <= 9) then
			tData.hour = "0" .. tData.hour
		end
		if(tData.min <= 9) then
			tData.min = "0" .. tData.min
		end
		sStr = getConvertedStr(5, 10135) .. tData.hour .. ":" .. tData.min
	else
		sStr = formatTime(fTime)
	end
	return sStr
end
--显示发送者的信息
function  ItemChatCard:updatePlayerMsg( )
	-- body
	local pData=self.pData
	local strText = {} --玩家信息字符列表
	-- self.pImgFlag:setVisible(false)

	--国家与官职
	local strCon = ""
	if pData.nAccperId and pData.nAccperId ~= 2 then --如果不是国家就加入国家信息
		if pData.nIe then			
			local sCountryNameImg=getCountryNameImg(pData.nIe)
			if not self.pImgCountryName then
				self.pImgCountryName = MUI.MImage.new(sCountryNameImg)
				self.pLayN:addChild(self.pImgCountryName)
			else
				self.pImgCountryName:setCurrentImage(sCountryNameImg)
				self.pImgCountryName:setVisible(true)
			end	
		end
	else
		if self.pImgCountryName then
			self.pImgCountryName:setVisible(false)
		end
	end
	if pData.nBt and pData.nBt > 0 then
		local tData=getNationTransport(pData.nBt)
		if tData then
			strCon = getCountryOfficerImg(tonumber(tData.officer))--官职
			if strCon and strCon ~= "" then

				if not self.pImgOfficer then
					self.pImgOfficer = MUI.MImage.new(strCon)
					self.pLayN:addChild(self.pImgOfficer)
				else
					self.pImgOfficer:setCurrentImage(strCon)
					self.pImgOfficer:setVisible(true)

				end
			end
		end
	else
		if self.pImgOfficer then
			self.pImgOfficer:setVisible(false)
		end
	end

	--如果是系统消息
	if(pData.nTmsg == 2) then
		local tStr = {}
		tStr.text = getConvertedStr(5, 10218)
		tStr.color = _cc.purple
		table.insert(strText,tStr)

		self.pVipText:hideImg()
		self.pVipText:setString("")
	else
		-- --官职文字
		-- if strCon ~= "" then
		-- 	local tStr = {}
		-- 	tStr.text = strCon.."  "
		-- 	tStr.color = _cc.purple
		-- 	table.insert(strText,tStr)
		-- end

		--名字
		if pData.sSn and  pData.sSn ~= "" then
			local tStr = {}
			tStr.text = pData.sSn..getSpaceStr(2)
			tStr.color = _cc.blue
			table.insert(strText,tStr)
		end	

		--vip
		local tVipStr = {}
		if pData.nVip  then
			local tVipData = getAvatarVIPByLevel(pData.nVip)
			if tVipData then
				self.pVipText:setImg("#".. tVipData.icon..".png")
				local sStr = "V".. pData.nVip
				if pData.nVip < 10 then
					sStr = "V ".. pData.nVip
				end
				if not self.pLbVip then
					self.pLbVip = MUI.MLabel.new({text = sStr,size = 14})
					local pVipImg = self.pVipText:getImg()
					pVipImg:addChild(self.pLbVip)
					self.pLbVip:setPosition(pVipImg:getWidth()/2-5, pVipImg:getHeight()/2 - 5)
					self.pLbVip:setLocalZOrder(111)
				else
					self.pLbVip:setString(sStr)
				end

				setTextCCColor(self.pLbVip,getVipColor(pData.nVip))
			end

			-- local tStr = {}
			-- tStr.text = pData.nVip
			-- tStr.color = _cc.yellow
			-- table.insert(tVipStr,tStr)
		else
			if self.pLbVip then
				self.pLbVip:setVisible(false)
			end
			self.pVipText:hideImg()
		end


		--玩家游戏所在区域
		if pData.nAccperId ~= e_lt_type.sj then -- 世界频道屏蔽区域信息
			if pData.nS and pData.nS> 0 and getWorldMapDataById(pData.nS) and getWorldMapDataById(pData.nS).name then
				local tStr = {}
				tStr.text = getWorldMapDataById(pData.nS).name
				tStr.color = _cc.white
				table.insert(tVipStr,tStr)
			end
		end
		--显示发送时间
		table.insert(tVipStr, {color=_cc.blue, text=getSpaceStr(1)..self:formatTimeHm(pData.nSt)}) 
		self.pVipText:setString(tVipStr, false)
		self.pVipText:showImg()
	end

	if strText and table.nums(strText)> 0 then
		self.pText:setString(strText,false)
	end

	local nFnFelw = (self.pLayN:getHeight()-self.pText:getHeight())/2
	local nCountryX,nOfficerX, nTextX,nVipTextX,nLabaX = 0, 0, 0,0,0
	if self.bOwn then
		nVipTextX = self.pLayN:getWidth()-self.pVipText:getWidth() - 61
		nTextX = nVipTextX - self.pText:getWidth()
		if self.pImgOfficer and self.pImgOfficer:isVisible() then
			nOfficerX = nTextX - self.pImgOfficer:getWidth()/2 -5

		end
		if self.pImgCountryName and self.pImgCountryName:isVisible() then
			if nOfficerX ~=0 then
				nCountryX = nOfficerX - self.pImgCountryName:getWidth()/2 - self.pImgOfficer:getWidth()/2 -5
			else
				nCountryX = nTextX - self.pImgCountryName:getWidth() /2 -5

			end

		end
		
		
		nLabaX  = nTextX - 20
	else
		if self.pImgCountryName and self.pImgCountryName:isVisible() then
			nCountryX = nCountryX + self.pImgCountryName:getWidth()/2
			nTextX = nCountryX +self.pImgCountryName:getWidth()/2 +5
		end
		if self.pImgOfficer and self.pImgOfficer:isVisible() then
			if nCountryX ~=0 then
				nOfficerX = nCountryX + self.pImgCountryName:getWidth()/2 + self.pImgOfficer:getWidth()/2 + 5
			else
				nOfficerX = nOfficerX + self.pImgOfficer:getWidth() /2
			end
			nTextX = nOfficerX +self.pImgOfficer:getWidth()/2 +5


		end

		nVipTextX = nTextX+ self.pText:getWidth()
		nLabaX = nVipTextX + self.pVipText:getWidth() + 50
	end
	self.pText:setPosition(nTextX, nFnFelw)
	self.pVipText:followPos("left", nVipTextX+ 5, self.pLayN:getHeight() / 2 , 0, 5 )
	if self.pImgCountryName and self.pImgCountryName:isVisible() then
		self.pImgCountryName:setPosition(nCountryX,self.pImgCountryName:getHeight()/2 + 5 )

	end
	if self.pImgOfficer and self.pImgOfficer:isVisible() then
		self.pImgOfficer:setPosition(nOfficerX,self.pImgOfficer:getHeight()/2 + 5 )

	end

end


function ItemChatCard:updateLaba( )
	-- body
	if self.pData.nTmsg == 3 then	
		-- dump(pData, "pData=", 100) 
		self.pImgLaba:setVisible(true)
		if not self.bOwn then --别人带喇叭
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang4.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})
			self.pImgLaba:setPosition(nLabaX, 20)
		else --自己带喇叭
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang3.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})			
			self.pImgLaba:setPosition(nLabaX, 20)
		end
	else
		--不带喇叭
		if not self.bOwn then
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang1.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})
		else
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang2.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})
		end
		self:setBackgroundImage("ui/daitu.png",{scale9 = true, capInsets=cc.rect(5,5, 1, 1)})
		self.pImgLaba:setVisible(false)
	end
end


--点击回调
function ItemChatCard:onItemClicked(pView)
	if self.pData and self.pData.nSid then
		--系统消息不打开
		if self.pData.nTmsg == e_chat_type.sys then
			return
		end
		local pMsgObj = {}
		pMsgObj.nplayerId = self.pData.nSid
		pMsgObj.tChatData = self.pData
		pMsgObj.bToChat = false
		--发送获取其他玩家信息的消息
		sendMsg(ghd_get_playerinfo_msg, pMsgObj)
	end
end

--聊天内容回调
function ItemChatCard:onConClick(pView)
	if not self.pData then
		return
	end
	if self.pData.strUrl then
   	 	gotoHttpAddress(self.pData.strUrl)
	else
		if self.pData.nMode == 1 then --界面
			self:junpToLayer()
		elseif self.pData.nMode == 2 then--仅活动1
			if self.pData.nWay then
				local nAct = 0
				for k,v in pairs(e_id_activity) do
					if self.pData.nWay == v then
						nAct = v
					end
				end
				if (nAct == 0 )or (nAct > 2000) then
					myprint("不正确的跳转id,该类型支持活动1")
					return
				end
				local pBActivity = Player:getActById(self.pData.nWay)--
				if pBActivity then
					local tObject = {}
					tObject.nType = e_dlg_index.actmodela --dlg类型
					tObject.nActID = self.pData.nWay
					sendMsg(ghd_show_dlg_by_type,tObject)
				else
					TOAST(getConvertedStr(6, 10522))
				end
			end
		elseif self.pData.nMode == 3 then   --世界
			 sendMsg(ghd_home_show_base_or_world, 2)
			 if self.pData.tPoint and self.pData.tPoint.x and self.pData.tPoint.y then
			 	sendMsg(ghd_world_location_dotpos_msg, {nX = self.pData.tPoint.x, nY = self.pData.tPoint.y, isClick = true, tOther = {bIsOpenCWar = true}})
			 end
			 closeDlgByType(e_dlg_index.dlgchat)

		end
		--todo
	end

end

--跳转到界面
function ItemChatCard:junpToLayer()
	if not self.pData then
		return
	end

	if self.pData.nWay then
		--打开对话框
	    local tObject = {}
 		tObject.nType = self.pData.nWay --dlg类型


-- -- type	int	查询个人分享所在频道
-- -- cid	long	查询个人分享的聊天信息的id
-- MsgType.checkShareMoreCnt = {id=-4534, keys = {"type","cid"}}
	-- dump(self.pData.nAccperId,"self.pData.nAccperId")
	    if self.pData.nWay == e_dlg_index.heroinfo then--英雄详情
	    	SocketManager:sendMsg("checkShareMoreCnt", {self.pData.nAccperId,self.pData.nId},function (__msg)
    		    if  __msg.head.state == SocketErrorType.success then 
			        if __msg.head.type == MsgType.checkShareMoreCnt.id then
			        	-- dump( __msg.body," __msg.body")
			       		if __msg.body and __msg.body.hvo and __msg.body.hvo.h then
			       			local pHeroData = getHeroDataById(__msg.body.hvo.h)
			       			if pHeroData then
			       				pHeroData:refreshDatasByService(__msg.body.hvo)
			       				tObject.tData = pHeroData
			       				sendMsg(ghd_show_dlg_by_type,tObject)
			       			end
			       		end
			        end
			    else
			        --弹出错误提示语
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
	    	end)
	   	elseif self.pData.nWay == e_dlg_index.maildetail then--邮件数据
			SocketManager:sendMsg("checkShareMoreCnt", {self.pData.nAccperId,self.pData.nId},function (__msg)
    		    if  __msg.head.state == SocketErrorType.success then 
			        if __msg.head.type == MsgType.checkShareMoreCnt.id then
			       		if __msg.body and __msg.body.mvo then --打开邮件
			       			local pMail = MailData:createMailMsg( __msg.body.mvo )
			       			if pMail then
			       				tObject.tMailMsg = pMail
			       				tObject.bShare = 1
			       				sendMsg(ghd_show_dlg_by_type,tObject)
			       			end
			       		end
			        end
			    else
			        --弹出错误提示语
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
	    	end)
		elseif self.pData.nWay == e_dlg_index.equipdetails then
	    	SocketManager:sendMsg("checkShareMoreCnt", {self.pData.nAccperId,self.pData.nId},function (__msg)
    		    if  __msg.head.state == SocketErrorType.success then 
			        if __msg.head.type == MsgType.checkShareMoreCnt.id then			        	
			       		if __msg.body and __msg.body.evo then
							local EquipVo = require("app.layer.equip.data.EquipVo")			       			
			       			local pEquipData = EquipVo.new(__msg.body.evo)
			       			if pEquipData then
			       				tObject.tData = pEquipData
			       				sendMsg(ghd_show_dlg_by_type,tObject)
			       			end
			       		end
			        end
			    else
			        --弹出错误提示语
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
	    	end)			
	    elseif self.pData.nWay == e_dlg_index.dlgweaponshareinfo then--神兵详情
	    	SocketManager:sendMsg("checkShareMoreCnt", {self.pData.nAccperId,self.pData.nId},function (__msg)
    		    if  __msg.head.state == SocketErrorType.success then 
			        if __msg.head.type == MsgType.checkShareMoreCnt.id then
			        	-- dump( __msg.body," __msg.body")
			       		if __msg.body and __msg.body.avo and __msg.body.avo.i then
			       			tObject.tData = __msg.body.avo
			       			sendMsg(ghd_show_dlg_by_type,tObject)
			       		end
			        end
			    else
			        --弹出错误提示语
			        TOAST(SocketManager:getErrorStr(__msg.head.state))
			    end
	    	end)
	   	elseif self.pData.nWay == e_dlg_index.tnolytree then --科技树
	   		local tScetionData = nil
	   		if self.pData.nGuide then
	   			tScetionData = getGoodsByTidFromDB(self.pData.nGuide)
	   		end
	   		--跳转到科技树界面
			tObject.tData = tScetionData
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.pData.nWay == e_dlg_index.dlgvipprivileges then --充值
			tObject.nVipLv = self.pData.nJumpNum or 1
			sendMsg(ghd_show_dlg_by_type,tObject)  
	   	else
		    sendMsg(ghd_show_dlg_by_type,tObject)
	    end
	end
end

--获取当前item数据
function ItemChatCard:getData()
	local tData = nil
	if self.pData then
		tData = self.pData
	end	
	return tData
end

--设置数据
function ItemChatCard:setCurData(_data)
	if not _data then
       return 
	end
	--dump(_data, "_data", 100)
	self.pData = _data
	self:updateViews()
end

function ItemChatCard:updateBuildIcon( )
	-- body
	if self.pData.nShareType then
		if self.pData.nShareType==e_share_type.boss then --纣王分享
			local pImg = WorldFunc.getBossIconOfContainer(self.pLayBuildIcon, self.pData.tPa.dl)
		elseif self.pData.nShareType == e_share_type.player 
			or self.pData.nShareType==e_share_type.city 
			or self.pData.nShareType==e_share_type.citywar 
			or self.pData.nShareType==e_share_type.becitywar then 		--玩家城池分享
			local pImg = WorldFunc.getCityIconOfContainer(self.pLayBuildIcon, self.pData.tPa.dc,self.pData.tPa.dl)
			if pImg then
				local scale=120 / pImg:getWidth()
				if scale>1 then
					scale=1
				end

				pImg:setScale(scale)
			end
			if self.pData.nShareType==e_share_type.becitywar then 		--被人打发起的求援显示攻击方和防守方的名字等级
				self.pLbTargetTitle:setString(getConvertedStr(9,10055))
				self.pLbPosTitle:setString(getConvertedStr(9,10056))
			end
		elseif self.pData.nShareType == e_share_type.syscity or self.pData.nShareType==e_share_type.countrywar then  		--系统城池分享
			local pImg = WorldFunc.getSysCityIconOfContainer(self.pLayBuildIcon, self.pData.tPa.did,self.pData.tPa.dl)
			if pImg then
				local scale=120 / pImg:getWidth()
				if scale>1 then
					scale=1
				end

				pImg:setScale(scale)
			end
			if self.pData.nShareType==e_share_type.countrywar then 		--被人打发起的求援显示攻击方和防守方的名字等级
				self.pLbPosTitle:setString(getConvertedStr(9,10108))
			end

		elseif self.pData.nShareType == e_share_type.call then  		--召唤
			-- local tStr =string.format("%s/%s",tostring(self.pData.nJs),tostring(self.pData.nCns))
        	-- local tViewDotMsg = Player:getWorldData():getViewDotMsg(self.pData.tPa.dx,self.pData.tPa.dy)
        	self.pImgCountry:setVisible(false)
        	self.pLbPosTitle:setString(getConvertedStr(9,10028))
        	--设置内容
			local sStr =string.format("%s/%s", tostring(self.pData.tPa.rn),tostring(self.pData.tPa.cannum))
			self.pLbTargetPos:setString(sStr, false)
   

			local pImg = WorldFunc.getCityIconOfContainer(self.pLayBuildIcon, self.pData.tPa.ac,self.pData.tPa.al)
			if pImg then
				local scale=120 / pImg:getWidth()
				if scale>1 then
					scale=1
				end
				pImg:setScale(scale)
			end

			if self.pData.nS and self.pData.nS> 0 and getWorldMapDataById(self.pData.nS) and getWorldMapDataById(self.pData.nS).name then
				self.pLbTarget:setString(getBlockShowName(self.pData.nS))--(getWorldMapDataById(self.pData.nS).name)
			end
		elseif self.pData.nShareType == e_share_type.bosssupport then  		--纣王求援
			local pImg = WorldFunc.getBossIconOfContainer(self.pLayBuildIcon, self.pData.tPa.dl)
			if pImg then
				local scale=120 / pImg:getWidth()
				if scale>1 then
					scale=1
				end

				pImg:setScale(scale)
			end
		elseif self.pData.nShareType == e_share_type.ghostsupport then  		--冥界求援
			local pImg = WorldFunc.getGhostIconOfContainer(self.pLayBuildIcon, self.pData.tPa.aId)
			if pImg then
				local scale=120 / pImg:getWidth()
				if scale>1 then
					scale=1
				end

				pImg:setScale(scale)
			end
		end
	end
end

--析构方法
function ItemChatCard:onDestroy(  )
	-- body
	self:unregMsgs()
end

function ItemChatCard:updatePlayerIcon( )	
	-- body
	local pData = self.pData
	local pActorData = nil
	if pData.nSid ~= Player.baseInfos.pid  then	
		pActorData = Player:getChatAvatorById(pData.nSid) 			
	else
		pActorData = Player:getPlayerInfo():getActorVo()		
	end
	self.pIcon:setCurData(pActorData)		
	self.pIcon:setIconTitleImg(pActorData.sTitle) 	
	-- 如果是系统消息
	if(self.pData.nTmsg == 2) then
		self.pIcon:setIconImg("#v1_img_headlaba.png")
	end
	if(self.pData.nTmsg == 2 or self.pData.nSid == Player.baseInfos.pid) then
		self.pIcon:setViewTouched(false)
	else
		self.pIcon:setViewTouched(true)
	end
end

return ItemChatCard