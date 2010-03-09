'**********************************************************
' myMusic - audio player application
'
' Copyright (c) 2010 Indossi Ruscelli (indossiruscelli@gmail.com)
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.

' ****************************************************************
'
' create a song map entry object
'        
' ****************************************************************
function createSongMapEntryObject(artistIndex as integer, albumIndex as integer, songIndex as integer) as object
    'print "createSongMapEntryObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.artistIndex = artistIndex
    obj.albumIndex = albumIndex
    obj.songIndex = songIndex

    obj.isEqualTo = songMapEntryIsEqualTo
    obj.compareNameTo = songMapEntryCompareNameTo

    return obj
end function

' ****************************************************************
'
' check if song map entry objects are the same
'        
' ****************************************************************
function songMapEntryIsEqualTo(obj as object) as boolean
    'print "songMapEntryIsEqualTo entry"

    if (m.artistIndex = obj.artistIndex) and (m.albumIndex = obj.albumIndex) and (m.songIndex = obj.songIndex) then
        return true
    else
        return false
    end if
end function

' ****************************************************************
'
' compare given song map entry object
'        
' ****************************************************************
function songMapEntryCompareNameTo(obj as object) as integer
    'print "songMapEntryCompareNameTo entry"

    if m.artistIndex < obj.artistIndex then
        return -1
    else if m.artistIndex > obj.artistIndex then
        return 1
    else
        if m.albumIndex < obj.albumIndex then
            return -1
        else if m.albumIndex > obj.albumIndex then
            return 1
        else
            if m.songIndex < obj.songIndex then
                return -1
            else if m.songtIndex > obj.songtIndex then
                return 1
            else
                return 0
            end if
        end if
    end if
end function
