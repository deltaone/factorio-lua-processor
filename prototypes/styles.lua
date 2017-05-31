local default_gui = data.raw["gui-style"].default

default_gui.label_style_1 = 
{
	type = "label_style",
	parent = "label_style",
	align = "center",
	minimal_height = 23,
	top_padding = 0, bottom_padding = 0,
	left_padding = 0, right_padding = 0,
}

default_gui.button_style_1 = 
{
	type = "button_style",
	parent = "button_style",

	font = "default-small-bold",
	top_padding = 2, bottom_padding = 2,
	--left_padding = 0, right_padding = 0,	
}

default_gui.wide_textbox_200 = 
{
	type = "textfield_style",
	parent = "textfield_style",
	minimal_width = 200,
	maximal_width = 200,  
}

default_gui.wide_textbox_400 = 
{
	type = "textfield_style",
	parent = "textfield_style",      
	minimal_width = 400,
	maximal_width = 400,  
}
