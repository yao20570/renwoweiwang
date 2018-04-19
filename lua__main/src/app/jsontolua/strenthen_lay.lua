local tTable = {}

tTable["texturesPng"] = {"ui/p1_commonse2.plist","ui/p1_commonse1.plist","ui/p2_commmon1_sep.plist"}
tTable["index_1"] = {
strenthen_lay={classname="Panel",name="strenthen_lay",parName="root",childCount="4",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="324",width="640",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="401",anchorPointX="0",anchorPointY="0",},
}
tTable["index_2"] = {
lay_info={classname="Panel",name="lay_info",parName="strenthen_lay",childCount="6",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="640",capInsetsY="33",height="174",width="640",x="0",y="150",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="472",anchorPointX="0",anchorPointY="0",},
lay_operate={classname="Panel",name="lay_operate",parName="strenthen_lay",childCount="3",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="130",width="640",x="0",y="20",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="404",anchorPointX="0",anchorPointY="0",},
lb_full={classname="Label",name="lb_full",parName="strenthen_lay",ZOrder="2",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="装备已达到最大强化等级",fontName="微软雅黑",fontSize="20",height="27",width="220",x="320",y="70",visible="false",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="407",anchorPointX="0.5",anchorPointY="0.5",},
lay_bg={classname="Panel",name="lay_bg",parName="strenthen_lay",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="true",backGroundImage="#v2_img_jinduyanjiudi.png",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="640",capInsetsY="33",height="174",width="640",x="0",y="150",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="402",anchorPointX="0",anchorPointY="0",},
}
tTable["index_3"] = {
lay_strengh_lv={classname="Panel",name="lay_strengh_lv",parName="lay_info",childCount="4",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="28",width="320",x="0",y="116",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="473",anchorPointX="0",anchorPointY="0",},
lay_attr={classname="Panel",name="lay_attr",parName="lay_info",childCount="5",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="28",width="320",x="0",y="67",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="478",anchorPointX="0",anchorPointY="0",},
lay_cost={classname="Panel",name="lay_cost",parName="lay_info",childCount="1",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="28",width="320",x="0",y="20",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="484",anchorPointX="0",anchorPointY="0",},
lay_strengthstone={classname="Panel",name="lay_strengthstone",parName="lay_info",childCount="2",ZOrder="2",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="174",width="320",x="320",y="0",visible="false",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="486",anchorPointX="0",anchorPointY="0",},
lay_blessstone={classname="Panel",name="lay_blessstone",parName="lay_info",childCount="5",ZOrder="2",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="174",width="320",x="320",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="489",anchorPointX="0",anchorPointY="0",},
img_line={classname="ImageView",name="img_line",parName="lay_info",ZOrder="3",fileName="#v1_line_blue2a.png",scale9Enable="true",scale9Height="155",scale9Width="2",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="1",capInsetsY="12",height="155",width="2",x="320",y="86",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="408",anchorPointX="0.5",anchorPointY="0.5",},
lay_btn={classname="Panel",name="lay_btn",parName="lay_operate",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="62",width="155",x="243",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="403",anchorPointX="0",anchorPointY="0",},
lb_vip_add={classname="Label",name="lb_vip_add",parName="lay_operate",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="(含vip5+10%成功率)",fontName="微软雅黑",fontSize="16",height="21",width="149",x="320",y="75",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="405",anchorPointX="0.5",anchorPointY="0.5",},
lb_success={classname="Label",name="lb_success",parName="lay_operate",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="强化总成功率: 100%",fontName="微软雅黑",fontSize="20",height="27",width="185",x="320",y="100",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="406",anchorPointX="0.5",anchorPointY="0.5",},
}
tTable["index_4"] = {
txt_lv={classname="Label",name="txt_lv",parName="lay_strengh_lv",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="强化等级：",fontName="微软雅黑",fontSize="20",height="27",width="100",x="40",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="474",anchorPointX="0",anchorPointY="0.4999999",},
lb_lv_b={classname="Label",name="lb_lv_b",parName="lay_strengh_lv",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="12",fontName="微软雅黑",fontSize="20",height="27",width="24",x="142",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="475",anchorPointX="0",anchorPointY="0.5",},
img_arrow_1={classname="ImageView",name="img_arrow_1",parName="lay_strengh_lv",ZOrder="0",fileName="#v1_img_xiangshangjiantou.png",scale9Enable="false",scale9Height="17",scale9Width="12",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="17",width="12",x="192",y="12",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="90",tag="476",anchorPointX="0.5",anchorPointY="0.5",},
lb_lv_a={classname="Label",name="lb_lv_a",parName="lay_strengh_lv",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="13",fontName="微软雅黑",fontSize="20",height="27",width="24",x="211",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="477",anchorPointX="0",anchorPointY="0.5",},
txt_attr={classname="Label",name="txt_attr",parName="lay_attr",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="攻击：",fontName="微软雅黑",fontSize="20",height="27",width="60",x="40",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="479",anchorPointX="0",anchorPointY="0.4999999",},
lb_attr_value_b={classname="Label",name="lb_attr_value_b",parName="lay_attr",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="12",fontName="微软雅黑",fontSize="20",height="27",width="24",x="142",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="480",anchorPointX="0",anchorPointY="0.5",},
img_arrow_2={classname="ImageView",name="img_arrow_2",parName="lay_attr",ZOrder="0",fileName="#v1_img_xiangshangjiantou.png",scale9Enable="false",scale9Height="17",scale9Width="12",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="17",width="12",x="192",y="12",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="90",tag="481",anchorPointX="0.5",anchorPointY="0.5",},
lb_attr_value_a={classname="Label",name="lb_attr_value_a",parName="lay_attr",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="12",fontName="微软雅黑",fontSize="20",height="27",width="24",x="211",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="482",anchorPointX="0",anchorPointY="0.5",},
img_arrow_3={classname="ImageView",name="img_arrow_3",parName="lay_attr",ZOrder="0",fileName="#v1_img_xiangshangjiantou.png",scale9Enable="false",scale9Height="17",scale9Width="12",capInsetsHeight="1",capInsetsWidth="1",capInsetsX="0",capInsetsY="0",height="17",width="12",x="270",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="483",anchorPointX="0.5",anchorPointY="0.5",},
txt_cost={classname="Label",name="txt_cost",parName="lay_cost",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="消耗：",fontName="微软雅黑",fontSize="20",height="27",width="60",x="40",y="14",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="485",anchorPointX="0",anchorPointY="0.4999999",},
txt_cost_1={classname="Label",name="txt_cost_1",parName="lay_strengthstone",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="消耗：",fontName="微软雅黑",fontSize="20",height="27",width="60",x="30",y="130",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="487",anchorPointX="0",anchorPointY="0.5",},
lay_stone_1={classname="Panel",name="lay_stone_1",parName="lay_strengthstone",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="86",width="86",x="130",y="39",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="488",anchorPointX="0",anchorPointY="0",},
lay_stone_2={classname="Panel",name="lay_stone_2",parName="lay_blessstone",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="86",width="86",x="15",y="78",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="490",anchorPointX="0",anchorPointY="0",},
lb_name={classname="Label",name="lb_name",parName="lay_blessstone",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="祝福石",fontName="微软雅黑",fontSize="22",height="30",width="66",x="112",y="146",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="491",anchorPointX="0",anchorPointY="0.5",},
lb_des={classname="Label",name="lb_des",parName="lay_blessstone",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="58",areaWidth="200",hAlignment="0",vAlignment="0",text="描述",fontName="微软雅黑",fontSize="18",height="58",width="200",x="112",y="102",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="492",anchorPointX="0",anchorPointY="0.5",},
lay_select_stone={classname="Panel",name="lay_select_stone",parName="lay_blessstone",childCount="4",ZOrder="2",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="70",width="320",x="0",y="0",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="504",anchorPointX="0",anchorPointY="0",},
lb_rate_full_tip={classname="Label",name="lb_rate_full_tip",parName="lay_blessstone",ZOrder="0",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="成功率已满，无需使用祝福石",fontName="微软雅黑",fontSize="16",height="21",width="208",x="160",y="39",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="505",anchorPointX="0.5",anchorPointY="0.5",},
}
tTable["index_5"] = {
lay_slider={classname="Panel",name="lay_slider",parName="lay_select_stone",ZOrder="2",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="18",width="188",x="70",y="34",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="493",anchorPointX="0",anchorPointY="0",},
lb_use_stone={classname="Label",name="lb_use_stone",parName="lay_select_stone",ZOrder="1",colorB="255",colorG="255",colorR="255",areaHeight="0",areaWidth="0",hAlignment="0",vAlignment="0",text="Text Label",fontName="微软雅黑",fontSize="16",height="21",width="77",x="164",y="16",visible="true",touchAble="false",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="494",anchorPointX="0.5",anchorPointY="0.5",},
lay_minus={classname="Panel",name="lay_minus",parName="lay_select_stone",ZOrder="1",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="35",width="35",x="9",y="26",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="495",anchorPointX="0",anchorPointY="0",},
lay_add={classname="Panel",name="lay_add",parName="lay_select_stone",ZOrder="0",useMergedTexture="false",clipAble="false",backGroundScale9Enable="false",height="35",width="35",x="280",y="26",visible="true",touchAble="true",flipX="false",scaleX="1",scaleY="1",opacity="255",rotation="0",tag="496",anchorPointX="0",anchorPointY="0",},
}

return tTable