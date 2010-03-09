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
' create an playlist category object
'
' ****************************************************************
function createPlaylistCategoryObject(mainObject as object, index as object) as object
    'print "createPlaylistCategoryObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.mo = mainObject
    obj.filterIndex = index
    obj.filterName = "playlist"
    obj.listItemIndex = 0

    obj.categoryPosterHandler = playlistCategoryPosterHandler

    obj.list = createLinkedList("playlist")
    obj.getList = function()
        return m.list
    end function
    obj.add = playlistAdd
    obj.delete = playlistDelete

    aa = CreateObject("roAssociativeArray")
    aa.contentPosterHandler = invalid
    aa.obj = invalid
    obj.emptyPoster = createPosterObject("empty", "", "pkg:/images/empty.png", aa)

    aa = CreateObject("roAssociativeArray")
    aa.contentPosterHandler = playlistPlayAllPosterHandler
    aa.playlist = obj
    obj.playAllPoster = createPosterObject("play all", "", "pkg:/images/playAll.png", aa)

    obj.content = CreateObject("roArray", 20, true)
    obj.content.Push(obj.emptyPoster)
    obj.createContent = playlistCreateContent

    return obj
end function

' ****************************************************************
'
' playlist category poster handler
'        
' ****************************************************************
sub playlistCategoryPosterHandler(index as integer)
    'print "playlistCategoryPosterHandler entry, index = "; index

    if index > m.getList().count() then
        return
    end if

    poster = m.content[index]

    if not poster.obj.contentPosterHandler = invalid then
        poster.obj.contentPosterHandler()
    end if
end sub

' ****************************************************************
'
' create playlist content
'        
' ****************************************************************
function playlistCreateContent() as boolean
    'print "playlistCreateContent entry"

    return true
end function

' ****************************************************************
'
' add song to playlist
'        
' ****************************************************************
sub playlistAdd(song as object)
    'print "playlistAdd entry"

    song.onPlaylist = true

    m.content.SetEntry(0, m.playAllPoster)

    m.getList().add(song)
    m.content.Push(song.contentPoster)
end sub

' ****************************************************************
'
' delete song from playlist
'        
' ****************************************************************
sub playlistDelete(song as object)
    'print "playlistAdd entry"

    song.onPlaylist = false

    index = m.getList().indexOf(song)
    m.getList().delete(index)
    m.content.Delete(index)

    if m.getList().count() = 0 then
        m.content.SetEntry(0, m.emptyPoster)
    end if
end sub

' ****************************************************************
'
' play all poster handler
' 
' ****************************************************************
sub playlistPlayAllPosterHandler()
    'print "playlistPlayAllPosterHandler entry"
  
    index = -1
    action = "next"
    while true
        if action = "next" then
            index = index + 1
            if index = m.playlist.getList().count() then
                return
            end if
        else if action = "previous" then
            index = index - 1
            if index < 0 then
                index = 0
            end if
        else if action = "up"
            return
        end if

        'print "playlistPlayAllPosterHandler: index = "; index
        song = m.playlist.getList().get(index)
        action = song.contentPosterHandler()
    end while
end sub
