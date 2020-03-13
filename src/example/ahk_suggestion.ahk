;2020-02-01
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force ; Prevent double execution of this script
SetBatchLines, -1

Gui, MainUI:New,, % "Input Suggestions Test"
Gui, Font, s20
Gui, Add, Text,, Type something to get suggestions:

Gui, % "+Delimiter" . "`n"
CBBList :="`n" . "4200 Revenu (Général)"
		. "`n" . "4201 Vente"
		. "`n" . "4202 Service"
		. "`n" . "4203 Consultation"
		. "`n" . "4204 Location"
		. "`n" . "4205 Pourboire"
		. "`n" . "4210 Revenu d'Intérêt"
		. "`n" . "5700 Fourniture"
		. "`n" . "5701 Location Outils et équipement"
		. "`n" . "5721 Location Véhicule"
		. "`n" . "5722 Entretien Véhicule"
		. "`n" . "5723 Essence Véhicule"
		. "`n" . "5724 Frais de Déplacement"
		. "`n" . "5725 Télécommunication"
		. "`n" . "5726 Poste et Papeterie (matériel bureau)"
		. "`n" . "5784 Voyage Professionnel"
		. "`n" . "9999 Location Fees"
Gui, Add, ComboBox, vCBB y+5 w550 R7, % CBBList
CBBLabelFunction := Func("CBBLabel").Bind("`n")
GuiControl, +g, CBB, %CBBLabelFunction%

Gui, Add, ListBox, vsuggestionsListBox y+0 wp R7 +Hidden
Gui, Show
return


;--------------------------------------------------------------------------------
CBBLabel(ByRef listDelimiter) {
;--------------------------------------------------------------------------------
	GuiControlGet, userInput,  MainUI:, %A_GuiControl%
	hCB := getEditParentComboBoxHwnd()
	if ((!Trim(userInput)) or (!hCB)) {
		GuiControl, MainUI:Hide, suggestionsListBox
		Return
	}
	
	ControlGet, CBList, List,,, % "ahk_id "hCB
	suggestions := {}
	suggestions := GetInputSuggestions(userInput, CBList, listDelimiter, 7)
	if (suggestions["count"] >= 1) {
		GuiControl, MainUI:Show  , suggestionsListBox
		GuiControl, MainUI:  	 , suggestionsListBox, % listDelimiter . suggestions["list"]
		GuiControl, MainUI:Choose, suggestionsListBox, 1
	} else {
		GuiControl, MainUI:Choose, suggestionsListBox, 0
		GuiControl, MainUI:Hide, suggestionsListBox
	}
}


;--------------------------------------------------------------------------------
GetInputSuggestions(ByRef userInput, ByRef list, listDelimiter:="`n", maxReturnedSuggestions:=7) {
;--------------------------------------------------------------------------------
	/* 	Inputs: Currently typed text input and list of possible matches.
		* By default, list is delimited by "`n".
		Returns: An object containing the number of matches and the suggestions list.
		* By default, list is delimited by "`n".
		* There will be a maximum of maxReturnedSuggestions in that list.
	*/
	matches := {}
	for each, list_item in StrSplit(list, listDelimiter) {
		importance_factor := 0
		capsOnly := RegExReplace(list_item, "[^A-Z]")
		if ((StrLen(capsOnly) > 1) and RegExMatch(capsOnly, "^" . userInput . "$")) {
			matches_count++
			importance_factor := 10000
			matches.InsertAt(0, list_item) 
		} 
		else {
			word_matches_count := 0
			for index, word in StrSplit(list_item, A_Space) {
				if (RegExMatch(word, "^"userinput)) {
					word_matches_count++
					importance_factor := importance_factor + 9000 - (index * maxReturnedSuggestions)
				}
				else if (RegExMatch(word, "i)^" . userinput)) {
					word_matches_count++
					importance_factor := importance_factor + 8000 - (index * maxReturnedSuggestions)
				}
				else if (RegExMatch(word, ".*" . userinput . ".*")) {
					word_matches_count++
					importance_factor := importance_factor + 1000 - (index * maxReturnedSuggestions)
				}
				else if (RegExMatch(word, "i).*" . userinput . ".*")) {
					word_matches_count++
					importance_factor := importance_factor + 500 - (index * maxReturnedSuggestions)
				}
				else {
					importance_factor := importance_factor - index
				}
			}
			if (word_matches_count > 0) {
				matches_count++
				sorted_importance_list .= importance_factor . ","
				Sort sorted_importance_list, N R D,  ; Sort numerically, use comma as delimiter.
				for i, position in StrSplit(sorted_importance_list, ",") {
					if (position = importance_factor) {
						matches.InsertAt(i, list_item)
						Break
					}
				}
			}
		}
	}
	
	for each, item in matches {
		matches_list .= item . listDelimiter
	}
	return { "list": matches_list
		   , "count": matches_count }
}


;--------------------------------------------------------------------------------
getControlHwnd(ctrl) {
;--------------------------------------------------------------------------------
	ControlGet, hwnd, HWND,, %ctrl%
	return hwnd
}


;--------------------------------------------------------------------------------
getEditParentComboBoxHwnd() {
;--------------------------------------------------------------------------------
	static GA_PARENT = 1
	ControlGetFocus, focusedCtrl
	if (!RegExMatch(focusedCtrl, "Edit\d+")) {
		MsgBox % "Focused Control is not of class Edit - can't associate to a ComboBox"
		return
	}
	ControlGet, hEdit, HWND,, %focusedCtrl%
	return DllCall("user32\GetAncestor"
					, Ptr,hEdit
					, UInt,GA_PARENT)
}


; Inject Selected ListBox Suggestion to the ComboBox in which we type.
~Tab::
~Enter::
~NumpadEnter::
GuiControlGet, LBChoice, MainUI:, suggestionsListBox
GuiControl, MainUI:ChooseString, CBB, %LBChoice%
GuiControl, MainUI:Hide, suggestionsListBox
return


MainUIGuiEscape:
MainUIGuiClose:
ExitApp