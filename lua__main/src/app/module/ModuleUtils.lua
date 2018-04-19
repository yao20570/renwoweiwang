-----------------------------------------------------
-- author: wangxs
-- updatetime: 2017-04-27 11:53:00 星期四
-- Description:  功能模块管理类
-----------------------------------------------------

--物品item类型
TypeItemInfoSize = {
    L             	=       1,          --570x130
    M            	=       2,          --532x100
}

--任务item类型
TypeTaskItemSize = {
    N               =       1,          --600x130--支线任务--限时任务
    H               =       2,          --600x139-- 主线任务
}

local DlgCostTip = require("app.module.DlgCostTip")
local DlgItemInfo = require("app.module.DlgItemInfo")
local DlgItemTips = require("app.module.DlgItemTips")
local DlgUseStuff = require("app.module.DlgUseStuff")
local DlgTaskDetails = require("app.module.DlgTaskDetails")
local DlgRankPlayerInfo = require("app.module.DlgRankPlayerInfo")
local DlgGetTaskPrize = require("app.module.DlgGetTaskPrize")
local DlgEquipDecomTip = require("app.module.DlgEquipDecomTip")
local DlgAlert = require("app.common.dialog.DlgAlert")
local DlgGetPrizeProgress = require("app.module.DlgGetPrizeProgress")
local RebuildRewardLayer = require("app.layer.world.RebuildRewardLayer")
local DlgMansionItemTip = require("app.module.DlgMansionItemTip")
local DlgBuyArenaChallenge = require("app.module.DlgBuyArenaChallenge")
local DlgBuyArenaShop = require("app.module.DlgBuyArenaShop")
local DlgArenaPlayerInfo = require("app.module.DlgArenaPlayerInfo")
local DlgInputNum = require("app.module.DlgInputNum")
local DlgUseStuffByTip = require("app.module.DlgUseStuffByTip")
local DlgUseArenatToken = require("app.module.DlgUseArenatToken")
local DlgUnlockModel = require("app.layer.newguide.DlgUnlockModel")

--打开购买对话框
--_tLabel：文本数组 
--_nNeedGold 需要金币数
-- _handler 购买回调
--_nType : 默认为 0 (添加是否花费前缀) 1直接显示传入 文本
--_bShowDlg: 如果是true话则永远弹出消费提示并隐藏复选框层, 默认为false
--_costId: 货币类型, 目前只针对珍宝阁里银币的特殊处理
--_other: 其他信息
function showBuyDlg( _tLabel, _nNeedGold, _handler, _nType, _bShowDlg, _costId, _other)
    local value = nil
    local nTipType = nil
    if _other and _other.nTipType == 2 then --私聊花费
        nTipType = _other.nTipType
        value = getSettingInfo("PChatGoldTip")
    else
        value = getSettingInfo("GoldCostTip")
    end
    if value == "1" or _bShowDlg then
    	local pDlg, bNew = getDlgByType(e_dlg_index.costtip)
        if not pDlg then
        	pDlg = DlgCostTip.new(nTipType)        
        end
        pDlg:showDlg(bNew)    
        pDlg:setNeedCost(tonumber(_nNeedGold or 0), _costId)
        pDlg:setRichTextTip(_tLabel,_nType or 0)	
        pDlg:setCostHandler(_handler)
        if _bShowDlg then
            pDlg:hideCheckBox(true)
        end
        if _costId then
            pDlg:setCostId(_costId)
        end
        return pDlg
    else
        if Player:getPlayerInfo().nMoney >= tonumber(_nNeedGold or 0) then
            _handler()
        else
            TOAST(getConvertedStr(1, 10160))--黄金不足        
            local pDlg, bNew = getDlgByType(e_dlg_index.alert)
            if(not pDlg) then
                pDlg = DlgAlert.new(e_dlg_index.alert)
            end
            pDlg:setTitle(getConvertedStr(3, 10091))
            pDlg:setContent(getConvertedStr(6, 10081))
            local btn = pDlg:getRightButton()
            btn:updateBtnText(getConvertedStr(6, 10291))
            btn:updateBtnType(TypeCommonBtn.L_YELLOW)
            pDlg:setRightHandler(function (  )            
                local tObject = {}
                tObject.nType = e_dlg_index.dlgrecharge --dlg类型
                sendMsg(ghd_show_dlg_by_type,tObject)   
            end)
            pDlg:showDlg(bNew)   
            return pDlg     
        end
    end
end

--打开物品显示对话框
--_itemid 物品的配表id
function showItemInfoDlg( _itemid , _type ,_data)
    _type = _type or 1
    if _type == 1 then
        -- body
        local pDlg, bNew = getDlgByType(e_dlg_index.iteminfo)
        if not pDlg then
            pDlg = DlgItemInfo.new()            
        end
        pDlg:showDlg(bNew)      
        pDlg:setItemDataById(_itemid)
        return pDlg
    elseif _type == 2 then
        local pDlg, bNew = getDlgByType(e_dlg_index.iteminfo)
        if not pDlg then
            pDlg = DlgItemTips.new() 
        end
        pDlg:showDlg(bNew)      
        pDlg:setItemDataById(_itemid, _data)
        return pDlg
    end 
end


--打开物品批量操作对话框
--_itemid 物品的配表id
--_tNeedValue 资源需求奖励列表
--_resId 对应的资源id
function showUseItemDlg( _itemid , _tNeedValue, _resId)
    -- body
    local itemdata = Player:getBagInfo():getItemDataById(_itemid)
    if itemdata then
        local nType = 0
        local nBatch = 0
        if itemdata.nCanUse == 1 then
            nType = 1
            nBatch = tonumber(getDisplayParam("batchUse"))
        else
            if itemdata.sSell then
                nType = 3
                nBatch = tonumber(getDisplayParam("batchSell"))
            end
        end
          

        if Player:getBagInfo():isItemCanUse(_itemid) then
            if (nType == 1 or nType == 3 ) then
                if itemdata.nCt >= nBatch and itemdata.nBatchUseNum > 0 then                
                    local pDlg, bNew = getDlgByType(e_dlg_index.useitems)
                    if not pDlg then
                        pDlg = DlgUseStuff.new()           
                    end
                    pDlg:showDlg(bNew) 
                    pDlg:setItemDataById(_itemid,_tNeedValue,_resId)
                else
                    local tObject = {}
                    tObject.useId = itemdata.sTid
                    tObject.useNum = 1
                    tObject.type = nType--正常使用
                    sendMsg(ghd_useItems_msg,tObject)                         
                end              
            end              
        else
            TOAST(string.format(getConvertedStr(6, 10532), itemdata.sName))
        end          
    end
end
--显示任务详情
function showTaskDetails( _ttaskid )
    -- body
    local pDlg, bNew = getDlgByType(e_dlg_index.taskdetails)
    if not pDlg then
        pDlg = DlgTaskDetails.new()                
    end
    pDlg:showDlg(bNew) 
    pDlg:setTaskId(_ttaskid)
end
--显示玩家信息
function showRankPlayerInfo( tdata )
    -- body
    local pDlg, bNew = getDlgByType(e_dlg_index.dlgrankplayerinfo)
    if not pDlg then
        pDlg = DlgRankPlayerInfo.new()                
    end
    pDlg:showDlg(bNew)     
    pDlg:setCurData(tdata)
end

--领取任务奖励对话框
function showDlgTaskPrize( _rootlayer, _nTaskId )
    if B_GUIDE_LOG then
        myprint("B_GUIDE_LOG 展示任务奖励面板咯 !!!!!!!!!! ", _nTaskId)
    end
    local function func(  )
        local tdata = Player:getPlayerTaskInfo():getTaskDataById( _nTaskId )
        if not tdata then
            --显示下一条顺序显示
            showNextSequenceFunc(e_show_seq.taskrward)
            return
        end

        if B_GUIDE_LOG then
            myprint("B_GUIDE_LOG 延迟显示任务奖励面板成功  任务id:  ", _nTaskId)
        end
        local pDlg, bNew = getDlgByType(e_dlg_index.gettaskprize)
        if not pDlg then
            pDlg = DlgGetTaskPrize.new()                
        end
        pDlg:showDlg(bNew, _rootlayer) 
        pDlg:setTaskData(tdata)
        --播放音效
        Sounds.playEffect(Sounds.Effect.unlock)
    end
    --加入顺序显示        
    showSequenceFunc(e_show_seq.taskrward, func, _nTaskId)
end

--弹出重建面板对话框
function showDlgReBuildReward( _rootlayer )
    print("rebuild---")
    if B_GUIDE_LOG then
        myprint("B_GUIDE_LOG showDlgReBuildReward")
    end
    local function func(  )
        if B_GUIDE_LOG then
            myprint("B_GUIDE_LOG 延迟显示重建奖励面板成功",_rootlayer)
        end
        local pDlg, bNew = getDlgByType(e_dlg_index.rebuildreward)
        if not pDlg then
            pDlg = RebuildRewardLayer.new()                
        end
        pDlg:showDlg(bNew, _rootlayer) 
    end
    --加入顺序显示
    showSequenceFunc(e_show_seq.rebuildreward, func)
end

--装备分解提示 _equipId,装备ID
function showDlgEquipDecomTip( _equipId, _handler, _sUuid )
    -- body
    local nLv = tonumber(getEquipInitParam("decomposeLv"))
    if Player:getPlayerInfo().nLv < nLv then
        TOAST(getTipsByIndex(10075))
        return
    end
    local pDlg, bNew = getDlgByType(e_dlg_index.dlgequipdecomtip)
    if not pDlg then
        pDlg = DlgEquipDecomTip.new()                
    end
    pDlg:showDlg(bNew, _rootlayer) 
    pDlg:setEquipID(_equipId, _sUuid)
    pDlg:setRightHandler(_handler)    
end
--显示奖励进度
function showDlgPrizeProgress( pScoreBox, nhandler )
    -- body
    if (not pScoreBox) then
        return
    end
    --dump(pScoreBox, "pScoreBox", 100)
    local pDlg, bNew = getDlgByType(e_dlg_index.taskprizeprogress)
    if not pDlg then
        pDlg = DlgGetPrizeProgress.new(pScoreBox, nhandler)                
    end
    pDlg:showDlg(bNew)    
end

--显示功能解锁框教程
function showDlgUnlockModelByGuide( nOpenId, nGuideId)
    if not nOpenId then
        return  
    end
    if B_GUIDE_LOG then
        myprint("B_GUIDE_LOG showDlgUnlockModelByGuide !!!!!!!!!! ", nOpenId)
    end
    local function func(  )
        --显示解锁教程
        closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
        closeDlgByType(e_dlg_index.dlgchat)
        sendMsg(ghd_home_show_base_or_world, 1)--主城或世界跳转    
        --打开功能解锁框
        local pDlg, bNew = getDlgByType(e_dlg_index.unlockmodel)
        if not pDlg then
            pDlg = DlgUnlockModel.new()                
        end
        pDlg:setData(nOpenId, nGuideId)
        pDlg:showDlg(bNew) 
        --播放音效
        Sounds.playEffect(Sounds.Effect.unlock)
    end
    --加入顺序显示        
    showSequenceFunc(e_show_seq.unlockmodel, func)
end

--关闭所有邮件
function closeMailDetail( )
    closeDlgByType(e_dlg_index.maildetailsys,false)
    closeDlgByType(e_dlg_index.maildetailcitywar,false)
    closeDlgByType(e_dlg_index.maildetailcountrywar,false)
    closeDlgByType(e_dlg_index.maildetailwildarmy,false)
    closeDlgByType(e_dlg_index.maildetailcollect,false)
    closeDlgByType(e_dlg_index.maildetailmine,false)
    closeDlgByType(e_dlg_index.maildetaildetect,false)
    closeDlgByType(e_dlg_index.maildetailgarrison,false)
    closeDlgByType(e_dlg_index.maildetaillose,false)
    closeDlgByType(e_dlg_index.maildetaildetectme,false)
end

--创建活动新的标识
function createActivityNew( pParent, nScale )
    local pImgNewBg = pParent:findViewByName("img_activity_new_bg")
    if pImgNewBg then
        return
    end
    local pTxtNew = pParent:findViewByName("txt_activity_new")
    if pTxtNew then
        return
    end

    local pImgNewBg =  MUI.MImage.new("#v1_img_xinpin.png")
    pParent:addView(pImgNewBg, 99)
    pImgNewBg:setName("img_activity_new_bg")
    if nScale then
        pImgNewBg:setScale(nScale)
    end

    
    local pTxtNew = MUI.MLabel.new({text = getConvertedStr(6, 10313), size = 20})
    pTxtNew:setRotation(-45)
    pParent:addView(pTxtNew, 100)
    pTxtNew:setName("txt_activity_new")

    --设置位置
    local pSize = pParent:getContentSize()
    local nBgWidth = pImgNewBg:getContentSize().width * nScale
    local nBgHeight = pImgNewBg:getContentSize().height * nScale
    pImgNewBg:setPosition(nBgWidth/2, pSize.height - nBgHeight/2)
    local nTxtWidth = pTxtNew:getContentSize().width
    local nTxtHeight = pTxtNew:getContentSize().height
    local nX, nY = pImgNewBg:getPosition()
    pTxtNew:setPosition(nX - nBgWidth/5, nY + nBgHeight/4)
end

--显示或隐藏活动新的标识
function showActivityNewVisible( pParent, bIsShow, nScale )
    local pImgNewBg = pParent:findViewByName("img_activity_new_bg")
    local pTxtNew = pParent:findViewByName("txt_activity_new")
    if not pImgNewBg or not pTxtNew then
        if bIsShow == true then
            createActivityNew(pParent, nScale)
        else
            return
        end
    end

    local pImgNewBg = pParent:findViewByName("img_activity_new_bg")
    if pImgNewBg then
        pImgNewBg:setVisible(bIsShow)
    end
    local pTxtNew = pParent:findViewByName("txt_activity_new")
    if pTxtNew then
        pTxtNew:setVisible(bIsShow)
    end
end

--显示登坛拜将物品购买提示
function showMansionTip(pData, handler)
    local tActData = Player:getActById(e_id_activity.heromansion)
    if not pData or not tActData then
        return
    end
    local pDlg, bNew = getDlgByType(e_dlg_index.mansionitemtip)
    if not pDlg then
        pDlg = DlgMansionItemTip.new()                
    end    
    pDlg:showDlg(bNew, _rootlayer) 
    pDlg:setRightHandler(handler)  
    pDlg:setCurData(pData)

end

--弹出触发礼包id (已废弃)
function showDlgTriggerGift( nPid, _rootlayer )
    --不存在就弹出
    if not getDlgByType(e_show_seq.triggergift) then
        --主动弹出界面
        local function func(  )
            --存在
            if Player:getTriggerGiftData():getPlayTriGiftRes(nPid) then
                if B_GUIDE_LOG then
                    myprint("B_GUIDE_LOG 延迟显示触发礼包界面成功")
                end

                local DlgTriggerGift = require("app.layer.triggergift.DlgTriggerGift")
                local pDlg, bNew = getDlgByType(e_dlg_index.triggergift)
                if not pDlg then
                    pDlg = DlgTriggerGift.new()
                end
                pDlg:setData(nPid)
                pDlg:showDlg(bNew, _rootlayer)
            else
                showNextSequenceFunc(e_show_seq.triggergift)
            end
        end
        --加入顺序显示
        showSequenceFunc(e_show_seq.triggergift , func)
    end
end

--弹出触发礼包
function openDlgTriggerGift( nPid, nGid, _rootlayer )
    --不存在就弹出
    if not getDlgByType(e_show_seq.triggergift) then
        --主动弹出界面
        local function func(  )
            --存在
            if Player:getTriggerGiftData():getPlayTpack(nPid, nGid) then
                if B_GUIDE_LOG then
                    myprint("B_GUIDE_LOG 延迟显示触发礼包界面成功")
                end

                local DlgTriggerGift = require("app.layer.triggergift.DlgTriggerGift")
                local pDlg, bNew = getDlgByType(e_dlg_index.triggergift)
                if not pDlg then
                    pDlg = DlgTriggerGift.new()
                end
                pDlg:setData(nPid, nGid)
                pDlg:showDlg(bNew, _rootlayer)
            else
                showNextSequenceFunc(e_show_seq.triggergift)
            end
        end
        --加入顺序显示
        showSequenceFunc(e_show_seq.triggergift , func)
    end
end


--弹出抢夺红包界面
function showDlgRedPacket( tChatData )
    if not tChatData then
        return
    end
    if tChatData:getIsRedPacket() then--红包
        local nRpId = tChatData.nRpId
        local nRpT = tChatData.nRpt 
        local nChatDataId = tChatData.nId
        SocketManager:sendMsg("checkredpocket", {nRpId}, function ( __msg, __oldMsg )
            -- body
            if __msg.head.type == MsgType.checkredpocket.id then        --查看红包
                if __msg.head.state == SocketErrorType.success then
                    local pRPData = {}  
                    pRPData.nRpId = __oldMsg[1]
                    pRPData.pData = __msg.body  
                    pRPData.nChatID = tChatData.nSid
                    pRPData.tChatData = tChatData    
                    if __msg.body.get == 0 then         
                        local tObj = {}
                        tObj.nType = e_dlg_index.dlgredpocketopen
                        tObj.pData = pRPData
                        sendMsg(ghd_show_dlg_by_type,tObj)
                    else
                        local tObj = {}
                        tObj.nType = e_dlg_index.dlgredpocketcheck
                        tObj.pData = pRPData
                        sendMsg(ghd_show_dlg_by_type,tObj)  
                    end
                    tChatData.nRpt = __msg.body.get                    
                    sendMsg(ghd_refresh_redpocket_msg, nChatDataId)   --刷新数据 
                else
                    TOAST(SocketManager:getErrorStr(__msg.head.state))
                end
            end    
        end) 
    end  
end

function showRedPacketDetail(nRpId, nChatID, nPlayerId )
    -- body
    if not nRpId or not nChatID or not nPlayerId then
        return
    end
    SocketManager:sendMsg("checkredpocket", {nRpId, nChatID, nPlayerId}, function ( __msg, __oldMsg )
        -- body
        if __msg.head.type == MsgType.checkredpocket.id then        --查看红包
            if __msg.head.state == SocketErrorType.success then 
                --dump(__msg.body, "__msg.body", 100)
                local pRPData = {}  
                pRPData.nRpId = __oldMsg[1]
                pRPData.pData = __msg.body  
                pRPData.nChatID = __oldMsg[2]
                pRPData.nId = __oldMsg[3]
                local tObj = {}
                tObj.nType = e_dlg_index.dlgredpocketcheck
                tObj.pData = pRPData        
                sendMsg(ghd_show_dlg_by_type,tObj)          
                Player:updateRedPocketById(__oldMsg[1], __msg.body.get) 
            else            
                TOAST(SocketManager:getErrorStr(__msg.head.state))
            end
        end
        closeDlgByType(e_dlg_index.dlgredpocketopen)  
    end)        
end

--显示购买竞技场挑战次数
function showBuyArenaChallenge(  )
    -- body
    local pDlg, bNew = getDlgByType(e_dlg_index.arenabuychallenge)
    if not pDlg then
        pDlg = DlgBuyArenaChallenge.new()                
    end
    pDlg:showDlg(bNew) 
end

--显示竞技场物品购买
function showBuyArenaShop( _tData )
    -- body
    local pDlg, bNew = getDlgByType(e_dlg_index.dlgbuyarenashop)
    if not pDlg then
        pDlg = DlgBuyArenaShop.new()                
    end
    pDlg:setData(_tData)
    pDlg:showDlg(bNew)     
    
end

--显示竞技场玩家信息
function showArenaPlayerInfo( _tData )
    -- body
    local pDlg, bNew = getDlgByType(e_dlg_index.arenaplayerinfo)
    if not pDlg then
        pDlg = DlgArenaPlayerInfo.new()                
    end
    pDlg:setCurData(_tData)
    pDlg:showDlg(bNew)     
    
end
--数字键盘
function showNumInputBoard( _nSelect, _nMaxNum )
    -- body
    local pDlg, bNew = getDlgByType(e_dlg_index.inputnum)
    if not pDlg then
        pDlg = DlgInputNum.new(_nSelect, _nMaxNum) 
    else
        pDlg:setNumMaxLimit(_nSelect, _nMaxNum)                                 
    end    
    pDlg:showDlg(bNew)   
end

function showDlgUseStuffByTip( _itemid, _sTip )
    -- body
-- body
    local itemdata = Player:getBagInfo():getItemDataById(_itemid)
    if itemdata then
        local nType = 0
        local nBatch = 0
        if itemdata.nCanUse == 1 then
            nType = 1
            nBatch = tonumber(getDisplayParam("batchUse"))
        else
            if itemdata.sSell then
                nType = 3
                nBatch = tonumber(getDisplayParam("batchSell"))
            end
        end
        if Player:getBagInfo():isItemCanUse(_itemid) then
            if (nType == 1 or nType == 3 ) then
                if itemdata.nCt >= nBatch and itemdata.nBatchUseNum > 0 then                
                    local pDlg, bNew = getDlgByType(e_dlg_index.useitemsbytip)
                    if not pDlg then
                        pDlg = DlgUseStuffByTip.new()                
                    end
                    pDlg:setItemDataById(_itemid)
                    pDlg:setTip(_sTip)                    
                    pDlg:showDlg(bNew) 
                else
                    local tObject = {}
                    tObject.useId = itemdata.sTid
                    tObject.useNum = 1
                    tObject.type = nType--正常使用
                    sendMsg(ghd_useItems_msg,tObject)                         
                end              
            end              
        else
            TOAST(string.format(getConvertedStr(6, 10532), itemdata.sName))
        end          
    end    
end

function ShowDlgUseArenatToken()
    -- body
    local _itemid = e_id_item.arenaToken
    local itemdata = Player:getBagInfo():getItemDataById(_itemid)
    if itemdata then
        local nType = 0
        local nBatch = 0
        if itemdata.nCanUse == 1 then
            nType = 1
            nBatch = tonumber(getDisplayParam("batchUse"))
        else
            if itemdata.sSell then
                nType = 3
                nBatch = tonumber(getDisplayParam("batchSell"))
            end
        end
        local func_use = function(nItemID, nNum)
            SocketManager:sendMsg("useArenaToken", {nItemID,nNum}, function( __msg )
                -- body
                if __msg.head.state == SocketErrorType.success  then
                    --关闭使用物品对话框
                    closeDlgByType(e_dlg_index.usearenatoken)                              
                    TOAST(getConvertedStr(1, 10167))                    
                else        
                    TOAST(SocketManager:getErrorStr(__msg.head.state))
                end
            end)
        end
        if Player:getBagInfo():isItemCanUse(_itemid) then
            if (nType == 1 or nType == 3 ) then
                -- if itemdata.nCt >= nBatch and itemdata.nBatchUseNum > 0 then
                if itemdata.nCt > 0 then                
                    local pDlg, bNew = getDlgByType(e_dlg_index.usearenatoken)
                    if not pDlg then
                        pDlg = DlgUseArenatToken.new()                
                    end
                    pDlg:setItemDataById(_itemid)                                    
                    pDlg:showDlg(bNew) 
                    pDlg:setUseHander(func_use)
                -- else                    
                --     func_use(_itemid, 1)                                         
                end              
            end              
        else
            TOAST(string.format(getConvertedStr(6, 10532), itemdata.sName))
        end          
    end 

end