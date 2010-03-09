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

import java.io.*;
import java.util.*;

import javax.xml.parsers.*;

import org.w3c.dom.*;
import org.xml.sax.*;

import com.sun.org.apache.xml.internal.serialize.*;

public class MusicXml {
    public final String appName = "MusicXml";
    
	public String baseRemoteUrl;// i.e. http://192.168.0.147/pub
	public String baseMusicDir;
	public String baseSymDir;
	public String hostUrl;
	
	public ArrayList<Song> songsList;
	public ArrayList<Album> albumsList;
	public ArrayList<Artist> artistsList;
	
	public final String xmlBaseFileName = "music.xml";
	public String xmlOutputFileName;
	public BufferedReader xmlInStream;
	
	public static final String musicTag = "music";
	public static final String artistsCountTag = "artists";
	public static final String albumsCountTag = "albums";
	public static final String songsCountTag = "songs";
	public static final String artistTag = "artist";
	public static final String albumTag = "album";
	public static final String artTag = "art";
	public static final String songTag = "song";
	public static final String nameTag = "name";
	public static final String trackTag = "track";
	public static final String formatTag = "format";
	public static final String urlTag = "url";
	public static final String lengthTag = "length";
	public static final String indexTag = "index";
	
	public static final String ampersand = "&";
	public static final String ampersandReplacement = "and";
	public static final String space = " ";
	public static final String spaceReplacement = "_";
	public static final String pound = "#";
	public static final String poundReplacement = "";
	
	public boolean verboseFlag = false;
	
	public MusicXml() {
	    songsList = new ArrayList<Song>();
	    albumsList = new ArrayList<Album>();
	    artistsList = new ArrayList<Artist>();
	}
	
	public void deleteDir(File dir) {
	    if (dir.isDirectory()) {
		    File[] files = dir.listFiles();
		    for (int i = 0; i < files.length; i++)
		        deleteDir(files[i]);
   		}
		
	    dir.delete();
	}

	public void createSymLink(String target, String link) {
	    ProcessBuilder pb;
	    	    
	    pb = new ProcessBuilder("ln", "-s", target, link);
	    pb.redirectErrorStream(true);
	    
	    try {
			pb.start();
		} catch (IOException e) {
		    System.out.printf("createSymLink: IOException\n");
		}
	}
	
	private void parseXmlFile(String fileName) {
	    Element rootElement, artistElement, albumElement, songElement;
	    NodeList artistsNodes, albumsNodes, songsNodes;
	    Artist artist;
	    Album album;
	    Song song;
	    int artistsCount, albumsCount, songsCount;
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		Document domIn = null;
		
		try {
		    DocumentBuilder db = dbf.newDocumentBuilder();
			
			domIn = db.parse(fileName);
		} catch (ParserConfigurationException pce) {
		    System.err.printf("parseXmlFile: ParserConfigurationException\n");
		} catch (SAXException se) {
		    System.err.printf("parseXmlFile: SAXException\n");
		} catch (IOException ioe) {
		    System.err.printf("parseXmlFile: IOException\n");
		}
		
		// get root element
		rootElement = domIn.getDocumentElement();
		
		artistsCount = Integer.parseInt(rootElement.getAttribute(artistsCountTag));
		artist = new Artist("null");
		for (int i = 0; i < artistsCount; i++)
			artistsList.add(artist);
		
		albumsCount = Integer.parseInt(rootElement.getAttribute(albumsCountTag));
		album = new Album("null");
        for (int i = 0; i < albumsCount; i++)
        	albumsList.add(album);
		
		songsCount = Integer.parseInt(rootElement.getAttribute(songsCountTag));
        song = new Song();
        for (int i = 0; i < songsCount; i++)
        	songsList.add(song);
        
		artistsNodes = rootElement.getElementsByTagName(artistTag);
        if (artistsNodes != null) {
        	for (int x = 0; x < artistsNodes.getLength(); x++) {
        		artistElement = (Element)artistsNodes.item(x);
        		artist = new Artist(artistElement);
        		artistsList.set(artist.listIndex, artist);
        		
        		albumsNodes = artistElement.getElementsByTagName(albumTag);
        		if (albumsNodes != null) {
        			for (int y = 0; y < albumsNodes.getLength(); y++) {
        			    albumElement = (Element)albumsNodes.item(y);
        			    album = new Album(albumElement);
        			    albumsList.set(album.listIndex, album);
        			    artist.albumList.add(album);
        			    
        			    songsNodes = albumElement.getElementsByTagName(songTag);
        			    for (int z = 0; z < songsNodes.getLength(); z++) {
        			    	songElement = (Element)songsNodes.item(z);
        			    	song = new Song(songElement);
        			    	songsList.set(song.listIndex, song);
        			    	album.songList.add(song);
        			    }
        			}
        		}
			    Collections.sort(artist.albumList);
            }
        }
	}
			
	public void init(Boolean updateFlag) {
		baseMusicDir = baseRemoteUrl.substring(baseRemoteUrl.lastIndexOf('/'));
		xmlOutputFileName = baseMusicDir + "/" + xmlBaseFileName;
		File outFile = new File(xmlOutputFileName );
		
		if (outFile.exists()) {
			if (updateFlag)
		        parseXmlFile(xmlOutputFileName);
				
			outFile.delete();
		}
				
		baseSymDir = baseMusicDir + "/" + "music";
		File baseSymFile = new File(baseSymDir);

		if (baseSymFile.exists())
			deleteDir(baseSymFile);

		baseSymFile.mkdir();
    }
	
	public void createXmlFile() {
		Artist artist;
		ListIterator<Artist> artistIterator;
		int index;
	    Document domOut;
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		
		try {
		    DocumentBuilder db = dbf.newDocumentBuilder();

			domOut = db.newDocument();
		} catch (ParserConfigurationException e) {
			System.out.printf("init: ParseConfigurationException");
			return;
		}
		
		Collections.sort(artistsList);
		for (index  = 0; index < artistsList.size(); index++)
		    artistsList.get(index).listIndex = index;
	
		Collections.sort(albumsList);
		for (index = 0; index < albumsList.size(); index++)
			albumsList.get(index).listIndex = index;
		
		Collections.sort(songsList);
		for (index = 0; index < songsList.size(); index++)
			songsList.get(index).listIndex = index + 1;
				
		// generate db file
		Element rootElement = domOut.createElement(musicTag);
		rootElement.setAttribute(artistsCountTag, Integer.toString(artistsList.size()));
		rootElement.setAttribute(albumsCountTag, Integer.toString(albumsList.size()));
		rootElement.setAttribute(songsCountTag, Integer.toString(songsList.size()));
        domOut.appendChild(rootElement);
		
		artistIterator = artistsList.listIterator();
		while (artistIterator.hasNext()) {
			artist = artistIterator.next();
			rootElement.appendChild(artist.createArtistElement(domOut));
		}

		try {
			OutputFormat format = new OutputFormat(domOut);
			format.setIndenting(true);

			XMLSerializer serializer = new XMLSerializer(
			    new FileOutputStream(new File(xmlOutputFileName)), format);

			serializer.serialize(domOut);
		} catch (IOException ie) {
			System.err.printf("createXmlFile: IOException\n");
		}
		
		System.out.printf("\n%s: added %d artists, %d albums, %d songs to xml file %s\n",
			appName, artistsList.size(), albumsList.size(), songsList.size(),
			xmlOutputFileName);
	}
	
	public static void main(String[] args) {
        MusicXml music = new MusicXml();
        ArrayList<String> wList = new ArrayList<String>();
        WmaMusic w;
        ListIterator<String> iterator;
        Boolean updateFlag = false;
        
        for (int i = 0; i < args.length; i++) {
		    if (args[i].equals("--wmadir")) {
		    	wList.add(args[++i]);
		    	System.out.printf("%s: wma dir = %s\n",
		    	    music.appName, args[i]);
		    } else if (args[i].equals("--url")) {
		    	String url = args[++i];
		    	music.baseRemoteUrl = url;
		    	music.hostUrl = url.substring(0, url.indexOf("/", 7));
		    } else if (args[i].equals("--update")) {
		    	updateFlag = true;
		    } else if (args[i].equals("--verbose")) {
		    	music.verboseFlag = true;
		    }
		}
		
		music.init(updateFlag);
        
        iterator = wList.listIterator();
        while (iterator.hasNext()) {
        	w = new WmaMusic(iterator.next(), music);
        	w.process();
        }
        
        music.createXmlFile();
	}
}
