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
' create global artists object
'        
' ****************************************************************
function createArtistsCategoryObject(mainObject as object, index as integer) as object
    'print "createArtistsObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.mo = mainObject
    obj.filterIndex = index
    obj.filterName = "artists"
    obj.listItemIndex = 0
    obj.listItemIndexPrevious = 0

    obj.categoryPosterHandler = artistsCategoryPosterHandler

    obj.createContent = createArtistsContent
    obj.contentBufferWingSize = 10
    obj.contentBufferThreshold = 6
    obj.contentBufferSize = 20
    obj.contentArtistsMapStart = 0
    obj.contentArtistsMapEnd = 0
    obj.content = CreateObject("roArray", obj.contentBufferSize, true)

    aa = CreateObject("roAssociativeArray")
    aa.contentPosterHandler = invalid
    aa.obj = invalid
    obj.emptyPoster = createPosterObject("empty", "", "pkg:/images/empty.png", aa)

    return obj
end function

' ****************************************************************
'        
' artists category poster handler
'        
' ****************************************************************
sub artistsCategoryPosterHandler(index as integer)
    'print "artistsCategoryPosterHandler entry"

    m.listItemIndex = index

    poster = m.content[index]

    if (not poster.obj = invalid) and (not poster.obj.contentPosterHandler = invalid) then
        poster.obj.contentPosterHandler()
    end if
end sub

' ****************************************************************
'
' create artists content
'        
' ****************************************************************
function createArtistsContent() as boolean
    'print "createArtistsContent entry"

    if m.mo.musicXmlFlag then
        if m.listItemIndex > m.listItemIndexPrevious then
            listItemDirection = "up"
        else if m.listItemIndex < m.listItemIndexPrevious then
            listItemDirection = "down"
        else
            listItemDirection = "none"
        end if
        print "createArtistsContent: direction is "; listItemDirection

        ' initialization
        if m.content.Count() = 1 then
            'print "createArtistsContent: init"

            m.content.Clear()
            for i = 0 to (m.contentBufferSize - 1)
                artist = createArtistObject(m.mo, m.mo.artistsMap[i])
                m.content.Push(artist.contentPoster)
            end for
            m.contentArtistsMapStart = 0
            m.contentArtistsMapEnd = i
        
            return true

        ' poster within start threshold of artists map
        else if listItemDirection = "down" and (m.listItemIndex < m.contentBufferThreshold)
            if m.contentArtistsMapStart = 0 then
                m.listItemIndexPrevious = m.listItemIndex
                return false
            else
                m.contentArtistsMapStart = m.contentArtistsMapStart - 1 
                m.contentArtistsMapEnd = m.contentArtistsMapEnd - 1
                m.listItemIndex = m.listItemIndex + 1
                m.listItemIndexPrevious = m.listItemIndex + 1
                artist = createSongObject(m.mo, m.mo.artistsMap[m.contentArtistsMapStart])
                shiftUp(m.content)
                m.content.SetEntry(0, artist.contentPoster)
                return true
            end if
        
        ' poster within end threshold of artists map
        else if listItemDirection = "up" and (m.listItemIndex > (m.content.Count() - m.contentBufferThreshold)) then
            if m.contentArtistsMapEnd = (m.mo.artistsCount - 1) then
                m.listItemIndexPrevious = m.listItemIndex
                return false
            else
                m.contentArtistsMapEnd = m.contentArtistsMapEnd + 1
                m.contentArtistsMapStart = m.contentArtistsMapStart + 1
                m.listItemIndex = m.listItemIndex - 1
                m.listItemIndexPrevious = m.listItemIndex - 1 
                artist = createArtistObject(m.mo, m.mo.artistsMap[m.contentArtistsMapEnd])
                m.content.Shift()
                m.content.Push(artist.contentPoster)
                return true
            end if
        end if
    else
        m.content.Clear()
        m.content.Push(m.emptyPoster)
        return true
    end if

    return false
end function
