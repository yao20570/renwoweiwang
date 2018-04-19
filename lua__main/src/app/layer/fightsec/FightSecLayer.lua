-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-09-12 16:30:30 星期二
-- Description: 战斗场景层 rootlayer
-----------------------------------------------------
import(".data.FightSecDatasDefine")
import(".FightSecUtils")

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemFightSecHero = require("app.layer.fightsec.ItemFightSecHero")
local FightSecController = require("app.layer.fightsec.FightSecController")
local FightSecBloodLayer = require("app.layer.fightsec.FightSecBloodLayer")

local FightSecLayer = class("FightSecLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MROOTLAYER)
end)

--_tReport：战报
--_nCallBack：战斗结束回调
--_bCanJumpFight：是否可以直接跳过战斗
function FightSecLayer:ctor( _tReport,_nCallBack, _bCanJumpFight)
	-- body
	self.tt = getSystemTime(false)
	self:myInit()
	self:initReports(copyTab(_tReport))-- copyTab(tReport[4])
	self.bCanJumpFight = _bCanJumpFight
	self:setFightCallback(_nCallBack)
	--播放战斗背景音乐
    --fix:因为音乐文件较大，所以改为在切换层时播放
    --但关闭声音在2秒后发出声音来达到原来2秒后播放音乐的效果
    Sounds.playMusic(Sounds.Music.battle, true) 
    local x = Sounds.getMusicVolume()
    Sounds.setMusicVolume(0)
	doDelayForSomething(self, function (  )
        Sounds.setMusicVolume(x)
    end, 2 )

	parseView("layout_fight_sec", handler(self, self.onParseViewCallback))
end

function FightSecLayer:myInit(  )
	-- body
	self.pFightController 				= 			nil 			--战斗控制类
	self.tReport 						= 			nil 			--战报
	self.nFightEndCallback 				= 			nil 			--战斗结束回调
	__bHasEndCallback 					= 			false  			--是否已经结束回调

	self.tHeroItemL 					= 			nil 			--左边正在战斗的武将
	self.tLHeroLists 					= 			{} 				--左边武将列表
	self.tHeroItemR 					= 			nil 			--右边正在战斗的武将
	self.tRHeroLists 					= 			{} 				--右边武将列表

	self.fItemScaleA 					= 			0.5 			--武将头像缩放值1
	self.fItemScaleB 					= 			0.7 			--武将头像缩放值2
	self.nItemOffset 					= 			15 				--武将item间隔大小

	self.pLayFightBloodB 				= 			nil 			--左边混战区头顶的信息层
	self.pLayFightBloodT 				= 			nil 			--右边混战区头顶的信息层
	self.jumpCd 						= 			0               --跳过倒计时
	self.jumpOver						= 			false 			--是否已经完成倒计时
end

--解析布局回调事件
function FightSecLayer:onParseViewCallback( pView )
	-- body
	pView:setLayoutSize(self:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	Player:initUIFightLayer(self)

	self:onResume()
	self:setupViews()
	
	--注册析构方法
	self:setDestroyHandler("FightSecLayer",handler(self, self.onFightSecLayerDestroy))
end

function FightSecLayer:setupViews()
    self:asyncPreloadTexture()
    -- body
    -- 注意这里可分帧加载也可以不分帧加载----------------------------
    -- 内容层
    self.pLayContent = self:findViewByName("main")
    self.pLayContent:setLayoutSize(self:getLayoutSize())
    self.pLayContent:getParent():requestLayout()
    -- 顶部层
    self.pLayTop = self.pLayContent:findViewByName("lay_con_top")
    -- 中间层
    self.pLayCenter = self.pLayContent:findViewByName("lay_con_center")
    self.pLayCenter:setLayoutSize(display.width, self.pLayContent:getHeight() - self.pLayTop:getHeight())
    -- 设置锚点
    self.pLayCenter:setAnchorPoint(0.5, 0.5)
    self.pLayCenter:ignoreAnchorPointForPosition(true)
    -- 对中心点赋值
    __fightCenterX = self.pLayCenter:getWidth() / 2
    __fightCenterY = self.pLayCenter:getHeight() / 2 + 50
    -- 背景图
    self.pImgBg = MUI.MImage.new("ui/bg_fight/bg_fight.jpg")
    self.pLayCenter:addView(self.pImgBg)
    -- self.pLayCenter:setPositionX(350)
    -- 设置位置（居中显示）
    self.pImgBg:setPosition(__fightCenterX, __fightCenterY)

    -- 初始化各种参数值
    -- 初始化缩放，旋转，位移值
    self.pLayCenter:setScale(__fSScale)
    -- 注意这里可分帧加载也可以不分帧加载----------------------------

    -- 设置位置（置顶）
    self.pLayTop:setPositionY(self:getHeight() - self.pLayTop:getHeight())
    -- 底部层
    self.pLayBottom = self.pLayContent:findViewByName("lay_con_bottom")
    -- 左边国家
    self.pImgCL = MUI.MImage.new(WorldFunc.getCountryFlagImg(self.tReport.oc))
    self.pImgCL:setPosition(25, 130)
    self.pLayTop:addView(self.pImgCL)
    -- 左边玩家名字
    self.pLbPNameL = MUI.MLabel.new( { text = self.tReport.on, size = 20 })
    setTextCCColor(self.pLbPNameL, _cc.pwhite)
    self.pLbPNameL:setPosition(140, 132)
    self.pLayTop:addView(self.pLbPNameL)

    -- 右边国家
    self.pImgCR = MUI.MImage.new(WorldFunc.getCountryFlagImg(self.tReport.dc))
    self.pImgCR:setPosition(615, 130)
    self.pLayTop:addView(self.pImgCR)
    -- 右边玩家名字
    self.pLbPNameR = MUI.MLabel.new( { text = self.tReport.dn, size = 20 })
    setTextCCColor(self.pLbPNameR, _cc.pwhite)
    self.pLbPNameR:setPosition(500, 132)
    self.pLayTop:addView(self.pLbPNameR)

    -- 武将列表背景框
    
    self.pLayTopOfB = MUI.MLayer.new()
    self.pLayTopOfB:setLayoutSize(640, 112)
    self.pLayTopOfB:setBackgroundImage("#v1_bg_honglanquyu.png", { scale9 = true, capInsets = cc.rect(320, 32, 1, 1) })
    self.pLayTop:addView(self.pLayTopOfB)
    -- 左边血条
    self.pLayBgBarL = MUI.MLayer.new()
    self.pLayBgBarL:setLayoutSize(188, 18)
    self.pLayBgBarL:setBackgroundImage("ui/bar/v1_bar_b1.png", { scale9 = true, capInsets = cc.rect(45, 9, 1, 1) })
    self.pLayBgBarL:setPosition(10, 5)
    self.pLayTopOfB:addView(self.pLayBgBarL)
    self.pBloodBarL = MCommonProgressBar.new( { name = "fight_bar_blood", bar = "v1_bar_yellow_1.png", barWidth = 184, barHeight = 14, dir = 1 })
    self.pBloodBarL:setPercent(100)
    self.pLayBgBarL:addView(self.pBloodBarL)
    centerInView(self.pLayBgBarL, self.pBloodBarL)
    self.pBloodBarL:setPositionY(self.pLayBgBarL:getHeight() / 2 + 1)
    -- 右边血条
    self.pLayBgBarR = MUI.MLayer.new()
    self.pLayBgBarR:setLayoutSize(188, 18)
    self.pLayBgBarR:setBackgroundImage("ui/bar/v1_bar_b1.png", { scale9 = true, capInsets = cc.rect(45, 9, 1, 1) })
    self.pLayBgBarR:setPosition(442, 5)
    self.pLayTopOfB:addView(self.pLayBgBarR)
    self.pBloodBarR = MCommonProgressBar.new( { name = "fight_bar_blood", bar = "v1_bar_yellow_1.png", barWidth = 184, barHeight = 14 })
    self.pBloodBarR:setPercent(100)
    self.pLayBgBarR:addView(self.pBloodBarR)
    centerInView(self.pLayBgBarR, self.pBloodBarR)
    self.pBloodBarR:setPositionY(self.pLayBgBarR:getHeight() / 2 + 1)

    -- 左边武将名字等级
    self.pLbHNameL = MUI.MLabel.new( { text = "", size = 18, anchorpoint = cc.p(1, 0.5) })
    self.pLbHNameL:setPosition(315, 15)
    self.pLayTopOfB:addView(self.pLbHNameL)
    self.pLbHLvL = MUI.MLabel.new( { text = "", size = 18, anchorpoint = cc.p(0, 0.5) })
    self.pLbHLvL:setPosition(206, 15)
    self.pLayTopOfB:addView(self.pLbHLvL)
    setTextCCColor(self.pLbHLvL, _cc.blue)

    -- 右边武将名字等级
    self.pLbHNameR = MUI.MLabel.new( { text = "", size = 18, anchorpoint = cc.p(0, 0.5) })
    self.pLbHNameR:setPosition(325, 15)
    self.pLayTopOfB:addView(self.pLbHNameR)
    self.pLbHLvR = MUI.MLabel.new( { text = "", size = 18, anchorpoint = cc.p(1, 0.5) })
    self.pLbHLvR:setPosition(435, 15)
    self.pLayTopOfB:addView(self.pLbHLvR)
    setTextCCColor(self.pLbHLvR, _cc.blue)

    -- 跳过按钮
    self.pLayFinish = self.pLayBottom:findViewByName("lay_btn_finish")
    self.pBtnFinish = getCommonButtonOfContainer(self.pLayFinish, TypeCommonBtn.L_YELLOW, getConvertedStr(1, 10213))
    -- 点击事件
    self.pBtnFinish:onCommonBtnClicked(handler(self, self.onFinishClicked))

    -- 跳过战斗按钮提示语
    self.pLbJumpTips = self.pLayBottom:findViewByName("lb_jump_tips")
    setTextCCColor(self.pLbJumpTips, _cc.yellow)
    self.pLbJumpTips:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    self.pLbJumpTips:setString(getConvertedStr(1, 10267))

    -- 武将列表存放层(左)
    self.pLayHeroListsL = MUI.MLayer.new()
    self.pLayHeroListsL:setLayoutSize(300, 80)
    self.pLayHeroListsL:setPosition(0, 25)
    self.pLayTopOfB:addView(self.pLayHeroListsL)
    -- 武将列表存放层(右)
    self.pLayHeroListsR = MUI.MLayer.new()
    self.pLayHeroListsR:setLayoutSize(300, 80)
    self.pLayHeroListsR:setPosition(340, 25)
    self.pLayTopOfB:addView(self.pLayHeroListsR)
    -- 兵种克制箭头
    self.pImgArrow = MUI.MImage.new("#v1_img_lanjiantou.png")
    self.pImgArrow:setPosition(320, 65)
    self.pImgArrow:setScale(0.5)
    self.pLayTopOfB:addView(self.pImgArrow)
    -- 战斗类型
    self.pLbTitle = MUI.MLabel.new( { text = getFightType(self.tReport.t), size = 32 })
    setTextCCColor(self.pLbTitle, _cc.white)
    self.pLbTitle:setPosition(320, 132)
    self.pLayTop:addView(self.pLbTitle)

    -- 默认隐藏
    self:setBtnFastVisible(false)
    -- 混战区头顶的信息层
    -- 左边
    self.pLayFightBloodB = FightSecBloodLayer.new(1)
    -- 位置
    self.pLayFightBloodB:setPosition(__fightCenterX - __fFightOffsetX - self.pLayFightBloodB:getWidth() / 2,
    __fightCenterY - __fFightOffsetY + 65)
    self.pLayCenter:addView(self.pLayFightBloodB, 2100)
    -- 右边
    self.pLayFightBloodT = FightSecBloodLayer.new(2)
    -- 位置
    local nBloodX, nBloodY = __fightCenterX + __fFightOffsetX - self.pLayFightBloodT:getWidth() / 2,
    __fightCenterY + __fFightOffsetY + 65
    if self.bIsTLBossReport then
    	nBloodX = nBloodX + 53
    	nBloodY = nBloodY + 120
    end
    self.pLayFightBloodT:setPosition(nBloodX, nBloodY)

    self.pLayCenter:addView(self.pLayFightBloodT, 2000)


    -- 默认隐藏
    self.pLayFightBloodB:setVisible(false)
    self.pLayFightBloodT:setVisible(false)

    -- 战斗展示层赋值
    __showFightLayer = self.pLayCenter
    -- 保存战斗顶部高度
    __nFightLayerTopH = self.pLayTop:getHeight()

    -- 初始化武将数据和UI
    self:initAllHeroMsgs()

    -- 分帧执行实际的加载刷新
    gRefreshViewsAsync(self, 1 + 8--[[#tPreLoadFightTx]], function(_bEnd, _index)
        if (_index == 1) then
--            self:addTexture(tPreLoadFightTx[1][1], tPreLoadFightTx[1][2])
        elseif (_index == 2) then
--            self:addTexture(tPreLoadFightTx[2][1], tPreLoadFightTx[2][2])
        elseif (_index == 3) then
            if not self.pFightController then
                self.pFightController = FightSecController.new(self, self.pLayCenter)
                if self.nCallShowFightLayer then
                    self:nCallShowFightLayer()
                end
            end
        elseif (_index == 4) then
--            -- _index - 1的1时_index == 3的那一帧
--            local n = _index - 1
--            self:addTexture(tPreLoadFightTx[n][1], tPreLoadFightTx[n][2])
        end
    end )

end

function FightSecLayer:asyncPreloadTexture()
     for k, v in pairs(tPreLoadFightImg) do
        MArmaturePlistUtils.preloadPlist(v[1], v[2])
    end
end
--function FightSecLayer:addTexture(_sPath, _nType)
--    addTextureToCache(_sPath, _nType, false, function(_sPlist, _sImg) 
--        --print("异步加载", _sPlist, _sImg)
--    end)
--end

-- 析构方法
function FightSecLayer:onFightSecLayerDestroy(  )
	self:onPause()
	--发送消息开启背景音乐（世界或者基地）
	sendMsg(ghd_open_worldorbase_music_msg)
	Player:releaseUIFightLayer()
	__showFightLayer = nil

end

-- 注册消息
function FightSecLayer:regMsgs( )
	-- body
	-- 注册结束消息
	regMsg(self, ghd_fight_play_end, handler(self, self.onFightEndCallback))
	-- 注册关闭战斗界面消息
	regMsg(self, ghd_fight_close, handler(self, self.onCloseFight))
	-- 注册混战区顶部信息层相关操作
	regMsg(self,ghd_fight_sec_show_msg_state,handler(self, self.onTopMsgInFight))
	-- 注册掉血消息
	regMsg(self, ghd_fight_sec_blood_msg, handler(self, self.onDropBlood))
	-- 注册主公名字刷新消息
	regMsg(self, ghd_fight_sec_king_msg, handler(self, self.onKingName))
end

-- 注销消息
function FightSecLayer:unregMsgs(  )
	-- body
	-- 注销结束消息
	unregMsg(self, ghd_fight_play_end)
	-- 注销关闭战斗界面消息
	unregMsg(self, ghd_fight_close)
	-- 注销混战区顶部信息层相关操作
	unregMsg(self, ghd_fight_sec_show_msg_state)
	-- 注销掉血消息
	unregMsg(self, ghd_fight_sec_blood_msg)
	-- 注销主公名字刷新消息
	unregMsg(self, ghd_fight_sec_king_msg)
end

--暂停方法
function FightSecLayer:onPause( )
	-- body
	self:unregMsgs()
	if not gIsNull(self.pFightController) then
		self.pFightController:onPause()
	end
end

--继续方法
function FightSecLayer:onResume( )
	-- body
	self:regMsgs()
end

--解析战报，初始化数据
--_tReport：战报数据
function FightSecLayer:initReports( _tReport )
	-- body
	--战报赋值
	self.tReport = _tReport 
	-- dump(self.tReport,"self.tReport=",100)

	--判空操作
	if not self.tReport 
		or not self.tReport.acts

		or not self.tReport.ous 
		or table.nums(self.tReport.ous) == 0 

		or not self.tReport.dus
		or table.nums(self.tReport.dus) == 0 then

		--直接调出战斗结果界面
		print("warning ==> ous or dus is nil ")
		self:onFightEndCallback()
		return
	end
	--解析下方阵容列表
	for k, v in pairs (self.tReport.ous) do
		--初始化相关数据
		local hid = v.hid
		if v.hs then
			hid = v.hs.t or v.hid
		end
		v.tHeroInfo = __getHeroInfoForFightById(hid,v.hs)
		v.curTrp = v.trp
	end
	--解析上方阵容列表
	for k, v in pairs (self.tReport.dus) do
		--初始化相关数据
		--初始化相关数据
		local hid = v.hid
		if v.hs then
			hid = v.hs.t or v.hid
		end
		v.tHeroInfo = __getHeroInfoForFightById(hid,v.hs)
		v.curTrp = v.trp
	end
	--是否是限时Boss战
	self.bIsTLBossReport = self.tReport.t == e_fight_report.tlboss

end

--获得战报
function FightSecLayer:getReport(  )
	-- body
	return self.tReport
end

--初始化武将信息
--_heroLists：武将信息
function FightSecLayer:initAllHeroMsgs(  )
	--左边数据
	for k, v in pairs (self.tReport.ous) do
		local pItemHero = ItemFightSecHero.new()
		local nX = 0
		local nY = 0
		if k == 1 then
			self:setCurHeroInfo(1,v)
			pItemHero:setNameVisible(false)
			nY = -28
			pItemHero:setScale(self.fItemScaleB)
			nX = self.pLayHeroListsL:getWidth() - pItemHero:getWidth()*pItemHero:getScale()
			self.tHeroItemL = pItemHero --对正在战斗的item赋值
		else
			nY = 0
			pItemHero:setScale(self.fItemScaleA)
			nX = self.pLayHeroListsL:getWidth() 
			 	- (k - 1) * pItemHero:getWidth()*pItemHero:getScale() - (k-1) * self.nItemOffset
			 	- pItemHero:getWidth()*self.fItemScaleB
		end
		--保存在列表中
		self.tLHeroLists[k] = pItemHero
		pItemHero:setCurData(v.tHeroInfo)
		pItemHero:setPosition(nX, nY)
		self.pLayHeroListsL:addView(pItemHero)
	end
	--右边的数据
	for k, v in pairs (self.tReport.dus) do
		local pItemHero = ItemFightSecHero.new()
		local nX = 0
		local nY = 0
		if k == 1 then
			self:setCurHeroInfo(2,v)
			pItemHero:setNameVisible(false)
			nY = -28
			pItemHero:setScale(self.fItemScaleB)
			nX = 0
			self.tHeroItemR = pItemHero --对正在战斗的item赋值
		else
			nY = 0
			pItemHero:setScale(self.fItemScaleA)
			nX = (k - 2) * pItemHero:getWidth()*pItemHero:getScale() + (k-1) * self.nItemOffset
			 	+ pItemHero:getWidth()*self.fItemScaleB
		end
		--保存在列表中
		self.tRHeroLists[k] = pItemHero
		if self.bIsTLBossReport and k == 1 then --是Boss 不显示兵种类型
			pItemHero:setCurData(v.tHeroInfo, true)
		else
			pItemHero:setCurData(v.tHeroInfo)
		end
		pItemHero:setPosition(nX, nY)
		self.pLayHeroListsR:addView(pItemHero)
	end
	--设置克制关系
	self:setArrowState(true)
end

--设置武将信息
--_nDir：方向 1：下方 2：上方
--_tInfo：武将信息
--_nIndex：武将下标
--注意：能够调到该方法说明存在下一个武将
function FightSecLayer:setCurHeroInfo( _nDir, _tInfo, _nIndex)
	-- body
	local sName = ""
	local nQuality = 1
	if _tInfo.tHeroInfo then
		sName = _tInfo.tHeroInfo.sName
		nQuality = _tInfo.tHeroInfo.nQuality
	end
	-- dump(_tInfo, "uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu")
	if _nDir == 1 then
		--字符自动缩进
		self.pLbHLvL:setString(getLvString( _tInfo.lvl , false))
		local nWidth = self.pLbHLvL:getContentSize().width
		self.pLbHNameL:setString(sName)
		local nScale = (315 - self.pLbHLvL:getPositionX() - nWidth - 4) / self.pLbHNameL:getContentSize().width
		if nScale >= 1 then
			self.pLbHNameL:setScale(1)
		else
			self.pLbHNameL:setScale(nScale)
		end
		setLbTextColorByQuality(self.pLbHNameL,nQuality)
		self.pBloodBarL:setProgressBarText(math.ceil(_tInfo.trp))
		self.pBloodBarL:setPercent(100)
	elseif _nDir == 2 then
		--字符自动缩进
		self.pLbHLvR:setString(getLvString( _tInfo.lvl , false))
		local nWidth = self.pLbHLvR:getContentSize().width
		self.pLbHNameR:setString(sName)
		local nScale = (self.pLbHLvR:getPositionX() - 325 - nWidth - 4) / self.pLbHNameR:getContentSize().width
		if nScale >= 1 then
			self.pLbHNameR:setScale(1)
		else
			self.pLbHNameR:setScale(nScale)
		end
		setLbTextColorByQuality(self.pLbHNameR,nQuality)
		self.pLbHLvR:setString(getLvString( _tInfo.lvl , false))
		if self.bIsTLBossReport then
			self.pBloodBarR:setProgressBarText("???")
		else
			self.pBloodBarR:setProgressBarText(math.ceil(_tInfo.trp))
		end
		self.pBloodBarR:setPercent(100)
	end
	if _nIndex then
		self:showHeroAction(_nDir,_nIndex)
	end
end

--武将消失
--_bEnd：是否结束
function FightSecLayer:fadeOutItemHeroByDir( _nDir, _bEnd )
	-- body
	if _nDir == 1 then
		self:fadeOutCurItemHero(_nDir, self.tHeroItemL,_bEnd)
		if _bEnd then --置灰
			-- self.pLbHNameL:setToGray(true)
			-- self.pLbHLvL:setToGray(true)
		end
	elseif _nDir == 2 then
		self:fadeOutCurItemHero(_nDir, self.tHeroItemR,_bEnd)
		if _bEnd then --置灰
			-- self.pLbHNameR:setToGray(true)
			-- self.pLbHLvR:setToGray(true)
		end
	end
end

--武将列表表现动作
function FightSecLayer:showHeroAction( _nDir, _nIndex )
	-- body
	local tLists = nil
	if _nDir == 1 then
		tLists = self.tLHeroLists
	elseif _nDir == 2 then
		tLists = self.tRHeroLists
	end

	--判断是否有下一个武将
	local tNextHItem = tLists[_nIndex]
	if tNextHItem then
		tNextHItem:setNameVisible(false)
		--移动
		local tPos = cc.p(0,0)
		if _nDir == 1 then
			tPos = cc.p(self.pLayHeroListsL:getWidth() - tNextHItem:getWidth()*self.fItemScaleB,-30)
		elseif _nDir == 2 then
			tPos = cc.p(0,-28)
		end 
		local actionMoveTo = cc.MoveTo:create(0.3, tPos)
		--缩放
		local actionScaleTo = cc.ScaleTo:create(0.3, self.fItemScaleB)
		--回调
		local fCallback = cc.CallFunc:create(function (  )
			-- body
			if _nDir == 1 then
				self.tHeroItemL = tNextHItem
				-- self.pBloodBarLM:setPercent(100)
			elseif _nDir == 2 then
				self.tHeroItemR = tNextHItem
				-- self.pBloodBarRM:setPercent(100)
			end
			--这里赋值后 应该就是最新战斗的两个将领了
			--设置克制关系
			self:setArrowState()
		end)
		local actions = cc.Spawn:create(actionMoveTo,actionScaleTo)
		tNextHItem:runAction(cc.Sequence:create(actions,fCallback))
	end
	--集体移动
	local nPreIndex = _nIndex - 1
	for k, v in pairs (tLists) do
		if k ~= _nIndex and (k ~= nPreIndex) then
			local nX = v:getWidth() * self.fItemScaleA + self.nItemOffset
			if _nDir == 1 then
				nX = -nX
			end
			local actionMoveBy = cc.MoveBy:create(0.3, cc.p(-nX,0))
			local actions = cc.Sequence:create(actionMoveBy)
			v:runAction(actions)
		end
	end
	--当前正在表现的武将(消失)
	self:fadeOutItemHeroByDir(_nDir,false)
end

--当前武将消失
function FightSecLayer:fadeOutCurItemHero(_nDir, _pItemHero, _bEnd )
	-- body
	if _pItemHero then
		-- body
		if not _bEnd then --如果是最后一个武将了
			local actionFadeOut = cc.FadeOut:create(0.15)
			local actionFadeIn = cc.FadeIn:create(0.2)
			--回调
			local fCallback = cc.CallFunc:create(function (  )
				-- body
				-- 不移除掉死亡的武将，做置灰效果
				-- _pItemHero:removeSelf()
				-- _pItemHero = nil
				if not _bEnd then
					if _nDir == 1 then --左边
						local nSize = table.nums(self.tLHeroLists) 
						_pItemHero:setScale(self.fItemScaleA) --重置缩放值
						local nX = self.pLayHeroListsL:getWidth() 
							- (nSize - 1) * _pItemHero:getWidth()*_pItemHero:getScale() - (nSize-1) * self.nItemOffset
							- _pItemHero:getWidth()*self.fItemScaleB
						local nY = 0
						_pItemHero:setPosition(nX, nY)
					elseif _nDir == 2 then --右边
						local nSize = table.nums(self.tRHeroLists) 
						_pItemHero:setScale(self.fItemScaleA)
						local nX = (nSize - 2) * _pItemHero:getWidth()*_pItemHero:getScale() + (nSize-1) * self.nItemOffset
						 	+ _pItemHero:getWidth()*self.fItemScaleB
						 local nY = 0
						 _pItemHero:setPosition(nX, nY)
					end
					--展示名字
					_pItemHero:setNameVisible(true)
					_pItemHero:setToGray(true)
				end
				
			end)
			local actions = cc.Sequence:create(actionFadeOut,actionFadeIn,fCallback)
			_pItemHero:runAction(actions)
		else
			--直接置灰
			_pItemHero:setToGray(true)
			--移除特效品质框
			if _pItemHero.pIconHero and _pItemHero.pIconHero.removeQualityTx then
				_pItemHero.pIconHero:removeQualityTx()
			end
		end
	end
end
--设置克制关系
function FightSecLayer:setArrowState(  )
	if self.tHeroItemL and self.tHeroItemR then
		local pLHData = self.tHeroItemL:getCurData()
		local pRHData = self.tHeroItemR:getCurData()
		if pLHData and pRHData then
			local nRestrainState = getHeroRestrainState(pLHData.nKind, pRHData.nKind)
			if nRestrainState == 0 then --不克制
				self.pImgArrow:setCurrentImage("#v1_img_bukezhi.png")
			elseif nRestrainState == 1 then --克制
				self.pImgArrow:setCurrentImage("#v1_img_lanjiantou.png")
			elseif nRestrainState == 2 then --被克制
				self.pImgArrow:setCurrentImage("#v1_img_hongjiantou.png")
			end
		end
	end
end

--设置跳过按钮是否展示
function FightSecLayer:setBtnFastVisible( bVisible )
	-- body
	self.pLayFinish:setVisible(bVisible)
	if bVisible then
		--跳过按钮提示
		local nCanSkip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip).canskip
		if self.jumpOver or nCanSkip == 1 or self.bCanJumpFight then
			self:unresJumpSchedule()
			self.pLbJumpTips:setVisible(false)
		else
			self:resJumpSchedule()
			self.pLbJumpTips:setVisible(true)
		end
	else
		self.pLbJumpTips:setVisible(bVisible)
	end
end

function FightSecLayer:resJumpSchedule()
	if(not self.nUpgradeHandler) then
		self.jumpCd = 5
		self:jumpHandler(0)
		self.nUpgradeHandler = MUI.scheduler.scheduleGlobal(
			handler(self, self.jumpHandler), 0.2)
	end
end

function FightSecLayer:unresJumpSchedule()
	if(self.nUpgradeHandler) then
		self.jumpCd = 0
		MUI.scheduler.unscheduleGlobal(self.nUpgradeHandler)
		self.pBtnFinish:updateBtnText(getConvertedStr(1,10213))
	end
end


--设置跳过按钮是否展示
function FightSecLayer:jumpHandler(_dt)
	if self.jumpCd then
		self.jumpCd =self.jumpCd - _dt
		local cd = math.ceil(self.jumpCd)
		self.pBtnFinish:updateBtnText(string.format(getConvertedStr(1, 10324), cd))
		if self.jumpCd<=0  then
			self.jumpOver = true
			self:setBtnFastVisible(true)
		end
	end
end

--跳过点击事件
function FightSecLayer:onFinishClicked( pView )
	-- body
	local nCanSkip = getAvatarVIPByLevel(Player:getPlayerInfo().nVip).canskip
	if self.jumpOver or nCanSkip == 1 or self.bCanJumpFight then
		self:onFightEndCallback()
	else
		TOAST(getTipsByIndex(539))
	end
end

-- 设置战斗结束回调
function FightSecLayer:setFightCallback( _nCallback )
	self.nFightEndCallback = _nCallback
end

-- 战斗结束回调
function FightSecLayer:onFightEndCallback(  )
	-- 战斗结束回调
	if (self.nFightEndCallback and not __bHasEndCallback) then
		__bHasEndCallback = true -- 已经回调
		Sounds.stopMusic(true)
		Sounds.stopAllSounds()
		self.nFightEndCallback()
		
		--停止战斗中所有的表现
		if self.pFightController then
			self.pFightController:stopAllFightActions()
			--停止技能表现相关动画
			self.pFightController:removeAllSkillArms()

		end

	end
end

-- 关闭战斗界面消息回调
function FightSecLayer:onCloseFight(  )
	-- body
	--已经在战斗结果对话框做数据的回收了，这里注释一下，以后有需要可以在这里添加
	-- nCollectCnt = 3 
	--停止播放战斗背景音乐
	-- Sounds.stopMusic(true)

	RootLayerHelper:finishRootLayer(self)
end

--战斗加载完成回调
function FightSecLayer:setShowFightLayerCallBack( _nHnalder )
	-- body
	self.nCallShowFightLayer = _nHnalder
end

--混战顶部信息栏回调
function FightSecLayer:onTopMsgInFight( pMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nDir = pMsgObj.nDir
		local nState = pMsgObj.nState
		local sWho = pMsgObj.sWho
		if nDir == 1 then
			if nState == 1 then
				local nHeroPos = pMsgObj.nHeroPos --第几个武将
				local nMatrix = pMsgObj.nIndexM --武将内第几条队伍
				if nHeroPos and nMatrix then
					local tT = self.tReport.ous[nHeroPos].phxs[nMatrix]
					if tT then
						self.pLayFightBloodB:setVisible(true)
						self.pLayFightBloodB:setCurData(self.tReport.ous[nHeroPos].tHeroInfo,nMatrix,tT.trp,nHeroPos)
					end
				end
			else
				self.pLayFightBloodB:setVisible(false)
			end
		elseif nDir == 2 then
			if nState == 1 then
				local nHeroPos = pMsgObj.nHeroPos --第几个武将
				local nMatrix = pMsgObj.nIndexM --武将内第几条队伍
				if nHeroPos and nMatrix then
					local tT = self.tReport.dus[nHeroPos].phxs[nMatrix]
					if tT then
						self.pLayFightBloodT:setVisible(true)
						self.pLayFightBloodT:setCurData(self.tReport.dus[nHeroPos].tHeroInfo,nMatrix,tT.trp,nHeroPos, self.bIsTLBossReport)
					end
				end
			else
				self.pLayFightBloodT:setVisible(false)
			end
		end
	end
end

--掉血消息回调
function FightSecLayer:onDropBlood( pMsgName, pMsgObj )
	-- body
	if pMsgObj then
		local nDir = pMsgObj.nDir
		local nDropBlood = pMsgObj.nDropBlood
		if nDir and nDropBlood then
			if nDir == 1 then --下方
				--混战区顶部层掉血
				self.pLayFightBloodB:updateBlood(nDropBlood)
				--战斗场景顶部层血量表现
				local nHeroPos = self.pLayFightBloodB:getHeroPos()
				if nHeroPos then
					local tT = self.tReport.ous[nHeroPos]
					if tT then
						tT.curTrp = tT.curTrp - nDropBlood
						self.pBloodBarL:setProgressBarText(math.ceil(tT.curTrp))
						self.pBloodBarL:setPercent(tT.curTrp / tT.trp * 100)
						if tT.curTrp == 0 then --当前该武将死亡了
							--获取下一个武将的数据
							local nNextHeroPos = nHeroPos + 1
							local tDatas = self.tReport.ous[nNextHeroPos]
							if tDatas then --存在下一个武将
								self:setCurHeroInfo(1,tDatas,nNextHeroPos)
							else
								self:fadeOutItemHeroByDir(1,true)
							end
						end
					end
				end
			elseif nDir == 2 then --上方
				--混战区顶部层掉血
				self.pLayFightBloodT:updateBlood(nDropBlood)
				--战斗场景顶部层血量表现
				local nHeroPos = self.pLayFightBloodT:getHeroPos()
				if nHeroPos then
					local tT = self.tReport.dus[nHeroPos]
					if tT then
						tT.curTrp = tT.curTrp - nDropBlood
						if self.bIsTLBossReport then
							self.pBloodBarR:setProgressBarText("???")
						else
							self.pBloodBarR:setProgressBarText(math.ceil(tT.curTrp))
						end
						self.pBloodBarR:setPercent(tT.curTrp / tT.trp * 100)
						if tT.curTrp == 0 then --当前该武将死亡了
							--获取下一个武将的数据
							local nNextHeroPos = nHeroPos + 1
							local tDatas = self.tReport.dus[nNextHeroPos]
							if tDatas then --存在下一个武将
								self:setCurHeroInfo(2,tDatas,nNextHeroPos)
							else
								self:fadeOutItemHeroByDir(2,true)
							end
						end
					end
				end
			end
		end
	end
end


--报招（技能名字）
--_nType:1：兵将技能 2：弓将技能 3：骑将技能
--_nDir：1：下方 2：上方
function FightSecLayer:callSkillName( _nDir, _nType )
	-- body
	if _nDir == 1 then
		self.pLayFightBloodB:callSkillNameAction(_nType)
	elseif _nDir == 2 then
		self.pLayFightBloodT:callSkillNameAction(_nType)
	end
end

function FightSecLayer:onKingName(pMsgName, pMsgObj)

--pMsgObj （table）:nDir（int）        ==>1：下方 2：上方 
--					sWho			   ==>主公名字
	if not pMsgObj or not pMsgObj.sWho then
		return
	end

	local nDir = pMsgObj.nDir
	if nDir == 1 then --上方
		self.pLbPNameL:setString(pMsgObj.sWho)
	elseif  nDir == 2 then --下方
		self.pLbPName:setString(pMsgObj.sWho)
	end
end

return FightSecLayer
