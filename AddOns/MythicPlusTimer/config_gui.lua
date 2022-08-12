-- 1.0
local addon_name, addon = ...
local config_gui = addon.new_module("config_gui")

-- ---------------------------------------------------------------------------------------------------------------------
local function on_input_enter(input)
  if not input.tooltip then
    return
  end

  GameTooltip:Hide()
  GameTooltip:ClearLines()
  GameTooltip:SetOwner(input, "ANCHOR_TOPLEFT")

  for _, v in pairs(input.tooltip) do
    GameTooltip:AddLine(v)
  end
  GameTooltip:Show()
end

-- ---------------------------------------------------------------------------------------------------------------------
local function hex_to_argb(hex)
  if string.len(hex) == 8 then
    return tonumber("0x" .. string.sub(hex, 1, 2)) / 255, tonumber("0x" .. string.sub(hex, 3, 4)) / 255, tonumber("0x" .. string.sub(hex, 5, 6)) / 255, tonumber("0x" .. string.sub(hex, 7, 8)) / 255
  else
    return 1, tonumber("0x" .. string.sub(hex, 1, 2)) / 255, tonumber("0x" .. string.sub(hex, 3, 4)) / 255, tonumber("0x" .. string.sub(hex, 5, 6)) / 255
  end
end

local function rgba_to_hex(r, g, b, a)
  r = math.ceil(255 * r)
  g = math.ceil(255 * g)
  b = math.ceil(255 * b)

  if a == nil then
    return string.format("FF%02x%02x%02x", r, g, b)
  end

  a = math.ceil(255 * a)
  return string.format("%02x%02x%02x%02x", a, r, g, b)
end

-- ---------------------------------------------------------------------------------------------------------------------
function config_gui.create_checkbox(name, text, checked, on_change, tooltip, parent)
  local checkbox_frame = CreateFrame("Frame", nil, parent)

  -- input
  local checkbox = CreateFrame("CheckButton", nil, checkbox_frame, "InterfaceOptionsCheckButtonTemplate")
  checkbox:SetPoint("TOPLEFT")
  checkbox:SetScript("OnClick", function(cb)
    on_change(cb.checkbox_name, cb:GetChecked())
  end)
  checkbox:SetChecked(checked)
  checkbox.checkbox_name = name

  checkbox.Text:SetText(text)
  checkbox.Text:SetWidth(checkbox.Text:GetStringWidth() + 20)
  -- tooltip
  checkbox.tooltip = tooltip

  checkbox:SetScript("OnEnter", on_input_enter)
  checkbox:SetScript("OnLeave", GameTooltip_Hide)

  checkbox_frame:SetWidth(checkbox:GetWidth() + checkbox.Text:GetStringWidth())
  checkbox_frame:SetHeight(checkbox:GetHeight())

  checkbox_frame.checkbox = checkbox

  return checkbox_frame
end

-- ---------------------------------------------------------------------------------------------------------------------
function config_gui.create_button(name, text, on_click, tooltip, parent)
  -- input
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetHeight(24)
  button:SetScript("OnClick", on_click)
  button.button_name = name

  button.Text:SetText(text)

  -- tooltip
  button.tooltip = tooltip

  button:SetScript("OnEnter", on_input_enter)
  button:SetScript("OnLeave", GameTooltip_Hide)

  return button
end

-- ---------------------------------------------------------------------------------------------------------------------
function config_gui.create_slider(text, on_change, min_value, max_value, step, value, tooltip, parent)
  -- input
  local slider_frame = CreateFrame("Frame", nil, parent)
  slider_frame:SetWidth(300)
  slider_frame:SetHeight(50)

  local slider_label = slider_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  local font_path, _, font_flags = slider_label:GetFont()
  slider_label:SetFont(font_path, 12, font_flags)
  slider_label:SetPoint("TOPLEFT", 5, 0)
  slider_label:SetText(text)

  local slider_backdrop = {
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    edgeSize = 8,
    tile = true,
    tileSize = 8,
    insets = {left = 3, right = 3, top = 6, bottom = 6},
  }

  local slider = CreateFrame("Slider", nil, slider_frame, BackdropTemplateMixin and "BackdropTemplate")
  local value_text = slider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  font_path, _, font_flags = value_text:GetFont()
  value_text:SetFont(font_path, 12, font_flags)

  min_value = min_value or 1
  max_value = max_value or 100
  step = step or 1
  value = value or 1

  slider:SetPoint("BOTTOMLEFT", 2, 18)
  slider:SetPoint("BOTTOMRIGHT", -2, 18)
  slider:SetHeight(17)
  slider:SetOrientation("HORIZONTAL")
  slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  slider:SetBackdrop(slider_backdrop)
  slider:EnableMouseWheel(true)
  slider:SetObeyStepOnDrag(true)
  slider:SetHitRectInsets(0, 0, -10, 0)
  slider:SetMinMaxValues(min_value, max_value)
  slider:SetValueStep(step)
  slider:SetValue(value)
  slider:SetScript("OnValueChanged", function(frame)
    local val = floor((frame:GetValue() - min_value) / step + 0.5) * step + min_value

    if val < min_value then
      val = min_value
    end

    if val > max_value then
      val = max_value
    end

    if tonumber(value_text:GetText()) ~= val then
      value_text:SetText(val)
      on_change(val)
    end
  end)

  value_text:SetPoint("TOP", slider, "BOTTOM")
  value_text:SetText(value)

  local min_text = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  font_path, _, font_flags = min_text:GetFont()
  min_text:SetFont(font_path, 10, font_flags)

  min_text:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, 3)
  min_text:SetText(min_value)

  local max_text = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  font_path, _, font_flags = max_text:GetFont()
  max_text:SetFont(font_path, 10, font_flags)
  max_text:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)
  max_text:SetText(max_value)

  -- tooltip
  slider.tooltip = tooltip

  slider:SetScript("OnEnter", on_input_enter)
  slider:SetScript("OnLeave", GameTooltip_Hide)

  return slider_frame
end

-- ---------------------------------------------------------------------------------------------------------------------
function config_gui.create_line(parent, height)
  local line_frame = CreateFrame("Frame", nil, parent)
  line_frame:SetHeight(height or 18)
  line_frame:SetPoint("LEFT", 0)
  line_frame:SetPoint("RIGHT", -13, 0)

  local line = line_frame:CreateTexture(nil, "BACKGROUND")
  line:SetHeight(8)
  line:SetPoint("LEFT", 3, 0)
  line:SetPoint("RIGHT", 0)
  line:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
  line:SetTexCoord(0.81, 0.94, 0.5, 1)

  return line_frame
end

-- ---------------------------------------------------------------------------------------------------------------------
function config_gui.create_color_picker(name, text, value, has_opacity, on_change, tooltip, parent)
  local picker_frame = CreateFrame("Button", nil, parent)
  picker_frame:SetWidth(350)
  picker_frame:SetHeight(24)

  picker_frame:EnableMouse(true)
  picker_frame:SetScript("OnClick", function()
    local on_color_picker_change = function(restore)
      local new_r, new_g, new_b, new_a;
      if restore then
        new_r, new_g, new_b, new_a = unpack(restore);
      else
        new_a, new_r, new_g, new_b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
      end

      picker_frame.color.value = {new_r, new_g, new_b, new_a}
      picker_frame.color:SetColorTexture(new_r, new_g, new_b, new_a)

      on_change(name, rgba_to_hex(new_r, new_g, new_b, new_a))
    end

    local r, g, b, a = unpack(picker_frame.color.value)

    ColorPickerFrame.hasOpacity = has_opacity
    ColorPickerFrame.opacity = a;
    ColorPickerFrame.previousValues = {r, g, b, a};
    ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = on_color_picker_change, on_color_picker_change, on_color_picker_change;
    ColorPickerFrame:SetColorRGB(r, g, b);
    ColorPickerFrame:Hide();
    ColorPickerFrame:Show();
  end)

  -- color
  local color = picker_frame:CreateTexture(nil, "OVERLAY")
  color:SetWidth(24)
  color:SetHeight(16)
  color:SetPoint("LEFT")

  local a, r, g, b = hex_to_argb(value)
  color.value = {r, g, b, a}
  color:SetColorTexture(r, g, b, a)

  picker_frame.color = color

  -- background
  local background = picker_frame:CreateTexture(nil, "BACKGROUND")
  background:SetWidth(24)
  background:SetHeight(16)
  background:SetTexture(188523)
  background:SetTexCoord(0.25, 0, 0.5, 0.25)
  background:SetDesaturated(true)
  background:SetVertexColor(1, 1, 1, 0.75)
  background:SetPoint("CENTER", color)
  background:Show()

  -- text
  local color_text = picker_frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  color_text:SetHeight(24)
  color_text:SetJustifyH("LEFT")
  color_text:SetPoint("LEFT", color, "RIGHT", 5, 0)
  color_text:SetText(text)
  color_text:Show()

  picker_frame.text = color_text

  -- tooltip
  picker_frame.tooltip = tooltip

  picker_frame:SetScript("OnEnter", on_input_enter)
  picker_frame:SetScript("OnLeave", GameTooltip_Hide)

  return picker_frame
end
