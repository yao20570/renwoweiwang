-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-25 20:28:23 星期四
-- Description: 游戏设置界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local GameSettingLayer = require("app.layer.setting.GameSettingLayer")
local ItemSettingLayer = require("app.layer.setting.ItemSettingLayer")
local DlgGameSetting = class("DlgGameSetting", function()
	-- body
	return DlgBase.new(e_dlg_index.dlggamesetting)
end)

function DlgGameSetting:ctor(  )
	-- body
	self:myInit()
	--parseView("dlg_setting_main", handler(self, self.onParseViewCallback))
end

function DlgGameSetting:myInit(  )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10256))	
	self.tbtnGroup = {}
    self.bIsCostServer = isPChatCostServer()

	--self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgGameSetting",handler(self, self.onDlgGameSettingDestroy))
end

--解析布局回调事件
function DlgGameSetting:onParseViewCallback( pView )
	-- body

end

--初始化控件
function DlgGameSetting:setupViews(  )
	-- body	
end

-- 控件刷新
function DlgGameSetting:updateViews()
    -- body	
    if not self.pLayContent then
        

        -- 加入内容层	
        self.pLayContent = MUI.MFillLayer.new()
        self.pLayContent:setViewTouched(false)
        self.pLayContent:setLayoutSize(640, 1026)
        self:addContentView(self.pLayContent, false)

        local pLayTop = MUI.MLayer.new()
        pLayTop:setLayoutSize(640, 20)
        pLayTop:setPositionY(1046)
        self.pLayContent:addView(pLayTop)

        

        -- 游戏相关设置
        self.pGameAboutLayer = GameSettingLayer.new()
        self.pGameAboutLayer:setTitle(getConvertedStr(6, 10267))
        local tId = {1,2,3,4,5,6} 
        if self.bIsCostServer then
            table.insert(tId, 20)
        end
        for j = 1, #tId do
            local i = tId[j]
            if self:checkSettingItem(gameSetting_eachButtonKey[i]) then
                local templayer = ItemSettingLayer.new(gameSetting_eachButtonKey[i])
                templayer:setName(gameSetting_eachButtonKey[i])
                self.pGameAboutLayer:addSettingItem(templayer)
            end
        end

        -- 推送相关设置
        self.pPushAboutLayer = GameSettingLayer.new()
        self.pPushAboutLayer:setTitle(getConvertedStr(6, 10268))
        local tId = {7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22}
        for j = 1, #tId do
            local i = tId[j]
            if self:checkSettingItem(gameSetting_eachButtonKey[i]) then
                local templayer = ItemSettingLayer.new(gameSetting_eachButtonKey[i])
                templayer:setName(gameSetting_eachButtonKey[i])
                self.pPushAboutLayer:addSettingItem(templayer)
            end
        end
        -- print("self.pGameAboutLayer:getHeight()="..self.pGameAboutLayer:getHeight())
        -- print("self.pPushAboutLayer:getHeight()="..self.pPushAboutLayer:getHeight())

        -- 加入内容层	
        local tSize = { width = 600, height = 1020 }
        local tmplayer = nil
        if tSize.height >= self.pGameAboutLayer:getHeight() + self.pPushAboutLayer:getHeight() then
            local y = tSize.height - self.pGameAboutLayer:getHeight()
            self.pGameAboutLayer:setPosition(0, y)
            y = y - self.pPushAboutLayer:getHeight()
            self.pPushAboutLayer:setPosition(0, y)
            tmplayer = MUI.MFillLayer.new()
            tmplayer:setLayoutSize(tSize.width, tSize.height)
        else
            tmplayer = MUI.MScrollLayer.new( {
                viewRect = cc.rect(0,0,tSize.width,tSize.height),
                touchOnContent = true,
                direction = MUI.MScrollLayer.DIRECTION_VERTICAL
            } )
            tmplayer:setBounceable(false)
        end
        self.pLayContent:setPosition(20,20)
        self.pLayContent:addView(tmplayer, 10)
        
        -- 加入明细内容
        tmplayer:addView(self.pGameAboutLayer)
        tmplayer:addView(self.pPushAboutLayer)

        local pLayBottom = MUI.MLayer.new()
        pLayBottom:setLayoutSize(640, 20)
        pLayBottom:setPositionY(0)
        self.pLayContent:addView(pLayBottom)
    else
        self.pGameAboutLayer:updateViews()
        self.pPushAboutLayer:updateViews()
    end
end

--设置项添加控制
function DlgGameSetting:checkSettingItem( _skey )
	-- body
	local bresult = true
	if not _skey then
		return false
	elseif _skey == "UnderAttack" or _skey == "Investigated" then
		return false
	end
	return true
end

--析构方法
function DlgGameSetting:onDlgGameSettingDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgGameSetting:regMsgs(  )
	-- body
	--注册任务数据刷新新消息
	regMsg(self, ghd_no_desturb_status_change, handler(self, self.updateNoDesTrubSetting))	
end
--注销消息
function DlgGameSetting:unregMsgs( )
	-- body
	--注销任务数据刷新新消息
	unregMsg(self, ghd_no_desturb_status_change)
end

--暂停方法
function DlgGameSetting:onPause( )
	-- body	
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgGameSetting:onResume( _bReshow )
	-- body		
	self:updateViews()
	self:regMsgs()
end
--免打扰设置项
function DlgGameSetting:updateNoDesTrubSetting()
	-- body
	local pitem = self.pGameAboutLayer:findViewByName(gameSetting_eachButtonKey[1])
	if pitem then
		pitem:updateSetting()
	end
end
return DlgGameSetting