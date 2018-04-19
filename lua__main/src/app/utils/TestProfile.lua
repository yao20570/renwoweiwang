--region TestProfile.lua
--Author : wenzongyao
--Date   : 2017/11/23
--此文件由[BabeLua]插件自动生成

TestProfile = {}

function TestProfile:startTime()
    self.bIsStart = true
    self.iStartTime = socket:gettime()
    self.iPreTime = self.iStartTime    
    self.tTimeList = {}
end

function TestProfile:endTime()
    self.iEndTime = socket:gettime()

    for k, v in pairs(self.tTimeList) do        
        if type(v.data) == "table" then
            release_print("==========>", v.tag, string.format("%0.3f",v.time), unpack(v.data))
        else
            release_print("==========>", v.tag, string.format("%0.3f",v.time), v.data)
        end
    end
    release_print("==========>总耗", string.format("%0.3f", self.iEndTime - self.iStartTime))
    release_print("\n\n")
    self.bIsStart = false
end

function TestProfile:printTime(tag, data)
    if self.bIsStart ~= true then   
        return
    end
    self.iCurTime = socket:gettime()
    table.insert(self.tTimeList, {tag = tag, time = self.iCurTime - self.iPreTime, data = data})
    self.iPreTime = self.iCurTime
end

function TestProfile:printJumpFrame()
    if self.bIsStart then
        release_print("====================>TestProfile JumpFrame")
    end
end

--endregion
