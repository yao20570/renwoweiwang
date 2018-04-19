--
-- Author: liangzhaowei
-- Date: 2017-04-13 10:31:31
-- 副本地图

local DlgBase = require("app.common.dialog.DlgBase")
local ItemFubenSpecialLevel = require("app.layer.fuben.ItemFubenSpecialLevel")
local ItemFubenSigleChapter = require("app.layer.fuben.ItemFubenSigleChapter")
local CircleListView = require("app.module.CircleListView")
local MCommonView = require("app.common.MCommonView")
local BeAttackRedBorder = require("app.layer.world.BeAttackRedBorder")


local ViewBarUtils = require("app.common.viewbar.ViewBarUtils")

local ItemFubenLevel = require("app.layer.fuben.ItemFubenLevel")



local DlgFubenMap = class("DlgFubenMap", function()
	return DlgBase.new(e_dlg_index.fubenmap)
end)

local nFbFlewX = -10
local nFbFlewY = -5
local nOffset = 229 --经过UI适配改版，上移了229个像素

--副本关卡item位置
local FubenCityItemPos = {
	-- ["fubencityItem6"] = {x=252+nFbFlewX,y=842+nFbFlewY },
	-- ["fubencityItem5"] = {x=428+nFbFlewX,y=668+nFbFlewY },
	-- ["fubencityItem4"] = {x=230+nFbFlewX,y=510+nFbFlewY },
	-- ["fubencityItem3"] = {x=86 +nFbFlewX,y=390+nFbFlewY },
	-- ["fubencityItem2"] = {x=304+nFbFlewX,y=282+nFbFlewY },
	-- ["fubencityItem1"] = {x=310+nFbFlewX,y=120+nFbFlewY },
	["fubencityItem6"] = {x=227+nFbFlewX,y=753+nFbFlewY-nOffset },
	["fubencityItem5"] = {x=501+nFbFlewX,y=708+nFbFlewY-nOffset },
	["fubencityItem4"] = {x=277+nFbFlewX,y=563+nFbFlewY-nOffset },
	["fubencityItem3"] = {x=543+nFbFlewX,y=518+nFbFlewY-nOffset },
	["fubencityItem2"] = {x=344+nFbFlewX,y=340+nFbFlewY-nOffset },
	["fubencityItem1"] = {x=115+nFbFlewX,y=408+nFbFlewY-nOffset },
}



--副本路线图片
local ExpeditionLineImg = {
	-- "#v1_line_fb01.png",
	-- "#v1_line_fb02.png",
	-- "#v1_line_fb03.png",
	-- "#v1_line_fb04.png",
	-- "#v1_line_fb05.png",

	-- "#v1_img_zjjt_lan.png",
	-- "#v1_img_zjjt_huang.png",
}

--副本路线坐标, 每条路线每个点的坐标
local ExpeditionLinePos = {
	-- [5]={x=250,y=748,dire = 0},
	-- [4]={x=390,y=574,dire = 0},
	-- [3]={x=180,y=474,dire = 0}, 
	-- [2]={x=140,y=358,dire = 0},
	-- [1]={x=324,y=190,dire = 0},

	[1] = 
	{
		[1] = {x = 139, y = 381-nOffset},
		[2] = {x = 171, y = 380-nOffset},
		[3] = {x = 201, y = 372-nOffset},
		[4] = {x = 227, y = 356-nOffset},
		[5] = {x = 252, y = 336-nOffset},
		[6] = {x = 282, y = 320-nOffset}
	},
	[2] = 
	{
		[1] = {x = 380, y = 334-nOffset},
		[2] = {x = 403, y = 356-nOffset},
		[3] = {x = 422, y = 384-nOffset},
		[4] = {x = 435, y = 414-nOffset},
		[5] = {x = 456, y = 434-nOffset},
		[6] = {x = 485, y = 446-nOffset},
		[7] = {x = 517, y = 454-nOffset}
	},
	[3] = 
	{
		[1] = {x = 486, y = 515-nOffset},
		[2] = {x = 452, y = 517-nOffset},
		[3] = {x = 420, y = 518-nOffset},
		[4] = {x = 388, y = 517-nOffset},
		[5] = {x = 356, y = 515-nOffset},
		[6] = {x = 323, y = 513-nOffset},
		[7] = {x = 293, y = 513-nOffset}
	},
	[4] = 
	{
		[1] = {x = 309, y = 559-nOffset},
		[2] = {x = 339, y = 569-nOffset},
		[3] = {x = 370, y = 579-nOffset},
		[4] = {x = 401, y = 587-nOffset},
		[5] = {x = 433, y = 597-nOffset},
		[6] = {x = 462, y = 614-nOffset},
		[7] = {x = 486, y = 637-nOffset}
	},
	[5] = 
	{
		[1] = {x = 438, y = 703-nOffset},
		[2] = {x = 405, y = 705-nOffset},
		[3] = {x = 373, y = 704-nOffset},
		[4] = {x = 340, y = 700-nOffset},
		[5] = {x = 309, y = 698-nOffset},
		[6] = {x = 279, y = 703-nOffset},
		[7] = {x = 248, y = 712-nOffset}
	}
}

function DlgFubenMap:ctor()
	-- body
	self:myInit()

	-- 这个资源已经没使用
	-- addTextureToCache("ui/p1_fuben")

	parseView("dlg_fuben_map", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("DlgFubenMap",handler(self, self.onDestroy))
	
end

--初始化参数
function DlgFubenMap:myInit()
	-- body
	self.tImgLine 		= 		{} 		-- 路线
	self.tItemDrop = {} --item 
 	self.tItemPos = {} --位置
	self.pScetionData = {} -- 章节数据
	self.tLevelListData = {} --当前章节的关卡列表
	self.tSpecialItem = {} --特殊入口列表
	
	self.tDotLineImgs = {} --点路线图片集合
	self.nZorderBeHitNotice = 100
	
end

--初始化数据
function DlgFubenMap:updateData()

	-- dump(self.pScetionData,"self.pScetionData")
	if self.pScetionData and self.pScetionData.nId then
		self.tLevelListData = Player:getFuben():getNormalLevelBySectionId(self.pScetionData.nId)
	end
	--已开启章节的数量
	self.nOpenedNum = Player:getFuben():getNearestOpenChapter()
	-- 副本所有已开启章节数据
	self.tSectionDatas = Player:getFuben():getOpenChpater() 
end

--从章节列表跳过来刷新界面
function DlgFubenMap:refreshFubenLevel(sMsgName, pMsgObj)
	-- body
	if pMsgObj and pMsgObj.tData then 
		self:setCurSectionData(pMsgObj.tData)
	end
end

--刷新数据
function DlgFubenMap:setCurSectionData(_data)
	self.pScetionData = _data or {}
	if self.pCircleList then
		self.pCircleList:setDefaultIndex(self.pScetionData.nId)
	else
		self:updateViews()
	end
end



--解析布局回调事件
function DlgFubenMap:onParseViewCallback( pView )

    self.dlg_fuben_layer = pView

	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
end


--请求章节数据
function DlgFubenMap:requestSectionData()
	if self.pScetionData.nId ~= self.nPreSecId then
    	SocketManager:sendMsg("loadFubenSectionData", {self.pScetionData.nId}, handler(self, self.onGetDataFunc))
    end
end

--接收服务端发回的登录回调
function DlgFubenMap:onGetDataFunc( __msg )
    local tSecondPar = {}
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.loadFubenSectionData.id then
        	--界面已经被销毁兼容
        	if tolua.isnull(self) then
        		return
        	end

			self.nPreSecId = self.pScetionData.nId
			-- 打开副本关卡
			if self.updateViews then
				self:updateViews()
			end
    		-- self.pScrollView:scrollTo(0,0) --移动到对应位置
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


--初始化控件
function DlgFubenMap:setupViews( )
	
    self:setTitle(getConvertedStr(9, 10097))

	-- local pImgR = self:findViewByName("img_r")
	-- pImgR:setFlippedX(true)

    self.pLyContent = self:findViewByName("ly_content")
    
    

	local pLayBtnZj = self:findViewByName("lay_btn_zj")
	pLayBtnZj:setViewTouched(true)
	pLayBtnZj:onMViewClicked(handler(self,self.onBtnZjClick))
    

	local pLbZj = self:findViewByName("lb_zj")
	pLbZj:setString(getConvertedStr(5, 10002))


	local pLbTip = self:findViewByName("lb_tip")
	pLbTip:setString(getTipsByIndex(20017))
	-- setTextCCColor(pLbTip, _cc.gray)
	--当前体力
	self.pLbTiLi = self:findViewByName("lb_tili")


	self.tItemLists = self.tItemLists or {}
    

	--添加活动便签
	local nActivityId=getIsShowActivityBtn(self.eDlgType)
    if nActivityId>0 then
    	self.pLayActBtn = self:findViewByName("lay_act_btn")
    	self.pActBtn = addActivityBtn(self.pLayActBtn,nActivityId)
    else
    	if self.pActBtn then
    		self.pActBtn:removeSelf()
    		self.pActBtn=nil
    	end
    end
    
    --被攻击提示层
	if not self.pBeAttackLayer then
		self.pBeAttackLayer = BeAttackRedBorder.new()
        self.pBeAttackLayer:setIgnoreOtherHeight(true)
        self.pBeAttackLayer:setContentSize(self.pLayBaseBg:getContentSize())
        self.pBeAttackLayer:requestLayout()
		self.pLayBaseBg:addView(self.pBeAttackLayer, self.nZorderBeHitNotice)
		centerInView(self.pLayBaseBg, self.pBeAttackLayer)
	end

	self:refreshEnergy()

    --按钮
	self.pLyBtnL = self:findViewByName("lay_btn_l")
	self.pLyBtnR = self:findViewByName("lay_btn_r")
	self.pImgJr = self:findViewByName("img_j_r")
	self.pImgJr:setFlippedX(true)

    
	self.pLayScroll = self:findViewByName("ly_top")

    self.pLyContent = self:findViewByName("ly_content")
    self.pLyReward =  self:findViewByName("ly_reward")

    local pLayBuyEnergyBtn = self:findViewByName("lay_buy_energy_btn")
	self.pBtnBuyEnergy = getCommonButtonOfContainer(pLayBuyEnergyBtn, TypeCommonBtn.L_YELLOW, getConvertedStr(6, 10080),false)
	self.pBtnBuyEnergy:onCommonBtnClicked(handler(self, self.onBtnBuyEnergyClick))
	setMCommonBtnScale(pLayBuyEnergyBtn, self.pBtnBuyEnergy, 0.8)
end

--刷新体力
function DlgFubenMap:refreshEnergy()
	-- body
	local nEnergy = Player:getPlayerInfo().nEnergy
	local nEnergyMax = tonumber(getGlobleParam("initEnergy") or 100)
	local sColor = _cc.green
	if nEnergy == 0 then
		sColor = _cc.red
	end

	local sTili = {
		{text = getConvertedStr(7, 10220)},
		{text = nEnergy,color=sColor},
		{text = "/"},
		{text = nEnergyMax}
	}
	self.pLbTiLi:setString(sTili)
end

function DlgFubenMap:onBtnZjClick(pView)
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.fubenlayer --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end

-- 刷新线路
function DlgFubenMap:refreshLine()
	for i = 1, 5 do
		if not self.tDotLineImgs[i] then
			self.tDotLineImgs[i] = {}
			for k, v in pairs(ExpeditionLinePos[i]) do
                --TODO:直接使用Sprite会快一些
                self.tDotLineImgs[i][k] = cc.Sprite:createWithSpriteFrameName("sg_fb_gd_hd_01.png")
				--self.tDotLineImgs[i][k] = MUI.MImage.new("#sg_fb_gd_hd_01.png")
				self.pLyContent:addView(self.tDotLineImgs[i][k], 7)
				self.tDotLineImgs[i][k]:setPosition(v.x, v.y)
				self.tDotLineImgs[i][k]:setVisible(false)
			end
		end
		if self.nOpenTime > i then
			for _, v in pairs(self.tDotLineImgs[i]) do
				v:setVisible(true)
			end
		else
			for _, v in pairs(self.tDotLineImgs[i]) do
				v:setVisible(false)
			end
		end
		-- local pLine = self.tLineImgs[i]
		-- if self.nOpenTime > i then
		-- 	pLine:setToGray(false)
		-- 	if i == self.nOpenTime - 1 then
		-- 		pLine:setCurrentImage("#v1_img_zjjt_huang.png")
		-- 	else
		-- 		pLine:setCurrentImage("#v1_img_zjjt_lan.png")
		-- 	end
		-- else
		-- 	pLine:setCurrentImage("#v1_img_zjjt_lan.png")
		-- 	pLine:setToGray(true)
		-- end
	end
end

--箭头特效
function DlgFubenMap:updateArrowAction(_index, _vis)
	-- body
	self.tImgRightArrow = self.tImgRightArrow or {}
	if _vis then
		self.posX = self.posX or self.pImgJr:getPositionX()
		self.posY = self.posY or self.pImgJr:getPositionY()
	    if not self.tImgRightArrow[_index] then
		    self.tImgRightArrow[_index] = MUI.MImage.new("#v1_btn_jiantou.png")
		    local pImgRightArrow = self.tImgRightArrow[_index]
		    if pImgRightArrow then
		    	pImgRightArrow:setFlippedX(true)
		        self.pLyBtnR:addView(pImgRightArrow, 10)
		        pImgRightArrow:setPosition(self.posX, self.posY)
		        pImgRightArrow:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		        local pSequence = cc.Sequence:create({
		            cc.Spawn:create({
		                cc.FadeTo:create(0, 255),
		                cc.MoveTo:create(0, cc.p(self.posX, self.posY)),
		                }),
		            cc.Spawn:create({
		                cc.FadeTo:create(1.0, 0),
		                cc.MoveTo:create(1.0, cc.p(self.posX + 36, self.posY)),
		                }),
		        	})
		        pImgRightArrow:runAction(cc.RepeatForever:create(pSequence))
		    end
		end
		self.tImgRightArrow[_index]:setVisible(true)
	else
		if self.tImgRightArrow[_index] then
			self.tImgRightArrow[_index]:setVisible(false)
		end
	end
end

--显示箭头特效
function DlgFubenMap:showArrowTx()
	-- body
	for i=1, 3, 1 do
		self:performWithDelay(function ()
			self:updateArrowAction(i, true)
		end, 0.48*(i-1))
	end
end
--隐藏箭头特效
function DlgFubenMap:hideArrowTx()
	-- body
	for i=1, 3, 1 do
		self:updateArrowAction(i, false)
	end
end


-- 修改控件内容或者是刷新控件数据
function DlgFubenMap:updateViews(  )
	--print("updateViews")

	self.tOpenPost = Player:getFuben():getNewPostOpen()

	--更新数据
	self:updateData()

	if table.nums(self.pScetionData) <= 0 then
		return
	end

	--上一章节按钮
	if Player:getFuben():getLastSectionData(self.pScetionData)  then
		self.pLyBtnL:setVisible(true)
	else
		self.pLyBtnL:setVisible(false)
	end

	--下一章节按钮
	if Player:getFuben():getNextSectionData(self.pScetionData)  then
		self.pLyBtnR:setVisible(true)
	else
		self.pLyBtnR:setVisible(false)
	end

	--如果有新的开启的副本章节显示箭头特效
	if self.pScetionData.nId == self.tSectionDatas[self.nOpenedNum].nId then
		self:hideArrowTx()
	end


--	gRefreshViewsAsync(self, 8, function ( _bEnd, _index )
--		if _index == 1 then
			--顶部列表层
			self.tScetionData = Player:getFuben():getShowChapter() -- 副本章节数据
			if not self.pCircleList then
				self.pCircleList = CircleListView.new(cc.size(600, 180), cc.size(291, 171), 180)
				self.pLayScroll:addView(self.pCircleList)
				centerInView(self.pLayScroll, self.pCircleList)
				self.pCircleList:setItemCallback(function (pView, _nIndex)
				    if pView then
				        if not pView.pItem then
				            pView.pItem = ItemFubenSigleChapter.new(1)
				            pView:addView(pView.pItem)
				            centerInView(pView, pView.pItem)
				        end
				        pView.pItem:setCurData(self.tScetionData[_nIndex], _nIndex, self.pCircleList)
				    end
				end)
				if self.nOpenedNum < table.nums(Player:getFuben():getAllChapter()) then
					self.pCircleList:setItemCount(self.nOpenedNum + 1)
				else
					self.pCircleList:setItemCount(self.nOpenedNum)
				end
				self.pCircleList:setIsCanMoveCallback(handler(self,self.IsCanMoveCallback))
				self.pCircleList:setDefaultIndex(self.pScetionData.nId)
				self.pCircleList:setMovedCallback(handler(self,self.refreshCurData))
			else
				if self.nOpenedNum < table.nums(Player:getFuben():getAllChapter()) then
					self.pCircleList:setItemCount(self.nOpenedNum + 1)
				else
					self.pCircleList:setItemCount(self.nOpenedNum)
				end
			end

			self.pCircleList:refreshData()

--		elseif _index >= 2 and _index <= 7 then
			
			--刷新关卡数据
			-- local i = _index - 1
--			if(_index == 2) then -- 临时处理
				--如果没有新开启的关卡直接刷新路线
				self.nPreOpenTime = self.nOpenTime
				self.nOpenTime = 0
				for k,v in pairs(self.tLevelListData) do
					if v.bOpen then
						self.nOpenTime = self.nOpenTime +1
					end
				end

				if self.tOpenPost == nil or #self.tOpenPost == 0 then
					--刷新线路
					self:refreshLine()
				end

				for i=1, 6, 1 do
					if not self.tItemLists[i] then
						self.tItemLists[i] = ItemFubenLevel.new(i)
						self.pLyContent:addView(self.tItemLists[i], 15+i)
						self.tItemLists[i]:setPosition(FubenCityItemPos["fubencityItem"..i].x - self.tItemLists[i]:getWidth()/2, 
							FubenCityItemPos["fubencityItem"..i].y - self.tItemLists[i]:getHeight()/2)
					end
					local tData = self.tLevelListData[i]
					if tData then
						self.tItemLists[i]:setCurData(tData, self.tOpenPost)
					end
				end

--			end
--		elseif  _index == 8 then
			--特殊关卡入口
			-- if not self.pLyContent then
				-- self.pLyContent = self:findViewByName("ly_cointent") 
				--img
				-- self.pImgRewardBg = self:findViewByName("img_reward_bg")
				if not self.tLayAwards then
					self.tLayAwards = {}
					self.tImgIcons = {}
					for i = 1, 3 do
						self.tLayAwards[i] = self.pLyReward:getChildByName("ly_reward_"..i)
						--特殊关卡上的icon
						self.tImgIcons[i] = self.pLyReward:getChildByName("img_icon_"..i)
					end
				end
			-- end
			--刷新特殊关卡入口
			self:refreshSpecialLevel()


--		end
--		if _bEnd then
			self:refreshNewGuide()
--		end

--	end)

end

--设置是否可以移动事件
function DlgFubenMap:IsCanMoveCallback(nIndex)
	if nIndex == self.nOpenedNum + 1 then
	    return false
	end
	return true
end

--移动列表显示回调
function DlgFubenMap:refreshCurData(nIndex)
	self.pScetionData = Player:getFuben():getSectionById(self.tSectionDatas[nIndex].nId)
	self:requestSectionData()
	--记录一下最后打开的章节
	Player:getFuben():setLastEnterChapter(self.pScetionData.nId)
end


--刷新特殊关卡入口
function DlgFubenMap:refreshSpecialLevel(sMsgName, pMsgObj)
	self.pScetionData.tSo = Player:getFuben():getSpecialLevelBySectionId(self.pScetionData.nId)
	local tSo = self.pScetionData.tSo or {}
	local tCo = self.pScetionData.tCo or {}
	if table.nums(tCo) > 0 then
		for k, v in pairs(tCo) do
			table.insert(tSo, v)
		end
	end
	--倒计时结束并且没有领取次数就清除
	if pMsgObj and pMsgObj.nId then
		for k, v in pairs(tSo) do
			if type(v) == "table" and pMsgObj.nId == v.nId then
				table.remove(tSo, k)
			end
		end
	end

	for k, v in pairs(tSo) do
		if type(v) == "number" then
			tSo[k] = Player:getFuben():getLevelById(v)
		end
	end
	--根据关卡唯一id重新排序
	table.sort(tSo, function (a,b)
		return a.nId < b.nId
	end )	
	-- 特殊关卡入口
	if table.nums(tSo) > 0  then
		for k,v in ipairs(tSo) do
			local tSpecialData = v
			if self.tSpecialItem[k] and  self.tSpecialItem[k].setCurData then
				self.tSpecialItem[k]:setCurData(tSpecialData, self.tOpenPost, self.tImgIcons[k])
			else
				self.tSpecialItem[k] = ItemFubenSpecialLevel.new()
				self.tSpecialItem[k]:setCurData(tSpecialData, self.tOpenPost, self.tImgIcons[k])
				-- self.tSpecialItem[k]:setPosition(15*k + (k-1)*self.tSpecialItem[k]:getWidth(),
					-- self.tSpecialItem[k]:getHeight()/2 - self.pImgRewardBg:getHeight()/2 )
				self.tSpecialItem[k]:setPosition(self.tLayAwards[k]:getPosition())
				self.pLyReward:addView(self.tSpecialItem[k],99)
			end
		end
	end

	--移除多余的特殊入口
	if table.nums(self.tSpecialItem) > table.nums(tSo)  then
		for k,v in pairs(self.tSpecialItem) do
			if not self.pScetionData.tSo[k] then
				if not tolua.isnull(v) then
					v:removeFromParent(true)
					v = nil
				end
				self.tImgIcons[k]:setCurrentImage("#v2_img_cha_fb.png")
			end
		end
	end
	
end

--新手引导招募
function DlgFubenMap:refreshNewGuide()
	-- body
	--当前主线任务
	local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	local tLinked
	if tCurTask and tCurTask.sLinked then
		tLinked = luaSplit(tCurTask.sLinked,":")
	end
	--新手引导招募按钮
	for k, v in pairs(self.tSpecialItem) do
		if v then
			if v.getData then
				local tData = v:getData()
				--判断是否是要招募的那个武将
				if tData and tData.nType == 1 and tLinked and tLinked[2] and tData.nId == tonumber(tLinked[2]) then
					sendMsg(ghd_guide_finger_show_or_hide, true)
					Player:getNewGuideMgr():setNewGuideFinger(self.tSpecialItem[k], e_guide_finer.fuben_first_post_cruit)
				else
					Player:getNewGuideMgr():setNewGuideFinger(nil, e_guide_finer.fuben_first_post_cruit)
				end
			end
		end
	end
end


--刷新方法
function DlgFubenMap:refreshState()
	-- body
	self.nPreSecId = self.pScetionData.nId
	self:updateViews()
end

--重新提示任务奖励
function DlgFubenMap:onNoticeTaskPrize(  )
	-- body
	if self.pScetionData and self.pScetionData.nId and self.pScetionData.nId <= 4 then
		local pAgencyTask = Player:getPlayerTaskInfo():getHomeTaskData()
		local tShowSeqDatas = getShowSeqDatas()
		local bIsHad = false
		for k, v in pairs(tShowSeqDatas) do
			if v.nKey == e_show_seq.taskrward and v.nParam == pAgencyTask.sTid then
				bIsHad = true
			end
		end
		if bIsHad then
			return
		end
		--当前主线任务的弹窗提示
		if pAgencyTask.nIsFinished == 1 and pAgencyTask.nIsGetPrize == 0 and pAgencyTask.nType == e_task_type.main then
			local tObject = {}
			tObject.nTaskId = pAgencyTask.sTid
			sendMsg(ghd_open_dlg_gettaskprize,tObject)
		end			
	end
end

--刷新新开启关卡的数据
function DlgFubenMap:refreshNewPostData(_target, pFromItem)
	-- body
	local bDid = false
	for k, v in pairs(self.tSpecialItem) do
		if v and v == _target then
			if v.refreshOpenData then
				v:refreshOpenData()
				bDid = true
			end
		end
	end
	if bDid then return end
	for k, v in pairs(self.tItemLists) do
		if v == _target or v == pFromItem and v.refreshOpenData then
			v:refreshOpenData()
		end
	end
end

--获取目标item
function DlgFubenMap:getTarget(_id)
	-- body
	for _, v in pairs(self.tItemLists) do
		if v.getData and v:getData() and v:getData().nId == _id then
			v.bSpecialType = false
			return v
		end
	end
	for _, v in pairs(self.tSpecialItem) do
		if v.getData and v:getData() and v:getData().nId == _id then
			v.bSpecialType = true
			return v
		end
	end
	return nil
end

--播放新关卡开启特效
function DlgFubenMap:playOpenPostTx(msgName, pMsg)
	-- body
	if pMsg then
		local tNewOpen = pMsg.tNewOpen
		if not tNewOpen then return end
		local nNewOpen = table.nums(tNewOpen)
		local pTarget
		if nNewOpen == 2 then             --普通关卡和特殊关卡都开启了
			local pTarget1, pTarget2
			for k, id in pairs(tNewOpen) do
				local tPost = Player:getFuben():getLevelById(id)
				if tPost.nType > 0 then
					pTarget1 = self:getTarget(id)
				else
					pTarget2 = self:getTarget(id)
				end
			end
			--先播放特殊关卡特效再播普通关卡
			self:showOpenTx(pTarget1, pTarget2)
		elseif nNewOpen == 1 then
			pTarget = self:getTarget(tNewOpen[1])
			self:showOpenTx(pTarget, nil)
		end

	end
end

--动态刷新路线动画
function DlgFubenMap:showLine(_target, _pFromItem)
	if not _pFromItem then return end
	if not _target then
		--通知可以刷新数据了
		self:refreshNewPostData(_target, _pFromItem)
		return
	end
	if self.nOpenTime == self.nPreOpenTime then
		return
	end

	--要播放动画的点集合
	local tDotImgs = self.tDotLineImgs[self.nOpenTime-1]
	local pLizi2, pRImg1, pRImg2, pRImg3, pRImg4

	local pPointTo = _target:getAnchorPointInPoints()
	local pWorldTarPos = _target:convertToWorldSpace(pPointTo)

	local pTarPos = self.pLyContent:convertToNodeSpace(pWorldTarPos)
	pTarPos.y = pTarPos.y + 10

	local pSequence = cc.Sequence:create({
		cc.CallFunc:create(function (  )
			for i=1, #tDotImgs, 1 do
				self:performWithDelay(function()
					tDotImgs[i]:setVisible(true)
					local pDotImg = MUI.MImage.new("#sg_fb_gd_hd_02.png")
					self.pLyContent:addView(pDotImg, 8)
					pDotImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
					pDotImg:setPosition(tDotImgs[i]:getPositionX(), tDotImgs[i]:getPositionY())
					pDotImg:runAction(cc.FadeTo:create(0.5, 0))
				end, 0.12*i)
			end
		end),
		cc.DelayTime:create(0.12*(#tDotImgs+1)),
		cc.CallFunc:create(function ()
			--通知可以刷新数据了
			self:refreshNewPostData(_target, _pFromItem)

			pLizi2 = createParitcle("tx/other/lizi_xishoudongh_a_03.plist")
			self.pLyContent:addView(pLizi2, 99)
			pLizi2:setPosition(pTarPos)

			pRImg1 = MUI.MImage.new("#sg_fbbkdh_kq_x_01.png")
			self.pLyContent:addView(pRImg1, 100)
			pRImg1:setPosition(pTarPos)
			pRImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg1:setScale(2)
			local pSequence = cc.Sequence:create({
	            cc.FadeOut:create(0.5),
	            cc.CallFunc:create(function()
		            pRImg1:removeSelf()
		        end)
            })
			pRImg1:runAction(pSequence)

			pRImg2 = MUI.MImage.new("#sg_fbbkdh_kq_x_02.png")
			self.pLyContent:addView(pRImg2, 100)
			pRImg2:setPosition(pTarPos)
			pRImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg2:setScale(2)
			local pSequence = cc.Sequence:create({
	            cc.Spawn:create({
	                cc.FadeOut:create(0.37),
	                cc.ScaleTo:create(0.37, 5.6)
	                }),
	            })
	        pRImg2:runAction(pSequence)

			pRImg3 = MUI.MImage.new("#sg_fbbkdh_kq_x_03.png")
			self.pLyContent:addView(pRImg3, 100)
			pRImg3:setPosition(pTarPos)
			pRImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg3:setScale(1.68)
			local pSequence = cc.Sequence:create({
	            cc.Spawn:create({
	                cc.FadeOut:create(0.38),
	                cc.ScaleTo:create(0.38, 3.5)
	                }),
	            cc.CallFunc:create(function()
		            pRImg3:removeSelf()
		        end)
	            })
	        pRImg3:runAction(pSequence)

			pRImg4 = MUI.MImage.new("#sg_fbbkdh_kq_x_04.png")
			self.pLyContent:addView(pRImg4, 100)
			pRImg4:setPosition(pTarPos)
			pRImg4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg4:setScale(2)
			local pSequence = cc.Sequence:create({
	            cc.FadeOut:create(0.41),
	            cc.CallFunc:create(function()
		            pRImg4:removeSelf()
		        end)
            })
			pRImg4:runAction(pSequence)
		end),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function (  )
			pRImg2:removeSelf()
			pLizi2:removeSelf()
		end)
	})

	self:runAction(pSequence)
end

--_target:目标关卡item, 即新开启的关卡
function DlgFubenMap:showOpenTx(_target1, _target2)
	--起点item
	local pFromItem
	local nFromItemId = Player:getFuben():getChanllengeId()
	for _, v in pairs(self.tItemLists) do
		if v.getData and v:getData() and v:getData().nId == nFromItemId then
			pFromItem = v
		end
	end
	if not pFromItem then return end 
	--如果没有找到目标就直接刷新(因为新开启目标在后一章了)
	if not _target1 then
		self:refreshNewPostData(_target1, pFromItem)
		return
	end
	--如果没有特殊关卡开启则直接播放刷新路线动画
	if _target2 == nil and _target1.bSpecialType == false then
		--动态刷新路线
		self:showLine(_target1, pFromItem)
		return
	end
	local pPointFrom = pFromItem:getAnchorPointInPoints()
	local pWorldBeginPos = pFromItem:convertToWorldSpace(pPointFrom)
	local pPointTo = _target1:getAnchorPointInPoints()
	local pWorldTarPos = _target1:convertToWorldSpace(pPointTo)

	local pBeginPos = self.pLyContent:convertToNodeSpace(pWorldBeginPos)
	local pTarPos = self.pLyContent:convertToNodeSpace(pWorldTarPos)
	pTarPos.y = pTarPos.y + 10
	

	local pMoveLiziEff, pLizi1, pImg, pLizi2, pRImg1, pRImg2, pRImg3, pRImg4

	local pSequence = cc.Sequence:create({
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(function (  )
			pMoveLiziEff = createParitcle("tx/other/lizi_xishoudongh_a_02.plist")
			self.pLyContent:addView(pMoveLiziEff, 99)
			pMoveLiziEff:setPosition(pBeginPos)
			pMoveLiziEff:runAction(cc.MoveTo:create(0.6, pTarPos))
		end),
		cc.DelayTime:create(0.6),
		cc.CallFunc:create(function (  )
			pLizi1 = createParitcle("tx/other/lizi_xishoudongh_a_01.plist")
			self.pLyContent:addView(pLizi1, 99)
			pLizi1:setPosition(pTarPos)
			pImg = MUI.MImage.new("ui/big_img/sg_fbbkdh_kq_x_05.png")
			self.pLyContent:addView(pImg, 100)
			pImg:setPosition(pTarPos)
			pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			local pSpawn = cc.Spawn:create({
				cc.ScaleTo:create(0.6, 0.45),
				cc.RotateTo:create(0.6, -160)
			})
			pImg:runAction(pSpawn)
		end),
		cc.DelayTime:create(0.6),
		cc.CallFunc:create(function (  )
			pLizi1:removeSelf()
			pImg:removeSelf()

			--动态刷新路线
			self:showLine(_target2, pFromItem)

			--通知可以刷新数据了
			self:refreshNewPostData(_target1, pFromItem)

			pLizi2 = createParitcle("tx/other/lizi_xishoudongh_a_03.plist")
			self.pLyContent:addView(pLizi2, 99)
			pLizi2:setPosition(pTarPos)

			pRImg1 = MUI.MImage.new("#sg_fbbkdh_kq_x_01.png")
			self.pLyContent:addView(pRImg1, 100)
			pRImg1:setPosition(pTarPos)
			pRImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg1:setScale(2)
			local pSequence = cc.Sequence:create({
	            cc.FadeOut:create(0.5),
	            cc.CallFunc:create(function()
		            pRImg1:removeSelf()
		        end)
            })
			pRImg1:runAction(pSequence)

			pRImg2 = MUI.MImage.new("#sg_fbbkdh_kq_x_02.png")
			self.pLyContent:addView(pRImg2, 100)
			pRImg2:setPosition(pTarPos)
			pRImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg2:setScale(2)
			local pSequence = cc.Sequence:create({
	            cc.Spawn:create({
	                cc.FadeOut:create(0.37),
	                cc.ScaleTo:create(0.37, 5.6)
	                }),
	            })
	        pRImg2:runAction(pSequence)

			pRImg3 = MUI.MImage.new("#sg_fbbkdh_kq_x_03.png")
			self.pLyContent:addView(pRImg3, 100)
			pRImg3:setPosition(pTarPos)
			pRImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg3:setScale(1.68)
			local pSequence = cc.Sequence:create({
	            cc.Spawn:create({
	                cc.FadeOut:create(0.38),
	                cc.ScaleTo:create(0.38, 3.5)
	                }),
	            cc.CallFunc:create(function()
		            pRImg3:removeSelf()
		        end)
	            })
	        pRImg3:runAction(pSequence)

			pRImg4 = MUI.MImage.new("#sg_fbbkdh_kq_x_04.png")
			self.pLyContent:addView(pRImg4, 100)
			pRImg4:setPosition(pTarPos)
			pRImg4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pRImg4:setScale(2)
			local pSequence = cc.Sequence:create({
	            cc.FadeOut:create(0.41),
	            cc.CallFunc:create(function()
		            pRImg4:removeSelf()
		        end)
            })
			pRImg4:runAction(pSequence)
		end),
		cc.DelayTime:create(2),
		cc.CallFunc:create(function (  )
			pRImg2:removeSelf()
			pLizi2:removeSelf()
			pMoveLiziEff:removeSelf()
		end)
	})

	self:runAction(pSequence)

end

function DlgFubenMap:onBtnBuyEnergyClick( )
	-- body
	openDlgBuyEnergy()
end


--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgFubenMap:onResume(_bReshow)
	-- body
	self:regMsgs()

    --TODO：应该不需要设置，等协议回来设置好了
	--self:updateViews()
end

-- 注册消息
function DlgFubenMap:regMsgs( )
	-- 注册副本信息刷新消息
	regMsg(self, gud_refresh_fuben, handler(self, self.refreshState))
	-- 注册重新发送玩家主线任务奖励提示
	regMsg(self, ghd_renotice_taskprize_msg, handler(self, self.onNoticeTaskPrize))
	--刷新任务消息
	regMsg(self, gud_refresh_task_msg, handler(self, self.refreshNewGuide))
	--注册刷新特殊关卡消息
	regMsg(self, ghd_refresh_special_level, handler(self, self.refreshSpecialLevel))
	--注册刷新关卡消息
	regMsg(self, ghd_refresh_fuben_level, handler(self, self.refreshFubenLevel))
	--是否显示副本关卡界面的右边特效消息
	regMsg(self, gud_refresh_fuben_arrowtx, handler(self, self.showArrowTx))
	--注册播放新关卡特效消息
	regMsg(self, ghd_show_fuben_openpost_tx, handler(self, self.playOpenPostTx))

	-- 注册玩家能量刷新消息
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.refreshEnergy))
end

-- 注销消息
function DlgFubenMap:unregMsgs(  )
	-- 销毁副本信息刷新消息
	unregMsg(self, gud_refresh_fuben)
	-- 注销重新发送玩家主线任务奖励提示
	unregMsg(self, ghd_renotice_taskprize_msg)	
	-- 注销刷新任务消息
	unregMsg(self, gud_refresh_task_msg)
	--注销刷新特殊关卡消息
	unregMsg(self, ghd_refresh_special_level)
	--注销刷新关卡消息
	unregMsg(self, ghd_refresh_fuben_level)
	--销毁是否显示副本关卡界面的右边特效消息
	unregMsg(self, gud_refresh_fuben_arrowtx)
	--销毁播放新关卡特效消息
	unregMsg(self, ghd_show_fuben_openpost_tx)

	-- 销毁玩家能量刷新消息
	unregMsg(self, ghd_refresh_energy_msg)
end


--暂停方法
function DlgFubenMap:onPause( )
	-- body
	self:unregMsgs()
	Player:getFuben():saveChanllengeId(nil)
end


--析构方法
function DlgFubenMap:onDestroy()

end

return DlgFubenMap