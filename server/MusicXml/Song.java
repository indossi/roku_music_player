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

import org.w3c.dom.*;

public class Song implements Comparable<Song> {
    public String name;
    public int trackId;
    public String format;
    public int length;
    public String actualFilename;
    public String actualUrl;
    public String symFilename;
    public String symUrl;
    public Album album;
    public Artist artist;
    public int listIndex;
    
    public Song() {
    	
    }
    public Song(Element element) {
    	name = element.getAttribute(MusicXml.nameTag);
    	trackId = Integer.parseInt(element.getAttribute(MusicXml.trackTag));
    	format = element.getAttribute(MusicXml.formatTag);
    	length = Integer.parseInt(element.getAttribute(MusicXml.lengthTag));
    	symUrl = element.getAttribute(MusicXml.urlTag);
    	listIndex = Integer.parseInt(element.getAttribute(MusicXml.indexTag));
    }
    
    public int compareTo(Song o) {
	    return(name.compareTo(o.name));
	}
    
    public Element createAlbumElement(Document dom) {
    	Element songElement = dom.createElement(MusicXml.songTag);
    	
		songElement.setAttribute(MusicXml.nameTag, name);
		songElement.setAttribute(MusicXml.indexTag, Integer.toString(listIndex));
		songElement.setAttribute(MusicXml.trackTag, Integer.toString(trackId));
		songElement.setAttribute(MusicXml.formatTag, format);
		songElement.setAttribute(MusicXml.lengthTag, Integer.toString(length));
		songElement.setAttribute(MusicXml.urlTag, symUrl);
		
		return songElement;
    }
    
	public int compareTrackId(Song o) {
		int value = 0;
		
		if (trackId < o.trackId)
			value = -1;
		else if (trackId > o.trackId)
			value = 1;
		
		return(value);
	}
}
