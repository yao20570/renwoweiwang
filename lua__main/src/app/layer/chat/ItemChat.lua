-- Author: liangzhaowei
-- Date: 2017-06-06 21:06:54
--聊天item

local MCommonView = require("app.common.MCommonView")
local MailData = require("app.layer.mail.data.MailData")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local RichText = require("app.common.richview.RichText")
local RichTextEx = require("app.common.richview.RichTextEx")
local ItemChat = class("ItemChat", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local f_up_div = 7 -- 上边距离
local f_left_div = 10 -- 左边距离
local f_down_div = 10 -- 下边距离
local f_right_div = 10 -- 右边边距离
local f_arrow_diff = 10 -- 带箭头边的距离修正

local f_min_height = 80 -- 每行最低高度
local f_top_time_height = 35 -- 顶部时间需要显示的高度
local n_item_flew_h = 20 --整个item的偏移量 

local n_content_width = 400
local n_richtext_v_space = 4


--创建函数
function ItemChat:ctor( _data)
	-- body
	self:myInit()

	self.pData = _data

	if self.pData.nSid ~= Player.baseInfos.pid  then
		parseView("item_chat1", handler(self, self.onParseViewCallback))
		self.nType = 1
	else
		parseView("item_chat2", handler(self, self.onParseViewCallback))
		self.nType = 2
	end


	--注册析构方法
	self:setDestroyHandler("ItemChat",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemChat:myInit()
	self.pData = {} --数据
	self.pView = nil --item
	self.nType = 1 --聊天类型
	self.bIsUseRichText = false
end

--解析布局回调事件
function ItemChat:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self.pView = pView


	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemChat:setupViews( )



	if not self.pData then
		return
	end

	local pView = self.pView
	local pData = self.pData

	self.pLayIcon = pView:findViewByName("lay_icon")
	self.pAllItem = pView:findViewByName("item_chat") --整个view
	self.pTxtVip = pView:findViewByName("txt_vip") --vip等级
	self.pTxtName = pView:findViewByName("txt_name") --玩家名称
	self.pTxtCon = pView:findViewByName("txt_con")-- --聊天内容
	self.pLayCon = pView:findViewByName("lay_con") --聊天内容框
	self.pLayN = pView:findViewByName("lay_name")  --名字的框
	self.pLayTopTime = pView:findViewByName("lay_top_time") --时间的框
	self.pTxtTopTime = pView:findViewByName("txt_top_time") --时间文本呢
	self.pLbTime = pView:findViewByName("txt_time") --聊天时间,未用到
	self.pImgPos = pView:findViewByName("img_pos") --位置图片
	self.pLyPos = pView:findViewByName("ly_pos") --位置框
	self.pLbPos = pView:findViewByName("lb_pos") --位置文本
	self.pImgLaba = pView:findViewByName("img_laba") --喇叭图片(只有item_chat1有)
	self.nImgPosX = self.pImgPos:getPositionX()
	self.pHideLabel = display.newTTFLabel({text = "",
    font = "微软雅黑",
    size = 20,})--MUI.MLabel.new({text = "",size = 20})
	self.pHideLabel:setVisible(false)
	self:addView(self.pHideLabel)

	self.pLyPos:setViewTouched(true)
	self.pLyPos:onMViewClicked(function ( _pView )
	    print("执行MLayer的点击事件")
	   
	    --消息回调
	    local function onChatPosSw( __msg )
	    	if  __msg.head.state == SocketErrorType.success then 
		        if __msg.head.type == MsgType.chatPosSw.id then
		        	if __msg.body.btn then
		        		local nValue = nil
		        		if __msg.body.btn == 1 then--关闭
		        			nValue = "0"
		        			TOAST(getConvertedStr(3, 10460))
		        		elseif __msg.body.btn == 2 then--开启
		        			nValue = "1"
		        			TOAST(getConvertedStr(3, 10461))
		        		end
		        		if nValue then
		        			local sKey = "ShowChatArea"
			        		setSettingInfo(sKey, nValue)
		        		end
		        	end    	
		        end          
		    else
		        --弹出错误提示语
		        TOAST(SocketManager:getErrorStr(__msg.head.state))
		    end
	    end
	     --二次确认框
	    local DlgAlert = require("app.common.dialog.DlgAlert")
	    local pDlg = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))
	    pDlg:setContent(getConvertedStr(3, 10458))
	    pDlg:setLeftBtnText(getConvertedStr(3, 10459))
	    pDlg:setLeftHandler(function (  )
	        SocketManager:sendMsg("chatPosSw", {1}, onChatPosSw)
	        pDlg:closeDlg(false)
	    end)
	    pDlg:setRightBtnText(getConvertedStr(3, 10334))
	    pDlg:setRightHandler(function (  )
	        SocketManager:sendMsg("chatPosSw", {2}, onChatPosSw)
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)
	end)

	--内容点击操作
	self.pLayCon:setViewTouched(true)
	self.pLayCon:setIsPressedNeedScale(false)
    self.pLayCon:onMViewClicked(handler(self,self.onConClick))



	--头像
	-- v1_img_headlaba.png
	self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL,
	 type_icongoods_show.header, nil,0.8)
	self.pIcon:setPosition(self.pLayIcon:getWidth()*(0.8-1),self.pLayIcon:getHeight()*(0.8-1))
	self.pIcon:setIconClickedCallBack(handler(self, self.onItemClicked))

	-- --信息栏
	self.pText = MUI.MLabel.new({text = "",size = 18,color = getC3B(_cc.white)})
	self.pText:setAnchorPoint(cc.p(0,0))
	self.pLayN:addView(self.pText,10)

	-- vip图片文本
	local MImgLabel = require("app.common.button.MImgLabel")
	self.pVipText = MImgLabel.new({text="", size=18, parent=self.pLayN})
	self.pVipText:setImg("#v1_img_v_chat.png", 1, "left")

end

function ItemChat:setHandler(_handler )
	-- body
	if _handler then
		self.pHandler = _handler
	end
end


-- 修改控件内容或者是刷新控件数据
function ItemChat:updateViews()


	if not self.pData then
		return
	end

	local pData = self.pData

	local pView = self.pView
	local bOwn = false --是否为自己发的
	local bOpenPos = true --是否开启聊天位置

	if pData.sPos== ""  then
		bOpenPos = false
	end

	if pData.nMode and pData.nMode> 0 then
		self.pLayCon:setViewTouched(true)
	else
		self.pLayCon:setViewTouched(false)
	end

	--如果有网页可以跳转页可以点击
	if self.pData.strUrl then
		self.pLayCon:setViewTouched(true)
	end
		
	self:updatePlayerIcon()
	if pData.nSid ~= Player.baseInfos.pid  then
		bOwn = false
		--self.pIcon:setCurData(Player:getChatAvatorById(pData.nSid))		
	else
		bOwn = true
		--self.pIcon:setCurData(Player:getPlayerInfo():getActorVo())		
	end
	--刷新icon信息
	--dump(Player:getChatAvatorById(pData.nSid), "icon",100)	


	local fTmpH = 0 -- 当前高度
	local fTmpW = 0 -- 宽度

	--背景框
	-- if self.pData.sBox then
	-- 	self.pIcon:setIconBg(self.pData.sBox)
	-- end

	

	-- -- 如果是系统消息
	-- if(pData.nTmsg == 2) then
	-- 	self.pIcon:setIconImg("#v1_img_headlaba.png")
	-- end
	-- if(pData.nTmsg == 2 or pData.nSid == Player.baseInfos.pid) then
	-- 	self.pIcon:setViewTouched(false)
	-- else
	-- 	self.pIcon:setViewTouched(true)
	-- end

	--位置栏显示类型
	local nOpenPosT = 0 --不显示位置不显示时间
	if pData.nTmsg == 3 then--时间喇叭
		if bOpenPos then
			nOpenPosT = 2 --显示位置显示时间
		end
	else
		if bOpenPos then
			nOpenPosT = 1
		else
			nOpenPosT = 0--显示位置
		end
	end
	--位置
	local bShowPos = false
	if nOpenPosT == 1 or nOpenPosT == 2 then--仅仅显示位置 
		bShowPos = true
		self.pLyPos:setVisible(true)
		-- pData.pos = "广州东部地区"
		local sStr = {}
		if pData.sPos then
			self.pLyPos:setVisible(true)
			table.insert(sStr, {color=_cc.white, text=pData.sPos})			
		end
		-- if nOpenPosT == 2 then
		-- 	table.insert(sStr, {color=_cc.white, text=" "..self:formatShowTime(pData.nSt)})
		-- end
		self.pLbPos:setString(sStr,false)
		fTmpH = fTmpH + self.pLyPos:getHeight()--位置层高度计算
		--设置整体y轴
		self.pLyPos:setPositionY(self.pLyPos:getHeight()/2 - 10)
		self.pLyPos:setLayoutSize(self.pLbPos:getWidth()+10+self.pImgPos:getWidth()+10, self.pLyPos:getHeight())

		if bOwn then
			local nPosX = self.pLyPos:getWidth()- self.pLbPos:getWidth()- self.pImgPos:getWidth()
			self.pLbPos:setPositionX(nPosX+self.pImgPos:getWidth()/2)
			self.pLyPos:setPositionX(self.pLayIcon:getPositionX()-self.pLyPos:getWidth()-10)
			--向左偏移
			local nOffsetX = -10
			self.pImgPos:setPositionX(self.pLbPos:getPositionX() + nOffsetX)
		else
			--向左偏移
			local nOffsetX = -20
			self.pImgPos:setPositionX(self.nImgPosX + nOffsetX)
			self.pLbPos:setPositionX(self.pImgPos:getPositionX()+self.pImgPos:getWidth()/2)
			-- self.pLyPos:setPositionX(self.pLayCon:getPositionX()+10)
			--写死
			self.pLyPos:setPositionX(115)
		end
	else			
		-- fTmpH = fTmpH + self.pLyPos:getHeight()--位置层高度计算
		self.pLyPos:setVisible(false)
	end
	
	--显示时间
	if(pData.bShTime) then
		self.pLayTopTime:setVisible(true)
		self.pLayTopTime:setString(self:formatShowTime(pData.nSt),false)
		self.pLayTopTime:updateTexture()		
		self.pLayTopTime:setLayoutSize(self.pLayTopTime:getWidth()+35, self.pLayTopTime:getHeight())
		centerInView(self.pLayTopTime, self.pTxtTopTime)
		self.pLayTopTime:setPositionX(self.pAllItem:getWidth()/2 - self.pLayTopTime:getWidth()/2)
	else
		self.pLayTopTime:setVisible(false)
	end

	--增加文字层的高度
	fTmpH = fTmpH + self.pLayN:getHeight()

	--显示内容以及位置
	if(self.pLayCon) then

		local tStr = nil
		if type(pData.sCnt) == "table" then
			tStr = pData.sCnt
		else
            local eColor = nil
            if pData.nTmsg == 3 then
                -- 喇叭
				eColor = _cc.dyellow
			elseif pData.nTmsg == 1 and pData.nNid == nil then
                -- 玩家自己说的话
                eColor = _cc.white
			end
			tStr = getTextColorByConfigure(pData.sCnt, _cc.white)
		end

		--删除旧控件
		if self.pRichArea then
	    	self.pRichArea:removeFromParent(true)
	    	self.pRichArea = nil
	    end 

		--转换表情
		local tNewStr = clone(tStr) --为了不影响原数据
		-- tStr = removeSysEmoInTable(tNewStr)
		tStr = getTableParseEmo(tNewStr)

		self.pRichArea = RichTextEx.new({width = n_content_width, autow = true})
		self.pRichArea:setAnchorPoint(0, 0)
		self.pLayCon:addView( self.pRichArea, 1 )
        
		--改用控件
		self.pRichArea:setString(tStr)
		local pSize = self.pRichArea:getContentSize()
		local nRichTextWidth = pSize.width
		local nRichTextHeight = pSize.height
        
		self.pTxtCon:setVisible(false)
		fTmpW = nRichTextWidth + f_left_div + f_right_div + f_arrow_diff
		if(fTmpW < 95) then
			fTmpW = 95
		end
		local fMinH = nRichTextHeight + f_up_div + f_down_div
		local bMin = false
		if(fMinH < 46) then -- 最小高度不能小于46
			fMinH = 46
			bMin = true
		end

		self.pLayCon:setLayoutSize(fTmpW, fMinH)
		fTmpH = fTmpH + self.pLayCon:getHeight()

		if(bOwn) then -- 自己的排版
		    self.pRichArea:setPosition(f_left_div, fMinH/2-nRichTextHeight/2)
		else
		    self.pRichArea:setPosition(f_left_div + f_arrow_diff, fMinH/2-nRichTextHeight/2)
		end
	end


	local strText = {} --玩家信息字符列表


	--国家与官职
	local strCon = ""
	if pData.nAccperId and pData.nAccperId ~= 2 then --如果不是国家就加入国家信息
		if pData.nIe then	
			self:setCountryImg(pData.nIe)
			-- local sCountryNameImg=getCountryNameImg(pData.nIe)
			-- if not self.pImgCountryName then
			-- 	self.pImgCountryName = MUI.MImage.new(sCountryNameImg)
			-- 	self.pLayN:addChild(self.pImgCountryName)
			-- else
			-- 	self.pImgCountryName:setCurrentImage(sCountryNameImg)
			-- 	self.pImgCountryName:setVisible(true)
			-- end	

		end
	else

		if pData.nTmsg  ~= 3 then  -- 信息类型 1玩家,2系统信息 3世界喇叭

			if self.pImgCountryName then
				self.pImgCountryName:setVisible(false)
			end
		else
			if pData.nIe then		
				self:setCountryImg(pData.nIe)

			end
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

		--隐藏国家
		if self.pImgCountryName then
			self.pImgCountryName:setVisible(false)
		end
	else
		--官职文字
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



	--设置玩家信息位置
	-- local nFnFelw = (self.pLayN:getHeight()-self.pText:getHeight())/2
	-- if bOwn then
	-- 	self.pText:setPosition(self.pLayN:getWidth()-self.pText:getWidth()-10
	-- 		,nFnFelw)
	-- else
	-- 	self.pText:setPosition(0,nFnFelw)
	-- end
	local nFnFelw = (self.pLayN:getHeight()-self.pText:getHeight())/2
	local nCountryX,nOfficerX, nTextX,nVipTextX,nLabaX = 0, 0, 0,0,0
	if bOwn then
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
	--设置显示喇叭图片位置(世界喇叭独有)
	local nTxtPosX, nTxtPosY = nil, nil
	if pData.nTmsg == 3 then	
		-- dump(pData, "pData=", 100) 
		self.pImgLaba:setVisible(false)
		if not bOwn then --别人带喇叭
			-- self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang4.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang3b.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})
			self.pImgLaba:setPosition(nLabaX, 20)
		else --自己带喇叭
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang3.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})			
			self.pImgLaba:setPosition(nLabaX, 20)
		end
	else
		--不带喇叭
		if not bOwn then
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang1.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})
		else
			self.pLayCon:setBackgroundImage("#v1_img_liaotiankuang2.png",{scale9 = true, capInsets=cc.rect(43,30, 1, 1)})
		end
		self:setBackgroundImage("ui/daitu.png",{scale9 = true, capInsets=cc.rect(5,5, 1, 1)})
		self.pImgLaba:setVisible(false)
	end

	-- 记录最后的高度
	local fAddH = 0
	if(pData.bShTime) then --如果需要显示时间
		fAddH = f_top_time_height + 10 --时间高度
	end
	local fLastHeight = f_min_height + fAddH --每行的最低高度加上时间的高度
	if(self.pIcon and self.pIcon:isShowHeaderTitle() and (not bShowPos)) then
		fLastHeight = fLastHeight + 35
	end
	-- fTmpH 当前高度
	if(fTmpH+fAddH > fLastHeight) then
		fLastHeight = fTmpH + fAddH
	end

	-- n_item_flew_h 为调整的值
	fLastHeight = fLastHeight + n_item_flew_h
	self.pAllItem:setLayoutSize(self.pAllItem:getWidth(), fLastHeight)
	pView:setLayoutSize(self.pAllItem:getWidth(),self.pAllItem:getHeight())
	self:setLayoutSize(pView:getWidth(),pView:getHeight())
	-- 调整y值
	self.pLayIcon:setPositionY(fLastHeight-self.pLayIcon:getHeight()*self.pLayIcon:getScale()
		-self.pLayN:getHeight()/4-fAddH)

	self.pLayN:setPositionY(fLastHeight-self.pLayN:getHeight()-fAddH - 10)
	self.pLayCon:setPositionY(self.pLayN:getPositionY()-self.pLayCon:getHeight())
	self.pLayTopTime:setPositionY(fLastHeight-self.pLayTopTime:getHeight() - 10)
	-- 调整x值
	if(bOwn) then
		self.pLayCon:setPositionX(self.pLayIcon:getPositionX()-self.pLayCon:getWidth()-5)
	else
		self.pLayCon:setPositionX(90)
	end
end

-- 时间错转时分
function ItemChat:formatTimeHm( fTime)
	local tData = os.date("*t", fTime/1000)
	return string.format("%02d:%02d",tData.hour,tData.min )
end

-- 格式化时间显示
function ItemChat:formatShowTime( fTime )
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


--点击回调
function ItemChat:onItemClicked(pView)
	if self.pData and self.pData.nSid then
		--系统消息不打开
		if self.pData.nTmsg == e_chat_type.sys then
			return
		end
		if self.pData.bIsRb then    --机器人数据
			
			SocketManager:sendMsg("playWithRobot", {self.pData.nSid, 6}, function ( __msg ,__oldMsg)
				-- body
				if __msg.head.state == SocketErrorType.success	then
					--print("获取其他玩家数据成功！")
				    --查看玩家数据
				    local SPlayerData = require("app.layer.rank.SPlayerData")
				    if __msg.body.pm then
						local temp = SPlayerData.new()
						__msg.body.pm.rb = 1    --自己给他加上机器人标志
						temp:refreshDatasByService(__msg.body.pm)
						--刷新聊天头像数据				
						-- Player:recordPlayerCardInfo(temp)
						-- Player:getFriendsData():addRecentRecord(temp.nID, temp, 1, false)
						if not b_open_ios_shenpi then
							local tObj = {}
							tObj.tplayerinfo = temp
							tObj.tChatData = self.pData
							showRankPlayerInfo(tObj)						
						end
					end
				else		
					TOAST(SocketManager:getErrorStr(__msg.head.state))
				end			
			end)
		else
			local pMsgObj = {}
			pMsgObj.nplayerId = self.pData.nSid
			pMsgObj.tChatData = self.pData
			pMsgObj.bToChat = false
			--发送获取其他玩家信息的消息
			sendMsg(ghd_get_playerinfo_msg, pMsgObj)
		end
	end
end

--聊天内容回调
function ItemChat:onConClick(pView)
	if not self.pData then
		return
	end

	--公告跳转
	onSysNoticeJump(self.pData)

end



--获取当前item数据
function ItemChat:getData()
	local tData = nil
	if self.pData then
		tData = self.pData
	end	
	return tData
end

--设置数据
function ItemChat:setCurData(_data)
	if not _data then
       return 
	end
	self.pData = _data
	self:updateViews()
end


--析构方法
function ItemChat:onDestroy(  )
	-- body
end


function ItemChat:updatePlayerIcon( )	
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

function ItemChat:setCountryImg(_nCountryId )
	-- body
	local sCountryNameImg=getCountryNameImg(_nCountryId)
	if not self.pImgCountryName then
		self.pImgCountryName = MUI.MImage.new(sCountryNameImg)
		self.pLayN:addChild(self.pImgCountryName)
	else
		self.pImgCountryName:setCurrentImage(sCountryNameImg)
		self.pImgCountryName:setVisible(true)
	end	
end

return ItemChat