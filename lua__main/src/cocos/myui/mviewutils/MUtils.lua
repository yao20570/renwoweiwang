------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-09 18:42:08
-- @Description: 自定义控件组的工具类
------------------------------
require "socket"
-- 可读写路径
WRITE_PATH_UPDATE = cc.FileUtils:getInstance():getWritablePath() .. "upd/"

function myclass(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

G_allFrames = {} -- 所有Frame的列表
-- 获取一个SpriteFrame,如果不存在，可以创建一个新的
-- _sName（string）  文件名称，可以是全路径，也可以是# + plist中的文件名称
-- _bNew（bool） 找不到的话，是否新建一个
function getSpriteFrameByName( _sName, _bNew)
	local pFrame = G_allFrames[_sName]
    if(tolua.isnull(pFrame)) then
        G_allFrames[_sName] = nil
    else
        -- 如果存在，并且正常使用中
        return pFrame
    end
	
    local sName = _sName
    -- 增加图片丢失的逻辑处理
	if(G_checkTexture) then
		sName, pFrame = G_checkTexture(_sName)
	end

	if(pFrame == nil) then
        -- 判断是否使用降阶的方式加载
        local isTextureFormatChange = (not gIsFileIn8888FormatList(sName))
        if isTextureFormatChange then
            if(string.find(sName, ".jpg")) then
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
            else
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
            end
        end
		local pTexture = MUI.TextureCache:addImage(sName)
		if(pTexture) then
            if b_show_load_texture_info ~= false then
        	    myprint("加载纹理-单图(UI同)","===========>:", _sName)
            end
            local size = pTexture:getContentSize()
			local rect = cc.rect(0, 0, size.width, size.height)
			pFrame = cc.SpriteFrame:createWithTexture(pTexture, rect)
			MUI.SpriteFrameCache:addSpriteFrame(pFrame, sName)
		end
        
        if isTextureFormatChange then
            --如果改变了默认纹理格式，恢复回来
            cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
        end
	end
    -- 记录到全局列表中
    G_allFrames[_sName] = pFrame
	return pFrame
end

--异步获取精灵帧
--_sName(string) 单图图片名
--_fAsync(function) 异步回调函数 ( handle(_sName, _pFrame) )
function asyncGetSpriteFrameByName( _sName, _fAsync)

    -- 记录到全局，并调用回调
    local fCallback = function(_sN, _pF)        
        G_allFrames[_sN] = _pF
        _fAsync(_sN, _pF)
    end

	local pFrame = G_allFrames[_sName]
    if(tolua.isnull(pFrame)) then
        G_allFrames[_sName] = nil
    else
        -- 如果存在，并且正常使用中
        fCallback(_sName, pFrame)
        return 
    end
	
    -- 增加图片丢失的逻辑处理
    local sName = _sName
	if(G_checkTexture) then
		sName, pFrame = G_checkTexture(_sName)
	end

	if(pFrame == nil) then
        -- 判断是否使用降阶的方式加载
        local isTextureFormatChange = (not gIsFileIn8888FormatList(sName))
        if isTextureFormatChange then
            if(string.find(sName, ".jpg")) then
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
            else
                cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
            end
        end
        if b_show_load_texture_info ~= false then
            myprint("加载纹理-单图(UI异)","===========>:开始", sName)
        end
		MUI.TextureCache:addImageAsync(sName, function(_pTexture) 
            if(_pTexture) then
                if b_show_load_texture_info ~= false then
                    myprint("加载纹理-单图(UI异)","===========>:成功", sName)
                end
                local size = _pTexture:getContentSize()
		    	local rect = cc.rect(0, 0, size.width, size.height)
		    	local frame = cc.SpriteFrame:createWithTexture(_pTexture, rect)
		    	MUI.SpriteFrameCache:addSpriteFrame(frame, sName)

                fCallback(sName, frame)
            else
                myprint("加载纹理-单图(UI异)","===========>:失败", sName)
		    end
        end)
		
        if isTextureFormatChange then
            --如果改变了默认纹理格式，恢复回来
            cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
        end
    else        
        fCallback(_sName, pFrame)
	end	
end

--[[--

用位图字体创建文本显示对象，并返回 LabelBMFont 对象。

BMFont 通常用于显示英文内容，因为英文字母加数字和常用符号也不多，生成的 BMFont 文件较小。如果是中文，应该用 TTFLabel。

可用参数：

-    text: 要显示的文本
-    font: 字体文件名
-    align: 文字的水平对齐方式（可选）
-    x, y: 坐标（可选）

~~~ lua

local label = MLabel:newBMFontLabel({
    text = "Hello",
    font = "UIFont.fnt",
})

~~~

@param table params 参数表格对象

@return LabelBMFont LabelBMFont对象

]]
function newBMFontLabel_(params)
    return display.newBMFontLabel(params)
end

--[[--

使用 TTF 字体创建文字显示对象，并返回 Label 对象。

可用参数：

-    text: 要显示的文本
-    font: 字体名，如果是非系统自带的 TTF 字体，那么指定为字体文件名
-    size: 文字尺寸，因为是 TTF 字体，所以可以任意指定尺寸
-    color: 文字颜色（可选），用 cc.c3b() 指定，默认为白色
-    align: 文字的水平对齐方式（可选）
-    valign: 文字的垂直对齐方式（可选），仅在指定了 dimensions 参数时有效
-    dimensions: 文字显示对象的尺寸（可选），使用 cc.size() 指定
-    x, y: 坐标（可选）

align 和 valign 参数可用的值：

-    cc.ui.TEXT_ALIGN_LEFT 左对齐
-    cc.ui.TEXT_ALIGN_CENTER 水平居中对齐
-    cc.ui.TEXT_ALIGN_RIGHT 右对齐
-    cc.ui.TEXT_VALIGN_TOP 垂直顶部对齐
-    cc.ui.TEXT_VALIGN_CENTER 垂直居中对齐
-    cc.ui.TEXT_VALIGN_BOTTOM 垂直底部对齐

~~~ lua

-- 创建一个居中对齐的文字显示对象
local label = MLabel:newTTFLabel({
    text = "Hello, World",
    font = "Marker Felt",
    size = 64,
    align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
})

-- 左对齐，并且多行文字顶部对齐
local label = MLabel:newTTFLabel({
    text = "Hello, World\n您好，世界",
    font = "Arial",
    size = 64,
    color = cc.c3b(255, 0, 0), -- 使用纯红色
    align = cc.ui.TEXT_ALIGN_LEFT,
    valign = cc.ui.TEXT_VALIGN_TOP,
    dimensions = cc.size(400, 200)
})

~~~

@param table params 参数表格对象

@return LabelTTF LabelTTF对象

]]
function newTTFLabel_(params)
    return display.newTTFLabel(params)
end
-- 让子控件居中于父控件
-- pPar(CCNode): 父控件
-- pChild(CCNode): 子控件
-- return(nil): 无返回值
function centerInView( pPar, pChild)
	if(pPar and pChild) then
		local fw, fh = nil, nil
        if(pPar.getWidth) then
            fw, fh = pPar:getWidth(), pPar:getHeight()
        else
            fw, fh = pPar:getContentSize().width, pPar:getContentSize().height
        end
		local fx, fy = fw/2, fh/2
		local fcw, fch = nil, nil
        if(pChild.getWidth) then
            fcw, fch = pChild:getWidth(), pChild:getHeight()
        else
            fcw, fch = pChild:getContentSize().width, pChild:getContentSize().height
        end
		local pp = pChild:getAnchorPoint()
        if(pChild.bMView and pChild.addView) then
            pp.x = 0
            pp.y = 0
        end
        fx = fx - fcw*(0.5-pp.x)
		fy = fy - fch*(0.5-pp.y)
		pChild:setPosition(fx, fy)
	end
end
-- 是否点在矩形范围内
-- _rect（cc.rect）: 矩形
-- _point（cc.p）: 点
function isRectContentPoint( _rect, _point )
    return cc.rectContainsPoint(_rect, _point)
end
-- 判断节点是否在屏幕的可视范围内容
function isNodeInGameVisible( _node )
    if(not _node) then
        return false
    end
    -- 如果自身存在检测方法，直接返回
    if(_node and _node.getIsInsideBounds) then
        return _node:getIsInsideBounds()
    end
    local rect = _node:getCascadeBoundingBox()
    local gameRect = cc.rect(0, 0, display.width, display.height)
    return cc.rectIntersectsRect(gameRect, rect)
end
-- 改变一个Sprite的可用状态，不可用时直接灰度化
-- _pSprite（CCSprite）: 一个可以灰度的Sprite
-- _bEnabled（bool）：是否可用
function changeSpriteEnabledShowState( _pSprite, _bEnabled ) 
    if(_bEnabled) then
        _pSprite:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(
            cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")))
    else
        local prog = cc.GLProgramCache:getInstance():getGLProgram("Gray")
        -- 利用Shader实现灰度的效果
        if(not prog) then
            prog = cc.GLProgram:create("shaders/Gray.vert", "shaders/Gray.frag")
            prog:link()
            prog:updateUniforms()
            cc.GLProgramCache:getInstance():addGLProgram(prog, "Gray")
        end
        local progStat= cc.GLProgramState:getOrCreateWithGLProgram(prog)
        _pSprite:setGLProgramState(progStat)
    end
end

-- 获取系统当前时间
-- isSecond(bool): 是否单位为秒，true为秒，false为毫秒
-- return（long）：isSecond为true返回秒，isSecond为false返回毫秒
function getSystemTime( isSecond )
    -- 默认是返回秒的
    if(isSecond == nil) then
        isSecond = true
    end
    if(isSecond) then
        return os.time()
    else -- socket.gettime() 返回的格式是 1223123123.XXXX， 小数点后的XXX代表毫秒数
        return math.floor(socket.gettime()*1000)
    end
end
-- 将plist文件加载到缓存中
-- _plistName（string）：plist文件的相对路径
function addTextureCache( _plistName )
    -- 如果游戏业务逻辑层有定义新的加载方式，使用新的加载方式来处理
    if(addTextureToCache and type(addTextureToCache) == "function") then
        -- 1代表使用png图片，2代表使用pvr图片
        addTextureToCache(string.gsub(_plistName, ".plist", ""), 1)
        return
    end
    if(not _plistName or string.len(_plistName) <= 0) then
        printMUI("plist文件不能为空")
        return
    end
    -- 获得png图片的名称
    local sPng = string.gsub(_plistName, ".plist", ".png")
    -- 执行实际的加载
    display.addSpriteFrames(_plistName, sPng)
end
-- 检验纹理是否存在，
-- _sFile(string):当前图片的相对路径（如果带#号的话，使用缓存池里面的图片）
-- 返回两个值
-- 值1,原文件名称或代图名称(ui/daitu.png)
-- 值2,如果存在精灵帧返回精灵帧,不存在返回nil
function G_checkTexture( _sFile )
    if(not _sFile or string.len(_sFile) <= 0) then
        return "ui/daitu.png"
    end
    local bFound = true
    local pFrame = nil
    if(string.find(_sFile, "#")) then -- 使用缓存的图片
        pFrame = MUI.SpriteFrameCache:getSpriteFrame(string.sub(_sFile, 2, #_sFile))
        bFound = pFrame ~= nil
    else
        bFound = isFileExistMUI(_sFile)
    end
    if(not bFound) then
        local sNew = "ui/daitu.png"
        myprint("找不到图片" .. _sFile .. "，使用代图".. sNew)
        _sFile = sNew
    end
    return _sFile, pFrame
end
-- 设置可以读写的路径，设置upd路径
function G_setUpdWritablePath( _path )
    WRITE_PATH_UPDATE = _path
end
-- 判断一个文件是否存在
-- _path（string）：文件的相对路径
-- _type（int）：当前获取的类型，nil为所有，1为res，2为upd
function isFileExistMUI( _path, _type )
    if(not _path) then
        return
    end
    local bFound = false
    if(_type == nil) then
        bFound = cc.FileUtils:getInstance():isFileExist("res/".. _path)
        if(not bFound) then
            if(string.find(_path, WRITE_PATH_UPDATE)) then
                bFound = cc.FileUtils:getInstance():isFileExist(_path)
            else
                bFound = cc.FileUtils:getInstance():isFileExist(WRITE_PATH_UPDATE.. _path)
            end
        end
    elseif(_type == 1) then
        bFound = cc.FileUtils:getInstance():isFileExist("res/".. _path)
    else
        if(string.find(_path, WRITE_PATH_UPDATE)) then
            bFound = cc.FileUtils:getInstance():isFileExist(_path)
        else
            bFound = cc.FileUtils:getInstance():isFileExist(WRITE_PATH_UPDATE.. _path)
        end
    end
    return bFound
end
-- 执行异步加载界面
-- _pView（CCNode）： 当前异步界面的依赖者
-- _count（number）：总共回调次数， 总次数会自动加1，目的是增加一个结束回调
-- _func(function): 每帧的回调函数，参数为( boolean<是否全部结束>, number<第几帧>)
-- _nTime(number)：多少帧回调一次
function gRefreshViewsAsync( _pView, _count, _func, _nTime )
    if(not _pView) then
        print("loadViewAsync传入的控件为空")
        return
    end
    -- 如果传进来的次数为0，直接回调出去
    if(_count == 0) then
        _func(true, 0)
        return
    end
    CLOSE_LABEL_ASYNC = true
    _nTime = _nTime or 2
    -- 如果已经存在tag的action，直接结束，重新开始
    gRemoveNodeFromPerFrameUpdate(_pView)
    local __asyncIndex = 0
    local __asyncEndIndex = _count + 1
    -- 如果是关闭分帧处理行为的话
    if(G_CLOSED_LAYER_ASYNC) then
        for i=1, __asyncEndIndex, 1 do
            __asyncIndex = __asyncIndex + 1
            if(__asyncEndIndex <= __asyncIndex) then
                if(_func) then
                    _func(true, __asyncEndIndex)
                end
                gRemoveNodeFromPerFrameUpdate(_pView)
            else
                if(_func) then
                    _func(false, __asyncIndex)
                end
                CLOSE_LABEL_ASYNC = false
            end
        end
        return
    else
        gAddNodeToPerFrameUpdate(_pView, function (  )
            __asyncIndex = __asyncIndex + 1
            if(__asyncEndIndex <= __asyncIndex) then
                if(_func) then
                    _func(true, __asyncEndIndex)
                end
                gRemoveNodeFromPerFrameUpdate(_pView)
            else
                if(_func) then
                    _func(false, __asyncIndex)
                end
                CLOSE_LABEL_ASYNC = false
            end
        end, _nTime)
    end
end
-- 执行全局的每帧刷新
function gPerFrameUpdate(  )
    g__tPerFrameViews = g__tPerFrameViews or {}
    for i=#g__tPerFrameViews, 1, -1 do
        local tData = g__tPerFrameViews[i]
        if(not tData or (not gIsNodeRunning(tData.node))) then
            table.remove(g__tPerFrameViews, i)
        else
            -- 执行次数加1，如果超过了设定的次数，则回调出去
            tData.curc = tData.curc + 1
            if(tData.curc >= tData.count) then
                tData.func()
                tData.curc = 0
            end
        end
    end
end
-- 判断节点是否存在
function gIsNodeRunning( _node )
    local bIs = false
    if(_node) then
        if(_node.bMView) then
            bIs = true
        end
    end
    return bIs
end
-- 将新的类和方法记录到全局中
function gAddNodeToPerFrameUpdate( _view, _func, _perCount )
    if(not _view or (not _func)) then
        return
    end
    g__tPerFrameViews = g__tPerFrameViews or {}
    table.insert(g__tPerFrameViews, {node=_view, func=_func, count=_perCount, curc=0})
end
-- 从全局中删除某个节点的每帧刷新
function gRemoveNodeFromPerFrameUpdate( _view )
    if(not _view) then
        return
    end
    g__tPerFrameViews = g__tPerFrameViews or {}
    for i=#g__tPerFrameViews, 1, -1 do
        -- 找到自己，然后移除掉
        local tData = g__tPerFrameViews[i]
        if(tData and tData.node == _view) then
            table.remove(g__tPerFrameViews, i)
            break
        end
    end
end
-- 执行列表的动画
-- _pView（MView）：当前列表项
-- _bVer（bool）：是否为垂直的列表
-- _nType（number）：当前动作类型
function gDoListItemAction( _pView, _bVer, _nType )
    if(not _pView) then
        return
    end
    if(_bVer == nil) then
        _bVer = true
    end
    _nType = _nType or 1
    local actionTime = 0.3
    if(_bVer) then
        if(_nType == 1) then
            local oldPos = cc.p(_pView:getPositionX(), _pView:getPositionY())
            _pView:setPositionY(oldPos.y+_pView:getHeight()*2/3)
            _pView:setOpacity(10)
            local action = cc.Spawn:create(cc.FadeIn:create(actionTime),
                cc.EaseBackOut:create(cc.MoveTo:create(actionTime, oldPos)))
            _pView:runAction(action)
        end
    end
end
-- 剔除所有html格式的内容
-- _sStr（string）：需要格式化的内容
function gCutHtmlString( _sStr )
    if(not _sStr) then
        return _sStr
    end
    -- 如果不是字符串的话，直接返回*号
    if(type(_sStr) == "table") then
        return "*"
    end
    -- 踢出多余的html内容
    local nS1, nE1 = string.find(_sStr, "<")
    local nS2, nE2 = string.find(_sStr, ">")
    if(nS1 and nS2) then
        _sStr = string.gsub(_sStr, "%b<>", "")
    end
    return _sStr
end
-- 增加一个自定义的多行输入框
function addCoupleLineEdit( _player, _options )
    if(not _player) then
        print("父控件不能为空")
        return
    end
    _options = _options or {}
    _options.gap = _options.gap or 5
    _options.image = _options.image or "v1_bar_sck_3.png"-- "ui/daitu.png"
    if(device.platform == "ios") then
        _options.imagePressed = "ui/daitu.png"
    end
    _options.fontSize = _options.fontSize or 20
    _options.fontColor = _options.fontColor or cc.c3b(255, 255, 255)
    local tmpSize = cc.size(_player:getWidth()-2*_options.gap, _player:getHeight()-2*_options.gap)
    local pEdit = _player:findViewByName("couple_line_edit")
    if(not pEdit) then
        pEdit = MUI.MInput.new({
            image=_options.image,
            imagePressed=_options.imagePressed,
            fontSize=_options.fontSize,
            size=tmpSize})
        pEdit:setName("couple_line_edit")
        _player:addView(pEdit, 20000)
        pEdit:setIsSingleLine(false)
        pEdit:setFontColor(_options.fontColor)
        pEdit:setFontSize(_options.fontSize)
        _player:setIsPressedNeedScale(false)
        _player:setIsPressedNeedColor(false)
        centerInView(_player, pEdit)
    end
    local pLabel = pEdit:getCoupleLineLabel()
    if(pLabel) then
        pLabel:setPosition(_options.gap, _player:getHeight()-_options.gap)
    end
    return pEdit
end
-- 保存图片使用加载的模式
-- _sName(string)：图片的全路径
function gSaveFileFor8888Format( _sName )
    G_saveingTexture = G_saveingTexture or {}
    G_saveingTexture[_sName] = 1
end
-- 清除图片使用加载的模式
-- _sName(string)：图片的全路径
function gReleaseFileFor8888Format( _sName )
    G_saveingTexture = G_saveingTexture or {}
    G_saveingTexture[_sName] = nil
end
-- 判断文件是否维持8888加载模式
-- _sName(string)：图片的全路径
function gIsFileIn8888FormatList( _sName )
    if not b_open_texture_cutquality then
        return true
    end
    G_saveingTexture = G_saveingTexture or {}
    if G_saveingTexture[_sName] == nil then
        return false
    end
    return true
end
-- 打印纹理使用情况
function gDumpTextureInfo(  )
    print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
end
-- 打印lua的内存使用大小
function gDumpLuaInfo()
    print("lua的内存大小为==>", collectgarbage("count"))
end
-- 判断一个lua变量是否存在，可以包含c++指针的判断
-- _data(any): 任何类型的变量
function gIsNull( _data )
    if(_data == nil) then
        return true
    end
    if(type(_data) == "userdata") then
        return tolua.isnull(_data)
    else
        return false
    end
end