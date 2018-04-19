------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 18:31:33
-- @Description: 自定义图片控件
------------------------------

--------------------------------
-- @module MImage

local MView = import(".MView")

local MImage = myclass("MImage", function(filename, options)
    local nType = MUI.VIEW_TYPE.image
    if(options and options.scale9) then
        nType = MUI.VIEW_TYPE.imagenine
    end
    -- 判断是否使用降阶的方式加载
    if(not gIsFileIn8888FormatList(filename)) then
        if(string.find(filename, ".jpg")) then
            cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
        else
            cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        end
    end
    local pView = MView.new(nType, filename, options)
    --恢复回来
    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    return pView
end)

-- start --

--------------------------------
-- UIImage构建函数
-- @function [parent=#MImage] new
-- @param string filename 图片文件名
-- @param table options 参数表

-- end --

function MImage:ctor(filename, options)
    -- 通用的重置初始值行为
    self:__resetOptions(true, filename, options)
end

-- 刷新是否可用的状态
function MImage:__onRefreshEnableState( _bEn )
    if(_bEn == nil) then
        _bEn = self:isViewEnabled()
    end
    changeSpriteEnabledShowState(self, _bEn)
end

-- 刷新按钮状态是否置灰
function MImage:__onRefreshGrayState( _bEn )
    if(_bEn == nil) then
        _bEn = self:isViewGray()
         _bEn = not _bEn
    end
    if self.isScale9_ and self.getProtectedChildren then --如果是九宫格图
        local children = self:getProtectedChildren()
        if children and #children > 0 then
            for _, aSprite in ipairs(children) do
                changeSpriteEnabledShowState(aSprite, _bEn)
            end
        end
    else
        changeSpriteEnabledShowState(self, _bEn)
    end
    
end

-- 重置特殊需求的控制
-- 这里的参数与ctor方法的参数一样
function MImage:__resetOptions( _bNew, filename, options )
    if(_bNew == nil) then
        _bNew = true
    end
    self:align(display.CENTER)
    local contentSize = self:getContentSize()
    self.isScale9_ = options and options.scale9
    if(options) then
        self.m_capInsets = options.capInsets
    end

    self.args_ = {filename, options}
    if(not _bNew) then
        if(filename) then
            self:setCurrentImage(filename) 
        end
        -- 取消置灰的控制
        self:setViewEnabled(true)
        self:setToGray(false)
        -- 取消图片的翻转
        self:setFlippedX(false)
        self:setFlippedY(false)
        --取消点击事件
        self:setViewTouched(false)
        self:onMViewClicked(nil)
        -- 恢复透明度
        self:setOpacity(255)
        -- 恢复颜色值
        self:setColor(cc.c3b(255, 255, 255))
    end
end
-- start --

--------------------------------
-- UIImage设置控件大小
-- @function [parent=#MImage] setLayoutSize
-- @param number width 宽度
-- @param number height 高度
-- @return MImage#MImage  自身

-- end --

function MImage:setLayoutSize(width, height)
    if(width and type(width) ~= "number") then
        self.m_fWidth = width.width or 1
        self.m_fHeight = height.height or 1
    else
        self.m_fWidth = width or self.m_fWidth
        self.m_fHeight = height or self.m_fHeight
    end
    
    if self.isScale9_ then
        self:setContentSize(self.m_fWidth, self.m_fHeight)
    else
        local boundingSize = self:getBoundingBox()
        local sx = self.m_fWidth / (boundingSize.width / self:getScaleX())
        local sy = self.m_fHeight / (boundingSize.height / self:getScaleY())
        if sx > 0 and sy > 0 then
            self:setScaleX(sx)
            self:setScaleY(sy)
        end
    end

    return self
end
-- 获取控件的大小，与contentsize区分开来
function MImage:getLayoutSize(  )
    if(self.m_fWidth) then
        return self.m_fWidth, self.m_fHeight
    end
    local size = self:getContentSize()
    return size.width, size.height
end

function MImage:createCloneInstance_()
    return MImage.new(unpack(self.args_))
end

function MImage:copySpecialProperties_(node)
    self:setLayoutSize(node:getLayoutSize())
end
-- 重新设置当前图片
function MImage:setCurrentImage(_sName, _capInsets)
    if (not _sName) then
        -- if self.setTexture then
        --     self:setTexture(nil)
        -- end
        -- printMUI("MImage:setCurrentImage图片的名称错误")
        return
    end
    -- 获取一个新的SpriteFrame
   local pFrame = getSpriteFrameByName(_sName, true)
   if (pFrame) then
       self.m_capInsets = _capInsets or self.m_capInsets
       if (self.isScale9_ and self.m_capInsets) then
           self:setSpriteFrame(pFrame, self.m_capInsets)
           self:setLayoutSize(self:getLayoutSize())
       else
           self:setSpriteFrame(pFrame)
       end
       if self.args_ then
           self.args_[1] = _sName
           if self.args_[2] then
               self.args_[2].capInsets = self.m_capInsets            
           end            
       end
   else
       printMUI("找不到对应的Frame")
   end
    -- asyncGetSpriteFrameByName(_sName, function(_sN, _sF)
    --     if (_sF) then
    --         self.m_capInsets = _capInsets or self.m_capInsets
    --         if (self.isScale9_ and self.m_capInsets) then
    --             self:setSpriteFrame(_sF, self.m_capInsets)
    --             self:setLayoutSize(self:getLayoutSize())
    --         else
    --             self:setSpriteFrame(_sF)
    --         end
    --         if self.args_ then
    --             self.args_[1] = _sN
    --             if self.args_[2] then
    --                 self.args_[2].capInsets = self.m_capInsets            
    --             end            
    --         end
    --     else
    --         printMUI("找不到对应的Frame")
    --     end
    -- end)
end

return MImage
