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
' create global songs object
'        
' ****************************************************************
function createSongsCategoryObject(mainObject as object, index as integer) as object
    'print "createSongsCategoryObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.mo = mainObject
    obj.filterIndex = index
    obj.filterName = "songs"
    obj.listItemIndex = 0
    obj.listItemIndexPrevious = 0

    obj.categoryPosterHandler = songsCategoryPosterHandler
 
    obj.createContent = createSongsContent
    obj.contentBufferWingSize = 10
    obj.contentBufferThreshold = 6
    obj.contentBufferSize = 20
    obj.contentSongsMapStart = 0
    obj.contentSongsMapEnd = 0
    obj.content = CreateObject("roArray", obj.contentBufferSize, true)

    aa = CreateObject("roAssociativeArray")
    aa.contentPosterHandler = invalid
    aa.obj = invalid
    obj.emptyPoster = createPosterObject("empty", "", "pkg:/images/empty.png", aa)

    aa = CreateObject("roAssociativeArray")
    aa.contentPosterHandler = shufflePosterHandler
    aa.mo = obj.mo
    obj.shufflePoster = createPosterObject("shuffle", "", "pkg:/images/shuffle.png", aa)

    return obj
end function

' ****************************************************************
'
' songs category poster handler
'        
' ****************************************************************
sub songsCategoryPosterHandler(index as integer)
    print "songsCategoryPosterHandler entry, index = "; index

    m.listItemIndex = index

    poster = m.content[index]

    if (not poster.obj = invalid) and (not poster.obj.contentPosterHandler = invalid) then
        poster.obj.contentPosterHandler()
    end if
end sub

' ****************************************************************
'
' create songs content
'        
' returns true if content has changed
' ****************************************************************
function createSongsContent() as boolean
    print "createSongsContent entry, index = "; m.listItemIndex; ", previous = "; m.listItemIndexPrevious

    if m.mo.musicXmlFlag then
        if m.listItemIndex > m.listItemIndexPrevious then
            listItemDirection = "up"
        else if m.listItemIndex < m.listItemIndexPrevious then
            listItemDirection = "down"
        else
            listItemDirection = "none"
        end if
        print "createSongsContent: direction is "; listItemDirection

        ' initialization
        if m.content.Count() = 1 then
            'print "createSongsContent: init"

            m.content.Clear()
            m.content.Push(m.shufflePoster)
        
            for i = 1 to (m.contentBufferSize - 1)
                song = createSongObject(m.mo, m.mo.songsMap[i])
                m.content.Push(song.contentPoster)
            end for
            m.contentSongsMapStart = 0
            m.contentSongsMapEnd = i
        
            return true

        ' poster within start threshold of songs map
        else if listItemDirection = "down" and (m.listItemIndex < m.contentBufferThreshold)
            if m.contentSongsMapStart = 0 then
                m.listItemIndexPrevious = m.listItemIndex
                return false
            else if m.contentSongsMapStart = 1 then
                m.contentSongsMapStart = 0 
                m.contentSongsMapEnd = m.contentSongsMapEnd - 1
                m.listItemIndex = m.listItemIndex + 1
                m.listItemIndexPrevious = m.listItemIndex
                shiftUp(m.content)
                m.content.SetEntry(0, m.shufflePoster)
                return true
            else
                m.contentSongsMapStart = m.contentSongsMapStart - 1 
                m.contentSongsMapEnd = m.contentSongsMapEnd - 1
                m.listItemIndex = m.listItemIndex + 1
                m.listItemIndexPrevious = m.listItemIndex + 1 
                song = createSongObject(m.mo, m.mo.songsMap[m.contentSongsMapStart])
                shiftUp(m.content)
                m.content.SetEntry(0, song.contentPoster)
                return true
            end if
        
        ' poster within end threshold of songs map
        else if listItemDirection = "up" and (m.listItemIndex > (m.content.Count() - m.contentBufferThreshold)) then
            if m.contentSongsMapEnd = (m.mo.songsCount - 1) then
                m.listItemIndexPrevious = m.listItemIndex
                return false
            else
                m.contentSongsMapEnd = m.contentSongsMapEnd + 1
                m.contentSongsMapStart = m.contentSongsMapStart + 1
                m.listItemIndex = m.listItemIndex - 1
                m.listItemIndexPrevious = m.listItemIndex - 1 
                song = createSongObject(m.mo, m.mo.songsMap[m.contentSongsMapEnd])
                m.content.Shift()
                m.content.Push(song.contentPoster)
                return true
            end if
        end if
    else
        m.content.Clear()
        m.content.Push(m.emptyPoster)
        return true
    end if

    m.listItemIndexPrevious = m.listItemIndex 
    return false
end function

' ****************************************************************
'
' songs shuffle poster handler
' 
' ****************************************************************
sub shufflePosterHandler()
    print "shufflePosterHandler entry"
  
    playList = createRandomPlayList(m.mo.songsMap, min(100, m.mo.songsMap.Count()))
 
    index = -1
    action = "next"
    while true
        if action = "next" then
            index = index + 1
            if index = playList.count() then
                playList = createRandomPlayList(m.mo.songsMap, min(100, m.mo.songsMap.Count()))
                index = 0
            end if
        else if action = "previous" then
            index = index - 1
            if index < 0 then
                index = 0
            end if
        else if action = "up"
            return
        end if

        'print "shufflePosterHandler: index = "; index
        songsMapEntry = playList.get(index)
        song = createSongObject(m.mo, songsMapEntry)
        action = song.contentPosterHandler()
    end while
end sub

' ****************************************************************
'
' create a playlist of random songs
'        
' ****************************************************************
function createRandomPlayList(songsMap as object, size as integer) as object
    'print "createRandomPlayList entry, songs count = "; songsMap.count()

    playlist = createLinkedList("random playlist")

    if songsMap.Count() < size then
        size = songsMap.Count()
    end if

    for index = 0 to (size - 1)
        rand = Rnd(songsMap.Count()) - 1
        songEntry = songsMap.GetEntry(rand)
        if playlist.indexOf(songEntry) = -1 then
            playlist.add(songEntry)
            'print "added song = "; song.name; " at index = "; index
            index = index + 1
        end if
    end for

    return playlist
end function
