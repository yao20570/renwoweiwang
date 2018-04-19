-- Author: maheng
-- Date: 2017-11-30 17:50:54
--红包

local MCommonView = require("app.common.MCommonView")
local MailData = require("app.layer.mail.data.MailData")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local RichText = require("app.common.richview.RichText")
local ItemRedPocket = class("ItemRedPocket", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemRedPocket:ctor( _data)
	-- body
	self:myInit()
	self.pData = _data

	if self.pData.nSid ~= Player.baseInfos.pid  or self.pData.nTmsg == 2 then
		parseView("item_chat_rp1",handler(self, self.onParseViewCallback))--红包
		self.nType = 1
	else
		parseView("item_chat_rp2",handler(self, self.onParseViewCallback))
		self.nType = 2
	end		

	--注册析构方法
	self:setDestroyHandler("ItemRedPocket",handler(self, self.onDestroy))
	
end

function ItemRedPocket:regMsgs(  )
	regMsg(self, ghd_catch_red_pocket, handler(self, self.onResetPocketState))
	
end
function ItemRedPocket:unregMsgs(  )
	unregMsg(self, ghd_catch_red_pocket)
end

--初始化参数
function ItemRedPocket:myInit()
	self.pData = {} --数据
	self.pView = nil --item
	self.nType = 1 --聊天类型
	self.bIsUseRichText = false
	self.bIsClick = false
end

--解析布局回调事件
function ItemRedPocket:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:onResume()
	self.pView = pView
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemRedPocket:setupViews( )
	-- body
	if not self.pData then
		return
	end
	-- dump(self.pData, "self.pData", 100)
	local pView = self.pView

	self.pLayCon=pView:findViewByName("lay_content")
	self.pLayIcon = pView:findViewByName("lay_icon")
	self.pLayN = pView:findViewByName("lay_name")  --名字的框

	self.pImgTitle=pView:findViewByName("img_title")
	self.pImgTitle:setCurrentImage(self.pData.sChatCardTitle)

	self.pImgBg=pView:findViewByName("img_bg")
	self.pImgBg:setCurrentImage(self.pData.sChatCardBg)
	self.pImgCountry=pView:findViewByName("img_country")

	if self.pData.nSid ~= Player.baseInfos.pid then
		self.pImgBg:setFlippedX(true)
	end

	self.pLbDetail=pView:findViewByName("lb_detail")
	local sStr=getTextColorByConfigure(self.pData.sChatCardDetail)
	self.pLbDetail:setString(sStr)

	self.pLbTip = pView:findViewByName("lb_tip")
	setTextCCColor(self.pLbTip, _cc.syellow)
	self.pLbTip:setString(getConvertedStr(6, 10620))

	self.pLayRpDec = self:findViewByName("lay_rp_status")
	self.pLbRPDesc = self:findViewByName("lb_rp_desc")
	self.pImgLaba = pView:findViewByName("img_laba") --喇叭图片(只有item_chat1有)
	--国家旗子
	--img
	-- self.pImgFlag = self:findViewByName("img_flag")--国家
	self:addIcon()
	self:addMsg()	
end
--添加头像
function ItemRedPocket:addIcon(  )
	-- body
	--头像
	-- v1_img_headlaba.png
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL,
	type_icongoods_show.header, nil,0.8)
	self.pIcon:setPosition(self.pLayIcon:getWidth()*(0.8-1),self.pLayIcon:getHeight()*(0.8-1))
	self.pIcon:setIconClickedCallBack(handler(self, self.onItemClicked))

end
--添加发送者的信息
function ItemRedPocket:addMsg( )
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

function ItemRedPocket:setHandler(_handler )
	-- body
	if _handler then
		self.pHandler = _handler
	end
end


-- 修改控件内容或者是刷新控件数据
function ItemRedPocket:updateViews()
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
	local sStr = ""
	if self.pData.nRpt == 0 then--未领取
		sStr = ""
	elseif self.pData.nRpt == 1 then--已经领取
		if self.pData.nTmsg == 5 then
			sStr = {
				{color=_cc.white, text=getConvertedStr(9, 10171)}
			}
		else
			sStr = {
				{color=_cc.white, text=string.format(getConvertedStr(6, 10623), self.pData.sSn)},
				{color=_cc.syellow, text=getConvertedStr(6, 10621)}
			}
		end
		
	elseif self.pData.nRpt == 2 then--红包抢完
		sStr = {
			{color=_cc.syellow, text=getConvertedStr(6, 10621)},
			{color=_cc.white, text=getConvertedStr(6, 10622)}			
		}
	end
	self.pLbRPDesc:setString(sStr, false)
	self.pLayRpDec:setVisible(self.pData.nRpt ~= 0)
	local nWidth = self.pLbRPDesc:getPositionX() + self.pLbRPDesc:getWidth() + 20
	if nWidth < 180 then
		nWidth = 180
	end 

	self.pLayRpDec:setLayoutSize(nWidth, self.pLayRpDec:getHeight())
	-- self.pLayRpDec:setContentSize(nWidth, self.pLayRpDec:getHeight())
	if self.nType == 2 then
		local nX = self.pLayCon:getPositionX() + self.pLayCon:getWidth() - nWidth
		--print("----------nX=", nX)
		self.pLayRpDec:setPositionX(nX)
	end

	self:updatePlayerMsg()

	--内容点击操作
	self.pLayCon:setViewTouched(true)
	self.pLayCon:setIsPressedNeedScale(false)
    self.pLayCon:onMViewClicked(handler(self,self.onConClick))	

    self:updateLaba()
end

-- 时间错转时分
function ItemRedPocket:formatTimeHm( fTime)
	local tData = os.date("*t", fTime/1000)
	return string.format("%02d:%02d",tData.hour,tData.min )
end

-- 格式化时间显示
function ItemRedPocket:formatShowTime( fTime )
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
function  ItemRedPocket:updatePlayerMsg( )
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
	if pData.nTmsg == 2 or pData.nTmsg == 5 then
		self.pVipText:setVisible(false)
		local tStr = {}
		tStr.text = pData.sSenderNameDb   --getConvertedStr(5, 10218)
		tStr.color = _cc.purple
		table.insert(strText,tStr)
		--显示发送时间
			table.insert(strText, {color=_cc.blue, text=getSpaceStr(1)..self:formatTimeHm(pData.nSt)}) 
		self.pVipText:hideImg()		
	else
		self.pVipText:setVisible(true)
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
		
		-- nTextX = nVipTextX - self.pText:getWidth()
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

function ItemRedPocket:updateLaba( )
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
function ItemRedPocket:onItemClicked(pView)
	if self.pData and self.pData.nSid then
		--系统消息不打开
		if self.pData.nTmsg == e_chat_type.sys or self.pData.nTmsg == e_chat_type.sysRedPocket then
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
function ItemRedPocket:onConClick(pView)
	if not self.pData then
		return
	end
	if self.bIsClick == true then
		return
	end
	if self.pData.nRpId and self.pData.nRpId > 0 then--红包
		--dump(self.pData, "self.pData", 100)
		local nRpId = self.pData.nRpId
		local nRpT = self.pData.nRpt 
		self.bIsClick = true
		SocketManager:sendMsg("checkredpocket", {nRpId}, function ( __msg, __oldMsg )
			-- body
			if __msg.head.type == MsgType.checkredpocket.id then 		--查看红包
				if __msg.head.state == SocketErrorType.success then
					local pRPData = {}	
					pRPData.nRpId = __oldMsg[1]
					pRPData.pData = __msg.body	
					pRPData.nChatID = self.pData.nSid
					pRPData.tChatData = self.pData
					if __msg.body.get == 0 then			
						local tObj = {}
						tObj.nType = e_dlg_index.dlgredpocketopen
						tObj.pData = pRPData
						sendMsg(ghd_show_dlg_by_type,tObj)
					else
						local tObj = {}
						tObj.nType = e_dlg_index.dlgredpocketcheck
						tObj.pData = pRPData
						sendMsg(ghd_show_dlg_by_type,tObj)	
					end
					self.pData.nRpt = __msg.body.get					
					self:updateViews()--刷新数据
				else
				    TOAST(SocketManager:getErrorStr(__msg.head.state))
		        end
		    end	
		    self.bIsClick = false   
		end) 	  	 	
	end

end

--获取当前item数据
function ItemRedPocket:getData()
	local tData = nil
	if self.pData then
		tData = self.pData
	end	
	return tData
end

--设置数据
function ItemRedPocket:setCurData(_data)
	if not _data then
       return 
	end
	--dump(_data, "_data", 100)
	self.pData = _data
	self:updateViews()
end

--析构方法
function ItemRedPocket:onDestroy(  )
	-- body
	self:onPause()
end

function ItemRedPocket:updatePlayerIcon( ... )
	-- body	
	local pData = self.pData
	if not pData then
		return
	end
	local pActorData = nil
	if pData.nSid ~= Player.baseInfos.pid  then	
		pActorData = Player:getChatAvatorById(pData.nSid) 			
	else

		pActorData = Player:getPlayerInfo():getActorVo()		
	end
	self.pIcon:setCurData(pActorData)		
	self.pIcon:setIconTitleImg(pActorData.sTitle) 
	if pData.sSenderNameIcon then
		self.pIcon:setIconImg(pData.sSenderNameIcon)
	end	
    if(pData.nTmsg == 2 or pData.nSid == Player.baseInfos.pid) then
		self.pIcon:setViewTouched(false)
	else
		self.pIcon:setViewTouched(true)
	end
end

function ItemRedPocket:onResetPocketState( _sMsgName,_tMsgObj )
	-- body
	if _tMsgObj and _tMsgObj.nRpId and _tMsgObj.nRpt then
		if _tMsgObj.nRpId == self.pData.nRpId then
			self.pData.nRpt = _tMsgObj.nRpt
			self:updateViews()
		end
	end
end

--暂停方法
function ItemRedPocket:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function ItemRedPocket:onResume( )
	-- body
	-- self:updateViews()
	self:regMsgs()
end

return ItemRedPocket