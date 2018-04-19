-- DlgWeaponShareInfo.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-10-09 17:53:10 星期一
-- Description: 神兵分享对话框
-----------------------------------------------------


local DlgCommon = require("app.common.dialog.DlgCommon")

local DlgWeaponShareInfo = class("DlgWeaponShareInfo", function ()
	return DlgCommon.new(e_dlg_index.dlgweaponshareinfo)
end)

--构造
function DlgWeaponShareInfo:ctor(_tData)
	-- body
	self:myInit(_tData)
	parseView("lay_weapon_info", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgWeaponShareInfo:myInit(_tData)
	-- body
	self.tData = _tData
	addTextureToCache("tx/other/p1_tx_weapon")
end

--解析布局回调事件
function DlgWeaponShareInfo:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, false)
	self:setupViews()
	self:onResume()
	--注册析构方法
    self:setDestroyHandler("DlgWeaponShareInfo",handler(self, self.onDlgDestroy))
end

--初始化控件
function DlgWeaponShareInfo:setupViews()
	self.pLayRoot 			= 	self:findViewByName("lay_weapon_info")

	--神兵阶位
	local nAdLv = self.tData.s or 0
	--id
	local nId = self.tData.i
	--等级
	local nWeaponLv = self.tData.l

	local pData = Player:getWeaponInfo():getWeaponInfoById(nId)
	--名字
	local sName = pData.sName
	--图片
	local sIcon = pData.sIcon

	--设置标题
	self:setTitle(getConvertedStr(7, 10009))

	--神兵名字
	self.pLbName 			= 	self:findViewByName("lb_name")
	if not self.pTxtName then
		self.pTxtName = MUI.MLabel.new({
			text = getConvertedStr(3, 10238),
			size = 26,
			align = cc.ui.TEXT_ALIGN_CENTER,
			valign = cc.ui.TEXT_VALIGN_TOP,
			dimensions = cc.size(26, 0),
			})
		self.pTxtName:setPosition(self.pLbName:getPosition())
		self.pLayRoot:addView(self.pTxtName, 10)
	end

	self.pTxtName:setString(sName)

	--神兵图片
	self.pImgWeapon 	    = 	self:findViewByName("img_weapon")
	self.pImgWeapon:setCurrentImage(sIcon)
	self.pImgWeapon:setScale(0.86)
	--神兵底座图片
	self.pImgFaZhen         =   MUI.MImage.new("#sg_sbfz_jjcg_z1_006.png")
	self.pImgFaZhen:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	self.pLayRoot:addView(self.pImgFaZhen, 1)
	self.pImgFaZhen:setPosition(258, 246)
	self.pImgFaZhen:setScaleX(1.29)
	self.pImgFaZhen:setScaleY(0.54)

	--神兵名字和等级
	self.pLbInfo1 			= 	self:findViewByName("lb_info_1")
	local tStr = {
		{text = sName..getSpaceStr(2), color = getC3B(_cc.pwhite)},
		{text = getLvString(nWeaponLv,false), color = getC3B(_cc.blue)},
	}
	self.pLbInfo1:setString(tStr)
	--神兵属性
	self.pLbInfo2 			= 	self:findViewByName("lb_info_2")
	local sAttrName, nAttack = Player:getWeaponInfo():getWeaponAttribute(nId, nWeaponLv, nAdLv)
	tStr = {
		{text = getConvertedStr(7, 10040)..sAttrName..getSpaceStr(2), color = getC3B(_cc.pwhite)},
		{text = "+"..nAttack, color = getC3B(_cc.blue)},
	}
	self.pLbInfo2:setString(tStr)

	--神兵阶层
	self.pLayJie 			= 	self:findViewByName("lay_jie")

	if nAdLv > 0 then
		self.pLayJie:setVisible(true)
	else
		self.pLayJie:setVisible(false)
	end
	--神兵阶数
	self.pLbJie = MUI.MLabelAtlas.new({text="234566", 
	    png="ui/atlas/v1_img_shuzitongyong.png", pngw=32, pngh=52, scm=48})
	self.pLbJie:setScale(0.6)
	self.pLayJie:addView(self.pLbJie, 1000, 100)
	self.pLbJie:setPosition(29, 30)
	self.pLbJie:setString(nAdLv)

end

function DlgWeaponShareInfo:updateViews()
	-- body
	
end

-- 析构方法
function DlgWeaponShareInfo:onDlgDestroy(  )
	-- body
	self:onPause()
end


--注册消息
function DlgWeaponShareInfo:regMsgs(  )
	-- body
end
--注销消息
function DlgWeaponShareInfo:unregMsgs(  )
	-- body	
end

-- 暂停方法
function DlgWeaponShareInfo:onPause()
	self:unregMsgs()	
    removeTextureFromCache("tx/other/p1_tx_weapon")
end

--继续方法
function DlgWeaponShareInfo:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgWeaponShareInfo