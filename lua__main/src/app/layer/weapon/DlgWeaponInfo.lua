-- DlgWeaponInfo.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-05-31 19:41:26 星期三
-- Description: 神兵详细信息
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local WeaponFragments = require("app.layer.weapon.WeaponFragments")
local WeaponUpgrade = require("app.layer.weapon.WeaponUpgrade")
local WeaponIcon = require("app.layer.weapon.WeaponIcon")

local DlgWeaponInfo = class("DlgWeaponInfo", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgweaponinfo)
end)

function DlgWeaponInfo:ctor(_index)
	-- body
	self:myInit(_index)
	parseView("dlg_weapon_info", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgWeaponInfo:myInit(_index)
	-- body
	self.tWeaponSerData = Player:getWeaponInfo()
	self.nIndex = _index                             --初始页
	self.tBaseData = self.tWeaponSerData:getWeaponList()
	self.nWeaponId = self.tBaseData[_index].nId                      --神兵id
	self.nRealIdx = _index                           --实际页
	self.nWeaponTotalCnt = 6                         --总神兵个数
	self.tImgWeapon = {}                             --神兵图片列表
	self.tWeaponIcons = {}                           --神兵小icon列表
	self.pWeaponSecImgs = {}                         --神兵第二层图标
	self.pWeaponThirdImgs = {}                       --神兵第三层图标
	self.isHasPlayAction = {}                        --神兵是否播放特效列表(如果已经播放过说明已经解锁了, 下次再刷新数据就不用刷新特效了)


    addTextureToCache("tx/other/p1_tx_weapon")
end

--解析布局回调事件
function DlgWeaponInfo:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgWeaponInfo",handler(self, self.onDlgHelpDestroy))
end

--初始化控件
function DlgWeaponInfo:setupViews()
	--设置标题
	self:setTitle(getConvertedStr(7, 10009))
	self.pLayRoot      = self:findViewByName("default")
	self.pLayBg        = self:findViewByName("lay_bg")
	--顶部列表层
	self.pLayTopList   = self:findViewByName("lay_top_list")
	--神兵名字
	self.pLbName       = self:findViewByName("lb_w_name")
	self.pLayCenter    = self:findViewByName("lay_center")
	--显示阶数层
	self.pLayJie       = self:findViewByName("lay_jie")
	--阶数
	self.pLbJie        = self:findViewByName("lb_jie")
	self.pLbJie = MUI.MLabelAtlas.new({text="234566", 
	    png="ui/atlas/v1_img_shuzitongyong.png", pngw=32, pngh=52, scm=48})
	self.pLbJie:setScale(0.7)
	self.pLayJie:addView(self.pLbJie, 1000, 100)
	self.pLbJie:setPosition(26, 30)
	--分享
	self.pLayShare     = self:findViewByName("lay_share")
	self.pLayShare:setViewTouched(true)
	self.pLayShare:onMViewClicked(handler(self, self.onShareClicked))

	-- self.pLayIcon      = self:findViewByName("lay_icon")

	--翻页层
	self.pLayPageView  = self:findViewByName("lay_pageview")
	self.pPageView     = MUI.MPageView.new{viewRect = cc.rect(0, 0, self.pLayPageView:getWidth(), self.pLayPageView:getHeight())}
	self.pPageView:setCirculatory(true)
	self.pLayPageView:addView(self.pPageView, 10)
	self.pPageView:loadDataAsync(self.nWeaponTotalCnt, self.nRealIdx, function(_pView, _index)
		-- body
		local item = self.pPageView:newItem()

		-- centerInView(item, pWeapon)
		local nIdx = _index + self.nIndex - 1
		if nIdx > self.nWeaponTotalCnt then
			nIdx = nIdx - self.nWeaponTotalCnt
		end
		local pImg = self.tBaseData[nIdx].sIcon
		local pWeapon = MUI.MImage.new(pImg, {scale9 = false})
		item:addView(pWeapon)
		pWeapon:setVisible(false)
		pWeapon:setPosition(item:getWidth()/2, item:getHeight()/2 + 20)
		-- pWeapon:setCurrentImage(pImg)
		self.tImgWeapon[nIdx] = pWeapon
		self:showWeaponAction(pWeapon, pImg, nIdx)
		return item
	end, function(_pView)
		-- body
	end )
	self.pPageView:onTouch(function(event)
		-- body
		if event.name == "pageChange" then
			self.bChanging = false
			local dev = self.nIndex - 1
			local nCurIdx = event.pageIdx
			local nRealIdx = nCurIdx + dev
			if nRealIdx > self.nWeaponTotalCnt then
				nRealIdx = nRealIdx - self.nWeaponTotalCnt
			end
			self.nRealIdx = nRealIdx
			self.nWeaponId = self.tBaseData[self.nRealIdx].nId
			self:updateViews()

			local nLAndRIdx = nCurIdx + dev
			if nLAndRIdx > self.nWeaponTotalCnt then
				nLAndRIdx = nLAndRIdx - self.nWeaponTotalCnt
			end
			-- 刷新当前nLAndRIdx页面的数据,传页数nLAndRIdx
		end
	end)

	--顶部列表
	self.pListView = MUI.MListView.new{
	bgColor = cc.c4b(255, 255, 255, 250),
        viewRect = cc.rect(0, 0, 600, 110),
        direction = MUI.MScrollView.DIRECTION_HORIZONTAL,
        itemMargin = {left =  9,
        right =  10,
        top =  -10,
        bottom =  0},
	}
	self.pLayTopList:addView(self.pListView)
	self.pListView:setBounceable(false)
    self.pListView:setItemCount(self.nWeaponTotalCnt)      
	self.pListView:setItemCallback(function ( _index, _pView )
	    local pTempView = _pView
	    local dev = self.nIndex - 1
	    local nGoPage = _index - dev
	    if nGoPage <= 0 then
	    	nGoPage = nGoPage + self.nWeaponTotalCnt
	    end
		if pTempView == nil then
	    	pTempView = WeaponIcon.new(_index, nGoPage, self.pPageView)
	    	-- pTempView:setAnchorPoint(0.5, 0.5)
	    	-- pTempView:ignoreAnchorPointForPosition(false)
	    	table.insert(self.tWeaponIcons, pTempView)
	    end
	    pTempView:onMViewClicked(function()
	    	self.pPageView:gotoPage(nGoPage, true)
		end)
	    return pTempView
	end)
	self.pListView:reload()

	--左右按钮
	self.pBtnLeft      = self:findViewByName("btn_left")
	self.pBtnLeft:onMViewClicked(handler(self, self.onTurnLeftClick))
	self.pBtnRight     = self:findViewByName("btn_right")
	self.pBtnRight:onMViewClicked(handler(self, self.onTurnRightClick))
	--属性层
	self.pLayAttr      = self:findViewByName("lay_attr")
	-- self.pImgArrow     = self:findViewByName("img_arrow")
	self.pLayBottom    = self:findViewByName("lay_bottom")
	--神兵等级已满
	self.pLbMaxLv      = self:findViewByName("lb_maxlv")
	self.pLbMaxLv:setVisible(false)

	-- self:showHotWaveEffect()

	self:createEffectLayer()

	--自动升级次数显示层
	self.pLayAutoUpgrade = self:findViewByName("lay_auto_upgrade")
	self.pLayAutoUpgrade:setVisible(false)
	--自动升级次数文本
	self.pLbAutoUpgrade = self:findViewByName("lb_auto_upgrade")

end

function DlgWeaponInfo:showAutoUpgradeLay(sMsgName, pMsgObj)
	if pMsgObj.bShow then
		local tStr = {
			{text=getConvertedStr(7, 10261), color=getC3B(_cc.pwhite)},
			{text=pMsgObj.nUpgradeTimes, color=getC3B(_cc.blue)},
			{text=getConvertedStr(7, 10120), color=getC3B(_cc.pwhite)},
		}
		self.pLbAutoUpgrade:setString(tStr)
		self.pLayAutoUpgrade:setVisible(true)
	else
		self.pLayAutoUpgrade:setVisible(false)
	end
end

--创建两个播放特效的层
function DlgWeaponInfo:createEffectLayer()
	-- body
    if not self.pLayerEff then
    	self.pLayerEff = MUI.MLayer.new()
    	self.pLayerEff:setLayoutSize(self.pLayPageView.width, self.pLayPageView.height)
    	self.pLayPageView:addView(self.pLayerEff, 9)
    end
	if not self.pLayerEffOver then
    	self.pLayerEffOver = MUI.MLayer.new()
    	self.pLayerEffOver:setLayoutSize(self.pLayPageView.width, self.pLayPageView.height)
    	self.pLayPageView:addView(self.pLayerEffOver, 99)
    end
end

--其他光圈热气和粒子效果
function DlgWeaponInfo:showHotWaveEffect()
	-- body
	G__PoolViews["shenbingtexiao"] = G__PoolViews["shenbingtexiao"] or {ri=0, si=0}

    local pos = cc.p(290, 120)
    local function run()
    	local pImg = popViewFromPool("shenbingtexiao")
    	if not pImg then
            pImg = MUI.MImage.new("#sg_sbfz_jjcg_z1_004.png")
        end
        local nIdx = math.random(1, 4)
        if nIdx == 1 then
        	pImg:setRotation(0)
            pImg:setFlippedY(false)
            pImg:setFlippedX(true)
        elseif nIdx == 2 then
        	pImg:setRotation(0)
            pImg:setFlippedX(false)
            pImg:setFlippedY(true)
        elseif nIdx == 3 then
            pImg:setFlippedX(false)
            pImg:setFlippedY(false)
            pImg:setRotation(180)
        elseif nIdx == 4 then
        end
        
        self.pLayerEffOver:addView(pImg)
        
    	local tarPosX, tarPosY = pos.x + math.random(-80, 80), pos.y + math.random(-40, 40)
    	pImg:setPosition(tarPosX, tarPosY)
        local pAction = cc.Sequence:create({
            cc.Spawn:create({
                cc.MoveTo:create(0.41, cc.p(tarPosX, tarPosY + 110)),
                cc.FadeTo:create(0.41, 255),
            }),
            cc.Spawn:create({
                cc.MoveTo:create(0.59, cc.p(tarPosX, tarPosY + 270)),
                cc.FadeOut:create(0.59),
            }),
            cc.CallFunc:create(function()
                pushViewToPool(pImg, "shenbingtexiao")
                -- dump(G__PoolViews["shenbingtexiao"])
            end)
    	})
		pImg:runAction(pAction)

    	local fDelay = math.random(10, 30)/100
		self:runAction(cc.Sequence:create({
			cc.DelayTime:create(fDelay),
        	cc.CallFunc:create(run)
		}))
		-- self:performWithDelay(function ()
		-- run()
		-- end, fDelay)
    end
    run()


    --法阵上的光波, 每隔两秒出现一次
    -- 时间       缩放值  
    -- 0秒         80%    
    -- 0.25秒      100%    
    -- 0.9秒       126% 
    pos = cc.p(290, 100)
    if not self.pImgLightWave then
	    self.pImgLightWave = MUI.MImage.new("#sg_sbfz_jjcg_z1_007.png")
	    if self.pImgLightWave then
	        self.pLayerEff:addView(self.pImgLightWave)
	        self.pImgLightWave:setPosition(pos)
	        self.pImgLightWave:setScale(0.8)
	        self.pImgLightWave:setOpacity(0)
	        self.pImgLightWave:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	        local pSequence = cc.Sequence:create({
	                cc.Spawn:create({
	                    cc.ScaleTo:create(0.25, 1),
	                    cc.FadeTo:create(0.25, 255),
	                    }),
	                cc.Spawn:create({
	                    cc.ScaleTo:create(0.65, 1.36),
	                    cc.FadeTo:create(0.65, 0),
	                    }),
	                cc.DelayTime:create(2 - 0.9),
	                cc.ScaleTo:create(0, 0.8),
	            })
	        self.pImgLightWave:runAction(cc.RepeatForever:create(pSequence))
	    end
	end

    --法阵上的光(分四层)
    --第一层
    if not self.pImgLight1 then
	    self.pImgLight1 = MUI.MImage.new("#sg_sbfz_jjcg_z1_005.png")
	    if self.pImgLight1 then
	        self.pLayerEff:addView(self.pImgLight1)
	        self.pImgLight1:setPosition(pos.x - 1, pos.y + 144)
	        self.pImgLight1:setScale(1.5)
	        self.pImgLight1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	    end
	end
    --第二层
    if not self.pImgLight2 then
	    self.pImgLight2 = MUI.MImage.new("#sg_sbfz_jjcg_z1_011.png")
	    if self.pImgLight2 then
	        self.pLayerEff:addView(self.pImgLight2)
	        self.pImgLight2:setPosition(pos.x + 4, pos.y + 110)
	        self.pImgLight2:setScale(2)
	        self.pImgLight2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	    end
	end
    --第三层
    if not self.pImgLight3 then
	    self.pImgLight3 = MUI.MImage.new("#sg_sbfz_jjcg_z1_003.png")
	    if self.pImgLight3 then
	        self.pLayerEff:addView(self.pImgLight3)
	        self.pImgLight3:setPosition(pos)
	        self.pImgLight3:setScale(2)
	        self.pImgLight3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	    end
	end
    --第四层
    if not self.pImgLight4 then
	    self.pImgLight4 = MUI.MImage.new("#sg_sbfz_jjcg_z1_003.png")
	    if self.pImgLight4 then
	        self.pLayerEff:addView(self.pImgLight4)
	        self.pImgLight4:setPosition(pos)
	        self.pImgLight4:setOpacity(0)
	        self.pImgLight4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	        local pSequence = cc.Sequence:create({
	                cc.FadeTo:create(0.25, 255*0.48),
	                cc.FadeTo:create(0.6, 0),
	                cc.DelayTime:create(2 - 0.85),
	            })
	        self.pImgLight4:runAction(cc.RepeatForever:create(pSequence))
	    end
	end

    --粒子效果
    if not self.pLiziEff then
		self.pLiziEff = createParitcle("tx/other/lizi_shengb_shengji_002.plist")
		self.pLiziEff:setPosition(pos.x, pos.y + 141)
		self.pLayerEffOver:addView(self.pLiziEff)
	end
end

--法阵特效
function DlgWeaponInfo:fazhenAction(_bCanPlay)
    -- body
    --法阵
    --内层法阵
    local pos = cc.p(290, 100)
    if not self.pImgFaZhenSmall then
	    self.pImgFaZhenSmall = MUI.MImage.new("#sg_sbfz_jjcg_z1_006.png")

	    self.pImgFaZhenSmall:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	    local pLayer1 = MUI.MLayer.new()
	    pLayer1:setLayoutSize(cc.size(self.pImgFaZhenSmall:getWidth(), self.pImgFaZhenSmall:getHeight()))
	    self.pLayPageView:addView(pLayer1, 9)
	    pLayer1:setPosition(pos)
	    pLayer1:addView(self.pImgFaZhenSmall, 10)

	    pLayer1:setScaleX(1.5)
	    pLayer1:setScaleY(0.63)
	    self.pImgFaZhenSmall:setOpacity(255)
	end
    
    --外层法阵
    if not self.pImageFaZhenBig then
	    self.pImageFaZhenBig = MUI.MImage.new("#sg_sbfz_jjcg_z1_006.png")
	    self.pImageFaZhenBig:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	    local pLayer2 = MUI.MLayer.new()
	    pLayer2:setLayoutSize(cc.size(self.pImageFaZhenBig:getWidth(), self.pImageFaZhenBig:getHeight()))
	    self.pLayPageView:addView(pLayer2, 9)
	    pLayer2:setPosition(pos)
	    pLayer2:addView(self.pImageFaZhenBig, 10)

	    pLayer2:setScaleX(1.85)
	    pLayer2:setScaleY(0.78)
	    self.pImageFaZhenBig:setOpacity(255*0.08)
	end

    self.pImgFaZhenSmall:setToGray(false)
    self.pImageFaZhenBig:setToGray(false)
    self.pImgFaZhenSmall:runAction(cc.RepeatForever:create(
        cc.RotateBy:create(8, 360)))
    self.pImageFaZhenBig:runAction(cc.RepeatForever:create(
        cc.RotateBy:create(8, -360)))

    if not _bCanPlay then
    	self:stopFazhenAction()
    	self.pLayerEff:setVisible(false)
    	self.pLayerEffOver:setVisible(false)
    else
    	self.pLayerEff:setVisible(true)
    	self.pLayerEffOver:setVisible(true)
    end
    
end

--神兵自身运动
function DlgWeaponInfo:runWeaponAct(_weapon)
	-- body
	local pSequence = cc.Sequence:create({
	    cc.MoveTo:create(1, cc.p(self.posX, self.posY + 8)),
	    cc.MoveTo:create(1, cc.p(self.posX, self.posY)),
	})
	_weapon:runAction(cc.RepeatForever:create(pSequence))
end

--神兵图标动画(3层)
function DlgWeaponInfo:showWeaponAction(_weapon, _img, _nIdx)
	-- body
	if not self.posX then
		self.posX = _weapon:getPositionX()
	end
	if not self.posY then
		self.posY = _weapon:getPositionY()
	end
	--第一层 不加亮
	self:runWeaponAct(_weapon)

    --第二层 加亮
	local pImgSec = MUI.MImage.new(_img)
	pImgSec:setOpacity(0)
	pImgSec:setPosition(self.posX, self.posY)
	local pSequence = cc.Sequence:create({
	    cc.Spawn:create({
	        cc.MoveTo:create(1, cc.p(self.posX, self.posY + 8)),
	        cc.FadeTo:create(1, 255*0.3),
	    }),
	    cc.Spawn:create({
	        cc.MoveTo:create(1, cc.p(self.posX, self.posY)),
	        cc.FadeTo:create(1, 0),
	    }),
	})
	_weapon:getParent():addView(pImgSec, 10)
	pImgSec:setPosition(cc.p(self.posX, self.posY))
	pImgSec:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgSec:runAction(cc.RepeatForever:create(pSequence))

	self.pWeaponSecImgs[_nIdx] = pImgSec

    --第三层 加亮
	local pImgThird = MUI.MImage.new(_img)
	pImgThird:setOpacity(0)
	local pSequence = cc.Sequence:create({
	    cc.Spawn:create({
	        cc.ScaleTo:create(0.3, 1.05),
	        cc.FadeTo:create(0.3, 255*0.3),
	    }),
	    cc.Spawn:create({
	        cc.ScaleTo:create(0.4, 1.1),
	        cc.FadeTo:create(0.4, 0),
	    }),
	    cc.ScaleTo:create(0, 1),
	    cc.DelayTime:create(2 - 0.7),
	})
	_weapon:getParent():addView(pImgThird, 10)
	pImgThird:setPosition(cc.p(self.posX, self.posY))
	pImgThird:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgThird:runAction(cc.RepeatForever:create(pSequence))

	self.pWeaponThirdImgs[_nIdx] = pImgThird

end

--停止法阵特效
function DlgWeaponInfo:stopFazhenAction()
	-- body
	if self.pImgFaZhenSmall then
		self.pImgFaZhenSmall:setToGray(true)
		self.pImgFaZhenSmall:stopAllActions()
		self.pImgFaZhenSmall:setRotation(0)
	end
	if self.pImageFaZhenBig then
    	self.pImageFaZhenBig:removeSelf()
    	self.pImageFaZhenBig = nil
    end
end

--左边翻页按钮点击事件
function DlgWeaponInfo:onTurnLeftClick(pview)
	if self.bChanging then
		return
	end
	local nCurPageIdx = self.pPageView:getCurPageIdx()
	nCurPageIdx = nCurPageIdx - 1
	if nCurPageIdx == 0 then
		nCurPageIdx = self.nWeaponTotalCnt
	end
	self.bChanging = true
	self.pPageView:gotoPage(nCurPageIdx, true)
end

--右边翻页按钮点击事件
function DlgWeaponInfo:onTurnRightClick(pview)
	if self.bChanging then
		return
	end
	local nCurPageIdx = self.pPageView:getCurPageIdx()
	nCurPageIdx = nCurPageIdx + 1
	if nCurPageIdx > self.nWeaponTotalCnt then
		nCurPageIdx = nCurPageIdx - self.nWeaponTotalCnt
	end
	self.bChanging = true
	self.pPageView:gotoPage(nCurPageIdx, true)
end

-- 创建属性组合文本
function DlgWeaponInfo:createTableLabel(_content1, _content2, _color1, _color2, anchor)
	-- body
	-- local tConTableNameL = {}
	-- tConTableNameL.tLabel = {
	-- 	{_content1.."  ", getC3B(_color1)},
	-- 	{_content2.."  ", getC3B(_color2)},
	-- }
	-- local pText =  createGroupText(tConTableNameL)
	-- pText:setAnchorPoint(anchor)
	-- self.pLayAttr:addView(pText,10)

	local pText = MUI.MLabel.new({text = "", size = 20})
	pText:setAnchorPoint(anchor)
	self.pLayAttr:addView(pText,10)
	local tStr = {
		{text = _content1..getSpaceStr(2), color = getC3B(_color1)},
		{text = _content2..getSpaceStr(2), color = getC3B(_color2)},
	}
	pText:setString(tStr)
	return pText
end

--只显示当前神兵属性
function DlgWeaponInfo:showOnlyCurAttr(_name, _lv, _attrName, _attackNum)
	self.pLayAttr:removeAllChildren()
	local pTextName = self:createTableLabel(_name, getLvString(_lv,false), _cc.white, _cc.blue, cc.p(0.5,0.5))
	pTextName:setPosition(290, 65)
	local pTextAttack = self:createTableLabel(getConvertedStr(7, 10040).._attrName, "+".._attackNum, _cc.white, _cc.blue, cc.p(0.5,0.5))
	pTextAttack:setPosition(290, 30)
end

--属性指向箭头
function DlgWeaponInfo:createAttrArrow()
	-- body
	local pImgArrow = MUI.MImage.new("#v1_img_lanjiantou.png", {scale9 = false})
	self.pLayAttr:addView(pImgArrow)
	centerInView(self.pLayAttr, pImgArrow)
	pImgArrow:setPosition(290, 45)
end



function DlgWeaponInfo:updateViews()
	--神兵基础信息
	local tWeaponinfo = self.tWeaponSerData:getWeaponInfoById(self.nWeaponId)
	--神兵名字
	local sName = tWeaponinfo.sName
	--神兵ID
	local nId = tWeaponinfo.nWeaponId
	--神兵等级
	local nLv = tWeaponinfo.nWeaponLv
	--神兵阶位
	local nAdLv = tWeaponinfo.nAdvanceLv

	self.pLayJie:setVisible(nAdLv and nAdLv > 0)
	--神兵名字文本
	if not self.pTxtName then
		self.pTxtName = MUI.MLabel.new({
			text = getConvertedStr(3, 10238),
			size = 30,
			align = cc.ui.TEXT_ALIGN_CENTER,
			valign = cc.ui.TEXT_VALIGN_TOP,
			dimensions = cc.size(30, 0),
			})
		self.pTxtName:setPosition(self.pLbName:getPosition())
		self.pLayCenter:addView(self.pTxtName, 10)
	end

	self.pTxtName:setString(sName)


	local tFragmentsList = self.tWeaponSerData:getFragmentsList()
	local tFragment = tFragmentsList[self.nWeaponId] 
	--属性名字和属性值
	local sAttrName, nAttack = self.tWeaponSerData:getWeaponAttribute(self.nWeaponId, 1, 0)
	--人物当前等级
	local roleLevel = Player:getPlayerInfo().nLv

	local tWeapList = self.tWeaponSerData:getAllWeaponDatas()
	for i, view in ipairs(self.tWeaponIcons) do
		view:updateViews(roleLevel, tWeapList[i+200])
		if i == self.nRealIdx then
			self.tWeaponIcons[i]:setIconScale(0.9)
		else
			self.tWeaponIcons[i]:setIconScale(0.8)
		end
	end

	--是否已获得神兵
	local bHasWeapon = nId ~= nil

	self.pLayShare:setVisible(false)
	if not bHasWeapon then
		--未解锁默认显示1级神兵属性
		self:showOnlyCurAttr(sName, 1, sAttrName, nAttack)
	end

	if self.tImgWeapon[self.nRealIdx] then
		--是否可以播放法阵特效
		self:fazhenAction(bHasWeapon)
		local pWeapon = self.tImgWeapon[self.nRealIdx]
		pWeapon:setToGray(not bHasWeapon)
		pWeapon:setVisible(true)
		local pDirector = cc.Director:getInstance()
		if not bHasWeapon then
            pDirector:getActionManager():pauseTarget(pWeapon)
			pWeapon:setPosition(cc.p(self.posX, self.posY))
		else
       		pDirector:getActionManager():resumeTarget(pWeapon)
		end
		if self.pWeaponSecImgs[self.nRealIdx] then
			self.pWeaponSecImgs[self.nRealIdx]:setVisible(bHasWeapon)
		end
		if self.pWeaponThirdImgs[self.nRealIdx] then
			self.pWeaponThirdImgs[self.nRealIdx]:setVisible(bHasWeapon)
		end
	end

	--1、未解锁
	if roleLevel < tWeaponinfo.nMakeLv then
		self.pTempBottomView = nil
		local pWeapon = self.tImgWeapon[self.nRealIdx]
		if pWeapon then
			pWeapon:setToGray(true)
			pWeapon:stopAllActions()
		end
		--是否可以播放法阵特效
		self:fazhenAction(false)
		if self.pWeaponSecImgs[self.nRealIdx] then
			self.pWeaponSecImgs[self.nRealIdx]:setVisible(false)
		end
		if self.pWeaponThirdImgs[self.nRealIdx] then
			self.pWeaponThirdImgs[self.nRealIdx]:setVisible(false)
		end
		if tFragment and tFragment.nFragments > 0 then
			local nNeedFragment = tWeaponinfo.nNeedFra
			local nCurFragment = tFragment.nFragments
			local pTempBottomView = self:createFragmentsView(self.nWeaponId)
			pTempBottomView:showTxtRequire(string.format(getConvertedStr(7, 10038), tWeaponinfo.nMakeLv))
			pTempBottomView:onWeaponBuildMaterials(nCurFragment, nNeedFragment)
		else
			self.pLayBottom:removeAllChildren()
			self.pLbMaxLv:setVisible(true)
			self.pLbMaxLv:setString(string.format(getConvertedStr(7, 10038), tWeaponinfo.nMakeLv))
			setTextCCColor(self.pLbMaxLv, _cc.red)
		end
		
		return
	end

	--2、未打造
	if not bHasWeapon then
		self.pTempBottomView = nil
		local nCurFragment = 0
		if tFragment then
			nCurFragment = tFragment.nFragments
		end
		local pTempBottomView = self:createFragmentsView(self.nWeaponId)
		pTempBottomView:onWeaponBuildMaterials(nCurFragment, tWeaponinfo.nNeedFra)
		--不可打造
		if nCurFragment < tWeaponinfo.nNeedFra then
			pTempBottomView:buyFragmentsBtnLay(nCurFragment, self.nWeaponId)
		else  -- 可打造
			local fTime = getWeaponInitData().makeTime
			pTempBottomView:showCreateWeaponTime(fTime)
			pTempBottomView:createWeaponBtn(self.nWeaponId)
		end
		return
	end

	if not self.isHasPlayAction[nId] then
		self:showHotWaveEffect()
		self.isHasPlayAction[nId] = true
	end

	--3、神兵正在打造
	--获得神兵打造的剩余时间
	local nLeftTime = self.tWeaponSerData:getBuildCDLeftTime(nId)
	if nLeftTime > 0 then
		self.pTempBottomView = nil
		local pTempBottomView = self:createUpgradeView()
		pTempBottomView:createWeaponBar(nId)

		return
	end

	self.pLayShare:setVisible(true)

	
	--神兵等级信息
	local tLvData = getWeaponLvData(nId, nLv)
	self.tLvData = tLvData
	--神兵进阶信息
	local tAdData = getWeaponAdData(nId, nAdLv)
	local tNextAdData = getWeaponAdData(nId, nAdLv + 1)
	--当前属性名称和属性值
	local sAttrName, nAttack = self.tWeaponSerData:getWeaponAttribute(nId, nLv, nAdLv)
	--下个等级属性名称和属性值
	local sNAttrName, nNAttack = self.tWeaponSerData:getWeaponAttribute(nId, nLv + 1, nAdLv)


	-- 4、已获得神兵信息

	if nAdLv > 0 then
		self.pLbJie:setString(nAdLv)
	end

	-- 6、神兵等级已满
	if self.tWeaponSerData:isWeaponFullLv(nId) then
		self:showOnlyCurAttr(sName, nLv, sAttrName, nAttack)
		self:setToTopLvText(getConvertedStr(7, 10021))
		return
	end

	--神兵等级达到人物等级
	if nLv >= roleLevel then
		self:showOnlyCurAttr(sName, nLv, sAttrName, nAttack)
		self:setToTopLvText(getConvertedStr(7, 10061))
		return 
	end


	--当前等级上限
	local nTopLv = tAdData.toplv
	-- 5、当前可进阶
	if self.tWeaponSerData:isWeaponCanAdvance(nId) then
		self.pTempBottomView = nil
		self.pLayAttr:removeAllChildren()
		self:createAttrArrow()
	    sNAttrName, nNAttack = self.tWeaponSerData:getWeaponAttribute(nId, nLv, nAdLv + 1)
	    if not sNAttrName or not nNAttack then return end
		local pTextNameL = self:createTableLabel(sName, getLvString(nLv,false), _cc.white, _cc.blue, cc.p(0,0.5))
		pTextNameL:setPosition(80, 75)
		local pTextAttackL = self:createTableLabel(getConvertedStr(7, 10040)..sAttrName, "+"..nAttack, _cc.white, _cc.blue, cc.p(0,0.5))
		pTextAttackL:setPosition(80, 45)
		local pTextLevelL = self:createTableLabel(getConvertedStr(7, 10057), nTopLv, _cc.white, _cc.blue, cc.p(0,0.5))
		pTextLevelL:setPosition(80, 15)
		local pTextNameR = self:createTableLabel(sName, getLvString(nLv,false), _cc.white, _cc.green, cc.p(0,0.5))
		pTextNameR:setPosition(360, 75)
		local pTextAttackR = self:createTableLabel(getConvertedStr(7, 10040)..sNAttrName, "+"..nNAttack, _cc.white, _cc.green, cc.p(0,0.5))
		pTextAttackR:setPosition(360, 45)
		local pTextLevelR = self:createTableLabel(getConvertedStr(7, 10057), tNextAdData.toplv, _cc.white, _cc.green, cc.p(0,0.5))
		pTextLevelR:setPosition(360, 15)

		local pTempBottomView = self:createUpgradeView()

		pTempBottomView:createAdvanceBtn(nId, tAdData.tCosts, getWeaponInitData().advaTime, tWeaponinfo.nAdvanceCnt, tAdData.section)

		--神兵正在进阶
		--获得神兵进阶的剩余时间
		local nLeftTime = self.tWeaponSerData:getAdvCDLeftTime(nId)
		if nLeftTime > 0 then
			self.pTempBottomView = nil
			local pTempBottomView = self:createUpgradeView()
			pTempBottomView:showAdvanceCount(nId)
		end

		return
	end

	
	--当前暴击倍数
	self.nCritical = tWeaponinfo.nPreCritical

	if not self.pTempBottomView then
		self.pTempBottomView = self:createUpgradeView()
	end
	local nNeedNum, nHasNum, sIcon, tGoods, nResId
	if tLvData then
		for nId, need in pairs(tLvData.tCosts) do
			nNeedNum = need
			tGoods = getGoodsByTidFromDB(nId)
			if tGoods then
				nHasNum = getMyGoodsCnt(nId)
			end
			sIcon = getItemResourceData(nId).sIcon
			nResId = tonumber(nId)
		end
		self.pTempBottomView:createUpgradeBar(tWeaponinfo, sIcon, nNeedNum, nHasNum, tGoods, nResId)
		
		--神兵暴击活动数据影响变化
		local nActivtCrit = nil
		local tData = Player:getActById(e_id_activity.magiccrit)
		if tData then
			nActivtCrit = tData:getCrit(self.nWeaponId)
		end
		if self.nCritical and nActivtCrit then
			if self.nCritical <= 1 then
				self.nCritical = math.max(self.nCritical, nActivtCrit)
			end
		end
		self.pTempBottomView:createUpgradeBtn(nId, self.nCritical, tLvData.rise)
	end

	--如果出现额外暴击
	-- if tWeaponinfo.nExtraCD and self.tWeaponSerData:getExtraCriticalLeftTime(nId) <= 0 then
		self:showExtraCritical()
	-- end
	

	self.pLayAttr:removeAllChildren()
	self:createAttrArrow()
	local pTextNameL = self:createTableLabel(sName, getLvString(nLv,false), _cc.white, _cc.blue, cc.p(0,0.5))
	pTextNameL:setPosition(80, 65)
	if sAttrName and nAttack then
		local pTextAttackL = self:createTableLabel(getConvertedStr(7, 10040)..sAttrName, "+"..nAttack, _cc.white, _cc.blue, cc.p(0,0.5))
		pTextAttackL:setPosition(80, 30)
	end
	local pTextNameR = self:createTableLabel(sName, getLvString(nLv+1,false), _cc.white, _cc.green, cc.p(0,0.5))
	pTextNameR:setPosition(360, 65)
	if sNAttrName and nNAttack then
		local pTextAttackR = self:createTableLabel(getConvertedStr(7, 10040)..sNAttrName, "+"..nNAttack, _cc.white, _cc.green, cc.p(0,0.5))
		pTextAttackR:setPosition(360, 30)
	end

end

--创建材料层
function DlgWeaponInfo:createFragmentsView(_nId)
	self.pLbMaxLv:setVisible(false)
	self.pLayBottom:removeAllChildren()
	local pTempBottomView = WeaponFragments.new(_nId)
	self.pLayBottom:addView(pTempBottomView)
	return pTempBottomView
end

--神兵升级层
function DlgWeaponInfo:createUpgradeView()
	-- body
	self.pLbMaxLv:setVisible(false)
	self.pLayBottom:removeAllChildren()
	local pTempBottomView = WeaponUpgrade.new()
	self.pLayBottom:addView(pTempBottomView, 99, 99)
	return pTempBottomView
end

--神兵等级达到上限
function DlgWeaponInfo:setToTopLvText(_text)
	-- body
	self.pTempBottomView = nil
	self.pLayBottom:removeAllChildren()
	self.pLbMaxLv:setVisible(true)
	self.pLbMaxLv:setString(_text)
	setTextCCColor(self.pLbMaxLv, _cc.red)
end

--点击分享按钮
function DlgWeaponInfo:onShareClicked(_pView)
	-- body
	self.pTempBottomView:stopAutoUpgrade()
	
	local pWeapon = self.tBaseData[self.nRealIdx]
	openShare(_pView, e_share_id.weapon, {"c^g_"..pWeapon.nWeaponId, pWeapon.nWeaponLv}, self.nWeaponId)

end

--出现额外暴击
function DlgWeaponInfo:showExtraCritical()
	-- body
	if self.pTempBottomView then
		local tWeaponInfo = self.tWeaponSerData:getWeaponInfoById(self.nWeaponId)
		if tWeaponInfo.nExtraCD and self.tWeaponSerData:getExtraCriticalLeftTime(self.nWeaponId) <= 0 then
			local nExtraBj = tWeaponInfo.nExtraBj
			if not nExtraBj or not self.tLvData then return end
			self.pTempBottomView:showBaoji(nExtraBj, nExtraBj*self.tLvData.rise)
		end
	end
end

--播放升级特效
function DlgWeaponInfo:playUpgradeEff()
	-- body
	self:showGreatAction("#v1_fonts_shengjichenggong.png")
end

--播放暴击特效
function DlgWeaponInfo:playBaojiEff()
	-- body
	--如果同时升级则不播放
	if self.tWeaponSerData:isHasLevelUp() then
		return
	end
	self:showGreatAction(_img, true)
end

--播放进阶特效
function DlgWeaponInfo:playAdvanEff()
	-- body
	self:showGreatAction("#v1_fonts_jinjiechenggong.png")
end

--暴击字体图片
function DlgWeaponInfo:createImgLay(bBlend)
	-- body
	--获取暴击倍数
	local nCritical = self.nCritical
	if not nCritical then
		return
	end
	local pLay = MUI.MLayer.new()
	local pLbBaoji = MUI.MLabelAtlas.new({text = nCritical, 
	    png = "ui/atlas/v1_img_shuzitongyong.png", pngw=32, pngh=52, scm=48})
	pLay:addView(pLbBaoji)
	pLbBaoji:setPosition(0, 26)
	pLbBaoji:setAnchorPoint(cc.p(0, 0.5))
	local pImg = MUI.MImage.new("#v1_fonts_beibaoji.png")
	if bBlend then
		pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	end
	pLay:addView(pImg)
	pImg:setAnchorPoint(cc.p(0, 0.5))
	if nCritical >= 10 then
		pImg:setPosition(60, 26)
	else
		pImg:setPosition(35, 26)
	end
	pLay:setLayoutSize(pLbBaoji:getContentSize().width + pImg:getContentSize().width, pImg:getContentSize().height)
	return pLay
end

--创建字体层
function DlgWeaponInfo:createFontLay(_img, baoji, bBlend)
	-- body
    local fontLay
    if _img then
    	fontLay = MUI.MImage.new(_img)
    	if bBlend then
			fontLay:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		end
	end
   	if baoji then
    	fontLay = self:createImgLay(bBlend)
    elseif _img then
    	fontLay = MUI.MImage.new(_img)
    	if bBlend then
			fontLay:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		end
    end
    if fontLay then
		fontLay:setAnchorPoint(cc.p(0.5, 0.5))
    end
    return fontLay
end

--升级暴击进阶各种特效
function DlgWeaponInfo:showGreatAction(_img, baoji)
	--字体动画
    local pFontPos = cc.p(self.posX, self.posY + 20) --大概神兵的中间
    --第一层
    local pFontLay1 = self:createFontLay(_img, baoji)
    if not pFontLay1 then return end

    self.pLayerEffOver:addView(pFontLay1, 1000)
    pFontLay1:setPosition(pFontPos)
    pFontLay1:setScale(0.25)
    local pSequence = cc.Sequence:create({
        cc.ScaleTo:create(0.13, 1.1),
        cc.ScaleTo:create(0.08, 0.98),
        cc.ScaleTo:create(0.09, 1),
        cc.ScaleTo:create(0.8, 1),
        cc.Spawn:create({
            cc.ScaleTo:create(0.54, 1),
            cc.MoveTo:create(0.54, cc.p(pFontPos.x, pFontPos.y + 43)),
            cc.FadeOut:create(0.54),
            }),
        cc.CallFunc:create(function()
            pFontLay1:removeSelf()
        end)
        })
    pFontLay1:runAction(pSequence)

    --第二层, 加亮
    local bBlend = true
    local pFontLay2 = self:createFontLay(_img, baoji, bBlend)
    if not pFontLay2 then return end
    
    self.pLayerEffOver:addView(pFontLay2, 1000)
    pFontLay2:setPosition(pFontPos)
    pFontLay2:setScale(0.25)
    local pSequence = cc.Sequence:create({
        cc.ScaleTo:create(0.13, 1.1),
        cc.ScaleTo:create(0.08, 0.98),
        
        cc.Spawn:create({
            cc.ScaleTo:create(0.09, 1),
            cc.FadeTo:create(0.09, 255*0.75),
            }),
        cc.Spawn:create({
            cc.ScaleTo:create(0.25, 1),
            cc.FadeOut:create(0.25),
            }),
        cc.CallFunc:create(function()
            pFontLay2:removeSelf()
        end)
        })
    pFontLay2:runAction(pSequence)

    --第三层, 加亮
    local bBlend = true
    local pFontLay3 = self:createFontLay(_img, baoji, bBlend)
    if not pFontLay3 then return end

    self.pLayerEffOver:addView(pFontLay3, 1000)
    pFontLay3:setPosition(pFontPos)
    local pSequence = cc.Sequence:create({
        cc.Spawn:create({
            cc.ScaleTo:create(0.13, 1.25),
            cc.FadeTo:create(0.13, 255),
            }),
        cc.Spawn:create({
            cc.ScaleTo:create(0.72, 1.37),
            cc.FadeOut:create(0.72),
            }),
        cc.CallFunc:create(function()
            pFontLay3:removeSelf()
        end)
        })
    pFontLay3:runAction(pSequence)

	--升级周边光圈特效
    self:playUpgradeLight()

    --粒子效果
    local pLiziEff = createParitcle("tx/other/lizi_shengb_shengji_001.plist")
    pLiziEff:setPosition(pFontPos.x, pFontPos.y + 50)
    self.pLayerEffOver:addView(pLiziEff, 999)
end

--升级周边光圈特效
function DlgWeaponInfo:playUpgradeLight()
    -- body
    local pos = cc.p(290, 100)
    --第一层
    local pImg1 = MUI.MImage.new("#sg_sbfz_jjcg_z1_007.png")
    if pImg1 then
        self.pLayerEffOver:addView(pImg1)
        pImg1:setPosition(pos)
        pImg1:setOpacity(0)
        pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
        local pSequence = cc.Sequence:create({
            cc.FadeTo:create(0.5, 255),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function()
	            pImg1:removeSelf()
	        end)
            })
        pImg1:runAction(pSequence)
    end
    --第二层
    local pImg2 = MUI.MImage.new("#sg_sbfz_jjcg_z1_007.png")
    if pImg2 then
        self.pLayerEffOver:addView(pImg2)
        pImg2:setPosition(pos.x, pos.y + 120)
        pImg2:setOpacity(0)
        pImg2:setScale(0.81)
        pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
        local pSequence = cc.Sequence:create({
            cc.Spawn:create({
                cc.FadeTo:create(0.25, 255*0.77),
                cc.ScaleTo:create(0.25, 0.87),
                }),
            cc.Spawn:create({
                cc.FadeTo:create(0.65, 0),
                cc.ScaleTo:create(0.65, 1),
                }),
            cc.CallFunc:create(function()
	            pImg2:removeSelf()
	        end)
            })
        pImg2:runAction(pSequence)
    end
    --第三层
    local pImg3 = MUI.MImage.new("#sg_sbfz_jjcg_z1_007.png")
    if pImg3 then
        self.pLayerEffOver:addView(pImg3)
        pImg3:setPosition(pos.x, pos.y + 265)
        pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
        pImg3:setScale(0.6)
        pImg3:setOpacity(0)
        local pSequence = cc.Sequence:create({
            cc.Spawn:create({
                cc.FadeTo:create(0.17, 0),
                cc.ScaleTo:create(0.17, 0.6),
                }),
            cc.Spawn:create({
                cc.FadeTo:create(0.25, 255*0.12),
                cc.ScaleTo:create(0.25, 0.65),
                }),
            cc.Spawn:create({
                cc.FadeOut:create(0.65),
                cc.ScaleTo:create(0.65, 0.8),
                }),
            cc.CallFunc:create(function()
	            pImg3:removeSelf()
	        end)
            })
        pImg3:runAction(pSequence)
    end
    --第四层
    local pImg4 = MUI.MImage.new("#sg_sbfz_jjcg_z1_002.png")
    if pImg4 then
        self.pLayerEffOver:addView(pImg4)
        pImg4:setPosition(pos.x, pos.y + 80)
        pImg4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
        local pSequence = cc.Sequence:create({
            cc.Spawn:create({
                cc.FadeTo:create(0, 255),
                cc.ScaleTo:create(0, 4.43,2.01),
                }),
            cc.Spawn:create({
                cc.ScaleTo:create(0.5, 5.05, 2.28),
                cc.FadeOut:create(0.5),
                }),
            cc.CallFunc:create(function()
	            pImg4:removeSelf()
	        end)
            })
        pImg4:runAction(pSequence)
    end
    --第五层
    local pImg5 = MUI.MImage.new("#sg_sbfz_jjcg_z1_001.png")
    if pImg5 then
        self.pLayerEff:addView(pImg5)
        pImg5:setPosition(pos)
        pImg5:setScaleX(2.625)
        pImg5:setScaleY(1.117)
        pImg5:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
        local pSequence = cc.Sequence:create({
            cc.FadeTo:create(0.46, 255),
            cc.FadeOut:create(0.44),
            cc.CallFunc:create(function()
	            pImg5:removeSelf()
	        end)
            })
        pImg5:runAction(cc.RepeatForever:create(pSequence))
    end
    --第六层
    local pImg6 = MUI.MImage.new("#sg_sbfz_jjcg_z1_009.png")
    if pImg6 then
        self.pLayerEffOver:addView(pImg6)
        pImg6:setPosition(pos)
        pImg6:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
        local pSequence = cc.Sequence:create({
            cc.Spawn:create({
                cc.FadeTo:create(0, 200),
                cc.ScaleTo:create(0, 14.93, 5.55),
                }),
            cc.ScaleTo:create(0.08, 28.35, 16.26),
            cc.ScaleTo:create(0.08, 25, 16.26),
            cc.ScaleTo:create(0.09, 26.71, 16.26),
            cc.ScaleTo:create(0.16, 16.45, 16.26),
            
            cc.Spawn:create({
                cc.ScaleTo:create(0.09, 17.21, 16.26),
                cc.FadeTo:create(0.09, 255*0.5),
                }),
            cc.FadeOut:create(0.1),
            cc.CallFunc:create(function()
	            pImg6:removeSelf()
	        end)
            })
        pImg6:runAction(pSequence)
    end
    --第七层
    if(not self.nHandler) then
        --记录当前跑了几次
        self.nTimes = 0
        self.nHandler = MUI.scheduler.scheduleGlobal(
            handler(self, self.onUpdateTime), 0.04)
    end

end

function DlgWeaponInfo:destroyHandler()
    -- 取消定时刷新
    if(self.nHandler ~= nil) then
        MUI.scheduler.unscheduleGlobal(self.nHandler)
        self.nHandler = nil
    end
end

--每0.04秒跑一次
function DlgWeaponInfo:onUpdateTime()
    -- body
    self.nTimes = self.nTimes + 1
    ---跑12次就停止
    if self.nTimes > 12 then
        self:destroyHandler()
        return
    end
    local nBornPosX, nBornPosY = self.posX + math.random(-200, 200), self.posY + math.random(-50, 50)
    local pImg = MUI.MImage.new("#sg_sbfz_jjcg_z1_010.png")
    self.pLayerEff:addView(pImg, 999)
    pImg:setPosition(nBornPosX, nBornPosY)
    pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
    local pSequence = cc.Sequence:create({
        cc.MoveTo:create(0.3, cc.p(nBornPosX, nBornPosY + 500)),
        cc.CallFunc:create(function()
            pImg:removeSelf()
        end)
        })
    pImg:runAction(pSequence)
end

-- 析构方法
function DlgWeaponInfo:onDlgHelpDestroy(  )
	-- body
	self:onPause()
	self:destroyHandler()
end

--注册消息
function DlgWeaponInfo:regMsgs(  )
	-- body
	--刷新神兵信息
	regMsg(self, gud_refresh_weaponInfo, handler(self, self.updateViews))
	--注册神兵升级成功特效消息
	regMsg(self, ghd_weapon_upgrade_effect, handler(self, self.playUpgradeEff))
	--注册神兵暴击成功特效消息
	regMsg(self, ghd_weapon_baoji_effect, handler(self, self.playBaojiEff))
	--注册神兵进阶成功特效消息
	regMsg(self, ghd_weapon_advance_effect, handler(self, self.playAdvanEff))
	--注册神兵额外暴击消息
	regMsg(self, gud_show_weapon_extracritical, handler(self, self.showExtraCritical))
	--注册神兵自动升级消息
	regMsg(self, ghd_weapon_auto_upgrade_tip, handler(self, self.showAutoUpgradeLay))
	--注册活动刷新信息
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	--注册玩家数据据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))
end
--注销消息
function DlgWeaponInfo:unregMsgs(  )
	-- body	
	unregMsg(self, gud_refresh_weaponInfo)
	--销毁神兵升级特效消息
	unregMsg(self, ghd_weapon_upgrade_effect)
	--销毁神兵暴击成功特效消息
	unregMsg(self, ghd_weapon_baoji_effect)
	--销毁神兵进阶成功特效消息
	unregMsg(self, ghd_weapon_advance_effect)
	--销毁神兵额外暴击消息
	unregMsg(self, gud_show_weapon_extracritical)
	--销毁神兵自动升级消息
	unregMsg(self, ghd_weapon_auto_upgrade_tip)
	--销毁神兵活动刷新信息
	unregMsg(self, gud_refresh_activity)
	--销毁玩家数据据刷新消息
	unregMsg(self, gud_refresh_playerinfo)
end

-- 暂停方法
function DlgWeaponInfo:onPause()
	self:unregMsgs()	
    removeTextureFromCache("tx/other/p1_tx_weapon")
end

--继续方法
function DlgWeaponInfo:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgWeaponInfo