----------------------------------------------------- 
-- author: liangzhaowei
-- Date: 2017-05-04 16:40:00
-- Description: 招募英雄
-----------------------------------------------------
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroInfo = require("app.layer.hero.ItemHeroInfo")

local DlgConscribeHero = class("DlgConscribeHero", function()
	return DlgCommon.new(e_dlg_index.conscribehero)
end)

--_tData 英雄列表  _nCost 英雄花费 _nId 关卡id
function DlgConscribeHero:ctor(_tData,_nCost,_nId)
	self:myInit()
	self.tData = _tData or {}
	self.nCost = _nCost or 0
	self.nPostId = _nId or 0

	parseView("dlg_fuben_buy_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgConscribeHero:onParseViewCallback( pView )

	self.pView =  pView

	self:addContentView(pView,true) --加入内容层

	self:setTitle(getConvertedStr(5, 10042))

	self.pLayMain = self:findViewByName("ly_main")

	self:setOutSideHandler(handler(self, self.onOutsideHandler))

	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgConscribeHero",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgConscribeHero:myInit(  )
	-- body
	self.tData  = {} --招募英雄列表数据
	self.tItemHeroList = {} -- 招募英雄列表详情item
	self.nCost = 0 --购买英雄花费
	self.nPostId = 0 --关卡id

end

-- 析构方法
function DlgConscribeHero:onDestroy(  )
    self:onPause()
end

function DlgConscribeHero:regMsgs(  )
end

function DlgConscribeHero:unregMsgs(  )
end

function DlgConscribeHero:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgConscribeHero:onPause(  )
	self:unregMsgs()
end


function DlgConscribeHero:updateViews(  )
	--ly
	if not self.pBtn then
		--创建招募按钮
		self.pBtn = self:getOnlyConfirmButton(TypeCommonBtn.L_BLUE,getConvertedStr(5,10043))
		self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClick))
	end


	--招募按钮文字
	if self.nCost and self.nCost > 0  then
		self.pBtn:setButton(TypeCommonBtn.L_YELLOW,getConvertedStr(5,10044)) --武将招募
		--添加购买花费

		local tBtnTable = {}
		--文本
		tBtnTable.img = "#v1_img_qianbi.png"
		local tLabel = {
			{tostring(self.nCost),getC3B(_cc.pWhite)},
		}
		tBtnTable.tLabel = tLabel

		--因为需要修改位置,因此必须放在后面
		self.pBtn:setBtnExText(tBtnTable)

	else
		self.pBtn:setButton(TypeCommonBtn.L_BLUE,getConvertedStr(5,10043)) --免费招募
	end

--	gRefreshViewsAsync(self, 2, function ( _bEnd, _index )
--		if _index == 1 then
			if not self.pLyBtn  then
				self.pLyBtn = self:findViewByName("ly_btn")

				--创建招募英雄详情
				if self.tData and table.nums(self.tData)> 0 then
					local tName = {}
					for k,v in pairs(self.tData) do
						self.tItemHeroList[k] = ItemHeroInfo.new(v)
						self.tItemHeroList[k]:setViewTouched(false)
						self.tItemHeroList[k]:setAnchorPoint(cc.p(0.5, 0.5))
						self.tItemHeroList[k].nKey = v.nKey

						table.insert(tName, {sName = v.sName, nQuality = v.nQuality})
						self.pView:addView(self.tItemHeroList[k],3)
						local nGap = (self.pView:getWidth()-self.tItemHeroList[k]:getWidth()*2)/3
						if table.nums(self.tData) == 2 then
							self.tItemHeroList[k]:setPosition( nGap* k + self.tItemHeroList[k]:getWidth()*(k-1), 30)
						else
							self.tItemHeroList[k]:setPosition(self.pView:getWidth()/2-self.tItemHeroList[k]:getWidth()/2, 30)
						end
					end
					--招募说明
					local pLbtip = self:findViewByName("lb_tip")
					if not self.pLbtip then
						self.pLbtip = MUI.MLabel.new({text = "", size = 20})
						self.pLayMain:addView(self.pLbtip, 10)
						self.pLbtip:setPosition(pLbtip:getPosition())
					end
					local tStr = ""
					if #tName == 1 then
						tStr = {
							{text = getConvertedStr(7,10146), color = getC3B(_cc.pwhite)},
							{text = tName[1].sName, color = getC3B(getColorByQuality(tName[1].nQuality))}
						}
						-- self.pLbtip:setString(string.format(getConvertedStr(7,10146), tName[1]))
					elseif #tName == 2 then
						tStr = {
							{text = getConvertedStr(7,10146), color = getC3B(_cc.pwhite)},
							{text = tName[1].sName, color = getC3B(getColorByQuality(tName[1].nQuality))},
							{text = getConvertedStr(7,10147), color = getC3B(_cc.pwhite)},
							{text = tName[2].sName, color = getC3B(getColorByQuality(tName[2].nQuality))}
						}
						-- self.pLbtip:setString(string.format(getConvertedStr(7,10147), tName[1], tName[2]))
					end
					self.pLbtip:setString(tStr)
				end
				
			end
			--新手引导招募按钮
			sendMsg(ghd_guide_finger_show_or_hide, true)
			Player:getNewGuideMgr():setNewGuideFinger(self.pBtn, e_guide_finer.recruit_hero_btn1)

--		elseif _index == 2 then
--			-- for k, v in pairs(self.tItemHeroList) do
--			-- 	if k == 1 then
--			-- 		v:setOpacity(255*0.6)
--			-- 	else
--			-- 		v:setToGray(true)
--			-- 	end
--			-- end
--		end
--	end)

end


function DlgConscribeHero:__nShowHandler( )
	
end

function DlgConscribeHero:onOutsideHandler()
	-- body
	if self.bActioning then
		self.pLayCClose:setViewTouched(false)
	else
		--关闭界面
		self:closeDlg(false)
	end
end


--按钮点击
function DlgConscribeHero:onBtnClick()

	local sName = ""
	if self.tData and self.tData[1] and self.tData[1].sName then
		sName = self.tData[1].sName
	end
	if self.nCost > 0 then
		local tTextLb = {
	    	{color=_cc.blue,text=getConvertedStr(5,10047)},--招募
	    	{color=_cc.white,text=sName},--名字
	    	{color=_cc.blue,text="?"},
    	}

		showBuyDlg(tTextLb, self.nCost, function ()
			self:buyHero()
		end)
	else
		self:buyHero()
	end

	--新手引导招募已点击
	Player:getNewGuideMgr():onClickedNewGuideFinger(self.pBtn)

end

--招募英雄
function DlgConscribeHero:buyHero()
	if self.nPostId and self.nPostId> 0 then
		--显示获得武将窗口
		showSequenceFunc(e_show_seq.gethero)
		SocketManager:sendMsg("fubenConscribeHero", {self.nPostId}, handler(self, self.onGetDataFunc))
	end
end

--转换效果(一边亮, 一边暗)
--_leftItem,_rightItem: 左边武将, 右边武将
--_leftLight, _rightLight: true代表点亮状态, false代表暗状态
--_bEnd: 最终效果选中位置
function DlgConscribeHero:transferAct(_leftItem, _rightItem, _leftLight, _bEnd)
	-- body
	if _leftLight then
		_leftItem:setScale(1.05)
		_leftItem:setOpacity(255)
		self.pImgLight:setPosition(self.pos1)
		_rightItem:setScale(1)
		_rightItem:setOpacity(255*0.6)
	else
		_rightItem:setScale(1.05)
		_rightItem:setOpacity(255)
		self.pImgLight:setPosition(self.pos2)
		_leftItem:setScale(1)
		_leftItem:setOpacity(255*0.6)
	end
	--如果是最终效果选中位置
	local pos = cc.p(self.pImgLight:getPositionX(), self.pImgLight:getPositionY())
	if _bEnd then
		if _leftLight then
			_rightItem:setToGray(true)
		else
			_leftItem:setToGray(true)
		end

		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["48"], 
			self.pView, 
			20,
			pos ,
			function (_pArm)
				if _pArm then
					_pArm:removeSelf()
				end
			end, Scene_arm_type.normal)
	    if pArm then
	        pArm:play(1)
	    end

	    --扫光
	    if not self.pClip then
		    self.pSaoImg = MUI.MImage.new("#sg_fkgx_fb_002.png")
		    self.pSaoImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		    self.pSaoImg:setScale(2)
		    local pSize = _leftItem:getContentSize()
		    self.pClip = display.newClippingRegionNode(cc.rect(0,0,pSize.width,pSize.height))
			self.pView:addChild(self.pClip, 999)
			
		    self.pLayTmp = MUI.MLayer.new()
		    self.pLayTmp:setContentSize(pSize)
		    self.pClip:addChild(self.pLayTmp)
		    self.pLayTmp:addView(self.pSaoImg)
		    self.pSaoImg:setPosition(-250, pSize.height/2)
		end
		if _leftLight then
			self.pClip:setPosition(_leftItem:getPosition())
		else
			self.pClip:setPosition(_rightItem:getPosition())
		end
		self.pSaoImg:runAction(cc.MoveTo:create(0.8, cc.p(350, _leftItem:getContentSize().height/2)))
	else
		_rightItem:setToGray(false)
		_leftItem:setToGray(false)
	end
end

--抽将动画
function DlgConscribeHero:showChooseHeroTx(_heroId, _tDataList)
	-- body
	--显示获得的英雄
	local function showHeroMansion()
		-- body
		if _tDataList then
			local tObject = {}
			tObject.nType = e_dlg_index.showheromansion --dlg类型
			tObject.tReward = _tDataList
			tObject.bHideGo = self.bHideGo
			sendMsg(ghd_show_dlg_by_type,tObject)
		end
		self:closeDlg(false)
	end

	--只有一个武将时不播放抽将动画
	if table.nums(self.tItemHeroList) == 1 then
		showHeroMansion()
		return
	end

	self.bActioning = true
	--设置按钮不可点
	self.pBtn:setBtnEnable(false)

	local pHeroItem1 = self.tItemHeroList[1]
	local pHeroItem2 = self.tItemHeroList[2]
	for k, v in pairs(self.tItemHeroList) do
		if v.nKey == _heroId then
			self.pGetHero = v
		end
	end

	if not self.pImgLight then
		self.pImgLight = MUI.MImage.new("ui/big_img_sep/sg_fkgx_fb_001.png")
		self.pView:addView(self.pImgLight, 10)
		self.pImgLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pImgLight:setScale(1.5)
		self.pos1 = cc.p(pHeroItem1:getPositionX()+pHeroItem1:getWidth()/2, 
			pHeroItem1:getPositionY()+pHeroItem1:getHeight()/2)
		self.pos2 = cc.p(pHeroItem2:getPositionX()+pHeroItem2:getWidth()/2, 
		pHeroItem2:getPositionY()+pHeroItem2:getHeight()/2)
	end
	if self.pGetHero == pHeroItem1 then
		self.pFirst = true 	--抽中的是第一个武将
	else
		self.pFirst = false --抽中的是第二个武将
	end

	local seq = cc.Sequence:create({
		cc.CallFunc:create(function ()
			self:transferAct(pHeroItem1, pHeroItem2, self.pFirst)
		end),
		cc.DelayTime:create(0.17),
		cc.CallFunc:create(function ()
			self:transferAct(pHeroItem1, pHeroItem2, not self.pFirst)
		end),
		cc.DelayTime:create(0.17),
		cc.CallFunc:create(function ()
			self:transferAct(pHeroItem1, pHeroItem2, self.pFirst)
		end),
		cc.DelayTime:create(0.21),
		cc.CallFunc:create(function ()
			self:transferAct(pHeroItem1, pHeroItem2, not self.pFirst)
		end),
		cc.DelayTime:create(0.21),
		cc.CallFunc:create(function ()
			self:transferAct(pHeroItem1, pHeroItem2, self.pFirst)
		end),
		cc.DelayTime:create(0.25),
		cc.CallFunc:create(function ()
			self:transferAct(pHeroItem1, pHeroItem2, not self.pFirst)
		end),
		cc.DelayTime:create(0.33),
		cc.CallFunc:create(function ()
			local _bEnd = true
			self:transferAct(pHeroItem1, pHeroItem2, self.pFirst, _bEnd)
		end),
		cc.CallFunc:create(function ()
			if self.pFirst then
				pHeroItem1:runAction(cc.ScaleTo:create(0.42, 1.07))
			else
				pHeroItem2:runAction(cc.ScaleTo:create(0.42, 1.07))
			end
		end),
		cc.DelayTime:create(1),
		cc.CallFunc:create(function ()
			self.bActioning = false
			self.pBtn:setBtnEnable(true)
			showHeroMansion()
		end)
		
	})

	self:runAction(seq)
end

--接收服务端发回的登录回调
function DlgConscribeHero:onGetDataFunc( __msg )
	--新手如果是这几个任务则获得武将特效界面隐藏前往上阵按钮
	self.bHideGo = false
	local tTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	if tTask then
		local nCurTaskId = tTask.sTid
		if nCurTaskId == e_special_task_id.recruit_xiaoqiao or
	 		nCurTaskId == e_special_task_id.recruit_jingke or
	 		nCurTaskId == e_special_task_id.recruit_hero then
	 		
	 		-- self:closeDlg(false)
	 		-- return
	 		self.bHideGo = true
	 	end
	 end

    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.fubenConscribeHero.id then
        	--打开新的界面
        	local pHeroData = {}
		    sendMsg(gud_refresh_fuben) --通知刷新界面

			--抽中的武将
        	if __msg.body.lot then
        		table.insert(pHeroData,Player:getHeroInfo():getHero(__msg.body.lot))
        	end
        	--购买的武将
        	if __msg.body.buy then
        		table.insert(pHeroData,Player:getHeroInfo():getHero(__msg.body.buy))
        	end
		    if pHeroData and table.nums(pHeroData) > 0 then
				
			 
			 	--展示获得武将特效界面
				local tDataList = {}
				local tKvData = {}
				tKvData.k = pHeroData[1].nId
				tKvData.v = 1
				local tReward = {}
				tReward.d = {}
				tReward.g = {}
				table.insert(tReward.d, copyTab(tKvData))
				table.insert(tReward.g, copyTab(tKvData))
				table.insert(tDataList, tReward)

				self:showChooseHeroTx(pHeroData[1].nId, tDataList)
		    else
		    	--允许下一个提示弹框
				showNextSequenceFunc(e_show_seq.gethero)
				self:closeDlg(false)
			end
        end
    else
    	--允许下一个提示弹框
		showNextSequenceFunc(e_show_seq.gethero)
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


return DlgConscribeHero