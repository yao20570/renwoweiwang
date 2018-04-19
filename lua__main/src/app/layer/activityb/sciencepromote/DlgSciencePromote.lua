-----------------------------------------------------
-- author: xiesite
-- updatetime:  2018-03-06 10:21:19
-- Description: 科技兴国界面
-----------------------------------------------------
local sciencepromoteid = {3009,3010,3016,3019,3020}

local DlgBase = require("app.common.dialog.DlgBase")
local ItemSciencePromote = require("app.layer.activityb.sciencepromote.ItemSciencePromote")
local ItemScienceState = require("app.layer.activityb.sciencepromote.ItemScienceState")

local DlgSciencePromote = class("DlgSciencePromote", function ()
	-- body
	return DlgBase.new(e_dlg_index.sciencepromote)
end)

function DlgSciencePromote:ctor()
	-- body
	self:myInit()
-- getTnolyByIdFromDB
	parseView("dlg_science_promote", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgSciencePromote:myInit(  )
	self.tStateItems = nil
	self.tBars = nil
	self.tStateImgs = nil
	self.tStateLabels = nil
	self.tShowList = {}
	self.pSpecialEffects = {}
	self.nSelect = nil --选中的索引
	self.nShowPoint = nil
end

--解析布局回调事件
function DlgSciencePromote:onParseViewCallback( pView )
	self.pView = pView
	-- body
	self:addContentView(pView) --加入内容层
	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSciencePromote",handler(self, self.onDestroy))
end

function DlgSciencePromote:setupViews( )
	self.pLayBannerBg  = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.ac_kjxg)

	self.pLbProTitle = self:findViewByName("lb_pro_title") --进度标题
	self.pLbProTitle:setString(getConvertedStr(1, 10376))

	self.pImgBx = self:findViewByName("img_6")
	self.pImgBx:setViewTouched(true)
	self.pImgBx:onMViewClicked(handler(self, self.onBoxClick))
	
	self.pLayReward = self:findViewByName("lay_reward")
	

	if not self.tStateItems then
		self.tStateItems = {}
		for i=1,5 do
			local item = ItemScienceState.new()
			item:setCurData(i)
			item:setClickCallBack(handler(self, self.onItemClick))
			table.insert(self.tStateItems, item)
			local pLyItem = self:findViewByName("ly_img_"..i)
			pLyItem:addView(item)
		end
	end

	if not self.tBars then
		self.tBars = {}
		for i=1,5 do
			local pBar = self:findViewByName("bar_"..i)
			table.insert(self.tBars, pBar)
		end
	end
	
	self.pImgT = self:findViewByName("img_title_1") --科技美术字标题
	self.pImgIcon = self:findViewByName("img_icon") --科技对应图标

	self.pLbDes = self:findViewByName("lb_des") --科技描述
	self.pLbDes2 = self:findViewByName("lb_des2") --科技描述2
	
	self.pLbTips = self:findViewByName("lb_tips")
	setTextCCColor(self.pLbTips, _cc.yellow)
	self.pLbTips:setString(getConvertedStr(1,10377))

	if not self.tStateImgs then
		self.tStateImgs = {}
		for i=1,3 do
			local img = self:findViewByName("img_state_"..i)
			table.insert(self.tStateImgs, img)
		end
		self.tStateLabels = {}
		for i=1,3 do
			local label = self:findViewByName("lb_state_"..i)
			table.insert(self.tStateLabels, label)
		end	
	end

	self.pLyContent = self:findViewByName("lay_content")
	self:setDefaultIndex()
end

function DlgSciencePromote:setDefaultIndex()
	self:onItemClick(1) --默认选中第一个
	local tData = Player:getActById(e_id_activity.sciencepromote)
	for i=1, 5 do
		--有奖励没领取
		if tData:rednumByPage(i) then
			self:onItemClick(i)
			return
		end
	end
	--默认选中1
	self:onItemClick(1)
end

function DlgSciencePromote:onItemClick(_index)
	_index = _index or 1
	if self.nSelect == _index then
		return
	end
	self.nSelect = _index
	self:onItemHandldr()
end

function DlgSciencePromote:onItemHandldr()
	local id = sciencepromoteid[self.nSelect]
	if id then
		local tTnoly = getTnolyByIdFromDB(id)
		if tTnoly then
			local tips = tTnoly:getLockState()
			if tips then
				for i=1, 3 do
					local tLimitInfo = tips[i]
					if tLimitInfo then
						if self.tStateImgs[i] then
							self.tStateImgs[i]:setVisible(true)
							if not tLimitInfo[1] then --没锁
								self.tStateImgs[i]:setCurrentImage("#v1_img_goua.png")
								self.tStateImgs[i]:setScale(0.7)
							else 		--锁
								self.tStateImgs[i]:setCurrentImage("#v2_img_lock_tjp.png")
								self.tStateImgs[i]:setScale(0.8)
							end
						end
						if self.tStateLabels[i] then
							self.tStateLabels[i]:setVisible(true)
							self.tStateLabels[i]:setString(tLimitInfo[2])
						end
					else
						if self.tStateImgs[i] then
							self.tStateImgs[i]:setVisible(false)
						end
						if self.tStateLabels[i] then
							self.tStateLabels[i]:setVisible(false)
						end
					end
				end
			end

			if tTnoly.tLimitUpData then
				self.pLbDes2:setString(tTnoly.tLimitUpData.desc)
			end
			self.pImgIcon:setCurrentImage(tTnoly.sSmallIcon)
			-- --设置说明
		end
		self:updateViews()
	end 
end

--宝箱点击回调
function DlgSciencePromote:onBoxClick()
	local tData = Player:getActById(e_id_activity.sciencepromote)
	if not tData then
		return
	end
	--可以领取
	if tData:canGetAward() then
		--已经领取
		if tData:getTake() == 1 then
			TOAST(getConvertedStr(1,10384))
		else
			SocketManager:sendMsg("sciencepromoteaward", {}, function(__msg)
				-- dump(__msg, "__msg")
				if  __msg.head.state == SocketErrorType.success then 
				    if __msg.head.type == MsgType.sciencepromoteaward.id then
				       	if __msg.body.ob then
							--获取物品效果
							showGetItemsAction(__msg.body.ob)
				       	end
				    end
				else
				    --弹出错误提示语
				    TOAST(SocketManager:getErrorStr(__msg.head.state))
				end
			end)
		end
	else
		TOAST(getConvertedStr(1,10385))
	end
end

function DlgSciencePromote:addEffects(  )
	-- body
	if not self.pParitcle then
		local pParitcleB = createParitcle("tx/other/lizi_huode_xjz_lzdh_001.plist")
		pParitcleB:setScale(0.8)
		pParitcleB:setPosition(self.pImgBx:getPositionX(), self.pImgBx:getPositionY())
		self.pLayReward:addView(pParitcleB,5)
		self.pParitcle = pParitcleB
	end

end

function DlgSciencePromote:removeEffect(  )
	-- body
	
	self.pImgBx:stopAllActions()
	self.pLayReward:stopAllActions()
	if self.pParitcle then
		self.pParitcle:removeSelf()
		self.pParitcle = nil
	end
	for k,v in pairs(self.pSpecialEffects) do
 		v:removeSelf()
 		v= nil
 	end
 	self.pSpecialEffects = {}
end


function DlgSciencePromote:updateViews( )
	local tData = Player:getActById(e_id_activity.sciencepromote)
	if not tData then
		return
	end
	self:setTitle(tData.sName)
	self.tShowList = tData:getListByPage(self.nSelect)
	for k,v in ipairs(self.tShowList) do
		if tData:isFinish(v.i) then
			--已经领取
			if tData:isGet(v.i) then
				v.sort = 1
			else
				v.sort = 3
			end
		else
			v.sort = 2
		end
	end
	local function sortFunc( a, b )
		if a.sort == b.sort then
			return a.i < b.i
		end
        return a.sort > b.sort
    end
	table.sort(self.tShowList, sortFunc)

	--更新列表数据
	local nCount = table.nums(self.tShowList)
	if not self.pListView then
		--列表
		local pSize = self.pLyContent:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height-20),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {
				left   = 0,
	            right  = 0,
	            top    = 10, 
	            bottom = 0}
	    }
	    self.pListView:setPositionY(10)
	    self.pLyContent:addView(self.pListView)
		self.pListView:setItemCount(nCount)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView = ItemSciencePromote.new()
			end
			pTempView:setCurData(self.tShowList[_index])
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
		self.pListView:reload()
	else
		self.pListView:notifyDataSetChange(true,nCount)
	end

	local tDecs = luaSplitMuilt(tData.sRule,";",",")
	local sDesStr = ""
	if tDecs then
		for k, v in ipairs(tDecs) do
			if v[1] and (v[1] == self.nSelect or v[1] == self.nSelect.."")  then
				sDesStr = v[2]
				break
			end
		end
	end
	self.pLbDes:setString(sDesStr)

	if self.nSelect == 1 then
		self.pImgT:setCurrentImage("#v2_fonts_cjybs.png")
	elseif self.nSelect == 2 then
		self.pImgT:setCurrentImage("#v2_fonts_zhjjs.png")
	elseif self.nSelect == 3 then
		self.pImgT:setCurrentImage("#v2_fonts_zhjybs.png")
	elseif self.nSelect == 4 then
		self.pImgT:setCurrentImage("#v2_fonts_fyzdbb.png")
	elseif self.nSelect == 5 then
		self.pImgT:setCurrentImage("#v2_fonts_gjjs.png")
	end

	for i=1, 5 do
		if self.nSelect == i then
			self.tStateItems[i]:showFrame()
		else
			self.tStateItems[i]:hideFrame()
		end
	end

	--上一级完成下一级自动出现个红点
	local nPage = tData:inPage()
	--已经显示过的
	local nShowPoint = getLocalInfo("scienceTemRed"..Player:getPlayerInfo().pid,"1")
	if nPage >= tonumber(nShowPoint) then
		local redPage = nPage+1
		if self.tStateItems[redPage] then
			self.tStateItems[redPage]:setTemRed()
		end
		saveLocalInfo("scienceTemRed"..Player:getPlayerInfo().pid, redPage.."")
	end

	for i=1, nPage do
		if self.tBars[i] then
			self.tBars[i]:setVisible(false)
		end
	end

	for i=1, 5 do
		--有奖励没领取
		if tData:rednumByPage(i) then
			self.tStateItems[i]:showRedPoint()
		else
			--暂时红点显示
			if self.tStateItems[i].bTemRed then
				self.tStateItems[i]:showRedPoint()
			else
			    self.tStateItems[i]:hideRedPoint()
			end
		end
	end

	--可以领取
	if tData:canGetAward() then
		--已经领取
		if tData:getTake() == 1 then
			self.pImgBx:setCurrentImage("#v1_img_guojia_renwubaoxiang3.png")
			self:removeEffect()
			showGrayTx(self.pImgBx, false)
		--还没领取
		else
 			self.pImgBx:setCurrentImage("#v1_img_guojia_renwubaoxiang1.png")
 			self:addEffects()
 			self:addSpecialEffect()
		end
	else
		self.pImgBx:setCurrentImage("#v1_img_guojia_renwubaoxiang1.png")
		self:removeEffect()
	end	
end


function DlgSciencePromote:addSpecialEffect()
 	-- body
 	addTextureToCache("tx/other/rwww_ksdh_qsaq")

 	if not self.pSpecialEffects[1] then
	 	self.pSpecialEffects[1] = MUI.MImage.new("#rwww_ksdh_qsaq_003.png")
	 	self.pLayReward:addChild(self.pSpecialEffects[1],6)
	 	self.pSpecialEffects[1]:setScale(1.7)
	 	self.pSpecialEffects[1]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	 	centerInView(self.pLayReward,self.pSpecialEffects[1])
	 	self.pSpecialEffects[1]:setPositionY(self.pSpecialEffects[1]:getPositionY() + 18)
	else
		return
	end
	if not self.pSpecialEffects[2] then
	 	self.pSpecialEffects[2] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[2]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[2]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[2],3)
		centerInView(self.pLayReward,self.pSpecialEffects[2])
		self.pSpecialEffects[2]:setPositionY(self.pSpecialEffects[2]:getPositionY() + 18)
	end
	if not self.pSpecialEffects[3] then
	 	self.pSpecialEffects[3] = MUI.MImage.new("#v1_img_guojia_renwubaoxiang1.png")
		self.pSpecialEffects[3]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		-- self.pSpecialEffects[3]:setScale(0.8)
		self.pSpecialEffects[3]:setOpacity(0)
		self.pImgBx:addChild(self.pSpecialEffects[3],110)
		centerInView(self.pImgBx,self.pSpecialEffects[3])
	end
	showFloatTx(self.pImgBx,0.5)
	showFloatTx(self.pSpecialEffects[3],0.5,0.5 * 255,0)

	if not self.pSpecialEffects[4] then
	 	self.pSpecialEffects[4] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[4]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[4]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[4],3)
		centerInView(self.pLayReward,self.pSpecialEffects[4])
		self.pSpecialEffects[4]:setPositionY(self.pSpecialEffects[4]:getPositionY() + 18)
	end
	if not self.pSpecialEffects[5] then
	 	self.pSpecialEffects[5] = MUI.MImage.new("#rwww_ksdh_qsaq_001.png")
		self.pSpecialEffects[5]:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		self.pSpecialEffects[5]:setScale(0.55)
		-- self.pLvEffect2:setOpacity(0)
		self.pLayReward:addChild(self.pSpecialEffects[5],3)
		centerInView(self.pLayReward,self.pSpecialEffects[5])
		self.pSpecialEffects[5]:setPositionY(self.pSpecialEffects[5]:getPositionY() + 18)
	end

	local delay1 = cc.DelayTime:create(0.33)
	local delay2 = cc.DelayTime:create(0.33)
	local delay3 = cc.DelayTime:create(0.33)
	local callback1 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		self.pSpecialEffects[2]:setRotation(random)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.38,0.92)
		local scale3 = cc.ScaleTo:create(0.55,1.5)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[2]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback2 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.38,0.92)
		local scale3 = cc.ScaleTo:create(0.55,1.5)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[4]:setRotation(random)
		self.pSpecialEffects[4]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	local callback3 = cc.CallFunc:create(function (  )
		-- body
		local random = math.random(0,360)
		local scale1 = cc.ScaleTo:create(0,0.55)
		local scale2 = cc.ScaleTo:create(0.38,0.92)
		local scale3 = cc.ScaleTo:create(0.55,1.5)

		local fadeTo1 = cc.FadeTo:create(0,0)
		local fadeTo2 = cc.FadeTo:create(0.38,255)
		local fadeTo3 = cc.FadeTo:create(0.55,0)

		local spawn1 = cc.Spawn:create(scale1,fadeTo1)
		local spawn2 = cc.Spawn:create(scale2,fadeTo2)
		local spawn3 = cc.Spawn:create(scale3,fadeTo3)
		self.pSpecialEffects[5]:setRotation(random)
		self.pSpecialEffects[5]:runAction(cc.Sequence:create(spawn1,spawn2,spawn3))--(cc.RepeatForever:create(cc.Sequence:create(spawn1,spawn2,spawn3)))
	end)
	self.pLayReward:runAction(cc.RepeatForever:create(cc.Sequence:create(callback1,delay1,callback2,delay2,callback3,delay3)))

 end 


function DlgSciencePromote:onDestroy( )
	self:onPause()
	-- body
end

--注册消息
function DlgSciencePromote:regMsgs(  )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
end
--注销消息
function DlgSciencePromote:unregMsgs(  )
	unregMsg(self, gud_refresh_activity)
end

--暂停方法
function DlgSciencePromote:onPause( )
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgSciencePromote:onResume( _bReshow )
	self:regMsgs()
end

return DlgSciencePromote