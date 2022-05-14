local styles = data.raw["gui-style"].default

styles["tro_trades_list"] = {
    type = "scroll_pane_style",
    horizontally_stretchable = "on"
}

styles["tro_trade_row"] = {
    type = "frame_style",
    horizontally_stretchable = "on",
}

styles["tro_trade_row_flow"] = {
  type = "horizontal_flow_style",
  horizontally_stretchable = "on",
  vertical_align = "center"
}

styles["tro_trade_group"] = {
    type = "frame_style"
}

styles["tro_trade_group_button"] = {
    type = "button_style",
}