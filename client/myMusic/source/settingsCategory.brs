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
' create global settings object
'        
' ****************************************************************
function createSettingsCategoryObject(mainObject as object, index as integer) as object
    'print "createSettingsCategoryObject entry"

    obj = CreateObject("roAssociativeArray")
    obj.mo = mainObject
    obj.filterIndex = index
    obj.filterName = "settings"
    obj.listItemIndex = 0

    obj.categoryPoster = createPosterObject("file url", "", "pkg:/images/xmlFile.png", obj)
    obj.categoryPosterHandler = settingsCategoryPosterHandler

    obj.content = invalid
    obj.createContent = createSettingsContent

    return obj
end function

' ****************************************************************
'
' settings category poster handler 
' 
' ****************************************************************
sub settingsCategoryPosterHandler(index as integer)
    'print "settingsCategoryPosterHandler entry"

    screen = CreateObject("roKeyboardScreen")
    port = CreateObject("roMessagePort")

    screen.SetMessagePort(port)
    screen.SetTitle("Xml Url Entry Screen")
    screen.SetText("http://192.168.1.11/pub/music.xml")
    screen.SetDisplayText("enter url of music xml file")
    screen.SetMaxLength(80)
    screen.AddButton(1, "done")
    screen.AddButton(2, "back")
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        
        if type(msg) = "roKeyboardScreenEvent" then
            if msg.isScreenClosed() then
                return
            else if msg.isButtonPressed() then
                'print "msg index ="; msg.GetIndex()
                if msg.GetIndex() = 1 then ' done button
                    m.mo.musicUrl = screen.GetText()
                    'print "remote db url = "; m.mo.musicUrl
                    exit while
                else if msg.GetIndex() = 2 then ' back button
                    return
                end if
            end if
        end if
    end while

    waitDialog = CreateObject("roOneLineDialog")
    waitDialog.SetTitle("processing music file(may take a few minutes)...")
    waitDialog.ShowBusyAnimation()
    waitDialog.Show()

    http = CreateObject("roUrlTransfer")
    print "remote db file name = "; m.mo.musicUrl
    http.SetUrl(m.mo.musicUrl)

    print "local db file name = "; m.mo.musicFileName
    response = http.GetToFile(m.mo.musicFileName)
    print "response = "; response

    m.mo.musicXml.Parse(ReadAsciiFile(m.mo.musicFileName))
    m.mo.musicXmlFlag = true

    m.mo.artistsCount = (m.mo.musicXml@artists).toInt()
    m.mo.artistsMap = CreateObject("roArray", m.mo.artistsCount, true)

    m.mo.albumsCount = (m.mo.musicXml@albums).toInt()
    m.mo.albumsMap = CreateObject("roArray", m.mo.albumsCount, true)

    m.mo.songsCount = (m.mo.musicXml@songs).toInt()
    m.mo.songsMap = CreateObject("roArray", m.mo.songsCount, true)

    for artistIndex = 0 to (m.mo.artistsCount - 1)
        artistXml = m.mo.musicXml.artist[artistIndex]
        print "adding artist "; artistXml@name
        artistEntry = CreateObject("roAssociativeArray")
        artistEntry.artistIndex = artistIndex
        m.mo.artistsMap.setEntry((artistXml@index).toInt(), artistEntry)

        for albumIndex = 0 to (artistXml.album.Count() - 1)
            albumXml = artistXml.album[albumIndex]
            albumEntry = CreateObject("roAssociativeArray")
            albumEntry.artistIndex = artistIndex
            albumEntry.albumIndex = albumIndex
            print "adding album "; albumXml@name
            m.mo.albumsMap.setEntry((albumXml@index).toInt(), albumEntry)
 
            for songIndex = 0 to (albumXml.song.Count() - 1)
                songXml = albumXml.song[songIndex]
                songEntry = createSongMapEntryObject(artistIndex, albumIndex, songIndex)
                m.mo.songsMap.setEntry((songXml@index).toInt(), songEntry)
            end for
        end for
    end for

    ' shuffle all entry
    m.mo.songsMap.setEntry(0, invalid)

    print "available artists = "; m.mo.artistsCount
    print "available albums = "; m.mo.albumsCount
    print "available songs = "; m.mo.songsCount

    waitDialog.Close()
end sub

' ****************************************************************
'
' create settings content
'        
' ****************************************************************
function createSettingsContent() as boolean
    'print "createSettingsContent entry"

    m.content = CreateObject("roArray", 1, false)
    aa = CreateObject("roAssociativeArray")
    aa.contentPosterHandler = m.categoryPosterHandler
    aa.obj = m
    p = m.categoryPoster
    m.content.Push(p)

    return false
end function
