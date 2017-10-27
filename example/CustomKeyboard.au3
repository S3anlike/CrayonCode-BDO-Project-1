#include "../Telegram.au3"

$Token = '' ;Insert here your token
$ChatID = '' ;Your Chat ID
_InitBot($Token)

;Normal Keyboard
Local $normalKeyboard[4] = ['TopLeft','TopRight','','SecondRow']
Local $normalMarkup = _CreateKeyboard($normalKeyboard)
;ConsoleWrite($normalMarkup & @CRLF)
_SendMsg($ChatID,"This is a message with a custom keyboard.",Default,$normalMarkup)

;Inline Keyboard
Local $inlineKeyboard[4] = ['Yes','pressed_yes','No','pressed_no']
Local $inlineMarkup = _CreateInlineKeyboard($inlineKeyboard)
;ConsoleWrite($inlineMarkup & @CRLF)
_SendMsg($ChatID,"This is a message with an inline keyboard.",Default,$inlineMarkup)
