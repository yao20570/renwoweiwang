-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-11-22 14:43:54 星期三
-- Description: 带裁剪功能的banner
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local MBanner = class("MBanner", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType：banner使用类型（TypeBannerUsed）
function MBanner:ctor( _nType, _sBName, _tOffSet )
	-- body
	self:myInit()
	self.nBannerType = _nType or self.nBannerType
	self.tBannerAttrs = TypeBannerAttrs[self.nBannerType.nType]
	if self.tBannerAttrs == nil then
		print("banner 图的参数为nil")
		return
	end
	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("MBanner",handler(self, self.onMBannerDestroy))
end

--初始化成员变量
function MBanner:myInit(  )
	-- body
	self.nBannerType 		= 			TypeBannerUsed.tjp  	--默认banner图类型
	self.tBannerAttrs 		= 			nil 					--banner参数集合
end

--初始化控件
function MBanner:setupViews( )
	-- body
	--裁剪层
	self.pClipLayer 		= 			MUI.MLayer.new(true)
	--特殊处理出界
	self.pClipLayer:setLayoutSize(self.tBannerAttrs.width, self.tBannerAttrs.height)
	self:setLayoutSize(self.tBannerAttrs.width, self.tBannerAttrs.height) 	
	self:addView(self.pClipLayer)

	--banner图
	self.pBanner = MUI.MImage.new(self.nBannerType.sImage)
	local nBannerW = self.pBanner:getWidth()
	local nBannerH = self.pBanner:getHeight()

	--设置位置
	self.pBanner:setPosition(nBannerW / 2 - self.tBannerAttrs.x, nBannerH / 2 - self.tBannerAttrs.y) 
	self.pClipLayer:addView(self.pBanner)

end

-- 修改控件内容或者是刷新控件数据
function MBanner:updateViews(  )
	-- body
end

-- 析构方法
function MBanner:onMBannerDestroy(  )
	-- body
	-- cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(self.sBName)
	-- removeUnusedTextures()
end

--设置透明度
function MBanner:setMBannerOpacity(_value)
	-- body
	self.pBanner:setOpacity(_value)
end

return MBanner
