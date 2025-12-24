#Requires AutoHotkey v2.0

class ButtonExtensions {
	static IMAGE_BITMAP := 0, IMAGE_ICON := 1
	
	static __New() {
		Gui.Button.Prototype.DefineProp("SetImage", 
			{ Call: (self, hImg, imgType := 0) => ButtonExtensions.SetImage(self, hImg, imgType) })
		Gui.Button.Prototype.DefineProp("GetImage", 
			{ Call: (self, imgType := 0) => ButtonExtensions.GetImage(self, imgType) })
	}

	/**
	 * Adds an image to a button. This image must be either an icon or a bitmap. If the button has no text,
	 * the style BS_IMAGE or BS_ICON is added to get it to display the image - note that this will prevent 
	 * text from ever appearing on the button. To display both an Image and text, set the button's text before 
	 * setting its image, or set remove the style later. Note also that setting an image will throw off 
	 * AutoHotKey's automatic button size calculations, you'll need to set the width of the button manually.
	 * 
	 * @param {Gui.Button} btn Button control to set the image for
	 * @param {Integer} imgHandle Handle of the image to assign to the button. Get this from `LoadImage()`.
	 * @param {Integer} imgType Type of the image. This defaults to 0 (bitmap). You can get this value by
	 * 			setting &OutImageType when calling `LoadPicture`, but note that buttons only support bitmaps 
	 * 			or icons, so it may be best to omit the parameter and allow AutoHotKey to convert the image to
	 * 			a bitmap automatically.
	 * @returns {Integer} A handle to the image previously associated with the button, if any; otherwise, it is 0.
	 */
	static SetImage(btn, imgHandle, imgType := 0){
		;https://ecs.syr.edu/faculty/fawcett/handouts/Coretechnologies/windowsprogramming/WinUser.h
		static BM_SETIMAGE := 0x00F7						;Message number
		static BS_BITMAP := 0x0080, BS_ICON := 0x0040		;Image styles determine whether an image is shown
		
		if(imgType != ButtonExtensions.IMAGE_BITMAP && imgType != ButtonExtensions.IMAGE_ICON)
			throw ValueError("Invalid image type. Buttons can only contain bitmaps or icons. LoadImage will convert images to bitmaps when &OutImageType is omitted", , imgType)
		
		;If button has no text we need to add a style to get it to show an image
		if(btn.text == "")
			btn.Opt(imgType == ButtonExtensions.IMAGE_BITMAP? BS_BITMAP : BS_ICON)
		
        A_LastError := 0
        
		oldHandle := SendMessage(BM_SETIMAGE, imgType, imgHandle, btn.hwnd)
		if(A_LastError)
			throw OSError()
		
		return oldHandle
	}
	
	/**
	 * Retrieves a handle to the image (icon or bitmap) associated with a button.
	 * 
	 * @param {Gui.Button} btn Button control to get the image of
	 * @param {Integer} imgType The type of image you expect to be assosciated with the button. 
	 * 			0 for a bitmap, 1 for an icon.
	 * @returns {Integer} The handle of the image assosciated with the button, or 0 if one does not exist.
	 */
	static GetImage(btn, imgType := ButtonExtensions.IMAGE_BITMAP){
	;https://learn.microsoft.com/en-us/windows/win32/controls/bm-getimage
		static BM_GETIMAGE := 0x00F6
        
        A_LastError := 0
        
		imgHandle := SendMessage(BM_GETIMAGE, imgType, 0, btn.hwnd)
		if(A_LastError)
			throw OSError()
		return imgHandle
	}
}

;@Ahk2Exe-IgnoreBegin
;Test code loads an icon and assigns it to a couple of buttons
if(A_ScriptName == "ButtonExtensions.ahk"){
	testGui := Gui("+Resize", "Test Gui")
	imgTxtBtn := testGui.AddButton("vTestButtonImgAndTxt w120", " Image and Text!")
	imgOnlyBtn := testGui.AddButton("vTestButtonImgOnly", "")
	testbtn2 := testGui.AddButton("vNoImgBtn w100", "No image button :(")

	hImg := LoadPicture("F:\EPIC\AutoHotKey\Experimental\tbeloney\res\crashycrashy.ico", "", &imgType)

    imgTxtBtn.SetImage(hImg, imgType)
    setImgHandle := imgTxtBtn.GetImage()
    imgOnlyBtn.setimage(setImgHandle, imgType)

	testGui.AddText("vhandleText", Format("Loaded picture handle: 0x{1:X}`nRetrieved picture handle: 0x{2:X}", hImg, setImgHandle))

	testGui.Show()
}
;@Ahk2Exe-IgnoreEnd
