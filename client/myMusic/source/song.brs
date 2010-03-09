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
' create a song object
'        
' ****************************************************************
function createSongObject(mo as object, mapEntry as object) as object
    'print "createSongObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.class = "song"
    obj.mo = mo
    obj.player = mo.audioPlayer

    obj.mapEntry = mapEntry
    obj.songXml = mo.musicXml.artist[mapEntry.artistIndex].album[mapEntry.albumIndex].song[mapEntry.songIndex]
    obj.name = obj.songXml@name
    obj.artistXml = mo.musicXml.artist[mapEntry.artistIndex]
    obj.albumXml = mo.musicXml.artist[mapEntry.artistIndex].album[mapEntry.albumIndex]
    obj.contentType = "audio"
    obj.url = obj.songXml@url
    obj.trackId = (obj.songXml@track).toInt()
    obj.format = obj.songXml@format
    obj.length = (obj.songXml@length).toInt()
    obj.onPlaylist = false

    if Len(obj.albumXml@art) > 0 then
        obj.art = obj.albumXml@art
    else
        obj.art = mo.defaultSongArt
    end if

    obj.content = CreateObject("roAssociativeArray")
    obj.content.url = obj.url
    obj.content.streamFormat = obj.format

    obj.contentList = CreateObject("roArray", 1, false)
    obj.contentList.Push(obj.content)

    obj.contentPoster = invalid
    obj.contentPosterHandler = songSpringboardHandler
    obj.createContentPoster = createSongContentPoster
    obj.createContentPoster()

    obj.springboard = invalid
    obj.createSpringboard = createSongSpringboard
    obj.setSpringboardButtonDisplay = setSongSpringboardButtonDisplay

    obj.isEqualTo = songIsEqualTo
    obj.compareNameTo = songCompareNameTo

    return obj
end function

' ****************************************************************
'
' create a song content poster 
'        
' ****************************************************************
sub createSongContentPoster()
    'print "createSongContentPoster entry"

    m.contentPoster = CreateObject("roAssociativeArray")
    m.contentPoster.ContentType = "audio"
    m.contentPoster.Title = m.name
    m.contentPoster.ShortDescriptionLine1 = m.name
    m.contentPoster.ShortDescriptionLine2 = m.artistXml@name
    m.contentPoster.HDPosterUrl = m.art
    m.contentPoster.SDPosterUrl = m.contentPoster.HDPosterUrl
    m.contentPoster.Description = ""
    m.contentPoster.Rating = ""
    m.contentPoster.StarRating = ""
    m.contentPoster.ReleaseDate = ""
    m.contentPoster.Length = 0
    m.contentPoster.Categories = []
    m.contentPoster.Categories.Push(m.name)
    m.contentPoster.Categories.Push(m.artistXml@name)
    m.contentPoster.Categories.Push(m.albumXml@name)

    m.contentPoster.obj = m
end sub

' ****************************************************************
'
' create a song springboard 
'        
' ****************************************************************
sub createSongSpringboard()
    'print "createSongSpringboard entry"

    port = CreateObject("roMessagePort")
    m.springboard = CreateObject("roSpringboardScreen")
    m.springboard.SetTitle(m.name)
    m.springboard.SetBreadCrumbText(m.artistXml@name, m.albumXml@name)
    m.springboard.SetBreadCrumbEnabled(true)
    m.springboard.SetMessagePort(port)
    m.springboard.SetDescriptionStyle("audio")
    m.springboard.SetProgressIndicatorEnabled(true)
    m.springboard.SetStaticRatingEnabled(false)

    c = CreateObject("roAssociativeArray")
    c.ContentType = "audio"
    c.Title = m.name
    c.HDPosterUrl = m.art
    c.SDPosterUrl = c.HDPosterUrl
    c.StreamUrls = CreateObject("roArray", 1, true)
    c.StreamUrls.push(m.url)
    c.StreamFormat = m.format
    c.Length = m.length
    c.Actors = CreateObject("roArray", 2, true)
    c.Actors.push(m.name)
    c.Actors.push(m.albumXml@name)
    c.Album = m.albumXml@name
    c.Artist = m.artistXml@name

    m.springboard.SetContent(c)

    m.setSpringboardButtonDisplay()
end sub

' ****************************************************************
'
' song springboard handler
'        
' ****************************************************************
function songSpringboardHandler() as string
    print "songSpringboardHandler entry, song = "; m.name; ", artist = "; m.artistXml@name

    m.createSpringboard()
    m.springboard.Show()
    port = m.player.getMessagePort()
    m.springboard.SetMessagePort(port)
    clearMessagePort(port)
    m.player.playContent(m.contentList)
    m.setSpringboardButtonDisplay()

    c = m.contentList.GetEntry(0)
    print "content url = "; c.url
    
    progress = 0
    timeout = 1000
    m.springboard.SetProgressIndicator(progress, m.length)
    while true
        msg = wait(timeout, port)

        if not msg = invalid then
	    'print "songSpringboardHandler: msg = "; msg.GetMessage(); " index = "; msg.GetIndex()
        end if
        
        if m.player.isPlaying() then
            progress = progress + (timeout/1000)
            m.springboard.SetProgressIndicator(progress, m.length)
        end if

        if type(msg) = "roAudioPlayerEvent" then
            if msg.isListItemSelected() then
                print "songSpringboardHandler: song started"
            else if msg.isStatusMessage() then
                'print "songSpringboardHandler: status msg "; msg.GetMessage()
            else if msg.isRequestSucceeded() then
                print "songSpringboardHandler: song ended"
                m.player.stop()
                m.springboard.Close()
                return "next"
            else if msg.isRequestFailed() then
                print "songSpringboardHandler: request failed: "; msg.GetData()
                if not msg.GetData() = 0 then
                    m.player.stop()
                    m.springboard.Close()
                    return "next"
                end if
            else if msg.isFullResult() then
                print "songSpringboardHandler: full result"
            else if msg.isPartialResult() then
                print "songSpringboardHandler: partial result"
            else
                print "songSpringboardHandler: message ignored: "; msg.GetType()
            end if
        else if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed() then
                'print "songSpringboardHandler: screen closed"
                m.player.stop()
                m.springboard.Close()
                return "up"
            else if msg.isRemoteKeyPressed() then
                key = msg.GetIndex()
                'print "songSpringboardHandler: remote key = "; key
                if key = 5 then 'go to next song
                    m.player.stop()
                    m.springboard.Close()
                    return "next"
                else if key = 4 'go to previous song
                    m.player.stop()
                    m.springboard.Close()
                    return "previous"
                end if
            else if msg.isButtonPressed() then
                button = msg.GetIndex()
                'print "songSpringboardHandler: button = "; button
                if button = 1 then ' play/pause/resume button
                    if m.player.isStopped() then
                        m.player.play()
                        m.setSpringboardButtonDisplay()
                    else if m.player.isPaused()
                        m.player.resume()
                        m.setSpringboardButtonDisplay()
                    else if m.player.isPlaying()
                        m.player.pause()
                        m.setSpringboardButtonDisplay()
                    end if
                else if button = 2 then ' stop button
                    m.player.stop()
                    m.springboard.Close()
                    return "up"
                else if button = 3 then ' go to album button
                    m.player.stop()
                    m.springboard.Close()
                    m.album.contentPosterHandler()
                    return "up"
                else if button = 4 then ' go to artist button
                    m.player.stop()
                    m.springboard.Close()
                    m.artist.contentPosterHandler()
                    return "up"
                else if button = 5 then ' playlist add/remove button
                    if m.onPlaylist = false then
                        m.mo.playlist.add(m)
                    else
                        m.mo.playlist.delete(m)
                    end if
                    m.setSpringboardButtonDisplay()
                end if
            end if
        else if msg = invalid then
            'print "songSpringboardHandler: invalid msg"
        end if
    end while

    return "next"
end function

' ****************************************************************
'
' set button display
'        
' ****************************************************************
sub setSongSpringboardButtonDisplay()
    'print "setSongSpringboardButtonDisplay entry"

    if m.springboard = invalid then
        return
    end if

    m.springboard.ClearButtons()

    if m.player.isPlaying() then
        m.springboard.AddButton(1, "pause")
        m.springboard.AddButton(2, "stop")
    else if m.player.isPaused() then
        m.springboard.AddButton(1, "resume")
        m.springboard.AddButton(2, "stop")
    else if m.player.isStopped() then
        m.springboard.AddButton(1, "play")
        m.springboard.AddButton(2, "")
    end if

    m.springboard.AddButton(3, "go to album")
    m.springboard.AddButton(4, "go to artist")

    if m.onPlaylist = false then
        m.springboard.AddButton(5, "add to playlist")
    else
        m.springboard.AddButton(5, "remove from playlist")
    end if
end sub

' ****************************************************************
'
' check if song objects are the same
'        
' ****************************************************************
function songIsEqualTo(obj as object) as boolean
    'print "songIsEqualTo entry"

    if (obj.class = "song") and (m.name = obj.name) and (m.albumXml@name = obj.albumXml@name) and (m.artistXml@name = obj.artistXml@name) then
        return true
    else
        return false
    end if
end function

' ****************************************************************
'
' compare given song object name
'        
' ****************************************************************
function songCompareNameTo(obj as object) as integer
    'print "songCompareNameTo entry"

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

' ****************************************************************
'
' create song map entry
'        
' ****************************************************************
function createSongMapEntry(artistIndex as integer, albumIndex as integer, songIndex as Integer) as object
    'print "createSongMapEntry entry"

    entry = CreateObject("roAssociativeArray")
    entry.artistIndex = artistIndex
    entry.albumIndex = albumIndex
    entry.songIndex = songIndex

    return entry
end function
