print("再续前缘：自动工具加载。");

local zxqy_zidonggongju = {
    -- uid
    uid = UnitName("player") .. "-" .. GetRealmName(),
    -- 窗体宽度
    Windows_width = 500,
    -- 窗体高度
    Windows_height = 600,
    -- 记录需要计算高度的控件
    page_content_table = {},
    -- 定时器初始化值
    ds_hanhua = 0,
    -- 定时器初始化值
    ds_zidingyi = 0,
    -- 收人间隔初始化
    ds_shouren = 0,
    -- 自动保存初始化
    ds_savedkp = 0,
    -- 是否自动保存
    is_savedkp = 0,
    -- 是否开启收人
    is_kaishishouren = 0,
    -- 是否显示设置窗体
    is_show_windows = false,
    -- 临时等级,用于初始化
    tmp_dengji = 0,
    -- 保存字符串控件
    content_text_table = {},
    -- 下拉选项菜单
    select_option1 = {
        [1] = "所有",
        [2] = "加分",
        [3] = "减分",
        [4] = "装备",
        [5] = "非装备"
    },
    -- 配置项, 将会保存, 读取配置文件时会覆盖
    Option = {
        -- 屏蔽名单
        blacklist = {},
        -- 当前登录已邀请人员记录
        GongHuiYaoQingOk = {},
        -- 搜索间隔
        yq_jiange = 30,
        -- 初始化等级搜索
        yq_dengji = 5,
        -- 等级递增
        yq_dizeng = 2,
        -- 是否勾选密语收人入会
        is_shouren = 0,
        -- 密语内容如果为*则是所有密语都会收人入会
        shouren_miyu = "*",
        -- 是否开始自定义喊话
        is_zidingyi = 0,
        -- 自定义频道间隔时间
        zidingyi_jiangeshijian = 60,
        -- 自定义频道号
        zidingyi_pindao = 1,
        -- 自定义频道喊话内容
        zidingyi_pindao_neirong = "自定义频道喊话内容",
        -- 是否开始喊话
        is_hanhua = 0,
        -- 喊话间隔时间
        hanhua_jiangeshijian = 60,
        -- 喊话内容
        hanhua_pindao_neirong = "喊话内容"
    },
    -- 样式
    style = {
        input = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", -- 设置背景材质
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- 设置边框材质
            tile = true,
            tileSize = 16,
            edgeSize = 16, -- 设置材质的平铺和边框大小
            insets = {
                left = 4,
                right = 4,
                top = 4,
                bottom = 4
            } -- 设置边框的内边距
        }
    }
}

function zxqy_zidonggongju:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- 初始化
function zxqy_zidonggongju:Init()
    -- 创建窗体
    self.CreateWindows(self)
    -- 创建窗体1
    self.CreateWindows1(self)
    -- 创建复选框 邀请入会
    self.Createcheckbox(self)
    -- 创建复选框1 喊话
    self.Createcheckbox1(self)
    -- 创建复选框1 喊话
    self.Createcheckbox2(self)
    -- 创建自动邀请入会
    self.Createcheckbox3(self)
    -- 喊话内容
    self.CreateText(self)
    -- 创建一个按钮
    self.Createbutton2(self)
    -- 将属性写入到控件
    self:SetFunctionByOption(self);
end

-- -- 读取配置
function zxqy_zidonggongju:LoadSettings()
    -- 在插件加载时初始化 SavedVariables
    -- local id = UnitName("player") .. "@" .. GetRealmName();
    -- 当前用户是否有配置
    if ZXQY_auto_option then
        -- Print("已读取配置");
        self.Option = ZXQY_auto_option;
    else
        -- Print("初始化配置");
        ZXQY_auto_option = self.Option
    end
    -- 将属性写入到控件
    self:SetFunctionByOption(self);
end

-- 将配置写入设置
function zxqy_zidonggongju:SetFunctionByOption()
    -- 是否勾选密语收人入会
    self.checkbox:SetChecked(self.Option.is_shouren)
    -- 密语内容如果为*则是所有密语都会收人入会
    self.checkbox_MyEditBox:SetText(self.Option.shouren_miyu)
    -- 是否开始自定义喊话
    self.checkbox1:SetChecked(self.Option.is_zidingyi)
    -- 自定义频道间隔时间
    self.checkbox1_MyEditBox:SetText(self.Option.zidingyi_jiangeshijian)
    -- 自定义频道号
    self.checkbox1_MyEditBox1:SetText(self.Option.zidingyi_pindao)
    -- 自定义频道喊话内容
    self.checkbox1_MyEditBox2:SetText(self.Option.zidingyi_pindao_neirong)
    -- 间隔时间
    self.checkbox3_MyEditBox:SetText(self.Option.yq_jiange);
    -- 初始等级
    self.checkbox3_MyEditBox1:SetText(self.Option.yq_dengji);
    -- 等级递增
    self.checkbox3_MyEditBox2:SetText(self.Option.yq_dizeng);
    -- 是否开始喊话
    self.checkbox2:SetChecked(self.Option.is_hanhua)
    -- 喊话间隔时间
    self.checkbox2_MyEditBox:SetText(self.Option.hanhua_jiangeshijian)
    -- 喊话内容
    self.checkbox2_MyEditBox2:SetText(self.Option.hanhua_pindao_neirong)
end

-- 保存配置
function zxqy_zidonggongju:SaveSettings()
    -- Print("已保存配置");
    ZXQY_auto_option = self.Option;
end

-- 间隔时间处理
function zxqy_zidonggongju:TimerFunc(arg1)
    -- 自定义频道内容
    self.ds_zidingyi = self.ds_zidingyi + arg1; -- 累加计时器
    if self.Option.is_zidingyi == 1 and self.ds_zidingyi >= self.Option.zidingyi_jiangeshijian then
        -- print("自定义频道", self.ds_zidingyi)
        self.ds_zidingyi = 0
        -- 发送内容到自定义频道
        SendChatMessage(self.Option.zidingyi_pindao_neirong, "CHANNEL", nil, self.Option.zidingyi_pindao)
    end
    -- 自定义喊话
    self.ds_hanhua = self.ds_hanhua + arg1;
    if self.Option.is_hanhua == 1 and self.ds_hanhua >= self.Option.hanhua_jiangeshijian then
        -- print("喊话", self.ds_hanhua)
        self.ds_hanhua = 0
        -- 发送内容到自定义频道
        SendChatMessage(self.Option.hanhua_pindao_neirong, "YELL")
    end

    -- 自动收人
    self.ds_shouren = self.ds_shouren + arg1;
    if self.is_kaishishouren == 1 and self.ds_shouren >= self.Option.yq_jiange then
        self.ds_shouren = 0;
        -- 加载一次等级
        if self.tmp_dengji == 0 then
            self.tmp_dengji = self.Option.yq_dengji
        end
        -- 将当前搜索等级写入输入框
        self.checkbox3_MyEditBox1:SetText(self.tmp_dengji)
        -- 搜索并邀请入会
        self:addgonghui(self.tmp_dengji, self.Option.yq_dizeng)
        self.tmp_dengji = self.tmp_dengji + self.Option.yq_dizeng + 1;
        -- 如果大于60级则重置
        if self.tmp_dengji > 60 then
            self.tmp_dengji = self.Option.yq_dengji
        end
        -- print("self.Option.yq_dengji:"..self.Option.yq_dengji)
        -- print("self.Option.yq_dizeng:"..self.Option.yq_dizeng)
        -- print("self.tmp_dengji:"..self.tmp_dengji)
        -- self.checkbox3:GetChecked()
        -- self.checkbox3:SetChecked(self.is_kaishishouren)
    end

    -- 勾选后,每1分钟自动保存
    self.ds_savedkp = self.ds_savedkp + arg1;
    if self.is_savedkp == 1 and self.ds_savedkp >= 60 then
        self.ds_savedkp = 0;
        self:SaveDKPtoFile();
    end
end

-- 创建窗体
function zxqy_zidonggongju:CreateWindows()
    self.Windows_master = CreateFrame("Frame", "Windows", UIParent)
    self.Windows_master:SetWidth(self.Windows_width)
    self.Windows_master:SetHeight(self.Windows_height)
    self.Windows_master:SetPoint("CENTER", UIParent, "CENTER")
    self.Windows_master:SetMovable(true)
    self.Windows_master:EnableMouse(true)
    self.Windows_master:EnableMouseWheel(true)
    self.Windows_master:RegisterForDrag("LeftButton")
    self.Windows_master:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    self.Windows_master:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    self.Windows_scrollFrame = CreateFrame("ScrollFrame", nil, self.Windows_master)
    self.Windows_scrollFrame:SetAllPoints(self.Windows_master)

    self.Windows = CreateFrame("Frame", nil, self.Windows_scrollFrame)

    self.Windows:SetWidth(self.Windows_width)
    self.Windows:SetHeight(300)
    self.Windows:EnableMouseWheel(true)

    self.Windows_scrollFrame:SetScrollChild(self.Windows)
    -- 获取所有控件的总高度
    -- local contentHeight = self.GetTextHeight(self)
    -- 初始化滚动条位置
    self.Windows_scrollFrame:SetVerticalScroll(0)
    self.Windows:SetScript("OnMouseWheel", function()
        -- print("滚动条传参:" .. arg1)
        local newValue = self.Windows_scrollFrame:GetVerticalScroll() - (arg1 * 100)
        if newValue < 0 then
            newValue = 0
        elseif newValue > self.Windows:GetHeight() - self.Windows_scrollFrame:GetHeight() then
            newValue = self.Windows:GetHeight() - self.Windows_scrollFrame:GetHeight()
        end
        self.Windows_scrollFrame:SetVerticalScroll(newValue)
    end)

    -- 创建背景
    self.Windows_master:SetBackdrop(self.style.input)
    self.Windows_master:SetBackdropColor(0, 0, 0, 0.5)

    -- 创建关闭窗体按钮
    self.closeButton = CreateFrame("Button", "MyAddonCloseButton", self.Windows_master, "UIPanelCloseButton")
    self.closeButton:SetPoint("TOPRIGHT", -6, -6)
    self.closeButton:SetScript("OnClick", function()
        self.is_show_windows = false
        self.Windows_master:Hide()
    end)

    self.Windows_master:Hide()
end

-- 创建跟随鼠标移动的窗口以及内部字符串
function zxqy_zidonggongju:CreateWindows1()
    self.Windows1 = CreateFrame("Frame", "MyFrame", UIParent)
    self.Windows1:SetWidth(430)
    self.Windows1:SetHeight(500)
    -- self.Windows1:SetPoint("CENTER", 0, 0)
    -- self.Windows1:EnableMouseWheel(true)
    self.Windows1:SetPoint("CENTER", UIParent, "CENTER")
    self.Windows1:SetMovable(true)
    self.Windows1:EnableMouse(true)
    self.Windows1:RegisterForDrag("LeftButton")
    self.Windows1:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    self.Windows1:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)
    -- 创建背景
    self.Windows1:SetBackdrop(self.style.input)
    self.Windows1:SetBackdropColor(0, 0, 0, 0.5)

    -- 创建关闭窗体按钮
    self.Windows1_closeButton = CreateFrame("Button", "Windows1_closeButton", self.Windows1, "UIPanelCloseButton")
    self.Windows1_closeButton:SetPoint("TOPRIGHT", -6, -6)
    self.Windows1_closeButton:SetScript("OnClick", function()
        self.is_show_windows1 = false
        self.Windows1:Hide()
    end)
    -- 创建单行输入框
    self.Windows1_editbox_content = CreateFrame("EditBox", "Windows1_content", self.Windows1)
    self.Windows1_editbox_content:SetWidth(100)
    self.Windows1_editbox_content:SetHeight(30)
    self.Windows1_editbox_content:SetBackdrop(self.style.input)
    self.Windows1_editbox_content:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.Windows1_editbox_content:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.Windows1_editbox_content:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.Windows1_editbox_content:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.Windows1_editbox_content:SetPoint("TOPLEFT", 6, 30)
    self.Windows1_editbox_content:SetAutoFocus(false)
    -- 按tab切换到下个输入框
    self.Windows1_editbox_content:SetScript("OnTabPressed", function()
        this:ClearFocus()
        self.Windows2_editbox_content:SetFocus()
    end)
    self.Windows1_editbox_content:SetScript("OnEnterPressed", function()
        this:ClearFocus()
    end)
    self.Windows1_editbox_content:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    -- 按回车键提交
    self.Windows1_editbox_content:SetScript("OnEditFocusLost", function()
        this:ClearFocus()
    end)
    -- 创建单行输入框
    self.Windows2_editbox_content = CreateFrame("EditBox", "Windows1_content", self.Windows1)
    self.Windows2_editbox_content:SetWidth(100)
    self.Windows2_editbox_content:SetHeight(30)
    self.Windows2_editbox_content:SetBackdrop(self.style.input)
    self.Windows2_editbox_content:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.Windows2_editbox_content:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.Windows2_editbox_content:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.Windows2_editbox_content:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.Windows2_editbox_content:SetPoint("LEFT", self.Windows1_editbox_content, "RIGHT", 3, 0)
    self.Windows2_editbox_content:SetAutoFocus(false)
    -- 按tab切换到下个输入框
    self.Windows2_editbox_content:SetScript("OnTabPressed", function()
        this:ClearFocus()
        self.Windows3_editbox_content:SetFocus()
    end)
    self.Windows2_editbox_content:SetScript("OnEnterPressed", function()
        this:ClearFocus()
    end)
    self.Windows2_editbox_content:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    -- 按回车键提交
    self.Windows2_editbox_content:SetScript("OnEditFocusLost", function()
        this:ClearFocus()
        -- self:ShowTableData(WebDKP_Log, self.Windows1_editbox_content:GetText(), self.Windows2_editbox_content:GetText(),
        -- self.Windows3_editbox_content:GetText())
    end)
    -- 创建单行输入框
    self.Windows3_editbox_content = CreateFrame("EditBox", "Windows1_content", self.Windows1)
    self.Windows3_editbox_content:SetWidth(100)
    self.Windows3_editbox_content:SetHeight(30)
    self.Windows3_editbox_content:SetBackdrop(self.style.input)
    self.Windows3_editbox_content:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.Windows3_editbox_content:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.Windows3_editbox_content:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.Windows3_editbox_content:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.Windows3_editbox_content:SetPoint("LEFT", self.Windows2_editbox_content, "RIGHT", 3, 0)
    self.Windows3_editbox_content:SetAutoFocus(false)
    -- 按tab切换到下个输入框
    self.Windows3_editbox_content:SetScript("OnTabPressed", function()
        this:ClearFocus()
        self.Windows1_editbox_content:SetFocus()
    end)
    self.Windows3_editbox_content:SetScript("OnEnterPressed", function()
        this:ClearFocus()
    end)
    self.Windows3_editbox_content:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    -- 按回车键提交
    self.Windows3_editbox_content:SetScript("OnEditFocusLost", function()
        this:ClearFocus()
        -- self:ShowTableData(WebDKP_Log, self.Windows1_editbox_content:GetText(), self.Windows2_editbox_content:GetText(),
        -- self.Windows3_editbox_content:GetText())
    end)
    -- 创建 select ,三选一,用于选择数据 {1="所有",2="加分",3="减分"}
    self.Windows1_select = CreateFrame("Frame", "Test_DropDown", self.Windows1, "UIDropDownMenuTemplate");
    self.Windows1_select:ClearAllPoints()
    self.Windows1_select:SetWidth(30)
    -- self.Windows1_select:SetPoint("LEFT", self.Windows3_editbox_content, "RIGHT", 3, 0)
    UIDropDownMenu_Initialize(self.Windows1_select, function()
        for key, val in pairs(self.select_option1) do
            local info = {};
            -- 值等于1则默认选中
            if key == 1 then
                info.checked = true;
            else
                info.checked = false;
            end
            -- info.hasArrow = true;
            info.notCheckable = true;
            info.text = val;
            info.value = key;
            info.func = function()
                UIDropDownMenu_SetSelectedValue(self.Windows1_select, info.value)
                print("选中值:" .. info.value)
                -- 打印当前值
                print("当前值:" .. UIDropDownMenu_GetSelectedValue(self.Windows1_select))
            end
            UIDropDownMenu_AddButton(info);
        end
        -- 设置默认值
        UIDropDownMenu_SetSelectedValue(self.Windows1_select, 1)
    end, "MENU");

    -- 创建一个按钮,用于操作 self.Windows1_select
    self.Windows1_select_button =
        CreateFrame("Button", "Windows1_select_button", self.Windows1, "UIPanelButtonTemplate")
    self.Windows1_select_button:SetWidth(30)
    self.Windows1_select_button:SetHeight(30)
    self.Windows1_select_button:SetPoint("LEFT", self.Windows3_editbox_content, "RIGHT", 3, 0)
    self.Windows1_select_button:SetText("默认")
    self.Windows1_select_button:SetScript("OnClick", function()
        ToggleDropDownMenu(1, nil, self.Windows1_select, self.Windows1_select_button, 0, 0);
    end)

    -- 创建按钮,用于提交数据
    self.Windows1_button = CreateFrame("Button", "Windows1_button", self.Windows1, "UIPanelButtonTemplate")
    self.Windows1_button:SetWidth(100)
    self.Windows1_button:SetHeight(30)
    self.Windows1_button:SetPoint("LEFT", self.Windows1_select_button, "RIGHT", 3, 0)
    self.Windows1_button:SetText("搜索人物")
    self.Windows1_button:SetScript("OnClick", function()
        self:ShowTableData(WebDKP_Log, self.Windows1_editbox_content:GetText(), self.Windows2_editbox_content:GetText(),
            self.Windows3_editbox_content:GetText())
    end)

    self.Windows1_scrollFrame = CreateFrame("ScrollFrame", nil, self.Windows1)
    self.Windows1_scrollFrame:SetAllPoints(self.Windows1)
    self.Windows1_content = CreateFrame("Frame", nil, self.Windows1_scrollFrame)
    -- 保持和窗口一样大
    local Windows1Width = self.Windows1:GetWidth()
    self.Windows1_content:SetWidth(Windows1Width)
    self.Windows1_scrollFrame:SetScrollChild(self.Windows1_content)

    self.Windows1_content:SetBackdropColor(0, 0, 0, 0) -- 设置背景颜色为透明
    self.Windows1_content:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 1,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    })

    self.Windows1:Hide()
end

-- 创建新的字符串控件并写入字符串
function zxqy_zidonggongju:CreateNewText(str, x, y)
    -- 先获取 self.content_text_table 的长度,然后创建 self.Windows1_content:CreateFontString(nil, "OVERLAY", "GameFontNormal") 追加保存到 self.content_text_table 中
    local next_length = table.getn(self.content_text_table) + 1
    local Windows1Width = self.Windows1:GetWidth()
    self.content_text_table[next_length] = self.Windows1_content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.content_text_table[next_length]:SetWidth(Windows1Width)
    self.content_text_table[next_length]:SetJustifyH("LEFT")
    self.content_text_table[next_length]:SetText(str)
    self.content_text_table[next_length]:SetPoint("TOPLEFT", x, y)
end
-- 销毁所有字符串控件
function zxqy_zidonggongju:DestroyText()
    for i = 1, table.getn(self.content_text_table) do
        self.content_text_table[i]:Hide()
        self.content_text_table[i] = nil
        table.remove(self.content_text_table, i)
    end
end
-- 获取所有字符串控件的高度,返回总高度
function zxqy_zidonggongju:GetTextHeight()
    local height = 0
    for i = 1, table.getn(self.content_text_table) do
        height = height + self.content_text_table[i]:GetHeight()
    end
    return height
end
-- 字符串参数1是否包含字符串参数2,如果参数2有空格则分割后比较
function zxqy_StrContains(str1, str2)
    -- print("参数1[" .. str1 .. "]是否包含参数2[" .. str2 .. "]")
    -- 如果参数2为空字符串则返回true
    if str2 == "" then
        return true
    end
    local list = string.split(str2, " ")
    -- print("参数2分割后的数组长度:" .. table.getn(list))
    for i = 1, table.getn(list) do
        -- print("参数1:" .. tostring(str1))
        -- print("参数2:" .. tostring(list[i]))
        -- print(str1 .. "包含" .. list[i] .. "的结果为:" .. tostring(string.find(str1, list[i], 1, true)))
        if string.find(str1, list[i], 1, true) ~= nil then
            return true
        end
    end
    return false
end

-- 将传参数据显示到窗口内
function zxqy_zidonggongju:ShowTableData(data, guolv_name, guolv_time, guolv_zone)
    -- 先检查data是否为table并且有数据
    if type(data) ~= "table" then
        -- zxqy_print(data)
        -- print("传参数据不是table，无法显示:")
        return
    end

    local hang = 4
    local neirong = ""
    -- 先销毁所有字符串控件
    self:DestroyText()
    -- 检查参数 guolv_name 是否有值
    if (type(guolv_name) == "string" and guolv_name ~= "") or (type(guolv_time) == "string" and guolv_time ~= "") or
        (type(guolv_zone) == "string" and guolv_zone ~= "") then
    else
        neirong = neirong ..
                      "传参数据格式为:\n第一个输入框输入内容为要过滤的人物名称\n第二个输入框输入内容为要过滤的时间,空格隔开多个日期,\n格式为:年-月-日或者月-日\n第三个输入框输入内容为要过滤的区域\n"
        -- 再写入字符串
        self.CreateNewText(self, neirong, 6, -6)
        self:ShowLog()
        return
    end
    -- 获取筛选值 1:所有,2:加分,3:减分,4:装备,5:不是装备
    local sxz = UIDropDownMenu_GetSelectedValue(self.Windows1_select)
    -- print("sxz:" .. tostring(sxz))
    -- 过滤
    local newdata = zxqy_FilterTable(data, function(arg1)
        -- print("foritem:type" .. type(arg1["foritem"]))
        for k1, v1 in pairs(arg1["awarded"]) do
            if zxqy_StrContains(tostring(v1["name"]), guolv_name) and
                zxqy_StrContains(tostring(arg1["date"]), guolv_time) and
                zxqy_StrContains(tostring(arg1["zone"]), guolv_zone) then
                -- 两种方法都可以
                -- arg1["points"] 值是正数或者负数代表加分或者减分
                -- arg1["foritem"] 值为true代表是装备，值为false代表不是装备
                if sxz == 1 then
                    return true
                end
                if sxz == 2 and arg1["points"] > 0 then
                    -- print("points:" .. tostring(arg1["points"]))
                    return true
                end
                if sxz == 3 and arg1["points"] < 0 then
                    -- print("points:" .. tostring(arg1["points"]))
                    return true
                end
                if sxz == 4 and arg1["foritem"] == "true" then
                    -- print("foritem:" .. tostring(arg1["foritem"]))
                    return true
                end
                if sxz == 5 and arg1["foritem"] == "false" then
                    -- print("foritem:" .. tostring(arg1["foritem"]))
                    return true
                end
                -- return true
            end
        end
        -- print("不符合过滤条件")
        return false
    end)
    -- 输出待显示table数据的长度
    -- print("符合过滤条件的数据长度:" .. table.getn(newdata))
    -- 偏移量
    -- local yOffset = 6
    for k, v in pairs(newdata) do
        -- 判断不为空
        if tostring(v["date"]) ~= "" then
            neirong = "---------------------------------\n"
            -- neirong = neirong .. tostring(k) .. "\n"
            --  tostring(v["tableid"]) v["reason"] v["date"] v["awardedby"]
            neirong =
                neirong .. tostring(v["date"]) .. "     " .. tostring(v["zone"]) .. "\n" .. tostring(v["reason"]) ..
                    "     " .. tostring(v["points"]) .. "\n"
            local xxx = 0;
            -- 检查 v["awarded"] 是否是table
            if type(v["awarded"]) == "table" then
                for k1, v1 in pairs(v["awarded"]) do
                    neirong = neirong .. tostring(v1["name"]) .. " ";
                    xxx = xxx + 1;
                    if yushu(xxx, hang) == 0 then
                        neirong = neirong .. "\n"
                    end
                end
            end
            neirong = neirong .. "\n---------------------------------\n"
            -- 获取已有高度
            local yOffset = self.GetTextHeight(self)
            self.CreateNewText(self, neirong, 6, -yOffset)
        end
    end
    -- 打印输出neirong字符串的长度
    -- print("neirong字符串长度:" .. string.len(neirong))

    self:ShowLog()
end

-- 筛选函数,过滤掉不符合条件的数据
function zxqy_FilterTable(tabledata, filter)
    local newTable = {}
    local count = 0
    for k, v in pairs(tabledata) do
        -- 删除指定key
        if k ~= "Version" and filter(v) then
            -- print("符合过滤条件")
            count = count + 1
            newTable[k] = v
            -- table.insert(newTable, {key = k, value = v})
        end
    end
    -- print("符合过滤条件的数据长度:" .. count)
    return newTable
end
-- 显示日志窗口
function zxqy_zidonggongju:ShowLog()
    -- 获取所有控件的总高度
    local contentHeight = self.GetTextHeight(self)
    -- 输出文字高度
    self.Windows1_content:SetHeight(contentHeight + 20)
    self.Windows1_content:EnableMouseWheel(true)
    self.Windows1_content:SetPoint("TOPLEFT", 6, -6)
    -- 初始化滚动条位置
    self.Windows1_scrollFrame:SetVerticalScroll(0)
    self.Windows1_content:SetScript("OnMouseWheel", function()
        -- print("滚动条传参:" .. arg1)
        local newValue = self.Windows1_scrollFrame:GetVerticalScroll() - (arg1 * 100)
        if newValue < 0 then
            newValue = 0
        elseif newValue > self.Windows1_content:GetHeight() - self.Windows1_scrollFrame:GetHeight() then
            newValue = self.Windows1_content:GetHeight() - self.Windows1_scrollFrame:GetHeight()
        end
        self.Windows1_scrollFrame:SetVerticalScroll(newValue)
    end)

    self.Windows1:Show()
end
-- 取余数方法,因为使用%报错了
function yushu(a, b)
    return a - math.floor(a / b) * b
end
-- 获取所有控件的总高度
function zxqy_zidonggongju:GetFrameHeight()
    local totalHeight = 0
    for k, v in pairs(self.page_content_table) do
        -- 10的间隔
        totalHeight = totalHeight + v:GetHeight() + 10
    end
    return totalHeight
end
-- 创建勾选框 邀请入会
function zxqy_zidonggongju:Createcheckbox()
    self.checkbox = CreateFrame("CheckButton", "is_shouren", self.Windows, "OptionsCheckButtonTemplate")
    self.checkbox:SetPoint("TOPLEFT", 20, -20)
    self.checkbox:SetScript("OnClick", function()
        self.Option.is_shouren = self.checkbox:GetChecked()
        -- print("is_shouren", self.Option.is_shouren)
        self.SaveSettings(self)
    end)
    -- 创建文字
    self.checkbox_text = self.Windows:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.page_content_table["checkbox_text"] = self.checkbox_text
    self.checkbox_text:SetPoint("LEFT", self.checkbox, "RIGHT", 10, 0)
    self.checkbox_text:SetText(
        "勾选后,所有给我发送下面填写的密语的人都会被邀请入会,*号表示任意字符")
    self.checkbox_text:SetJustifyH("LEFT");
    self.checkbox_text:SetWidth(400)
    -- 创建单行输入框
    self.checkbox_MyEditBox = CreateFrame("EditBox", nil, self.Windows)
    self.page_content_table["checkbox_MyEditBox"] = self.checkbox_MyEditBox
    self.checkbox_MyEditBox:SetWidth(200)
    self.checkbox_MyEditBox:SetHeight(20)
    self.checkbox_MyEditBox:SetBackdrop(self.style.input)
    self.checkbox_MyEditBox:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox_MyEditBox:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox_MyEditBox:SetAutoFocus(false)
    self.checkbox_MyEditBox:SetPoint("TOPLEFT", self.checkbox, "BOTTOMLEFT", 0, -10)
    self.checkbox_MyEditBox:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox_MyEditBox:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox_MyEditBox:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox_MyEditBox:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.shouren_miyu = this:GetText()
        self.SaveSettings(self)
    end)
    self.checkbox_MyEditBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.shouren_miyu = this:GetText()
        self.SaveSettings(self)
    end)
    self.checkbox_MyEditBox:SetScript("OnTextChanged", function()
        self.Option.shouren_miyu = this:GetText()
        self.SaveSettings(self)
    end)
    self.checkbox_MyEditBox:Show()
end

-- 创建勾选框 自定义频道说话
function zxqy_zidonggongju:Createcheckbox1()
    self.checkbox1 = CreateFrame("CheckButton", "is_zidingyi", self.Windows, "OptionsCheckButtonTemplate")
    self.checkbox1:SetPoint("TOPLEFT", self.checkbox_MyEditBox, "BOTTOMLEFT", 0, -10)
    self.checkbox1:SetScript("OnClick", function()
        self.Option.is_zidingyi = self.checkbox1:GetChecked()
        -- print("is_zidingyi", self.Option.is_zidingyi)
        self.SaveSettings(self)
    end)
    -- 创建文字
    self.checkbox1_text1 = self.Windows:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.page_content_table["checkbox1_text1"] = self.checkbox1_text1
    self.checkbox1_text1:SetPoint("LEFT", self.checkbox1, "RIGHT", 10, 0)
    self.checkbox1_text1:SetText(
        "勾选后,开始发送到自定义频道,第一行为间隔时间,第二行输入频道名称1则是world,第三行输入内容")
    self.checkbox1_text1:SetJustifyH("LEFT");
    self.checkbox1_text1:SetWidth(400)
    -- 创建单行输入框 间隔时间
    self.checkbox1_MyEditBox = CreateFrame("EditBox", nil, self.Windows)
    self.page_content_table["checkbox1_MyEditBox"] = self.checkbox1_MyEditBox
    self.checkbox1_MyEditBox:SetBackdrop(self.style.input)
    self.checkbox1_MyEditBox:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox1_MyEditBox:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox1_MyEditBox:SetAutoFocus(false)
    self.checkbox1_MyEditBox:SetNumeric(true) -- 设置只能输入数字
    self.checkbox1_MyEditBox:SetWidth(50)
    self.checkbox1_MyEditBox:SetHeight(20)
    self.checkbox1_MyEditBox:SetPoint("TOPLEFT", self.checkbox1, "BOTTOMLEFT", 0, -10)
    self.checkbox1_MyEditBox:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox1_MyEditBox:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox1_MyEditBox:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox1_MyEditBox:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.zidingyi_jiangeshijian = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.zidingyi_jiangeshijian = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox:SetScript("OnTextChanged", function()
        self.Option.zidingyi_jiangeshijian = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox:Show()

    -- 创建单行输入框 频道号
    self.checkbox1_MyEditBox1 = CreateFrame("EditBox", nil, self.Windows)
    self.checkbox1_MyEditBox1:SetBackdrop(self.style.input)
    self.checkbox1_MyEditBox1:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox1_MyEditBox1:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox1_MyEditBox1:SetAutoFocus(false)
    self.checkbox1_MyEditBox1:SetWidth(50)
    self.checkbox1_MyEditBox1:SetHeight(20)
    self.checkbox1_MyEditBox1:SetPoint("LEFT", self.checkbox1_MyEditBox, "RIGHT", 10, 0)
    self.checkbox1_MyEditBox1:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox1_MyEditBox1:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox1_MyEditBox1:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox1_MyEditBox1:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.zidingyi_pindao = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox1:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.zidingyi_pindao = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox1:SetScript("OnTextChanged", function()
        self.Option.zidingyi_pindao = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox1:Show()

    -- 创建一个多行编辑框,用于输入文本
    -- self.MyEditBox:SetHistoryLines(10); -- 设置编辑框的历史记录行数为1
    -- self.MyEditBox:SetTextInsets(10, 10, 0, 0); -- 设置编辑框的文本内边距为(10,10,0,0)
    -- self.MyEditBox:SetJustifyH("RIGHT") -- 设置文本水平对齐方式为右对齐
    -- self.MyEditBox:SetTextColor(.2, 1, .8, 1) -- 设置文本颜色为RGBA(0.2, 1, 0.8, 1)
    -- self.MyEditBox:SetText("测试内容") -- 设置输入框的文本内容为"测试内容"
    -- self.MyEditBox:EnableKeyboard() -- 启用键盘交互功能
    self.checkbox1_MyEditBox2 = CreateFrame("EditBox", nil, self.Windows)
    self.page_content_table["checkbox1_MyEditBox2"] = self.checkbox1_MyEditBox2
    self.checkbox1_MyEditBox2:SetBackdrop(self.style.input)
    self.checkbox1_MyEditBox2:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox1_MyEditBox2:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox1_MyEditBox2:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox1_MyEditBox2:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox1_MyEditBox2:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox1_MyEditBox2:SetMultiLine(true) -- 设置输入框为多行模式
    self.checkbox1_MyEditBox2:SetWidth(self.Windows:GetWidth() - 30) -- 设置输入框宽度为280
    self.checkbox1_MyEditBox2:SetHeight(280) -- 设置输入框高度为280
    self.checkbox1_MyEditBox2:SetAutoFocus(false) -- 设置输入框失去焦点
    self.checkbox1_MyEditBox2:SetPoint("TOPLEFT", self.checkbox1_MyEditBox, "BOTTOMLEFT", 0, -10)
    self.checkbox1_MyEditBox2:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.checkbox2:SetPoint("TOPLEFT", self.checkbox1_MyEditBox2, "BOTTOMLEFT", 0, -10)
        self.Option.zidingyi_pindao_neirong = this:GetText()
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox2:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.checkbox2:SetPoint("TOPLEFT", self.checkbox1_MyEditBox2, "BOTTOMLEFT", 0, -10)
        self.Option.zidingyi_pindao_neirong = this:GetText()
        self.SaveSettings(self)
    end)
    self.checkbox1_MyEditBox2:SetScript("OnTextChanged", function()
        self.checkbox2:SetPoint("TOPLEFT", self.checkbox1_MyEditBox2, "BOTTOMLEFT", 0, -10)
        self.Option.zidingyi_pindao_neirong = this:GetText()
        self.SaveSettings(self)
        self.Windows:SetHeight(self.GetFrameHeight(self))
    end)
    self.checkbox1_MyEditBox2:Show()
end

-- 创建勾选框 喊话
function zxqy_zidonggongju:Createcheckbox2()
    self.checkbox2 = CreateFrame("CheckButton", "is_hanhua", self.Windows, "OptionsCheckButtonTemplate")
    -- self.checkbox2:SetPoint("TOPLEFT", 20, -190)
    self.checkbox2:SetPoint("TOPLEFT", self.checkbox1_MyEditBox2, "BOTTOMLEFT", 0, -10)
    self.checkbox2:SetScript("OnClick", function()
        self.Option.is_hanhua = self.checkbox2:GetChecked()
        -- print("is_hanhua", self.Option.is_hanhua)
        self.SaveSettings(self)
    end)
    -- 创建文字
    self.checkbox2_text1 = self.Windows:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.page_content_table["checkbox2_text1"] = self.checkbox2_text1
    self.checkbox2_text1:SetPoint("LEFT", self.checkbox2, "RIGHT", 10, 0)
    self.checkbox2_text1:SetText("勾选后,开始发送到喊话,第一行为间隔时间,第二行输入内容")
    self.checkbox2_text1:SetJustifyH("LEFT");
    self.checkbox2_text1:SetWidth(400)
    -- 创建单行输入框 间隔时间
    self.checkbox2_MyEditBox = CreateFrame("EditBox", nil, self.Windows)
    self.page_content_table["checkbox2_MyEditBox"] = self.checkbox2_MyEditBox
    self.checkbox2_MyEditBox:SetBackdrop(self.style.input)
    self.checkbox2_MyEditBox:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox2_MyEditBox:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox2_MyEditBox:SetAutoFocus(false)
    self.checkbox2_MyEditBox:SetNumeric(true) -- 设置只能输入数字
    self.checkbox2_MyEditBox:SetWidth(50)
    self.checkbox2_MyEditBox:SetHeight(20)
    self.checkbox2_MyEditBox:SetPoint("TOPLEFT", self.checkbox2, "BOTTOMLEFT", 0, -10)
    self.checkbox2_MyEditBox:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox2_MyEditBox:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox2_MyEditBox:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox2_MyEditBox:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.hanhua_jiangeshijian = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox2_MyEditBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.hanhua_jiangeshijian = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox2_MyEditBox:SetScript("OnTextChanged", function()
        self.Option.hanhua_jiangeshijian = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox2_MyEditBox:Show()

    -- 创建一个多行编辑框,用于输入文本
    self.checkbox2_MyEditBox2 = CreateFrame("EditBox", nil, self.Windows)
    self.page_content_table["checkbox2_MyEditBox2"] = self.checkbox2_MyEditBox2
    self.checkbox2_MyEditBox2:SetBackdrop(self.style.input)
    self.checkbox2_MyEditBox2:SetBackdropColor(0, 0, 0, 1)
    self.checkbox2_MyEditBox2:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox2_MyEditBox2:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox2_MyEditBox2:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox2_MyEditBox2:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox2_MyEditBox2:SetMultiLine(true) -- 设置输入框为多行模式
    self.checkbox2_MyEditBox2:SetWidth(self.Windows:GetWidth() - 30)
    self.checkbox2_MyEditBox2:SetHeight(280)
    self.checkbox2_MyEditBox2:SetPoint("TOPLEFT", self.checkbox2_MyEditBox, "BOTTOMLEFT", 0, -10)
    self.checkbox2_MyEditBox2:SetAutoFocus(false) -- 设置输入框失去焦点
    -- self.checkbox2_MyEditBox2:SetPoint("CENTER", self.checkbox2_Frame, "CENTER", 0, 0)
    self.checkbox2_MyEditBox2:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.hanhua_pindao_neirong = this:GetText()
        self.SaveSettings(self)
    end)
    self.checkbox2_MyEditBox2:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.hanhua_pindao_neirong = this:GetText()
        self.SaveSettings(self)
    end)
    self.checkbox2_MyEditBox2:SetScript("OnTextChanged", function()
        self.Option.hanhua_pindao_neirong = this:GetText()
        self.SaveSettings(self)
        self.Windows:SetHeight(self.GetFrameHeight(self))
    end)
    self.checkbox2_MyEditBox2:Show()
end

-- 创建勾选框 开始自动收人
function zxqy_zidonggongju:Createcheckbox3()
    self.checkbox3 = CreateFrame("CheckButton", "is_kaishishouren", self.Windows, "OptionsCheckButtonTemplate")
    self.checkbox3:SetPoint("TOPLEFT", self.checkbox2_MyEditBox2, "BOTTOMLEFT", 0, -10)
    self.checkbox3:SetScript("OnClick", function()
        self.is_kaishishouren = self.checkbox3:GetChecked()
    end)
    -- 创建文字
    self.checkbox3_text1 = self.Windows:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.page_content_table["checkbox3_text1"] = self.checkbox3_text1
    self.checkbox3_text1:SetPoint("LEFT", self.checkbox3, "RIGHT", 10, 0)
    self.checkbox3_text1:SetText("开始邀请入会,间隔,等级,递增:")
    self.checkbox3_text1:SetJustifyH("LEFT");
    self.checkbox3_text1:SetWidth(200)
    -- 创建自动保存DKP勾选框
    self.checkbox_autosavedkp = CreateFrame("CheckButton", nil, self.Windows, "OptionsCheckButtonTemplate")
    self.checkbox_autosavedkp:SetPoint("LEFT", self.checkbox3_text1, "RIGHT", 10, 0)
    self.checkbox_autosavedkp:SetScript("OnClick", function()
        self.is_savedkp = self.checkbox_autosavedkp:GetChecked()
    end)
    -- 创建文字
    self.checkbox_autosavedkp_text1 = self.Windows:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.checkbox_autosavedkp_text1:SetPoint("LEFT", self.checkbox_autosavedkp, "RIGHT", 3, 0)
    self.checkbox_autosavedkp_text1:SetText("[SuperWoW]每1分钟自动保存dkp到文件")
    self.checkbox_autosavedkp_text1:SetJustifyH("LEFT");
    self.checkbox_autosavedkp_text1:SetWidth(350)
    -- 创建单行输入框 间隔时间
    self.checkbox3_MyEditBox = CreateFrame("EditBox", nil, self.Windows)
    self.page_content_table["checkbox3_MyEditBox"] = self.checkbox3_MyEditBox
    self.checkbox3_MyEditBox:SetBackdrop(self.style.input)
    self.checkbox3_MyEditBox:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox3_MyEditBox:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox3_MyEditBox:SetAutoFocus(false)
    self.checkbox3_MyEditBox:SetNumeric(true) -- 设置只能输入数字
    self.checkbox3_MyEditBox:SetWidth(40)
    self.checkbox3_MyEditBox:SetHeight(20)
    self.checkbox3_MyEditBox:SetPoint("TOPLEFT", self.checkbox3, "BOTTOMLEFT", 0, -10)
    self.checkbox3_MyEditBox:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox3_MyEditBox:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox3_MyEditBox:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox3_MyEditBox:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.yq_jiange = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
    end)
    self.checkbox3_MyEditBox:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.yq_jiange = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
    end)
    self.checkbox3_MyEditBox:SetScript("OnTextChanged", function()
        self.Option.yq_jiange = tonumber(this:GetText()) == nil and 60 or tonumber(this:GetText())
    end)
    self.checkbox3_MyEditBox:Show()

    -- 创建单行输入框 初始等级
    self.checkbox3_MyEditBox1 = CreateFrame("EditBox", nil, self.Windows)
    self.checkbox3_MyEditBox1:SetBackdrop(self.style.input)
    self.checkbox3_MyEditBox1:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox3_MyEditBox1:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox3_MyEditBox1:SetAutoFocus(false)
    self.checkbox3_MyEditBox1:SetNumeric(true) -- 设置只能输入数字
    self.checkbox3_MyEditBox1:SetWidth(40)
    self.checkbox3_MyEditBox1:SetHeight(20)
    self.checkbox3_MyEditBox1:SetPoint("LEFT", self.checkbox3_MyEditBox, "RIGHT", 10, 0)
    self.checkbox3_MyEditBox1:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox3_MyEditBox1:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox3_MyEditBox1:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox3_MyEditBox1:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.yq_dengji = tonumber(this:GetText()) == nil and self.Option.yq_dengji or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox3_MyEditBox1:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.yq_dengji = tonumber(this:GetText()) == nil and self.Option.yq_dengji or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    -- self.checkbox3_MyEditBox1:SetScript("OnTextChanged", function()
    --     self.Option.yq_dengji = tonumber(this:GetText()) == nil and self.Option.yq_dengji or tonumber(this:GetText())
    --     self.SaveSettings(self)
    -- end)
    self.checkbox3_MyEditBox1:Show()

    -- 创建单行输入框 等级递增
    self.checkbox3_MyEditBox2 = CreateFrame("EditBox", nil, self.Windows)
    self.checkbox3_MyEditBox2:SetBackdrop(self.style.input)
    self.checkbox3_MyEditBox2:SetBackdropColor(0, 0, 0, 1) -- 设置背景颜色为黑色，透明度为0.5
    self.checkbox3_MyEditBox2:SetTextColor(1, 1, 1) -- 设置文字颜色为白色
    self.checkbox3_MyEditBox2:SetAutoFocus(false)
    self.checkbox3_MyEditBox2:SetNumeric(true) -- 设置只能输入数字
    self.checkbox3_MyEditBox2:SetWidth(40)
    self.checkbox3_MyEditBox2:SetHeight(20)
    self.checkbox3_MyEditBox2:SetPoint("LEFT", self.checkbox3_MyEditBox1, "RIGHT", 10, 0)
    self.checkbox3_MyEditBox2:SetFontObject("GameFontHighlight") -- 设置输入框的字体为游戏默认字体
    self.checkbox3_MyEditBox2:SetMaxLetters(0) -- 设置输入框的最大字符数为0，表示不限制字符数
    self.checkbox3_MyEditBox2:EnableMouse(true) -- 启用鼠标交互功能
    self.checkbox3_MyEditBox2:SetScript("OnEnterPressed", function()
        this:ClearFocus()
        self.Option.yq_dizeng = tonumber(this:GetText()) == nil and self.Option.yq_dizeng or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox3_MyEditBox2:SetScript("OnEscapePressed", function()
        this:ClearFocus()
        self.Option.yq_dizeng = tonumber(this:GetText()) == nil and self.Option.yq_dizeng or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox3_MyEditBox2:SetScript("OnTextChanged", function()
        self.Option.yq_dizeng = tonumber(this:GetText()) == nil and self.Option.yq_dizeng or tonumber(this:GetText())
        self.SaveSettings(self)
    end)
    self.checkbox3_MyEditBox2:Show()
end
-- 创建可编辑的文本框，用于待发送字符串内容
function zxqy_zidonggongju:CreateText()
    -- 创建一个按钮
    self.button2 = CreateFrame("Button", nil, self.Windows, "UIPanelButtonTemplate")
    self.button2:SetWidth(100)
    self.button2:SetHeight(30)
    self.button2:SetPoint("LEFT", self.checkbox3_MyEditBox2, "RIGHT", 10, 0)
    self.button2:SetText("测试搜索")
    self.button2:SetScript("OnClick", function()
        print("开始搜索")
        self:addgonghui(self.Option.yq_dengji, self.Option.yq_dizeng);
    end)
    -- 创建一个按钮
    self.button2_1 = CreateFrame("Button", nil, self.Windows, "UIPanelButtonTemplate")
    self.button2_1:SetWidth(100)
    self.button2_1:SetHeight(30)
    self.button2_1:SetPoint("LEFT", self.button2, "RIGHT", 10, 0)
    self.button2_1:SetText("清空历史名单")
    self.button2_1:SetScript("OnClick", function()
        print("清空历史名单")
        self.Option.GongHuiYaoQingOk = {};
        self.SaveSettings(self)
    end)

    self.button6 = CreateFrame("Button", "qingkong", self.Windows, "UIPanelButtonTemplate")
    self.button6:SetWidth(100)
    self.button6:SetHeight(30)
    self.button6:SetPoint("LEFT", self.button2_1, "RIGHT", 10, 0)
    self.button6:SetText("屏蔽列表")
    self.button6:SetScript("OnClick", function()
        -- 如果窗口已创建，则显示窗口
        if self.pingbilist_frame then
            self.pingbilist_frame:Show()
        else
            -- 创建一个新窗口
            self:pingbilistinit(self)
        end
    end)

    -- 创建新的按钮
    self.button4 = CreateFrame("Button", "shanchubutton", self.Windows, "UIPanelButtonTemplate")
    self.page_content_table["button4"] = self.button4
    self.button4:SetWidth(150)
    self.button4:SetHeight(30)
    self.button4:SetPoint("TOPLEFT", self.checkbox3_MyEditBox, "BOTTOMLEFT", 0, -10)
    self.button4:SetText("删除超30天成员")
    self.button4:SetScript("OnClick", function()
        -- 如果显示公会的离线成员，则返回 true。
        if GetGuildRosterShowOffline() then
            print("已开启显示离线成员")
            -- 删除20天成员
            self:delgonghuichengyuan(30)
        else
            print("请开启显示离线成员")
        end
    end)
    -- 创建新的按钮
    self.button8 = CreateFrame("Button", "shanchubutton1", self.Windows, "UIPanelButtonTemplate")
    self.button8:SetWidth(150)
    self.button8:SetHeight(30)
    self.button8:SetPoint("LEFT", self.button4, "RIGHT", 10, 0)
    self.button8:SetText("发送删除通知")
    self.button8:SetScript("OnClick", function()
        tmp_log =
            "为了便于公会管理,现在删除离线时间超过30天的公会成员.想入会再次密我!或者找工会任何成员都可以收人!";
        -- 发送到公会频道
        SendChatMessage(tmp_log, "GUILD")
    end)

    -- 创建新的按钮
    self.button3 = CreateFrame("Button", "jiangjibutton", self.Windows, "UIPanelButtonTemplate")
    self.button3:SetWidth(150)
    self.button3:SetHeight(30)
    self.button3:SetPoint("LEFT", self.button8, "RIGHT", 10, 0)
    self.button3:SetText("[GuildReRank]公会管理")
    self.button3:SetScript("OnClick", function()
        GRRG.Functions.ShowGRR()
    end)

    -- 清空DKP数据变量测试
    -- WebDKP_Options, WebDKP_Log, WebDKP_DkpTable, WebDKP_Tables, WebDKP_Loot, WebDKP_WebOptions
    -- 创建新的按钮
    self.button5 = CreateFrame("Button", "qingkong", self.Windows, "UIPanelButtonTemplate")
    self.page_content_table["button5"] = self.button5
    self.button5:SetWidth(150)
    self.button5:SetHeight(30)
    self.button5:SetPoint("TOPLEFT", self.button4, "BOTTOMLEFT", 0, -10)
    self.button5:SetText("[WEBDKP]清空DKP数据")
    self.button5:SetScript("OnClick", function()
        -- WebDKP_Options = {}
        -- WebDKP_Log = {}
        WebDKP_DkpTable = {}
        -- WebDKP_Tables = {}
        -- WebDKP_Loot = {}
        -- WebDKP_WebOptions = {}
        -- WebDKP_UpdateTable();
    end)

    self.button7 = CreateFrame("Button", "qingkong1", self.Windows, "UIPanelButtonTemplate")
    self.button7:SetWidth(150)
    self.button7:SetHeight(30)
    self.button7:SetPoint("LEFT", self.button5, "RIGHT", 10, 0)
    self.button7:SetText("[WEBDKP]打开日志")
    self.button7:SetScript("OnClick", function()
        -- 清空输入框1的内容
        self.Windows1_editbox_content:SetText("")
        self.Windows2_editbox_content:SetText("")
        self.Windows3_editbox_content:SetText("")
        self:ShowTableData(WebDKP_Log, self.Windows1_editbox_content:GetText(), self.Windows2_editbox_content:GetText(),
            self.Windows3_editbox_content:GetText())
    end)

    self.button9 = CreateFrame("Button", "loadsetting", self.Windows, "UIPanelButtonTemplate")
    self.button9:SetWidth(150)
    self.button9:SetHeight(30)
    self.button9:SetPoint("LEFT", self.button7, "RIGHT", 10, 0)
    self.button9:SetText("[SuperWoW]读取缓存覆盖")
    self.button9:SetScript("OnClick", function()
        -- 保存DKP到文件
        -- self:SaveDKPtoFile()
        -- 读取并覆盖缓存
        self:LoadDKPfromFile()
    end)

    -- 创建一个多行编辑框,用于输入文本
    self.checkbox2_MyEditBox3 = CreateFrame("EditBox", nil, self.Windows)
    self.page_content_table["checkbox2_MyEditBox3"] = self.checkbox2_MyEditBox3
    self.checkbox2_MyEditBox3:SetBackdrop(self.style.input)
    self.checkbox2_MyEditBox3:SetBackdropColor(0, 0, 0, 1)
    self.checkbox2_MyEditBox3:SetTextColor(1, 1, 1)
    self.checkbox2_MyEditBox3:SetFontObject("GameFontHighlight")
    self.checkbox2_MyEditBox3:SetMaxLetters(0)
    self.checkbox2_MyEditBox3:EnableMouse(true)
    self.checkbox2_MyEditBox3:SetMultiLine(true)
    self.checkbox2_MyEditBox3:SetWidth(self.Windows:GetWidth() - 30)
    self.checkbox2_MyEditBox3:SetHeight(280)
    self.checkbox2_MyEditBox3:SetPoint("TOPLEFT", self.button5, "BOTTOMLEFT", 0, -10)
    self.checkbox2_MyEditBox3:SetAutoFocus(false)
    self.checkbox2_MyEditBox3:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    self.checkbox2_MyEditBox3:SetScript("OnTextChanged", function()
        self.Windows:SetHeight(self.GetFrameHeight(self))
    end)
    self.checkbox2_MyEditBox3:Show()

    -- 读取团队人员名单写入到输入框中便于复制
    self.button8 = CreateFrame("Button", "huoqumingdan", self.Windows, "UIPanelButtonTemplate")
    self.page_content_table["button8"] = self.button8
    self.button8:SetWidth(150)
    self.button8:SetHeight(30)
    self.button8:SetPoint("TOPLEFT", self.checkbox2_MyEditBox3, "BOTTOMLEFT", 0, -10)
    self.button8:SetText("获取团队名单")
    self.button8:SetScript("OnClick", function()
        -- 读取团队人员名单写入到输入框中便于复制
        self.checkbox2_MyEditBox3:SetText(getraidnames())
        -- 获取当前控件的高度
        local height = self.checkbox2_MyEditBox3:GetHeight()
        -- 设置滚动框的高度
        self.checkbox2_MyEditBox3:SetHeight(height)
        self.Windows:SetHeight(self.GetFrameHeight(self))
    end)
end

-- 初始化屏蔽列表窗口函数
function zxqy_zidonggongju:pingbilistinit()
    -- 创建主框架
    self.pingbilist_frame = CreateFrame("Frame", "BlacklistFrame", UIParent)
    self.pingbilist_frame:SetWidth(400)
    self.pingbilist_frame:SetHeight(600)
    self.pingbilist_frame:SetPoint("CENTER", 0, 0)

    -- 创建背景
    self.pingbilist_frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })
    self.pingbilist_frame:SetBackdropColor(0, 0, 0, 0.5)

    -- 设置框架可移动
    self.pingbilist_frame:SetMovable(true)
    self.pingbilist_frame:EnableMouse(true)
    self.pingbilist_frame:RegisterForDrag("LeftButton")
    self.pingbilist_frame:SetScript("OnDragStart", function()
        this:StartMoving()
    end)
    self.pingbilist_frame:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)

    -- 创建关闭按钮
    self.pingbilist_frame.Windows1_closeButton = CreateFrame("Button", nil, self.pingbilist_frame, "UIPanelCloseButton")
    self.pingbilist_frame.Windows1_closeButton:SetPoint("TOPRIGHT", -1, -1)
    self.pingbilist_frame.Windows1_closeButton:SetScript("OnClick", function()
        this:GetParent():Hide()
    end)

    -- 创建标题
    self.pingbilist_frame.title = self.pingbilist_frame:CreateFontString(nil, "OVERLAY")
    self.pingbilist_frame.title:SetFontObject("GameFontHighlight")
    self.pingbilist_frame.title:SetPoint("TOP", self.pingbilist_frame, "TOP", 0, -10)
    self.pingbilist_frame.title:SetText("屏蔽列表")

    -- 创建滚动框架
    self.pingbilist_frame.scrollFrame = CreateFrame("ScrollFrame", "BlacklistScrollFrame", self.pingbilist_frame)
    -- self.pingbilist_frame.scrollFrame:SetAllPoints(self.pingbilist_frame)
    self.pingbilist_frame.scrollFrame:SetWidth(400)
    self.pingbilist_frame.scrollFrame:SetHeight(580)
    self.pingbilist_frame.scrollFrame:SetPoint("TOP", 0, -20)

    -- 创建可滚动区域
    self.pingbilist_frame.scrollChild = CreateFrame("Frame", nil, self.pingbilist_frame.scrollFrame)
    self.pingbilist_frame.scrollChild:SetWidth(400)
    self.pingbilist_frame.scrollChild:SetHeight(580)
    self.pingbilist_frame.scrollFrame:SetScrollChild(self.pingbilist_frame.scrollChild)

    -- 初始化滚动条位置
    self.pingbilist_frame.scrollFrame:SetVerticalScroll(0)
    -- 添加鼠标滚轮事件
    self.pingbilist_frame.scrollChild:EnableMouseWheel(true)
    self.pingbilist_frame.scrollChild:SetScript("OnMouseWheel", function()
        -- print("滚动条传参:" .. arg1)
        local newValue = self.pingbilist_frame.scrollFrame:GetVerticalScroll() - (arg1 * 100)
        if newValue < 0 then
            newValue = 0
        elseif newValue > self.pingbilist_frame.scrollChild:GetHeight() - self.pingbilist_frame.scrollFrame:GetHeight() then
            newValue = self.pingbilist_frame.scrollChild:GetHeight() - self.pingbilist_frame.scrollFrame:GetHeight()
        end
        self.pingbilist_frame.scrollFrame:SetVerticalScroll(newValue)
    end)

    -- 添加屏蔽名单输入框
    self.pingbilist_frame.input = CreateFrame("EditBox", nil, self.pingbilist_frame, "InputBoxTemplate")
    self.pingbilist_frame.input:SetWidth(200)
    self.pingbilist_frame.input:SetHeight(30)
    self.pingbilist_frame.input:SetPoint("TOPLEFT", self.pingbilist_frame, "BOTTOMLEFT", 10, 0)
    self.pingbilist_frame.input:SetAutoFocus(false)
    -- 搜索名称
    self.pingbilist_frame.input:SetScript("OnTextChanged", function()
        local name = this:GetText()
        if name ~= "" then
            -- print("搜索名称：" .. name)
            -- 搜索结果table
            local result = {}
            -- 遍历黑名单
            for keyname, _ in pairs(self.Option.blacklist) do
                -- 搜索字符串
                local startIndex, endIndex = string.find(keyname, name)
                -- 搜索
                if startIndex then
                    -- print("有结果：" .. keyname)
                    result[keyname] = true;
                end
            end
            -- 显示搜索结果
            self:pingbilist_UpdateBlacklist(self, result)
        end
    end)
    self.pingbilist_frame.input:SetScript("OnEscapePressed", function()
        this:ClearFocus()
    end)
    -- 添加回车提交
    self.pingbilist_frame.input:SetScript("OnEnterPressed", function()
        local name = this:GetText()
        if name ~= "" then
            this:SetText("")
            self.Option.blacklist[name] = true;
            self:SaveSettings(self)
            self:pingbilist_UpdateBlacklist(self, self.Option.blacklist)
        end
    end)

    -- 添加按钮
    self.pingbilist_frame.addButton = CreateFrame("Button", nil, self.pingbilist_frame, "GameMenuButtonTemplate")
    self.pingbilist_frame.addButton:SetWidth(80)
    self.pingbilist_frame.addButton:SetHeight(30)
    self.pingbilist_frame.addButton:SetPoint("TOPRIGHT", self.pingbilist_frame, "BOTTOMRIGHT", 0, 0)
    self.pingbilist_frame.addButton:SetText("添加")
    self.pingbilist_frame.addButton:SetScript("OnClick", function()
        local name = self.pingbilist_frame.input:GetText()
        if name ~= "" then
            self.Option.blacklist[name] = true;
            self.pingbilist_frame.input:SetText("")
            self:SaveSettings(self)
            self:pingbilist_UpdateBlacklist(self, self.Option.blacklist)
        end
    end)
    -- 初始化数据
    if not self.Option.blacklist then
        self.Option.blacklist = {};
    end
    -- 加载屏蔽列表
    self:pingbilist_UpdateBlacklist(self, self.Option.blacklist)
end

-- 更新屏蔽名单函数
function zxqy_zidonggongju:pingbilist_UpdateBlacklist(_, blacklist)
    -- 清空之前的屏蔽名单项
    for _, child in ipairs({self.pingbilist_frame.scrollChild:GetChildren()}) do
        child:Hide()
    end
    -- 序号
    local index = 1
    -- 累计高度
    local height = 0
    -- 创建新的屏蔽名单项
    for name, _ in pairs(blacklist) do
        print(name)
        -- 累加高度
        height = height + 32;
        local nameFrame = CreateFrame("Frame", nil, self.pingbilist_frame.scrollChild)
        nameFrame:SetWidth(380)
        nameFrame:SetHeight(30)
        nameFrame:SetPoint("TOP", 0, -((index - 1) * 32))

        local nameLabel = nameFrame:CreateFontString(nil, "OVERLAY")
        nameLabel:SetFontObject("GameFontNormal")
        nameLabel:SetPoint("LEFT", 10, 0)
        nameLabel:SetText(index .. ". " .. name)

        local removeButton = CreateFrame("Button", nil, nameFrame, "GameMenuButtonTemplate")
        removeButton:SetWidth(80)
        removeButton:SetHeight(30)
        removeButton:SetPoint("RIGHT", -10, 0)
        removeButton:SetText("删除")
        -- 创建一个新的闭包来捕获当前的 name 值
        local function createClickHandler(n)
            return function()
                -- print(n)
                self.Option.blacklist[n] = nil;
                self:SaveSettings(self)
                self:pingbilist_UpdateBlacklist(self, self.Option.blacklist)
            end
        end
        removeButton:SetScript("OnClick", createClickHandler(name))
        index = index + 1
    end
    -- 重新调整child高度
    self.pingbilist_frame.scrollChild:SetHeight(height)
end

-- 获取当前团队成员名单,返回字符串
function getraidnames()
    local raidname = ""
    for i = 1, 40 do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        -- print(tostring(name))
        -- print(tostring(rank))
        -- print(tostring(subgroup))
        -- print(tostring(level)) --级别
        -- print(tostring(class)) --职业
        -- print("职业:" ..tostring(fileName))
        -- print("职业:" ..fileName)
        -- print(tostring(zone)) --当前地区
        -- print(tostring(online)) --在线1离线0
        -- print(tostring(isDead))
        -- print(tostring(role))
        -- print(tostring(isML))
        if name == nil then
            break
        end
        -- 格式:职业-名称
        raidname = raidname .. getzhiyestr(fileName) .. "-" .. name .. " "
    end
    return raidname
end

function getzhiyestr(class)
    if class == "PRIEST" then
        return "牧师"
    elseif class == "ROGUE" then
        return "盗贼"
    elseif class == "WARRIOR" then
        return "战士"
    elseif class == "HUNTER" then
        return "猎人"
    elseif class == "WARLOCK" then
        return "术士"
    elseif class == "DRUID" then
        return "德鲁伊"
    elseif class == "PALADIN" then
        return "圣骑士"
    elseif class == "MAGE" then
        return "法师"
    end
end

-- 遍历打印 WebDKP_DkpTable
-- zxqy_print(WebDKP_Tables)
-- zxqy_print(WebDKP_Log)
-- for name,value in pairs(WebDKP_DkpTable) do
--     print("名字:" .. name)
--     print("dkp:" .. value["dkp_1"])
--     -- 是否选中
--     -- if value["Selected"] ~= nil then
--     --     print("Selected:" .. value["Selected"])
--     -- end
--     -- 职业
--     print("class:" .. value["class"])
--     -- for k,v in pairs(value) do
--     --     print("k:" .. tostring(k))
--     -- end
-- end

function zxqy_print(table)
    for key, value in pairs(table) do
        print("key:" .. tostring(key))
        if type(value) == "table" then
            zxqy_print(value)
        else
            print("value:" .. tostring(v))
        end
    end
end

function zxqy_zidonggongju:delgonghuichengyuan(int)
    -- 获取公会成员数量
    local numMembers = GetNumGuildMembers()
    -- print("公会成员数量:" .. numMembers)
    local tmp_log;
    -- 遍历公会成员并打印信息
    for i = 1, numMembers do
        local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName =
            GetGuildRosterInfo(i)
        -- 状态字符
        online = online and "在线" or "离线"
        -- 返回当前排序顺序中第一个成员自上次在线以来的时间。
        local old_nian, old_yue, old_ri, old_xiaoshi = GetGuildRosterLastOnline(i)
        old_nian, old_yue, old_ri, old_xiaoshi = old_nian and old_nian or 0, old_yue and old_yue or 0,
            old_ri and old_ri or 0, old_xiaoshi and old_xiaoshi or 0;
        -- 计算出总时长
        local z_xiaoshi = (((old_nian * 12) + old_yue) * 30.5 + old_ri) * 24 + old_xiaoshi;
        -- print("离线时间:" .. old_nian .. "年" .. old_yue .. "月" .. old_ri .. "日" .. old_xiaoshi ..
        --           "时" .. "总计时长:" .. z_xiaoshi .. "小时")
        -- print(name .. "|" .. online .. "|" .. rank )
        if online == "离线" and rank == "缘" then
            -- 总时长超过 480 小时则删除,就是20天
            if z_xiaoshi > 24 * int then
                -- 删除成员“name”。
                print("删除成员" .. name)
                GuildUninviteByName(name)
                -- break
            end
        end
    end
end

-- table键值互换
function tableduidiao(table)
    local newtable = {};
    for k, v in pairs(table) do
        newtable[v] = true;
    end
    return newtable;
end

function zxqy_zidonggongju:addgonghui(lv, jiange)
    -- 联盟种族
    local zhongzu = tableduidiao({"人类", "侏儒", "矮人", "高等精灵", "暗夜精灵"});
    -- zxqy_print(zhongzu)
    -- 区域
    -- request = 'z-"' .. request .. '"';
    -- 职业
    -- request = 'c-"' .. request .. '"';
    local minlevel = lv;
    local maxlevel = lv + jiange;
    -- 只搜索级别区域
    request = minlevel .. "-" .. maxlevel;
    print("搜索: " .. request);
    SendWho(request);
    -- 拿到搜索结果数量 numWhos ,服务器总数 totalCount
    -- numWhos, totalCount = GetNumWhoResults();
    -- print("搜索结果:numWhos"..numWhos..",totalCount:"..totalCount);
    -- 根据索引拿到详情
    -- name, guild, level, race, class, zone, classFileName = GetWhoInfo(1)
    -- 玩家名称
    -- print("name:"..name);
    -- 公会名称
    -- print("guild:"..guild);
    -- print("level:"..level);
    -- 种族
    -- print("race:"..race);
    -- 职业
    -- print("class:"..class);
    -- 所在地区
    -- print("zone:"..zone);
    local numWhos, totalCount = GetNumWhoResults();
    -- print("搜索结果:numWhos"..numWhos..",totalCount:"..totalCount);
    for i = 1, numWhos do
        local name, guild, level, race, class, zone, classFileName = GetWhoInfo(i)
        -- print(i);
        -- print("race:" .. tostring(zhongzu[race]))
        if zhongzu[race] and string.len(guild) == 0 and self.Option.GongHuiYaoQingOk[name] == nil and
            self.Option.blacklist[name] == nil then
            -- print("name:"..name..",race:"..race..",guild:"..guild..",level:"..level)
            -- 邀请入会
            GuildInviteByName(name)
            print("邀请入会:" .. name)
            self.Option.GongHuiYaoQingOk[name] = true;
            self.SaveSettings(self)
        end
    end
end
function zxqy_isgonghui()
    -- 拿到角色公会名称
    local guildName = GetGuildInfo("player")
    -- print("当前角色所在公会：" .. guildName)
    -- 如果不是再续前缘公会则不进行操作
    if guildName ~= "再续前缘" then
        return false
    end
    return true
end
-- 创建圆形按钮
function zxqy_zidonggongju:Createbutton2()
    -- 按钮大小
    local size = 32
    self.MiniMapButton = CreateFrame("Button", "MyAddonButton", UIParent, Minimap)
    -- self.MiniMapButton:SetFrameStrata("MEDIUM")
    -- self.MiniMapButton:SetFrameLevel(8)
    self.MiniMapButton:Raise()
    self.MiniMapButton:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 0, 0)
    -- 用于设置按钮的材质
    -- self.MiniMapButton:SetNormalTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    self.MiniMapButton:SetNormalTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
    -- 用于设置鼠标悬停在按钮上时的纹理材质
    self.MiniMapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    -- self.MiniMapButton:SetHighlightTexture("interface\\buttons\\iconborder-glowring")
    self.MiniMapButton:SetWidth(size)
    self.MiniMapButton:SetHeight(size)

    self.MiniMapButton:SetScript("OnClick", function()
        if not zxqy_isgonghui() then
            print("《再续前缘》公会专用工具,你不是此公会成员,无法使用")
            return
        end

        if self.is_show_windows then
            self.Windows_master:Hide()
            self.is_show_windows = false
        else
            -- print("当前窗口总高度：" .. self.GetFrameHeight(self))
            self.Windows:SetHeight(self.GetFrameHeight(self))
            self.Windows_master:Show()
            self.is_show_windows = true
        end
    end)

    -- 创建按钮的右键拖动事件
    self.MiniMapButton:SetMovable(true)
    self.MiniMapButton:SetClampedToScreen(true)
    self.MiniMapButton:SetScript("OnMouseDown", function()
        if arg1 == "RightButton" then
            self.MiniMapButton:StartMoving()
        end
    end)
    self.MiniMapButton:SetScript("OnMouseUp", function()
        self.MiniMapButton:StopMovingOrSizing()
    end)

    -- 创建按钮上的图标
    -- local icon = self.MiniMapButton:CreateTexture(nil, "BACKGROUND")
    -- icon:SetWidth(size)
    -- icon:SetHeight(size)
    -- icon:SetPoint("CENTER", self.MiniMapButton, "CENTER", 0, 0)
    -- icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    -- self.MiniMapButton.icon = icon

    -- 创建按钮上的文本
    local text = self.MiniMapButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER", self.MiniMapButton, "CENTER", 0, 0)
    text:SetText("缘")
    self.MiniMapButton.text = text

    -- 创建按钮上的提示
    self.MiniMapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.MiniMapButton, "ANCHOR_LEFT")
        GameTooltip:AddLine("《再续前缘》公会管理工具", 1, 1, 1)
        GameTooltip:AddLine("|cff1eff00左键:|r 隐藏/显示")
        GameTooltip:AddLine("|cff1eff00右键:|r 拖动按钮")
        GameTooltip:Show()
    end)
    self.MiniMapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

end

-- 通过判断全局变量 SUPERWOW_STRING 和 SUPERWOW_VERSION 来确定是否启用插件
function zxqy_zidonggongju:IsSuperWow()
    return SUPERWOW_VERSION ~= nil
end

-- 将WebDKP_DkpTable表转换为自定义格式字符串并保存到文件
function zxqy_zidonggongju:SaveDKPtoFile()
    -- 校验变量是否存在且为表类型
    if type(WebDKP_DkpTable) ~= "table" then
        print("DKP数据为空，保存失败")
        return
    end

    local content = ""
    -- 遍历每个玩家的数据
    for playername, playerdata in pairs(WebDKP_DkpTable) do
        -- 提取字段，设置默认值避免空值导致解析错误
        local dkp = playerdata.dkp_1 or 0
        local selected = tostring(playerdata.Selected or false)
        local class = playerdata.class or "未知职业"

        -- 拼接成行：玩家名|职业|dkp值|选中状态
        local line = string.format("%s|%s|%d|%s\n", playername, class, dkp, selected)
        content = content .. line
    end

    -- 保存到文件
    ExportFile(self.uid .. "-WebDKP_cache", content)
    print("DKP数据已保存（自定义格式）")
end

-- 从文件读取自定义格式数据并恢复为WebDKP_DkpTable表（适配无#符号）
function zxqy_zidonggongju:LoadDKPfromFile()
    -- 读取文件内容
    local content = ImportFile(self.uid .. "-WebDKP_cache")
    if not content or content == "" then
        print("未找到DKP缓存文件，加载失败")
        return
    end

    -- 初始化空表，覆盖原有有效数据
    WebDKP_DkpTable = {}

    -- 改用gfind按行分割内容（兼容Windows和Linux换行符）
    local lines = {}
    -- gfind是Lua 5.0的函数，替代gmatch实现行分割
    for line in string.gfind(content, "[^\r\n]+") do
        if line ~= "" then -- 跳过空行
            table.insert(lines, line)
        end
    end

    -- 解析每一行数据
    for _, line in ipairs(lines) do
        -- 改用gfind按|分割字段
        local parts = {}
        for part in string.gfind(line, "[^|]+") do
            table.insert(parts, part)
        end

        -- 移除#符号，改用自定义函数判断表长度
        local parts_count = 0
        for _, _ in pairs(parts) do
            parts_count = parts_count + 1
        end
        -- 校验字段数量，避免格式错误导致崩溃
        if parts_count >= 4 then
            local playername = parts[1]
            local class = parts[2]
            local dkp = tonumber(parts[3]) or 0
            -- 转换布尔值（兼容大小写，如True/TRUE/false）
            local selected = string.lower(parts[4]) == "true"

            -- 恢复为原表结构
            WebDKP_DkpTable[playername] = {
                ["dkp_1"] = dkp,
                ["Selected"] = selected,
                ["class"] = class
            }
        else
            print("解析失败，无效的行格式：" .. line)
        end
    end

    print("DKP数据已加载（自定义格式）")
end

-- 设置拾取人员的功能
function zxqy_SetLootMaster(unit)
    if UnitIsPlayer(unit) and UnitInRaid(unit) then
        local name = GetUnitName(unit, true)
        local raidIndex = UnitInRaid(unit)
        if raidIndex then
            SetLootMethod("master", name) -- 设置拾取人员
            print(name .. " 已被指定为装备拾取人员。")
        else
            print("错误：未找到团队成员。")
        end
    else
        print("错误：只能指定在线的团队成员为拾取人员。")
    end
end

-- 解散团队
function zxay_del_raid_names()
    for i = 1, 40 do
        local name1, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if name1 and rank ~= 2 then
            -- print("name:"..name1)
            -- print("rank:"..rank)
            -- print("subgroup:"..subgroup)
            -- print("level:"..level)
            print("删除队员:" .. name1)
            UninviteByName(name1)
        end
    end
end

-- 解散团队
function zxay_del_lixian_raid_names()
    for i = 1, 40 do
        local name1, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if name1 and online == nil then
            -- print("name:"..name1)
            -- print("online:"..online)
            -- print("rank:"..rank)
            -- print("subgroup:"..subgroup)
            -- print("level:"..level)
            print("剔掉暂离人员:" .. name1)
            UninviteByName(name1)
        end
    end
end

-- 向头像菜单中添加新的按钮
function AddCustomButtonToUnitPopup()
    UnitPopupButtons["ZXQY_JIESHAN"] = {
        text = "|cff1eff00[缘]解散团队",
        dist = 0,
        notCheckable = true
    }
    table.insert(UnitPopupMenus["SELF"], table.maxn(UnitPopupMenus["SELF"]), "ZXQY_JIESHAN")

    UnitPopupButtons["ZXQY_TIZANLI"] = {
        text = "|cff1eff00[缘]剔掉暂离人员",
        dist = 0,
        notCheckable = true
    }
    table.insert(UnitPopupMenus["SELF"], table.maxn(UnitPopupMenus["SELF"]), "ZXQY_TIZANLI")
end

-- 钩子 UnitPopup_OnClick 函数
hooksecurefunc("UnitPopup_OnClick", function(self)
    -- 获取当前点击的菜单项的文本
    -- local text = this:GetText()
    -- 获取点击的key
    local buttonkey = this.value;
    -- print("click text:" .. this.value)
    -- 检查是否是新选项
    if buttonkey == "ZXQY_JIESHAN" then
        zxay_del_raid_names()
    end
    if buttonkey == "ZXQY_TIZANLI" then
        zxay_del_lixian_raid_names()
    end
end)

-- 检查是否点击的是自己并在右键菜单中显示相应按钮
hooksecurefunc("UnitPopup_ShowMenu", function(dropdownMenu, which, unit, name, userData)
    -- 遍历所有可用的菜单类型
    -- print("which:" .. which)
    -- print("unit:" .. unit)
    -- print("dropdownMenu:" .. dropdownMenu)
    -- print("UnitPopupMenus:"..UnitPopupMenus["SELF"])
    -- 判断当前点击的单位是否为自己
    -- if which == "SELF" then
    -- end
    if which == "RAID" then
        -- 用于检查当前战利品分配方法的函数。它返回一个字符串，表示当前的分配方法，可能的值包括：
        -- freeforall：自由争夺
        -- roundrobin：轮流分配
        -- master：主人分配
        -- group：组队分配
        -- needbeforegreed：需要优先于贪婪
        -- personalloot：个人分配
        local lootMethod, lootMasterIndex = GetLootMethod()
        if "master" ~= lootMethod then
            return
        end
        local lootMasterName
        if lootMasterIndex and lootMasterIndex > 0 then
            lootMasterName = GetRaidRosterInfo(lootMasterIndex) -- 索引从0开始
        end
        local info = {}
        -- 是否在线
        local isOnline = UnitIsConnected(unit)
        if isOnline then
            if lootMasterName == name or (name == UnitName("player") and lootMasterIndex == 0) then
                info.text = "|cff1eff00[缘]已经是拾取人员"
                -- 靠左对齐
                info.notCheckable = true
                info.disabled = true
            else
                info.text = "[缘]提升为拾取人员"
                info.notCheckable = true
                info.func = function()
                    zxqy_SetLootMaster(unit)
                end
            end
        else
            info.text = "|cfff22c3d[缘]离线"
            info.notCheckable = true
            info.disabled = true
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- 创建对象
ZXQY = zxqy_zidonggongju:new(nil)
ZXQY:Init()

ZXQY.MiniMapButton:RegisterEvent("ADDON_LOADED") -- 每个插件加载完成后触发
ZXQY.MiniMapButton:RegisterEvent("PLAYER_ENTERING_WORLD") -- 注册监听进入世界
ZXQY.MiniMapButton:RegisterEvent("CHAT_MSG_WHISPER") -- 注册监听悄悄话事件
ZXQY.MiniMapButton:RegisterEvent("VARIABLES_LOADED") -- 变量加载完成后触发
ZXQY.MiniMapButton:SetScript("OnEvent", function()
    -- print("OnEvent：", event, arg1, arg2)
    -- print("is_shouren" , self.Option.is_shouren)
    -- 插件加载完成
    if event == "ADDON_LOADED" and arg1 == "ZXQY_auto" then
        ZXQY:LoadSettings()
        print("[再续前缘]自动工具加载完成")
        AddCustomButtonToUnitPopup()
        print("[再续前缘]分配拾取加载完成")
    end
    if event == "CHAT_MSG_WHISPER" and ZXQY.Option.is_shouren then
        if (ZXQY.Option.shouren_miyu ~= "*" and arg1 == ZXQY.Option.shouren_miyu) or ZXQY.Option.shouren_miyu == "*" then
            -- 为了防止冲突，这里延时执行
            -- C_Timer.After(2, function(arg2)
            -- print("邀请入会 " .. arg2 .. " 说:" .. arg1);
            -- 邀请入会
            GuildInviteByName(arg2)
            -- end)
        end
    end
    -- if event == "PLAYER_ENTERING_WORLD" then
    --     Print("插件加载完成，等待悄悄话");
    -- end
end)

-- 定时器
ZXQY.MiniMapButton:SetScript("OnUpdate", function()
    ZXQY:TimerFunc(arg1)
end)

-- 读取 /script print(SUPERWOW_VERSION)
-- /script print(ImportFile("test"))
-- 写入
-- /script print(ExportFile("test","32132132"))
-- ImportFile（“filename”） 读取 gamedirectory\imports 中的 txt 文件，并返回其内容的字符串。
-- ExportFile（“filename”， “text”） 在 gamedirectory\imports 中创建一个 txt 文件，并在其中写入文本。
