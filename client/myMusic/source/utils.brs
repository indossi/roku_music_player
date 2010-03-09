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
' clear a message port 
'
' ****************************************************************
sub clearMessagePort(port as object)
    'print "clearMessagePort"

    while true
        msg = wait(500, port)
        if msg = invalid then
            return
        end if
    end while
end sub

' ****************************************************************
' 
' shift up each array entry by one index 
'
' ****************************************************************
sub shiftUp(array as object)
    for i = (array.Count()-1) to 1 step -1
       array[i] = array[i-1] 
    end for
end sub

' ****************************************************************
' 
' mininum integer function 
'
' ****************************************************************
function min(int1 as integer, int2 as integer) as integer
    if int1 < int2 then
        return int1
    else
        return int2
    end if
end function
