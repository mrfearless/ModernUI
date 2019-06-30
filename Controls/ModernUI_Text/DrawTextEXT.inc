;==============================================================================
;
; DrawTextEXT v1.0.0.0
;
; by mrfearless - www.github.com/mrfearless - http://www.LetTheLight.in
;
; Adapted from DrawHTML code posted by Ukkie9 
;
; https://www.codeproject.com/Articles/7936/DrawHTML
;
;==============================================================================



;==============================================================================
; DrawTextEXT
;==============================================================================
; Wrapper for calling DrawHTMLCODE or DrawBBCODE by specifying dwCodeType:
; 0 = DrawHTMLCODE
; 1 = DrawBBCODE
;------------------------------------------------------------------------------
; DrawTextEXT hdc, lpString, nCount, lpRect, uFormat, lpHyperLink, dwCodeType
;------------------------------------------------------------------------------
DrawTextEXT PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD 



;==============================================================================
; DrawHTMLCODE 
;==============================================================================
; Supports the following html tags, enclosed in angle brackets '<>' for 
; starting tags and '</>' for ending tags:
;
; - <b> </b>, <strong> </strong> for bolding text 
; - <i> </i>, <em> </em> for italic text
; - <u> </u> for underlined text
; - <sub> </sub> for subscript
; - <sup> </sup> for superscript
; - <pre> </pre>, <code> </code> for preformatted text
; - <br> for line breaks
; - <p> for paragraph breaks
; - <font color='#RRGGBB'> </font> for color of text using a hex string
; - <color='#RRGGBB'> </color> for color of text using a hex string
; - <q> </q>, <quote> </quote>, <blockq> </blockq> for block quotes
; - <ul> </ul> for unordered lists with bullets
; - <ol> </ol> for ordered lists with numbers
; - <li> </li> for list items within a list
; - <hr> </hr> for horizontal rule
; - <a href='url'>title</a> for hyperlinks having a url and title
;
; Note: Strings that include byte sequences of 13,10 (0D,0Ah) known as CRLF 
; or 10 (0Ah) known as LF, ARE IGNORED. Use the <br> or <p> if you wish to break
; to a new line.
;
; <a> tag supports internal ids if prefixed with a #, for example: 
;
; Click on this <a href="#1010">link</a> to show a message box
;
; The url title text is shown as 'link' and the id as #1010. When the url is 
; clicked, the id will be converted to an integer (1010) and send to the parent
; window via the WM_COMMAND message with the id integer stored in the high word 
; of wParam 
;
;------------------------------------------------------------------------------
; DrawHTMLCODE hdc, lpString, nCount, lpRect, uFormat, lpHyperLink
;------------------------------------------------------------------------------
DrawHTMLCODE PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD



;==============================================================================
; DrawBBCODE
;==============================================================================
; Supports the following bbcode tags, enclosed in aquare brackets '[]' for 
; starting tags and '[/]' for ending tags:
;
; - [b] [/b], <strong> </strong> for bolding text 
; - [i] [/i] for italic text
; - [u] [/u] for underlined text
; - [code] [/code] for preformatted text
; - [color=#RRGGBB] [/color] for color of text using a hex string
; - [q] [/q], [quote] [/quote] for block quotes *
; - [ul] [/ul] for unordered lists with bullets
; - [ol] [/ol] for ordered lists with numbers
; - [li] [/li] or [*] for list items within a list
; - [url] [/url] for hyperlinks having a url and title
;
; * Experimental/Not Complete
;
; Note: There is no bbcode for line breaks or paragraph. Strings that include 
; byte sequences of 13,10 (0D,0Ah) known as CRLF or 10 (0Ah) known as LF, are
; automatically processed to break to a new line.
; 
; [url] tag supports internal ids if prefixed with a #, for example: 
;
; Click on this [url=#1010]link[/url] to show a message box
;
; The url title text is shown as 'link' and the id as #1010. When the url is 
; clicked, the id will be converted to an integer (1010) and send to the parent
; window via the WM_COMMAND message with the id integer stored in the high word 
; of wParam 
;
;------------------------------------------------------------------------------
; DrawBBCODE hdc, lpString, nCount, lpRect, uFormat, lpHyperLink
;------------------------------------------------------------------------------
DrawBBCODE PROTO:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD 



;------------------------------------------------------------------------------
; DrawTextEXTLink Notification
;
; Send to the parent window via WM_NOTIFY with lParam a pointer to a NM_DTEL 
; structure. NM_DTEL.NMHDR.hdr.code will contain the notification code as
; defined below for: mouse over, mouse leave or mouse click.;
;
; Note: DrawTextEXTLink is a custom window that is created if a user passes a
; pointer to a DWORD variable in the lpHyperLink parameter of either 
; DrawHTMLCODE or DrawBBCODE. The variable will store the handle of the
; DrawTextEXTLink control for all future calls. If any url tags are used,
; DrawTextEXTLink creates an overlay made up of regions representing the 
; position of the url text, and draws the url text in these regions, along
; with the background, font etc. It handles cursor change, mouse over, and 
; click events for the hyperlink, along with notifications sent to the parent.
;
;------------------------------------------------------------------------------
LINKURL_MAXLENGTH       EQU 256 ; length of url text

IFNDEF LINKURL
LINKURL                 STRUCT
    rcLinkUrl           RECT <0,0,0,0>                  ; rect/rgn for linkurl
    szLinkUrl           DB LINKURL_MAXLENGTH DUP (0)    ; Url: 'www.site.com'
    szLinkTitle         DB LINKURL_MAXLENGTH DUP (0)    ; Title: 'MySite'
LINKURL                 ENDS
ENDIF

IFNDEF NM_DTEL
NM_DTEL                 STRUCT
    hdr                 NMHDR <>    ; Notify Header
    item                LINKURL <>  ; Link url information
NM_DTEL                 ENDS
ENDIF

; NM_DTEL.NMHDR.code values:
DTELN_MOUSEOVER         EQU 1   ; Mouse has moved over DrawTextEXTLink
DTELN_MOUSELEAVE        EQU 2   ; Mouse has left DrawTextEXTLink
DTELN_MOUSECLICK        EQU 3   ; User has clicked DrawTextEXTLink









