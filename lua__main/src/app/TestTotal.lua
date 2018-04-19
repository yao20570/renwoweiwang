--region Test.lua
--Author : User
--Date   : 2017/11/15
--此文件由[BabeLua]插件自动生成





local ______test_______ = true

testArmatureNames = {}


testArmatureUpdateCount = 0
testArmatureUpdateCount2 = 0
testArmatureUpdateCount3 = 0


testTimeType = {}
testTimeType.test1 = "test1"
testTimeType.test2 = "test2"
testTimeType.test3 = "test3"
testTimeType.test4 = "test4"


testTimeDatas = {}

--_timeType 使用testTimeType
function addTestTime(_timeType, _time, _isPrint)
    testTimeDatas[_timeType] = string.format("%0.0f", _time*1000)  
    
    if _isPrint ~= true then
        return
    end

    printProfile()
end

function printProfile(tag)
    local total = 0
    for k, v in pairs(testTimeDatas) do
        total = total + tonumber(v)
    end    

    --if total > 0.005 then
        local str = tag .. "->循环逻辑耗时:" .. total .. ", "
        for k, v in pairs(testTimeDatas) do
            str = str .. k .. ":" .. v .. ", "
        end

        str = str .. "所有:" .. testArmatureUpdateCount ..
                    ", 没显:" .. testArmatureUpdateCount2 ..
                    ", 界外:" .. testArmatureUpdateCount3 

        print(str)
    --end
end


testType = {}
testType.scheduler = "scheduler" --计划
testType.armBone = "armBone" --骨骼动画

-- 初始化测试数据
testDatas = {}
for k, v in pairs(testType) do
    local typeInfo = {}
    typeInfo.list = {}
    typeInfo.count = 0
    testDatas[v] = typeInfo
end


function printTestDataInfo()
    local str = "testDatas====> "
    for k, v in pairs(testDatas) do        
        str = str .. k .. ":" .. v.count .. ", "
    end
    print(str)
end

--_type string   类型testType的值 
--_data any      
function addTestData(_type, _data)
    if ______test_______ == false then
        return
    end

    local typeInfo = testDatas[_type]
    if typeInfo.list[_data] == nil then
        typeInfo.list[_data] = {debug.traceback("", 2)}
        typeInfo.count = typeInfo.count + 1
    else        
        print(debug.traceback("数据重复了", 2))
    end

    printTestDataInfo()

end

function delTestData(_type, _data)
    if ______test_______ == false then
        return
    end

    local typeInfo = testDatas[_type]
    if typeInfo.list[_data] ~= nil then
        typeInfo.list[_data] = nil
        typeInfo.count = typeInfo.count - 1
    end

    printTestDataInfo()
end

--测试节点,myui的不适用,因为重设了cleanup事件
function addTestDataNode(_type, _node, _name)
    if ______test_______ == false then
        return
    end
    _node.fileName = _name
    print("==>addTestDataNode", _name)
    _node:onNodeEvent("cleanup", function()
        local x = 1111
        print("==>delTestDataNode", _name)
        delTestData(_type, _node)
    end )

    addTestData(_type, _node)
end




--endregion
