--region 战争大厅列表子项
--Author : wenzongyao
--Date   : 2018/3/20
--此文件由[BabeLua]插件自动生成


local MCommonView = require("app.common.MCommonView")
local ItemWarHall = class("ItemWarHall", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemWarHall:ctor()
	-- body
	self:myInit()

	parseView("item_war_hall", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemWarHall",handler(self, self.onDestroy))
	
    --注册每秒刷新
    regUpdateControl(self, handler(self, self.refreshPerSec))
end

--析构方法
function ItemWarHall:onDestroy(  )
	unregUpdateControl(self)

end

--初始化参数
function ItemWarHall:myInit()
	self.tData = nil --数据
end

--解析布局回调事件
function ItemWarHall:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)	
    self:setupViews()
	self:onResume()
	-- self:updateViews()
end

function ItemWarHall:regMsgs()
    regMsg(self, gud_refresh_rankinfo, handler(self, self.onReqExamRankInfo))  
    regMsg(self, ghd_refresh_arena_rank_msg, handler(self, self.onReqArenaRankInfo))  
    regMsg(self, gud_refresh_arena_msg, handler(self, self.updateViews))  
    regMsg(self, gud_refresh_pass_kill_hero_msg, handler(self, self.updateViews))  
    regMsg(self, gud_refresh_hero, handler(self, self.updateViews))  
    regMsg(self, gud_refresh_activity, handler(self, self.updateViews))  
    regMsg(self, ghd_refresh_epw_award_state, handler(self, self.updateViews))  

end

function ItemWarHall:unregMsgs()
    unregMsg(self, gud_refresh_rankinfo)
    unregMsg(self, ghd_refresh_arena_rank_msg)
    unregMsg(self, gud_refresh_arena_msg)
    unregMsg(self, gud_refresh_pass_kill_hero_msg)
    unregMsg(self, gud_refresh_hero)
    unregMsg(self, gud_refresh_activity)
    unregMsg(self, ghd_refresh_epw_award_state)
end

function ItemWarHall:onResume()
    self:regMsgs()
    self:updateViews()
end

function ItemWarHall:onPause()
    self:unregMsgs()
end


--初始化控件
function ItemWarHall:setupViews()

	--ly
	self.pLyIcon = self:findViewByName("ly_icon")
	self.pLayRed = self:findViewByName("lay_red")
	-- self.pLyIcon:setBackgroundImage("sBgName")--改变背景图片
	
	--lb
	self.pLbTitle       = self:findViewByName("lb_title")
	self.pLbDesc1       = self:findViewByName("lb_desc1")
	self.pLbDesc2       = self:findViewByName("lb_desc2")
	self.pLbEnable      = self:findViewByName("lb_enable")
    setTextCCColor(self.pLbTitle,  _cc.yellow)
    setTextCCColor(self.pLbDesc2,  _cc.pwhite)
    setTextCCColor(self.pLbEnable, _cc.red)
    

	--img
	self.pImgBg         = self:findViewByName("img_bg")
	self.pImgIcon       = self:findViewByName("img_icon")

    --btn
    -- self.pLayBtnEnter   = self:findViewByName("ly_btn_enter")
    -- self.pLayBtnEnter:setVisible(false)
 --    self.pBtnEnter = getCommonButtonOfContainer(self.pLayBtnEnter, TypeCommonBtn.L_BLUE, getConvertedStr(10, 10202))
	-- self.pBtnEnter:onCommonBtnClicked(handler(self, self.onEnter)) 
 --    setMCommonBtnScale(self.pLayBtnEnter, self.pBtnEnter, 0.8)

    self:setViewTouched(true)
    self:setIsPressedNeedScale(false)
    self:onMViewClicked(handler(self,self.onEnter))

end

-- 修改控件内容或者是刷新控件数据
function ItemWarHall:updateViews(  )
    local tData = self.tData
	if not tData then
       return
	end

    if self.pTx1 then
        self.pTx1:removeSelf()
        self.pTx1 = nil
    end

    if self.pTx2 then
        self.pTx2:removeSelf()
        self.pTx2 = nil
    end

    --请求数据
    self.tData:reqData()

    --icon
    self.pImgBg:setCurrentImage("#" .. tData.sIcon .. ".png")

	--活动名称
	self.pLbTitle:setString(tData.sName)
	
	--描述 
    --有可能在setCurData()里通过self.tData:reqData()来设置
    local sDesc1 = tData:getDescript1()
	self.pLbDesc1:setString(sDesc1)
	
	--时间
    local sDesc2 = tData:getDescript2()
	self.pLbDesc2:setString(sDesc2)
        
	--解锁描述
    -- print("tData.sOpenTips:", tData.sOpenTips)
    self.pLbEnable:setString(tData.sOpenTips)
    --红点
    if tData:isShowRedTip() then
	    showRedTips(self.pLayRed, 0, 1, 1)
    else
        showRedTips(self.pLayRed, 0, 0, 1)
    end

    --是否解锁
    local bIsLock = tData:isLock()
    -- self.pLayBtnEnter:setVisible(not bIsLock)
    self.pLbEnable:setVisible(bIsLock)

    --新手教程
    if tData.nId == eWallHallType.Expedite then
        Player:getNewGuideMgr():setNewGuideFinger(self.pLyIcon, e_guide_finer.pkhero_enter)
    elseif tData.nId == eWallHallType.Arena then
        Player:getNewGuideMgr():setNewGuideFinger(self.pLyIcon, e_guide_finer.arena_enter)
    end
end

--
function ItemWarHall:refreshPerSec()
    local tData = self.tData
	if not tData then
       return
	end
	
    -- 刷新描述
    local sDesc2 = tData:getDescript2()
	self.pLbDesc2:setString(sDesc2)
end


--获得按钮回调
function ItemWarHall:onEnter()	
    if self.tData:isCanOpenDlg() then
        local tObject = {}
        tObject.nType = self.tData.nDlgIndex    
        sendMsg(ghd_show_dlg_by_type, tObject)
    else
        TOAST(self.tData.sOpenTips)
    end
     --新手教程
    if self.tData.nId == eWallHallType.Expedite then
        Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.pkhero_enter)
    elseif self.tData.nId == eWallHallType.Arena then
        Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.arena_enter)
    elseif self.tData.nId == eWallHallType.MingJie then
        local tData = Player:getActById(e_id_activity.mingjie)
        if tData then
            Player:removeFirstRedNums(tData)--移除第一次登录红点
            sendMsg(gud_refresh_activity) --通知刷新界面
        end   
    end
    
end

--设置数据 _data
function ItemWarHall:setCurData(_tData)
	if not _tData then
		return
	end

	self.tData = _tData

	self:updateViews()

end

-- 设置排名特效
-- _len:特效覆盖的字符串的长度
function ItemWarHall:createRankTx(_len)
    local tx1 = nil
    local tx2 = nil
    if _len < 3 then
        tx1 = createParitcle("tx/other/lizi_rrww_lszt_2_1.plist")
        tx2 = createParitcle("tx/other/lizi_rrww_lszt_2_3.plist")
    elseif _len < 5 then
        tx1 = createParitcle("tx/other/lizi_rrww_lszt_4_1.plist")
        tx2 = createParitcle("tx/other/lizi_rrww_lszt_4_3.plist")
    else             
        tx1 = createParitcle("tx/other/lizi_rrww_lszt_6_1.plist")
        tx2 = createParitcle("tx/other/lizi_rrww_lszt_6_3.plist")
    end
    return tx1, tx2
end

function ItemWarHall:removeRankTx(  )
    -- body
    if self.pTx1 then
        self.pTx1:removeSelf()
        self.pTx1 = nil
    end
    if self.pTx2 then
        self.pTx2:removeSelf()
        self.pTx2 = nil
    end    
end


-- 请求每日答题排行榜数据回调
function ItemWarHall:onReqExamRankInfo()        
    if self.tData.nId == eWallHallType.Exam then
        self:removeRankTx()
        local sDesc = ""
        local tFristRankInfo = Player:getExamFristRankInfo()

        -- dump(tFristRankInfo)
        if tFristRankInfo then
            sDesc = string.format("%s:%s;%s%s:%s;", getConvertedStr(10, 10203), _cc.white, parseCountryName(tFristRankInfo.c), tFristRankInfo.n, _cc.blue)            
            local len = string.getUTF8Length(tFristRankInfo.n)
            self.pTx1, self.pTx2 = self:createRankTx(len)
        else
            sDesc = string.format("%s:%s;%s:%s;", getConvertedStr(10, 10203), _cc.white, getConvertedStr(10, 10204), _cc.blue)
        end

        self.pLbDesc1:setString(getTextColorByConfigure(sDesc))

        local x, y = self.pLbDesc1:getPosition()
        if self.pTx1 then
            self.pTx1:setPosition(x + (self.pLbDesc1:getWidth() + 20 * 5) / 2, y - 10)
            self:addChild(self.pTx1)
        end
        if self.pTx2 then
            self.pTx2:setPosition(x + (self.pLbDesc1:getWidth() + 20 * 5)/2, y - 10)
            self:addChild(self.pTx2)
        end
    end
end

-- 请求竞技场排行榜数据回调
function ItemWarHall:onReqArenaRankInfo()        
    if self.tData.nId == eWallHallType.Arena then
        self:removeRankTx()
        local sDesc = ""
        local tFristRankInfo = nil
        local tArenaRankDatas = Player:getArenaData():getArenaRankDatas()
        if tArenaRankDatas then
            tFristRankInfo = tArenaRankDatas[1]
        end
        --dump(tFristRankInfo)
        if tFristRankInfo then
            sDesc = string.format("%s:%s;%s%s:%s;", getConvertedStr(10, 10205), _cc.white, parseCountryName(tFristRankInfo.country), tFristRankInfo.name, _cc.blue)
            local len = string.getUTF8Length(tFristRankInfo.name)
            self.pTx1, self.pTx2 = self:createRankTx(len)
        else
            sDesc = string.format("%s:%s;%s:%s;", getConvertedStr(10, 10205), _cc.white, getConvertedStr(10, 10204), _cc.blue)
        end
        self.pLbDesc1:setString(getTextColorByConfigure(sDesc))

        local x, y = self.pLbDesc1:getPosition()
        if self.pTx1 then
            self.pTx1:setPosition(x + (self.pLbDesc1:getWidth() + 20 * 7)/2, y - 10)
            self:addChild(self.pTx1)
        end
        if self.pTx2 then
            self.pTx2:setPosition(x + (self.pLbDesc1:getWidth() + 20 * 7)/2, y - 10)
            self:addChild(self.pTx2)
        end
    end
end

return ItemWarHall

--endregion
