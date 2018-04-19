-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-24 15:48:32 星期一
-- Description: 武将全身像
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local HeroViewHalf = require("app.common.heroview.HeroViewHalf")


local HeroView = class("HeroView", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_sImgName：武将外显图片名字
function HeroView:ctor( _sImgName )
	-- body
	self:myInit()
	if not _sImgName or #_sImgName == 0 then 
		print("HeroView--->武将_sImgName为nil")
		return 
	end
	self.sHeroImg = _sImgName
	self.sHeroImgKey = "#" .. _sImgName .. "%d.png"

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HeroView",handler(self, self.onHeroViewDestroy))
end

--初始化成员变量
function HeroView:myInit(  )
	-- body
	self.sHeroImg 				= 			nil 				--武将图片名
	self.sHeroImgKey 			= 			nil 				--图片名字（比如：#i200001_%d.png）
end

--初始化控件
function HeroView:setupViews( )
	-- body
end

-- 修改控件内容或者是刷新控件数据
function HeroView:updateViews(  )
	-- body
	--纹理加载控制
	--获得武将纹理
--	local pHeroTexture = tHeroViewTexture[tostring(self.sHeroImg)]
--	if pHeroTexture then --存在纹理指向
--		addTextureToCache(pHeroTexture,3)
--		--判断是否已经加载了
--		if tCurUseTextures[pHeroTexture] == nil then
--			--引用纹理
--			tCurUseTextures[pHeroTexture] = 1
--		else
--			tCurUseTextures[pHeroTexture] = tCurUseTextures[pHeroTexture] + 1
--		end
--	end
--    addHeroTextureToCache(self.sHeroImg, 1)

	--全身像宽高
	local nAllWidth = 0
	local nAllHeight = 0

	local pPreView = nil --最后加载的图片

    local tempViews = {}
	for i = 1, 5 do
		local nImgIndex = 1
		if i == 1 then
			nImgIndex = 1
		elseif i == 2 then
			nImgIndex = 2
		elseif i == 4 then
			nImgIndex = 8
		elseif i == 5 then
			nImgIndex = 9
		end

		local pView = self:getChildByName("hero_view_" .. i)
		if not pView then
			if i == 3 then --半身像
				pView = HeroViewHalf.new(self.sHeroImg)
			else
				--pView = MUI.MImage.new(string.format(self.sHeroImgKey,nImgIndex))
                pView = MUI.MImage.new(getHeroBodyImagePath(self.sHeroImg, nImgIndex))
			end
			pView:setName("hero_view_" .. i)
			self:addView(pView)
		else
			if i == 3 then --半身像
				pView:updateHeroView(self.sHeroImg)
			else
				--pView:setCurrentImage(string.format(self.sHeroImgKey,nImgIndex))
                pView:setCurrentImage(getHeroBodyImagePath(self.sHeroImg, nImgIndex))
			end
		end

        tempViews[i] = pView
	end
    for i = 1, 5 do 
        local pView = tempViews[i]

		--获取宽高
		local nW = pView:getWidth()
		local nH = pView:getHeight()
		--计算位置
		local nPosX = nil
		local nPosY = nil

		if i == 1 then
			nAllWidth = nW --全身像宽
			nAllHeight = nAllHeight + nH --全身像高
			nPosX = nW / 2
			nPosY = nH / 2
		elseif i == 2 then
			if pPreView then
				nPosX = nW / 2
				nPosY = pPreView:getHeight() + nH / 2
				nAllHeight = nAllHeight + nH --全身像高
			end
		elseif i == 3 then
			if pPreView then
				nPosX = pPreView:getWidth() 
				nPosY = pPreView:getPositionY() - pPreView:getHeight() / 2 
			end
		elseif i == 4 then
			if pPreView then
				nPosX = pPreView:getPositionX() + pPreView:getWidth()  + nW / 2
				nPosY = pPreView:getPositionY() + nH / 2
			end
		elseif i == 5 then
			if pPreView then
				nPosX = nW / 2
				nPosY = pPreView:getPositionY() + pPreView:getHeight() / 2 + nH / 2
				nAllHeight = nAllHeight + nH --全身像高
			end
		end
		--设置位置
		if nPosX and nPosY then
			pView:setPosition(nPosX, nPosY)
		end
		pPreView = pView
	end
	--设置layer的大小
	self:setLayoutSize(nAllWidth, nAllHeight)
end

-- 析构方法
function HeroView:onHeroViewDestroy(  )
	-- body
	self:onPause()
	--移除武将纹理
	--removeHeroUnuserPvr()
end

-- 注册消息
function HeroView:regMsgs( )
	-- body
end

-- 注销消息
function HeroView:unregMsgs(  )
	-- body
end


--暂停方法
function HeroView:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function HeroView:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置缩放值
function HeroView:adjustToScale( _pTarget )
	-- body
	if not _pTarget then return end
	self:setScale(_pTarget:getWidth() / self:getWidth())
end

--刷新图片
function HeroView:updateHeroView(_sImgName )
	-- body
	if not _sImgName then 
		print("HeroView.updateHeroView--->武将id为nil")
		return 
	end

	if  self.sHeroImg == _sImgName then
		return
	end
	self.sHeroImg = _sImgName
	self.sHeroImgKey = "#" .. _sImgName .. "%d.png"
	self:updateViews()
end

return HeroView