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
' create an artist object
'        
' ****************************************************************
function createArtistObject(mo as object, mapEntry as object) as object
    'print "createArtistObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.class = "artist"
    obj.mo = mo

    obj.mapEntry = mapEntry
    obj.artistXml = mo.musicXml.artist[mapEntry.artistIndex]
    obj.name = obj.artistXml@name
    obj.contentType = "audio"
 
    obj.art = mo.defaultArtistArt
    for each albumXml in obj.artistXml.album
        if Len(albumXml@art) > 0 then
            obj.art = albumXml@art
            exit for
        end if
    end for

    obj.contentPoster = createArtistContentPoster(obj)
    obj.contentPosterHandler = artistContentPosterHandler

    obj.albums = invalid

    obj.content = invalid
    obj.contentScreen = invalid
    obj.contentScreenCreate = createArtistAlbumsContentScreen

    obj.isEqualTo = artistIsEqualTo
    obj.compareNameTo = artistCompareNameTo

    return obj
end function

' ****************************************************************
'
' create an artist content poster 
'        
' ****************************************************************
function createArtistContentPoster(artist as object) as object
    'print "createArtistContentPoster entry"

    p = CreateObject("roAssociativeArray")
    p.ContentType = "audio"
    p.Title = artist.name
    p.ShortDescriptionLine1 = artist.name
    p.ShortDescriptionLine2 = ""
    p.HDPosterUrl = artist.art
    p.SDPosterUrl = p.HDPosterUrl
    p.Description = ""
    p.Rating = ""
    p.StarRating = ""
    p.ReleaseDate = ""
    p.Length = 0
    p.Categories = []
    p.Categories.Push(artist.name)

    p.obj = artist

    return p
end function

' ****************************************************************
'        
' artist content(albums) poster handler
'
' ****************************************************************
sub artistContentPosterHandler()
    'print "artistContentPosterHandler entry"

    if m.contentScreen = invalid then
        'print "artistContenPosterHandler: invalid content screen, name = "; m.name

        m.albums = createLinkedList(m.name + " albums")
        for each albumXml in m.artistXml.album
            print "adding album... "; albumXml@name
            album = createAlbumObject(m.mo, m.mo.albumsMap[(albumXml@index).toInt()])
            m.albums.insertByName(album)
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
' create an artist content screen
'
' ****************************************************************
sub createArtistAlbumsContentScreen()
    print "createArtistAlbumsContentScreen entry"

    m.contentScreen = CreateObject("roPosterScreen")
    m.contentScreen.SetBreadcrumbText(m.name, "")
    port = CreateObject("roMessagePort")
    m.contentScreen.SetMessagePort(port)
    m.contentScreen.SetListStyle("arced-portrait")

    m.content = CreateObject("roArray", m.albums.count(), true)

    for each album in m.albums.getArray()
        m.content.Push(album.contentPoster)
    end for

    m.contentScreen.SetContentList(m.content)
end sub

' ****************************************************************
'
' check if artist objects are the same
'        
' ****************************************************************
function artistIsEqualTo(obj as object) as boolean
    'print "artistIsEqualTo entry"

    if (obj.class = "artist") and (m.name = obj.name) then
        return true
    else
        return false
    end if
end function

' ****************************************************************
'
' compare given artist object name
'        
' ****************************************************************
function artistCompareNameTo(obj as object) as integer
    'print "artistCompareNameTo entry"

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
