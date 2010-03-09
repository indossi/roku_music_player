/*
 * Copyright (c) 2010 Indossi Ruscelli (indossiruscelli@gmail.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

package app;

import java.util.*;

import org.w3c.dom.*;

public class Album implements Comparable<Album> {
    public String name;
    public String actualArtFilename;
    public String actualArtUrl;
    public String symArtFilename;
    public String symArtUrl;
    public int listIndex;
    public ArrayList<Song> songList;
   
    public Album(String name) {
    	this.name = name;
    	songList = new ArrayList<Song>();
    }
    public Album(Element element) {
    	name = element.getAttribute(MusicXml.nameTag);
    	listIndex = Integer.parseInt(element.getAttribute(MusicXml.indexTag));
    	symArtUrl = element.getAttribute(MusicXml.artTag);
        songList = new ArrayList<Song>();
    }
    
    public Element createAlbumElement(Document dom) {
    	ListIterator<Song> iterator;
    	Song song;
    	Element albumElement = dom.createElement(MusicXml.albumTag);
    	
		albumElement.setAttribute(MusicXml.nameTag, name);
		albumElement.setAttribute(MusicXml.indexTag, Integer.toString(listIndex));
		albumElement.setAttribute(MusicXml.artTag, symArtUrl);
		
		iterator = songList.listIterator();
		while (iterator.hasNext()) {
			song = iterator.next();
			albumElement.appendChild(song.createAlbumElement(dom));
		}
		
		return albumElement;
    }
    
	public int compareTo(Album o) {
	    return(name.compareTo(o.name));
	}
}
