;  Intellitype: typing aid 
;  Press 1 to 0 keys to autocomplete the word upon suggestion 
;  (0 will match suggestion 10) 
;                                  - Jordi S 
;                               Heavily modified by:
;                               Maniac
;___________________________________________ 

;    CONFIGURATIONS 

; Editor Window Recognition 
; (make it blank to make the script seek all windows) 

#SingleInstance, force
OnExit, SaveScript
ETitle =

;Minimum word length to make a guess 
WLen = 3 
keyagain= 
key= 
clearword=1 
;Gosub,clearallvars   ; clean vars from start 

; Press 1 to 0 keys to autocomplete the word upon suggestion 
; (0 will match suggestion 10) 
;_______________________________________ 

CoordMode, ToolTip, Relative 
AutoTrim, Off

WordListDone = 0

FileEncoding, UTF-8

;reads list of words from file 
Loop, Read,  %A_ScriptDir%\Wordlist.txt    
{ 
   addword = %a_loopreadline%
   Gosub, addwordtolist
} 
SetTimer, Winchanged, 100 
GoSub, ReverseWordNums
WordlistDone = 1

Loop 
{ 
   ;Editor window check 
    WinGetActiveTitle, ATitle 
    WinGet, A_id, ID, %ATitle% 
    IfNotInString, ATitle, %ETitle% 
    { 
      ToolTip 
      Setenv, Word, 
      WinWaitActive, %ETitle%
      Continue 
  } 
    
   ;Get one key at a time 
   Input, chr, L1 V,{enter}{space}.;`,:¿?¡!'"()]{}{}}{bs}{{}{esc}{tab}{Home}{End}{PgUp}{PdDn}{Up}{Dn}{Left}{Right} 
   EndKey = %errorlevel% 
   ; If active window has different window ID from before the input, blank word 
   ; (well, assign the number pressed to the word)    
   WinGetActiveTitle, ATitle 
   WinGet, A_id2, ID, %ATitle% 
   IfNotEqual, A_id, %A_id2% 
   { 
      Gosub,clearallvars 
      Setenv, Word, %chr% 
      Continue 
   } 
   
   ifequal, OldCaretY,
        OldCaretY = %A_CaretY%
   ifnotequal, OldCaretY, %A_CaretY%
   {
      ; add the word if switching lines
      addword = %Word%
      Gosub, addwordtolist
         Gosub,clearallvars
         Setenv, Word, %chr%
         Continue
         
   }
   
   OldCaretY=%A_CaretY%
   
      ;Backspace clears last letter 
   ifequal, EndKey, Endkey:BackSpace
   {
      StringLen, len, Word
      IfNotEqual, len, 0
      { 
         ifequal, len, 1   
         { 
            Gosub,clearallvars
         } else {
                  StringTrimRight, Word, Word, 1
                }     
      }
   } else ifequal, EndKey, Max
         {
            Setenv, Word, %word%%chr%
         } else {
                  addword = %Word%
                  Gosub, addwordtolist
                  Gosub, clearallvars     
                }
    
   ;Wait till minimum letters 
   IF ( StrLen(Word) < wlen )
   {
      ToolTip,
      Continue
   } 
    
   ;Match part-word with command 
   Num = 
   Match = 
   singlematch = 0 
   number = 0 
   StringLeft, baseword, Word, %wlen%
   baseword := ConvertWordToAscii(baseword,1)
   Loop
   {
      IfEqual, zword%baseword%%a_index%,, Break
      IfEqual, number, 10
         Break
      if ( SubStr(zword%baseword%%a_index%, 1, StrLen(Word)) = Word )
      {
         number ++
         singlematch := zword%baseword%%a_index%
         match := match . Mod(number,10) . ". " . singlematch . "`n"
         singlematch%number% = %singlematch%
            
         Continue            
      }
   }
   
   ;If no match then clear Tip 
   IfEqual, Match, 
   { 
      clearword=0 
      Gosub,clearallvars 
      Continue 
   } 
    
   ;Show matched command 
   StringTrimRight, match, match, 1        ; Get rid of the last linefeed 
   WinGetActiveTitle, ATitle 
   WinGetPos, , PosY, , SizeY, %ATitle%
   ToolTipSizeY := (number * 12)
   ToolTipPosY := A_CaretY+14
   if ((ToolTipSizeY + ToolTipPosY) > (PosY + SizeY))
       ToolTipPosY := (A_CaretY - 14 - ToolTipSizeY)
   IfNotEqual, Word,,ToolTip, %match%, %A_CaretX%, %ToolTipPosY%
   ; +14 Move tooltip down a little so as not to hide the caret. 
} 

; Timed function to detect change of focus (and remove tooltip when changing active window) 
Winchanged: 
   WinGetActiveTitle, ATitle 
   WinGet, A_id3, ID, %ATitle% 
   IfNotEqual, A_id, %A_id3% 
   { 
      ToolTip ,
   } else {
            ; If we are in the correct window, and OldCaretY is set, clear the tooltip if not in the same line
            IfInString, ATitle, %ETitle%
            {
               IfNotEqual, OldCaretY,
               {
                  IfNotEqual, OldCaretY, %A_CaretY%    
                  {
                     ToolTip,
                  }
               }
            }
         }
   Return
    
; Key definitions for autocomplete (0 to 9) 
#MaxThreadsPerHotkey 1 
$1:: 
key=1 
Gosub, checkword 
Return 

$2:: 
key=2 
Gosub, checkword 
Return 

$3:: 
key=3 
Gosub, checkword 
Return 

$4:: 
key=4 
Gosub, checkword 
Return 

$5:: 
key=5 
Gosub, checkword 
Return 

$6:: 
key=6 
Gosub, checkword 
Return 

$7:: 
key=7 
Gosub, checkword 
Return 

$8:: 
key=8 
Gosub, checkword 
Return 

$9:: 
key=9 
Gosub, checkword 
Return 

$0:: 
key=10 
Gosub, checkword 
Return 


; If hotkey was pressed, check wether there's a match going on and send it, otherwise send the number(s) typed 
checkword: 
   clearword=1 

   ; If active window has different window ID from before the input, blank word 
   ; (well, assign the number pressed to the word) 
   WinGetActiveTitle, ATitle 
   WinGet, A_id2, ID, %ATitle% 
   IfNotEqual, A_id, %A_id2% 
      { 
         if key =10 
            key = 0 
         BlockInput, On
         SendInput,%key% 
         BlockInput, Off
         Gosub,clearallvars 
         Return 
      } 
      
   IfNotEqual, OldCaretY, %A_CaretY% ;Make sure we are still on the same line
      { 
         if key =10 
            key = 0 
         BlockInput, On
         SendInput,%key% 
         BlockInput, Off
         Gosub,clearallvars 
         Return 
      } 

   ifequal, Word,        ; only continue if word is not empty 
   { 
      if key =10 
         key = 0 
      BlockInput, On
      SendInput,%key% 
      BlockInput, Off
      Setenv, Word, %key% 
      clearword=0 
      Gosub,clearallvars 
      Return 
   } 
   
   ifequal, singlematch%key%,   ; only continue singlematch is not empty 
      { 
         if key =10 
         BlockInput, On
         SendInput,%key% 
         BlockInput, Off
         Setenv, Word, %word%%key% 
         clearword=0 
         Gosub,clearallvars 
         Return 
      } 

   ; SEND THE WORD! 
   if key =0 
      key = 10 
   sending := singlematch%key%
   StringLen, len, Word 
   ; Update Typed Count
   UpdateWordCount(sending)   
   BlockInput, On
   SendInput, {BS %len%}{Raw}Hello ; First do the backspaces, Then send word (Raw because we want the string exactly as in wordlist.txt) 
   BlockInput, Off
   Gosub,clearallvars 
   Return 


; This is to blank all vars related to matches, tooltip and (optionally) word 
clearallvars: 
      Ifequal,clearword,1
      {
         Setenv,word,   
         OldCaretY=
      }
      ToolTip 
      ; Clear all singlematches 
      Loop, 10 
      { 
         singlematch%a_index% = 
      } 
      sending = 
      key= 
      match= 
      clearword=1 
      Return
;expects a value in addword
addwordtolist:
   Ifequal, Addword,  ;If we have no word to add, skip out.
      Return
   if ( Substr(addword,1,1) = ";" ) ;If first char is ";", clear word and skip out.
   {
      IfEqual, wordlistdone, 0 ;If we are still reading the wordlist file and we come across ;LEARNEDWORDS; set the LearnedWordsCount flag
      {
         IfEqual, AddWord, `;LEARNEDWORDS`;
            LearnedWordsCount=0
      }
      addword =
      Return
   }
   ifequal, wordlistdone, 1 ;if we are not reading the wordlist file, use the following characters in the terminate list
         CharTerminateList = 1,2,3,4,5,6,7,8,9,0
   else CharTerminateList = 
   if addword contains %CharTerminateList% ;if one of the chars in the word is in the terminate list, don't add it
   {
      addword =
      CharTerminateList = 
      Return
   }
   CharTerminateList =
   IF ( StrLen(addword) <= wlen ) ; don't add the word if it's not longer than the minimum length
   {
      addword =
      Return
   }

   Base := ConvertWordToAscii(SubStr(addword,1,wlen),1)
   AddWordInList =
   Loop ;Check to see if the word is already in the list, case sensitive
   {
      IfEqual, zword%base%%a_index%,, Break
      if ( zword%base%%a_index% == Word )
      {
         AddWordInList = 1
         Break
      }            
      Continue            
   }
      
   ifequal, AddWordInList,   ; if the word is not in the list
   {
      IfEqual, WordListDone, 0 ;if this is read from the wordlist
      {
         IfNotEqual,LearnedWordsCount,  ;if this is a stored learned word
         {
            CountWord := ConvertWordToAscii(addword,0)
            IfEqual, LearnedWords,     ;if we haven't learned any words yet, set the LearnedWords list to the new word
            {
               LearnedWords = %addword%  
            } else {   ;otherwise append the learned word to the list
                     LearnedWords = %LearnedWords%,%addword% 
                  }
            zCount%CountWord% := LearnedWordsCount++    ;increment the count and store the Weight of the LearnedWord in reverse order (will be inverted later)
         }
      } else {    ; If this is an on-the-fly learned word
               CountWord := ConvertWordToAscii(addWord,0)
               zCount%CountWord% = 1   ;set the count to one as it's the first time we typed it
               IfEqual, LearnedWords,    ;if we haven't learned any words yet, set the LearnedWords list to the new word
               {
                  LearnedWords = %addword%  
               } else {   ;otherwise append the learned word to the list
                        LearnedWords = %LearnedWords%,%addword%
                     }
            }
      ; Increment the counter for each hash
      zbasenum%Base%++        
      pos := zbasenum%Base%
      ; Set the hashed value to the word
      zword%Base%%pos% = %addword%
      pos = 
   } Else {
            IfEqual, WordListDone, 1   ;if we've already typed the word and we've loaded the wordlist increment the count
            {
               UpdateWordCount(addword)
            }
         }
   
   CountWord = 
   AddWordInList =
   addword = 
   Base =
   Return
   
; This sub will reverse the read numbers since now we know the total number of words
ReverseWordNums:
LearnedWordsCount+=4
Loop,parse,LearnedWords, `,
{
   AsciiWord := ConvertWordToAscii(A_LoopField,0)
   zCount%AsciiWord% := LearnedWordsCount - zCount%AsciiWord%
}

AsciiWord = 
LearnedWordsCount = 

Return

UpdateWordCount(word)
{
; If the Count for the word already exists - ie if it's a learned word, increment it, else don't.
   local CountWord := ConvertWordToAscii(word,0)
   IfNotEqual, zCount%CountWord%,
   {
      zCount%CountWord%++  
      local WordBase
      StringLeft, WordBase, word, %wlen% ;find the pseudohash for the word
      WordBase := ConvertWordToAscii(WordBase,1)
      Local ConvertWord = 
      Local LowIndex = 
      Local WordList = 
      Loop
      {
         ifequal, zword%WordBase%%A_Index%, ;Break the loop if no more words to read for the hash
            Break
         CountWord := zword%WordBase%%A_Index% ;Set CountWord to the current Word position
         ConvertWord := ConvertWordToAscii(CountWord,0) ; Find the Ascii equivalent of the word
         IfNotEqual, zCount%ConvertWord%,  ;If there's no count for this word do nothing
         {
            IfEqual, LowIndex,
               LowIndex = %A_Index% ;If this is the first word we've found with a count set this as our starting position
            
            IfEqual, WordList,  ;if we have no words in our wordlist, start it - prefix all words with (Count"z")
            {
               WordList := zCount%ConvertWord% . "z" . CountWord
            } Else {  ;else append to the wordlist
                     WordList := WordList . "," . zCount%ConvertWord% . "z" . CountWord
                  }
         }
      }
      
      ifnotequal, Wordlist, ;If we have no words to process, don't
      {
         Sort, WordList, N R D, ;Sort the wordlist by order of 
         
         LowIndex-- ;A_Index starts at 1 so this value needs to be decremented
         Local IndexPos = 
         Loop, Parse, WordList, `,
         {
            IndexPos := LowIndex + A_Index ;Set the current word we are processing to the starting pos plus word position
            StringTrimLeft, CountWord, A_LoopField, InStr(A_LoopField,"z") ;Strip (Number,"z") from beginning
            zword%WordBase%%IndexPos% = %CountWord% ; update the word in the list
            
         }
      }
   }
   Return
}
      
ConvertWordToAscii(Base,Caps)
{
; Return the word in Ascii numbers padded to length 3 per character
; Capitalize the string if NoCaps is not set
   IfEqual, Caps, 1
      StringUpper, Base, Base
   Loop, % StrLen(Base)
   {
      New := New . PadZeros(Asc(Base),3)
      StringTrimLeft, Base, Base, 1
   }
Return New
}

PadZeros(Word,Length)
{
; Pad a string out to Length numbers of 0's
   StringLen, WordLen, Word
   IfLess, WordLen, Length
   {
      Loop, % (Length - WordLen)
      {
         Word := "0" . Word
      }
   }
Return Word
}      
   
SaveScript:
; Delete the Temp_Wordlist if it exists
FileDelete, %A_ScriptDir%\Temp_WordList.txt
; Add all the standard words to the tempwordlist
Loop, Read, %A_ScriptDir%\Wordlist.txt, %A_ScriptDir%\Temp_WordList.txt
{
   IfEqual, A_LoopReadLine, `;LEARNEDWORDS`;
      SkipRest = 1
   IfEqual, SkipRest,
      FileAppend, %A_LoopReadLine%`n
}
; Parse the learned words and store them in a new list by count if their total count is greater than 5.
; Prefix the word with the count and "z" for sorting
Loop, Parse, LearnedWords, `,
{
   SortWord := ConvertWordToAscii(A_LoopField,0)
   
   IfGreaterOrEqual, zCount%SortWord%, 5
   {
      IfEqual, SortWordList, 
      {
         SortWordList := zCount%SortWord% . "z" . A_LoopField
      } else {
               SortWordList := SortWordList . "," . zCount%SortWord% . "z" . A_LoopField
            }
   }
}

Sort, SortWordList, N R D, ; Sort numerically, comma delimiter

IfNotEqual, SortWordList, ; If SortWordList exists write to the file, otherwise don't.
{
   FileAppend, `;LEARNEDWORDS`;`n, %A_ScriptDir%\Temp_WordList.txt

   FirstTimeLoop = 1
   Loop, Parse, SortWordList, `,
   {
      StringTrimLeft, AppendWord, A_LoopField, InStr(A_LoopField,"z") ;Strip (Number,"z") from beginning
      IfEqual, FirstTimeLoop,  ;If we are not in our first time through the loop append a new line before the word
      {
         AppendWord = `n%AppendWord%
      } else {
               FirstTimeLoop =
            }
      FileAppend, %AppendWord%, %A_ScriptDir%\Temp_WordList.txt
   }

   FileCopy, %A_ScriptDir%\Temp_WordList.txt, %A_ScriptDir%\WordList.txt, 1 ;Only update the file if we have learned words

}

FileDelete, %A_ScriptDir%\Temp_WordList.txt ;Delete the Tempwordlist as we no longer need it

ExitApp