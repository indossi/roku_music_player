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
' create a linked list object 
'
' ****************************************************************
function createLinkedList(name as string) as object
    'print "createLinkedList entry: list = "; name

    list = CreateObject("roAssociativeArray")
    list.head = invalid
    list.tail = invalid
    list.size = 0
    list.name = name

    list.addHead = addHeadElement
    list.addTail = addTailElement
    list.add = list.addTail
    list.push = list.addTail
    list.insert = insertElement
    list.insertByName = insertElementByName
    list.delete = deleteElementByIndex
    list.deleteItem = deleteElementByData
    list.contains = containsElement
    list.indexOf = indexOfElementByData
    list.clear = clearList
    'list.count = getListCount
    list.count = function()
        return m.size
    end function
    list.get = getElementByIndex
    list.getArray = toArray
    list.getHead = getHeadElement
    list.getTail = getTailElement
    list.getByName = getElementByName
    list.createElement = createElementObject

    list.isEmpty = function ()
        return (m.size <= 0)
    end function

    return list
end function

' ****************************************************************
'
' list count 
'
' ****************************************************************
function getListCount() as integer
    'print "getListCount entry: list = "; m.name

    return m.size
end function

' ****************************************************************
'
' create an element object
'
' ****************************************************************
function createElementObject(obj as object) as object
    'print "createElementObject entry: list = "; m.name

    if m.head = invalid then
        'print "createElementObject: head invalid"
    end if

    element = CreateObject("roAssociativeArray")
    element.data = obj
    element.next = invalid
    element.previous = invalid

    return element
end function

' ****************************************************************
'
' add element to list tail
'
' ****************************************************************
sub addTailElement(obj as object)
    'print "addTailElement entry: list = "; m.name; " obj.name = "; obj.name

    if m.head = invalid then
        'print "addTailElement: head invalid"
    end if

    element = m.createElement(obj)
    
    if m.head = invalid then
        m.head = element
    end if

    if not m.tail = invalid then
        m.tail.next = element
        element.previous = m.tail
    end if

    m.tail = element
    m.size = m.size + 1

    'print "addTailElement exit: head name = "; m.head.data.name
end sub

' ****************************************************************
'
' add element to list head
'
' ****************************************************************
sub addHeadElement(obj as object)
    'print "addHeadElement entry: list = "; m.name; " obj.name = "; obj.name

    if m.head = invalid then
        'print "addHeadElement: head invalid"
    end if

    element = m.createElement(obj)
    
    if m.head = invalid then
        'print "head is invalid"
        m.head = element
        m.tail = element
        m.size = 1
        return
    end if

    m.head.previous = element
    element.next = m.head
    m.head = element
    
    m.size = m.size + 1
    'print "addHeadElement exit: after head.name = "; m.head.data.name; " size = "; m.size
end sub

' ****************************************************************
'
' insert element to list at given index
'
' ****************************************************************
sub insertElement(index as integer, obj as object)
    'print "insertElement entry: list = "; m.name; " index = "; index; " size = "; m.size; " obj.name = "; obj.name

    if index > m.size then
        return
    end if

    if index = 0 or m.head = invalid then
        m.addHead(obj)
        return
    end if

    element = m.createElement(obj)
   
    cur = m.head
    for pos = 0 to index - 1
        cur = cur.next
    end for

    if not cur.previous = invalid then
        cur.previous.next = element
    end if

    element.previous = cur.previous
    element.next = cur
    cur.previous = element

    m.size = m.size + 1

    return
end sub

' ****************************************************************
'
' insert element by name member of element
'
' ****************************************************************
sub insertElementByName(obj as object)
    'print "insertElementByName entry: list = "; m.name; " name = "; obj.name

    if m.head = invalid then
        'print "insertElementByName: head invalid"
    end if

    if m.head = invalid or obj.compareNameTo(m.head.data) <= 0 then
        m.addHead(obj)
        return
    end if

    element = m.createElement(obj)
   
    cur = m.head
    while not cur = invalid
        if obj.compareNameTo(cur.data) <= 0 then 
            'print "insertElementByName: "; obj.name; " < "; cur.data.name
            cur.previous.next = element
            element.previous = cur.previous
            element.next = cur
            cur.previous = element
            m.size = m.size + 1
            return
        end if
        cur = cur.next
    end while

    if cur = invalid then
        'print "insertElementByName: cur = invalid"
        m.add(obj)
    end if

    return
end sub

' ****************************************************************
'
' delete element at given index
'
' ****************************************************************
sub deleteElementByIndex(index as integer)
    'print "deleteElement entry: list = "; m.name; " index = "; index

    if m.head = invalid or index > m.size then
        return
    end if

    if index = 0 then
        if m.size = 1 then
            m.head.data = invalid
            m.head = invalid
            m.tail = invalid
            m.size = 0
            return
        end if
        
        tmp = m.head 
        m.head = m.head.next
        m.head.previous = invalid
        clearElement(tmp)
        return
    end if
    
    cur = m.head
    while not index = 0
        cur = cur.next
        index = index - 1
    end while

    cur.previous.next = cur.next
    if not cur.next = invalid then
        cur.next.previous = cur.previous
    end if

    clearElement(cur)
end sub

' ****************************************************************
'
' delete element with given data
'
' ****************************************************************
sub deleteElementByData(data as object)
    'print "deleteElementByData entry: list = "; m.name; " index = "; index

    if m.size = 0 then
        return
    end if

    if m.head.data = data then
        m.head.data = invalid
        if not m.head.next = invalid then
            m.head.next.previous = invalid
        end if
        m.head = m.head.next

        if m.size = 1 then
            m.tail = invalid
        end if

        m.size = m.size - 1
        return
    end if

    cur = m.head
    while not cur = invalid
        if cur.data.isEqualTo(obj) then
            cur.previous.next = cur.next
            if not cur.next = invalid then
                cur.next.previous = cur.previous
            end if
            m.size = m.size - 1

            return
        end if

        cur = cur.next
    end while
end sub

' ****************************************************************
'
' clear element members (for gc)
'
' ****************************************************************
sub clearElement(e as object)
    'print "clearElement entry: list = "; m.name

    e.next = invalid
    e.prev = invalid
end sub

' ****************************************************************
'
' check if list contains given element 
'
' ****************************************************************
function containsElement(obj as object) as boolean
    'print "containsElement entry: list = "; m.name

    if m.size = 0 then
        return false
    end if

    cur = m.head
    while not cur = invalid
        if cur.data = obj then
            return true
        end if
        cur = cur.next
    end while

    return false
end function

' ****************************************************************
'
' return index of given element
'
' ****************************************************************
function indexOfElementByData(obj as object) as integer
    'print "indexOfElement entry: list = "; m.name

    if m.size = 0 then
        return -1
    end if

    cur = m.head
    i = 0
    while not cur = invalid
        if cur.data.isEqualTo(obj) then
            return i
        end if

        cur = cur.next
        i = i + 1   
    end while

    return -1
end function

' ****************************************************************
'
' return element at given index
'
' ****************************************************************
function getElementByIndex(index as integer) as object
    'print "getElementByIndex entry: list = "; m.name; " index ="; index; " m.size ="; m.size

    if index >= m.size then
        return invalid
    end if

    cur = m.head
    for i = 1 to index
        cur = cur.next
    end for

    'print "getElementByIndex exit: cur.data.name = "; cur.data.name; " head = "; m.head.data.name

    return cur.data
end function

' ****************************************************************
'
' return head element
'
' ****************************************************************
function getHeadElement() as object
    'print "getHeadElement entry: list = "; m.name

    if m.head = invalid then
        return invalid
    end if

    return m.head.data
end function

' ****************************************************************
'
' return tail element
'
' ****************************************************************
function getTailElement() as object
    'print "getTailElement entry: list = "; m.name

    if m.tail = invalid then
        return invalid
    end if

    return m.tail.data
end function

' ****************************************************************
'
' get element by name
'        
' ****************************************************************
function getElementByName(name as string) as object
    'print "getElementByName entry: list = "; m.name; " name = "; name

    cur = m.head
    while not cur = invalid
        if cur.data.name = name then
            return cur.data
        end if
        cur = cur.next
    end while

    return invalid
end function

' ****************************************************************
'
' clear list 
'
' ****************************************************************
sub clearList()
    'print "clearList entry: list = "; m.name

    m.size = 0
    m.head = invalid
    m.tail = invalid
end sub

' ****************************************************************
'
' return list as array
'
' ****************************************************************
function toArray() as object
    'print "toArray entry: list = "; m.name

    if m.size = 0 then
        return invalid
    end if

    array = CreateObject("roList")
    cur = m.head
    while not cur = invalid
        ''print "toArray: name = "; cur.data.name
        array.addTail(cur.data)
        cur = cur.next
    end while

    return array
end function
