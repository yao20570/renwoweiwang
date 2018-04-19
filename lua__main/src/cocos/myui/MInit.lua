------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-07-03 23:09:22
-- @Description: 自定义ui控件处理
------------------------------

local CURRENT_MODULE_NAME = ...
local c = cc

------------------------- 上面是系统使用的工具 ---------------------------------------
MUI = {}

function makeMUIControl_(control)
    cc(control)
    control:addComponent("components.ui.LayoutProtocol"):exportMethods()
    control:addComponent("components.behavior.EventProtocol"):exportMethods()

    control:setCascadeOpacityEnabled(true)
    control:setCascadeColorEnabled(true)
    -- 替换掉上面的方法
    control:onNodeEvent("cleanup", function (  )
        control:removeAllEventListeners()
    end)
end

function reAddMUIComponent_(control)
    control:addComponent("components.ui.LayoutProtocol"):exportMethods()
    control:addComponent("components.behavior.EventProtocol"):exportMethods()

    -- 替换掉上面的方法
    control:onNodeEvent("cleanup", function (  )
        control:removeAllEventListeners()
    end)
end

-- 是否开启控件的打印
MUI_DEBUG = 1

-- 执行MUI的打印
function printMUI( ... )
    if(MUI_DEBUG and MUI_DEBUG > 0) then
        -- 0代表自己getinfo, 1代表当前执行的方法printMUI,2代表调用printMUI的方法
        -- local tDa = debug.getinfo(2)
        -- local sFunName = tDa.name
        -- local sFileName = string.split(tDa.source, "/")
        -- if(sFileName and #sFileName > 0) then
        --     sFileName = sFileName[#sFileName]
        -- end
        -- if(sFileName) then
        --     sFileName = string.sub(sFileName, 1, string.find(sFileName, ".lua")-1)
        --     sFunName = sFileName .. ":" .. sFunName
        -- end
        local sFunName = "MUI打印--->"
        print(sFunName, ...)
    end
end

MUI.CLICKED_EVENT = "CLICKED_EVENT" -- 点击事件
MUI.PRESSED_EVENT = "PRESSED_EVENT" -- 触摸按下事件
MUI.RELEASE_EVENT = "RELEASE_EVENT" -- 触摸释放事件
MUI.STATE_CHANGED_EVENT = "STATE_CHANGED_EVENT" -- 状态变化的事件
MUI.TEXT_ALIGN_LEFT    = cc.TEXT_ALIGNMENT_LEFT
MUI.TEXT_ALIGN_CENTER  = cc.TEXT_ALIGNMENT_CENTER
MUI.TEXT_ALIGN_RIGHT   = cc.TEXT_ALIGNMENT_RIGHT
MUI.TEXT_VALIGN_TOP    = cc.VERTICAL_TEXT_ALIGNMENT_TOP
MUI.TEXT_VALIGN_CENTER = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
MUI.TEXT_VALIGN_BOTTOM = cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM

MUI.VIEW_TYPE = { -- 控件类型
    group = 10, -- MGroup
    image = 20, -- MImage
    imagenine = 21, -- MImage 点9
    label = 30, -- MLabel
    labelbm = 31, -- MLabelBM
    labelatlas = 32, -- MLabelAtlas
    button = 40, -- MButton
    pushbutton = 41, -- MPushButton
    checkbutton = 42, -- MCheckButton
    slider = 50, -- MSlider
    loadingbar = 60, -- MLoadingBar
    scrollview = 70, -- MScrollLayer
    layer = 80, -- MLayer
    filllayer = 81, -- MFillLayer
    listview = 90, -- MListView
    rootlayer = 100, -- MRootLayer
    clippingnode = 110, -- MClippingNode
    input = 120, -- MInput
    pageview = 130, -- MPageView
}
MUI.TOUCH_HANDLE_TYPE = { -- 触摸的控制类型
    MOVED = 100, -- 移动了
}
MUI.GL_ONE = 1 -- 高亮时的值

MUI.DEFAULT_FONT = "微软雅黑" --默认字体

MUI.LAYER_BG_ZORDER = -300 --底部背景层默认层级


--输入框：定义了被输入文字的显示格式
MUI.MINPUT_FLAG = {
    PASSWORD = 0, --表示输入文本为机密数据，只要可能就不要直接显示。 此标志暗含了SENSITIVE标志。
    SENSITIVE = 1, --表示输入文字为敏感数据，在实现时禁止为了预测、自动填充 或者其余加速输入的目的而将其存入字典或者表格。 例如信用卡号就是一种敏感数据。
    INITIAL_CAPS_WORD = 2, --表示在文本编辑的过程中，每个单词的首字母都应该大写。
    INITIAL_CAPS_SENTENCE = 3, --表示在文本编辑的过程中，每句话的首字母都应该大写。
    INTIAL_CAPS_ALL_CHARACTERS = 4, --自动将所有字母大写。
}

--输入框：定义了用户可输入的文本类型
MUI.MINPUT_MODE = {
    ANY = 0,             --用户可输入任何文本，包括换行
    EMAIL_ADDRESS = 1,   --用户可输入一个电子邮件地址
    NUMERIC = 2,         --用户可输入一个整数
    PHONE_NUMBER = 3,    --用户可输入一个电话号码
    URL = 4,             --用户可输入一个URL
    DECIMAL = 5,         --用户可输入一个实数 跟NUMERIC相比，此模式可以多出一个小数点
    SINGLE_LINE = 6,     --用户可输入除换行符外的任何文本
}

MUI.kCCPositionTypeFree = 0         --粒子添加到世界后，不会受到发射定位的影响
MUI.kCCPositionTypeRelative = 1     --粒子添加到世界后，受到发射定位的影响 用例: 添加一个发射器到一个精灵，并让发射器随精灵的移动而移动。
MUI.kCCPositionTypeGrouped = 2      --粒子附着在发生器上并随它一起移动

MUI.CAMERA_FLAG = {
    USER1 = 2, --相机类型1
    USER2 = 3, --相机类型2
}

-- armature的播放事件回调
MovementEventType = {
    START           = 0, -- 开始
    COMPLETE        = 1, -- 完全结束
    LOOP_COMPLETE   = 2, -- 循环结束
}

-- 引入工具类
import(".mviewutils.MUtils")
import(".mviewutils.MPrivateUtils")
import(".mviewutils.MViewPool")
import(".mviewutils.MViewReader")
import(".mviewutils.MArmatureUtils")

MUI.MView                = import(".MView")
MUI.MLayer               = import(".MLayer")
MUI.MFillLayer           = import(".MFillLayer")
MUI.MRootLayer           = import(".MRootLayer")
MUI.MImage               = import(".MImage")
MUI.MLabel               = import(".MLabel")
MUI.MLabelBM             = import(".MLabelBM")
MUI.MLabelAtlas          = import(".MLabelAtlas")
MUI.MButton              = import(".MButton")
MUI.MPushButton          = import(".MPushButton")
MUI.MLoadingBar          = import(".MLoadingBar")
MUI.MSlider              = import(".MSlider")
MUI.MCheckBoxButton      = import(".MCheckBoxButton")
MUI.MInput               = import(".MInput")
MUI.MScrollLayer         = import(".MScrollLayer")
MUI.MScrollView          = import(".MScrollView")
MUI.MListView            = import(".MListView")
MUI.MPageView            = import(".MPageView")
MUI.scheduler            = require("framework.scheduler")

-- abandon舍弃的类，暂时不考虑使用
MUI.MGroup               = import(".abandoned.MGroup")
MUI.MStretch             = import(".abandoned.MStretch")
MUI.MLayout              = import(".abandoned.MLayout")
MUI.MBoxLayout           = import(".abandoned.MBoxLayout")
MUI.MCheckBoxButtonGroup = import(".abandoned.MCheckBoxButtonGroup")

MUI.SpriteFrameCache = cc.SpriteFrameCache:getInstance()
MUI.Director         = cc.Director:getInstance()
MUI.TextureCache = MUI.Director:getTextureCache()
MUI.AnimationCache   = cc.AnimationCache:getInstance()
-- 设置可读写的路径
if(S_WRITABLE_PATH and G_setUpdWritablePath) then
    G_setUpdWritablePath(S_WRITABLE_PATH .. "upd/")
end
