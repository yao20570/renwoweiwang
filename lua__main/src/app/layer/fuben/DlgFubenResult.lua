-- Author: liangzhaowei
-- Date: 2017-04-13 17:04:32
-- 战斗结果界面


local DlgBase = require("app.common.dialog.DlgBase")
local ViewBarUtils = require("app.common.viewbar.ViewBarUtils")

local ItemFubenSection = require("app.layer.fuben.ItemFubenSection")
local ItemAccoutList = require("app.layer.login.ItemAccoutList")
local MDialog = require("app.common.dialog.MDialog")
local ItemFubenMyArmy = require("app.layer.fuben.ItemFubenMyArmy")
local ItemHeroExps = require("app.layer.fuben.ItemHeroExps")
local ItemPlayerExps = require("app.layer.fuben.ItemPlayerExps")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemFubenGetReward = require("app.layer.fuben.ItemFubenGetReward")
local DlgFubenResult = class("DlgFubenResult", function()
	return MDialog.new(e_dlg_index.fubenresult)
end)

local nOffsetBgY = 50 --背景图片更改

--副本失败界面需要判断的科技id是否达到1级
TnolyId = {
	3009,
	3010,
	3016,
	3020,
}

-- _tData 战斗结果数据
function DlgFubenResult:ctor(_tData)
	-- body
	self:myInit()

	self:initData()

	self:setCurData(_tData)

	parseView("dlg_fuben_result", handler(self, self.onParseViewCallback))

	--设置背景颜色
	self:setDialogBgColor(cc.c4b(0, 0, 0, 127))
	self:setIsNeedOutside(false)

	--注册析构方法
	self:setDestroyHandler("DlgFubenResult",handler(self, self.onDestroy))
	
end

--初始化参数
function DlgFubenResult:myInit()

	self.tData = {} -- 结果数据
	self.nStar = 0 -- 获得星数
	self.tUpdateHeroData = {} --升级英雄数据
	self.pLyHeroExps = {} --英雄经验展示icon
	self.tAd = {} --获得物品数据

	self.nWin = 0 -- 是否成功 1为胜利

	self.bHideHeros = false --用于竞技场战斗结算界面控制
end

--初始化数据
function DlgFubenResult:initData()

end

--解析布局回调事件
function DlgFubenResult:onParseViewCallback( pView )

    self.pImgBg  = pView:findViewByName("img_bg") --背景图片

    -- 如果是低分辨率设备的情况下
    local isLow  = getIsTargetLow()
    if isLow then
        --计算缩放比例
        local fScale = self:getHeight() / pView:getHeight()
        local pVg = MUI.MLayer.new()
        self:setContentView(pVg)
        pVg:setContentSize(self:getContentSize())
        pView:setScale(fScale)
        pVg:addView(pView)
        		
		self.pImgBg:setContentSize(display.width/fScale, display.height/fScale)
        centerInView(pVg,pView)
    else
		self:setContentView(pView) --加入内容层
        
        self.pImgBg:setContentSize(display.width, display.height)
        centerInView(pVg,pView)
    end


	--ly
	self.pLyBtnL = self:findViewByName("ly_down_l") --左按钮
	self.pLyBtnR = self:findViewByName("ly_down_r") --右按钮
	self.pBtnL =  getCommonButtonOfContainer(self.pLyBtnL,TypeCommonBtn.L_BLUE,getConvertedStr(5,10174))--关闭
	self.pBtnR =  getCommonButtonOfContainer(self.pLyBtnR,TypeCommonBtn.L_BLUE,getConvertedStr(7,10223))--继续挑战
	self.pBtnL:onCommonBtnClicked(handler(self, self.onTitleBtnLClicked))
	self.pBtnR:onCommonBtnClicked(handler(self, self.onTitleBtnRClicked))
	self.pLyFail = self:findViewByName("ly_fail")--失败层
	self.pLyDown = self:findViewByName("ly_down")--底部按钮层
	self.pLyShowHero = self:findViewByName("ly_show_hero")--展示英雄层
	self.pLyShowReward  = self:findViewByName("ly_show_reward") --展示奖励或者战力提升途径icon
	self.pLyWin  = self:findViewByName("ly_win") --胜利层
	self.pLyGetItem1  = self:findViewByName("ly_get_item_1") --获得层1
	self.pLyGetItem2  = self:findViewByName("ly_get_item_2") --获得层2
	self.pLyGetItem1:setVisible(false)
	self.pLyGetItem2:setVisible(false)
	self.pLyGetItem1:setOpacity(0)
	self.pLyGetItem2:setOpacity(0)
	self.pLyGetItem1:setZOrder(99)
	self.pLyGetItem2:setZOrder(99)

	self.pImgZLBg = self:findViewByName("img_zl_bg")
	self.pImgZLBg:setVisible(false)
	self.pLbZLTitle = self:findViewByName("lb_zl_title")
	self.pLbZLTitle:setString(getConvertedStr(5, 10010))
	self.pLbZLTitle:setVisible(false)

	self.pImgExpBg = self:findViewByName("img_exp_bg")
	self.pImgExpBg:setVisible(false)
	self.pLbExpTitle = self:findViewByName("lb_exp_title")
	self.pLbExpTitle:setString(getConvertedStr(5,10011))
	self.pLbExpTitle:setVisible(false)

	self.pImgPrizeBg = self:findViewByName("img_prize_bg")
	self.pImgPrizeBg:setVisible(false)
	self.pLbPrizeTitle = self:findViewByName("lb_prize_title")
	self.pLbPrizeTitle:setString(getConvertedStr(5,10009))
	self.pLbPrizeTitle:setVisible(false)

	self.pLyWin:setZOrder(10)

	self.pLyMain  = self:findViewByName("ly_main") --主层

	self.pLyShowHero:setScale(0.8)
	self.pLyShowReward:setScale(0.8)
	self.pLyShowHero:setAnchorPoint(0,0)
	self.pLyShowReward:setAnchorPoint(0,0)
	local nFlewX = 128
	self.pLyShowHero:setPositionX(nFlewX)
	self.pLyShowReward:setPositionX(nFlewX)

	self.pLyDown:setVisible(false)--底部按钮层
	self.pLyShowHero:setVisible(false)--展示英雄层
	self.pLyShowHero:setZOrder(99)
	self.pLyFail:setVisible(false) --失败背景层
	self.pLyShowReward:setVisible(false) --获得物品展示栏
	self.pLyPlayer = self:findViewByName("lay_player") 
	self.pLyPlayer:setScale(0.8)
	self.pLyPlayer:setVisible(false) --隐藏主公层
	self.pLayPlayer = ItemPlayerExps.new()
	self.pLyPlayer:addView(self.pLayPlayer)
	centerInView(self.pLyPlayer, self.pLayPlayer)


	-- self.pLyStart = self:findViewByName("ly_start") --获取星星显示层
	--

	--武将升级展示
	self.tLyHero = {}
	-- ly_hero_1
	
	--如果是邮件战斗回放
	if self.tData.mailPlayBack or 
		(self.tData.report and self.tData.report.t==e_war_report_type.worldboss) or--世界boss一天只有一次机会
		(self.tData.report and self.tData.report.t==e_war_report_type.killhero) or --过关斩将
		(self.tData.report and self.tData.report.t==e_war_report_type.tlboss) then  --限时Boss
		self:hideBtnR()
	end
	--如果是任务战斗回放
	if self.tData.taskPlayBack then
	-- 	self.pBtnR:setVisible(false)
	-- 	self.pBtnL:updateBtnText(getConvertedStr(7,10106)) --回到主城
		-- pLyBtnL:setPositionX(pView:getWidth()/2 - self.pBtnL:getWidth()/2)
	-- 	self.pBtnL:onCommonBtnClicked(handler(self, self.onBackCity))
	end
	--竞技场战斗结算
	if self.tData.arenafightBack then
		self.bHideHeros = true		--隐藏武将显示
		self.nCloseHandler = self.tData.nCloseHandler
	end

	self.pLbRewardTips = self:findViewByName("lb_reward_tips") --胜利了没有奖励提示
	self.pLbRewardTips:setVisible(false)
	

	-- self.pImgLeftP = self:findViewByName("img_left_p") --需要翻转的图片
	-- self.pImgLeftP:setFlippedX(true)

	--img
	-- self.tImgStart = {}
	-- for i=1,3 do
	-- 	self.tImgStart[i] = self:findViewByName("img_start_"..i)
	-- end

	-- self.pImgResult = self:findViewByName("img_result") --战斗结果




	self.pLbTnolyTips = self:findViewByName("txt_tnoly")
	self.pLayGoTnoly = self:findViewByName("lay_go_tnoly")

	self.pLbTnolyTips:setVisible(false)
	self.pLayGoTnoly:setVisible(false)
	self.pBtnGoTnoly =  getCommonButtonOfContainer(self.pLayGoTnoly,TypeCommonBtn.L_BLUE,getConvertedStr(8,10035))
	self.pBtnGoTnoly:onCommonBtnClicked(handler(self, self.onGoBtnTnolyClicked))

	self:setupViews()
	-- self:updateViews()
	self:onResume()
end



--刷新数据
-- _data
	
function DlgFubenResult:setCurData(_tData)
	if not _tData then
 		return
	end

	--刷新关卡数据
	self.tData = _tData

	self.nStar = self.tData.star or self.nStar --战斗星数

	if self.tData.report and self.tData.report.w then
		if self.tData.report.w == 2 then
			self.nWin = 0
		elseif self.tData.report.w == 1 then
			self.nWin = 1
		end
		self.tUpdateHeroData = self.tData.report.haes or {} --英雄升级数据
		self.tAd = self.tData.report.as or  {}
	end

	--扫荡需要重新拿
	if self.tData.heroExps then
		self.tUpdateHeroData = self.tData.heroExps
	end

	--奖励
	if self.tData.awards then
		self.tAd = self.tData.awards or  {}
	end
	--把主公经验去掉 
	if self.tAd then
		for i=#self.tAd,1, -1 do
			if self.tAd[i].k == e_type_resdata.exp then
				table.remove(self.tAd, i)
			end
		end
	end

	--战斗结果 --前端在扫荡结果中添加的字段(self.tData.nResult)
	if self.tData.nResult then
		self.nWin = self.tData.nResult
	end

	if self.tData.nEndHandler then
		self.nEndHanlder = self.tData.nEndHandler
	else
		self.nEndHanlder = nil
	end
	--结果类型
	self.nArmyType = self.tData.nArmyType

	--主公战斗变化
	--正常副本战斗
	if self.tData.report then
		self.tAvaAddExpVo = self.tData.report.aae
	else
		--扫荡战斗
		self.tAvaAddExpVo = self.tData.aae
	end
end

--初始化控件
function DlgFubenResult:setupViews( )
	if not self.tData then
		return
	end
	-- dump(self.tUpdateHeroData, "self.tUpdateHeroData", 100)

	--Sounds.stopAllSounds()
	-- --创建战力品或战力提升途径icon
	if self.nWin == 0 then --失败
		--播放失败声音

		Sounds.playEffect(Sounds.Effect.shibai)
		
		self.pImgZLBg:setVisible(not self.bHideHeros)
		self.pLbZLTitle:setVisible(not self.bHideHeros)
	 	local tIconImg = {
		 	"#v1_img_kejikuaiyan.png",
		 	"#v1_img_wujiangyangcheng.png",
		 	"#v1_img_dazaozhuangbei.png",
		 	"#v1_img_zhuangbeixilian.png",
	 	}
	 	local bResult,nIndex = self:getAllTnolyLvToCertainLv() 
	 	if bResult  then --所有科技等级都达到一级
	 		self.pLbTnolyTips:setVisible(false)
			self.pLayGoTnoly:setVisible(false)
	 		for i=1,4 do
		 		local pCurIcon = IconGoods.new(TypeIconGoods.HADMORE)
		        self.pLyShowReward:addView(pCurIcon,9)
		        pCurIcon:setIconImg(tIconImg[i])
		        pCurIcon:setIsShowNumber(false)
		        pCurIcon:setMoreText(getConvertedStr(5, 10229-1+i))--底部文字
		        pCurIcon:setMoreTextColor(_cc.pwhite)
		        pCurIcon:setMoreTextBg(nil, 26)
		        pCurIcon:setPosition((i-1)*124, 0)

		        pCurIcon.nTpIndex = i


		        local bOpen = false
		        if i == 1 then--科学院
					local pBuild = Player:getBuildData():getBuildById(e_build_ids.tnoly)
					if pBuild  then
						bOpen = true
					end
		        elseif i == 2 then
		        	bOpen = true
		        elseif i == 3 then--铁匠铺打造
					local pBuild = Player:getBuildData():getBuildById(e_build_ids.tjp)
					if pBuild  then
						bOpen = true
					end	        	
		        elseif i == 4 then--铁匠铺洗炼
					local pBuild = Player:getBuildData():getBuildById(e_build_ids.tjp)
					if pBuild  then
						bOpen = true
					end	
		        end
		        if bOpen then
					pCurIcon:setIsPressedNeedScale(false)
		        	pCurIcon:setIconClickedCallBack(function ()
	        		    local tObject = {}
		        		if i == 1 then
					    	tObject.nType = e_dlg_index.technology --科技园
		        		elseif i ==2 then
					    	tObject.nType = e_dlg_index.dlgherolineup --英雄界面
		        		elseif i ==3 then
					    	tObject.nType = e_dlg_index.smithshop --铁匠铺
					    	tObject.nFuncIdx = n_smith_func_type.build --打造功能
		        		elseif i ==4 then
					    	tObject.nType = e_dlg_index.smithshop --铁匠铺
					    	tObject.nFuncIdx = n_smith_func_type.train --洗练功能
		        		end

		        		local nEndHandler = self.nEndHanlder 
						if nEndHandler then
							nEndHandler()
						end

				    	--关闭战斗界面
						sendMsg(ghd_fight_close)					
					    sendMsg(ghd_show_dlg_by_type,tObject)
						closeDlgByType(e_dlg_index.fubenresult,false)
						closeDlgByType(e_dlg_index.fubenmap,false)

						--跳转到其他界面的话清除奖励弹窗
						clearTaskReward()
						--允许提示弹框
						showNextSequenceFunc(e_show_seq.fight)

						--打开弹窗类提示信息
						setToastNCState(2)
						--战斗结束后播放战力变化
						Player:getPlayerInfo():playFCChangeTx()
		        	end)
		        else
		       		pCurIcon:setIconIsCanTouched(false)
		       		pCurIcon:setToGray(true)
		        end


	 		end
	 	else
	 		self.pLbTnolyTips:setVisible(true)
			self.pLayGoTnoly:setVisible(true)
	 		local str =  getTipsByIndex( 20026+ nIndex)

	 		self.pLbTnolyTips:setString(getTextColorByConfigure(str))
	 	end
		--获得物品显示刷新
		if self.bHideHeros then
			local tItemGoods = self:refreshShowItems()	 	
			self:showItemsPanel(tItemGoods)
		end
		self.pImgExpBg:setVisible(not self.bHideHeros)
		self.pLbExpTitle:setVisible(not self.bHideHeros)
		self.pLyShowHero:setVisible(not self.bHideHeros)--展示英雄层
		self.pLyFail:setVisible(true) --失败背景层
		self.pLyShowReward:setVisible(not self.bHideHeros) --获得物品展示栏
		self.pLyDown:setVisible(true)--底部按钮层
		if self.tAvaAddExpVo then
			self.pLyPlayer:setVisible(true) --显示主公
			self.pLayPlayer:setCurData(self.tAvaAddExpVo)
		end

		self:hideBtnR()

	elseif self.nWin == 1 then  --胜利
		-- local nOffsetY = -40
		-- self.pLyShowHero:setPositionY(self.pLyShowHero:getPositionY() + nOffsetY)
		-- self.pImgExpBg:setPositionY(self.pImgExpBg:getPositionY() + nOffsetY)
		-- self.pLbExpTitle:setPositionY(self.pLbExpTitle:getPositionY() + nOffsetY)
		-- self.pImgPrizeBg:setPositionY(self.pImgPrizeBg:getPositionY() + nOffsetY)
		-- self.pLbPrizeTitle:setPositionY(self.pLbPrizeTitle:getPositionY() + nOffsetY)
		-- self.pLyGetItem1:setPositionY(self.pLyGetItem1:getPositionY() + nOffsetY)
		-- self.pLyGetItem2:setPositionY(self.pLyGetItem2:getPositionY() + nOffsetY)		

		--播放胜利声音
		Sounds.playEffect(Sounds.Effect.shengli)

		doDelayForSomething(self, function( )
			--隐藏胜利层
			self.pLyWin:setVisible(true)
			--播放胜利动画
			local nArmTag = 897854
			local sName = createAnimationBackName("tx/exportjson/", "sg_dzjs_zzsk_01")
		    local pArm = ccs.Armature:create(sName)
		    --替换骨骼
		    changeBoneWithPngAndScale(pArm,"slth001","#sg_dzjs_zzsk_xk_005.png",false) 
		    changeBoneWithPngAndScale(pArm,"qbth001","ui/sg_dzjs_zzsk_xk_008.png",false,cc.p(0.5,1))
		    --设置胜利动画位置
		    pArm:setPosition(320,412+nOffsetBgY)
		    self.pLyWin:addChild(pArm,10,nArmTag)
		    pArm:getAnimation():play("Animation1", 1)
		    --注册胜利动画监听
			pArm:getAnimation():setFrameEventCallFunc(function ( pBone, frameEventName, originFrameIndex, currentFrameIndex ) 
				if frameEventName == "slzd01" then
					self:useShakeAction()
				elseif frameEventName == "gxcx01" then
					--粒子
					local pParitcle = createParitcle("tx/other/lizi_jiesjm_002.plist")
					pParitcle:setPosition(320,868+nOffsetBgY)
					self.pLyMain:addView(pParitcle,0)
					--创建光圈图片
					self:creatLightImg()
					--延迟创建光圈
					local pDelay = cc.DelayTime:create(0.45)
					local fCallback = cc.CallFunc:create(function (  )
						self:creatLightImg()
					end)
					self.pLyWin:runAction(cc.RepeatForever:create(cc.Sequence:create(pDelay,fCallback)))
				elseif frameEventName == "wpcx01"  then
					-- --奖励物品
					-- local pRewardGoods = {}
					-- pRewardGoods = getRewardItemsFromSever(self.tAd) or {}					
					-- --国器碎片需要前端加上奖励
					-- if self.tData.arft then
					-- 	local tData = {}
					-- 	tData = clone(getBaseWeaponDataByID(self.tData.arft))
					-- 	tData.nCt = self.tData.arftN or 1
					-- 	tData.sIcon = tData.sFraIcon --特殊处理得用神兵碎片的图片
					-- 	table.insert(pRewardGoods,tData)
					-- end
					-- --资源建筑碎片
					-- if self.tData.filed then
					-- 	local tDraw = getSubBDatasFromDBByCell(self.tData.filed)
					-- 	if tDraw then
					-- 		-- dump(tDraw, "tDraw", 100)
					-- 		local tData = {}						
					-- 		tData.nQuality = 4
					-- 		tData.sIcon = "#"..tDraw.icon..".png" --特殊处理得用神兵碎片的图片
					-- 		tData.sName = tDraw.drawingname
					-- 		tData.nCt = self.tData.filedN or 1
					-- 		table.insert(pRewardGoods,tData)		
					-- 	end				
					-- end
					-- --奖励物品显示
					-- if pRewardGoods and table.nums(pRewardGoods)> 0 then
					-- 	self.pLbRewardTips:setVisible(false)
					-- else
					-- 	self.pLbRewardTips:setVisible(true)
					-- 	self.pLbRewardTips:setString(getConvertedStr(5, 10255))
					-- end
					-- for k,v in pairs(pRewardGoods) do
					-- 	if k<5 then --超出部分不做展示
					-- 		local pLayer =  ItemFubenGetReward.new()
					-- 		pLayer:setCurData(v)
					-- 		if k<3 then
					-- 			self.pLyGetItem1:addView( pLayer)
					-- 		elseif (k>2) and (k<5) then
					-- 			self.pLyGetItem2:addView( pLayer)
					-- 		end
					-- 		if k%2 == 0 then
					-- 			pLayer:setPositionX(pLayer:getWidth())
					-- 		end
					-- 	end
					-- end
					--获得物品显示刷新
					local pRewardGoods = self:refreshShowItems()
					self:runWinPanelAction(pRewardGoods)--显示胜利动画
					--显示主公
					if self.tAvaAddExpVo then
						self.pLyPlayer:setVisible(true)
						self.pLayPlayer:setCurData(self.tAvaAddExpVo)
					end
				end
			end) 

		end, 0.1)

		local nChaId, tHeroIdList = Player:getFuben():getChanllengeId()
		self.nChaId = nChaId
		self.tHeroIdList = tHeroIdList
		local tPostData = Player:getFuben():getLevelById(nChaId)
		self.tPostData = tPostData

		if (tPostData.nType == 2 and tPostData:isWpFragmentsMax()) or 
			(tPostData.nType == 5 and tPostData:isResourceMax()) then
			self:hideBtnR()
		else
			local tOpenChapters = Player:getFuben():getOpenChpater()
			--前4章在新手期也需要屏蔽继续挑战按钮
			if tPostData.nCanRepeat == 1 and #tOpenChapters > 5 then
				--刷新右边按钮
				self:refreshBtnR()

			else
				self:hideBtnR()
			end
		end

	
		self.pLbTnolyTips:setVisible(false)
		self.pLayGoTnoly:setVisible(false)
	end

	-- --英雄升级经验数据
 	for i=1,4 do
 		local pLyHero = self:findViewByName("ly_hero_"..i)
		self.pLyHeroExps[i] = ItemHeroExps.new()
		if self.tUpdateHeroData[i] then
			self.pLyHeroExps[i]:setCurData(self.tUpdateHeroData[i])
		else
			local nIconType =  TypeIconHero.LOCK
			--锁住类型待添加
			if i> Player:getHeroInfo().nOnlineNums then
				nIconType = TypeIconHero.LOCK
			else
				nIconType = TypeIconHero.ADD
			end

			--设置icon类型
			self.pLyHeroExps[i]:setIConType(nIconType)
		end
		pLyHero:addView(self.pLyHeroExps[i])
		centerInView(pLyHero, self.pLyHeroExps[i])
	end

	--获得物品显示刷新
	if self.bHideHeros then

		self:hideBtnR()
	end
end

--物品显示刷新
function DlgFubenResult:refreshShowItems( ... )
	-- body
	--奖励物品
	local pRewardGoods = {}
	pRewardGoods = getRewardItemsFromSever(self.tAd) or {}					
	--国器碎片需要前端加上奖励
	if self.tData.arft then
		local tData = {}
		tData = clone(getBaseWeaponDataByID(self.tData.arft))
		tData.nCt = self.tData.arftN or 1
		tData.sIcon = tData.sFraIcon --特殊处理得用神兵碎片的图片
		table.insert(pRewardGoods,tData)
	end
	--资源建筑碎片
	if self.tData.filed then
		local tDraw = getSubBDatasFromDBByCell(self.tData.filed)
		if tDraw then
			-- dump(tDraw, "tDraw", 100)
			local tData = {}						
			tData.nQuality = 4
			tData.sIcon = "#"..tDraw.icon..".png" --特殊处理得用神兵碎片的图片
			tData.sName = tDraw.drawingname
			tData.nCt = self.tData.filedN or 1
			table.insert(pRewardGoods,tData)		
		end				
	end
	--奖励物品显示
	if pRewardGoods and table.nums(pRewardGoods)> 0 then
		self.pLbRewardTips:setVisible(false)
	else
		self.pLbRewardTips:setVisible(true)
		self.pLbRewardTips:setString(getConvertedStr(5, 10255))
	end
	for k,v in pairs(pRewardGoods) do
		if k<5 then --超出部分不做展示
			local pLayer =  ItemFubenGetReward.new()
			pLayer:setCurData(v)
			if k<3 then
				self.pLyGetItem1:addView( pLayer)
			elseif (k>2) and (k<5) then
				self.pLyGetItem2:addView( pLayer)
			end
			if k%2 == 0 then
				pLayer:setPositionX(pLayer:getWidth())
			end
		end
	end	
	return pRewardGoods
end
--物品显示
function DlgFubenResult:showItemsPanel( _pRewardGoods )
	-- body
	local pRewardGoods = _pRewardGoods
	local nGetNums = table.nums(pRewardGoods)
	if self.bHideHeros then
		local nHeightOff = 250
		self.pImgPrizeBg:setPositionY(self.pImgPrizeBg:getPositionY() + nHeightOff)	
		self.pLbPrizeTitle:setPositionY(self.pLbPrizeTitle:getPositionY() + nHeightOff)	
		self.pLbRewardTips:setPositionY(self.pLbRewardTips:getPositionY() + nHeightOff)	
		self.pLyGetItem1:setPositionY(self.pLyGetItem1:getPositionY() + nHeightOff)	
		self.pLyGetItem2:setPositionY(self.pLyGetItem2:getPositionY() + nHeightOff)				
	end	
	self.pImgPrizeBg:setVisible(true)
	self.pLbPrizeTitle:setVisible(true)

	if nGetNums == 0 then --没有获得物品的时候

	elseif nGetNums>=1 and nGetNums<=2 then --获得1~2个物品的时候
		self.pLyGetItem1:setVisible(true)
	else      --超出4个物品时
		self.pLyGetItem1:setVisible(true)
		self.pLyGetItem2:setVisible(true)
	end
end

function DlgFubenResult:hideBtnR(  )
	-- body
	self .pBtnR:setVisible(false)
	self.pLyBtnL:setPositionX((self.pLyDown:getWidth() - self.pLyBtnL:getWidth())/2)
	if self.pLbTili then
		self.pLbTili:setVisible(false)
	end
end

--刷新右边按钮
function DlgFubenResult:refreshBtnR()
	-- body
	if self.pBtnR:isVisible() == false then
		return
	end
	if not self.pLbTili then
		self.pLbTili = MUI.MLabel.new({text = "", size = 18})
		self.pLyBtnR:addView(self.pLbTili, 2)
		self.pLbTili:setPosition(self.pLyBtnR:getWidth()/2, self.pLyBtnR:getHeight() + 5)
	end
	--挑战类型
	local nChaType = Player:getFuben():getChanllengeType()
	if nChaType == 1 then --继续挑战
		self.pBtnR:updateBtnText(getConvertedStr(7, 10223))
		local sColor = _cc.green
		if Player:getPlayerInfo().nEnergy < tonumber(self.tPostData.nCost) then
			sColor = _cc.red

		end
		local tLabel = {
			{text = getConvertedStr(5,10040), color = _cc.pwhite},
			{text = Player:getPlayerInfo().nEnergy, color = sColor},
			{text = "/", color = _cc.pwhite},
			{text = self.tPostData.nCost},
			
		}
		self.pLbTili:setString(tLabel)
	else
		self.nTimes = math.floor(Player:getPlayerInfo().nEnergy / self.tPostData.nCost)
		if self.nTimes == 0 or self.nTimes > 5 then
			self.nTimes = 5
		end
		local sColor = _cc.green
		if Player:getPlayerInfo().nEnergy < tonumber(self.tPostData.nCost)*self.nTimes then
			sColor = _cc.red

		end

		self.pBtnR:updateBtnText(string.format(getConvertedStr(7, 10224), self.nTimes)) --扫荡%s次
		local tLabel = {
			{text = getConvertedStr(5,10040), color = _cc.pwhite},
			{text = Player:getPlayerInfo().nEnergy, color = sColor},
			{text = "/", color = _cc.pwhite},
			{text = self.tPostData.nCost*self.nTimes},
		}
		self.pLbTili:setString(tLabel)
	end
end
	--展示战斗胜利时的动画
function DlgFubenResult:runWinPanelAction(_pRewardGoods)
	-- body
	local pRewardGoods = _pRewardGoods
	local nGetNums = table.nums(pRewardGoods)
	if self.bHideHeros then
		local nHeightOff = 250
		self.pImgPrizeBg:setPositionY(self.pImgPrizeBg:getPositionY() + nHeightOff)	
		self.pLbPrizeTitle:setPositionY(self.pLbPrizeTitle:getPositionY() + nHeightOff)	
		self.pLbRewardTips:setPositionY(self.pLbRewardTips:getPositionY() + nHeightOff)	
		self.pLyGetItem1:setPositionY(self.pLyGetItem1:getPositionY() + nHeightOff)	
		self.pLyGetItem2:setPositionY(self.pLyGetItem2:getPositionY() + nHeightOff)				
	end	
	self.pImgPrizeBg:setVisible(true)
	self.pLbPrizeTitle:setVisible(true)

	if nGetNums == 0 then --没有获得物品的时候

		-- self.pImgExpBg:setPositionY(self.pImgExpBg:getPositionY() + 100)
		-- self.pLbExpTitle:setPositionY(self.pLbExpTitle:getPositionY() + 100)
		-- self.pLyShowHero:setPositionY(self.pLyShowHero:getPositionY() + 100)

		local pOriY = self.pLbRewardTips:getPositionY() 
		-- self.pLbRewardTips:setPositionY(pOriY-100)
		self.pLbRewardTips:setOpacity(0)

		local pMoveTo =   cc.MoveTo:create(0.15, cc.p(self.pLbRewardTips:getPositionX(),pOriY))
		local pFadeTo1  = cc.FadeTo:create(0.15, 255)
		local action1 = cc.Spawn:create(pMoveTo,pFadeTo1)

		local fCallback = cc.CallFunc:create(function (  )
			self:playHeroAction()--显示英雄获得经验动作
		end)
		self.pLbRewardTips:runAction(cc.Sequence:create(action1,fCallback))

	elseif nGetNums>=1 and nGetNums<=2 then --获得1~2个物品的时候
		-- self.pImgExpBg:setPositionY(self.pImgExpBg:getPositionY() + 100)
		-- self.pLbExpTitle:setPositionY(self.pLbExpTitle:getPositionY() + 100)
		-- self.pLyShowHero:setPositionY(self.pLyShowHero:getPositionY() + 100)

		local pOriY = self.pLyGetItem1:getPositionY() 
		self.pLyGetItem1:setVisible(true)
		-- self.pLyGetItem1:setPositionY(pOriY-100)
		self.pLyGetItem1:setOpacity(0)

		local pMoveTo =  cc.MoveTo:create(0.15, cc.p(self.pLyGetItem1:getPositionX(),pOriY))
		local pFadeTo1  = cc.FadeTo:create(0.15, 255)
		local action1 = cc.Spawn:create(pMoveTo,pFadeTo1)

		local fCallback = cc.CallFunc:create(function (  )
			self:playHeroAction()--显示英雄获得经验动作
		end)
		self.pLyGetItem1:runAction(cc.Sequence:create(action1,fCallback))
	else      --超出4个物品时
		-- self.pImgExpBg:setPositionY(self.pImgExpBg:getPositionY() + 40)
		-- self.pLbExpTitle:setPositionY(self.pLbExpTitle:getPositionY() + 40)
		-- self.pLyShowHero:setPositionY(self.pLyShowHero:getPositionY() + 40)

		self.pLyGetItem1:setVisible(true)
		self.pLyGetItem2:setVisible(true)
		local pOriY = self.pLyGetItem1:getPositionY() 
		-- self.pLyGetItem1:setPositionY(pOriY-100)
		self.pLyGetItem1:setOpacity(0)


		local pOriY2 = self.pLyGetItem2:getPositionY() 
		-- self.pLyGetItem2:setPositionY(pOriY2-100)
		self.pLyGetItem2:setOpacity(0)

		local pMoveTo =   cc.MoveTo:create(0.15, cc.p(self.pLyGetItem1:getPositionX(),pOriY))
		local pFadeTo1  = cc.FadeTo:create(0.15, 255)
		local action1 = cc.Spawn:create(pMoveTo,pFadeTo1)

		local fCallback = cc.CallFunc:create(function (  )

			local pMoveTo2 =   cc.MoveTo:create(0.15, cc.p(self.pLyGetItem2:getPositionX(),pOriY2))
			local pFadeTo2  = cc.FadeTo:create(0.15, 255)
			local action2 = cc.Spawn:create(pMoveTo2,pFadeTo2)

			local fCallback2 = cc.CallFunc:create(function (  )
				self:playHeroAction()--显示英雄获得经验动作
			end)
			self.pLyGetItem2:runAction(cc.Sequence:create(action2,fCallback2))

		end)
		self.pLyGetItem1:runAction(cc.Sequence:create(action1,fCallback))

	end
end

function DlgFubenResult:resetWinPanelContentHeight( )
	-- self.pLyShowHero:setPositionY(self.pLyShowHero:getPositionY()-20)--展示英雄层
	-- self.pLyGetItem1:setPositionY(self.pLyGetItem1:getPositionY()-20) --获得层1
	-- self.pLyGetItem2:setPositionY(self.pLyGetItem2:getPositionY()-20) --获得层2
	-- self.pImgExpBg:setPositionY(self.pImgExpBg:getPositionY()-20)
	-- self.pLbExpTitle:setPositionY(self.pLbExpTitle:getPositionY()-20)
	-- self.pImgPrizeBg:setPositionY(self.pImgPrizeBg:getPositionY()-20)
	-- self.pLbPrizeTitle:setPositionY(self.pLbPrizeTitle:getPositionY()-20)
end



--判断3009 初级御兵术3010 中级军势3016 中级御兵术3020 高级军势 这些科技是否达到1级
function DlgFubenResult:getAllTnolyLvToCertainLv()
	local nIndex = 0
	local nCount = 0
	
	for k,v in pairs(TnolyId) do
		local pTnoly = Player:getTnolyData():getTnolyByIdFromAll(v)
	
		if pTnoly and pTnoly.nLv and pTnoly.nLv >= 1 then
			nCount = nCount + 1
		else
			nIndex = k
			break
		end
		
	end
	return  nCount >= table.nums(TnolyId),nIndex
end
--播放文件特效
function DlgFubenResult:playFileTx(_pos,_name,_bLoop)
	-- body

    -- body
    local pArm =  createMArmature(self.pLyWin,tNormalCusArmDatas[_name],function (pArmate)
        if pArmate then
            pArmate:removeSelf()
        end
    end,_pos,10)
    if pArm then
    	if _bLoop  then
        	pArm:play(-1)
        else
        	pArm:play(1)
    	end
    end
end

--播放循环特效文件
function DlgFubenResult:showLoopWinTx()

   local  pArm =  createMArmature(self.pLyWin,tNormalCusArmDatas["24_4"],function (pArmate)
	    if pArmate then
			doDelayForSomething(self.pLyWin, function( )
				self:showLoopWinTx()
			end, 3.5)
		
	        self:playFileTx(cc.p(320,410+nOffsetBgY),"24_5")
	        pArmate:removeSelf()
	    end
    end,cc.p(320,410+nOffsetBgY),10)
    if pArm then
		pArm:setFlippedX(true)
    	if _bLoop  then
        	pArm:play(-1)
        else
        	pArm:play(1)
    	end
    end

	self:playFileTx(cc.p(320,410+nOffsetBgY),"24_3")
end

--播放英雄获得经验动作
function DlgFubenResult:playHeroAction()
	-- body
	self.pImgExpBg:setVisible(not self.bHideHeros)
	self.pLbExpTitle:setVisible(not self.bHideHeros)
	self.pLyShowHero:setVisible(not self.bHideHeros)
	local pOriY = self.pLyShowHero:getPositionY() 
	-- self.pLyShowHero:setPositionY(pOriY-100)
	self.pLyShowHero:setOpacity(0)

	local pMoveTo =   cc.MoveTo:create(0.15, cc.p(self.pLyShowHero:getPositionX(),pOriY))
	local pFadeTo1  = cc.FadeTo:create(0.15, 255)
	local action1 = cc.Spawn:create(pMoveTo,pFadeTo1)

	local fCallback = cc.CallFunc:create(function ()
		if self.nStar > 0 then
			self:showStart1()
		end
		doDelayForSomething(self.pLyWin, function( )
			self:showLoopWinTx()
			self.pLyDown:setVisible(true)--底部按钮层
		end, 0.6)

	end)
	self.pLyShowHero:runAction(cc.Sequence:create(action1,fCallback))
end

--显示获得星数1
function DlgFubenResult:showStart1()


	local star1X = 263
	local star1Y = 800 + 3 + nOffsetBgY


	

	--第一颗,第一层
	local pImg1 =  MUI.MImage.new("#v1_img_result_star.png")
	pImg1:setOpacity(100)
	pImg1:setAnchorPoint(0.5,0.5)
	pImg1:setScale(5.5)
	pImg1:setPosition(star1X-150,star1Y-50)
	self.pLyMain:addView(pImg1,101)

	local pMoveTo =   cc.MoveTo:create(0.23, cc.p(star1X,star1Y))
	local pScaleto  = cc.ScaleTo:create(0.23, 0.75)
	local pFadeTo  = cc.FadeTo:create(0.21, 255)
	local action = cc.Spawn:create(pMoveTo,pScaleto,pFadeTo)

	local fCallback = cc.CallFunc:create(function (  )



		--第一颗,第二层
		local pImg2 =  MUI.MImage.new("#v1_img_result_star.png")
    	pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg2:setAnchorPoint(0.5,0.5)
		pImg2:setScale(0.75)
		pImg2:setPosition(star1X,star1Y)
		self.pLyMain:addView(pImg2,101)
		
		local pFadeTo1  = cc.FadeTo:create(0.12, 255*0.5)
		local pFadeTo2  = cc.FadeTo:create(0.38, 255*0)
		local action1 = cc.Spawn:create(pFadeTo1,pFadeTo2)
		pImg2:runAction(action1)


		--第一颗,第三层
		local pImg3 =  MUI.MImage.new("#v1_img_result_star.png")
    	pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg3:setAnchorPoint(0.5,0.5)
		pImg3:setScale(0.9)
		pImg3:setOpacity(255*0.5)
		pImg3:setPosition(star1X,star1Y)
		self.pLyMain:addView(pImg3,101)

		local pScaleto3  = cc.ScaleTo:create(0.25, 1)
		local pFadeTo3  = cc.FadeTo:create(0.25, 255*0)
		local action3 = cc.Spawn:create(pScaleto3,pFadeTo3)
		pImg3:runAction(action3)

		--粒子
		local pParitcle = createParitcle("tx/other/lizi_jiesjm_001.plist")
		pParitcle:setPosition(star1X,star1Y)
		self.pLyMain:addView(pParitcle,101)

		--播放获得星星声音
		Sounds.playEffect(Sounds.Effect.star)

		--震屏效果
		self:useShakeAction()

		if self.nStar > 1 then
			self:showStart2()
		end

	end)

	pImg1:runAction(cc.Sequence:create(action,fCallback))



end


--显示获得星数2
function DlgFubenResult:showStart2()


	local star1X = 323
	local star1Y = 800 + 3 + nOffsetBgY



	--第2颗,第一层
	local pImg1 =  MUI.MImage.new("#v1_img_result_star.png")
	pImg1:setAnchorPoint(0.5,0.5)
	pImg1:setOpacity(100)
	pImg1:setScale(7)
	pImg1:setPosition(star1X,star1Y-150)
	self.pLyMain:addView(pImg1, 101)

	local pMoveTo =   cc.MoveTo:create(0.23, cc.p(star1X,star1Y))
	local pScaleto  = cc.ScaleTo:create(0.23, 1)
	local pFadeTo  = cc.FadeTo:create(0.21, 255)
	local action = cc.Spawn:create(pMoveTo,pScaleto,pFadeTo)

	local fCallback = cc.CallFunc:create(function (  )




		--第2颗,第二层
		local pImg2 =  MUI.MImage.new("#v1_img_result_star.png")
    	pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg2:setAnchorPoint(0.5,0.5)
		pImg2:setScale(1)
		pImg2:setPosition(star1X,star1Y)
		self.pLyMain:addView(pImg2,101)
		
		local pFadeTo1  = cc.FadeTo:create(0.12, 255*0.5)
		local pFadeTo2  = cc.FadeTo:create(0.38, 255*0)
		local pFadeTo  = cc.FadeTo:create(0.23, 255)

		local action1 = cc.Spawn:create(pFadeTo1,pFadeTo2,pFadeTo)
		pImg2:runAction(action1)


		--第2颗,第三层
		local pImg3 =  MUI.MImage.new("#v1_img_result_star.png")
    	pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg3:setAnchorPoint(0.5,0.5)
		pImg3:setScale(1.1)
		pImg3:setOpacity(255*0.5)
		pImg3:setPosition(star1X,star1Y)
		self.pLyMain:addView(pImg3,101)

		local pScaleto3  = cc.ScaleTo:create(0.25, 1.2)
		local pFadeTo3  = cc.FadeTo:create(0.25, 255*0)
		local action3 = cc.Spawn:create(pScaleto3,pFadeTo3)
		pImg3:runAction(action3)

		--粒子
		local pParitcle = createParitcle("tx/other/lizi_jiesjm_001.plist")
		pParitcle:setPosition(star1X,star1Y)
		pParitcle:setScale(1.1)
		self.pLyMain:addView(pParitcle,101)

		--播放获得星星声音
		Sounds.playEffect(Sounds.Effect.star)


		if self.nStar > 2 then
			self:showStart3()
		end

		--震屏效果
		self:useShakeAction()

	end)

	pImg1:runAction(cc.Sequence:create(action,fCallback))



end


--显示获得星数3
function DlgFubenResult:showStart3()


	local star1X = 383
	local star1Y = 800 + 3 + nOffsetBgY


	--第3颗,第一层
	local pImg1 =  MUI.MImage.new("#v1_img_result_star.png")
	pImg1:setAnchorPoint(0.5,0.5)
	pImg1:setScale(5.5)
	pImg1:setOpacity(100)
	pImg1:setPosition(star1X+150,star1Y-50)
	self.pLyMain:addView(pImg1,101)

	local pMoveTo =   cc.MoveTo:create(0.23, cc.p(star1X,star1Y))
	local pScaleto  = cc.ScaleTo:create(0.23, 0.75)
	local pFadeTo  = cc.FadeTo:create(0.21, 255)

	local action = cc.Spawn:create(pMoveTo,pScaleto,pFadeTo)

	local fCallback = cc.CallFunc:create(function (  )



		--第3颗,第二层
		local pImg2 =  MUI.MImage.new("#v1_img_result_star.png")
    	pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg2:setAnchorPoint(0.5,0.5)
		pImg2:setScale(0.75)
		pImg2:setPosition(star1X,star1Y)
		self.pLyMain:addView(pImg2,101)
		
		local pFadeTo1  = cc.FadeTo:create(0.12, 255*0.5)
		local pFadeTo2  = cc.FadeTo:create(0.38, 255*0)
		local action1 = cc.Spawn:create(pFadeTo1,pFadeTo2)
		pImg2:runAction(action1)


		--第3颗,第三层
		local pImg3 =  MUI.MImage.new("#v1_img_result_star.png")
    	pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg3:setAnchorPoint(0.5,0.5)
		pImg3:setScale(0.9)
		pImg3:setOpacity(255*0.5)
		pImg3:setPosition(star1X,star1Y)
		self.pLyMain:addView(pImg3,101)

		local pScaleto3  = cc.ScaleTo:create(0.25, 1)
		local pFadeTo3  = cc.FadeTo:create(0.25, 255*0)
		local action3 = cc.Spawn:create(pScaleto3,pFadeTo3)
		pImg3:runAction(action3)

		--粒子
		local pParitcle = createParitcle("tx/other/lizi_jiesjm_001.plist")
		pParitcle:setPosition(star1X,star1Y)
		self.pLyMain:addView(pParitcle,101)

		--播放获得星星声音
		Sounds.playEffect(Sounds.Effect.star)

		--震屏效果
		self:useShakeAction()

	end)

	pImg1:runAction(cc.Sequence:create(action,fCallback))



end


-- 修改控件内容或者是刷新控件数据
function DlgFubenResult:updateViews()
	if not self.tData then
		return
	end



end

--前往科技院按钮点击回调
function DlgFubenResult:onGoBtnTnolyClicked( pView )
	local bRes , nIndex = self:getAllTnolyLvToCertainLv()
	if bRes then
		return 
	end
	local nEndHandler = self.nEndHanlder 
	if nEndHandler then
		nEndHandler()
	end

	closeDlgByType(e_dlg_index.fubenmap,false)
	closeDlgByType(e_dlg_index.fubenlayer,false)
	closeDlgByType(e_dlg_index.fubenresult,false)
	closeDlgByType(e_dlg_index.mail,false)
	closeMailDetail()
	--关闭战斗界面
	sendMsg(ghd_fight_close)

	--跳转到其他界面的话清除奖励弹窗
	clearTaskReward()
	--允许提示弹框
	showNextSequenceFunc(e_show_seq.fight)

	 --跳转到科技树界面
	local tObject = {}
	tObject.nType = e_dlg_index.tnolytree --dlg类型
	tObject.tData = Player:getTnolyData():getTnolyByIdFromAll(TnolyId[nIndex])
	sendMsg(ghd_show_dlg_by_type,tObject)
	closeDlgByType(e_dlg_index.alert)
end

--左边按钮
function DlgFubenResult:onTitleBtnLClicked(pView)
	local bInArena = self.bHideHeros
	local nHandler = self.nCloseHandler
	local nEndHandler = self.nEndHanlder  
	sendMsg(ghd_renotice_taskprize_msg)
	-- body
	closeDlgByType(e_dlg_index.fubenresult,false)
	-- --关闭战斗界面
	sendMsg(ghd_fight_close)

	--允许提示弹框
	showNextSequenceFunc(e_show_seq.fight)

	--打开弹窗类提示信息
	setToastNCState(2)
	--战斗结束后播放战力变化
	Player:getPlayerInfo():playFCChangeTx()
	--战斗借宿后播放竞技场排行变化	
	if bInArena and nHandler then
		nHandler()
	end

	if nEndHandler then
		nEndHandler(true)
	end
end

--右边按钮
function DlgFubenResult:onTitleBtnRClicked(pView)
	if self.pBtnR:getBtnText() == getConvertedStr(7, 10223) then --继续挑战
		if Player:getPlayerInfo().nEnergy < tonumber(self.tPostData.nCost) then
			gotoBuyEnergy()
		else
			SocketManager:sendMsg("challengeFubenLevel", {self.nChaId, self.tHeroIdList}, handler(self, self.onGetDataFunc))
		end
	else --扫荡%s次
		if Player:getPlayerInfo().nEnergy < (self.tPostData.nCost*self.nTimes) then
			gotoBuyEnergy()
		else
			--加这个是防止快速点击请求多次
			if not self.bIsSweepping then
				self.bIsSweepping = true
				SocketManager:sendMsg("sweepFubenLevel", {self.nChaId, self.nTimes, self.tHeroIdList}, handler(self, self.onGetDataFunc))
			end
		end
	end

end

--接收服务端发回的登录回调
function DlgFubenResult:onGetDataFunc( __msg , __oldmsg)
    if  __msg.head.state == SocketErrorType.success then 
        closeDlgByType(e_dlg_index.fubenresult,false)
        --关闭战斗界面
		sendMsg(ghd_fight_close)
        if __msg.head.type == MsgType.challengeFubenLevel.id then
        	-- dump(__msg.body,"__msg.body",100)
        	if __oldmsg and __oldmsg[2] then
        		Player:getHeroInfo():saveLocalHeroOrder(luaSplit(__oldmsg[2], ";"))
        	end
        	sendMsg(gud_refresh_fuben) --通知刷新界面
        	--战斗表现
        	showFight(__msg.body.report,function (  )
        		showFightRst(__msg.body)
        	end,nil,function ()
        		-- body
        	end)        	
        elseif __msg.head.type == MsgType.sweepFubenLevel.id  then
        	--todo        
        	--打开战斗结果界面
        	local pData = __msg.body
        	pData.nResult = 1
        	showFightRst(pData)
        	sendMsg(gud_refresh_fuben) --通知刷新界面
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
        --打开弹窗类提示信息
		setToastNCState(2)
		--允许提示弹框
		showNextSequenceFunc(e_show_seq.fight)
    end
    self.bIsSweepping = false
end

--回到主城
function DlgFubenResult:onBackMainCity( pView )
	-- body
	closeDlgByType(e_dlg_index.fubenmap,false)
	closeDlgByType(e_dlg_index.fubenlayer,false)
	closeDlgByType(e_dlg_index.fubenresult,false)
	closeDlgByType(e_dlg_index.mail,false)
	closeMailDetail()
	--关闭战斗界面
	sendMsg(ghd_fight_close)

	--允许提示弹框
	showNextSequenceFunc(e_show_seq.fight)

	--打开弹窗类提示信息
	setToastNCState(2)
	--战斗结束后播放战力变化
	Player:getPlayerInfo():playFCChangeTx()
end

function DlgFubenResult:onBackCity()
	-- body
	closeDlgByType(e_dlg_index.fubenresult,false)
	sendMsg(ghd_home_show_base_or_world, 1) --打开主城
	--关闭战斗界面
	sendMsg(ghd_fight_close)

	--允许提示弹框
	showNextSequenceFunc(e_show_seq.fight)

	--打开弹窗类提示信息
	setToastNCState(2)
	--战斗结束后播放战力变化
	Player:getPlayerInfo():playFCChangeTx()	
end

--获取震屏效果
function DlgFubenResult:useShakeAction()

	self.pLyMain:stopAllActions()

	local pMoveTo1 = cc.MoveTo:create(0.05, cc.p(0,-2))
	local pMoveTo2 = cc.MoveTo:create(0.05, cc.p(0,3))
	local pMoveTo3 = cc.MoveTo:create(0.05, cc.p(0,-1))
	local pMoveTo4 = cc.MoveTo:create(0.05, cc.p(0,0))

	self.pLyMain:runAction(cc.Sequence:create(pMoveTo1,pMoveTo2,pMoveTo3,pMoveTo4)) 
	
end

--继续方法
function DlgFubenResult:onResume( )
	-- body
	--addTextureToCache("tx/other/sg_tx_jmtx_smjsj")
	self:updateViews()
	self:regMsgs()
	
end

--创建光芒图片
function DlgFubenResult:creatLightImg()
	-- body
	local nRold =  math.random(0,360)
	local pImg =  MUI.MImage.new("#sg_slhmdg_zdg_01.png")
	pImg:setRotation(nRold)
	pImg:setAnchorPoint(0.5,0.5)
	pImg:setScale(0.96)
	pImg:setOpacity(0)
	pImg:setPosition(320,823)
	self.pLyMain:addView(pImg,-1)

	local pImg1 =  MUI.MImage.new("#sg_slhmdg_zdg_01.png")
	pImg1:setRotation(nRold)
	pImg1:setAnchorPoint(0.5,0.5)
	pImg1:setScale(0.96)
	pImg1:setOpacity(0)
	pImg1:setPosition(320,823)
    pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	self.pLyMain:addView(pImg1,-1)

	for i=1,2 do
		local pOj = nil
		if i== 1 then
			pOj = pImg
		elseif i ==2 then
			pOj = pImg1
		end

		if pOj then
			local pScaleTo1 =  cc.ScaleTo:create(0.5, 1.19)
			local pFadeTo1  = cc.FadeTo:create(0.5, 255)
			local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1)

			local pScaleTo2 =  cc.ScaleTo:create(0.65, 1.48)
			local pFadeTo2  = cc.FadeTo:create(0.65, 0)
			local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)

			local fCallback = cc.CallFunc:create(function (  )
				pOj:removeFromParent(true)
			end)

			pOj:runAction(cc.Sequence:create(action1,action2,fCallback))
		end
	end

end

-- 注册消息
function DlgFubenResult:regMsgs( )
	-- body
	-- 注册玩家能量刷新消息
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.refreshBtnR))
end

-- 注销消息
function DlgFubenResult:unregMsgs(  )
	-- body
	-- 销毁玩家能量刷新消息
	unregMsg(self, ghd_refresh_energy_msg)
end


-- icon点击
function DlgFubenResult:onViewClick(pVeiw)

	-- dump(pVeiw.nTpIndex,"pVeiw.nTpIndex")
	-- if pVeiw.nTpIndex then
	--    if  pVeiw.nTpIndex == 1 then

	--    elseif pVeiw.nTpIndex == 2 then

	--    elseif pVeiw.nTpIndex == 3 then

	--    elseif pVeiw.nTpIndex == 4 then

	--    end
	-- end
end



--暂停方法
function DlgFubenResult:onPause( )
	-- body
	--removeTextureFromCache("tx/other/sg_tx_jmtx_smjsj")


	if self.nWin == 1  then


		-- sendMsg(gud_show_fuben_line)

		local function func()
			local tNewOpen = Player:getFuben():getNewPostOpen()
			local tMsg = {}
			tMsg.tNewOpen = tNewOpen
			sendMsg(ghd_show_fuben_openpost_tx, tMsg)
		end
		doInAllOverFuncOnce( func )
	end



	self:unregMsgs()
end


--析构方法
function DlgFubenResult:onDestroy()
	self:onPause()
	nCollectCnt = 2
end

return DlgFubenResult