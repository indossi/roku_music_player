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
' create an album object
'
' ****************************************************************
function createAlbumObject(mo as object, mapEntry as object) as object
    'print "createAlbumObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.class = "album"
    obj.mo = mo

    obj.mapEntry = mapEntry
    obj.albumXml = mo.musicXml.artist[mapEntry.artistIndex].album[mapEntry.albumIndex]
    obj.name = obj.albumXml@name
    obj.artistXml = mo.musicXml.artist[mapEntry.artistIndex]
    obj.contentType = "audio"

    if Len(obj.albumXml@art) > 0 then
        obj.art = obj.albumXml@art
    else
        obj.art = mo.defaultSongArt
    end if

    obj.contentPoster = createAlbumContentPoster(obj)
    obj.contentPosterHandler = albumContentPosterHandler

    obj.contentScreen = invalid
    obj.contentScreenCreate = createAlbumContentScreen

    obj.isEqualTo = albumIsEqualTo
    obj.compareNameTo = albumCompareNameTo

    obj.songs = invalid
    aa = CreateObject("roAssociativeArray")
    aa.contentPosterHandler = playAllPosterHandler
    aa.album = obj
    obj.playAllPoster = createPosterObject("play all", "", "pkg:/images/playAll.png", aa)

    return obj
end function

' ****************************************************************
'
' create an album content poster 
'        
' ****************************************************************
function createAlbumContentPoster(album as object) as object
    'print "createAlbumContentPoster entry, name = "; album.name

    p = CreateObject("roAssociativeArray")
    p.ContentType = "audio"
    p.Title = album.name
    p.ShortDescriptionLine1 = album.name
    p.ShortDescriptionLine2 = album.artistXml@name
    p.HDPosterUrl = album.art
    p.SDPosterUrl = p.HDPosterUrl
    p.Description = ""
    p.Rating = ""
    p.StarRating = ""
    p.ReleaseDate = ""
    p.Length = 0
    p.Categories = []
    p.Categories.Push(album.name)
    p.Categories.Push(album.artistXml@name)

    p.obj = album

    return p
end function

' ****************************************************************
'        
' album content(songs) poster handler
'
' ****************************************************************
sub albumContentPosterHandler()
    'print "albumContentPosterHandler entry"

    if m.contentScreen = invalid then
        'print "albumContentPosterHandler: invalid content screen, name = "; m.name

        m.songs = createLinkedList(m.name + " songs")
        for each songXml in m.albumXml.song
            'print "adding song... "; songXml@name
            song = createSongObject(m.mo, m.mo.songsMap[(songXml@index).toInt()])
            m.songs.addTail(song)
        end for

        m.contentScreenCreate()
    end if

    m.contentScreen.Show()

    content = m.contentScreen.GetContentList()

    port = m.contentScreen.GetMessagePort()
    while true
        msg = wait(0, port)
        'print "content screen get selection type msg = "; type(msg)

        if msg.isScreenClosed() then
            return
        end if

        if type(msg) = "roPosterScreenEvent" then
            if msg.isListItemSelected() then
                content[msg.GetIndex()].obj.contentPosterHandler()
            end if
        end if
    end while
end sub

' ****************************************************************
'        
' create content screen for album songs
'
' ****************************************************************
sub createAlbumContentScreen()
    'print "createAlbumContentScreen entry"
    'print "createAlbumContentScreen album = " + m.name
    'print "createAlbumContentScreen artist = " + m.artistXml@name

    m.contentScreen = CreateObject("roPosterScreen")
    m.contentScreen.SetBreadcrumbText(m.name, m.artistXml@name)
    port = CreateObject("roMessagePort")
    m.contentScreen.SetMessagePort(port)
    m.contentScreen.SetListStyle("arced-portrait")

    content = CreateObject("roArray", m.songs.count() + 1, true)

    content.Push(m.playAllPoster)

    for each song in m.songs.getArray()
        content.Push(song.contentPoster)
    end for

    m.contentScreen.SetContentList(content)
end sub

' ****************************************************************
'
' play all poster handler
' 
' ****************************************************************
sub playAllPosterHandler()
    'print "playAllPosterHandler entry"
  
    index = -1
    action = "next"
    while true
        if action = "next" then
            index = index + 1
            if index = m.album.songs.count() then
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

        song = m.album.songs.get(index)
        action = song.contentPosterHandler()
    end while
end sub

' ****************************************************************
'
' check if album objects are the same
'        
' ****************************************************************
function albumIsEqualTo(obj as object) as boolean
    'print "albumIsEqualTo entry"

    if (obj.class = "album") and (m.name = obj.name) and (m.artistXml@name = obj.artistXml@name) then
        return true
    else
        return false
    end if
end function

' ****************************************************************
'
' compare given album object name
'        
' ****************************************************************
function albumCompareNameTo(obj as object) as integer
    'print "albumCompareTo entry"

    if m.class = obj.class then
        mName = UCase(m.name)
        objName = UCase(obj.name)

        if mName < objName then
            return -1
        else if mName = objName then
            return 0
        else if mName > objName then
            return 1
        end if
    else
        return invalid
    end if
end function
