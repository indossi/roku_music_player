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
' main routine
'
' ****************************************************************
sub main()
    'print "main entry"

    mainObject = CreateObject("roAssociativeArray")
    mainObject.musicUrl = ""
    mainObject.musicFileName = "tmp:/music"
    mainObject.musicXml = createObject("roXMLElement")
    mainObject.musicXmlFlag = false

    mainObject.defaultArtistArt = "pkg:/images/artist.png"
    mainObject.defaultAlbumArt = "pkg:/images/album.png"
    mainObject.defaultSongArt = "pkg:/images/song.png"

    ' create category objects
    mainObject.catObjects = createObject("roArray", 4, true)

    mainObject.settings = createSettingsCategoryObject(mainObject, 0)
    mainObject.settings.createContent()
    mainObject.catObjects.Push(mainObject.settings)

    mainObject.songs = createSongsCategoryObject(mainObject, 1)
    mainObject.songs.createContent()
    mainObject.catObjects.Push(mainObject.songs)
    mainObject.songsMap = invalid
    mainObject.songsCount = 0

    mainObject.albums = createAlbumsCategoryObject(mainObject, 2)
    mainObject.albums.createContent()
    mainObject.catObjects.Push(mainObject.albums)
    mainObject.albumsMap = invalid
    mainObject.albumsCount = 0

    mainObject.artists = createArtistsCategoryObject(mainObject, 3)
    mainObject.artists.createContent()
    mainObject.catObjects.Push(mainObject.artists)
    mainObject.artistsMaps = invalid
    mainObject.artistsCount = 0

    mainObject.playlist = createPlaylistCategoryObject(mainObject, 4)
    mainObject.playlist.createContent()
    mainObject.catObjects.Push(mainObject.playlist)
    mainObject.playlistMaps = invalid

    mainObject.audioPlayer = createAudioPlayerObject()

    ' set application theme
    setTheme()

    ' show categories posters
    port = CreateObject("roMessagePort")
    mainObject.catScreen = CreateObject("roPosterScreen")
    mainObject.catScreen.SetMessagePort(port)
    mainObject.catScreen.SetListStyle("arced-portrait")
    mainObject.catScreen.SetFocusedListItem(0)
    mainObject.catScreen.SetContentList(mainObject.catObjects[0].content)

    mainObject.filterBannerNames = CreateObject("roArray", 4, true)
    mainObject.filterBannerNames.push(mainObject.catObjects[0].filterName)
    mainObject.filterBannerNames.push(mainObject.catObjects[1].filterName)
    mainObject.filterBannerNames.push(mainObject.catObjects[2].filterName)
    mainObject.filterBannerNames.push(mainObject.catObjects[3].filterName)
    mainObject.filterBannerNames.push(mainObject.catObjects[4].filterName)
    mainObject.catScreen.SetListNames(mainObject.filterBannerNames)
    mainObject.catScreen.SetFocusedList(0)
    mainObject.catScreen.SetBreadCrumbText(mainObject.catObjects[0].filterName, "")
    listIndex = 0

    mainObject.catScreen.Show()

    listSelected = false
    while true
        msg = wait(0, port)
        index = msg.GetIndex()
        print "main: category screen get selection type msg = "; type(msg); " index = "; index

        if msg.isScreenClosed() then
            return
        end if

        if type(msg) = "roPosterScreenEvent" then
            if msg.isListItemSelected() then
                print "isListItemSelected"
                obj = mainObject.catObjects[listIndex]
                if not obj = invalid then
                    obj.categoryPosterHandler(index)
                end if
            else if msg.isListFocused() then
                print "isListFocused"
                obj = mainObject.catObjects[index]
                mainObject.catScreen.SetBreadCrumbText(obj.filterName, "")

                obj.createContent()
 
                mainObject.catScreen.SetContentList(obj.content)
                mainObject.catScreen.SetFocusedListItem(obj.listItemIndex)
                mainObject.catScreen.Show()

                listSelected = false
            else if msg.isListSelected() then
                print "isListSelected"
                listIndex = index

                obj = mainObject.catObjects[index]
                mainObject.catScreen.SetFocusedListItem(obj.listItemIndex)

                listSelected = true
            else if listSelected then
                print "listSelected true"
                obj = mainObject.catObjects[listIndex]
                obj.listItemIndex = index
                if obj.createContent() then
                    mainObject.catScreen.SetContentList(obj.content)
                    mainObject.catScreen.SetFocusedListItem(obj.listItemIndex)
                    mainObject.catScreen.Show()
                    clearMessagePort(port)
                end if
            end if
        end if
    end while
end sub

' ****************************************************************
'
' set theme
'
' ****************************************************************
sub setTheme()
    'print "setTheme entry"

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "25"
    theme.OverhangSliceSD = "pkg:/images/Overhang_BackgroundSlice_Blue_SD43.png"
    theme.OverhangLogoSD  = "pkg:/images/Logo_Overhang_Roku_SDK_SD43.png"

    theme.OverhangOffsetHD_X = "123"
    theme.OverhangOffsetHD_Y = "48"
    theme.OverhangSliceHD = "pkg:/images/Overhang_BackgroundSlice_Blue_HD.png"
    theme.OverhangLogoHD  = "pkg:/images/Logo_Overhang_Roku_SDK_HD.png"

    app.SetTheme(theme)
end sub

' ****************************************************************
'
' create audio player object
'
' ****************************************************************
function createAudioPlayerObject() as object
    'print "createAudioPlayerObject entry"

    o = CreateObject("roAssociativeArray")
    o.addContent = audioPlayerAddContent
    o.setContentList = audioPlayerSetContentList
    o.getMessagePort = audioPlayerGetMessagePort
    o.setMessagePort = audioPlayerSetMessagePort
    o.playContent = audioPlayerPlayContent
    o.play = audioPlayerPlay
    o.stop = audioPlayerStop
    o.pause = audioPlayerPause
    o.resume = audioPlayerResume
    o.setState = audioPlayerSetState
    o.isPlaying = audioPlayerIsPlaying
    o.isStopped = audioPlayerIsStopped
    o.isPaused = audioPlayerIsPaused
    o.STOP_STATE = 0
    o.PLAY_STATE = 1
    o.PAUSE_STATE = 2
    o.state = o.STOP_STATE

    o.player = CreateObject("roAudioPlayer")
    port = CreateObject("roMessagePort")
    o.player.SetMessagePort(port)
    o.player.SetLoop(false)

    return o
end function

' ****************************************************************
'
' add audio player content
'
' ****************************************************************
sub audioPlayerAddContent(content as object)
    'print "audioPlayerAddContent entry"

    m.player.AddContent(content)
end sub

' ****************************************************************
'
' set audio player content list
'
' ****************************************************************
sub audioPlayerSetContentList(list as object)
    'print "audioPlayerContentList entry"

    m.player.SetContentList(list)
end sub

' ****************************************************************
'
' set audio player state
'
' ****************************************************************
sub audioPlayerSetState(newState as integer)
    'print "audioPlayerSetState entry"

    if newState = m.state then
        return
    end if

    if newState = m_PLAY_STATE or newState = m.PAUSE_STATE or newState = m.STOP_STATE then
        m.state = newState
    end if

    if newState = m.PLAY_STATE then
        if m.state = m.STOP_STATE
            m.player.Play()
        else if m.state = m.PAUSE_STATE
            m.player.Resume()
        end if
    else if newState = m.STOP_STATE
        m.player.Stop()
    else if newState = m.PAUSE_STATE then
        m.player.Pause()
    end if
end sub

' ****************************************************************
'
' play audio player content
'
' ****************************************************************
sub audioPlayerPlayContent(content as object)
    'print "audioPlayerPlayContent entry"

    m.player.SetContentList(content)
    m.state = m.PLAY_STATE
    m.player.Play()
end sub

' ****************************************************************
'
' play audio player
'
' ****************************************************************
sub audioPlayerPlay()
    'print "audioPlayerPlay entry"

    m.state = m.PLAY_STATE
    m.player.Play()
end sub

' ****************************************************************
'
' stop audio player
'
' ****************************************************************
sub audioPlayerStop()
    'print "audioPlayerStop entry"

    m.state = m.STOP_STATE
    m.player.Stop()
end sub

' ****************************************************************
'
' pause audio player
'
' ****************************************************************
sub audioPlayerPause()
    'print "audioPlayerPause entry"

    m.state = m.PAUSE_STATE
    m.player.Pause()
end sub

' ****************************************************************
'
' resume audio player
'
' ****************************************************************
sub audioPlayerResume()
    'print "audioPlayerResume entry"

    m.state = m.PLAY_STATE
    m.player.Resume()
end sub

' ****************************************************************
'
' set audio player message port
'
' ****************************************************************
sub audioPlayerSetMessagePort(port as object)
    'print "audioPlayerSetMessagePort entry"

    m.player.SetMessagePort(port)
end sub

' ****************************************************************
'
' set audio player message port
'
' ****************************************************************
function audioPlayerGetMessagePort() as object
    'print "audioPlayerGetMessagePort entry"

    return m.player.GetMessagePort()
end function

' ****************************************************************
'
' is audio player playing
'
' ****************************************************************
function audioPlayerIsPlaying() as boolean
    'print "audioPlayerIsPlaying"

    if m.state = m.PLAY_STATE then
        return true
    else
        return false
    end if
end function

' ****************************************************************
'
' is audio player stopped
'
' ****************************************************************
function audioPlayerIsStopped() as boolean
    'print "audioPlayerIsStopped"

    if m.state = m.STOP_STATE then
        return true
    else
        return false
    end if
end function

' ****************************************************************
'
' is audio player paused
'
' ****************************************************************
function audioPlayerIsPaused() as boolean
    'print "audioPlayerIsPaused"

    if m.state = m.PAUSE_STATE then
        return true
    else
        return false
    end if
end function
