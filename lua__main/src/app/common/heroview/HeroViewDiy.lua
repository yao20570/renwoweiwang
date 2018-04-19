-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-10-18 10:34:01 星期三
-- Description: 通过参数值 生成武将截图
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local HeroViewDiy = class("HeroViewDiy", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_sImgName：武将图片外显名字
--_tSPos：起始点坐标
--_fScale：对应类型截取的比例大小
--_nHType：全身像大小类型
function HeroViewDiy:ctor( _sImgName, _tSPos, _fScale, _nHType )
	-- body
	self:myInit()

	if _sImgName == nil then
		print("HeroViewDiy,params : _sImgName is nil")
		return
	end

	self.sImgName = _sImgName
	self.tSPos = _tSPos or self.tSPos
	self.fScale = _fScale or self.fScale
	self.nHVType = _nHType or self.nHVType

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HeroViewDiy",handler(self, self.onHeroViewDiyDestroy))
end

--初始化成员变量
function HeroViewDiy:myInit(  )
	-- body
	self.nHVType 			= 			TypeHeroDiy.I 			--默认类型1
	self.tSPos 				= 			cc.p(250,20) 			--起点坐标
	self.fScale 			= 			1.0 					--按类型大小截取的缩放值
	self.sImgName 			= 			nil 					--武将名字

	self.nHeroH 			= 			400 					--武将图像的高
	self.nHeroW 			= 			250 					--武将图素的宽

end

--初始化控件
function HeroViewDiy:setupViews()
    -- body
    if self.nHVType == TypeHeroDiy.I then -- 类型1        
        self.nHeroH = 400
        self.nHeroW = 250
    end
    local nDistance = 10

    -- 裁剪层
    self.pClipLayer = MUI.MLayer.new(true)


    -- 特殊处理出界
    local nClipW = self.nHeroW * self.fScale - nDistance
    local nClipH = self.nHeroH * self.fScale - nDistance
    self.pClipLayer:setLayoutSize(nClipW, nClipH)
    self:setLayoutSize(self.nHeroW, self.nHeroH)
    self:addView(self.pClipLayer)
    self.pClipLayer:setPosition(nDistance / 2, nDistance / 2)


    -- 生成半或全身像
    local pHeroView = creatHeroView(self.sImgName, self.nHVType)
    local size = pHeroView:getContentSize()
    pHeroView:setPosition(-self.tSPos.x, -self.tSPos.y)
    self.pClipLayer:addView(pHeroView)
    self.pClipLayer:setScale(1 / self.fScale)
end

-- 修改控件内容或者是刷新控件数据
function HeroViewDiy:updateViews(  )
	-- body
end

-- 析构方法
function HeroViewDiy:onHeroViewDiyDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function HeroViewDiy:regMsgs( )
	-- body
end

-- 注销消息
function HeroViewDiy:unregMsgs( )
	-- body
end


--暂停方法
function HeroViewDiy:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function HeroViewDiy:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return HeroViewDiy