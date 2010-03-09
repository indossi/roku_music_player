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

public class Artist implements Comparable<Artist> {
	public String name;
    public ArrayList<Album> albumList;
    public String actualFilename;
    public String symFilename;
    public int listIndex;
     
    public Artist(String name) {
    	this.name = name;
    	albumList = new ArrayList<Album>();
    }
    public Artist(Element element) {
    	name = element.getAttribute(MusicXml.nameTag);
    	listIndex = Integer.parseInt(element.getAttribute(MusicXml.indexTag));
    	albumList = new ArrayList<Album>();
    }
    
    public Element createArtistElement(Document dom) {
    	ListIterator<Album> iterator;
    	Album album;
    	Element artistElement = dom.createElement(MusicXml.artistTag);
    	
		artistElement.setAttribute(MusicXml.nameTag, name);
		artistElement.setAttribute(MusicXml.indexTag, Integer.toString(listIndex));
		
		iterator = albumList.listIterator();
		while (iterator.hasNext()) {
			album = iterator.next();
			artistElement.appendChild(album.createAlbumElement(dom));
		}
		
		return artistElement;
    }
    
    public int compareTo(Artist o) {
	    return(name.compareTo(o.name));
	}
}
