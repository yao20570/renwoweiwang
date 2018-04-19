-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-14 17:02:39 星期五
-- Description: 展示解锁建筑提示框
-----------------------------------------------------


local MDialog = require("app.common.dialog.MDialog")
local DlgUnlockBuild = class("DlgUnlockBuild", function ()
	return MDialog.new()
end)

function DlgUnlockBuild:ctor( _tBuildInfo )
	-- body
	self:myInit()

	if not _tBuildInfo then
		return
	end
    self:setIsNeedOutside(false)

    self.tAllBuildDatas = _tBuildInfo
    self.tBuildData = self.tAllBuildDatas.tLists[1] 
    self.tShowData = getBuildGroupShowDataByCell(self.tBuildData.nCellIndex,self.tBuildData.sTid)

	parseView("dlg_unlock_build", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgUnlockBuild:myInit(  )
	-- body
	self.eDlgType 		= e_dlg_index.unlockbuild   --对话框类型
	self.tBuildData 	= nil 						--建筑数据 
	self.tAllBuildDatas = nil 						--所有该类型解锁的建筑
	self.tShowData 		= nil 		                --建筑展示相关数据
end

--解析布局回调事件
function DlgUnlockBuild:onParseViewCallback( pView )
	-- body
	self:setContentView(pView)
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("DlgUnlockBuild",handler(self, self.onDlgUnlockBuildDestroy))
end

-- 修改控件内容或者是刷新控件数据
function DlgUnlockBuild:updateViews(  )
	-- body
	if self.tBuildData then
		-- 分帧执行实际的刷新
		gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
			if(_index == 1) then
				-- body
				--设置标题
				if self.pLbTitle == nil then
					self.pLbTitle = self:findViewByName("lb_title")
					setTextCCColor(self.pLbTitle, _cc.white)
				end
				self.pLbTitle:setString(getConvertedStr(1, 10253))

				--设置名字
				if(self.pLbName == nil) then
					self.pLbName =  self:findViewByName("lb_name")
				end
				self.pLbName:setString({
					{text=getConvertedStr(1, 10254),color=getC3B(_cc.pwhite)},
				 	{text=self.tBuildData.sName,color=getC3B(_cc.yellow)},
				})
			elseif(_index == 2) then
				--设置内容
				if self.pLbDesc == nil then
					self.pLbDesc = self:findViewByName("lb_desc")
					setTextCCColor(self.pLbDesc, _cc.pwhite)
				end

				self.pLbDesc:setString(getTextColorByConfigure(self.tBuildData.sDes))
				--设置提示语
				if self.pLbTips == nil then
					self.pLbTips = self:findViewByName("lb_tips")
					setTextCCColor(self.pLbTips, _cc.pwhite)
				end
				self.pLbTips:setString(getConvertedStr(1, 10255))
			elseif(_index == 3) then
				--获得内容层 
				if self.pLayCon == nil then
					self.pLayCon = self:findViewByName("lay_main")
				end
				--展示特效
				self:showOpenTx()
			end 
			if(_bEnd) then
				--1秒后关闭提示框
				doDelayForSomething(self, function (  )
					-- body
					self:jumpToShowBuildUnLocked()
				end,5.0)
			end
		end)
	end
	
end

--展示解锁动画
function DlgUnlockBuild:jumpToShowBuildUnLocked(  )
	-- body
	--发送消息展示特效
	local tObj = {}
	tObj.tData = self.tAllBuildDatas
	sendMsg(ghd_show_tx_unlock_build_msg,tObj)
	self:closeDlg()
end

-- 析构方法
function DlgUnlockBuild:onDlgUnlockBuildDestroy(  )
	-- body
end

--展示解锁特效
function DlgUnlockBuild:showOpenTx(  )
	--添加纹理
	addTextureToCache("tx/other/p1_tx_jzjs")
	-- body
	local fScale = 1
	local tPos = cc.p(100,100)
	local tBgPos = cc.p(100,100)
	if self.tBuildData.sTid == e_build_ids.house
		or self.tBuildData.sTid == e_build_ids.farm
		or self.tBuildData.sTid == e_build_ids.iron
		or self.tBuildData.sTid == e_build_ids.wood then --资源田
		tPos = cc.p(self.tShowData.w * self.tShowData.fDzRw + 40,self.pLayCon:getHeight() / 2)
		tBgPos = tPos
	elseif self.tBuildData.sTid == e_build_ids.store then --仓库
		fScale = 0.8
		tPos = cc.p(self.tShowData.w * self.tShowData.fDzRw - 30,self.tShowData.h * self.tShowData.fDzRh + 30)
		tBgPos = tPos
	elseif self.tBuildData.sTid == e_build_ids.tnoly then --科技院
		fScale = 0.65
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 170),(self.tShowData.h * self.tShowData.fDzRh + 45))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 120),(self.tShowData.h * self.tShowData.fDzRh + 30))
	elseif self.tBuildData.sTid == e_build_ids.infantry then --步兵营
		fScale = 0.8
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 100),(self.tShowData.h * self.tShowData.fDzRh + 30))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 80),(self.tShowData.h * self.tShowData.fDzRh + 25))
	elseif self.tBuildData.sTid == e_build_ids.sowar then --骑兵营
		fScale = 0.7
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 100),(self.tShowData.h * self.tShowData.fDzRh + 30))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 80),(self.tShowData.h * self.tShowData.fDzRh + 25))
	elseif self.tBuildData.sTid == e_build_ids.archer then --弓兵营
		fScale = 0.7
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 110),(self.tShowData.h * self.tShowData.fDzRh + 35))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 95),(self.tShowData.h * self.tShowData.fDzRh + 25))
	elseif self.tBuildData.sTid == e_build_ids.gate then --城墙
		fScale = 0.5
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 10),(self.tShowData.h * self.tShowData.fDzRh - 65))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 10),(self.tShowData.h * self.tShowData.fDzRh - 65))
	elseif self.tBuildData.sTid == e_build_ids.atelier then --作坊
		fScale = 0.7
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 85),(self.tShowData.h * self.tShowData.fDzRh + 35))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 70),(self.tShowData.h * self.tShowData.fDzRh + 25))
	elseif self.tBuildData.sTid == e_build_ids.tjp then --铁匠铺
		fScale = 0.7
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 125),(self.tShowData.h * self.tShowData.fDzRh + 25))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 100),(self.tShowData.h * self.tShowData.fDzRh + 15))
	elseif self.tBuildData.sTid == e_build_ids.ylp then --冶炼铺
		fScale = 0.7
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 85),(self.tShowData.h * self.tShowData.fDzRh + 25))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 70),(self.tShowData.h * self.tShowData.fDzRh + 15))
	elseif self.tBuildData.sTid == e_build_ids.jxg then --将军府
		-- fScale = 0.7
		-- tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 95),(self.tShowData.h * self.tShowData.fDzRh + 40))
		-- tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 80),(self.tShowData.h * self.tShowData.fDzRh + 30))
		fScale = 0.8
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 40),(self.tShowData.h * self.tShowData.fDzRh + 40))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 25),(self.tShowData.h * self.tShowData.fDzRh + 30))
	elseif self.tBuildData.sTid == e_build_ids.jbp then --珍宝阁
		fScale = 0.8
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 40),(self.tShowData.h * self.tShowData.fDzRh + 40))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 25),(self.tShowData.h * self.tShowData.fDzRh + 30))
	elseif self.tBuildData.sTid == e_build_ids.bjt then --拜将台
		fScale = 0.7
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 95),(self.tShowData.h * self.tShowData.fDzRh + 40))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 80),(self.tShowData.h * self.tShowData.fDzRh + 30))
	elseif self.tBuildData.sTid == e_build_ids.tcf then --统帅府
		fScale = 0.8
		tPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 40),(self.tShowData.h * self.tShowData.fDzRh + 40))
		tBgPos = cc.p((self.tShowData.w * self.tShowData.fDzRw - 25),(self.tShowData.h * self.tShowData.fDzRh + 30))		
	end
	
	--第一层
	local pParitcle = createParitcle("tx/other/lizi_huode_xjz_lzdh_001.plist")
	pParitcle:setPosition(tBgPos)
	self.pLayCon:addView(pParitcle,10)
	--第二层
	local pImg1 = getCircleRepeatForever("#sg_guqt__2_sa1_001.png",9,true)
	pImg1:setPosition(tBgPos)
	self.pLayCon:addView(pImg1,20)
	--第三层
	local pImg2 = getCircleRepeatForever("#sg_guqt__2_sa1_002.png",6,true)
	pImg2:setPosition(tBgPos)
	self.pLayCon:addView(pImg2,30)
	--第四层
	local pImg3 = MUI.MImage.new(self.tShowData.img) --这里先临时全部统一用这个图片
	pImg3:setPosition(tPos)
	pImg3:setScale(fScale)
	self.pLayCon:addView(pImg3,40)
	--第五层
	local pImg4 = MUI.MImage.new(self.tShowData.img) --这里先临时全部统一用这个图片
	pImg4:setPosition(tPos)
	pImg4:setScale(fScale)
	pImg4:setOpacity(13)
	self.pLayCon:addView(pImg4,50)
	self:showScaleRepeatForever(pImg4)
	--第六层
	self:showLightTx(tBgPos)
end

--循环缩放
function DlgUnlockBuild:showScaleRepeatForever( _pView )
	-- body
	local action1 = cc.FadeTo:create(0.6, 50)
	local action2 = cc.FadeTo:create(0.6, 13)
	local allActions = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
	_pView:runAction(allActions)
end

--展示光晕效果
function DlgUnlockBuild:showLightTx( _tPos )
	-- body
	local pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["8"], 
		self.pLayCon, 
		60, 
		_tPos,
	    function ( _pArm )

	    end, Scene_arm_type.base)
	if pArm then
		pArm:play(-1)
	end
end

return DlgUnlockBuild