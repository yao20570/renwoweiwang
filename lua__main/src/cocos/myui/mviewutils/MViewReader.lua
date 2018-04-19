------------------------------
-- @Author:      xieruidong(谢锐东)
-- @DateTime:    2016-11-20 14:08:30
-- @Description: 布局文件的解读器
------------------------------
MViewReader = myclass("MViewReader")

--控件的标识命名
local PANEL = "Panel" -- 层控件的标识
local BUTTON = "Button" -- 按钮的标识
local CUSTOMBUTTON = "CustomButton"-- 自定义按钮的标识
local LABEL = "Label" -- 文本的标识
local LABELATLAS = "LabelAtlas" -- 数字标签的标识
local CUSTOMLABEL = "CustomLabel" -- 自定义文本的标识
local IMAGEVIEW = "ImageView" --图片的标识
local CUSTOMIMAGEVIEW = "CustomImageView" --自定义图片的标识
local CHECKBOX = "CheckBox" -- 复选框的标识
local LOADINGBAR = "LoadingBar" -- 进度条
local SLIDER = "Slider" -- 拖动条
local TEXTFIELD = "TextField" -- 输入框
local CUSTOMTEXTFIELD = "CustomTextField" -- 自定义输入框
local SCROLLVIEW = "ScrollView" -- 拖动层
local LISTVIEW = "ListView" -- 列表
local PAGEVIEW = "PageView"-- 分页列表

local ROOT = "root" -- 根控件的标识
local KEY_INDEX = "index_" -- 层级标识的前缀
--参数的标识命名
local Kname = "name" -- 名字
local Kclassname = "classname" -- 控件类型名称
local KZOrder = "ZOrder" -- 层级order
local Ktag = "tag" -- tag标识
local KanchorPointX = "anchorPointX" -- 锚点x
local KanchorPointY = "anchorPointY" -- 锚点y
local Kheight = "height" -- 高度
local Kwidth = "width" -- 宽度
local Kopacity = "opacity" -- 透明度
local Krotation = "rotation" -- 旋转值
local KscaleX = "scaleX" -- 缩放x
local KscaleY = "scaleY" -- 缩放y
local KtouchAble = "touchAble" -- 是否可触摸
local Kvisible = "visible" -- 是否可见
local KuseMergedTexture = "useMergedTexture" -- 是否使用合成的大图
local Kx = "x" -- 坐标x
local Ky = "y" -- 坐标y
local KcapInsetsHeight = "capInsetsHeight" -- 9宫格的高度
local KcapInsetsWidth = "capInsetsWidth" -- 9宫格的宽度
local KcapInsetsX = "capInsetsX" -- 9宫格的起点x
local KcapInsetsY = "capInsetsY" -- 9宫格的起点y
local KclipAble = "clipAble" -- 层--是否裁剪
local KflipX = "flipX" -- 是否翻转
local KbackGroundImage = "backGroundImage" -- 层--背景图片
local KparName = "parName" -- 父控件的名称
local KtreeIndex = "treeIndex" -- 当前在树状的层级位置
local KchildCount = "childCount" -- 子控件的个数
local KbackGroundScale9Enable = "backGroundScale9Enable" -- 背景是否使用9宫格图
--特殊参数
local Knormal = "normal" -- 按钮的正常图片
local Kpressed = "pressed" -- 按钮按下的图片
local Kdisabled = "disabled" -- 按钮无效的图片
local KfontName = "fontName" -- 文字的字体名称
local KfontSize = "fontSize" -- 文字的字体大小
local Kscale9Enable = "scale9Enable" -- 是否使用9宫格
local Kscale9Height = "scale9Height" -- 9宫格的高度
local Kscale9Width = "scale9Width" -- 9宫格的宽度
local Ktext = "text" -- 文本的内容
local KtextColorB = "textColorB" -- 文本的字体颜色B值
local KtextColorG = "textColorG" -- 文本的字体颜色G值
local KtextColorR = "textColorR" -- 文本的字体颜色R值
local KcolorB = "colorB" -- 文本的字体颜色B值
local KcolorG = "colorG" -- 文本的字体颜色G值
local KcolorR = "colorR" -- 文本的字体颜色R值
local KareaHeight = "areaHeight" -- 文本区域的高度
local KareaWidth = "areaWidth" -- 文本区域的宽度
local KhAlignment = "hAlignment" -- 文本的横向对齐方式
local KvAlignment = "vAlignment" -- 文本的纵向对齐方式
local KfileName = "fileName" -- 图片的名称
local KbackGroundBox = "backGroundBox" -- 复选框背景图片
local KfrontCross = "frontCross" -- 复选框选中的图片
local KselectedState = "selectedState" -- 复选框选中的状态
local Kdirection = "direction" -- 进度条的方向
local Kpercent = "percent" -- 进度条的进度
local Ktexture = "texture" -- 进度条的进度图片
local KballNormal = "ballNormal" -- 拖动条的球
local KbarFileName = "barFileName" -- 拖动条的进度条背景
local KprogressBar = "progressBar" -- 拖动条的进度条
local KmaxLength = "maxLength" -- 输入框的最大字节长度
local KmaxLengthEnable = "maxLengthEnable" -- 是否开启输入框的最大字节长度
local KpasswordStyleText = "passwordStyleText" -- 输入框开启密码时的替换字符
local KpasswordEnable = "passwordEnable" -- 是否开启输入框的密码格式
local KeditorClipAble = "editorClipAble" -- 列表是否裁剪
local KitemMargin = "itemMargin" -- 列表子项之间的间距
local KbounceEnable = "bounceEnable" -- 列表是否支持回弹
local KcharMapFile = "charMapFile" -- 数字标签的文件
local KitemHeight = "itemHeight" -- 数字标签的单个数字高度
local KitemWidth = "itemWidth" -- 数字标签的单个数字宽度
local KstartCharMap = "startCharMap" --数字标签的起始的字符
local KstringValue = "stringValue" -- 数字标签的文本

-- 获取单列类
function MViewReader:getInstance(  )
    if(not self.m_instance) then
        self.m_instance = MViewReader.new()
    end
    return self.m_instance
end

function MViewReader:ctor()
    self.tCreateFuns = {}
    self.tCreateFuns[PANEL]             = self.__handleNewLayer
    self.tCreateFuns[LABEL]             = self.__handleNewLabel         -- 文本
    self.tCreateFuns[CUSTOMLABEL]       = self.__handleNewLabel         -- 文本
    self.tCreateFuns[IMAGEVIEW]         = self.__handleNewImage         -- 图片
    self.tCreateFuns[CUSTOMIMAGEVIEW]   = self.__handleNewImage         -- 图片
    self.tCreateFuns[SCROLLVIEW]        = self.__handleNewScrollLayer   -- 拖动层
    self.tCreateFuns[LISTVIEW]          = self.__handleNewListView      -- 列表
    self.tCreateFuns[PAGEVIEW]          = self.__handleNewPageView      -- 分页列表
    self.tCreateFuns[BUTTON]            = self.__handleNewButton        -- 按钮
    self.tCreateFuns[CUSTOMBUTTON]      = self.__handleNewButton        -- 按钮
    self.tCreateFuns[LOADINGBAR]        = self.__handleNewLoadingBar    -- 进度条
    self.tCreateFuns[SLIDER]            = self.__handleNewSlider        -- 拖动条
    self.tCreateFuns[TEXTFIELD]         = self.__handleNewInput         -- 输入框
    self.tCreateFuns[CUSTOMTEXTFIELD]   = self.__handleNewInput         -- 输入框
    self.tCreateFuns[LABELATLAS]        = self.__handleNewLabelAtlas    -- 数字标签
    self.tCreateFuns[CHECKBOX]          = self.__handleNewCheckBox      -- 复选框

    -- 注册可重用对象(取消了对象池，所以数量改为0)
    MViewPool:getInstance():regObjInfo(MPoolObjectType.FILLLAYER, 0, MUI.MFillLayer, nil)
    MViewPool:getInstance():regObjInfo(MPoolObjectType.IMAGE, 0, MUI.MImage, { "ui/daitu.png" })
    MViewPool:getInstance():regObjInfo(MPoolObjectType.IMAGENINE, 0, MUI.MImage, { "ui/daitu.png", { scale9 = true, capInsets = { 0, 0, 0, 0 } } })
    MViewPool:getInstance():regObjInfo(MPoolObjectType.LABEL, 0, MUI.MLabel, { { text = "", size = 20, color = cc.c3b(255, 255, 255) } })
    MViewPool:getInstance():regObjInfo(MPoolObjectType.LAYER, 0, MUI.MLayer, nil)
end

-- 解析布局，返回解析后的控件组合
-- _sName（string）：文件的全路径
-- _nFunc（function）：回调方法
function MViewReader:createNewGroup( _sName, _nFunc )
	-- 加载该文件内容
	local tViewDatas = require(_sName)
	-- 执行正式的控件解析
	local pView = self:__doRealCreate(tViewDatas)
	-- 释放该文件内容(暂时取消，io操作对手机还是比较有影响)
	-- package.loaded[_sName] = nil
	-- 执行回调
	_nFunc(pView)
end
-- 执行实际的解析
-- _tViewDatas（table）：整个布局的数据
function MViewReader:__doRealCreate( _tViewDatas )
	-- 执行纹理的加载
--	if(_tViewDatas.texturesPng) then
--		for i, v in pairs(_tViewDatas.texturesPng) do
--			if(v and string.find(v, ".plist")) then
--				-- 只加载plist文件
--				addTextureCache(v)
--			end
--		end
--	end

	local pView =  self:__doBeginCreate(_tViewDatas, 1, ROOT)
	return pView
end
-- 执行layer的解析
-- _tViewDatas(table)：控件的所有数据
-- _index（int）：当前解析的层级
-- _parName(String or MLayer): 父控件名称或者是父控件本身
function MViewReader:__doBeginCreate( _tViewDatas, _index, _parName )
	local pReturnView = nil
	local pParView = nil
	if(type(_parName) ~= "string") then
		pParView = _parName
		_parName = pParView:getName()
	end
	if(_tViewDatas[KEY_INDEX.._index]) then
		-- 遍历所有的控件，然后挂载到父控件身上
		for i, v in pairs(_tViewDatas[KEY_INDEX.._index]) do
			-- 找到子项的内容
			if(v and v[KparName] == _parName) then 
				-- 创建一个新的控件出来
				local pView = self:__doCreateNewMView(v)
				-- 如果是扩充层，取消自动刷新的行为
				if(pView and pView.setRefreshEveryTime) then
					pView:setRefreshEveryTime(false)
				end
				if(pParView) then
					-- 增加到父控件中
					pParView:addView(pView)
				end
				-- 层控件的话，加载其子控件
				if(v[Kclassname] == PANEL and v[KchildCount] 
					and tonumber(v[KchildCount]) > 0) then 
					self:__doBeginCreate(_tViewDatas, _index+1, pView)
				end
				-- 如果是扩充层，恢复自动刷新的行为,并且强制刷新一下
				if(pView and pView.setRefreshEveryTime) then
					pView:setRefreshEveryTime(true)
					pView:requestLayout()
				end
				if(_parName == ROOT) then
					pReturnView = pView
				end
			end
		end
	end
	return pReturnView
end
-- 格式化名称
-- _name（string）：当前名称
function MViewReader:__formatName( _name )
	local nS, nE = string.find(_name, "@")
	if(nS) then
		_name = string.sub(_name, 1, nS-1)
	end
	return _name
end
-- 创建一个新的控件
-- _tD（table）：布局中的参数内容
function MViewReader:__doCreateNewMView( _tD )
    

    local pView = self.tCreateFuns[_tD[Kclassname]](self, _tD)


	return pView
end
-- 执行共有属性的解析
-- _tD（table）：共有属性的内容
-- _pView（MView）：已经生成好的控件
function MViewReader:__doSharedParams( _tD, _pView )
	if(not _tD or not _pView) then
		printMUI("解析布局时共有属性不能为空")
		return
	end
	_pView:setName(self:__formatName(_tD[Kname] or "")) -- 名字
	_pView:setZOrder(tonumber(_tD[KZOrder]) or 0) -- 层级
	_pView:setTag(tonumber(_tD[Ktag]) or 0) -- tag标识
	-- 锚点
	_pView:setAnchorPoint(cc.p(tonumber(_tD[KanchorPointX] or 0.5), 
		tonumber(_tD[KanchorPointY] or 0.5)))
	-- 大小
	_pView:setLayoutSize(tonumber(_tD[Kwidth] or 0), tonumber(_tD[Kheight] or 0))
	_pView:setOpacity(tonumber(_tD[Kopacity] or 255)) -- 透明值
	_pView:setRotation(tonumber(_tD[Krotation] or 0)) -- 旋转值
	_pView:setScaleX(tonumber(_tD[KscaleX] or 1)) -- x缩放大小
	_pView:setScaleY(tonumber(_tD[KscaleY] or 1)) -- y缩放大小
	-- 
	if(_tD[KtouchAble] == nil
		or _tD[Kclassname] == PANEL) then
		_tD[KtouchAble] = "false"
	end
	_pView:setViewTouched(_tD[KtouchAble] == "true") -- 是否可以触摸
	_pView:setVisible(_tD[Kvisible] == "true") -- 是否可见
	_pView:setPosition(tonumber(_tD[Kx] or 0), tonumber(_tD[Ky] or 0)) -- 位置
	-- 检测是否存在此方法，再确定是否需要设置
	if(_pView.setFlipX) then
		_pView:setFlipX(_tD[KflipX] == "true")
	end
end
-- 处理层控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewLayer( _tD )
	local pView = nil
	local bClipping = _tD[KclipAble] == "true"
	if(string.find(_tD[Kname], "@fill_layout")) then
        pView = MViewPool:getInstance():pop(MPoolObjectType.FILLLAYER)
        if (pView) then
            pView:__resetOptions(false, bClipping)
        else
            pView = MUI.MFillLayer.new(bClipping)
        end

        -- 忽略同级其它的高来适配
        if (string.find(_tD[Kname], "@fill_layout_height")) then
            pView:setIgnoreOtherHeight(true)
        end
	else
		-- 如果开启缓存池控制的话，使用缓存池中的控件
        pView = MViewPool:getInstance():pop(MPoolObjectType.LAYER)
        if (pView) then
            pView:__resetOptions(false, bClipping)
        else
            pView = MUI.MLayer.new(bClipping)
        end
	end   

	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	if(_tD[KbackGroundImage]) then
		local tT = {}
		-- 如果背景图使用9宫格的话,记录拉伸的数值
		if(_tD[KbackGroundScale9Enable]) then
			tT.scale9 = _tD[KbackGroundScale9Enable] == "true"
			if(tT.scale9) then
				tT.capInsets = cc.rect(tonumber(_tD[KcapInsetsX]),
					tonumber(_tD[KcapInsetsY]),
					tonumber(_tD[KcapInsetsWidth]),
					tonumber(_tD[KcapInsetsHeight]))
			end
		end
		pView:setBackgroundImage(_tD[KbackGroundImage], tT, true)
	end
	return pView
end
-- 处理按钮控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewButton( _tD )
	local tT = {}
	if(_tD[Knormal]) then
		tT.normal = _tD[Knormal]
	end
	if(_tD[Kpressed]) then
		tT.pressed = _tD[Kpressed]
	end
	if(_tD[Kdisabled]) then
		tT.disabled = _tD[Kdisabled]
	end
	if(_tD[Kscale9Enable] == "true") then
		tT.scale9 = true
	end
	local pView = nil
	pView = MUI.MPushButton.new(tT)
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	if(_tD[Ktext]) then
		local pLabel = MUI.MLabel.new(
	        {text=_tD[Ktext], size=tonumber(_tD[KfontSize]), 
	        color=cc.c3b(tonumber(_tD[KtextColorR]), 
	        	tonumber(_tD[KtextColorG]),
	        	tonumber(_tD[KtextColorB])),})
		pLabel:setSystemFontName(_tD[KfontName])
		pView:setButtonLabel("normal", pLabel)
	end
	if(_tD[Kscale9Enable] == "true") then
		pView:setButtonSize(tonumber(_tD[Kscale9Width]),
			tonumber(_tD[Kscale9Height]))
	end
	return pView
end
-- 处理文本控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewLabel( _tD )
	local tT = {}
	tT.UILabelType = 2
	-- tT.text = _tD[Ktext]
	tT.text = ""
	tT.size = tonumber(_tD[KfontSize])
	-- tT.color = cc.c3b(tonumber(_tD[KcolorR]),
	-- 	tonumber(_tD[KcolorG]), tonumber(_tD[KcolorB]))
	tT.color = cc.c3b(255,255, 255)
	if(tonumber(_tD[KareaWidth] or 0) > 0 and tonumber(_tD[KareaHeight] or 0) > 0) then
		tT.dimensions = cc.size(tonumber(_tD[KareaWidth]), tonumber(_tD[KareaHeight]))
	end
	-- 这2个取消，完全由setAnchorPoint()来控制
	-- tT.textAlign = tonumber(_tD[KhAlignment])
	-- tT.textValign = tonumber(_tD[KvAlignment])
	local pView = nil
	-- 如果开启缓存池控制的话，使用缓存池中的控件
    pView = MViewPool:getInstance():pop(MPoolObjectType.LABEL)
    if (pView) then
        pView:__resetOptions(false, tT)
    else
        pView = MUI.MLabel.new(tT)
    end

	pView:setSystemFontName(_tD[KfontName])
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------

	return pView
end
-- 处理图片控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewImage( _tD )

	local tT = {}
	tT.scale9 = _tD[Kscale9Enable] == "true"
	if(tT.scale9) then
		tT.capInsets = cc.rect(tonumber(_tD[KcapInsetsX]),
			tonumber(_tD[KcapInsetsY]), tonumber(_tD[KcapInsetsWidth]),
			tonumber(_tD[KcapInsetsHeight]))
	end
	local pView = nil
	-- 如果开启缓存池控制的话，使用缓存池中的控件
--	if(MViewPool:getInstance():isReady()) then
--		if(tT.scale9) then
--			pView = MViewPool:getInstance():pop(POOL_NAME_IMAGENINE, function (  )
--				return MUI.MImage.new(_tD[KfileName], tT)
--			end, _tD[KfileName], tT)
--		else
--			pView = MViewPool:getInstance():pop(POOL_NAME_IMAGE, function (  )
--				return MUI.MImage.new(_tD[KfileName], tT)
--			end, _tD[KfileName], tT)
--		end
--	end
    if(tT.scale9) then
		pView = MViewPool:getInstance():pop(MPoolObjectType.IMAGENINE)
	else
		pView = MViewPool:getInstance():pop(MPoolObjectType.IMAGE)
	end

    if (pView) then
        pView:__resetOptions(false, _tD[KfileName], tT)
    else
        pView = MUI.MImage.new(_tD[KfileName], tT)
    end

	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	if(tT.scale9) then
		pView:setLayoutSize(tonumber(_tD[Kscale9Width]), tonumber(_tD[Kscale9Height]))
	end

	return pView
end
-- 处理复选框控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewCheckBox( _tD )
	local tT = {}
	-- 这里没有去自定义参数，所有使用了特殊指向
	-- KfrontCross为选中图片，KbackGroundBox为未选中的图片
	tT.off = _tD[KbackGroundBox]
	tT.on = _tD[KfrontCross]
	local pView = MUI.MCheckBoxButton.new(tT)
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	pView:setButtonSelected(_tD[KselectedState] == "true")

	return pView
end
-- 处理进度条控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewLoadingBar( _tD )
	local tT = {}
	tT.scale9 = _tD[Kscale9Enable] == "true"
	if(tT.scale9) then
		tT.capInsets = cc.rect(tonumber(_tD[KcapInsetsX]),
			tonumber(_tD[KcapInsetsY]), tonumber(_tD[KcapInsetsWidth]),
			tonumber(_tD[KcapInsetsHeight]))
	end
	tT.image = _tD[Ktexture]
	tT.viewRect = cc.rect(0, 0, tonumber(_tD[Kwidth]),
		tonumber(_tD[Kheight]))
	local pView = MUI.MLoadingBar.new(tT)
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	pView:setPercent(tonumber(_tD[Kpercent]))
	pView:setDirection(tonumber(_tD[Kdirection]))
	return pView
end
-- 处理拖动条控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewSlider( _tD )
	local tT = {}
	tT.scale9 = _tD[Kscale9Enable] == "true"
	local images = {button=_tD[KballNormal],
		bar=_tD[KbarFileName], barfg=_tD[KprogressBar]}
	local pView = MUI.MSlider.new(display.LEFT_TO_RIGHT, images, tT)
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	--设置初始化进度值
	pView:setSliderValue(tonumber(_tD[Kpercent]))
	return pView
end
-- 处理输入框控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewInput( _tD )
	-- 暂时不做处理
	local tT = {}
	tT.image="ui/daitu.png"
	tT.UIInputType = 1 --这里默认解析第一种（EditBox）
	tT.font = _tD[KfontName]
	tT.fontSize = _tD[KfontSize]
	tT.fontColor = cc.c3b(_tD[KcolorR] or 255, _tD[KcolorG] or 255, _tD[KcolorB] or 255)
	tT.maxLength = _tD[KmaxLength]
	tT.passwordEnable = _tD[KpasswordEnable] == "true"
	tT.text = _tD[Ktext]
	tT.size = cc.size(_tD[Kwidth] or 200, _tD[Kheight] or 50)

	local pView = MUI.MInput.new(tT)
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	return pView
end
-- 处理列表控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewScrollLayer( _tD )
	local tT = {}
	tT.direction = tonumber(_tD[Kdirection])
	tT.viewRect = cc.rect(0, 0, tonumber(_tD[Kwidth] or 0),
		tonumber(_tD[Kheight] or 0))
	local pView = MUI.MScrollLayer.new(tT)
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	pView:setClipping(_tD[KclipAble] == "true")
	pView:setBounceable(_tD[KbounceEnable] == "true")
	if(_tD[KbackGroundImage]) then
		-- 如果背景图使用9宫格的话,记录拉伸的数值
		if(_tD[KbackGroundScale9Enable]) then
			tT.bgScale9 = _tD[KbackGroundScale9Enable] == "true"
			if(tT.bgScale9) then
				tT.capInsets = cc.rect(tonumber(_tD[KcapInsetsX]),
					tonumber(_tD[KcapInsetsY]),
					tonumber(_tD[KcapInsetsWidth]),
					tonumber(_tD[KcapInsetsHeight]))
			end
		end
		tT.bg = _tD[KbackGroundImage]
		pView:addBgIf(tT)
	end
	return pView
end
-- 处理列表控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewListView( _tD )
	local tT = {}
	tT.direction = tonumber(_tD[Kdirection])
	tT.itemMargin = tonumber(_tD[KitemMargin])
	local pView = MUI.MListView.new(tT)
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	pView:setClipping(_tD[KclipAble] == "true")
	pView:setBounceable(_tD[KbounceEnable] == "true")
	if(_tD[KbackGroundImage]) then
		local tT1 = {}
		-- 如果背景图使用9宫格的话,记录拉伸的数值
		if(_tD[KbackGroundScale9Enable]) then
			tT1.scale9 = _tD[KbackGroundScale9Enable] == "true"
			if(tT1.scale9) then
				tT1.capInsets = cc.rect(tonumber(_tD[KcapInsetsX]),
					tonumber(_tD[KcapInsetsY]),
					tonumber(_tD[KcapInsetsWidth]),
					tonumber(_tD[KcapInsetsHeight]))
			end
		end
		pView:setBackgroundImage(_tD[KbackGroundImage], tT1)
	end
	return pView
end
-- 处理分页列表控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewPageView( _tD )
	local pView = MUI.MPageView.new()
	
	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)
	--------处理特殊参数--------
	pView:setClipping(_tD[KclipAble] == "true")
	if(_tD[KbackGroundImage]) then
		local tT1 = {}
		-- 如果背景图使用9宫格的话,记录拉伸的数值
		if(_tD[KbackGroundScale9Enable]) then
			tT1.scale9 = _tD[KbackGroundScale9Enable] == "true"
			if(tT1.scale9) then
				tT1.capInsets = cc.rect(tonumber(_tD[KcapInsetsX]),
					tonumber(_tD[KcapInsetsY]),
					tonumber(_tD[KcapInsetsWidth]),
					tonumber(_tD[KcapInsetsHeight]))
			end
		end
		pView:setBackgroundImage(_tD[KbackGroundImage], tT1)
	end
	return pView
end
-- 处理数字控件的内容
-- _tD(table): 布局中的参数列表
function MViewReader:__handleNewLabelAtlas( _tD )
	local tT = {}
	tT.text = _tD[KstringValue] or ""
	tT.png = _tD[KcharMapFile]
	tT.pngw = tonumber(_tD[KitemWidth] or 0)
	tT.pngh = tonumber(_tD[KitemHeight] or 0)
	-- 获取字符的ascii码值
	tT.scm = string.byte(_tD[KstartCharMap] or "0")
	local pView = MUI.MLabelAtlas.new(tT)

	--------处理基础参数--------
	self:__doSharedParams(_tD, pView)

	return pView
end
