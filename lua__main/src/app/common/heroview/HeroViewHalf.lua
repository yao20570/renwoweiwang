-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-24 14:46:55 星期一
-- Description: 武将半身像（碎图从3-7）
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local HeroViewHalf = class("HeroViewHalf", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_sImgName：武将外显图片名字
function HeroViewHalf:ctor( _sImgName )
	-- body
	self:myInit()

	if not _sImgName or #_sImgName == 0 then 
		print("HeroViewHalf--->武将_sImgName为nil")
		return 
	end
	self.sHeroImg = _sImgName
	--self.sHeroImgKey = "#" .. _sImgName .. "%d.png"
    
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HeroViewHalf",handler(self, self.onHeroViewHalfDestroy))
end

--初始化成员变量
function HeroViewHalf:myInit(  )
	-- body
	self.sHeroImg 				= 			nil 				--武将图片名
	--self.sHeroImgKey 			= 			nil 				--图片名字（比如：#i200001_%d.png）
	self.nIndexMin 				= 			3 					--武将半身像起始下标
	self.nIndexMax 				= 			7 					--武将半身像结束下标
	self.tImgs 					= 			{} 					--图片列表

end

--初始化控件
function HeroViewHalf:setupViews( )
	-- body
end

-- 修改控件内容或者是刷新控件数据
function HeroViewHalf:updateViews(  )
	-- body

	--纹理加载控制
	--获得武将纹理
--	local pHeroTexture = tHeroHalfTexture[tostring(self.sHeroImg)]
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
--    addHeroTextureToCache(self.sHeroImg, 2)

	--半身像宽高
	local nAllWidth = 0
	local nAllHeight = 0

	local pPreImg = nil --最后加载的图片

	local nIndex  = 1
	for i = self.nIndexMin, self.nIndexMax do
        local sUIName = "hero_half_" .. i
		local pImg = self:getChildByName(sUIName)
		if not pImg  then
            if i == 5 then
                -- 头像
                pImg = MUI.MImage.new(getHeroHeadImagePath(self.sHeroImg))
            else
			    pImg = MUI.MImage.new(getHeroBodyImagePath(self.sHeroImg, i))
            end
			pImg:setName(sUIName)
			self:addView(pImg)
		else
            if i == 5 then
                -- 头像
                pImg:setCurrentImage(getHeroHeadImagePath(self.sHeroImg))
            else
			    pImg:setCurrentImage(getHeroBodyImagePath(self.sHeroImg, i))
            end
		end
		
		--获取宽高
		local nW = pImg:getWidth()
		local nH = pImg:getHeight()
		--计算位置
		local nPosX = nil
		local nPosY = nil
		--
		if nIndex == 1 then
			nAllWidth = nW --半身像宽
			nAllHeight = nAllHeight + nH --半身像高
			nPosX = nW / 2
			nPosY = nH / 2
		elseif nIndex == 2 then
			if pPreImg then
				nPosX = nW / 2
				nPosY = pPreImg:getHeight() + nH / 2
				nAllHeight = nAllHeight + nH --半身像高
			end
		elseif nIndex == 3 then
			if pPreImg then
				nPosX = pPreImg:getWidth() + nW / 2
				nPosY = pPreImg:getPositionY() - pPreImg:getHeight() / 2 + nH / 2
			end
		elseif nIndex == 4 then
			if pPreImg then
				nPosX = pPreImg:getPositionX() + pPreImg:getWidth() / 2 + nW / 2
				nPosY = pPreImg:getPositionY() - pPreImg:getHeight() / 2 + nH / 2
			end
		elseif nIndex == 5 then
			if pPreImg then
				nPosX = nW / 2
				nPosY = pPreImg:getPositionY() + pPreImg:getHeight() / 2 + nH / 2
				nAllHeight = nAllHeight + nH --半身像高
			end
		end
		--设置位置
		if nPosX and nPosY then
			pImg:setPosition(nPosX, nPosY)
		end
		--保存最后加载的图片
		pPreImg = pImg
		nIndex = nIndex + 1
	end
	--设置layer的大小
	self:setLayoutSize(nAllWidth, nAllHeight)
	-- print("nAllWidth, nAllHeight", nAllWidth, nAllHeight)
end

-- 析构方法
function HeroViewHalf:onHeroViewHalfDestroy(  )
	-- body
	self:onPause()
	--移除武将纹理
	--removeHeroUnuserPvr()
end

-- 注册消息
function HeroViewHalf:regMsgs( )
	-- body
end

-- 注销消息
function HeroViewHalf:unregMsgs(  )
	-- body
end


--暂停方法
function HeroViewHalf:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function HeroViewHalf:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

--设置缩放值
function HeroViewHalf:adjustToScale( _pTarget )
	-- body
	if not _pTarget then return end
	self:setScale(_pTarget:getWidth() / self:getWidth())
end

--刷新图片
function HeroViewHalf:updateHeroView(_sImgName )
	-- body
	if not _sImgName then 
		print("HeroViewHalf.updateHeroView--->武将id为nil")
		return 
	end

	if  self.sHeroImg == _sImgName then
		return
	end
	self.sHeroImg = _sImgName
	--self.sHeroImgKey = "#" .. _sImgName .. "%d.png"
	self:updateViews()
end

return HeroViewHalf